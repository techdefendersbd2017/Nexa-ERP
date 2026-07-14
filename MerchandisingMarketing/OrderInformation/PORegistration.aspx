<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PORegistration.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.OrderInformation.PORegistration" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>PO Registration - NexaERP</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<style>
/* ===== BASE ===== */
body { background:#f4f6f9; font-size:13px; }
.card { border-radius:10px; }
.card-header { padding:8px 15px; }
.card-header h4 { font-size:16px; margin:0; }
label { font-size:12px; font-weight:500; margin-bottom:2px; display:block; }
.form-control,.form-select { border-radius:6px; height:30px; font-size:12px; padding:2px 6px; }
textarea.form-control { height:auto; }
.btn { border-radius:6px; font-size:12px; padding:4px 12px; }
.table { font-size:12px; }
.table th,.table td { padding:4px 6px; vertical-align:middle; }
.card-body { padding:12px 15px; }

/* ===== MULTI-PO TABS ===== */
.po-tabs-wrapper {
    background:#fff; border-bottom:2px solid #dee2e6;
    padding:6px 15px 0; display:flex; align-items:flex-end; gap:4px;
    overflow-x:auto; flex-wrap:nowrap; min-height:44px;
}
.po-tab {
    display:inline-flex; align-items:center; gap:6px;
    padding:5px 14px 5px 12px; border-radius:8px 8px 0 0;
    border:1px solid #dee2e6; border-bottom:none;
    background:#f8f9fa; cursor:pointer; font-size:12px; font-weight:500;
    color:#6c757d; transition:all 0.15s; white-space:nowrap; user-select:none;
    position:relative; top:2px;
}
.po-tab:hover { background:#e7f1ff; color:#0d6efd; }
.po-tab.active { background:#fff; color:#0d6efd; font-weight:700; border-color:#0d6efd #dee2e6 #fff; z-index:2; }
.po-tab .tab-close {
    width:16px; height:16px; border-radius:50%; background:transparent;
    border:none; color:#adb5bd; font-size:11px; cursor:pointer; padding:0;
    display:flex; align-items:center; justify-content:center; line-height:1;
}
.po-tab .tab-close:hover { background:#dc3545; color:#fff; }
.po-tab .tab-badge {
    font-size:10px; background:#e7f1ff; color:#0d6efd; border-radius:4px;
    padding:1px 5px; font-weight:600;
}
.po-tab.active .tab-badge { background:#0d6efd; color:#fff; }
.add-po-tab {
    display:inline-flex; align-items:center; gap:4px;
    padding:5px 12px; border-radius:8px 8px 0 0;
    border:1px dashed #0d6efd; border-bottom:none;
    background:transparent; cursor:pointer; font-size:12px; color:#0d6efd;
    transition:background 0.15s; white-space:nowrap;
    position:relative; top:2px;
}
.add-po-tab:hover { background:#e7f1ff; }

/* ===== PO PANEL ===== */
.po-panel { display:none; }
.po-panel.active { display:block; }

/* ===== SECTION COLLAPSE ===== */
.section-collapse-btn {
    background:none; border:none; font-size:12px; font-weight:700;
    color:#0d6efd; text-transform:uppercase; letter-spacing:0.5px;
    padding:0; cursor:pointer; display:flex; align-items:center; gap:5px;
}
.section-collapse-btn:focus { outline:none; }

/* ===== STYLE SEARCH BOX ===== */
.style-search-box {
    background:#e7f1ff; border:1px solid #b6d4fe; border-radius:6px;
    height:30px; font-size:12px; padding:2px 8px; color:#0d6efd;
    font-weight:600; display:flex; align-items:center; justify-content:space-between;
    cursor:pointer; transition:background 0.15s;
}
.style-search-box:hover { background:#d0e4ff; }

/* ===== INFO READONLY BAR ===== */
.info-readonly {
    background:#f8f9fa; border:1px solid #dee2e6; border-radius:8px;
    padding:7px 14px; display:flex; flex-wrap:wrap; gap:14px;
    align-items:center; font-size:12px;
}
.info-readonly .info-item { display:flex; flex-direction:column; }
.info-readonly .info-label { font-size:10px; color:#6c757d; font-weight:600; text-transform:uppercase; }
.info-readonly .info-value { font-weight:600; color:#212529; font-size:12px; }
.info-readonly .info-value.ph { color:#adb5bd; font-weight:400; font-style:italic; }

/* ===== AUTO ID BOX ===== */
.auto-id-box {
    background:#e7f1ff; border:1px solid #b6d4fe; border-radius:6px;
    height:30px; font-size:12px; padding:2px 8px; color:#0d6efd;
    font-weight:600; display:flex; align-items:center;
}

/* ===== STATUS DOT ===== */
.status-dot { display:inline-block; width:8px; height:8px; border-radius:50%; }
.s-pending   { background:#ffc107; }
.s-confirmed { background:#0d6efd; }
.s-production{ background:#fd7e14; }
.s-shipped   { background:#198754; }
.s-closed    { background:#6c757d; }

/* ===== MATRIX ===== */
.matrix-wrap { overflow-x:auto; }
.matrix-table { border-collapse:collapse; font-size:12px; min-width:300px; width:100%; }
.matrix-table th {
    background:#e9ecef; padding:5px 7px; text-align:center;
    border:1px solid #dee2e6; white-space:nowrap; font-size:11px; font-weight:600;
}
.matrix-table td { border:1px solid #dee2e6; padding:2px 3px; }
.matrix-table .row-label { background:#f8f9fa; font-weight:600; min-width:110px; padding:3px 6px; }
.matrix-table .total-cell { background:#e7f1ff; font-weight:700; color:#0d6efd; text-align:center; padding:3px 6px; }
.matrix-table .total-row td { background:#dce8ff; font-weight:700; color:#0d6efd; text-align:center; }
.matrix-table .grand-cell { background:#0d6efd; color:#fff; font-weight:700; text-align:center; padding:3px 8px; }
.matrix-table input.qty-inp {
    width:58px; border:none; background:transparent;
    text-align:center; font-size:12px; outline:none; padding:2px 3px; display:block; margin:auto;
}
.matrix-table input.qty-inp:focus { background:#fff3cd; border-radius:3px; }
.matrix-table input.color-nm {
    width:100%; font-size:12px; font-weight:600; height:26px;
    border:1px solid transparent; border-radius:4px; padding:2px 5px; background:transparent;
}
.matrix-table input.color-nm:focus { border-color:#b6d4fe; background:#fff; outline:none; }
.matrix-table input.size-nm {
    width:54px; font-size:11px; font-weight:700; height:22px; text-align:center;
    border:1px solid transparent; border-radius:4px; padding:2px 3px; background:transparent;
}
.matrix-table input.size-nm:focus { border-color:#b6d4fe; background:#fff; outline:none; }

/* ===== SUMMARY STRIP ===== */
.summary-strip {
    background:#e7f1ff; border:1px solid #b6d4fe; border-radius:8px;
    padding:7px 14px; display:flex; gap:24px; flex-wrap:wrap; font-size:12px; align-items:center;
}
.s-item { display:flex; flex-direction:column; }
.s-lbl { font-size:10px; color:#6c757d; font-weight:600; text-transform:uppercase; }
.s-val { font-size:14px; font-weight:700; color:#0d6efd; }

/* ===== TEMPLATE PILLS ===== */
.tpl-pill {
    display:inline-flex; align-items:center; gap:3px;
    background:#fff; border:1px solid #dee2e6; border-radius:5px;
    padding:2px 9px; cursor:pointer; font-size:11px; font-weight:500; transition:all 0.15s;
}
.tpl-pill:hover { background:#e7f1ff; border-color:#0d6efd; color:#0d6efd; }

/* ===== INNER TABLE CARD ===== */
.inner-table-card { border:1px solid #dee2e6; border-radius:8px; overflow:hidden; }

/* ===== MULTI-PO SUMMARY TABLE ===== */
.po-summary-table { font-size:12px; }
.po-summary-table th { background:#f0f4ff; font-size:11px; font-weight:600; padding:5px 8px; }
.po-summary-table td { padding:4px 8px; }
.po-summary-table .badge-status { font-size:10px; padding:2px 8px; border-radius:10px; }

/* ===== GRAND TOTAL BAR ===== */
.grand-total-bar {
    background:linear-gradient(90deg,#0d6efd,#3d8bfd);
    color:#fff; border-radius:8px; padding:8px 16px;
    display:flex; gap:30px; flex-wrap:wrap; font-size:12px; align-items:center;
}
.gt-item { display:flex; flex-direction:column; }
.gt-lbl { font-size:10px; opacity:.8; font-weight:600; text-transform:uppercase; }
.gt-val { font-size:15px; font-weight:700; }

/* ===== ACTION BAR ===== */
.action-bar {
    background:#fff; border-top:1px solid #dee2e6;
    padding:8px 15px; display:flex; align-items:center; justify-content:space-between;
}
.action-bar .info-text { font-size:12px; color:#6c757d; }

/* ===== MODAL ===== */
.modal-search-row { cursor:pointer; transition:background 0.1s; }
.modal-search-row:hover td { background:#e7f1ff !important; }
</style>
</head>
<body>
<form id="mainForm" runat="server">
<div class="container-fluid py-2 px-3">
<div class="card shadow-sm">

    <!-- ===== CARD HEADER ===== -->
    <div class="card-header bg-primary text-white d-flex align-items-center justify-content-between">
        <h4 class="mb-0"><i class="bi bi-file-earmark-text me-2"></i>PO Registration</h4>
        <div class="d-flex align-items-center gap-3">
            <span class="text-white-50" style="font-size:12px;">Total POs: <strong id="totalPOCount" class="text-white">0</strong></span>
            <span class="text-white-50" style="font-size:12px;">Grand Total Qty: <strong id="headerGrandQty" class="text-white">0</strong></span>
        </div>
    </div>

    <!-- ===== MULTI-PO TABS ===== -->
    <div class="po-tabs-wrapper" id="poTabsWrapper">
        <!-- tabs injected here -->
        <div class="add-po-tab" onclick="addNewPO()" title="Add New PO">
            <i class="bi bi-plus-lg"></i> Add PO
        </div>
    </div>

    <div class="card-body" id="poTabContent">
        <!-- PO panels injected here -->
        <div id="noPOMessage" class="text-center text-muted py-5">
            <i class="bi bi-file-earmark-plus display-6 d-block mb-2 text-primary opacity-50"></i>
            <div style="font-size:14px;">Click <strong>"+ Add PO"</strong> above to start entering a Purchase Order.</div>
        </div>
    </div>

    <!-- ===== MULTI-PO SUMMARY ===== -->
    <div id="multiPOSummarySection" style="display:none; padding:0 15px 12px;">
        <hr class="mt-0 mb-2"/>
        <div class="d-flex align-items-center justify-content-between mb-2">
            <span style="font-size:12px;font-weight:700;color:#0d6efd;text-transform:uppercase;letter-spacing:.5px;">
                <i class="bi bi-table me-1"></i> All POs Summary
            </span>
        </div>
        <div class="inner-table-card mb-3">
            <div class="table-responsive">
                <table class="table table-sm table-bordered table-hover table-striped mb-0 po-summary-table">
                    <thead class="table-light">
                        <tr>
                            <th>#</th>
                            <th>PO ID</th>
                            <th>PO No. (Buyer)</th>
                            <th>Style No.</th>
                            <th>Buyer</th>
                            <th>PO Type</th>
                            <th>Ship Mode</th>
                            <th>Ship Date</th>
                            <th>Destination</th>
                            <th>Incoterm</th>
                            <th>Currency</th>
                            <th class="text-end">Unit Price</th>
                            <th class="text-end">Total Qty</th>
                            <th class="text-end">Total Value</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="poSummaryBody"></tbody>
                </table>
            </div>
        </div>
        <!-- Grand Total Bar -->
        <div class="grand-total-bar" id="grandTotalBar">
            <div class="gt-item"><span class="gt-lbl">Total POs</span><span class="gt-val" id="gtTotalPOs">0</span></div>
            <div class="gt-item"><span class="gt-lbl">Grand Total Qty</span><span class="gt-val" id="gtGrandQty">0</span></div>
            <div class="gt-item"><span class="gt-lbl">Total Value (USD)</span><span class="gt-val" id="gtTotalValue">—</span></div>
            <div class="gt-item"><span class="gt-lbl">Styles</span><span class="gt-val" id="gtStyles">—</span></div>
            <div class="gt-item"><span class="gt-lbl">Buyers</span><span class="gt-val" id="gtBuyers">—</span></div>
        </div>
    </div>

    <!-- ===== ACTION BAR ===== -->
    <div class="action-bar">
        <div class="info-text">
            Active PO: <strong id="previewActivePO">—</strong> &nbsp;|&nbsp;
            Style: <strong id="previewActiveStyle">—</strong> &nbsp;|&nbsp;
            Status: <strong id="previewActiveStatus">—</strong> &nbsp;|&nbsp;
            Qty: <strong id="previewActiveQty">0</strong>
        </div>
        <div class="d-flex gap-2">
            <button type="button" class="btn btn-secondary" onclick="resetActiveForm()">
                <i class="bi bi-arrow-counterclockwise me-1"></i>Clear
            </button>
            <button type="button" class="btn btn-warning" onclick="saveActiveDraft()">
                <i class="bi bi-floppy me-1"></i>Save Draft
            </button>
            <button type="button" class="btn btn-info text-white" onclick="submitAllPOs()">
                <i class="bi bi-collection me-1"></i>Submit All POs
            </button>
            <asp:LinkButton ID="btnSubmitSingle" runat="server" CssClass="btn btn-success d-inline-flex align-items-center">
                <i class="bi bi-save me-1"></i>Submit Active PO
            </asp:LinkButton>
        </div>
    </div>

</div><!-- end card -->
</div><!-- end container -->
</form>

<!-- ====================================================== -->
<!-- STYLE SEARCH MODAL                                      -->
<!-- ====================================================== -->
<div class="modal fade" id="styleSearchModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header py-2 bg-primary text-white">
                <h6 class="modal-title"><i class="bi bi-search me-2"></i>Search &amp; Select Style</h6>
                <button type="button" class="btn-close btn-close-white btn-sm" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-2">
                <input type="text" id="modalSearchInput" class="form-control mb-2"
                    placeholder="Search by Style No., Style Name, or Buyer..." oninput="filterStyles(this.value)"/>
                <div class="table-responsive" style="max-height:360px;overflow-y:auto;">
                    <table class="table table-sm table-bordered table-hover mb-0">
                        <thead class="table-light sticky-top">
                            <tr>
                                <th>Style No.</th><th>Style Name</th><th>Buyer</th>
                                <th>Category</th><th>Gender</th><th>Type</th><th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="styleSearchBody"></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- ====================================================== -->
<!-- TOAST                                                   -->
<!-- ====================================================== -->
<div class="toast-container position-fixed top-0 end-0 p-3" style="z-index:9999;">
    <div id="toast" class="toast align-items-center text-bg-success border-0" role="alert">
        <div class="d-flex">
            <div class="toast-body" id="toastMsg">Saved!</div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<!-- ====================================================== -->
<!-- PO PANEL TEMPLATE (hidden)                             -->
<!-- ====================================================== -->
<template id="poPanelTemplate">
<div class="po-panel" id="panel_PO_ID">

    <!-- ---- STYLE SEARCH ROW ---- -->
    <div class="mb-3">
        <div class="row g-2 align-items-end">
            <div class="col-md-3">
                <label>Style No. <span class="text-danger">*</span></label>
                <div class="style-search-box" onclick="openStyleSearch('PO_ID')" id="styleBox_PO_ID">
                    <span id="styleBoxTxt_PO_ID">— Click to search Style —</span>
                    <i class="bi bi-search"></i>
                </div>
                <input type="hidden" id="hidStyle_PO_ID" />
            </div>
            <div class="col-md-9">
                <div class="info-readonly">
                    <div class="info-item"><span class="info-label">Style Name</span><span class="info-value ph" id="iName_PO_ID">—</span></div>
                    <div class="info-item"><span class="info-label">Buyer</span><span class="info-value ph" id="iBuyer_PO_ID">—</span></div>
                    <div class="info-item"><span class="info-label">Category</span><span class="info-value ph" id="iCat_PO_ID">—</span></div>
                    <div class="info-item"><span class="info-label">Gender</span><span class="info-value ph" id="iGender_PO_ID">—</span></div>
                    <div class="info-item"><span class="info-label">Fit</span><span class="info-value ph" id="iFit_PO_ID">—</span></div>
                    <div class="info-item"><span class="info-label">Type</span><span class="info-value ph" id="iType_PO_ID">—</span></div>
                    <div class="info-item"><span class="info-label">Merchandiser</span><span class="info-value ph" id="iMerch_PO_ID">—</span></div>
                </div>
            </div>
        </div>
    </div>
    <hr class="my-2"/>

    <!-- ---- SECTION 1: PO BASIC INFO ---- -->
    <div class="mb-3">
        <div class="d-flex align-items-center mb-2">
            <button type="button" class="section-collapse-btn" data-bs-toggle="collapse" data-bs-target="#sec1_PO_ID">
                <i class="bi bi-chevron-down"></i> 1. PO Basic Info
            </button>
        </div>
        <div class="collapse show" id="sec1_PO_ID">
            <div class="row g-2">
                <div class="col-md-2">
                    <label>PO ID</label>
                    <div class="auto-id-box" id="poAutoId_PO_ID">PO-2025-0001</div>
                </div>
                <div class="col-md-2">
                    <label>PO No. (Buyer) <span class="text-danger">*</span></label>
                    <input type="text" class="form-control po-no-input" id="poNo_PO_ID" placeholder="e.g. PO-HM-2025-001" oninput="onPONoChange('PO_ID',this.value)"/>
                </div>
                <div class="col-md-2">
                    <label>PO Date <span class="text-danger">*</span></label>
                    <input type="date" class="form-control" id="poDate_PO_ID"/>
                </div>
                <div class="col-md-1">
                    <label>PO Type</label>
                    <select class="form-select" id="poType_PO_ID">
                        <option value="">—</option>
                        <option>New</option><option>Repeat</option><option>Revised</option>
                    </select>
                </div>
                <div class="col-md-1">
                    <label>Ship Mode</label>
                    <select class="form-select" id="shipMode_PO_ID">
                        <option value="">—</option>
                        <option>Sea</option><option>Air</option><option>Courier</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label>Ship Date</label>
                    <input type="date" class="form-control" id="shipDate_PO_ID"/>
                </div>
                <div class="col-md-2">
                    <label>Ex-Factory Date</label>
                    <input type="date" class="form-control" id="exFactory_PO_ID"/>
                </div>
                <div class="col-md-2">
                    <label>Destination Country</label>
                    <input type="text" class="form-control" id="dest_PO_ID" placeholder="e.g. Germany"/>
                </div>
                <div class="col-md-2">
                    <label>Port of Loading</label>
                    <input type="text" class="form-control" id="portLoading_PO_ID" placeholder="e.g. Chittagong"/>
                </div>
                <div class="col-md-1">
                    <label>Incoterm</label>
                    <select class="form-select" id="incoterm_PO_ID">
                        <option value="">—</option>
                        <option>FOB</option><option>CNF</option><option>CIF</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label>Payment Term</label>
                    <select class="form-select" id="payTerm_PO_ID">
                        <option value="">—</option>
                        <option>LC</option><option>TT</option><option>DP</option>
                    </select>
                </div>
                <div class="col-md-1">
                    <label>Unit Price</label>
                    <input type="number" class="form-control" id="unitPrice_PO_ID" placeholder="0.00" step="0.01" oninput="recalcValue('PO_ID')"/>
                </div>
                <div class="col-md-1">
                    <label>Currency</label>
                    <select class="form-select" id="currency_PO_ID" onchange="recalcValue('PO_ID')">
                        <option>USD</option><option>EUR</option><option>GBP</option>
                    </select>
                </div>
            </div>
        </div>
    </div>
    <hr class="my-2"/>

    <!-- ---- SECTION 2: COLOR-SIZE MATRIX ---- -->
    <div class="mb-3">
        <div class="d-flex align-items-center justify-content-between mb-2 flex-wrap gap-1">
            <button type="button" class="section-collapse-btn" data-bs-toggle="collapse" data-bs-target="#sec2_PO_ID">
                <i class="bi bi-chevron-down"></i> 2. Color &amp; Size Matrix
            </button>
            <div class="d-flex align-items-center gap-1 flex-wrap">
                <span style="font-size:11px;color:#6c757d;">Template:</span>
                <span class="tpl-pill" onclick="loadTemplate('PO_ID','basic')"><i class="bi bi-lightning-charge"></i>S-M-L-XL</span>
                <span class="tpl-pill" onclick="loadTemplate('PO_ID','full')"><i class="bi bi-lightning-charge"></i>XS–3XL</span>
                <span class="tpl-pill" onclick="loadTemplate('PO_ID','num')"><i class="bi bi-lightning-charge"></i>28–40</span>
                <div class="vr mx-1"></div>
                <button type="button" class="btn btn-outline-secondary btn-sm" style="font-size:12px;padding:3px 10px;" onclick="addColorRow('PO_ID')">
                    <i class="bi bi-plus-lg"></i> Color
                </button>
                <button type="button" class="btn btn-outline-primary btn-sm" style="font-size:12px;padding:3px 10px;" onclick="addSizeCol('PO_ID')">
                    <i class="bi bi-plus-lg"></i> Size
                </button>
            </div>
        </div>
        <div class="collapse show" id="sec2_PO_ID">
            <!-- Summary strip -->
            <div class="summary-strip mb-2">
                <div class="s-item"><span class="s-lbl">Total Qty</span><span class="s-val" id="totalQty_PO_ID">0</span></div>
                <div class="s-item"><span class="s-lbl">Unit Price</span><span class="s-val" id="unitPriceDisp_PO_ID">—</span></div>
                <div class="s-item"><span class="s-lbl">Total Value</span><span class="s-val" id="totalValue_PO_ID">—</span></div>
                <div class="s-item"><span class="s-lbl">Colors</span><span class="s-val" id="colorCount_PO_ID">0</span></div>
                <div class="s-item"><span class="s-lbl">Sizes</span><span class="s-val" id="sizeCount_PO_ID">0</span></div>
            </div>
            <div class="inner-table-card">
                <div class="matrix-wrap">
                    <table class="matrix-table" id="matrix_PO_ID">
                        <thead id="matHead_PO_ID"></thead>
                        <tbody id="matBody_PO_ID"></tbody>
                        <tfoot id="matFoot_PO_ID"></tfoot>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <hr class="my-2"/>

    <!-- ---- SECTION 3: PO-SPECIFIC TRIM ---- -->
    <div class="mb-3">
        <div class="d-flex align-items-center mb-2">
            <button type="button" class="section-collapse-btn" data-bs-toggle="collapse" data-bs-target="#sec3_PO_ID">
                <i class="bi bi-chevron-down"></i> 3. PO-Specific Trim
            </button>
            <span class="ms-2 badge bg-secondary" style="font-size:10px;" id="trimBadge_PO_ID">From Style: 0 items</span>
        </div>
        <div class="collapse show" id="sec3_PO_ID">
            <div class="inner-table-card">
                <div class="table-responsive">
                    <table class="table table-sm table-bordered table-hover table-striped mb-0">
                        <thead class="table-light">
                            <tr>
                                <th style="min-width:120px;">Item Name</th>
                                <th style="min-width:80px;">Type</th>
                                <th style="min-width:150px;">Spec / Color / Size</th>
                                <th style="min-width:120px;">Supplier</th>
                                <th style="min-width:80px;">Unit Price</th>
                                <th style="min-width:130px;">Remarks</th>
                            </tr>
                        </thead>
                        <tbody id="trimBody_PO_ID">
                            <tr><td colspan="6" class="text-center text-muted py-3" style="font-size:12px;">
                                <i class="bi bi-info-circle me-1"></i>Select a Style first.
                            </td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <hr class="my-2"/>

    <!-- ---- SECTION 4: REMARKS & STATUS ---- -->
    <div class="mb-1">
        <div class="d-flex align-items-center mb-2">
            <button type="button" class="section-collapse-btn" data-bs-toggle="collapse" data-bs-target="#sec4_PO_ID">
                <i class="bi bi-chevron-down"></i> 4. PO Remarks &amp; Status
            </button>
        </div>
        <div class="collapse show" id="sec4_PO_ID">
            <div class="row g-2">
                <div class="col-md-5">
                    <label>Special Instruction</label>
                    <textarea class="form-control" id="specInstr_PO_ID" rows="3" placeholder="Special buyer instructions, packing, notes..."></textarea>
                </div>
                <div class="col-md-2">
                    <label>PO Status <span class="text-danger">*</span></label>
                    <div style="position:relative;">
                        <span class="status-dot s-pending" id="statusDot_PO_ID" style="position:absolute;left:8px;top:50%;transform:translateY(-50%);z-index:5;"></span>
                        <select class="form-select" id="poStatus_PO_ID" onchange="onStatusChange('PO_ID',this.value)" style="padding-left:22px;">
                            <option value="Pending">Pending</option>
                            <option value="Confirmed">Confirmed</option>
                            <option value="In Production">In Production</option>
                            <option value="Shipped">Shipped</option>
                            <option value="Closed">Closed</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-2">
                    <label>Confirmed By</label>
                    <input type="text" class="form-control" id="confirmedBy_PO_ID" placeholder="Name"/>
                </div>
                <div class="col-md-2">
                    <label>Confirmation Date</label>
                    <input type="date" class="form-control" id="confirmDate_PO_ID"/>
                </div>
            </div>
        </div>
    </div>

</div><!-- end po-panel -->
</template>


<!-- ====================================================== -->
<!-- JAVASCRIPT                                              -->
<!-- ====================================================== -->
<script>
    /* ===================================================
       DEMO DATA
    =================================================== */
    const STYLES = [
        { styleNo: 'STY-2025-0001', styleName: 'Classic Oxford Shirt', buyer: 'H&M', category: 'Formal Shirt', gender: 'Men', type: 'Woven', fit: 'Regular Fit', merch: 'Rahim Uddin', status: 'Active', poTrims: [{ name: 'Button', type: 'Button' }, { name: 'Care Label', type: 'Care Label' }, { name: 'Hang Tag', type: 'Hang Tag' }] },
        { styleNo: 'STY-2025-0002', styleName: 'Essential Polo Shirt', buyer: 'Zara', category: 'Polo Shirt', gender: 'Men', type: 'Knit', fit: 'Slim Fit', merch: 'Fatema Khatun', status: 'Active', poTrims: [{ name: 'Woven Label', type: 'Woven Label' }, { name: 'Price Tag', type: 'Price Tag' }] },
        { styleNo: 'STY-2025-0003', styleName: 'Summer Dress Collection', buyer: 'Next', category: 'Dress', gender: 'Women', type: 'Woven', fit: 'Relaxed Fit', merch: 'Shahinur Islam', status: 'Active', poTrims: [{ name: 'Zipper', type: 'Zipper' }, { name: 'Elastic', type: 'Elastic' }] },
        { styleNo: 'STY-2025-0004', styleName: 'Kids Hoodie Basic', buyer: 'Primark', category: 'Hoodie', gender: 'Kids', type: 'Knit', fit: 'Oversized', merch: 'Nadia Akter', status: 'Active', poTrims: [{ name: 'Snap Button', type: 'Snap Button' }] },
        { styleNo: 'STY-2025-0005', styleName: 'Slim Fit Trouser', buyer: 'Marks & Spencer', category: 'Trouser', gender: 'Men', type: 'Woven', fit: 'Slim Fit', merch: 'Mizanur Rahman', status: 'Active', poTrims: [{ name: 'Button', type: 'Button' }, { name: 'Hook & Eye', type: 'Hook & Eye' }] },
        { styleNo: 'STY-2025-0006', styleName: 'Oversized Sweatshirt', buyer: 'ASOS', category: 'Sweatshirt', gender: 'Unisex', type: 'Knit', fit: 'Oversized', merch: 'Rahim Uddin', status: 'Active', poTrims: [{ name: 'Cord', type: 'Elastic' }, { name: 'Label', type: 'Woven Label' }] },
    ];

    const TRIM_SUPPLIERS = ['Trim World', 'Apex Accessories', 'Star Trim', 'Delta Trims'];

    const TEMPLATES = {
        basic: ['S', 'M', 'L', 'XL'],
        full: ['XS', 'S', 'M', 'L', 'XL', '2XL', '3XL'],
        num: ['28', '30', '32', '34', '36', '38', '40']
    };

    /* ===================================================
       GLOBAL PO STATE
    =================================================== */
    let poList = [];   // [{id, label, data:{...}}]
    let activePO = null; // current PO id
    let poSeq = 0;
    let searchTargetPO = null; // which PO triggered modal

    const matState = {}; // matState[poId] = {colors:[], sizes:[], qty:{}}

    /* ===================================================
       CREATE PO
    =================================================== */
    function genPOId() {
        poSeq++;
        return 'PO' + String(poSeq).padStart(3, '0');
    }

    function addNewPO() {
        const poId = genPOId();
        const label = `PO-${poSeq}`;
        poList.push({ id: poId, label });
        matState[poId] = { colors: ['White', 'Navy'], sizes: ['S', 'M', 'L', 'XL'], qty: {} };

        buildTab(poId, label);
        buildPanel(poId);
        switchTab(poId);
        buildMatrix(poId);
        updatePOAutoId(poId);
        updateSummaryTable();
        document.getElementById('noPOMessage').style.display = 'none';
        document.getElementById('multiPOSummarySection').style.display = '';
        showToast(`${label} added.`);
    }

    function updatePOAutoId(poId) {
        const el = document.getElementById(`poAutoId_${poId}`);
        if (el) el.textContent = `PO-${new Date().getFullYear()}-${String(poSeq).padStart(4, '0')}`;
    }

    /* ===================================================
       BUILD TAB
    =================================================== */
    function buildTab(poId, label) {
        const wrapper = document.getElementById('poTabsWrapper');
        const addBtn = wrapper.querySelector('.add-po-tab');

        const tab = document.createElement('div');
        tab.className = 'po-tab';
        tab.id = `tab_${poId}`;
        tab.setAttribute('data-poid', poId);
        tab.innerHTML = `
        <i class="bi bi-file-earmark-text" style="font-size:11px;"></i>
        <span class="tab-label-txt" id="tabTxt_${poId}">${label}</span>
        <span class="tab-badge" id="tabBadge_${poId}">0</span>
        <button type="button" class="tab-close" onclick="closePO('${poId}',event)" title="Remove PO">✕</button>
    `;
        tab.addEventListener('click', function (e) {
            if (!e.target.classList.contains('tab-close')) switchTab(poId);
        });
        wrapper.insertBefore(tab, addBtn);
    }

    /* ===================================================
       BUILD PANEL (from template)
    =================================================== */
    function buildPanel(poId) {
        const tmpl = document.getElementById('poPanelTemplate');
        const frag = tmpl.content.cloneNode(true);
        const panel = frag.querySelector('.po-panel');

        // Replace all PO_ID placeholders
        panel.id = `panel_${poId}`;
        panel.innerHTML = panel.innerHTML.replace(/PO_ID/g, poId);

        document.getElementById('poTabContent').appendChild(panel);
        // Set today's date for PO Date
        const pd = document.getElementById(`poDate_${poId}`);
        if (pd) pd.value = new Date().toISOString().split('T')[0];
    }

    /* ===================================================
       SWITCH TAB
    =================================================== */
    function switchTab(poId) {
        activePO = poId;
        // Toggle tabs
        document.querySelectorAll('.po-tab').forEach(t => t.classList.remove('active'));
        const tab = document.getElementById(`tab_${poId}`);
        if (tab) tab.classList.add('active');
        // Toggle panels
        document.querySelectorAll('.po-panel').forEach(p => p.classList.remove('active'));
        const panel = document.getElementById(`panel_${poId}`);
        if (panel) panel.classList.add('active');
        // Update action bar preview
        refreshActionBar(poId);
    }

    /* ===================================================
       CLOSE / REMOVE PO
    =================================================== */
    function closePO(poId, e) {
        e.stopPropagation();
        if (poList.length === 1) {
            if (!confirm('Remove the only PO? The form will be cleared.')) return;
        } else {
            if (!confirm(`Remove ${getLabel(poId)}?`)) return;
        }
        // Remove from list
        const idx = poList.findIndex(p => p.id === poId);
        poList.splice(idx, 1);
        delete matState[poId];

        // Remove tab + panel
        document.getElementById(`tab_${poId}`)?.remove();
        document.getElementById(`panel_${poId}`)?.remove();

        if (poList.length === 0) {
            activePO = null;
            document.getElementById('noPOMessage').style.display = '';
            document.getElementById('multiPOSummarySection').style.display = 'none';
            clearActionBar();
        } else {
            // Switch to neighbour
            const nextIdx = Math.min(idx, poList.length - 1);
            switchTab(poList[nextIdx].id);
        }
        updateSummaryTable();
        showToast('PO removed.');
    }

    function getLabel(poId) {
        return poList.find(p => p.id === poId)?.label || poId;
    }

    /* ===================================================
       STYLE SEARCH
    =================================================== */
    function openStyleSearch(poId) {
        searchTargetPO = poId;
        renderStyleTable(STYLES);
        document.getElementById('modalSearchInput').value = '';
        new bootstrap.Modal(document.getElementById('styleSearchModal')).show();
    }

    function renderStyleTable(data) {
        const tbody = document.getElementById('styleSearchBody');
        if (!data.length) {
            tbody.innerHTML = `<tr><td colspan="7" class="text-center text-muted py-3">No styles found.</td></tr>`;
            return;
        }
        tbody.innerHTML = data.map(s => `
        <tr class="modal-search-row" onclick="selectStyle('${s.styleNo}')">
            <td><strong class="text-primary">${s.styleNo}</strong></td>
            <td>${s.styleName}</td><td>${s.buyer}</td><td>${s.category}</td>
            <td>${s.gender}</td>
            <td><span class="badge bg-secondary">${s.type}</span></td>
            <td><span class="badge bg-success">${s.status}</span></td>
        </tr>
    `).join('');
    }

    function filterStyles(q) {
        renderStyleTable(STYLES.filter(s =>
            s.styleNo.toLowerCase().includes(q.toLowerCase()) ||
            s.styleName.toLowerCase().includes(q.toLowerCase()) ||
            s.buyer.toLowerCase().includes(q.toLowerCase())
        ));
    }

    function selectStyle(styleNo) {
        const poId = searchTargetPO;
        const s = STYLES.find(x => x.styleNo === styleNo);
        if (!s || !poId) return;

        // Update style box text
        document.getElementById(`styleBoxTxt_${poId}`).textContent = s.styleNo;
        document.getElementById(`hidStyle_${poId}`).value = s.styleNo;

        // Fill info bar
        const set = (sfx, val) => {
            const el = document.getElementById(`i${sfx}_${poId}`);
            if (!el) return;
            el.textContent = val || '—';
            el.classList.remove('ph');
        };
        set('Name', s.styleName);
        set('Buyer', s.buyer);
        set('Cat', s.category);
        set('Gender', s.gender);
        set('Fit', s.fit);
        set('Type', s.type);
        set('Merch', s.merch);

        // Update tab label with buyer
        const tabTxt = document.getElementById(`tabTxt_${poId}`);
        if (tabTxt) tabTxt.textContent = `${getLabel(poId)} · ${s.buyer}`;

        // Load trims
        loadPOTrims(poId, s.poTrims);

        // Update summary
        updateSummaryTable();

        bootstrap.Modal.getInstance(document.getElementById('styleSearchModal')).hide();
        showToast(`Style ${s.styleNo} loaded into ${getLabel(poId)}.`);
    }

    /* ===================================================
       TRIM
    =================================================== */
    function loadPOTrims(poId, trims) {
        document.getElementById(`trimBadge_${poId}`).textContent = `From Style: ${trims.length} items`;
        const tbody = document.getElementById(`trimBody_${poId}`);
        if (!trims.length) {
            tbody.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-2" style="font-size:12px;">No PO-Specific trims for this style.</td></tr>`;
            return;
        }
        tbody.innerHTML = trims.map((t, i) => `
        <tr>
            <td><input type="text" class="form-control" value="${t.name}" readonly style="background:#f8f9fa;color:#6c757d;"/></td>
            <td><input type="text" class="form-control" value="${t.type}" readonly style="background:#f8f9fa;color:#6c757d;"/></td>
            <td><input type="text" class="form-control" placeholder="Color / Size / Spec"/></td>
            <td><select class="form-select"><option value="">— Supplier —</option>${TRIM_SUPPLIERS.map(s => `<option>${s}</option>`).join('')}</select></td>
            <td><input type="number" class="form-control" placeholder="0.00" step="0.01"/></td>
            <td><input type="text" class="form-control" placeholder="Remarks..."/></td>
        </tr>
    `).join('');
    }

    /* ===================================================
       MATRIX
    =================================================== */
    function buildMatrix(poId) {
        const st = matState[poId];
        const head = document.getElementById(`matHead_${poId}`);
        const body = document.getElementById(`matBody_${poId}`);
        const foot = document.getElementById(`matFoot_${poId}`);
        if (!head || !body || !foot) return;

        const colors = st.colors;
        const sizes = st.sizes;

        // HEAD
        head.innerHTML = `<tr>
        <th class="row-label" style="text-align:left;">Color \\ Size</th>
        ${sizes.map((sz, si) => `<th>
            <div style="display:flex;align-items:center;justify-content:center;gap:2px;">
                <input type="text" class="size-nm" value="${sz}" onchange="renameSize('${poId}',${si},this.value)"/>
                <span onclick="removeSize('${poId}',${si})" style="cursor:pointer;color:#dc3545;font-size:10px;flex-shrink:0;">✕</span>
            </div>
        </th>`).join('')}
        <th class="total-cell">Total</th>
    </tr>`;

        // BODY
        body.innerHTML = colors.map((c, ci) => `
        <tr>
            <td class="row-label">
                <div style="display:flex;align-items:center;gap:4px;">
                    <input type="text" class="color-nm" value="${c}" onchange="renameColor('${poId}',${ci},this.value)"/>
                    <span onclick="removeColor('${poId}',${ci})" style="cursor:pointer;color:#dc3545;font-size:11px;flex-shrink:0;">✕</span>
                </div>
            </td>
            ${sizes.map((_, si) => `<td>
                <input type="number" class="qty-inp" min="0" value="${getQty(poId, ci, si) || ''}" placeholder="0"
                    onchange="setQty('${poId}',${ci},${si},this.value)" oninput="setQty('${poId}',${ci},${si},this.value)"/>
            </td>`).join('')}
            <td class="total-cell" id="rTot_${poId}_${ci}">0</td>
        </tr>
    `).join('');

        // FOOT
        foot.innerHTML = `<tr class="total-row">
        <td class="row-label" style="font-weight:700;padding-left:6px;">Total</td>
        ${sizes.map((_, si) => `<td class="total-cell" id="cTot_${poId}_${si}">0</td>`).join('')}
        <td class="grand-cell" id="grand_${poId}">0</td>
    </tr>`;

        recalcMatrix(poId);
        document.getElementById(`colorCount_${poId}`).textContent = colors.length;
        document.getElementById(`sizeCount_${poId}`).textContent = sizes.length;
    }

    function getQty(poId, ci, si) { return matState[poId]?.qty[`${ci}_${si}`] || 0; }
    function setQty(poId, ci, si, v) {
        if (!matState[poId]) return;
        matState[poId].qty[`${ci}_${si}`] = parseInt(v) || 0;
        recalcMatrix(poId);
        updateSummaryTable();
    }

    function recalcMatrix(poId) {
        const st = matState[poId];
        if (!st) return;
        let grand = 0;
        st.colors.forEach((_, ci) => {
            let r = 0;
            st.sizes.forEach((_, si) => { r += getQty(poId, ci, si); });
            const el = document.getElementById(`rTot_${poId}_${ci}`);
            if (el) el.textContent = r;
            grand += r;
        });
        st.sizes.forEach((_, si) => {
            let c = 0;
            st.colors.forEach((_, ci) => { c += getQty(poId, ci, si); });
            const el = document.getElementById(`cTot_${poId}_${si}`);
            if (el) el.textContent = c;
        });
        const gEl = document.getElementById(`grand_${poId}`);
        if (gEl) gEl.textContent = grand;
        document.getElementById(`totalQty_${poId}`).textContent = grand.toLocaleString();

        // Tab badge
        const badge = document.getElementById(`tabBadge_${poId}`);
        if (badge) badge.textContent = grand.toLocaleString();

        recalcValue(poId, grand);
        if (poId === activePO) refreshActionBar(poId);
        updateHeaderGrandQty();
    }

    function recalcValue(poId, qty) {
        if (qty === undefined) qty = parseInt(document.getElementById(`totalQty_${poId}`)?.textContent || '0') || 0;
        const price = parseFloat(document.getElementById(`unitPrice_${poId}`)?.value) || 0;
        const cur = document.getElementById(`currency_${poId}`)?.value || 'USD';
        document.getElementById(`unitPriceDisp_${poId}`).textContent = price ? `${cur} ${price.toFixed(2)}` : '—';
        document.getElementById(`totalValue_${poId}`).textContent = (price && qty) ? `${cur} ${(price * qty).toLocaleString(undefined, { minimumFractionDigits: 2 })}` : '—';
    }

    function addColorRow(poId) {
        matState[poId].colors.push('New Color');
        buildMatrix(poId);
    }
    function addSizeCol(poId) {
        matState[poId].sizes.push('New');
        buildMatrix(poId);
    }
    function removeColor(poId, ci) {
        matState[poId].colors.splice(ci, 1);
        // Shift qty keys
        const oldQty = { ...matState[poId].qty };
        matState[poId].qty = {};
        const nc = matState[poId].colors.length;
        const ns = matState[poId].sizes.length;
        for (let c = 0; c < nc; c++) for (let s = 0; s < ns; s++) {
            const oc = c < ci ? c : c + 1;
            matState[poId].qty[`${c}_${s}`] = oldQty[`${oc}_${s}`] || 0;
        }
        buildMatrix(poId);
    }
    function removeSize(poId, si) {
        matState[poId].sizes.splice(si, 1);
        const oldQty = { ...matState[poId].qty };
        matState[poId].qty = {};
        const nc = matState[poId].colors.length;
        const ns = matState[poId].sizes.length;
        for (let c = 0; c < nc; c++) for (let s = 0; s < ns; s++) {
            const os = s < si ? s : s + 1;
            matState[poId].qty[`${c}_${s}`] = oldQty[`${c}_${os}`] || 0;
        }
        buildMatrix(poId);
    }
    function renameColor(poId, ci, val) { matState[poId].colors[ci] = val; }
    function renameSize(poId, si, val) { matState[poId].sizes[si] = val; }

    function loadTemplate(poId, key) {
        matState[poId].sizes = [...TEMPLATES[key]];
        matState[poId].qty = {};
        buildMatrix(poId);
        showToast(`Template "${key}" applied to ${getLabel(poId)}.`);
    }

    /* ===================================================
       STATUS DOT
    =================================================== */
    function onStatusChange(poId, val) {
        const dot = document.getElementById(`statusDot_${poId}`);
        if (!dot) return;
        const map = { Pending: 's-pending', Confirmed: 's-confirmed', 'In Production': 's-production', Shipped: 's-shipped', Closed: 's-closed' };
        dot.className = 'status-dot ' + (map[val] || 's-pending');
        if (poId === activePO) document.getElementById('previewActiveStatus').textContent = val;
        updateSummaryTable();
    }

    /* ===================================================
       PO NO CHANGE
    =================================================== */
    function onPONoChange(poId, val) {
        if (poId === activePO) document.getElementById('previewActivePO').textContent = val || '—';
        updateSummaryTable();
    }

    /* ===================================================
       ACTION BAR
    =================================================== */
    function refreshActionBar(poId) {
        const poNo = document.getElementById(`poNo_${poId}`)?.value || '—';
        const style = document.getElementById(`hidStyle_${poId}`)?.value || '—';
        const status = document.getElementById(`poStatus_${poId}`)?.value || '—';
        const qty = document.getElementById(`totalQty_${poId}`)?.textContent || '0';
        document.getElementById('previewActivePO').textContent = poNo;
        document.getElementById('previewActiveStyle').textContent = style;
        document.getElementById('previewActiveStatus').textContent = status;
        document.getElementById('previewActiveQty').textContent = qty;
    }
    function clearActionBar() {
        ['previewActivePO', 'previewActiveStyle', 'previewActiveStatus'].forEach(id => document.getElementById(id).textContent = '—');
        document.getElementById('previewActiveQty').textContent = '0';
    }

    /* ===================================================
       SUMMARY TABLE
    =================================================== */
    const STATUS_BADGE = {
        Pending: 'warning text-dark', Confirmed: 'primary',
        'In Production': 'warning text-dark', Shipped: 'success', Closed: 'secondary'
    };

    function updateSummaryTable() {
        const tbody = document.getElementById('poSummaryBody');
        if (!tbody) return;
        let grandQty = 0, grandVal = 0, valCurrency = 'USD';
        const buyers = new Set(), styles = new Set();

        tbody.innerHTML = poList.map((po, idx) => {
            const id = po.id;
            const poNo = document.getElementById(`poNo_${id}`)?.value || '—';
            const styleNo = document.getElementById(`hidStyle_${id}`)?.value || '—';
            const buyer = document.getElementById(`iBuyer_${id}`)?.textContent || '—';
            const poType = document.getElementById(`poType_${id}`)?.value || '—';
            const shipM = document.getElementById(`shipMode_${id}`)?.value || '—';
            const shipD = document.getElementById(`shipDate_${id}`)?.value || '—';
            const dest = document.getElementById(`dest_${id}`)?.value || '—';
            const inco = document.getElementById(`incoterm_${id}`)?.value || '—';
            const cur = document.getElementById(`currency_${id}`)?.value || 'USD';
            const price = parseFloat(document.getElementById(`unitPrice_${id}`)?.value) || 0;
            const qty = parseInt(document.getElementById(`totalQty_${id}`)?.textContent.replace(/,/g, '')) || 0;
            const val = price * qty;
            const status = document.getElementById(`poStatus_${id}`)?.value || 'Pending';
            const badgeCls = STATUS_BADGE[status] || 'secondary';

            grandQty += qty; grandVal += val; valCurrency = cur;
            if (buyer !== '—') buyers.add(buyer);
            if (styleNo !== '—') styles.add(styleNo);

            return `<tr class="${id === activePO ? 'table-primary' : ''}" onclick="switchTab('${id}')" style="cursor:pointer;">
            <td>${idx + 1}</td>
            <td><span class="text-primary fw-bold">${document.getElementById(`poAutoId_${id}`)?.textContent || '—'}</span></td>
            <td class="fw-bold">${poNo}</td>
            <td>${styleNo}</td><td>${buyer}</td><td>${poType}</td><td>${shipM}</td><td>${shipD}</td>
            <td>${dest}</td><td>${inco}</td><td>${cur}</td>
            <td class="text-end">${price ? price.toFixed(2) : '—'}</td>
            <td class="text-end fw-bold">${qty.toLocaleString()}</td>
            <td class="text-end fw-bold">${val ? (cur + ' ' + val.toLocaleString(undefined, { minimumFractionDigits: 2 })) : '—'}</td>
            <td><span class="badge bg-${badgeCls} badge-status">${status}</span></td>
        </tr>`;
        }).join('');

        // Grand totals
        document.getElementById('gtTotalPOs').textContent = poList.length;
        document.getElementById('gtGrandQty').textContent = grandQty.toLocaleString();
        document.getElementById('gtTotalValue').textContent = grandVal ? `${valCurrency} ${grandVal.toLocaleString(undefined, { minimumFractionDigits: 2 })}` : '—';
        document.getElementById('gtStyles').textContent = styles.size;
        document.getElementById('gtBuyers').textContent = buyers.size;
        document.getElementById('totalPOCount').textContent = poList.length;
    }

    function updateHeaderGrandQty() {
        let total = 0;
        poList.forEach(po => {
            total += parseInt(document.getElementById(`totalQty_${po.id}`)?.textContent.replace(/,/g, '') || '0') || 0;
        });
        document.getElementById('headerGrandQty').textContent = total.toLocaleString();
    }

    /* ===================================================
       ACTIONS
    =================================================== */
    function saveActiveDraft() {
        if (!activePO) { showToast('No active PO.', 'warning'); return; }
        showToast(`${getLabel(activePO)} draft saved!`);
    }

    function submitAllPOs() {
        if (!poList.length) { showToast('No POs to submit.', 'warning'); return; }
        updateSummaryTable();
        showToast(`${poList.length} PO(s) submitted successfully!`);
    }

    function resetActiveForm() {
        if (!activePO) { showToast('No active PO.', 'warning'); return; }
        if (!confirm(`Clear all data in ${getLabel(activePO)}? This cannot be undone.`)) return;
        // Reset style info
        document.getElementById(`styleBoxTxt_${activePO}`).textContent = '— Click to search Style —';
        document.getElementById(`hidStyle_${activePO}`).value = '';
        [`iName_${activePO}`, `iBuyer_${activePO}`, `iCat_${activePO}`, `iGender_${activePO}`, `iFit_${activePO}`, `iType_${activePO}`, `iMerch_${activePO}`]
            .forEach(id => { const el = document.getElementById(id); if (el) { el.textContent = '—'; el.classList.add('ph'); } });
        // Reset text inputs
        [`poNo_${activePO}`, `dest_${activePO}`, `portLoading_${activePO}`, `confirmedBy_${activePO}`]
            .forEach(id => { const el = document.getElementById(id); if (el) el.value = ''; });
        [`poDate_${activePO}`, `shipDate_${activePO}`, `exFactory_${activePO}`, `confirmDate_${activePO}`]
            .forEach(id => { const el = document.getElementById(id); if (el) el.value = ''; });
        [`poType_${activePO}`, `shipMode_${activePO}`, `incoterm_${activePO}`, `payTerm_${activePO}`]
            .forEach(id => { const el = document.getElementById(id); if (el) el.value = ''; });
        const up = document.getElementById(`unitPrice_${activePO}`); if (up) up.value = '';
        const si = document.getElementById(`specInstr_${activePO}`); if (si) si.value = '';
        // Reset matrix
        matState[activePO] = { colors: ['White', 'Navy'], sizes: ['S', 'M', 'L', 'XL'], qty: {} };
        buildMatrix(activePO);
        // Reset trims
        document.getElementById(`trimBody_${activePO}`).innerHTML =
            `<tr><td colspan="6" class="text-center text-muted py-3" style="font-size:12px;"><i class="bi bi-info-circle me-1"></i>Select a Style first.</td></tr>`;
        document.getElementById(`trimBadge_${activePO}`).textContent = 'From Style: 0 items';
        // Reset status
        onStatusChange(activePO, 'Pending');
        document.getElementById(`poStatus_${activePO}`).value = 'Pending';
        refreshActionBar(activePO);
        updateSummaryTable();
        showToast(`${getLabel(activePO)} cleared.`);
    }

    /* ===================================================
       TOAST
    =================================================== */
    function showToast(msg, type = 'success') {
        const t = document.getElementById('toast');
        t.className = `toast align-items-center text-bg-${type} border-0`;
        document.getElementById('toastMsg').textContent = msg;
        new bootstrap.Toast(t, { delay: 3000 }).show();
    }

    /* ===================================================
       INIT — auto add first PO
    =================================================== */
    document.addEventListener('DOMContentLoaded', function () {
        addNewPO();
    });
</script>
</body>
</html>