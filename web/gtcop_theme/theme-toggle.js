/**
 * Accion Cooperativa - CDPE Identity & Single Theme Controller
 * Manages Dark/Light mode universally and ensures complete branding compliance.
 */
(function() {
    'use strict';

    // 1. Immediate early execution to prevent Flash of Unstyled Content (FOUC)
    var savedTheme = null;
    try {
        savedTheme = localStorage.getItem('gtcop_theme') || localStorage.getItem('gtcop-theme');
    } catch(e) {}

    var prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    var activeTheme = savedTheme || (prefersDark ? 'dark' : 'light');

    if (activeTheme === 'dark') {
        document.documentElement.classList.add('dark-theme', 'dark-mode');
    } else {
        document.documentElement.classList.remove('dark-theme', 'dark-mode');
    }

    function initTheme() {
        // Clean up any legacy or duplicate buttons if they exist
        var oldFloating = document.getElementById('gtcop-theme-toggle-floating');
        if (oldFloating) oldFloating.remove();
        var oldNavLi = document.getElementById('gtcop-navbar-theme-li');
        if (oldNavLi) oldNavLi.remove();

        applyTheme(activeTheme);
        injectToggleButton();
        enforceBranding();
    }

    function applyTheme(theme) {
        activeTheme = theme;
        if (theme === 'dark') {
            document.documentElement.classList.add('dark-theme', 'dark-mode');
            if (document.body) document.body.classList.add('dark-theme', 'dark-mode');
        } else {
            document.documentElement.classList.remove('dark-theme', 'dark-mode');
            if (document.body) document.body.classList.remove('dark-theme', 'dark-mode');
        }

        try {
            localStorage.setItem('gtcop_theme', theme);
            localStorage.setItem('gtcop-theme', theme);
        } catch(e) {}

        updateToggleIcon(theme);
    }

    function toggleTheme() {
        var next = (activeTheme === 'dark') ? 'light' : 'dark';
        applyTheme(next);
    }

    function updateToggleIcon(theme) {
        var btn = document.getElementById('cdpe-theme-toggle-btn');
        if (!btn) return;
        var icon = btn.querySelector('i');
        if (icon) {
            if (theme === 'dark') {
                icon.className = 'fa fa-sun-o';
                icon.style.color = '#FBBF24';
                btn.title = 'Cambiar a Modo Claro';
            } else {
                icon.className = 'fa fa-moon-o';
                icon.style.color = '';
                btn.title = 'Cambiar a Modo Oscuro';
            }
        }
    }

    function injectToggleButton() {
        if (document.getElementById('cdpe-theme-toggle-li')) {
            updateToggleIcon(activeTheme);
            return;
        }

        var navbarCustomMenu = document.querySelector('.navbar-custom-menu > .navbar-nav');
        if (!navbarCustomMenu) return;

        var li = document.createElement('li');
        li.id = 'cdpe-theme-toggle-li';

        var a = document.createElement('a');
        a.id = 'cdpe-theme-toggle-btn';
        a.href = '#';
        a.role = 'button';
        a.title = (activeTheme === 'dark') ? 'Cambiar a Modo Claro' : 'Cambiar a Modo Oscuro';
        a.style.fontSize = '16px';
        a.style.padding = '15px 15px';
        a.style.cursor = 'pointer';
        a.style.display = 'inline-flex';
        a.style.alignItems = 'center';

        if (activeTheme === 'dark') {
            a.innerHTML = '<i class="fa fa-sun-o" style="color:#FBBF24;"></i>';
        } else {
            a.innerHTML = '<i class="fa fa-moon-o"></i>';
        }

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
        setTimeout(initTheme, 400);
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
