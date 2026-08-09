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
    <script type="text/javascript">
        // পেজ লোড হওয়ার পর স্ক্রোল পজিশন সেট করা
        window.onload = function () {
            var scrollPos = document.getElementById('<%= hfScrollPosition.ClientID %>').value;
        if (scrollPos) {
            window.scrollTo(0, scrollPos);
        }
    };

    // সেভ বা আপডেট বাটনে ক্লিক করার সময় বর্তমান স্ক্রোল পজিশন সেভ করা
    window.onscroll = function () {
        var scrollPos = window.pageYOffset || document.documentElement.scrollTop;
        document.getElementById('<%= hfScrollPosition.ClientID %>').value = scrollPos;
        };
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfScrollPosition" runat="server" Value="0" />
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

                        <div class="col-md-7 ps-md-4 mt-4 mt-md-0">
                            <!-- হেডার এবং সার্চ বক্সের জন্য ফ্লেক্স লেআউট -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h6 class="text-primary fw-bold m-0">Unit List</h6>
        
                                <!-- সার্চ বক্স -->
                                <div class="input-group input-group-sm w-50">
                                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search units..." AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                                    <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-outline-primary" Text="Search" OnClick="btnSearch_Click" />
                                </div>
                            </div>

                            <div class="table-responsive">
                                <asp:GridView ID="gvRawMaterial" runat="server" CssClass="table table-bordered table-striped table-hover align-middle" AutoGenerateColumns="False" EmptyDataText="No units found." OnSelectedIndexChanged="gvRawMaterial_SelectedIndexChanged" DataKeyNames="UnitID">
                                    <Columns>
                                        <asp:BoundField DataField="UnitID" HeaderText="ID"/>
                                        <asp:BoundField DataField="UnitName" HeaderText="Unit Name" />
                                        <asp:BoundField DataField="ShortCode" HeaderText="Short Code" />
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
