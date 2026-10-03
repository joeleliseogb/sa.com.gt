/**
 * Acción Cooperativa R.L. - Form Wizard & Smart Stepper Engine (v2)
 * Automatically transforms multi-section forms (with h4, legend, or .box)
 * into modern, responsive, bite-sized multi-step wizards with real-time validation
 * and financial credit underwriting capacity analysis.
 */
(function() {
    'use strict';

    function initFormWizards() {
        var forms = document.querySelectorAll('form');
        forms.forEach(function(form) {
            if (form.classList.contains('no-wizard')) return;
            if (form.dataset.wizardInitialized === 'true') return;

            var action = (form.getAttribute('action') || window.location.pathname).toLowerCase();

            // 1. Specialized Crédito Wizard
            if (form.id === 'form-credito' || action.indexOf('/credito/create') >= 0 || action.indexOf('/credito/edit') >= 0) {
                buildCreditoWizard(form);
                return;
            }

            // 2. Specialized Microcrédito Wizard
            if (action.indexOf('/microcredito/create') >= 0 || action.indexOf('/microcredito/edit') >= 0) {
                buildMicrocreditoWizard(form);
                return;
            }

            // 3. Multi-heading forms (like Socio/Create)
            var headings = form.querySelectorAll('.box-body > h4, .box-body > legend, fieldset > legend');
            var inputs = form.querySelectorAll('input:not([type="hidden"]), select, textarea');

            if ((headings.length >= 2 || form.classList.contains('smart-wizard')) && inputs.length >= 6) {
                buildWizardFromHeadings(form, headings);
                return;
            }

            // 4. Multi-box forms
            var boxes = form.querySelectorAll(':scope > .box, :scope > div > .box');
            if (boxes.length >= 2 && inputs.length >= 6) {
                buildWizardFromBoxes(form, boxes);
            }
        });
    }

    // Common Wizard Builder Engine
    function buildWizardUI(form, stepsData, submitBtn) {
        form.dataset.wizardInitialized = 'true';
        form.classList.add('smart-wizard-form');

        var container = document.createElement('div');
        container.className = 'smart-wizard-container';

        // Stepper Header
        var header = document.createElement('div');
        header.className = 'wizard-stepper-header';
        var totalSteps = stepsData.length;
        var panes = [];

        stepsData.forEach(function(sData, idx) {
            var ind = document.createElement('div');
            ind.className = 'wizard-step-indicator' + (idx === 0 ? ' active' : '');
            ind.dataset.stepIndex = idx;
            ind.innerHTML = '<div class="step-circle">' + (idx + 1) + '</div>' +
                '<div class="step-info">' +
                '<span class="step-num">Paso ' + (idx + 1) + ' de ' + totalSteps + '</span>' +
                '<span class="step-title">' + sData.title + '</span>' +
                '</div>';

            ind.addEventListener('click', function() {
                var cur = parseInt(container.dataset.currentStep || '0', 10);
                if (idx < cur) {
                    goToStep(container, panes, header, actionsBar, submitBtn, idx);
                } else if (idx > cur) {
                    if (validatePane(panes[cur])) {
                        goToStep(container, panes, header, actionsBar, submitBtn, idx);
                    }
                }
            });
            header.appendChild(ind);

            var pane = document.createElement('div');
            pane.className = 'wizard-step-pane' + (idx === 0 ? ' active' : '');
            pane.dataset.stepIndex = idx;
            pane.dataset.stepTitle = sData.title;

            sData.elements.forEach(function(el) {
                pane.appendChild(el);
            });

            container.appendChild(pane);
            panes.push(pane);
        });

        container.insertBefore(header, container.firstChild);

        // Actions Bar
        var actionsBar = document.createElement('div');
        actionsBar.className = 'wizard-actions-bar';
        actionsBar.innerHTML = '<button type="button" class="btn btn-default btn-wizard-prev" style="display:none;">' +
            '<i class="fa fa-arrow-left"></i> Anterior</button>' +
            '<div class="wizard-progress-counter text-muted" style="font-weight:600; font-size:13px;">Paso 1 de ' + totalSteps + '</div>' +
            '<button type="button" class="btn btn-primary btn-wizard-next">Siguiente <i class="fa fa-arrow-right"></i></button>';

        container.appendChild(actionsBar);

        // Append submit button to actions bar
        if (submitBtn) {
            submitBtn.style.display = 'none';
            actionsBar.appendChild(submitBtn);

            submitBtn.addEventListener('click', function(e) {
                var cur = parseInt(container.dataset.currentStep || '0', 10);
                if (!validatePane(panes[cur])) {
                    e.preventDefault();
                    return false;
                }
                var token = form.querySelector('input[name="__IdempotencyKey"]');
                if (!token) {
                    token = document.createElement('input');
                    token.type = 'hidden';
                    token.name = '__IdempotencyKey';
                    token.value = Date.now() + '-' + Math.random().toString(36).substring(2, 9);
                    form.appendChild(token);
                }
                submitBtn.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Guardando...';
                submitBtn.style.pointerEvents = 'none';
                submitBtn.style.opacity = '0.7';
            });
        }

        var btnPrev = actionsBar.querySelector('.btn-wizard-prev');
        var btnNext = actionsBar.querySelector('.btn-wizard-next');

        btnNext.addEventListener('click', function() {
            var cur = parseInt(container.dataset.currentStep || '0', 10);
            if (validatePane(panes[cur])) {
                goToStep(container, panes, header, actionsBar, submitBtn, cur + 1);
            }
        });

        btnPrev.addEventListener('click', function() {
            var cur = parseInt(container.dataset.currentStep || '0', 10);
            goToStep(container, panes, header, actionsBar, submitBtn, cur - 1);
        });

        container.dataset.currentStep = '0';
        updateStepViews(container, panes, header, actionsBar, submitBtn, 0);

        return container;
    }

    function buildWizardFromHeadings(form, headings) {
        var boxBody = form.querySelector('.box-body') || form;
        var boxFooter = form.querySelector('.box-footer');
        var submitBtn = form.querySelector('button[type="submit"], input[type="submit"]');

        var stepsData = [];
        var currentSectionTitle = '1. Datos Principales';
        var currentElements = [];

        var children = Array.from(boxBody.children);
        children.forEach(function(child) {
            if (child.tagName === 'H4' || child.tagName === 'LEGEND') {
                if (currentElements.length > 0) {
                    stepsData.push({ title: currentSectionTitle, elements: currentElements });
                    currentElements = [];
                }
                currentSectionTitle = child.textContent.replace(/[•\-\:\d]/g, '').trim();
                child.style.display = 'none';
            } else if (child.tagName === 'HR') {
                child.style.display = 'none';
            } else {
                currentElements.push(child);
            }
        });

        if (currentElements.length > 0) {
            stepsData.push({ title: currentSectionTitle, elements: currentElements });
        }

        if (stepsData.length < 2) return;

        if (boxFooter) boxFooter.style.display = 'none';
        var container = buildWizardUI(form, stepsData, submitBtn);
        boxBody.appendChild(container);
    }

    function buildWizardFromBoxes(form, boxes) {
        var submitBtn = form.querySelector('button[type="submit"], input[type="submit"]');
        var stepsData = [];

        boxes.forEach(function(box, i) {
            var titleEl = box.querySelector('.box-title, .box-header strong');
            var title = titleEl ? titleEl.textContent.trim() : ('Paso ' + (i + 1));
            stepsData.push({ title: title, elements: [box] });
        });

        if (stepsData.length < 2) return;

        var parent = boxes[0].parentNode;
        var container = buildWizardUI(form, stepsData, submitBtn);
        parent.appendChild(container);
    }

    // Specialized Crédito Underwriting Wizard
    function buildCreditoWizard(form) {
        var boxes = form.querySelectorAll('.box');
        if (boxes.length < 2) return;

        var boxAsociado = boxes[0];
        var boxCredito = boxes[1];
        var submitBtn = form.querySelector('button[type="submit"], input[type="submit"]');

        // Locate rows & elements inside boxCredito
        var boxBodyCredito = boxCredito.querySelector('.box-body');
        if (!boxBodyCredito) return;

        var mainRow = boxBodyCredito.querySelector('.row');
        var tabpanel = boxBodyCredito.querySelector('div[role="tabpanel"]');
        var hr = boxBodyCredito.querySelector('hr');
        var h4Garantias = boxBodyCredito.querySelector('h4');

        if (!mainRow) return;

        // Step 1 Elements: Asociado + Condiciones del Crédito
        var step1Container = document.createElement('div');
        step1Container.appendChild(boxAsociado);

        var step1CreditoBox = document.createElement('div');
        step1CreditoBox.className = 'box box-primary';
        step1CreditoBox.innerHTML = '<div class="box-header with-border"><strong><i class="fa fa-money"></i> Parámetros y Condiciones del Crédito</strong></div>';
        var step1Body = document.createElement('div');
        step1Body.className = 'box-body';
        var step1Row = document.createElement('div');
        step1Row.className = 'row';

        // Step 2 Elements: Estudio Socioeconómico y Capacidad de Pago
        var step2Container = document.createElement('div');
        step2Container.className = 'box box-primary';
        step2Container.innerHTML = '<div class="box-header with-border"><strong><i class="fa fa-line-chart"></i> Estudio Socioeconómico y Capacidad de Pago</strong></div>';
        var step2Body = document.createElement('div');
        step2Body.className = 'box-body';
        var step2Row = document.createElement('div');
        step2Row.className = 'row';

        // Underwriting Card (Live debt capacity analysis)
        var uwCard = document.createElement('div');
        uwCard.className = 'underwriting-card';
        uwCard.innerHTML = '<div style="margin:10px 0 20px 0; background:linear-gradient(135deg, #F8FAFC 0%, #EFF6FF 100%); border:1px solid #BFDBFE; border-radius:14px; padding:18px; box-shadow:0 4px 12px rgba(15,82,138,0.06);">' +
            '<div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; flex-wrap:wrap; gap:10px;">' +
            '<h4 style="margin:0; font-size:15px; font-weight:700; color:#0F528A;"><i class="fa fa-calculator text-primary"></i> Capacidad de Pago y Riesgo Crediticio</h4>' +
            '<span id="uw-risk-badge" class="label label-success" style="font-size:12px; padding:6px 12px; border-radius:20px; font-weight:700;">Capacidad Óptima</span>' +
            '</div>' +
            '<div class="row text-center" style="margin-bottom:12px;">' +
            '<div class="col-xs-6 col-sm-3" style="margin-bottom:8px;"><div style="font-size:11px; text-transform:uppercase; color:#64748B; font-weight:700;">Ingreso Total</div><div id="uw-ingreso-total" style="font-size:16px; font-weight:800; color:#0F172A;">Q 0.00</div></div>' +
            '<div class="col-xs-6 col-sm-3" style="margin-bottom:8px;"><div style="font-size:11px; text-transform:uppercase; color:#64748B; font-weight:700;">Egreso Total</div><div id="uw-egreso-total" style="font-size:16px; font-weight:800; color:#EF4444;">Q 0.00</div></div>' +
            '<div class="col-xs-6 col-sm-3" style="margin-bottom:8px;"><div style="font-size:11px; text-transform:uppercase; color:#64748B; font-weight:700;">Flujo Libre</div><div id="uw-disponible" style="font-size:16px; font-weight:800; color:#10B981;">Q 0.00</div></div>' +
            '<div class="col-xs-6 col-sm-3" style="margin-bottom:8px;"><div style="font-size:11px; text-transform:uppercase; color:#64748B; font-weight:700;">Cuota Est.</div><div id="uw-cuota-est" style="font-size:16px; font-weight:800; color:#2563EB;">Q 0.00</div></div>' +
            '</div>' +
            '<div style="background:#E2E8F0; height:8px; border-radius:4px; overflow:hidden; margin-top:8px;">' +
            '<div id="uw-ratio-bar" style="background:#10B981; width:0%; height:100%; transition:width 0.3s ease, background 0.3s ease;"></div>' +
            '</div>' +
            '<div id="uw-ratio-text" style="font-size:12px; color:#475569; margin-top:6px; font-weight:600; text-align:right;">Relación Cuota / Ingreso: 0% (Límite prudencial: 40%)</div>' +
            '</div>';
        step2Body.appendChild(uwCard);

        // Partition form groups in mainRow
        var formGroups = Array.from(mainRow.children);
        var socioEconomicFields = ['IngresoPersonal', 'IngresoFamiliar', 'EgresoMensual', 'EgresoFamiliar', 'MenajeCasa', 'TelefonoTrabajo', 'DireccionTrabajo'];

        formGroups.forEach(function(fg) {
            var isSocioEconomic = false;
            socioEconomicFields.forEach(function(fieldName) {
                if (fg.querySelector('[name*="' + fieldName + '"]') || fg.querySelector('[id*="' + fieldName + '"]')) {
                    isSocioEconomic = true;
                }
            });

            if (isSocioEconomic) {
                step2Row.appendChild(fg);
            } else {
                step1Row.appendChild(fg);
            }
        });

        step1Body.appendChild(step1Row);
        step1CreditoBox.appendChild(step1Body);
        step1Container.appendChild(step1CreditoBox);

        step2Body.appendChild(step2Row);
        step2Container.appendChild(step2Body);

        // Step 3 Elements: Garantías, Fiadores y Referencias
        var step3Container = document.createElement('div');
        step3Container.className = 'box box-primary';
        step3Container.innerHTML = '<div class="box-header with-border"><strong><i class="fa fa-shield"></i> Garantías, Fiadores y Referencias</strong></div>';
        var step3Body = document.createElement('div');
        step3Body.className = 'box-body';

        if (h4Garantias) h4Garantias.style.display = 'none';
        if (hr) hr.style.display = 'none';
        if (tabpanel) step3Body.appendChild(tabpanel);

        step3Container.appendChild(step3Body);

        // Hide original boxCredito
        boxCredito.style.display = 'none';

        var stepsData = [
            { title: 'Condiciones del Crédito', elements: [step1Container] },
            { title: 'Estudio Socioeconómico', elements: [step2Container] },
            { title: 'Garantías y Fiadores', elements: [step3Container] }
        ];

        var container = buildWizardUI(form, stepsData, submitBtn);
        form.appendChild(container);

        // Bind Underwriting calculation
        bindUnderwritingCalculator(form);
    }

    // Specialized Microcrédito Wizard
    function buildMicrocreditoWizard(form) {
        var boxes = form.querySelectorAll('.box');
        if (boxes.length < 2) return;

        var boxAsociado = boxes[0];
        var boxMicro = boxes[1];
        var submitBtn = form.querySelector('button[type="submit"], input[type="submit"]');

        var stepsData = [
            { title: 'Datos del Asociado', elements: [boxAsociado] },
            { title: 'Datos del Microcrédito', elements: [boxMicro] }
        ];

        var container = buildWizardUI(form, stepsData, submitBtn);
        form.appendChild(container);
    }

    // Real-Time Debt Capacity & Risk Calculator
    function bindUnderwritingCalculator(form) {
        var inputMonto = form.querySelector('input[name*="Importe"]');
        var inputCuotas = form.querySelector('input[name*="NumeroCuotas"]');
        var inputInteres = form.querySelector('input[name*="Interes"]');
        var inputIngresoPers = form.querySelector('input[name*="IngresoPersonal"]');
        var inputIngresoFam = form.querySelector('input[name*="IngresoFamiliar"]');
        var inputEgresoMens = form.querySelector('input[name*="EgresoMensual"]');
        var inputEgresoFam = form.querySelector('input[name*="EgresoFamiliar"]');

        function recalc() {
            var monto = parseFloat(inputMonto ? inputMonto.value : 0) || 0;
            var cuotas = parseInt(inputCuotas ? inputCuotas.value : 1, 10) || 1;
            var interesAnual = parseFloat(inputInteres ? inputInteres.value : 0) || 0;

            var ingPers = parseFloat(inputIngresoPers ? inputIngresoPers.value : 0) || 0;
            var ingFam = parseFloat(inputIngresoFam ? inputIngresoFam.value : 0) || 0;
            var egresoMens = parseFloat(inputEgresoMens ? inputEgresoMens.value : 0) || 0;
            var egresoFam = parseFloat(inputEgresoFam ? inputEgresoFam.value : 0) || 0;

            var totalIngresos = ingPers + ingFam;
            var totalEgresos = egresoMens + egresoFam;
            var disponible = totalIngresos - totalEgresos;

            // Cuota estimada mensual: amortización capital + interés mensual
            var cuotaCapital = cuotas > 0 ? (monto / cuotas) : 0;
            var cuotaInteres = monto * (interesAnual / 100 / 12);
            var cuotaEstimada = cuotaCapital + cuotaInteres;

            var ratio = totalIngresos > 0 ? (cuotaEstimada / totalIngresos) * 100 : 0;

            // UI Elements
            var elIngreso = document.getElementById('uw-ingreso-total');
            var elEgreso = document.getElementById('uw-egreso-total');
            var elDisp = document.getElementById('uw-disponible');
            var elCuota = document.getElementById('uw-cuota-est');
            var elBadge = document.getElementById('uw-risk-badge');
            var elBar = document.getElementById('uw-ratio-bar');
            var elText = document.getElementById('uw-ratio-text');

            if (elIngreso) elIngreso.textContent = 'Q ' + totalIngresos.toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            if (elEgreso) elEgreso.textContent = 'Q ' + totalEgresos.toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            if (elDisp) elDisp.textContent = 'Q ' + disponible.toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
            if (elCuota) elCuota.textContent = 'Q ' + cuotaEstimada.toLocaleString('es-GT', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

            if (elBar && elBadge && elText) {
                var widthPct = Math.min(Math.round(ratio), 100);
                elBar.style.width = widthPct + '%';

                if (ratio <= 0) {
                    elBadge.className = 'label label-default';
                    elBadge.textContent = 'Sin Datos';
                    elBadge.style.background = '#94A3B8';
                    elBar.style.background = '#94A3B8';
                } else if (ratio <= 35) {
                    elBadge.className = 'label label-success';
                    elBadge.textContent = 'Capacidad Óptima (Riesgo Bajo)';
                    elBadge.style.background = '#10B981';
                    elBar.style.background = '#10B981';
                } else if (ratio <= 45) {
                    elBadge.className = 'label label-warning';
                    elBadge.textContent = 'Capacidad Ajustada (Requiere Fiador)';
                    elBadge.style.background = '#F59E0B';
                    elBar.style.background = '#F59E0B';
                } else {
                    elBadge.className = 'label label-danger';
                    elBadge.textContent = '⚠ Sobreendeudamiento (> 45%)';
                    elBadge.style.background = '#EF4444';
                    elBar.style.background = '#EF4444';
                }

                elText.textContent = 'Relación Cuota / Ingreso: ' + ratio.toFixed(1) + '% (Límite prudencial: 40%)';
            }
        }

        var watched = [inputMonto, inputCuotas, inputInteres, inputIngresoPers, inputIngresoFam, inputEgresoMens, inputEgresoFam];
        watched.forEach(function(inp) {
            if (inp) {
                inp.addEventListener('input', recalc);
                inp.addEventListener('change', recalc);
            }
        });

        recalc();
    }

    function goToStep(container, panes, header, actionsBar, submitBtn, target) {
        if (target >= 0 && target < panes.length) {
            container.dataset.currentStep = target.toString();
            updateStepViews(container, panes, header, actionsBar, submitBtn, target);
            container.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
    }

    function updateStepViews(container, panes, header, actionsBar, submitBtn, current) {
        var total = panes.length;
        panes.forEach(function(p, i) {
            if (i === current) {
                p.classList.add('active');
            } else {
                p.classList.remove('active');
            }
        });

        var indicators = header.querySelectorAll('.wizard-step-indicator');
        indicators.forEach(function(ind, i) {
            ind.classList.remove('active');
            if (i === current) {
                ind.classList.add('active');
            } else if (i < current) {
                ind.classList.add('completed');
            }
        });

        var btnPrev = actionsBar.querySelector('.btn-wizard-prev');
        var btnNext = actionsBar.querySelector('.btn-wizard-next');
        var counter = actionsBar.querySelector('.wizard-progress-counter');

        btnPrev.style.display = (current === 0) ? 'none' : 'inline-flex';
        counter.textContent = 'Paso ' + (current + 1) + ' de ' + total;

        if (current === total - 1) {
            btnNext.style.display = 'none';
            if (submitBtn) submitBtn.style.display = 'inline-flex';
        } else {
            btnNext.style.display = 'inline-flex';
            if (submitBtn) submitBtn.style.display = 'none';
        }
    }

    function validatePane(pane) {
        var inputs = pane.querySelectorAll('input:not([type="hidden"]), select, textarea');
        var isValid = true;
        var firstInvalid = null;

        inputs.forEach(function(input) {
            input.classList.remove('has-error');
            var isRequired = input.hasAttribute('required') || (input.className && input.className.indexOf('validate[required') >= 0);
            if (isRequired && !input.value.trim()) {
                isValid = false;
                input.classList.add('has-error');
                if (!firstInvalid) firstInvalid = input;
            }

            if ((input.name && input.name.toLowerCase().indexOf('cui') >= 0) || input.id === 'Cui') {
                var clean = input.value.replace(/[\s-]/g, '');
                if (clean && (clean.length !== 13 || !/^\d+$/.test(clean))) {
                    isValid = false;
                    input.classList.add('has-error');
                    alert('El CUI / DPI debe contener exactamente 13 dígitos numéricos.');
                    if (!firstInvalid) firstInvalid = input;
                }
            }
        });

        if (!isValid && firstInvalid) {
            firstInvalid.focus();
        }
        return isValid;
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initFormWizards);
    } else {
        initFormWizards();
    }
    window.addEventListener('load', initFormWizards);
})();
