<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeIDCard.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports.EmployeeIDCard" %>

<!DOCTYPE html>
<html lang="bn">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee ID Card (PVC)</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        :root { --ink:#000; }
        * { box-sizing:border-box; }
        html,body { margin:0; padding:0; background:#e5e7eb; }
        body { font-family:'SolaimanLipi','Kalpurush','Noto Sans Bengali',sans-serif; color:var(--ink); }

        /* ---- screen toolbar ---- */
        .bar { position:sticky; top:0; z-index:10; display:flex; gap:10px; align-items:center; justify-content:space-between;
               padding:10px 20px; background:#fff; border-bottom:1px solid #d1d5db; font-family:'Noto Sans Bengali',Arial,sans-serif; }
        .bar b { font-size:14px; }
        .bar span { font-size:12px; color:#64748b; }
        .bar button { height:32px; padding:0 16px; border:0; border-radius:8px; background:#2563eb; color:#fff; font-size:13px; cursor:pointer; }
        .bar button:hover { background:#1d4ed8; }
        .msg { max-width:760px; margin:40px auto; padding:18px 22px; background:#fff; border:1px solid #fca5a5; border-radius:10px;
               font-family:'Noto Sans Bengali',Arial,sans-serif; font-size:14px; color:#7f1d1d; }

        /* ---- A4 পেজ: প্রতি সারিতে সামনে + পিছনে, ৫ সারি = ১০টি PVC কার্ড ---- */
        .sheet { width:210mm; height:297mm; margin:16px auto; padding:9.5mm 17.4mm 0; background:#fff;
                 box-shadow:0 2px 10px rgba(0,0,0,.18); overflow:hidden; page-break-after:always;
                 display:grid; grid-template-columns:85.6mm 85.6mm; grid-auto-rows:54mm; gap:2mm 4mm; align-content:start; }
        .sheet:last-child { page-break-after:auto; }

        /* ---- PVC কার্ড (CR80) ৮৫.৬ × ৫৪ মিমি ---- */
        .card { width:85.6mm; height:54mm; border:0.2mm solid #000; border-radius:3mm; padding:2mm 2.5mm; overflow:hidden;
                display:flex; flex-direction:column; font-size:6.6pt; line-height:1.3; background:#fff; }
        .card .hd { display:flex; align-items:center; gap:2mm; border-bottom:0.3mm solid #000; padding-bottom:1mm; }
        .card .hd .mid { flex:1; text-align:center; }
        .card .hd h2 { margin:0; font-size:9.5pt; line-height:1.2; }
        .card .hd .ad { font-size:5.4pt; line-height:1.2; }
        .logo { width:9mm; height:9mm; object-fit:contain; }
        .photo { width:19mm; height:23mm; object-fit:cover; border:0.2mm solid #666; }
        .noimg { display:inline-block; background:#f1f5f9; }
        .card .bd { display:flex; gap:2mm; margin-top:1.2mm; flex:1; }
        .card .bd table { flex:1; border-collapse:collapse; align-self:flex-start; }
        .card .bd td { padding:0.5mm 0.5mm; vertical-align:top; }
        .card .bd td.k { white-space:nowrap; width:1%; }
        .card .sg { display:flex; justify-content:space-between; margin-top:auto; font-size:5.8pt; }
        .card .sg div { border-top:0.2mm solid #000; min-width:24mm; text-align:center; padding-top:0.3mm; }
        /* পিছনের পাশের স্বাক্ষরের জায়গা (লাইনের উপরে ফাঁকা স্থান) */
        .card .sg.big { height:8mm; align-items:flex-end; flex:none; }
        .card .ttl { text-align:center; font-weight:bold; font-size:8pt; border-bottom:0.3mm solid #000; padding-bottom:0.8mm; flex:none; }
        /* পিছনের পাশ: পুরো কার্ড ভরে */
        .card .back { display:flex; gap:3mm; margin-top:1.5mm; font-size:7pt; line-height:1.4; flex:1; min-height:0; }
        .card .back > div { flex:1; display:flex; flex-direction:column; justify-content:space-around; }
        .card .back > div + div { border-left:0.2mm solid #999; padding-left:3mm; }
        .card .back p { margin:0; }

        .no-print-note { max-width:210mm; margin:12px auto; padding:10px 16px; background:#fffbeb; border:1px solid #fcd34d; border-radius:8px;
                         font-family:Arial,sans-serif; font-size:13px; color:#78350f; }

        @media print {
            html,body { background:#fff; }
            .no-print { display:none !important; }
            .sheet { margin:0; box-shadow:none; width:210mm; height:297mm; }
            * { -webkit-print-color-adjust:exact; print-color-adjust:exact; }
        }
    </style>
    <style media="print">@page { size:A4; margin:0; }</style>
</head>
<body>
<form id="form1" runat="server">
    <div class="bar no-print">
        <div><b>Employee ID Card (PVC)</b>
             <span>&nbsp;·&nbsp;<asp:Literal ID="litCount" runat="server" /></span></div>
        <button type="button" onclick="window.print()">Print</button>
    </div>
    <asp:Literal ID="litCards" runat="server" />
</form>
</body>
</html>
