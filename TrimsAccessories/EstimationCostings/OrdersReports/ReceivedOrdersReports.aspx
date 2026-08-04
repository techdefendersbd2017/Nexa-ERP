<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReceivedOrdersReports.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports.ReceivedOrdersReports" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Work Order Receive Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            font-size: 13px;
            color: #333;
            margin: 0;
            padding: 20px;
            background: #f8f9fa;
        }
        .action-bar {
            max-width: 1100px;
            margin: 0 auto 15px auto;
            text-align: right;
        }
        .btn {
            padding: 8px 15px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            border: none;
            border-radius: 4px;
            margin-left: 5px;
            color: #fff;
        }
        .btn-print { background-color: #17a2b8; }
        .btn-download { background-color: #28a745; }
        .btn:hover { opacity: 0.9; }

        .invoice-box {
            max-width: 1100px;
            margin: auto;
            padding: 25px;
            border: 1px solid #eee;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.15);
            background: #fff;
        }
        .header-table, .details-table {
            width: 100%;
            border-collapse: collapse;
        }
        .header-table td {
            padding: 5px;
            vertical-align: top;
        }
        .company-info {
            text-align: right;
        }
        .title {
            font-size: 22px;
            font-weight: bold;
            color: #444;
            text-transform: uppercase;
            margin-bottom: 10px;
        }
        .section-title {
            font-weight: bold;
            background: #f2f2f2;
            padding: 8px;
            margin-top: 15px;
            margin-bottom: 10px;
            border-left: 4px solid #007bff;
        }
        .details-table th, .details-table td {
            border: 1px solid #ddd;
            padding: 6px 8px;
            text-align: left;
        }
        .details-table th {
            background-color: #f8f9fa;
            color: #333;
            font-size: 12px;
        }
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .subtotal-row {
            background-color: #e9ecef;
            font-weight: bold;
        }
        
        .signature-section {
            margin-top: 50px;
            width: 100%;
        }
        .signature-section td {
            width: 33%;
            text-align: center;
            vertical-align: bottom;
            padding-top: 40px;
        }
        .signature-line {
            border-top: 1px solid #333;
            display: inline-block;
            width: 80%;
            padding-top: 5px;
            font-weight: bold;
        }

        @media print {
            body { padding: 0; background: #fff; }
            .action-bar { display: none; }
            .invoice-box { border: none; box-shadow: none; padding: 0; }
        }
    </style>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <script type="text/javascript">
        function printReport() { window.print(); }
        function downloadPDF() {
            const element = document.querySelector('.invoice-box');
            const options = {
                margin: 5,
                filename: 'WorkOrder_Receive_Report.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'landscape' }
            };
            html2pdf().from(element).set(options).save();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div class="action-bar">
            <button type="button" class="btn btn-print" onclick="printReport()">Print</button>
            <button type="button" class="btn btn-download" onclick="downloadPDF()">Download PDF</button>
        </div>

        <div class="invoice-box">
            <!-- Header Section -->
            <table class="header-table">
                <tr>
                    <td>
                        <div class="title">Work Order Receive Report</div>
                        <div><strong>Work Order No:</strong> <asp:Label ID="lblWONo" runat="server"></asp:Label></div>
                        <div><strong>Receive Date:</strong> <asp:Label ID="lblWORcvDate" runat="server"></asp:Label></div>
                        <div><strong>Delivery Date:</strong> <asp:Label ID="lblDeliveryDate" runat="server"></asp:Label></div>
                    </td>
                    <td class="company-info">
                        <h3><asp:Label ID="lblBranchName" runat="server"></asp:Label></h3>
                        <div><asp:Label ID="lblBranchAddress" runat="server"></asp:Label></div>
                        <div>Phone: <asp:Label ID="lblBranchPhone" runat="server"></asp:Label></div>
                        <div>Email: <asp:Label ID="lblBranchEmail" runat="server"></asp:Label></div>
                    </td>
                </tr>
            </table>

            <!-- Customer & Buyer Info Section -->
            <div class="section-title">Customer & Buyer Information</div>
            <table class="header-table">
                <tr>
                    <td><strong>Customer Name:</strong> <asp:Label ID="lblPartyName" runat="server"></asp:Label></td>
                    <td><strong>Buyer:</strong> <asp:Label ID="lblBuyer" runat="server"></asp:Label></td>
                    <td><strong>Style:</strong> <asp:Label ID="lblStyle" runat="server"></asp:Label></td>
                </tr>
                <tr>
                    <td><strong>Order No:</strong> <asp:Label ID="lblOrderNo" runat="server"></asp:Label></td>
                    <td><strong>Contact Person:</strong> <asp:Label ID="lblContactPerson" runat="server"></asp:Label></td>
                    <td><strong>Phone:</strong> <asp:Label ID="lblCustomerPhone" runat="server"></asp:Label></td>
                </tr>
            </table>

            <!-- Details Table Section -->
            <div class="section-title">Itemized Order Details</div>
            <asp:GridView ID="gvOrderDetails" runat="server" AutoGenerateColumns="False" CssClass="details-table" ShowFooter="true" EmptyDataText="No item details available." OnRowDataBound="gvOrderDetails_RowDataBound">
                <Columns>
                    <asp:BoundField DataField="ItemName" HeaderText="Item Name" />
                    <asp:BoundField DataField="ColorName" HeaderText="Color Name" />
                    <asp:BoundField DataField="Size" HeaderText="Size" />
                    <asp:BoundField DataField="Measurement" HeaderText="Measurement" />
                    <asp:BoundField DataField="ReqQty" HeaderText="Required Qty" DataFormatString="{0:N2}"><ItemStyle CssClass="text-right" /></asp:BoundField>
                    <asp:BoundField DataField="Unit" HeaderText="Unit" />
                    <asp:BoundField DataField="RateUnit" HeaderText="Rate/Unit" DataFormatString="{0:N2}"><ItemStyle CssClass="text-right" /></asp:BoundField>
                    <asp:BoundField DataField="ExtraPercent" HeaderText="Extra %" DataFormatString="{0:N2}"><ItemStyle CssClass="text-right" /></asp:BoundField>
                    <asp:BoundField DataField="TotalReqQty" HeaderText="Total Req. Qty" DataFormatString="{0:N2}"><ItemStyle CssClass="text-right" /></asp:BoundField>
                    <asp:BoundField DataField="TotalAmount" HeaderText="Total Amount" DataFormatString="{0:N2}"><ItemStyle CssClass="text-right" /></asp:BoundField>
                    <asp:BoundField DataField="Remarks" HeaderText="Specification / Remarks" />
                    <asp:BoundField DataField="WoRefNoDetails" HeaderText="Price Work Order Ref." />
                    <asp:TemplateField HeaderText="Action">
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>

            <!-- Grand Total Section -->
            <table style="width: 100%; margin-top: 15px;">
                <tr>
                    <td style="text-align: right;">
                        <strong>Grand Total Amount: </strong> 
                        <asp:Label ID="lblGrandTotal" runat="server" Font-Bold="true" Font-Size="16px"></asp:Label>
                    </td>
                </tr>
            </table>

            <!-- Signature Section -->
            <table class="signature-section">
                <tr>
                    <td><span class="signature-line">Prepared By</span></td>
                    <td><span class="signature-line">Checked By</span></td>
                    <td><span class="signature-line">Authorized Signature</span></td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>