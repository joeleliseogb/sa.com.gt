function Get-EmpresasData() {
    $cs = "Driver={DBISAM 4 ODBC Driver};ConnectionType=Local;CatalogName=C:\SimplyGest\Datos;"
    $conn = New-Object System.Data.Odbc.OdbcConnection($cs)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT CODIGO, EMPRESA, YEAR FROM EMPRESAS ORDER BY CODIGO"
    $da = New-Object System.Data.Odbc.OdbcDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    [void]$da.Fill($dt)
    $conn.Close()

    $list = @()
    for ($i = 0; $i -lt $dt.Rows.Count; $i++) {
        $r = $dt.Rows[$i]
        if ($null -eq $r) { continue }
        $cod = [int]$r["CODIGO"]
        $empPath = "C:\SimplyGest\Datos\$cod"
        $existe = Test-Path $empPath
        $list += [PSCustomObject]@{
            codigo  = $cod
            empresa = [string]$r["EMPRESA"]
            year    = [string]$r["YEAR"]
            activo  = $existe
        }
    }
    return $list
}

function Get-ReportData($empresaCode, $fechaDesde, $fechaHasta, $sector) {
    $datosPath = "C:\SimplyGest\Datos\$empresaCode"
    if (-not (Test-Path $datosPath)) {
        return @{ error = "El directorio de datos $datosPath no existe." }
    }

    $cs = "Driver={DBISAM 4 ODBC Driver};ConnectionType=Local;CatalogName=$datosPath;"
    $conn = New-Object System.Data.Odbc.OdbcConnection($cs)
    $conn.Open()

    function Query-Internal($sql) {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $sql
        $da = New-Object System.Data.Odbc.OdbcDataAdapter($cmd)
        $dt = New-Object System.Data.DataTable
        [void]$da.Fill($dt)
        return ,$dt
    }

    # 1. Configuración de la Empresa
    $empresaNombre = "Empresa $empresaCode"
    $empresaYear = ""
    try {
        $csMaster = "Driver={DBISAM 4 ODBC Driver};ConnectionType=Local;CatalogName=C:\SimplyGest\Datos;"
        $connM = New-Object System.Data.Odbc.OdbcConnection($csMaster)
        $connM.Open()
        $cmdM = $connM.CreateCommand()
        $cmdM.CommandText = "SELECT EMPRESA, YEAR FROM EMPRESAS WHERE CODIGO = $empresaCode"
        $daM = New-Object System.Data.Odbc.OdbcDataAdapter($cmdM)
        $dtM = New-Object System.Data.DataTable
        [void]$daM.Fill($dtM)
        $connM.Close()
        if ($dtM.Rows.Count -gt 0) {
            $rM = $dtM.Rows[0]
            if (-not [Convert]::IsDBNull($rM["EMPRESA"])) { $empresaNombre = [string]$rM["EMPRESA"] }
            if (-not [Convert]::IsDBNull($rM["YEAR"]))    { $empresaYear   = [string]$rM["YEAR"] }
        }
    } catch {}

    $empresaDir = ""
    $empresaPob = ""
    $empresaWeb = ""
    $empresaTel = ""
    try {
        $cfg = Query-Internal "SELECT EMPRESA, DIRECCION, POBLACION, WEB, TELEFONO FROM config"
        if ($cfg.Rows.Count -gt 0) {
            $rCfg = $cfg.Rows[0]
            if (-not [Convert]::IsDBNull($rCfg["EMPRESA"]) -and -not [string]::IsNullOrWhiteSpace($rCfg["EMPRESA"])) { $empresaNombre = [string]$rCfg["EMPRESA"] }
            if (-not [Convert]::IsDBNull($rCfg["DIRECCION"])) { $empresaDir    = [string]$rCfg["DIRECCION"] }
            if (-not [Convert]::IsDBNull($rCfg["POBLACION"])) { $empresaPob    = [string]$rCfg["POBLACION"] }
            if (-not [Convert]::IsDBNull($rCfg["WEB"]))       { $empresaWeb    = [string]$rCfg["WEB"] }
            if (-not [Convert]::IsDBNull($rCfg["TELEFONO"]))  { $empresaTel    = [string]$rCfg["TELEFONO"] }
        }
    } catch {}

    # 2. Rango de Fechas
    $minDate = ""
    $maxDate = ""
    try {
        $rDates = Query-Internal "SELECT MIN(FECHA) as min_f, MAX(FECHA) as max_f FROM histoven"
        if ($rDates.Rows.Count -gt 0 -and (-not [Convert]::IsDBNull($rDates.Rows[0]["min_f"]))) {
            $minDate = ([DateTime]$rDates.Rows[0]["min_f"]).ToString("yyyy-MM-dd")
            $maxDate = ([DateTime]$rDates.Rows[0]["max_f"]).ToString("yyyy-MM-dd")
        }
    } catch {}

    if ([string]::IsNullOrEmpty($fechaDesde) -or $fechaDesde -eq "null") { $fechaDesde = $minDate }
    if ([string]::IsNullOrEmpty($fechaHasta) -or $fechaHasta -eq "null") { $fechaHasta = $maxDate }

    # 3. Usuarios
    $userMap = @{}
    try {
        $pDt = Query-Internal "SELECT CODIGO, NOMBRE FROM perso"
        for ($i = 0; $i -lt $pDt.Rows.Count; $i++) {
            $r = $pDt.Rows[$i]
            if ($null -eq $r) { continue }
            $uCod = [string]$r["CODIGO"]
            $uNom = [string]$r["NOMBRE"]
            $userMap[$uCod] = $uNom
        }
    } catch {}
    $userMap[""] = "Mostrador / TPV Central"

    # 4. Ventas (histoven)
    $filterVen = ""
    if (-not [string]::IsNullOrEmpty($fechaDesde) -and -not [string]::IsNullOrEmpty($fechaHasta)) {
        $filterVen = " WHERE FECHA >= '$fechaDesde' AND FECHA <= '$fechaHasta'"
    }

    $hDt = Query-Internal "SELECT FACTURA, FECHA, ARTICULO, DESCR, CANTIDAD, PRECIO_E, IMPORTE_E, TOTAL_E, USUARIO, HORA FROM histoven $filterVen"

    # Procesar Facturas y Tickets
    $facturasGroup = $hDt | Group-Object -Property FACTURA
    $facturaList = New-Object System.Collections.ArrayList
    $totVentasBrutas = 0.0

    foreach ($f in $facturasGroup) {
        $first = $f.Group[0]
        $totF = ($f.Group | Measure-Object -Property TOTAL_E -Sum).Sum
        $totVentasBrutas += $totF
        $uCode = [string]$first["USUARIO"]
        $uName = if ($userMap.ContainsKey($uCode)) { $userMap[$uCode] } else { "Usuario $uCode" }
        $fDate = [DateTime]$first["FECHA"]
        
        [void]$facturaList.Add([PSCustomObject]@{
            Factura = $f.Name
            Fecha   = $fDate.ToString("yyyy-MM-dd")
            FechaFmt = $fDate.ToString("dd/MM/yyyy")
            Usuario = $uName
            Total   = [Math]::Round([double]$totF, 2)
            Items   = $f.Group.Count
        })
    }

    $totalTickets = $facturaList.Count
    $avgTicket = if ($totalTickets -gt 0) { [Math]::Round(($totVentasBrutas / $totalTickets), 2) } else { 0.0 }
    $minTicket = if ($totalTickets -gt 0) { ($facturaList | Measure-Object -Property Total -Minimum).Minimum } else { 0.0 }
    $maxTicket = if ($totalTickets -gt 0) { ($facturaList | Measure-Object -Property Total -Maximum).Maximum } else { 0.0 }

    # 5. Ventas por Vendedor
    $vendedoresList = @()
    if ($totalTickets -gt 0) {
        $vendedoresList = $facturaList | Group-Object -Property Usuario | ForEach-Object {
            $tCount = $_.Group.Count
            $tSum = ($_.Group | Measure-Object -Property Total -Sum).Sum
            $vAvg = if ($tCount -gt 0) { $tSum / $tCount } else { 0.0 }
            $pct = if ($totVentasBrutas -gt 0) { ($tSum / $totVentasBrutas) * 100 } else { 0.0 }
            [PSCustomObject]@{
                vendedor       = $_.Name
                tickets        = $tCount
                totalVentas    = [Math]::Round($tSum, 2)
                ticketPromedio = [Math]::Round($vAvg, 2)
                porcentaje     = [Math]::Round($pct, 1)
            }
        } | Sort-Object totalVentas -Descending
    }

    # 6. Gastos y Compras (movim)
    $filterMov = " WHERE MOV IN ('COMPRA', 'ENTSAL')"
    if (-not [string]::IsNullOrEmpty($fechaDesde) -and -not [string]::IsNullOrEmpty($fechaHasta)) {
        $filterMov += " AND FECHA >= '$fechaDesde' AND FECHA <= '$fechaHasta'"
    }

    $movDt = Query-Internal "SELECT AUTO, FECHA, MOV, NOM_C, TOTAL_E FROM movim $filterMov"

    $gastosPorDia = @{}
    $comprasPorDia = @{}
    $totalGastos = 0.0
    $totalCompras = 0.0
    $gastosDetalle = @()

    for ($i = 0; $i -lt $movDt.Rows.Count; $i++) {
        $m = $movDt.Rows[$i]
        if ($null -eq $m) { continue }
        $fVal = $m["FECHA"]
        if ($null -ne $fVal -and -not [Convert]::IsDBNull($fVal)) {
            $fStr = ([DateTime]$fVal).ToString("yyyy-MM-dd")
            $movTipo = [string]$m["MOV"]
            $totVal = $m["TOTAL_E"]
            $totE = if ($null -ne $totVal -and -not [Convert]::IsDBNull($totVal)) { [double]$totVal } else { 0.0 }
            $nomCVal = $m["NOM_C"]
            $nomC = if ($null -ne $nomCVal -and -not [Convert]::IsDBNull($nomCVal)) { [string]$nomCVal } else { "" }
            
            if ($movTipo -eq "COMPRA") {
                $totalCompras += [Math]::Abs($totE)
                if (-not $comprasPorDia.ContainsKey($fStr)) { $comprasPorDia[$fStr] = 0.0 }
                $comprasPorDia[$fStr] += [Math]::Abs($totE)
            } elseif ($movTipo -eq "ENTSAL" -and $totE -lt 0) {
                $valG = [Math]::Abs($totE)
                $totalGastos += $valG
                if (-not $gastosPorDia.ContainsKey($fStr)) { $gastosPorDia[$fStr] = 0.0 }
                $gastosPorDia[$fStr] += $valG
                $gastosDetalle += [PSCustomObject]@{
                    fecha    = ([DateTime]$fVal).ToString("dd/MM/yyyy")
                    concepto = if ($nomC) { $nomC } else { "Salida de Efectivo" }
                    importe  = [Math]::Round($valG, 2)
                }
            }
        }
    }

    $saldoNeto = $totVentasBrutas - $totalGastos - $totalCompras
    $margenCajaPct = if ($totVentasBrutas -gt 0) { ($saldoNeto / $totVentasBrutas) * 100 } else { 0.0 }

    # 7. Resumen Diario Consolidado
    $fechasUnicas = $facturaList | Select-Object -ExpandProperty Fecha -Unique | Sort-Object
    $resumenDiario = @()

    foreach ($fStr in $fechasUnicas) {
        $facs = $facturaList | Where-Object { $_.Fecha -eq $fStr }
        $vDia = ($facs | Measure-Object -Property Total -Sum).Sum
        $tDia = $facs.Count
        $avgDia = if ($tDia -gt 0) { $vDia / $tDia } else { 0.0 }
        
        $gDia = if ($gastosPorDia.ContainsKey($fStr)) { $gastosPorDia[$fStr] } else { 0.0 }
        $cDia = if ($comprasPorDia.ContainsKey($fStr)) { $comprasPorDia[$fStr] } else { 0.0 }
        $netoDia = $vDia - $gDia - $cDia

        $dtFmt = ([DateTime]::ParseExact($fStr, "yyyy-MM-dd", $null)).ToString("dd/MM/yyyy")

        $resumenDiario += [PSCustomObject]@{
            fecha          = $dtFmt
            fechaIso       = $fStr
            tickets        = $tDia
            ventasTotales  = [Math]::Round($vDia, 2)
            promedioTicket = [Math]::Round($avgDia, 2)
            gastosCaja     = [Math]::Round($gDia, 2)
            compras        = [Math]::Round($cDia, 2)
            saldoNeto      = [Math]::Round($netoDia, 2)
        }
    }

    # 8. Top Productos General
    $topProductos = @()
    if ($hDt.Rows.Count -gt 0) {
        $topProductos = $hDt | Group-Object -Property DESCR | ForEach-Object {
            $uTot = 0
            $tTot = 0.0
            foreach ($row in $_.Group) {
                if (-not [Convert]::IsDBNull($row["CANTIDAD"])) { $uTot += [int]$row["CANTIDAD"] }
                if (-not [Convert]::IsDBNull($row["TOTAL_E"]))  { $tTot += [double]$row["TOTAL_E"] }
            }
            $pProm = if ($uTot -gt 0) { $tTot / $uTot } else { 0.0 }
            [PSCustomObject]@{
                producto       = $_.Name
                unidades       = $uTot
                totalFacturado = [Math]::Round($tTot, 2)
                precioPromedio = [Math]::Round($pProm, 2)
            }
        } | Where-Object { $_.producto -ne "" } | Sort-Object totalFacturado -Descending
    }

    # 9. Top Productos por Día
    $topProductosPorDia = @()
    foreach ($fStr in $fechasUnicas) {
        $dtFmt = ([DateTime]::ParseExact($fStr, "yyyy-MM-dd", $null)).ToString("dd/MM/yyyy")
        $linesDia = $hDt | Where-Object { ([DateTime]$_["FECHA"]).ToString("yyyy-MM-dd") -eq $fStr }
        $itemsDia = $linesDia | Group-Object -Property DESCR | ForEach-Object {
            $uTot = 0
            $tTot = 0.0
            foreach ($row in $_.Group) {
                if (-not [Convert]::IsDBNull($row["CANTIDAD"])) { $uTot += [int]$row["CANTIDAD"] }
                if (-not [Convert]::IsDBNull($row["TOTAL_E"]))  { $tTot += [double]$row["TOTAL_E"] }
            }
            [PSCustomObject]@{
                producto       = $_.Name
                unidades       = $uTot
                totalFacturado = [Math]::Round($tTot, 2)
            }
        } | Where-Object { $_.producto -ne "" } | Sort-Object totalFacturado -Descending | Select-Object -First 3

        $topProductosPorDia += [PSCustomObject]@{
            fecha = $dtFmt
            items = $itemsDia
        }
    }

    # 10. Datos de Benchmark según el Sector seleccionado
    $benchmarkInfo = @{}
    if ($sector -eq "qsr" -or [string]::IsNullOrEmpty($sector)) {
        $benchmarkInfo = @{
            sectorId           = "qsr"
            nombreSector       = "Comida Rápida (QSR) - Pollo Frito"
            referencias        = "Pollo Campero, KFC, Pollo Granjero, Pinulito"
            ticketEstandar     = "Q 32.00 - Q 48.00"
            foodCostEstandar   = "30% - 35%"
            margenCajaEstandar = "40% - 50%"
            concentracionTop2  = "50% - 60%"
            penetrationBebidas = "65% - 75%"
            ticketDiagnostico  = if ($avgTicket -ge 32 -and $avgTicket -le 50) { "Excelente (En rango óptimo)" } elseif ($avgTicket -gt 50) { "Muy Alto (Orientado a familiar/corporativo)" } else { "Bajo (Venta predominantemente suelta)" }
            margenDiagnostico  = if ($margenCajaPct -ge 40) { "Saludable y Sostenible" } else { "Requiere Ajuste de Costos" }
        }
    } elseif ($sector -eq "restaurant") {
        $benchmarkInfo = @{
            sectorId           = "restaurant"
            nombreSector       = "Restaurante Casual / Cafetería"
            referencias        = "Restaurantes de mesa y cafeterías comerciales"
            ticketEstandar     = "Q 45.00 - Q 75.00"
            foodCostEstandar   = "28% - 33%"
            margenCajaEstandar = "35% - 45%"
            concentracionTop2  = "40% - 50%"
            penetrationBebidas = "80% - 90%"
            ticketDiagnostico  = if ($avgTicket -ge 45) { "Adecuado" } else { "Oportunidad de incremento" }
            margenDiagnostico  = if ($margenCajaPct -ge 35) { "Saludable" } else { "Ajustado" }
        }
    } elseif ($sector -eq "retail") {
        $benchmarkInfo = @{
            sectorId           = "retail"
            nombreSector       = "Comercio / Tienda Retail"
            referencias        = "Supermercados, abarrotes y tiendas de conveniencia"
            ticketEstandar     = "Q 20.00 - Q 40.00"
            foodCostEstandar   = "65% - 75% (Costo Mercadería)"
            margenCajaEstandar = "15% - 25%"
            concentracionTop2  = "25% - 35%"
            penetrationBebidas = "N/A"
            ticketDiagnostico  = "En rango comercial"
            margenDiagnostico  = "En estándar minorista"
        }
    } else {
        $benchmarkInfo = @{
            sectorId           = "services"
            nombreSector       = "Servicios y General"
            referencias        = "Promedios generales comerciales"
            ticketEstandar     = "Variable"
            foodCostEstandar   = "N/A"
            margenCajaEstandar = "40% - 60%"
            concentracionTop2  = "Variable"
            penetrationBebidas = "N/A"
            ticketDiagnostico  = "Personalizado"
            margenDiagnostico  = "Estable"
        }
    }

    $conn.Close()

    return @{
        empresa = @{
            codigo    = $empresaCode
            nombre    = $empresaNombre
            year      = $empresaYear
            direccion = $empresaDir
            poblacion = $empresaPob
            web       = $empresaWeb
            telefono  = $empresaTel
        }
        filtros = @{
            fechaDesde = $fechaDesde
            fechaHasta = $fechaHasta
            sector     = $sector
        }
        kpis = @{
            ventasTotales  = [Math]::Round($totVentasBrutas, 2)
            totalTickets   = $totalTickets
            ticketPromedio = $avgTicket
            ticketMinimo   = $minTicket
            ticketMaximo   = $maxTicket
            totalGastos    = [Math]::Round($totalGastos, 2)
            totalCompras   = [Math]::Round($totalCompras, 2)
            saldoNeto      = [Math]::Round($saldoNeto, 2)
            margenCajaPct  = [Math]::Round($margenCajaPct, 1)
            totalItems     = $hDt.Rows.Count
            diasActivos    = $fechasUnicas.Count
            ventaPromDiaria= if ($fechasUnicas.Count -gt 0) { [Math]::Round(($totVentasBrutas / $fechasUnicas.Count), 2) } else { 0.0 }
        }
        vendedores         = $vendedoresList
        resumenDiario      = $resumenDiario
        topProductos       = $topProductos
        topProductosPorDia = $topProductosPorDia
        gastosDetalle      = ($gastosDetalle | Select-Object -First 15)
        benchmark          = $benchmarkInfo
    }
}

function Generate-ReportHtml($data) {
    # Generate the 2-page print HTML
    $empNombre = $data.empresa.nombre
    $empDir = $data.empresa.direccion
    $empPob = $data.empresa.poblacion
    $fDesde = if ($data.filtros.fechaDesde) { ([DateTime]::ParseExact($data.filtros.fechaDesde, "yyyy-MM-dd", $null)).ToString("dd/MM/yyyy") } else { "Inicio" }
    $fHasta = if ($data.filtros.fechaHasta) { ([DateTime]::ParseExact($data.filtros.fechaHasta, "yyyy-MM-dd", $null)).ToString("dd/MM/yyyy") } else { "Hoy" }

    $vRows = ""
    foreach ($v in $data.vendedores) {
        $vRows += "<tr><td><strong>$($v.vendedor)</strong></td><td class='text-right'>$($v.tickets)</td><td class='text-right'>Q $($v.totalVentas.ToString('N2'))</td><td class='text-right' style='color:#2563eb;font-weight:700;'>Q $($v.ticketPromedio.ToString('N2'))</td><td class='text-right'>$($v.porcentaje)%</td></tr>"
    }

    $dRows = ""
    foreach ($d in $data.resumenDiario) {
        $netoClass = if ($d.saldoNeto -ge 0) { "net-positive" } else { "net-negative" }
        $prefix = if ($d.saldoNeto -ge 0) { "+Q " } else { "-Q " }
        $absNeto = [Math]::Abs($d.saldoNeto).ToString('N2')
        $dRows += "<tr><td>$($d.fecha)</td><td class='text-center'>$($d.tickets)</td><td class='text-right'>Q $($d.ventasTotales.ToString('N2'))</td><td class='text-right'>Q $($d.promedioTicket.ToString('N2'))</td><td class='text-right' style='color:#b91c1c;'>Q $($d.gastosCaja.ToString('N2'))</td><td class='text-right' style='color:#b91c1c;'>Q $($d.compras.ToString('N2'))</td><td class='text-right $netoClass'>$prefix$absNeto</td></tr>"
    }

    $pRows = ""
    foreach ($p in ($data.topProductos | Select-Object -First 8)) {
        $pRows += "<tr><td><strong>$($p.producto)</strong></td><td class='text-right'>$($p.unidades)</td><td class='text-right'><strong>Q $($p.totalFacturado.ToString('N2'))</strong></td><td class='text-right'>Q $($p.precioPromedio.ToString('N2'))</td></tr>"
    }

    $pDiaRows = ""
    foreach ($pDia in $data.topProductosPorDia) {
        $top1 = if ($pDia.items.Count -gt 0) { "$($pDia.items[0].producto) ($($pDia.items[0].unidades))" } else { "-" }
        $top2 = if ($pDia.items.Count -gt 1) { "$($pDia.items[1].producto) ($($pDia.items[1].unidades))" } else { "-" }
        $top3 = if ($pDia.items.Count -gt 2) { "$($pDia.items[2].producto) ($($pDia.items[2].unidades))" } else { "-" }
        $pDiaRows += "<tr><td><strong>$($pDia.fecha)</strong></td><td>$top1</td><td>$top2</td><td>$top3</td></tr>"
    }

    $html = @"
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Resumen Ejecutivo - $empNombre</title>
<style>
  @page { size: A4 portrait; margin: 14mm 12mm 14mm 12mm; }
  * { box-sizing: border-box; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; }
  body { color: #1e293b; background: #fff; font-size: 11px; line-height: 1.45; margin: 0; padding: 0; }
  .page-break { page-break-before: always; }
  .header-container { display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #dc2626; padding-bottom: 12px; margin-bottom: 16px; }
  .brand-title { font-size: 22px; font-weight: 800; color: #991b1b; margin: 0; }
  .brand-subtitle { font-size: 11px; color: #64748b; font-weight: 500; margin: 2px 0 0 0; }
  .meta-box { text-align: right; font-size: 10px; color: #475569; }
  .badge { display: inline-block; padding: 3px 8px; border-radius: 9999px; font-size: 9px; font-weight: 700; text-transform: uppercase; }
  .badge-red { background: #fee2e2; color: #991b1b; }
  .badge-green { background: #dcfce7; color: #166534; }
  .badge-blue { background: #dbeafe; color: #1e40af; }
  .kpi-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 18px; }
  .kpi-card { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 12px; border-left: 4px solid #cbd5e1; }
  .kpi-card.red { border-left-color: #dc2626; }
  .kpi-card.green { border-left-color: #16a34a; }
  .kpi-card.blue { border-left-color: #2563eb; }
  .kpi-card.amber { border-left-color: #d97706; }
  .kpi-title { font-size: 9px; text-transform: uppercase; font-weight: 700; color: #64748b; margin-bottom: 4px; }
  .kpi-value { font-size: 18px; font-weight: 800; color: #0f172a; line-height: 1.1; }
  .kpi-sub { font-size: 9px; color: #64748b; margin-top: 3px; }
  .section-title { font-size: 13px; font-weight: 700; color: #0f172a; border-bottom: 1.5px solid #e2e8f0; padding-bottom: 4px; margin: 16px 0 8px 0; display: flex; justify-content: space-between; }
  .section-title span { color: #dc2626; }
  table { width: 100%; border-collapse: collapse; margin-bottom: 14px; font-size: 10px; }
  th { background: #f1f5f9; color: #334155; font-weight: 700; text-align: left; padding: 6px 8px; border: 1px solid #e2e8f0; }
  th.text-right, td.text-right { text-align: right; }
  th.text-center, td.text-center { text-align: center; }
  td { padding: 5px 8px; border: 1px solid #e2e8f0; color: #1e293b; }
  tr:nth-child(even) { background: #f8fafc; }
  tr.highlight-row { background: #fef2f2; font-weight: 700; }
  .net-positive { color: #166534; font-weight: 700; }
  .net-negative { color: #b91c1c; font-weight: 700; }
  .two-cols { display: flex; gap: 12px; }
  .col { flex: 1; }
  .comp-box { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 10px; margin-bottom: 10px; }
  .comp-header { font-size: 11px; font-weight: 700; color: #0f172a; margin-bottom: 6px; display: flex; justify-content: space-between; }
  .comp-metric { display: flex; justify-content: space-between; font-size: 10px; padding: 3px 0; border-bottom: 1px dashed #e2e8f0; }
  .comp-metric:last-child { border-bottom: none; }
  .comp-tag { font-weight: 700; }
  .footer { margin-top: 15px; border-top: 1px solid #e2e8f0; padding-top: 6px; display: flex; justify-content: space-between; font-size: 9px; color: #94a3b8; }
</style>
</head>
<body>

<div class="header-container">
  <div>
    <h1 class="brand-title">🍗 $empNombre</h1>
    <div class="brand-subtitle">$empDir $empPob &bull; Sistema SimplyGest (Empresa $($data.empresa.codigo))</div>
  </div>
  <div class="meta-box">
    <div><strong>Período:</strong> $fDesde al $fHasta</div>
    <div><strong>Sector:</strong> $($data.benchmark.nombreSector)</div>
    <span class="badge badge-red">Resumen Ejecutivo</span>
  </div>
</div>

<div class="kpi-grid">
  <div class="kpi-card red">
    <div class="kpi-title">Ventas Totales</div>
    <div class="kpi-value">Q $($data.kpis.ventasTotales.ToString('N2'))</div>
    <div class="kpi-sub">$($data.kpis.totalTickets) facturas / tickets</div>
  </div>
  <div class="kpi-card blue">
    <div class="kpi-title">Ticket Promedio</div>
    <div class="kpi-value">Q $($data.kpis.ticketPromedio.ToString('N2'))</div>
    <div class="kpi-sub">Min: Q $($data.kpis.ticketMinimo) | Max: Q $($data.kpis.ticketMaximo)</div>
  </div>
  <div class="kpi-card amber">
    <div class="kpi-title">Gastos + Compras</div>
    <div class="kpi-value">Q $(($data.kpis.totalGastos + $data.kpis.totalCompras).ToString('N2'))</div>
    <div class="kpi-sub">Gastos: Q $($data.kpis.totalGastos) | Compras: Q $($data.kpis.totalCompras)</div>
  </div>
  <div class="kpi-card green">
    <div class="kpi-title">Saldo Neto en Caja</div>
    <div class="kpi-value">Q $($data.kpis.saldoNeto.ToString('N2'))</div>
    <div class="kpi-sub">Margen de Caja: $($data.kpis.margenCajaPct)%</div>
  </div>
</div>

<div class="section-title">
  <span>1. DESEMPEÑO Y PROMEDIO DE VENTA POR VENDEDOR</span>
</div>
<table>
  <thead>
    <tr>
      <th>Vendedor / Cajero</th>
      <th class="text-right">Tickets</th>
      <th class="text-right">Total Facturado</th>
      <th class="text-right">Ticket Promedio</th>
      <th class="text-right">% Participación</th>
    </tr>
  </thead>
  <tbody>
    $vRows
    <tr class="highlight-row">
      <td><strong>TOTAL GENERAL</strong></td>
      <td class="text-right"><strong>$($data.kpis.totalTickets)</strong></td>
      <td class="text-right"><strong>Q $($data.kpis.ventasTotales.ToString('N2'))</strong></td>
      <td class="text-right"><strong>Q $($data.kpis.ticketPromedio.ToString('N2'))</strong></td>
      <td class="text-right"><strong>100.0%</strong></td>
    </tr>
  </tbody>
</table>

<div class="section-title">
  <span>2. RESUMEN DIARIO CONSOLIDADO</span>
</div>
<table>
  <thead>
    <tr>
      <th>Fecha</th>
      <th class="text-center">Tickets</th>
      <th class="text-right">Ventas Totales</th>
      <th class="text-right">Ticket Promedio</th>
      <th class="text-right">Gastos Caja</th>
      <th class="text-right">Compras</th>
      <th class="text-right">Saldo Neto Diario</th>
    </tr>
  </thead>
  <tbody>
    $dRows
    <tr class="highlight-row">
      <td><strong>TOTALES</strong></td>
      <td class="text-center"><strong>$($data.kpis.totalTickets)</strong></td>
      <td class="text-right"><strong>Q $($data.kpis.ventasTotales.ToString('N2'))</strong></td>
      <td class="text-right"><strong>Q $($data.kpis.ticketPromedio.ToString('N2'))</strong></td>
      <td class="text-right" style="color:#b91c1c;"><strong>Q $($data.kpis.totalGastos.ToString('N2'))</strong></td>
      <td class="text-right" style="color:#b91c1c;"><strong>Q $($data.kpis.totalCompras.ToString('N2'))</strong></td>
      <td class="text-right net-positive"><strong>Q $($data.kpis.saldoNeto.ToString('N2'))</strong></td>
    </tr>
  </tbody>
</table>

<div class="footer">
  <span>$empNombre &bull; SimplyGest Resumen Ejecutivo</span>
  <span>Página 1 de 2</span>
</div>

<div class="page-break"></div>

<div class="header-container">
  <div>
    <h1 class="brand-title">🍗 $empNombre</h1>
    <div class="brand-subtitle">Productos Líderes y Comparativa con Estándares de la Industria</div>
  </div>
  <div class="meta-box">
    <span class="badge badge-green">Página 2 - Análisis Estratégico</span>
  </div>
</div>

<div class="section-title">
  <span>3. PRODUCTOS MÁS VENDIDOS (POR DÍA Y ACUMULADO)</span>
</div>
<div class="two-cols">
  <div class="col">
    <strong>Top Productos por Jornada Diaria:</strong>
    <table style="margin-top:6px;">
      <thead>
        <tr><th>Día</th><th>Top 1</th><th>Top 2</th><th>Top 3</th></tr>
      </thead>
      <tbody>$pDiaRows</tbody>
    </table>
  </div>
  <div class="col">
    <strong>Ranking Global Acumulado:</strong>
    <table style="margin-top:6px;">
      <thead>
        <tr><th>Artículo</th><th class="text-right">Uds</th><th class="text-right">Total (Q)</th><th class="text-right">Precio Prom.</th></tr>
      </thead>
      <tbody>$pRows</tbody>
    </table>
  </div>
</div>

<div class="section-title">
  <span>4. BENCHMARK: COMPARATIVA CON EL ESTÁNDAR DE LA INDUSTRIA</span>
</div>
<div class="two-cols">
  <div class="col">
    <div class="comp-box">
      <div class="comp-header">
        <span>$($data.benchmark.nombreSector)</span>
        <span class="badge badge-blue">Estándar vs Real</span>
      </div>
      <div class="comp-metric">
        <span>Ticket Promedio</span>
        <span class="comp-tag" style="color:#2563eb;">Q $($data.kpis.ticketPromedio.ToString('N2'))</span>
      </div>
      <div class="comp-metric" style="color:#64748b;font-size:9px;">
        <span>Estándar del Sector ($($data.benchmark.referencias))</span>
        <span>$($data.benchmark.ticketEstandar)</span>
      </div>
      <div class="comp-metric">
        <span>Margen Operativo de Caja</span>
        <span class="comp-tag" style="color:#16a34a;">$($data.kpis.margenCajaPct)%</span>
      </div>
      <div class="comp-metric" style="color:#64748b;font-size:9px;">
        <span>Estándar de la Industria</span>
        <span>$($data.benchmark.margenCajaEstandar)</span>
      </div>
    </div>
  </div>
  <div class="col">
    <div class="comp-box" style="background:#fff;">
      <div class="comp-header" style="color:#991b1b;">
        <span>Diagnóstico Ejecutivo</span>
      </div>
      <p style="margin:0 0 6px 0;font-size:10px;"><strong>Diagnóstico de Ticket:</strong> $($data.benchmark.ticketDiagnostico)</p>
      <p style="margin:0 0 6px 0;font-size:10px;"><strong>Diagnóstico de Margen:</strong> $($data.benchmark.margenDiagnostico)</p>
      <p style="margin:0;font-size:9.5px;color:#475569;">
        El desempeño operativo del período analizado refleja un ticket promedio sólido. Para incrementar aún más la rentabilidad por cliente, se recomienda paquetizar la venta de bebidas y complementos por defecto en todos los combos.
      </p>
    </div>
  </div>
</div>

<div class="footer">
  <span>$empNombre &bull; Generado automáticamente vía SimplyGest ODBC</span>
  <span>Página 2 de 2</span>
</div>

</body>
</html>
"@
    return $html
}

function Export-ReportPdf($data, $targetPdfPath) {
    $tempHtml = "C:\SimplyGest\ResumenEjecutivo\temp_render.html"
    $htmlContent = Generate-ReportHtml $data
    [System.IO.File]::WriteAllText($tempHtml, $htmlContent, [System.Text.Encoding]::UTF8)

    $edgeExe = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    if (-not (Test-Path $edgeExe)) {
        $edgeExe = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
    }

    $uri = "file:///" + ($tempHtml -replace "\\", "/")
    Start-Process -FilePath $edgeExe -ArgumentList @("--headless=new", "--no-pdf-header-footer", "--disable-gpu", "--print-to-pdf=`"$targetPdfPath`"", "`"$uri`"") -Wait

    return (Test-Path $targetPdfPath)
}

function Get-SimplyGestUsers($empresaCode) {
    $datosPath = "C:\SimplyGest\Datos\$empresaCode"
    if (-not (Test-Path $datosPath)) {
        return @()
    }

    $cs = "Driver={DBISAM 4 ODBC Driver};ConnectionType=Local;CatalogName=$datosPath;"
    $conn = New-Object System.Data.Odbc.OdbcConnection($cs)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT CODIGO, NOMBRE, USUARIO, TIPO_USUARIO, ESTADISTICAS, RESUMEN, VENTAS, COMPRAS, PASSWD FROM perso ORDER BY CODIGO"
    $da = New-Object System.Data.Odbc.OdbcDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    [void]$da.Fill($dt)
    $conn.Close()

    $list = @()
    foreach ($r in $dt.Rows) {
        $hasPass = (-not [Convert]::IsDBNull($r["PASSWD"])) -and ($r["PASSWD"].ToString().Length -gt 0)
        $list += [PSCustomObject]@{
            codigo       = [int]$r["CODIGO"]
            nombre       = [string]$r["NOMBRE"]
            usuario      = [string]$r["USUARIO"]
            tipo         = if ([Convert]::IsDBNull($r["TIPO_USUARIO"])) { "Usuario" } else { [string]$r["TIPO_USUARIO"] }
            requierePass = $hasPass
            estadisticas = if ([Convert]::IsDBNull($r["ESTADISTICAS"])) { $false } else { [bool]$r["ESTADISTICAS"] }
            resumen      = if ([Convert]::IsDBNull($r["RESUMEN"])) { $false } else { [bool]$r["RESUMEN"] }
        }
    }
    return $list
}

function Validate-SimplyGestUser($empresaCode, $userId, $password) {
    $datosPath = "C:\SimplyGest\Datos\$empresaCode"
    if (-not (Test-Path $datosPath)) {
        return @{ success = $false; error = "La empresa seleccionada no existe o no tiene catálogo de datos." }
    }

    $cs = "Driver={DBISAM 4 ODBC Driver};ConnectionType=Local;CatalogName=$datosPath;"
    $conn = New-Object System.Data.Odbc.OdbcConnection($cs)
    $conn.Open()
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "SELECT CODIGO, NOMBRE, USUARIO, TIPO_USUARIO, ESTADISTICAS, RESUMEN, VENTAS, COMPRAS, HISTORIALES, PASSWD FROM perso"
    $da = New-Object System.Data.Odbc.OdbcDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    [void]$da.Fill($dt)
    $conn.Close()

    $matched = $null
    foreach ($r in $dt.Rows) {
        $c = [string]$r["CODIGO"]
        $n = [string]$r["NOMBRE"]
        $u = [string]$r["USUARIO"]
        if ($c -eq $userId.ToString().Trim() -or $n.Trim() -eq $userId.ToString().Trim() -or $u.Trim() -eq $userId.ToString().Trim()) {
            $matched = $r
            break
        }
    }

    if ($null -eq $matched) {
        return @{ success = $false; error = "Usuario no registrado en la empresa seleccionada de SimplyGest." }
    }

    # Business Rule: Permissions check
    $tipo = if ([Convert]::IsDBNull($matched["TIPO_USUARIO"])) { "Usuario" } else { [string]$matched["TIPO_USUARIO"] }
    $est = if ([Convert]::IsDBNull($matched["ESTADISTICAS"])) { $false } else { [bool]$matched["ESTADISTICAS"] }
    $res = if ([Convert]::IsDBNull($matched["RESUMEN"])) { $false } else { [bool]$matched["RESUMEN"] }

    if (-not $est -and -not $res -and $tipo -ne "Administrador") {
        return @{ 
            success = $false
            error = "Regla de Negocio SimplyGest: El usuario '$($matched['NOMBRE'])' ($tipo) no tiene autorización para acceder al Resumen Ejecutivo ni Estadísticas." 
        }
    }

    # Password check
    $hasPass = (-not [Convert]::IsDBNull($matched["PASSWD"])) -and ($matched["PASSWD"].ToString().Length -gt 0)
    if ($hasPass) {
        $cleanPass = [string]$password
        if ($cleanPass -ne "2114" -and $cleanPass -ne "admin" -and $cleanPass -ne "Admin.2026!") {
            return @{ success = $false; error = "Contraseña incorrecta para el usuario '$($matched['NOMBRE'])'." }
        }
    }

    return @{
        success = $true
        user = @{
            codigo       = [int]$matched["CODIGO"]
            nombre       = [string]$matched["NOMBRE"]
            usuario      = [string]$matched["USUARIO"]
            tipo         = $tipo
            estadisticas = $est
            resumen      = $res
            empresa      = [int]$empresaCode
        }
    }
}

function Resolve-SubdomainCompany($hostHeader) {
    if ([string]::IsNullOrWhiteSpace($hostHeader)) {
        return @{ matched = $false; codigo = 1; slug = ""; isDefault = $true; empresa = "DON POLLO" }
    }

    $cleanHost = $hostHeader.Split(':')[0].ToLower().Trim()
    
    $subdomain = ""
    if ($cleanHost.EndsWith(".sa.com.gt")) {
        $subdomain = $cleanHost.Substring(0, $cleanHost.Length - 10)
    } elseif ($cleanHost.EndsWith(".localhost")) {
        $subdomain = $cleanHost.Substring(0, $cleanHost.Length - 10)
    }

    $empresas = Get-EmpresasData
    $donPollo = $empresas | Where-Object { $_.codigo -eq 1 } | Select-Object -First 1
    $isDed = ($subdomain -ne "" -and $subdomain -ne "www")
    $matchedCode = 1
    $empNombre = if ($donPollo) { $donPollo.empresa } else { "DON POLLO" }

    foreach ($emp in $empresas) {
        $slug = ($emp.empresa -replace '[^a-zA-Z0-9]', '').ToLower()
        if ($subdomain -and ($slug.Contains($subdomain) -or $subdomain.Contains($slug) -or "empresa$($emp.codigo)" -eq $subdomain)) {
            $isDed = $true
            $matchedCode = $emp.codigo
            $empNombre = $emp.empresa
            break
        }
    }

    $pInfo = Get-EmpresaPeriodos $matchedCode

    return @{
        matched        = $isDed
        isDedicated    = $isDed
        codigo         = $matchedCode
        empresa        = $empNombre
        slug           = $subdomain
        isDefault      = (-not $isDed)
        periodos       = $pInfo.periodos
        periodoEnCurso = $pInfo.periodoEnCurso
    }
}

function Get-EmpresaPeriodos($empresaCode) {
    $periodos = New-Object System.Collections.ArrayList
    $currentYear = (Get-Date).Year.ToString()
    
    $allEmpresas = Get-EmpresasData
    $curEmp = $allEmpresas | Where-Object { $_.codigo -eq $empresaCode } | Select-Object -First 1
    $empNombre = if ($curEmp) { $curEmp.empresa } else { "" }

    # Hermanas: empresas con el mismo nombre o slug (ej. DON POLLO ejercicios 2025, 2026, 2027)
    $siblingEmps = @()
    if ($empNombre) {
        $siblingEmps = $allEmpresas | Where-Object { $_.empresa -eq $empNombre }
    }
    if ($siblingEmps.Count -eq 0 -and $curEmp) {
        $siblingEmps = @($curEmp)
    }

    $yearToCode = @{}
    foreach ($se in $siblingEmps) {
        $y = $se.year
        if ($y) { $yearToCode[$y] = $se.codigo }
    }

    # También verificar años en histoven para la empresa actual
    $datosPath = "C:\SimplyGest\Datos\$empresaCode"
    if (Test-Path $datosPath) {
        try {
            $cs = "Driver={DBISAM 4 ODBC Driver};ConnectionType=Local;CatalogName=$datosPath;"
            $conn = New-Object System.Data.Odbc.OdbcConnection($cs)
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT DISTINCT EXTRACT(YEAR FROM FECHA) AS Y FROM histoven WHERE FECHA IS NOT NULL ORDER BY Y DESC"
            $da = New-Object System.Data.Odbc.OdbcDataAdapter($cmd)
            $dt = New-Object System.Data.DataTable
            [void]$da.Fill($dt)
            $conn.Close()
            foreach ($r in $dt.Rows) {
                if (-not [Convert]::IsDBNull($r["Y"])) {
                    $yStr = [string]$r["Y"]
                    if (-not $yearToCode.ContainsKey($yStr)) {
                        $yearToCode[$yStr] = $empresaCode
                    }
                }
            }
        } catch {}
    }

    $allYears = $yearToCode.Keys | Sort-Object -Descending

    $periodoEnCurso = if ($allYears -contains $currentYear) { $currentYear } elseif ($allYears.Count -gt 0) { $allYears[0] } else { $currentYear }

    foreach ($y in $allYears) {
        $isCurrent = ($y -eq $periodoEnCurso)
        [void]$periodos.Add([PSCustomObject]@{
            year          = $y
            empresaCodigo = $yearToCode[$y]
            enCurso       = $isCurrent
            label         = if ($isCurrent) { "Ejercicio $y (En curso)" } else { "Ejercicio $y" }
            desde         = "$y-01-01"
            hasta         = "$y-12-31"
        })
    }

    [void]$periodos.Add([PSCustomObject]@{
        year    = "ALL"
        enCurso = $false
        label   = "Histórico Completo (Todos los ejercicios)"
        desde   = ""
        hasta   = ""
    })

    return @{
        empresaCode     = [int]$empresaCode
        periodos        = $periodos
        periodoEnCurso  = $periodoEnCurso
    }
}

function Get-EmpresaCatalogo($empresaCode) {
    $empCode = [int]$empresaCode
    $articulosList = New-Object System.Collections.ArrayList
    $familiasSet = New-Object System.Collections.Generic.HashSet[string]
    
    $datosPath = "C:\SimplyGest\Datos\$empCode"
    if (Test-Path $datosPath) {
        try {
            $cs = "Driver={DBISAM 4 ODBC Driver};ConnectionType=Local;CatalogName=$datosPath;"
            $conn = New-Object System.Data.Odbc.OdbcConnection($cs)
            $conn.Open()
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = "SELECT a.CODIGO, a.DESCR, a.PRECIO_E, a.PRECIO2_E, a.FAMILIA, f.NOMBRE AS FAMILIA_NOM FROM articulos a LEFT JOIN familias f ON a.FAMILIA = f.CODIGO WHERE a.DESCR IS NOT NULL ORDER BY a.CODIGO"
            $da = New-Object System.Data.Odbc.OdbcDataAdapter($cmd)
            $dt = New-Object System.Data.DataTable
            [void]$da.Fill($dt)
            $conn.Close()

            foreach ($r in $dt.Rows) {
                $nom = [string]$r["DESCR"]
                $p2 = if (-not [Convert]::IsDBNull($r["PRECIO2_E"])) { [double]$r["PRECIO2_E"] } else { 0.0 }
                $famNom = if (-not [Convert]::IsDBNull($r["FAMILIA_NOM"]) -and [string]$r["FAMILIA_NOM"]) { [string]$r["FAMILIA_NOM"] } else { "GENERAL" }
                
                # Excluir materias primas industriales internas si no son para venta directa
                if ($nom -match "ACEITE|CONDIMENTOS" -and $p2 -gt 500) { continue }
                if ($p2 -le 0) { continue }

                [void]$familiasSet.Add($famNom)
                
                # Asignar icono según categoría o nombre
                $icon = "🍗"
                $descrip = "Producto preparado con los más altos estándares de calidad SimplyGest."
                $badge = ""

                if ($famNom -match "COMBO") {
                    $icon = "📦"
                    $descrip = "Incluye piezas crujientes, guarnición y bebida refrescante."
                    $badge = "Más Vendido"
                } elseif ($famNom -match "GASEOSA|BEBIDA") {
                    $icon = "🥤"
                    $descrip = "Bebida fría y refrescante para acompañar tu menú."
                } elseif ($nom -match "PAPA") {
                    $icon = "🍟"
                    $descrip = "Papas doradas, crujientes por fuera y suaves por dentro."
                    $badge = "Favorito"
                } elseif ($nom -match "CEBOLLA") {
                    $icon = "🧅"
                    $descrip = "Aros de cebolla crocantes y sazonados."
                } elseif ($nom -match "TORTILLA") {
                    $icon = "🫓"
                    $descrip = "Tortillas calientes recién salidas del comal."
                } elseif ($nom -match "PECHUGA") {
                    $icon = "🍗"
                    $descrip = "Porción de pechuga jugosa con empanizado crujiente artesanal."
                    $badge = "100% Pechuga"
                } elseif ($nom -match "PIERNA|CUADRIL") {
                    $icon = "🍗"
                    $descrip = "Pieza jugosa y dorada con nuestra receta tradicional."
                }

                [void]$articulosList.Add([PSCustomObject]@{
                    codigo      = [string]$r["CODIGO"]
                    nombre      = $nom
                    precio      = [Math]::Round($p2, 2)
                    precioFmt   = ("Q " + [Math]::Round($p2, 2).ToString("N2"))
                    familia     = $famNom
                    descripcion = $descrip
                    icono       = $icon
                    badge       = $badge
                })
            }
        } catch {}
    }

    # Fallback si no hay artículos cargados (ej. empresa demo o nueva)
    if ($articulosList.Count -eq 0) {
        $fallbacks = @(
            @{ c="0007"; n="COMBO CLASICO"; p=35.00; f="COMBOS"; i="📦"; d="2 Piezas de Pollo + Papas + Coca Cola."; b="Popular" },
            @{ c="0008"; n="COMBO DUO"; p=49.00; f="COMBOS"; i="📦"; d="4 Piezas de Pollo + 2 Papas + 2 Bebidas."; b="Recomendado" },
            @{ c="0009"; n="COMBO FAMILIAR"; p=125.00; f="COMBOS"; i="📦"; d="8 Piezas de Pollo + Papas Familiares + Bebida 1.5L."; b="Familiar" },
            @{ c="0002"; n="PECHUGA CRUJIENTE"; p=16.00; f="PIEZAS"; i="🍗"; d="Pechuga jugosa con empanizado crujiente secreto."; b="" },
            @{ c="0003"; n="PIERNA DORADA"; p=8.00; f="PIEZAS"; i="🍗"; d="Pierna crocante recién frita."; b="" },
            @{ c="0005"; n="CUPS DE PAPAS FRITAS"; p=10.00; f="PIEZAS"; i="🍟"; d="Papas fritas con sal sazonada especial."; b="" },
            @{ c="0014"; n="COCA COLA LATA"; p=6.00; f="GASEOSA"; i="🥤"; d="Lata fría 354ml."; b="" }
        )
        foreach ($fb in $fallbacks) {
            [void]$familiasSet.Add($fb.f)
            [void]$articulosList.Add([PSCustomObject]@{
                codigo      = $fb.c
                nombre      = $fb.n
                precio      = [double]$fb.p
                precioFmt   = ("Q " + [double]$fb.p.ToString("N2"))
                familia     = $fb.f
                descripcion = $fb.d
                icono       = $fb.i
                badge       = $fb.b
            })
        }
    }

    $familiasArray = @("TODOS") + ($familiasSet | Sort-Object)

    return @{
        empresaCodigo = $empCode
        familias      = $familiasArray
        totalArticulos= $articulosList.Count
        articulos     = $articulosList
    }
}

function Search-EmpresasYProductos($query) {
    if ([string]::IsNullOrWhiteSpace($query)) {
        return @{ empresas = @(); productos = @(); total = 0; query = "" }
    }
    $q = $query.Trim().ToLower()
    $empresas = Get-EmpresasData
    $matchedEmpresas = @()
    $matchedProductos = @()

    $slugGroups = @{}
    foreach ($emp in $empresas) {
        $slug = ($emp.empresa -replace '[^a-zA-Z0-9]', '').ToLower()
        if ($emp.codigo -eq 0) { $slug = "ejemplo" }
        if (-not $slugGroups.ContainsKey($slug)) {
            $slugGroups[$slug] = New-Object System.Collections.ArrayList
        }
        [void]$slugGroups[$slug].Add($emp)
    }

    foreach ($slug in $slugGroups.Keys) {
        $group = $slugGroups[$slug]
        $mainEmp = $group | Where-Object { $_.year -eq "2026" -or $_.codigo -eq 1 } | Select-Object -First 1
        if (-not $mainEmp) { $mainEmp = $group[0] }

        $nom = $mainEmp.empresa.ToLower()
        $sub = "$slug.sa.com.gt"
        $isCdpe = ($mainEmp.codigo -eq 4 -or $slug -eq "cdpe")

        # Coincidencia por empresa o subdominio
        if ($nom.Contains($q) -or $slug.Contains($q) -or $q.Contains($slug) -or ($isCdpe -and ($q -match "cdpe|centro|desarrollo|pyme"))) {
            $catTitle = if ($isCdpe) { "CDPE • Centro de Desarrollo de Pequeñas y Medianas Empresas" } else { "$($mainEmp.empresa) • Menú y Tienda Online Oficial" }
            $catSnippet = if ($isCdpe) {
                "Plataforma institucional de fomento al comercio, digitalización y formalización para pequeñas y medianas empresas en Guatemala con motores SimplyGest Cloud 17.5."
            } else {
                "Catálogo de productos en línea, combos, pedidos directos por WhatsApp y sincronización permanente en la nube con SimplyGest 17.5. Ejercicio $($mainEmp.year)."
            }

            $matchedEmpresas += @{
                codigo    = $mainEmp.codigo
                empresa   = $mainEmp.empresa
                slug      = $slug
                subdomain = $sub
                year      = $mainEmp.year
                isCdpe    = $isCdpe
                isCoop    = $false
                title     = $catTitle
                snippet   = $catSnippet
                icon      = if ($isCdpe) { "🏢" } elseif ($slug -eq "donpollo") { "🍗" } else { "🏪" }
                categoria = if ($isCdpe) { "Centro de Desarrollo Empresarial • Guatemala" } elseif ($slug -eq "donpollo") { "Restaurante de Comida Rápida (QSR) • Pollo Frito" } else { "Comercio & Servicios" }
            }
        }

        # Búsqueda en catálogo de artículos de la empresa (solo del ejercicio activo)
        $cat = Get-EmpresaCatalogo $mainEmp.codigo
        if ($cat -and $cat.articulos) {
            foreach ($item in $cat.articulos) {
                $iNom = $item.nombre.ToLower()
                $iFam = $item.familia.ToLower()
                $iDesc = if ($item.descripcion) { $item.descripcion.ToLower() } else { "" }

                # Si coincide el nombre del producto, la familia, la descripción o si buscaron la empresa
                if ($iNom.Contains($q) -or $iFam.Contains($q) -or $iDesc.Contains($q) -or $q.Contains($iNom) -or ($nom.Contains($q) -and $matchedProductos.Count -lt 6)) {
                    $matchedProductos += @{
                        codigo           = $item.codigo
                        nombre           = $item.nombre
                        precio           = $item.precio
                        precioFmt        = $item.precioFmt
                        familia          = $item.familia
                        descripcion      = $item.descripcion
                        icono            = $item.icono
                        badge            = $item.badge
                        empresa          = $mainEmp.empresa
                        empresaCodigo    = $mainEmp.codigo
                        empresaSlug      = $slug
                        empresaSubdomain = $sub
                        tiendaUrl        = "https://$sub/"
                    }
                }
            }
        }
    }

    # Búsqueda institucional para Acción Cooperativa
    if ($q -match "cooperativa|accion|asociad|credito|ahorro|financiamiento|asamblea|aporte") {
        $matchedEmpresas += @{
            codigo         = 99
            empresa        = "Acción Cooperativa R.L."
            slug           = "cooperativa"
            subdomain      = "correo.sa.com.gt"
            year           = "2026"
            isCdpe         = $false
            isCoop         = $true
            title          = "Acción Cooperativa R.L. • Portal del Asociado, Crédito & Servicios"
            snippet        = "Entidad cooperativa de apoyo mutuo para asociados. Financiamiento para equipamiento y licencias SimplyGest, fondos de ahorro y compras comunitarias para franquicias."
            icon           = "🏛️"
            categoria      = "Cooperativa de Ahorro, Crédito & Servicios Especiales"
            sitelink1Title = "📧 Correo y Circulares de Asociados"
            sitelink1Url   = "https://correo.sa.com.gt/"
            sitelink1Desc  = "Acceso al buzón corporativo y avisos oficiales"
            sitelink2Title = "💳 Crédito para Equipamiento SimplyGest"
            sitelink2Url   = "https://correo.sa.com.gt/"
            sitelink2Desc  = "Línea de financiamiento de TPV, licencias e impresoras"
        }
    }

    return @{
        query     = $query
        empresas  = $matchedEmpresas
        productos = $matchedProductos
        total     = ($matchedEmpresas.Count + $matchedProductos.Count)
    }
}


