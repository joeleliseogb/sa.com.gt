/**
 * Acción Cooperativa R.L. - Form Wizard & Smart Stepper Engine (v3 Enterprise)
 * Automatically transforms multi-section forms (with h4, legend, or .box)
 * into modern, responsive, bite-sized multi-step wizards with real-time validation,
 * master error banners, mobile-sticky save button, and financial credit underwriting.
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

    // Helper: extract human-friendly label for any form field
    function getFriendlyLabel(input) {
        if (!input) return 'Campo requerido';

        // 1. Check for label element
        var label = null;
        if (input.id) {
            label = document.querySelector('label[for="' + input.id + '"]');
        }
        if (!label) {
            var fg = input.closest('.form-group');
            if (fg) {
                label = fg.querySelector('label');
            }
        }
        if (label && label.textContent.trim()) {
            return label.textContent.replace(/[*:\-\•]/g, '').trim();
        }

        // 2. Check placeholder or title
        if (input.placeholder) return input.placeholder.trim();
        if (input.title) return input.title.trim();

        // 3. Known field map for GTcop
        var nameOrId = (input.name || input.id || '').toLowerCase();
        if (nameOrId.indexOf('docorden') >= 0 || nameOrId.indexOf('orden') >= 0) return 'Tipo de Documento';
        if (nameOrId.indexOf('docregistro') >= 0 || nameOrId.indexOf('registro') >= 0 || nameOrId.indexOf('cui') >= 0 || nameOrId.indexOf('dpi') >= 0) return 'Número de Documento (CUI / DPI)';
        if (nameOrId.indexOf('deptosiddoc') >= 0) return 'Departamento de Emisión del Documento';
        if (nameOrId.indexOf('selecteddoc') >= 0) return 'Municipio de Emisión del Documento';
        if (nameOrId.indexOf('primernombre') >= 0) return 'Primer Nombre';
        if (nameOrId.indexOf('segundonombre') >= 0) return 'Segundo Nombre';
        if (nameOrId.indexOf('primerapellido') >= 0) return 'Primer Apellido';
        if (nameOrId.indexOf('segundoapellido') >= 0) return 'Segundo Apellido';
        if (nameOrId.indexOf('estadocivil') >= 0) return 'Estado Civil';
        if (nameOrId.indexOf('nombreconyugue') >= 0) return 'Nombre del Cónyuge';
        if (nameOrId.indexOf('fechanacimiento') >= 0) return 'Fecha de Nacimiento';
        if (nameOrId.indexOf('sexo') >= 0 || nameOrId.indexOf('genero') >= 0) return 'Género / Sexo';
        if (nameOrId.indexOf('actividad') >= 0) return 'Actividad Económica';
        if (nameOrId.indexOf('ingresopromedio') >= 0 || nameOrId.indexOf('ingresopersonal') >= 0) return 'Ingreso Promedio';
        if (nameOrId.indexOf('egresopromedio') >= 0 || nameOrId.indexOf('egresomensual') >= 0) return 'Egreso Promedio';
        if (nameOrId.indexOf('nohijos') >= 0) return 'Número de Hijos';
        if (nameOrId.indexOf('direccion1') >= 0) return 'Dirección de Residencia';
        if (nameOrId.indexOf('deptosiddir') >= 0) return 'Departamento de Residencia';
        if (nameOrId.indexOf('selecteddir') >= 0) return 'Municipio de Residencia';
        if (nameOrId.indexOf('telefono') >= 0) return 'Teléfono';
        if (nameOrId.indexOf('celular') >= 0) return 'Celular';
        if (nameOrId.indexOf('nit') >= 0) return 'NIT';

        return input.name || input.id || 'Campo requerido';
    }

    // Helper: validate a single input element
    function validateSingleInput(input) {
        if (!input || input.type === 'hidden') return { valid: true };

        var val = (input.value || '').trim();
        var isRequired = input.hasAttribute('required') || 
            (input.className && input.className.indexOf('validate[required') >= 0);

        // Required check
        if (isRequired) {
            if (input.type === 'radio') {
                var group = input.form ? input.form.querySelectorAll('input[name="' + input.name + '"]') : [];
                var oneChecked = Array.from(group).some(function(r) { return r.checked; });
                if (!oneChecked) {
                    return { valid: false, message: 'Debe seleccionar una opción' };
                }
            } else if (!val || val === '' || val === '0' && (input.id.indexOf('Selected') >= 0 || input.id.indexOf('Deptos') >= 0)) {
                return { valid: false, message: 'Este campo es obligatorio' };
            }
        }

        // DPI / CUI specific check (Guatemala 13 numeric digits)
        var nameOrId = (input.name || input.id || '').toLowerCase();
        var isDpi = nameOrId.indexOf('cui') >= 0 || nameOrId.indexOf('dpi') >= 0 || input.id === 'docRegistro';
        if (isDpi && val.length > 0) {
            var docOrdenVal = '';
            var docOrdenEl = document.getElementById('docOrden') || (input.form && input.form.querySelector('[name*="Orden"]'));
            if (docOrdenEl) docOrdenVal = docOrdenEl.value;

            // If doc type is DPI or default
            if (!docOrdenVal || docOrdenVal === 'DPI' || docOrdenVal === 'CUI') {
                var clean = val.replace(/[\s-]/g, '');
                if (clean.length !== 13 || !/^\d+$/.test(clean)) {
                    return { 
                        valid: false, 
                        message: 'El CUI / DPI debe tener exactamente 13 dígitos numéricos (actualmente tiene ' + clean.length + ')' 
                    };
                }
            }
        }

        // Positive number check
        if (input.className && input.className.indexOf('custom[number]') >= 0 && val.length > 0) {
            var num = parseFloat(val);
            if (isNaN(num) || num <= 0) {
                return { valid: false, message: 'Debe ingresar una cantidad numérica mayor a 0' };
            }
        }

        // Integer check
        if (input.className && input.className.indexOf('custom[integer]') >= 0 && val.length > 0) {
            var intVal = parseInt(val, 10);
            if (isNaN(intVal) || intVal < 0) {
                return { valid: false, message: 'Debe ingresar un número entero válido (0 o mayor)' };
            }
        }

        return { valid: true };
    }

    // Apply error highlight and inline badge
    function markFieldError(input, message) {
        input.classList.add('field-error-highlight');
        var fg = input.closest('.form-group') || input.parentElement;
        if (fg) {
            fg.classList.add('has-error');
            // Remove previous error badge if any
            var oldBadge = fg.querySelector('.wizard-inline-error');
            if (oldBadge) oldBadge.remove();

            var badge = document.createElement('div');
            badge.className = 'wizard-inline-error';
            badge.innerHTML = '<i class="fa fa-exclamation-circle"></i> ' + message;
            fg.appendChild(badge);
        }
    }

    // Clear error highlight and badge
    function clearFieldError(input) {
        input.classList.remove('field-error-highlight');
        var fg = input.closest('.form-group') || input.parentElement;
        if (fg) {
            fg.classList.remove('has-error');
            var oldBadge = fg.querySelector('.wizard-inline-error');
            if (oldBadge) oldBadge.remove();
        }
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

        // 1. View Mode Switcher Button
        var toggleModeBtn = document.createElement('button');
        toggleModeBtn.type = 'button';
        toggleModeBtn.className = 'btn btn-default btn-xs btn-mode-toggle';
        toggleModeBtn.style.cssText = 'flex:0 0 auto; border-radius:20px; font-weight:700; padding:6px 14px; margin-right:8px; border:1px solid #CBD5E1; color:#0F528A;';
        toggleModeBtn.innerHTML = '<i class="fa fa-th-list"></i> Ver Todo Continuo';
        header.appendChild(toggleModeBtn);

        // 2. Step Indicators
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
                if (container.classList.contains('continuous-mode')) {
                    panes[idx].scrollIntoView({ behavior: 'smooth', block: 'start' });
                    return;
                }
                var cur = parseInt(container.dataset.currentStep || '0', 10);
                if (idx < cur) {
                    goToStep(container, panes, header, actionsBar, submitBtn, idx);
                } else if (idx > cur) {
                    var curErrors = validatePane(panes[cur], true);
                    if (curErrors.length === 0) {
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

        // Master Error Banner Container
        var masterBannerContainer = document.createElement('div');
        masterBannerContainer.className = 'wizard-master-banner-wrap';
        container.insertBefore(masterBannerContainer, header.nextSibling);

        // Actions Bar
        var actionsBar = document.createElement('div');
        actionsBar.className = 'wizard-actions-bar';
        actionsBar.innerHTML = '<button type="button" class="btn btn-default btn-wizard-prev" style="display:none;">' +
            '<i class="fa fa-arrow-left"></i> Anterior</button>' +
            '<div class="wizard-progress-counter text-muted" style="font-weight:600; font-size:13px;">Paso 1 de ' + totalSteps + '</div>' +
            '<button type="button" class="btn btn-primary btn-wizard-next">Siguiente <i class="fa fa-arrow-right"></i></button>';

        container.appendChild(actionsBar);

        // Setup Submit Button: ALWAYS VISIBLE ON ALL STEPS
        if (!submitBtn) {
            submitBtn = document.createElement('button');
            submitBtn.type = 'submit';
            submitBtn.className = 'btn btn-success btn-wizard-submit';
            submitBtn.innerHTML = '<i class="fa fa-floppy-o"></i> Guardar Asociado';
        } else {
            submitBtn.classList.add('btn-wizard-submit');
            // If button text is generic or short, make it prominent
            if (!submitBtn.innerHTML || submitBtn.innerHTML.trim() === '' || submitBtn.innerHTML.indexOf('fa') < 0) {
                submitBtn.innerHTML = '<i class="fa fa-floppy-o"></i> ' + (submitBtn.innerText || 'Guardar');
            }
        }
        submitBtn.style.display = 'inline-flex';
        actionsBar.appendChild(submitBtn);

        // Hook Submit Click with Full-Form Validation
        submitBtn.addEventListener('click', function(e) {
            var allErrors = [];
            panes.forEach(function(p, pIdx) {
                var pErrors = validatePane(p, true);
                pErrors.forEach(function(err) {
                    err.paneIndex = pIdx;
                    err.stepTitle = stepsData[pIdx].title;
                    allErrors.push(err);
                });
            });

            if (allErrors.length > 0) {
                e.preventDefault();
                e.stopPropagation();

                // Show Master Error Banner
                renderMasterErrorBanner(masterBannerContainer, allErrors, container, panes, header, actionsBar, submitBtn);

                // Update Step Indicators with error flags
                updateIndicatorErrors(header, allErrors);

                // Jump to the step with the FIRST error
                var firstErr = allErrors[0];
                if (!container.classList.contains('continuous-mode')) {
                    goToStep(container, panes, header, actionsBar, submitBtn, firstErr.paneIndex);
                }

                // Smooth scroll to the invalid field and focus it
                setTimeout(function() {
                    firstErr.input.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    try { firstErr.input.focus(); } catch (ex) {}
                }, 200);

                if (window.toastr) {
                    toastr.error('Por favor complete los ' + allErrors.length + ' campos obligatorios marcados en rojo.', 'Faltan Datos');
                }
                return false;
            }

            // Zero errors: clear banners and prepare submission
            masterBannerContainer.innerHTML = '';
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
            submitBtn.style.opacity = '0.85';
        });

        // Prev & Next Buttons
        var btnPrev = actionsBar.querySelector('.btn-wizard-prev');
        var btnNext = actionsBar.querySelector('.btn-wizard-next');

        btnNext.addEventListener('click', function() {
            var cur = parseInt(container.dataset.currentStep || '0', 10);
            var paneErrors = validatePane(panes[cur], true);
            if (paneErrors.length === 0) {
                goToStep(container, panes, header, actionsBar, submitBtn, cur + 1);
            } else {
                // Focus first error in pane
                paneErrors[0].input.scrollIntoView({ behavior: 'smooth', block: 'center' });
                try { paneErrors[0].input.focus(); } catch (ex) {}
                if (window.toastr) {
                    toastr.warning('Hay datos pendientes en este paso antes de continuar.', 'Paso Incompleto');
                }
            }
        });

        btnPrev.addEventListener('click', function() {
            var cur = parseInt(container.dataset.currentStep || '0', 10);
            goToStep(container, panes, header, actionsBar, submitBtn, cur - 1);
        });

        // Mode Toggle handler
        toggleModeBtn.addEventListener('click', function() {
            var isContinuous = container.classList.toggle('continuous-mode');
            if (isContinuous) {
                toggleModeBtn.innerHTML = '<i class="fa fa-step-forward"></i> Ver por Pasos';
                btnNext.style.display = 'none';
                btnPrev.style.display = 'none';
                actionsBar.querySelector('.wizard-progress-counter').style.display = 'none';
            } else {
                toggleModeBtn.innerHTML = '<i class="fa fa-th-list"></i> Ver Todo Continuo';
                var cur = parseInt(container.dataset.currentStep || '0', 10);
                updateStepViews(container, panes, header, actionsBar, submitBtn, cur);
            }
        });

        // Real-time error clearing on inputs
        form.querySelectorAll('input, select, textarea').forEach(function(inp) {
            function clearOnInteraction() {
                var res = validateSingleInput(inp);
                if (res.valid) {
                    clearFieldError(inp);
                    // Check if all master banner errors are resolved
                    var remaining = form.querySelectorAll('.field-error-highlight');
                    if (remaining.length === 0) {
                        masterBannerContainer.innerHTML = '';
                        header.querySelectorAll('.wizard-step-indicator').forEach(function(ind) {
                            ind.classList.remove('has-step-error');
                        });
                    }
                }
            }
            inp.addEventListener('input', clearOnInteraction);
            inp.addEventListener('change', clearOnInteraction);
        });

        container.dataset.currentStep = '0';
        updateStepViews(container, panes, header, actionsBar, submitBtn, 0);

        return container;
    }

    function renderMasterErrorBanner(bannerWrap, allErrors, container, panes, header, actionsBar, submitBtn) {
        bannerWrap.innerHTML = '';
        var banner = document.createElement('div');
        banner.className = 'wizard-error-banner';
        
        var listItems = allErrors.map(function(err, i) {
            return '<li style="margin-bottom:6px;">' +
                '<a class="error-jump-link" data-err-idx="' + i + '" style="font-weight:700;">' +
                '[' + err.stepTitle + '] ' + err.label + ':</a> ' +
                '<span style="color:#7F1D1D;">' + err.message + '</span>' +
                '</li>';
        }).join('');

        banner.innerHTML = '<div style="display:flex; justify-content:space-between; align-items:flex-start; margin-bottom:10px;">' +
            '<div style="display:flex; align-items:center; gap:10px;">' +
            '<i class="fa fa-exclamation-triangle" style="font-size:22px; color:#DC2626;"></i>' +
            '<div>' +
            '<strong style="font-size:15px; color:#991B1B; display:block;">Atención: No se puede guardar aún</strong>' +
            '<span style="font-size:12px; color:#7F1D1D;">Faltan ' + allErrors.length + ' campos obligatorios por completar:</span>' +
            '</div>' +
            '</div>' +
            '<button type="button" class="close" style="color:#991B1B; opacity:0.8; font-size:22px; cursor:pointer;" onclick="this.closest(\'.wizard-error-banner\').remove();">&times;</button>' +
            '</div>' +
            '<ul style="margin:0; padding-left:22px; font-size:13px; line-height:1.5;">' + listItems + '</ul>';

        // Add jump-to click handler on each error link
        banner.querySelectorAll('.error-jump-link').forEach(function(link) {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                var idx = parseInt(link.dataset.errIdx, 10);
                var err = allErrors[idx];
                if (err) {
                    if (!container.classList.contains('continuous-mode')) {
                        goToStep(container, panes, header, actionsBar, submitBtn, err.paneIndex);
                    }
                    setTimeout(function() {
                        err.input.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        try { err.input.focus(); } catch (ex) {}
                    }, 150);
                }
            });
        });

        bannerWrap.appendChild(banner);
        banner.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }

    function updateIndicatorErrors(header, allErrors) {
        var errStepIndices = {};
        allErrors.forEach(function(e) {
            errStepIndices[e.paneIndex] = true;
        });

        header.querySelectorAll('.wizard-step-indicator').forEach(function(ind, idx) {
            if (errStepIndices[idx]) {
                ind.classList.add('has-step-error');
            } else {
                ind.classList.remove('has-step-error');
            }
        });
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

        if (boxFooter) {
            // Keep Volver button if present, but hide boxFooter duplicate
            boxFooter.style.display = 'none';
        }

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

        var boxBodyCredito = boxCredito.querySelector('.box-body');
        if (!boxBodyCredito) return;

        var mainRow = boxBodyCredito.querySelector('.row');
        var tabpanel = boxBodyCredito.querySelector('div[role="tabpanel"]');
        var hr = boxBodyCredito.querySelector('hr');
        var h4Garantias = boxBodyCredito.querySelector('h4');

        if (!mainRow) return;

        // Step 1: Asociado + Parámetros del Crédito
        var step1Container = document.createElement('div');
        step1Container.appendChild(boxAsociado);

        var step1CreditoBox = document.createElement('div');
        step1CreditoBox.className = 'box box-primary';
        step1CreditoBox.innerHTML = '<div class="box-header with-border"><strong><i class="fa fa-money"></i> Parámetros y Condiciones del Crédito</strong></div>';
        var step1Body = document.createElement('div');
        step1Body.className = 'box-body';
        var step1Row = document.createElement('div');
        step1Row.className = 'row';

        // Step 2: Estudio Socioeconómico
        var step2Container = document.createElement('div');
        step2Container.className = 'box box-primary';
        step2Container.innerHTML = '<div class="box-header with-border"><strong><i class="fa fa-line-chart"></i> Estudio Socioeconómico y Capacidad de Pago</strong></div>';
        var step2Body = document.createElement('div');
        step2Body.className = 'box-body';
        var step2Row = document.createElement('div');
        step2Row.className = 'row';

        // Live Underwriting Card
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

        // Step 3: Garantías y Fiadores
        var step3Container = document.createElement('div');
        step3Container.className = 'box box-primary';
        step3Container.innerHTML = '<div class="box-header with-border"><strong><i class="fa fa-shield"></i> Garantías, Fiadores y Referencias</strong></div>';
        var step3Body = document.createElement('div');
        step3Body.className = 'box-body';

        if (h4Garantias) h4Garantias.style.display = 'none';
        if (hr) hr.style.display = 'none';
        if (tabpanel) step3Body.appendChild(tabpanel);

        step3Container.appendChild(step3Body);

        boxCredito.style.display = 'none';

        var stepsData = [
            { title: 'Condiciones del Crédito', elements: [step1Container] },
            { title: 'Estudio Socioeconómico', elements: [step2Container] },
            { title: 'Garantías y Fiadores', elements: [step3Container] }
        ];

        var container = buildWizardUI(form, stepsData, submitBtn);
        form.appendChild(container);

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

    // Real-Time Underwriting Calculator
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

            var cuotaCapital = cuotas > 0 ? (monto / cuotas) : 0;
            var cuotaInteres = monto * (interesAnual / 100 / 12);
            var cuotaEstimada = cuotaCapital + cuotaInteres;

            var ratio = totalIngresos > 0 ? (cuotaEstimada / totalIngresos) * 100 : 0;

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
                // Ensure active step indicator is scrolled into view in horizontal stepper
                ind.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
            } else if (i < current) {
                ind.classList.add('completed');
            }
        });

        var btnPrev = actionsBar.querySelector('.btn-wizard-prev');
        var btnNext = actionsBar.querySelector('.btn-wizard-next');
        var counter = actionsBar.querySelector('.wizard-progress-counter');

        btnPrev.style.display = (current === 0) ? 'none' : 'inline-flex';
        counter.textContent = 'Paso ' + (current + 1) + ' de ' + total;

        // Next button: hidden on final step
        if (current === total - 1) {
            btnNext.style.display = 'none';
        } else {
            btnNext.style.display = 'inline-flex';
        }

        // Submit button: ALWAYS VISIBLE AND PROMINENT
        if (submitBtn) {
            submitBtn.style.display = 'inline-flex';
        }
    }

    // Validates a specific pane, marks errors if showErrors = true, returns list of errors
    function validatePane(pane, showErrors) {
        var inputs = pane.querySelectorAll('input:not([type="hidden"]), select, textarea');
        var errors = [];

        inputs.forEach(function(input) {
            var res = validateSingleInput(input);
            if (!res.valid) {
                errors.push({
                    input: input,
                    label: getFriendlyLabel(input),
                    message: res.message
                });
                if (showErrors) {
                    markFieldError(input, res.message);
                }
            } else {
                if (showErrors) {
                    clearFieldError(input);
                }
            }
        });

        return errors;
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initFormWizards);
    } else {
        initFormWizards();
    }
    window.addEventListener('load', initFormWizards);
})();
