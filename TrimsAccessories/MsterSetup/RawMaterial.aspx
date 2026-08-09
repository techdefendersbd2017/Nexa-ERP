<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RawMaterial.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.MsterSetup.RawMaterial" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Raw Material Setup</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />
    <style>
        body { background-color: #f8f9fa; font-size: 14px; }
        .card-header-custom { background-color: #1f4e78; color: white; font-weight: bold; }

        /* Select2 - rounded, clean look for the search box on every dropdown */
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
    <!-- jQuery (Select2 এর জন্য প্রয়োজন) -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- Select2 JS -->
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

    <script>
        $(document).ready(function () {
            // প্রতিটি ড্রপডাউনে সার্চ বক্স যুক্ত করা হলো (placeholder: Search)
            $('.search-dropdown').select2({
                theme: 'bootstrap-5',
                width: '100%',
                placeholder: "Search"
            });

            // ড্রপডাউনে ক্লিক করলে সাথে সাথে সার্চ বক্সে কার্সর/ফোকাস চলে যাবে
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
        
        <asp:HiddenField ID="hfScrollPosition" runat="server" Value="0" />
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
                                <asp:TextBox ID="txtRawMaterialId" runat="server" CssClass="form-control" placeholder="Enter Raw Material ID" ReadOnly="True"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Material Code</label>
                                <asp:TextBox ID="txtMaterialCode" runat="server" CssClass="form-control" placeholder="Enter Material Code"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Raw Material Name</label>
                                <asp:TextBox ID="txtRawMaterialName" runat="server" CssClass="form-control" placeholder="Enter Raw Material Name"></asp:TextBox>
                            </div>

                            <!-- আইটেম টাইপ সিলেকশন (General বনাম Liquid) -->
                            <div class="mb-3">
                                <label class="form-label fw-bold text-danger">Item Type (Is Liquid?)</label>
                                <asp:DropDownList ID="ddlItemCategory" runat="server" CssClass="form-select border-primary search-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlItemCategory_SelectedIndexChanged">
                                    <asp:ListItem Text="General / Solid Item (Accessories, etc.)" Value="General" Selected="True" />
                                    <asp:ListItem Text="Liquid Item (Dyes, Chemicals, etc.)" Value="Liquid" />
                                </asp:DropDownList>
                            </div>

                            <!-- প্যানেল ১: জেনারেল/সলিড আইটেম মেজারমেন্ট ফিল্ড -->
                            <asp:Panel ID="pnlGeneralFields" runat="server" CssClass="card p-3 bg-light mb-3">
                                <h6 class="text-secondary fw-bold mb-2">General / Solid Item Specifications</h6>
                                
                                <div class="row mb-2">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold small">Length</label>
                                        <asp:TextBox ID="txtLength" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. 7.0"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold small">Width / Dia</label>
                                        <asp:TextBox ID="txtWidth" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. 0.5"></asp:TextBox>
                                    </div>
                                </div>

                                <div class="row mb-2">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold small">Thickness</label>
                                        <asp:TextBox ID="txtThickness" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. 0.2 mm"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold small">Dimension Unit</label>
                                        <asp:DropDownList ID="ddlDimensionUnit" runat="server" CssClass="form-select form-select-sm search-dropdown">
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </asp:Panel>

                            <!-- প্যানেল ২: লিকুইড আইটেম ফিল্ড (ডাইস/কেমিক্যাল) -->
                            <asp:Panel ID="pnlLiquidFields" runat="server" CssClass="card p-3 bg-light mb-3" Visible="false">
                                <h6 class="text-secondary fw-bold mb-2">Liquid Calculation Parameters</h6>
                                
                                <div class="row mb-2">
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold small">Density / Specific Gravity</label>
                                        <asp:TextBox ID="txtDensity" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. 1.05"></asp:TextBox>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-bold small">Concentration (%)</label>
                                        <asp:TextBox ID="txtConcentration" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. 100%"></asp:TextBox>
                                    </div>
                                </div>

                                <div class="mb-2">
                                    <label class="form-label fw-bold small">PH Value</label>
                                    <asp:TextBox ID="txtPhValue" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. 7.0"></asp:TextBox>
                                </div>
                            </asp:Panel>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Base Unit</label>
                            <div class="mb-3">
                                <label class="form-label fw-bold small">Unit</label>
                                <asp:DropDownList ID="ddlUnit" runat="server" CssClass="form-select search-dropdown">
                                </asp:DropDownList>
                            </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Standard Unit Price</label>
                                <asp:TextBox ID="txtUnitPrice" runat="server" CssClass="form-control" placeholder="0.00"></asp:TextBox>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Currency</label>
                                <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-select search-dropdown">
                                    <asp:ListItem Text="BDT" Value="BDT" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="USD" Value="USD"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select search-dropdown">
                                    <asp:ListItem Text="Active" Value="Active" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="d-flex gap-2">
                                <asp:Button ID="btnSave" runat="server" CssClass="btn btn-success px-4" Text="Save" OnClick="btnSave_Click" OnClientClick="saveScrollPos();" />
                                <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel" OnClick="btnRefresh_Click" OnClientClick="saveScrollPos();" />
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
                                        <asp:BoundField DataField="UnitName" HeaderText="Unit" />
                                        <asp:BoundField DataField="UnitPrice" HeaderText="Unit Price" />
                                        <asp:BoundField DataField="Currency" HeaderText="Currency" />
                                        <asp:BoundField DataField="Status" HeaderText="Status" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-sm btn-primary" Text="Edit" CommandName="Select" OnClientClick="saveScrollPos();" />
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
