<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeliveryChallan.aspx.cs" Inherits="Nexa_ERP.Shipment.ShipmentReports.DeliveryChallan" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Delivery Challan & Get Pass</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />

    <%-- tailwind link --%>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>

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
            margin: 20px auto;
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
            }

        .sig-space {
            margin-top: 60px;
            text-align: center;
        }

        .sig-border {
            border-top: 1px solid #64748b;
            width: 80%;
            margin: 0 auto 4px auto;
        }

        /* ===================== Gate Pass Styles ===================== */

        .gate-pass-page {
            /* force this whole block onto a fresh page when printed */
            page-break-before: always;
            break-before: page;
        }

        .gate-pass-wrap {
            display: flex;
            flex-direction: column;
            gap: 0;
        }

        .gate-pass-copy {
            border: 1.5px dashed #94a3b8;
            border-radius: 6px;
            padding: 14px 18px;
            position: relative;
            margin-bottom: 14px;
        }

        .gate-pass-copy:last-child {
            margin-bottom: 0;
        }

        .gate-pass-copy-label {
            position: absolute;
            top: -11px;
            right: 16px;
            background: #2e7d32;
            color: #fff;
            font-size: 10px;
            font-weight: bold;
            letter-spacing: .5px;
            text-transform: uppercase;
            padding: 2px 10px;
            border-radius: 10px;
        }

        .gate-pass-title {
            color: #1f4e78;
            font-weight: bold;
            font-size: 17px;
        }

        .gate-pass-subtitle {
            color: #2e7d32;
            font-weight: bold;
            font-size: 13px;
        }

        .gate-pass-field {
            margin-bottom: 4px;
            font-size: 12px;
        }

        .gate-pass-field b {
            color: #334155;
        }

        .gate-pass-table {
            width: 100%;
            border-collapse: collapse;
            margin: 8px 0;
        }

            .gate-pass-table td {
                border: 1px solid #cbd5e1;
                padding: 4px 8px;
                font-size: 12px;
            }

            .gate-pass-table td.label-cell {
                background: #f1f5fa;
                font-weight: bold;
                width: 30%;
            }

        .gate-pass-sig-row {
            display: flex;
            justify-content: space-between;
            margin-top: 22px;
        }

        .gate-pass-sig {
            text-align: center;
            width: 30%;
        }

        .gate-pass-sig .sig-border {
            width: 100%;
        }

        .scissor-note {
            text-align: center;
            font-size: 10px;
            color: #94a3b8;
            margin: 6px 0;
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
        <!-- PAGE 1: DELIVERY CHALLAN                                       -->
        <!-- ============================================================ -->
        <div class="print-container">
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
                    <div class="challan-badge">DELIVERY CHALLAN</div>
                    <small class="fw-bold text-secondary">Office &amp; Store Copy</small>
                </div>
            </div>

            <!-- Customer & Challan Reference Info -->
            <div class="row g-2 mb-3">
                <div class="col-6">
                    <div class="info-box">
                        <div class="info-title">Customer &amp; Delivery Details</div>
                        <div class="mb-1">
                            <b>Customer:</b>
                            <asp:Label ID="lblCustomerName" runat="server"></asp:Label>
                        </div>
                        <div class="mb-1">
                            <b>Address:</b>
                            <asp:Label ID="lblCustomerAddress" runat="server"></asp:Label>
                        </div>
                        <div class="mb-1">
                            <b>Contract Info:</b><b>Name:</b><asp:Label ID="txtContactPerson" runat="server"></asp:Label>
                            <b>Phone:</b><asp:Label ID="lblCustomerPhone" runat="server"></asp:Label>
                            <b>Email:</b><asp:Label ID="lblCustomerEmail" runat="server"></asp:Label>
                        </div>
                        <div>
                            <b>Delivery Date:</b>
                            <asp:Label ID="lblDeliveryDate" runat="server"></asp:Label>
                        </div>
                    </div>
                </div>
                <div class="col-6">
                    <div class="info-box">
                        <div class="info-title">Challan Reference</div>
                        <div class="mb-1">
                            <b>Challan No:</b>
                            <asp:Label ID="lblChallanNo" runat="server" Text="DC-2026-0001"></asp:Label>
                        </div>
                        <div class="mb-1">
                            <b>Ref Work Order No:</b>
                            <asp:Label ID="lblWoNo" runat="server"></asp:Label>
                        </div>
                        <div>
                            <b>WO Date:</b>
                            <asp:Label ID="lblWoDate" runat="server"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Challan Grid Table -->
            <asp:GridView ID="gvChallanItems" runat="server" AutoGenerateColumns="False" CssClass="table-custom" GridLines="None">
                <HeaderStyle CssClass="table-custom th" />
                <Columns>
                    <asp:TemplateField HeaderText="SL">
                        <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                        <ItemStyle HorizontalAlign="Center" Width="5%" />
                    </asp:TemplateField>
                    <asp:BoundField DataField="BuyerName" HeaderText="Buyer" ItemStyle-Width="15%" />
                    <asp:BoundField DataField="StyleName" HeaderText="Style / PO" ItemStyle-Width="15%" />
                    <asp:BoundField DataField="ItemName" HeaderText="Item Description" ItemStyle-Width="25%" />
                    <asp:BoundField DataField="ColorName" HeaderText="Color" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="12%" />
                    <asp:BoundField DataField="SizeName" HeaderText="Size" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="10%" />
                    <asp:BoundField DataField="DeliveryQuantity" HeaderText="Delivered Qty" ItemStyle-HorizontalAlign="Right" ItemStyle-Width="10%" DataFormatString="{0:N2}" />
                    <asp:BoundField DataField="ItemUnit" HeaderText="Unit" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="8%" />
                </Columns>
            </asp:GridView>



            <!-- Signatures for Challan -->
            <div class="grid grid-cols-4 gap-4 items-end mt-12">

                <!-- Prepared By -->
                <div class="flex flex-col items-center justify-end text-center h-20">
                    <asp:Label ID="lblPreparedBy" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
                    <div class="border-t border-gray-400 w-full mb-1"></div>
                    <b class="text-sm">Prepared By</b>
                </div>

                <!-- Store Officer -->
                <div class="flex flex-col items-center justify-end text-center h-20">
                    <asp:Label ID="lblStoreOfficer" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
                    <div class="border-t border-gray-400 w-full mb-1"></div>
                    <b class="text-sm">Store Officer</b>
                </div>

                <!-- Gate Pass Checked -->
                <div class="flex flex-col items-center justify-end text-center h-20">
                    <asp:Label ID="lblGatePassChecked" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
                    <div class="border-t border-gray-400 w-full mb-1"></div>
                    <b class="text-sm">Gate Pass Checked</b>
                </div>

                <!-- Receiver's Sign & Seal -->
                <div class="flex flex-col items-center justify-end text-center h-20">
                    <asp:Label ID="lblReceiverSign" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
                    <div class="border-t border-gray-400 w-full mb-1"></div>
                    <b class="text-sm whitespace-nowrap">Receiver's Sign &amp; Seal</b>
                </div>

            </div>
        </div>

        <!-- ============================================================ -->
        <!-- PAGE 2: GATE PASS (2 copies on this single page)               -->
        <!-- ============================================================ -->
        <div class="print-container gate-pass-page">
            <div class="gate-pass-wrap">

                <!-- ---------- Gate Pass Copy #1 (Security Copy) ---------- -->
                <div class="gate-pass-copy">
                    <span class="gate-pass-copy-label">Security Copy</span>
                    <div class="row align-items-center mb-2">
                        <div class="col-8">
                            <div class="gate-pass-title">
                                <asp:Label ID="lblGpCompanyName1" runat="server" Text="Nexa ERP"></asp:Label>
                            </div>
                            <small class="text-muted">
                                <asp:Label ID="lblGpCompanyAddress1" runat="server"></asp:Label>
                            </small>
                        </div>
                        <div class="col-4 text-end">
                            <div class="gate-pass-subtitle">GATE PASS</div>
                        </div>
                    </div>

                    <table class="gate-pass-table">
                        <tr>
                            <td class="label-cell">Gate Pass No</td>
                            <td><asp:Label ID="lblGpNo1" runat="server"></asp:Label></td>
                            <td class="label-cell">Date</td>
                            <td><asp:Label ID="lblGpDate1" runat="server"></asp:Label></td>
                        </tr>
                        <tr>
                            <td class="label-cell">Ref. Challan No</td>
                            <td><asp:Label ID="lblGpChallanNo1" runat="server"></asp:Label></td>
                            <td class="label-cell">Customer</td>
                            <td><asp:Label ID="lblGpCustomerName1" runat="server"></asp:Label></td>
                        </tr>
                        <tr>
                            <td class="label-cell">Vehicle No</td>
                            <td><asp:Label ID="lblGpVehicleNo1" runat="server"></asp:Label></td>
                            <td class="label-cell">Driver Name &amp; Phone</td>
                            <td><asp:Label ID="lblGpDriverInfo1" runat="server"></asp:Label></td>
                        </tr>
                        <tr>
                            <td class="label-cell">Total Line Items</td>
                            <td><asp:Label ID="lblGpTotalLines1" runat="server"></asp:Label></td>
                            <td class="label-cell">Total Quantity</td>
                            <td><asp:Label ID="lblGpTotalQty1" runat="server"></asp:Label></td>
                        </tr>
                        <tr>
                            <td class="label-cell">Remarks</td>
                            <td colspan="3"><asp:Label ID="lblGpRemarks1" runat="server"></asp:Label></td>
                        </tr>
                    </table>

 <!-- Signatures for Challan -->
 <div class="grid grid-cols-4 gap-4 items-end mt-12">

     <!-- Prepared By -->
     <div class="flex flex-col items-center justify-end text-center h-20">
         <asp:Label ID="lblGpPreparedBy" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
         <div class="border-t border-gray-400 w-full mb-1"></div>
         <b class="text-sm">Prepared By</b>
     </div>

     <!-- Store Officer -->
     <div class="flex flex-col items-center justify-end text-center h-20">
         <asp:Label ID="Label2" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
         <div class="border-t border-gray-400 w-full mb-1"></div>
         <b class="text-sm">Store Officer</b>
     </div>

     <!-- Gate Pass Checked -->
     <div class="flex flex-col items-center justify-end text-center h-20">
         <asp:Label ID="Label3" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
         <div class="border-t border-gray-400 w-full mb-1"></div>
         <b class="text-sm">Gate Pass Checked</b>
     </div>

     <!-- Receiver's Sign & Seal -->
     <div class="flex flex-col items-center justify-end text-center h-20">
         <asp:Label ID="Label4" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
         <div class="border-t border-gray-400 w-full mb-1"></div>
         <b class="text-sm whitespace-nowrap">Receiver's Sign &amp; Seal</b>
     </div>

 </div>
                </div>

                <div class="scissor-note">&#9986; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -</div>

                <!-- ---------- Gate Pass Copy #2 (Office Copy) ---------- -->
                <div class="gate-pass-copy">
                    <span class="gate-pass-copy-label">Office Copy</span>
                    <div class="row align-items-center mb-2">
                        <div class="col-8">
                            <div class="gate-pass-title">
                                <asp:Label ID="lblGpCompanyName2" runat="server" Text="Nexa ERP"></asp:Label>
                            </div>
                            <small class="text-muted">
                                <asp:Label ID="lblGpCompanyAddress2" runat="server"></asp:Label>
                            </small>
                        </div>
                        <div class="col-4 text-end">
                            <div class="gate-pass-subtitle">GATE PASS</div>
                        </div>
                    </div>

                    <table class="gate-pass-table">
                        <tr>
                            <td class="label-cell">Gate Pass No</td>
                            <td><asp:Label ID="lblGpNo2" runat="server"></asp:Label></td>
                            <td class="label-cell">Date</td>
                            <td><asp:Label ID="lblGpDate2" runat="server"></asp:Label></td>
                        </tr>
                        <tr>
                            <td class="label-cell">Ref. Challan No</td>
                            <td><asp:Label ID="lblGpChallanNo2" runat="server"></asp:Label></td>
                            <td class="label-cell">Customer</td>
                            <td><asp:Label ID="lblGpCustomerName2" runat="server"></asp:Label></td>
                        </tr>
                        <tr>
                            <td class="label-cell">Vehicle No</td>
                            <td><asp:Label ID="lblGpVehicleNo2" runat="server"></asp:Label></td>
                            <td class="label-cell">Driver Name &amp; Phone</td>
                            <td><asp:Label ID="lblGpDriverInfo2" runat="server"></asp:Label></td>
                        </tr>
                        <tr>
                            <td class="label-cell">Total Line Items</td>
                            <td><asp:Label ID="lblGpTotalLines2" runat="server"></asp:Label></td>
                            <td class="label-cell">Total Quantity</td>
                            <td><asp:Label ID="lblGpTotalQty2" runat="server"></asp:Label></td>
                        </tr>
                        <tr>
                            <td class="label-cell">Remarks</td>
                            <td colspan="3"><asp:Label ID="lblGpRemarks2" runat="server"></asp:Label></td>
                        </tr>
                    </table>
 <!-- Signatures for Challan -->
 <div class="grid grid-cols-4 gap-4 items-end mt-12">

     <!-- Prepared By -->
     <div class="flex flex-col items-center justify-end text-center h-20">
         <asp:Label ID="lblGpPreparedBy2" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
         <div class="border-t border-gray-400 w-full mb-1"></div>
         <b class="text-sm">Prepared By</b>
     </div>

     <!-- Store Officer -->
     <div class="flex flex-col items-center justify-end text-center h-20">
         <asp:Label ID="Label6" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
         <div class="border-t border-gray-400 w-full mb-1"></div>
         <b class="text-sm">Store Officer</b>
     </div>

     <!-- Gate Pass Checked -->
     <div class="flex flex-col items-center justify-end text-center h-20">
         <asp:Label ID="Label7" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
         <div class="border-t border-gray-400 w-full mb-1"></div>
         <b class="text-sm">Gate Pass Checked</b>
     </div>

     <!-- Receiver's Sign & Seal -->
     <div class="flex flex-col items-center justify-end text-center h-20">
         <asp:Label ID="Label8" runat="server" class="text-sm pb-1 min-h-[1.5rem]"></asp:Label>
         <div class="border-t border-gray-400 w-full mb-1"></div>
         <b class="text-sm whitespace-nowrap">Receiver's Sign &amp; Seal</b>
     </div>

 </div>

                </div>

            </div>
        </div>
    </form>
</body>
</html>
