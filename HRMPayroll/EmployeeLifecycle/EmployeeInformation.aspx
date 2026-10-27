<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeInformation.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.EmployeeInformation" %>
<!DOCTYPE html>
<html lang="bn">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Employee Information</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Hind+Siliguri:wght@400;500;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" />

    <style>
        :root {
            --brand-primary: #2e5bd7;
            --brand-primary-dark: #234699;
            --text-muted: #6b7280;
            --shell-offset: 0px;   /* ERP এর উপরের বার হেডার ঢেকে ফেললে এখানে 4.5rem দিন */
        }

        body { background-color: #f0f2f5; font-family: 'Inter', 'Hind Siliguri', 'Segoe UI', Arial, sans-serif; font-size: 12px; padding-top: var(--shell-offset); }

        .main-wrapper { max-width: 1150px; margin: 10px auto; background: #fff; border: 1px solid #ccc; box-shadow: 0 0 10px rgba(0,0,0,0.1); padding: 0; border-radius: 5px; }

        .page-heading { display: flex; align-items: center; gap: 12px; padding: 16px 20px; border-bottom: 1px solid #e6e9ef; }
        .page-heading i { font-size: 1.6rem; color: var(--brand-primary); }
        .page-heading h3 { margin: 0; font-weight: 700; font-size: 1.25rem; color: #111827; }
        .page-heading small { display: block; color: var(--text-muted); font-weight: 400; font-size: 0.78rem; }

        .content-area { padding: 15px; }
        .fixed-top-section { border-bottom: 1px solid #eee; margin-bottom: 10px; padding-bottom: 10px; }

        .employee-meta-grid { display: grid; grid-template-columns: auto 150px; column-gap: 12px; row-gap: 8px; align-items: center; }
        .employee-meta-grid label { text-align: left; white-space: nowrap; }
        .employee-meta-grid .form-control-sm, .employee-meta-grid .form-select-sm { width: 100%; }

        .photo-box { width: 120px; height: 140px; border: 1px solid #ccc; background: #f8f9fa; display: flex; align-items: center; justify-content: center; margin-bottom: 5px; overflow: hidden; }
        .photo-btn { background: #eef3ff; border: 1px solid #adc5ff; color: #2e5bd7; font-weight: bold; width: 120px; font-size: 11px; padding: 2px; text-align: center; display: block; cursor: pointer; }
        .photo-btn:hover { background: #dfe8ff; }

        .nav-tabs { flex-wrap: wrap; }
        .nav-tabs .nav-link { background: #f8f9fa; border: 1px solid #ddd; color: #555; margin-right: 2px; padding: 6px 12px; font-size: 12px; }
        .nav-tabs .nav-link.active { background: #2e5bd7 !important; color: #fff !important; border-bottom: none; font-weight: bold; }
        .tab-content { background: #fff; border: 1px solid #ddd; border-top: none; padding: 20px; }
        .tab-pane { min-height: 260px; }

        .form-row-custom { display: flex; align-items: center; margin-bottom: 6px; }
        .form-row-custom label { width: 130px; min-width: 130px; margin-bottom: 0; font-weight: 500; color: #333; }
        .form-control-sm, .form-select-sm { border-radius: 4px; border: 1px solid #ced4da; font-size: 12px; height: 28px; }
        .form-control:disabled, .form-control[readonly] { background: #f1f3f5; }
        .pair { display: flex; gap: 6px; flex: 1 1 auto; min-width: 0; }
        .pair > .form-control { flex: 1 1 0; min-width: 0; width: auto; }
        .chk-line label { width: auto; min-width: 0; }

        .section-title { font-weight: bold; background: #f0f4ff; color: #2e5bd7; padding: 4px 10px; display: block; margin-bottom: 10px; border-left: 4px solid #2e5bd7; }
        .section-box { border: 1px solid #ddd; border-radius: 8px; padding: 14px; background: #fafbfc; height: 100%; }
        .section-box .form-row-custom:last-child { margin-bottom: 0; }

        .tab-nav-btns { display: flex; justify-content: space-between; align-items: center; margin-top: 18px; padding-top: 12px; border-top: 1px dashed #e0e4eb; }
        .tab-nav-btns .btn-nav { background-color: #eef3ff; border: 1px solid #2e5bd7; color: #2e5bd7; font-weight: bold; font-size: 12px; border-radius: 5px; padding: 6px 16px; display: inline-flex; align-items: center; gap: 6px; cursor: pointer; }
        .tab-nav-btns .btn-nav:hover { background-color: #2e5bd7; color: #fff; }
        .tab-nav-btns .btn-nav-spacer { visibility: hidden; }

        .footer-btns { margin-top: 15px; text-align: center; background: #fff; border-top: 1px solid #eee; padding-top: 15px; padding-bottom: 5px; }
        .footer-btns .btn { min-width: 140px; border-radius: 5px; margin: 0 5px 8px; font-size: 12px; font-weight: bold; background-color: #eef3ff; border: 1px solid #2e5bd7; color: #2e5bd7; }
        .footer-btns .btn:hover { background-color: #2e5bd7; color: #fff; }
        .btn-search-dark { background-color: #f8f9fa; border: 1px solid #ccc; color: #333; }

        /* Select2 — রেফারেন্স ছবির মতো গোল বক্স, chevron আইকন, pill সার্চ */
        .select2-container--default .select2-selection--single { height: 30px; border: 1px solid #ced4da; border-radius: 8px; background-color: #fff; display: flex; align-items: center; padding: 0; transition: border-color .15s ease, box-shadow .15s ease; }
        .select2-container--default.select2-container--focus .select2-selection--single,
        .select2-container--default.select2-container--open .select2-selection--single { border-color: var(--brand-primary); box-shadow: 0 0 0 3px rgba(46, 91, 215, 0.12); }
        .select2-container--default.select2-container--disabled .select2-selection--single { background: #e9ecef; }
        .select2-container--default .select2-selection--single .select2-selection__rendered { line-height: 28px; padding-left: 12px; padding-right: 30px; font-size: 12px; color: #222; }
        .select2-container--default .select2-selection--single .select2-selection__placeholder { color: #8a93a3; }
        .select2-container--default .select2-selection--single .select2-selection__arrow { height: 28px; width: 26px; right: 4px; }
        .select2-container--default .select2-selection--single .select2-selection__arrow b { display: none; }
        .select2-container--default .select2-selection--single .select2-selection__arrow::before { font-family: "bootstrap-icons"; content: "\F2F4"; font-size: 12px; color: #8a93a3; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); }
        .select2-container--default .select2-dropdown { border: 1px solid #e2e6ee; border-radius: 12px; box-shadow: 0 10px 28px rgba(17, 24, 39, 0.12); overflow: hidden; padding-top: 8px; font-size: 12.5px; }
        .select2-dropdown--below { margin-top: 4px; }
        .select2-dropdown--above { margin-top: -4px; }
        .select2-container--default .select2-search--dropdown { padding: 4px 10px 10px 10px; position: relative; }
        .select2-container--default .select2-search--dropdown::before { font-family: "bootstrap-icons"; content: "\F52A"; position: absolute; left: 22px; top: 50%; transform: translateY(-45%); color: #9aa2b1; font-size: 13px; pointer-events: none; }
        .select2-container--default .select2-search--dropdown .select2-search__field { border: 1px solid #e2e6ee; border-radius: 20px; padding: 6px 12px 6px 32px; font-size: 12.5px; outline: none; background: #f8f9fb; }
        .select2-container--default .select2-search--dropdown .select2-search__field:focus { border-color: var(--brand-primary); background: #fff; }
        .select2-container--default .select2-results__options { max-height: 260px; }
        .select2-container--default .select2-results__option { padding: 8px 16px; color: #333; }
        .select2-container--default .select2-results__option--highlighted[aria-selected] { background-color: #f1f4fb; color: var(--brand-primary-dark); }
        .select2-container--default .select2-results__option[aria-selected="true"] { background-color: #eef3ff; color: var(--brand-primary-dark); font-weight: 600; }
        .select2-results__option:empty { display: none; }
        .select2-container { width: 100% !important; }
        .form-row-custom .select2-container { flex: 1 1 auto; min-width: 0; }
    </style>
</head>
<body>
<form id="form1" runat="server" enctype="multipart/form-data" defaultbutton="btnSearch">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <asp:HiddenField ID="hfTab" runat="server" />

    <div class="main-wrapper">
        <div class="page-heading">
            <i class="bi bi-person-lines-fill"></i>
            <div>
                <h3>Employee Information</h3>
                <small>HRM Payroll &rsaquo; Employee Lifecycle &rsaquo; Employee Information</small>
            </div>
        </div>

        <div class="content-area">

            <!-- ================= 1. FIXED TOP SECTION ================= -->
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
                        <div class="form-row-custom"><label>Name</label><asp:TextBox ID="txtName" runat="server" CssClass="form-control form-control-sm"></asp:TextBox></div>
                        <div class="form-row-custom"><label>Bangla Name</label><asp:TextBox ID="txtBanglaName" runat="server" CssClass="form-control form-control-sm"></asp:TextBox></div>
                        <div class="mt-1"><span class="text-primary fw-bold">User Name: <%= Convert.ToString(Session["User_Name"] ?? Session["UserName"] ?? "") %></span></div>
                    </div>

                    <div class="col-md-6">
                        <div class="d-flex justify-content-end align-items-start flex-wrap gap-2">
                            <div class="employee-meta-grid small pt-1 me-3">
                                <label class="mb-0">Joining Date</label>
                                <asp:TextBox ID="txtJoiningDate" runat="server" AutoPostBack="true" TextMode="Date" CssClass="form-control form-control-sm" OnTextChanged="txtJoiningDate_TextChanged"></asp:TextBox>

                                <label class="mb-0">Probation Period</label>
                                <asp:TextBox ID="txtProbationPeriod" runat="server" TextMode="Date" CssClass="form-control form-control-sm"></asp:TextBox>

                                <label class="mb-0">Employee Status</label>
                                <asp:DropDownList ID="ddlEmployeeStatus" runat="server" CssClass="form-select form-select-sm sel2">
                                    <asp:ListItem Text="Active" Value="Active" />
                                    <asp:ListItem Text="Inactive" Value="Inactive" />
                                </asp:DropDownList>

                                <label class="mb-0">Separation Date</label>
                                <asp:TextBox ID="txtSeparationDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" ReadOnly="True"></asp:TextBox>
                            </div>

                            <div>
                                <label for="<%= FileUpload1.ClientID %>" style="cursor:pointer; display:block;">
                                    <div class="photo-box text-muted" id="photoPreviewBox">
                                        <img id="imgPhotoPreview" runat="server" src="#" alt="Photo preview" style="width:100%; height:100%; object-fit:cover; display:none;" />
                                        <span id="photoPlaceholderText" runat="server">Photo</span>
                                    </div>
                                </label>
                                <asp:FileUpload ID="FileUpload1" runat="server" CssClass="d-none" onchange="previewEmployeePhoto(this)" accept=".jpg,.jpeg,.png,.bmp" />
                                <label for="<%= FileUpload1.ClientID %>" class="photo-btn">Choose Photo</label>
                                <div id="photoInfo" class="text-muted" style="font-size:10px; text-align:center; margin-top:2px;">সর্বোচ্চ 300KB</div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="footer-btns">
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn" UseSubmitBehavior="false" OnClientClick="window.location.href = window.location.pathname + window.location.search; return false;" />
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn" OnClick="btnSave_Click" OnClientClick="return validateForm();" />
                    <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="btn" UseSubmitBehavior="false" OnClientClick="history.back(); return false;" />
                </div>
            </div>

            <!-- ================= 2. TAB NAVIGATION ================= -->
            <ul class="nav nav-tabs" id="hrTabs" role="tablist">
                <li class="nav-item"><button type="button" class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab1">Office Information</button></li>
                <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab2">Salary and Bank Information</button></li>
                <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab3">Personal Information</button></li>
                <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab4">Address Information</button></li>
                <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab5">Nominee Information</button></li>
                <li class="nav-item"><button type="button" class="nav-link" data-bs-toggle="tab" data-bs-target="#tab6">Job Experience</button></li>
            </ul>

            <!-- ================= 3. TAB CONTENT ================= -->
            <div class="tab-content">

                <!-- ---------- Office Information ---------- -->
                <div class="tab-pane fade show active" id="tab1">
                    <div class="section-box">
                        <span class="section-title">Job &amp; Work Assignment</span>
                        <div class="row g-2">
                            <div class="col-md-6">
                                <div class="form-row-custom"><label>Branch</label><asp:DropDownList ID="ddlBranch" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                                <div class="form-row-custom"><label>Department</label><asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                                <div class="form-row-custom"><label>Section</label><asp:DropDownList ID="ddlSection" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                                <div class="form-row-custom"><label>Line</label><asp:DropDownList ID="ddlLine" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                                <div class="form-row-custom"><label>Designation</label><asp:DropDownList ID="ddlDesignation" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-row-custom"><label>Category</label><asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                                <div class="form-row-custom"><label>Shift</label><asp:DropDownList ID="ddlShift" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                                <div class="form-row-custom"><label>Floor</label><asp:DropDownList ID="ddlFloor" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                                <div class="form-row-custom"><label>Weekly Holiday</label><asp:DropDownList ID="ddlWeekoff" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                            </div>
                        </div>
                    </div>
                    <div class="tab-nav-btns">
                        <span class="btn-nav btn-nav-spacer"><i class="bi bi-chevron-left"></i> Previous Page</span>
                        <button type="button" class="btn-nav" data-goto="#tab2">Next Page <i class="bi bi-chevron-right"></i></button>
                    </div>
                </div>

                <!-- ---------- Salary and Bank Information ---------- -->
                <div class="tab-pane fade" id="tab2">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <div class="section-box">
                                <span class="section-title">Salary</span>
                                <div class="form-row-custom"><label>Gross Salary</label><asp:TextBox ID="txtGrossSalary" runat="server" TextMode="Number" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="form-row-custom"><label>Pay Type</label><asp:DropDownList ID="ddlPayType" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                                <div class="form-row-custom"><label>Taxable Gross Salary</label><asp:TextBox ID="txtTaxableGrossSalary" runat="server" TextMode="Number" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="form-row-custom"><label>Non-Taxable Gross Salary</label><asp:TextBox ID="txtNonTaxableGrossSalary" runat="server" TextMode="Number" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="form-row-custom"><label>Joining Gross Salary</label><asp:TextBox ID="txtJoiningGross" runat="server" TextMode="Number" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="form-row-custom"><label>Compliance Salary</label><asp:TextBox ID="txtNonComplianceGross" runat="server" TextMode="Number" CssClass="form-control form-control-sm w-100" /></div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="section-box">
                                <span class="section-title">Tax &amp; Bank</span>
                                <div class="form-row-custom"><label>Tax Holder</label>
                                    <asp:DropDownList ID="ddlTaxHolder" runat="server" CssClass="form-select form-select-sm sel2">
                                        <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                                        <asp:ListItem Text="Yes" Value="Yes"></asp:ListItem>
                                        <asp:ListItem Text="No" Value="No"></asp:ListItem>
                                    </asp:DropDownList></div>
                                <div class="form-row-custom"><label>Amount</label><asp:TextBox ID="txtTaxAmount" runat="server" TextMode="Number" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="form-row-custom"><label>TIN</label><asp:TextBox ID="txtTIN" runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Bank Holder</label>
                                    <asp:DropDownList ID="ddlBankHolder" runat="server" CssClass="form-select form-select-sm sel2">
                                        <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                                        <asp:ListItem Text="Yes" Value="Yes"></asp:ListItem>
                                        <asp:ListItem Text="No" Value="No"></asp:ListItem>
                                    </asp:DropDownList></div>
                                <div class="form-row-custom"><label>Bank Name</label>
                                    <asp:DropDownList ID="ddlBank" runat="server" CssClass="form-select form-select-sm sel2">
                                        <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                                    </asp:DropDownList></div>
                                <div class="form-row-custom"><label>Account Number</label><asp:TextBox ID="txtAccountNumber" runat="server" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="form-row-custom"><label>Routing No</label><asp:TextBox ID="txtRoutingNo" runat="server" CssClass="form-control form-control-sm w-100" /></div>
                            </div>
                        </div>
                    </div>
                    <div class="tab-nav-btns">
                        <button type="button" class="btn-nav" data-goto="#tab1"><i class="bi bi-chevron-left"></i> Previous Page</button>
                        <button type="button" class="btn-nav" data-goto="#tab3">Next Page <i class="bi bi-chevron-right"></i></button>
                    </div>
                </div>

                <!-- ---------- Personal Information ---------- -->
                <div class="tab-pane fade" id="tab3">
                    <div class="row">
                        <div class="col-md-6 border-end pe-4">
                            <div class="form-row-custom"><label>Father English</label><asp:TextBox ID="txtFatherEnglish" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>Mother English</label><asp:TextBox ID="txtMotherEnglish" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>Spouse English</label><asp:TextBox ID="txtSpouseEnglish" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>NID</label><asp:TextBox ID="txtNID" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>Date Of Birth</label><asp:TextBox ID="txtDateOfBirth" runat="server" TextMode="Date" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>Religion</label><asp:DropDownList ID="ddlReligion" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                            <div class="form-row-custom"><label>Gender</label><asp:DropDownList ID="ddlGender" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                            <div class="form-row-custom"><label>Blood Group</label>
                                <asp:DropDownList ID="ddlBloodGroup" runat="server" CssClass="form-select form-select-sm sel2">
                                    <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                                    <asp:ListItem Text="A+" Value="A+"></asp:ListItem>
                                    <asp:ListItem Text="A-" Value="A-"></asp:ListItem>
                                    <asp:ListItem Text="B+" Value="B+"></asp:ListItem>
                                    <asp:ListItem Text="B-" Value="B-"></asp:ListItem>
                                    <asp:ListItem Text="AB+" Value="AB+"></asp:ListItem>
                                    <asp:ListItem Text="AB-" Value="AB-"></asp:ListItem>
                                    <asp:ListItem Text="O+" Value="O+"></asp:ListItem>
                                    <asp:ListItem Text="O-" Value="O-"></asp:ListItem>
                                </asp:DropDownList></div>
                            <div class="form-row-custom"><label>Personal Phone</label><asp:TextBox ID="txtPersonalPhone" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>Education</label><asp:DropDownList ID="ddlEducation" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                        </div>
                        <div class="col-md-6 ps-4">
                            <div class="form-row-custom"><label>Father (Bangla)</label><asp:TextBox ID="txtFatherBangla" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>Mother (Bangla)</label><asp:TextBox ID="txtMotherBangla" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>Spouse (Bangla)</label><asp:TextBox ID="txtSpouseBangla" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>BID</label><asp:TextBox ID="txtBID" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>Marital Status</label><asp:DropDownList ID="ddlMaritalStatus" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                            <div class="form-row-custom"><label>No of Child</label><asp:TextBox ID="txtNoofChild" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>Height</label>
                                <asp:TextBox ID="txtHeightFeet" runat="server" Width="55px" CssClass="form-control form-control-sm" /><span class="mx-1">ft</span>
                                <asp:TextBox ID="txtHeightInch" runat="server" Width="55px" CssClass="form-control form-control-sm" /><span class="mx-1">inc</span>
                                <span class="ms-2 me-1">Weight</span><asp:TextBox ID="txtWeightKG" runat="server" Width="60px" CssClass="form-control form-control-sm" /><span class="ms-1">KG</span>
                            </div>
                            <div class="form-row-custom"><label>Home Phone</label><asp:TextBox ID="txtHomePhone" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>E-mail</label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control form-control-sm" /></div>
                        </div>
                    </div>
                    <div class="tab-nav-btns">
                        <button type="button" class="btn-nav" data-goto="#tab2"><i class="bi bi-chevron-left"></i> Previous Page</button>
                        <button type="button" class="btn-nav" data-goto="#tab4">Next Page <i class="bi bi-chevron-right"></i></button>
                    </div>
                </div>

                <!-- ---------- Address Information ---------- -->
                <div class="tab-pane fade" id="tab4">
                    <asp:UpdatePanel ID="upAddressInfo" runat="server">
                        <ContentTemplate>
                            <div class="row">
                                <div class="col-md-6 border-end pe-3">
                                    <span class="section-title">Permanent Address</span>
                                    <div class="form-row-custom"><label>District</label><asp:DropDownList ID="ddlPermanentDistrict" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                                    <div class="form-row-custom"><label>Police Station</label><asp:DropDownList ID="ddlPermanentPoliceStation" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                                    <div class="form-row-custom"><label>Post Office</label><div class="pair">
                                        <asp:TextBox runat="server" ID="txtPermanentPostOfficeEnglish" CssClass="form-control form-control-sm" placeholder="English"></asp:TextBox>
                                        <asp:TextBox runat="server" ID="txtPermanentPostOfficeBangla" CssClass="form-control form-control-sm" placeholder="বাংলা"></asp:TextBox></div></div>
                                    <div class="form-row-custom"><label>Village</label><div class="pair">
                                        <asp:TextBox runat="server" ID="txtPermanentVillageEnglish" CssClass="form-control form-control-sm" placeholder="English"></asp:TextBox>
                                        <asp:TextBox runat="server" ID="txtPermanentVillageBangla" CssClass="form-control form-control-sm" placeholder="বাংলা"></asp:TextBox></div></div>
                                </div>

                                <div class="col-md-6 ps-3">
                                    <div class="form-check mb-3 chk-line">
                                        <asp:CheckBox ID="chkSame" AutoPostBack="true" Text=" If present or permanent address same click here." runat="server" OnCheckedChanged="chkSame_CheckedChanged" />
                                    </div>
                                    <span class="section-title">Present Address</span>
                                    <div class="form-row-custom"><label>District</label><asp:DropDownList runat="server" ID="ddlPresentDistrict" CssClass="form-select form-select-sm sel2" /></div>
                                    <div class="form-row-custom"><label>Police Station</label><asp:DropDownList runat="server" ID="ddlPresentPoliceStation" CssClass="form-select form-select-sm sel2" /></div>
                                    <div class="form-row-custom"><label>Post Office</label><div class="pair">
                                        <asp:TextBox runat="server" ID="txtPresentPostOfficeEnglish" CssClass="form-control form-control-sm" placeholder="English"></asp:TextBox>
                                        <asp:TextBox runat="server" ID="txtPresentPostOfficeBangla" CssClass="form-control form-control-sm" placeholder="বাংলা"></asp:TextBox></div></div>
                                    <div class="form-row-custom"><label>Village</label><div class="pair">
                                        <asp:TextBox runat="server" ID="txtPresentVillageEnglish" CssClass="form-control form-control-sm" placeholder="English"></asp:TextBox>
                                        <asp:TextBox runat="server" ID="txtPresentVillageBangla" CssClass="form-control form-control-sm" placeholder="বাংলা"></asp:TextBox></div></div>
                                    <div class="form-row-custom"><label>House Holder</label><div class="pair">
                                        <asp:TextBox runat="server" ID="txtHouseHolderNameEnglish" CssClass="form-control form-control-sm" placeholder="English"></asp:TextBox>
                                        <asp:TextBox runat="server" ID="txtHouseHolderNameBangla" CssClass="form-control form-control-sm" placeholder="বাংলা"></asp:TextBox></div></div>
                                    <div class="form-row-custom"><label>Phone</label><asp:TextBox runat="server" ID="txtHouseHolderPhoneNo" CssClass="form-control form-control-sm"></asp:TextBox></div>
                                </div>
                            </div>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                    <div class="tab-nav-btns">
                        <button type="button" class="btn-nav" data-goto="#tab3"><i class="bi bi-chevron-left"></i> Previous Page</button>
                        <button type="button" class="btn-nav" data-goto="#tab5">Next Page <i class="bi bi-chevron-right"></i></button>
                    </div>
                </div>

                <!-- ---------- Nominee Information ---------- -->
                <div class="tab-pane fade" id="tab5">
                    <div class="row">
                        <div class="col-md-6 border-end pe-4">
                            <div class="form-row-custom"><label>Relation</label><asp:DropDownList ID="ddlNomineeRelation" runat="server" CssClass="form-select form-select-sm sel2" /></div>
                            <div class="form-row-custom"><label>Nominee's Name</label><asp:TextBox ID="txtNomineesName" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>NID</label><asp:TextBox ID="txtNomineesNID" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>BID</label><asp:TextBox ID="txtNomineesBID" runat="server" CssClass="form-control form-control-sm" /></div>
                        </div>
                        <div class="col-md-6 ps-4">
                            <div class="form-row-custom"><label>Nominee Name (Ban)</label><asp:TextBox ID="txtNomineeNameBangla" runat="server" CssClass="form-control form-control-sm" /></div>
                            <div class="form-row-custom"><label>Date Of Birth</label><asp:TextBox ID="txtNomineesDateOfBirth" runat="server" CssClass="form-control form-control-sm" Width="170px" TextMode="Date" /></div>
                            <div class="form-row-custom"><label>Phone No</label><asp:TextBox ID="txtNomineesPhoneNo" runat="server" CssClass="form-control form-control-sm" /></div>
                        </div>
                    </div>

                    <div class="mt-3">
                        <asp:UpdatePanel ID="upNomineeInfo" runat="server">
                            <ContentTemplate>
                                <span class="section-title">Nominee Address</span>
                                <div class="form-check mb-3 chk-line">
                                    <asp:CheckBox ID="CheckNominee" AutoPostBack="true" Text=" If Employee &amp; Nominee Address Same." runat="server" OnCheckedChanged="CheckNominee_CheckedChanged" />
                                </div>
                                <div class="row">
                                    <div class="col-md-8">
                                        <div class="form-row-custom"><label>District</label><asp:DropDownList runat="server" ID="ddlNomineeDistrict" CssClass="form-select form-select-sm sel2" /></div>
                                        <div class="form-row-custom"><label>Police Station</label><asp:DropDownList runat="server" ID="ddlNomineePoliceStation" CssClass="form-select form-select-sm sel2" /></div>
                                        <div class="form-row-custom"><label>Post Office</label><div class="pair">
                                            <asp:TextBox runat="server" ID="txtNomineePostOfficeEnglish" CssClass="form-control form-control-sm" placeholder="English"></asp:TextBox>
                                            <asp:TextBox runat="server" ID="txtNomineePostOfficeBangla" CssClass="form-control form-control-sm" placeholder="বাংলা"></asp:TextBox></div></div>
                                        <div class="form-row-custom"><label>Village</label><div class="pair">
                                            <asp:TextBox runat="server" ID="txtNomineeVillageEnglish" CssClass="form-control form-control-sm" placeholder="English"></asp:TextBox>
                                            <asp:TextBox runat="server" ID="txtNomineeVillageBangla" CssClass="form-control form-control-sm" placeholder="বাংলা"></asp:TextBox></div></div>
                                    </div>
                                </div>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>

                    <div class="tab-nav-btns">
                        <button type="button" class="btn-nav" data-goto="#tab4"><i class="bi bi-chevron-left"></i> Previous Page</button>
                        <button type="button" class="btn-nav" data-goto="#tab6">Next Page <i class="bi bi-chevron-right"></i></button>
                    </div>
                </div>

                <!-- ---------- Job Experience ---------- -->
                <div class="tab-pane fade" id="tab6">
                    <div class="row">
                        <div class="col-md-9">
                            <div class="form-row-custom"><label>Factory Name</label><div class="pair">
                                <asp:TextBox ID="txtFactoryName" runat="server" CssClass="form-control form-control-sm" placeholder="English" />
                                <asp:TextBox ID="txtFactoryNameBangla" runat="server" CssClass="form-control form-control-sm" placeholder="বাংলা" /></div></div>
                            <div class="form-row-custom align-items-start"><label>Address</label><div class="pair">
                                <asp:TextBox ID="txtFactoryAddress" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control form-control-sm" placeholder="English" />
                                <asp:TextBox ID="txtFactoryAddressBangla" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control form-control-sm" placeholder="বাংলা" /></div></div>
                            <div class="form-row-custom"><label>Total Experience</label>
                                <asp:TextBox ID="txtTotalExpYear" runat="server" Width="70px" CssClass="form-control form-control-sm" /><span class="ms-2">Year</span></div>
                        </div>
                    </div>
                    <div class="tab-nav-btns">
                        <button type="button" class="btn-nav" data-goto="#tab5"><i class="bi bi-chevron-left"></i> Previous Page</button>
                    </div>
                </div>

            </div>
        </div>
    </div>
</form>

<script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>


</body>
</html>
