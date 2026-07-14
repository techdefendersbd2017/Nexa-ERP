<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DesignationInformation.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting.DesignationInformation" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Designation Information - NexaERP</title>

    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />

    <!-- Google Font -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />

<style>
    :root {
        --brand-primary: #0d6efd;
        --brand-primary-dark: #0b5ed7;
        --brand-success: #198754;
        --brand-success-dark: #157347;
        --surface: #ffffff;
        --page-bg: #f2f4f8;
        --border-soft: #e6e9ef;
        --text-muted: #6b7280;
    }

    * {
        font-family: 'Inter', 'Segoe UI', Roboto, Arial, sans-serif;
    }

    body {
        background: var(--page-bg);
        margin: 0;
        padding: 0;
        color: #1f2937;
    }

    .main-container {
        min-height: 100vh;
        padding: 20px;
    }

    .page-heading {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 16px;
    }

    .page-heading i {
        font-size: 1.4rem;
        color: var(--brand-primary);
    }

    .page-heading h3 {
        margin: 0;
        font-weight: 700;
        font-size: 1.35rem;
        color: #111827;
    }

    .page-heading small {
        display: block;
        color: var(--text-muted);
        font-weight: 400;
        font-size: 0.8rem;
    }

    .card {
        border: 1px solid var(--border-soft);
        border-radius: 14px;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(17, 24, 39, 0.06);
    }

    .card-header {
        border: none;
        padding: 14px 20px;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .card-header.bg-primary {
        background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)) !important;
    }

    .card-header.bg-success {
        background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)) !important;
    }

    .card-header h4 {
        font-size: 1.05rem;
        font-weight: 600;
        letter-spacing: 0.2px;
    }

    .card-header i {
        font-size: 1.1rem;
    }

    label {
        font-weight: 600;
        font-size: 0.85rem;
        color: #374151;
        margin-bottom: 6px;
        display: block;
    }

    .form-control,
    .form-select {
        border-radius: 8px;
        border: 1px solid #d7dce3;
        padding: 9px 12px;
        font-size: 0.92rem;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }

    .form-control:focus,
    .form-select:focus {
        border-color: var(--brand-primary);
        box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15);
    }

    .form-control[readonly] {
        background-color: #f3f4f6;
        color: #6b7280;
    }

    .btn {
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.9rem;
        padding: 8px 20px;
    }

    .btn-success {
        background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark));
        border: none;
    }

    .btn-secondary {
        background-color: #eef0f3;
        border: 1px solid #d7dce3;
        color: #374151;
    }

    .btn-secondary:hover {
        background-color: #e2e5ea;
        color: #111827;
    }

    .btn-info {
        background: linear-gradient(135deg, #20c997, #1aa179);
        border: none;
        color: #fff;
    }

    .btn-info:hover {
        color: #fff;
        opacity: 0.92;
    }

    .btn-danger {
        background: linear-gradient(135deg, #dc3545, #bb2d3b);
        border: none;
    }

    .form-check-input:checked {
        background-color: var(--brand-success);
        border-color: var(--brand-success);
    }

    #chkIsActive {
        accent-color: #198754;
        cursor: pointer !important;
    }

    .left-panel {
        max-height: calc(100vh - 220px);
        overflow-y: auto;
        padding: 22px;
    }

    .right-panel {
        height: 100%;
    }

    .action-bar {
        border-top: 1px solid var(--border-soft);
        margin-top: 20px;
        padding-top: 16px;
    }

    .grid-wrapper {
        max-height: calc(100vh - 220px);
        overflow-y: auto;
        overflow-x: auto;
    }

    .grid-wrapper table {
        margin-bottom: 0;
        white-space: nowrap;
        font-size: 0.88rem;
    }

    .grid-wrapper th {
        position: sticky;
        top: 0;
        background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)) !important;
        color: #fff !important;
        z-index: 100;
        font-weight: 600;
        font-size: 0.82rem;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        padding: 12px 14px;
        border: none;
    }

    .grid-wrapper td {
        padding: 10px 14px;
        vertical-align: middle;
        color: #374151;
    }

    .grid-wrapper tbody tr:hover {
        background-color: #f0f6ff;
    }

    .grid-wrapper .table-bordered > :not(caption) > * > * {
        border-width: 0 0 1px 0;
        border-color: var(--border-soft);
    }

    /* ===== Fieldset (Tiffin / Night / Holiday) ===== */
    fieldset.section-box {
        border: 1px solid var(--border-soft);
        border-radius: 10px;
        padding: 14px 16px 16px 16px;
        background: #fafbfc;
    }

    fieldset.section-box legend {
        width: auto;
        padding: 0 8px;
        font-size: 0.85rem;
        font-weight: 700;
        color: var(--brand-primary);
        font-style: normal;
    }

    fieldset.section-box .form-control {
        padding: 6px 10px;
        font-size: 0.85rem;
    }

    fieldset.section-box label {
        font-size: 0.78rem;
        margin-bottom: 3px;
    }

    /* Tablet & Mobile */
    @media (max-width: 991.98px) {

        .main-container {
            height: auto;
            padding: 14px;
        }

        .card {
            height: auto !important;
            margin-bottom: 15px;
        }

        .left-panel,
        .grid-wrapper {
            max-height: none;
            overflow: visible;
        }

        .grid-wrapper {
            overflow-x: auto;
        }

        .action-bar .btn {
            width: 100%;
            margin-bottom: 8px;
        }
    }

    @media (max-width: 575.98px) {
        .page-heading h3 {
            font-size: 1.1rem;
        }

        .card-header h4 {
            font-size: 0.95rem;
        }

        .left-panel {
            padding: 16px;
        }

        .action-bar {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }
    }
</style>

</head>
<body>
<form id="form1" runat="server">
<div class="container-fluid main-container">

    <div class="page-heading">
        <i class="bi bi-person-badge-fill"></i>
        <div>
            <h3>Designation Information</h3>
            <small>HRM Configuration &rsaquo; HRM Setting &rsaquo; Designation Information</small>
        </div>
    </div>

    <div class="row">

        <!-- Left Side Form -->
        <div class="col-12 col-lg-7 mb-3">

            <div class="card shadow">

                <div class="card-header bg-primary text-white d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div class="d-flex align-items-center gap-2">
                        <i class="bi bi-person-vcard"></i>
                        <h4 class="mb-0">Designation Information</h4>
                    </div>
                    <div>
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success btn-sm me-2" OnClick="btnSave2_Click" />
                        <asp:Button ID="btnRefresh2" runat="server" Text="Refresh" CssClass="btn btn-info" OnClick="btnRefresh2_Click"/>
                    </div>
                </div>

                <div class="card-body left-panel">

                    <asp:HiddenField ID="hfUserId" runat="server" />

                    <!-- ===== Basic Info ===== -->
                    <div class="row g-3">

                        <div class="col-md-4">
                            <label>Designation ID</label>
                            <asp:TextBox ID="txtDesignationId" runat="server" ReadOnly="true" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-4">
                            <asp:Label ID="Label2" runat="server" Text="Designation Name"></asp:Label>
                            <asp:TextBox ID="txtDesignationName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-4">
                            <asp:Label ID="Label1" runat="server" Text="Designation Name (Local)"></asp:Label>
                            <asp:TextBox ID="txtDesignationNameBangla" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-4">
                            <asp:Label ID="Label3" runat="server" Text="Work Type"></asp:Label>
                            <asp:TextBox ID="txtWorkType" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-4">
                            <asp:Label ID="Label4" runat="server" Text="Work Type Bangla"></asp:Label>
                            <asp:TextBox ID="txtWorkTypeBangla" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-4">
                            <asp:Label ID="Label5" runat="server" Text="Tafsil"></asp:Label>
                            <asp:DropDownList ID="ddlTafsil" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlTafsil_SelectedIndexChanged"></asp:DropDownList>
                        </div>

                        <div class="col-md-4">
                            <asp:Label ID="Label6" runat="server" Text="Grade"></asp:Label>
                            <asp:TextBox ID="txtGrade" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-4">
                            <asp:Label ID="Label7" runat="server" Text="Designation Leval"></asp:Label>
                            <asp:DropDownList ID="ddlDesignationLeval" runat="server" CssClass="form-select"></asp:DropDownList>
                        </div>

                        <div class="col-md-4">
                            <asp:Label ID="Label8" runat="server" Text="Minimum Wages"></asp:Label>
                            <asp:TextBox ID="txtMinimumWages" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-4">
                            <asp:Label ID="Label9" runat="server" Text="Att. Bonus"></asp:Label>
                            <asp:TextBox ID="txtAttBonus" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <div class="col-md-4">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                            <asp:Label for="chkIsActive" runat="server" Text="Is Active?" CssClass="form-check-label mb-0"></asp:Label>
                        </div>
                    </div>

                    <!-- ===== Tiffin / Night / Holiday ===== -->
                    <div class="row g-3 mt-1">

                        <!-- Tiffin -->
                        <div class="col-12">
                            <fieldset class="section-box">
                                <legend>Tiffin</legend>

                                <div class="row g-2">
                                    <div class="col-md-3">
                                        <asp:Label ID="Label11" runat="server" Text="1st Min"></asp:Label>
                                        <asp:TextBox ID="txtTiffin1stMin" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label12" runat="server" Text="1st Allowance"></asp:Label>
                                        <asp:TextBox ID="txtTiffin1stAllowance" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label13" runat="server" Text="2nd Min"></asp:Label>
                                        <asp:TextBox ID="txtTiffin2ndMin" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label14" runat="server" Text="2nd Allowance"></asp:Label>
                                        <asp:TextBox ID="txtTiffin2ndAllowance" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label15" runat="server" Text="3rd Min"></asp:Label>
                                        <asp:TextBox ID="txtTiffin3rdMin" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label16" runat="server" Text="3rd Allowance"></asp:Label>
                                        <asp:TextBox ID="txtTiffin3rdAllowance" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label17" runat="server" Text="4th Min"></asp:Label>
                                        <asp:TextBox ID="txtTiffin4thMin" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label18" runat="server" Text="4th Allowance"></asp:Label>
                                        <asp:TextBox ID="txtTifin4thAllowance" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>

                                </div>
                            </fieldset>
                        </div>

                        <!-- Night -->
                        <div class="col-12">
                            <fieldset class="section-box">
                                <legend>Night</legend>

                                <div class="row g-2">
                                    <div class="col-md-3">
                                        <asp:Label ID="Label19" runat="server" Text="1st Min"></asp:Label>
                                        <asp:TextBox ID="txtNight1stMin" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label20" runat="server" Text="1st Allowance"></asp:Label>
                                        <asp:TextBox ID="txtNight1stAllowance" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label21" runat="server" Text="2nd Min"></asp:Label>
                                        <asp:TextBox ID="txtNight2ndMin" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label22" runat="server" Text="2nd Allowance"></asp:Label>
                                        <asp:TextBox ID="txtNight2ndAllowance" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label23" runat="server" Text="3rd Min"></asp:Label>
                                        <asp:TextBox ID="txt3rdNightMin" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label24" runat="server" Text="3rd Allowance"></asp:Label>
                                        <asp:TextBox ID="TxtNight3rdAllowance" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label25" runat="server" Text="4th Min"></asp:Label>
                                        <asp:TextBox ID="txtNight4thMin" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label26" runat="server" Text="4th Allowance"></asp:Label>
                                        <asp:TextBox ID="txtNight4thAllowance" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                            </fieldset>
                        </div>

                        <!-- Holiday -->
                        <div class="col-12">
                            <fieldset class="section-box">
                                <legend>Holiday</legend>

                                <div class="row g-2">
                                    <div class="col-md-3">
                                        <asp:Label ID="Label27" runat="server" Text="1st Min"></asp:Label>
                                        <asp:TextBox ID="txtHoliday1stMin" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label28" runat="server" Text="1st Allowance"></asp:Label>
                                        <asp:TextBox ID="txtHoliday1stAllowance" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label29" runat="server" Text="2nd Min"></asp:Label>
                                        <asp:TextBox ID="txtHoliday2ndMin" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                    <div class="col-md-3">
                                        <asp:Label ID="Label30" runat="server" Text="2nd Allowance"></asp:Label>
                                        <asp:TextBox ID="txtHoliday2ndAllowance" runat="server" CssClass="form-control"></asp:TextBox>
                                    </div>
                                </div>
                            </fieldset>
                        </div>

                    </div>

                    <!-- ===== Action Bar ===== -->
                    <div class="mt-4 d-flex align-items-center action-bar flex-wrap gap-3">

                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn btn-info" OnClick="btnRefresh_Click"/>
                        <asp:Button ID="btnSave2" runat="server" Text="Save" CssClass="btn btn-success btn-sm me-2" OnClick="btnSave2_Click" />



                    </div>

                </div>

            </div>

        </div>

        <!-- Right Side Grid -->
        <div class="col-12 col-lg-5 mb-3">

            <div class="card shadow right-panel">

                <div class="card-header bg-success text-white">
                    <i class="bi bi-list-check"></i>
                    <h4 class="mb-0">Designation List</h4>
                </div>

                <div class="grid-wrapper">
                    <asp:GridView ID="gvDesignation"
                        runat="server"
                        CssClass="table table-bordered table-hover"
                        AutoGenerateColumns="False"
                        Width="100%"
                        DataKeyNames="Designation_Code"
                        OnSelectedIndexChanged="gvSection_SelectedIndexChanged">

                        <Columns>
                            <asp:CommandField ShowSelectButton="True" SelectText="Select"> <ItemStyle Width="80px" /> </asp:CommandField>
                            <asp:BoundField DataField="Designation_Code" HeaderText="ID" />
                            <asp:BoundField DataField="Desigation_name" HeaderText="Desigation Name" />
                            <asp:BoundField DataField="Grade" HeaderText="Grade" />

                            <%--<asp:CheckBoxField DataField="IsActive" HeaderText="Status" />--%>

                        </Columns>

                    </asp:GridView>
                </div>

            </div>

        </div>

    </div>

</div>
</form>
</body>
</html>