<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HRBranchInformation.aspx.cs" Inherits="Nexa_ERP.MasterConfiguration.OrganizationMaster.HRBranchInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Branch Information - NexaERP</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        body { background-color: #f8f9fa; font-size: 14px; }
        .card-header-custom { background-color: #1f4e78; color: white; font-weight: bold; }
        .wrap-cell { word-break: break-all; max-width: 200px; }
        .logo-preview { width: 80px; height: 80px; object-fit: cover; border-radius: 6px; border: 1px solid #ced4da; }
    </style>

    <script type="text/javascript">
        window.onload = function () {
            var hf = document.getElementById('<%= hfScrollPosition.ClientID %>');
            if (hf && hf.value && parseInt(hf.value) > 0) {
                window.scrollTo(0, parseInt(hf.value));
            }
        };

        function saveScrollPos() {
            document.getElementById('<%= hfScrollPosition.ClientID %>').value =
                (window.pageYOffset || document.documentElement.scrollTop);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <asp:HiddenField ID="hfUserId" runat="server" />
        <asp:HiddenField ID="hfScrollPosition" runat="server" Value="0" />

        <div class="container-fluid my-4 px-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-shop fs-3 text-primary"></i>
                    <div>
                        <h4 class="mb-0 fw-bold">Branch Information</h4>
                        <small class="text-muted">ERP Configuration &rsaquo; Company Information &rsaquo; Branch</small>
                    </div>
                </div>
                <span class="badge bg-secondary p-2">
                    <asp:Label ID="Label1" runat="server" Text=""></asp:Label>
                </span>
            </div>

            <asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="alert alert-success py-2">
                <asp:Label ID="lblMsg" runat="server" />
            </asp:Panel>

            <div class="card shadow-sm">
                <div class="card-header card-header-custom py-2">
                    <h5 class="mb-0"><i class="bi bi-building"></i> Branch Setup & Management</h5>
                </div>

                <div class="card-body">
                    <div class="row">
                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-5 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Branch Details</h6>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtBranchCode" Text="Branch Code" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtBranchCode" runat="server" CssClass="form-control" Text="0" ReadOnly="True" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="ddlCompany" CssClass="form-label fw-bold small">
                                    Company Name <span class="text-danger">*</span>
                                </asp:Label>
                                <asp:DropDownList ID="ddlCompany" runat="server" CssClass="form-select" AppendDataBoundItems="true">
                                    <asp:ListItem Text="-- Select Company --" Value="" />
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvCompany" runat="server"
                                    ControlToValidate="ddlCompany" InitialValue="" Display="Dynamic" CssClass="text-danger small"
                                    ErrorMessage="Company is required." ValidationGroup="BranchInfo" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtBranchName" CssClass="form-label fw-bold small">
                                    Branch Name <span class="text-danger">*</span>
                                </asp:Label>
                                <asp:TextBox ID="txtBranchName" runat="server" CssClass="form-control" MaxLength="150" placeholder="Enter Branch Name" />
                                <asp:RequiredFieldValidator ID="rfvName" runat="server"
                                    ControlToValidate="txtBranchName" Display="Dynamic" CssClass="text-danger small"
                                    ErrorMessage="Branch Name is required." ValidationGroup="BranchInfo" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtBanglaName" Text="Bangla Name" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtBanglaName" runat="server" CssClass="form-control" MaxLength="200" placeholder="ব্রাঞ্চের নাম (বাংলা)" />
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtShortName" Text="Short Name" CssClass="form-label fw-bold small" />
                                    <asp:TextBox ID="txtShortName" runat="server" CssClass="form-control" MaxLength="50" placeholder="Enter Short Name" />
                                </div>
                                <div class="col-md-6 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtPhone" Text="Phone Number" CssClass="form-label fw-bold small" />
                                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" MaxLength="50" placeholder="Enter Phone No" />
                                </div>
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtEmail" Text="E-Mail" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" MaxLength="150" TextMode="Email" placeholder="example@domain.com" />
                            </div>

                            <!-- লোগো আপলোড ও প্রিভিউ -->
                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="fuLogo" Text="Branch Logo (Binary)" CssClass="form-label fw-bold small" />
                                <div class="d-flex align-items-center gap-3">
                                    <asp:FileUpload ID="fuLogo" runat="server" CssClass="form-control" accept=".jpg,.jpeg,.png,.bmp" />
                                    <asp:Image ID="imgLogoPreview" runat="server" CssClass="logo-preview" ImageUrl="~/Images/no-image.png" />
                                </div>
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtAddress" Text="Address" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="300" placeholder="Enter Address" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtBanglaAddress" Text="Bangla Address" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtBanglaAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="300" placeholder="ঠিকানা (বাংলা)" />
                            </div>

                            <div class="d-flex gap-2">
                                <asp:Button ID="btnSave" runat="server"
                                    Text="Save" CssClass="btn btn-success px-4" OnClick="btnSave_Click" ValidationGroup="BranchInfo" OnClientClick="saveScrollPos();" />
                                <asp:Button ID="btnClear" runat="server"
                                    Text="Refresh" CssClass="btn btn-secondary px-4" OnClick="btnClear_Click" CausesValidation="false" OnClientClick="saveScrollPos();" />
                            </div>
                        </div>

                        <!-- ডান সাইড: গ্রিড ভিউ -->
                        <div class="col-md-7 ps-md-4 mt-4 mt-md-0">
                            <h6 class="text-primary fw-bold mb-3">Branch List</h6>
                            <div class="table-responsive">
                                <asp:GridView ID="gvBranch"
                                    runat="server"
                                    CssClass="table table-bordered table-striped table-hover align-middle"
                                    AutoGenerateColumns="False"
                                    DataKeyNames="Branch_Code"
                                    Width="100%"
                                    EmptyDataText="No branches found."
                                    OnSelectedIndexChanged="gvBranch_SelectedIndexChanged">

                                    <Columns>
                                        <asp:BoundField DataField="Branch_Code" HeaderText="Code" />
                                        <asp:TemplateField HeaderText="Logo">
                                            <ItemTemplate>
                                                <asp:Image ID="imgGridLogo" runat="server"
                                                    ImageUrl='<%# Eval("Logo") != DBNull.Value ? "data:image/png;base64," + Convert.ToBase64String((byte[])Eval("Logo")) : "~/Images/no-image.png" %>'
                                                    Width="40" Height="40" CssClass="rounded object-fit-cover border" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="Branch_Name" HeaderText="Name" />
                                        <asp:BoundField DataField="Short_Name" HeaderText="Short Name" />
                                        <asp:BoundField DataField="Phone" HeaderText="Phone" />
                                        <asp:BoundField DataField="EMail" HeaderText="E-Mail" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnSelect" runat="server" CssClass="btn btn-sm btn-primary" Text="Select" CommandName="Select" OnClientClick="saveScrollPos();" />
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
