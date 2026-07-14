<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StyleInformation.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.OrderInformation.StyleInformation" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Style Registration - NexaERP</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        body {
            background: #f4f6f9;
            font-size: 13px;
        }

        .card {
            border-radius: 10px;
        }

        .card-header {
            padding: 8px 15px;
        }

        .card-header h4 {
            font-size: 16px;
            margin: 0;
        }

        label {
            font-size: 12px;
            font-weight: 500;
            margin-bottom: 2px;
        }

        .form-control, .form-select {
            border-radius: 6px;
            height: 30px;
            font-size: 12px;
            padding: 2px 6px;
        }

        textarea.form-control {
            height: auto;
        }

        .form-check-input {
            transform: scale(0.9);
            margin-top: 2px;
        }

        .btn {
            border-radius: 6px;
            font-size: 12px;
            padding: 4px 12px;
        }

        .table {
            font-size: 12px;
        }

        .table th, .table td {
            padding: 4px 6px;
            vertical-align: middle;
        }

        .row.g-2 > * {
            padding-top: 5px;
            padding-bottom: 5px;
        }

        .card-body {
            padding: 12px 15px;
        }

        .section-title {
            font-size: 12px;
            font-weight: 700;
            color: #0d6efd;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 6px;
            padding-bottom: 4px;
            border-bottom: 1px solid #dee2e6;
        }

        .del-btn {
            padding: 2px 7px;
            font-size: 11px;
        }

        .add-row-btn {
            font-size: 12px;
            padding: 3px 12px;
        }

        /* Auto-generated field badge */
        .auto-id-box {
            background: #e7f1ff;
            border: 1px solid #b6d4fe;
            border-radius: 6px;
            height: 30px;
            font-size: 12px;
            padding: 2px 8px;
            color: #0d6efd;
            font-weight: 600;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .status-indicator {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            margin-right: 5px;
        }

        .status-draft   { background: #6c757d; }
        .status-active  { background: #198754; }
        .status-closed  { background: #dc3545; }

        /* Upload zone */
        .upload-zone {
            border: 2px dashed #ced4da;
            border-radius: 6px;
            padding: 10px;
            text-align: center;
            cursor: pointer;
            background: #fff;
            position: relative;
            transition: border-color 0.2s;
        }
        .upload-zone:hover { border-color: #0d6efd; }
        .upload-zone input[type="file"] {
            position: absolute; inset: 0; opacity: 0; cursor: pointer;
        }
        .upload-zone .upload-icon { font-size: 20px; color: #6c757d; }
        .upload-zone .upload-label { font-size: 11px; color: #6c757d; }

        /* Checkbox pills for processes */
        .process-pill {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            background: #fff;
            border: 1px solid #dee2e6;
            border-radius: 6px;
            padding: 3px 10px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 500;
            transition: all 0.15s;
            margin: 2px;
        }
        .process-pill input[type="checkbox"] {
            accent-color: #0d6efd;
            width: 13px; height: 13px;
        }
        .process-pill:has(input:checked) {
            background: #e7f1ff;
            border-color: #0d6efd;
            color: #0d6efd;
        }

        /* Section collapse header */
        .section-collapse-btn {
            background: none;
            border: none;
            font-size: 12px;
            font-weight: 700;
            color: #0d6efd;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 0;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .section-collapse-btn:focus { outline: none; }

        /* Table inside cards */
        .inner-table-card {
            border: 1px solid #dee2e6;
            border-radius: 8px;
            overflow: hidden;
        }

        /* Footer action bar */
        .action-bar {
            background: #fff;
            border-top: 1px solid #dee2e6;
            padding: 8px 15px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .action-bar .info-text {
            font-size: 12px;
            color: #6c757d;
        }
    </style>
</head>
<body>
<form id="styleForm" runat="server">
<div class="container-fluid py-2 px-3">

    <!-- ===== MAIN CARD ===== -->
    <div class="card shadow-sm">
        <div class="card-header bg-primary text-white d-flex align-items-center justify-content-between">
            <h4 class="mb-0"><i class="bi bi-scissors me-2"></i>Style Registration</h4>
            <asp:Label ID="Label1" runat="server" Text=""></asp:Label>
            <span class="text-white-50" style="font-size:12px;">Garments Management System</span>
        </div>

        <div class="card-body">

            <!-- ============ SECTION 1: STYLE IDENTITY ============ -->
            <div class="mb-3">
                <div class="d-flex align-items-center mb-2">
                    <button type="button" class="section-collapse-btn" data-bs-toggle="collapse" data-bs-target="#secIdentity">
                        <i class="bi bi-chevron-down"></i> 1. Style Identity
                    </button>
                </div>
                <div class="collapse show" id="secIdentity">
                    <div class="row g-2">

                        <div class="col-md-2">
                            <label>Style Entry No. <span class="text-danger">*</span></label>
                            <div class="auto-id-box" id="styleNoBadge">
                                <i class="bi bi-pencil" style="cursor:pointer;font-size:11px;" onclick="editStyleNo()" title="Edit"></i>
                            </div>
                            <asp:TextBox type="hidden" id="styleNo" name="styleNo" runat="server"></asp:TextBox>
                            <asp:TextBox type="text" id="styleNoEdit" class="form-control" style="display:none" placeholder="Style No." runat="server"></asp:TextBox>
                        </div>

                        <div class="col-md-3">
                            <label>Style Name <span class="text-danger">*</span></label>
                            <asp:TextBox ID="txtStyleName" runat="server" CssClass="form-control" placeholder="e.g. Classic Oxford Shirt" />
                        </div>

                        <div class="col-md-2">
                            <label>Buyer <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>

                        <div class="col-md-2">
                            <label>Buyer Style Ref No.</label>
                            <asp:TextBox ID="txtBuyerRef" runat="server" CssClass="form-control" placeholder="e.g. BYR-2025-9988" />
                        </div>

                        <div class="col-md-2">
                            <label>Season</label>
                            <asp:DropDownList ID="ddlSeason" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">— Select Season —</asp:ListItem>
                                <asp:ListItem>SS25</asp:ListItem>
                                <asp:ListItem>AW25</asp:ListItem>
                                <asp:ListItem>SS26</asp:ListItem>
                                <asp:ListItem>AW26</asp:ListItem>
                                <asp:ListItem>FW25</asp:ListItem>
                                <asp:ListItem>Resort 2026</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-1">
                            <label>Status <span class="text-danger">*</span></label>
                            <div style="position:relative;">
                                <span class="status-indicator status-draft" id="statusDot" style="position:absolute;left:8px;top:50%;transform:translateY(-50%);z-index:5;"></span>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select" onchange="updateStatusDot(this.value)" style="padding-left:22px;">
                                    <asp:ListItem Value="Draft">Draft</asp:ListItem>
                                    <asp:ListItem Value="Active">Active</asp:ListItem>
                                    <asp:ListItem Value="Closed">Closed</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>

                        <div class="col-md-2">
                            <label>Product Type <span class="text-danger">*</span></label>
                            <asp:DropDownList ID="ddlProductType" name="productType" class="form-select" onchange="handleProductType(this.value)" runat="server"></asp:DropDownList>                            
                        </div>

                        <div class="col-md-2">
                            <label>Product Category</label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>

                        <div class="col-md-2">
                            <label>Product Department</label>
                            <asp:DropDownList ID="ddlProductDepartment" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>

                        <div class="col-md-2">
                            <label>Fit Type</label>
                            <asp:DropDownList ID="ddlFitType" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">— Select Fit —</asp:ListItem>
                                <asp:ListItem>Regular Fit</asp:ListItem>
                                <asp:ListItem>Slim Fit</asp:ListItem>
                                <asp:ListItem>Oversized</asp:ListItem>
                                <asp:ListItem>Relaxed Fit</asp:ListItem>
                                <asp:ListItem>Athletic Fit</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-2">
                            <label>In-house Merchandiser</label>
                            <asp:DropDownList ID="ddlInhouseMerch" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">— Select —</asp:ListItem>
                                <asp:ListItem>Rahim Uddin</asp:ListItem>
                                <asp:ListItem>Shahinur Islam</asp:ListItem>
                                <asp:ListItem>Fatema Khatun</asp:ListItem>
                                <asp:ListItem>Mizanur Rahman</asp:ListItem>
                                <asp:ListItem>Nadia Akter</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="col-md-2">
                            <label>Buyer Merchandiser</label>
                            <asp:TextBox ID="txtBuyerMerch" runat="server" CssClass="form-control" placeholder="Buyer's merchandiser name" />
                        </div>

                        <div class="col-md-2">
                            <label>Registration Date</label>
                            <asp:TextBox ID="txtRegDate" runat="server" CssClass="form-control" ReadOnly="True" />
                        </div>

                    </div>
                </div>
            </div>

            <hr class="my-2" />

            <!-- ============ SECTION 2: FABRIC INFORMATION ============ -->
            <div class="mb-3">
                <div class="d-flex align-items-center justify-content-between mb-2">
                    <button type="button" class="section-collapse-btn" data-bs-toggle="collapse" data-bs-target="#secFabric">
                        <i class="bi bi-chevron-down"></i> 2. Fabric Information
                    </button>
                    <button type="button" class="btn btn-outline-primary btn-sm add-row-btn" onclick="addFabricRow()">
                        <i class="bi bi-plus-lg me-1"></i>Add Fabric Part
                    </button>
                </div>
                <div class="collapse show" id="secFabric">
                    <div class="inner-table-card">
                        <div class="table-responsive">
                            <table class="table table-sm table-bordered table-hover table-striped mb-0" id="fabricTable">
                                <thead class="table-light">
                                    <tr>
                                        <th style="min-width:110px;">Part Name</th>
                                        <th style="min-width:140px;">Fabric Type / Desc</th>
                                        <th style="min-width:130px;">Composition</th>
                                        <th class="knit-col" style="min-width:60px;">GSM</th>
                                        <th class="woven-col" style="display:none; min-width:120px;">Construction</th>
                                        <th class="woven-col" style="display:none; min-width:70px;">Width</th>
                                        <th class="knit-col" style="min-width:120px;">Yarn/Dia/Gauge</th>
                                        <th class="woven-col" style="display:none; min-width:120px;">Yarn/Dia/Gauge</th>
                                        <th style="min-width:90px;">Color/Shade</th>
                                        <th style="min-width:110px;">Supplier</th>
                                        <th style="min-width:75px;">Source</th>
                                        <th style="min-width:90px;">Consumption</th>
                                        <th style="min-width:65px;">Unit</th>
                                        <th style="min-width:40px; text-align:center;">Del</th>
                                    </tr>
                                </thead>
                                <tbody id="fabricBody"></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <hr class="my-2" />

            <!-- ============ SECTION 3: TRIM & ACCESSORIES ============ -->
            <div class="mb-3">
                <div class="d-flex align-items-center justify-content-between mb-2">
                    <button type="button" class="section-collapse-btn" data-bs-toggle="collapse" data-bs-target="#secTrim">
                        <i class="bi bi-chevron-down"></i> 3. Trim &amp; Accessories
                    </button>
                    <button type="button" class="btn btn-outline-primary btn-sm add-row-btn" onclick="addTrimRow()">
                        <i class="bi bi-plus-lg me-1"></i>Add Trim Item
                    </button>
                </div>
                <div class="collapse show" id="secTrim">
                    <div class="inner-table-card">
                        <div class="table-responsive">
                            <table class="table table-sm table-bordered table-hover table-striped mb-0" id="trimTable">
                                <thead class="table-light">
                                    <tr>
                                        <th style="min-width:120px;">Item Type</th>
                                        <th style="min-width:150px;">Description</th>
                                        <th style="min-width:120px;">Color/Size/Spec</th>
                                        <th style="min-width:65px;">Unit</th>
                                        <th style="min-width:90px;">Consumption</th>
                                        <th style="min-width:110px;">Supplier</th>
                                        <th style="min-width:80px; text-align:center;">PO-Specific?</th>
                                        <th style="min-width:40px; text-align:center;">Del</th>
                                    </tr>
                                </thead>
                                <tbody id="trimBody"></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <hr class="my-2" />

            <!-- ============ SECTION 4: TECHNICAL ============ -->
            <div class="mb-3">
                <div class="d-flex align-items-center mb-2">
                    <button type="button" class="section-collapse-btn" data-bs-toggle="collapse" data-bs-target="#secTechnical">
                        <i class="bi bi-chevron-down"></i> 4. Technical
                    </button>
                </div>
                <div class="collapse show" id="secTechnical">
                    <div class="row g-2">
                        <div class="col-12">
                            <label>Special Processes</label>
                            <div>
                                <label class="process-pill">
                                    <input type="checkbox" name="process" value="Washing" id="chkWashing" onchange="toggleWashType()" />
                                    🫧 Washing
                                </label>
                                <label class="process-pill">
                                    <input type="checkbox" name="process" value="Printing" />
                                    🖨️ Printing
                                </label>
                                <label class="process-pill">
                                    <input type="checkbox" name="process" value="Embroidery" />
                                    🧶 Embroidery
                                </label>
                                <label class="process-pill">
                                    <input type="checkbox" name="process" value="Garments Dye" />
                                    🎨 Garments Dye
                                </label>
                                <label class="process-pill">
                                    <input type="checkbox" name="process" value="Screen Print" />
                                    ✂️ Screen Print
                                </label>
                                <label class="process-pill">
                                    <input type="checkbox" name="process" value="Heat Transfer" />
                                    🔥 Heat Transfer
                                </label>
                            </div>
                        </div>

                        <div class="col-md-2" id="washTypeField" style="display:none;">
                            <label>Wash Type</label>
                            <select id="washType" name="washType" class="form-select">
                                <option value="">— Select Wash —</option>
                                <option>Stone Wash</option>
                                <option>Enzyme Wash</option>
                                <option>Acid Wash</option>
                                <option>Bleach Wash</option>
                                <option>Snow Wash</option>
                                <option>Sand Blast</option>
                                <option>Pigment Wash</option>
                                <option>Silicon Wash</option>
                            </select>
                        </div>

                        <div class="col-md-2">
                            <label>SMV</label>
                            <input type="number" id="smv" name="smv" class="form-control" placeholder="0.00" min="0" step="0.01" />
                        </div>

                        <div class="col-md-8">
                            <label>Remarks</label>
                            <textarea id="remarks" name="remarks" class="form-control" rows="2" placeholder="Technical notes or special instructions..."></textarea>
                        </div>
                    </div>
                </div>
            </div>

            <hr class="my-2" />

            <!-- ============ SECTION 5: ATTACHMENTS ============ -->
            <div class="mb-3">
                <div class="d-flex align-items-center mb-2">
                    <button type="button" class="section-collapse-btn" data-bs-toggle="collapse" data-bs-target="#secAttachments">
                        <i class="bi bi-chevron-down"></i> 5. Attachments
                    </button>
                </div>
                <div class="collapse show" id="secAttachments">
                    <div class="row g-2">
                        <div class="col-md-3">
                            <label>Tech Pack (PDF)</label>
                            <div class="upload-zone" id="techPackZone">
                                <input type="file" id="techPackFile" accept=".pdf" onchange="handleFileSelect('techPack', this)" runat="server" />
                                <div id="techPackContent">
                                    <div class="upload-icon"><i class="bi bi-file-earmark-pdf"></i></div>
                                    <div class="upload-label">Click to upload PDF (max 20MB)</div>
                                </div>
                                <div id="techPackPreview" style="display:none; font-size:11px; color:#198754;">
                                    <i class="bi bi-check-circle me-1"></i>
                                    <span id="techPackName"></span>
                                    <span id="techPackSize" class="text-muted ms-1"></span>
                                    <span onclick="clearFile('techPack',event)" style="cursor:pointer; color:#dc3545; margin-left:6px;">✕</span>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-3">
                            <label>Style Photo</label>
                            <div class="upload-zone" id="stylePhotoZone">
                                <input type="file" id="stylePhotoFile" accept="image/*" onchange="handleFileSelect('stylePhoto', this)" runat="server" />
                                <div id="stylePhotoContent">
                                    <div class="upload-icon"><i class="bi bi-image"></i></div>
                                    <div class="upload-label">Click to upload image (JPG/PNG)</div>
                                </div>
                                <div id="stylePhotoPreview" style="display:none; font-size:11px; color:#198754;">
                                    <i class="bi bi-check-circle me-1"></i>
                                    <span id="stylePhotoName"></span>
                                    <span id="stylePhotoSize" class="text-muted ms-1"></span>
                                    <span onclick="clearFile('stylePhoto',event)" style="cursor:pointer; color:#dc3545; margin-left:6px;">✕</span>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-6">
                            <label>Additional Notes</label>
                            <textarea id="addlNotes" name="addlNotes" class="form-control" rows="3" placeholder="Buyer comments, special requirements..."></textarea>
                        </div>
                    </div>
                </div>
            </div>

        </div><!-- end card-body -->

        <!-- ===== ACTION BAR ===== -->
        <div class="action-bar">
            <div class="info-text">
                Style: <strong id="previewStyleNo">STY-2025-0001</strong> &nbsp;|&nbsp;
                Status: <strong id="previewStatus">Draft</strong>
            </div>
            <div class="d-flex gap-2">
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary" OnClientClick="return resetForm();" />
                <button type="button" class="btn btn-warning" onclick="saveDraft()">
                    <i class="bi bi-floppy me-1"></i>Save Draft
                </button>
                <asp:LinkButton ID="btnSave" runat="server" CssClass="btn btn-success d-inline-flex align-items-center">
                    <i class="bi bi-save me-1"></i>Submit Style
                </asp:LinkButton>
            </div>
        </div>

    </div><!-- end card -->
</div><!-- end container -->
</form>

<!-- TOAST -->
<div class="toast-container position-fixed top-0 end-0 p-3" style="z-index:9999;">
    <div id="toast" class="toast align-items-center text-bg-success border-0" role="alert">
        <div class="d-flex">
            <div class="toast-body" id="toastMsg">Saved successfully!</div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>

<!-- ===== JAVASCRIPT ===== -->
<script>
    /* Auto date */
    (function () {
        const d = new Date().toISOString().split('T')[0];
        document.getElementById('txtRegDate') && (document.getElementById('txtRegDate').value = d);
        // Fallback for plain input
        const rd = document.querySelector('[id$="txtRegDate"]');
        if (rd) rd.value = d;
    })();

    /* Style No editable */
    function editStyleNo() {
        document.getElementById('styleNoBadge').style.display = 'none';
        const edit = document.getElementById('styleNoEdit');
        edit.style.display = '';
        edit.value = document.getElementById('styleNo').value;
        edit.focus();
        edit.onblur = function () {
            document.getElementById('styleNoDisplay').textContent = this.value || 'STY-2025-0001';
            document.getElementById('styleNo').value = this.value;
            document.getElementById('previewStyleNo').textContent = this.value || 'STY-2025-0001';
            document.getElementById('styleNoBadge').style.display = '';
            edit.style.display = 'none';
        };
    }

    /* Status dot */
    function updateStatusDot(val) {
        const dot = document.getElementById('statusDot');
        dot.className = 'status-indicator';
        if (val === 'Active') dot.classList.add('status-active');
        else if (val === 'Closed') dot.classList.add('status-closed');
        else dot.classList.add('status-draft');
        document.getElementById('previewStatus').textContent = val || 'Draft';
    }

    /* Product type knit/woven */
    let currentType = '';
    function handleProductType(val) {
        currentType = val;
        document.querySelectorAll('#fabricBody tr').forEach(row => updateFabricRowCols(row, val));
        document.querySelectorAll('.knit-col').forEach(c => c.style.display = val === 'Woven' ? 'none' : '');
        document.querySelectorAll('.woven-col').forEach(c => c.style.display = val === 'Woven' ? '' : 'none');
    }
    function updateFabricRowCols(row, type) {
        row.querySelectorAll('.knit-td').forEach(td => td.style.display = type === 'Woven' ? 'none' : '');
        row.querySelectorAll('.woven-td').forEach(td => td.style.display = type === 'Woven' ? '' : 'none');
    }

    /* Fabric rows */
    let fabricRowCount = 0;
    const partNames = ['Body', 'Collar', 'Cuff', 'Lining', 'Interlining', 'Sleeve', 'Facing', 'Pocket'];
    const fabricSuppliers = ['Tex Fabrics Ltd.', 'Knit World', 'Global Fabric Co.', 'Fine Weave Mills', 'Comfort Knit', 'Premium Textile'];

    function addFabricRow() {
        const tbody = document.getElementById('fabricBody');
        const i = ++fabricRowCount;
        const isWoven = currentType === 'Woven';
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td><select class="form-select" name="fabric_part_${i}">
                <option value="">— Part —</option>
                ${partNames.map(p => `<option>${p}</option>`).join('')}
            </select></td>
            <td><input type="text" class="form-control" name="fabric_type_${i}" placeholder="Single Jersey" /></td>
            <td><input type="text" class="form-control" name="fabric_comp_${i}" placeholder="100% Cotton" /></td>
            <td class="knit-td" style="${isWoven ? 'display:none' : ''}">
                <input type="number" class="form-control" name="fabric_gsm_${i}" placeholder="180" />
            </td>
            <td class="woven-td" style="${isWoven ? '' : 'display:none'}">
                <input type="text" class="form-control" name="fabric_const_${i}" placeholder="40x40/133x72" />
            </td>
            <td class="woven-td" style="${isWoven ? '' : 'display:none'}">
                <input type="text" class="form-control" name="fabric_width_${i}" placeholder='58"' />
            </td>
            <td class="knit-td" style="${isWoven ? 'display:none' : ''}">
                <input type="text" class="form-control" name="fabric_yarn_${i}" placeholder="30s/30&quot;/28G" />
            </td>
            <td class="woven-td" style="${isWoven ? '' : 'display:none'}">
                <input type="text" class="form-control" name="fabric_yarn_w_${i}" placeholder="40s / —" />
            </td>
            <td><input type="text" class="form-control" name="fabric_color_${i}" placeholder="As per PO" /></td>
            <td><select class="form-select" name="fabric_supplier_${i}">
                <option value="">— Supplier —</option>
                ${fabricSuppliers.map(s => `<option>${s}</option>`).join('')}
            </select></td>
            <td><select class="form-select" name="fabric_source_${i}">
                <option>Local</option><option>Import</option>
            </select></td>
            <td><input type="number" class="form-control" name="fabric_consumption_${i}" placeholder="1.45" step="0.01" /></td>
            <td><select class="form-select" name="fabric_unit_${i}">
                <option>per dz</option><option>per pcs</option><option>per set</option>
            </select></td>
            <td class="text-center">
                <button type="button" class="btn btn-outline-danger btn-sm del-btn" onclick="this.closest('tr').remove()">
                    <i class="bi bi-trash3"></i>
                </button>
            </td>
        `;
        tbody.appendChild(tr);
    }

    /* Trim rows */
    let trimRowCount = 0;
    const trimTypes = ['Button', 'Label', 'Thread', 'Zipper', 'Elastic', 'Interlining', 'Hang Tag', 'Poly Bag', 'Carton', 'Snap Button', 'Hook & Eye', 'Woven Label', 'Care Label', 'Price Tag'];

    function addTrimRow() {
        const tbody = document.getElementById('trimBody');
        const i = ++trimRowCount;
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td><select class="form-select" name="trim_type_${i}">
                <option value="">— Type —</option>
                ${trimTypes.map(t => `<option>${t}</option>`).join('')}
            </select></td>
            <td><input type="text" class="form-control" name="trim_desc_${i}" placeholder="Description..." /></td>
            <td><input type="text" class="form-control" name="trim_spec_${i}" placeholder="15mm / Black" /></td>
            <td><select class="form-select" name="trim_unit_${i}">
                <option>pcs</option><option>dz</option><option>meter</option><option>cone</option><option>set</option>
            </select></td>
            <td><input type="number" class="form-control" name="trim_consumption_${i}" placeholder="12" step="0.01" /></td>
            <td><select class="form-select" name="trim_supplier_${i}">
                <option value="">— Supplier —</option>
                <option>Trim World</option><option>Apex Accessories</option><option>Star Trim</option><option>Delta Trims</option>
            </select></td>
            <td class="text-center">
                <div class="form-check d-flex justify-content-center">
                    <input type="checkbox" class="form-check-input" name="trim_po_${i}" />
                </div>
            </td>
            <td class="text-center">
                <button type="button" class="btn btn-outline-danger btn-sm del-btn" onclick="this.closest('tr').remove()">
                    <i class="bi bi-trash3"></i>
                </button>
            </td>
        `;
        tbody.appendChild(tr);
    }

    /* Wash type toggle */
    function toggleWashType() {
        document.getElementById('washTypeField').style.display =
            document.getElementById('chkWashing').checked ? '' : 'none';
    }

    /* File upload */
    function handleFileSelect(key, input) {
        if (!input.files.length) return;
        const file = input.files[0];
        document.getElementById(key + 'Content').style.display = 'none';
        document.getElementById(key + 'Preview').style.display = '';
        document.getElementById(key + 'Name').textContent = file.name;
        document.getElementById(key + 'Size').textContent = formatBytes(file.size);
    }
    function clearFile(key, e) {
        e.stopPropagation(); e.preventDefault();
        document.getElementById(key + 'File').value = '';
        document.getElementById(key + 'Content').style.display = '';
        document.getElementById(key + 'Preview').style.display = 'none';
    }
    function formatBytes(b) {
        if (b < 1024) return b + ' B';
        if (b < 1048576) return (b / 1024).toFixed(1) + ' KB';
        return (b / 1048576).toFixed(1) + ' MB';
    }

    /* Toast */
    function showToast(msg) {
        document.getElementById('toastMsg').textContent = msg;
        const t = new bootstrap.Toast(document.getElementById('toast'), { delay: 3000 });
        t.show();
    }

    /* Save Draft */
    function saveDraft() {
        updateStatusDot('Draft');
        showToast('Draft saved successfully!');
    }

    /* Reset */
    function resetForm() {
        if (!confirm('Reset all fields? This cannot be undone.')) return false;
        document.getElementById('fabricBody').innerHTML = '';
        document.getElementById('trimBody').innerHTML = '';
        fabricRowCount = 0; trimRowCount = 0;
        document.getElementById('washTypeField').style.display = 'none';
        document.getElementById('styleNoDisplay').textContent = 'STY-2025-0001';
        document.getElementById('previewStyleNo').textContent = 'STY-2025-0001';
        updateStatusDot('Draft');
        ['techPack', 'stylePhoto'].forEach(k => {
            document.getElementById(k + 'Content').style.display = '';
            document.getElementById(k + 'Preview').style.display = 'none';
        });
        addFabricRow(); addTrimRow();
        showToast('Form has been reset.');
        return true;
    }

    /* Init */
    addFabricRow();
    addTrimRow();
</script>
</body>
</html>