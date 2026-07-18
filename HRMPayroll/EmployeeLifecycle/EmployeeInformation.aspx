<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeInformation.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.EmployeeInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Employee Entry Information - NexaERP</title>

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
        margin: 0;
    }

    .card-header i {
        font-size: 1.1rem;
    }

    .card-body {
        padding: 22px;
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

    .form-check-input:checked {
        background-color: var(--brand-success);
        border-color: var(--brand-success);
    }

    .action-bar {
        border-top: 1px solid var(--border-soft);
        margin-top: 20px;
        padding-top: 16px;
    }

    /* Section boxes used for grouped dropdown/field blocks */
    .section-box {
        border: 1px solid var(--border-soft);
        border-radius: 12px;
        padding: 18px;
        background: #fafbfc;
        height: 100%;
    }

    .section-box .field-row {
        margin-bottom: 14px;
    }

    .section-box .field-row:last-child {
        margin-bottom: 0;
    }

    .top-section {
        border-bottom: 1px solid var(--border-soft);
        padding-bottom: 20px;
        margin-bottom: 20px;
    }

    /* Photo box */
    .photo-box {
        width: 140px;
        height: 160px;
        border: 1px solid var(--border-soft);
        border-radius: 10px;
        background: #fff;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
    }

    .photo-box img {
        width: 100%;
        height: 100%;
        object-fit: cover;
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

        .action-bar .btn {
            width: 100%;
        }
    }

    @media (max-width: 575.98px) {
        .page-heading h3 {
            font-size: 1.1rem;
        }

        .card-header h4 {
            font-size: 0.95rem;
        }

        .card-body {
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
<form id="form" runat="server">
<div class="container-fluid main-container">

    <div class="page-heading">
        <i class="bi bi-person-badge-fill"></i>
        <div>
            <h3>Employee Entry Information</h3>
            <small>HRM &amp; Payroll &rsaquo; Employee Lifecycle &rsaquo; Employee Entry Information</small>
        </div>
    </div>

    <div class="card shadow">

        <div class="card-header bg-primary text-white">
            <i class="bi bi-person-lines-fill"></i>
            <h4 class="mb-0">Employee Entry Information</h4>
            <asp:Label ID="Label27" runat="server" Text=""></asp:Label>
        </div>

        <div class="card-body">

            <!-- Top Section -->
            <div class="row g-3 top-section">

                <!-- Left Part -->
                <div class="col-12 col-lg-5">

                    <div class="field-row">
                        <label>Employee ID</label>
                        <div class="input-group">
                            <asp:TextBox ID="TextBox1" runat="server" CssClass="form-control" />
                            <asp:Button ID="Button1" runat="server" Text="Search" CssClass="btn btn-secondary" />
                        </div>
                    </div>

                    <div class="field-row">
                        <label>Name</label>
                        <asp:TextBox ID="TextBox2" runat="server" CssClass="form-control" />
                    </div>

                    <div class="field-row">
                        <label>Bangla Name</label>
                        <asp:TextBox ID="TextBox3" runat="server" CssClass="form-control" />
                    </div>

                    <div class="row g-3">
                        <div class="col-6">
                            <label>Blood Group</label>
                            <asp:DropDownList ID="DropDownList1" runat="server" CssClass="form-select">
                                <asp:ListItem Text="--" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-6">
                            <label>Gross Salary</label>
                            <asp:TextBox ID="TextBox4" runat="server" TextMode="Number" CssClass="form-control" />
                        </div>
                    </div>

                </div>

                <!-- Middle Part -->
                <div class="col-12 col-lg-4">

                    <div class="field-row">
                        <label>Joining Date</label>
                        <asp:TextBox ID="TextBox5" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>

                    <div class="field-row">
                        <label>Probation Period</label>
                        <asp:TextBox ID="TextBox6" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>

                    <div class="field-row">
                        <label>Employee Status</label>
                        <asp:DropDownList ID="DropDownList2" runat="server" CssClass="form-select">
                            <asp:ListItem Text="Select" Value="">Unlock</asp:ListItem>
                        </asp:DropDownList>
                    </div>

                    <div class="field-row">
                        <asp:TextBox ID="TextBox7" runat="server" TextMode="Date" CssClass="form-control" />
                    </div>

                </div>

                <!-- Right Photo -->
                <div class="col-12 col-lg-3 d-flex flex-column align-items-center">
                    <div class="photo-box">
                        <asp:Image ID="Image1" runat="server" />
                    </div>
                    <asp:Button ID="Button2" runat="server" Text="Photo" CssClass="btn btn-secondary mt-2 w-100" />
                </div>

            </div>

            <!-- Bottom Section -->
            <div class="row g-3">

                <!-- Left Box -->
                <div class="col-12 col-lg-7">
                    <div class="section-box">

                        <div class="row g-3">
                            <div class="col-md-6 field-row">
                                <label>Branch</label>
                                <asp:DropDownList ID="DropDownList3" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6 field-row">
                                <label>Department</label>
                                <asp:DropDownList ID="DropDownList4" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6 field-row">
                                <label>Section</label>
                                <asp:DropDownList ID="DropDownList5" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6 field-row">
                                <label>Line</label>
                                <asp:DropDownList ID="DropDownList6" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6 field-row">
                                <label>Designation</label>
                                <asp:DropDownList ID="DropDownList7" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6 field-row">
                                <label>Category</label>
                                <asp:DropDownList ID="DropDownList8" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6 field-row">
                                <label>Shift</label>
                                <asp:DropDownList ID="DropDownList9" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6 field-row">
                                <label>Floor</label>
                                <asp:DropDownList ID="DropDownList10" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6 field-row">
                                <label>Machine Name</label>
                                <asp:DropDownList ID="ddlMachineName" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="col-md-6 field-row">
                                <label>Skill Grade</label>
                                <asp:DropDownList ID="ddlSkilGrade" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>

                    </div>
                </div>

                <!-- Right Box -->
                <div class="col-12 col-lg-5">
                    <div class="section-box">

                        <div class="field-row">
                            <label>Weekly Holiday</label>
                            <asp:DropDownList ID="DropDownList11" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="field-row">
                            <label>Break Down</label>
                            <asp:DropDownList ID="DropDownList12" runat="server" CssClass="form-select">
                                <asp:ListItem Text="--" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="field-row">
                            <label>Pay Type</label>
                            <asp:DropDownList ID="DropDownList13" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="row g-3 field-row">
                            <div class="col-6">
                                <label>Cash Gross</label>
                                <asp:TextBox ID="TextBox8" runat="server" TextMode="Number" CssClass="form-control" />
                            </div>
                            <div class="col-6">
                                <label>Cash Gross</label>
                                <asp:TextBox ID="TextBox9" runat="server" TextMode="Number" CssClass="form-control" />
                            </div>
                        </div>

                        <div class="row g-3 field-row">
                            <div class="col-6">
                                <label>Tax Holder</label>
                                <asp:DropDownList ID="DropDownList14" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="col-6">
                                <label>Amount</label>
                                <asp:TextBox ID="TextBox10" runat="server" TextMode="Number" CssClass="form-control" />
                            </div>
                        </div>

                        <div class="field-row">
                            <label>Bank Holder</label>
                            <asp:DropDownList ID="DropDownList15" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="field-row">
                            <label>Bank Name</label>
                            <asp:DropDownList ID="DropDownList16" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="field-row">
                            <label>A/C No</label>
                            <asp:TextBox ID="TextBox11" runat="server" CssClass="form-control" />
                        </div>

                    </div>
                </div>

            </div>

            <!-- Footer Buttons -->
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3 action-bar">

                <div class="d-flex align-items-center gap-4 flex-wrap">
                    <asp:Button ID="Button6" runat="server" Text="Increment History" CssClass="btn btn-secondary" />

                    <div class="form-check mb-0">
                        <asp:CheckBox ID="CheckBox2" runat="server" CssClass="form-check-input" />
                        <asp:Label runat="server" AssociatedControlID="CheckBox2"
                            Text="Is Active?" CssClass="form-check-label" />
                    </div>
                </div>

                <div class="d-flex gap-2">
                    <asp:Button ID="Button4" runat="server" Text="Save" CssClass="btn btn-success" />
                    <asp:Button ID="Button5" runat="server" Text="Clear" CssClass="btn btn-secondary" />
                </div>

            </div>

        </div>

    </div>

</div>
</form>
</body>
</html>

