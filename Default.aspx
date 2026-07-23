<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Nexa_ERP.Default" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Nexa Garments ERP | Sign in to your workspace</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Inter:wght@400;500;600&family=JetBrains+Mono:wght@500;600&display=swap" rel="stylesheet">
    <style>
        :root{
            --bg-deep:#0A0F1E;
            --bg-panel:#0F1830;
            --line:rgba(255,255,255,0.08);
            --teal:#17E3C4;
            --amber:#F5A524;
            --text:#E9EDF7;
            --muted:#8892A8;
            --card:rgba(255,255,255,0.97);
        }
        *{ margin:0; padding:0; box-sizing:border-box; }
        html,body{ height:100%; overflow:hidden; }
        body{
            font-family:'Inter', sans-serif;
            background:var(--bg-deep);
            color:var(--text);
        }
        h1,h2,h3,.brand-name,.stat-value{ font-family:'Space Grotesk', sans-serif; }
        .mono{ font-family:'JetBrains Mono', monospace; }

        /* ===== layout ===== */
        .wrap{
            display:flex;
            height:100vh;
        }

        /* ===== left: brand / live system panel ===== */
        .brand-panel{
            position:relative;
            flex:1.35;
            padding:clamp(28px, 5vh, 56px) 64px;
            display:flex;
            flex-direction:column;
            justify-content:space-between;
            background:
                radial-gradient(circle at 15% 20%, rgba(23,227,196,0.14), transparent 45%),
                radial-gradient(circle at 85% 80%, rgba(245,165,36,0.10), transparent 45%),
                var(--bg-panel);
            overflow:hidden;
            border-right:1px solid var(--line);
        }
        .grid-overlay{
            position:absolute; inset:0;
            background-image:
                linear-gradient(var(--line) 1px, transparent 1px),
                linear-gradient(90deg, var(--line) 1px, transparent 1px);
            background-size:42px 42px;
            mask-image:radial-gradient(ellipse at center, black 40%, transparent 80%);
            opacity:.5;
            pointer-events:none;
        }

        .brand-top{ position:relative; z-index:1; }
        .brand-mark{
            display:flex; align-items:center; gap:12px; margin-bottom:clamp(20px, 4vh, 46px);
        }
        .brand-mark .logo-box{
            width:40px; height:40px; border-radius:10px;
            background:linear-gradient(135deg, var(--teal), #0B8C7C);
            display:flex; align-items:center; justify-content:center;
            font-weight:700; color:#04241F; font-size:18px;
            box-shadow:0 6px 18px rgba(23,227,196,0.35);
        }
        .brand-name{ font-size:20px; font-weight:700; letter-spacing:.2px; }
        .brand-name span{ color:var(--teal); }

        .status-pill{
            display:inline-flex; align-items:center; gap:8px;
            font-size:12px; color:var(--muted);
            border:1px solid var(--line); padding:6px 12px; border-radius:999px;
            margin-bottom:clamp(14px, 3vh, 28px);
        }
        .status-pill .dot{
            width:7px; height:7px; border-radius:50%; background:var(--teal);
            box-shadow:0 0 0 0 rgba(23,227,196,.6);
            animation:pulse 2s infinite;
        }
        @keyframes pulse{
            0%{ box-shadow:0 0 0 0 rgba(23,227,196,.55); }
            70%{ box-shadow:0 0 0 8px rgba(23,227,196,0); }
            100%{ box-shadow:0 0 0 0 rgba(23,227,196,0); }
        }

        .headline{ font-size:clamp(24px, 2.6vw + 1vh, 36px); line-height:1.2; font-weight:700; max-width:480px; margin-bottom:10px; }
        .subhead{ font-size:14.5px; color:var(--muted); max-width:440px; line-height:1.55; margin-bottom:clamp(16px, 3vh, 34px); }

        /* module wheel — the signature element: modules orbiting a live ERP hub */
        .module-wheel-wrap{
            position:relative; z-index:1;
            display:flex; justify-content:center; align-items:center;
            width:100%; max-width:600px;
            margin-top:0;
        }
        .module-wheel{ width:min(420px, 42vh); height:auto; overflow:visible; }

        .wheel-ring{ fill:none; stroke:var(--line); stroke-width:1; stroke-dasharray:2 6; }
        .wheel-ring.inner{ stroke:rgba(23,227,196,0.35); stroke-dasharray:0; }

        .wheel-hub-glow{ fill:url(#hubGlow); }
        .wheel-hub{
            fill:var(--bg-panel);
            stroke:url(#hubStroke);
            stroke-width:1.4;
        }
        .wheel-hub-label{
            font-family:'Space Grotesk', sans-serif;
            font-size:21px; font-weight:700; fill:var(--text);
            text-anchor:middle;
        }
        .wheel-hub-sub{
            font-family:'JetBrains Mono', monospace;
            font-size:9.5px; letter-spacing:1.5px; fill:var(--teal);
            text-anchor:middle; text-transform:uppercase;
        }

        .wheel-spoke{
            stroke:var(--line); stroke-width:1; stroke-dasharray:3 4;
        }
        .node-circle{
            fill:rgba(255,255,255,0.035);
            stroke:var(--line); stroke-width:1;
            transition:fill .2s ease, stroke .2s ease;
        }
        .node-icon{ color:var(--teal); }
        .wheel-label{
            font-family:'Inter', sans-serif;
            font-size:11.5px; font-weight:600; fill:var(--muted);
        }
        .wheel-node{
            animation:nodeIn .55s cubic-bezier(.2,.8,.2,1) both;
            animation-delay:calc(var(--d) * 55ms);
        }
        @keyframes nodeIn{
            from{ opacity:0; transform:scale(.85); transform-origin:300px 300px; }
            to{ opacity:1; transform:scale(1); }
        }
        .wheel-node:hover .node-circle{ fill:rgba(23,227,196,0.10); stroke:var(--teal); }
        .wheel-node:hover .wheel-label{ fill:var(--text); }

        @media (prefers-reduced-motion: reduce){
            .wheel-node{ animation:none; }
        }

        .brand-bottom{ position:relative; z-index:1; }
        .footline{ font-size:12px; color:var(--muted); display:flex; gap:18px; flex-wrap:wrap; }
        .footline b{ color:var(--text); font-weight:600; }

        /* ===== right: login card ===== */
        .login-panel{
            flex:1;
            display:flex;
            align-items:center;
            justify-content:center;
            padding:40px 32px;
            position:relative;
        }
        .login-card{
            width:100%; max-width:380px;
            background:var(--card);
            border-radius:18px;
            padding:38px 34px 30px;
            color:#141B2E;
            box-shadow:0 24px 60px rgba(0,0,0,0.45);
        }
        .login-card h2{ font-size:22px; margin-bottom:6px; }
        .login-card .lead{ font-size:13.5px; color:#5B6478; margin-bottom:28px; }

        .field{ position:relative; margin-bottom:20px; }
        .field label{
            display:block; font-size:12.5px; font-weight:600; color:#3C4356;
            margin-bottom:6px;
        }
        .field .input-wrap{ position:relative; }
        .field input[type="text"],
        .field input[type="password"]{
            width:100%; padding:11px 14px; font-size:14.5px;
            border:1.5px solid #E1E4EC; border-radius:9px;
            background:#FBFBFD; color:#141B2E;
            font-family:'Inter', sans-serif;
            transition:border-color .15s ease, box-shadow .15s ease;
        }
        .field input:focus{
            outline:none; border-color:var(--teal);
            box-shadow:0 0 0 3px rgba(23,227,196,0.18);
        }
        .toggle-eye{
            position:absolute; right:12px; top:50%; transform:translateY(-50%);
            cursor:pointer; color:#8892A8; font-size:12px; user-select:none;
            font-weight:600;
        }
        .row-between{
            display:flex; align-items:center; justify-content:space-between;
            font-size:12.5px; margin-bottom:22px; color:#5B6478;
        }
        .remember{ display:flex; align-items:center; gap:7px; }
        .row-between a{ color:#0B8C7C; text-decoration:none; font-weight:600; }
        .row-between a:hover{ text-decoration:underline; }

        .btn-signin{
            width:100%; border:none; border-radius:9px;
            background:linear-gradient(135deg, #17E3C4, #0B8C7C);
            color:#04241F; font-weight:700; font-size:14.5px;
            padding:12px 0; cursor:pointer;
            transition:transform .12s ease, box-shadow .12s ease;
            box-shadow:0 10px 22px rgba(23,227,196,0.3);
        }
        .btn-signin:hover{ transform:translateY(-1px); box-shadow:0 14px 28px rgba(23,227,196,0.4); }

        .secure-note{
            margin-top:20px; display:flex; align-items:flex-start; gap:8px;
            font-size:11.5px; color:#8892A8; line-height:1.5;
        }

        #lblMessage{
            display:block; font-size:12.5px; color:#C43C3C; margin:2px 0 14px;
        }

        /* ===== responsive ===== */
        @media (max-width:900px){
            html,body{ height:auto; overflow:auto; }
            .wrap{ flex-direction:column; height:auto; min-height:100vh; }
            .brand-panel{ padding:36px 26px; border-right:none; border-bottom:1px solid var(--line); overflow:visible; }
            .headline{ font-size:26px; }
            .module-wheel-wrap{ max-width:100%; }
            .module-wheel{ width:min(300px, 46vh); }
            .login-panel{ padding:32px 20px 48px; }
        }

        /* respect reduced motion */
        @media (prefers-reduced-motion: reduce){
            .status-pill .dot{ animation:none; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="wrap">

            <!-- ===== Left: brand + live ERP snapshot ===== -->
            <div class="brand-panel">
                <div class="grid-overlay"></div>

                <div class="brand-top">
                    <div class="brand-mark">
                        <div class="logo-box">N</div>
                        <div class="brand-name">Nexa<span>Garments ERP</span></div>
                    </div>

                    <div class="status-pill"><span class="dot"></span> All floors &amp; sections online</div>

                    <h1 class="headline">One system, from yarn to shipment.</h1>
                    <p class="subhead">Yarn, knitting, dyeing, garments production, HR, accounts and commercial &mdash; synced floor to floor so every department works from the same numbers.</p>

                    <div class="module-wheel-wrap">
                        <svg class="module-wheel" viewBox="0 0 600 600" xmlns="http://www.w3.org/2000/svg">
                            <defs>
                                <radialGradient id="hubGlow" cx="50%" cy="50%" r="50%">
                                    <stop offset="0%" stop-color="rgba(23,227,196,0.22)"/>
                                    <stop offset="100%" stop-color="rgba(23,227,196,0)"/>
                                </radialGradient>
                                <linearGradient id="hubStroke" x1="0%" y1="0%" x2="100%" y2="100%">
                                    <stop offset="0%" stop-color="#17E3C4"/>
                                    <stop offset="100%" stop-color="#F5A524"/>
                                </linearGradient>
                            </defs>

                            <circle class="wheel-ring" cx="300" cy="300" r="218"/>
                            <circle class="wheel-hub-glow" cx="300" cy="300" r="130"/>
                            <circle class="wheel-ring inner" cx="300" cy="300" r="90"/>
                            <circle class="wheel-hub" cx="300" cy="300" r="72"/>
                            <text class="wheel-hub-label" x="300" y="298">ERP</text>
                            <text class="wheel-hub-sub" x="300" y="317">Nexa Core</text>

                            <g class="wheel-node" style="--d:0">
                                <line class="wheel-spoke" x1="300.0" y1="210.0" x2="300.0" y2="82.0"/>
                                <circle class="node-circle" cx="300.0" cy="82.0" r="33"/>
                                <g transform="translate(289.0,71.0)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M20 12L12 4H5v7l8 8 7-7z"/><circle cx="8.2" cy="7.2" r="1.3" fill="currentColor" stroke="none"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="300.0" y="32.0" text-anchor="middle" dominant-baseline="middle">Merchandising</text>
                            </g>

                            <g class="wheel-node" style="--d:1">
                                <line class="wheel-spoke" x1="345.0" y1="222.1" x2="409.0" y2="111.2"/>
                                <circle class="node-circle" cx="409.0" cy="111.2" r="33"/>
                                <g transform="translate(398.0,100.2)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <rect x="3.5" y="4.5" width="17" height="16" rx="2"/><path d="M16 2.5v4M8 2.5v4M3.5 9.5h17"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="434.0" y="67.9" text-anchor="start" dominant-baseline="middle">Planning</text>
                            </g>

                            <g class="wheel-node" style="--d:2">
                                <line class="wheel-spoke" x1="377.9" y1="255.0" x2="488.8" y2="191.0"/>
                                <circle class="node-circle" cx="488.8" cy="191.0" r="33"/>
                                <g transform="translate(477.8,180.0)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M3 7l9-4 9 4-9 4-9-4z"/><path d="M3 7v10l9 4 9-4V7"/><path d="M12 11v10"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="532.1" y="166.0" text-anchor="start" dominant-baseline="middle">Store</text>
                            </g>

                            <g class="wheel-node" style="--d:3">
                                <line class="wheel-spoke" x1="390.0" y1="300.0" x2="518.0" y2="300.0"/>
                                <circle class="node-circle" cx="518.0" cy="300.0" r="33"/>
                                <g transform="translate(507.0,289.0)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M5 6c4 3-4 3 0 6s-4 3 0 6M12 6c4 3-4 3 0 6s-4 3 0 6M19 6c-4 3 4 3 0 6s4 3 0 6"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="568.0" y="300.0" text-anchor="start" dominant-baseline="middle">Knitting</text>
                            </g>

                            <g class="wheel-node" style="--d:4">
                                <line class="wheel-spoke" x1="377.9" y1="345.0" x2="488.8" y2="409.0"/>
                                <circle class="node-circle" cx="488.8" cy="409.0" r="33"/>
                                <g transform="translate(477.8,398.0)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M12 2c3 4 6 8 6 12a6 6 0 1 1-12 0c0-4 3-8 6-12z"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="532.1" y="434.0" text-anchor="start" dominant-baseline="middle">Dyeing</text>
                            </g>

                            <g class="wheel-node" style="--d:5">
                                <line class="wheel-spoke" x1="345.0" y1="377.9" x2="409.0" y2="488.8"/>
                                <circle class="node-circle" cx="409.0" cy="488.8" r="33"/>
                                <g transform="translate(398.0,477.8)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M8 3L4 6l1 4h2v11h10V10h2l1-4-4-3-3 2h-2z"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="434.0" y="525.1" text-anchor="start"><tspan x="434.0" dy="0">Garments</tspan><tspan x="434.0" dy="15">Production</tspan></text>
                            </g>

                            <g class="wheel-node" style="--d:6">
                                <line class="wheel-spoke" x1="300.0" y1="390.0" x2="300.0" y2="518.0"/>
                                <circle class="node-circle" cx="300.0" cy="518.0" r="33"/>
                                <g transform="translate(289.0,507.0)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M12 2l8 4v6c0 5-3.5 8.5-8 10-4.5-1.5-8-5-8-10V6l8-4z"/><path d="M9 12l2 2 4-4"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="300.0" y="561.0" text-anchor="middle"><tspan x="300.0" dy="0">Quality</tspan><tspan x="300.0" dy="15">Control</tspan></text>
                            </g>

                            <g class="wheel-node" style="--d:7">
                                <line class="wheel-spoke" x1="255.0" y1="377.9" x2="191.0" y2="488.8"/>
                                <circle class="node-circle" cx="191.0" cy="488.8" r="33"/>
                                <g transform="translate(180.0,477.8)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <circle cx="9" cy="7" r="3"/><path d="M2 21v-1a6 6 0 0 1 12 0v1"/><circle cx="18" cy="8" r="2.3"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="166.0" y="525.1" text-anchor="end"><tspan x="166.0" dy="0">HR &amp;</tspan><tspan x="166.0" dy="15">Payroll</tspan></text>
                            </g>

                            <g class="wheel-node" style="--d:8">
                                <line class="wheel-spoke" x1="222.1" y1="345.0" x2="111.2" y2="409.0"/>
                                <circle class="node-circle" cx="111.2" cy="409.0" r="33"/>
                                <g transform="translate(100.2,398.0)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <rect x="4" y="3" width="16" height="18" rx="2"/><path d="M8 8h8M8 12h8M8 16h5"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="67.9" y="434.0" text-anchor="end" dominant-baseline="middle">Accounts</text>
                            </g>

                            <g class="wheel-node" style="--d:9">
                                <line class="wheel-spoke" x1="210.0" y1="300.0" x2="82.0" y2="300.0"/>
                                <circle class="node-circle" cx="82.0" cy="300.0" r="33"/>
                                <g transform="translate(71.0,289.0)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <path d="M3 15h18l-2 5H5l-2-5z"/><path d="M5 15V9h14v6M12 3v6M9 6h6"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="32.0" y="300.0" text-anchor="end" dominant-baseline="middle">Commercial</text>
                            </g>

                            <g class="wheel-node" style="--d:10">
                                <line class="wheel-spoke" x1="222.1" y1="255.0" x2="111.2" y2="191.0"/>
                                <circle class="node-circle" cx="111.2" cy="191.0" r="33"/>
                                <g transform="translate(100.2,180.0)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <circle cx="9" cy="20" r="1.4" fill="currentColor" stroke="none"/><circle cx="18" cy="20" r="1.4" fill="currentColor" stroke="none"/><path d="M2.5 3h2l2.3 12.3a2 2 0 0 0 2 1.7h8.5a2 2 0 0 0 2-1.6L21 8H6"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="67.9" y="166.0" text-anchor="end" dominant-baseline="middle">Procurement</text>
                            </g>

                            <g class="wheel-node" style="--d:11">
                                <line class="wheel-spoke" x1="255.0" y1="222.1" x2="191.0" y2="111.2"/>
                                <circle class="node-circle" cx="191.0" cy="111.2" r="33"/>
                                <g transform="translate(180.0,100.2)" class="node-icon">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
                                        <rect x="1.5" y="7" width="12.5" height="9.5"/><path d="M14 10.5h3.5l3 3.5v2.5h-3.5"/><circle cx="6" cy="19" r="1.8"/><circle cx="17" cy="19" r="1.8"/>
                                    </svg>
                                </g>
                                <text class="wheel-label" x="166.0" y="67.9" text-anchor="end" dominant-baseline="middle">Logistics</text>
                            </g>
                        </svg>
                    </div>
                </div>

                <div class="brand-bottom">
                    <div class="footline">
                        <span><b>Yarn</b> &middot; <b>Knitting</b> &middot; <b>Dyeing</b> &middot; <b>Garments Production</b> &middot; <b>HRM</b> &middot; <b>Accounts</b> &middot; <b>Commercial</b></span>
                    </div>
                </div>
            </div>

            <!-- ===== Right: login card ===== -->
            <div class="login-panel">
                <div class="login-card">
                    <h2>Sign in to your workspace</h2>
                    <p class="lead">Enter your ERP credentials to access the production &amp; office panel.</p>

                    <asp:Label ID="lblMessage" runat="server" Text=""></asp:Label>

                    <div class="field">
                        <label for="txtUser">User name</label>
                        <div class="input-wrap">
                            <asp:TextBox ID="txtUser" runat="server" CssClass="form-control" ClientIDMode="Static" placeholder="e.g. rahim.admin" />
                        </div>
                    </div>

                    <div class="field">
                        <label for="txtPass">Password</label>
                        <div class="input-wrap">
                            <asp:TextBox ID="txtPass" runat="server" TextMode="Password" CssClass="form-control" ClientIDMode="Static" placeholder="Enter your password" />
                            <span class="toggle-eye" onclick="togglePassword()" id="eyeToggle">SHOW</span>
                        </div>
                    </div>

                    <div class="row-between">
                        <label class="remember">
                            <input type="checkbox" /> Remember me
                        </label>
                        <a href="#">Forgot password?</a>
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Sign in" OnClick="btnLogin_Click" CssClass="btn-signin" />

                    <div class="secure-note">
                        🔒 Access is logged and restricted to authorized ERP users only. Contact your system admin if you're locked out.
                    </div>
                </div>
            </div>

        </div>
    </form>

    <script>
        // ===== password show/hide =====
        function togglePassword() {
            var pass = document.getElementById("txtPass");
            var eye = document.getElementById("eyeToggle");
            if (pass.type === "password") {
                pass.type = "text";
                eye.textContent = "HIDE";
            } else {
                pass.type = "password";
                eye.textContent = "SHOW";
            }
        }
    </script>
</body>
</html>
