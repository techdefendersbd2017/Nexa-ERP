<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WorkOrderReceive.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.WorkOrderReceive" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Work Order Input Form - ERP</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Bootstrap 5 ও Select2 CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
<link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />

<!-- jQuery এবং Select2 JS -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <style>
        body {
            background-color: #f8f9fa;
            font-size: 14px;
        }
        .card-header-custom {
            background-color: #1f4e78;
            color: white;
            font-weight: bold;
        }
        .table-dark-custom {
            background-color: #1f4e78;
            color: white;
        }
        .active-color-row {
            background-color: #d1e7ff !important;
        }
        .selected-color-badge {
            background-color: #198754;
        }
        .panel {
            display: none;
        }
        .panel.active {
            display: block;
        }
        .list-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .list-title {
            font-size: 1.25rem;
            font-weight: bold;
            color: #1f4e78;
        }
        .grid {
            width: 100%;
            background: white;
            border: 1px solid #dee2e6;
        }
        .grid th {
            background-color: #1f4e78;
            color: white;
            padding: 8px;
        }
        .grid td {
            padding: 8px;
            border-bottom: 1px solid #dee2e6;
        }
    </style>
    <script type="text/javascript">
        function showPanel(panelId) {
            document.querySelectorAll('.panel').forEach(function (p) {
                p.classList.remove('active');
            });
            document.getElementById(panelId).classList.add('active');
        }

        function calculateRowTotal() {
            var reqQty = parseFloat(document.getElementById('<%= txtReqQty.ClientID %>').value) || 0;
            var rateUnit = parseFloat(document.getElementById('<%= txtRateUnit.ClientID %>').value) || 0;
            var extraPercent = parseFloat(document.getElementById('<%= txtExtraPercent.ClientID %>').value) || 0;

            var totalReqQty = reqQty + (reqQty * (extraPercent / 100));
            var totalAmount = reqQty * rateUnit;

            document.getElementById('<%= txtTotalReqQtyInput.ClientID %>').value = totalReqQty.toFixed(2);
            document.getElementById('<%= txtTotalAmountInput.ClientID %>').value = totalAmount.toFixed(2);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <!-- ScriptManager for UpdatePanel to prevent full page postbacks -->
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div class="container my-4">


            <!-- ================= 1. LIST PANEL ================= -->
            <div id="pnlList" class="panel active">
                <div class="list-toolbar">
                    <div class="list-title">Work Order Receive List</div>
                    <button type="button" class="btn btn-success btn-sm" onclick="showPanel('pnlForm')">+ Add New Work Order</button>
                </div>

                <asp:GridView ID="gvWorkOrderReceive" runat="server" AutoGenerateColumns="False" CssClass="grid" ShowHeaderWhenEmpty="True" OnRowCommand="gvWorkOrderReceive_RowCommand">
                    <EmptyDataTemplate>
                        <div style="color: #777; padding: 12px; font-size: 12px; text-align: center;">
                            No records found in list
                        </div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="SL">
                            <ItemTemplate>
                                <%# Container.DataItemIndex + 1 %>
                            </ItemTemplate>
                            <ItemStyle Width="40px" />
                        </asp:TemplateField>
                    
                        <asp:BoundField DataField="WORcvNo" HeaderText="WO Rcv No" ItemStyle-Width="15%" />
                    
                        <asp:BoundField DataField="WORcvDate" HeaderText="WO Rcv Date" DataFormatString="{0:dd-MM-yyyy}" HtmlEncode="false" ItemStyle-Width="15%" />
                    
                        <asp:BoundField DataField="DeliveryDate" HeaderText="Delivery Date" DataFormatString="{0:dd-MM-yyyy}" HtmlEncode="false" ItemStyle-Width="15%" />
                    
                        <asp:BoundField DataField="GrandTotal" HeaderText="Total Value" DataFormatString="{0:N2}" HtmlEncode="false" ItemStyle-Width="15%" />
                    
                        <asp:TemplateField HeaderText="Action" ItemStyle-Width="40%" >
                            <ItemTemplate>
                                <div style="display: flex; gap: 5px; align-items: center;">
                                    <asp:LinkButton ID="lnkEdit" runat="server" Text="Edit" CommandName="EditRow" CommandArgument='<%# Eval("WORcvNo") %>' 
                                        Style="background-color: #e3f2fd; color: #1976d2; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #90caf9;" />
                                
                                    <asp:LinkButton ID="lnkDelete" runat="server" Text="Delete" CommandName="DeleteRow" CommandArgument='<%# Eval("WORcvNo") %>' 
                                        Style="background-color: #ffebee; color: #c62828; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #ef9a9a;" 
                                        OnClientClick="return confirm('Are you sure you want to delete this item?');" />
                                
                                    <asp:LinkButton ID="lnkPrintView" runat="server" Text="WO Report" CommandName="ReportView" CommandArgument='<%# Eval("WORcvID") %>' 
                                        Style="background-color: #e8f5e9; color: #2e7d32; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #a5d6a7;" />
                                    
                                   <%-- <asp:LinkButton ID="btnRawMaterialReport" runat="server" Text="Raw Material Report" CommandName="RawMaterialReport" CommandArgument='<%# Eval("WORcvID") %>' 
                                        Style="background-color: #e8f5e9; color: #2e7d32; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #a5d6a7;" />--%>
                                </div>
                            </ItemTemplate>
                            <ItemStyle Width="180px" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- ================= 2. FORM PANEL ================= -->
            <div id="pnlForm" class="panel">
                <div class="card shadow-sm">
                    <div class="card-header card-header-custom text-center py-2 d-flex justify-content-between align-items-center">
                        <span>Work Order Input Form (ERP Module)</span>
                        <button type="button" class="btn btn-light btn-sm text-dark fw-bold" onclick="showPanel('pnlList')">← Back to List</button>
                    </div>
                    <div class="card-body">

                        <!-- Wrap dynamic sections in UpdatePanel to handle partial postbacks smoothly -->
                        <asp:UpdatePanel ID="updFormContent" runat="server">
                            <ContentTemplate>
                                
                                <asp:HiddenField ID="hdnWorkOrderNo" runat="server" />
                                <asp:HiddenField ID="hdnSelectedColorSlNo" runat="server" />
                                <!-- SECTION 1: Company PAD & Header Information -->
                                <fieldset class="border p-3 rounded mb-4">
                                    <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">[Company PAD Common] - Header Info</legend>
                                    <div class="row g-3">
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold">1. Customer Name</label>
                                            <asp:DropDownList ID="ddlCustomerName" runat="server" CssClass="form-select form-select-sm">
                                                <asp:ListItem Text="--Select Customer--" Value="0" />
                                            </asp:DropDownList>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold">2. Work Order No.[Auto]</label>
                                            <asp:TextBox ID="txtWoRef" runat="server" CssClass="form-control form-control-sm" Text="WO-2026-0001" ReadOnly="true"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold">3. Work Order Date</label>
                                            <asp:TextBox ID="txtWoDate" runat="server" CssClass="form-control form-control-sm" TextMode="Date"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold">4. Delivery Date</label>
                                            <asp:TextBox ID="txtDeliveryDate" runat="server" CssClass="form-control form-control-sm" TextMode="Date"></asp:TextBox>
                                        </div>
                                    </div>
                                </fieldset>

                                <!-- SECTION 2: Buyer, Style, Order, WO No. & Item Name -->
                                <fieldset class="border p-3 rounded mb-4">
                                    <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">WO Details Header (Buyer, Style, Order, WO No. &amp; Item Name)</legend>
                                    <div class="row g-3">
                                        <div class="col-md-4">
                                            <label class="form-label fw-bold">Customer Buyer</label>
                                            <asp:TextBox ID="txtBuyer" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Buyer Name"></asp:TextBox>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label fw-bold">Style</label>
                                            <asp:TextBox ID="txtStyle" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Style No/Name"></asp:TextBox>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label fw-bold">Order</label>
                                            <asp:TextBox ID="txtOrderNo" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Order No"></asp:TextBox>
                                        </div>

                                        <div class="col-md-4">
                                            <label class="form-label fw-bold">Ref. Work Order No</label>
                                            <asp:TextBox ID="txtWoNoDetails" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. WO-001"></asp:TextBox>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label fw-bold">Item Name</label>
                                            <asp:DropDownList ID="ddlItemNameDetails" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                                <asp:ListItem Text="--Select Item--" Value="0" />
                                            </asp:DropDownList>
                                        </div>
                                        </div>
                                        
                                        <div class="col-md-3">
                                            <label class="form-label fw-bold">Quotation No</label>
                                            <asp:TextBox ID="txtQuotationNo" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Quotation No"></asp:TextBox>
                                        </div>
                                    </div>
                                </fieldset>

                                <!-- Color List Section (Multi Colors Add) -->
                                <fieldset class="border p-3 rounded mb-4">
                                    <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">Color List</legend>

                                    <!-- Color Entry Input Row -->
                                    <div class="row g-2 align-items-end bg-light p-2 rounded">
                                        <div class="col-md-4">
                                            <label class="form-label small fw-bold">Color Name</label>
                                            <asp:DropDownList ID="ddlColorName" runat="server" CssClass="form-select form-select-sm">
                                                <asp:ListItem Text="--Select Color--" Value="0" />
                                            </asp:DropDownList>
                                        </div>
                                        <div class="col-md-5">
                                            <label class="form-label small fw-bold">Color Remarks</label>
                                            <asp:TextBox ID="txtColorRemarks" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. Navy Blue / Transparent"></asp:TextBox>
                                        </div>
                                        <div class="col-md-3">
                                            <asp:Button ID="btnAddColor" runat="server" CssClass="btn btn-success btn-sm w-100" Text="Add Color" OnClick="btnAddColor_Click" />
                                        </div>
                                    </div>

                                    <!-- Color List Grid -->
                                    <div class="table-responsive mt-3">
                                        <asp:GridView ID="gvColorList" runat="server" CssClass="table table-bordered table-striped table-sm text-center align-middle" AutoGenerateColumns="False" DataKeyNames="ColorSlNo" EmptyDataText="No color added yet. Add colors above." OnRowCommand="gvColorList_RowCommand" OnRowDataBound="gvColorList_RowDataBound">
                                            <HeaderStyle CssClass="table-dark-custom" />
                                            <Columns>
                                                <asp:BoundField DataField="ColorSlNo" HeaderText="Sl No" />
                                                <asp:BoundField DataField="ColorName" HeaderText="Color Name" />
                                                <asp:BoundField DataField="ColorRemarks" HeaderText="Remarks" />
                                                <asp:BoundField DataField="TotalReqQty" HeaderText="Total Req. Qty" />
                                                <asp:BoundField DataField="ColorTotalAmount" HeaderText="Color Total Amount" />
                                                <asp:TemplateField HeaderText="Action">
                                                    <ItemTemplate>
                                                        <asp:Button ID="btnSelectColor" runat="server" CssClass="btn btn-info btn-sm px-2 py-0 text-white" Text="Add Sizes" CommandName="SelectColor" CommandArgument='<%# Eval("ColorSlNo") %>' CausesValidation="false" />
                                                        <asp:Button ID="btnEditColor" runat="server" CssClass="btn btn-primary btn-sm px-2 py-0" Text="Edit" CommandName="EditColor" CommandArgument='<%# Eval("ColorSlNo") %>' CausesValidation="false" />
                                                        <asp:Button ID="btnDeleteColor" runat="server" CssClass="btn btn-danger btn-sm px-2 py-0" Text="X" CommandName="DeleteColor" CommandArgument='<%# Eval("ColorSlNo") %>' CausesValidation="false" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </div>
                                </fieldset>

                                <!-- Size-wise Variant Details Section -->
                                <fieldset class="border p-3 rounded mb-4">
                                    <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">Size-wise Variant &amp; Quantities Grid</legend>

                                    <div class="alert alert-primary py-2 px-3 mb-3 d-flex justify-content-between align-items-center">
                                        <span>Currently adding sizes for Color: <asp:Label ID="lblSelectedColorName" runat="server" CssClass="fw-bold" Text="-- No color selected --"></asp:Label></span>
                                        <span class="badge selected-color-badge">Select "Add Sizes" from the Color List above</span>
                                    </div>

                                    <!-- Size Variant Input Fields -->
                                    <div class="row g-2 align-items-end bg-light p-2 rounded">
                                        <div class="col-md-2">
                                            <label class="form-label small fw-bold">Size</label>
                                            <asp:TextBox ID="txtSize" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. S / 10x12"></asp:TextBox>
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label small fw-bold">Measurement</label>
                                            <asp:TextBox ID="txtMeasurement" runat="server" CssClass="form-control form-control-sm" placeholder="Measurement"></asp:TextBox>
                                        </div>
                                        <div class="col-md-1">
                                            <label class="form-label small fw-bold">Req. Qty</label>
                                            <asp:TextBox ID="txtReqQty" runat="server" CssClass="form-control form-control-sm" Text="0" onkeyup="calculateRowTotal()"></asp:TextBox>
                                        </div>
                                        <div class="col-md-1">
                                            <label class="form-label small fw-bold">Unit</label>
                                            <asp:DropDownList ID="ddlUnit" runat="server" CssClass="form-select form-select-sm">
                                                <asp:ListItem Text="Pcs" Value="Pcs" />
                                                <asp:ListItem Text="Set" Value="Set" />
                                                <asp:ListItem Text="Kg" Value="Kg" />
                                                <asp:ListItem Text="Roll" Value="Roll" />
                                            </asp:DropDownList>
                                        </div>
                                        <div class="col-md-1">
                                            <label class="form-label small fw-bold">Rate/Unit</label>
                                            <asp:TextBox ID="txtRateUnit" runat="server" CssClass="form-control form-control-sm" Text="0" onkeyup="calculateRowTotal()"></asp:TextBox>
                                        </div>
                                        <div class="col-md-1">
                                            <label class="form-label small fw-bold">Extra %</label>
                                            <asp:TextBox ID="txtExtraPercent" runat="server" CssClass="form-control form-control-sm" Text="0" onkeyup="calculateRowTotal()"></asp:TextBox>
                                        </div>
                                        <div class="col-md-1">
                                            <label class="form-label small fw-bold">Total Req. Qty</label>
                                            <asp:TextBox ID="txtTotalReqQtyInput" runat="server" CssClass="form-control form-control-sm" Text="0.00" ReadOnly="true"></asp:TextBox>
                                        </div>
                                        <div class="col-md-1">
                                            <label class="form-label small fw-bold">Total Amount</label>
                                            <asp:TextBox ID="txtTotalAmountInput" runat="server" CssClass="form-control form-control-sm" Text="0.00" ReadOnly="true"></asp:TextBox>
                                        </div>
                                        <div class="col-md-2">
                                            <label class="form-label small fw-bold">Item Spec / Remarks</label>
                                            <asp:TextBox ID="txtSizeRemarks" runat="server" CssClass="form-control form-control-sm" placeholder="Remarks"></asp:TextBox>
                                        </div>
                                        <div class="col-md-1">
                                            <asp:Button ID="btnAddSize" runat="server" CssClass="btn btn-success btn-sm w-100" Text="Add" OnClick="btnAddSize_Click" />
                                        </div>
                                    </div>

                                    <!-- Data Table: Size Variants -->
                                    <div class="table-responsive mt-3">
                                        <asp:GridView ID="gvSizeDetails" runat="server" CssClass="table table-bordered table-striped table-sm text-center align-middle" AutoGenerateColumns="False" DataKeyNames="SlNo" EmptyDataText="No size variant added for this color yet." OnRowCommand="gvSizeDetails_RowCommand">
                                            <HeaderStyle CssClass="table-dark-custom" />
                                            <Columns>
                                                <asp:BoundField DataField="SlNo" HeaderText="Sl No" />
                                                <asp:BoundField DataField="Size" HeaderText="Size" />
                                                <asp:BoundField DataField="Measurement" HeaderText="Measurement" />
                                                <asp:BoundField DataField="ReqQty" HeaderText="Required Qty" />
                                                <asp:BoundField DataField="Unit" HeaderText="Unit" />
                                                <asp:BoundField DataField="RateUnit" HeaderText="Rate/Unit" />
                                                <asp:BoundField DataField="ExtraPercent" HeaderText="Extra %" />
                                                <asp:BoundField DataField="TotalReqQty" HeaderText="Total Req. Qty" />
                                                <asp:BoundField DataField="TotalAmount" HeaderText="Total Amount" />
                                                <asp:BoundField DataField="Remarks" HeaderText="Item Specification/Remarks" />
                                                <asp:TemplateField HeaderText="Action">
                                                    <ItemTemplate>
                                                        <asp:Button ID="btnEditSize" runat="server" CssClass="btn btn-primary btn-sm px-2 py-0" Text="Edit" CommandName="EditSize" CommandArgument='<%# Eval("SlNo") %>' CausesValidation="false" />
                                                        <asp:Button ID="btnDeleteSize" runat="server" CssClass="btn btn-danger btn-sm px-2 py-0" Text="X" CommandName="DeleteSize" CommandArgument='<%# Eval("SlNo") %>' CausesValidation="false" />
                                                    </ItemTemplate>
                                                </asp:TemplateField>
                                            </Columns>
                                        </asp:GridView>
                                    </div>

                                    <!-- Per-Color Summary -->
                                    <div class="row justify-content-end mt-3">
                                        <div class="col-md-4">
                                            <div class="input-group input-group-sm">
                                                <span class="input-group-text fw-bold w-50">This Color's Total Amount</span>
                                                <asp:TextBox ID="txtColorTotalAmount" runat="server" CssClass="form-control text-end" Text="0.00" ReadOnly="true"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>

                                <!-- Other Costs & Grand Total Summary -->
                                <fieldset class="border p-3 rounded mb-4">
                                    <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">Other Costs &amp; Grand Total Summary</legend>
                                    <div class="row justify-content-end">
                                        <div class="col-md-4">
                                            <div class="input-group input-group-sm mb-1">
                                                <span class="input-group-text fw-bold w-50">Sub Total Amount</span>
                                                <asp:TextBox ID="txtSubTotalAmount" runat="server" CssClass="form-control text-end" Text="0.00" ReadOnly="true"></asp:TextBox>
                                            </div>
                                            <div class="input-group input-group-sm mb-1">
                                                <span class="input-group-text fw-bold w-50">Transport / Carrying Cost</span>
                                                <asp:TextBox ID="txtTransportCost" runat="server" CssClass="form-control text-end" Text="0.00"></asp:TextBox>
                                            </div>
                                            <div class="input-group input-group-sm mb-1">
                                                <span class="input-group-text fw-bold w-50">VAT / Tax (%)</span>
                                                <asp:TextBox ID="txtVatPercent" runat="server" CssClass="form-control text-end" Text="0.00"></asp:TextBox>
                                            </div>
                                            <div class="input-group input-group-sm">
                                                <span class="input-group-text fw-bold w-50 bg-secondary text-white">Grand Total Amount</span>
                                                <asp:TextBox ID="txtGrandTotalAmount" runat="server" CssClass="form-control text-end fw-bold" Text="0.00" ReadOnly="true"></asp:TextBox>
                                            </div>
                                        </div>
                                    </div>
                                </fieldset>

                            </ContentTemplate>
                        </asp:UpdatePanel>

                        <!-- Bottom Action Buttons -->
                        <div class="d-flex gap-2">
                            <asp:Button ID="btnSave" runat="server" CssClass="btn btn-success px-4" Text="Save &amp; Print Work Order" OnClick="btnSave_Click" />
                            <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel" OnClick="btnCancel_Click" />
                            <button type="button" class="btn btn-info px-4 text-white" onclick="showPanel('pnlList')">Back to List</button>
                        </div>

                    </div>
                </div>
            </div>

        </div>
    </form>


</body>
</html>