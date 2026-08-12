<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RawMaterialReports.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports.RawMaterialReports" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Raw Material Requirement Report</title>
    
    <!-- html2pdf CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

    <script>
// PDF Download Function
function downloadPDF() {
    const element = document.getElementById('reportContent');
    const options = {
        margin: 5,
        filename: 'RawMaterial_Requirement_Report.pdf',
        image: { type: 'jpeg', quality: 0.98 },
        html2canvas: { scale: 2, useCORS: true },
        jsPDF: { unit: 'mm', format: 'a4', orientation: 'landscape' }
    };
    html2pdf().from(element).set(options).save();
        }
    </script>

    <style>
        * { box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 13px;
            color: #1f2937;
            margin: 0;
            padding: 24px;
            background-color: #eef1f4;
        }

        .report-container {
            max-width: 1050px;
            margin: 0 auto;
            background: #fff;
            padding: 30px 34px;
            box-shadow: 0 1px 6px rgba(0,0,0,0.12);
            border-radius: 4px;
        }

        /* Company Header */
        .company-header {
            text-align: center;
            border-bottom: 3px solid #1e3a5f;
            padding-bottom: 12px;
            margin-bottom: 6px;
        }
        .company-header h2 {
            margin: 0;
            font-size: 23px;
            letter-spacing: 0.5px;
            color: #1e3a5f;
        }
        .company-header .sub {
            font-size: 12px;
            color: #4b5563;
            margin-top: 4px;
        }

        .report-title {
            text-align: center;
            font-weight: 700;
            font-size: 16px;
            letter-spacing: 1px;
            margin: 16px 0 18px 0;
            color: #1e3a5f;
            text-transform: uppercase;
        }
        .report-title::after {
            content: "";
            display: block;
            width: 70px;
            height: 3px;
            background: #c9a24b;
            margin: 6px auto 0 auto;
        }

        /* Work Order Info */
        .info-table {
            width: 100%;
            margin-bottom: 18px;
            border-collapse: collapse;
            background: #f8f9fb;
            border: 1px solid #e2e5e9;
            border-radius: 4px;
        }
        .info-table td {
            padding: 8px 12px;
            vertical-align: top;
            font-size: 13px;
        }
        .info-label {
            font-weight: 600;
            color: #374151;
            width: 150px;
        }
        .info-value {
            color: #111827;
        }
        .item-highlight {
            background: #eef3fa;
        }
        .item-highlight .info-value {
            font-weight: 700;
            color: #1e3a5f;
        }

        /* Detail Table (GridView) */
        table.detail-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 6px;
        }
        table.detail-table th,
        table.detail-table td {
            border: 1px solid #d7dbe0;
            padding: 7px 9px;
            font-size: 12px;
        }
        table.detail-table th {
            background: #1e3a5f;
            color: #fff;
            text-align: center;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 11px;
            letter-spacing: 0.3px;
        }
        table.detail-table tbody tr:nth-child(even) {
            background-color: #f7f9fb;
        }
        .num { text-align: right; }
        .center { text-align: center; }

        .materials-total-cell {
            text-align: right;
            font-weight: 700;
            background: #eef3fa !important;
            color: #1e3a5f !important;
        }

        /* Cost Summary Box */
        .summary-wrap {
            display: flex;
            justify-content: flex-end;
            margin-top: 18px;
        }
        .summary-box {
            width: 320px;
            border: 1px solid #d7dbe0;
            border-radius: 4px;
            overflow: hidden;
        }
        .summary-box .row {
            display: flex;
            justify-content: space-between;
            padding: 8px 14px;
            font-size: 13px;
            border-bottom: 1px solid #e5e7eb;
            background: #fff;
        }
        .summary-box .row .label {
            color: #4b5563;
        }
        .summary-box .row .value {
            font-weight: 600;
            color: #111827;
        }
        .summary-box .grand {
            background: #1e3a5f;
        }
        .summary-box .grand .label,
        .summary-box .grand .value {
            color: #fff;
            font-size: 14px;
            font-weight: 700;
        }

        .signature-row {
            display: flex;
            justify-content: space-between;
            margin-top: 80px;
        }
        .signature-box {
            text-align: center;
            width: 200px;
            border-top: 1px solid #000;
            padding-top: 6px;
            font-size: 12px;
            color: #374151;
        }

        .print-toolbar {
            text-align: center;
            margin-bottom: 20px;
            background: #f1f2f6;
            padding: 12px;
            border-radius: 6px;
            max-width: 1050px;
            margin-left: auto;
            margin-right: auto;
        }
        .print-toolbar button {
            padding: 9px 22px;
            font-size: 14px;
            cursor: pointer;
            margin: 0 5px;
            border: none;
            border-radius: 4px;
            background: #1e3a5f;
            color: #fff;
            font-weight: 600;
        }
        .print-toolbar button:last-child {
            background: #6b7280;
        }
        .print-toolbar button:hover {
            opacity: 0.9;
        }

        @media print {
            .print-toolbar { display: none; }
            body { padding: 0; background: #fff; }
            .report-container { box-shadow: none; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <!-- Print & Download Controls -->
        <div class="print-toolbar">
            <button type="button" onclick="window.print();">🖨 Print Report</button>
            <button type="button" onclick="downloadPDF();">📥 Download PDF</button>
            <button type="button" onclick="window.close();">Close</button>
        </div>

        <div class="report-container" id="reportContent">

            <!-- Company Dynamic Header -->
            <div class="company-header">
                <h2><asp:Label ID="lblBranchName" runat="server" Text="Branch Name Ltd." /></h2>
                <div class="sub">
                    <asp:Label ID="lblAddress" runat="server" Text="Address Line, City" /> &nbsp;|&nbsp;
                    Phone: <asp:Label ID="lblPhone" runat="server" Text="000-0000000" /> &nbsp;|&nbsp;
                    Web: <asp:Label ID="lblWeb" runat="server" Text="www.domain.com" />
                </div>
            </div>

            <div class="report-title">Raw Material Requirement Report</div>

            <!-- Work Order / Style Information -->
            <table class="info-table">
                <tr>
                    <td class="info-label">Work Order No:</td>
                    <td class="info-value">: <asp:Label ID="lblWorkOrderNo" runat="server" /></td>
                    <td class="info-label">WO Date:</td>
                    <td class="info-value">: <asp:Label ID="lblWORcvDate" runat="server" /></td>
                </tr>
                <tr>
                    <td class="info-label">Delivery Date:</td>
                    <td class="info-value">: <asp:Label ID="lblDeliveryDate" runat="server" /></td>
                    <td class="info-label">Buyer:</td>
                    <td class="info-value">: <asp:Label ID="lblBuyer" runat="server" /></td>
                </tr>
                <tr>
                    <td class="info-label">Style:</td>
                    <td class="info-value">: <asp:Label ID="lblStyle" runat="server" /></td>
                    <td class="info-label">Order No:</td>
                    <td class="info-value">: <asp:Label ID="lblOrderNo" runat="server" /></td>
                </tr>
                <tr class="item-highlight">
                    <td class="info-label">Finished Goods Item:</td>
                    <td class="info-value" colspan="3">: <asp:Label ID="lblItemName" runat="server" /></td>
                </tr>
            </table>

            <!-- Raw Material Details -->
            <asp:GridView ID="gvRawMaterialReport" runat="server" AutoGenerateColumns="False"
                ShowFooter="true" OnRowDataBound="gvRawMaterialReport_RowDataBound"
                CssClass="detail-table" GridLines="None">
                <Columns>
                    <asp:BoundField DataField="SlNo" HeaderText="SL" ItemStyle-CssClass="center" ItemStyle-Width="35px" />
                    <asp:BoundField DataField="RawMaterialName" HeaderText="Raw Material Name" />
                    <asp:BoundField DataField="ReqQty" HeaderText="Req Qty" ItemStyle-CssClass="num" DataFormatString="{0:0.00}" />
                    <asp:BoundField DataField="UnitName" HeaderText="Unit" ItemStyle-CssClass="center" />
                    <asp:BoundField DataField="UnitPrice" HeaderText="Unit Price" ItemStyle-CssClass="num" DataFormatString="{0:0.00}" />
                    <asp:BoundField DataField="Currency" HeaderText="Currency" ItemStyle-CssClass="center" />
                    <asp:BoundField DataField="Loss" HeaderText="Loss %" ItemStyle-CssClass="num" DataFormatString="{0:0.00}" />
                    <asp:TemplateField HeaderText="Total Cost">
                        <ItemTemplate>
                            <asp:Label ID="lblTotalCost" runat="server" Text='<%# Eval("TotalCost", "{0:N2}") %>'></asp:Label>
                        </ItemTemplate>
                        <ItemStyle CssClass="num" />
                        <FooterStyle CssClass="materials-total-cell" />
                        <FooterTemplate>
                            <asp:Label ID="lblMaterialsTotal" runat="server" Font-Bold="true"></asp:Label>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                </Columns>
            </asp:GridView>

            <!-- Cost Summary -->
            <div class="summary-wrap">
                <div class="summary-box">
                    <div class="row">
                        <span class="label">Sub Total</span>
                        <span class="value"><asp:Label ID="lblSubTotal" runat="server" /></span>
                    </div>
                    <div class="row">
                        <span class="label">Transport Cost</span>
                        <span class="value"><asp:Label ID="lblTransportCost" runat="server" /></span>
                    </div>
                    <div class="row">
                        <span class="label">VAT %</span>
                        <span class="value"><asp:Label ID="lblVatPercent" runat="server" /></span>
                    </div>
                    <div class="row grand">
                        <span class="label">Grand Total</span>
                        <span class="value"><asp:Label ID="lblGrandTotal" runat="server" /></span>
                    </div>
                </div>
            </div>

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