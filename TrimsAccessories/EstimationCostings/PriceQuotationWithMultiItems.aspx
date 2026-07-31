<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PriceQuotationWithMultiItems.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.PriceQuotationWithMultiItems" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Price Quotation Management</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
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
        .active-item-row {
            background-color: #d1e7ff !important;
        }
        .selected-item-badge {
            background-color: #198754;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container my-4">
            <asp:HiddenField ID="Costing_No" runat="server" />
            <!-- Tracks which Item (from gvItemList) is currently active for Raw Material entry -->
            <asp:HiddenField ID="hdnSelectedItemSlNo" runat="server" />

            <!-- ========================================== -->
            <!-- SECTION 1: PRICE QUOTATION LIST (DEFAULT) -->
            <!-- ========================================== -->
            <asp:Panel ID="pnlList" runat="server">
                <div class="card shadow-sm">
                    <div class="card-header card-header-custom d-flex justify-content-between align-items-center py-2">
                        <h5 class="mb-0">Price Quotation List</h5>
                        <asp:Button ID="btnAddNew" runat="server" CssClass="btn btn-light btn-sm text-primary fw-bold px-3" Text="+ Add New Quotation" OnClick="btnAddNew_Click" />
                    </div>
                    <div class="card-body">

                        <!-- Search Filter Box -->
                        <div class="row g-3 align-items-end bg-light p-3 rounded mb-4 border">
                            <div class="col-md-3">
                                <label class="form-label small fw-bold">Quotation No</label>
                                <asp:TextBox ID="txtSearchQuotationNo" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. QT-0002"></asp:TextBox>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label small fw-bold">Customer</label>
                                <asp:DropDownList ID="ddlSearchCustomer" runat="server" CssClass="form-select form-select-sm">
                                    <asp:ListItem Text="--All Customer--" Value="0" />
                                </asp:DropDownList>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small fw-bold">From Date</label>
                                <asp:TextBox ID="txtFromDate" runat="server" CssClass="form-control form-control-sm" TextMode="Date"></asp:TextBox>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small fw-bold">Till Date</label>
                                <asp:TextBox ID="txtTillDate" runat="server" CssClass="form-control form-control-sm" TextMode="Date"></asp:TextBox>
                            </div>
                            <div class="col-md-2">
                                <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-primary btn-sm w-100" Text="Search" OnClick="btnSearch_Click" />
                            </div>
                        </div>

                        <!-- Quotation GridView List -->
                        <div class="table-responsive">
                            <asp:GridView ID="gvQuotationList" runat="server" CssClass="table table-bordered table-striped table-sm text-center align-middle" AutoGenerateColumns="False" EmptyDataText="No quotation records found." OnRowCommand="gvQuotationList_RowCommand">
                                <HeaderStyle CssClass="table-dark-custom" />
                                <Columns>
                                    <asp:BoundField DataField="SlNo" HeaderText="Sl No" />
                                    <asp:BoundField DataField="QuotationCode" HeaderText="Quotation No" />
                                    <asp:BoundField DataField="CreateDate" HeaderText="Date" />
                                    <asp:BoundField DataField="Customer" HeaderText="Customer" />
                                    <asp:BoundField DataField="QuotationName" HeaderText="Quotation Name" />
                                    <asp:BoundField DataField="GTotalCost" HeaderText="G. Total Cost" />
                                    <asp:BoundField DataField="Status" HeaderText="Status" />
                                    <asp:TemplateField HeaderText="Action">
                                        <ItemTemplate>
                                            <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-primary btn-sm px-2 py-0" Text="Edit" CommandName="EditQuotation" CommandArgument='<%# Eval("QuotationID") %>' />
                                            <asp:Button ID="btnShort" runat="server" CssClass="btn btn-secondary btn-sm px-2 py-0" Text="Print Short" CommandName="PrintQuotationShort" CommandArgument='<%# Eval("QuotationID") %>' CausesValidation="false" />
                                            <asp:Button ID="btnPrint" runat="server" CssClass="btn btn-secondary btn-sm px-2 py-0" Text="Print Details" CommandName="PrintQuotation" CommandArgument='<%# Eval("QuotationID") %>' CausesValidation="false" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>

                    </div>
                </div>
            </asp:Panel>


            <!-- ========================================== -->
            <!-- SECTION 2: PRICE QUOTATION ENTRY FORM      -->
            <!-- ========================================== -->
            <asp:Panel ID="pnlEntry" runat="server" Visible="false">
                <div class="card shadow-sm">
                    <div class="card-header card-header-custom text-center py-2">
                        <h5 class="mb-0">Price Quotation Entry Form</h5>
                    </div>
                    <div class="card-body">

                        <!-- Master Info Section (Quotation level - one per Quotation) -->
                        <fieldset class="border p-3 rounded mb-4">
                            <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">Master Info</legend>

                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Customer</label>
                                    <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Text="--Select Customer--" Value="0" />
                                        <asp:ListItem Text="RS Packaging" Value="RS Packaging" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Quotation Code</label>
                                    <asp:TextBox ID="txtQuotationCode" runat="server" CssClass="form-control form-control-sm" Text="QT-0002"></asp:TextBox>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Create Date</label>
                                    <asp:TextBox ID="txtCreateDate" runat="server" CssClass="form-control form-control-sm" TextMode="Date"></asp:TextBox>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Quotation Name</label>
                                    <div class="input-group input-group-sm">
                                        <asp:TextBox ID="txtQuotationName" runat="server" CssClass="form-control" Text="RSP-SINGLE POLY"></asp:TextBox>
                                        <asp:TextBox ID="txtSameAs" runat="server" CssClass="form-control" placeholder="Same As"></asp:TextBox>
                                        <asp:Button ID="btnCopy" runat="server" CssClass="btn btn-primary" Text="Copy" />
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Status</label>
                                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Text="Active" Value="1" Selected="True" />
                                        <asp:ListItem Text="Inactive" Value="2" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </fieldset>

                        <!-- ========================================== -->
                        <!-- Item List Section (Multi Items Add) -->
                        <!-- ========================================== -->
                        <fieldset class="border p-3 rounded mb-4">
                            <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">Item List</legend>

                            <!-- Item Entry Input Row -->
                            <div class="row g-2 align-items-end bg-light p-2 rounded">
                                <div class="col-md-3">
                                    <label class="form-label small fw-bold">Item Category</label>
                                    <asp:DropDownList ID="ddlItemCategory" AutoPostBack="true" runat="server" CssClass="form-select form-select-sm" OnSelectedIndexChanged="ddlItemCategory_SelectedIndexChanged">
                                        <asp:ListItem Text="--Select Category--" Value="0" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label small fw-bold">Sub Category</label>
                                    <asp:DropDownList ID="ddlSubCategory" AutoPostBack="true" runat="server" CssClass="form-select form-select-sm" OnSelectedIndexChanged="ddlSubCategory_SelectedIndexChanged">
                                        <asp:ListItem Text="--Select Sub Category--" Value="0" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label small fw-bold">Item Name</label>
                                    <asp:DropDownList ID="ddlItemName" runat="server" AutoPostBack="true" CssClass="form-select form-select-sm" OnSelectedIndexChanged="ddlItemName_SelectedIndexChanged">
                                        <asp:ListItem Text="--Select Item Name--" Value="0" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label small fw-bold">Qty</label>
                                    <div class="input-group input-group-sm">
                                        <asp:TextBox ID="txtQty" runat="server" CssClass="form-control" Text="1"></asp:TextBox>
                                        <asp:DropDownList ID="ddlItemUnit" runat="server" CssClass="form-select">
                                            <asp:ListItem Text="Select" Value="0" />
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div class="col-md-1">
                                    <asp:Button ID="btnAddItem" runat="server" CssClass="btn btn-success btn-sm w-100" Text="Add Item" OnClick="btnAddItem_Click" />
                                </div>
                            </div>

                            <!-- Item List Grid -->
                            <div class="table-responsive mt-3">
                                <asp:GridView ID="gvItemList" runat="server" CssClass="table table-bordered table-striped table-sm text-center align-middle" AutoGenerateColumns="False" DataKeyNames="ItemSlNo" EmptyDataText="No item added yet. Add items above." OnRowCommand="gvItemList_RowCommand" OnRowDataBound="gvItemList_RowDataBound">
                                    <HeaderStyle CssClass="table-dark-custom" />
                                    <Columns>
                                        <asp:BoundField DataField="ItemSlNo" HeaderText="Sl No" />
                                        <asp:BoundField DataField="ItemCategory" HeaderText="Category" />
                                        <asp:BoundField DataField="SubCategory" HeaderText="Sub Category" />
                                        <asp:BoundField DataField="ItemName" HeaderText="Item Name" />
                                        <asp:BoundField DataField="Qty" HeaderText="Qty" />
                                        <asp:BoundField DataField="Unit" HeaderText="Unit" />
                                        <asp:BoundField DataField="ItemTotalCost" HeaderText="Item Total Cost" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnSelectItem" runat="server" CssClass="btn btn-info btn-sm px-2 py-0 text-white" Text="Add Materials" CommandName="SelectItem" CommandArgument='<%# Eval("ItemSlNo") %>' CausesValidation="false" />
                                                <asp:Button ID="btnEditItem" runat="server" CssClass="btn btn-primary btn-sm px-2 py-0" Text="Edit" CommandName="EditItem" CommandArgument='<%# Eval("ItemSlNo") %>' CausesValidation="false" />
                                                <asp:Button ID="btnDeleteItem" runat="server" CssClass="btn btn-danger btn-sm px-2 py-0" Text="X" CommandName="DeleteItem" CommandArgument='<%# Eval("ItemSlNo") %>' CausesValidation="false" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </fieldset>

                        <!-- ========================================== -->
                        <!-- Item Details / Raw Material Costing Section -->
                        <!-- (Materials belong to the currently selected Item above) -->
                        <!-- ========================================== -->
                        <fieldset class="border p-3 rounded mb-4">
                            <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">Raw Material Costing Details</legend>

                            <div class="alert alert-primary py-2 px-3 mb-3 d-flex justify-content-between align-items-center">
                                <span>Currently adding materials for Item: <asp:Label ID="lblSelectedItemName" runat="server" CssClass="fw-bold" Text="-- No item selected --"></asp:Label></span>
                                <span class="badge selected-item-badge">Select "Add Materials" from the Item List above</span>
                            </div>

                            <!-- Item Details Input Fields -->
                            <div class="row g-2 align-items-end bg-light p-2 rounded">
                                <div class="col-md-3">
                                    <label class="form-label small fw-bold">Raw Material</label>
                                    <asp:DropDownList ID="ddlRawMaterial" AutoPostBack="true" runat="server" CssClass="form-select form-select-sm" OnSelectedIndexChanged="ddlRawMaterial_SelectedIndexChanged">
                                        <asp:ListItem Text="--Select Raw Material--" Value="0" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-1">
                                    <label class="form-label small fw-bold">Req. Qty</label>
                                    <asp:TextBox ID="txtReqQty" runat="server" CssClass="form-control form-control-sm" Text="1" onkeyup="calculateRowTotal()"></asp:TextBox>
                                </div>
                                <div class="col-md-1">
                                    <label class="form-label small fw-bold">Unit</label>
                                    <asp:DropDownList ID="ddlDetailUnit" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Text="--Select--" Value="0" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-1">
                                    <label class="form-label small fw-bold">Unit Price</label>
                                    <asp:TextBox ID="txtUnitPrice" runat="server" CssClass="form-control form-control-sm" Text="1" onkeyup="calculateRowTotal()"></asp:TextBox>
                                </div>
                                <div class="col-md-1">
                                    <label class="form-label small fw-bold">Currency</label>
                                    <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Text="--Select--" Value="0" />
                                        <asp:ListItem Text="BDT" Value="BDT" Selected="True" />
                                        <asp:ListItem Text="USD" Value="USD" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-1">
                                    <label class="form-label small fw-bold">Loss %</label>
                                    <asp:TextBox ID="txtLoss" runat="server" CssClass="form-control form-control-sm" Text="5" onkeyup="calculateRowTotal()"></asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label small fw-bold">Total Cost</label>
                                    <asp:TextBox ID="txtTotalCostInput" runat="server" CssClass="form-control form-control-sm" Text="1.05" ReadOnly="true"></asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <asp:Button ID="btnAdd" runat="server" CssClass="btn btn-success btn-sm w-100" Text="Add" OnClick="btnAdd_Click" />
                                </div>
                            </div>

                            <!-- Data Table: Materials for the currently selected Item only -->
                            <div class="table-responsive mt-3">
                                <asp:GridView ID="gvQuotationDetails" runat="server" CssClass="table table-bordered table-striped table-sm text-center align-middle" AutoGenerateColumns="False" DataKeyNames="SlNo" EmptyDataText="No material added for this item yet." OnRowDeleting="gvQuotationDetails_RowDeleting">
                                    <HeaderStyle CssClass="table-dark-custom" />
                                    <Columns>
                                        <asp:BoundField DataField="SlNo" HeaderText="Sl No" />
                                        <asp:BoundField DataField="RawMaterialID" HeaderText="Material ID" ItemStyle-Width="80px"/>
                                        <asp:BoundField DataField="RawMaterialName" HeaderText="Raw Material Name" />
                                        <asp:BoundField DataField="ReqQty" HeaderText="Req. Qty" />
                                        <asp:BoundField DataField="Unit" HeaderText="Unit" />
                                        <asp:BoundField DataField="UnitPrice" HeaderText="Unit Price" />
                                        <asp:BoundField DataField="Currency" HeaderText="Currency" />
                                        <asp:BoundField DataField="Loss" HeaderText="Loss%" />
                                        <asp:BoundField DataField="TotalCost" HeaderText="Total Cost" />
                                        <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnEditDetail" runat="server" CssClass="btn btn-primary btn-sm px-2 py-0" Text="Edit" CommandName="EditDetail" CommandArgument='<%# Container.DataItemIndex %>' />
                                                <asp:Button ID="btnDeleteDetail" runat="server" CssClass="btn btn-danger btn-sm px-2 py-0" Text="X" CommandName="Delete" CausesValidation="false" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>

                            <!-- Per-Item Summary -->
                            <div class="row justify-content-end mt-3">
                                <div class="col-md-4">
                                    <div class="input-group input-group-sm">
                                        <span class="input-group-text fw-bold w-50">This Item's Total Cost</span>
                                        <asp:TextBox ID="txtItemTotalCost" runat="server" CssClass="form-control text-end" Text="0.00" ReadOnly="true"></asp:TextBox>
                                        <span class="input-group-text">BDT</span>
                                    </div>
                                </div>
                            </div>

                        </fieldset>

                        <!-- ========================================== -->
                        <!-- Quotation Grand Total Section (all Items combined) -->
                        <!-- ========================================== -->
                        <fieldset class="border p-3 rounded mb-4">
                            <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">Quotation Summary</legend>
                            <div class="row justify-content-end">
                                <div class="col-md-4">
                                    <div class="input-group input-group-sm mb-1">
                                        <span class="input-group-text fw-bold w-50">Total Cost (All Items)</span>
                                        <asp:TextBox ID="txtTotalCostSum" runat="server" CssClass="form-control text-end" Text="0.00" ReadOnly="true"></asp:TextBox>
                                        <span class="input-group-text">BDT</span>
                                    </div>
                                    <div class="input-group input-group-sm mb-1">
                                        <span class="input-group-text fw-bold w-50">Others Cost</span>
                                        <asp:TextBox ID="txtOthersCost" runat="server" CssClass="form-control text-end" Text="0.00"></asp:TextBox>
                                        <span class="input-group-text">BDT</span>
                                    </div>
                                    <div class="input-group input-group-sm">
                                        <span class="input-group-text fw-bold w-50 bg-secondary text-white">G. Total Cost</span>
                                        <asp:TextBox ID="txtGTotalCost" runat="server" CssClass="form-control text-end fw-bold" Text="0.00" ReadOnly="true"></asp:TextBox>
                                        <span class="input-group-text bg-secondary text-white">BDT</span>
                                    </div>
                                </div>
                            </div>
                        </fieldset>

                        <!-- Bottom Action Buttons -->
                        <div class="d-flex gap-2">
                            <asp:Button ID="btnSave" runat="server" CssClass="btn btn-success px-4" Text="Save" OnClick="btnSave_Click" />
                            <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel" OnClick="btnCancel_Click" />
                            <asp:Button ID="btnBackToList" runat="server" CssClass="btn btn-info px-4 text-white" Text="Back to List" OnClick="btnBackToList_Click" />
                        </div>

                    </div>
                </div>
            </asp:Panel>

        </div>
    </form>
<script type="text/javascript">
    function calculateRowTotal() {
        var qty = parseFloat(document.getElementById('<%= txtReqQty.ClientID %>').value) || 0;
        var unitPrice = parseFloat(document.getElementById('<%= txtUnitPrice.ClientID %>').value) || 0;
        var lossPercent = parseFloat(document.getElementById('<%= txtLoss.ClientID %>').value) || 0;

        var subTotal = qty * unitPrice;
        var totalCost = subTotal + (subTotal * (lossPercent / 100));

        document.getElementById('<%= txtTotalCostInput.ClientID %>').value = totalCost.toFixed(2);
    }
</script>

</body>
</html>
