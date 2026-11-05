<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StyleInformationForGarments.aspx.cs" Inherits="Nexa_ERP.MasterConfiguration.BuyerManagement.StyleInformationForGarments" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Garments ERP - Style Entry Master</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <script src="../../Assets/StyleInformationForGarments.js"></script>
    <style>
        :root {
            --erp-primary: #0f172a;
            --erp-secondary: #3b82f6;
            --erp-bg: #f8fafc;
            --erp-card-bg: #ffffff;
            --erp-border: #e2e8f0;
            --brand-primary: #3b82f6;
            --brand-primary-dark: #1d4ed8;
        }
        body { background-color: var(--erp-bg); font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; font-size: 0.875rem; color: #334155; }
        .navbar-erp { background-color: var(--erp-primary); color: #fff; padding: 0.75rem 1.5rem; }
        .card-erp { background: var(--erp-card-bg); border: 1px solid var(--erp-border); border-radius: 0.375rem; box-shadow: 0 1px 3px 0 rgba(0,0,0,0.05); margin-bottom: 1rem; }
        .card-header-erp { background-color: #f1f5f9; border-bottom: 1px solid var(--erp-border); font-weight: 600; color: #1e293b; padding: 0.75rem 1rem; }
        .form-label { font-weight: 500; color: #475569; margin-bottom: 0.25rem; }
        .required::after { content: " *"; color: #ef4444; }
        .nav-tabs .nav-link { color: #64748b; font-weight: 500; border: none; padding: 0.75rem 1rem; }
        .nav-tabs .nav-link.active { color: var(--erp-secondary); background-color: transparent; border-bottom: 2px solid var(--erp-secondary); }
        .btn-xs { padding: 0.1rem 0.35rem; font-size: 0.75rem; }
        .add-row { background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 0.375rem; padding: 0.5rem; margin-bottom: 0.75rem; }
        .img-box { border: 2px dashed #cbd5e1; border-radius: 0.375rem; padding: 1rem; text-align: center; background: #f8fafc; }
        .sec-title { border-bottom: 1px solid var(--erp-border); padding-bottom: 0.25rem; margin-top: 0.5rem; }

        /* Searchable Dropdown */
        .dd-ctl { position: relative; min-width: 0; }
        .dd-fld { display: flex; align-items: center; gap: 6px; height: 31px; padding: 0 8px 0 10px; border: 1px solid #ced4da; border-radius: 0.25rem;
                  background: #fff; font-size: 0.8125rem; cursor: pointer; user-select: none; transition: border-color .15s ease, box-shadow .15s ease; }
        .dd-fld:focus, .dd-fld.open { outline: none; border-color: var(--brand-primary); box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15); }
        .dd-fld .txt { flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; color: #8a93a3; }
        .dd-fld.has .txt { color: #222; }
        .dd-fld .clr { display: none; color: #9aa2b1; font-size: 10px; padding: 0 2px; }
        .dd-fld.has .clr { display: inline; }
        .dd-fld .clr:hover { color: #dc3545; }
        .dd-fld .chev { color: #8a93a3; font-size: 12px; }
        .dd-fld.dis { background: #e9ecef; cursor: not-allowed; opacity: .8; }
        .dd-fld.dis .clr { display: none !important; }

        .dd-panel { position: absolute; left: 0; top: calc(100% + 4px); z-index: 1050; min-width: 100%; width: max-content; max-width: 22rem;
                    background: #fff; border: 1px solid #e2e6ee; border-radius: 12px; box-shadow: 0 10px 28px rgba(17, 24, 39, 0.12); overflow: hidden; padding-top: 8px; font-size: 12.5px; }
        .dd-panel.right { left: auto; right: 0; }
        .dd-panel .ps { position: relative; padding: 4px 10px 10px 10px; }
        .dd-panel .ps i { position: absolute; left: 22px; top: 50%; transform: translateY(-55%); color: #9aa2b1; font-size: 13px; pointer-events: none; }
        .dd-panel .ps input { width: 100%; border: 1px solid #e2e6ee; border-radius: 20px; padding: 6px 12px 6px 32px; font-size: 12.5px; outline: none; background: #f8f9fb; font-family: inherit; }
        .dd-panel .ps input:focus { border-color: var(--brand-primary); background: #fff; }
        .dd-panel .pl { max-height: 260px; overflow-y: auto; }
        .dd-panel .it { display: flex; align-items: center; padding: 8px 16px; color: #333; cursor: pointer; }
        .dd-panel .it:hover { background: #f1f4fb; color: var(--brand-primary-dark); }
        .dd-panel .it.sel-single { background: #eef3ff; color: var(--brand-primary-dark); font-weight: 600; }
        .dd-panel .empty { padding: 12px; text-align: center; color: #8a93a3; }

        /* ===== Fabric Name Builder ===== */
        .fnb-card { border: 1px solid var(--erp-border); border-radius: .5rem; background: #fff; margin-bottom: 1rem; overflow: hidden; }
        .fnb-head { display: flex; align-items: center; justify-content: space-between; padding: .6rem 1rem; cursor: pointer;
                    background: linear-gradient(90deg, #eef2ff, #f5f3ff); border-bottom: 1px solid var(--erp-border); }
        .fnb-head .ttl { font-weight: 600; color: #3730a3; }
        .fnb-head .ttl i { margin-right: .4rem; }
        .fnb-head .chev { transition: transform .2s ease; color: #6366f1; }
        .fnb-card.collapsed .fnb-head .chev { transform: rotate(-90deg); }
        .fnb-card.collapsed .fnb-body { display: none; }
        .fnb-card.collapsed .fnb-head { border-bottom: 0; }
        .fnb-body { padding: 1rem; }
        .fnb-lbl { font-size: .6875rem; font-weight: 700; text-transform: uppercase; letter-spacing: .04em; color: #64748b; margin-bottom: .25rem; display: block; }
        .fnb-lbl i { color: #6366f1; margin-right: .2rem; }
        .fnb-preview { position: relative; overflow: hidden; border-radius: .75rem; padding: 1rem; color: #fff; height: 100%; min-height: 230px;
                       background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 55%, #4c1d95 100%); display: flex; flex-direction: column; justify-content: space-between; }
        .fnb-preview::before { content: ""; position: absolute; right: -50px; top: -50px; width: 150px; height: 150px; border-radius: 50%; background: rgba(99,102,241,.25); filter: blur(40px); }
        .fnb-preview .cap { font-size: .625rem; letter-spacing: .12em; text-transform: uppercase; color: #a5b4fc; display: flex; justify-content: space-between; align-items: center;
                            border-bottom: 1px solid rgba(255,255,255,.12); padding-bottom: .5rem; margin-bottom: .75rem; position: relative; }
        .fnb-preview .code { font-family: Consolas, monospace; background: rgba(255,255,255,.1); border: 1px solid rgba(255,255,255,.2); border-radius: 99px; padding: 1px 10px; color: #c7d2fe; font-size: .6875rem; letter-spacing: 0; }
        .fnb-preview .name { font-size: 1rem; font-weight: 700; line-height: 1.45; word-break: break-word; position: relative; }
        .fnb-tags { display: flex; flex-wrap: wrap; gap: 6px; margin: .75rem 0; position: relative; }
        .fnb-tags span { font-size: .6875rem; padding: 2px 9px; border-radius: 6px; background: rgba(255,255,255,.1); border: 1px solid rgba(255,255,255,.15); }
        .fnb-actions { display: grid; gap: 6px; position: relative; }
        .fnb-actions .btn-copy { background: rgba(255,255,255,.12); color: #fff; border: 1px solid rgba(255,255,255,.18); }
        .fnb-actions .btn-copy:hover { background: rgba(255,255,255,.22); color: #fff; }
        .fnb-actions .btn-use { background: linear-gradient(90deg, #6366f1, #7c3aed); color: #fff; border: 0; font-weight: 600; }
        .fnb-actions .btn-use:hover { filter: brightness(1.1); color: #fff; }
        .fnb-cat { display: inline-block; padding: .3rem .7rem; border-radius: .375rem; font-weight: 600; font-size: .8125rem; border: 1px solid #e2e8f0; background: #f8fafc; }
        .fnb-cat.knit { color: #0d9488; } .fnb-cat.woven { color: #4f46e5; }
        .fnb-flash { animation: fnbFlash 1.2s ease; }
        @keyframes fnbFlash { 0% { background: #dcfce7; box-shadow: 0 0 0 3px rgba(34,197,94,.35); } 100% { background: #fff; box-shadow: none; } }

        @media print { .navbar-erp, .nav-tabs, .btn, .col-lg-3 { display: none !important; } .tab-pane { display: block !important; opacity: 1 !important; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfActiveTab" runat="server" ClientIDMode="Static" Value="basic-tab" />
        <asp:HiddenField ID="hfStyleId" runat="server" Value="0" ClientIDMode="Static" />
        <asp:HiddenField ID="hfUserId" runat="server" Value="0" ClientIDMode="Static" />
        <asp:HiddenField ID="hfTab" runat="server" Value="" ClientIDMode="Static" />
        <asp:HiddenField ID="hfLocked" runat="server" Value="0" ClientIDMode="Static" />
        <asp:HiddenField ID="hfSetId" runat="server" Value="0" ClientIDMode="Static" />

        <!-- ড্রপডাউনের নির্বাচিত মান (JS এখানে লেখে, Server এখান থেকে পড়ে) -->
        <asp:HiddenField ID="hfBuyerFilter" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfStatusFilter" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfMainStatus" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfBuyer" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfBrand" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfAgent" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfSeason" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfSeasonYear" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfProductCategory" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfProductType" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfGarmentType" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfGender" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfMerchandiser" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfKnitWoven" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfColor" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfSize" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfFabUnit" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfFabCat" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfAccType" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfAccUnit" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfMapComp" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfMapType" runat="server" ClientIDMode="Static" />

        <!-- Top ERP Header -->
        <nav class="navbar navbar-erp navbar-expand-lg">
            <div class="container-fluid">
                <span class="navbar-brand mb-0 h1 text-white"><i class="bi bi-layers-fill me-2"></i>Garments ERP &gt; Style Entry Master</span>
                <div class="d-flex align-items-center">
                    <span class="text-light small">Logged in as: <b><asp:Label ID="lblUser" runat="server" /></b></span>
                </div>
            </div>
        </nav>

        <div class="container-fluid py-3">

            <!-- ====================== LIST PANEL ====================== -->
            <asp:Panel ID="pnlList" runat="server">
                <div class="card card-erp">
                    <div class="card-header-erp d-flex justify-content-between align-items-center">
                        <span><i class="bi bi-list-ul"></i> Style List</span>
                        <asp:LinkButton ID="btnAddNew" runat="server" CssClass="btn btn-sm btn-primary" OnClick="btnAddNew_Click"><i class="bi bi-plus-lg"></i> Add New Style</asp:LinkButton>
                    </div>
                    <div class="card-body">
                        <div class="row g-2 mb-3 align-items-end">
                            <div class="col-md-3">
                                <label class="form-label">Buyer</label>
                                <div data-dd="buyerFilter"></div>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Status</label>
                                <div data-dd="statusFilter"></div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label">Search (Style Code / No / Name)</label>
                                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control form-control-sm" placeholder="Search..." />
                            </div>
                            <div class="col-md-3">
                                <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn btn-sm btn-primary" OnClick="btnSearch_Click"><i class="bi bi-search"></i> Search</asp:LinkButton>
                                <asp:LinkButton ID="btnClearFilter" runat="server" CssClass="btn btn-sm btn-outline-secondary" OnClick="btnClearFilter_Click"><i class="bi bi-x-lg"></i> Clear</asp:LinkButton>
                            </div>
                        </div>
                        <div class="table-responsive">
                            <asp:GridView ID="gvStyles" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" OnRowCommand="gvStyles_RowCommand" EmptyDataText="No style found.">
                                <Columns>
                                    <asp:BoundField DataField="StyleCode" HeaderText="Style ID" />
                                    <asp:BoundField DataField="StyleNo" HeaderText="Style No" />
                                    <asp:BoundField DataField="StyleName" HeaderText="Style Name" />
                                    <asp:BoundField DataField="BuyerName" HeaderText="Buyer" />
                                    <asp:BoundField DataField="Season" HeaderText="Season" />
                                    <asp:TemplateField HeaderText="Status">
                                        <ItemTemplate><span class="badge bg-secondary"><%# Eval("StyleStatus") %></span></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:BoundField DataField="RevisionNo" HeaderText="Rev" />
                                    <asp:TemplateField HeaderText="Action" ItemStyle-Width="110px">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("StyleID") %>' CssClass="btn btn-xs btn-outline-primary" ToolTip="Edit"><i class="bi bi-pencil"></i></asp:LinkButton>
                                            <asp:LinkButton runat="server" CommandName="DeleteRow" CommandArgument='<%# Eval("StyleID") %>' CssClass="btn btn-xs btn-outline-danger" ToolTip="Delete" OnClientClick="return confirm('Delete this style?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </asp:Panel>

            <!-- ====================== ENTRY PANEL ====================== -->
            <asp:Panel ID="pnlEntry" runat="server" Visible="false">

                <!-- Main Header Bar -->
                <div class="card card-erp mb-3">
                    <div class="card-body py-2">
                        <div class="row align-items-center">
                            <div class="col-md-2">
                                <label class="form-label text-muted small mb-0">Style ID (Auto)</label>
                                <asp:TextBox ID="txtStyleID" runat="server" CssClass="form-control form-control-sm bg-light fw-bold text-primary" ReadOnly="true" />
                            </div>
                            <div class="col-md-2">
                                <label class="form-label required">Style No</label>
                                <asp:TextBox ID="txtStyleNo" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Style No" MaxLength="50" />
                            </div>
                            <div class="col-md-3">
                                <label class="form-label required">Style Name</label>
                                <asp:TextBox ID="txtStyleName" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Style Name" MaxLength="150" />
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Style Status</label>
                                <div data-dd="mainStatus"></div>
                            </div>
                            <div class="col-md-1">
                                <label class="form-label">Rev. No</label>
                                <asp:TextBox ID="txtRevNo" runat="server" CssClass="form-control form-control-sm bg-light" ReadOnly="true" Text="00" />
                            </div>
                            <div class="col-md-2 text-end mt-3 mt-md-0">
                                <div class="btn-group btn-group-sm">
                                    <asp:LinkButton ID="btnSave" runat="server" CssClass="btn btn-primary" OnClick="btnSave_Click" ToolTip="Save Record"><i class="bi bi-save"></i> Save</asp:LinkButton>
                                    <asp:LinkButton ID="btnUpdate" runat="server" CssClass="btn btn-success" OnClick="btnUpdate_Click" ToolTip="Update Record" Visible="false"><i class="bi bi-arrow-clockwise"></i> Update</asp:LinkButton>
                                    <asp:LinkButton ID="btnReset" runat="server" CssClass="btn btn-outline-secondary" OnClick="btnReset_Click" ToolTip="Reset Form"><i class="bi bi-x-lg"></i></asp:LinkButton>
                                    <button type="button" class="btn btn-outline-dark dropdown-toggle" data-bs-toggle="dropdown"></button>
                                    <ul class="dropdown-menu dropdown-menu-end">
                                        <li><asp:LinkButton ID="btnCopyStyle" runat="server" CssClass="dropdown-item" OnClick="btnCopyStyle_Click" OnClientClick="return confirm('Copy this style as a new Draft style?');"><i class="bi bi-files me-2"></i>Copy Style</asp:LinkButton></li>
                                        <li><a class="dropdown-item" href="#" onclick="window.print(); return false;"><i class="bi bi-printer me-2"></i>Print TechSheet</a></li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li><asp:LinkButton ID="btnClose" runat="server" CssClass="dropdown-item text-danger" OnClick="btnClose_Click"><i class="bi bi-box-arrow-right me-2"></i>Close</asp:LinkButton></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <!-- Main Content Area with Tabs -->
                    <div class="col-lg-9">
                        <div class="card card-erp">
                            <div class="card-header bg-white pb-0 pt-2 border-bottom-0">
                                <ul class="nav nav-tabs card-header-tabs" id="styleTabs" role="tablist">
                                    <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#basic-tab" type="button"><i class="bi bi-info-circle me-1"></i> Basic Info</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#image-tab" type="button"><i class="bi bi-images me-1"></i> Images</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#spec-tab" type="button"><i class="bi bi-sliders me-1"></i> Specification</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#colorsize-tab" type="button"><i class="bi bi-grid-3x3 me-1"></i> Color &amp; Size</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#fabric-tab" type="button"><i class="bi bi-layers me-1"></i> Fabric</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#accessories-tab" type="button"><i class="bi bi-tag me-1"></i> Accessories</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#set-tab" type="button"><i class="bi bi-collection me-1"></i> Set</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#history-tab" type="button"><i class="bi bi-clock-history me-1"></i> History</button></li>
                                </ul>
                            </div>

                            <div class="card-body">
                                <div class="tab-content" id="styleTabContent">

                                    <!-- TAB 1: BASIC INFORMATION -->
                                    <div class="tab-pane fade show active" id="basic-tab">
                                        <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-info-circle"></i> Style Basic Master Information</h6>
                                        <div class="row g-3">
                                            <div class="col-md-12">
                                                <label class="form-label">Style Description</label>
                                                <asp:TextBox ID="txtStyleDesc" runat="server" CssClass="form-control form-control-sm" placeholder="Enter description" MaxLength="300" />
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label required">Buyer</label>
                                                <div data-dd="buyer"></div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Brand</label>
                                                <div data-dd="brand"></div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Agent / Buying House</label>
                                                <div data-dd="agent"></div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Season / Year</label>
                                                <div class="d-flex gap-1">
                                                    <div class="flex-grow-1" data-dd="season"></div>
                                                    <div style="width: 96px;" data-dd="seasonYear"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Product Category</label>
                                                <div data-dd="productCategory"></div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Product Type</label>
                                                <div data-dd="productType"></div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Garment Type / Gender</label>
                                                <div class="d-flex gap-1">
                                                    <div class="flex-grow-1" data-dd="garmentType"></div>
                                                    <div class="flex-grow-1" data-dd="gender"></div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Department / Division</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtDepartment" runat="server" CssClass="form-control" placeholder="Department" MaxLength="100" />
                                                    <asp:TextBox ID="txtDivision" runat="server" CssClass="form-control" placeholder="Division" MaxLength="100" />
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label required">Assigned Merchandiser</label>
                                                <div data-dd="merchandiser"></div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Creation Date</label>
                                                <asp:TextBox ID="txtCreationDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                                            </div>

                                            <!-- ===== Additional Commercial / Planning Fields ===== -->
                                            <div class="col-12"><h6 class="text-uppercase text-secondary fw-bold sec-title">Commercial &amp; Planning</h6></div>
                                            <div class="col-md-3">
                                                <label class="form-label">Buyer Style Ref</label>
                                                <asp:TextBox ID="txtBuyerStyleRef" runat="server" CssClass="form-control form-control-sm" MaxLength="50" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Fit Type</label>
                                                <asp:DropDownList ID="ddlFit" runat="server" CssClass="form-select form-select-sm">
                                                    <asp:ListItem Value="">-- Select --</asp:ListItem>
                                                    <asp:ListItem>Regular</asp:ListItem>
                                                    <asp:ListItem>Slim</asp:ListItem>
                                                    <asp:ListItem>Relaxed</asp:ListItem>
                                                    <asp:ListItem>Oversized</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Target Price &amp; Currency</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtTargetPrice" runat="server" CssClass="form-control" placeholder="FOB Price" MaxLength="20" />
                                                    <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-select" Style="max-width: 90px">
                                                        <asp:ListItem>USD</asp:ListItem>
                                                        <asp:ListItem>EUR</asp:ListItem>
                                                        <asp:ListItem>GBP</asp:ListItem>
                                                        <asp:ListItem>BDT</asp:ListItem>
                                                    </asp:DropDownList>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Delivery Date</label>
                                                <asp:TextBox ID="txtDeliveryDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">HS Code</label>
                                                <asp:TextBox ID="txtHSCode" runat="server" CssClass="form-control form-control-sm" MaxLength="30" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Country of Origin</label>
                                                <asp:TextBox ID="txtCountryOrigin" runat="server" CssClass="form-control form-control-sm" Text="Bangladesh" MaxLength="50" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Lead Time (Days) / MOQ</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtLeadTime" runat="server" CssClass="form-control" placeholder="Lead Time" MaxLength="10" />
                                                    <asp:TextBox ID="txtMOQ" runat="server" CssClass="form-control" placeholder="MOQ" MaxLength="10" />
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">SMV</label>
                                                <asp:TextBox ID="txtSMV" runat="server" CssClass="form-control form-control-sm" MaxLength="10" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Sample Type</label>
                                                <asp:DropDownList ID="ddlSampleType" runat="server" CssClass="form-select form-select-sm">
                                                    <asp:ListItem Value="">-- Select --</asp:ListItem>
                                                    <asp:ListItem>Proto</asp:ListItem>
                                                    <asp:ListItem>Fit</asp:ListItem>
                                                    <asp:ListItem>Size Set</asp:ListItem>
                                                    <asp:ListItem>PP</asp:ListItem>
                                                    <asp:ListItem>Shipment</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Garment Weight (g/pc)</label>
                                                <asp:TextBox ID="txtGarmentWeight" runat="server" CssClass="form-control form-control-sm" MaxLength="10" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Packing Type</label>
                                                <asp:TextBox ID="txtPacking" runat="server" CssClass="form-control form-control-sm" MaxLength="100" />
                                            </div>

                                            <div class="col-12">
                                                <label class="form-label">Internal Remarks / Notes</label>
                                                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control form-control-sm" placeholder="Enter remarks..." MaxLength="500" />
                                            </div>
                                        </div>
                                    </div>

                                    <!-- TAB 2: STYLE IMAGE & DESIGN -->
                                    <div class="tab-pane fade" id="image-tab">
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-images"></i> Style Image &amp; Technical Sketch Repository</h6>
                                            <span class="small text-muted">ফাইল সিলেক্ট করে উপরের Save/Update চাপুন (Max 10 MB)</span>
                                        </div>
                                        <div class="row g-3">
                                            <div class="col-md-4">
                                                <div class="img-box h-100">
                                                    <i class="bi bi-image fs-1 text-muted"></i>
                                                    <p class="small text-muted mb-1">Front View Image</p>
                                                    <asp:Image ID="imgFront" runat="server" CssClass="img-fluid mb-2" Style="max-height: 160px" Visible="false" />
                                                    <asp:FileUpload ID="fuFront" runat="server" CssClass="form-control form-control-sm" accept="image/*" />
                                                    <div class="mt-2">
                                                        <asp:Label ID="lblFrontName" runat="server" CssClass="small fw-bold text-muted" Text="No file selected" />
                                                        <asp:HyperLink ID="lnkFrontZoom" runat="server" Target="_blank" Visible="false" CssClass="btn btn-xs btn-outline-secondary"><i class="bi bi-zoom-in"></i></asp:HyperLink>
                                                        <asp:LinkButton ID="btnDelFront" runat="server" CommandArgument="Front" OnCommand="DeleteImage_Command" Visible="false" CssClass="btn btn-xs btn-outline-danger" OnClientClick="return confirm('Delete this image?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="img-box h-100">
                                                    <i class="bi bi-image fs-1 text-muted"></i>
                                                    <p class="small text-muted mb-1">Back View Image</p>
                                                    <asp:Image ID="imgBack" runat="server" CssClass="img-fluid mb-2" Style="max-height: 160px" Visible="false" />
                                                    <asp:FileUpload ID="fuBack" runat="server" CssClass="form-control form-control-sm" accept="image/*" />
                                                    <div class="mt-2">
                                                        <asp:Label ID="lblBackName" runat="server" CssClass="small fw-bold text-muted" Text="No file selected" />
                                                        <asp:HyperLink ID="lnkBackZoom" runat="server" Target="_blank" Visible="false" CssClass="btn btn-xs btn-outline-secondary"><i class="bi bi-zoom-in"></i></asp:HyperLink>
                                                        <asp:LinkButton ID="btnDelBack" runat="server" CommandArgument="Back" OnCommand="DeleteImage_Command" Visible="false" CssClass="btn btn-xs btn-outline-danger" OnClientClick="return confirm('Delete this image?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <div class="img-box h-100">
                                                    <i class="bi bi-file-earmark-code fs-1 text-muted"></i>
                                                    <p class="small text-muted mb-1">Technical Sketch / CAD</p>
                                                    <asp:Image ID="imgTech" runat="server" CssClass="img-fluid mb-2" Style="max-height: 160px" Visible="false" />
                                                    <asp:FileUpload ID="fuTech" runat="server" CssClass="form-control form-control-sm" />
                                                    <div class="mt-2">
                                                        <asp:Label ID="lblTechName" runat="server" CssClass="small fw-bold text-muted" Text="No file selected" />
                                                        <asp:HyperLink ID="lnkTechZoom" runat="server" Target="_blank" Visible="false" CssClass="btn btn-xs btn-outline-secondary"><i class="bi bi-download"></i></asp:HyperLink>
                                                        <asp:LinkButton ID="btnDelTech" runat="server" CommandArgument="Technical" OnCommand="DeleteImage_Command" Visible="false" CssClass="btn btn-xs btn-outline-danger" OnClientClick="return confirm('Delete this file?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- TAB 3: PRODUCT SPECIFICATION -->
                                    <div class="tab-pane fade" id="spec-tab">
                                        <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-sliders"></i> Garment Specifications &amp; Construction</h6>
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <label class="form-label">Fabric Type</label>
                                                <asp:TextBox ID="txtFabricType" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. Fleece" MaxLength="100" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Knit / Woven</label>
                                                <div data-dd="knitWoven"></div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Construction &amp; GSM</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtConstruction" runat="server" CssClass="form-control" placeholder="Construction" MaxLength="100" />
                                                    <asp:TextBox ID="txtSpecGsm" runat="server" CssClass="form-control" placeholder="GSM" MaxLength="20" />
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Composition</label>
                                                <asp:TextBox ID="txtSpecComposition" runat="server" CssClass="form-control form-control-sm" placeholder="e.g. 80% Cotton 20% Poly" MaxLength="150" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Fabric Width &amp; Finish</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtFabricWidth" runat="server" CssClass="form-control" placeholder="Width" MaxLength="50" />
                                                    <asp:TextBox ID="txtFinish" runat="server" CssClass="form-control" placeholder="Finish" MaxLength="100" />
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Wash Type</label>
                                                <asp:TextBox ID="txtWashType" runat="server" CssClass="form-control form-control-sm" placeholder="Wash Type" MaxLength="100" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Sleeve &amp; Neck Type</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtSleeve" runat="server" CssClass="form-control" placeholder="Sleeve" MaxLength="100" />
                                                    <asp:TextBox ID="txtNeck" runat="server" CssClass="form-control" placeholder="Neck" MaxLength="100" />
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Closure &amp; Pocket Type</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtClosure" runat="server" CssClass="form-control" placeholder="Closure" MaxLength="100" />
                                                    <asp:TextBox ID="txtPocket" runat="server" CssClass="form-control" placeholder="Pocket" MaxLength="100" />
                                                </div>
                                            </div>

                                            <!-- ===== Additional Specification Fields ===== -->
                                            <div class="col-md-3">
                                                <label class="form-label">Print / Embroidery</label>
                                                <asp:TextBox ID="txtPrintEmb" runat="server" CssClass="form-control form-control-sm" MaxLength="150" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Main Label / Care Label</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtMainLabel" runat="server" CssClass="form-control" placeholder="Main Label" MaxLength="100" />
                                                    <asp:TextBox ID="txtCareLabel" runat="server" CssClass="form-control" placeholder="Care Label" MaxLength="100" />
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Stitch Type &amp; SPI</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtStitchType" runat="server" CssClass="form-control" placeholder="Stitch" MaxLength="100" />
                                                    <asp:TextBox ID="txtSPI" runat="server" CssClass="form-control" placeholder="SPI" MaxLength="10" />
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Hem Type</label>
                                                <asp:TextBox ID="txtHemType" runat="server" CssClass="form-control form-control-sm" MaxLength="100" />
                                            </div>
                                            <div class="col-md-12">
                                                <label class="form-label">Care Instruction</label>
                                                <asp:TextBox ID="txtCareInstr" runat="server" CssClass="form-control form-control-sm" MaxLength="300" />
                                            </div>
                                        </div>
                                    </div>

                                    <!-- TAB 4: COLOR & SIZE -->
                                    <div class="tab-pane fade" id="colorsize-tab">
                                        <div class="row">
                                            <div class="col-md-6">
                                                <h6 class="text-uppercase text-secondary fw-bold mb-2">Color Configuration</h6>
                                                <div class="add-row">
                                                    <div class="row g-2">
                                                        <div class="col-5"><div data-dd="color"></div></div>
                                                        <div class="col-4"><asp:TextBox ID="txtPantone" runat="server" CssClass="form-control form-control-sm" placeholder="Pantone" MaxLength="50" /></div>
                                                        <div class="col-3"><asp:LinkButton ID="btnAddColor" runat="server" CssClass="btn btn-sm btn-outline-primary w-100" OnClick="btnAddColor_Click"><i class="bi bi-plus-lg"></i> Add</asp:LinkButton></div>
                                                    </div>
                                                </div>
                                                <div class="table-responsive">
                                                    <asp:GridView ID="gvColors" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" OnRowCommand="gvColors_RowCommand" EmptyDataText="No color added.">
                                                        <Columns>
                                                            <asp:BoundField DataField="ColorCode" HeaderText="Code" />
                                                            <asp:BoundField DataField="ColorName" HeaderText="Color Name" />
                                                            <asp:BoundField DataField="PantoneCode" HeaderText="Pantone" />
                                                            <asp:TemplateField HeaderText="Active">
                                                                <ItemTemplate>
                                                                    <span class='badge <%# GetActiveCss(Eval("IsActive")) %>'><%# GetActiveText(Eval("IsActive")) %></span>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Action">
                                                                <ItemTemplate><asp:LinkButton runat="server" CommandName="DelRow" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-xs btn-outline-danger"><i class="bi bi-trash"></i></asp:LinkButton></ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </div>
                                            </div>
                                            <div class="col-md-6">
                                                <h6 class="text-uppercase text-secondary fw-bold mb-2">Size Configuration</h6>
                                                <div class="add-row">
                                                    <div class="row g-2">
                                                        <div class="col-9"><div data-dd="size"></div></div>
                                                        <div class="col-3"><asp:LinkButton ID="btnAddSize" runat="server" CssClass="btn btn-sm btn-outline-primary w-100" OnClick="btnAddSize_Click"><i class="bi bi-plus-lg"></i> Add</asp:LinkButton></div>
                                                    </div>
                                                </div>
                                                <div class="table-responsive">
                                                    <asp:GridView ID="gvSizes" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" OnRowCommand="gvSizes_RowCommand" EmptyDataText="No size added.">
                                                        <Columns>
                                                            <asp:BoundField DataField="SizeCode" HeaderText="Code" />
                                                            <asp:BoundField DataField="SizeName" HeaderText="Size Name" />
                                                            <asp:BoundField DataField="SizeRange" HeaderText="Range" />
                                                            <asp:TemplateField HeaderText="Active">
                                                                <ItemTemplate>
                                                                    <span class='badge <%# GetActiveCss(Eval("IsActive")) %>'><%# GetActiveText(Eval("IsActive")) %></span>
                                                                </ItemTemplate>
                                                            </asp:TemplateField>
                                                            <asp:TemplateField HeaderText="Action">
                                                                <ItemTemplate><asp:LinkButton runat="server" CommandName="DelRow" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-xs btn-outline-danger"><i class="bi bi-trash"></i></asp:LinkButton></ItemTemplate>
                                                            </asp:TemplateField>
                                                        </Columns>
                                                    </asp:GridView>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- TAB 5: FABRIC -->
                                    <div class="tab-pane fade" id="fabric-tab">
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-layers"></i> Style Fabric Requirements Master</h6>
                                            <button type="button" class="btn btn-sm btn-success"><i class="bi bi-box-arrow-up-right"></i> Go to Fabric Booking</button>
                                        </div>

                                        <!-- ===== Fabric Name Builder ===== -->
                                        <div class="fnb-card" id="fnbCard">
                                            <div class="fnb-head" onclick="document.getElementById('fnbCard').classList.toggle('collapsed')">
                                                <span class="ttl"><i class="bi bi-magic"></i> Fabric Name Builder <small class="text-muted fw-normal">— ড্রপডাউন থেকে নির্বাচন করে স্ট্যান্ডার্ড নাম তৈরি করুন</small></span>
                                                <i class="bi bi-chevron-down chev"></i>
                                            </div>
                                            <div class="fnb-body">
                                                <div class="row g-3">
                                                    <div class="col-lg-8">
                                                        <div class="row g-2">
                                                            <div class="col-md-4">
                                                                <label class="fnb-lbl"><i class="bi bi-flask"></i> Composition *</label>
                                                                <select id="fnbComp" class="form-select form-select-sm">
                                                                    <option value="100% Cotton">100% Cotton</option>
                                                                    <option value="100% Polyester">100% Polyester</option>
                                                                    <option value="60% Cotton 40% Polyester">CVC (60/40)</option>
                                                                    <option value="65% Polyester 35% Cotton">TC (65/35)</option>
                                                                    <option value="95% Cotton 5% Spandex">Cotton Elastane (95/5)</option>
                                                                    <option value="100% Viscose">100% Viscose</option>
                                                                    <option value="100% Linen">100% Linen</option>
                                                                    <option value="80% Cotton 20% Polyester">80/20 CVC</option>
                                                                    <option value="50% Cotton 50% Polyester">50/50 Blend</option>
                                                                    <option value="100% Nylon">100% Nylon</option>
                                                                    <option value="__custom">✏️ Custom...</option>
                                                                </select>
                                                                <input type="text" id="fnbCompCustom" class="form-control form-control-sm mt-1 d-none" placeholder="Custom composition" maxlength="150" />
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="fnb-lbl"><i class="bi bi-layers"></i> Construction *</label>
                                                                <select id="fnbConst" class="form-select form-select-sm">
                                                                    <optgroup label="🧶 Knit">
                                                                        <option>Single Jersey</option><option>1x1 Rib</option><option>2x2 Rib</option><option>Interlock</option>
                                                                        <option>Pique</option><option>French Terry</option><option>Fleece</option><option>Jacquard Knit</option>
                                                                    </optgroup>
                                                                    <optgroup label="🪡 Woven">
                                                                        <option>Twill</option><option>Canvas</option><option>Oxford</option><option>Poplin</option>
                                                                        <option>Satin</option><option>Chiffon</option><option>Denim</option><option>Corduroy</option>
                                                                    </optgroup>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="fnb-lbl"><i class="bi bi-speedometer2"></i> GSM *</label>
                                                                <div class="input-group input-group-sm">
                                                                    <input type="number" id="fnbGsm" class="form-control" value="180" min="50" max="800" />
                                                                    <span class="input-group-text">GSM</span>
                                                                </div>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="fnb-lbl"><i class="bi bi-record-circle"></i> Yarn Count</label>
                                                                <select id="fnbYarn" class="form-select form-select-sm">
                                                                    <option value="20s/1">20s/1</option><option value="24s/1">24s/1</option><option value="26s/1">26s/1</option>
                                                                    <option value="30s/1" selected>30s/1</option><option value="36s/1">36s/1</option><option value="40s/1">40s/1</option>
                                                                    <option value="20/2">20/2</option><option value="30/2">30/2</option><option value="40/2">40/2</option>
                                                                    <option value="">N/A</option>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="fnb-lbl"><i class="bi bi-palette"></i> Dyeing Type</label>
                                                                <select id="fnbDye" class="form-select form-select-sm">
                                                                    <option>Solid Dyed</option><option>Yarn Dyed</option><option>Melange</option>
                                                                    <option>AOP Printed</option><option>Greige / RFD</option><option>Tie Dye</option>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="fnb-lbl"><i class="bi bi-stars"></i> Finishing</label>
                                                                <select id="fnbFinish" class="form-select form-select-sm">
                                                                    <option>Bio-Wash</option><option>Peach Finish</option><option>Mercerized</option>
                                                                    <option>Brushed / Silicon</option><option>Waterproof / DWR</option><option>Regular Wash</option><option>Enzyme Wash</option>
                                                                </select>
                                                            </div>
                                                            <div class="col-md-4">
                                                                <label class="fnb-lbl">Category (Auto)</label>
                                                                <div><span id="fnbCat" class="fnb-cat knit">🧶 Knit Fabric</span></div>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="col-lg-4">
                                                        <div class="fnb-preview">
                                                            <div>
                                                                <div class="cap"><span><i class="bi bi-eye"></i> Live Preview</span><span class="code" id="fnbCode">FAB-000</span></div>
                                                                <div class="name" id="fnbName">—</div>
                                                                <div class="fnb-tags" id="fnbTags"></div>
                                                            </div>
                                                            <div class="fnb-actions">
                                                                <button type="button" class="btn btn-sm btn-copy" id="fnbCopyBtn"><i class="bi bi-clipboard me-1"></i> Copy Name</button>
                                                                <button type="button" class="btn btn-sm btn-use" id="fnbUseBtn"><i class="bi bi-arrow-down-circle me-1"></i> Use in Fabric Row</button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <!-- ===== /Fabric Name Builder ===== -->

                                        <div class="add-row">
                                            <div class="row g-2">
                                                <div class="col-md-2"><asp:TextBox ID="txtFabCode" runat="server" CssClass="form-control form-control-sm" placeholder="Code (FAB-001)" MaxLength="20" /></div>
                                                <div class="col-md-3"><asp:TextBox ID="txtFabName" runat="server" CssClass="form-control form-control-sm" placeholder="Fabric Name &amp; Type" MaxLength="150" /></div>
                                                <div class="col-md-3"><asp:TextBox ID="txtFabComp" runat="server" CssClass="form-control form-control-sm" placeholder="Composition" MaxLength="150" /></div>
                                                <div class="col-md-2"><asp:TextBox ID="txtFabGsm" runat="server" CssClass="form-control form-control-sm" placeholder="GSM" MaxLength="20" /></div>
                                                <div class="col-md-2"><asp:TextBox ID="txtFabColor" runat="server" CssClass="form-control form-control-sm" placeholder="Color" MaxLength="100" /></div>
                                                <div class="col-md-2"><asp:TextBox ID="txtFabCons" runat="server" CssClass="form-control form-control-sm" placeholder="Consumption" /></div>
                                                <div class="col-md-2"><asp:TextBox ID="txtFabWaste" runat="server" CssClass="form-control form-control-sm" placeholder="Wastage %" /></div>
                                                <div class="col-md-2"><div data-dd="fabUnit"></div></div>
                                                <div class="col-md-2"><asp:LinkButton ID="btnAddFabric" runat="server" CssClass="btn btn-sm btn-outline-primary w-100" OnClick="btnAddFabric_Click"><i class="bi bi-plus-lg"></i> Add Fabric</asp:LinkButton></div>
                                            </div>
                                        </div>
                                        <div class="table-responsive">
                                            <asp:GridView ID="gvFabric" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" OnRowCommand="gvFabric_RowCommand" EmptyDataText="No fabric added.">
                                                <Columns>
                                                    <asp:BoundField DataField="FabricCode" HeaderText="Code" />
                                                    <asp:BoundField DataField="FabricName" HeaderText="Fabric Name &amp; Type" HtmlEncode="false" />
                                                    <asp:BoundField DataField="Composition" HeaderText="Composition" />
                                                    <asp:BoundField DataField="GSM" HeaderText="GSM" />
                                                    <asp:BoundField DataField="ColorName" HeaderText="Color" />
                                                    <asp:BoundField DataField="Consumption" HeaderText="Consumption" DataFormatString="{0:0.000}" />
                                                    <asp:BoundField DataField="WastagePercent" HeaderText="Wastage %" DataFormatString="{0:0.00}" />
                                                    <asp:BoundField DataField="Unit" HeaderText="Unit" />
                                                    <asp:BoundField DataField="Category" HeaderText="Type" />
                                                    <asp:TemplateField HeaderText="Action">
                                                        <ItemTemplate><asp:LinkButton runat="server" CommandName="DelRow" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-xs btn-outline-danger"><i class="bi bi-trash"></i></asp:LinkButton></ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>

                                    <!-- TAB 6: ACCESSORIES -->
                                    <div class="tab-pane fade" id="accessories-tab">
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-tag"></i> Trims &amp; Accessories Requirements</h6>
                                            <button type="button" class="btn btn-sm btn-success"><i class="bi bi-box-arrow-up-right"></i> Go to Accessories Booking</button>
                                        </div>
                                        <div class="add-row">
                                            <div class="row g-2">
                                                <div class="col-md-2"><asp:TextBox ID="txtAccCode" runat="server" CssClass="form-control form-control-sm" placeholder="Item Code" MaxLength="20" /></div>
                                                <div class="col-md-3"><asp:TextBox ID="txtAccName" runat="server" CssClass="form-control form-control-sm" placeholder="Item Name" MaxLength="150" /></div>
                                                <div class="col-md-2"><div data-dd="accType"></div></div>
                                                <div class="col-md-3"><asp:TextBox ID="txtAccSizeColor" runat="server" CssClass="form-control form-control-sm" placeholder="Size / Color" MaxLength="100" /></div>
                                                <div class="col-md-2"><asp:TextBox ID="txtAccCons" runat="server" CssClass="form-control form-control-sm" placeholder="Consumption" /></div>
                                                <div class="col-md-2"><div data-dd="accUnit"></div></div>
                                                <div class="col-md-2"><asp:TextBox ID="txtAccWaste" runat="server" CssClass="form-control form-control-sm" placeholder="Wastage %" /></div>
                                                <div class="col-md-3"><asp:TextBox ID="txtAccSupplier" runat="server" CssClass="form-control form-control-sm" placeholder="Supplier" MaxLength="150" /></div>
                                                <div class="col-md-2"><asp:LinkButton ID="btnAddAcc" runat="server" CssClass="btn btn-sm btn-outline-primary w-100" OnClick="btnAddAcc_Click"><i class="bi bi-plus-lg"></i> Add Item</asp:LinkButton></div>
                                            </div>
                                        </div>
                                        <div class="table-responsive">
                                            <asp:GridView ID="gvAcc" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" OnRowCommand="gvAcc_RowCommand" EmptyDataText="No accessories added.">
                                                <Columns>
                                                    <asp:BoundField DataField="ItemCode" HeaderText="Item Code" />
                                                    <asp:BoundField DataField="ItemName" HeaderText="Item Name" />
                                                    <asp:BoundField DataField="ItemType" HeaderText="Type" />
                                                    <asp:BoundField DataField="SizeColor" HeaderText="Size/Color" />
                                                    <asp:BoundField DataField="Consumption" HeaderText="Consumption" DataFormatString="{0:0.000}" />
                                                    <asp:BoundField DataField="Unit" HeaderText="Unit" />
                                                    <asp:BoundField DataField="WastagePercent" HeaderText="Wastage %" DataFormatString="{0:0.00}" />
                                                    <asp:BoundField DataField="Supplier" HeaderText="Supplier" />
                                                    <asp:TemplateField HeaderText="Action">
                                                        <ItemTemplate><asp:LinkButton runat="server" CommandName="DelRow" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-xs btn-outline-danger"><i class="bi bi-trash"></i></asp:LinkButton></ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>

                                    <!-- TAB 7: SET -->
                                    <div class="tab-pane fade" id="set-tab">
                                        <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-collection"></i> Set Configuration</h6>
                                        <div class="table-responsive mb-3">
                                            <asp:GridView ID="gvSets" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" OnRowCommand="gvSets_RowCommand" EmptyDataText="No set configured for this style.">
                                                <Columns>
                                                    <asp:BoundField DataField="SetName" HeaderText="Set Name" />
                                                    <asp:TemplateField HeaderText="Action">
                                                        <ItemTemplate>
                                                            <asp:LinkButton runat="server" CommandName="LoadSet" CommandArgument='<%# Eval("SetID") %>' CssClass="btn btn-xs btn-outline-primary"><i class="bi bi-folder2-open"></i> Load</asp:LinkButton>
                                                            <asp:LinkButton runat="server" CommandName="OffSet" CommandArgument='<%# Eval("SetID") %>' CssClass="btn btn-xs btn-outline-danger" OnClientClick="return confirm('Deactivate this set?');"><i class="bi bi-slash-circle"></i></asp:LinkButton>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                        <div class="add-row">
                                            <div class="row g-2 align-items-end">
                                                <div class="col-md-4"><label class="form-label">Set Name</label><asp:TextBox ID="txtSetName" runat="server" CssClass="form-control form-control-sm" MaxLength="100" /></div>
                                                <div class="col-md-5"><label class="form-label">Remarks</label><asp:TextBox ID="txtSetRemarks" runat="server" CssClass="form-control form-control-sm" MaxLength="300" /></div>
                                                <div class="col-md-3"><div class="btn-group btn-group-sm w-100">
                                                    <asp:LinkButton ID="btnSetSave" runat="server" CssClass="btn btn-primary" OnClick="btnSetSave_Click"><i class="bi bi-save"></i> Save Set</asp:LinkButton>
                                                    <asp:LinkButton ID="btnSetNew" runat="server" CssClass="btn btn-outline-secondary" OnClick="btnSetNew_Click"><i class="bi bi-file-earmark-plus"></i> New</asp:LinkButton>
                                                </div></div>
                                            </div>
                                        </div>
                                        <div class="add-row">
                                            <div class="row g-2">
                                                <div class="col-md-4"><asp:TextBox ID="txtCompName" runat="server" CssClass="form-control form-control-sm" placeholder="Component name (Top / Bottom / Inner)" MaxLength="100" /></div>
                                                <div class="col-md-2"><asp:TextBox ID="txtCompQty" runat="server" CssClass="form-control form-control-sm" placeholder="Qty per Set" Text="1" /></div>
                                                <div class="col-md-3"><asp:TextBox ID="txtCompStyle" runat="server" CssClass="form-control form-control-sm" placeholder="Component Style ID (optional)" /></div>
                                                <div class="col-md-3"><asp:LinkButton ID="btnAddSetComp" runat="server" CssClass="btn btn-sm btn-outline-primary w-100" OnClick="btnAddSetComp_Click"><i class="bi bi-plus-lg"></i> Add Component</asp:LinkButton></div>
                                            </div>
                                        </div>
                                        <div class="table-responsive mb-3">
                                            <asp:GridView ID="gvSetComp" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" OnRowCommand="gvSetComp_RowCommand" EmptyDataText="No components.">
                                                <Columns>
                                                    <asp:BoundField DataField="ComponentName" HeaderText="Component" />
                                                    <asp:BoundField DataField="ComponentStyleID" HeaderText="Style ID" />
                                                    <asp:BoundField DataField="QtyPerSet" HeaderText="Qty / Set" DataFormatString="{0:0.###}" />
                                                    <asp:TemplateField HeaderText="Action">
                                                        <ItemTemplate><asp:LinkButton runat="server" CommandName="DelRow" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-xs btn-outline-danger"><i class="bi bi-trash"></i></asp:LinkButton></ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                        <div class="add-row">
                                            <div class="row g-2">
                                                <div class="col-md-3"><div data-dd="mapComp"></div></div>
                                                <div class="col-md-2"><div data-dd="mapType"></div></div>
                                                <div class="col-md-2"><asp:TextBox ID="txtMapSet" runat="server" CssClass="form-control form-control-sm" placeholder="Set code (e.g. L)" MaxLength="50" /></div>
                                                <div class="col-md-2"><asp:TextBox ID="txtMapComp" runat="server" CssClass="form-control form-control-sm" placeholder="Component code (e.g. 32)" MaxLength="50" /></div>
                                                <div class="col-md-3"><asp:LinkButton ID="btnAddSetMap" runat="server" CssClass="btn btn-sm btn-outline-primary w-100" OnClick="btnAddSetMap_Click"><i class="bi bi-link-45deg"></i> Add Mapping</asp:LinkButton></div>
                                            </div>
                                        </div>
                                        <div class="table-responsive">
                                            <asp:GridView ID="gvSetMap" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" OnRowCommand="gvSetMap_RowCommand" EmptyDataText="No size/color mapping (same codes are used).">
                                                <Columns>
                                                    <asp:BoundField DataField="ComponentName" HeaderText="Component" />
                                                    <asp:BoundField DataField="MapType" HeaderText="Type" />
                                                    <asp:BoundField DataField="SetCode" HeaderText="Set Code" />
                                                    <asp:BoundField DataField="ComponentCode" HeaderText="Component Code" />
                                                    <asp:TemplateField HeaderText="Action">
                                                        <ItemTemplate><asp:LinkButton runat="server" CommandName="DelRow" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-xs btn-outline-danger"><i class="bi bi-trash"></i></asp:LinkButton></ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>

                                    <!-- TAB 8: HISTORY -->
                                    <div class="tab-pane fade" id="history-tab">
                                        <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-clock-history"></i> Audit Trail &amp; Activity Log</h6>
                                        <div class="table-responsive">
                                            <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" EmptyDataText="No history yet.">
                                                <Columns>
                                                    <asp:BoundField DataField="ActionDateTime" HeaderText="Date &amp; Time" DataFormatString="{0:yyyy-MM-dd hh:mm tt}" />
                                                    <asp:BoundField DataField="ActionByUser" HeaderText="User" />
                                                    <asp:TemplateField HeaderText="Action">
                                                        <ItemTemplate><span class="badge bg-primary"><%# Eval("ActionType") %></span></ItemTemplate>
                                                    </asp:TemplateField>
                                                    <asp:BoundField DataField="FieldName" HeaderText="Field" />
                                                    <asp:BoundField DataField="PreviousValue" HeaderText="Previous Value" />
                                                    <asp:BoundField DataField="NewValue" HeaderText="New Value" />
                                                    <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Sidebar -->
                    <div class="col-lg-3">
                        <div class="card card-erp">
                            <div class="card-header-erp"><i class="bi bi-info-square"></i> System Summary</div>
                            <div class="card-body small">
                                <p class="mb-1"><b>Created By:</b> <asp:Label ID="lblCreatedBy" runat="server" Text="-" /></p>
                                <p class="mb-1"><b>Created Date:</b> <asp:Label ID="lblCreatedDate" runat="server" Text="-" /></p>
                                <p class="mb-1"><b>Last Modified:</b> <asp:Label ID="lblModified" runat="server" Text="-" /></p>
                                <p class="mb-0"><b>Lock Status:</b> <asp:Label ID="lblLock" runat="server" Text="Unlocked for Editing" /></p>
                            </div>
                        </div>
                    </div>
                </div>
            </asp:Panel>

        </div>

    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- ===== Fabric Name Builder script ===== -->
    <script>
(function () {
    var KNIT = ['Single Jersey', '1x1 Rib', '2x2 Rib', 'Interlock', 'Pique', 'French Terry', 'Fleece', 'Jacquard Knit'];
    function $(id) { return document.getElementById(id); }
    function esc(s) { return String(s).replace(/[&<>"]/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c]; }); }

    function comp() {
        var v = $('fnbComp').value;
        if (v === '__custom') return ($('fnbCompCustom').value || '').trim() || 'Custom Blend';
        return v;
    }
    function isKnit() { return KNIT.indexOf($('fnbConst').value) >= 0; }
    function fullName() {
        var p = [comp(), $('fnbConst').value, ($('fnbGsm').value || '180') + ' GSM', $('fnbYarn').value, $('fnbDye').value, $('fnbFinish').value];
        return p.filter(function (x) { return x; }).join(' ');
    }
    function nextCode() { return 'FAB-' + String(Math.floor(100 + Math.random() * 900)); }

    function update() {
        if (!$('fnbName')) return;
        $('fnbCompCustom').classList.toggle('d-none', $('fnbComp').value !== '__custom');
        $('fnbName').textContent = fullName();

        var cat = $('fnbCat');
        cat.textContent = isKnit() ? '🧶 Knit Fabric' : '🪡 Woven Fabric';
        cat.className = 'fnb-cat ' + (isKnit() ? 'knit' : 'woven');

        $('fnbTags').innerHTML =
            '<span>' + esc(comp()) + '</span><span>' + esc($('fnbConst').value) + '</span>' +
            '<span>' + esc($('fnbGsm').value || '180') + ' GSM</span><span>' + esc($('fnbFinish').value) + '</span>';
    }

    function flash(el) {
        if (!el) return;
        el.classList.remove('fnb-flash'); void el.offsetWidth; el.classList.add('fnb-flash');
    }

    function useInRow() {
        var name = fullName();
        var code = $('txtFabCode');
        if (!code.value.trim()) code.value = $('fnbCode').textContent;
        $('txtFabName').value = name.length > 150 ? name.substring(0, 150) : name;
        $('txtFabComp').value = comp();
        $('txtFabGsm').value = $('fnbGsm').value || '';
        $('hfFabCat').value = isKnit() ? 'Knit' : 'Woven';
        ['txtFabCode', 'txtFabName', 'txtFabComp', 'txtFabGsm'].forEach(function (id) { flash($(id)); });
        $('txtFabColor').focus();
    }

    function copyName() {
        var t = fullName(), btn = $('fnbCopyBtn'), old = btn.innerHTML;
        function done() { btn.innerHTML = '<i class="bi bi-check2 me-1"></i> Copied!'; setTimeout(function () { btn.innerHTML = old; }, 1400); }
        if (navigator.clipboard) navigator.clipboard.writeText(t).then(done);
        else { var ta = document.createElement('textarea'); ta.value = t; document.body.appendChild(ta); ta.select(); document.execCommand('copy'); document.body.removeChild(ta); done(); }
    }

    function init() {
        if (!$('fnbCard')) return;
        ['fnbComp', 'fnbConst', 'fnbYarn', 'fnbDye', 'fnbFinish'].forEach(function (id) { $(id).addEventListener('change', update); });
        ['fnbGsm', 'fnbCompCustom'].forEach(function (id) { $(id).addEventListener('input', update); });
        $('fnbUseBtn').addEventListener('click', useInRow);
        $('fnbCopyBtn').addEventListener('click', copyName);
        $('fnbCode').textContent = nextCode();
        update();
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init); else init();
})();
</script>

</body>
</html>
