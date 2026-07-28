<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UnitSetup.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.CompanyInformation.UnitSetup" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Unit Setup</title>
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
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid my-4 px-4">
            <div class="card shadow-sm">
                <!-- হেডার -->
                <div class="card-header card-header-custom py-2">
                    <h5 class="mb-0">Unit Setup</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-5 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Unit</h6>
                            
                            <div class="mb-3">
                                <label class="form-label fw-bold">Unit ID</label>
                                <asp:TextBox ID="txtUnitID" runat="server" CssClass="form-control" placeholder="Auto Generated" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Unit Name <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtUnitName" runat="server" CssClass="form-control" placeholder="e.g. Pcs, Kg, Yard, Roll"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Short Code</label>
                                <asp:TextBox ID="txtShortCode" runat="server" CssClass="form-control" placeholder="e.g. PCS, KG"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Active" Value="Active" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="d-flex gap-2 mt-4">
                                <asp:Button ID="btnSave" runat="server" CssClass="btn btn-success px-4" Text="Save" OnClick="btnSave_Click" />
                                <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel" OnClick="btnCancel_Click" />
                            </div>
                        </div>

                        <!-- ডান সাইড: গ্রিড ভিউ / টেবিল -->
                        <div class="col-md-7 ps-md-4 mt-4 mt-md-0">
                            <h6 class="text-primary fw-bold mb-3">Unit List</h6>
                            <div class="table-responsive">
                                <asp:GridView ID="gvUnit" runat="server" DataKeyNames="UnitID" CssClass="table table-bordered table-striped table-hover align-middle text-center" AutoGenerateColumns="False" EmptyDataText="No records found." OnSelectedIndexChanged="gvUnit_SelectedIndexChanged">
                                    <Columns>
                                        <asp:BoundField DataField="SlNo" HeaderText="Sl No" />
                                        <asp:BoundField DataField="UnitName" HeaderText="Unit Name" />
                                        <asp:BoundField DataField="ShortCode" HeaderText="Short Code" />
                                        <asp:BoundField DataField="Status" HeaderText="Status" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-sm btn-primary px-3" Text="Edit" CommandName="Select" />
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