<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="eSDeliveryChallanGetpass.aspx.cs" Inherits="Nexa_ERP.Shipment.ShipmentReports.eSDeliveryChallanGetpass" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Delivery Challan</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />

    <%-- tailwind link --%>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

    <%-- barcode generator --%>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/JsBarcode/3.11.5/JsBarcode.all.min.js" onerror="window.__jsBarcodeLoadFailed = true;"></script>

    <style>
        body {
            background-color: #f8fafc;
            font-size: 13px;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #1e293b;
        }

        .print-container {
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            max-width: 900px;
            margin: 20px auto;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }

        /* ===================== Header ===================== */
        .doc-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            border-bottom: 2px solid #2e7d32;
            padding-bottom: 10px;
            margin-bottom: 4px;
        }

        .doc-header-left {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .doc-logo {
            width: 56px;
            height: 56px;
            object-fit: contain;
        }

        .company-name {
            color: #111827;
            font-weight: 800;
            font-size: 24px;
            line-height: 1.1;
        }

        .doc-title {
            color: #334155;
            font-weight: 600;
            font-size: 15px;
        }

        .doc-header-right {
            text-align: right;
        }

        .company-address-line {
            font-size: 11px;
            color: #64748b;
            margin: 6px 0 18px 0;
        }

        /* ===================== Info Boxes ===================== */
        .info-box {
            background: #f8fafc;
            border: 1px solid #dbe6f2;
            border-radius: 6px;
            padding: 10px 14px;
            margin-bottom: 12px;
        }

        .info-title {
            font-weight: bold;
            color: #2e7d32;
            border-bottom: 1px solid #cbd5e1;
            padding-bottom: 4px;
            margin-bottom: 6px;
            font-size: 11px;
            text-transform: uppercase;
        }

        .info-line {
            font-size: 12px;
            margin-bottom: 3px;
        }

        .info-line b {
            color: #334155;
        }

        .plain-box {
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            padding: 10px 14px;
            margin-bottom: 15px;
            font-size: 12px;
        }

        /* ===================== Table ===================== */
        .table-custom {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 4px;
        }

            .table-custom th {
                background-color: #2e7d32;
                color: #fff;
                font-size: 11px;
                padding: 6px 4px;
                text-align: center;
            }

            .table-custom td {
                border: 1px solid #cbd5e1;
                padding: 6px 4px;
                font-size: 11px;
                vertical-align: middle;
            }

            .table-custom tfoot td {
                border: 1px solid #cbd5e1;
                background: #f1f5fa;
                font-weight: bold;
                font-size: 11px;
                padding: 6px 4px;
            }

        /* ===================== Signatures ===================== */
        .sig-space {
            margin-top: 60px;
            text-align: center;
        }

        .sig-border {
            border-top: 1px solid #64748b;
            width: 80%;
            margin: 0 auto 4px auto;
        }

        .cert-text {
            font-size: 11px;
            color: #475569;
            text-align: center;
            margin-bottom: 50px;
        }

        .receiver-line {
            border-top: 1px solid #64748b;
            width: 100%;
            text-align: center;
            font-size: 12px;
            font-weight: bold;
            padding-top: 4px;
        }

        /* ===================== Barcode ===================== */
        .barcode-wrap {
            text-align: center;
            align-self: flex-start;
        }

        .barcode-wrap svg {
            display: block;
            max-width: 260px;
        }

        /* ===================== Gate Pass ===================== */
        .gate-pass-page {
            page-break-before: always;
            break-before: page;
        }

        .gate-pass-title {
            color: #111827;
            font-weight: 800;
            font-size: 22px;
            text-align: center;
            letter-spacing: 1px;
            margin: 10px 0 18px 0;
        }

        .gate-pass-table {
            width: 100%;
            border-collapse: collapse;
            margin: 8px 0 18px 0;
        }

            .gate-pass-table td {
                border: 1px solid #cbd5e1;
                padding: 6px 10px;
                font-size: 12px;
            }

            .gate-pass-table td.label-cell {
                background: #f1f5fa;
                font-weight: bold;
                width: 22%;
                color: #334155;
            }

        .gp-footer-note {
            text-align: center;
            font-size: 10px;
            color: #94a3b8;
            margin-top: 40px;
        }

        @media print {
            body {
                background: #fff;
            }

            .print-container {
                box-shadow: none;
                padding: 0;
                max-width: 100%;
            }

            .no-print {
                display: none !important;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container no-print text-end my-3" style="max-width: 900px;">
            <button type="button" class="btn btn-success" onclick="window.print()">
                <i class="bi bi-printer"></i>Print Delivery Challan &amp; Gate Pass
            </button>
        </div>

        <!-- ============================================================ -->
        <!-- PAGE 1: DELIVERY CHALLAN                                      -->
        <!-- ============================================================ -->
        <div class="print-container">

            <!-- Header Section -->
            <div style="width: 100%; display: flex; flex-direction: column; gap: 20px; font-family: sans-serif;">
    
                <!-- প্রথম লাইন: অ্যাড্রেস এবং বারকোড পাশাপাশি থাকবে -->
                <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
        
                    <!-- বাম পাশে লোগো এবং অ্যাড্রেস -->
                    <div style="display: flex; gap: 15px; align-items: flex-start;">
                        <asp:Image ID="imgCompanyLogo" runat="server" CssClass="doc-logo" ImageUrl="~/Images/logo.png" AlternateText="Logo not found: check Images/logo.png on the server" style="width: 70px; height: 70px; border: 1px solid #ccc; display: block;" />
                        <div>
                            <div style="font-size: 20px; font-weight: bold; color: #1a2b4c; margin-bottom: 5px; line-height: 1.2;">
                                <asp:Label ID="lblCompanyName" runat="server" Text="eS Trims Limited"></asp:Label>
                            </div>
                            <div style="font-size: 13px; color: #555; line-height: 1.4;">
                                <asp:Label ID="lblCompanyAddress" runat="server">Narayanganj, Bangladesh-1420</asp:Label>
                                <br>
                                <asp:Label ID="lblCompanyPhone" runat="server">01639572449</asp:Label>
                                |&nbsp;
                                <asp:Label ID="lblCompanyEmail" runat="server">info@estrims.com</asp:Label>
                            </div>
                        </div>
                    </div>

                    <div class="barcode-wrap">
                        <h3><asp:Label ID="lblChallanNo" runat="server" Text="CLN-000444-2026" Font-Names="Code39AzaleaWide3"></asp:Label></h3>
                        <h2><asp:Label ID="lblChallan" runat="server" Text="CLN-000444-2026"></asp:Label></h2>
                    </div>
        
                </div>

                <div style="text-align: center; width: 100%; margin-bottom: 8px;">
                    <div style="font-size: 28px; font-weight: bold; color: #1a2b4c; display: inline-block; text-decoration: underline;">
                        Delivery Challan
                                  </div>
                </div>
            </div>



            <!-- Bill To / Ship To -->
            <div class="row g-2 mb-1">
                <div class="col-6">
                    <div class="info-box">
                        <div class="info-title">Invoice Address / Bill to Party</div>
                        <div class="info-line"><b>Customer:</b> <asp:Label ID="lblCustomerName" runat="server"></asp:Label></div>
                        <div class="info-line"><b>Address:</b> <asp:Label ID="lblCustomerBillingAddress" runat="server"></asp:Label></div>
                    </div>
                    <div class="info-box">
                        <div class="info-title">Delivery Address / Ship to Party / Notify Party</div>
                        <div class="info-line"><b>Address:</b> <asp:Label ID="lblCustomerAddress" runat="server"></asp:Label></div>
                        <div class="info-line"><b>Contact Person:</b> <asp:Label ID="txtContactPerson" runat="server" Text="N/A"></asp:Label></div>
                    </div>
                    <div class="info-box">
                        <div class="info-line"><b>Delivery By:</b> <asp:Label ID="lblDeliveryBy" runat="server"></asp:Label></div>
                        <div class="info-line"><b>Box:</b> <asp:Label ID="lblBoxCount" runat="server"></asp:Label></div>
                        <div class="info-line"><b>Net Weight:</b> <asp:Label ID="lblNetWeight" runat="server"></asp:Label></div>
                        <div class="info-line"><b>Gross Weight:</b> <asp:Label ID="lblGrossWeight" runat="server"></asp:Label></div>
                    </div>
                </div>
                <div class="col-6">
                    <div class="info-box">
                        <div class="info-title">Order Reference</div>
                        <div class="info-line"><b>P.O:</b> <asp:Label ID="lblPoNo" runat="server"></asp:Label></div>
                        <div class="info-line"><b>Buyer:</b> <asp:Label ID="lblBuyerName" runat="server"></asp:Label></div>
                        <div class="info-line"><b>Work Order No:</b> <asp:Label ID="lblWoNo" runat="server"></asp:Label></div>
                        <div class="info-line"><b>PI No:</b> <asp:Label ID="lblPiNo" runat="server"></asp:Label></div>
                        <div class="info-line"><b>FSC-COC:</b> <asp:Label ID="lblFscCoc" runat="server"></asp:Label></div>
                    </div>
                    <div class="info-box">
                        <div class="info-title">Challan Reference</div>
                        <div class="info-line"><b>Challan No:</b> <asp:Label ID="lblChallanNoDisplay" runat="server" Text="CLN-000444-2026"></asp:Label></div>
                        <div class="info-line"><b>Date:</b> <asp:Label ID="lblChallanDate" runat="server"></asp:Label></div>
                        <div class="info-line"><b>Job Bag No:</b> <asp:Label ID="lblJobBagNo" runat="server"></asp:Label></div>
                        <div class="info-line"><b>Marketing:</b> <asp:Label ID="lblMarketing" runat="server"></asp:Label></div>
                        <div class="info-line"><b>CS Name:</b> <asp:Label ID="lblCsName" runat="server"></asp:Label></div>
                    </div>
                    <div class="info-box">
                        <div class="info-line"><b>Tracking No:</b> <asp:Label ID="lblTrackingNo" runat="server"></asp:Label></div>
                    </div>
                </div>
            </div>

            <!-- Challan Grid Table -->
            <asp:GridView ID="gvChallanItems" runat="server" AutoGenerateColumns="False" CssClass="table-custom" GridLines="None" ShowFooter="True">
                <HeaderStyle CssClass="table-custom th" />
                <Columns>
                    <asp:TemplateField HeaderText="SN">
                        <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        <ItemStyle HorizontalAlign="Center" Width="3%" />
                        <FooterTemplate>Total:</FooterTemplate>
                        <FooterStyle HorizontalAlign="Right" />
                    </asp:TemplateField>
                    <asp:BoundField DataField="SubCategoryName" HeaderText="Sub Category" ItemStyle-Width="7%" />
                    <asp:BoundField DataField="BookingNo" HeaderText="Booking No" ItemStyle-Width="7%" />
                    <asp:BoundField DataField="StyleName" HeaderText="Style" ItemStyle-Width="7%" />
                    <asp:BoundField DataField="JobNo" HeaderText="Job No" ItemStyle-Width="6%" />
                    <asp:BoundField DataField="PoNo" HeaderText="PO No" ItemStyle-Width="7%" />
                    <asp:BoundField DataField="ItemNo" HeaderText="Item No" ItemStyle-Width="7%" />
                    <asp:BoundField DataField="ColorName" HeaderText="Color" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="9%" />
                    <asp:BoundField DataField="SizeName" HeaderText="Size" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="5%" />
                    <asp:BoundField DataField="Measurement" HeaderText="Measurement" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="7%" />
                    <asp:BoundField DataField="ItemName" HeaderText="Item Description" ItemStyle-Width="12%" />
                    <asp:BoundField DataField="OrderQty" HeaderText="Order QTY" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="6%" DataFormatString="{0:N0}">
                        <FooterStyle HorizontalAlign="Right" />
                    </asp:BoundField>
                    <asp:BoundField DataField="PChallanQty" HeaderText="P. Challan QTY" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="6%" DataFormatString="{0:N0}">
                        <FooterStyle HorizontalAlign="Right" />
                    </asp:BoundField>
                    <asp:BoundField DataField="ChallanQty" HeaderText="Challan QTY" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="6%" DataFormatString="{0:N0}">
                        <FooterStyle HorizontalAlign="Right" />
                    </asp:BoundField>
                    <asp:BoundField DataField="BalanceQty" HeaderText="Balance QTY" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="6%" DataFormatString="{0:N0}">
                        <FooterStyle HorizontalAlign="Right" />
                    </asp:BoundField>
                    <asp:BoundField DataField="ItemUnit" HeaderText="UOM" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="4%" />
                    <asp:BoundField DataField="Remarks" HeaderText="Remarks" ItemStyle-Width="6%" />
                </Columns>
                <FooterStyle CssClass="table-custom tfoot" />
            </asp:GridView>

            <!-- Signatures for Challan -->
            <div class="row mt-5">
                <div class="col-6">
                    <div class="sig-space">
                        <asp:Label ID="lblPreparedBy" runat="server" class="d-block mb-1"></asp:Label>
                        <div class="sig-border"></div>
                        <b>Prepared By</b><br />
                        <small class="text-muted"><asp:Label ID="lblPreparedDate" runat="server"></asp:Label></small>
                    </div>
                </div>
                <div class="col-6">
                    <div class="cert-text">
                        <b>Customer / Applicant Certification</b><br />
                        Above goods are acknowledged and received in good condition of package and quantity as per challan.
                    </div>
                    <div class="receiver-line">Receiver Name &amp; Signature Date &amp; Seal</div>
                </div>
            </div>
        </div>

        <!-- ============================================================ -->
        <!-- PAGE 2: GATE PASS                                             -->
        <!-- ============================================================ -->
        <div class="print-container gate-pass-page">

        <!-- পুরো হেডার এরিয়া -->
        <div style="width: 100%; display: flex; flex-direction: column; gap: 20px; font-family: sans-serif; margin-bottom: 20px;">
    
            <!-- প্রথম লাইন: অ্যাড্রেস এবং বারকোড পাশাপাশি থাকবে -->
            <div style="display: flex; justify-content: space-between; align-items: flex-start; width: 100%;">
        
                <!-- বাম পাশে লোগো এবং অ্যাড্রেস -->
                <div style="display: flex; gap: 15px; align-items: flex-start;">
                    <asp:Image ID="imgGpLogo" runat="server" CssClass="doc-logo" ImageUrl="~/Images/logo.png" AlternateText="Logo not found: check Images/logo.png on the server" style="width: 70px; height: 70px; border: 1px solid #ccc; display: block;" />
                    <div>
                        <div style="font-size: 20px; font-weight: bold; color: #1a2b4c; margin-bottom: 5px; line-height: 1.2;">
                            <asp:Label ID="lblGpCompanyName" runat="server" Text="Nexa ERP"></asp:Label>
                        </div>
                        <div style="font-size: 13px; color: #6c757d; line-height: 1.4;">
                            <asp:Label ID="lblGpCompanyAddress" runat="server"></asp:Label>
                        </div>
                    </div>
                </div>

                <!-- ডান পাশে বারকোড (একদম ডান কোনায় থাকবে) -->

                
                    <div class="barcode-wrap">
                        <h4><asp:Label ID="lblGpNo" runat="server" Text="CLN-000444-2026" Font-Names="Code39AzaleaWide3"></asp:Label></h4>
                        <h4><asp:Label ID="lblGpNoDisplayH" runat="server"></asp:Label></h4>
                    </div>
        
            </div>

            <!-- দ্বিতীয় লাইন: গেট পাস একদম মাঝে এবং নিচে থাকবে -->
            <div style="text-align: center; width: 100%;">
                <div style="font-size: 28px; font-weight: bold; color: #1a2b4c; display: inline-block; text-decoration: underline;">
                    GATE PASS
                </div>
            </div>
        </div>

            <table class="gate-pass-table">
                <tr>
                    <td class="label-cell">Gate Pass No</td>
                    <td><asp:Label ID="lblGpNoDisplay" runat="server"></asp:Label></td>
                    <td class="label-cell">Date</td>
                    <td><asp:Label ID="lblGpDate" runat="server"></asp:Label></td>
                </tr>
                <tr>
                    <td class="label-cell">Customer</td>
                    <td><asp:Label ID="lblGpCustomerName" runat="server"></asp:Label></td>
                    <td class="label-cell">Job No</td>
                    <td><asp:Label ID="lblGpJobNo" runat="server"></asp:Label></td>
                </tr>
                <tr>
                    <td class="label-cell">Delivery Factory</td>
                    <td><asp:Label ID="lblGpDeliveryFactory" runat="server"></asp:Label></td>
                    <td class="label-cell">Buyer</td>
                    <td><asp:Label ID="lblGpBuyer" runat="server"></asp:Label></td>
                </tr>
            </table>

            <asp:GridView ID="gvGatePassItems" runat="server" AutoGenerateColumns="False" CssClass="table-custom" GridLines="None" ShowFooter="True">
                <HeaderStyle CssClass="table-custom th" />
                <Columns>
                    <asp:TemplateField HeaderText="SL">
                        <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        <ItemStyle HorizontalAlign="Center" Width="6%" />
                    </asp:TemplateField>
                    <asp:BoundField DataField="ItemName" HeaderText="Item" ItemStyle-Width="26%" />
                    <asp:BoundField DataField="ChallanNo" HeaderText="Challan No" ItemStyle-Width="22%" />
                    <asp:BoundField DataField="ChallanQty" HeaderText="Challan Qty" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="14%" DataFormatString="{0:N0}">
                        <FooterStyle HorizontalAlign="Right" />
                    </asp:BoundField>
                    <asp:BoundField DataField="ItemUnit" HeaderText="UoM" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%" />
                    <asp:BoundField DataField="Remarks" HeaderText="Remarks" ItemStyle-Width="16%" />
                </Columns>
                <FooterStyle CssClass="table-custom tfoot" />
            </asp:GridView>

            <table class="gate-pass-table mt-3">
                <tr>
                    <td class="label-cell">Delivery Man</td>
                    <td><asp:Label ID="lblGpDeliveryMan" runat="server"></asp:Label></td>
                    <td class="label-cell">Delivery Man Mobile No</td>
                    <td><asp:Label ID="lblGpDeliveryManMobile" runat="server"></asp:Label></td>
                </tr>
                <tr>
                    <td class="label-cell">Driver Name</td>
                    <td><asp:Label ID="lblGpDriverName" runat="server"></asp:Label></td>
                    <td class="label-cell">Driver Mobile No</td>
                    <td><asp:Label ID="lblGpDriverMobile" runat="server"></asp:Label></td>
                </tr>
                <tr>
                    <td class="label-cell">Vehicle No</td>
                    <td colspan="3"><asp:Label ID="lblGpVehicleNo" runat="server"></asp:Label></td>
                </tr>
            </table>

            <!-- Signatures for Gate Pass -->
            <div class="row mt-5">
                <div class="col-6">
                    <div class="sig-space">
                        <asp:Label ID="lblGpPreparedBy" runat="server" class="d-block mb-1"></asp:Label>
                        <div class="sig-border"></div>
                        <b>Prepared By</b><br />
                        <small class="text-muted"><asp:Label ID="lblGpPreparedDate" runat="server"></asp:Label></small>
                    </div>
                </div>
                <div class="col-6">
                    <div class="sig-space">
                        <asp:Label ID="lblGpDeliveredBy" runat="server" class="d-block mb-1"></asp:Label>
                        <div class="sig-border"></div>
                        <b>Delivery By</b>
                    </div>
                </div>
            </div>

            <div class="gp-footer-note">This is a computer-generated document. No signature is required.</div>
        </div>
    </form>


    <!--java Script-->
    <script type="text/javascript">
        function showBarcodeProblem(svgId, message) {
            var svg = document.getElementById(svgId);
            if (!svg) return;
            svg.outerHTML = '<div style="font-size:10px;color:#b91c1c;border:1px dashed #b91c1c;padding:4px 6px;max-width:220px;">' + message + '</div>';
        }

        document.addEventListener('DOMContentLoaded', function () {
            if (window.__jsBarcodeLoadFailed || typeof JsBarcode === 'undefined') {
                var msg = 'Barcode library did not load from CDN (cdnjs.cloudflare.com). Likely no internet access or it is blocked on this server/network.';
                console.error(msg);
                showBarcodeProblem('barcodeChallan', msg);
                showBarcodeProblem('barcodeGatePass', msg);
                return;
            }

            try {
                var challanNo = document.getElementById('<%= lblChallanNo.ClientID %>').textContent.trim();
                if (challanNo) {
                    JsBarcode("#barcodeChallan", challanNo, {
                        format: "CODE128",
                        displayValue: true,
                        fontSize: 14,
                        height: 40,
                        margin: 0
                    });
                } else {
                    showBarcodeProblem('barcodeChallan', 'Challan No is empty, so no barcode value to encode.');
                }
            } catch (e) {
                console.error('Challan barcode error:', e);
                showBarcodeProblem('barcodeChallan', 'Barcode error: ' + e.message);
            }

            try {
                var gpNo = document.getElementById('<%= lblGpNo.ClientID %>').textContent.trim();
                if (gpNo) {
                    JsBarcode("#barcodeGatePass", gpNo, {
                        format: "CODE128",
                        displayValue: true,
                        fontSize: 14,
                        height: 40,
                        margin: 0
                    });
                } else {
                    showBarcodeProblem('barcodeGatePass', 'Gate Pass No is empty, so no barcode value to encode.');
                }
            } catch (e) {
                console.error('Gate pass barcode error:', e);
                showBarcodeProblem('barcodeGatePass', 'Barcode error: ' + e.message);
            }
        });
    </script>
</body>
</html>
