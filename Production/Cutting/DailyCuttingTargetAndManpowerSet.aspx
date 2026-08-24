<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyCuttingTargetAndManpowerSet.aspx.cs" Inherits="Nexa_ERP.Production.Cutting.DailyCuttingTargetAndManpowerSet" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Daily Cutting Target & Manpower Set - NexaERP</title>
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
            --brand-danger: #dc3545;
            --brand-danger-dark: #bb2d3b;
            --brand-info: #17a2b8;
            --brand-info-dark: #138496;
            --surface: #ffffff;
            --page-bg: #f2f4f8;
            --border-soft: #e6e9ef;
            --text-muted: #6b7280;
        }

        * { font-family: 'Inter', 'Segoe UI', Roboto, Arial, sans-serif; }

        body { background: var(--page-bg); margin: 0; padding: 0; color: #1f2937; }

        .main-container { min-height: 100vh; padding: 20px; }

        .page-heading { display: flex; align-items: center; gap: 10px; margin-bottom: 16px; }
        .page-heading i { font-size: 1.4rem; color: var(--brand-primary); }
        .page-heading h3 { margin: 0; font-weight: 700; font-size: 1.35rem; color: #111827; }
        .page-heading small { display: block; color: var(--text-muted); font-weight: 400; font-size: 0.8rem; }

        .card { border: 1px solid var(--border-soft); border-radius: 14px; overflow: hidden; box-shadow: 0 2px 10px rgba(17, 24, 39, 0.06); margin-bottom: 20px; }
        .card-header { border: none; padding: 14px 20px; display: flex; align-items: center; gap: 10px; }
        .card-header.bg-primary { background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)) !important; color: #fff; }
        .card-header.bg-success { background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)) !important; color: #fff; }
        .card-header h4 { font-size: 1.05rem; font-weight: 600; letter-spacing: 0.2px; margin: 0; }

        label { font-weight: 600; font-size: 0.82rem; color: #374151; margin-bottom: 4px; display: block; }

        .form-control, .form-select { border-radius: 8px; border: 1px solid #d7dce3; padding: 6px 10px; font-size: 0.88rem; transition: border-color 0.15s ease, box-shadow 0.15s ease; }
        .form-control:focus, .form-select:focus { border-color: var(--brand-primary); box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15); }

        .btn { border-radius: 8px; font-weight: 600; font-size: 0.85rem; padding: 6px 16px; border: none; }
        .btn-primary { background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)); color: #fff; }
        .btn-success { background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)); color: #fff; }
        .btn-danger { background: var(--brand-danger); color: #fff; }
        .btn-info { background: linear-gradient(135deg, var(--brand-info), var(--brand-info-dark)); color: #fff; }
        .btn-secondary { background-color: #eef0f3; border: 1px solid #d7dce3; color: #374151; }

        .left-panel, .card-body-tight { padding: 20px; }

        .action-bar { border-top: 1px solid var(--border-soft); margin-top: 18px; padding-top: 16px; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 10px; }
        .action-bar .btn-group-left, .action-bar .btn-group-right { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; }

        /* Field grid - mirrors original layout ratios while using brand form styling */
        .field-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 10px 12px; }
        .field-grid .span-2 { grid-column: span 2; }
        .field-grid .span-3 { grid-column: span 3; }
        .field-item { display: flex; flex-direction: column; }
        .field-inline { display: flex; align-items: flex-end; gap: 6px; }
        .field-btn-align { display: flex; align-items: flex-end; }

        fieldset.custom-fieldset { border: 1px solid var(--border-soft); border-radius: 10px; padding: 10px 14px 14px; margin: 0; }
        fieldset.custom-fieldset legend { width: auto; padding: 0 8px; font-size: 0.8rem; font-weight: 600; font-style: italic; color: var(--text-muted); }

        .side-grid-wrapper { border: 1px solid var(--border-soft); border-radius: 10px; background: #f8f9fa; height: 100%; min-height: 220px; overflow-y: auto; }
        .grid-wrapper { max-height: 280px; overflow-y: auto; overflow-x: auto; }
        .grid-wrapper table, .side-grid-wrapper table { margin-bottom: 0; white-space: nowrap; font-size: 0.86rem; }
        .grid-wrapper th, .side-grid-wrapper th { position: sticky; top: 0; background: #f1f3f5; z-index: 100; font-weight: 600; font-size: 0.8rem; text-transform: uppercase; padding: 10px 12px; border: none; }

        .form-check-input.accent-success { accent-color: var(--brand-success); }

        @media (max-width: 991.98px) {
            .main-container { padding: 14px; }
            .field-grid { grid-template-columns: repeat(2, 1fr); }
            .field-grid .span-2, .field-grid .span-3 { grid-column: span 2; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid main-container">

            <div class="page-heading">
                <i class="bi bi-scissors"></i>
                <div>
                    <h3>Daily Cutting Target &amp; Manpower Set</h3>
                    <small>Production &rsaquo; Cutting &rsaquo; Daily Cutting Target &amp; Manpower Set</small>
                </div>
            </div>

            <asp:HiddenField ID="hfUserId" runat="server" />

            <!-- Main Info Card -->
            <div class="card shadow">
                <div class="card-header bg-primary text-white">
                    <i class="bi bi-pencil-square"></i>
                    <h4>Target &amp; Manpower Information</h4>
                </div>
                <div class="card-body card-body-tight">
                    <div class="row g-3">
                        <!-- Left: field grid -->
                        <div class="col-12 col-lg-12">
                            <div class="row">
                                <!-- Floor Information (বাম কলাম) -->
<div class="col-12 col-md-4">
    <fieldset class="custom-fieldset p-3 border rounded shadow-sm">
        <legend>Floor Information</legend>
        
        <!-- ফিল্ডগুলো সুন্দরভাবে সাজানোর জন্য সরাসরি স্টাইল ব্যবহার করা হয়েছে -->
        <div class="field-grid" style="display: flex; flex-direction: column; gap: 15px;">
            
            <div class="field-item">
                <label class="form-label mb-1 fw-semibold d-block">Floor</label>
                <asp:DropDownList ID="ddlFloor" runat="server" CssClass="form-select shadow-none" Width="250px"></asp:DropDownList>
            </div>
            
            <div class="field-item">
                <label class="form-label mb-1 fw-semibold d-block">Section</label>
                <asp:DropDownList ID="ddlSection" runat="server" CssClass="form-select shadow-none" Width="250px"></asp:DropDownList>
            </div>
            
            <div class="field-item">
                <label class="form-label mb-1 fw-semibold d-block">Line No</label>
                <asp:DropDownList ID="ddlLineNo" runat="server" CssClass="form-select shadow-none" Width="250px"></asp:DropDownList>
            </div>
            
            <div class="field-item">
                <label class="form-label mb-1 fw-semibold d-block">Date Time</label>
                <asp:DropDownList ID="ddlDateTime" runat="server" CssClass="form-select shadow-none" Width="250px"></asp:DropDownList>
            </div>

        </div>
    </fieldset>
</div>

                                <!-- Order Information (মাঝের কলাম) -->
                                <div class="col-12 col-md-4">
                                    <fieldset class="custom-fieldset">
                                        <legend>Order Information</legend>
                                        <div class="field-grid">
                                            <div class="field-item">
                                                <label>Buyer</label>
                                                <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="form-select"></asp:DropDownList>
                                            </div>
                                            <div class="field-item">
                                                <label>Style No</label>
                                                <asp:TextBox ID="txtStyleNo" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="field-item">
                                                <label>PO No</label>
                                                <asp:TextBox ID="txtPoNo" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="field-item">
                                                <label>Color</label>
                                                <asp:DropDownList ID="ddlColor" runat="server" CssClass="form-select"></asp:DropDownList>
                                            </div>
                                            <div class="field-item">
                                                <label>Order Qty</label>
                                                <asp:TextBox ID="txtOrderQty" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="field-item">
                                                <label>Plan Cut Qty</label>
                                                <asp:TextBox ID="txtPlanCutQty" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>

                                <!-- Performance Information (ডান কলাম) -->
                                <div class="col-12 col-md-4">
                                    <fieldset class="custom-fieldset">
                                        <legend>Performance Information</legend>
                                        <div class="field-grid">
                                            <div class="field-item">
                                                <label>Cut Qty</label>
                                                <asp:TextBox ID="txtCutQty" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="field-item">
                                                <label>Cut Balance</label>
                                                <asp:TextBox ID="txtCutBalance" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="field-item">
                                                <label>Target Hour</label>
                                                <asp:TextBox ID="txtTargetHour" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="field-item">
                                                <label>Calculative Hour</label>
                                                <asp:TextBox ID="txtCalculativeHour" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="field-item">
                                                <label>Target Eff.</label>
                                                <div class="field-inline" style="display: flex; align-items: center; gap: 5px;">
                                                    <asp:TextBox ID="txtTargetEfficiency" runat="server" CssClass="form-control" />
                                                    <span class="pb-1">%</span>
                                                </div>
                                            </div>
                                            <div class="field-item">
                                                <label>Cut. SMV</label>
                                                <asp:TextBox ID="txtCutSMV" runat="server" CssClass="form-control" />
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                            </div>
                            <br/>
                                <div class="span-3">
                                    <fieldset class="custom-fieldset">
                                        <legend>Manpower Status</legend>
                                        <div class="row g-2">
                                            <div class="col-2">
                                                <label>Cutting Man</label>
                                                <asp:TextBox ID="txtCuttingMan" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-2">
                                                <label>Cutting Assistant</label>
                                                <asp:TextBox ID="TextBox2" runat="server" CssClass="form-control" />
                                            </div>
                                            <div class="col-8">
                                                <label>Remarks</label>
                                                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control" />
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                        </div>
                    </div>


                        <div class="row">
                            <!-- বাম পাশের অংশ (ফর্ম) -->
                            <div class="col-12 col-lg-8">
                                <fieldset class="custom-fieldset mt-3">
                                    <legend>Table &amp; Time Information</legend>
                                    <div class="field-grid">
                                        <div class="field-item">
                                            <label>Day Target</label>
                                            <asp:TextBox ID="txtDayTarget" runat="server" CssClass="form-control" />
                                        </div>
                                        <div class="field-item">
                                            <label>Table</label>
                                            <asp:DropDownList ID="ddlTable" runat="server" CssClass="form-select"></asp:DropDownList>
                                        </div>
                                        <div class="field-item">
                                            <label>Table Cut. Man</label>
                                            <asp:TextBox ID="txtTableCutterMan" runat="server" CssClass="form-control" />
                                        </div>
                                        <div class="field-item">
                                            <label>Table Cut. Assis.</label>
                                            <asp:TextBox ID="txtTableCutterAssistant" runat="server" CssClass="form-control" />
                                        </div>
                                        <div class="field-item">
                                            <label>Marker Pcs</label>
                                            <asp:TextBox ID="txtMarkerPcs" runat="server" CssClass="form-control" />
                                        </div>

                                        <div class="field-item">
                                            <label>Lay Qty</label>
                                            <asp:TextBox ID="txtLayQty" runat="server" CssClass="form-control" />
                                        </div>
                                        <div class="field-item">
                                            <label>Req. Min</label>
                                            <asp:TextBox ID="txtReqMin" runat="server" CssClass="form-control" />
                                        </div>
                                        <div class="field-item">
                                            <label>Hour</label>
                                            <asp:TextBox ID="txtHour" runat="server" CssClass="form-control" />
                                        </div>
                                        <div class="field-item">
                                            <label>Plan Start Time</label>
                                            <asp:DropDownList ID="ddlPlanStartTime" runat="server" CssClass="form-select"></asp:DropDownList>
                                        </div>
                                        <div class="field-item">
                                            <label>Plan End Time</label>
                                            <asp:DropDownList ID="ddlPlanEndTime" runat="server" CssClass="form-select"></asp:DropDownList>
                                        </div>

                                        <div class="field-item">
                                            <label>T. Eff%</label>
                                            <asp:TextBox ID="txtTEff" runat="server" CssClass="form-control" />
                                        </div>
                                        <div class="field-item">
                                            <label>W. Hour</label>
                                            <asp:TextBox ID="txtWHour" runat="server" CssClass="form-control" />
                                        </div>
                                        <div class="field-item">
                                            <label>Total</label>
                                            <asp:TextBox ID="txtTotal" runat="server" CssClass="form-control" />
                                        </div>
                                        <div class="field-btn-align">
                                            <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="btn btn-success w-100" />
                                        </div>
                                        <div class="span-3">
                                            <label>Remarks</label>
                                            <asp:TextBox ID="txtRemark" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control" />
                                        </div>
                                    </div>
                                </fieldset>
                            </div>

                            <!-- ডান পাশের অংশ (গ্রিডভিউ) -->
                            <div class="col-12 col-lg-4 mt-3">
                                <div class="side-grid-wrapper">
                                    <asp:GridView ID="GridView1" runat="server" CssClass="table table-bordered table-hover mb-0" Width="100%"></asp:GridView>
                                </div>
                            </div>
                        </div>


                </div>
            </div>

            <!-- Details List Card -->
            <div class="card shadow">
                <div class="card-header bg-success text-white">
                    <i class="bi bi-list-check"></i>
                    <h4>Cutting Target &amp; Manpower List</h4>
                </div>
                <div class="grid-wrapper">
                    <asp:GridView ID="GridView2" runat="server" CssClass="table table-bordered table-hover mb-0" Width="100%"></asp:GridView>
                </div>

                <div class="card-body-tight">
                    <div class="action-bar">
                        <div class="btn-group-left">
                            <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn btn-secondary" />
                            <div class="form-check d-flex align-items-center gap-1 mb-0">
                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input accent-success" />
                                <asp:Label AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="form-check-label fw-bold mb-0"></asp:Label>
                            </div>
                        </div>
                        <div class="btn-group-right">
                            <asp:Button ID="btnCutingTargetSheet" runat="server" Text="Cutting Target Sheet" CssClass="btn btn-primary" />
                            <asp:Button ID="btnShow" runat="server" Text="Show" CssClass="btn btn-primary" />
                            <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success" />
                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-danger" />
                            <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary" />
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </form>
</body>
</html>
