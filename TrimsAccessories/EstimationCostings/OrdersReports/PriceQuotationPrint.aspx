<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PriceQuotationPrint.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.PriceQuotationPrint" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Price Quotation - Print</title>
    
    <!-- SheetJS & html2pdf CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

    <script>
        // 1. PDF Download using html2pdf
        function downloadPDF() {
            const element = document.getElementById('reportContent');
            const options = {
                margin: 10,
                filename: 'PriceQuotation_' + (document.getElementById('<%= lblQuotationCode.ClientID %>') ? document.getElementById('<%= lblQuotationCode.ClientID %>').innerText : 'Report') + '.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
            };
            html2pdf().from(element).set(options).save();
        }

        // 2. Excel Download (Exact Format & Design Match)
        function downloadExcel() {
            var htmlElement = document.getElementById('reportContent');

            var excelTemplate = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">' +
                '<head>' +
                '<meta http-equiv="content-type" content="text/html; charset=UTF-8">' +
                '<style>' +
                'body { font-family: \'Segoe UI\', Arial, sans-serif; font-size: 13px; color: #2c3e50; }' +
                '.company-header { text-align: center; border-bottom: 2px solid #2980b9; padding-bottom: 15px; margin-bottom: 25px; }' +
                '.company-header h2 { margin: 0 0 8px 0; color: #2c3e50; font-size: 24px; text-transform: uppercase; }' +
                '.company-header .sub { font-size: 13px; color: #7f8c8d; line-height: 1.6; }' +
                '.report-title { text-align: center; font-weight: bold; font-size: 18px; letter-spacing: 1px; text-transform: uppercase; margin: 15px 0 25px 0; color: #2c3e50; background: #f8f9fa; padding: 8px; border-top: 1px solid #e9ecef; border-bottom: 1px solid #e9ecef; }' +
                '.info-table { width: 100%; margin-bottom: 25px; border-collapse: collapse; background: #f8f9fa; border: 1px solid #e9ecef; }' +
                '.info-table td { padding: 10px 15px; vertical-align: top; font-size: 13px; }' +
                '.info-label { font-weight: bold; width: 140px; color: #34495e; }' +
                'table.detail-table { width: 100%; border-collapse: collapse; margin-top: 10px; }' +
                'table.detail-table th, table.detail-table td { border: 1px solid #dcdde1; padding: 8px 10px; font-size: 12px; }' +
                'table.detail-table th { background: #34495e; color: #ffffff; text-align: center; font-weight: 600; }' +
                '.num { text-align: right; }' +
                '.center { text-align: center; }' +
                '.summary-table { width: 320px; margin-left: auto; margin-top: 20px; border-collapse: collapse; }' +
                '.summary-table td { padding: 8px 12px; border: 1px solid #dcdde1; font-size: 13px; }' +
                '.summary-table .label { font-weight: bold; background: #f1f2f6; color: #2c3e50; }' +
                '.signature-row { display: flex; justify-content: space-between; margin-top: 70px; }' +
                '.signature-box { text-align: center; width: 200px; border-top: 1px solid #7f8c8d; padding-top: 8px; font-size: 12px; color: #34495e; font-weight: 600; }' +
                '</style>' +
                '</head>' +
                '<body>' + htmlElement.innerHTML + '</body>' +
                '</html>';

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
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 13px;
            color: #2c3e50;
            margin: 0;
            padding: 20px;
            background-color: #f5f6fa;
        }
        .report-container {
            max-width: 900px;
            margin: 0 auto;
            background: #fff;
            padding: 30px;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
            border-radius: 6px;
        }
        .company-header {
            text-align: center;
            border-bottom: 2px solid #2980b9;
            padding-bottom: 15px;
            margin-bottom: 25px;
        }
        .company-header h2 {
            margin: 0 0 8px 0;
            color: #2c3e50;
            font-size: 24px;
            text-transform: uppercase;
        }
        .company-header .sub {
            font-size: 13px;
            color: #7f8c8d;
            line-height: 1.6;
        }
        .company-header .sub span {
            margin: 0 5px;
        }
        .report-title {
            text-align: center;
            font-weight: bold;
            font-size: 18px;
            letter-spacing: 1px;
            text-transform: uppercase;
            margin: 15px 0 25px 0;
            color: #2c3e50;
            background: #f8f9fa;
            padding: 8px;
            border-top: 1px solid #e9ecef;
            border-bottom: 1px solid #e9ecef;
        }
        .info-table {
            width: 100%;
            margin-bottom: 25px;
            border-collapse: collapse;
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
        }
        .info-table td {
            padding: 10px 15px;
            vertical-align: top;
            font-size: 13px;
        }
        .info-label {
            font-weight: bold;
            width: 140px;
            color: #34495e;
        }
        table.detail-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        table.detail-table th,
        table.detail-table td {
            border: 1px solid #dcdde1;
            padding: 8px 10px;
            font-size: 12px;
        }
        table.detail-table th {
            background: #34495e;
            color: #ffffff;
            text-align: center;
            font-weight: 600;
        }
        .num {
            text-align: right;
        }
        .center {
            text-align: center;
        }
        .summary-table {
            width: 320px;
            margin-left: auto;
            margin-top: 20px;
            border-collapse: collapse;
        }
        .summary-table td {
            padding: 8px 12px;
            border: 1px solid #dcdde1;
            font-size: 13px;
        }
        .summary-table .label {
            font-weight: bold;
            background: #f1f2f6;
            color: #2c3e50;
        }
        .signature-row {
            display: flex;
            justify-content: space-between;
            margin-top: 70px;
        }
        .signature-box {
            text-align: center;
            width: 200px;
            border-top: 1px solid #7f8c8d;
            padding-top: 8px;
            font-size: 12px;
            color: #34495e;
            font-weight: 600;
        }
        .print-toolbar {
            text-align: center;
            margin-bottom: 20px;
            background: #f1f2f6;
            padding: 12px;
            border-radius: 6px;
        }
        .print-toolbar button {
            padding: 8px 22px;
            font-size: 14px;
            cursor: pointer;
            margin: 0 5px;
            background: #3498db;
            color: white;
            border: none;
            border-radius: 4px;
            font-weight: 600;
        }
        .print-toolbar button:hover {
            background: #2980b9;
        }
        .group-header td {
            background: #e4ebf0 !important;
            font-weight: bold;
            color: #2c3e50;
            padding: 8px 10px;
            border: 1px solid #dcdde1;
        }
        .group-subtotal td {
            background: #f8f9fa !important;
            font-weight: bold;
            color: #2c3e50;
            border: 1px solid #dcdde1;
            padding: 8px 10px;
        }
        .print-footer {
            display: none;
        }
        @media print {
            .print-toolbar {
                display: none;
            }
            body {
                padding: 0;
                background: #fff;
            }
            .report-container {
                padding: 0;
                box-shadow: none;
            }
            @page {
                size: A4;
                margin: 15mm;
            }
            .print-footer {
                position: fixed;
                bottom: 0;
                width: 100%;
                display: flex;
                justify-content: space-between;
                font-size: 10px;
                color: #7f8c8d;
                border-top: 1px solid #dcdde1;
                padding-top: 5px;
            }
            .page-number:after {
                content: "Page " counter(page) " of " counter(pages);
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <div class="print-toolbar">
            <button type="button" onclick="window.print();">🖨 Print</button>
            <button type="button" onclick="downloadPDF();">📥 Download PDF</button>
            <button type="button" onclick="downloadExcel();">📊 Download Excel</button>
            <button type="button" onclick="window.close();">Close</button>
        </div>

        <div class="report-container" id="reportContent">

            <div class="company-header">
                <h2><asp:Label ID="lblBranchName" runat="server"></asp:Label></h2>
                <div class="sub">
                    <asp:Label ID="lblAddress" runat="server"></asp:Label><br />
                    <asp:Label ID="Label1" runat="server" Text="Phone: "></asp:Label><asp:Label ID="lblPhone" runat="server"></asp:Label> 
                    <span>|</span>
                    <asp:Label ID="Label2" runat="server" Text="E-Mail: "></asp:Label><asp:Label ID="lblEmail" runat="server"></asp:Label>
                </div>
            </div>

            <div class="report-title">Price Quotation</div>

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
                GridLines="None" EmptyDataText="কোনো আইটেম পাওয়া যায়নি।"
                OnRowDataBound="gvPrintDetails_RowDataBound">
                <Columns>
                    <asp:BoundField DataField="SlNo" HeaderText="Sl" ItemStyle-CssClass="center" />
                    <asp:BoundField DataField="RawMaterialName" HeaderText="Raw Material" />
                    <asp:BoundField DataField="ReqQty" HeaderText="Qty" ItemStyle-CssClass="num" />
                    <asp:BoundField DataField="Unit" HeaderText="Unit" ItemStyle-CssClass="center" />
                    <asp:BoundField DataField="UnitPrice" HeaderText="Unit Price" ItemStyle-CssClass="num" />
                    <asp:BoundField DataField="Currency" HeaderText="Ccy" ItemStyle-CssClass="center" />
                    <asp:BoundField DataField="Loss" HeaderText="Loss%" ItemStyle-CssClass="center" />
                    <asp:BoundField DataField="TotalCost" HeaderText="Total Cost" ItemStyle-CssClass="num" />
                    <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
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
                    <td style="text-align:right; font-weight:bold; color:#2c3e50;"><asp:Label ID="lblGTotalCost" runat="server" /></td>
                </tr>
            </table>

            <div class="signature-row">
                <div class="signature-box">Prepared By</div>
                <div class="signature-box">Checked By</div>
                <div class="signature-box">Approved By</div>
            </div>

            <!-- Developer Info & Page Numbering for Print -->
            <div class="print-footer">
                <div class="developer-info">
                    <asp:Label ID="lblDeveloperInfo" runat="server" />
                </div>
                <div class="page-number"></div>
            </div>

        </div>
    </form>
</body>
</html>