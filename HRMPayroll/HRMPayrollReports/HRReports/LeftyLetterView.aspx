<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LeftyLetterView.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports.LeftyLetterView" %>
<!DOCTYPE html>
<html lang="bn">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Letter View</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        :root { --ink:#000; --line:#9a9a9a; }
        * { box-sizing:border-box; }
        html,body { margin:0; padding:0; background:#e5e7eb; }
        body { font-family:'SolaimanLipi','Kalpurush','Noto Sans Bengali',sans-serif; color:var(--ink); font-size:13px; line-height:1.55; }

        /* ---- screen toolbar ---- */
        .bar { position:sticky; top:0; z-index:10; display:flex; gap:10px; align-items:center; justify-content:space-between;
               padding:10px 20px; background:#fff; border-bottom:1px solid #d1d5db; font-family:'Noto Sans Bengali',Arial,sans-serif; }
        .bar b { font-size:14px; }
        .bar span { font-size:12px; color:#64748b; }
        .bar button { height:32px; padding:0 16px; border:0; border-radius:8px; background:#2563eb; color:#fff; font-size:13px; cursor:pointer; }
        .bar button:hover { background:#1d4ed8; }
        .msg { max-width:760px; margin:40px auto; padding:18px 22px; background:#fff; border:1px solid #fca5a5; border-radius:10px;
               font-family:'Noto Sans Bengali',Arial,sans-serif; font-size:14px; color:#7f1d1d; }

        /* ---- A4 page ---- */
        .page { width:210mm; min-height:297mm; margin:16px auto; padding:12mm 12mm 14mm; background:#fff; box-shadow:0 2px 10px rgba(0,0,0,.18); page-break-after:always; }
        .page:last-child { page-break-after:auto; }

        .lh { text-align:center; padding-bottom:8px; border-bottom:2px solid #333; margin-bottom:22px; }
        .lh .co { font-size:24px; font-weight:700; line-height:1.3; }
        .lh .ad { font-size:14px; margin-top:4px; }
        .title { text-align:center; font-size:16px; font-weight:700; line-height:1.55; }
        .date { margin-top:2px; font-size:13px; }
        hr.rule { border:0; border-top:4px double #777; margin:10px 0 8px; }
        .reg { text-align:center; font-weight:700; font-size:14px; text-decoration:underline; text-underline-offset:3px; margin-bottom:6px; }

        table.info { width:100%; border-collapse:collapse; font-size:13px; }
        table.info th { font-weight:400; text-align:center; padding:6px 4px; border:1px solid var(--line); }
        table.info td { vertical-align:top; padding:3px 4px; border-left:1px solid var(--line); border-right:1px solid var(--line); }
        table.info tr:last-child td { border-bottom:1px solid var(--line); }
        table.info td.c1 { width:33%; } table.info td.c2,table.info td.c3 { width:33.5%; }
        .kv { display:grid; grid-template-columns:62px 1fr; }
        .kv.w { grid-template-columns:52px 1fr; }
        .kv i { font-style:normal; }
        .kv span::before { content:": "; }

        .subject { margin:16px 0 26px; font-size:14px; font-weight:700; }
        .body p { margin:0 0 12px; text-align:justify; font-size:13.5px; line-height:1.85; }
        .sign { margin-top:70px; }
        .sign .gap { height:46px; }
        .cc { margin-top:26px; }
        .sign .co2 { margin-top:0; }


        .subject.u { text-decoration:underline; text-underline-offset:3px; }
        .row3 { display:grid; grid-template-columns:1fr auto 1fr; align-items:center; margin-top:2px; }
        .row3 .issue { font-size:16px; font-weight:700; }

        /* ---- খাম (৬৮৪ x ২৯৭ pt = ২৪১.৩ x ১০৪.৮ মিমি) ---- */
        .env { width:241.3mm; height:104.8mm; margin:16px auto; padding:5mm 9mm 4mm; background:#fff; box-shadow:0 2px 10px rgba(0,0,0,.18);
               overflow:hidden; page-break-after:always; }
        .env:last-child { page-break-after:auto; }
        .env .idn { text-align:center; font-size:17px; font-weight:700; }
        .env .hr2 { border-top:4px double #444; margin:4px 0 10px; }
        .env .egrid { display:grid; grid-template-columns:1fr 14px 1.25fr; }
        .env .from { align-self:center; padding-right:12px; }
        .env .fco { font-size:21px; font-weight:700; line-height:1.35; }
        .env .fad { font-size:14px; margin-top:10px; line-height:1.6; }
        .env .vl { border-left:4px double #555; }
        .env .to { padding-left:10px; }
        .env .tt { text-align:center; font-size:15px; border-bottom:4px double #999; padding-bottom:2px; margin-bottom:6px; }
        .env .tr { font-size:15px; margin-bottom:3px; }
        .env .ekv { display:grid; grid-template-columns:66px 1fr; font-size:15px; line-height:1.5; }
        .env .ekv i { font-style:normal; }
        .env .ekv span::before { content:": "; }

        @media print {
            html,body { background:#fff; }
            .no-print { display:none !important; }
            .page { margin:0; box-shadow:none; width:210mm; min-height:297mm; }
            .env { margin:0; box-shadow:none; }
        }
    </style>
    <asp:Literal ID="litPageCss" runat="server" />
</head>
<body>
<form id="form1" runat="server">
    <div class="bar no-print">
        <div><b><asp:Literal ID="litTitle" runat="server" Text="Letter View" /></b>
             <span>&nbsp;·&nbsp;<asp:Literal ID="litCount" runat="server" /></span></div>
        <button type="button" onclick="window.print()">Print</button>
    </div>
    <asp:Literal ID="litLetters" runat="server" />
</form>
</body>
</html>
