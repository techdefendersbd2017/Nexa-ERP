<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StyleInformationForGarments.aspx.cs" Inherits="Nexa_ERP.MasterConfiguration.BuyerManagement.StyleInformationForGarments" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Garments ERP - Style Entry Master</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <!-- Select2 CSS for Searchable Dropdowns -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />
    
    <style>
        :root {
            --erp-primary: #0f172a;
            --erp-secondary: #3b82f6;
            --erp-bg: #f8fafc;
            --erp-card-bg: #ffffff;
            --erp-border: #e2e8f0;
        }
        body {
            background-color: var(--erp-bg);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 0.875rem;
            color: #334155;
        }
        .navbar-erp {
            background-color: var(--erp-primary);
            color: #fff;
            padding: 0.75rem 1.5rem;
        }
        .card-erp {
            background: var(--erp-card-bg);
            border: 1px solid var(--erp-border);
            border-radius: 0.375rem;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.05);
            margin-bottom: 1rem;
        }
        .card-header-erp {
            background-color: #f1f5f9;
            border-bottom: 1px solid var(--erp-border);
            font-weight: 600;
            color: #1e293b;
            padding: 0.75rem 1rem;
        }
        .form-label {
            font-weight: 500;
            color: #475569;
            margin-bottom: 0.25rem;
        }
        .required::after {
            content: " *";
            color: #ef4444;
        }
        .nav-tabs .nav-link {
            color: #64748b;
            font-weight: 500;
            border: none;
            padding: 0.75rem 1rem;
        }
        .nav-tabs .nav-link.active {
            color: var(--erp-secondary);
            background-color: transparent;
            border-bottom: 2px solid var(--erp-secondary);
        }
        .quick-action-btn {
            text-align: left;
            margin-bottom: 0.5rem;
            font-size: 0.8rem;
        }
        .image-upload-box {
            border: 2px dashed #cbd5e1;
            border-radius: 0.375rem;
            padding: 1.5rem;
            text-align: center;
            background: #f8fafc;
            cursor: pointer;
            transition: all 0.2s;
        }
        .image-upload-box:hover {
            border-color: var(--erp-secondary);
            background: #eff6ff;
        }
        .workflow-step {
            text-align: center;
            padding: 0.5rem;
            background: #f1f5f9;
            border-radius: 0.25rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        .workflow-step.active {
            background: #dbeafe;
            color: #1d4ed8;
            border: 1px solid #93c5fd;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">

    <!-- Top ERP Header -->
    <nav class="navbar navbar-erp navbar-expand-lg">
        <div class="container-fluid">
            <span class="navbar-brand mb-0 h1 text-white"><i class="bi bi-layers-fill me-2"></i>Garments ERP &gt; Style Entry Master</span>
            <div class="d-flex align-items-center">
                <span class="badge bg-success me-3 px-3 py-2">Status: Active</span>
                <span class="text-light small">Logged in as: <b>Merchandiser-04</b></span>
            </div>
        </div>
    </nav>

    <!-- Form Container -->
    <div class="container-fluid py-3">
        
        <!-- Main Header Bar -->
        <div class="card card-erp mb-3">
            <div class="card-body py-2">
                <div class="row align-items-center">
                    <div class="col-md-2">
                        <label class="form-label text-muted small mb-0">Style ID (Auto)</label>
                        <input type="text" id="txtStyleID" class="form-control form-control-sm bg-light fw-bold text-primary" value="ST-2026-0941" readonly>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label required">Style No</label>
                        <input type="text" id="txtStyleNo" class="form-control form-control-sm" placeholder="Enter Style No" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label required">Style Name</label>
                        <input type="text" id="txtStyleName" class="form-control form-control-sm" placeholder="Enter Style Name" required>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Style Status</label>
                        <select id="ddlMainStatus" class="form-select form-select-sm">
                            <option value="Draft" selected>Draft</option>
                            <option value="Submitted">Submitted</option>
                            <option value="Approved">Approved</option>
                            <option value="Active">Active</option>
                            <option value="Rejected">Rejected</option>
                        </select>
                    </div>
                    <div class="col-md-1">
                        <label class="form-label">Rev. No</label>
                        <input type="text" id="txtRevNo" class="form-control form-control-sm bg-light" value="00" readonly>
                    </div>
                    <div class="col-md-2 text-end mt-3 mt-md-0">
                        <div class="btn-group btn-group-sm">
                            <button type="button" id="btnSave" class="btn btn-primary" title="Save Record"><i class="bi bi-save"></i> Save</button>
                            <button type="button" id="btnUpdate" class="btn btn-success" title="Update Record"><i class="bi bi-arrow-clockwise"></i></button>
                            <button type="button" id="btnReset" class="btn btn-outline-secondary" title="Reset Form"><i class="bi bi-x-lg"></i></button>
                            <button type="button" class="btn btn-outline-dark dropdown-toggle" data-bs-toggle="dropdown"></button>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="#" id="btnCopyStyle"><i class="bi bi-files me-2"></i>Copy Style</a></li>
                                <li><a class="dropdown-item" href="#" id="btnPrint"><i class="bi bi-printer me-2"></i>Print TechSheet</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item text-danger" href="#" id="btnClose"><i class="bi bi-box-arrow-right me-2"></i>Close</a></li>
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
                        <!-- Nav Tabs -->
                        <ul class="nav nav-tabs card-header-tabs" id="styleTabs" role="tablist">
                            <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#basic-tab" type="button"><i class="bi bi-info-circle me-1"></i> Basic Info</button></li>
                            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#commercial-tab" type="button"><i class="bi bi-cash-coin me-1"></i> Commercial</button></li>
                            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#image-tab" type="button"><i class="bi bi-images me-1"></i> Images</button></li>
                            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#spec-tab" type="button"><i class="bi bi-sliders me-1"></i> Specification</button></li>
                            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#colorsize-tab" type="button"><i class="bi bi-grid-3x3 me-1"></i> Color & Size</button></li>
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
                                    <div class="col-md-4">
                                        <label class="form-label required">Style No</label>
                                        <input type="text" class="form-control form-control-sm" placeholder="Enter Style No">
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label required">Style Name</label>
                                        <input type="text" class="form-control form-control-sm" placeholder="Enter Style Name">
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Style Description</label>
                                        <input type="text" class="form-control form-control-sm" placeholder="Enter description">
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label required">Buyer</label>
                                        <select class="form-select form-select-sm select2">
                                            <option value="">Select Buyer</option>
                                            <option>H&M Hennes & Mauritz</option>
                                            <option>Zara / Inditex</option>
                                            <option>Walmart Sourcing</option>
                                            <option>Primark Stores Ltd</option>
                                        </select>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Brand</label>
                                        <select class="form-select form-select-sm select2">
                                            <option value="">Select Brand</option>
                                            <option>Divided</option>
                                            <option>Basic Collection</option>
                                            <option>Denim Co</option>
                                        </select>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Agent / Buying House</label>
                                        <select class="form-select form-select-sm select2">
                                            <option value="">Select Agent</option>
                                            <option>Li & Fung Bangladesh</option>
                                            <option>Target Sourcing</option>
                                            <option>Direct Buyer</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Season / Year</label>
                                        <div class="input-group input-group-sm">
                                            <select class="form-select select2">
                                                <option>Autumn/Winter</option>
                                                <option>Spring/Summer</option>
                                            </select>
                                            <select class="form-select" style="max-width: 90px;">
                                                <option selected>2026</option>
                                                <option>2027</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Product Category</label>
                                        <select class="form-select form-select-sm select2">
                                            <option>Knit Outerwear</option>
                                            <option>Woven Bottoms</option>
                                            <option>Activewear</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Product Type</label>
                                        <select class="form-select form-select-sm select2">
                                            <option>Hoodie & Sweatshirt</option>
                                            <option>T-Shirt & Polo</option>
                                            <option>Jacket</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Garment Type / Gender</label>
                                        <div class="input-group input-group-sm">
                                            <select class="form-select select2">
                                                <option>Pullover</option>
                                                <option>Zip-Up</option>
                                            </select>
                                            <select class="form-select select2">
                                                <option>Mens</option>
                                                <option>Womens</option>
                                                <option>Kids</option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Department / Division</label>
                                        <div class="input-group input-group-sm">
                                            <input type="text" class="form-control" placeholder="Department">
                                            <input type="text" class="form-control" placeholder="Division">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label required">Assigned Merchandiser</label>
                                        <select class="form-select form-select-sm select2">
                                            <option>Tanvir Ahmed (M-102)</option>
                                            <option>Nazmul Hasan (M-105)</option>
                                            <option>Farhana Rahman (M-112)</option>
                                        </select>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Creation Date</label>
                                        <input type="date" class="form-control form-control-sm">
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label">Internal Remarks / Notes</label>
                                        <textarea class="form-control form-control-sm" rows="2" placeholder="Enter remarks..."></textarea>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 2: BUYER & COMMERCIAL -->
                            <div class="tab-pane fade" id="commercial-tab">
                                <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-cash-coin"></i> Buyer & Commercial Terms</h6>
                                <div class="row g-3">
                                    <div class="col-md-4">
                                        <label class="form-label">Buyer Style No / Product No</label>
                                        <div class="input-group input-group-sm">
                                            <input type="text" class="form-control" placeholder="Buyer Style No">
                                            <input type="text" class="form-control" placeholder="Product No">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Destination Country</label>
                                        <select class="form-select form-select-sm select2">
                                            <option>Germany</option>
                                            <option>United Kingdom</option>
                                            <option>United States</option>
                                            <option>France</option>
                                        </select>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Currency</label>
                                        <select class="form-select form-select-sm">
                                            <option selected>USD ($)</option>
                                            <option>EUR (€)</option>
                                            <option>GBP (£)</option>
                                        </select>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Payment Term</label>
                                        <select class="form-select form-select-sm">
                                            <option>LC At Sight (Irrevocable)</option>
                                            <option>TT 30 Days Advance</option>
                                            <option>DA 60 Days</option>
                                        </select>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Shipment Mode</label>
                                        <select class="form-select form-select-sm">
                                            <option>Sea Freight (FCL)</option>
                                            <option>Air Freight</option>
                                            <option>Courier</option>
                                        </select>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label">Port of Loading & Discharge</label>
                                        <div class="input-group input-group-sm">
                                            <input type="text" class="form-control" placeholder="Port of Loading">
                                            <input type="text" class="form-control" placeholder="Port of Discharge">
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 3: STYLE IMAGE & DESIGN -->
                            <div class="tab-pane fade" id="image-tab">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-images"></i> Style Image & Technical Sketch Repository</h6>
                                    <div>
                                        <button type="button" class="btn btn-sm btn-outline-primary"><i class="bi bi-clipboard"></i> Paste from Clipboard</button>
                                        <button type="button" class="btn btn-sm btn-primary"><i class="bi bi-upload"></i> Upload New</button>
                                    </div>
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-4">
                                        <div class="card card-erp h-100">
                                            <div class="image-upload-box m-2">
                                                <i class="bi bi-image fs-1 text-muted"></i>
                                                <p class="small text-muted mb-1">Front View Image</p>
                                                <span class="badge bg-secondary">Drag & Drop or Browse</span>
                                            </div>
                                            <div class="card-body p-2 text-center">
                                                <span class="small fw-bold text-muted">No file selected</span>
                                                <div class="mt-2">
                                                    <button type="button" class="btn btn-xs btn-outline-secondary" title="Zoom"><i class="bi bi-zoom-in"></i></button>
                                                    <button type="button" class="btn btn-xs btn-outline-primary" title="Replace"><i class="bi bi-arrow-repeat"></i></button>
                                                    <button type="button" class="btn btn-xs btn-outline-danger" title="Delete"><i class="bi bi-trash"></i></button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="card card-erp h-100">
                                            <div class="image-upload-box m-2">
                                                <i class="bi bi-image fs-1 text-muted"></i>
                                                <p class="small text-muted mb-1">Back View Image</p>
                                                <span class="badge bg-secondary">Drag & Drop or Browse</span>
                                            </div>
                                            <div class="card-body p-2 text-center">
                                                <span class="small fw-bold text-muted">No file selected</span>
                                                <div class="mt-2">
                                                    <button type="button" class="btn btn-xs btn-outline-secondary" title="Zoom"><i class="bi bi-zoom-in"></i></button>
                                                    <button type="button" class="btn btn-xs btn-outline-primary" title="Replace"><i class="bi bi-arrow-repeat"></i></button>
                                                    <button type="button" class="btn btn-xs btn-outline-danger" title="Delete"><i class="bi bi-trash"></i></button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="card card-erp h-100">
                                            <div class="image-upload-box m-2">
                                                <i class="bi bi-file-earmark-code fs-1 text-muted"></i>
                                                <p class="small text-muted mb-1">Technical Sketch / CAD</p>
                                                <span class="badge bg-secondary">Drag & Drop or Browse</span>
                                            </div>
                                            <div class="card-body p-2 text-center">
                                                <span class="small fw-bold text-muted">No file selected</span>
                                                <div class="mt-2">
                                                    <button type="button" class="btn btn-xs btn-outline-secondary" title="Download"><i class="bi bi-download"></i></button>
                                                    <button type="button" class="btn btn-xs btn-outline-primary" title="Replace"><i class="bi bi-arrow-repeat"></i></button>
                                                    <button type="button" class="btn btn-xs btn-outline-danger" title="Delete"><i class="bi bi-trash"></i></button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 4: PRODUCT SPECIFICATION -->
                            <div class="tab-pane fade" id="spec-tab">
                                <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-sliders"></i> Garment Specifications & Construction</h6>
                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <label class="form-label">Fabric Type</label>
                                        <input type="text" class="form-control form-control-sm" placeholder="e.g. Fleece">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Knit / Woven</label>
                                        <select class="form-select form-select-sm">
                                            <option>Knit</option>
                                            <option>Woven</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Construction & GSM</label>
                                        <div class="input-group input-group-sm">
                                            <input type="text" class="form-control" placeholder="Construction">
                                            <input type="text" class="form-control" placeholder="GSM">
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Composition</label>
                                        <input type="text" class="form-control form-control-sm" placeholder="e.g. 80% Cotton 20% Poly">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Fabric Width & Finish</label>
                                        <div class="input-group input-group-sm">
                                            <input type="text" class="form-control" placeholder="Width">
                                            <input type="text" class="form-control" placeholder="Finish">
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Wash Type</label>
                                        <input type="text" class="form-control form-control-sm" placeholder="Wash Type">
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Sleeve & Neck Type</label>
                                        <div class="input-group input-group-sm">
                                            <input type="text" class="form-control" placeholder="Sleeve">
                                            <input type="text" class="form-control" placeholder="Neck">
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Closure & Pocket Type</label>
                                        <div class="input-group input-group-sm">
                                            <input type="text" class="form-control" placeholder="Closure">
                                            <input type="text" class="form-control" placeholder="Pocket">
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 5: COLOR & SIZE CONFIGURATION -->
                            <div class="tab-pane fade" id="colorsize-tab">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <h6 class="text-uppercase text-secondary fw-bold m-0">Color Configuration</h6>
                                            <button type="button" class="btn btn-sm btn-outline-primary"><i class="bi bi-plus-lg"></i> Add Color</button>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table table-bordered table-sm align-middle">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th><input type="checkbox" class="form-check-input"></th>
                                                        <th>Code</th>
                                                        <th>Color Name</th>
                                                        <th>Pantone</th>
                                                        <th>Active</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td><input type="checkbox" class="form-check-input" checked></td>
                                                        <td>C-01</td>
                                                        <td>Jet Black</td>
                                                        <td>19-4008 TCX</td>
                                                        <td><span class="badge bg-success">Yes</span></td>
                                                        <td><button type="button" class="btn btn-xs btn-outline-danger"><i class="bi bi-trash"></i></button></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="d-flex justify-content-between align-items-center mb-2">
                                            <h6 class="text-uppercase text-secondary fw-bold m-0">Size Configuration</h6>
                                            <button type="button" class="btn btn-sm btn-outline-primary"><i class="bi bi-plus-lg"></i> Add Size</button>
                                        </div>
                                        <div class="table-responsive">
                                            <table class="table table-bordered table-sm align-middle">
                                                <thead class="table-light">
                                                    <tr>
                                                        <th><input type="checkbox" class="form-check-input"></th>
                                                        <th>Code</th>
                                                        <th>Size Name</th>
                                                        <th>Range</th>
                                                        <th>Active</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <tr>
                                                        <td><input type="checkbox" class="form-check-input" checked></td>
                                                        <td>S01</td>
                                                        <td>Medium (M)</td>
                                                        <td>Adult</td>
                                                        <td><span class="badge bg-success">Yes</span></td>
                                                        <td><button type="button" class="btn btn-xs btn-outline-danger"><i class="bi bi-trash"></i></button></td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 6: FABRIC INFORMATION -->
                            <div class="tab-pane fade" id="fabric-tab">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-layers"></i> Style Fabric Requirements Master</h6>
                                    <div>
                                        <button type="button" class="btn btn-sm btn-outline-primary me-2"><i class="bi bi-plus-lg"></i> Add Fabric</button>
                                        <button type="button" class="btn btn-sm btn-success"><i class="bi bi-box-arrow-up-right"></i> Go to Fabric Booking</button>
                                    </div>
                                </div>
                                <div class="table-responsive">
                                    <table class="table table-bordered table-sm align-middle">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Code</th>
                                                <th>Fabric Name & Type</th>
                                                <th>Composition</th>
                                                <th>GSM</th>
                                                <th>Color</th>
                                                <th>Consumption</th>
                                                <th>Wastage %</th>
                                                <th>Unit</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>FAB-001</td>
                                                <td>Cotton Poly Brushed Fleece</td>
                                                <td>80/20 Cotton Polyester</td>
                                                <td>320</td>
                                                <td>Jet Black</td>
                                                <td>0.580</td>
                                                <td>5.00</td>
                                                <td>Kgs</td>
                                                <td><button type="button" class="btn btn-xs btn-outline-primary"><i class="bi bi-pencil"></i></button></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- TAB 7: ACCESSORIES / TRIMS -->
                            <div class="tab-pane fade" id="accessories-tab">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-tag"></i> Trims & Accessories Requirements</h6>
                                    <div>
                                        <button type="button" class="btn btn-sm btn-outline-primary me-2"><i class="bi bi-plus-lg"></i> Add Item</button>
                                        <button type="button" class="btn btn-sm btn-success"><i class="bi bi-box-arrow-up-right"></i> Go to Accessories Booking</button>
                                    </div>
                                </div>
                                <div class="table-responsive">
                                    <table class="table table-bordered table-sm align-middle">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Item Code</th>
                                                <th>Item Name</th>
                                                <th>Type</th>
                                                <th>Size/Color</th>
                                                <th>Consumption</th>
                                                <th>Unit</th>
                                                <th>Wastage %</th>
                                                <th>Supplier</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>ACC-101</td>
                                                <td>Woven Main Label</td>
                                                <td>Label</td>
                                                <td>Standard / Black</td>
                                                <td>1.00</td>
                                                <td>Pcs</td>
                                                <td>3.00</td>
                                                <td>YKK BD</td>
                                                <td><button type="button" class="btn btn-xs btn-outline-primary"><i class="bi bi-pencil"></i></button></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- TAB 8: COSTING -->
                            <div class="tab-pane fade" id="costing-tab">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-calculator"></i> Costing Summary Overview</h6>
                                    <div>
                                        <button type="button" class="btn btn-sm btn-primary"><i class="bi bi-plus-circle"></i> Create Costing</button>
                                        <button type="button" class="btn btn-sm btn-outline-secondary"><i class="bi bi-eye"></i> View Full Costing</button>
                                    </div>
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <div class="p-3 border rounded bg-light">
                                            <span class="text-muted small">Costing Status</span>
                                            <h5 class="text-success mb-0 mt-1">Approved</h5>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="p-3 border rounded bg-light">
                                            <span class="text-muted small">Latest Version & Date</span>
                                            <h5 class="mb-0 mt-1">Ver 02 (2026-08-10)</h5>
                                        </div>
                                    </div>
                                    <div class="col-md-2">
                                        <div class="p-3 border rounded bg-light">
                                            <span class="text-muted small">Total Cost</span>
                                            <h5 class="text-primary mb-0 mt-1">$ 8.45</h5>
                                        </div>
                                    </div>
                                    <div class="col-md-2">
                                        <div class="p-3 border rounded bg-light">
                                            <span class="text-muted small">FOB / Buyer Price</span>
                                            <h5 class="text-dark mb-0 mt-1">$ 10.50</h5>
                                        </div>
                                    </div>
                                    <div class="col-md-2">
                                        <div class="p-3 border rounded bg-light">
                                            <span class="text-muted small">Profit Margin</span>
                                            <h5 class="text-success mb-0 mt-1">19.52%</h5>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 9: WORK ORDER -->
                            <div class="tab-pane fade" id="workorder-tab">
                                <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-tools"></i> Embellishment & Special Process Work Orders</h6>
                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <div class="card p-3 border text-center">
                                            <span class="fw-bold mb-2">Printing Required</span>
                                            <span class="badge bg-success mb-3 p-2">Yes (Chest Print)</span>
                                            <button type="button" class="btn btn-sm btn-outline-primary"><i class="bi bi-file-earmark-plus"></i> Printing Work Order</button>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="card p-3 border text-center">
                                            <span class="fw-bold mb-2">Embroidery Required</span>
                                            <span class="badge bg-secondary mb-3 p-2">No</span>
                                            <button type="button" class="btn btn-sm btn-outline-secondary" disabled>Embroidery Work Order</button>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="card p-3 border text-center">
                                            <span class="fw-bold mb-2">Washing Required</span>
                                            <span class="badge bg-success mb-3 p-2">Yes (Enzyme)</span>
                                            <button type="button" class="btn btn-sm btn-outline-primary"><i class="bi bi-file-earmark-plus"></i> Wash Work Order</button>
                                        </div>
                                    </div>
                                    <div class="col-md-3">
                                        <div class="card p-3 border text-center">
                                            <span class="fw-bold mb-2">Special Process</span>
                                            <span class="badge bg-secondary mb-3 p-2">None</span>
                                            <button type="button" class="btn btn-sm btn-outline-secondary" disabled>Special Work Order</button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 10: TNA -->
                            <div class="tab-pane fade" id="tna-tab">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-calendar-check"></i> TNA Milestones Summary</h6>
                                    <button type="button" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i> View Full TNA Schedule</button>
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-4">
                                        <label class="form-label">TNA Template</label>
                                        <input type="text" class="form-control form-control-sm bg-light" value="Standard 90 Days Winterwear Template" readonly>
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label">Sample Deadline</label>
                                        <input type="date" class="form-control form-control-sm">
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label">PP Meeting Date</label>
                                        <input type="date" class="form-control form-control-sm">
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label">Fabric In Date</label>
                                        <input type="date" class="form-control form-control-sm">
                                    </div>
                                    <div class="col-md-2">
                                        <label class="form-label">Shipment Date</label>
                                        <input type="date" class="form-control form-control-sm">
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 11: DOCUMENTS -->
                            <div class="tab-pane fade" id="docs-tab">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-file-earmark-text"></i> Document Management</h6>
                                    <button type="button" class="btn btn-sm btn-primary"><i class="bi bi-upload"></i> Upload Document</button>
                                </div>
                                <div class="table-responsive">
                                    <table class="table table-bordered table-sm align-middle">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Document Name</th>
                                                <th>Type</th>
                                                <th>Upload Date</th>
                                                <th>Uploaded By</th>
                                                <th>Version</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>Tech_Pack_MSW881_Final.pdf</td>
                                                <td>Tech Pack</td>
                                                <td>2026-08-20</td>
                                                <td>Tanvir Ahmed</td>
                                                <td>v1.2</td>
                                                <td>
                                                    <button type="button" class="btn btn-xs btn-outline-secondary"><i class="bi bi-download"></i></button>
                                                    <button type="button" class="btn btn-xs btn-outline-danger"><i class="bi bi-trash"></i></button>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- TAB 12: APPROVAL -->
                            <div class="tab-pane fade" id="approval-tab">
                                <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-shield-check"></i> Workflow & Approval Status</h6>
                                <div class="row mb-4">
                                    <div class="col"><div class="workflow-step">Draft</div></div>
                                    <div class="col"><div class="workflow-step active">Submitted</div></div>
                                    <div class="col"><div class="workflow-step">Merchandising Approval</div></div>
                                    <div class="col"><div class="workflow-step">Management Approval</div></div>
                                    <div class="col"><div class="workflow-step">Active (Locked)</div></div>
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <label class="form-label">Submitted By / Date</label>
                                        <input type="text" class="form-control form-control-sm bg-light" value="Tanvir Ahmed (2026-08-22)" readonly>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label">Approved By / Date</label>
                                        <input type="text" class="form-control form-control-sm bg-light" value="Pending Head of Merchandising" readonly>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Approval Remarks</label>
                                        <input type="text" class="form-control form-control-sm" placeholder="Enter remarks">
                                    </div>
                                    <div class="col-12 mt-3">
                                        <button type="button" class="btn btn-sm btn-success me-2"><i class="bi bi-check-circle"></i> Approve</button>
                                        <button type="button" class="btn btn-sm btn-danger me-2"><i class="bi bi-x-circle"></i> Reject</button>
                                        <button type="button" class="btn btn-sm btn-warning me-2"><i class="bi bi-arrow-right-circle"></i> Forward</button>
                                        <button type="button" class="btn btn-sm btn-secondary"><i class="bi bi-send"></i> Submit</button>
                                    </div>
                                </div>
                            </div>

                            <!-- TAB 13: HISTORY -->
                            <div class="tab-pane fade" id="history-tab">
                                <h6 class="text-uppercase text-secondary fw-bold mb-3"><i class="bi bi-clock-history"></i> Audit Trail & Activity Log</h6>
                                <div class="table-responsive">
                                    <table class="table table-bordered table-sm align-middle">
                                        <thead class="table-light">
                                            <tr>
                                                <th>Date & Time</th>
                                                <th>User</th>
                                                <th>Action</th>
                                                <th>Previous Value</th>
                                                <th>New Value</th>
                                                <th>Remarks</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                                <td>2026-08-24 10:15 AM</td>
                                                <td>Tanvir Ahmed</td>
                                                <td><span class="badge bg-primary">Created</span></td>
                                                <td>-</td>
                                                <td>ST-2026-0941</td>
                                                <td>Initial style record entry</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Sidebar: Quick Actions & Related Modules -->
            <div class="col-lg-3">
                <div class="card card-erp mb-3">
                    <div class="card-header-erp"><i class="bi bi-lightning-charge"></i> Quick Actions / Related Links</div>
                    <div class="card-body d-grid gap-2 p-2">
                        <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-cart-check me-2"></i> PO Entry</span>
                            <span class="badge bg-success">3 Records</span>
                        </button>
                        <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-calculator me-2"></i> Costing</span>
                            <span class="badge bg-primary">Completed</span>
                        </button>
                        <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-layers me-2"></i> Fabric Booking</span>
                            <span class="badge bg-warning text-dark">2 Records</span>
                        </button>
                        <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-tag me-2"></i> Accessories Booking</span>
                            <span class="badge bg-secondary">Pending</span>
                        </button>
                        <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-calendar-range me-2"></i> TNA Schedule</span>
                            <span class="badge bg-success">Active</span>
                        </button>
                        <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-tools me-2"></i> Printing Work Order</span>
                            <span class="badge bg-success">Generated</span>
                        </button>
                        <button type="button" class="btn btn-outline-secondary btn-sm quick-action-btn d-flex justify-content-between align-items-center" disabled>
                            <span><i class="bi bi-tools me-2"></i> Embroidery W/O</span>
                            <span class="badge bg-light text-muted">Not Req.</span>
                        </button>
                        <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-gear me-2"></i> Production Order</span>
                            <span class="badge bg-secondary">0 Records</span>
                        </button>
                        <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-kanban me-2"></i> Production Plan</span>
                            <span class="badge bg-secondary">Not Scheduled</span>
                        </button>
                        <button type="button" class="btn btn-outline-primary btn-sm quick-action-btn d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-truck me-2"></i> Shipment Module</span>
                            <span class="badge bg-secondary">Pending</span>
                        </button>
                    </div>
                </div>

                <div class="card card-erp">
                    <div class="card-header-erp"><i class="bi bi-info-square"></i> System Summary</div>
                    <div class="card-body small">
                        <p class="mb-1"><b>Created By:</b> Tanvir Ahmed</p>
                        <p class="mb-1"><b>Created Date:</b> 2026-08-24</p>
                        <p class="mb-1"><b>Last Modified:</b> 2026-08-24 14:30</p>
                        <p class="mb-0"><b>Lock Status:</b> Unlocked for Editing</p>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- Bootstrap & jQuery JS -->
    <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
    <script>
        $(document).ready(function () {
            $('.select2').select2({
                theme: 'bootstrap-5',
                width: '100%'
            });
        });
    </script>
    </form>
</body>
</html>