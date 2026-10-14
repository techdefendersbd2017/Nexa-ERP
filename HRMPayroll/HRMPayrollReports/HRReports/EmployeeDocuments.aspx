<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeDocuments.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports.EmployeeDocuments" %>

<!DOCTYPE html>
<html lang="bn">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Documents</title>
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
        .sheet { width:210mm; min-height:297mm; margin:16px auto; padding:14mm 14mm 10mm; background:#fff; box-shadow:0 2px 10px rgba(0,0,0,.18); font-size:13px; line-height:1.55; page-break-after:always; }
        .sheet:last-child { page-break-after:auto; }
        .hd { text-align:center; border-bottom:2px solid #000; padding-bottom:4px; margin-bottom:8px; }
        .hd h1 { margin:0; font-size:24px; }
        .hd .sub { font-size:12px; }
        .ttl { text-align:center; font-weight:bold; font-size:16px; text-decoration:underline; margin:8px 0 12px; }
        table.kv { width:100%; border-collapse:collapse; }
        table.kv td { padding:2px 4px; vertical-align:top; }
        table.kv td.k { width:34%; white-space:nowrap; }
        table.bd { width:100%; border-collapse:collapse; }
        table.bd td, table.bd th { border:1px solid #000; padding:4px 6px; vertical-align:top; }
        table.bd th { background:#f1f5f9; }
        .sign { display:flex; justify-content:space-between; margin-top:50px; }
        .sign div { border-top:1px solid #000; min-width:150px; text-align:center; padding-top:2px; }
        p.j { text-align:justify; margin:4px 0; }
        .photo { width:90px; height:105px; object-fit:cover; border:1px solid #999; }
        .logo { width:70px; height:60px; object-fit:contain; }
        .noimg { display:inline-block; background:#f1f5f9; }

        .card { border:1px solid #000; border-radius:8px; width:150mm; margin:0 auto 14px; padding:8px 12px; box-sizing:border-box; }
        .card .top { display:flex; gap:10px; align-items:center; }
        .card .mid { flex:1; text-align:center; }
        .card .mid h2 { margin:0; font-size:18px; }
        .card .back { display:flex; gap:12px; }
        .card .back > div { flex:1; }

        /* ---- ফরম-৪১ ---- */
        .f41h{text-align:center;border-bottom:3px solid #000;padding-bottom:6px;margin-bottom:10px}
        .f41h .t1{font-size:22px;font-weight:bold}
        .f41h .t2{font-size:13px}
        .f41ttl{text-align:center;font-weight:bold;font-size:17px;margin:8px 0 14px}
        .f41p{margin:6px 0}
        table.f41k{width:100%;border-collapse:collapse;margin-top:8px}
        table.f41k td{padding:3px 4px;vertical-align:top}
        table.f41k td.l{width:27%;text-align:right;white-space:nowrap}
        table.f41t{margin-top:10px}
        table.f41t th{background:#fff;font-weight:normal;text-align:center}
        table.f41t td.c{text-align:center}
        .f41s{display:flex;justify-content:space-between;margin-top:60px}

        /* ---- ফরম-১৫ ---- */
        .f15top{position:relative;min-height:38mm;margin-top:8px}
        .f15top .mid{text-align:center;padding-top:12mm;line-height:1.7}
        .pbox{position:absolute;right:0;top:0;width:34mm;height:36mm;border:1px solid #9a9a9a;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:12px}
        .pbox img{width:100%;height:100%;object-fit:cover}
        table.f15{width:100%;border-collapse:collapse;table-layout:fixed}
        table.f15 > tbody > tr > td{border:1px solid #000;padding:4px 6px;vertical-align:top}
        table.f15 td.h{text-align:center;font-size:18px}
        .f15ck{display:flex;justify-content:space-between;width:72%;margin-top:2px}
        .bx{display:inline-block;width:11mm;height:7mm;border:1px solid #000;vertical-align:middle;margin:0 6px}
        .f15sg{display:flex;justify-content:space-between;align-items:flex-end;height:30mm}

        /* ঠিকানার ছোট টেবিল (দুই ফরমেই) */
        table.ad{border-collapse:collapse;width:100%}
        table.ad td{border:0!important;padding:2px 4px}
        table.ad.half td{width:50%}

        @media print {
            html,body { background:#fff; }
            .no-print { display:none !important; }
            .sheet { margin:0; box-shadow:none; width:210mm; min-height:297mm; }
        }
    </style>
    <asp:Literal ID="litPageCss" runat="server" />
</head>
<body>
<form id="form1" runat="server">
    <div class="bar no-print">
        <div><b><asp:Literal ID="litTitle" runat="server" Text="Employee Documents" /></b>
             <span>&nbsp;·&nbsp;<asp:Literal ID="litCount" runat="server" /></span></div>
        <button type="button" onclick="window.print()">Print</button>
    </div>
    <asp:Literal ID="litLetters" runat="server" />
</form>
</body>
</html>
