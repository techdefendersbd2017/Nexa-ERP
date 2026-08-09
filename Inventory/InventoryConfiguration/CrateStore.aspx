<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CrateStore.aspx.cs" Inherits="Nexa_ERP.Inventory.InventoryConfiguration.CrateStore" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Crate Store Setup - Nexa ERP</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background-color: #f8f9fa; font-size: 14px; }
        .card-header-custom { background-color: #1f4e78; color: white; font-weight: bold; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid my-4 px-4">
            <div class="card shadow-sm">
                
                <!-- Card Header -->
                <div class="card-header card-header-custom py-2">
                    <h5 class="mb-0">Crate Store Setup</h5>
                </div>
                
                <div class="card-body">
                    
                    <!-- Feedback Message Banner -->
                    <asp:Label ID="lblMessage" runat="server" CssClass="mb-3 d-block" EnableViewState="false"></asp:Label>

                    <div class="row">
                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-5 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Crate Store</h6>
                            
                            <div class="mb-3">
                                <label class="form-label fw-bold">Store ID</label>
                                <asp:TextBox ID="txtStoreId" runat="server" CssClass="form-control" placeholder="Store ID Auto Generated" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Branch Name</label>
                                <asp:DropDownList ID="ddlBranchName" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlBranchName_SelectedIndexChanged">
                                    <asp:ListItem Text="-- Select Branch --" Value="0" />
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvBranchName" runat="server" ControlToValidate="ddlBranchName" 
                                    InitialValue="" ErrorMessage="Branch selection is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Store Name</label>
                                <asp:TextBox ID="txtStoreName" runat="server" CssClass="form-control" placeholder="Enter Store Name (e.g., Cratify, Apex)"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvStoreName" runat="server" ControlToValidate="txtStoreName" 
                                    ErrorMessage="Store name is required." CssClass="text-danger small" Display="Dynamic" />
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Active" Value="Active" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="d-flex gap-2">
                                <asp:Button ID="btnSaveStoreName" runat="server" CssClass="btn btn-success px-4" Text="Save" OnClick="btnSaveStoreName_Click" />
                                <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false" />
                            </div>
                        </div>

                        <!-- ডান সাইড: গ্রিড ভিউ লিস্ট -->
                        <div class="col-md-7 ps-md-4 mt-4 mt-md-0">
                            <h6 class="text-primary fw-bold mb-3">Crate Store List</h6>
                            <div class="table-responsive">
                                <asp:GridView ID="gvCrateStore" runat="server" CssClass="table table-bordered table-striped table-hover align-middle" AutoGenerateColumns="False" EmptyDataText="No store records found." OnSelectedIndexChanged="gvCrateStore_SelectedIndexChanged">
                                    <Columns>
                                        <asp:BoundField DataField="StoreId" HeaderText="ID" />
                                        <asp:BoundField DataField="StoreName" HeaderText="Store Name" />
                                        <asp:BoundField DataField="Status" HeaderText="Status" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-sm btn-primary" Text="Edit" CommandName="Select" CausesValidation="false" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </form>
</body>
</html>