<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RawMaterialReports.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports.RawMaterialReports" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Raw Material Requirement Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            font-size: 13px;
            color: #000;
            margin: 0;
            padding: 20px;
        }
        .report-container {
            max-width: 1000px;
            margin: 0 auto;
        }
        .company-header {
            text-align: center;
            border-bottom: 2px solid #000;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        .company-header h2 {
            margin: 0;
            font-size: 22px;
        }
        .company-header .sub {
            font-size: 12px;
            color: #333;
            margin-top: 4px;
        }
        .report-title {
            text-align: center;
            font-weight: bold;
            font-size: 16px;
            text-decoration: underline;
            margin: 15px 0;
            letter-spacing: 0.5px;
        }
        .info-table {
            width: 100%;
            margin-bottom: 15px;
            border-collapse: collapse;
        }
        .info-table td {
            padding: 4px 6px;
            vertical-align: top;
        }
        .info-label {
            font-weight: bold;
            width: 130px;
        }
        table.detail-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        table.detail-table th,
        table.detail-table td {
            border: 1px solid #000;
            padding: 6px 8px;
            font-size: 12px;
        }
        table.detail-table th {
            background: #e9ecef;
            text-align: center;
        }
        .num {
            text-align: right;
        }
        .center {
            text-align: center;
        }
        .signature-row {
            display: flex;
            justify-content: space-between;
            margin-top: 70px;
        }
        .signature-box {
            text-align: center;
            width: 200px;
            border-top: 1px solid #000;
            padding-top: 5px;
            font-size: 12px;
        }
        .print-toolbar {
            text-align: center;
            margin-bottom: 20px;
        }
        .print-toolbar button {
            padding: 8px 20px;
            font-size: 14px;
            cursor: pointer;
            margin: 0 5px;
        }
        @media print {
            .print-toolbar {
                display: none;
            }
            body {
                padding: 0;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- Print & Close Controls -->
        <div class="print-toolbar">
            <button type="button" onclick="window.print();">🖨 Print Report</button>
            <button type="button" onclick="window.close();">Close</button>
        </div>

        <div class="report-container">

            <!-- Company Dynamic Header (From vw_Branch_Information) -->
            <div class="company-header">
                <h2><asp:Label ID="lblBranchName" runat="server" Text="Branch Name Ltd." /></h2>
                <div class="sub">
                    <asp:Label ID="lblAddress" runat="server" Text="Address Line, City" /> &nbsp;|&nbsp; 
                    Phone: <asp:Label ID="lblPhone" runat="server" Text="000-0000000" /> &nbsp;|&nbsp; 
                    Web: <asp:Label ID="lblWeb" runat="server" Text="www.domain.com" />
                </div>
            </div>

            <div class="report-title">RAW MATERIAL REQUIREMENT REPORT</div>

            <!-- Master Information (Work Order & Delivery Details) -->
            <table class="info-table">
                <tr>
                    <td class="info-label">Work Order No:</td>
                    <td>: <asp:Label ID="lblWorkOrderNo" runat="server" /></td>
                    <td class="info-label">WO Receive Date</td>
                    <td>: <asp:Label ID="lblWORcvDate" runat="server" /></td>
                </tr>
                <tr>
                    <td class="info-label">Delivery Date</td>
                    <td>: <asp:Label ID="lblDeliveryDate" runat="server" /></td>
                    <td class="info-label">Status / Info</td>
                    <td>: <asp:Label ID="lblExtraInfo" runat="server" /></td>
                </tr>
            </table>

            <!-- Details GridView based on SQL Query Fields -->
            <asp:GridView ID="gvRawMaterialReport" runat="server" AutoGenerateColumns="False" 
                ShowFooter="true" OnRowDataBound="gvRawMaterialReport_RowDataBound">
                <Columns>
                    <asp:BoundField DataField="SlNo" HeaderText="SL" ItemStyle-CssClass="center" />
                    <asp:BoundField DataField="ItemsName" HeaderText="Finished Goods Item" />
                    <asp:BoundField DataField="RawMaterialName" HeaderText="Raw Material Name" />
                    <asp:BoundField DataField="ReqQty" HeaderText="Req Qty" ItemStyle-CssClass="num" DataFormatString="{0:0.00}" />
                    <asp:BoundField DataField="UnitName" HeaderText="Unit" ItemStyle-CssClass="center" />
                    <asp:BoundField DataField="UnitPrice" HeaderText="Unit Price" ItemStyle-CssClass="num" DataFormatString="{0:0.00}" />
                    <asp:BoundField DataField="Currency" HeaderText="Currency" ItemStyle-CssClass="center" />
                    <asp:TemplateField HeaderText="Total Cost">
                        <ItemTemplate>
                            <asp:Label ID="lblTotalCost" runat="server" Text='<%# Eval("TotalCost", "{0:N2}") %>'></asp:Label>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:Label ID="lblGrandTotal" runat="server" Font-Bold="true"></asp:Label>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                </Columns>
            </asp:GridView>

            <!-- Signatures -->
            <div class="signature-row">
                <div class="signature-box">Prepared By</div>
                <div class="signature-box">Checked By</div>
                <div class="signature-box">Approved By</div>
            </div>

        </div>
    </form>
</body>
</html>