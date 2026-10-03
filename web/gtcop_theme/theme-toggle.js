/**
 * Accion Cooperativa - CDPE Identity & Theme Controller
 * Manages Dark/Light mode and ensures complete branding compliance.
 */
(function() {
    'use strict';

    function initTheme() {
        var savedTheme = localStorage.getItem('gtcop_theme');
        var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
        var theme = savedTheme || (prefersDark ? 'dark' : 'light');

        applyTheme(theme);
        injectToggleButton();
        enforceBranding();
    }

    function applyTheme(theme) {
        if (theme === 'dark') {
            document.documentElement.classList.add('dark-theme');
            if (document.body) document.body.classList.add('dark-theme');
        } else {
            document.documentElement.classList.remove('dark-theme');
            if (document.body) document.body.classList.remove('dark-theme');
        }
        localStorage.setItem('gtcop_theme', theme);
        updateToggleIcon(theme);
    }

    function toggleTheme() {
        var current = localStorage.getItem('gtcop_theme') === 'dark' ? 'dark' : 'light';
        var next = current === 'dark' ? 'light' : 'dark';
        applyTheme(next);
    }

    function updateToggleIcon(theme) {
        var btn = document.getElementById('cdpe-theme-toggle-btn');
        if (!btn) return;
        var icon = btn.querySelector('i');
        if (icon) {
            if (theme === 'dark') {
                icon.className = 'fa fa-sun-o';
                btn.title = 'Cambiar a Modo Claro';
            } else {
                icon.className = 'fa fa-moon-o';
                btn.title = 'Cambiar a Modo Oscuro';
            }
        }
    }

    function injectToggleButton() {
        if (document.getElementById('cdpe-theme-toggle-li')) return;
        var navbarCustomMenu = document.querySelector('.navbar-custom-menu > .navbar-nav');
        if (!navbarCustomMenu) return;

        var li = document.createElement('li');
        li.id = 'cdpe-theme-toggle-li';
        var isDark = localStorage.getItem('gtcop_theme') === 'dark';

        var a = document.createElement('a');
        a.id = 'cdpe-theme-toggle-btn';
        a.href = '#';
        a.role = 'button';
        a.title = isDark ? 'Cambiar a Modo Claro' : 'Cambiar a Modo Oscuro';
        a.style.fontSize = '16px';
        a.style.padding = '15px 15px';
        a.style.cursor = 'pointer';
        a.innerHTML = '<i class="' + (isDark ? 'fa fa-sun-o' : 'fa fa-moon-o') + '"></i>';

        a.addEventListener('click', function(e) {
            e.preventDefault();
            toggleTheme();
        });

        li.appendChild(a);
        navbarCustomMenu.insertBefore(li, navbarCustomMenu.firstChild);
    }

    function enforceBranding() {
        // Enforce document title
        if (document.title && document.title.indexOf('Acción Cooperativa') === -1) {
            var cleanTitle = document.title.replace(/\s*-\s*IQ'?\s*A&C/gi, '').replace(/IQ'?\s*A&C/gi, '').trim();
            if (!cleanTitle) cleanTitle = 'Inicio';
            document.title = cleanTitle + ' - Acción Cooperativa';
        }

        // Clean any leftover Inversiones menu item
        var spans = document.querySelectorAll('.sidebar-menu span');
        spans.forEach(function(s) {
            if (s.textContent.trim().toLowerCase() === 'inversiones') {
                s.textContent = 'Ahorros';
            }
        });
        var headers = document.querySelectorAll('.sidebar-menu li.header');
        headers.forEach(function(h) {
            if (h.textContent.trim().toLowerCase() === 'inversiones') {
                h.textContent = 'Ahorros';
            }
        });

        // Ensure favicon
        var favicon = document.querySelector('link[rel="shortcut icon"]') || document.querySelector('link[rel="icon"]');
        if (!favicon) {
            favicon = document.createElement('link');
            favicon.rel = 'shortcut icon';
            document.head.appendChild(favicon);
        }
        favicon.href = '/gtcop_theme/favicon.ico?v=cdpe';
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initTheme);
    } else {
        initTheme();
    }

    window.addEventListener('load', function() {
        initTheme();
        setTimeout(initTheme, 500);
    });

    // Observer for dynamically loaded content
    if (window.MutationObserver) {
        var observer = new MutationObserver(function() {
            enforceBranding();
        });
        if (document.body) {
            observer.observe(document.body, { childList: true, subtree: true });
        }
    }

    // PWA Service Worker Registration & Mobile Install Banner
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', function() {
            navigator.serviceWorker.register('/service-worker.js', { scope: '/' })
                .then(function(reg) {
                    console.log('[PWA] Service Worker activo:', reg.scope);
                })
                .catch(function(err) {
                    console.warn('[PWA] Service Worker no registrado:', err);
                });
        });
    }

    window.addEventListener('beforeinstallprompt', function(e) {
        e.preventDefault();
        window.__pwaInstallPrompt = e;
        var pwaBtn = document.getElementById('cdpe-pwa-install-btn');
        if (!pwaBtn) {
            var navbarCustomMenu = document.querySelector('.navbar-custom-menu > .navbar-nav');
            if (navbarCustomMenu) {
                var li = document.createElement('li');
                li.id = 'cdpe-pwa-install-btn';
                li.innerHTML = '<a href="#" title="Instalar Aplicación Móvil (PWA)" style="color:#10B981; font-weight:700; cursor:pointer;"><i class="fa fa-download"></i> <span class="hidden-xs">Instalar App</span></a>';
                li.addEventListener('click', function(ev) {
                    ev.preventDefault();
                    if (window.__pwaInstallPrompt) {
                        window.__pwaInstallPrompt.prompt();
                        window.__pwaInstallPrompt.userChoice.then(function(choice) {
                            if (choice.outcome === 'accepted') {
                                li.remove();
                            }
                        });
                    }
                });
                navbarCustomMenu.insertBefore(li, navbarCustomMenu.firstChild);
            }
        }
    });
})();
