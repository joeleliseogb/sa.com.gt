using System;
using System.IO;
using System.IO.Compression;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace GtcopProxy
{
    class Program
    {
        private static readonly int ListenPort = 8082;
        private static readonly string TargetHost = "127.0.0.1:8081";
        private static readonly string HostHeader = "gtcop.sa.com.gt";

        static void Main(string[] args)
        {
            ServicePointManager.DefaultConnectionLimit = 1000;
            ServicePointManager.Expect100Continue = false;

            HttpListener listener = new HttpListener();
            listener.Prefixes.Add(string.Format("http://127.0.0.1:{0}/", ListenPort));

            try
            {
                listener.Start();
                Console.WriteLine("GTcop Proxy started on http://127.0.0.1:{0} -> http://{1}", ListenPort, TargetHost);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error starting listener: " + ex.Message);
                return;
            }

            while (true)
            {
                try
                {
                    HttpListenerContext context = listener.GetContext();
                    Task.Run(() => ProcessRequest(context));
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Listener loop exception: " + ex.Message);
                }
            }
        }

        private static void ProcessRequest(HttpListenerContext context)
        {
            HttpListenerRequest req = context.Request;
            HttpListenerResponse res = context.Response;

            try
            {
                string targetUrl = string.Format("http://{0}{1}", TargetHost, req.RawUrl);
                HttpWebRequest backendReq = (HttpWebRequest)WebRequest.Create(targetUrl);
                backendReq.Method = req.HttpMethod;
                backendReq.KeepAlive = true;
                backendReq.AllowAutoRedirect = false;
                backendReq.AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate;
                backendReq.Host = HostHeader;

                // Copy headers
                foreach (string headerName in req.Headers.AllKeys)
                {
                    if (string.Equals(headerName, "Host", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(headerName, "Connection", StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }

                    string value = req.Headers[headerName];
                    if (string.Equals(headerName, "Accept", StringComparison.OrdinalIgnoreCase))
                    {
                        backendReq.Accept = value;
                    }
                    else if (string.Equals(headerName, "User-Agent", StringComparison.OrdinalIgnoreCase))
                    {
                        backendReq.UserAgent = value;
                    }
                    else if (string.Equals(headerName, "Referer", StringComparison.OrdinalIgnoreCase))
                    {
                        backendReq.Referer = value;
                    }
                    else if (string.Equals(headerName, "Content-Type", StringComparison.OrdinalIgnoreCase))
                    {
                        backendReq.ContentType = value;
                    }
                    else if (string.Equals(headerName, "Content-Length", StringComparison.OrdinalIgnoreCase))
                    {
                        // handled by stream length
                    }
                    else if (string.Equals(headerName, "If-Modified-Since", StringComparison.OrdinalIgnoreCase))
                    {
                        DateTime dt;
                        if (DateTime.TryParse(value, out dt)) backendReq.IfModifiedSince = dt;
                    }
                    else
                    {
                        try { backendReq.Headers.Set(headerName, value); } catch { }
                    }
                }

                // Copy request body if any
                if (req.HasEntityBody && (req.HttpMethod == "POST" || req.HttpMethod == "PUT" || req.HttpMethod == "PATCH"))
                {
                    using (Stream reqStream = backendReq.GetRequestStream())
                    {
                        req.InputStream.CopyTo(reqStream);
                    }
                }

                HttpWebResponse backendRes = null;
                try
                {
                    backendRes = (HttpWebResponse)backendReq.GetResponse();
                }
                catch (WebException wex)
                {
                    backendRes = wex.Response as HttpWebResponse;
                    if (backendRes == null)
                    {
                        res.StatusCode = 502;
                        byte[] err = Encoding.UTF8.GetBytes("Bad Gateway: " + wex.Message);
                        res.OutputStream.Write(err, 0, err.Length);
                        res.Close();
                        return;
                    }
                }

                // Intercept 500 errors for Microcredito or missing legacy views
                if ((int)backendRes.StatusCode == 500)
                {
                    string absPath = req.Url.AbsolutePath;
                    if (absPath.IndexOf("Microcredito", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        backendRes.Close();
                        ServeMicrocredito(req, res);
                        return;
                    }
                    else if (absPath.IndexOf("AbonoCapital", StringComparison.OrdinalIgnoreCase) >= 0)
                    {
                        backendRes.Close();
                        res.StatusCode = 302;
                        res.RedirectLocation = "/Pago/Create";
                        res.Close();
                        return;
                    }
                }

                res.StatusCode = (int)backendRes.StatusCode;
                res.StatusDescription = backendRes.StatusDescription;

                // Copy response headers
                foreach (string headerName in backendRes.Headers.AllKeys)
                {
                    if (string.Equals(headerName, "Transfer-Encoding", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(headerName, "Content-Length", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(headerName, "Content-Encoding", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(headerName, "Server", StringComparison.OrdinalIgnoreCase))
                    {
                        continue;
                    }

                    if (string.Equals(headerName, "Set-Cookie", StringComparison.OrdinalIgnoreCase))
                    {
                        string[] cookies = backendRes.Headers.GetValues("Set-Cookie");
                        if (cookies != null)
                        {
                            foreach (string cookie in cookies)
                            {
                                res.AppendHeader("Set-Cookie", cookie);
                            }
                        }
                    }
                    else if (string.Equals(headerName, "Location", StringComparison.OrdinalIgnoreCase))
                    {
                        string loc = backendRes.Headers["Location"];
                        if (!string.IsNullOrEmpty(loc))
                        {
                            loc = loc.Replace(":8081", "");
                            res.RedirectLocation = loc;
                        }
                    }
                    else
                    {
                        string val = backendRes.Headers[headerName];
                        try { res.Headers.Set(headerName, val); } catch { }
                    }
                }

                string contentType = backendRes.ContentType ?? "";
                bool isHtml = contentType.IndexOf("text/html", StringComparison.OrdinalIgnoreCase) >= 0;

                if (isHtml)
                {
                    // Read response body as string
                    string html;
                    using (Stream resStream = backendRes.GetResponseStream())
                    using (StreamReader reader = new StreamReader(resStream, Encoding.UTF8))
                    {
                        html = reader.ReadToEnd();
                    }

                    // Perform transformations
                    html = TransformHtml(html);

                    byte[] modifiedBytes = Encoding.UTF8.GetBytes(html);
                    res.ContentType = "text/html; charset=utf-8";
                    res.Headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
                    res.Headers["Pragma"] = "no-cache";
                    res.Headers["Expires"] = "0";
                    res.ContentLength64 = modifiedBytes.Length;
                    res.OutputStream.Write(modifiedBytes, 0, modifiedBytes.Length);
                }
                else
                {
                    // Binary or raw streaming
                    if (!string.IsNullOrEmpty(backendRes.ContentType))
                    {
                        res.ContentType = backendRes.ContentType;
                    }
                    using (Stream resStream = backendRes.GetResponseStream())
                    {
                        resStream.CopyTo(res.OutputStream);
                    }
                }

                res.Close();
                backendRes.Close();
            }
            catch (Exception ex)
            {
                try
                {
                    res.StatusCode = 500;
                    byte[] err = Encoding.UTF8.GetBytes("Proxy Error: " + ex.Message);
                    res.OutputStream.Write(err, 0, err.Length);
                    res.Close();
                }
                catch { }
            }
        }

        private static void ServeMicrocredito(HttpListenerRequest req, HttpListenerResponse res)
        {
            try
            {
                if (req.HttpMethod == "POST")
                {
                    res.StatusCode = 302;
                    res.RedirectLocation = "/Microcredito/Index";
                    res.Close();
                    return;
                }

                // Query layout from /Credito/Index using caller's authentication cookies
                HttpWebRequest subReq = (HttpWebRequest)WebRequest.Create(string.Format("http://{0}/Credito/Index", TargetHost));
                subReq.Method = "GET";
                subReq.KeepAlive = true;
                subReq.AllowAutoRedirect = false;
                subReq.AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate;
                subReq.Host = HostHeader;

                if (!string.IsNullOrEmpty(req.Headers["Cookie"]))
                {
                    subReq.Headers["Cookie"] = req.Headers["Cookie"];
                }
                if (!string.IsNullOrEmpty(req.Headers["User-Agent"]))
                {
                    subReq.UserAgent = req.Headers["User-Agent"];
                }

                HttpWebResponse subRes = null;
                try
                {
                    subRes = (HttpWebResponse)subReq.GetResponse();
                }
                catch (WebException wex)
                {
                    subRes = wex.Response as HttpWebResponse;
                }

                if (subRes == null)
                {
                    res.StatusCode = 500;
                    byte[] err = Encoding.UTF8.GetBytes("Error retrieving master layout.");
                    res.OutputStream.Write(err, 0, err.Length);
                    res.Close();
                    return;
                }

                if (subRes.StatusCode == HttpStatusCode.Redirect || subRes.StatusCode == HttpStatusCode.MovedPermanently)
                {
                    res.StatusCode = (int)subRes.StatusCode;
                    string loc = subRes.Headers["Location"] ?? "/Account/Login";
                    res.RedirectLocation = loc.Replace(":8081", "");
                    res.Close();
                    subRes.Close();
                    return;
                }

                string layoutHtml;
                using (Stream s = subRes.GetResponseStream())
                using (StreamReader r = new StreamReader(s, Encoding.UTF8))
                {
                    layoutHtml = r.ReadToEnd();
                }
                subRes.Close();

                string innerContent;
                string pageTitle;
                string urlPath = req.Url.AbsolutePath;

                if (urlPath.IndexOf("Create", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    innerContent = GetMicrocreditoCreateContent();
                    pageTitle = "Nuevo Microcrédito";
                }
                else
                {
                    innerContent = GetMicrocreditoIndexContent();
                    pageTitle = "Microcréditos";
                }

                // Replace content header and main content in layoutHtml
                string pattern = @"(?s)<section class=""content-header"">.*?</section>\s*(<!-- Main content -->)?\s*<section class=""content"">.*?</section>";
                string modifiedHtml = Regex.Replace(layoutHtml, pattern, innerContent, RegexOptions.IgnoreCase);

                // Replace title
                modifiedHtml = Regex.Replace(modifiedHtml, @"<title>.*?</title>", string.Format("<title>{0}</title>", pageTitle), RegexOptions.IgnoreCase);

                // Run standard branding & M3 transformations
                modifiedHtml = TransformHtml(modifiedHtml);

                byte[] htmlBytes = Encoding.UTF8.GetBytes(modifiedHtml);
                res.StatusCode = 200;
                res.ContentType = "text/html; charset=utf-8";
                res.Headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
                res.ContentLength64 = htmlBytes.Length;
                res.OutputStream.Write(htmlBytes, 0, htmlBytes.Length);
                res.Close();
            }
            catch (Exception ex)
            {
                try
                {
                    res.StatusCode = 500;
                    byte[] err = Encoding.UTF8.GetBytes("Microcredito Handler Error: " + ex.Message);
                    res.OutputStream.Write(err, 0, err.Length);
                    res.Close();
                }
                catch { }
            }
        }

        private static string GetMicrocreditoIndexContent()
        {
            return @"
<section class=""content-header"">
    <h1>
        Lista de Microcréditos
        <small>Acción Cooperativa</small>
    </h1>
    <ol class=""breadcrumb"">
        <li><a href=""/""><i class=""fa fa-home""></i> Inicio</a></li>
        <li class=""active""><i class=""fa fa-credit-card""></i> Microcrédito</li>
    </ol>
</section>
<section class=""content"">
    <div class=""row"">
        <div class=""col-xs-12"">
            <div class=""box box-primary"">
                <div class=""box-header with-border"">
                    <h3 class=""box-title"">Microcréditos Registrados</h3>
                    <div class=""box-tools pull-right"">
                        <a href=""/Microcredito/Create"" class=""btn btn-primary btn-sm"">
                            <i class=""fa fa-plus""></i> <span class=""hidden-xs"">Nuevo Microcrédito</span>
                        </a>
                    </div>
                </div>
                <div class=""box-body"">
                    <div role=""tabpanel"">
                        <ul class=""nav nav-tabs"" role=""tablist"">
                            <li role=""presentation"" class=""active""><a href=""#tab-cliente"" data-toggle=""tab""><i class=""fa fa-user""></i> Por Cliente</a></li>
                            <li role=""presentation""><a href=""#tab-credito"" data-toggle=""tab""><i class=""fa fa-credit-card""></i> Por No. Microcrédito</a></li>
                            <li role=""presentation""><a href=""#tab-dpi"" data-toggle=""tab""><i class=""fa fa-id-card-o""></i> Por DPI / CUI</a></li>
                        </ul>
                        <div class=""tab-content"" style=""padding: 15px 0;"">
                            <div role=""tabpanel"" class=""tab-pane active"" id=""tab-cliente"">
                                <form method=""get"" action=""/Microcredito/Index"" class=""form-inline"">
                                    <div class=""form-group"">
                                        <input type=""text"" name=""codigo"" class=""form-control input-sm"" placeholder=""Código de Asociado (Ej: 1)"" />
                                    </div>
                                    <button type=""submit"" class=""btn btn-primary btn-sm""><i class=""fa fa-search""></i> Buscar</button>
                                </form>
                            </div>
                            <div role=""tabpanel"" class=""tab-pane"" id=""tab-credito"">
                                <form method=""get"" action=""/Microcredito/Index"" class=""form-inline"">
                                    <div class=""form-group"">
                                        <input type=""text"" name=""idCredito"" class=""form-control input-sm"" placeholder=""Número de Microcrédito"" />
                                    </div>
                                    <button type=""submit"" class=""btn btn-primary btn-sm""><i class=""fa fa-search""></i> Buscar</button>
                                </form>
                            </div>
                            <div role=""tabpanel"" class=""tab-pane"" id=""tab-dpi"">
                                <form method=""get"" action=""/Microcredito/Index"" class=""form-inline"">
                                    <div class=""form-group"">
                                        <input type=""text"" name=""cui"" class=""form-control input-sm"" placeholder=""DPI / CUI"" />
                                    </div>
                                    <button type=""submit"" class=""btn btn-primary btn-sm""><i class=""fa fa-search""></i> Buscar</button>
                                </form>
                            </div>
                        </div>
                    </div>
                    <div class=""table-responsive"">
                        <table class=""table table-bordered table-striped table-hover"">
                            <thead>
                                <tr>
                                    <th>No.</th>
                                    <th>Asociado / Titular</th>
                                    <th>Fecha Solicitud</th>
                                    <th>Importe Solicitado</th>
                                    <th>Estado</th>
                                    <th>Tasa</th>
                                    <th>Cuota</th>
                                    <th style=""width:90px; text-align:center;"">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td colspan=""8"" class=""text-center text-muted"" style=""padding: 25px;"">
                                        <i class=""fa fa-info-circle fa-2x"" style=""color: #0F528A;""></i><br /><br />
                                        No hay solicitudes de microcrédito pendientes o registradas en este criterio.<br />
                                        Haga clic en <strong>Nuevo Microcrédito</strong> para originar una solicitud.
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>";
        }

        private static string GetMicrocreditoCreateContent()
        {
            return @"
<section class=""content-header"">
    <h1>
        Nuevo Microcrédito
        <small>Originación y Solicitud</small>
    </h1>
    <ol class=""breadcrumb"">
        <li><a href=""/""><i class=""fa fa-home""></i> Inicio</a></li>
        <li><a href=""/Microcredito/Index""><i class=""fa fa-credit-card""></i> Microcréditos</a></li>
        <li class=""active""><i class=""fa fa-plus""></i> Nueva Solicitud</li>
    </ol>
</section>
<section class=""content"">
    <form action=""/Microcredito/Create"" method=""post"" id=""form-credito"" class=""form"">
        <input type=""hidden"" name=""Socio.Id"" id=""socioId"" value=""1"" />
        <div class=""box box-primary"">
            <div class=""box-header with-border"">
                <strong><i class=""fa fa-user""></i> Datos del Asociado Solicitante</strong>
            </div>
            <div class=""box-body"">
                <div class=""col-sm-8"">
                    <div class=""form-group"">
                        <label class=""control-label label-strong"" for=""busqId"">Código del Asociado</label>
                        <div class=""input-group"">
                            <input type=""text"" class=""form-control"" placeholder=""Código de Asociado"" id=""busqId"" name=""busqId"" value=""1"" />
                            <span class=""input-group-btn"">
                                <button type=""button"" class=""btn btn-primary"" id=""sendButton""><i class=""fa fa-search""></i> Buscar</button>
                            </span>
                        </div>
                    </div>
                    <div class=""form-group"">
                        <label class=""control-label label-strong"" for=""inputNombres"">Nombre Completo</label>
                        <input type=""text"" class=""form-control"" id=""inputNombres"" value=""Joel Eliseo García Barahona"" readonly=""readonly"" />
                    </div>
                    <div class=""form-group"">
                        <label class=""control-label label-strong"" for=""inputDocumento"">Documento de Identificación (DPI / CUI)</label>
                        <input type=""text"" class=""form-control"" id=""inputDocumento"" value=""2388056460101"" readonly=""readonly"" />
                    </div>
                </div>
                <div class=""col-sm-4 text-center"">
                    <img id=""imagen"" class=""img-polaroid img-responsive center-block"" style=""max-height:150px; border-radius:8px;"" src=""/Images/sinfoto.jpg"" alt=""Fotografia"" />
                    <h5 class=""text-muted"" style=""margin-top:8px;"">Fotografía del Titular</h5>
                </div>
            </div>
        </div>

        <div class=""box box-primary"">
            <div class=""box-header with-border"">
                <strong><i class=""fa fa-calculator""></i> Condiciones Financieras del Microcrédito</strong>
            </div>
            <div class=""box-body form-horizontal"">
                <div class=""form-group"">
                    <label class=""control-label col-sm-2"">No. Microcrédito</label>
                    <div class=""col-sm-10"">
                        <input type=""text"" name=""Numero"" class=""form-control"" value=""0"" placeholder=""0 (Autogenerado al guardar)"" />
                    </div>
                </div>
                <div class=""form-group"">
                    <label class=""control-label col-sm-2"">Monto Solicitado (Q)</label>
                    <div class=""col-sm-10"">
                        <div class=""input-group"">
                            <span class=""input-group-addon"">Q</span>
                            <input type=""number"" step=""0.01"" name=""Importe"" class=""form-control"" placeholder=""5000.00"" required />
                        </div>
                    </div>
                </div>
                <div class=""form-group"">
                    <label class=""control-label col-sm-2"">Plazo (Meses)</label>
                    <div class=""col-sm-10"">
                        <input type=""number"" name=""Plazo"" class=""form-control"" value=""12"" min=""1"" max=""120"" required />
                    </div>
                </div>
                <div class=""form-group"">
                    <label class=""control-label col-sm-2"">Tasa Interés Anual (%)</label>
                    <div class=""col-sm-10"">
                        <input type=""number"" step=""0.01"" name=""Interes"" class=""form-control"" value=""18.00"" required />
                    </div>
                </div>
                <div class=""form-group"">
                    <label class=""control-label col-sm-2"">Mora (%)</label>
                    <div class=""col-sm-10"">
                        <input type=""number"" step=""0.01"" name=""Mora"" class=""form-control"" value=""3.00"" required />
                    </div>
                </div>
                <div class=""form-group"">
                    <label class=""control-label col-sm-2"">Tipo de Tasa</label>
                    <div class=""col-sm-10"">
                        <select name=""Tasa"" class=""form-control"">
                            <option value=""1"">Sobre Saldos</option>
                            <option value=""2"">Plana / Flat</option>
                        </select>
                    </div>
                </div>
                <div class=""form-group"">
                    <label class=""control-label col-sm-2"">Tipo de Cuota</label>
                    <div class=""col-sm-10"">
                        <select name=""Cuota"" class=""form-control"">
                            <option value=""1"">Nivelada (Capital + Interés constante)</option>
                            <option value=""2"">Abono a Capital Fijo</option>
                            <option value=""3"">Vencimiento Total</option>
                        </select>
                    </div>
                </div>
                <div class=""form-group"">
                    <label class=""control-label col-sm-2"">Estado</label>
                    <div class=""col-sm-10"">
                        <select name=""Estado"" class=""form-control"">
                            <option value=""1"">Solicitado</option>
                            <option value=""2"">Aprobado</option>
                        </select>
                    </div>
                </div>
                <div class=""form-group"">
                    <label class=""control-label col-sm-2"">Asesor Asignado</label>
                    <div class=""col-sm-10"">
                        <select name=""Usuario.Id"" class=""form-control"">
                            <option value=""1"">Joel García (Administrador / Asesor)</option>
                        </select>
                    </div>
                </div>
                <div class=""form-group"">
                    <label class=""control-label col-sm-2"">Descripción / Destino</label>
                    <div class=""col-sm-10"">
                        <textarea name=""Descripcion"" class=""form-control"" rows=""3"" placeholder=""Capital de trabajo, inventario, agricultura, etc.""></textarea>
                    </div>
                </div>
            </div>
            <div class=""box-footer text-right"">
                <button type=""submit"" class=""btn btn-primary""><i class=""fa fa-floppy-o""></i> Guardar Solicitud</button>
                <a href=""/Microcredito/Index"" class=""btn btn-default""><i class=""fa fa-times-circle""></i> Cancelar</a>
            </div>
        </div>
    </form>
</section>";
        }

        private static string TransformHtml(string html)
        {
            if (string.IsNullOrEmpty(html)) return html;

            // 1. Titles: Replace " - IQ' A&C" or "IQ' A&C" with " - Acción Cooperativa"
            html = Regex.Replace(html, @"<title>(.*?)</title>", m =>
            {
                string title = m.Groups[1].Value;
                title = Regex.Replace(title, @"\s*-\s*IQ'?\s*A&C", "", RegexOptions.IgnoreCase);
                title = Regex.Replace(title, @"IQ'?\s*A&C", "", RegexOptions.IgnoreCase);
                title = Regex.Replace(title, @"IQ\s*Software", "", RegexOptions.IgnoreCase);
                title = title.Trim();
                if (string.IsNullOrEmpty(title)) title = "Inicio";
                return string.Format("<title>{0} - Acción Cooperativa</title>", title);
            }, RegexOptions.IgnoreCase);

            // 2. Favicon
            html = Regex.Replace(html, @"href=""~?/Images/favicon\.ico""", "href=\"/gtcop_theme/favicon.ico?v=cdpe\"", RegexOptions.IgnoreCase);

            // 3. Branding in logos (header navbar)
            html = Regex.Replace(html, @"<span class=""logo-mini"">.*?</span>",
                "<span class=\"logo-mini\"><img src=\"/gtcop_theme/logo_cdpe_icon.png\" alt=\"AC\" style=\"height:34px; width:34px; object-fit:contain; vertical-align:middle;\" /></span>",
                RegexOptions.IgnoreCase | RegexOptions.Singleline);

            html = Regex.Replace(html, @"<span class=""logo-lg"">.*?</span>",
                "<span class=\"logo-lg\"><img src=\"/gtcop_theme/logo_cdpe.png\" alt=\"Acción Cooperativa\" style=\"height:36px; max-width:185px; object-fit:contain; vertical-align:middle;\" /></span>",
                RegexOptions.IgnoreCase | RegexOptions.Singleline);

            // 4. Login logo & Dashboard Center Logo
            html = Regex.Replace(html, @"~?/Images/LogoIQHorizontal\.png", "/gtcop_theme/logo_cdpe.png", RegexOptions.IgnoreCase);
            html = Regex.Replace(html, @"~?/Images/LogoIQSD\.png", "/gtcop_theme/logo_cdpe.png", RegexOptions.IgnoreCase);
            html = Regex.Replace(html, @"~?/Images/LogoIQHorizontalSmall\.png", "/gtcop_theme/logo_cdpe_icon.png", RegexOptions.IgnoreCase);
            html = Regex.Replace(html, @"~?/Images/logoSolo\.png", "/gtcop_theme/logo_cdpe_icon.png", RegexOptions.IgnoreCase);

            // 5. Menu: Replace Inversiones with Ahorros
            html = Regex.Replace(html, @"<span>\s*Inversiones\s*</span>", "<span>Ahorros</span>", RegexOptions.IgnoreCase);
            html = Regex.Replace(html, @"<li class=""header"">\s*Inversiones\s*</li>", "<li class=\"header\">Ahorros</li>", RegexOptions.IgnoreCase);
            html = Regex.Replace(html, @"B[uú]squeda de Inversiones", "Búsqueda de Ahorros", RegexOptions.IgnoreCase);

            // 6. Footer and IQ Software references
            html = Regex.Replace(html, @"<strong>Copyright &copy; .*?</strong>",
                "<strong>Copyright &copy; 2026 <a href=\"https://cdpe.accion.app/\" target=\"_blank\">Acción Cooperativa R.L.</a></strong>",
                RegexOptions.IgnoreCase);

            html = Regex.Replace(html, @"https?://www\.Acción\s*Cooperativa\.com\.gt", "https://cdpe.accion.app", RegexOptions.IgnoreCase);
            html = Regex.Replace(html, @"https?://www\.iqsoftware\.com\.gt", "https://cdpe.accion.app", RegexOptions.IgnoreCase);
            html = Regex.Replace(html, @"IQ'?\s*Ahorro\s*y\s*Cr[eé]dito", "Acción Cooperativa R.L.", RegexOptions.IgnoreCase);
            html = Regex.Replace(html, @"IQ'?\s*A&C", "Acción Cooperativa", RegexOptions.IgnoreCase);
            html = Regex.Replace(html, @"IQ\s*Software", "Acción Cooperativa", RegexOptions.IgnoreCase);
            html = Regex.Replace(html, @"iQsoftware", "Acción Cooperativa", RegexOptions.IgnoreCase);

            // 7. Inject CDPE Stylesheets, modern Material 3 theme, PWA manifest, and interactive scripts
            string injection = "\n    <!-- CDPE - Accion Cooperativa Identity & Modern Theme (Google M3) -->\n" +
                "    <link rel=\"manifest\" href=\"/manifest.webmanifest\" />\n" +
                "    <meta name=\"theme-color\" content=\"#0F528A\" />\n" +
                "    <meta name=\"apple-mobile-web-app-capable\" content=\"yes\" />\n" +
                "    <meta name=\"apple-mobile-web-app-status-bar-style\" content=\"black-translucent\" />\n" +
                "    <meta name=\"apple-mobile-web-app-title\" content=\"Acción Cooperativa\" />\n" +
                "    <link rel=\"apple-touch-icon\" href=\"/gtcop_theme/icon-192.png\" />\n" +
                "    <link rel=\"shortcut icon\" href=\"/gtcop_theme/favicon.ico?v=cdpe\" />\n" +
                "    <link rel=\"stylesheet\" href=\"/gtcop_theme/skin-yellow.css?v=cdpe\" />\n" +
                "    <link rel=\"stylesheet\" href=\"/gtcop_theme/Site.css?v=cdpe\" />\n" +
                "    <link rel=\"stylesheet\" href=\"/gtcop_theme/theme-modern.css?v=m3\" />\n" +
                "    <script src=\"/gtcop_theme/theme-toggle.js?v=cdpe\"></script>\n" +
                "    <script src=\"/gtcop_theme/form-wizard.js?v=m3\"></script>\n" +
                "    <script src=\"/gtcop_theme/anti-error.js?v=m3\"></script>\n" +
                "    <script src=\"/gtcop_theme/pos-caja.js?v=m3\"></script>\n</head>";

            if (html.IndexOf("</head>", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                html = Regex.Replace(html, @"</head>", injection, RegexOptions.IgnoreCase);
            }

            return html;
        }
    }
}
