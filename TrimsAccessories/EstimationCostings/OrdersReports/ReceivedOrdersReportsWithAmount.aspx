<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReceivedOrdersReportsWithAmount.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports.ReceivedOrdersReportsWithAmount" %>

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

            var rcvNoLbl = document.getElementById('<%= lblWORcvNo.ClientID %>');
            var rcvNoText = rcvNoLbl ? rcvNoLbl.innerText.trim() : 'Report';
            if (!rcvNoText) rcvNoText = 'WorkOrder_Receive';

            const options = {
                margin: 4,
                filename: 'WorkOrder_Receive_' + rcvNoText + '.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'Landscape' }
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
                'body { font-family: \'Arial Narrow\', Arial, sans-serif; font-size: 11px; color: #000000; }' +
                '.company-header { position: relative; border-bottom: 2px solid #2980b9; padding-bottom: 4px; margin-bottom: 6px; min-height: 50px; }' +
                '.branch-logo { position: absolute; left: 0; top: 0; max-height: 45px; max-width: 120px; object-fit: contain; }' +
                '.header-text { text-align: center; width: 100%; }' +
                '.company-header h2 { margin: 0 0 2px 0; color: #000000; font-size: 18px; text-transform: uppercase; }' +
                '.company-header .sub { font-size: 11px; color: #000000; line-height: 1.3; }' +
                '.report-title { text-align: center; font-weight: bold; font-size: 13px; letter-spacing: 0.5px; text-transform: uppercase; margin: 4px 0 6px 0; color: #000000; background: #f8f9fa; padding: 3px; border-top: 1px solid #e9ecef; border-bottom: 1px solid #e9ecef; }' +
                '.info-table { width: 100%; margin-bottom: 6px; border-collapse: collapse; background: #f8f9fa; border: 1px solid #e9ecef; }' +
                '.info-table td { padding: 4px 8px; vertical-align: top; font-size: 11px; color: #000000; }' +
                '.info-label { font-weight: bold; width: 130px; color: #000000; }' +
                '.group-header { background: #e2e8f0; font-weight: bold; padding: 4px 6px; margin-top: 6px; font-size: 11px; border: 1px solid #cbd5e1; color: #000000; }' +
                'table.detail-table { width: 100%; border-collapse: collapse; margin-bottom: 6px; table-layout: fixed; }' +
                'table.detail-table th, table.detail-table td { border: 1px solid #dcdde1; padding: 3px 6px; font-size: 10px; overflow: hidden; word-wrap: break-word; }' +
                'table.detail-table td { color: #000000; }' +
                'table.detail-table th { background: #34495e; color: #ffffff; text-align: center; font-weight: 600; }' +
                '.num { text-align: right; }' +
                '.center { text-align: center; }' +
                '.group-total-row td { background: #eef3f8; font-weight: bold; color: #000000; border-top: 2px solid #34495e; }' +
                '.summary-section { width: 100%; margin-top: 6px; }' +
                '.summary-section table { width: 100%; border-collapse: collapse; }' +
                '.summary-box-cell { border: 1px solid #dcdde1; padding: 6px 10px; text-align: right; width: 50%; background: #f8f9fa; }' +
                '.summary-label { font-weight: bold; font-size: 11px; color: #000000; }' +
                '.summary-value { font-size: 13px; font-weight: bold; color: #000000; margin-top: 2px; }' +
                '.amount-in-words { margin-top: 4px; text-align: right; font-size: 11px; font-style: italic; color: #000000; border: 1px solid #dcdde1; padding: 4px 8px; background: #f8f9fa; }' +
                '.signature-table { width: 100%; margin-top: 25px; border-collapse: collapse; }' +
                '.signature-table td { border: none; text-align: center; width: 33.33%; padding-top: 2px; font-size: 10px; color: #000000; }' +
                '.signature-line { border-top: 1px solid #7f8c8d; width: 160px; margin: 0 auto; padding-top: 3px; color: #000000; font-weight: 600; }' +
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

        // 3. Fix column widths reliably using <colgroup> — DYNAMIC / WEIGHT-BASED
        var columnWeights = {
            "SL No": 2,
            "Job No": 5,
            "Item Name": 14,
            "Item Description": 13,
            "Color Name": 10,
            "Size": 5,
            "Measurement": 8,
            "Req Qty": 5,
            "Unit": 3,
            "Rate Unit": 2,
            "Extra %": 5,
            "Total Req Qty": 8,
            "Amount": 8,
            "Remarks": 7
        };
        var DEFAULT_COLUMN_WEIGHT = 5;

        function applyFixedColumnWidths() {
            document.querySelectorAll('table.detail-table').forEach(function (table) {
                var existing = table.querySelector('colgroup[data-auto-width]');
                if (existing) existing.remove();

                var headerCells = table.querySelectorAll('thead th, tr:first-child th');
                if (!headerCells.length) return;

                var presentWeights = [];
                var totalWeight = 0;

                headerCells.forEach(function (th) {
                    var headerText = th.innerText.trim();
                    var weight = columnWeights.hasOwnProperty(headerText)
                        ? columnWeights[headerText]
                        : DEFAULT_COLUMN_WEIGHT;
                    presentWeights.push(weight);
                    totalWeight += weight;
                });

                if (totalWeight <= 0) return;

                var colgroup = document.createElement('colgroup');
                colgroup.setAttribute('data-auto-width', '1');

                presentWeights.forEach(function (w) {
                    var col = document.createElement('col');
                    var pct = (w / totalWeight) * 100;
                    col.style.width = pct.toFixed(3) + '%';
                    colgroup.appendChild(col);
                });

                table.insertBefore(colgroup, table.firstChild);
            });
        }

        window.addEventListener('DOMContentLoaded', applyFixedColumnWidths);
        window.addEventListener('load', applyFixedColumnWidths);
    </script>

    <style>
        body {
            font-family: 'Arial Narrow', Arial, sans-serif;
            font-size: 11px;
            color: #000000;
            margin: 0;
            padding: 5px;
            background-color: #f5f6fa;
        }
        .report-container {
            max-width: 1100px;
            margin: 0 auto;
            background: #fff;
            padding: 10px 15px;
            box-shadow: 0 0 10px rgba(0,0,0,0.05);
            border-radius: 4px;
        }
        
        .company-header {
            position: relative;
            border-bottom: 2px solid #2980b9;
            padding-bottom: 4px;
            margin-bottom: 6px;
            min-height: 50px;
        }
        .branch-logo {
            position: absolute;
            left: 0;
            top: 0;
            max-height: 45px;
            max-width: 120px;
            object-fit: contain;
        }
        .header-text {
            text-align: center;
            width: 100%;
        }
        .header-text h2 {
            margin: 0 0 2px 0;
            color: #000000;
            font-size: 18px;
            text-transform: uppercase;
        }
        .header-text .sub {
            font-size: 11px;
            color: #000000;
            line-height: 1.3;
        }
        .header-text .sub span {
            margin: 0 4px;
            color: #000000;
        }

        .report-title {
            text-align: center;
            font-weight: bold;
            font-size: 13px;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            margin: 4px 0 6px 0;
            color: #000000;
            background: #f8f9fa;
            padding: 3px;
            border-top: 1px solid #e9ecef;
            border-bottom: 1px solid #e9ecef;
        }
        .info-table {
            width: 100%;
            margin-bottom: 6px;
            border-collapse: collapse;
            background: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 4px;
        }
        .info-table td {
            padding: 4px 8px;
            vertical-align: top;
            font-size: 11px;
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
            padding: 4px 6px;
            margin-top: 6px;
            margin-bottom: 0px;
            font-size: 11px;
            border: 1px solid #cbd5e1;
            border-bottom: none;
            color: #000000;
        }
        
        table.detail-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 6px;
            table-layout: fixed;
        }
        table.detail-table th,
        table.detail-table td {
            border: 1px solid #dcdde1;
            padding: 3px 6px;
            font-size: 10px;
            overflow: hidden;
            word-wrap: break-word;
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

        .group-total-row td {
            background: #eef3f8;
            font-weight: bold;
            color: #000000;
            border-top: 2px solid #34495e;
        }

        .summary-section {
            width: 100%;
            margin-top: 6px;
        }
        .summary-section table {
            width: 100%;
            border-collapse: collapse;
        }
        .summary-box-cell {
            border: 1px solid #dcdde1;
            padding: 6px 10px;
            text-align: right;
            width: 50%;
            background: #f8f9fa;
        }
        .summary-label {
            font-weight: bold;
            font-size: 11px;
            color: #000000;
        }
        .summary-value {
            font-size: 13px;
            font-weight: bold;
            color: #000000;
            margin-top: 2px;
        }
        .amount-in-words {
            margin-top: 4px;
            text-align: right;
            font-size: 11px;
            font-style: italic;
            color: #000000;
            border: 1px solid #dcdde1;
            padding: 4px 8px;
            background: #f8f9fa;
        }

        .signature-table {
            width: 100%;
            margin-top: 25px;
            border-collapse: collapse;
        }
        .signature-table td {
            border: none;
            text-align: center;
            width: 33.33%;
            padding-top: 2px;
            font-size: 10px;
            color: #000000;
        }
        .signature-line {
            border-top: 1px solid #7f8c8d;
            width: 160px;
            margin: 0 auto;
            padding-top: 3px;
            color: #000000;
            font-weight: 600;
        }
        .print-toolbar {
            text-align: center;
            margin-bottom: 8px;
            background: #f1f2f6;
            padding: 6px;
            border-radius: 6px;
            max-width: 1100px;
            margin-left: auto;
            margin-right: auto;
        }
        .print-toolbar button {
            padding: 5px 14px;
            font-size: 12px;
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
            @page { size: A4 landscape; margin: 8mm; }

            thead { display: table-header-group; }
            tr { page-break-inside: avoid; }
            
            .company-header {
                display: block;
            }

            .group-header {
                page-break-after: avoid;
                page-break-inside: avoid;
            }

            table.detail-table {
                page-break-inside: auto;
            }

            .print-footer {
                position: fixed; bottom: 0; left: 0; right: 0; width: 100%;
                display: flex; justify-content: space-between; font-size: 8px;
                color: #000000; border-top: 1px solid #dcdde1; padding-top: 2px; background: #fff;
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

            <!-- 1st Part: Branch Header -->
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

            <!-- 3rd Part: Grouped Tables with fixed column widths -->
            <asp:Repeater ID="rptGroupedOrders" runat="server" OnItemDataBound="rptGroupedOrders_ItemDataBound">
                <ItemTemplate>
                    <div class="group-header">
                        Buyer: <strong><%# Eval("Buyer") %></strong> | Style: <strong><%# Eval("Style") %></strong> | PO: <strong><%# Eval("PO") %></strong>
                    </div>
                    <asp:GridView ID="gvGroupDetails" runat="server" AutoGenerateColumns="False" CssClass="detail-table"
                        GridLines="None" ShowFooter="True" OnRowDataBound="gvGroupDetails_RowDataBound">
                        <Columns>
                            <asp:BoundField DataField="RowNo" HeaderText="SL No" HeaderStyle-Width="4%" ItemStyle-Width="4%" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="JobNo" HeaderText="Job No" HeaderStyle-Width="9%" ItemStyle-Width="9%" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="ItemName" HeaderText="Item Name" HeaderStyle-Width="14%" ItemStyle-Width="14%" />
                            <asp:BoundField DataField="ItemDescription" HeaderText="Item Description" HeaderStyle-Width="13%" ItemStyle-Width="13%" />
                            <asp:BoundField DataField="ColorName" HeaderText="Color Name" HeaderStyle-Width="8%" ItemStyle-Width="8%" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="Size" HeaderText="Size" HeaderStyle-Width="5%" ItemStyle-Width="5%" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="Measurement" HeaderText="Measurement" HeaderStyle-Width="8%" ItemStyle-Width="8%" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="ReqQty" HeaderText="Req Qty" DataFormatString="{0:N2}" HeaderStyle-Width="5%" ItemStyle-Width="5%" ItemStyle-CssClass="num" />
                            <asp:BoundField DataField="UnitName" HeaderText="Unit" HeaderStyle-Width="5%" ItemStyle-Width="5%" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="RateUnitName" HeaderText="Rate Unit" HeaderStyle-Width="4%" ItemStyle-Width="4%" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="ExtraPercent" HeaderText="Extra %" DataFormatString="{0:N2}" HeaderStyle-Width="3%" ItemStyle-Width="3%" ItemStyle-CssClass="center" />
                            <asp:BoundField DataField="TotalReqQty" HeaderText="Total Req Qty" DataFormatString="{0:N2}" HeaderStyle-Width="5%" ItemStyle-Width="5%" ItemStyle-CssClass="num" />
                            <asp:BoundField DataField="TotalAmount" HeaderText="Amount" DataFormatString="{0:N2}" HeaderStyle-Width="7%" ItemStyle-Width="7%" ItemStyle-CssClass="num" />
                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" HeaderStyle-Width="5%" ItemStyle-Width="5%" />
                        </Columns>
                    </asp:GridView>
                </ItemTemplate>
            </asp:Repeater>

            <!-- 4th Part: Grand Total Section -->
            <div class="summary-section">
                <table>
                    <tr>
                        <td class="summary-box-cell">
                            <div class="summary-label">Grand Total Required Qty: <asp:Label ID="lblGrandTotalReqQty" runat="server" /></div>
                        </td>
                        <td class="summary-box-cell">
                            <div class="summary-label">Grand Total Amount: <asp:Label ID="lblGrandTotalAmount" runat="server" /></div>
                        </td>
                    </tr>
                </table>
                <div class="amount-in-words">
                    <strong>In Words:</strong> <asp:Label ID="lblGrandTotalAmountInWords" runat="server" />
                </div>
            </div>

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