<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PriceQuotationPrintItemsWise.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.PriceQuotationPrintItemsWise" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Price Quotation - Print</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            font-size: 13px;
            color: #000;
            margin: 0;
            padding: 20px;
        }
        .report-container {
            max-width: 900px;
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
        }
        .company-header .sub {
            font-size: 12px;
            color: #333;
        }
        .report-title {
            text-align: center;
            font-weight: bold;
            font-size: 16px;
            text-decoration: underline;
            margin: 15px 0;
        }
        .info-table {
            width: 100%;
            margin-bottom: 15px;
            border-collapse: collapse;
        }
        .info-table td {
            padding: 3px 6px;
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
        .summary-table {
            width: 300px;
            margin-left: auto;
            margin-top: 10px;
            border-collapse: collapse;
        }
        .summary-table td {
            padding: 5px 8px;
            border: 1px solid #000;
        }
        .summary-table .label {
            font-weight: bold;
            background: #f1f1f1;
        }
        .signature-row {
            display: flex;
            justify-content: space-between;
            margin-top: 60px;
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
        .group-header td {
            background: #dfe6ec;
            font-weight: bold;
            padding: 6px 8px;
            border: 1px solid #000;
        }
        .group-subtotal td {
            background: #f7f7f7;
            font-weight: bold;
            border: 1px solid #000;
            padding: 6px 8px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- Screen-only controls, hidden automatically when printing -->
        <div class="print-toolbar">
            <button type="button" onclick="window.print();">🖨 Print</button>
            <button type="button" onclick="window.close();">Close</button>
        </div>

        <div class="report-container">

            <div class="company-header">
                <h2>Your Company Name Ltd.</h2>
                <div class="sub">Address Line, City, Country &nbsp;|&nbsp; Phone: 000-0000000 &nbsp;|&nbsp; Email: info@company.com</div>
            </div>

            <div class="report-title">PRICE QUOTATION</div>

            <table class="info-table">
                <tr>
                    <td class="info-label">Quotation No</td>
                    <td><asp:Label ID="lblQuotationCode" runat="server" /></td>
                    <td class="info-label">Date</td>
                    <td><asp:Label ID="lblCreateDate" runat="server" /></td>
                </tr>
                <tr>
                    <td class="info-label">Customer</td>
                    <td><asp:Label ID="lblCustomer" runat="server" /></td>
                    <td class="info-label">Status</td>
                    <td><asp:Label ID="lblStatus" runat="server" /></td>
                </tr>
                <tr>
                    <td class="info-label">Quotation Name</td>
                    <td colspan="3"><asp:Label ID="lblQuotationName" runat="server" /></td>
                </tr>
            </table>

            <asp:GridView ID="gvPrintDetails" runat="server" CssClass="detail-table" AutoGenerateColumns="False"
                GridLines="None" EmptyDataText="কোনো আইটেম পাওয়া যায়নি।">
                <Columns>
                    <asp:BoundField DataField="SlNo" HeaderText="Sl" ItemStyle-CssClass="center" />
                    <asp:BoundField DataField="ItemName" HeaderText="Item Name" />
                    <asp:BoundField DataField="ItemTotalCost" HeaderText="Total Cost" ItemStyle-CssClass="num" DataFormatString="{0:0.00}" />
                </Columns>
            </asp:GridView>

            <table class="summary-table">
                <tr>
                    <td class="label">Total Cost</td>
                    <td style="text-align:right;"><asp:Label ID="lblTotalCostSum" runat="server" /></td>
                </tr>
                <tr>
                    <td class="label">Others Cost</td>
                    <td style="text-align:right;"><asp:Label ID="lblOthersCost" runat="server" /></td>
                </tr>
                <tr>
                    <td class="label">Grand Total</td>
                    <td style="text-align:right; font-weight:bold;"><asp:Label ID="lblGTotalCost" runat="server" /></td>
                </tr>
            </table>

            <div class="signature-row">
                <div class="signature-box">Prepared By</div>
                <div class="signature-box">Checked By</div>
                <div class="signature-box">Approved By</div>
            </div>

        </div>
    </form>
</body>
</html>