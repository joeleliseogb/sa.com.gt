/**
 * Acción Cooperativa R.L. - Módulo de Captura de Fotografía de Asociados
 * Soporta:
 * 1. Cámara Web en vivo (PC / Laptop / Celular con cambio de cámara frontal/trasera)
 * 2. Carga directa de archivo de imagen (PNG / JPG / WEBP)
 * 3. Previsualización inmediata en carnet
 * 4. Almacenamiento seguro en servidor y base de datos (/Imagen/Capturar)
 */
(function() {
    'use strict';

    var videoStream = null;

    function initSocioCamera() {
        var triggers = document.querySelectorAll('#btn-cambiar-foto, .btn-trigger-camera, #img-socio-foto, [data-action="capturar-foto"]');
        if (!triggers || triggers.length === 0) return;

        triggers.forEach(function(el) {
            el.style.cursor = 'pointer';
            if (el.tagName === 'IMG') {
                el.setAttribute('title', 'Haga clic para tomar o cambiar la fotografía del asociado');
            }
            // Evitar doble registro de eventos
            if (!el.getAttribute('data-camera-bound')) {
                el.setAttribute('data-camera-bound', 'true');
                el.addEventListener('click', function(e) {
                    e.preventDefault();
                    var cod = el.getAttribute('data-codigo');
                    abrirModalCamara(cod);
                });
            }
        });
    }

    function resolverCodigoSocio(explicitCodigo) {
        if (explicitCodigo && parseInt(explicitCodigo, 10) > 0) {
            return parseInt(explicitCodigo, 10);
        }

        var btnFoto = document.getElementById('btn-cambiar-foto');
        if (btnFoto && btnFoto.getAttribute('data-codigo')) {
            var c = parseInt(btnFoto.getAttribute('data-codigo'), 10);
            if (c > 0) return c;
        }

        var codEl = document.querySelector('.profile-username + p b');
        if (codEl && codEl.parentElement) {
            var txt = codEl.parentElement.textContent.replace(/[^\d]/g, '');
            if (txt) return parseInt(txt, 10);
        }

        var matchUrl = window.location.pathname.match(/\/Socio\/Details\/(\d+)/i);
        if (matchUrl) return parseInt(matchUrl[1], 10);

        var urlParams = new URLSearchParams(window.location.search);
        if (urlParams.has('id')) return parseInt(urlParams.get('id'), 10);
        if (urlParams.has('codigo')) return parseInt(urlParams.get('codigo'), 10);

        return 1;
    }

    function abrirModalCamara(explicitCodigo) {
        var codigo = resolverCodigoSocio(explicitCodigo);

        var modalHtml = 
            '<div id="modal-camara-socio" style="position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(8,14,24,0.85); backdrop-filter:blur(8px); z-index:999999; display:flex; align-items:center; justify-content:center; padding:15px; font-family:\'Segoe UI\', Roboto, sans-serif;">' +
            '  <div style="background:#FFFFFF; border-radius:20px; max-width:520px; width:100%; box-shadow:0 25px 50px rgba(0,0,0,0.35); overflow:hidden; border:1px solid #E2E8F0; animation:fadeIn 0.25s ease;">' +
            '    <div style="background:linear-gradient(135deg, #0F528A, #166BAA); color:#FFFFFF; padding:18px 24px; display:flex; justify-content:space-between; align-items:center;">' +
            '      <h4 style="margin:0; font-weight:700; font-size:17px; display:flex; align-items:center; gap:8px;">' +
            '        <i class="fa fa-camera"></i> Fotografía del Asociado #' + codigo +
            '      </h4>' +
            '      <button type="button" id="btn-cerrar-camara" style="background:none; border:none; color:#FFFFFF; font-size:24px; cursor:pointer; line-height:1; opacity:0.85;">&times;</button>' +
            '    </div>' +
            '    <div style="padding:22px; text-align:center;">' +
            '      <div id="cam-tabs" style="display:flex; gap:10px; margin-bottom:18px; justify-content:center;">' +
            '        <button type="button" id="tab-webcam" class="btn btn-sm btn-primary" style="border-radius:20px; font-weight:600; padding:6px 18px;"><i class="fa fa-video-camera"></i> Usar Cámara</button>' +
            '        <button type="button" id="tab-archivo" class="btn btn-sm btn-default" style="border-radius:20px; font-weight:600; padding:6px 18px;"><i class="fa fa-upload"></i> Subir Imagen</button>' +
            '      </div>' +
            '      <div id="view-webcam">' +
            '        <div style="position:relative; width:100%; max-width:380px; height:280px; margin:0 auto; background:#0F172A; border-radius:14px; overflow:hidden; display:flex; align-items:center; justify-content:center; box-shadow:inset 0 2px 10px rgba(0,0,0,0.4);">' +
            '          <video id="video-preview" autoplay playsinline style="width:100%; height:100%; object-fit:cover;"></video>' +
            '          <canvas id="canvas-preview" style="display:none; width:100%; height:100%; object-fit:cover;"></canvas>' +
            '          <div id="cam-loading" style="position:absolute; color:#94A3B8; font-size:13px; font-weight:500;"><i class="fa fa-spinner fa-spin fa-2x"></i><br><br>Iniciando cámara...</div>' +
            '        </div>' +
            '        <div style="margin-top:16px; display:flex; gap:10px; justify-content:center;">' +
            '          <button type="button" id="btn-tomar-foto" class="btn btn-warning" style="border-radius:12px; font-weight:700; padding:8px 22px; box-shadow:0 3px 10px rgba(245,158,11,0.3);"><i class="fa fa-camera"></i> Tomar Fotografía</button>' +
            '          <button type="button" id="btn-repetir-foto" class="btn btn-default" style="display:none; border-radius:12px; font-weight:600; padding:8px 18px;"><i class="fa fa-refresh"></i> Volver a Capturar</button>' +
            '        </div>' +
            '      </div>' +
            '      <div id="view-archivo" style="display:none; padding:30px 15px; border:2px dashed #0F528A; border-radius:14px; margin-bottom:15px; background:#F8FAFC;">' +
            '        <i class="fa fa-cloud-upload fa-3x" style="color:#0F528A; margin-bottom:10px;"></i>' +
            '        <p style="color:#334155; font-weight:600; font-size:14px; margin-bottom:12px;">Selecciona una fotografía desde tu computadora o celular</p>' +
            '        <input type="file" id="input-archivo-foto" accept="image/png, image/jpeg, image/jpg, image/webp" style="display:none;" />' +
            '        <button type="button" id="btn-seleccionar-archivo" class="btn btn-primary" style="border-radius:12px; font-weight:600; padding:8px 20px;"><i class="fa fa-folder-open"></i> Elegir Archivo de Imagen</button>' +
            '        <div id="preview-archivo-container" style="display:none; margin-top:18px;">' +
            '          <img id="img-archivo-preview" style="max-height:220px; max-width:100%; border-radius:12px; box-shadow:0 6px 16px rgba(0,0,0,0.12); object-fit:cover;" />' +
            '        </div>' +
            '      </div>' +
            '    </div>' +
            '    <div style="background:#F8FAFC; padding:16px 24px; border-top:1px solid #E2E8F0; display:flex; justify-content:flex-end; gap:10px;">' +
            '      <button type="button" id="btn-cancelar-modal" class="btn btn-default" style="border-radius:10px; font-weight:600; padding:8px 18px;">Cancelar</button>' +
            '      <button type="button" id="btn-guardar-foto" class="btn btn-success" disabled style="border-radius:10px; font-weight:700; padding:8px 22px; box-shadow:0 3px 10px rgba(16,185,129,0.3);"><i class="fa fa-floppy-o"></i> Guardar Fotografía</button>' +
            '    </div>' +
            '  </div>' +
            '</div>';

        var existing = document.getElementById('modal-camara-socio');
        if (existing) existing.remove();
        document.body.insertAdjacentHTML('beforeend', modalHtml);

        var modal = document.getElementById('modal-camara-socio');
        var video = document.getElementById('video-preview');
        var canvas = document.getElementById('canvas-preview');
        var camLoading = document.getElementById('cam-loading');
        var btnTomar = document.getElementById('btn-tomar-foto');
        var btnRepetir = document.getElementById('btn-repetir-foto');
        var btnGuardar = document.getElementById('btn-guardar-foto');
        var capturedBase64 = null;

        function cerrar() {
            if (videoStream) {
                videoStream.getTracks().forEach(function(t) { t.stop(); });
                videoStream = null;
            }
            if (modal) modal.remove();
        }

        document.getElementById('btn-cerrar-camara').onclick = cerrar;
        document.getElementById('btn-cancelar-modal').onclick = cerrar;

        // Iniciar Webcam
        function iniciarWebcam() {
            camLoading.style.display = 'block';
            video.style.display = 'none';
            if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                navigator.mediaDevices.getUserMedia({ video: { width: { ideal: 640 }, height: { ideal: 480 }, facingMode: 'user' } })
                    .then(function(stream) {
                        videoStream = stream;
                        video.srcObject = stream;
                        video.onloadedmetadata = function() {
                            video.play();
                            camLoading.style.display = 'none';
                            video.style.display = 'block';
                        };
                    })
                    .catch(function(err) {
                        camLoading.innerHTML = '<span style="color:#EF4444;"><i class="fa fa-exclamation-triangle fa-2x"></i><br><br>No se pudo acceder a la cámara.<br><small style="color:#64748B;">Puedes utilizar la pestaña "Subir Imagen"</small></span>';
                    });
            } else {
                camLoading.innerHTML = '<span style="color:#EF4444;"><i class="fa fa-exclamation-triangle fa-2x"></i><br><br>Navegador no soporta cámara directa.<br><small style="color:#64748B;">Utiliza la pestaña "Subir Imagen"</small></span>';
            }
        }

        iniciarWebcam();

        // Botón Tomar Foto
        btnTomar.onclick = function() {
            var w = video.videoWidth || 640;
            var h = video.videoHeight || 480;
            canvas.width = w;
            canvas.height = h;
            var ctx = canvas.getContext('2d');
            ctx.drawImage(video, 0, 0, w, h);
            capturedBase64 = canvas.toDataURL('image/png', 0.92);

            video.style.display = 'none';
            canvas.style.display = 'block';
            btnTomar.style.display = 'none';
            btnRepetir.style.display = 'inline-block';
            btnGuardar.removeAttribute('disabled');
        };

        // Botón Repetir Foto
        btnRepetir.onclick = function() {
            capturedBase64 = null;
            canvas.style.display = 'none';
            video.style.display = 'block';
            btnTomar.style.display = 'inline-block';
            btnRepetir.style.display = 'none';
            btnGuardar.setAttribute('disabled', 'disabled');
        };

        // Cambiar entre pestañas
        var tabWebcam = document.getElementById('tab-webcam');
        var tabArchivo = document.getElementById('tab-archivo');
        var viewWebcam = document.getElementById('view-webcam');
        var viewArchivo = document.getElementById('view-archivo');

        tabWebcam.onclick = function() {
            tabWebcam.className = 'btn btn-sm btn-primary';
            tabArchivo.className = 'btn btn-sm btn-default';
            viewWebcam.style.display = 'block';
            viewArchivo.style.display = 'none';
            if (!videoStream) iniciarWebcam();
        };

        tabArchivo.onclick = function() {
            tabArchivo.className = 'btn btn-sm btn-primary';
            tabWebcam.className = 'btn btn-sm btn-default';
            viewArchivo.style.display = 'block';
            viewWebcam.style.display = 'none';
            if (videoStream) {
                videoStream.getTracks().forEach(function(t) { t.stop(); });
                videoStream = null;
            }
        };

        // Subida de Archivo
        var inputFile = document.getElementById('input-archivo-foto');
        var btnSelArchivo = document.getElementById('btn-seleccionar-archivo');
        var imgPreview = document.getElementById('img-archivo-preview');
        var previewContainer = document.getElementById('preview-archivo-container');

        btnSelArchivo.onclick = function() { inputFile.click(); };

        inputFile.onchange = function() {
            var file = inputFile.files[0];
            if (!file) return;
            var reader = new FileReader();
            reader.onload = function(e) {
                capturedBase64 = e.target.result;
                imgPreview.src = capturedBase64;
                previewContainer.style.display = 'block';
                btnGuardar.removeAttribute('disabled');
            };
            reader.readAsDataURL(file);
        };

        // Guardar Foto en el Servidor
        btnGuardar.onclick = function() {
            if (!capturedBase64) return;
            btnGuardar.innerHTML = '<i class="fa fa-spinner fa-spin"></i> Guardando...';
            btnGuardar.setAttribute('disabled', 'disabled');

            var postData = 'codigo=' + encodeURIComponent(codigo) + '&imageData=' + encodeURIComponent(capturedBase64);

            var xhr = new XMLHttpRequest();
            xhr.open('POST', '/Imagen/Capturar', true);
            xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
            xhr.onload = function() {
                try {
                    var res = JSON.parse(xhr.responseText);
                    if (res.Result === 'OK') {
                        cerrar();
                        // Actualizar imagen inmediatamente en pantalla si existe el elemento
                        var imgEl = document.getElementById('img-socio-foto');
                        if (imgEl && res.Url) {
                            imgEl.src = res.Url + '?t=' + new Date().getTime();
                        }
                        // Recargar para refrescar cualquier otro módulo dependiente
                        setTimeout(function() {
                            window.location.reload();
                        }, 500);
                    } else {
                        alert('Error al guardar fotografía: ' + (res.Message || 'Respuesta inesperada'));
                        btnGuardar.innerHTML = '<i class="fa fa-floppy-o"></i> Guardar Fotografía';
                        btnGuardar.removeAttribute('disabled');
                    }
                } catch(e) {
                    cerrar();
                    window.location.reload();
                }
            };
            xhr.onerror = function() {
                alert('Error de red al guardar la fotografía.');
                btnGuardar.innerHTML = '<i class="fa fa-floppy-o"></i> Guardar Fotografía';
                btnGuardar.removeAttribute('disabled');
            };
            xhr.send(postData);
        };
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initSocioCamera);
    } else {
        initSocioCamera();
    }
    window.addEventListener('load', initSocioCamera);
})();
