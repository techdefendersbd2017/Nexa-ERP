<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SalarySheetBangla.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.PayrollReports.SalarySheetBangla" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <title>মাসিক বেতন পত্র</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;700&display=swap" rel="stylesheet" />
    <style>
        @page { size: A4 landscape; margin: 5mm; }
        * { box-sizing: border-box; }
        body { font-family: 'Kalpurush', 'Nikosh', 'SolaimanLipi', 'Noto Sans Bengali', 'Vrinda', Arial, sans-serif; margin: 0; background: #e5e7eb; color: #000; }

        .toolbar { position: sticky; top: 0; background: #1e293b; padding: 8px 16px; text-align: right; z-index: 10; }
        .toolbar button { padding: 6px 16px; font-size: 13px; cursor: pointer; border: 0; border-radius: 4px; background: #2563eb; color: #fff; }
        .msg { margin: 20px; padding: 14px; background: #fef2f2; border: 1px solid #fca5a5; color: #991b1b; font-size: 14px; }

        /* ---- পৃষ্ঠা: A4 landscape (৫ মিমি মার্জিন বাদে 287 x 199 মিমি) ---- */
        .pg { position: relative; width: 287mm; height: 199mm; margin: 10px auto; background: #fff; overflow: hidden; page-break-after: always; break-after: page; }
        .pg:last-child { page-break-after: auto; break-after: auto; }

        /* ---- বিস্তারিত পৃষ্ঠার হেডার ---- */
        .box { border: 1.5px solid #000; }
        .ph { display: flex; justify-content: space-between; align-items: flex-start; padding: 3px 6px 4px; }
        .ph .co { font-size: 20px; font-weight: bold; line-height: 1.15; }
        .ph .ad { font-size: 11.5px; }
        .ph .pn { font: bold 10px Arial, sans-serif; text-align: center; }
        .ph .pay { font-size: 13px; text-align: center; margin-top: 8px; }
        .ph .tt { font-size: 15px; font-weight: bold; text-align: right; }
        .ph .sec { font-size: 15px; text-align: right; }

        /* ---- টেবিল ---- */
        table.sheet { width: 100%; border-collapse: collapse; table-layout: fixed; }
        table.sheet th, table.sheet td { border: 1px solid #000; padding: 0 1px; overflow: hidden; }
        table.sheet thead th { background: #d9d9d9; font-weight: bold; font-size: 8px; line-height: 1.1; text-align: center; vertical-align: middle; }
        table.sheet thead th.stkh { padding: 0; vertical-align: top; }
        .stkh div { height: 16px; line-height: 16px; border-bottom: 1px solid #000; font-size: 8px; white-space: nowrap; }
        .stkh div:last-child { border-bottom: 0; }
        .vt, .vt2 { writing-mode: vertical-rl; transform: rotate(180deg); display: inline-block; line-height: 1.05; }
        .vt { max-height: 64px; }
        .vt2 { max-height: 46px; }

        tr.dr { height: 54px; }
        tr.dr td { font-size: 9.5px; text-align: center; vertical-align: middle; }
        tr.dr td.l { text-align: left; vertical-align: top; padding: 2px; }
        td.b { font-weight: bold; }
        td.stk { padding: 0; }
        td.stk .s { height: 17px; line-height: 17px; border-bottom: 1px solid #000; text-align: center; font-size: 9.5px; white-space: nowrap; }
        td.stk .s:last-child { border-bottom: 0; }
        .rv { writing-mode: vertical-rl; transform: rotate(180deg); display: inline-block; line-height: 1; white-space: nowrap; }

        tr.tr td { height: 44px; font-size: 9.5px; font-weight: bold; text-align: center; vertical-align: middle; }
        tr.tr td.tl { font-size: 17px; }

        /* ---- স্বাক্ষর ---- */
        .sign { position: absolute; left: 0; right: 0; bottom: 6mm; display: flex; justify-content: space-between; padding: 0 4px; font: bold 12px Arial, sans-serif; }
        .sign div { width: 112px; border-top: 1px solid #000; text-align: center; padding-top: 3px; line-height: 1.15; }

        /* ---- সারসংক্ষেপ পৃষ্ঠা ---- */
        .pnr { position: absolute; right: 10px; top: 4px; font: bold 10px Arial, sans-serif; }
        .sh { text-align: center; border-bottom: 1px solid #000; padding-bottom: 8px; margin: 22px 6px 0; }
        .sh .co { font-size: 32px; font-weight: bold; line-height: 1.2; }
        .sh .ad { font-size: 14px; }
        .sr { display: flex; justify-content: space-between; align-items: flex-end; padding: 22px 8px 0; }
        .sr .sec { font-size: 24px; }
        .sr .tt { font-size: 26px; font-weight: bold; }
        .paybox { width: 300px; margin: 14px auto 12px; border-top: 1px solid #000; border-bottom: 2px solid #000; text-align: center; font-size: 24px; font-weight: bold; padding: 2px 0; }
        .sumwrap { display: flex; justify-content: center; gap: 70px; margin-top: 8px; }
        .sumwrap table { border-collapse: collapse; }
        .sumwrap td { font-size: 19px; padding: 2px 3px; line-height: 1.3; }
        .sumwrap td.lb { text-align: right; }
        .sumwrap td.cl { width: 14px; text-align: center; }
        .sumwrap td.vl { text-align: left; min-width: 110px; }
        .sumwrap tr.b td { font-weight: bold; }

        @media print {
            body { background: #fff; }
            .toolbar { display: none; }
            .pg { margin: 0; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="toolbar"><button type="button" onclick="window.print()">Print</button></div>
        <asp:Literal ID="litReport" runat="server" />
    </form>
</body>
</html>
