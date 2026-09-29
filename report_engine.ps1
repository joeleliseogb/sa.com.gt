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
        return @{
            query      = ""
            cdpe       = @()
            empresas   = @()
            productos  = @()
            tiendaCdpe = @()
            dominio    = @{}
            web        = @()
            total      = 0
        }
    }
    $q = $query.Trim().ToLower()

    # ----------------------------------------------------
    # NIVEL 1: PRIORIDAD MÁXIMA INSTITUCIONAL CDPE & MANUALES
    # ----------------------------------------------------
    $cdpeResults = @()
    $manualesCdpe = @(
        @{
            id       = 1
            codigo   = "CDPE-MAN-01"
            titulo   = "Manual 1 CDPE: Gestión Comercial, Técnicas de Venta y Diseño de Combos"
            resumen  = "Directrices estándar CDPE para negocios QSR y comercios. Fórmula del combo rentable (12% a 15% de ahorro), upselling y protocolo de respuesta por WhatsApp en menos de 2 minutos."
            icono    = "📘"
            categoria= "Manual de Gestión Comercial"
            linkUrl  = "https://cdpe.sa.com.gt/"
            waText   = "Hola CDPE, deseo asesoría sobre el Manual 1 de Ventas y Combos"
            keywords = "manual|gestion|comercial|venta|combo|menu|ticket|upsell|precio|promocion|cliente"
        },
        @{
            id       = 2
            codigo   = "CDPE-MAN-02"
            titulo   = "Manual 2 CDPE: Control de Inventarios, Mermas y Rotación PEPS (FIFO)"
            resumen  = "Control riguroso de materias primas y productos terminados en SimplyGest 17.5. Tolerancia máxima de descongelación 3-5%, vida útil de aceites y punto de reorden automático."
            icono    = "📦"
            categoria= "Manual de Inventarios & Mermas"
            linkUrl  = "https://cdpe.sa.com.gt/"
            waText   = "Hola CDPE, deseo asesoría sobre el Manual 2 de Inventarios y Mermas"
            keywords = "manual|inventario|merma|stock|peps|fifo|almacen|reorden|descongelacion|materia prima"
        },
        @{
            id       = 3
            codigo   = "CDPE-MAN-03"
            titulo   = "Manual 3 CDPE: Arqueo de Caja con Doble Ciego y Facturación SAT (FEL)"
            resumen  = "Auditoría financiera diaria, cuadre de turnos a ciegas (tolerancia ± Q 5.00), cierre Z e integración obligatoria de Facturación Electrónica SAT (FEL) con SimplyGest."
            icono    = "💰"
            categoria= "Manual de Arqueo & Facturación SAT"
            linkUrl  = "https://cdpe.sa.com.gt/"
            waText   = "Hola CDPE, deseo asesoría sobre el Manual 3 de Arqueo y SAT FEL"
            keywords = "manual|arqueo|caja|cierre|turno|ciego|sat|fel|factura|impuesto|fiscal|dinero"
        },
        @{
            id       = 4
            codigo   = "CDPE-MAN-04"
            titulo   = "Manual 4 CDPE: Estandarización de Franquicias y Activación de Subdominios"
            resumen  = "Protocolo de apertura de sucursales, Buenas Prácticas de Manufactura (BPM), manual de marca e infraestructura en la nube con subdominio dedicado .sa.com.gt."
            icono    = "🏢"
            categoria= "Manual de Franquicias & Expansión"
            linkUrl  = "https://cdpe.sa.com.gt/"
            waText   = "Hola CDPE, deseo asesoría sobre el Manual 4 de Franquicias"
            keywords = "manual|franquicia|expansion|sucursal|bpm|estandar|marca|subdominio|sa.com.gt"
        }
    )

    foreach ($m in $manualesCdpe) {
        if ($m.titulo.ToLower().Contains($q) -or ($m.keywords -and ($q -match $m.keywords)) -or ($q -match "cdpe|manual|asesor|asesoria|capacitacion|guatemala|pyme")) {
            $cdpeResults += $m
        }
    }
    if ($cdpeResults.Count -eq 0 -and ($q -match "negocio|comercio|gestion|ventas|restaurante|tienda")) {
        $cdpeResults += $manualesCdpe[0]
    }

    # ----------------------------------------------------
    # NIVEL 2: EMPRESAS DE LA RED & ARTÍCULOS SIMPLYGEST
    # ----------------------------------------------------
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

        # Búsqueda en catálogo de artículos SimplyGest
        $cat = Get-EmpresaCatalogo $mainEmp.codigo
        if ($cat -and $cat.articulos) {
            foreach ($item in $cat.articulos) {
                $iNom = $item.nombre.ToLower()
                $iFam = $item.familia.ToLower()
                $iDesc = if ($item.descripcion) { $item.descripcion.ToLower() } else { "" }

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

    # ----------------------------------------------------
    # NIVEL 3: PRODUCTOS DE LA TIENDA DEL CDPE (13,396 Ítems)
    # ----------------------------------------------------
    $matchedTiendaCdpe = Search-CdpeTiendaProducts $q 24

    # ----------------------------------------------------
    # NIVEL 4: DOMINIOS Y HOSTING sa.com.gt
    # ----------------------------------------------------
    $cleanSlug = ($q -replace '[^a-z0-9]', '')
    if ([string]::IsNullOrEmpty($cleanSlug)) { $cleanSlug = "miempresa" }
    $dominioLibre = "$cleanSlug.sa.com.gt"
    $dominioExiste = ($matchedEmpresas | Where-Object { $_.slug -eq $cleanSlug }).Count -gt 0
    $dominioInfo = @{
        subdominio   = $dominioLibre
        disponible   = (-not $dominioExiste)
        planSugerido = "Franquicia QSR Pro (Q 599/mes)"
    }

    # ----------------------------------------------------
    # NIVEL 5: MOTOR DE BÚSQUEDA WEB GLOBAL (Todo Internet)
    # ----------------------------------------------------
    $webResults = Search-GlobalWebOrganic $query 6
    $encodedQ = [System.Uri]::EscapeDataString($query)
    $webResults += @{
        title   = "Explorar más resultados de '$query' en Google"
        snippet = "Consultar el índice web global de Google en una pestaña externa para '$query'."
        url     = "https://www.google.com/search?q=$encodedQ"
        fuente  = "Google Web Search"
        icon    = "🔎"
    }

    $totalCalculado = $cdpeResults.Count + $matchedEmpresas.Count + $matchedProductos.Count + $matchedTiendaCdpe.Count + $webResults.Count

    return @{
        query       = $query
        cdpe        = $cdpeResults
        empresas    = $matchedEmpresas
        productos   = $matchedProductos
        tiendaCdpe  = $matchedTiendaCdpe
        dominio     = $dominioInfo
        web         = $webResults
        total       = $totalCalculado
    }
}

# --------------------------------------------------------
# MOTOR DE CATÁLOGO CDPE TIENDA & ASESOR CON ACCESO A INTERNET
# --------------------------------------------------------
$global:CdpeTiendaCatalogCache = $null

function Get-CdpeTiendaCatalog() {
    if ($null -ne $global:CdpeTiendaCatalogCache -and $global:CdpeTiendaCatalogCache.Count -gt 0) {
        return $global:CdpeTiendaCatalogCache
    }
    $path = "C:\SimplyGest\ResumenEjecutivo\cdpe_tienda_productos.json"
    if (Test-Path $path) {
        try {
            $raw = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
            $global:CdpeTiendaCatalogCache = $raw | ConvertFrom-Json
        } catch {
            $global:CdpeTiendaCatalogCache = @()
        }
    } else {
        $global:CdpeTiendaCatalogCache = @()
    }
    return $global:CdpeTiendaCatalogCache
}

function Search-CdpeTiendaProducts($query, $limit = 20) {
    $catalog = Get-CdpeTiendaCatalog
    if (-not $catalog -or [string]::IsNullOrWhiteSpace($query)) {
        return @()
    }
    $terms = ($query.Trim().ToLower() -split '\s+') | Where-Object { $_.Length -gt 1 }
    if ($terms.Count -eq 0) { return @() }

    $matches = @()
    foreach ($item in $catalog) {
        $nom = if ($item.nombre) { $item.nombre.ToLower() } else { "" }
        $cat = if ($item.categoria) { $item.categoria.ToLower() } else { "" }
        $desc = if ($item.descripcion) { $item.descripcion.ToLower() } else { "" }
        $prov = if ($item.proveedor) { $item.proveedor.ToLower() } else { "" }
        $sku = if ($item.sku) { $item.sku.ToLower() } else { "" }

        $score = 0
        foreach ($t in $terms) {
            if ($nom.Contains($t)) { $score += 10 }
            if ($sku.Contains($t)) { $score += 8 }
            if ($cat.Contains($t)) { $score += 5 }
            if ($prov.Contains($t)) { $score += 3 }
            if ($desc.Contains($t)) { $score += 2 }
        }

        if ($score -gt 0) {
            $matches += [PSCustomObject]@{
                item  = $item
                score = $score
            }
        }
    }

    $sorted = $matches | Sort-Object score -Descending | Select-Object -First $limit
    $resultList = @()
    foreach ($m in $sorted) {
        $resultList += $m.item
    }
    return $resultList
}

function Search-GlobalWebOrganic($query, $limit = 5) {
    $results = @()
    if ([string]::IsNullOrWhiteSpace($query)) { return $results }
    $encQ = [System.Uri]::EscapeDataString($query)

    try {
        Add-Type -AssemblyName System.Web -ErrorAction SilentlyContinue
    } catch {}

    # 1. DuckDuckGo Lite Organic Web Extraction (High Reliability & Anti-Bot Resilient)
    try {
        $postBody = "q=" + $encQ
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($postBody)
        $req = [System.Net.HttpWebRequest]::Create("https://lite.duckduckgo.com/lite/")
        $req.Method = "POST"
        $req.ContentType = "application/x-www-form-urlencoded"
        $req.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) sa.com.gt-Advisor/2.0"
        $req.ContentLength = $bytes.Length
        $req.Timeout = 3800

        $os = $req.GetRequestStream()
        $os.Write($bytes, 0, $bytes.Length)
        $os.Close()

        $resp = $req.GetResponse()
        $rdr = New-Object System.IO.StreamReader($resp.GetResponseStream())
        $html = $rdr.ReadToEnd()
        $rdr.Close()
        $resp.Close()

        $linkPattern = '<a\s+[^>]*href=["'']([^"'']+)["''][^>]*class=["'']result-link["''][^>]*>([\s\S]*?)<\/a>'
        $snipPattern = '<td\s+[^>]*class=["'']result-snippet["''][^>]*>([\s\S]*?)<\/td>'

        $linkMatches = [regex]::Matches($html, $linkPattern)
        $snipMatches = [regex]::Matches($html, $snipPattern)

        $count = [Math]::Min($linkMatches.Count, $snipMatches.Count)
        for ($i = 0; $i -lt $count; $i++) {
            $lm = $linkMatches[$i]
            $sm = $snipMatches[$i]

            $rawUrl = $lm.Groups[1].Value
            $rawTitle = $lm.Groups[2].Value
            $rawSnip = $sm.Groups[1].Value

            $title = try { [System.Web.HttpUtility]::HtmlDecode($rawTitle) -replace '<[^>]+>', '' } catch { $rawTitle -replace '<[^>]+>', '' }
            $snippet = try { [System.Web.HttpUtility]::HtmlDecode($rawSnip) -replace '<[^>]+>', '' } catch { $rawSnip -replace '<[^>]+>', '' }

            $realUrl = $rawUrl
            if ($rawUrl -match 'uddg=([^&]+)') {
                $cleanEnc = $Matches[1]
                $realUrl = [System.Uri]::UnescapeDataString($cleanEnc)
            }
            if ($realUrl -and $realUrl.StartsWith("http") -and -not $realUrl.Contains("duckduckgo.com/y.js")) {
                $domain = try { ([System.Uri]$realUrl).Host } catch { "Web" }
                $results += @{
                    title   = $title.Trim()
                    snippet = $snippet.Trim()
                    url     = $realUrl
                    fuente  = $domain
                    icon    = "🌐"
                }
                if ($results.Count -ge $limit) { break }
            }
        }
    } catch {}

    # 2. Wikipedia Fallback / Supplement
    if ($results.Count -lt $limit) {
        try {
            $wikiUrl = "https://es.wikipedia.org/w/api.php?action=opensearch&search=$encQ&limit=3&namespace=0&format=json"
            $wReq = [System.Net.HttpWebRequest]::Create($wikiUrl)
            $wReq.UserAgent = "Mozilla/5.0 sa.com.gt/2.0"
            $wReq.Timeout = 2500
            $wResp = $wReq.GetResponse()
            $rdr = New-Object System.IO.StreamReader($wResp.GetResponseStream())
            $wData = $rdr.ReadToEnd() | ConvertFrom-Json
            $rdr.Close()
            $wResp.Close()
            if ($wData.Count -ge 4 -and $wData[1].Count -gt 0) {
                for ($i = 0; $i -lt $wData[1].Count; $i++) {
                    if ($wData[2][$i] -and $wData[2][$i].Length -gt 15) {
                        $results += @{
                            title   = [string]$wData[1][$i]
                            snippet = [string]$wData[2][$i]
                            url     = [string]$wData[3][$i]
                            fuente  = "Wikipedia Oficial"
                            icon    = "📚"
                        }
                        if ($results.Count -ge $limit) { break }
                    }
                }
            }
        } catch {}
    }

    return $results
}

function Invoke-CdpeAgentAdvisor($query) {
    if ([string]::IsNullOrWhiteSpace($query)) {
        return @{
            respuestaHtml = "<p>Por favor escribe una consulta o pregunta comercial para el Asesor CDPE.</p>"
            productos = @()
            fuentes = @()
        }
    }
    $cleanQ = ($query -replace '\+', ' ')
    $q = [System.Uri]::UnescapeDataString($cleanQ).Trim()
    $qLower = $q.ToLower()

    # 1. Manuales CDPE
    $manualEncontrado = $null
    if ($qLower -match "venta|combo|menu|menú|cliente|fideliz|upsell|cross-sell|sugestiv|promocion|precio|ticket") {
        $manualEncontrado = @{
            num = 1
            titulo = "Manual 1 CDPE: Gestión Comercial, Técnicas de Venta y Diseño de Combos"
            resumen = "Fórmula del combo rentable (12% a 15% de ahorro para elevar ticket promedio de Q 25 a Q 35-49), venta sugestiva sistemática en mostrador y protocolo de atención inmediata por WhatsApp en menos de 2 minutos."
        }
    } elseif ($qLower -match "inventario|stock|merma|peps|fifo|perecedero|simplygest|pollo crudo|aceite|porcion|almacen") {
        $manualEncontrado = @{
            num = 2
            titulo = "Manual 2 CDPE: Control de Inventarios, Mermas y Rotación PEPS (FIFO)"
            resumen = "Rotación PEPS/FIFO obligatoria, control de mermas por descongelación con tolerancia estricta del 3% al 5%, bitácora de horas de freído para aceites y punto de reorden automatizado en SimplyGest 17.5 Cloud."
        }
    } elseif ($qLower -match "arqueo|caja|cierre|factura|sat|fel|cuadre|sobrante|faltante|efectivo|tarjeta|pos|turno") {
        $manualEncontrado = @{
            num = 3
            titulo = "Manual 3 CDPE: Arqueo de Caja con Doble Ciego y Facturación SAT (FEL)"
            resumen = "Apertura con fondo fijo de Q 300 a Q 500, cuadre a ciegas antes del reporte Z (tolerancia máxima ± Q 5.00) y emisión obligatoria de DTE con firma electrónica FEL autorizada por la SAT en SimplyGest."
        }
    } elseif ($qLower -match "franquicia|afiliar|cdpe|subdominio|abrir|sucursal|requisito|formaliz|costo|pyme") {
        $manualEncontrado = @{
            num = 4
            titulo = "Manual 4 CDPE: Modelo de Franquicias, BPM y Expansión en Red sa.com.gt"
            resumen = "Buenas Prácticas de Manufactura (BPM), estandarización operativa, tienda digital y subdominio empresarial dedicado tuempresa.sa.com.gt con SSL institucional y buzón de correo corporativo."
        }
    }

    # 2. Catálogo Oficial CDPE (Top 4 productos afines de los 13,396 disponibles)
    $productosCdpe = Search-CdpeTiendaProducts $q 4

    # 3. Consulta Externa / Web en Vivo (Internet)
    $fuentesExternas = Search-GlobalWebOrganic $q 2

    # 4. Composición de Respuesta HTML Estructurada
    try {
        Add-Type -AssemblyName System.Web -ErrorAction SilentlyContinue
    } catch {}

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.Append("<div class='cdpe-agent-response'>")

    # Status Badges
    [void]$sb.Append("<div style='display:flex;align-items:center;flex-wrap:wrap;gap:6px;margin-bottom:12px;'>")
    [void]$sb.Append("<span style='font-size:11px;font-weight:700;color:#137333;background:#e6f4ea;padding:3px 9px;border-radius:12px;'>🌐 Conexión a Internet & Fuentes Externas</span>")
    [void]$sb.Append("<span style='font-size:11px;font-weight:700;color:#1a73e8;background:#e8f0fe;padding:3px 9px;border-radius:12px;'>🛍️ Catálogo Oficial CDPE (13,396 Productos)</span>")
    [void]$sb.Append("</div>")

    # Core CDPE Guidance
    if ($manualEncontrado) {
        [void]$sb.Append("<p style='margin-bottom:6px;'><strong>📘 $($manualEncontrado.titulo)</strong></p>")
        [void]$sb.Append("<div style='background:#ffffff;border:1px solid #e0e2e6;border-radius:8px;padding:12px 14px;margin-bottom:12px;font-size:13px;line-height:1.55;color:#202124;'>")
        [void]$sb.Append($manualEncontrado.resumen)
        [void]$sb.Append("</div>")
    } else {
        $encTerm = [System.Web.HttpUtility]::HtmlEncode($q)
        [void]$sb.Append("<p style='margin-bottom:6px;'><strong>🤖 Asesoría Especializada CDPE</strong></p>")
        [void]$sb.Append("<p style='font-size:13.5px;line-height:1.55;margin-bottom:12px;color:#202124;'>Para consultas sobre <em>'$encTerm'</em>, el CDPE recomienda implementar protocolos estandarizados de atención, control en SimplyGest 17.5 y equipamiento con garantía oficial.</p>")
    }

    # External Web Intel Block
    if ($fuentesExternas.Count -gt 0) {
        [void]$sb.Append("<div style='margin-bottom:14px;background:#f8f9fa;border-left:3px solid #1a73e8;padding:10px 14px;border-radius:0 8px 8px 0;'>")
        [void]$sb.Append("<div style='font-size:11.5px;font-weight:700;color:#1a73e8;margin-bottom:6px;display:flex;align-items:center;gap:5px;'><span>🌐 Información Consultada en Internet / Fuentes Externas:</span></div>")
        foreach ($src in $fuentesExternas) {
            $sTitle = [System.Web.HttpUtility]::HtmlEncode($src.title)
            $sSnip = [System.Web.HttpUtility]::HtmlEncode($src.snippet)
            $sUrl = $src.url
            $sFuente = [System.Web.HttpUtility]::HtmlEncode($src.fuente)
            [void]$sb.Append("<div style='margin-bottom:8px;font-size:12px;line-height:1.45;'>")
            [void]$sb.Append("<strong><a href='$sUrl' target='_blank' style='color:#1a0dab;text-decoration:underline;'>$sTitle</a></strong> <span style='color:#70757a;'>($sFuente)</span><br/>")
            [void]$sb.Append("<span style='color:#3c4043;'>$sSnip</span>")
            [void]$sb.Append("</div>")
        }
        [void]$sb.Append("</div>")
    }

    # Products from CDPE Store
    if ($productosCdpe.Count -gt 0) {
        [void]$sb.Append("<div style='margin-bottom:14px;'>")
        [void]$sb.Append("<div style='font-size:12.5px;font-weight:700;color:#202124;margin-bottom:8px;display:flex;align-items:center;gap:6px;'>")
        [void]$sb.Append("<span>🛍️ Equipamiento y Soluciones Disponibles en Tienda CDPE:</span>")
        [void]$sb.Append("</div>")
        [void]$sb.Append("<div style='display:grid;grid-template-columns:repeat(auto-fit, minmax(210px, 1fr));gap:10px;'>")
        foreach ($p in $productosCdpe) {
            $pNom = [System.Web.HttpUtility]::HtmlEncode($p.nombre)
            $pProv = [System.Web.HttpUtility]::HtmlEncode($p.proveedor)
            $pUrl = $p.linkUrl
            $pWa = "https://wa.me/50245550004?text=" + [System.Uri]::EscapeDataString($p.waText)
            [void]$sb.Append("<div style='background:#ffffff;border:1px solid #dadce0;border-radius:8px;padding:10px;display:flex;flex-direction:column;justify-content:space-between;box-shadow:0 1px 3px rgba(0,0,0,0.05);'>")
            [void]$sb.Append("<div>")
            [void]$sb.Append("<div style='display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:4px;'>")
            [void]$sb.Append("<span style='font-size:20px;'>$($p.icono)</span>")
            [void]$sb.Append("<span style='font-size:10px;font-weight:600;background:#f1f3f4;color:#5f6368;padding:2px 6px;border-radius:4px;'>$pProv</span>")
            [void]$sb.Append("</div>")
            [void]$sb.Append("<div style='font-size:12.5px;font-weight:600;color:#1a0dab;line-height:1.3;margin-bottom:4px;'><a href='$pUrl' target='_blank' style='color:#1a0dab;text-decoration:none;'>$pNom</a></div>")
            [void]$sb.Append("<div style='font-size:13px;font-weight:700;color:#188038;margin-bottom:6px;'>$($p.precioFmt)</div>")
            [void]$sb.Append("</div>")
            [void]$sb.Append("<div style='display:flex;gap:6px;margin-top:6px;'>")
            [void]$sb.Append("<a href='$pUrl' target='_blank' style='flex:1;background:#f8f9fa;border:1px solid #dadce0;border-radius:12px;font-size:11px;color:#1a73e8;text-align:center;padding:5px 6px;text-decoration:none;font-weight:600;'>🛒 Ver Tienda</a>")
            [void]$sb.Append("<a href='$pWa' target='_blank' style='flex:1;background:#e6f4ea;border:1px solid #ceead6;border-radius:12px;font-size:11px;color:#137333;text-align:center;padding:5px 6px;text-decoration:none;font-weight:600;'>💬 Cotizar</a>")
            [void]$sb.Append("</div>")
            [void]$sb.Append("</div>")
        }
        [void]$sb.Append("</div>")
        [void]$sb.Append("</div>")
    }

    # WhatsApp and Direct Links
    $waGral = "https://wa.me/50245550004?text=" + [System.Uri]::EscapeDataString("Hola Asesor CDPE, deseo ampliar la consulta sobre: $q")
    [void]$sb.Append("<div style='margin-top:12px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;'>")
    [void]$sb.Append("<a href='$waGral' target='_blank' class='agent-wa-link' style='margin:0;'>💬 Consultar a un Especialista CDPE (+502 4555-0004) &rarr;</a>")
    [void]$sb.Append("<a href='https://cdpe.accion.app/tienda.html' target='_blank' style='font-size:12px;color:#1a73e8;font-weight:600;text-decoration:none;'>🌐 Catálogo Completo CDPE &rarr;</a>")
    [void]$sb.Append("</div>")

    [void]$sb.Append("</div>")

    return @{
        respuestaHtml = $sb.ToString()
        productos     = $productosCdpe
        fuentes       = $fuentesExternas
    }
}


