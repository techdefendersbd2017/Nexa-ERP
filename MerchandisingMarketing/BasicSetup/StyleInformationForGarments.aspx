<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StyleInformationForGarments.aspx.cs" Inherits="Nexa_ERP.MasterConfiguration.BuyerManagement.StyleInformationForGarments" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Garments ERP - Style Entry Master</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

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
        .quick-action-btn { text-align: left; margin-bottom: 0.5rem; font-size: 0.8rem; }
        .workflow-step { text-align: center; padding: 0.5rem; background: #f1f5f9; border-radius: 0.25rem; font-weight: 600; margin-bottom: 0.5rem; }
        .workflow-step.done { background: #dcfce7; color: #166534; border: 1px solid #86efac; }
        .workflow-step.active { background: #dbeafe; color: #1d4ed8; border: 1px solid #93c5fd; }
        .btn-xs { padding: 0.1rem 0.35rem; font-size: 0.75rem; }
        .add-row { background: #f8fafc; border: 1px dashed #cbd5e1; border-radius: 0.375rem; padding: 0.5rem; margin-bottom: 0.75rem; }
        .img-box { border: 2px dashed #cbd5e1; border-radius: 0.375rem; padding: 1rem; text-align: center; background: #f8fafc; }

        /* =========================================================
           Searchable Dropdown (Employee Entry পেজের মতো)
        ========================================================= */
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

        @media print { .navbar-erp, .nav-tabs, .btn, .col-lg-3 { display: none !important; } .tab-pane { display: block !important; opacity: 1 !important; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">

        <asp:HiddenField ID="hfStyleId" runat="server" Value="0" ClientIDMode="Static" />
        <asp:HiddenField ID="hfUserId" runat="server" Value="0" ClientIDMode="Static" />
        <asp:HiddenField ID="hfTab" runat="server" Value="" ClientIDMode="Static" />
        <asp:HiddenField ID="hfLocked" runat="server" Value="0" ClientIDMode="Static" />

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
        <asp:HiddenField ID="hfCountry" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfCurrency" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfPaymentTerm" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfShipmentMode" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfKnitWoven" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfColor" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfSize" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfFabUnit" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfAccType" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfAccUnit" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfCostStatus" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfTnaTemplate" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfDocType" runat="server" ClientIDMode="Static" />

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
                                    <asp:LinkButton ID="btnUpdate" runat="server" CssClass="btn btn-success" OnClick="btnSave_Click" ToolTip="Update Record" Visible="false"><i class="bi bi-arrow-clockwise"></i> Update</asp:LinkButton>
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
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#commercial-tab" type="button"><i class="bi bi-cash-coin me-1"></i> Commercial</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#image-tab" type="button"><i class="bi bi-images me-1"></i> Images</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#spec-tab" type="button"><i class="bi bi-sliders me-1"></i> Specification</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#colorsize-tab" type="button"><i class="bi bi-grid-3x3 me-1"></i> Color &amp; Size</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#fabric-tab" type="button"><i class="bi bi-layers me-1"></i> Fabric</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#accessories-tab" type="button"><i class="bi bi-tag me-1"></i> Accessories</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#costing-tab" type="button"><i class="bi bi-calculator me-1"></i> Costing</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#workorder-tab" type="button"><i class="bi bi-tools me-1"></i> Work Order</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tna-tab" type="button"><i class="bi bi-calendar-check me-1"></i> TNA</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#docs-tab" type="button"><i class="bi bi-file-earmark-text me-1"></i> Documents</button></li>
                                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#approval-tab" type="button"><i class="bi bi-shield-check me-1"></i> Approval</button></li>
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
                                            <div class="col-12">
                                                <label class="form-label">Internal Remarks / Notes</label>
                                                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control form-control-sm" placeholder="Enter remarks..." MaxLength="500" />
                                            </div>
                                        </div>
                                    </div>

                                    <!-- TAB 2: BUYER & COMMERCIAL -->
                                    <div class="tab-pane fade" id="commercial-tab">
                                        <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-cash-coin"></i> Buyer &amp; Commercial Terms</h6>
                                        <div class="row g-3">
                                            <div class="col-md-4">
                                                <label class="form-label">Buyer Style No / Product No</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtBuyerStyleNo" runat="server" CssClass="form-control" placeholder="Buyer Style No" MaxLength="50" />
                                                    <asp:TextBox ID="txtProductNo" runat="server" CssClass="form-control" placeholder="Product No" MaxLength="50" />
                                                </div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Destination Country</label>
                                                <div data-dd="country"></div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Currency</label>
                                                <div data-dd="currency"></div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Payment Term</label>
                                                <div data-dd="paymentTerm"></div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Shipment Mode</label>
                                                <div data-dd="shipmentMode"></div>
                                            </div>
                                            <div class="col-md-4">
                                                <label class="form-label">Port of Loading &amp; Discharge</label>
                                                <div class="input-group input-group-sm">
                                                    <asp:TextBox ID="txtPortLoading" runat="server" CssClass="form-control" placeholder="Port of Loading" MaxLength="100" />
                                                    <asp:TextBox ID="txtPortDischarge" runat="server" CssClass="form-control" placeholder="Port of Discharge" MaxLength="100" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- TAB 3: STYLE IMAGE & DESIGN -->
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

                                    <!-- TAB 4: PRODUCT SPECIFICATION -->
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
                                        </div>
                                    </div>

                                    <!-- TAB 5: COLOR & SIZE -->
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
                                                                <ItemTemplate><span class='badge <%# Convert.ToBoolean(Eval("IsActive")) ? "bg-success" : "bg-secondary" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "Yes" : "No" %></span></ItemTemplate>
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
                                                                <ItemTemplate><span class='badge <%# Convert.ToBoolean(Eval("IsActive")) ? "bg-success" : "bg-secondary" %>'><%# Convert.ToBoolean(Eval("IsActive")) ? "Yes" : "No" %></span></ItemTemplate>
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

                                    <!-- TAB 6: FABRIC -->
                                    <div class="tab-pane fade" id="fabric-tab">
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-layers"></i> Style Fabric Requirements Master</h6>
                                            <button type="button" class="btn btn-sm btn-success"><i class="bi bi-box-arrow-up-right"></i> Go to Fabric Booking</button>
                                        </div>
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
                                                    <asp:TemplateField HeaderText="Action">
                                                        <ItemTemplate><asp:LinkButton runat="server" CommandName="DelRow" CommandArgument='<%# Container.DataItemIndex %>' CssClass="btn btn-xs btn-outline-danger"><i class="bi bi-trash"></i></asp:LinkButton></ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>

                                    <!-- TAB 7: ACCESSORIES -->
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

                                    <!-- TAB 8: COSTING -->
                                    <div class="tab-pane fade" id="costing-tab">
                                        <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-calculator"></i> Costing Summary Overview</h6>
                                        <div class="row g-3 mb-3">
                                            <div class="col-md-3">
                                                <div class="p-3 border rounded bg-light"><span class="text-muted small">Costing Status</span>
                                                    <h5 class="text-success mb-0 mt-1"><asp:Label ID="lblCostStatus" runat="server" Text="-" /></h5></div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="p-3 border rounded bg-light"><span class="text-muted small">Latest Version &amp; Date</span>
                                                    <h5 class="mb-0 mt-1"><asp:Label ID="lblCostVer" runat="server" Text="-" /></h5></div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="p-3 border rounded bg-light"><span class="text-muted small">Total Cost</span>
                                                    <h5 class="text-primary mb-0 mt-1"><asp:Label ID="lblTotalCost" runat="server" Text="-" /></h5></div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="p-3 border rounded bg-light"><span class="text-muted small">FOB / Buyer Price</span>
                                                    <h5 class="text-dark mb-0 mt-1"><asp:Label ID="lblFob" runat="server" Text="-" /></h5></div>
                                            </div>
                                            <div class="col-md-2">
                                                <div class="p-3 border rounded bg-light"><span class="text-muted small">Profit Margin</span>
                                                    <h5 class="text-success mb-0 mt-1"><asp:Label ID="lblProfit" runat="server" Text="-" /></h5></div>
                                            </div>
                                        </div>
                                        <div class="add-row">
                                            <div class="row g-2 align-items-end">
                                                <div class="col-md-3">
                                                    <label class="form-label">Costing Status</label>
                                                    <div data-dd="costStatus"></div>
                                                </div>
                                                <div class="col-md-3"><label class="form-label">Total Cost</label><asp:TextBox ID="txtCostTotal" runat="server" CssClass="form-control form-control-sm" /></div>
                                                <div class="col-md-3"><label class="form-label">FOB Price</label><asp:TextBox ID="txtCostFob" runat="server" CssClass="form-control form-control-sm" /></div>
                                                <div class="col-md-3"><asp:LinkButton ID="btnCreateCosting" runat="server" CssClass="btn btn-sm btn-primary w-100" OnClick="btnCreateCosting_Click"><i class="bi bi-plus-circle"></i> Create Costing (New Version)</asp:LinkButton></div>
                                            </div>
                                        </div>
                                        <div class="table-responsive">
                                            <asp:GridView ID="gvCosting" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" EmptyDataText="No costing created yet.">
                                                <Columns>
                                                    <asp:BoundField DataField="VersionNo" HeaderText="Ver" />
                                                    <asp:BoundField DataField="CostingStatus" HeaderText="Status" />
                                                    <asp:BoundField DataField="TotalCost" HeaderText="Total Cost" DataFormatString="{0:0.00}" />
                                                    <asp:BoundField DataField="FOBPrice" HeaderText="FOB" DataFormatString="{0:0.00}" />
                                                    <asp:BoundField DataField="ProfitMarginPercent" HeaderText="Profit %" DataFormatString="{0:0.00}" />
                                                    <asp:BoundField DataField="CostingDate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" />
                                                    <asp:TemplateField HeaderText="Current">
                                                        <ItemTemplate><%# Convert.ToBoolean(Eval("IsCurrent")) ? "<span class='badge bg-success'>Current</span>" : "" %></ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>

                                    <!-- TAB 9: WORK ORDER -->
                                    <div class="tab-pane fade" id="workorder-tab">
                                        <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-tools"></i> Embellishment &amp; Special Process Work Orders</h6>
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <div class="card p-3 border">
                                                    <asp:CheckBox ID="chkPrinting" runat="server" Text=" Printing Required" CssClass="fw-bold mb-2" />
                                                    <asp:TextBox ID="txtPrintingDetails" runat="server" CssClass="form-control form-control-sm mb-2" placeholder="e.g. Chest Print" MaxLength="200" />
                                                    <button type="button" class="btn btn-sm btn-outline-primary"><i class="bi bi-file-earmark-plus"></i> Printing Work Order</button>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="card p-3 border">
                                                    <asp:CheckBox ID="chkEmbroidery" runat="server" Text=" Embroidery Required" CssClass="fw-bold mb-2" />
                                                    <asp:TextBox ID="txtEmbroideryDetails" runat="server" CssClass="form-control form-control-sm mb-2" placeholder="Details" MaxLength="200" />
                                                    <button type="button" class="btn btn-sm btn-outline-primary"><i class="bi bi-file-earmark-plus"></i> Embroidery Work Order</button>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="card p-3 border">
                                                    <asp:CheckBox ID="chkWashing" runat="server" Text=" Washing Required" CssClass="fw-bold mb-2" />
                                                    <asp:TextBox ID="txtWashingDetails" runat="server" CssClass="form-control form-control-sm mb-2" placeholder="e.g. Enzyme" MaxLength="200" />
                                                    <button type="button" class="btn btn-sm btn-outline-primary"><i class="bi bi-file-earmark-plus"></i> Wash Work Order</button>
                                                </div>
                                            </div>
                                            <div class="col-md-3">
                                                <div class="card p-3 border">
                                                    <asp:CheckBox ID="chkSpecial" runat="server" Text=" Special Process" CssClass="fw-bold mb-2" />
                                                    <asp:TextBox ID="txtSpecialDetails" runat="server" CssClass="form-control form-control-sm mb-2" placeholder="Details" MaxLength="200" />
                                                    <button type="button" class="btn btn-sm btn-outline-primary"><i class="bi bi-file-earmark-plus"></i> Special Work Order</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- TAB 10: TNA -->
                                    <div class="tab-pane fade" id="tna-tab">
                                        <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-calendar-check"></i> TNA Milestones Summary</h6>
                                        <div class="row g-3">
                                            <div class="col-md-4">
                                                <label class="form-label">TNA Template</label>
                                                <div data-dd="tnaTemplate"></div>
                                            </div>
                                            <div class="col-md-2"><label class="form-label">Sample Deadline</label><asp:TextBox ID="txtSampleDeadline" runat="server" TextMode="Date" CssClass="form-control form-control-sm" /></div>
                                            <div class="col-md-2"><label class="form-label">PP Meeting Date</label><asp:TextBox ID="txtPPMeeting" runat="server" TextMode="Date" CssClass="form-control form-control-sm" /></div>
                                            <div class="col-md-2"><label class="form-label">Fabric In Date</label><asp:TextBox ID="txtFabricIn" runat="server" TextMode="Date" CssClass="form-control form-control-sm" /></div>
                                            <div class="col-md-2"><label class="form-label">Shipment Date</label><asp:TextBox ID="txtShipmentDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" /></div>
                                        </div>
                                    </div>

                                    <!-- TAB 11: DOCUMENTS -->
                                    <div class="tab-pane fade" id="docs-tab">
                                        <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-file-earmark-text"></i> Document Management</h6>
                                        <div class="add-row">
                                            <div class="row g-2 align-items-end">
                                                <div class="col-md-4"><asp:FileUpload ID="fuDoc" runat="server" CssClass="form-control form-control-sm" /></div>
                                                <div class="col-md-3"><div data-dd="docType"></div></div>
                                                <div class="col-md-2"><asp:TextBox ID="txtDocVersion" runat="server" CssClass="form-control form-control-sm" placeholder="Version (v1.0)" MaxLength="20" /></div>
                                                <div class="col-md-3"><asp:LinkButton ID="btnUploadDoc" runat="server" CssClass="btn btn-sm btn-primary w-100" OnClick="btnUploadDoc_Click"><i class="bi bi-upload"></i> Upload Document</asp:LinkButton></div>
                                            </div>
                                        </div>
                                        <div class="table-responsive">
                                            <asp:GridView ID="gvDocs" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle" HeaderStyle-CssClass="table-light" GridLines="None" OnRowCommand="gvDocs_RowCommand" EmptyDataText="No document uploaded.">
                                                <Columns>
                                                    <asp:BoundField DataField="DocumentName" HeaderText="Document Name" />
                                                    <asp:BoundField DataField="DocumentType" HeaderText="Type" />
                                                    <asp:BoundField DataField="UploadedDate" HeaderText="Upload Date" DataFormatString="{0:yyyy-MM-dd}" />
                                                    <asp:BoundField DataField="UploadedBy" HeaderText="Uploaded By" />
                                                    <asp:BoundField DataField="VersionNo" HeaderText="Version" />
                                                    <asp:TemplateField HeaderText="Action">
                                                        <ItemTemplate>
                                                            <asp:HyperLink runat="server" NavigateUrl='<%# ResolveUrl(Eval("FilePath").ToString()) %>' Target="_blank" CssClass="btn btn-xs btn-outline-secondary"><i class="bi bi-download"></i></asp:HyperLink>
                                                            <asp:LinkButton runat="server" CommandName="DelDoc" CommandArgument='<%# Eval("DocumentID") %>' CssClass="btn btn-xs btn-outline-danger" OnClientClick="return confirm('Delete this document?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>

                                    <!-- TAB 12: APPROVAL -->
                                    <div class="tab-pane fade" id="approval-tab">
                                        <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-shield-check"></i> Workflow &amp; Approval Status</h6>
                                        <div class="row mb-4">
                                            <asp:Literal ID="ltWorkflow" runat="server" />
                                        </div>
                                        <div class="row g-3">
                                            <div class="col-md-3">
                                                <label class="form-label">Submitted By / Date</label>
                                                <asp:TextBox ID="txtSubmittedBy" runat="server" CssClass="form-control form-control-sm bg-light" ReadOnly="true" />
                                            </div>
                                            <div class="col-md-3">
                                                <label class="form-label">Approved By / Date</label>
                                                <asp:TextBox ID="txtApprovedBy" runat="server" CssClass="form-control form-control-sm bg-light" ReadOnly="true" />
                                            </div>
                                            <div class="col-md-6">
                                                <label class="form-label">Approval Remarks</label>
                                                <asp:TextBox ID="txtApprovalRemarks" runat="server" CssClass="form-control form-control-sm" placeholder="Enter remarks" MaxLength="500" />
                                            </div>
                                            <div class="col-12 mt-3">
                                                <asp:LinkButton ID="btnApprove" runat="server" CssClass="btn btn-sm btn-success me-2" OnClick="btnApprove_Click"><i class="bi bi-check-circle"></i> Approve</asp:LinkButton>
                                                <asp:LinkButton ID="btnReject" runat="server" CssClass="btn btn-sm btn-danger me-2" OnClick="btnReject_Click"><i class="bi bi-x-circle"></i> Reject</asp:LinkButton>
                                                <asp:LinkButton ID="btnForward" runat="server" CssClass="btn btn-sm btn-warning me-2" OnClick="btnForward_Click"><i class="bi bi-arrow-right-circle"></i> Forward</asp:LinkButton>
                                                <asp:LinkButton ID="btnSubmit" runat="server" CssClass="btn btn-sm btn-secondary" OnClick="btnSubmit_Click"><i class="bi bi-send"></i> Submit</asp:LinkButton>
                                            </div>
                                            <div class="col-12">
                                                <asp:GridView ID="gvApproval" runat="server" AutoGenerateColumns="false" CssClass="table table-bordered table-sm align-middle mt-2" HeaderStyle-CssClass="table-light" GridLines="None" EmptyDataText="No approval activity yet.">
                                                    <Columns>
                                                        <asp:BoundField DataField="ActionDate" HeaderText="Date &amp; Time" DataFormatString="{0:yyyy-MM-dd hh:mm tt}" />
                                                        <asp:BoundField DataField="WorkflowStep" HeaderText="Step" />
                                                        <asp:BoundField DataField="ActionTaken" HeaderText="Action" />
                                                        <asp:BoundField DataField="ActionBy" HeaderText="By" />
                                                        <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                                                    </Columns>
                                                </asp:GridView>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- TAB 13: HISTORY -->
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
                        <div class="card card-erp mb-3">
                            <div class="card-header-erp"><i class="bi bi-lightning-charge"></i> Quick Actions / Related Links</div>
                            <div class="card-body d-grid gap-2 p-2">
                                <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center"><span><i class="bi bi-cart-check me-2"></i> PO Entry</span><asp:Label ID="bdgPO" runat="server" CssClass="badge bg-secondary" Text="0 Records" /></button>
                                <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center"><span><i class="bi bi-calculator me-2"></i> Costing</span><asp:Label ID="bdgCosting" runat="server" CssClass="badge bg-secondary" Text="Pending" /></button>
                                <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center"><span><i class="bi bi-layers me-2"></i> Fabric Booking</span><asp:Label ID="bdgFabric" runat="server" CssClass="badge bg-secondary" Text="0 Records" /></button>
                                <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center"><span><i class="bi bi-tag me-2"></i> Accessories Booking</span><asp:Label ID="bdgAcc" runat="server" CssClass="badge bg-secondary" Text="Pending" /></button>
                                <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center"><span><i class="bi bi-calendar-range me-2"></i> TNA Schedule</span><asp:Label ID="bdgTna" runat="server" CssClass="badge bg-secondary" Text="Pending" /></button>
                                <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center"><span><i class="bi bi-tools me-2"></i> Printing Work Order</span><asp:Label ID="bdgPrint" runat="server" CssClass="badge bg-secondary" Text="Not Req." /></button>
                                <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center"><span><i class="bi bi-tools me-2"></i> Embroidery W/O</span><asp:Label ID="bdgEmb" runat="server" CssClass="badge bg-secondary" Text="Not Req." /></button>
                                <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center"><span><i class="bi bi-gear me-2"></i> Production Order</span><span class="badge bg-secondary">Pending</span></button>
                                <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center"><span><i class="bi bi-kanban me-2"></i> Production Plan</span><span class="badge bg-secondary">Not Scheduled</span></button>
                                <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center"><span><i class="bi bi-truck me-2"></i> Shipment Module</span><span class="badge bg-secondary">Pending</span></button>
                            </div>
                        </div>

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

    <!-- ১) ড্রপডাউনের অপশন তালিকা (Server থেকে) -->
    <script>var OPT = {}; try { OPT = JSON.parse('<%= HttpUtility.JavaScriptStringEncode(OptJson) %>'); } catch (e) { window.__optErr = e.message; }</script>

    <!-- ২) Searchable ড্রপডাউন (Employee Entry এর মতো; এখানে value + text আলাদা, Brand নির্ভর করে Buyer এর উপর) -->
    <script>
        var FIELDS = [
            // List panel
            { id: 'buyerFilter', hf: 'hfBuyerFilter', ph: 'All Buyers' },
            { id: 'statusFilter', hf: 'hfStatusFilter', ph: 'All' },
            // Header
            { id: 'mainStatus', hf: 'hfMainStatus', ph: 'Select' },
            // Basic
            { id: 'buyer', hf: 'hfBuyer', ph: 'Select Buyer' },
            { id: 'brand', hf: 'hfBrand', ph: 'Select Brand', dep: 'buyer', depLabel: 'buyer' },
            { id: 'agent', hf: 'hfAgent', ph: 'Direct Buyer' },
            { id: 'season', hf: 'hfSeason', ph: 'Season' },
            { id: 'seasonYear', hf: 'hfSeasonYear', ph: 'Year' },
            { id: 'productCategory', hf: 'hfProductCategory', ph: 'Select' },
            { id: 'productType', hf: 'hfProductType', ph: 'Select' },
            { id: 'garmentType', hf: 'hfGarmentType', ph: 'Type' },
            { id: 'gender', hf: 'hfGender', ph: 'Gender' },
            { id: 'merchandiser', hf: 'hfMerchandiser', ph: 'Select Merchandiser' },
            // Commercial
            { id: 'country', hf: 'hfCountry', ph: 'Select Country' },
            { id: 'currency', hf: 'hfCurrency', ph: 'Select' },
            { id: 'paymentTerm', hf: 'hfPaymentTerm', ph: 'Select Payment Term' },
            { id: 'shipmentMode', hf: 'hfShipmentMode', ph: 'Select' },
            // Specification / Color / Size / Fabric / Accessories / Costing / TNA / Docs
            { id: 'knitWoven', hf: 'hfKnitWoven', ph: 'Select' },
            { id: 'color', hf: 'hfColor', ph: 'Select Color' },
            { id: 'size', hf: 'hfSize', ph: 'Select Size' },
            { id: 'fabUnit', hf: 'hfFabUnit', ph: 'Unit' },
            { id: 'accType', hf: 'hfAccType', ph: 'Type' },
            { id: 'accUnit', hf: 'hfAccUnit', ph: 'Unit' },
            { id: 'costStatus', hf: 'hfCostStatus', ph: 'Select' },
            { id: 'tnaTemplate', hf: 'hfTnaTemplate', ph: 'Select Template' },
            { id: 'docType', hf: 'hfDocType', ph: 'Select Type' }
        ];
        FIELDS.forEach(function (f) { f.opts = OPT[f.id] || []; });
        var state = {};

        var esc = function (s) { return String(s).replace(/[&<>"']/g, function (c) { return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]; }); };
        var fieldOf = function (id) { return FIELDS.filter(function (f) { return f.id === id; })[0]; };

        // value -> দেখানোর text (অপশনে না থাকলে value নিজেই দেখায়)
        function labelOf(f, v) {
            for (var i = 0; i < f.opts.length; i++) if (f.opts[i].v === v) return f.opts[i].t;
            return v;
        }

        function buildFilters() {
            FIELDS.forEach(function (f) {
                var host = document.querySelector('[data-dd="' + f.id + '"]');
                var hf = document.getElementById(f.hf);
                if (!host || !hf) return;          // যে Panel দেখা যাচ্ছে না, সেটা বাদ
                host.id = 'wrap-' + f.id;
                state[f.id] = hf.value || '';
                host.innerHTML =
                    '<div class="dd-ctl">' +
                      '<div id="fld-' + f.id + '" class="dd-fld" tabindex="0" onclick="toggleDD(\'' + f.id + '\')" ' +
                          'onkeydown="if(event.key===\'Enter\'||event.key===\' \'){event.preventDefault();toggleDD(\'' + f.id + '\')}">' +
                        '<span class="txt"></span>' +
                        '<span class="clr" onclick="clearField(\'' + f.id + '\',event)" title="Clear"><i class="bi bi-x-lg"></i></span>' +
                        '<i class="bi bi-chevron-expand chev"></i>' +
                      '</div>' +
                      '<div id="panel-' + f.id + '" class="dd-panel d-none" onclick="event.stopPropagation()">' +
                        '<div class="ps"><i class="bi bi-search"></i>' +
                          '<input type="text" id="q-' + f.id + '" placeholder="Search..." autocomplete="off" ' +
                          'oninput="renderList(\'' + f.id + '\')" onkeydown="if(event.key===\'Enter\')return false;"></div>' +
                        '<div class="pl" id="list-' + f.id + '"></div>' +
                      '</div>' +
                    '</div>';
                refreshField(f.id);
            });
        }

        function syncHidden(id) {
            document.getElementById(fieldOf(id).hf).value = state[id] || '';
        }

        function refreshField(id) {
            var f = fieldOf(id), v = state[id] || '';
            var box = document.getElementById('fld-' + id);
            box.classList.toggle('has', v !== '');
            box.querySelector('.txt').textContent = v !== '' ? labelOf(f, v) : f.ph;
            renderList(id);
        }

        function renderList(id) {
            var f = fieldOf(id), cur = state[id] || '';
            var q = (document.getElementById('q-' + id).value || '').toLowerCase();
            var list = document.getElementById('list-' + id);

            if (f.dep && !state[f.dep]) {
                list.innerHTML = '<div class="empty">Select ' + esc(f.depLabel || f.dep) + ' first</div>';
                return;
            }
            var html = f.opts.map(function (o, i) { return { o: o, i: i }; }).filter(function (x) {
                if (f.dep && String(x.o.p) !== state[f.dep]) return false;
                return String(x.o.t).toLowerCase().indexOf(q) > -1;
            }).map(function (x) {
                var on = x.o.v === cur;
                return '<div class="it ' + (on ? 'sel-single' : '') + '" onclick="pick(\'' + id + '\',' + x.i + ')"><span>' + esc(x.o.t) + '</span>' +
                       (on ? '<i class="bi bi-check-lg ms-auto"></i>' : '') + '</div>';
            }).join('');
            list.innerHTML = html || '<div class="empty">No results found</div>';
        }

        function pick(id, i) {
            state[id] = fieldOf(id).opts[i].v;
            closeAll();
            syncHidden(id); refreshField(id);
            if (window.onFieldChange) window.onFieldChange(id);
        }

        function clearField(id, ev) {
            if (ev) ev.stopPropagation();
            state[id] = '';
            syncHidden(id); refreshField(id);
            if (window.onFieldChange) window.onFieldChange(id);
        }

        function closeAll() {
            document.querySelectorAll('.dd-panel').forEach(function (p) { p.classList.add('d-none'); });
            document.querySelectorAll('.dd-fld.open').forEach(function (b) { b.classList.remove('open'); });
        }

        function toggleDD(id) {
            var box = document.getElementById('fld-' + id);
            if (box.classList.contains('dis')) return;
            var panel = document.getElementById('panel-' + id);
            var wasOpen = !panel.classList.contains('d-none');
            closeAll();
            if (wasOpen) return;
            panel.classList.remove('d-none');
            box.classList.add('open');
            panel.classList.remove('right');
            if (panel.getBoundingClientRect().right > window.innerWidth - 8) panel.classList.add('right');
            var q = document.getElementById('q-' + id);
            q.value = ''; renderList(id);
            setTimeout(function () { q.focus(); }, 0);
        }

        document.addEventListener('click', function (e) { if (!e.target.closest('[id^="wrap-"]')) closeAll(); });
        document.addEventListener('keydown', function (e) { if (e.key === 'Escape') closeAll(); });

        function setFieldDisabled(id, off) {
            var box = document.getElementById('fld-' + id);
            if (box) box.classList.toggle('dis', !!off);
        }
    </script>

    <!-- ৩) পেজের নিজস্ব লজিক -->
    <script>
        // Buyer বদলালে Brand খালি (Brand তালিকা Buyer অনুযায়ী ফিল্টার হয়)
        window.onFieldChange = function (id) {
            if (id === 'buyer') {
                state['brand'] = '';
                syncHidden('brand');
                refreshField('brand');
            }
        };

        // Locked (Active) style এ Status ড্রপডাউন বন্ধ
        function applyLock() {
            var hl = document.getElementById('hfLocked');
            if (hl && hl.value === '1') setFieldDisabled('mainStatus', true);
        }

        // Postback এর পরও আগের Tab খোলা রাখে (hfTab এ মনে রাখে)
        function initTabs() {
            var hf = document.getElementById('hfTab');
            if (!hf) return;
            document.querySelectorAll('#styleTabs [data-bs-toggle="tab"]').forEach(function (b) {
                b.addEventListener('shown.bs.tab', function () { hf.value = b.getAttribute('data-bs-target'); });
            });
            if (hf.value) {
                var el = document.querySelector('#styleTabs [data-bs-target="' + hf.value + '"]');
                if (el) bootstrap.Tab.getOrCreateInstance(el).show();
            }
        }

        document.addEventListener('DOMContentLoaded', function () {
            buildFilters();
            applyLock();
            initTabs();
        });
    </script>
</body>
</html>
