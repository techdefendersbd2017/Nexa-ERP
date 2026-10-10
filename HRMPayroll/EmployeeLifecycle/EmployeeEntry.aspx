<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeEntry.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.EmployeeEntry" %>

<!DOCTYPE html>
<html lang="bn">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Employee Entry</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Hind+Siliguri:wght@400;500;600&display=swap" rel="stylesheet" />

    <style>
        :root {
            --brand-primary: #2e5bd7;
            --brand-primary-dark: #234699;
            --text-muted: #6b7280;
            --shell-offset: 4.5rem;   /* ERP shell এর উপরের বারের জন্য ফাঁকা জায়গা; দরকারে বদলান */
        }

        body { background-color: #f0f2f5; font-family: 'Inter', 'Hind Siliguri', 'Segoe UI', Arial, sans-serif; font-size: 12px; padding-top: var(--shell-offset); }

        .main-wrapper {
            max-width: 1150px;
            margin: 10px auto;
            background: #fff;
            border: 1px solid #ccc;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            padding: 0;
            border-radius: 5px;
        }

        /* পেজ হেডিং (আইকন + টাইটেল + ব্রেডক্রাম্ব) */
        .page-heading { display: flex; align-items: center; gap: 12px; padding: 16px 20px; border-bottom: 1px solid #e6e9ef; }
        .page-heading i { font-size: 1.6rem; color: var(--brand-primary); }
        .page-heading h3 { margin: 0; font-weight: 700; font-size: 1.25rem; color: #111827; }
        .page-heading small { display: block; color: var(--text-muted); font-weight: 400; font-size: 0.78rem; }

        .content-area { padding: 15px; }
        .fixed-top-section { border-bottom: 1px solid #eee; margin-bottom: 10px; padding-bottom: 10px; }

        .employee-meta-grid { display: grid; grid-template-columns: auto 150px; column-gap: 12px; row-gap: 8px; align-items: center; }
        .employee-meta-grid label { text-align: left; white-space: nowrap; }
        .employee-meta-grid .form-control-sm { width: 100%; }
        .employee-meta-grid .val { font-weight: 600; }

        /* ছবি */
        .photo-box { width: 120px; height: 140px; border: 1px solid #ccc; background: #f8f9fa; display: flex; align-items: center; justify-content: center; margin-bottom: 5px; overflow: hidden; }
        .photo-box img { width: 100%; height: 100%; object-fit: cover; display: block; }
        .photo-btn { background: #eef3ff; border: 1px solid #adc5ff; color: #2e5bd7; font-weight: bold; width: 120px; font-size: 11px; padding: 2px; text-align: center; display: block; cursor: pointer; }
        .photo-btn:hover { background: #dfe8ff; }

        /* ট্যাব */
        .nav-tabs .nav-link { background: #f8f9fa; border: 1px solid #ddd; color: #555; margin-right: 2px; padding: 6px 12px; font-size: 12px; }
        .nav-tabs .nav-link.active { background: #2e5bd7 !important; color: #fff !important; border-bottom: none; font-weight: bold; }
        .tab-content { background: #fff; border: 1px solid #ddd; border-top: none; padding: 20px; }
        .tab-pane { min-height: 260px; }

        .form-row-custom { display: flex; align-items: center; margin-bottom: 6px; }
        .form-row-custom label { width: 130px; min-width: 130px; margin-bottom: 0; font-weight: 500; color: #333; }
        .form-control-sm { border-radius: 4px; border: 1px solid #ced4da; font-size: 12px; height: 28px; }

        .section-title { font-weight: bold; background: #f0f4ff; color: #2e5bd7; padding: 4px 10px; display: block; margin-bottom: 10px; border-left: 4px solid #2e5bd7; }
        .section-box { border: 1px solid #ddd; border-radius: 8px; padding: 14px; background: #fafbfc; height: 100%; }
        .section-box .form-row-custom:last-child { margin-bottom: 0; }

        /* Previous / Next Page */
        .tab-nav-btns { display: flex; justify-content: space-between; align-items: center; margin-top: 18px; padding-top: 12px; border-top: 1px dashed #e0e4eb; }
        .tab-nav-btns .btn-nav { background-color: #eef3ff; border: 1px solid #2e5bd7; color: #2e5bd7; font-weight: bold; font-size: 12px; border-radius: 5px; padding: 6px 16px; display: inline-flex; align-items: center; gap: 6px; cursor: pointer; }
        .tab-nav-btns .btn-nav:hover { background-color: #2e5bd7; color: #fff; }
        .tab-nav-btns .btn-nav-spacer { visibility: hidden; }

        /* বাটন বার */
        .footer-btns { margin-top: 15px; text-align: center; background: #fff; border-top: 1px solid #eee; padding-top: 15px; padding-bottom: 5px; }
        .footer-btns .btn { min-width: 130px; border-radius: 5px; margin: 0 5px 8px; font-size: 12px; font-weight: bold; background-color: #eef3ff; border: 1px solid #2e5bd7; color: #2e5bd7; }
        .footer-btns .btn:hover { background-color: #2e5bd7; color: #fff; }
        .footer-btns .btn-danger-soft { background-color: #fff5f5; border-color: #dc3545; color: #dc3545; }
        .footer-btns .btn-danger-soft:hover { background-color: #dc3545; color: #fff; }
        .footer-btns .btn:disabled { opacity: .5; }
        .btn-search-dark { background-color: #f8f9fa; border: 1px solid #ccc; color: #333; }

        /* code-behind এর Lock লেবেলের ক্লাস */
        .font-semibold { font-weight: 600; }
        .text-red-600 { color: #dc2626; }
        .text-emerald-600 { color: #059669; }

        /* =========================================================
           Searchable Dropdown — Select2 স্টাইলের (গোল বক্স, chevron, pill সার্চ)
        ========================================================= */
        .dd-ctl { position: relative; flex: 1 1 auto; min-width: 0; }
        .dd-fld { display: flex; align-items: center; gap: 6px; height: 30px; padding: 0 8px 0 12px; border: 1px solid #ced4da; border-radius: 8px;
                  background: #fff; font-size: 12px; cursor: pointer; user-select: none; transition: border-color .15s ease, box-shadow .15s ease; }
        .dd-fld:focus, .dd-fld.open { outline: none; border-color: var(--brand-primary); box-shadow: 0 0 0 3px rgba(46, 91, 215, 0.12); }
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

        /* Increment টেবিল */
        .gv th { background: #f0f4ff !important; color: #2e5bd7; font-size: 11.5px; white-space: nowrap; }
        .gv td { font-size: 12px; vertical-align: middle; }

        /* Toast */
        #toastContainer { position: fixed; right: 16px; top: 16px; z-index: 2000; display: flex; flex-direction: column; gap: 8px; pointer-events: none; }
        .app-toast { background: #111827; color: #fff; font-size: 12px; padding: 10px 16px; border-radius: 10px; box-shadow: 0 6px 18px rgba(0,0,0,.25);
                     display: flex; align-items: center; gap: 8px; opacity: 0; transform: translateY(8px); transition: all .25s ease; pointer-events: auto; }
        .app-toast.show { opacity: 1; transform: none; }
        .app-toast i { color: #8fb0ff; }
    </style>
</head>
<body>
<form id="form1" runat="server" enctype="multipart/form-data">
    <asp:HiddenField ID="hfEmpNo" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfLock" runat="server" ClientIDMode="Static" />

    <!-- ড্রপডাউনের নির্বাচিত মান (JS এখানে লেখে, Server এখান থেকে পড়ে) -->
    <asp:HiddenField ID="hfMR" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfBlood" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfCompany" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfBranch" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfDept" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfSection" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfLine" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfDesig" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfCategory" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfShift" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfFloor" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfWeekOff" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfBreak" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfPayType" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfTax" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfBank" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfBankName" runat="server" ClientIDMode="Static" />

    <div id="toastContainer"></div>

    <div class="main-wrapper">

        <!-- পেজ হেডিং -->
        <div class="page-heading">
            <i class="bi bi-person-vcard-fill"></i>
            <div>
                <h3>Employee Entry</h3>
                <small>HRM Payroll &rsaquo; Employee Lifecycle &rsaquo; Employee Entry</small>
            </div>
        </div>

        <div class="content-area">

            <div id="errBox" class="alert alert-danger py-2 d-none" role="alert"></div>

            <!-- 1. ফিক্সড টপ সেকশন (Basic Information) -->
            <div class="fixed-top-section">
                <div class="row g-2">
                    <div class="col-md-6">
                        <div class="form-row-custom">
                            <label>Employee ID</label>
                            <div class="input-group input-group-sm" style="width: 250px;">
                                <asp:TextBox ID="txtEmpId" runat="server" CssClass="form-control" MaxLength="20"></asp:TextBox>
                                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-search-dark" OnClick="btnSearch_Click" CausesValidation="false" />
                            </div>
                        </div>
                        <div data-dd="mr"></div>
                        <div class="form-row-custom">
                            <label>Name</label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control form-control-sm"></asp:TextBox>
                        </div>
                        <div class="form-row-custom">
                            <label>Bangla Name</label>
                            <asp:TextBox ID="txtBanglaName" runat="server" CssClass="form-control form-control-sm"></asp:TextBox>
                        </div>
                        <div data-dd="blood"></div>
                        <div class="mt-1"><span class="text-primary fw-bold">User Name: <asp:Label ID="lblUser" runat="server" /></span></div>
                    </div>

                    <div class="col-md-6">
                        <div class="d-flex justify-content-end align-items-start flex-wrap gap-2">
                            <div class="employee-meta-grid small pt-1 me-3">
                                <label class="mb-0">Joining Date</label>
                                <asp:TextBox ID="txtJoining" runat="server" TextMode="Date" CssClass="form-control form-control-sm"></asp:TextBox>

                                <label class="mb-0">Probation Period</label>
                                <asp:TextBox ID="txtProbation" runat="server" TextMode="Date" CssClass="form-control form-control-sm"></asp:TextBox>

                                <label class="mb-0">Employee Status</label>
                                <span class="val"><asp:Label ID="lblLock" runat="server" CssClass="font-semibold text-emerald-600" Text="Unlock" /></span>

                                <label class="mb-0">Status</label>
                                <span class="val"><asp:Label ID="lblStatus" runat="server" CssClass="font-semibold" /> <asp:Label ID="lblStatusDate" runat="server" /></span>
                            </div>

                            <!-- Photo -->
                            <div>
                                <label for="fuPhoto" style="cursor:pointer; display:block;">
                                    <div class="photo-box text-muted">
                                        <asp:Image ID="imgEmp" runat="server" ClientIDMode="Static" ImageUrl="~/Images/user-default.png" AlternateText="Employee photo"
                                            onerror="this.onerror=null;this.src='data:image/svg+xml;utf8,%3Csvg xmlns=%27http://www.w3.org/2000/svg%27 viewBox=%270 0 100 125%27%3E%3Crect width=%27100%27 height=%27125%27 fill=%27%23e6eded%27/%3E%3Ccircle cx=%2750%27 cy=%2746%27 r=%2720%27 fill=%27%23a9bcc0%27/%3E%3Cpath d=%27M12 125c0-26 17-42 38-42s38 16 38 42z%27 fill=%27%23a9bcc0%27/%3E%3C/svg%3E';" />
                                    </div>
                                </label>
                                <asp:FileUpload ID="fuPhoto" runat="server" ClientIDMode="Static" accept=".jpg,.jpeg,.png,.bmp" CssClass="d-none" />
                                <label for="fuPhoto" class="photo-btn">Choose Photo</label>
                                <div id="photoInfo" class="text-muted" style="font-size:10px; text-align:center; margin-top:2px;">সর্বোচ্চ 300KB (JPG/PNG/BMP)</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- বাটন বার -->
                <div class="footer-btns">
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn" OnClick="btnRefresh_Click" CausesValidation="false" />
                    <asp:Button ID="btnIncrement" runat="server" Text="Increment History" CssClass="btn" OnClick="btnIncrement_Click" CausesValidation="false" />
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn" OnClick="btnSave_Click" OnClientClick="return validateForm();" />
                    <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn" OnClick="btnUpdate_Click" OnClientClick="return validateForm();" />
                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-danger-soft" OnClick="btnDelete_Click" OnClientClick="return confirm('এই কর্মচারীকে Delete করতে চান?');" />
                </div>
            </div>

            <!-- 2. ট্যাব নেভিগেশন -->
            <ul class="nav nav-tabs" id="hrTabs" role="tablist">
                <li class="nav-item"><button type="button" class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab1">Office Information</button></li>
                <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab2">Salary and Bank Information</button></li>
                <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab3">Increment History</button></li>
            </ul>

            <!-- 3. ট্যাব কনটেন্ট -->
            <div class="tab-content">

                <!-- Office Information -->
                <div class="tab-pane fade show active" id="tab1">
                    <div class="section-box">
                        <span class="section-title">Job &amp; Work Assignment</span>
                        <div class="row g-2">
                            <div class="col-md-6">
                                <div data-dd="company"></div>
                                <div data-dd="branch"></div>
                                <div data-dd="dept"></div>
                                <div data-dd="section"></div>
                                <div data-dd="line"></div>
                                <div data-dd="desig"></div>
                            </div>
                            <div class="col-md-6">
                                <div data-dd="category"></div>
                                <div data-dd="shift"></div>
                                <div data-dd="floor"></div>
                                <div data-dd="weekoff"></div>
                                <div data-dd="brk"></div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-nav-btns">
                        <span class="btn-nav btn-nav-spacer"><i class="bi bi-chevron-left"></i> Previous Page</span>
                        <button type="button" class="btn-nav" data-goto="#tab2">Next Page <i class="bi bi-chevron-right"></i></button>
                    </div>
                </div>

                <!-- Salary and Bank Information -->
                <div class="tab-pane fade" id="tab2">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="section-box">
                                <span class="section-title">Salary</span>
                                <div class="form-row-custom"><label>Gross Salary</label><asp:TextBox ID="txtGross" runat="server" CssClass="form-control form-control-sm w-100" Text="0" /></div>
                                <div data-dd="paytype"></div>
                                <div class="form-row-custom"><label>Bank Gross</label><asp:TextBox ID="txtBankGross" runat="server" CssClass="form-control form-control-sm w-100" Text="0" /></div>
                                <div class="form-row-custom"><label>Cash Gross</label><asp:TextBox ID="txtCashGross" runat="server" CssClass="form-control form-control-sm w-100" Text="0" /></div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="section-box">
                                <span class="section-title">Tax &amp; Bank</span>
                                <div data-dd="tax"></div>
                                <div class="form-row-custom"><label>Amount</label><asp:TextBox ID="txtTaxAmount" runat="server" CssClass="form-control form-control-sm w-100" /></div>
                                <div data-dd="bank"></div>
                                <div data-dd="bankname"></div>
                                <div class="form-row-custom"><label>A/C No</label><asp:TextBox ID="txtAcNo" runat="server" CssClass="form-control form-control-sm w-100" /></div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-nav-btns">
                        <button type="button" class="btn-nav" data-goto="#tab1"><i class="bi bi-chevron-left"></i> Previous Page</button>
                        <button type="button" class="btn-nav" data-goto="#tab3">Next Page <i class="bi bi-chevron-right"></i></button>
                    </div>
                </div>

                <!-- Increment History -->
                <div class="tab-pane fade" id="tab3">
                    <span class="section-title">Confirm হওয়া Increment / Promotion তালিকা</span>
                    <div class="table-responsive">
                        <asp:GridView ID="gvIncrement" runat="server" AutoGenerateColumns="false"
                            CssClass="table table-sm table-bordered table-hover mb-0 gv" GridLines="None"
                            EmptyDataText="কোনো তথ্য নেই">
                            <Columns>
                                <asp:BoundField DataField="Efective_Date" HeaderText="Effective Date" DataFormatString="{0:dd-MMM-yyyy}" />
                                <asp:BoundField DataField="Old_Gross_Salary" HeaderText="Old Gross" />
                                <asp:BoundField DataField="Increment_Amount" HeaderText="Increment Amount" />
                                <asp:BoundField DataField="New_Gross" HeaderText="New Gross" ItemStyle-Font-Bold="true" />
                                <asp:BoundField DataField="Increment_Name" HeaderText="Promotion Status" />
                                <asp:BoundField DataField="Designation" HeaderText="Old Designation" />
                                <asp:BoundField DataField="Desigation_name" HeaderText="New Designation" />
                            </Columns>
                        </asp:GridView>
                    </div>

                    <div class="tab-nav-btns">
                        <button type="button" class="btn-nav" data-goto="#tab2"><i class="bi bi-chevron-left"></i> Previous Page</button>
                    </div>
                </div>

            </div>
        </div>
    </div>
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- ১) ড্রপডাউনের অপশন তালিকা (Server থেকে) -->
<script>var OPT = {}; try { OPT = JSON.parse('<%= HttpUtility.JavaScriptStringEncode(OptJson) %>'); } catch (e) { window.__optErr = e.message; }</script>

<!-- ২) Searchable ড্রপডাউন -->
<script>
const FIELDS = [
    { id: 'mr', hf: 'hfMR', label: 'Title', ph: 'Select title' },
    { id: 'blood', hf: 'hfBlood', label: 'Blood Group', ph: 'Select blood group' },
    { id: 'company', hf: 'hfCompany', label: 'Company', ph: 'Select company' },
    { id: 'branch', hf: 'hfBranch', label: 'Branch', ph: 'Select branch' },
    { id: 'dept', hf: 'hfDept', label: 'Department', ph: 'Select department' },
    { id: 'section', hf: 'hfSection', label: 'Section', ph: 'Select section' },
    { id: 'line', hf: 'hfLine', label: 'Line', ph: 'Select line' },
    { id: 'desig', hf: 'hfDesig', label: 'Designation', ph: 'Select designation' },
    { id: 'category', hf: 'hfCategory', label: 'Category', ph: 'Select category' },
    { id: 'shift', hf: 'hfShift', label: 'Shift', ph: 'Select shift' },
    { id: 'floor', hf: 'hfFloor', label: 'Floor', ph: 'Select floor' },
    { id: 'weekoff', hf: 'hfWeekOff', label: 'Weekly Holiday', ph: 'Select weekly holiday' },
    { id: 'brk', hf: 'hfBreak', label: 'Break Down', ph: 'Select break down' },
    { id: 'paytype', hf: 'hfPayType', label: 'Pay Type', ph: 'Select pay type' },
    { id: 'tax', hf: 'hfTax', label: 'Tax Holder', ph: 'Select' },
    { id: 'bank', hf: 'hfBank', label: 'Bank Holder', ph: 'Select' },
    { id: 'bankname', hf: 'hfBankName', label: 'Bank Name', ph: 'Select bank' }
];
FIELDS.forEach(function (f) { f.opts = OPT[f.id] || []; });
const state = {};

const esc = function (s) { return String(s).replace(/[&<>"']/g, function (c) { return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]; }); };
const fieldOf = function (id) { return FIELDS.find(function (f) { return f.id === id; }); };
const hfVal = function (id) { return document.getElementById(fieldOf(id).hf).value || ''; };

function buildFilters() {
    FIELDS.forEach(function (f) {
        var host = document.querySelector('[data-dd="' + f.id + '"]');
        if (!host) return;
        host.id = 'wrap-' + f.id;
        host.classList.add('form-row-custom');
        var saved = document.getElementById(f.hf).value;
        state[f.id] = saved ? saved.split('|').filter(Boolean) : [];
        host.innerHTML =
            '<label>' + f.label + '</label>' +
            '<div class="dd-ctl">' +
              '<div id="fld-' + f.id + '" class="dd-fld" tabindex="0" onclick="toggleDD(\'' + f.id + '\')" ' +
                  'onkeydown="if(event.key===\'Enter\'||event.key===\' \'){event.preventDefault();toggleDD(\'' + f.id + '\')}">' +
                '<span class="txt"></span>' +
                '<span class="clr" onclick="clearField(\'' + f.id + '\',event)" title="Clear"><i class="bi bi-x-lg"></i></span>' +
                '<i class="bi bi-chevron-expand chev"></i>' +
              '</div>' +
              '<div id="panel-' + f.id + '" class="dd-panel d-none" onclick="event.stopPropagation()">' +
                '<div class="ps"><i class="bi bi-search"></i>' +
                  '<input type="text" id="q-' + f.id + '" placeholder="Search ' + f.label.toLowerCase() + '..." autocomplete="off" ' +
                  'oninput="renderList(\'' + f.id + '\')" onkeydown="if(event.key===\'Enter\')return false;"></div>' +
                '<div class="pl" id="list-' + f.id + '"></div>' +
              '</div>' +
            '</div>';
        refreshField(f.id);
    });
}

function syncHidden(id) {
    document.getElementById(fieldOf(id).hf).value = (state[id] || []).join('|');
}

function refreshField(id) {
    var f = fieldOf(id), vals = state[id] || [];
    var box = document.getElementById('fld-' + id);
    box.classList.toggle('has', vals.length > 0);
    box.querySelector('.txt').textContent = vals.length ? vals.join(', ') : f.ph;
    renderList(id);
}

function renderList(id) {
    var f = fieldOf(id), vals = state[id] || [];
    var q = (document.getElementById('q-' + id).value || '').toLowerCase();
    var list = document.getElementById('list-' + id);
    var html = f.opts.filter(function (o) { return o.toLowerCase().indexOf(q) > -1; }).map(function (o) {
        var i = f.opts.indexOf(o), on = vals.indexOf(o) > -1;
        return '<div class="it ' + (on ? 'sel-single' : '') + '" onclick="pick(\'' + id + '\',' + i + ')"><span>' + esc(o) + '</span>' +
               (on ? '<i class="bi bi-check-lg ms-auto"></i>' : '') + '</div>';
    }).join('');
    list.innerHTML = html || '<div class="empty">No results found</div>';
}

function pick(id, i) {
    state[id] = [fieldOf(id).opts[i]];
    closeAll();
    syncHidden(id); refreshField(id);
    if (window.onFieldChange) window.onFieldChange(id);
}

function clearField(id, ev) {
    if (ev) ev.stopPropagation();
    state[id] = [];
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

function showNotification(message) {
    var container = document.getElementById('toastContainer');
    var toast = document.createElement('div');
    toast.className = 'app-toast';
    toast.innerHTML = '<i class="bi bi-info-circle-fill"></i><span>' + esc(message) + '</span>';
    container.appendChild(toast);
    setTimeout(function () { toast.classList.add('show'); }, 10);
    setTimeout(function () { toast.classList.remove('show'); setTimeout(function () { toast.remove(); }, 300); }, 3500);
}
</script>

<!-- ৩) পেজের নিজস্ব লজিক -->
<script>
    // ---- Photo: 300 KB limit ----
    var MAX_PHOTO = 300 * 1024;
    document.getElementById('fuPhoto').addEventListener('change', function () {
        var f = this.files && this.files[0];
        if (!f) return;
        if (f.size > MAX_PHOTO) {
            showNotification('ছবির সাইজ 300 KB এর বেশি (' + Math.round(f.size / 1024) + ' KB)। ছোট ছবি দিন।');
            this.value = '';
            document.getElementById('photoInfo').textContent = 'সর্বোচ্চ 300KB (JPG/PNG/BMP)';
            return;
        }
        document.getElementById('photoInfo').textContent = f.name + ' (' + Math.round(f.size / 1024) + ' KB)';
        var r = new FileReader();
        r.onload = function (e) { document.getElementById('imgEmp').src = e.target.result; };
        r.readAsDataURL(f);
    });

    // ---- Cash Gross = Gross - Bank Gross ----
    function num(id) { return parseInt(document.getElementById(id).value, 10) || 0; }
    function calcCash() {
        document.getElementById('<%= txtCashGross.ClientID %>').value = num('<%= txtGross.ClientID %>') - num('<%= txtBankGross.ClientID %>');
    }
    function payTypeLock() {
        var ro = hfVal('paytype') === 'Bank Or Cash';
        document.getElementById('<%= txtBankGross.ClientID %>').readOnly = ro;
        document.getElementById('<%= txtCashGross.ClientID %>').readOnly = ro;
    }
    function bankLock() {
        var locked = document.getElementById('hfLock').value === '1';
        var yes = hfVal('bank') === 'Yes';
        setFieldDisabled('bankname', locked || !yes);
        document.getElementById('<%= txtAcNo.ClientID %>').readOnly = locked || !yes;
    }
    function applyLock() {
        if (document.getElementById('hfLock').value !== '1') return;
        FIELDS.forEach(function (f) { setFieldDisabled(f.id, true); });
    }

    window.onFieldChange = function (id) {
        if (id === 'paytype') payTypeLock();
        if (id === 'bank') bankLock();
    };

    function validateForm() {
        if (!document.getElementById('<%= txtEmpId.ClientID %>').value.trim()) { showNotification('Please enter ID No.'); return false; }
        if (!document.getElementById('<%= txtName.ClientID %>').value.trim()) { showNotification('Please check Name (English).'); return false; }
        if (!document.getElementById('<%= txtBanglaName.ClientID %>').value.trim()) { showNotification('Please check Bangla Name.'); return false; }
        return true;
    }

    // ---- Previous / Next Page ----
    function showTab(target) {
        var t = document.querySelector('[data-bs-target="' + target + '"]');
        if (t) bootstrap.Tab.getOrCreateInstance(t).show();
    }
    document.querySelectorAll('[data-goto]').forEach(function (b) {
        b.addEventListener('click', function () { showTab(this.getAttribute('data-goto')); });
    });
    // Increment History বাটন (server '#p4' সেট করে)
    function checkHash() { if (location.hash === '#p4') showTab('#tab3'); }
    window.addEventListener('hashchange', checkHash);

    // JS এ ত্রুটি হলে পেজেই দেখাবে
    window.addEventListener('error', function (ev) {
        var b = document.getElementById('errBox'); b.classList.remove('d-none');
        b.textContent = 'JS error: ' + ev.message + ' (line ' + ev.lineno + ')';
    });

    document.addEventListener('DOMContentLoaded', function () {
        buildFilters();
        document.getElementById('<%= txtBankGross.ClientID %>').addEventListener('input', calcCash);
        document.getElementById('<%= txtGross.ClientID %>').addEventListener('input', calcCash);
        payTypeLock(); bankLock(); applyLock();
        checkHash();
    });
</script>
</body>
</html>
