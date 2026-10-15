<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CompanyInformation.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.CompanyInformation" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Company Information - NexaERP</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        body { background-color: #f8f9fa; font-size: 14px; }
        .card-header-custom { background-color: #1f4e78; color: white; font-weight: bold; }
        .wrap-cell { word-break: break-all; max-width: 200px; }
        .logo-preview { width: 80px; height: 80px; object-fit: cover; border-radius: 6px; border: 1px solid #ced4da; }
    </style>
    <script src="../Assets/CompanyInformationHR.js"></script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <asp:HiddenField ID="hfUserId" runat="server" />
        <asp:HiddenField ID="hfScrollPosition" runat="server" Value="0" />

        <div class="container-fluid my-4 px-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-building-fill fs-3 text-primary"></i>
                    <div>
                        <h4 class="mb-0 fw-bold">Company Information</h4>
                        <small class="text-muted">ERP Configuration &rsaquo; Company Information &rsaquo; Company</small>
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
                    <h5 class="mb-0"><i class="bi bi-building"></i> Company Setup & Management</h5>
                </div>

                <div class="card-body">
                    <div class="row">
                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-6 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Company Details</h6>

                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtCompanyCode" Text="Company Code" CssClass="form-label fw-bold small" />
                                    <asp:TextBox ID="txtCompanyCode" runat="server" CssClass="form-control" Text="0" ReadOnly="True" />
                                </div>
                                <div class="col-md-8 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtShortName" CssClass="form-label fw-bold small">
                                        Short Name <span class="text-danger">*</span>
                                    </asp:Label>
                                    <asp:TextBox ID="txtShortName" runat="server" CssClass="form-control" MaxLength="50" placeholder="Enter Short Name" />
                                    <asp:RequiredFieldValidator ID="rfvShort" runat="server"
                                        ControlToValidate="txtShortName" Display="Dynamic" CssClass="text-danger small"
                                        ErrorMessage="Short Name is required." ValidationGroup="CompanyInfo" />
                                </div>
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtCompanyName" CssClass="form-label fw-bold small">
                                    Company Name <span class="text-danger">*</span>
                                </asp:Label>
                                <asp:TextBox ID="txtCompanyName" runat="server" CssClass="form-control" MaxLength="150" placeholder="Enter Company Name" />
                                <asp:RequiredFieldValidator ID="rfvName" runat="server"
                                    ControlToValidate="txtCompanyName" Display="Dynamic" CssClass="text-danger small"
                                    ErrorMessage="Company Name is required." ValidationGroup="CompanyInfo" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtCompanyBangla" Text="Company Bangla" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtCompanyBangla" runat="server" CssClass="form-control" MaxLength="200" placeholder="কোম্পানির নাম (বাংলা)" />
                            </div>

                            <!-- লোগো আপলোড ও প্রিভিউ -->
                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="fuLogo" Text="Company Logo (Binary)" CssClass="form-label fw-bold small" />
                                <div class="d-flex align-items-center gap-3">
                                    <asp:FileUpload ID="fuLogo" runat="server" CssClass="form-control" accept=".jpg,.jpeg,.png,.bmp" />
                                    <asp:Image ID="imgLogoPreview" runat="server" CssClass="logo-preview" ImageUrl="~/Images/no-image.png" />
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtPhone" Text="Phone Number" CssClass="form-label fw-bold small" />
                                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" MaxLength="50" placeholder="Enter Phone No" />
                                </div>
                                <div class="col-md-6 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtEmail" Text="E-Mail" CssClass="form-label fw-bold small" />
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" MaxLength="150" TextMode="Email" placeholder="example@domain.com" />
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

                            <h6 class="text-primary fw-bold mt-4 mb-3">Overtime & Attendance Settings</h6>
                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtOtDeductOrg" Text="OT Deduction Org" CssClass="form-label fw-bold small" />
                                    <asp:TextBox ID="txtOtDeductOrg" runat="server" CssClass="form-control" MaxLength="20" />
                                </div>
                                <div class="col-md-4 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtOtDeductComp" Text="OT Deduction Com." CssClass="form-label fw-bold small" />
                                    <asp:TextBox ID="txtOtDeductComp" runat="server" CssClass="form-control" MaxLength="20" />
                                </div>
                                <div class="col-md-4 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtExtOtStart" Text="Ext. OT Start" CssClass="form-label fw-bold small" />
                                    <asp:TextBox ID="txtExtOtStart" runat="server" CssClass="form-control" MaxLength="20" />
                                </div>
                                <div class="col-md-4 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtEarlyDeduct" Text="Early Deduct Start" CssClass="form-label fw-bold small" />
                                    <asp:TextBox ID="txtEarlyDeduct" runat="server" CssClass="form-control" MaxLength="20" />
                                </div>
                                <div class="col-md-4 mb-3">
                                    <asp:Label runat="server" AssociatedControlID="txtOutTimeStart" Text="Out Time Start" CssClass="form-label fw-bold small" />
                                    <asp:TextBox ID="txtOutTimeStart" runat="server" CssClass="form-control" MaxLength="20" />
                                </div>
                            </div>

                            <div class="d-flex gap-2">
                                <asp:Button ID="btnSave" runat="server"
                                    Text="Save" CssClass="btn btn-success px-4" OnClick="btnSave_Click" ValidationGroup="CompanyInfo" OnClientClick="saveScrollPos();" />
                                <asp:Button ID="btnClear" runat="server"
                                    Text="Refresh" CssClass="btn btn-secondary px-4" OnClick="btnClear_Click" CausesValidation="false" OnClientClick="saveScrollPos();" />
                            </div>
                        </div>

                        <!-- ডান সাইড: গ্রিড ভিউ -->
                        <div class="col-md-6 ps-md-4 mt-4 mt-md-0">
                            <h6 class="text-primary fw-bold mb-3">Company List</h6>
                            <div class="table-responsive">
                                <asp:GridView ID="gvCompany"
                                    runat="server"
                                    CssClass="table table-bordered table-striped table-hover align-middle"
                                    AutoGenerateColumns="False"
                                    DataKeyNames="Company_Code"
                                    Width="100%"
                                    EmptyDataText="No companies found."
                                    OnSelectedIndexChanged="gvCompany_SelectedIndexChanged">

                                    <Columns>
                                        <asp:BoundField DataField="Company_Code" HeaderText="Code" />
                                        <asp:TemplateField HeaderText="Logo">
                                            <ItemTemplate>
                                                <asp:Image ID="imgGridLogo" runat="server"
                                                    ImageUrl='<%# Eval("Logo") != DBNull.Value ? "data:image/png;base64," + Convert.ToBase64String((byte[])Eval("Logo")) : "~/Images/no-image.png" %>'
                                                    Width="40" Height="40" CssClass="rounded object-fit-cover border" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="Company_Name" HeaderText="Name" />
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
