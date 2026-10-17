<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JobCardReport.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.AttendanceReport.JobCardReport" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Job Card</title>
    <style>
        :root { --ink:#000; --line:#555; }
        * { box-sizing:border-box; }
        html,body { margin:0; padding:0; background:#e5e7eb; }
        body { font-family:Arial,'Segoe UI','Noto Sans Bengali',sans-serif; color:var(--ink); font-size:11.5px; line-height:1.35; }

        .bar { position:sticky; top:0; z-index:10; display:flex; gap:10px; align-items:center; justify-content:space-between;
               padding:10px 20px; background:#fff; border-bottom:1px solid #d1d5db; }
        .bar b { font-size:14px; }
        .bar span { font-size:12px; color:#64748b; }
        .bar button { height:32px; padding:0 16px; border:0; border-radius:8px; background:#2563eb; color:#fff; font-size:13px; cursor:pointer; }
        .bar button:hover { background:#1d4ed8; }
        .msg { max-width:760px; margin:40px auto; padding:18px 22px; background:#fff; border:1px solid #fca5a5; border-radius:10px;
               font-size:14px; color:#7f1d1d; }

        /* ---- A4 page (প্রতিটি কর্মী আলাদা পাতায়) ---- */
        .page { width:210mm; min-height:297mm; margin:16px auto; padding:10mm 10mm 12mm; background:#fff; box-shadow:0 2px 10px rgba(0,0,0,.18); page-break-after:always; }
        .page:last-child { page-break-after:auto; }

        .co { text-align:center; font-size:20px; font-weight:700; line-height:1.3; }
        .ad { text-align:center; font-size:12px; margin-top:2px; }
        .ttl { text-align:center; font-size:15px; font-weight:700; margin:8px 0 8px; text-decoration:underline; text-underline-offset:3px; }

        table.info { width:100%; border-collapse:collapse; font-size:12px; margin-bottom:8px; }
        table.info td { padding:2px 4px; vertical-align:top; }
        table.info td.l { width:90px; font-weight:700; }
        table.info td.s { width:10px; }

        table.rp { width:100%; border-collapse:collapse; font-size:11px; }
        table.rp th, table.rp td { border:1px solid var(--line); padding:3px 4px; vertical-align:middle; }
        table.rp th { background:#f1f1f1; font-weight:700; text-align:center; }
        table.rp thead { display:table-header-group; }
        table.rp tr { page-break-inside:avoid; }
        table.rp td.c { text-align:center; }
        table.rp tr.abs td { background:#fdecec; }
        table.rp tr.wo td { background:#f3f4f6; }
        table.rp tr.late td.st { color:#b91c1c; font-weight:700; }

        table.sm { width:100%; border-collapse:collapse; font-size:11px; margin-top:10px; }
        table.sm th, table.sm td { border:1px solid var(--line); padding:3px 4px; text-align:center; }
        table.sm th { background:#f1f1f1; }

        .signs { display:grid; grid-template-columns:repeat(4,1fr); gap:14px; margin-top:60px; text-align:center; font-size:11px; }
        .signs div { border-top:1px solid #000; padding-top:3px; }

        .stamp { margin-top:14px; font-size:10px; color:#333; display:flex; justify-content:space-between; }

        @media print {
            @page { size:A4; margin:10mm; }
            html,body { background:#fff; }
            .no-print { display:none !important; }
            .page { margin:0; box-shadow:none; width:auto; min-height:0; padding:0; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="bar no-print">
        <div><b><asp:Literal ID="litTitle" runat="server" Text="Employee Job Card" /></b>
             <span>&nbsp;·&nbsp;<asp:Literal ID="litCount" runat="server" /></span></div>
        <button type="button" onclick="window.print()">Print</button>
    </div>
    <asp:Literal ID="litReport" runat="server" />
</form>
</body>
</html>
