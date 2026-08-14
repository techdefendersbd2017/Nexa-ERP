<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubCategory.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.MsterSetup.SubCategory" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Sub Category Setup</title>
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
                <div class="card-header card-header-custom py-2">
                    <h5 class="mb-0">Sub Category Setup</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-5 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Sub Category</h6>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Sub Category ID</label>
                                <asp:TextBox ID="txtSubCategoryId" runat="server" CssClass="form-control" placeholder="Sub Category ID Auto Generated" ReadOnly="true"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Sub Category Name</label>
                                <asp:TextBox ID="txtSubCategoryName" runat="server" CssClass="form-control" placeholder="Enter Sub Category Name"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Item Category</label>
                                <asp:DropDownList ID="ddlItemCategory" runat="server" CssClass="form-select"></asp:DropDownList>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Active" Value="Active" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="d-flex gap-2">
                                <asp:Button ID="btnSave" runat="server" CssClass="btn btn-success px-4" Text="Save" OnClick="btnSave_Click" />
                                <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel" OnClick="btnRefresh_Click" />
                            </div>
                        </div>

                        <!-- ডান সাইড: গ্রিড ভিউ -->
                        <div class="col-md-7 ps-md-4 mt-4 mt-md-0">
                            <h6 class="text-primary fw-bold mb-3">Sub Category List</h6>
                            <div class="table-responsive">
                                <asp:GridView ID="gvSubCategory" runat="server" CssClass="table table-bordered table-striped table-hover align-middle" AutoGenerateColumns="False" EmptyDataText="No sub categories found." OnSelectedIndexChanged="gvSubCategory_SelectedIndexChanged">
                                    <Columns>
                                        <asp:BoundField DataField="SubCategoryId" HeaderText="ID"/>
                                        <asp:BoundField DataField="CategoryName" HeaderText="Item Category" />
                                        <asp:BoundField DataField="SubCategoryName" HeaderText="Sub Category Name" />
                                        <asp:BoundField DataField="Status" HeaderText="Status" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-sm btn-primary" Text="Edit" CommandName="Select" />                                                
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