<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ActiveEmployeeListReport.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports.ActiveEmployeeListReport" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Employee Report</title>
<style>
@page{size:A4;margin:10mm 10mm 10mm 10mm}
*{box-sizing:border-box}
body{font-family:Arial,"Nirmala UI",Vrinda,Helvetica,sans-serif;font-size:8pt;color:#000;margin:0}

.head{position:relative;text-align:center;padding-bottom:2mm;border-bottom:1.2px solid #000}
.head .logo{position:absolute;left:0;top:0;max-height:14mm;max-width:30mm}
.head .co{font-size:14pt;font-weight:700;line-height:1.3}
.head .adr{font-size:8pt}
.head .ttl{font-size:9pt;margin-top:1mm;font-weight:700}
.head .sub{font-size:8pt;margin-top:.5mm}

table.t{border-collapse:collapse;width:100%;margin-top:2mm;table-layout:fixed}
table.t th,table.t td{border:1px solid #000;padding:1mm 1.1mm;vertical-align:top;font-size:8pt;word-wrap:break-word}
table.t th{font-weight:400;text-align:center;vertical-align:middle;height:6mm}
table.t thead{display:table-header-group}
table.t tr{page-break-inside:avoid}

table.t td.headCell{border:0;padding:0 0 2mm 0}
table.t thead tr.headRow{page-break-inside:avoid;page-break-after:avoid}

table.t tr.gDept td{background:#d9d9d9}
table.t tr.gSec td{background:#efefef}
table.t tr.sub td{background:#f7f7f7}
table.t tr.grand td{background:#d9d9d9;font-size:9pt}
table.t td img.ph{width:14mm;height:17mm;object-fit:cover;display:block;margin:0 auto}

.c{text-align:center}.r{text-align:right}

.msg{display:block;text-align:center;font-size:12pt;margin:20mm auto}

.bar{position:fixed;top:10px;right:14px;display:flex;gap:6px;z-index:10}
.bar button,.bar a{padding:6px 12px;font-size:13px;cursor:pointer;border:1px solid #94a3b8;background:#fff;border-radius:6px;color:#0f172a;text-decoration:none;font-family:Arial,Helvetica,sans-serif}
.bar button:hover,.bar a:hover{background:#f1f5f9}

@media screen{html{background:#e5e5e5}.sheet{width:210mm;min-height:297mm;margin:8mm auto;padding:10mm;background:#fff;box-shadow:0 0 6px rgba(0,0,0,.25)}}
@media print{.noprint{display:none!important}}
</style>
</head>
<body>
<form id="form1" runat="server">

<div class="bar noprint">
    <!-- Print চাপলে ব্রাউজারের "Save as PDF" দিয়ে PDF করা যাবে -->
    <button type="button" onclick="window.print()">Print / PDF</button>
    <asp:LinkButton ID="btnWord" runat="server" OnClick="btnWord_Click">Download Word</asp:LinkButton>
    <asp:LinkButton ID="btnExcel" runat="server" OnClick="btnExcel_Click">Download Excel</asp:LinkButton>
</div>

<asp:Label ID="lblNone" runat="server" CssClass="msg" Visible="false" />

<asp:Panel ID="pnlReport" runat="server" CssClass="sheet">
    <asp:Literal ID="litTable" runat="server" />
</asp:Panel>

</form>
</body>
</html>