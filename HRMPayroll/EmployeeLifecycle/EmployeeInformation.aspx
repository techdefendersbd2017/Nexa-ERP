<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeInformation.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.EmployeeInformation" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Personal Information Update</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />

    <!-- Bootstrap Icons (added to match CreateCategory header style) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />

    <!-- Google Font (added to match CreateCategory header style) -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />

    <!-- Select2 (searchable dropdown) -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" />

    <style>
        :root {
            --brand-primary: #2e5bd7;
            --brand-primary-dark: #234699;
            --text-muted: #6b7280;
        }

        /* ছবির সাথে মিল রেখে কালার আপডেট */
        body { background-color: #f0f2f5; font-family: 'Inter', 'Segoe UI', Arial, sans-serif; font-size: 12px; }

        .main-wrapper { 
            max-width: 1150px; 
            margin: 10px auto; 
            background: #fff; 
            border: 1px solid #ccc; 
            box-shadow: 0 0 10px rgba(0,0,0,0.1); 
            padding: 0; /* হেডার ফুল উইডথ করার জন্য */
            border-radius: 5px;
            overflow: hidden;
        }

        /* CreateCategory পেজের মত পেজ হেডিং (আইকন + টাইটেল + ব্রেডক্রাম্ব) */
        .page-heading {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 20px;
            border-bottom: 1px solid #e6e9ef;
        }

        .page-heading i {
            font-size: 1.6rem;
            color: var(--brand-primary);
        }

        .page-heading h3 {
            margin: 0;
            font-weight: 700;
            font-size: 1.25rem;
            color: #111827;
        }

        .page-heading small {
            display: block;
            color: var(--text-muted);
            font-weight: 400;
            font-size: 0.78rem;
        }

        .content-area { padding: 15px; }

        .fixed-top-section { border-bottom: 1px solid #eee; margin-bottom: 10px; padding-bottom: 10px; }

        /* Joining Date / Probation Period / Employee Status / Separation Date
           box (top-right of the fixed section). Grid guarantees the label
           column and the input column line up on the same x-position on
           every row, regardless of how long each label's text is. */
        .employee-meta-grid {
            display: grid;
            grid-template-columns: auto 150px;
            column-gap: 12px;
            row-gap: 8px;
            align-items: center;
        }
        .employee-meta-grid label {
            text-align: left;
            white-space: nowrap;
        }
        .employee-meta-grid .form-control-sm,
        .employee-meta-grid .form-select-sm {
            width: 100%;
        }
        
        /* ছবি অনুযায়ী ফটো বক্স ও বাটন */
        .photo-box { width: 120px; height: 140px; border: 1px solid #ccc; background: #f8f9fa; display: flex; align-items: center; justify-content: center; margin-bottom: 5px; overflow: hidden; }
        .photo-btn { background: #eef3ff; border: 1px solid #adc5ff; color: #2e5bd7; font-weight: bold; width: 120px; font-size: 11px; padding: 2px; text-align: center; display: block; }

        /* ট্যাব কালার */
        .nav-tabs .nav-link { background: #f8f9fa; border: 1px solid #ddd; color: #555; margin-right: 2px; padding: 6px 12px; }
        .nav-tabs .nav-link.active { background: #2e5bd7 !important; color: #fff !important; border-bottom: none; font-weight: bold; }
        
        .tab-content { background: #fff; border: 1px solid #ddd; border-top: none; padding: 20px; min-height: 0; }
        .tab-pane { min-height: 260px; }
        
        .form-row-custom { display: flex; align-items: center; margin-bottom: 6px; }
        .form-row-custom label { width: 130px; min-width: 130px; margin-bottom: 0; font-weight: 500; color: #333; }
        .form-control-sm, .form-select-sm { border-radius: 4px; border: 1px solid #ced4da; font-size: 12px; height: 28px; }
        
        .section-title { font-weight: bold; background: #f0f4ff; color: #2e5bd7; padding: 4px 10px; display: block; margin-bottom: 10px; border-left: 4px solid #2e5bd7; }

        /* EmployeeEntryInformation পেজের মত সেকশন বক্স - Office Information ট্যাবের জন্য */
        .section-box {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 14px;
            background: #fafbfc;
            height: 100%;
        }

        .section-box .form-row-custom:last-child { margin-bottom: 0; }

        /* =========================================================
           TAB PAGE NAVIGATION (Previous Page / Next Page)
           প্রতিটি ট্যাবের নিচে বাম পাশে Previous এবং ডান পাশে Next বাটন
        ========================================================= */
        .tab-nav-btns {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 18px;
            padding-top: 12px;
            border-top: 1px dashed #e0e4eb;
        }

        .tab-nav-btns .btn-nav {
            background-color: #eef3ff;
            border: 1px solid #2e5bd7;
            color: #2e5bd7;
            font-weight: bold;
            font-size: 12px;
            border-radius: 5px;
            padding: 6px 16px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .tab-nav-btns .btn-nav:hover {
            background-color: #2e5bd7;
            color: #fff;
        }

        .tab-nav-btns .btn-nav-spacer {
            visibility: hidden;
        }
        
        /* ছবির মত ফুটার বাটন স্টাইল - এখন ফিক্সড সেকশনে থাকবে */
        .footer-btns {
            position: sticky;
            bottom: 0;
            left: 0;
            right: 0;
            margin-top: 15px;
            text-align: center;
            background: #fff;
            border-top: 1px solid #eee;
            padding-top: 15px;
            padding-bottom: 15px;
            z-index: 20;
            box-shadow: 0 -4px 10px rgba(0,0,0,0.05);
        }
        .footer-btns .btn { 
            min-width: 140px; 
            border-radius: 5px; 
            margin: 0 5px; 
            font-size: 12px; 
            font-weight: bold;
            background-color: #eef3ff;
            border: 1px solid #2e5bd7;
            color: #2e5bd7;
        }
        .footer-btns .btn:hover { background-color: #2e5bd7; color: #fff; }

        .btn-search-dark { background-color: #f8f9fa; border: 1px solid #ccc; color: #333; }

        /* =========================================================
           SEARCHABLE DROPDOWN (Select2) — styled to match the reference image:
           rounded input box, chevron icon, rounded search panel with
           a magnifying-glass icon inside a pill-shaped search field.
        ========================================================= */

        /* Closed box (the "Select department" bar) */
        .select2-container--default .select2-selection--single {
            height: 30px;
            border: 1px solid #ced4da;
            border-radius: 8px;
            background-color: #fff;
            display: flex;
            align-items: center;
            padding: 0;
            transition: border-color .15s ease, box-shadow .15s ease;
        }

        .select2-container--default.select2-container--focus .select2-selection--single,
        .select2-container--default.select2-container--open .select2-selection--single {
            border-color: var(--brand-primary);
            box-shadow: 0 0 0 3px rgba(46, 91, 215, 0.12);
        }

        .select2-container--default .select2-selection--single .select2-selection__rendered {
            line-height: 28px;
            padding-left: 12px;
            padding-right: 30px;
            font-size: 12px;
            color: #222;
        }

        .select2-container--default .select2-selection--single .select2-selection__placeholder {
            color: #8a93a3;
        }

        /* Chevron (up/down) icon like the screenshot */
        .select2-container--default .select2-selection--single .select2-selection__arrow {
            height: 28px;
            width: 26px;
            right: 4px;
        }

        .select2-container--default .select2-selection--single .select2-selection__arrow b {
            display: none;
        }

        .select2-container--default .select2-selection--single .select2-selection__arrow::before {
            font-family: "bootstrap-icons";
            content: "\F2F4"; /* bi-chevron-expand */
            font-size: 12px;
            color: #8a93a3;
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
        }

        /* Dropdown result panel */
        .select2-container--default .select2-dropdown {
            border: 1px solid #e2e6ee;
            border-radius: 12px;
            box-shadow: 0 10px 28px rgba(17, 24, 39, 0.12);
            overflow: hidden;
            padding-top: 8px;
            font-size: 12.5px;
        }

        .select2-dropdown--below { margin-top: 4px; }
        .select2-dropdown--above { margin-top: -4px; }

        /* Search box with magnifying-glass icon, pill shaped */
        .select2-container--default .select2-search--dropdown {
            padding: 4px 10px 10px 10px;
            position: relative;
        }

        .select2-container--default .select2-search--dropdown::before {
            font-family: "bootstrap-icons";
            content: "\F52A"; /* bi-search */
            position: absolute;
            left: 22px;
            top: 50%;
            transform: translateY(-45%);
            color: #9aa2b1;
            font-size: 13px;
            pointer-events: none;
        }

        .select2-container--default .select2-search--dropdown .select2-search__field {
            border: 1px solid #e2e6ee;
            border-radius: 20px;
            padding: 6px 12px 6px 32px;
            font-size: 12.5px;
            outline: none;
            background: #f8f9fb;
        }

        .select2-container--default .select2-search--dropdown .select2-search__field:focus {
            border-color: var(--brand-primary);
            background: #fff;
        }

        /* Results list */
        .select2-container--default .select2-results__options {
            max-height: 260px;
        }

        .select2-container--default .select2-results__option {
            padding: 8px 16px;
            color: #333;
        }

        .select2-container--default .select2-results__option--highlighted[aria-selected] {
            background-color: #f1f4fb;
            color: var(--brand-primary-dark);
        }

        .select2-container--default .select2-results__option[aria-selected="true"] {
            background-color: #eef3ff;
            color: var(--brand-primary-dark);
            font-weight: 600;
        }

        .select2-results__option:empty { display: none; }

        /* Match the compact row height used across the form */
        .select2-container { width: 100% !important; }
        .form-row-custom .select2-container,
        .col-md-6 .select2-container,
        .col-md-12 .select2-container { flex: 1 1 auto; }
    </style>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div class="main-wrapper">
            <!-- CreateCategory পেজের স্টাইলে পেজ হেডিং -->
            <div class="page-heading">
                <i class="bi bi-person-lines-fill"></i>
                <div>
                    <h3>Personal Information Update</h3>
                    <small>HRM Payroll &rsaquo; Employee Lifecycle &rsaquo; Personal Information Update</small>
                </div>
            </div>

            <div class="content-area">
                <!-- 1. FIXED TOP SECTION -->
                <div class="fixed-top-section">
                    <div class="row g-2">
                        <div class="col-md-6">
                            <div class="form-row-custom">
                                <label>Employee ID</label>
                                <div class="input-group input-group-sm" style="width: 250px;">
                                    <asp:TextBox ID="txtEmpID" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-search-dark" OnClick="btnSearch_Click" />
                                </div>
                            </div>
                            <div class="form-row-custom">
                                <label>Name</label>
                                <asp:TextBox ID="txtName" runat="server" CssClass="form-control form-control-sm"></asp:TextBox>
                            </div>
                            <div class="form-row-custom">
                                <label>Bangla Name</label>
                                <asp:TextBox ID="txtBanglaName" runat="server" CssClass="form-control form-control-sm"></asp:TextBox>
                            </div>
                            <div class="mt-1"><span class="text-primary fw-bold">User Name: Monzil</span></div>
                        </div>
                        <div class="col-md-6">
                            <div class="d-flex justify-content-end align-items-start">
                                <div class="employee-meta-grid small pt-1 me-3">
                                    <label class="mb-0">Joining Date</label>
                                    <asp:TextBox ID="txtJoiningDate" runat="server" AutoPostBack="true" TextMode="Date" CssClass="form-control form-control-sm" OnTextChanged="txtJoiningDate_TextChanged"></asp:TextBox>

                                    <label class="mb-0">Probation Period</label>
                                    <asp:TextBox ID="txtProbationPeriod" runat="server" TextMode="Date" CssClass="form-control form-control-sm"></asp:TextBox>

                                    <label class="mb-0">Employee Status</label>
                                    <asp:DropDownList ID="ddlEmployeeStatus" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Text="Active" Value="Active" />
                                        <asp:ListItem Text="Inactive" Value="Inactive" />
                                    </asp:DropDownList>

                                    <label class="mb-0">Separation Date</label>
                                    <asp:TextBox ID="txtSeparationDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" ReadOnly="True"></asp:TextBox>
                                </div>
                                <div>
                                    <label for="<%= FileUpload1.ClientID %>" style="cursor:pointer; display:block;">
                                        <div class="photo-box text-muted" id="photoPreviewBox">
                                            <img id="imgPhotoPreview" runat="server" src="#" alt="Photo preview" style="max-width:100%; max-height:100%; object-fit:cover; display:none;" />
                                            <span id="photoPlaceholderText" runat="server">Photo</span>
                                        </div>
                                    </label>
                                    <asp:FileUpload ID="FileUpload1" runat="server" CssClass="d-none" onchange="previewEmployeePhoto(this)" accept="image/*" />
                                    <label for="<%= FileUpload1.ClientID %>" class="photo-btn" style="cursor:pointer;">Choose Photo</label>
                                    <div class="text-muted" style="font-size:10px; text-align:center; margin-top:2px;">সর্বোচ্চ 300KB</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- FOOTER BUTTONS (ফিক্সড সেকশন - সবসময় দৃশ্যমান থাকবে) -->
                    <div class="footer-btns">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn" />
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn" OnClick="btnSave_Click" />
                        <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn" />
                        <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="btn" />
                    </div>
                </div>

                <!-- 2. TAB NAVIGATION -->
                <ul class="nav nav-tabs" id="hrTabs" role="tablist">
                    <li class="nav-item"><button type="button" class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab1">Office Information</button></li>
                    <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab2">Salary and Bank Information</button></li>
                    <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab3">Personal Information</button></li>
                    <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab4">Address Information</button></li>
                    <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab5">Nominee Information</button></li>
                    <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab6">Job Experience</button></li>
                    <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab7">Reference</button></li>
                </ul>

                <!-- 3. TAB CONTENT -->
                <div class="tab-content">
                    <!-- 8. OFFICE INFORMATION (নতুন ট্যাব - EmployeeEntryInformation পেজ থেকে মিসিং এলিমেন্টগুলো এখানে যুক্ত করা হয়েছে) -->
                    <div class="tab-pane fade show active" id="tab1">
                        <div class="row g-3">

                            <!-- বাম বক্স: জব / ওয়ার্ক অ্যাসাইনমেন্ট সংক্রান্ত তথ্য -->
                            <div class="col-12">
                                <div class="section-box">
                                    <span class="section-title">Job &amp; Work Assignment</span>
                                    <div class="row g-2">
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Branch</label>
                                                <asp:DropDownList ID="ddlBranch" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Department</label>
                                                <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Section</label>
                                                <asp:DropDownList ID="ddlSection" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Line</label>
                                                <asp:DropDownList ID="ddlLine" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Designation</label>
                                                <asp:DropDownList ID="ddlDesignation" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Category</label>
                                                <asp:DropDownList ID="ddlCategory" runat="server" AutoPostBack="true" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Shift</label>
                                                <asp:DropDownList ID="ddlShift" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Floor</label>
                                                <asp:DropDownList ID="ddlFloor" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Weekly Holiday</label>
                                                <asp:DropDownList ID="ddlWeekoff" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>


                        </div>

                        <!-- নিচের অ্যাকশন বার: Increment History + Is Active (EmployeeEntryInformation পেজ থেকে) -->
                        <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mt-3 pt-3 border-top">
                            <asp:Button ID="btnIncrementHistory" runat="server" Text="Increment History" CssClass="btn btn-sm" Style="background:#eef3ff;border:1px solid #2e5bd7;color:#2e5bd7;font-weight:bold;" />
                            <div class="form-check mb-0">
                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                                <asp:Label runat="server" AssociatedControlID="chkIsActive" Text="Is Active?" CssClass="form-check-label fw-bold" />
                            </div>
                        </div>

                        <!-- Page Navigation -->
                        <div class="tab-nav-btns">
                            <span class="btn-nav btn-nav-spacer"><i class="bi bi-chevron-left"></i> Previous Page</span>
                            <button type="button" class="btn-nav" data-goto="#tab2">Next Page <i class="bi bi-chevron-right"></i></button>
                        </div>
                    </div>

                    <!-- 8. OFFICE INFORMATION (নতুন ট্যাব - EmployeeEntryInformation পেজ থেকে মিসিং এলিমেন্টগুলো এখানে যুক্ত করা হয়েছে) -->
                    <div class="tab-pane fade" id="tab2">
                        <!-- Salary & Bank Information -->
                        <div class="col-12">
                            <div class="section-box">
                                <span class="section-title">Salary &amp; Bank Information</span>

                                <div class="row">

                                    <!-- Left Side -->
                                    <div class="col-md-6">

                                        <div class="form-row-custom">
                                            <label>Gross Salary</label>
                                            <asp:TextBox ID="txtGrossSalary" runat="server" TextMode="Number"
                                                CssClass="form-control form-control-sm w-100" />
                                        </div>

                                        <div class="form-row-custom">
                                            <label>Pay Type</label>
                                            <asp:DropDownList ID="ddlPayType" runat="server"
                                                CssClass="form-select form-select-sm w-100">
                                            </asp:DropDownList>
                                        </div>

                                        <div class="form-row-custom">
                                            <label>Taxable Gross Salary</label>
                                            <asp:TextBox ID="txtTaxableGrossSalary" runat="server" TextMode="Number"
                                                CssClass="form-control form-control-sm w-100" />
                                        </div>

                                        <div class="form-row-custom">
                                            <label>Non-Taxable Gross Salary</label>
                                            <asp:TextBox ID="txtNonTaxableGrossSalary" runat="server" TextMode="Number"
                                                CssClass="form-control form-control-sm w-100" />
                                        </div>

                                        <div class="form-row-custom">
                                            <label>Tax Holder</label>
                                            <asp:DropDownList ID="ddlTaxHolder" runat="server"
                                                CssClass="form-select form-select-sm w-100">
                                                <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                                                <asp:ListItem Text="Yes" Value="1"></asp:ListItem>
                                                <asp:ListItem Text="No" Value="2"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>

                                        <div class="form-row-custom">
                                            <label>Amount</label>
                                            <asp:TextBox ID="txtTaxAmount" runat="server" TextMode="Number"
                                                CssClass="form-control form-control-sm w-100" />
                                        </div>

                                    </div>

                                    <!-- Right Side -->
                                    <div class="col-md-6">

                                        <div class="form-row-custom">
                                            <label>Bank Holder</label>
                                            <asp:DropDownList ID="ddlBankHolder" runat="server"
                                                CssClass="form-select form-select-sm w-100">
                                                <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                                                <asp:ListItem Text="Yes" Value="1"></asp:ListItem>
                                                <asp:ListItem Text="No" Value="2"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>

                                        <div class="form-row-custom">
                                            <label>Bank Name</label>
                                            <asp:DropDownList ID="ddlBank" runat="server"
                                                CssClass="form-select form-select-sm w-100">
                                                <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                                            </asp:DropDownList>
                                        </div>

                                        <div class="form-row-custom">
                                            <label>Account Number</label>
                                            <asp:TextBox ID="txtAccountNumber" runat="server"
                                                CssClass="form-control form-control-sm w-100" />
                                        </div>

                                        <div class="form-row-custom">
                                            <label>Routing No</label>
                                            <asp:TextBox ID="txtRoutingNo" runat="server"
                                                CssClass="form-control form-control-sm w-100" />
                                        </div>

                                    </div>

                                </div>
                            </div>
                        </div>

                        <!-- Page Navigation -->
                        <div class="tab-nav-btns">
                            <button type="button" class="btn-nav" data-goto="#tab1"><i class="bi bi-chevron-left"></i> Previous Page</button>
                            <button type="button" class="btn-nav" data-goto="#tab3">Next Page <i class="bi bi-chevron-right"></i></button>
                        </div>
                    </div>                    
                    <div class="tab-pane fade" id="tab3">
                        <div class="row">
                            <div class="col-md-6 border-end pe-4">
                                <div class="form-row-custom"><label>Father English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Mother English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Husband English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Wife English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>NID</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Date Of Birth</label>
                                    <asp:TextBox runat="server" CssClass="form-control form-control-sm" Placeholder="DD-MM-YYYY" />
                                </div>
                                <div class="form-row-custom"><label>Religion</label><asp:DropDownList ID="ddlReligion" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>Gender</label><asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>Blood Group</label>
                                    <asp:DropDownList ID="ddlBloodGroup" runat="server" CssClass="form-select form-select-sm w-100">
                                        <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                                        <asp:ListItem Text="A+" Value="1"></asp:ListItem>
                                        <asp:ListItem Text="A-" Value="2"></asp:ListItem>
                                        <asp:ListItem Text="B+" Value="3"></asp:ListItem>
                                        <asp:ListItem Text="B-" Value="4"></asp:ListItem>
                                        <asp:ListItem Text="AB+" Value="5"></asp:ListItem>
                                        <asp:ListItem Text="AB-" Value="6"></asp:ListItem>
                                        <asp:ListItem Text="O+" Value="7"></asp:ListItem>
                                        <asp:ListItem Text="O-" Value="8"></asp:ListItem>
                                    </asp:DropDownList>

                                </div>
                                <div class="form-row-custom"><label>Personal Phone</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Education</label><asp:DropDownList ID="ddlEducation" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                            </div>
                            <div class="col-md-6 ps-4">
                                <div class="form-row-custom"><label>Father (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Mother (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Husband (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Wife (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>BID</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Marital Status</label><asp:DropDownList ID="ddlMaritalStatus" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>No of Child</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Height</label>
                                    <asp:TextBox runat="server" Width="50px" CssClass="form-control-sm me-1" /> ft 
                                    <asp:TextBox runat="server" Width="50px" CssClass="form-control-sm mx-1" /> inc
                                    <label style="width:70px; min-width:70px;" class="ms-2">Weight KG</label><asp:TextBox runat="server" Width="60px" CssClass="form-control-sm" />
                                </div>
                                <div class="form-row-custom"><label>TIN</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Home Phone</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>E-mail</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                            </div>
                        </div>

                        <!-- Page Navigation -->
                        <div class="tab-nav-btns">
                            <button type="button" class="btn-nav" data-goto="#tab2"><i class="bi bi-chevron-left"></i> Previous Page</button>
                            <button type="button" class="btn-nav" data-goto="#tab4">Next Page <i class="bi bi-chevron-right"></i></button>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="tab4">
                        <asp:UpdatePanel ID="upAddressInfo" runat="server">
                        <ContentTemplate>
                        <div class="row">
                            <div class="col-md-6 border-end">
                                <span class="section-title">Permanent Address</span>
                                <div class="form-row-custom"><label>District</label>
                                    <asp:DropDownList ID="ddlPermanentDistrict" runat="server" CssClass="form-select-sm w-100"></asp:DropDownList></div>
                                <div class="form-row-custom">
                                    <label>Police Station</label>
                                    <asp:DropDownList ID="ddlPermanentPoliceStation" runat="server" CssClass="form-select-sm w-100"></asp:DropDownList>
                                </div>
                                <div class="form-row-custom">
                                    <label>Post Office</label>
                                    <asp:TextBox runat="server" ID="txtPermanentPostOfficeEnglish" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                    <asp:TextBox runat="server" ID="txtPermanentPostOfficeBangla" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                </div>                                
                                <div class="form-row-custom">
                                    <label>Village</label>
                                    <asp:TextBox runat="server" ID="txtPermanentVillageEnglish" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                    <asp:TextBox runat="server" ID="txtPermanentVillageBangla" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                </div>                                
                            </div>
                            <div class="col-md-6">
                                <div class="form-check mb-4">
                                    <asp:CheckBox ID="chkSame" class="form-select-sm w-100" AutoPostBack="true" Text=".   If present or permanent address same click here." runat="server" OnCheckedChanged="chkSame_CheckedChanged" />
                                </div>
                                <span class="section-title ms-4">Present Address</span>
                                <div class="ms-4">
                                    <div class="form-row-custom">
                                        <label>District</label>
                                        <asp:DropDownList runat="server" ID="ddlPresentDistrict" CssClass="form-select-sm w-100"></asp:DropDownList>
                                    </div>
                                    <div class="form-row-custom">
                                        <label>Police Station</label>
                                        <asp:DropDownList runat="server" ID="ddlPresentPoliceStation"  CssClass="form-select-sm w-100"></asp:DropDownList>
                                    </div>
                                    <div class="form-row-custom">
                                        <label>Post Office</label>
                                        <asp:TextBox runat="server" ID="txtPresentPostOfficeEnglish" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                        <asp:TextBox runat="server" ID="txtPresentPostOfficeBangla" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                    </div>
                                    <div class="form-row-custom">
                                        <label>Village</label>
                                        <asp:TextBox runat="server" ID="txtPresentVillageEnglish" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                        <asp:TextBox runat="server" ID="txtPresentVillageBangla" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                    </div>
                                    <div class="form-row-custom">
                                        <label>House Holder</label>
                                        <asp:TextBox runat="server" CssClass="form-control form-control-sm w-100"></asp:TextBox>
                                    </div>
                                    <div class="form-row-custom">
                                        <label>Phone</label>
                                        <asp:TextBox runat="server" CssClass="form-control form-control-sm w-100"></asp:TextBox>
                                    </div>
                                </div>
                            </div>
                        </div>
                        </ContentTemplate>
                        </asp:UpdatePanel>

                        <!-- Page Navigation -->
                        <div class="tab-nav-btns">
                            <button type="button" class="btn-nav" data-goto="#tab3"><i class="bi bi-chevron-left"></i> Previous Page</button>
                            <button type="button" class="btn-nav" data-goto="#tab5">Next Page <i class="bi bi-chevron-right"></i></button>
                        </div>
                    </div>
                    

                    <div class="tab-pane fade" id="tab5">
                        <div class="row">
                            <div class="col-md-6 border-end">
                                <div class="form-row-custom"><label>Relation</label><asp:DropDownList ID="ddlNomineeRelation" runat="server" CssClass="form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>Nominee's Name</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>NID</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>BID</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                            </div>
                            <div class="col-md-6 ps-4">
                                <div class="form-row-custom"><label>Nominee Name(Ban)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Date Of Birth</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" Width="150px" /></div>
                                <div class="form-row-custom"><label>Phone No</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                            </div>
                        </div>
                        <div class="col-md-6">
                        <asp:UpdatePanel ID="upNomineeInfo" runat="server">
                        <ContentTemplate>
                            <div class="form-check mb-4">
                                <asp:CheckBox ID="CheckNominee" class="form-select-sm w-100" AutoPostBack="true" Text=".    If Employee & Nominee Address Same." runat="server" OnCheckedChanged="CheckNominee_CheckedChanged"/>
                            </div>
                            <span class="section-title ms-4">Nominee Address</span>
                            <div class="ms-4">
                                <div class="form-row-custom">
                                    <label>District</label>
                                    <asp:DropDownList runat="server" ID="ddlNomineeDistrict" CssClass="form-select-sm w-100"></asp:DropDownList>
                                </div>
                                <div class="form-row-custom">
                                    <label>Police Station</label>
                                    <asp:DropDownList runat="server" ID="ddlNomineePoliceStation"  CssClass="form-select-sm w-100"></asp:DropDownList>
                                </div>
                                <div class="form-row-custom">
                                    <label>Post Office</label>
                                    <asp:TextBox runat="server" ID="txtNomineePostOfficeEnglish" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                    <asp:TextBox runat="server" ID="txtNomineePostOfficeBangla" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                </div>
                                <div class="form-row-custom">
                                    <label>Village</label>
                                    <asp:TextBox runat="server" ID="txtNomineeVillageEnglish" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                    <asp:TextBox runat="server" ID="txtNomineeVillageBangla" CssClass="form-control form-control-sm w-50"></asp:TextBox>
                                </div>
                            </div>
                        </ContentTemplate>
                        </asp:UpdatePanel>
                        </div>

                        <!-- Page Navigation -->
                        <div class="tab-nav-btns">
                            <button type="button" class="btn-nav" data-goto="#tab4"><i class="bi bi-chevron-left"></i> Previous Page</button>
                            <button type="button" class="btn-nav" data-goto="#tab6">Next Page <i class="bi bi-chevron-right"></i></button>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab6">
                        <div class="row">
                            <div class="col-md-7 border-end">
                                <div class="form-row-custom"><label>Factory Name</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="form-row-custom"><label>Address</label><asp:TextBox runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control form-control-sm w-100" /></div>
                            </div>
                            <div class="col-md-5 ps-4">
                                <div class="form-row-custom"><label>Total Experience</label><asp:TextBox Width="40px" runat="server" /> Year <asp:TextBox Width="40px" runat="server" CssClass="ms-2" /> Month</div>
                                <div class="form-check mb-2"><input type="checkbox" /> If you use Experience From & Till Date</div>
                                <div class="form-row-custom"><label>From Date</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" Width="150px" /></div>
                                <div class="form-row-custom"><label>Till Date</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" Width="150px" /></div>
                            </div>
                        </div>

                        <!-- Page Navigation -->
                        <div class="tab-nav-btns">
                            <button type="button" class="btn-nav" data-goto="#tab5"><i class="bi bi-chevron-left"></i> Previous Page</button>
                            <button type="button" class="btn-nav" data-goto="#tab7">Next Page <i class="bi bi-chevron-right"></i></button>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab7">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-row-custom">
                                    <label>Ref. Employee ID</label>
                                    <div class="input-group input-group-sm">
                                        <asp:TextBox runat="server" CssClass="form-control" />
                                        <asp:Button runat="server" Text="Search" CssClass="btn btn-search-dark" />
                                    </div>
                                </div>
                                <div class="form-row-custom"><label>Name</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Designation</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Company</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Email</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Phone</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                            </div>
                        </div>

                        <!-- Page Navigation -->
                        <div class="tab-nav-btns">
                            <button type="button" class="btn-nav" data-goto="#tab6"><i class="bi bi-chevron-left"></i> Previous Page</button>
                            <span class="btn-nav btn-nav-spacer">Next Page <i class="bi bi-chevron-right"></i></span>
                        </div>
                    </div>

                    
                </div>
            </div>
        </div>
    </form>

    <!-- jQuery (Select2 dependency) -->
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Select2 (searchable dropdown) -->
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

    <script>
        // সর্বোচ্চ ছবির সাইজ: 300KB
        var MAX_PHOTO_SIZE_BYTES = 300 * 1024;

        // ছবি সিলেক্ট করার সাথে সাথে photo-box-এ প্রিভিউ দেখানো হয়
        function previewEmployeePhoto(input) {
            var img = document.getElementById('imgPhotoPreview');
            var placeholder = document.getElementById('photoPlaceholderText');

            if (input.files && input.files[0]) {
                var file = input.files[0];

                if (file.size > MAX_PHOTO_SIZE_BYTES) {
                    alert('ছবির সাইজ 300KB-এর বেশি হতে পারবে না। আপনার ফাইলের সাইজ: ' + (file.size / 1024).toFixed(1) + 'KB');
                    input.value = ''; // সিলেকশন বাতিল
                    img.removeAttribute('src');
                    img.style.display = 'none';
                    placeholder.style.display = 'block';
                    return;
                }

                var reader = new FileReader();
                reader.onload = function (e) {
                    img.src = e.target.result;
                    img.style.display = 'block';
                    placeholder.style.display = 'none';
                };
                reader.readAsDataURL(file);
            } else {
                img.removeAttribute('src');
                img.style.display = 'none';
                placeholder.style.display = 'block';
            }
        }

        document.addEventListener("DOMContentLoaded", function () {
            var defaultTab = '#tab1';
            var selectedTab = localStorage.getItem('activeTab') || defaultTab;
            var tabEl = document.querySelector(`button[data-bs-target="${selectedTab}"]`);
            if (tabEl) new bootstrap.Tab(tabEl).show();

            var tabLinks = document.querySelectorAll('.nav-link');
            tabLinks.forEach(function (tab) {
                tab.addEventListener('shown.bs.tab', function (e) {
                    localStorage.setItem('activeTab', e.target.getAttribute('data-bs-target'));
                });
            });

            document.querySelectorAll('.tab-nav-btns [data-goto]').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    var targetSelector = btn.getAttribute('data-goto');
                    var targetTabBtn = document.querySelector('button[data-bs-target="' + targetSelector + '"]');
                    if (targetTabBtn) {
                        new bootstrap.Tab(targetTabBtn).show();
                        var contentArea = document.querySelector('.content-area');
                        if (contentArea) {
                            contentArea.scrollIntoView({ behavior: 'smooth', block: 'start' });
                        }
                    }
                });
            });
        });

        $(function () {
            function humanize(name) {
                // Convert "ddlDepartment" -> "Department", "ddlSkillGrade" -> "Skill Grade"
                var base = (name || 'Option').replace(/^ddl/i, '');
                base = base.replace(/([a-z0-9])([A-Z])/g, '$1 $2').trim();
                return base || 'Option';
            }
            function initSelect2($el) {
                var label = $el.closest('.form-row-custom').find('label').first().text().trim();
                var placeholderText = 'Select ' + (label || humanize($el.attr('id')));
                var hasEmptyOption = $el.find('option[value=""]').length > 0;
                var $pane = $el.closest('.tab-pane');

                var options = {
                    width: '100%',
                    dropdownParent: $pane.length ? $pane : $(document.body),
                    minimumResultsForSearch: 0 // always show the search box, like the reference image
                };

                if (hasEmptyOption) {
                    options.placeholder = placeholderText;
                    options.allowClear = false;
                }

                $el.select2(options);
            }

            $('select').each(function () {
                initSelect2($(this));
            });

            // Bootstrap tabs hide inactive panes with display:none, so Select2
            // (which measures width on init) can render 0-width the first time
            // a tab is opened. Force a re-calc when a tab becomes visible.
            $('button[data-bs-toggle="tab"]').on('shown.bs.tab', function (e) {
                var target = $(e.target).attr('data-bs-target');
                $(target).find('select').each(function () {
                    if ($(this).hasClass('select2-hidden-accessible')) {
                        $(this).select2('destroy');
                    }
                });
                $(target).find('select').each(function () {
                    initSelect2($(this));
                });
            });

            // =====================================================
            // chkSame / CheckNominee live inside <asp:UpdatePanel>s,
            // so toggling them causes an ASYNC (AJAX) postback that
            // replaces only that panel's HTML — the page itself never
            // reloads, so the active tab no longer resets. But the
            // replaced <select> elements need Select2 re-initialized,
            // since the plain DOM Select2 built earlier is discarded
            // along with the old markup.
            // =====================================================
            if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function (sender, args) {
                    var panel = args.get_panelsUpdated && args.get_panelsUpdated()[0];
                    var $scope = panel ? $(panel) : $(document);
                    $scope.find('select').each(function () {
                        if ($(this).hasClass('select2-hidden-accessible')) {
                            $(this).select2('destroy');
                        }
                        initSelect2($(this));
                    });
                });
            }
        });
    </script>
</body>
</html>
