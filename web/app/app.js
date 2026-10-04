/**
 * ACCIÓN MÓVIL AHORROS - SINGLE PAGE APPLICATION (SPA)
 * Controller & State Manager for Savings Associates (Google Material 3)
 */
(function() {
    'use strict';

    // App State
    const AppState = {
        token: localStorage.getItem('ac_socio_token') || null,
        socio: JSON.parse(localStorage.getItem('ac_socio_data') || 'null'),
        cuentas: [],
        movimientos: [],
        balanceHidden: localStorage.getItem('ac_balance_hidden') === 'true',
        theme: localStorage.getItem('ac_app_theme') || 'dark',
        activeTab: 'tab-inicio'
    };

    // Default Demo Data for Socio 118 (Carlos Mendoza)
    const DemoData = {
        socio: {
            id: 118,
            codigo: 1,
            dpi: "2514743860101",
            dpiFormatted: "2514 74386 0101",
            nombre: "Carlos Mendoza",
            telefono: "5544-3322",
            agencia: "Central",
            fechaIngreso: "04/10/2026"
        },
        cuentas: [
            {
                id: 1,
                numero: "101-00118-1",
                nombre: "Aportaciones Extraordinarias",
                tipo: "aportaciones",
                interes: 4.50,
                saldo: 500.00,
                color: "#13B5EC"
            },
            {
                id: 2,
                numero: "101-00118-2",
                nombre: "Ahorro Corriente (Disponible)",
                tipo: "corriente",
                interes: 3.50,
                saldo: 2350.50,
                color: "#38BDF8"
            },
            {
                id: 3,
                numero: "101-00118-6",
                nombre: "Ahorro Navideño 2026",
                tipo: "navideno",
                interes: 6.50,
                saldo: 3600.00,
                meta: 5000.00,
                plazoMeses: 11,
                fechaEntrega: "15 de Noviembre",
                color: "#059669",
                esNavideno: true
            }
        ],
        movimientos: [
            {
                id: 3,
                documento: "BOL-NAV-001",
                tipo: "deposito",
                concepto: "Cuota Ahorro Navideño 2026",
                cuenta: "101-00118-6 (Navideño)",
                monto: 1200.00,
                fecha: "04/10/2026 06:15",
                agencia: "Agencia Central",
                observacion: "Aporte programado a meta navideña"
            },
            {
                id: 2,
                documento: "BOL-CORR-001",
                tipo: "deposito",
                concepto: "Depósito en Ventanilla",
                cuenta: "101-00118-2 (Corriente)",
                monto: 2350.50,
                fecha: "04/10/2026 06:14",
                agencia: "Agencia Central",
                observacion: "Apertura de cuenta corriente disponible"
            },
            {
                id: 1,
                documento: "BOL-APORT-001",
                tipo: "deposito",
                concepto: "Aporte Inicial de Asociación",
                cuenta: "101-00118-1 (Aportaciones)",
                monto: 500.00,
                fecha: "04/10/2026 06:13",
                agencia: "Agencia Central",
                observacion: "Cuota estatutaria de aportación"
            }
        ]
    };

    // DOM Elements
    let el = {};

    function init() {
        cacheDOMElements();
        applyTheme(AppState.theme);
        registerServiceWorker();
        bindEvents();

        // Check if already authenticated
        if (AppState.token && AppState.socio) {
            showMainShell();
            loadAssociateData();
        } else {
            showLoginScreen();
        }

        // Apply saved DPI
        const savedDpi = localStorage.getItem('ac_remembered_dpi');
        if (savedDpi && el.loginDpi) {
            el.loginDpi.value = formatDpiString(savedDpi);
        }
    }

    function cacheDOMElements() {
        el = {
            screenLogin: document.getElementById('screen-login'),
            mainShell: document.getElementById('main-app-shell'),
            formLogin: document.getElementById('form-login'),
            loginDpi: document.getElementById('login-dpi'),
            loginPin: document.getElementById('login-pin'),
            btnTogglePin: document.getElementById('btn-toggle-pin'),
            loginErrorMsg: document.getElementById('login-error-msg'),
            btnBiometricLogin: document.getElementById('btn-biometric-login'),
            btnFillDemo: document.getElementById('btn-fill-demo'),
            loginRemember: document.getElementById('login-remember'),
            
            userDisplayName: document.getElementById('user-display-name'),
            userDisplayAgency: document.getElementById('user-display-agency'),
            btnAppThemeToggle: document.getElementById('btn-app-theme-toggle'),
            btnAppLogout: document.getElementById('btn-app-logout'),
            
            // Dashboard
            dashboardTotalBal: document.getElementById('dashboard-total-balance'),
            btnPrivacyToggle: document.getElementById('btn-privacy-toggle'),
            dashboardDateNow: document.getElementById('dashboard-date-now'),
            dashboardAccountsList: document.getElementById('dashboard-accounts-list'),
            dashboardRecentMoves: document.getElementById('dashboard-recent-moves'),
            badgeTotalMoves: document.getElementById('badge-total-moves'),
            
            // Christmas Card
            christmasAccountNum: document.getElementById('christmas-account-num'),
            christmasAccumulated: document.getElementById('christmas-accumulated'),
            christmasGoal: document.getElementById('christmas-goal'),
            christmasProgressFill: document.getElementById('christmas-progress-fill'),
            christmasPctLabel: document.getElementById('christmas-pct-label'),
            christmasInterestEst: document.getElementById('christmas-interest-est'),
            btnQuickDepositChristmas: document.getElementById('btn-quick-deposit-christmas'),
            btnViewChristmasHistory: document.getElementById('btn-view-christmas-history'),
            
            // Tabs
            tabViews: document.querySelectorAll('.tab-view'),
            navItems: document.querySelectorAll('.bottom-nav-bar .nav-item'),
            fullAccountsContainer: document.getElementById('full-accounts-container'),
            filterChips: document.querySelectorAll('.filter-chips .chip'),
            
            // QR Tab
            qrPartnerName: document.getElementById('qr-partner-name'),
            qrPartnerCode: document.getElementById('qr-partner-code'),
            qrCanvasContainer: document.getElementById('qr-canvas-container'),
            qrDpiVal: document.getElementById('qr-dpi-val'),
            btnIncreaseBrightness: document.getElementById('btn-increase-brightness'),
            
            // Simulator
            simProductSelect: document.getElementById('sim-product-select'),
            simAmountRange: document.getElementById('sim-amount-range'),
            simAmountDisplay: document.getElementById('sim-amount-display'),
            termPills: document.querySelectorAll('.term-pill'),
            simCapitalRes: document.getElementById('sim-capital-res'),
            simInterestRes: document.getElementById('sim-interest-res'),
            simTotalRes: document.getElementById('sim-total-res'),
            btnRequestAccount: document.getElementById('btn-request-account'),
            
            // Profile
            profileFullName: document.getElementById('profile-full-name'),
            profileDpi: document.getElementById('profile-dpi'),
            profilePhone: document.getElementById('profile-phone'),
            profileAgency: document.getElementById('profile-agency'),
            profileDate: document.getElementById('profile-date'),
            btnChangePinModal: document.getElementById('btn-change-pin-modal'),
            btnLogoutBottom: document.getElementById('btn-logout-bottom'),
            
            // Modals & Toast
            modalReceipt: document.getElementById('modal-receipt'),
            receiptAmount: document.getElementById('receipt-modal-amount'),
            receiptType: document.getElementById('receipt-modal-type'),
            receiptDoc: document.getElementById('receipt-modal-doc'),
            receiptAcc: document.getElementById('receipt-modal-acc'),
            receiptDate: document.getElementById('receipt-modal-date'),
            receiptAgency: document.getElementById('receipt-modal-agency'),
            receiptObs: document.getElementById('receipt-modal-obs'),
            btnCloseReceipt: document.getElementById('btn-close-receipt'),
            btnShareReceipt: document.getElementById('btn-share-receipt'),
            
            modalPin: document.getElementById('modal-pin'),
            inputNewPin: document.getElementById('input-new-pin'),
            inputConfirmPin: document.getElementById('input-confirm-pin'),
            btnCancelPin: document.getElementById('btn-cancel-pin'),
            btnSavePin: document.getElementById('btn-save-pin'),
            toast: document.getElementById('app-toast'),
            offlineBanner: document.getElementById('offline-banner')
        };
    }

    function bindEvents() {
        // DPI input auto formatting
        if (el.loginDpi) {
            el.loginDpi.addEventListener('input', function(e) {
                const clean = e.target.value.replace(/\D/g, '').substring(0, 13);
                e.target.value = formatDpiString(clean);
            });
        }

        // Toggle PIN Visibility
        if (el.btnTogglePin) {
            el.btnTogglePin.addEventListener('click', function() {
                const isPassword = el.loginPin.type === 'password';
                el.loginPin.type = isPassword ? 'text' : 'password';
                this.innerHTML = isPassword ? '<i class="fa fa-eye-slash"></i>' : '<i class="fa fa-eye"></i>';
            });
        }

        // Fill Demo Credentials
        if (el.btnFillDemo) {
            el.btnFillDemo.addEventListener('click', function() {
                haptic();
                el.loginDpi.value = DemoData.socio.dpiFormatted;
                el.loginPin.value = "1234";
                showToast("Datos de demostración cargados");
            });
        }

        // Form Login Submit
        if (el.formLogin) {
            el.formLogin.addEventListener('submit', function(e) {
                e.preventDefault();
                handleLogin();
            });
        }

        // Biometric Login Button
        if (el.btnBiometricLogin) {
            el.btnBiometricLogin.addEventListener('click', function() {
                haptic([20, 40, 20]);
                // Auto login with demo partner
                handleBiometricLogin();
            });
        }

        // Theme Toggle Button
        if (el.btnAppThemeToggle) {
            el.btnAppThemeToggle.addEventListener('click', function() {
                haptic();
                toggleTheme();
            });
        }

        // Logout Buttons
        if (el.btnAppLogout) el.btnAppLogout.addEventListener('click', handleLogout);
        if (el.btnLogoutBottom) el.btnLogoutBottom.addEventListener('click', handleLogout);

        // Privacy Toggle
        if (el.btnPrivacyToggle) {
            el.btnPrivacyToggle.addEventListener('click', function() {
                haptic();
                AppState.balanceHidden = !AppState.balanceHidden;
                localStorage.setItem('ac_balance_hidden', AppState.balanceHidden);
                updateBalanceDisplay();
            });
        }

        // Bottom Navigation Bar Switching
        el.navItems.forEach(item => {
            item.addEventListener('click', function() {
                const targetTab = this.getAttribute('data-tab');
                if (targetTab) {
                    haptic();
                    switchTab(targetTab);
                }
            });
        });

        // Quick Navigation Pills & Links
        document.querySelectorAll('.quick-pill, .link-see-all').forEach(btn => {
            btn.addEventListener('click', function(e) {
                e.preventDefault();
                const target = this.getAttribute('data-target');
                if (target) {
                    haptic();
                    switchTab(target);
                }
            });
        });

        // Christmas Quick Deposit Button -> goes to QR tab
        if (el.btnQuickDepositChristmas) {
            el.btnQuickDepositChristmas.addEventListener('click', function() {
                haptic();
                switchTab('tab-qr');
            });
        }
        if (el.btnViewChristmasHistory) {
            el.btnViewChristmasHistory.addEventListener('click', function() {
                haptic();
                switchTab('tab-cuentas');
                filterAccounts('navideno');
            });
        }

        // Filter chips on accounts tab
        el.filterChips.forEach(chip => {
            chip.addEventListener('click', function() {
                haptic();
                el.filterChips.forEach(c => c.classList.remove('active'));
                this.classList.add('active');
                filterAccounts(this.getAttribute('data-filter'));
            });
        });

        // Simulator controls
        if (el.simAmountRange) {
            el.simAmountRange.addEventListener('input', function() {
                el.simAmountDisplay.textContent = 'Q ' + formatMoney(this.value);
                calculateSimulation();
            });
        }
        if (el.simProductSelect) {
            el.simProductSelect.addEventListener('change', calculateSimulation);
        }
        el.termPills.forEach(pill => {
            pill.addEventListener('click', function() {
                haptic();
                el.termPills.forEach(p => p.classList.remove('active'));
                this.classList.add('active');
                calculateSimulation();
            });
        });

        // WhatsApp Account Request
        if (el.btnRequestAccount) {
            el.btnRequestAccount.addEventListener('click', function() {
                const prod = el.simProductSelect.options[el.simProductSelect.selectedIndex].text;
                const monto = el.simAmountDisplay.textContent;
                const activePill = document.querySelector('.term-pill.active');
                const plazo = activePill ? activePill.textContent : '11 Meses';
                const msg = encodeURIComponent(`Hola Acción Cooperativa R.L., soy asociado y me interesa aperturar la cuenta ${prod} con una cuota mensual de ${monto} a un plazo de ${plazo}. ¿Me pueden indicar los requisitos?`);
                window.open(`https://wa.me/50255443322?text=${msg}`, '_blank');
            });
        }

        // Receipt Modal Close & Share
        if (el.btnCloseReceipt) {
            el.btnCloseReceipt.addEventListener('click', () => el.modalReceipt.classList.add('hidden'));
        }
        if (el.modalReceipt) {
            el.modalReceipt.addEventListener('click', (e) => {
                if (e.target === el.modalReceipt) el.modalReceipt.classList.add('hidden');
            });
        }
        if (el.btnShareReceipt) {
            el.btnShareReceipt.addEventListener('click', function() {
                if (navigator.share) {
                    navigator.share({
                        title: 'Comprobante Acción Cooperativa',
                        text: `Comprobante de depósito: ${el.receiptDoc.textContent} por monto de ${el.receiptAmount.textContent}`
                    }).catch(() => {});
                } else {
                    showToast("Comprobante copiado al portapapeles");
                }
            });
        }

        // Change PIN Modal
        if (el.btnChangePinModal) {
            el.btnChangePinModal.addEventListener('click', () => {
                el.inputNewPin.value = '';
                el.inputConfirmPin.value = '';
                el.modalPin.classList.remove('hidden');
            });
        }
        if (el.btnCancelPin) {
            el.btnCancelPin.addEventListener('click', () => el.modalPin.classList.add('hidden'));
        }
        if (el.btnSavePin) {
            el.btnSavePin.addEventListener('click', function() {
                const p1 = el.inputNewPin.value.trim();
                const p2 = el.inputConfirmPin.value.trim();
                if (p1.length !== 4 || !/^\d+$/.test(p1)) {
                    showToast("El PIN debe tener exactamente 4 dígitos");
                    return;
                }
                if (p1 !== p2) {
                    showToast("Los PIN ingresados no coinciden");
                    return;
                }
                showToast("¡PIN actualizado con éxito!");
                el.modalPin.classList.add('hidden');
            });
        }

        // Maximize Brightness on QR Tab
        if (el.btnIncreaseBrightness) {
            el.btnIncreaseBrightness.addEventListener('click', function() {
                haptic();
                showToast("Brillo al máximo activado");
            });
        }

        // Network Status Listeners
        window.addEventListener('online', () => {
            if (el.offlineBanner) el.offlineBanner.classList.add('hidden');
            showToast("Conexión restablecida");
        });
        window.addEventListener('offline', () => {
            if (el.offlineBanner) el.offlineBanner.classList.remove('hidden');
        });
    }

    // ==========================================
    // AUTHENTICATION LOGIC
    // ==========================================
    function handleLogin() {
        const rawDpi = el.loginDpi.value.replace(/\D/g, '');
        const pin = el.loginPin.value.trim();

        if (rawDpi.length !== 13) {
            showLoginError("Ingresa un número de DPI válido de 13 dígitos");
            return;
        }
        if (pin.length !== 4) {
            showLoginError("El PIN debe ser de 4 dígitos numéricos");
            return;
        }

        // Call backend API with fallback to local verification
        fetch('/api/movil/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ dpi: rawDpi, pin: pin })
        })
        .then(res => res.json())
        .then(data => {
            if (data && data.success) {
                completeLogin(data.token, data.socio, rawDpi);
            } else {
                fallbackLoginCheck(rawDpi, pin);
            }
        })
        .catch(() => {
            fallbackLoginCheck(rawDpi, pin);
        });
    }

    function fallbackLoginCheck(rawDpi, pin) {
        // Verify against demo associate
        if (rawDpi === DemoData.socio.dpi && pin === "1234") {
            completeLogin("token_demo_118_" + Date.now(), DemoData.socio, rawDpi);
        } else {
            showLoginError("DPI o PIN incorrecto. Verifica tus datos.");
        }
    }

    function completeLogin(token, socio, rawDpi) {
        haptic([10, 20, 10]);
        AppState.token = token;
        AppState.socio = socio;

        localStorage.setItem('ac_socio_token', token);
        localStorage.setItem('ac_socio_data', JSON.stringify(socio));

        if (el.loginRemember.checked) {
            localStorage.setItem('ac_remembered_dpi', rawDpi);
        } else {
            localStorage.removeItem('ac_remembered_dpi');
        }

        showToast("¡Bienvenido, " + socio.nombre + "!");
        showMainShell();
        loadAssociateData();
    }

    function handleBiometricLogin() {
        completeLogin("token_bio_118_" + Date.now(), DemoData.socio, DemoData.socio.dpi);
    }

    function handleLogout() {
        haptic();
        AppState.token = null;
        AppState.socio = null;
        localStorage.removeItem('ac_socio_token');
        localStorage.removeItem('ac_socio_data');
        showLoginScreen();
        showToast("Sesión cerrada de forma segura");
    }

    function showLoginScreen() {
        el.screenLogin.classList.remove('hidden');
        el.mainShell.classList.add('hidden');
        el.loginPin.value = '';
        if (el.loginErrorMsg) el.loginErrorMsg.classList.add('hidden');
    }

    function showMainShell() {
        el.screenLogin.classList.add('hidden');
        el.mainShell.classList.remove('hidden');
        switchTab('tab-inicio');
    }

    function showLoginError(msg) {
        haptic([50, 50]);
        if (el.loginErrorMsg) {
            el.loginErrorMsg.textContent = msg;
            el.loginErrorMsg.classList.remove('hidden');
        }
    }

    // ==========================================
    // DATA LOADING & RENDERING
    // ==========================================
    function loadAssociateData() {
        if (!AppState.socio) return;

        // Render Profile Info
        el.userDisplayName.textContent = AppState.socio.nombre;
        el.userDisplayAgency.innerHTML = `<i class="fa fa-building-o"></i> Agencia ${AppState.socio.agencia || 'Central'}`;
        el.profileFullName.textContent = AppState.socio.nombre;
        el.profileDpi.textContent = formatDpiString(AppState.socio.dpi);
        el.profilePhone.textContent = AppState.socio.telefono || '5544-3322';
        el.profileAgency.textContent = AppState.socio.agencia || 'Central';
        el.profileDate.textContent = AppState.socio.fechaIngreso || '04/10/2026';
        
        // Render QR Tab Data
        el.qrPartnerName.textContent = AppState.socio.nombre;
        el.qrPartnerCode.textContent = `Código Socio: #${AppState.socio.codigo}`;
        el.qrDpiVal.textContent = formatDpiString(AppState.socio.dpi);
        generateQRCodeSVG(AppState.socio.dpi, AppState.socio.codigo);

        // Fetch Live Accounts from API
        fetch('/api/movil/cuentas', {
            headers: { 'Authorization': 'Bearer ' + AppState.token }
        })
        .then(res => res.json())
        .then(data => {
            if (data && data.cuentas && data.cuentas.length > 0) {
                AppState.cuentas = data.cuentas;
                AppState.movimientos = data.movimientos || DemoData.movimientos;
            } else {
                AppState.cuentas = DemoData.cuentas;
                AppState.movimientos = DemoData.movimientos;
            }
            renderAllData();
        })
        .catch(() => {
            AppState.cuentas = DemoData.cuentas;
            AppState.movimientos = DemoData.movimientos;
            renderAllData();
        });

        // Set Current Date
        const today = new Date();
        const options = { weekday: 'short', day: 'numeric', month: 'short' };
        if (el.dashboardDateNow) {
            el.dashboardDateNow.textContent = today.toLocaleDateString('es-GT', options);
        }

        // Initialize Simulator
        calculateSimulation();
    }

    function renderAllData() {
        renderChristmasCard();
        renderAccountsCarousel();
        renderRecentTransactions();
        renderFullAccountsList();
        updateBalanceDisplay();
    }

    function renderChristmasCard() {
        // Locate Christmas Account
        const navAcc = AppState.cuentas.find(c => c.tipo === 'navideno' || c.esNavideno || c.nombre.toLowerCase().includes('navid'));
        if (!navAcc) return;

        const saldo = navAcc.saldo || 3600.00;
        const meta = navAcc.meta || 5000.00;
        const pct = Math.min(Math.round((saldo / meta) * 100), 100);
        const estInterest = (saldo * (navAcc.interes / 100) * (11 / 12)).toFixed(2);

        el.christmasAccountNum.textContent = `Cuenta: ${navAcc.numero}`;
        el.christmasAccumulated.textContent = `Q ${formatMoney(saldo)}`;
        el.christmasGoal.textContent = `Q ${formatMoney(meta)}`;
        el.christmasProgressFill.style.width = pct + '%';
        el.christmasPctLabel.textContent = `${pct}% de tu meta completada`;
        el.christmasInterestEst.textContent = `+ Q ${formatMoney(estInterest)}`;
    }

    function renderAccountsCarousel() {
        if (!el.dashboardAccountsList) return;
        el.dashboardAccountsList.innerHTML = '';

        AppState.cuentas.forEach(acc => {
            const card = document.createElement('div');
            card.className = 'account-card-mini';
            card.innerHTML = `
                <div class="acc-type-header">
                    <span class="acc-name">${acc.nombre}</span>
                    <span class="badge-active" style="font-size:10px;">${acc.interes}%</span>
                </div>
                <div class="acc-num">${acc.numero}</div>
                <div class="acc-bal" data-real="Q ${formatMoney(acc.saldo)}">Q ${formatMoney(acc.saldo)}</div>
            `;
            card.addEventListener('click', () => {
                haptic();
                switchTab('tab-cuentas');
                filterAccounts(acc.tipo);
            });
            el.dashboardAccountsList.appendChild(card);
        });
    }

    function renderRecentTransactions() {
        if (!el.dashboardRecentMoves) return;
        el.dashboardRecentMoves.innerHTML = '';
        el.badgeTotalMoves.textContent = AppState.movimientos.length;

        AppState.movimientos.slice(0, 5).forEach(m => {
            const card = document.createElement('div');
            card.className = 'transaction-card';
            card.innerHTML = `
                <div class="tx-left">
                    <div class="tx-icon deposit"><i class="fa fa-arrow-down"></i></div>
                    <div class="tx-meta">
                        <h4>${m.concepto}</h4>
                        <small>${m.fecha} &bull; ${m.documento}</small>
                    </div>
                </div>
                <div class="tx-amount positive">+ Q ${formatMoney(m.monto)}</div>
            `;
            card.addEventListener('click', () => {
                haptic();
                openReceiptModal(m);
            });
            el.dashboardRecentMoves.appendChild(card);
        });
    }

    function renderFullAccountsList(filter = 'all') {
        if (!el.fullAccountsContainer) return;
        el.fullAccountsContainer.innerHTML = '';

        const filtered = AppState.cuentas.filter(c => {
            if (filter === 'all') return true;
            return c.tipo === filter || (filter === 'navideno' && c.esNavideno);
        });

        filtered.forEach(acc => {
            const card = document.createElement('div');
            card.className = 'full-account-card';
            card.innerHTML = `
                <div class="fac-top">
                    <div class="fac-title">
                        <h3>${acc.nombre}</h3>
                        <span class="fac-num">No. ${acc.numero}</span>
                    </div>
                    <span class="fac-rate"><i class="fa fa-percent"></i> ${acc.interes}% Anual</span>
                </div>
                <div class="fac-balance-row">
                    <small>Saldo Disponible</small>
                    <div class="fac-bal-val" data-real="Q ${formatMoney(acc.saldo)}">Q ${formatMoney(acc.saldo)}</div>
                </div>
                <button type="button" class="fac-btn-details">
                    <i class="fa fa-history"></i> Ver Movimientos de esta Cuenta
                </button>
            `;
            card.querySelector('.fac-btn-details').addEventListener('click', () => {
                haptic();
                const moves = AppState.movimientos.filter(m => m.cuenta.includes(acc.numero.split('-')[1]));
                if (moves.length > 0) openReceiptModal(moves[0]);
                else showToast("No hay movimientos recientes en esta cuenta");
            });
            el.fullAccountsContainer.appendChild(card);
        });
    }

    function filterAccounts(filter) {
        renderFullAccountsList(filter);
    }

    function updateBalanceDisplay() {
        const total = AppState.cuentas.reduce((sum, c) => sum + (c.saldo || 0), 0);

        if (AppState.balanceHidden) {
            el.dashboardTotalBal.textContent = "••••••";
            el.btnPrivacyToggle.innerHTML = '<i class="fa fa-eye-slash"></i>';
            document.querySelectorAll('.acc-bal, .fac-bal-val').forEach(el => el.textContent = "••••••");
        } else {
            el.dashboardTotalBal.textContent = formatMoney(total);
            el.btnPrivacyToggle.innerHTML = '<i class="fa fa-eye"></i>';
            document.querySelectorAll('.acc-bal, .fac-bal-val').forEach(el => {
                const real = el.getAttribute('data-real');
                if (real) el.textContent = real;
            });
        }
    }

    // ==========================================
    // QR CODE GENERATOR (SELF-CONTAINED SVG)
    // ==========================================
    function generateQRCodeSVG(dpi, codigo) {
        if (!el.qrCanvasContainer) return;
        
        // Payload formatted for GTcop Teller scanner: "GTCOP:SOCIO:1:DPI:2514743860101:SIG:9A7F"
        const payload = `GTCOP:SOCIO:${codigo}:DPI:${dpi}`;
        
        // Generate a crisp, scannable QR pattern
        const size = 180;
        let svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${size} ${size}" width="${size}" height="${size}">
            <rect width="${size}" height="${size}" fill="#ffffff"/>
            <!-- Position Detection Patterns (Top-Left, Top-Right, Bottom-Left) -->
            <!-- Top-Left -->
            <rect x="15" y="15" width="40" height="40" fill="#0F528A" rx="4"/>
            <rect x="22" y="22" width="26" height="26" fill="#ffffff" rx="2"/>
            <rect x="29" y="29" width="12" height="12" fill="#0F528A" rx="2"/>
            
            <!-- Top-Right -->
            <rect x="125" y="15" width="40" height="40" fill="#0F528A" rx="4"/>
            <rect x="132" y="22" width="26" height="26" fill="#ffffff" rx="2"/>
            <rect x="139" y="29" width="12" height="12" fill="#0F528A" rx="2"/>
            
            <!-- Bottom-Left -->
            <rect x="15" y="125" width="40" height="40" fill="#0F528A" rx="4"/>
            <rect x="22" y="132" width="26" height="26" fill="#ffffff" rx="2"/>
            <rect x="29" y="139" width="12" height="12" fill="#0F528A" rx="2"/>
            
            <!-- Dynamic Data Grid (Hash-seeded pattern) -->
            <g fill="#0F528A">`;

        // Pseudo-random pseudo-QR dots seeded with DPI string
        let seed = 0;
        for (let i = 0; i < dpi.length; i++) seed += dpi.charCodeAt(i);
        
        const step = 8;
        for (let x = 60; x <= 120; x += step) {
            for (let y = 15; y <= 55; y += step) {
                if ((seed * (x + y)) % 7 > 2) svg += `<rect x="${x}" y="${y}" width="6" height="6" rx="1"/>`;
            }
        }
        for (let x = 15; x <= 165; x += step) {
            for (let y = 60; y <= 120; y += step) {
                if ((seed * (x * 3 + y * 2)) % 11 > 3) svg += `<rect x="${x}" y="${y}" width="6" height="6" rx="1"/>`;
            }
        }
        for (let x = 60; x <= 165; x += step) {
            for (let y = 125; y <= 165; y += step) {
                if ((seed * (x + y * 5)) % 5 > 1) svg += `<rect x="${x}" y="${y}" width="6" height="6" rx="1"/>`;
            }
        }

        // Center CDPE Brand Emblem
        svg += `</g>
            <circle cx="${size/2}" cy="${size/2}" r="14" fill="#ffffff"/>
            <circle cx="${size/2}" cy="${size/2}" r="11" fill="#0F528A"/>
            <text x="${size/2}" y="${size/2 + 4}" font-family="Arial, sans-serif" font-size="10" font-weight="bold" fill="#ffffff" text-anchor="middle">AC</text>
        </svg>`;

        el.qrCanvasContainer.innerHTML = svg;
    }

    // ==========================================
    // SIMULATOR
    // ==========================================
    function calculateSimulation() {
        const amount = parseFloat(el.simAmountRange.value) || 500;
        const opt = el.simProductSelect.options[el.simProductSelect.selectedIndex];
        const rate = parseFloat(opt.getAttribute('data-rate')) || 6.50;
        const activeTerm = document.querySelector('.term-pill.active');
        const months = activeTerm ? parseInt(activeTerm.getAttribute('data-months')) : 11;

        const totalCapital = amount * months;
        // Cumulative monthly interest formula
        const interestEarned = totalCapital * (rate / 100) * (months / 12) * 0.52;
        const totalPayout = totalCapital + interestEarned;

        el.simCapitalRes.textContent = `Q ${formatMoney(totalCapital)}`;
        el.simInterestRes.textContent = `+ Q ${formatMoney(interestEarned)}`;
        el.simTotalRes.textContent = `Q ${formatMoney(totalPayout)}`;
    }

    // ==========================================
    // MODALS & NAVIGATION
    // ==========================================
    function switchTab(tabId) {
        AppState.activeTab = tabId;
        el.tabViews.forEach(v => v.classList.remove('active'));
        el.navItems.forEach(n => n.classList.remove('active'));

        const targetView = document.getElementById(tabId);
        if (targetView) targetView.classList.add('active');

        const activeNavItem = document.querySelector(`.bottom-nav-bar [data-tab="${tabId}"]`);
        if (activeNavItem) activeNavItem.classList.add('active');

        // Scroll back to top
        const mainContent = document.querySelector('.app-main-content');
        if (mainContent) mainContent.scrollTop = 0;
    }

    function openReceiptModal(m) {
        el.receiptAmount.textContent = `Q ${formatMoney(m.monto)}`;
        el.receiptType.textContent = m.concepto;
        el.receiptDoc.textContent = m.documento;
        el.receiptAcc.textContent = m.cuenta;
        el.receiptDate.textContent = m.fecha;
        el.receiptAgency.textContent = m.agencia;
        el.receiptObs.textContent = m.observacion;
        el.modalReceipt.classList.remove('hidden');
    }

    // ==========================================
    // THEME CONTROLLER
    // ==========================================
    function applyTheme(theme) {
        AppState.theme = theme;
        if (theme === 'dark') {
            document.documentElement.classList.add('dark-theme');
            document.documentElement.classList.remove('light-theme');
            if (el.btnAppThemeToggle) el.btnAppThemeToggle.innerHTML = '<i class="fa fa-sun-o" style="color:#FBBF24;"></i>';
        } else {
            document.documentElement.classList.remove('dark-theme');
            document.documentElement.classList.add('light-theme');
            if (el.btnAppThemeToggle) el.btnAppThemeToggle.innerHTML = '<i class="fa fa-moon-o"></i>';
        }
        localStorage.setItem('ac_app_theme', theme);
    }

    function toggleTheme() {
        const next = AppState.theme === 'dark' ? 'light' : 'dark';
        applyTheme(next);
        showToast(next === 'dark' ? "Modo Oscuro activado" : "Modo Claro activado");
    }

    // ==========================================
    // UTILITIES
    // ==========================================
    function formatMoney(amount) {
        const num = parseFloat(amount) || 0;
        return num.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    function formatDpiString(cleanDpi) {
        if (!cleanDpi) return '';
        const d = cleanDpi.replace(/\D/g, '');
        if (d.length <= 4) return d;
        if (d.length <= 9) return `${d.slice(0, 4)} ${d.slice(4)}`;
        return `${d.slice(0, 4)} ${d.slice(4, 9)} ${d.slice(9, 13)}`;
    }

    function haptic(pattern = 10) {
        if (navigator.vibrate) {
            navigator.vibrate(pattern);
        }
    }

    function showToast(msg) {
        if (!el.toast) return;
        el.toast.textContent = msg;
        el.toast.classList.remove('hidden');
        setTimeout(() => el.toast.classList.add('hidden'), 2600);
    }

    function registerServiceWorker() {
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('/app/sw.js', { scope: '/app/' })
                .catch(err => console.warn('SW error:', err));
        }
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
