<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerSupplier.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.CompanyInformation.CustomerSupplier" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Customer & Supplier Setup</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />

    <style>
        body { background-color: #f8f9fa; font-size: 14px; }
        .card-header-custom { background-color: #1f4e78; color: white; font-weight: bold; }

        /* আপনার ছবির স্টাইল অনুযায়ী ড্রপডাউন ডিজাইন কাস্টমাইজেশন */
        .select2-container--bootstrap-5 .select2-selection {
            background-color: #ffffff !important;
            border: 1px solid #d9dde3 !important;
            border-radius: 0.6rem !important;
            min-height: 40px;
            padding: 4px 10px;
        }
        .select2-container--bootstrap-5 .select2-selection__rendered {
            color: #6c757d !important;   /* placeholder-এর মতো হালকা ধূসর রং */
            line-height: 26px !important;
        }

        /* উপরে-নিচে তীর আইকন (native select এর মতো দেখানোর জন্য) */
        .select2-container--bootstrap-5 .select2-selection__arrow {
            height: 38px !important;
        }
        .select2-container--bootstrap-5 .select2-selection__arrow b {
            border-color: #adb5bd transparent transparent transparent !important;
        }

        /* ড্রপডাউন পপআপ মেনু স্টাইল */
        .select2-container--bootstrap-5 .select2-dropdown {
            border-radius: 0.6rem !important;
            box-shadow: 0 0.5rem 1.2rem rgba(0, 0, 0, 0.1);
            border: 1px solid #d9dde3 !important;
            overflow: hidden;
            padding: 4px;
        }

        /* সার্চ বক্সের ডিজাইন - ম্যাগনিফাইং গ্লাস আইকনসহ */
        .select2-container--bootstrap-5 .select2-search--dropdown {
            padding: 8px;
        }
        .select2-container--bootstrap-5 .select2-search__field {
            border-radius: 2rem !important;
            border: 1px solid #d9dde3 !important;
            padding: 6px 12px 6px 34px !important;
            background-color: #fff;
            background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='16' height='16' fill='%236c757d' viewBox='0 0 16 16'><path d='M11.742 10.344a6.5 6.5 0 1 0-1.397 1.398h-.001c.03.04.062.078.098.115l3.85 3.85a1 1 0 0 0 1.415-1.414l-3.85-3.85a1.007 1.007 0 0 0-.115-.1zM12 6.5a5.5 5.5 0 1 1-11 0 5.5 5.5 0 0 1 11 0z'/></svg>");
            background-repeat: no-repeat;
            background-position: 10px center;
            background-size: 14px 14px;
        }

        /* ড্রপডাউন অপশন হোভার ও সিলেক্ট স্টাইল */
        .select2-container--bootstrap-5 .select2-results__options {
            padding: 2px;
        }
        .select2-container--bootstrap-5 .select2-results__option {
            border-radius: 0.4rem;
            padding: 8px 10px;
            margin-bottom: 2px;
        }
        .select2-container--bootstrap-5 .select2-results__option--highlighted[aria-selected] {
            background-color: #f1f3f5 !important;
            color: #212529 !important;
        }
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
                                <asp:DropDownList ID="ddlPartyType" runat="server" CssClass="form-select searchable-dropdown" AutoPostBack="true" data-placeholder="Select category" required="true" OnSelectedIndexChanged="ddlPartyType_SelectedIndexChanged">
                                    <asp:ListItem Text="Customer" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="Supplier" Value="2"></asp:ListItem>
                                    <asp:ListItem Text="Both" Value="3"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Party Name / Company</label><asp:Label ID="Label1" runat="server" Text="  *" style="color: #FF0000; font-size: large;"></asp:Label>
                                <asp:TextBox ID="txtPartyName" runat="server" CssClass="form-control" placeholder="Enter Company Name" required="true"></asp:TextBox>
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
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select searchable-dropdown" data-placeholder="Select status">
                                    <asp:ListItem Text="" Value=""></asp:ListItem>
                                    <asp:ListItem Text="Active" Value="Active"></asp:ListItem>
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
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h6 class="text-primary fw-bold mb-0">Party List</h6>
                                <div class="input-group input-group-sm" style="max-width: 220px;">
                                    <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
                                    <input type="text" id="txtGridSearch" class="form-control" placeholder="Search..." onkeyup="filterPartyGrid()" />
                                </div>
                            </div>
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
                                                <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-sm btn-primary" Text="Edit" CommandName="Select" formnovalidate="formnovalidate" />
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

    <!-- jQuery & Select2 JS -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script>
        function filterPartyGrid() {
            var searchText = document.getElementById('txtGridSearch').value.toLowerCase();
            var table = document.getElementById('<%= gvParty.ClientID %>');
            if (!table) return;

            var rows = table.getElementsByTagName('tr');
            // rows[0] হলো header row, তাই i = 1 থেকে শুরু
            for (var i = 1; i < rows.length; i++) {
                var rowText = rows[i].innerText.toLowerCase();
                rows[i].style.display = rowText.indexOf(searchText) > -1 ? '' : 'none';
            }
        }
        $(document).ready(function () {
            $('.searchable-dropdown').each(function () {
                var placeholderText = $(this).attr('data-placeholder') || 'Select option';
                $(this).select2({
                    theme: 'bootstrap-5',
                    width: '100%',
                    placeholder: placeholderText
                    // allowClear বাদ দেওয়া হয়েছে, যাতে সিলেক্ট করার পর × (clear) আইকন না আসে
                });
            });
        });
    </script>
</body>
</html>
