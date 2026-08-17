<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReceivedOrdersReports.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports.ReceivedOrdersReports" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Work Order Receive Report</title>
    
    <!-- SheetJS & html2pdf CDN -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

    <script>
        // 1. PDF Download
        function downloadPDF() {
            const element = document.getElementById('reportContent');

            // Get Receive No safely for filename
            var rcvNoLbl = document.getElementById('<%= lblWORcvNo.ClientID %>');
            var rcvNoText = rcvNoLbl ? rcvNoLbl.innerText.trim() : 'Report';
            if (!rcvNoText) rcvNoText = 'WorkOrder_Receive';

            const options = {
                margin: 5,
                filename: 'WorkOrder_Receive_' + rcvNoText + '.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'Portrait' }
            };
            html2pdf().from(element).set(options).save();
        }

        // 2. Excel Download
        function downloadExcel() {
            var htmlElement = document.getElementById('reportContent');

            var excelTemplate = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">' +
                '<head>' +
                '<meta http-equiv="content-type" content="text/html; charset=UTF-8">' +
                '<style>' +
                'body { font-family: \'Segoe UI\', Arial, sans-serif; font-size: 12px; color: #000000; }' +
                '.company-header { position: relative; border-bottom: 2px solid #2980b9; padding-bottom: 8px; margin-bottom: 12px; min-height: 65px; }' +
                '.branch-logo { position: absolute; left: 0; top: 0; max-height: 60px; max-width: 140px; object-fit: contain; }' +
                '.header-text { text-align: center; width: 100%; }' +
                '.company-header h2 { margin: 0 0 4px 0; color: #000000; font-size: 20px; text-transform: uppercase; }' +
                '.company-header .sub { font-size: 12px; color: #000000; line-height: 1.4; }' +
                '.report-title { text-align: center; font-weight: bold; font-size: 15px; letter-spacing: 0.5px; text-transform: uppercase; margin: 8px 0 12px 0; color: #000000; background: #f8f9fa; padding: 5px; border-top: 1px solid #e9ecef; border-bottom: 1px solid #e9ecef; }' +
                '.info-table { width: 100%; margin-bottom: 12px; border-collapse: collapse; background: #f8f9fa; border: 1px solid #e9ecef; }' +
                '.info-table td { padding: 6px 10px; vertical-align: top; font-size: 12px; color: #000000; }' +
                '.info-label { font-weight: bold; width: 130px; color: #000000; }' +
                '.group-header { background: #e2e8f0; font-weight: bold; padding: 6px 8px; margin-top: 10px; font-size: 12px; border: 1px solid #cbd5e1; color: #000000; }' +
                'table.detail-table { width: 100%; border-collapse: collapse; margin-bottom: 10px; }' +
                'table.detail-table th, table.detail-table td { border: 1px solid #dcdde1; padding: 5px 8px; font-size: 11px; }' +
                'table.detail-table td { color: #000000; }' +
                'table.detail-table th { background: #34495e; color: #ffffff; text-align: center; font-weight: 600; }' +
                '.num { text-align: right; }' +
                '.center { text-align: center; }' +
                '.summary-table { width: 320px; margin-left: auto; margin-top: 10px; border-collapse: collapse; }' +
                '.summary-table td { padding: 6px 10px; border: 1px solid #dcdde1; font-size: 12px; color: #000000; }' +
                '.summary-table .label { font-weight: bold; background: #f1f2f6; color: #000000; }' +
                '.signature-table { width: 100%; margin-top: 40px; border-collapse: collapse; }' +
                '.signature-table td { border: none; text-align: center; width: 33.33%; padding-top: 2px; font-size: 11px; color: #000000; }' +
                '.signature-line { border-top: 1px solid #7f8c8d; width: 180px; margin: 0 auto; padding-top: 5px; color: #000000; font-weight: 600; }' +
                '</style>' +
                '</head>' +
                '<body>' + htmlElement.innerHTML + '</body>' +
                '</html>';

            var blob = new Blob(['\ufeff' + excelTemplate], {
                type: 'application/vnd.ms-excel'
            });

            var rcvNoLbl = document.getElementById('<%= lblWORcvNo.ClientID %>');
            var fileRcvNo = rcvNoLbl ? rcvNoLbl.innerText.trim() : 'Report';
            fileRcvNo = fileRcvNo ? fileRcvNo.replace(/[\/\\]/g, '_') : 'Report';

            var url = URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = 'WorkOrder_Receive_Report_' + fileRcvNo + '.xls';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }
    </script>

    <style>
        body {
            font-family: 'Segoe UI', Arial, sans-serif;
            font-size: 12px;
            color: #000000;
            margin: 0;
            padding: 10px;
            background-color: #f5f6fa;
        }
        .report-container {
            max-width: 1100px;
            margin: 0 auto;
            background: #fff;
            padding: 15px 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
            border-radius: 4px;
        }
        
        /* Company Header Layout: Logo on absolute left, Text centered */
        .company-header {
            position: relative;
            border-bottom: 2px solid #2980b9;
            padding-bottom: 8px;
            margin-bottom: 12px;
            min-height: 65px;
        }
        .branch-logo {
            position: absolute;
            left: 0;
            top: 0;
            max-height: 60px;
            max-width: 140px;
            object-fit: contain;
        }
        .header-text {
            text-align: center;
            width: 100%;
        }
        .header-text h2 {
            margin: 0 0 4px 0;
            color: #000000;
            font-size: 20px;
            text-transform: uppercase;
        }
        .header-text .sub {
            font-size: 12px;
            color: #000000;
            line-height: 1.4;
        }
        .header-text .sub span {
            margin: 0 5px;
            color: #000000;
        }

        .report-title {
            text-align: center;
            font-weight: bold;
            font-size: 15px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            margin: 8px 0 12px 0;
            color: #000000;
            background: #f8f9fa;
            padding: 5px;
            border-top: 1px solid #e9ecef;
            border-bottom: 1px solid #e9ecef;
        }
        .info-table {
            width: 100%;
            margin-bottom: 12px;
            border-collapse: collapse;
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
        }
        .info-table td {
            padding: 6px 10px;
            vertical-align: top;
            font-size: 12px;
            color: #000000;
        }
        .info-label {
            font-weight: bold;
            width: 130px;
            color: #000000;
        }
        .group-header {
            background: #f1f5f9;
            font-weight: bold;
            padding: 6px 10px;
            margin-top: 12px;
            margin-bottom: 0px;
            font-size: 12px;
            border: 1px solid #cbd5e1;
            border-bottom: none;
            color: #000000;
        }
        table.detail-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 10px;
        }
        table.detail-table th,
        table.detail-table td {
            border: 1px solid #dcdde1;
            padding: 5px 8px;
            font-size: 11px;
        }
        table.detail-table td {
            color: #000000;
        }
        table.detail-table th {
            background: #34495e;
            color: #ffffff;
            text-align: center;
            font-weight: 600;
        }
        .num { text-align: right; }
        .center { text-align: center; }
        
        .summary-table {
            width: 320px;
            margin-left: auto;
            margin-top: 10px;
            border-collapse: collapse;
        }
        .summary-table td {
            padding: 6px 10px;
            border: 1px solid #dcdde1;
            font-size: 12px;
            color: #000000;
        }
        .summary-table .label {
            font-weight: bold;
            background: #f1f2f6;
            color: #000000;
        }
        .signature-table {
            width: 100%;
            margin-top: 45px;
            border-collapse: collapse;
        }
        .signature-table td {
            border: none;
            text-align: center;
            width: 33.33%;
            padding-top: 2px;
            font-size: 11px;
            color: #000000;
        }
        .signature-line {
            border-top: 1px solid #7f8c8d;
            width: 180px;
            margin: 0 auto;
            padding-top: 5px;
            color: #000000;
            font-weight: 600;
        }
        .print-toolbar {
            text-align: center;
            margin-bottom: 12px;
            background: #f1f2f6;
            padding: 8px;
            border-radius: 6px;
            max-width: 1100px;
            margin-left: auto;
            margin-right: auto;
        }
        .print-toolbar button {
            padding: 6px 16px;
            font-size: 13px;
            cursor: pointer;
            margin: 0 4px;
            background: #3498db;
            color: white;
            border: none;
            border-radius: 4px;
            font-weight: 600;
        }
        .print-toolbar button:hover {
            background: #2980b9;
        }
        .print-footer {
            display: none;
        }
        @media print {
            .print-toolbar { display: none; }
            body { padding: 0; background: #fff; }
            .report-container { padding: 0; box-shadow: none; max-width: 100%; }
            @page { size: A4 landscape; margin: 10mm; }
            .print-footer {
                position: fixed; bottom: 0; left: 0; right: 0; width: 100%;
                display: flex; justify-content: space-between; font-size: 9px;
                color: #000000; border-top: 1px solid #dcdde1; padding-top: 3px; background: #fff;
            }
            .page-number:after { content: "Page " counter(page) " of " counter(pages); }
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

            <!-- 1st Part: Branch Header with Logo on Absolute Left & Centered Text -->
            <div class="company-header">
                <asp:Image ID="imgBranchLogo" runat="server" CssClass="branch-logo" Visible="false" AlternateText="Logo" />
                <div class="header-text">
                    <h2><asp:Label ID="lblBranchName" runat="server"></asp:Label></h2>
                    <div class="sub">
                        <asp:Label ID="lblBranchAddress" runat="server"></asp:Label><br />
                        <asp:Label ID="Label1" runat="server" Text="Phone: "></asp:Label><asp:Label ID="lblBranchPhone" runat="server"></asp:Label> 
                        <span>|</span>
                        <asp:Label ID="Label2" runat="server" Text="E-Mail: "></asp:Label><asp:Label ID="lblBranchEmail" runat="server"></asp:Label>
                        <span>|</span>
                        <asp:Label ID="Label3" runat="server" Text="Web: "></asp:Label><asp:Label ID="lblBranchWeb" runat="server"></asp:Label>
                    </div>
                </div>
            </div>

            <div class="report-title">Work Order Receive Report</div>

            <!-- 2nd Part: Meta Information Table -->
            <table class="info-table">
                <tr>
                    <td class="info-label">Receive No</td>
                    <td><asp:Label ID="lblWORcvNo" runat="server" /></td>
                    <td class="info-label">Customer Name</td>
                    <td><asp:Label ID="lblPartyName" runat="server" /></td>
                </tr>
                <tr>
                    <td class="info-label">Receive Date</td>
                    <td><asp:Label ID="lblWORcvDate" runat="server" /></td>
                    <td class="info-label">Ref Work Order No</td>
                    <td><asp:Label ID="lblRefWorkOrderNo" runat="server" /></td>
                </tr>
                <tr>
                    <td class="info-label">Delivery Date</td>
                    <td><asp:Label ID="lblDeliveryDate" runat="server" /></td>
                    <td class="info-label"></td>
                    <td></td>
                </tr>
            </table>

            <!-- 3rd Part: Grouped Tables (Buyer, Style, PO wise) -->
            <asp:Repeater ID="rptGroupedOrders" runat="server" OnItemDataBound="rptGroupedOrders_ItemDataBound">
                <ItemTemplate>
                    <div class="group-header">
                        Buyer: <strong><%# Eval("Buyer") %></strong> | Style: <strong><%# Eval("Style") %></strong> | PO: <strong><%# Eval("PO") %></strong>
                    </div>
                    <asp:GridView ID="gvGroupDetails" runat="server" AutoGenerateColumns="False" CssClass="detail-table" 
                        GridLines="None" OnRowDataBound="gvGroupDetails_RowDataBound">
                        <Columns>
                            <asp:BoundField DataField="RowNo" HeaderText="SL No" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="ItemName" HeaderText="Item Name" />
                            <asp:BoundField DataField="ItemDescription" HeaderText="Item Description" />
                            <asp:BoundField DataField="ColorName" HeaderText="Color Name" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="Size" HeaderText="Size" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="Measurement" HeaderText="Measurement" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="ReqQty" HeaderText="Req Qty" DataFormatString="{0:N2}" ItemStyle-CssClass="num" />
                            <asp:BoundField DataField="Unit" HeaderText="Unit" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="ExtraPercent" HeaderText="Extra %" DataFormatString="{0:N2}" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="TotalReqQty" HeaderText="Total Req Qty" DataFormatString="{0:N2}" ItemStyle-CssClass="num" />
                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                        </Columns>
                    </asp:GridView>
                </ItemTemplate>
            </asp:Repeater>

            <!-- 4th Part: Grand Total Section -->
            <table class="summary-table">
                <tr>
                    <td class="label">Grand Total Req Qty</td>
                    <td style="text-align:right; font-weight:bold; color:#000000;">
                        <asp:Label ID="lblGrandTotalReqQty" runat="server" />
                    </td>
                </tr>
            </table>

            <!-- Signatures -->
            <table class="signature-table">
                <tr>
                    <td><div class="signature-line">Prepared By</div></td>
                    <td><div class="signature-line">Checked By</div></td>
                    <td><div class="signature-line">Authorized Signature</div></td>
                </tr>
            </table>

            <!-- Print Footer -->
            <div class="print-footer">
                <div class="developer-info">
                    <asp:Label ID="lblDeveloperInfo" runat="server" Text="Developed by: Nexa ERP" />
                </div>
                <div class="page-number"></div>
            </div>

        </div>
    </form>
</body>
</html>