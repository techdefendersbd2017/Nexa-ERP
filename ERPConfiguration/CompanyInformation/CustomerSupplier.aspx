<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerSupplier.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.CompanyInformation.CustomerSupplier" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Customer & Supplier Setup</title>
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
                <!-- হেডার -->
                <div class="card-header card-header-custom py-2">
                    <h5 class="mb-0">Customer & Supplier Setup</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-5 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Information</h6>
                            
                            <div class="mb-3">
                                <label class="form-label fw-bold">Party ID</label>
                                <asp:TextBox ID="txtPartyID" runat="server" CssClass="form-control" placeholder="Auto Generated" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Party Type</label>
                                <asp:DropDownList ID="ddlPartyType" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="--Select Type--" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="Customer" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="Supplier" Value="3"></asp:ListItem>
                                    <asp:ListItem Text="Both" Value="3"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Party Name / Company</label>
                                <asp:TextBox ID="txtPartyName" runat="server" CssClass="form-control" placeholder="Enter Company Name"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Contact Person</label>
                                <asp:TextBox ID="txtContactPerson" runat="server" CssClass="form-control" placeholder="Enter Contact Person Name"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Phone / Mobile</label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="Enter Phone Number"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Email Address</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="Enter Email"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Address</label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Enter Full Address"></asp:TextBox>
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
                            <h6 class="text-primary fw-bold mb-3">Party List</h6>
                            <div class="table-responsive">
                                <asp:GridView ID="gvParty" runat="server" DataKeyNames="PartyID" CssClass="table table-bordered table-striped table-hover align-middle" AutoGenerateColumns="False" EmptyDataText="No records found." OnSelectedIndexChanged="gvParty_SelectedIndexChanged">
                                    <Columns>
                                        <asp:BoundField DataField="SlNo" HeaderText="Sl No" />
                                        <asp:BoundField DataField="PartyType" HeaderText="Type" />
                                        <asp:BoundField DataField="PartyName" HeaderText="Party Name" />
                                        <asp:BoundField DataField="Phone" HeaderText="Phone" />
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
