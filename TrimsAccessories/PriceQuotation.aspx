<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PriceQuotation.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.PriceQuotation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Price Quotation</title>
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container my-4">
            
            <!-- Main Card Container -->
            <div class="card shadow-sm">
                <div class="card-header card-header-custom text-center py-2">
                    <h5 class="mb-0">Price Quotation</h5>
                </div>
                <div class="card-body">
                    
                    <!-- Master Info Section -->
                    <fieldset class="border p-3 rounded mb-4">
                        <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">Master Info</legend>
                        
                        <div class="row g-3">
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Customer</label>
                                <asp:TextBox ID="txtCustomer" runat="server" CssClass="form-control form-control-sm" Text="RS Packaging"></asp:TextBox>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Quotation Code</label>
                                <asp:TextBox ID="txtQuotationCode" runat="server" CssClass="form-control form-control-sm" Text="QT-0002"></asp:TextBox>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Create Date</label>
                                <asp:TextBox ID="txtCreateDate" runat="server" CssClass="form-control form-control-sm" Text="26-07-26"></asp:TextBox>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label fw-bold">Item Category</label>
                                <asp:TextBox ID="txtItemCategory" runat="server" CssClass="form-control form-control-sm" Text="ACCESSORIES"></asp:TextBox>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Sub Category</label>
                                <asp:TextBox ID="txtSubCategory" runat="server" CssClass="form-control form-control-sm" Text="POLY"></asp:TextBox>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Quotation Name</label>
                                <div class="input-group input-group-sm">
                                    <asp:TextBox ID="txtQuotationName" runat="server" CssClass="form-control" Text="RSP-SINGLE POLY"></asp:TextBox>
                                    <asp:TextBox ID="txtSameAs" runat="server" CssClass="form-control" placeholder="Same As"></asp:TextBox>
                                    <asp:Button ID="btnCopy" runat="server" CssClass="btn btn-primary" Text="Copy" />
                                </div>
                            </div>

                            <div class="col-md-4">
                                <label class="form-label fw-bold">Item Name</label>
                                <asp:TextBox ID="txtItemName" runat="server" CssClass="form-control form-control-sm" Text="Single Poly"></asp:TextBox>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Unit & Qty</label>
                                <div class="input-group input-group-sm">
                                    <asp:TextBox ID="txtQty" runat="server" CssClass="form-control" Text="1"></asp:TextBox>
                                    <asp:DropDownList ID="ddlItemUnit" runat="server" CssClass="form-control" >
                                        <asp:ListItem Text="Select" Value="0" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Status</label>
                                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control" >
                                        <asp:ListItem Text="Active" Value="1" />
                                        <asp:ListItem Text="Inactive" Value="2" />
                                    </asp:DropDownList>
                            </div>
                        </div>
                    </fieldset>

                    <!-- Item Details Section -->
                    <fieldset class="border p-3 rounded mb-4">
                        <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">Item Details</legend>
                        
                        <div class="row g-2 align-items-end bg-light p-2 rounded">
                            <div class="col-md-3">
                                <label class="form-label small fw-bold">Raw Material</label>
                                <asp:TextBox ID="txtRawMaterial" runat="server" CssClass="form-control form-control-sm" Text="LLDPE Dana"></asp:TextBox>
                            </div>
                            <div class="col-md-1">
                                <label class="form-label small fw-bold">Req. Qty</label>
                                <asp:TextBox ID="txtReqQty" runat="server" CssClass="form-control form-control-sm" Text="1"></asp:TextBox>
                            </div>
                            <div class="col-md-1">
                                <label class="form-label small fw-bold">Per</label>
                                <asp:TextBox ID="txtPer" runat="server" CssClass="form-control form-control-sm" Text="Pcs"></asp:TextBox>
                            </div>
                            <div class="col-md-1">
                                <label class="form-label small fw-bold">Unit Price</label>
                                <asp:TextBox ID="txtUnitPrice" runat="server" CssClass="form-control form-control-sm" Text="1"></asp:TextBox>
                            </div>
                            <div class="col-md-1">
                                <label class="form-label small fw-bold">Currency</label>
                                <asp:TextBox ID="txtCurrency" runat="server" CssClass="form-control form-control-sm" Text="BDT"></asp:TextBox>
                            </div>
                            <div class="col-md-1">
                                <label class="form-label small fw-bold">Loss %</label>
                                <asp:TextBox ID="txtLoss" runat="server" CssClass="form-control form-control-sm" Text="5%"></asp:TextBox>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label small fw-bold">Total Cost</label>
                                <asp:TextBox ID="txtTotalCostInput" runat="server" CssClass="form-control form-control-sm" Text="1.05"></asp:TextBox>
                            </div>
                            <div class="col-md-2">
                                <asp:Button ID="btnAdd" runat="server" CssClass="btn btn-success btn-sm w-100" Text="Add" />
                            </div>
                        </div>

                        <!-- Data Table -->
                        <div class="table-responsive mt-3">
                            <asp:GridView ID="gvQuotationDetails" runat="server" CssClass="table table-bordered table-striped table-sm text-center align-middle" AutoGenerateColumns="False">
                                <HeaderStyle CssClass="table-dark-custom" />
                                <Columns>
                                    <asp:BoundField DataField="SlNo" HeaderText="Sl No" />
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
                                            <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-primary btn-sm px-2 py-0" Text="Edit" />
                                            <asp:Button ID="btnDelete" runat="server" CssClass="btn btn-danger btn-sm px-2 py-0" Text="X" />
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>

                        <!-- Summary Totals Section -->
                        <div class="row justify-content-end mt-3">
                            <div class="col-md-4">
                                <div class="input-group input-group-sm mb-1">
                                    <span class="input-group-text fw-bold w-50">Total Cost</span>
                                    <asp:TextBox ID="txtTotalCostSum" runat="server" CssClass="form-control text-end" Text="6.65" ReadOnly="true"></asp:TextBox>
                                    <span class="input-group-text">BDT</span>
                                </div>
                                <div class="input-group input-group-sm mb-1">
                                    <span class="input-group-text fw-bold w-50">Others Cost</span>
                                    <asp:TextBox ID="txtOthersCost" runat="server" CssClass="form-control text-end" Text="2.00"></asp:TextBox>
                                    <span class="input-group-text">BDT</span>
                                </div>
                                <div class="input-group input-group-sm">
                                    <span class="input-group-text fw-bold w-50 bg-secondary text-white">G. Total Cost</span>
                                    <asp:TextBox ID="txtGTotalCost" runat="server" CssClass="form-control text-end fw-bold" Text="8.65" ReadOnly="true"></asp:TextBox>
                                    <span class="input-group-text bg-secondary text-white">BDT</span>
                                </div>
                            </div>
                        </div>

                    </fieldset>

                    <!-- Bottom Action Buttons -->
                    <div class="d-flex gap-2">
                        <asp:Button ID="btnSave" runat="server" CssClass="btn btn-success px-4" Text="Save" />
                        <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel" />
                        <asp:Button ID="btnBackToList" runat="server" CssClass="btn btn-info px-4 text-white" Text="Back to List" />
                    </div>

                </div>
            </div>

        </div>
    </form>
</body>
</html>