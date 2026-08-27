<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BillInvoiceReport.aspx.cs" Inherits="Nexa_ERP.Shipment.ShipmentReports.BillInvoiceReport" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <title>Bill / Invoice Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            font-size: 11pt;
            color: #000;
            background-color: #fff;
            margin: 0;
            padding: 20px;
        }
        .header-container { width: 100%; margin-bottom: 20px; }
        .header-left { float: left; width: 60%; }
        .header-right { float: right; width: 35%; text-align: right; }
        .clearfix::after { content: ""; clear: both; display: table; }
        .company-name { font-weight: bold; font-size: 13pt; margin-bottom: 3px; }
        .company-address { font-size: 10pt; line-height: 1.4; }
        .bill-title { font-size: 14pt; font-weight: bold; margin-bottom: 5px; }
        .bill-date { font-size: 10pt; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 9.5pt; }
        th, td { border: 1px solid #000; padding: 6px 8px; vertical-align: middle; }
        th { background-color: #f2f2f2; text-align: center; font-weight: bold; }
        .text-center { text-align: center; }
        .text-right { text-align: right; }
        .text-left { text-align: left; }
        .total-row td { font-weight: bold; background-color: #f9f9f9; }
        .amount-in-words { margin-top: 15px; font-weight: bold; text-align: center; font-size: 10.5pt; }
        .signature-section { margin-top: 60px; width: 100%; }
        .signature-box { width: 200px; border-top: 1px solid #000; text-align: center; padding-top: 5px; font-weight: bold; }

        .no-print { margin-bottom: 15px; }
        @media print {
            .no-print { display: none !important; }
            body { padding: 0; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <div class="no-print">
            <asp:Button ID="btnPrint" runat="server" Text="Print" CssClass="btn btn-success"
                OnClientClick="window.print(); return false;" />
        </div>

        <div class="header-container clearfix">
            <div class="header-left">
                <div style="font-weight: bold; font-size: 11pt; margin-bottom: 5px;">To</div>
                <asp:Literal ID="litCompanyName" runat="server" />
                <div class="company-address">
                    <asp:Literal ID="litCompanyAddress" runat="server" />
                </div>
            </div>
            <div class="header-right">
                <div class="bill-title">
                    Bill No.: <asp:Literal ID="litInvoiceNo" runat="server" />
                </div>
                <div class="bill-date">
                    Date: <asp:Literal ID="litBillDate" runat="server" />
                </div>
            </div>
        </div>

        <table>
            <thead>
                <tr>
                    <th>SL</th>
                    <th>Challan No</th>
                    <th>Date</th>
                    <th>WO Ref No</th>
                    <th>Amount</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptItems" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td class="text-center"><%# Container.ItemIndex + 1 %></td>
                            <td class="text-center"><%# Eval("DeliveryChallanNumber") %></td>
                            <td class="text-center"><%# Eval("DeliveryChallanDate") %></td>
                            <td class="text-center"><%# Eval("RefWorkOrderNo") %></td>
                            <td class="text-right"><%# Eval("ChallanAmount", "{0:0.00}") %></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
                <tr class="total-row">
                    <td colspan="4" class="text-right">SUB TOTAL</td>
                    <td class="text-right"><asp:Literal ID="litSubTotal" runat="server" /></td>
                </tr>
                <tr class="total-row">
                    <td colspan="4" class="text-right">TRANSPORT COST</td>
                    <td class="text-right"><asp:Literal ID="litTransport" runat="server" /></td>
                </tr>
                <tr class="total-row">
                    <td colspan="4" class="text-right">VAT (<asp:Literal ID="litVatPercent" runat="server" />%)</td>
                    <td class="text-right"><asp:Literal ID="litVatAmount" runat="server" /></td>
                </tr>
                <tr class="total-row">
                    <td colspan="4" class="text-right">GRAND TOTAL</td>
                    <td class="text-right"><asp:Literal ID="litGrandTotal" runat="server" /></td>
                </tr>
            </tbody>
        </table>

        <div class="amount-in-words">
            <asp:Literal ID="litAmountInWords" runat="server" />
        </div>

        <div class="signature-section">
            <div class="signature-box">Manager</div>
        </div>

    </form>
</body>
</html>