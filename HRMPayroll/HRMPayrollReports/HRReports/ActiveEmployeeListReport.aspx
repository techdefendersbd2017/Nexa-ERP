<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ActiveEmployeeListReport.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports.ActiveEmployeeListReport" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Active Employee List</title>
<style>
@page{size:A4;margin:10mm 10mm 10mm 10mm}
*{box-sizing:border-box}
body{font-family:Arial,Helvetica,sans-serif;font-size:8pt;color:#000;margin:0}

.head{position:relative;text-align:center;padding-bottom:2mm;border-bottom:1.2px solid #000}
.head .logo{position:absolute;left:0;top:0;max-height:14mm;max-width:30mm}
.head .co{font-size:14pt;font-weight:700;line-height:1.3}
.head .ttl{font-size:9pt;margin-top:1mm}

table.t{border-collapse:collapse;width:100%;margin-top:2mm;table-layout:fixed}
table.t th,table.t td{border:1px solid #000;padding:1mm 1.1mm;vertical-align:top;font-size:8pt;word-wrap:break-word}
table.t th{font-weight:400;text-align:center;vertical-align:middle;height:6mm}
table.t thead{display:table-header-group}
table.t tr{page-break-inside:avoid}

/* header cell (holds logo + company + report title) — no border, no padding */
table.t td.headCell{border:0;padding:0 0 2mm 0}
table.t thead tr.headRow{page-break-inside:avoid;page-break-after:avoid}

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
    <button type="button" onclick="window.print()">Print</button>
    <asp:LinkButton ID="btnPdf" runat="server" OnClick="btnPdf_Click">Download PDF</asp:LinkButton>
    <asp:LinkButton ID="btnWord" runat="server" OnClick="btnWord_Click">Download Word</asp:LinkButton>
    <asp:LinkButton ID="btnExcel" runat="server" OnClick="btnExcel_Click">Download Excel</asp:LinkButton>
</div>

<asp:Label ID="lblNone" runat="server" CssClass="msg" Visible="false" />

<asp:Panel ID="pnlReport" runat="server" CssClass="sheet">

    <table class="t">
        <colgroup>
            <col style="width:5%" /><col style="width:7%" /><col style="width:19%" /><col style="width:14%" />
            <col style="width:12%" /><col style="width:15%" /><col style="width:12%" /><col style="width:5%" /><col style="width:11%" />
        </colgroup>

        <thead>
            <!-- এই row প্রিন্টের প্রতি পেজে repeat হবে -->
            <tr class="headRow">
                <td class="headCell" colspan="9">
                    <div class="head">
                        <asp:Literal ID="litLogo" runat="server" />
                        <div class="co"><asp:Label ID="lblCompany" runat="server" /></div>
                        <div class="ttl">Active Employee List</div>
                    </div>
                </td>
            </tr>
            <!-- কলাম হেডারও প্রতি পেজে repeat হবে -->
            <tr>
                <th>Sl</th><th>ID No</th><th>Name</th><th>Designation</th><th>Joining Date</th>
                <th>Department</th><th>Section</th><th>Line</th><th>Gross Salary</th>
            </tr>
        </thead>

        <tbody>
            <asp:Repeater ID="rptRows" runat="server">
                <ItemTemplate>
                    <asp:PlaceHolder runat="server" Visible='<%# Convert.ToString(Eval("GroupHead")) != "" %>'>
                        <tr class="grpRow">
                            <td class="grp" colspan="8">Department : <%# H(Eval("GroupHead")) %></td>
                        </tr>
                    </asp:PlaceHolder>
                    <tr>
                        <td class="c"><%# H(Eval("Sl")) %></td>
                        <td class="r"><%# H(Eval("IdNo")) %></td>
                        <td><%# H(Eval("Name")) %></td>
                        <td><%# H(Eval("Designation")) %></td>
                        <td><%# H(Eval("JoinDate")) %></td>
                        <td><%# H(Eval("Department")) %></td>
                        <td><%# H(Eval("Section")) %></td>
                        <td><%# H(Eval("Line")) %></td>
                        <td class="r"><%# H(Eval("Gross")) %></td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>

</asp:Panel>

</form>
</body>
</html>