<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PriceQuotationPrintItemsWise.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.PriceQuotationPrintItemsWise" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Price Quotation - Print</title>
    
   <!-- SheetJS with Style support CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

    <script>
        // 1. PDF Download
        function downloadPDF() {
            const element = document.getElementById('reportContent');
            const options = {
                margin: 10,
                filename: 'PriceQuotation.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
            };
            html2pdf().from(element).set(options).save();
        }

        // 2. Excel Download (Exact Format & Design Match)
        function downloadExcel() {
            var htmlElement = document.getElementById('reportContent');

            // এক্সেল ফাইলের জন্য সঠিক MIME Type সহ HTML টেবিল স্ট্রাকচার তৈরি
            var excelTemplate = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">' +
                '<head>' +
                '<meta http-equiv="content-type" content="text/html; charset=UTF-8">' +
                '<style>' +
                'body { font-family: Arial, sans-serif; font-size: 13px; color: #000; }' +
                '.company-header { text-align: center; border-bottom: 2px solid #000; padding-bottom: 10px; margin-bottom: 15px; }' +
                '.company-header h2 { margin: 0; }' +
                '.company-header .sub { font-size: 12px; color: #333; }' +
                '.report-title { text-align: center; font-weight: bold; font-size: 16px; text-decoration: underline; margin: 15px 0; }' +
                '.info-table { width: 100%; margin-bottom: 15px; border-collapse: collapse; }' +
                '.info-table td { padding: 4px 6px; vertical-align: top; }' +
                '.info-label { font-weight: bold; width: 130px; }' +
                'table.detail-table { width: 100%; border-collapse: collapse; margin-top: 10px; }' +
                'table.detail-table th, table.detail-table td { border: 1px solid #000; padding: 6px 8px; font-size: 12px; }' +
                'table.detail-table th { background: #e9ecef; text-align: center; }' +
                '.num { text-align: right; }' +
                '.center { text-align: center; }' +
                '.summary-table { width: 300px; margin-left: auto; margin-top: 10px; border-collapse: collapse; }' +
                '.summary-table td { padding: 5px 8px; border: 1px solid #000; }' +
                '.summary-table .label { font-weight: bold; background: #f1f1f1; }' +
                '.signature-table { width: 100%; margin-top: 60px; border-collapse: collapse; }' +
                '.signature-box { text-align: center; width: 200px; border-top: 1px solid #000; padding-top: 5px; font-size: 12px; }' +
                '</style>' +
                '</head>' +
                '<body>' + htmlElement.innerHTML + '</body>' +
                '</html>';

            // Blob ব্যবহার করে এক্সেল ফাইল (.xls) হিসেবে ডাউনলোড করানো
            var blob = new Blob(['\ufeff' + excelTemplate], {
                type: 'application/vnd.ms-excel'
            });

            var url = URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = 'PriceQuotation_' + (document.getElementById('<%= lblQuotationCode.ClientID %>') ? document.getElementById('<%= lblQuotationCode.ClientID %>').innerText : 'Report') + '.xls';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }
    </script>

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
            background: #fff;
            padding: 15px;
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
        /* Excel & PDF friendly Signature Table Structure */
        .signature-table {
            width: 100%;
            margin-top: 60px;
            border-collapse: collapse;
        }
        .signature-table td {
            border: none;
            text-align: center;
            width: 33.33%;
            padding-top: 5px;
            font-size: 12px;
        }
        .signature-line {
            border-top: 1px solid #000;
            width: 200px;
            margin: 0 auto;
            padding-top: 5px;
        }
        .print-toolbar {
            text-align: center;
            margin-bottom: 20px;
        }
        .print-toolbar button {
            padding: 8px 15px;
            font-size: 14px;
            cursor: pointer;
            margin: 0 5px;
            background-color: #f8f9fa;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .print-toolbar button:hover {
            background-color: #e2e6ea;
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

        <!-- Toolbar with Print, PDF & Excel buttons -->
        <div class="print-toolbar">
            <button type="button" onclick="window.print();">🖨 Print</button>
            <button type="button" onclick="downloadPDF();">📥 Download PDF</button>
            <button type="button" onclick="downloadExcel();">📊 Download Excel</button>
            <button type="button" onclick="window.close();">Close</button>
        </div>

        <!-- Main Report Container -->
        <div class="report-container" id="reportContent">

            <div class="company-header">
                <h2>Your Company Name Ltd.</h2>
                <div class="sub">Address Line, City, Country &nbsp;|&nbsp; Phone: 000-0000000 &nbsp;|&nbsp; Email: info@company.com</div>
            </div>

            <div class="report-title">PRICE QUOTATION</div>

            <table class="info-table">
                <tr>
                    <td class="info-label">Quotation No</td>
                    <td><asp:Label ID="lblQuotationCode" runat="server" Text="QT-2026-001" /></td>
                    <td class="info-label">Date</td>
                    <td><asp:Label ID="lblCreateDate" runat="server" Text="06-Jun-2026" /></td>
                </tr>
                <tr>
                    <td class="info-label">Customer</td>
                    <td><asp:Label ID="lblCustomer" runat="server" Text="ABC Fashion Ltd." /></td>
                    <td class="info-label">Status</td>
                    <td><asp:Label ID="lblStatus" runat="server" Text="Approved" /></td>
                </tr>
                <tr>
                    <td class="info-label">Quotation Name</td>
                    <td colspan="3"><asp:Label ID="lblQuotationName" runat="server" Text="Summer Collection Trims & Accessories" /></td>
                </tr>
            </table>

            <asp:GridView ID="gvPrintDetails" runat="server" CssClass="detail-table" AutoGenerateColumns="False"
                GridLines="None" EmptyDataText="Items Not Found">
                <Columns>
                    <asp:BoundField DataField="SlNo" HeaderText="Sl" ItemStyle-CssClass="center" />
                    <asp:BoundField DataField="ItemName" HeaderText="Item Name" />
                    <asp:BoundField DataField="ItemTotalCost" HeaderText="Total Cost" ItemStyle-CssClass="num" DataFormatString="{0:0.00}" />
                </Columns>
            </asp:GridView>

            <table class="summary-table">
                <tr>
                    <td class="label">Total Cost</td>
                    <td style="text-align:right;"><asp:Label ID="lblTotalCostSum" runat="server" Text="500.00" /></td>
                </tr>
                <tr>
                    <td class="label">Others Cost</td>
                    <td style="text-align:right;"><asp:Label ID="lblOthersCost" runat="server" Text="50.00" /></td>
                </tr>
                <tr>
                    <td class="label">Grand Total</td>
                    <td style="text-align:right; font-weight:bold;"><asp:Label ID="lblGTotalCost" runat="server" Text="550.00" /></td>
                </tr>
            </table>

            <!-- Excel & PDF Compatible Signature Section -->
            <table class="signature-table">
                <tr>
                    <td>
                        <div class="signature-line">Prepared By</div>
                    </td>
                    <td>
                        <div class="signature-line">Checked By</div>
                    </td>
                    <td>
                        <div class="signature-line">Approved By</div>
                    </td>
                </tr>
            </table>

        </div>
    </form>
</body>
</html>