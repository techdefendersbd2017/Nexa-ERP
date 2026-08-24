<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeliveryChallanWiseBill.aspx.cs" Inherits="Nexa_ERP.Shipment.ShipmentReports.DeliveryChallanWiseBill" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Commercial Bill</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />

    <%-- tailwind link --%>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

    <!-- PDF & Excel export libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>

    <script>
// 1. PDF Download — ব্রাউজারে যেভাবে দেখাচ্ছে, হুবহু সেভাবেই PDF হবে
function downloadPDF() {
    const element = document.getElementById('<%= pnlPrintArea.ClientID %>');

            var challanLbl = document.getElementById('<%= lblChallanNo.ClientID %>');
            var challanText = challanLbl ? challanLbl.innerText.trim() : 'Bill';
            if (!challanText) challanText = 'CommercialBill';
            challanText = challanText.replace(/[\/\\]/g, '_');

            const options = {
                margin: 6,
                filename: 'CommercialBill_' + challanText + '.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
            };
            html2pdf().from(element).set(options).save();
        }

        // 2. Excel Download
        function downloadExcel() {
            var htmlElement = document.getElementById('<%= pnlPrintArea.ClientID %>');

            var excelTemplate = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/TR/REC-html40">' +
                '<head>' +
                '<meta http-equiv="content-type" content="text/html; charset=UTF-8">' +
                '<style>' +
                'body { font-family: Arial, sans-serif; font-size: 11px; color: #000000; }' +
                '.header-title { font-size: 16px; font-weight: bold; color: #000000; }' +
                '.info-box { border: 1px solid #dbe6f2; padding: 6px 10px; background: #f1f5fa; }' +
                '.info-title { font-weight: bold; color: #000000; }' +
                '.table-custom { width: 100%; border-collapse: collapse; }' +
                '.table-custom th { background: #2e7d32; color: #ffffff; padding: 4px; text-align: center; }' +
                '.table-custom td { border: 1px solid #dcdde1; padding: 4px; color: #000000; }' +
                '.totals-table td { padding: 3px 6px; color: #000000; }' +
                '.grand-total td { font-weight: bold; border-top: 2px solid #000000; }' +
                '.amount-words { font-style: italic; color: #000000; }' +
                '.sig-table td { text-align: center; font-size: 10px; color: #000000; }' +
                '.sig-line { border-top: 1px solid #7f8c8d; }' +
                '</style>' +
                '</head>' +
                '<body>' + htmlElement.innerHTML + '</body>' +
                '</html>';

            var blob = new Blob(['\ufeff' + excelTemplate], {
                type: 'application/vnd.ms-excel'
            });

            var challanLbl = document.getElementById('<%= lblChallanNo.ClientID %>');
            var fileChallan = challanLbl ? challanLbl.innerText.trim() : 'Bill';
            fileChallan = fileChallan ? fileChallan.replace(/[\/\\]/g, '_') : 'Bill';

            var url = URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = 'CommercialBill_' + fileChallan + '.xls';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }
    </script>

    <style>
        body {
            background-color: #f8fafc;
            font-size: 13px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .print-container {
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            max-width: 900px;
            margin: 10px auto;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }

        .header-title {
            color: #1f4e78;
            font-weight: bold;
            font-size: 22px;
        }

        .challan-badge {
            color: #2e7d32;
            font-weight: bold;
            font-size: 18px;
            text-align: right;
        }

        .info-box {
            background: #f1f5fa;
            border: 1px solid #dbe6f2;
            border-radius: 6px;
            padding: 12px 15px;
            margin-bottom: 15px;
        }

        .info-title {
            font-weight: bold;
            color: #2e7d32;
            border-bottom: 1px solid #cbd5e1;
            padding-bottom: 4px;
            margin-bottom: 8px;
            font-size: 12px;
            text-transform: uppercase;
        }

        .table-custom {
            width: 100%;
            table-layout: fixed;
            border-collapse: collapse;
            margin-bottom: 15px;
        }

            .table-custom th {
                background-color: #2e7d32;
                color: #fff;
                font-size: 12px;
                padding: 7px;
                text-align: center;
            }

            .table-custom td {
                border: 1px solid #cbd5e1;
                padding: 7px;
                font-size: 12px;
                vertical-align: middle;
                word-wrap: break-word;
            }

        /* ---- totals: flex-এর বদলে table (Excel export-এও ভালোভাবে বসে) ---- */
        .totals-table {
            width: 320px;
            margin-left: auto;
            border-collapse: collapse;
            background: #f1f5fa;
            border: 1px solid #dbe6f2;
            border-radius: 6px;
        }

            .totals-table td {
                padding: 5px 12px;
                font-size: 13px;
            }

            .totals-table td:last-child {
                text-align: right;
            }

            .totals-table .grand-total td {
                border-top: 1px solid #64748b;
                font-weight: bold;
                color: #2e7d32;
                font-size: 14px;
            }

        .amount-words {
            font-style: italic;
            font-size: 12px;
            margin: 10px 0;
        }

        .sig-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 60px;
        }

            .sig-table td {
                text-align: center;
                padding: 0 10px;
                width: 25%;
                vertical-align: bottom;
            }

            .sig-table .sig-name {
                display: block;
                min-height: 20px;
                font-size: 12px;
                margin-bottom: 4px;
            }

            .sig-table .sig-line {
                border-top: 1px solid #64748b;
                margin-bottom: 4px;
            }

            .sig-table .sig-label {
                font-size: 12px;
                font-weight: bold;
            }

        .print-toolbar {
            text-align: center;
            margin-bottom: 8px;
        }
        .print-toolbar button {
            padding: 6px 16px;
            font-size: 13px;
            cursor: pointer;
            margin: 0 4px;
            border: none;
            border-radius: 4px;
            font-weight: 600;
            color: #fff;
        }
        .btn-print { background: #198754; }
        .btn-pdf { background: #dc3545; }
        .btn-excel { background: #0d6efd; }

        @media print {
            @page {
                size: A4 portrait;
                margin: 8mm;
            }

            body {
                background: #fff;
            }

            .print-container {
                box-shadow: none;
                padding: 0;
                max-width: 100%;
                width: 100%;
            }

            .no-print {
                display: none !important;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container no-print print-toolbar" style="max-width: 900px; margin: 20px auto;">
            <button type="button" class="btn-print" onclick="window.print();">🖨 Print</button>
            <button type="button" class="btn-pdf" onclick="downloadPDF();">📥 Download PDF</button>
            <button type="button" class="btn-excel" onclick="downloadExcel();">📊 Download Excel</button>
        </div>

        <asp:Panel ID="pnlPrintArea" runat="server" CssClass="print-container">
            <!-- Header Section -->
            <div class="row align-items-center mb-3">
                <div class="col-8">
                    <div class="header-title">
                        <asp:Label ID="lblCompanyName" runat="server" Text="Nexa ERP"></asp:Label>
                    </div>
                    <small class="text-muted">
                        <asp:Label ID="lblCompanyAddress" runat="server"></asp:Label>
                        <br />
                        <asp:Label ID="lblCompanyPhone" runat="server"></asp:Label>
                        <asp:Label ID="lblCompanyEmail" runat="server"></asp:Label>
                    </small>
                </div>
                <div class="col-4 text-end">
                    <div class="challan-badge">COMMERCIAL BILL</div>
                    <small class="fw-bold text-secondary">Bill / Tax Invoice</small>
                </div>
            </div>

            <!-- Billed To & Bill Reference -->
            <div class="row g-2 mb-3">
                <div class="col-6">
                    <div class="info-box">
                        <div class="info-title">Billed To</div>
                        <div class="mb-1">
                            <b>Customer Name:</b>
                            <asp:Label ID="lblCustomerName" runat="server"></asp:Label>
                        </div>
                        <div class="mb-1">
                            <b>Billing Address:</b>
                            <asp:Label ID="lblBillingAddress" runat="server"></asp:Label>
                        </div>
                        <div>
                            <b>BIN / VAT Reg No:</b>
                            <asp:Label ID="lblBinVatNo" runat="server"></asp:Label>
                        </div>
                    </div>
                </div>
                <div class="col-6">
                    <div class="info-box">
                        <div class="info-title">Bill / Invoice Reference</div>
                        <div class="mb-1">
                            <b>Bill No:</b>
                            <asp:Label ID="lblBillNo" runat="server"></asp:Label>
                        </div>
                        <div class="mb-1">
                            <b>Bill Date:</b>
                            <asp:Label ID="lblBillDate" runat="server"></asp:Label>
                        </div>
                        <div class="mb-1">
                            <b>Challan Ref:</b>
                            <asp:Label ID="lblChallanNo" runat="server"></asp:Label>
                        </div>
                        <div>
                            <b>Work Order Ref:</b>
                            <asp:Label ID="lblWoNo" runat="server"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Bill Items Grid -->
            <asp:GridView ID="gvBillItems" runat="server" AutoGenerateColumns="False" CssClass="table-custom" GridLines="None">
                <HeaderStyle CssClass="table-custom th" />
                <Columns>
                    <asp:TemplateField HeaderText="SL">
                        <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        <ItemStyle HorizontalAlign="Center" Width="4%" />
                    </asp:TemplateField>
                    <asp:BoundField DataField="ItemName" HeaderText="Item &amp; Description" ItemStyle-Width="17%" />
                    <asp:TemplateField HeaderText="Buyer &amp; Style">
                        <ItemTemplate><%# Eval("BuyerName") %> / <%# Eval("StyleName") %></ItemTemplate>
                        <ItemStyle Width="13%" />
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Color / Size">
                        <ItemTemplate><%# Eval("ColorName") %> / <%# Eval("SizeName") %></ItemTemplate>
                        <ItemStyle HorizontalAlign="Center" Width="10%" />
                    </asp:TemplateField>
                    <asp:BoundField DataField="DeliveryQuantity" HeaderText="Delivered Qty" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="9%" DataFormatString="{0:N0}" />
                    <asp:BoundField DataField="ItemUnit" HeaderText="Unit" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="5%" />
                    <asp:BoundField DataField="UnitRateAmount" HeaderText="Unit Rate" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="8%" DataFormatString="{0:N3}" />
                    <asp:BoundField DataField="RateUnitName" HeaderText="Currency" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="7%" />
                    <asp:BoundField DataField="ExtraPercentage" HeaderText="Extra %" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="5%" DataFormatString="{0:N0}%" />
                    <asp:BoundField DataField="TotalAmount" HeaderText="Total Amount" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="10%" DataFormatString="{0:N2}" />
                </Columns>
            </asp:GridView>

            <!-- Totals (table-based) -->
            <table class="totals-table mb-3">
                <tr><td>Items Sub Total:</td><td><asp:Label ID="lblItemsSubTotal" runat="server"></asp:Label></td></tr>
                <tr><td>Transport Cost:</td><td><asp:Label ID="lblTransportCost" runat="server"></asp:Label></td></tr>
                <tr><td>VAT / Tax:</td><td><asp:Label ID="lblVatAmount" runat="server"></asp:Label></td></tr>
                <tr class="grand-total"><td>Grand Total Amount:</td><td><asp:Label ID="lblGrandTotal" runat="server"></asp:Label></td></tr>
            </table>

            <!-- Amount in Words -->
            <div class="amount-words">
                <b>In Words:</b> <asp:Label ID="lblAmountInWords" runat="server"></asp:Label>
            </div>

            <div class="row mb-4">
                <div class="col-12">
                    <b>Payment Terms:</b> <asp:Label ID="lblPaymentTerms" runat="server" Text="30 Days Net from Delivery Date."></asp:Label>
                </div>
            </div>

            <!-- Signatures -->
            <table class="sig-table">
                <tr>
                    <td>
                        <asp:Label ID="lblAccountsOfficer" runat="server" CssClass="sig-name"></asp:Label>
                        <div class="sig-line"></div>
                        <span class="sig-label">Accounts Officer</span>
                    </td>
                    <td>
                        <asp:Label ID="lblCheckedBy" runat="server" CssClass="sig-name"></asp:Label>
                        <div class="sig-line"></div>
                        <span class="sig-label">Checked By</span>
                    </td>
                    <td>
                        <asp:Label ID="lblManagerDGM" runat="server" CssClass="sig-name"></asp:Label>
                        <div class="sig-line"></div>
                        <span class="sig-label">Manager / DGM</span>
                    </td>
                    <td>
                        <asp:Label ID="lblCustomerAuthSign" runat="server" CssClass="sig-name"></asp:Label>
                        <div class="sig-line"></div>
                        <span class="sig-label">Customer Authorized Sign</span>
                    </td>
                </tr>
            </table>
        </asp:Panel>
    </form>
</body>
</html>