# sa.com.gt • Plataforma Empresarial CDPE & SimplyGest Cloud 17.5

Plataforma web institucional, motor de búsqueda empresarial y ecosistema en la nube para la Red de Pequeñas y Medianas Empresas (CDPE), comercios afiliados (Don Pollo), Acción Cooperativa R.L. e integración con SimplyGest 17.5.

## Estructura del Proyecto

* **`web/portal.html`**: Portal principal estilo Google (`sa.com.gt`), motor de búsqueda vertical con resultados en Quetzales y Asesor Inteligente CDPE (Manuales de Gestión Comercial).
* **`web/cdpe.html`**: Portal institucional del Centro de Desarrollo de Pequeñas y Medianas Empresas (`cdpe.sa.com.gt`).
* **`web/ecommerce.html`**: Tienda digital para franquicias (`donpollo.sa.com.gt`) con catálogo y pedidos por WhatsApp.
* **`web/correo.html`**: Cliente de correo webmail corporativo para asociados (`correo.sa.com.gt`).
* **`web/gestion.html`**: Panel de Resumen Ejecutivo y estadísticas para SimplyGest.
* **`server.ps1`**: Microservicio HTTP en PowerShell 32-bit (SysWOW64) con enrutador multi-dominio y conector ODBC DBISAM.
* **`report_engine.ps1`**: Motor de consultas ODBC a bases de datos SimplyGest (`EMPRESAS.DB`, `ARTICULOS.DB`, `HISTOVEN.DB`), reportes ejecutivos y búsqueda global.
* **`Caddyfile`**: Configuración de Caddy Server con soporte de certificados SSL automáticos Let's Encrypt para `sa.com.gt` y todos los subdominios.
* **`service_manager.ps1`**: Gestor de inicio y supervisión de servicios.
