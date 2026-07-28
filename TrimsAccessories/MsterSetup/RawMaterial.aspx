<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RawMaterial.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.MsterSetup.RawMaterial" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Raw Material Setup</title>
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
                    <h5 class="mb-0">Raw Material Setup</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-5 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Raw Material</h6>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Raw Material ID</label>
                                <asp:TextBox ID="txtRawMaterialId" runat="server" CssClass="form-control" placeholder="Enter Raw Material ID"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Material Code</label>
                                <asp:TextBox ID="txtMaterialCode" runat="server" CssClass="form-control" placeholder="Enter Material Code"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Raw Material Name</label>
                                <asp:TextBox ID="txtRawMaterialName" runat="server" CssClass="form-control" placeholder="Enter Raw Material Name"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Unit</label>
                                <asp:DropDownList ID="ddlUnit" runat="server" CssClass="form-select">
                                </asp:DropDownList>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Standard Unit Price</label>
                                <asp:TextBox ID="txtUnitPrice" runat="server" CssClass="form-control" placeholder="0.00"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Currency</label>
                                <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="BDT" Value="BDT" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="USD" Value="USD"></asp:ListItem>
                                </asp:DropDownList>
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
                            <h6 class="text-primary fw-bold mb-3">Raw Material List</h6>
                            <div class="table-responsive">
                                <asp:GridView ID="gvRawMaterial" runat="server" CssClass="table table-bordered table-striped table-hover align-middle" AutoGenerateColumns="False" EmptyDataText="No raw materials found." OnSelectedIndexChanged="gvRawMaterial_SelectedIndexChanged">
                                    <Columns>
                                        <asp:BoundField DataField="RawMaterialId" HeaderText="ID"/>
                                        <asp:BoundField DataField="RawMaterialName" HeaderText="Raw Material Name" />
                                        <asp:BoundField DataField="Unit" HeaderText="Unit" />
                                        <asp:BoundField DataField="UnitPrice" HeaderText="Unit Price" />
                                        <asp:BoundField DataField="Currency" HeaderText="Currency" />
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