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
        
        /* ছবি অনুযায়ী ফটো বক্স ও বাটন */
        .photo-box { width: 120px; height: 140px; border: 1px solid #ccc; background: #f8f9fa; display: flex; align-items: center; justify-content: center; margin-bottom: 5px; }
        .photo-btn { background: #eef3ff; border: 1px solid #adc5ff; color: #2e5bd7; font-weight: bold; width: 120px; font-size: 11px; padding: 2px; text-align: center; display: block; }

        /* ট্যাব কালার */
        .nav-tabs .nav-link { background: #f8f9fa; border: 1px solid #ddd; color: #555; margin-right: 2px; padding: 6px 12px; }
        .nav-tabs .nav-link.active { background: #2e5bd7 !important; color: #fff !important; border-bottom: none; font-weight: bold; }
        
        .tab-content { background: #fff; border: 1px solid #ddd; border-top: none; padding: 20px; min-height: 480px; }
        
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
        
        /* ছবির মত ফুটার বাটন স্টাইল */
        .footer-btns { margin-top: 15px; text-align: center; border-top: 1px solid #eee; padding-top: 15px; padding-bottom: 15px; }
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
    <form id="form1" runat="server">
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
                        <div class="col-md-8">
                            <div class="form-row-custom">
                                <label>Employee ID</label>
                                <div class="input-group input-group-sm" style="width: 250px;">
                                    <asp:TextBox ID="txtEmpID" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-search-dark" />
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
                        <div class="col-md-4">
                            <div class="d-flex justify-content-end align-items-start">
                                <div class="text-end small me-3 pt-1" style="min-width: 210px;">
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <label class="mb-0 me-2">Joining Date</label>
                                        <asp:TextBox ID="txtJoiningDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" Width="130px"></asp:TextBox>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <label class="mb-0 me-2">Probation Period</label>
                                        <asp:TextBox ID="txtProbationPeriod" runat="server" TextMode="Date" CssClass="form-control form-control-sm" Width="130px"></asp:TextBox>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <label class="mb-0 me-2">Employee Status</label>
                                        <asp:DropDownList ID="ddlEmployeeStatus" runat="server" CssClass="form-select form-select-sm" Width="130px">
                                            <asp:ListItem Text="Active" Value="Active" />
                                            <asp:ListItem Text="Inactive" Value="Inactive" />
                                        </asp:DropDownList>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <label class="mb-0 me-2">Separation Date</label>
                                        <asp:TextBox ID="txtSeparationDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" Width="130px"></asp:TextBox>
                                    </div>
                                </div>
                                <div>
                                    <div class="photo-box text-muted">Photo</div>
                                    <span class="photo-btn">Photo</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 2. TAB NAVIGATION -->
                <ul class="nav nav-tabs" id="hrTabs" role="tablist">
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab8">Office Information</button></li>
                    <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab1">Personal Information</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab2">Address Information</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab3">Nominee Information</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab4">Job Experience</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab5">Reference</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab6">Covid 19 Info</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab7">Training Information</button></li>
                </ul>

                <!-- 3. TAB CONTENT -->
                <div class="tab-content">
                    <!-- 8. OFFICE INFORMATION (নতুন ট্যাব - EmployeeEntryInformation পেজ থেকে মিসিং এলিমেন্টগুলো এখানে যুক্ত করা হয়েছে) -->
                    <div class="tab-pane fade" id="tab8">
                        <div class="row g-3">

                            <!-- বাম বক্স: জব / ওয়ার্ক অ্যাসাইনমেন্ট সংক্রান্ত তথ্য -->
                            <div class="col-12 col-lg-7">
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
                                                <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
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
                                                <label>Machine Name</label>
                                                <asp:DropDownList ID="ddlMachineName" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Skill Grade</label>
                                                <asp:DropDownList ID="ddlSkillGrade" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Weekly Holiday</label>
                                                <asp:DropDownList ID="ddlWeeklyHoliday" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <div class="form-row-custom">
                                                <label>Break Down</label>
                                                <asp:DropDownList ID="ddlBreakDown" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="--" Value=""></asp:ListItem></asp:DropDownList>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- ডান বক্স: স্যালারি ও ব্যাংক তথ্য -->
                            <div class="col-12 col-lg-5">
                                <div class="section-box">
                                    <span class="section-title">Salary &amp; Bank Information</span>

                                    <div class="form-row-custom">
                                        <label>Gross Salary</label>
                                        <asp:TextBox ID="txtGrossSalary" runat="server" TextMode="Number" CssClass="form-control form-control-sm w-100" />
                                    </div>

                                    <div class="form-row-custom">
                                        <label>Pay Type</label>
                                        <asp:DropDownList ID="ddlPayType" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                    </div>

                                    <div class="row g-2 form-row-custom">
                                        <div class="col-6">
                                            <label class="d-block">Cash Gross</label>
                                            <asp:TextBox ID="txtCashGross" runat="server" TextMode="Number" CssClass="form-control form-control-sm w-100" />
                                        </div>
                                        <div class="col-6">
                                            <label class="d-block">Non-Cash Gross</label>
                                            <asp:TextBox ID="txtNonCashGross" runat="server" TextMode="Number" CssClass="form-control form-control-sm w-100" />
                                        </div>
                                    </div>

                                    <div class="row g-2 form-row-custom">
                                        <div class="col-6">
                                            <label class="d-block">Tax Holder</label>
                                            <asp:DropDownList ID="ddlTaxHolder" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                        </div>
                                        <div class="col-6">
                                            <label class="d-block">Amount</label>
                                            <asp:TextBox ID="txtTaxAmount" runat="server" TextMode="Number" CssClass="form-control form-control-sm w-100" />
                                        </div>
                                    </div>

                                    <div class="form-row-custom">
                                        <label>Bank Holder</label>
                                        <asp:DropDownList ID="ddlBankHolder" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                    </div>

                                    <div class="form-row-custom">
                                        <label>Bank Name</label>
                                        <asp:DropDownList ID="ddlBankName" runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value="">--</asp:ListItem></asp:DropDownList>
                                    </div>

                                    <div class="form-row-custom">
                                        <label>A/C No</label>
                                        <asp:TextBox ID="txtAccountNo" runat="server" CssClass="form-control form-control-sm w-100" />
                                    </div>

                                    <!-- বাড়তি সংযোজন: রাউটিং নাম্বার, প্রায়ই ব্যাংক তথ্যের সাথে দরকার হয় -->
                                    <div class="form-row-custom">
                                        <label>Routing No</label>
                                        <asp:TextBox ID="txtRoutingNo" runat="server" CssClass="form-control form-control-sm w-100" />
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
                    </div>
                    <div class="tab-pane fade show active" id="tab1">
                        <div class="row">
                            <div class="col-md-6 border-end pe-4">
                                <div class="form-row-custom"><label>Father English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Mother English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Husband English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Wife English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>NID</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Date Of Birth</label>
                                    <asp:TextBox runat="server" CssClass="form-control form-control-sm me-1" Width="120px" Placeholder="DD-MM-YYYY" />
                                    <asp:DropDownList runat="server" CssClass="form-select form-select-sm" Width="100px"><asp:ListItem Text="Format" Value=""></asp:ListItem></asp:DropDownList>
                                </div>
                                <div class="form-row-custom"><label>Religion</label><asp:DropDownList runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>Gender</label><asp:DropDownList runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>Blood Group</label><asp:DropDownList runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>Personal Phone</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Education</label><asp:DropDownList runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                            </div>
                            <div class="col-md-6 ps-4">
                                <div class="form-row-custom"><label>Father (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Mother (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Husband (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Wife (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>BID</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Marital Status</label><asp:DropDownList runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
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
                    </div>

                    <div class="tab-pane fade" id="tab2">
                        <div class="row">
                            <div class="col-md-6 border-end">
                                <span class="section-title">Permanent Address</span>
                                <div class="form-row-custom"><label>Village</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                <div class="form-row-custom"><label>Post Office</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                <div class="form-row-custom"><label>Police Station</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                <div class="form-row-custom"><label>District</label><asp:DropDownList runat="server" CssClass="form-select-sm w-100"></asp:DropDownList></div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-check mb-2 ms-4">
                                    <input class="form-check-input" type="checkbox" id="chkSame" />
                                    <label class="form-check-label fw-bold">If present or permanent address same click here.</label>
                                </div>
                                <span class="section-title ms-4">Present Address</span>
                                <div class="ms-4">
                                    <div class="form-row-custom"><label>Village</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                    <div class="form-row-custom"><label>Post Office</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                    <div class="form-row-custom"><label>Police Station</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                    <div class="form-row-custom"><label>District</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                    <div class="form-row-custom"><label>House Holder</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100"></asp:TextBox></div>
                                    <div class="form-row-custom"><label>Phone</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100"></asp:TextBox></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab3">
                        <div class="row">
                            <div class="col-md-6 border-end">
                                <div class="form-row-custom"><label>Relation</label><asp:DropDownList runat="server" CssClass="form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
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
                        <div class="form-check my-2"><input type="checkbox" /> If Employee & Nominee Address Same</div>
                        <div class="row mt-2">
                            <div class="col-md-6"><div class="form-row-custom"><label>Village</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div></div>
                            <div class="col-md-6"><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div>
                            <div class="col-md-6"><div class="form-row-custom"><label>District</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div></div>
                            <div class="col-md-6"><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div>
                            <div class="col-md-6"><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100 mt-2" TextMode="MultiLine" Rows="3" /></div>
                            <div class="col-md-6"><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100 mt-2" TextMode="MultiLine" Rows="3" /></div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab4">
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
                    </div>

                    <div class="tab-pane fade" id="tab5">
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
                    </div>

                    <div class="tab-pane fade" id="tab6">
                        <div class="row">
                            <div class="col-md-5 border-end">
                                <div class="form-row-custom"><label>Vaccine Status</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="form-row-custom"><label>Vaccine Name</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="ms-4 mt-3">
                                    <div class="mb-2"><input type="checkbox" /> 1st Dose <asp:TextBox runat="server" CssClass="ms-2" Width="120px" /></div>
                                    <div class="mb-2"><input type="checkbox" /> 2nd Dose <asp:TextBox runat="server" CssClass="ms-2" Width="120px" /></div>
                                    <div class="mb-2"><input type="checkbox" /> 3rd Dose <asp:TextBox runat="server" CssClass="ms-2" Width="120px" /></div>
                                    <div class="mb-2"><input type="checkbox" /> 4th Dose <asp:TextBox runat="server" CssClass="ms-2" Width="120px" /></div>
                                </div>
                            </div>
                            <div class="col-md-7 ps-4">
                                <span class="section-title">Vaccine Basic Info</span>
                                <div class="border p-2" style="height: 250px; background: #f9f9f9;"></div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab7">
                        <div class="row">
                            <div class="col-md-5 border-end pe-4">
                                 <div class="form-row-custom"><label>Training Head</label><asp:DropDownList runat="server" CssClass="form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                                 <div class="form-row-custom"><label>Training Subject</label><asp:DropDownList runat="server" CssClass="form-select-sm w-100"><asp:ListItem Text="Select" Value=""></asp:ListItem></asp:DropDownList></div>
                                 <div class="form-row-custom"><label>Duration Date</label><asp:TextBox runat="server" Width="110px" /> to <asp:TextBox runat="server" Width="110px" /></div>
                                 <div class="form-row-custom"><label>Days</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                 <div class="form-row-custom"><label>Trainer Name</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                 <div class="form-row-custom"><label>Trainer Org.</label><asp:TextBox runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control form-control-sm w-100" /></div>
                                 <div class="form-row-custom"><label>Org. Address</label><asp:TextBox runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control form-control-sm w-100" /></div>
                                 <div class="text-center mt-2">
                                     <asp:Button runat="server" Text="Save" CssClass="btn btn-sm btn-light border w-25" /> 
                                     <asp:Button runat="server" Text="Delete" CssClass="btn btn-sm btn-light border w-25" />
                                 </div>
                            </div>
                            <div class="col-md-7 ps-4">
                                <table class="table table-sm table-bordered">
                                    <thead class="table-light small">
                                        <tr><th>Entry No</th><th>Training Head</th><th>Subject</th><th>Duration Date</th></tr>
                                    </thead>
                                    <tbody style="height:300px; display:block;"></tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    
                </div>

                <!-- FOOTER BUTTONS -->
                <div class="footer-btns">
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn" />
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn" />
                    <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn" />
                    <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="btn" />
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
document.addEventListener("DOMContentLoaded", function() {
    var selectedTab = localStorage.getItem('activeTab');
    if (selectedTab) {
        var tabEl = document.querySelector(`button[data-bs-target="${selectedTab}"]`);
        if (tabEl) new bootstrap.Tab(tabEl).show();
    }
    var tabLinks = document.querySelectorAll('.nav-link');
    tabLinks.forEach(function(tab) {
        tab.addEventListener('shown.bs.tab', function(e) {
            localStorage.setItem('activeTab', e.target.getAttribute('data-bs-target'));
        });
    });
});

// ==========================================================
// Initialize Select2 (searchable dropdown) on every <select>
// on the page, and re-position it correctly inside Bootstrap
// tab panes (which start hidden, so width detection needs a
// dropdownParent so the widget is not clipped/mis-sized).
// ==========================================================
$(function() {
    function humanize(name) {
        // Convert "ddlDepartment" -> "Department", "ddlSkillGrade" -> "Skill Grade"
        var base = (name || 'Option').replace(/^ddl/i, '');
        base = base.replace(/([a-z0-9])([A-Z])/g, '$1 $2').trim();
        return base || 'Option';
    }

    // IMPORTANT: We never add/remove/reorder <option> elements here.
    // ASP.NET WebForms' Event Validation only allows postback values
    // that were actually rendered by the server. Injecting a new
    // client-side <option value=""> (even just for a placeholder)
    // causes "Invalid postback or callback argument" errors if that
    // option ever gets submitted. So placeholders are only used for
    // selects that ALREADY have a real, server-rendered empty-value
    // option (e.g. <asp:ListItem Text="Select" Value="" />).
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

    $('select').each(function() {
        initSelect2($(this));
    });

    // Bootstrap tabs hide inactive panes with display:none, so Select2
    // (which measures width on init) can render 0-width the first time
    // a tab is opened. Force a re-calc when a tab becomes visible.
    $('button[data-bs-toggle="tab"]').on('shown.bs.tab', function(e) {
        var target = $(e.target).attr('data-bs-target');
        $(target).find('select').each(function() {
            if ($(this).hasClass('select2-hidden-accessible')) {
                $(this).select2('destroy');
            }
        });
        $(target).find('select').each(function() {
            initSelect2($(this));
        });
    });
        });
    </script>
</body>
</html>
