<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GroupInformation.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.CompanyInformation.GroupInformation" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Group Information - NexaERP</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />

    <style>
        body { background-color: #f8f9fa; font-size: 14px; }
        .card-header-custom { background-color: #1f4e78; color: white; font-weight: bold; }
        .wrap-cell { word-break: break-all; max-width: 200px; }

        /* Select2 - rounded, clean look */
        .select2-container--bootstrap-5 .select2-selection {
            border-radius: 8px !important;
            border: 1px solid #ced4da !important;
        }
        .select2-container--bootstrap-5 .select2-selection:focus,
        .select2-container--bootstrap-5.select2-container--focus .select2-selection {
            border-color: #86b7fe !important;
            box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15) !important;
        }
        .select2-container--bootstrap-5 .select2-dropdown {
            border-radius: 8px !important;
            border: 1px solid #ced4da !important;
            overflow: hidden;
        }
        .select2-container--bootstrap-5 .select2-search--dropdown .select2-search__field {
            border-radius: 6px !important;
            border: 1px solid #ced4da !important;
            padding: 6px 10px !important;
        }
        .select2-container--bootstrap-5 .select2-results__option--highlighted[aria-selected] {
            background-color: #1f4e78 !important;
        }
    </style>

    <script type="text/javascript">
        // পেজ লোড হওয়ার পর সেভ করা scroll position এ ফিরে যাওয়া
        window.onload = function () {
    var hf = document.getElementById('<%= hfScrollPosition.ClientID %>');
    if (hf && hf.value && parseInt(hf.value) > 0) {
        window.scrollTo(0, parseInt(hf.value));
    }
};

// বাটনে ক্লিক করার মুহূর্তে বর্তমান scroll position hidden field এ সেভ করা
function saveScrollPos() {
            document.getElementById('<%= hfScrollPosition.ClientID %>').value =
                (window.pageYOffset || document.documentElement.scrollTop);
        }
    </script>

    <!-- jQuery & Select2 JS -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        $(document).ready(function () {
            $('.search-dropdown').select2({
                theme: 'bootstrap-5',
                width: '100%',
                placeholder: "Search"
            });

            $('.search-dropdown').on('select2:open', function () {
                setTimeout(function () {
                    var searchField = document.querySelector('.select2-container--open .select2-search__field');
                    if (searchField) {
                        searchField.focus();
                    }
                }, 0);
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <asp:HiddenField ID="hfUserId" runat="server" />
        <asp:HiddenField ID="hfScrollPosition" runat="server" Value="0" />

        <div class="container-fluid my-4 px-4">
            
            <!-- Page Heading -->
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div class="d-flex align-items-center gap-2">
                    <i class="bi bi-diagram-3-fill fs-3 text-primary"></i>
                    <div>
                        <h4 class="mb-0 fw-bold">Group Information</h4>
                        <small class="text-muted">ERP Configuration &rsaquo; Company Information &rsaquo; Group</small>
                    </div>
                </div>
                <span class="badge bg-secondary p-2">
                    <asp:Label ID="Label1" runat="server" Text=""></asp:Label>
                </span>
            </div>

            <div class="card shadow-sm">
                <div class="card-header card-header-custom py-2">
                    <h5 class="mb-0"><i class="bi bi-building"></i> Group Setup & Management</h5>
                </div>

                <div class="card-body">
                    <div class="row">

                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-5 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Group Details</h6>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtGroupID" Text="Group ID" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtGroupID" runat="server" CssClass="form-control" Text="0" ReadOnly="True" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtGroup" CssClass="form-label fw-bold small">
                                    Group Name <span class="text-danger">*</span>
                                </asp:Label>
                                <asp:TextBox ID="txtGroup" runat="server" CssClass="form-control" MaxLength="150" placeholder="Enter Group Name" />
                                <asp:RequiredFieldValidator ID="rfvGroup" runat="server"
                                    ControlToValidate="txtGroup" Display="Dynamic" CssClass="text-danger small"
                                    ErrorMessage="Group Name is required." ValidationGroup="GroupInfo" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtPrefix" Text="Prefix" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtPrefix" runat="server" CssClass="form-control" MaxLength="50" placeholder="Enter Prefix" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtEmail" Text="E-Mail" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" MaxLength="150" TextMode="Email" placeholder="example@domain.com" />
                                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                    ControlToValidate="txtEmail" Display="Dynamic" CssClass="text-danger small"
                                    ErrorMessage="Enter a valid email address."
                                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                                    ValidationGroup="GroupInfo" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtPhone" Text="Phone No" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" MaxLength="50" placeholder="Enter Phone No" />
                                <asp:RegularExpressionValidator ID="revPhone" runat="server"
                                    ControlToValidate="txtPhone" Display="Dynamic" CssClass="text-danger small"
                                    ErrorMessage="Enter a valid phone number."
                                    ValidationExpression="^[0-9+\-\s()]{6,20}$"
                                    ValidationGroup="GroupInfo" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtWeb" Text="Web" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtWeb" runat="server" CssClass="form-control" MaxLength="150" placeholder="https://example.com" />
                                <asp:RegularExpressionValidator ID="revWeb" runat="server"
                                    ControlToValidate="txtWeb" Display="Dynamic" CssClass="text-danger small"
                                    ErrorMessage="Enter a valid website URL."
                                    ValidationExpression="^(https?:\/\/)?([\w\-]+\.)+[\w\-]{2,}(\/\S*)?$"
                                    ValidationGroup="GroupInfo" />
                            </div>

                            <div class="mb-3">
                                <asp:Label runat="server" AssociatedControlID="txtAddress" Text="Address" CssClass="form-label fw-bold small" />
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="300" placeholder="Enter Address" />
                            </div>

                            <div class="mb-3 form-check">
                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" Checked="True" />
                                <asp:Label runat="server" AssociatedControlID="chkIsActive" Text="Is Active?" CssClass="form-check-label fw-bold small" />
                            </div>

                            <div class="d-flex gap-2">
                                <asp:Button ID="btnSave" runat="server"
                                    Text="Save" CssClass="btn btn-success px-4" OnClick="btnSave_Click" ValidationGroup="GroupInfo" OnClientClick="saveScrollPos();" />
                                <asp:Button ID="btnClear" runat="server"
                                    Text="Clear" CssClass="btn btn-secondary px-4" OnClick="btnClear_Click" CausesValidation="false" OnClientClick="saveScrollPos();" />
                            </div>
                        </div>

                        <!-- ডান সাইড: গ্রিড ভিউ -->
                        <div class="col-md-7 ps-md-4 mt-4 mt-md-0">
                            <h6 class="text-primary fw-bold mb-3">Group List</h6>
                            <div class="table-responsive">
                                <asp:GridView ID="gvGroup"
                                    runat="server"
                                    CssClass="table table-bordered table-striped table-hover align-middle"
                                    AutoGenerateColumns="False"
                                    DataKeyNames="Group_ID"
                                    Width="100%" 
                                    EmptyDataText="No groups found."
                                    OnSelectedIndexChanged="gvGroup_SelectedIndexChanged">

                                    <Columns>
                                        <asp:BoundField DataField="Group_ID" HeaderText="ID" />
                                        <asp:BoundField DataField="Group_Name" HeaderText="Group Name" />
                                        <asp:BoundField DataField="Prifix" HeaderText="Prefix" />
                                        <asp:BoundField DataField="E_Mail" HeaderText="E-Mail" />
                                        <asp:BoundField DataField="Phone_No" HeaderText="Phone" />
                                        <asp:BoundField DataField="Address" HeaderText="Address" ItemStyle-CssClass="wrap-cell" />
                                        <asp:CheckBoxField DataField="Is_Active" HeaderText="Status" />
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