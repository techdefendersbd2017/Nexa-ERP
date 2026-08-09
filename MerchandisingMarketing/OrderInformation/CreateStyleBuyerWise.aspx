<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateStyleBuyerWise.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.OrderInformation.CreateStyleBuyerWise" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Create Style - Buyer Wise | Nexa ERP</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />

    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <!-- Select2 Bootstrap 5 Theme -->
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />

    <!-- jQuery (Must be loaded before Select2 JS) -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <!-- Select2 JS -->
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

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
        .table-dark-custom {
            background-color: #1f4e78;
            color: white;
        }
        .panel {
            display: none;
        }
        .panel.active {
            display: block;
        }
        .list-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .list-title {
            font-size: 1.25rem;
            font-weight: bold;
            color: #1f4e78;
        }
        .grid {
            width: 100%;
            background: white;
            border: 1px solid #dee2e6;
        }
        .grid th {
            background-color: #1f4e78;
            color: white;
            padding: 8px;
        }
        .grid td {
            padding: 8px;
            border-bottom: 1px solid #dee2e6;
        }

        /* Select2 styling to match a rounded modern textbox without arrow */
        .select2-container--bootstrap-5 .select2-selection {
            border-radius: 0.375rem !important;
            min-height: calc(1.5em + 0.5rem + 2px);
            padding: 0.25rem 0.5rem;
            font-size: 0.875rem;
            border: 1px solid #ced4da;
            background-image: none !important;
        }
        .select2-container--bootstrap-5 .select2-selection .select2-selection__arrow {
            display: none !important;
        }
        .select2-container--bootstrap-5 .select2-dropdown {
            border-radius: 0.5rem !important;
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
            border: 1px solid #86b7fe;
            padding: 6px;
        }
        .select2-container--bootstrap-5 .select2-search {
            padding: 4px;
        }
        .select2-container--bootstrap-5 .select2-search .select2-search__field {
            width: 85% !important;
            margin: 0 auto !important;
            display: block !important;
            border-radius: 50rem !important;
            padding: 0.25rem 0.75rem !important;
            font-size: 0.8rem !important;
            border: 1px solid #bce8f1 !important;
            background-color: #fdfdfe !important;
            outline: none;
            transition: all 0.2s ease-in-out;
        }
        .select2-container--bootstrap-5 .select2-search .select2-search__field:focus {
            border-color: #1f4e78 !important;
            box-shadow: 0 0 0 0.2rem rgba(31, 78, 120, 0.15) !important;
            background-color: #ffffff !important;
        }

        /* ================= FORM TABS ================= */
        .form-tabs {
            display: flex;
            gap: 6px;
            border-bottom: 2px solid #dee2e6;
            margin-bottom: 20px;
        }
        .form-tab-btn {
            background: #f1f3f5;
            border: 1px solid #dee2e6;
            border-bottom: none;
            padding: 10px 20px;
            font-weight: 600;
            font-size: 14px;
            color: #495057;
            border-radius: 6px 6px 0 0;
            cursor: pointer;
        }
        .form-tab-btn.active {
            background: #1f4e78;
            color: #fff;
            border-color: #1f4e78;
        }
        .form-tab-content {
            display: none;
        }
        .form-tab-content.active {
            display: block;
        }
    </style>

    <script type="text/javascript">
        // =====================================================================
        // PANEL (List / Form) SWITCHING — with state persisted in sessionStorage
        // =====================================================================
        function applyPanel(panelId) {
            document.querySelectorAll('.panel').forEach(function (p) {
                p.classList.remove('active');
            });
            var el = document.getElementById(panelId);
            if (el) { el.classList.add('active'); }
        }

        function showPanel(panelId) {
            applyPanel(panelId);
            try { sessionStorage.setItem('style_panel', panelId); } catch (e) { }
        }

        // =====================================================================
        // FORM TAB (Buyer & Classification / Size & Color) SWITCHING
        // — with state persisted in sessionStorage
        // =====================================================================
        function applyFormTab(tabId) {
            document.querySelectorAll('.form-tab-content').forEach(function (t) {
                t.classList.remove('active');
            });
            var tabEl = document.getElementById(tabId);
            if (tabEl) { tabEl.classList.add('active'); }

            document.querySelectorAll('.form-tab-btn').forEach(function (b) {
                b.classList.remove('active');
            });
            var btnEl = document.querySelector('.form-tab-btn[data-tab="' + tabId + '"]');
            if (btnEl) { btnEl.classList.add('active'); }
        }

        function showFormTab(tabId) {
            applyFormTab(tabId);
            try { sessionStorage.setItem('style_tab', tabId); } catch (e) { }
        }

        // =====================================================================
        // RESTORE UI STATE (panel + tab + scroll position) after ANY postback
        // (both full postback and UpdatePanel async postback)
        // =====================================================================
        function restoreUIState() {
            try {
                var panel = sessionStorage.getItem('style_panel') || 'pnlList';
                var tab = sessionStorage.getItem('style_tab') || 'tabBasicInfo';

                applyPanel(panel);
                applyFormTab(tab);

                var scrollY = sessionStorage.getItem('style_scrollY');
                if (scrollY !== null) {
                    setTimeout(function () {
                        window.scrollTo(0, parseInt(scrollY, 10) || 0);
                    }, 0);
                }
            } catch (e) { }
        }

        // Continuously (debounced) remember the current scroll position
        var _styleScrollSaveTimer = null;
        window.addEventListener('scroll', function () {
            if (_styleScrollSaveTimer) { clearTimeout(_styleScrollSaveTimer); }
            _styleScrollSaveTimer = setTimeout(function () {
                try { sessionStorage.setItem('style_scrollY', window.scrollY); } catch (e) { }
            }, 150);
        });

        // Initialize Select2 + restore UI state on first load
        $(document).ready(function () {
            initializeSelect2();
            restoreUIState();
        });

        // Initialize Select2 + restore UI state for normal load AND UpdatePanel partial postbacks
        // (pageLoad is invoked by Microsoft Ajax after EVERY postback when a ScriptManager is present)
        function pageLoad(sender, args) {
            initializeSelect2();
            restoreUIState();
        }

        function initializeSelect2() {
            $('.searchable-dropdown').each(function () {
                if (!$(this).hasClass("select2-hidden-accessible")) {
                    $(this).select2({
                        theme: "bootstrap-5",
                        placeholder: "Search",
                        allowClear: true,
                        width: '100%'
                    });
                }
            });
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <!-- ScriptManager for UpdatePanel -->
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div class="container my-4">

            <!-- ================= 1. LIST PANEL ================= -->
            <div id="pnlList" class="panel active">
                <div class="list-toolbar">
                    <div class="list-title"><i class="fa-solid fa-shirt text-primary me-2"></i>Create Style (Buyer Wise) List</div>
                    <button type="button" class="btn btn-success btn-sm" onclick="showPanel('pnlForm')">+ Add New Style</button>
                </div>

                <asp:GridView ID="gvStyleList" runat="server" AutoGenerateColumns="False" CssClass="grid" ShowHeaderWhenEmpty="True" OnRowCommand="gvStyleList_RowCommand">
                    <EmptyDataTemplate>
                        <div style="color: #777; padding: 12px; font-size: 12px; text-align: center;">
                            No records found in list
                        </div>
                    </EmptyDataTemplate>
                    <Columns>
                        <asp:TemplateField HeaderText="SL">
                            <ItemTemplate>
                                <%# Container.DataItemIndex + 1 %>
                            </ItemTemplate>
                            <ItemStyle Width="40px" />
                        </asp:TemplateField>

                        <asp:BoundField DataField="StyleCode" HeaderText="Style Code" ItemStyle-Width="12%" />
                        <asp:BoundField DataField="StyleName" HeaderText="Style Name" ItemStyle-Width="18%" />
                        <asp:BoundField DataField="BuyerName" HeaderText="Buyer" ItemStyle-Width="15%" />
                        <asp:BoundField DataField="Category" HeaderText="Category" ItemStyle-Width="15%" />
                        <asp:BoundField DataField="Season" HeaderText="Season" ItemStyle-Width="15%" />

                        <asp:TemplateField HeaderText="Action" ItemStyle-Width="25%">
                            <ItemTemplate>
                                <div style="display: flex; gap: 5px; align-items: center;">
                                    <asp:LinkButton ID="lnkEdit" runat="server" Text="Edit" CommandName="EditRow" CommandArgument='<%# Eval("StyleCode") %>'
                                        Style="background-color: #e3f2fd; color: #1976d2; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #90caf9;" />

                                    <asp:LinkButton ID="lnkDelete" runat="server" Text="Delete" CommandName="DeleteRow" CommandArgument='<%# Eval("StyleCode") %>'
                                        Style="background-color: #ffebee; color: #c62828; padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: 600; text-decoration: none; border: 1px solid #ef9a9a;"
                                        OnClientClick="return confirm('Are you sure you want to delete this style?');" />
                                </div>
                            </ItemTemplate>
                            <ItemStyle Width="140px" />
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

            <!-- ================= 2. FORM PANEL ================= -->
            <div id="pnlForm" class="panel">
                <div class="card shadow-sm">
                    <div class="card-header card-header-custom text-center py-2 d-flex justify-content-between align-items-center">
                        <span>Create Style (Buyer Wise) - Input Form</span>
                        <button type="button" class="btn btn-light btn-sm text-dark fw-bold" onclick="showPanel('pnlList')">← Back to List</button>
                    </div>
                    <div class="card-body">

                        <!-- Alert Message -->
                        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-success alert-dismissible fade show" role="alert">
                            <asp:Label ID="lblMessage" runat="server" Text=""></asp:Label>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </asp:Panel>

                        <!-- UpdatePanel for Partial Postbacks -->
                        <asp:UpdatePanel ID="updFormContent" runat="server">
                            <ContentTemplate>

                                <asp:HiddenField ID="hdnStyleID" runat="server" />
                                <asp:HiddenField ID="hdnSelectedColorSlNo" runat="server" />

                                <!-- ============ TAB BUTTONS ============ -->
                                <div class="form-tabs">
                                    <button type="button" class="form-tab-btn active" data-tab="tabBasicInfo" onclick="showFormTab('tabBasicInfo')">
                                        1. Buyer &amp; Classification
                                    </button>
                                    <button type="button" class="form-tab-btn" data-tab="tabSizeColor" onclick="showFormTab('tabSizeColor')">
                                        2. Size &amp; Color Information
                                    </button>
                                </div>

                                <!-- ============ TAB 1: BUYER & STYLE BASIC INFO + CLASSIFICATION ============ -->
                                <div id="tabBasicInfo" class="form-tab-content active">

                                    <!-- SECTION 1: Buyer & Style Basic Info -->
                                    <fieldset class="border p-3 rounded mb-4">
                                        <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">1. Buyer &amp; Style Basic Information</legend>
                                        <div class="row g-3">
                                            <div class="col-md-4">
                                                <label class="form-label small fw-semibold">Select Buyer <span class="text-danger">*</span></label>
                                                <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="form-select form-select-sm searchable-dropdown" AutoPostBack="true">
                                                    <asp:ListItem Value="">-- Choose Buyer --</asp:ListItem>
                                                    <asp:ListItem Value="1">H&amp;M</asp:ListItem>
                                                    <asp:ListItem Value="2">ZARA</asp:ListItem>
                                                    <asp:ListItem Value="3">Uniqlo</asp:ListItem>
                                                    <asp:ListItem Value="4">GAP</asp:ListItem>
                                                    <asp:ListItem Value="5">Marks &amp; Spencer</asp:ListItem>
                                                </asp:DropDownList>
                                                <asp:RequiredFieldValidator ID="rfvBuyer" runat="server" ControlToValidate="ddlBuyer" InitialValue="" ErrorMessage="Buyer is required" CssClass="text-danger small" Display="Dynamic" />
                                            </div>

                                            <div class="col-md-4">
                                                <label class="form-label small fw-semibold">Style Reference / Name <span class="text-danger">*</span></label>
                                                <asp:TextBox ID="txtStyleName" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. Basic Regular Fit Tee"></asp:TextBox>
                                                <asp:RequiredFieldValidator ID="rfvStyleName" runat="server" ControlToValidate="txtStyleName" ErrorMessage="Style Name is required" CssClass="text-danger small" Display="Dynamic" />
                                            </div>

                                            <div class="col-md-4">
                                                <label class="form-label small fw-semibold">Style Code / No (Auto)</label>
                                                <asp:TextBox ID="txtStyleCode" runat="server" CssClass="form-control form-control-sm bg-light" ReadOnly="true" placeholder="Auto-generated"></asp:TextBox>
                                            </div>
                                        </div>
                                    </fieldset>

                                    <!-- SECTION 2: Classification -->
                                    <fieldset class="border p-3 rounded mb-4">
                                        <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">2. Product Classification</legend>
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <label class="form-label small fw-semibold">Product Category <span class="text-danger">*</span></label>
                                                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                                    <asp:ListItem>Knit - T-Shirt</asp:ListItem>
                                                    <asp:ListItem>Knit - Polo Shirt</asp:ListItem>
                                                    <asp:ListItem>Woven - Shirt</asp:ListItem>
                                                    <asp:ListItem>Woven - Trouser</asp:ListItem>
                                                    <asp:ListItem>Sweater</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>

                                            <div class="col-md-3">
                                                <label class="form-label small fw-semibold">Season</label>
                                                <asp:DropDownList ID="ddlSeason" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                                    <asp:ListItem>Summer 2026</asp:ListItem>
                                                    <asp:ListItem>Fall/Winter 2026</asp:ListItem>
                                                    <asp:ListItem>Spring 2027</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>

                                            <div class="col-md-3">
                                                <label class="form-label small fw-semibold">Department</label>
                                                <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                                    <asp:ListItem>Mens</asp:ListItem>
                                                    <asp:ListItem>Womens</asp:ListItem>
                                                    <asp:ListItem>Kids</asp:ListItem>
                                                    <asp:ListItem>Unisex</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>

                                            <div class="col-md-3">
                                                <label class="form-label small fw-semibold">Order UOM</label>
                                                <asp:DropDownList ID="ddlUOM" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                                    <asp:ListItem>PCS</asp:ListItem>
                                                    <asp:ListItem>SET</asp:ListItem>
                                                    <asp:ListItem>DOZ</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>
                                    </fieldset>

                                    <div class="text-end">
                                        <button type="button" class="btn btn-primary btn-sm px-4" onclick="showFormTab('tabSizeColor')">
                                            Next: Size &amp; Color Information →
                                        </button>
                                    </div>

                                </div>

                                <!-- ============ TAB 2: SIZE BREAKDOWN, COLORWAYS & REMARKS ============ -->
                                <div id="tabSizeColor" class="form-tab-content">

                                    <div class="row g-4 mb-4">
                                        <!-- Size Breakdown -->
                                        <div class="col-md-6">
                                            <fieldset class="border p-3 rounded h-100">
                                                <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary d-flex align-items-center gap-2">
                                                    3. Size Breakdown
                                                    <button type="button" class="btn btn-outline-primary btn-sm ms-2" data-bs-toggle="modal" data-bs-target="#sizeGroupModal">
                                                        <i class="fa-solid fa-plus me-1"></i> Add Size Group
                                                    </button>
                                                </legend>

                                                <div class="mb-3">
                                                    <label class="form-label small fw-semibold">Select Size Group <span class="text-danger">*</span></label>
                                                    <asp:DropDownList ID="ddlSizeGroup" runat="server" CssClass="form-select form-select-sm searchable-dropdown" AutoPostBack="true" OnSelectedIndexChanged="ddlSizeGroup_SelectedIndexChanged">
                                                        <asp:ListItem Value="">-- Choose Size Group --</asp:ListItem>
                                                    </asp:DropDownList>
                                                    <asp:RequiredFieldValidator ID="rfvSizeGroup" runat="server" ControlToValidate="ddlSizeGroup" InitialValue="" ErrorMessage="Size Group is required" CssClass="text-danger small" Display="Dynamic" />
                                                </div>

                                                <div>
                                                    <label class="form-label small fw-semibold mb-2">Available Sizes in Group:</label>
                                                    <asp:CheckBoxList ID="chkSizes" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="d-flex flex-wrap gap-3">
                                                    </asp:CheckBoxList>
                                                </div>
                                            </fieldset>
                                        </div>

                                        <!-- Colorways -->
                                        <div class="col-md-6">
                                            <fieldset class="border p-3 rounded h-100">
                                                <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">4. Colorways</legend>

                                                <div class="row g-2 align-items-end bg-light p-2 rounded">
                                                    <div class="col-md-5">
                                                        <label class="form-label small fw-bold">Color Name</label>
                                                        <asp:TextBox ID="txtColorName" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. Navy Blue"></asp:TextBox>
                                                    </div>
                                                    <div class="col-md-4">
                                                        <label class="form-label small fw-bold">Pantone No</label>
                                                        <asp:TextBox ID="txtPantone" runat="server" CssClass="form-control form-control-sm" placeholder="Pantone No"></asp:TextBox>
                                                    </div>
                                                    <div class="col-md-3">
                                                        <asp:Button ID="btnAddColor" runat="server" CssClass="btn btn-success btn-sm w-100" Text="Add Color" OnClick="btnAddColor_Click" CausesValidation="false" />
                                                    </div>
                                                </div>

                                                <div class="table-responsive mt-3">
                                                    <asp:GridView ID="gvColorList" runat="server" CssClass="table table-bordered table-striped table-sm text-center align-middle" AutoGenerateColumns="False" DataKeyNames="ColorSlNo" EmptyDataText="No color added yet. Add colors above." OnRowCommand="gvColorList_RowCommand">
                                                        <HeaderStyle CssClass="table-dark-custom" />
                                                        <Columns>
                                                            <asp:BoundField DataField="ColorSlNo" HeaderText="Sl No" />
                                                            <asp:BoundField DataField="ColorName" HeaderText="Color Name" />
                                                            <asp:BoundField DataField="Pantone" HeaderText="Pantone No" />
                                                            <asp:TemplateField HeaderText="Action">
                                                                <ItemTemplate>
                                                                    <asp:Button ID="btnEditColor" runat="server" CssClass="btn btn-primary btn-sm px-2 py-0" Text="Edit" CommandName="EditColor" CommandArgument='<%# Eval("ColorSlNo") %>' CausesValidation="false" />
                                                                    <asp:Button ID="btnDeleteColor" runat="server" CssClass="btn btn-danger btn-sm px-2 py-0" Text="X" CommandName="DeleteColor" CommandArgument='<%# Eval("ColorSlNo") %>' CausesValidation="false" />
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </div>
                                            </fieldset>
                                        </div>
                                    </div>

                                    <!-- SECTION 5: Remarks -->
                                    <fieldset class="border p-3 rounded mb-4">
                                        <legend class="float-none w-auto px-3 fs-6 fw-bold text-primary">5. Remarks &amp; Instructions</legend>
                                        <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control form-control-sm" placeholder="Add printing, embroidery, or special washing instructions..."></asp:TextBox>
                                    </fieldset>

                                    <div class="text-start">
                                        <button type="button" class="btn btn-outline-secondary btn-sm px-4" onclick="showFormTab('tabBasicInfo')">
                                            ← Back to Buyer &amp; Classification
                                        </button>
                                    </div>

                                </div>

                            </ContentTemplate>
                        </asp:UpdatePanel>

                        <!-- Footer Action Buttons -->
                        <div class="d-flex justify-content-end gap-2 border-top pt-3 mt-3">
                            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-secondary btn-sm px-4" CausesValidation="false" OnClick="btnCancel_Click" />
                            <asp:Button ID="btnSaveAndNew" runat="server" Text="Save &amp; New" CssClass="btn btn-primary btn-sm px-4" OnClick="btnSaveAndNew_Click" />
                            <asp:Button ID="btnSaveAndExit" runat="server" Text="Save &amp; Exit" CssClass="btn btn-success btn-sm px-4" OnClick="btnSaveAndExit_Click" />
                            <button type="button" class="btn btn-info btn-sm px-4 text-white" onclick="showPanel('pnlList')">Back to List</button>
                        </div>

                    </div>
                </div>
            </div>

        </div>

        <!-- Modal for Adding New Size Group -->
        <div class="modal fade" id="sizeGroupModal" tabindex="-1" aria-labelledby="sizeGroupModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title fs-6 fw-bold" id="sizeGroupModalLabel">Add New Size Group</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Size Group Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtNewSizeGroupName" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. Mens Basic (S-XXL)"></asp:TextBox>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-semibold">Sizes (Comma Separated) <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtNewGroupSizes" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. S, M, L, XL, XXL"></asp:TextBox>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary btn-sm" data-bs-dismiss="modal">Close</button>
                        <asp:Button ID="btnSaveSizeGroup" runat="server" Text="Save Size Group" CssClass="btn btn-primary btn-sm" CausesValidation="false" OnClick="btnSaveSizeGroup_Click" />
                    </div>
                </div>
            </div>
        </div>

    </form>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
