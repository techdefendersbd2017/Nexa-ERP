<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ActiveEmployeeListLastIncrement.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports.ActiveEmployeeListLastIncrement" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Active Employee List with Last Increment</title>
<style>
@page{size:A4 landscape;margin:8mm 10mm}
*{box-sizing:border-box}
body{font-family:Calibri,Arial,Helvetica,sans-serif;font-size:8.5pt;color:#000;margin:0}

/* ===== Header (PDF এর মতো: বোল্ড কোম্পানি নাম, বোল্ড টাইটেল, নিচে লাইন) ===== */
.head{position:relative;text-align:center;padding-bottom:1.5mm;border-bottom:1.3px solid #000}
.head .logo{position:absolute;left:0;top:0;max-height:14mm;max-width:30mm}
.head .co{font-family:Arial,Helvetica,sans-serif;font-size:16pt;font-weight:700;line-height:1.25;text-transform:uppercase}
.head .ttl{font-family:Arial,Helvetica,sans-serif;font-size:8.5pt;font-weight:700;margin-top:.5mm}

/* ===== Table ===== */
/*table.t{border-collapse:collapse;width:100%;margin-top:3mm;table-layout:fixed}
table.t th,table.t td{border:1px solid #444;padding:0 1.4mm;font-size:8.5pt;word-wrap:break-word}
table.t th{font-weight:400;text-align:center;vertical-align:middle;height:12mm;line-height:1.15}
table.t tbody tr.dr td{height:9mm;vertical-align:middle}
table.t thead{display:table-header-group}
table.t tr{page-break-inside:avoid}

table.t td.headCell{border:0;padding:0}
table.t thead tr.headRow{page-break-inside:avoid;page-break-after:avoid}*/

/* ===== Table ===== */
table.t{border-collapse:separate;border-spacing:0;width:100%;margin-top:3mm;table-layout:fixed}
table.t th,table.t td{border:0;border-right:1px solid #444;border-bottom:1px solid #444;padding:0 1.4mm;font-size:8.5pt;word-wrap:break-word}
table.t th:first-child,table.t td:first-child{border-left:1px solid #444}
table.t thead tr+tr th{border-top:1px solid #444}
table.t th{font-weight:400;text-align:center;vertical-align:middle;height:12mm;line-height:1.15}
table.t tbody tr.dr td{height:9mm;vertical-align:middle}
table.t thead{display:table-header-group}
table.t tr{page-break-inside:avoid}

table.t td.headCell{border:0;padding:0 0 2mm 0}
table.t thead tr.headRow{page-break-inside:avoid;page-break-after:avoid}

/* Department group heading */
table.t td.grp{font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:9pt;background:#e9e9e9;text-align:left;padding:1.5mm 2mm;height:auto}
table.t tr.grpRow{page-break-after:avoid}

/* Department group heading */
table.t td.grp{font-family:Arial,Helvetica,sans-serif;font-weight:700;font-size:9pt;background:#e9e9e9;text-align:left;padding:1.5mm 2mm;height:auto}
table.t tr.grpRow{page-break-after:avoid}

.c{text-align:center}.r{text-align:right}.l{text-align:left}
td.rm{font-family:Arial,Helvetica,sans-serif;font-size:8.5pt}

.msg{display:block;text-align:center;font-size:12pt;margin:20mm auto}

.bar{position:fixed;top:10px;right:14px;display:flex;gap:6px;z-index:10}
.bar button,.bar a{padding:6px 12px;font-size:13px;cursor:pointer;border:1px solid #94a3b8;background:#fff;border-radius:6px;color:#0f172a;text-decoration:none;font-family:Arial,Helvetica,sans-serif}
.bar button:hover,.bar a:hover{background:#f1f5f9}

@media screen{html{background:#e5e5e5}.sheet{width:297mm;min-height:210mm;margin:8mm auto;padding:8mm 10mm;background:#fff;box-shadow:0 0 6px rgba(0,0,0,.25)}}
@media print{.noprint{display:none!important}}
</style>
</head>
<body>
<form id="form1" runat="server">

<div class="bar noprint">
    <button type="button" onclick="window.print()">Print</button>
    <asp:LinkButton ID="btnPdf" runat="server" OnClick="btnPdf_Click">Download PDF</asp:LinkButton>
    <asp:LinkButton ID="btnWord" runat="server" OnClick="btnWord_Click">Download Word</asp:LinkButton>
    <asp:LinkButton ID="btnExcel" runat="server" OnClick="btnExcel_Click">Download Excel</asp:LinkButton>
</div>
    <br/>
<asp:Label ID="lblNone" runat="server" CssClass="msg" Visible="false" />

<asp:Panel ID="pnlReport" runat="server" CssClass="sheet">

    <table class="t">
        <colgroup>
            <col style="width:4.2%" /><col style="width:5.2%" /><col style="width:11.6%" /><col style="width:11.3%" />
            <col style="width:9.4%" /><col style="width:13.3%" /><col style="width:9.9%" /><col style="width:5.7%" />
            <col style="width:6%" /><col style="width:5.7%" /><col style="width:5.8%" /><col style="width:11.9%" />
        </colgroup>
        <thead>
            <tr class="headRow">
                <td class="headCell" colspan="12">
                    <div class="head">
                        <asp:Literal ID="Literal1" runat="server" />
                        <div class="co"><asp:Label ID="Label1" runat="server" /></div>
                        <div class="ttl">Active Employee List with Last Increment</div>
                    </div>
                </td>
            </tr>
            <tr>
                <th>Sl No</th><th>ID No</th><th>Name</th><th>Designation</th><th>Joining Date</th>
                <th>Department</th><th>Section</th><th>Line</th><th>Gross<br />Salary</th>
                <th>Last<br />Increment<br />Month</th><th>Last<br />Increment<br />Amount</th><th>Remarks</th>
            </tr>
        </thead>

        <tbody>
            <asp:Repeater ID="rptRows" runat="server">
                <ItemTemplate>
                    <asp:PlaceHolder runat="server" Visible='<%# Convert.ToString(Eval("GroupHead")) != "" %>'>
                        <tr class="grpRow">
                            <td class="grp" colspan="12">Department : <%# H(Eval("GroupHead")) %></td>
                        </tr>
                    </asp:PlaceHolder>
                    <tr class="dr">
                        <td class="c"><%# H(Eval("Sl")) %></td>
                        <td class="c"><%# H(Eval("IdNo")) %></td>
                        <td class="l"><%# H(Eval("Name")) %></td>
                        <td class="l"><%# H(Eval("Designation")) %></td>
                        <td class="c"><%# H(Eval("JoinDate")) %></td>
                        <td class="l"><%# H(Eval("Department")) %></td>
                        <td class="l"><%# H(Eval("Section")) %></td>
                        <td class="l"><%# H(Eval("Line")) %></td>
                        <td class="l"><%# H(Eval("Gross")) %></td>
                        <td class="c"><%# H(Eval("IncMonth")) %></td>
                        <td class="r"><%# H(Eval("IncAmount")) %></td>
                        <td class="l rm"><%# H(Eval("Remarks")) %></td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>

</asp:Panel>

</form>
</body>
</html>
