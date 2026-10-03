/**
 * Acción Cooperativa R.L. - Módulo Touch POS para Caja y Ventanilla
 * Transforma los formularios de depósitos, retiros y pagos en terminales ágiles
 * con teclado numérico táctil, denominaciones rápidas de billetes (Q50, Q100, Q200, Q500, Q1000)
 * y lectura inmediata de montos en letras.
 */
(function() {
    'use strict';

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

    function initPosCaja() {
        var action = window.location.pathname.toLowerCase();
        var isTransactionPage = action.indexOf('transaccion') >= 0 || action.indexOf('pago') >= 0 || action.indexOf('caja') >= 0;
        
        var montoInput = document.getElementById('Monto') || document.querySelector('input[name="Monto"]');
        if (!montoInput || montoInput.dataset.posInitialized === 'true') return;

        montoInput.dataset.posInitialized = 'true';
        montoInput.style.fontSize = '22px';
        montoInput.style.fontWeight = '800';
        montoInput.style.color = '#0F528A';

        // Container wrapper
        var parentFg = montoInput.closest('.form-group') || montoInput.parentElement;
        
        // Quick Denomination Chips
        var chipsContainer = document.createElement('div');
        chipsContainer.className = 'pos-quick-chips';
        chipsContainer.style.cssText = 'display:flex; flex-wrap:wrap; gap:8px; margin-top:10px; margin-bottom:8px;';

        var denominations = [
            { label: '+ Q 50', val: 50 },
            { label: '+ Q 100', val: 100 },
            { label: '+ Q 200', val: 200 },
            { label: '+ Q 500', val: 500 },
            { label: '+ Q 1,000', val: 1000 }
        ];

        denominations.forEach(function(d) {
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'btn btn-default btn-xs pos-chip-btn';
            btn.style.cssText = 'border-radius:20px; font-weight:700; padding:6px 14px; background:#F1F5F9; border:1px solid #CBD5E1; color:#0F528A; transition:all 0.15s ease;';
            btn.textContent = d.label;

            btn.addEventListener('click', function(e) {
                e.preventDefault();
                var cur = parseFloat(montoInput.value) || 0;
                var nuevo = cur + d.val;
                montoInput.value = nuevo.toFixed(2);
                montoInput.dispatchEvent(new Event('input', { bubbles: true }));
                montoInput.dispatchEvent(new Event('change', { bubbles: true }));
            });
            chipsContainer.appendChild(btn);
        });

        // Clear button
        var btnClear = document.createElement('button');
        btnClear.type = 'button';
        btnClear.className = 'btn btn-default btn-xs pos-chip-clear';
        btnClear.style.cssText = 'border-radius:20px; font-weight:700; padding:6px 14px; background:#FEE2E2; border:1px solid #FCA5A5; color:#DC2626;';
        btnClear.innerHTML = '<i class="fa fa-eraser"></i> Borrar';
        btnClear.addEventListener('click', function(e) {
            e.preventDefault();
            montoInput.value = '';
            montoInput.dispatchEvent(new Event('input', { bubbles: true }));
            montoInput.dispatchEvent(new Event('change', { bubbles: true }));
        });
        chipsContainer.appendChild(btnClear);

        // Live Letras Display
        var letrasBox = document.createElement('div');
        letrasBox.className = 'pos-live-letras';
        letrasBox.style.cssText = 'display:none; margin-top:8px; background:#EFF6FF; border:1px solid #BFDBFE; border-radius:10px; padding:8px 14px; font-size:13px; font-weight:700; color:#0F528A; animation:fadeIn 0.2s ease;';
        letrasBox.innerHTML = '<i class="fa fa-font"></i> <span class="letras-content"></span>';

        // Insert below monto
        montoInput.parentElement.appendChild(chipsContainer);
        montoInput.parentElement.appendChild(letrasBox);

        function updateLetras() {
            var val = parseFloat(montoInput.value) || 0;
            if (val > 0) {
                var letras = numeroALetras(val);
                letrasBox.querySelector('.letras-content').textContent = letras;
                letrasBox.style.display = 'block';
            } else {
                letrasBox.style.display = 'none';
            }
        }

        montoInput.addEventListener('input', updateLetras);
        montoInput.addEventListener('change', updateLetras);
        updateLetras();

        // Modernize Navigation Tabs on Transaction page
        var navTabs = document.querySelectorAll('.nav-tabs');
        navTabs.forEach(function(tab) {
            tab.classList.add('nav-pills-modern');
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initPosCaja);
    } else {
        initPosCaja();
    }
    window.addEventListener('load', initPosCaja);
})();
