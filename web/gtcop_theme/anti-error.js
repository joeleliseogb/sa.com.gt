/**
 * Acción Cooperativa R.L. - Sistema Anti-Error y Blindaje de Calidad de Datos
 * Características:
 * 1. Confirmación de ventanilla con números y letras en Quetzales
 * 2. Control de saldo y fondos insuficientes en retiros
 * 3. Validación algorítmica Módulo 11 de CUI / DPI (RENAP Guatemala)
 * 4. Validación algorítmica de NIT (SAT Guatemala)
 * 5. Estandarización automática de nombres propios (Capitalización limpia)
 * 6. Máscara telefónica de Guatemala (####-####)
 * 7. Prevención de doble clic e idempotencia en formularios
 */
(function() {
    'use strict';

    // Conversor de Números a Letras en Quetzales
    function numeroALetras(monto) {
        var num = parseFloat(monto);
        if (isNaN(num) || num <= 0) return '';
        var entero = Math.floor(num);
        var centavos = Math.round((num - entero) * 100);
        var centavosStr = (centavos < 10 ? '0' : '') + centavos + '/100';

        function seccion(num, divisor, strSingular, strPlural) {
            var cientos = Math.floor(num / divisor);
            var resto = num - (cientos * divisor);
            var letras = '';
            if (cientos > 0) {
                if (cientos > 1) {
                    letras = centenas(cientos) + ' ' + strPlural;
                } else {
                    letras = strSingular;
                }
            }
            if (resto > 0) {
                letras += '';
            }
            return { letras: letras, resto: resto };
        }

        function centenas(num) {
            var c = Math.floor(num / 100);
            var d = num - (c * 100);
            var strC = ['', 'Ciento', 'Doscientos', 'Trescientos', 'Cuatrocientos', 'Quinientos', 'Seiscientos', 'Setecientos', 'Ochocientos', 'Novecientos'];
            if (num === 100) return 'Cien';
            return (strC[c] + ' ' + decenas(d)).trim();
        }

        function decenas(num) {
            var d = Math.floor(num / 10);
            var u = num - (d * 10);
            var strU = ['', 'Uno', 'Dos', 'Tres', 'Cuatro', 'Cinco', 'Seis', 'Siete', 'Ocho', 'Nueve'];
            var str10_19 = ['Diez', 'Once', 'Doce', 'Trece', 'Catorce', 'Quince', 'Dieciséis', 'Diecisiete', 'Dieciocho', 'Diecinueve'];
            var strD = ['', '', 'Veinte', 'Treinta', 'Cuarenta', 'Cincuenta', 'Sesenta', 'Setenta', 'Ochenta', 'Noventa'];

            if (num < 10) return strU[num];
            if (num >= 10 && num < 20) return str10_19[num - 10];
            if (num === 20) return 'Veinte';
            if (num > 20 && num < 30) return 'Veinti' + strU[u].toLowerCase();
            return (strD[d] + (u > 0 ? ' y ' + strU[u] : '')).trim();
        }

        var res = '';
        if (entero >= 1000000) {
            var m = seccion(entero, 1000000, 'Un Millón', 'Millones');
            res += m.letras + ' ';
            entero = m.resto;
        }
        if (entero >= 1000) {
            var k = seccion(entero, 1000, 'Un Mil', 'Mil');
            res += k.letras + ' ';
            entero = k.resto;
        }
        if (entero > 0) {
            res += centenas(entero);
        }
        res = res.trim() || 'Cero';
        return res + ' Quetzales con ' + centavosStr;
    }

    // Validación Módulo 11 de CUI (Guatemala RENAP)
    function validarCui(cuiStr) {
        var cui = cuiStr.replace(/[\s-]/g, '');
        if (cui.length !== 13 || !/^\d+$/.test(cui)) return false;
        var numero = cui.substring(0, 8);
        var validador = parseInt(cui.charAt(8), 10);
        var total = 0;
        for (var i = 0; i < numero.length; i++) {
            total += parseInt(numero.charAt(i), 10) * (i + 2);
        }
        var modulo = total % 11;
        return modulo === validador;
    }

    // Validación Algorítmica de NIT SAT Guatemala
    function validarNit(nitStr) {
        if (!nitStr) return false;
        var nit = nitStr.trim().toUpperCase().replace(/[\s-]/g, '');
        if (nit === 'CF' || nit === 'C/F') return true;
        if (nit.length < 2) return false;

        var checkChar = nit.charAt(nit.length - 1);
        var numeroStr = nit.substring(0, nit.length - 1);
        if (!/^\d+$/.test(numeroStr)) return false;

        var factor = numeroStr.length + 1;
        var total = 0;
        for (var i = 0; i < numeroStr.length; i++) {
            total += parseInt(numeroStr.charAt(i), 10) * factor;
            factor--;
        }
        var residuo = total % 11;
        var esperado = (11 - residuo) % 11;
        var esperadoChar = (esperado === 10) ? 'K' : esperado.toString();
        return checkChar === esperadoChar;
    }

    // Capitalizador estándar de nombres propios
    function capitalizarNombre(str) {
        if (!str) return '';
        var palabrasMenores = ['de', 'del', 'la', 'las', 'los', 'y', 'e'];
        return str.toLowerCase().split(' ').map(function(palabra, idx) {
            if (!palabra) return '';
            if (idx > 0 && palabrasMenores.indexOf(palabra) >= 0) return palabra;
            return palabra.charAt(0).toUpperCase() + palabra.slice(1);
        }).join(' ');
    }

    function initAntiError() {
        // 1. Control de Retiro vs Saldo
        var isRetiro = window.location.pathname.toLowerCase().indexOf('retiro') >= 0;
        if (isRetiro) {
            var montoInput = document.getElementById('Monto') || document.querySelector('input[name="Monto"]');
            var saldoEl = document.querySelector('.saldo-disponible, #saldo, [data-saldo]');
            var saldoVal = saldoEl ? parseFloat(saldoEl.textContent.replace(/[^\d.]/g, '')) : null;

            if (montoInput && saldoVal !== null) {
                montoInput.addEventListener('input', function() {
                    var m = parseFloat(montoInput.value) || 0;
                    if (m > saldoVal) {
                        montoInput.style.borderColor = '#EF4444';
                        montoInput.style.boxShadow = '0 0 0 3px rgba(239,68,68,0.25)';
                        showWarningBadge(montoInput, '¡Fondos Insuficientes! Saldo disponible: Q ' + saldoVal.toFixed(2));
                    } else {
                        montoInput.style.borderColor = '';
                        montoInput.style.boxShadow = '';
                        removeWarningBadge(montoInput);
                    }
                });
            }
        }

        // 2. Validación en vivo de DPI / CUI RENAP (Módulo 11)
        var dpiInputs = document.querySelectorAll('input[name*="DPI" i], input[name*="CUI" i], input[id*="DPI" i], input[id*="CUI" i], input[name*="Documento" i]');
        dpiInputs.forEach(function(dpiInput) {
            if (dpiInput.dataset.cuiBound) return;
            dpiInput.dataset.cuiBound = 'true';

            dpiInput.addEventListener('input', function() {
                var val = dpiInput.value.replace(/[\s-]/g, '');
                if (val.length === 13) {
                    if (validarCui(val)) {
                        dpiInput.style.borderColor = '#10B981';
                        dpiInput.style.boxShadow = '0 0 0 3px rgba(16,185,129,0.2)';
                        removeWarningBadge(dpiInput);
                        showSuccessBadge(dpiInput, '✓ CUI / DPI Válido (RENAP)');
                    } else {
                        dpiInput.style.borderColor = '#EF4444';
                        dpiInput.style.boxShadow = '0 0 0 3px rgba(239,68,68,0.25)';
                        removeSuccessBadge(dpiInput);
                        showWarningBadge(dpiInput, '⚠ CUI / DPI Inválido (Fallo dígito verificador RENAP)');
                    }
                } else {
                    dpiInput.style.borderColor = '';
                    dpiInput.style.boxShadow = '';
                    removeWarningBadge(dpiInput);
                    removeSuccessBadge(dpiInput);
                }
            });
        });

        // 3. Validación en vivo de NIT SAT
        var nitInputs = document.querySelectorAll('input[name*="NIT" i], input[id*="NIT" i]');
        nitInputs.forEach(function(nitInput) {
            if (nitInput.dataset.nitBound) return;
            nitInput.dataset.nitBound = 'true';
            nitInput.addEventListener('input', function() {
                var val = nitInput.value.trim();
                if (val.length >= 2) {
                    if (validarNit(val)) {
                        nitInput.style.borderColor = '#10B981';
                        nitInput.style.boxShadow = '0 0 0 3px rgba(16,185,129,0.2)';
                        removeWarningBadge(nitInput);
                        showSuccessBadge(nitInput, '✓ NIT Válido (SAT)');
                    } else if (val.replace(/[\s-]/g, '').length >= 5) {
                        nitInput.style.borderColor = '#EF4444';
                        nitInput.style.boxShadow = '0 0 0 3px rgba(239,68,68,0.25)';
                        removeSuccessBadge(nitInput);
                        showWarningBadge(nitInput, '⚠ NIT Inválido (Dígito verificador SAT erróneo)');
                    }
                } else {
                    nitInput.style.borderColor = '';
                    nitInput.style.boxShadow = '';
                    removeWarningBadge(nitInput);
                    removeSuccessBadge(nitInput);
                }
            });
        });

        // 4. Estandarización automática de Nombres Propios
        var nameInputs = document.querySelectorAll('input[name*="Nombre" i], input[name*="Apellido" i], input[id*="Nombre" i], input[id*="Apellido" i]');
        nameInputs.forEach(function(inp) {
            if (inp.dataset.nameBound) return;
            inp.dataset.nameBound = 'true';
            inp.addEventListener('blur', function() {
                var clean = inp.value.replace(/\s+/g, ' ').trim();
                if (clean) {
                    inp.value = capitalizarNombre(clean);
                }
            });
        });

        // 5. Máscara telefónica guatemalteca (####-####)
        var telInputs = document.querySelectorAll('input[name*="Telefono" i], input[name*="Celular" i], input[id*="Telefono" i], input[id*="Celular" i]');
        telInputs.forEach(function(telInput) {
            if (telInput.dataset.telBound) return;
            telInput.dataset.telBound = 'true';
            telInput.addEventListener('input', function() {
                var digits = telInput.value.replace(/\D/g, '').substring(0, 8);
                if (digits.length > 4) {
                    telInput.value = digits.substring(0, 4) + '-' + digits.substring(4);
                } else {
                    telInput.value = digits;
                }
            });
        });

        // 6. Modal de Confirmación en Pagos y Transacciones
        var transForm = document.querySelector('form[action*="Transaccion/Create"], form[action*="Transaccion/Retiro"], form[action*="Pago/Create"], form[action*="Micropago/Create"]');
        if (transForm && !transForm.dataset.antiErrorBound) {
            transForm.dataset.antiErrorBound = 'true';
            var submitBtn = transForm.querySelector('button[type="submit"], input[type="submit"]');

            if (submitBtn) {
                submitBtn.addEventListener('click', function(e) {
                    var montoInput = transForm.querySelector('input[name="Monto"]');
                    var monto = montoInput ? parseFloat(montoInput.value) : 0;
                    if (monto <= 0) return;

                    if (transForm.dataset.confirmed !== 'true') {
                        e.preventDefault();
                        showConfirmModal(monto, transForm);
                    }
                });
            }
        }

        // 7. Prevención de Doble Clic (Anti-Double-Submit)
        document.querySelectorAll('form').forEach(function(form) {
            if (form.dataset.antiDoubleClickBound) return;
            form.dataset.antiDoubleClickBound = 'true';
            form.addEventListener('submit', function(e) {
                if (form.dataset.submitting === 'true') {
                    e.preventDefault();
                    return false;
                }
                form.dataset.submitting = 'true';
                var btn = form.querySelector('button[type="submit"], input[type="submit"]');
                if (btn) {
                    btn.classList.add('disabled');
                    btn.setAttribute('disabled', 'disabled');
                    var origHtml = btn.innerHTML;
                    btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Procesando...';
                    setTimeout(function() {
                        btn.classList.remove('disabled');
                        btn.removeAttribute('disabled');
                        btn.innerHTML = origHtml;
                        form.dataset.submitting = 'false';
                    }, 4000);
                }
            });
        });
    }

    function showConfirmModal(monto, form) {
        var letras = numeroALetras(monto);
        var isRetiro = form.action.toLowerCase().indexOf('retiro') >= 0;
        var titulo = isRetiro ? 'Confirmación de Retiro de Efectivo' : 'Confirmación de Recepción de Fondos';
        var accionTexto = isRetiro ? 'ENTREGAR AL ASOCIADO' : 'RECIBIR EN EFECTIVO';
        var badgeColor = isRetiro ? '#EF4444' : '#10B981';

        var modalHtml = '<div id="anti-error-modal" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(8,14,24,0.75); backdrop-filter:blur(8px); z-index:99999; display:flex; align-items:center; justify-content:center; padding:15px; animation:fadeIn 0.2s ease;">' +
            '<div style="background:#FFFFFF; border-radius:18px; max-width:480px; width:100%; box-shadow:0 20px 40px rgba(0,0,0,0.3); overflow:hidden; border:1px solid #E2E8F0; text-align:center;">' +
            '<div style="background:#F8FAFC; padding:20px; border-bottom:1px solid #E2E8F0;">' +
            '<h4 style="margin:0; color:#0F528A; font-weight:700;"><i class="fa fa-shield"></i> ' + titulo + '</h4>' +
            '</div>' +
            '<div style="padding:28px 24px;">' +
            '<span style="display:inline-block; font-size:12px; font-weight:700; text-transform:uppercase; letter-spacing:1px; background:' + (isRetiro ? '#FEE2E2' : '#DCFCE7') + '; color:' + badgeColor + '; padding:4px 12px; border-radius:99px; margin-bottom:12px;">' + accionTexto + '</span>' +
            '<div style="font-size:36px; font-weight:800; color:#0F172A; margin-bottom:6px;">Q ' + monto.toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 }) + '</div>' +
            '<div style="font-size:14px; color:#475569; font-weight:600; line-height:1.4; background:#F1F5F9; padding:10px 14px; border-radius:10px; margin-bottom:20px;">' + letras + '</div>' +
            '<p style="font-size:13px; color:#64748B; margin:0;">Verifica que la cantidad en billetes coincida exactamente antes de confirmar.</p>' +
            '</div>' +
            '<div style="background:#F8FAFC; padding:16px 20px; display:flex; gap:12px; justify-content:center; border-top:1px solid #E2E8F0;">' +
            '<button type="button" id="btn-cancel-modal" class="btn btn-default" style="flex:1; border-radius:10px; font-weight:600;"><i class="fa fa-times"></i> Corregir</button>' +
            '<button type="button" id="btn-confirm-modal" class="btn btn-success" style="flex:2; border-radius:10px; font-weight:700; background:' + badgeColor + ';"><i class="fa fa-check-circle"></i> Confirmar</button>' +
            '</div>' +
            '</div>' +
            '</div>';

        var existing = document.getElementById('anti-error-modal');
        if (existing) existing.remove();

        document.body.insertAdjacentHTML('beforeend', modalHtml);

        document.getElementById('btn-cancel-modal').addEventListener('click', function() {
            document.getElementById('anti-error-modal').remove();
        });

        document.getElementById('btn-confirm-modal').addEventListener('click', function() {
            form.dataset.confirmed = 'true';
            var btn = document.getElementById('btn-confirm-modal');
            btn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Procesando...';
            btn.style.pointerEvents = 'none';

            var submitBtn = form.querySelector('button[type="submit"], input[type="submit"]');
            if (submitBtn) {
                submitBtn.click();
            } else {
                form.submit();
            }
        });
    }

    function showWarningBadge(input, msg) {
        var existing = input.parentElement.querySelector('.anti-error-warning');
        if (!existing) {
            var b = document.createElement('div');
            b.className = 'anti-error-warning';
            b.style.cssText = 'color:#DC2626; font-size:12px; font-weight:700; margin-top:5px;';
            b.innerHTML = '<i class="fa fa-exclamation-triangle"></i> ' + msg;
            input.parentElement.appendChild(b);
        }
    }

    function removeWarningBadge(input) {
        var existing = input.parentElement.querySelector('.anti-error-warning');
        if (existing) existing.remove();
    }

    function showSuccessBadge(input, msg) {
        var existing = input.parentElement.querySelector('.anti-error-success');
        if (!existing) {
            var b = document.createElement('div');
            b.className = 'anti-error-success';
            b.style.cssText = 'color:#10B981; font-size:12px; font-weight:700; margin-top:5px;';
            b.innerHTML = '<i class="fa fa-check-circle"></i> ' + msg;
            input.parentElement.appendChild(b);
        }
    }

    function removeSuccessBadge(input) {
        var existing = input.parentElement.querySelector('.anti-error-success');
        if (existing) existing.remove();
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initAntiError);
    } else {
        initAntiError();
    }
    window.addEventListener('load', initAntiError);
})();
