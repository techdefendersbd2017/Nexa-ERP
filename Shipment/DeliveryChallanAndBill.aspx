<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeliveryChallanAndBill.aspx.cs" Inherits="Nexa_ERP.Shipment.DeliveryChallanAndBill" %>

<!DOCTYPE html>
<html lang="bn">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery Challan & Commercial Bill</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />

    <style>
        body { background-color: #f4f6f9; font-size: 14px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .card-header-custom { background: linear-gradient(135deg, #2e7d32 0%, #1b5e20 100%); color: #fff; font-weight: bold; }
        .card { border: none; border-radius: 10px; overflow: hidden; width: 100%; }
        .grid { width: 100%; background: white; border: 1px solid #dee2e6; border-radius: 6px; }
        .grid th { background-color: #2e7d32; color: white; padding: 10px; text-align: center; }
        .grid td { padding: 8px; border-bottom: 1px solid #eef0f2; vertical-align: middle; }
        
        fieldset.section-box {
            background-color: #fbfcfe; border: 1px solid #e1e6ec !important;
            border-radius: 10px !important; padding: 18px 20px !important; margin-bottom: 22px !important;
        }
        fieldset.section-box legend {
            background-color: #e8f5e9; padding: 4px 14px !important;
            border-radius: 20px; color: #2e7d32 !important; font-size: 0.95rem !important; font-weight: bold; width: auto; float: none;
        }

        .summary-box .input-group-text { background-color: #eef2f7; color: #1f4e78; }
        .summary-box .input-group-text.grand-total { background-color: #1f4e78 !important; color: #fff !important; }
        .summary-box .form-control { font-weight: 600; }
        
        .panel { display: none; width: 100%; }
        .panel.active { display: block; }
        .list-toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; }
        .list-title { font-size: 1.3rem; font-weight: 700; color: #2e7d32; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <!-- পুরো উইডথ নেওয়ার জন্য container-fluid ব্যবহার করা হলো -->
        <div class="container-fluid px-4 my-4">
            <asp:HiddenField ID="hdnChallanHeaderID" runat="server" Value="0" />

            <!-- বর্তমানে কোন প্যানেল (pnlList / pnlForm) অ্যাক্টিভ তা ট্র্যাক করার জন্য -->
            <asp:HiddenField ID="hdnActivePanel" runat="server" Value="pnlList" />

            <!-- ================= 1. LIST PANEL ================= -->
            <div id="pnlList" class="panel active">
                <div class="list-toolbar">
                    <div class="list-title">Delivery Challan & Bill List</div>
                    <asp:Button ID="btnNewChallan" runat="server" Text="+ Create New Challan & Bill" CssClass="btn btn-success btn-sm" OnClientClick="showPanel('pnlForm'); return false;" />
                </div>

                <div class="table-responsive w-100">
                    <asp:GridView ID="gvChallans" runat="server" CssClass="grid" AutoGenerateColumns="false" 
    GridLines="None" OnRowCommand="gvChallans_RowCommand">
    <Columns>
        <asp:BoundField DataField="SL" HeaderText="SL" ItemStyle-CssClass="text-center" />
        <asp:BoundField DataField="ChallanNo" HeaderText="Challan No" />
        <asp:BoundField DataField="ChallanDate" HeaderText="Challan Date" />
        <asp:BoundField DataField="WORefNo" HeaderText="WO Ref No" />
        <asp:BoundField DataField="Customer" HeaderText="Customer" />
        <asp:BoundField DataField="BillAmount" HeaderText="Bill Amount" ItemStyle-CssClass="text-end" />
        <asp:TemplateField HeaderText="Action" ItemStyle-CssClass="text-center">
            <ItemTemplate>
                <asp:Button ID="btnEdit" runat="server" Text="Edit" CssClass="btn btn-sm btn-outline-success"
                    CommandName="EditChallan" CommandArgument='<%# Eval("DeliveryChallanHeaderID") %>' />
                <asp:Button ID="btnChallan" runat="server" Text="Print View Challan" CssClass="btn btn-sm btn-outline-success"
                    CommandName="ReportView" CommandArgument='<%# Eval("DeliveryChallanHeaderID") %>' />
                <asp:Button ID="btnBill" runat="server" Text="Print View Bill" CssClass="btn btn-sm btn-outline-success"
                    CommandName="ReportViewWithAmount" CommandArgument='<%# Eval("DeliveryChallanHeaderID") %>' />
            </ItemTemplate>
        </asp:TemplateField>
    </Columns>
</asp:GridView>
                </div>
            </div>

            <!-- ================= 2. FORM PANEL ================= -->
            <div id="pnlForm" class="panel active">
                <div class="card shadow-sm">
                    <div class="card-header card-header-custom py-2 d-flex justify-content-between align-items-center">
                        <span>Delivery Challan & Commercial Bill Entry</span>
                        <asp:Button ID="btnBackList" runat="server" Text="← Back to List" CssClass="btn btn-light btn-sm text-dark fw-bold" OnClientClick="showPanel('pnlList'); return false;" />
                    </div>

                    <div class="card-body p-4">

                        <!-- SECTION 1: REFERENCE WORK ORDER -->
                        <fieldset class="section-box">
                            <legend>Select Work Order</legend>
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Receiving Branch</label>
                                    <asp:DropDownList ID="ddlReceivingBranch" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                        <asp:ListItem Text="-- Select Work Order --" Value="" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Customer Name</label>
                                    <asp:DropDownList ID="ddlCustomer" runat="server" AutoPostBack="true" CssClass="form-select form-select-sm searchable-dropdown" OnSelectedIndexChanged="ddlCustomer_SelectedIndexChanged">
                                        <asp:ListItem Text="-- Select Customer --" Value="" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Work Order No</label>
                                    <asp:DropDownList ID="ddlWorkOrder" runat="server" AutoPostBack="true" CssClass="form-select form-select-sm searchable-dropdown" OnSelectedIndexChanged="ddlWorkOrder_SelectedIndexChanged">
                                        <asp:ListItem Text="-- Select Work Order --" Value="" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </fieldset>

                        <!-- SECTION 2: DELIVERY CHALLAN INFO -->
                        <fieldset class="section-box">
                            <legend>1. Delivery Challan Header Info</legend>
                            <div class="row g-3">
                                <div class="col-md-2">
                                    <label class="form-label fw-bold">Challan No.[Auto]</label>
                                    <asp:TextBox ID="txtChallanNo" runat="server" CssClass="form-control form-control-sm" Text="DC-2026-0003" ReadOnly="true" />
                                </div>                                
                                <div class="col-md-2">
                                    <label class="form-label fw-bold">Delivery Type</label>
                                    <asp:DropDownList ID="ddlDeliveryType" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Text="-- Select Delivery Type --" Value="0" />
                                        <asp:ListItem Text="Partial" Value="1" />
                                        <asp:ListItem Text="Full" Value="2" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label fw-bold">Challan Date</label>
                                    <asp:TextBox ID="txtChallanDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" Text="2026-08-19" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Vehicle / Transport No</label>
                                    <asp:TextBox ID="txtVehicle" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. Dhaka Metro-M 11-2233" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Driver Name / Phone</label>
                                    <asp:TextBox ID="txtDriver" runat="server" CssClass="form-control form-control-sm" placeholder="Driver Name & Contact" />
                                </div>
                            </div>
                        </fieldset>

                        <!-- SECTION 3: COMMERCIAL BILL REF INFO -->
                        <fieldset class="section-box">
                            <legend>2. Commercial Bill / Invoice Info</legend>
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Bill / Invoice No.[Auto]</label>
                                    <asp:TextBox ID="txtInvoiceNo" runat="server" CssClass="form-control form-control-sm" Text="INV-2026-0001" ReadOnly="true" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Bill Date</label>
                                    <asp:TextBox ID="txtBillDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" Text="2026-08-19" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Payment Terms</label>
                                    <asp:TextBox ID="txtPaymentTerms" runat="server" CssClass="form-control form-control-sm" Text="30 Days Net" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Remarks</label>
                                    <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control form-control-sm" placeholder="Delivery Remarks" />
                                </div>
                            </div>
                        </fieldset>

                        <!-- SECTION 4: ITEMS DELIVERY & BILLING GRID -->
                        <fieldset class="section-box">
                            <legend>3. Delivery Items & Billing Details</legend>
                            <div class="table-responsive w-100">
                                <asp:GridView ID="gvDeliveryItems" runat="server" CssClass="table table-bordered table-striped table-sm text-center align-middle w-100" 
                                    AutoGenerateColumns="false" GridLines="None" OnRowDataBound="gvDeliveryItems_RowDataBound">
                                    <HeaderStyle CssClass="table-dark" />
                                    <Columns>
                                        <asp:TemplateField HeaderText="Sl No">
                                            <ItemTemplate>
                                                <asp:Label ID="lblSL" runat="server" Text='<%# Container.DataItemIndex + 1 %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Job No">
                                            <ItemTemplate>
                                                <asp:Label ID="lblJobNo" runat="server" Text='<%# Eval("JobNo") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Item Name">
                                            <ItemTemplate>
                                                <asp:Label ID="lblItemName" runat="server" Text='<%# Eval("ItemName") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Buyer Name">
                                            <ItemTemplate>
                                                <asp:Label ID="lblBuyer" runat="server" Text='<%# Eval("Buyer") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Style Name">
                                            <ItemTemplate>
                                                <asp:Label ID="lblStyle" runat="server" Text='<%# Eval("Style") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="PO Name">
                                            <ItemTemplate>
                                                <asp:Label ID="lblPOName" runat="server" Text='<%# Eval("POName") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Color">
                                            <ItemTemplate>
                                                <asp:Label ID="lblColor" runat="server" Text='<%# Eval("Color") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Size">
                                            <ItemTemplate>
                                                <asp:Label ID="lblSize" runat="server" Text='<%# Eval("Size") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Measurement" ItemStyle-Width="110px">
                                            <ItemTemplate>
                                                <asp:Label ID="lblMeasurement" runat="server" Text='<%# Eval("Measurement") %>'></asp:Label>                                                
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Order Qty & Unit">
                                            <ItemTemplate>
                                                <asp:Label ID="lblWOQty" runat="server" Text='<%# Eval("WOQty") %>'></asp:Label>
                                                <asp:Label ID="lblWOQtyUnit" runat="server" Text='<%# Eval("WOQtyUnit") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Ready Qty & Unit" ItemStyle-Width="110px">
                                            <ItemTemplate>
                                                <asp:Label ID="lblReadyQty" runat="server" Text='<%# Eval("ReadyQty") %>'></asp:Label>
                                                <asp:Label ID="lblReadyQtyUnit" runat="server" Text='<%# Eval("ReadyQtyUnit") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Delivery Qty" ItemStyle-Width="110px">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtRowQty" runat="server" CssClass="form-control form-control-sm text-center fw-bold row-qty" 
                                                    Text='<%# Eval("ChallanQty") %>' oninput="calculateTotal()"></asp:TextBox>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Rate/Unit ($)" ItemStyle-Width="110px">
                                            <ItemTemplate>
                                                <asp:Label ID="lblUnitRate" runat="server" Text='<%# Eval("RateUnit") %>'></asp:Label>
                                                <asp:Label ID="lblRateUnit" runat="server" Text='<%# Eval("RateUnitName") %>'></asp:Label>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Total Amount ($)" ItemStyle-Width="130px">
                                            <ItemTemplate>
                                                <span class="row-total fw-bold text-primary"><%# Eval("TotalAmount") %></span>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Item Specification/Remarks" ItemStyle-Width="150px">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtItemRemarks" runat="server" CssClass="form-control form-control-sm" Text='<%# Eval("ItemRemarks") %>'></asp:TextBox>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>

                            <!-- Summary / Totals -->
                            <div class="row justify-content-end mt-3">
                                <div class="col-md-4 summary-box">
                                    <div class="input-group input-group-sm mb-2">
                                        <span class="input-group-text fw-bold w-50">Sub Total Amount</span>
                                        <asp:TextBox ID="txtSubTotal" runat="server" CssClass="form-control text-end" Text="810.00" ReadOnly="true" />
                                    </div>
                                    <div class="input-group input-group-sm mb-2">
                                        <span class="input-group-text fw-bold w-50">Transport Cost</span>
                                        <asp:TextBox ID="txtTransport" runat="server" CssClass="form-control text-end" Text="50.00" oninput="calculateTotal()" />
                                    </div>
                                    <div class="input-group input-group-sm mb-2">
                                        <span class="input-group-text fw-bold w-50">VAT / Tax (%)</span>
                                        <asp:TextBox ID="txtVat" runat="server" CssClass="form-control text-end" Text="5" oninput="calculateTotal()" />
                                    </div>
                                    <div class="input-group input-group-sm">
                                        <span class="input-group-text fw-bold w-50 grand-total">Grand Total Amount</span>
                                        <asp:TextBox ID="txtGrandTotal" runat="server" CssClass="form-control text-end fw-bold" Text="903.00" ReadOnly="true" />
                                    </div>
                                </div>
                            </div>
                        </fieldset>

                        <!-- Action Buttons -->
                        <div class="d-flex gap-2">
                            <asp:Button ID="btnSave" runat="server" Text="Save & Print Challan + Bill" CssClass="btn btn-success px-4" OnClick="btnSave_Click" />
                            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary px-4" OnClientClick="showPanel('pnlList'); return false;" OnClick="btnCancel_Click" />
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </form>

    <!-- jQuery & Select2 JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

    <script>
        function showPanel(panelId) {
            $('.panel').removeClass('active');
            $('#' + panelId).addClass('active');
            // ★ NEW: বর্তমান অ্যাক্টিভ প্যানেল হিডেন ফিল্ডে সেভ রাখা হচ্ছে,
            // যাতে যেকোনো পোস্টব্যাক (dropdown change ইত্যাদি) এর পরও সার্ভার-সাইড থেকে সঠিক প্যানেল দেখানো যায়
            $('#<%= hdnActivePanel.ClientID %>').val(panelId);
        }

        $(document).ready(function () {
            $('.searchable-dropdown').select2({
                theme: "bootstrap-5",
                placeholder: "Search Order",
                allowClear: true,
                width: '100%'
            });
            calculateTotal();
        });

        function calculateTotal() {
            let subTotal = 0;

            // ASP.NET GridView এর প্রতিটি রো (Row) লুপ করা
            $('#<%= gvDeliveryItems.ClientID %> tr').each(function () {
            // হেডার রো বাদ দেওয়ার জন্য
            if ($(this).find('th').length > 0) return;

            // Delivery Qty (Textbox)
            let qty = parseFloat($(this).find('.row-qty').val()) || 0;

            // Unit Rate (Label থেকে ভ্যালু নেওয়া)
            let rateText = $(this).find('[id*="lblUnitRate"]').text();
            let rate = parseFloat(rateText) || 0;

            // টোটাল অ্যামাউন্ট হিসাব (Qty * Rate)
            let rowAmount = qty * rate;

            // রো টোটাল আপডেট করা
            $(this).find('.row-total').text(rowAmount.toFixed(2));
            subTotal += rowAmount;
        });

        // সাব-টোটাল সেট করা
        $('#<%= txtSubTotal.ClientID %>').val(subTotal.toFixed(2));

        // ট্রান্সপোর্ট এবং ভ্যাট হিসাব
        let transport = parseFloat($('#<%= txtTransport.ClientID %>').val()) || 0;
        let vatPercent = parseFloat($('#<%= txtVat.ClientID %>').val()) || 0;

        let vatAmount = (subTotal * vatPercent) / 100;
        let grandTotal = subTotal + transport + vatAmount;

        // গ্র্যান্ড টোটাল সেট করা
        $('#<%= txtGrandTotal.ClientID %>').val(grandTotal.toFixed(2));
        }
    </script>
</body>
</html>
