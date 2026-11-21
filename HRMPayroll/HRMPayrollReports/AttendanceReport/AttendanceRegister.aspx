<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AttendanceRegister.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.AttendanceReport.AttendanceRegister" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance Register</title>
    <style>
        :root { --ink:#000; --line:#555; }
        * { box-sizing:border-box; }
        html,body { margin:0; padding:0; background:#e5e7eb; }
        body { font-family:Arial,'Segoe UI','Noto Sans Bengali',sans-serif; color:var(--ink); font-size:11px; line-height:1.3; }

        /* ---- screen toolbar ---- */
        .bar { position:sticky; top:0; z-index:10; display:flex; gap:10px; align-items:center; justify-content:space-between;
               padding:10px 20px; background:#fff; border-bottom:1px solid #d1d5db; }
        .bar b { font-size:14px; }
        .bar span { font-size:12px; color:#64748b; }
        .bar button, .bar .btn { height:32px; padding:0 16px; border:0; border-radius:8px; background:#2563eb; color:#fff; font-size:13px; cursor:pointer; }
        .bar button:hover, .bar .btn:hover { background:#1d4ed8; }
        .bar .btns { display:flex; gap:8px; align-items:center; }
        .msg { max-width:760px; margin:40px auto; padding:18px 22px; background:#fff; border:1px solid #fca5a5; border-radius:10px;
               font-size:14px; color:#7f1d1d; }

        /* ---- A4 Landscape page (প্রতিটি Department/Section আলাদা পাতায়) ---- */
        .page { width:297mm; min-height:210mm; margin:16px auto; padding:8mm 8mm 10mm; background:#fff; box-shadow:0 2px 10px rgba(0,0,0,.18); page-break-after:always; }
        .page:last-child { page-break-after:auto; }

        .co { text-align:center; font-size:19px; font-weight:700; line-height:1.3; }
        .ad { text-align:center; font-size:11.5px; margin-top:2px; }
        .ttl { text-align:center; font-size:14px; font-weight:700; margin:6px 0 4px; text-decoration:underline; text-underline-offset:3px; }
        .grpl { font-weight:700; font-size:11.5px; margin:4px 0; }

        table.rg { width:100%; border-collapse:collapse; table-layout:fixed; font-size:9px; }
        table.rg th, table.rg td { border:1px solid var(--line); padding:2px 1px; vertical-align:middle; overflow:hidden; }
        table.rg th { background:#f1f1f1; font-weight:700; text-align:center; }
        table.rg thead { display:table-header-group; }
        table.rg tr { page-break-inside:avoid; }
        table.rg td.c { text-align:center; }
        table.rg td.l { text-align:left; padding-left:3px; }
        table.rg th.sl { width:7mm; }
        table.rg th.id { width:16mm; }
        table.rg th.ph { width:9mm; }
        table.rg th.nm { width:30mm; }
        table.rg th.ds { width:24mm; }
        table.rg th.dy { width:5mm; }
        table.rg th.tt { width:8mm; }
        table.rg th small { display:block; font-weight:400; font-size:7px; color:#444; }

        /* স্ট্যাটাস রং */
        td.sA { color:#b91c1c; font-weight:700; }
        td.sH { background:#eeeeee; color:#444; }
        td.sL { color:#1d4ed8; }
        tr.tot td { font-weight:700; border:0; padding-top:5px; font-size:10.5px; }
        .legend { margin-top:4px; font-size:9.5px; color:#333; }

        img.ph { width:26px; height:32px; object-fit:cover; display:block; margin:0 auto; border:1px solid #999; }

        .signs { display:grid; grid-template-columns:repeat(6,1fr); gap:8px; margin-top:34px; text-align:center; font-size:10.5px; }
        .signs div { border-top:1px solid #000; padding-top:3px; }
        .stamp { margin-top:10px; font-size:10px; color:#333; display:flex; justify-content:space-between; }

        @media print {
            @page { size:A4 landscape; margin:8mm; }
            html,body { background:#fff; }
            .no-print { display:none !important; }
            .page { margin:0; box-shadow:none; width:auto; min-height:0; padding:0; }
            * { -webkit-print-color-adjust:exact; print-color-adjust:exact; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">
    <div class="bar no-print">
        <div><b><asp:Literal ID="litTitle" runat="server" Text="Attendance Register" /></b>
             <span>&nbsp;·&nbsp;<asp:Literal ID="litCount" runat="server" /></span></div>
        <div class="btns">
            <asp:Button ID="btnPdf" runat="server" Text="PDF" CssClass="btn" OnClick="btnPdf_Click" />
            <asp:Button ID="btnWord" runat="server" Text="Word" CssClass="btn" OnClick="btnWord_Click" />
            <asp:Button ID="btnExcel" runat="server" Text="Excel" CssClass="btn" OnClick="btnExcel_Click" />
            <button type="button" onclick="window.print()">Print</button>
        </div>
    </div>
    <asp:Literal ID="litReport" runat="server" />
</form>
</body>
</html>
