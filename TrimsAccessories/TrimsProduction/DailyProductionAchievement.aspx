<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyProductionAchievement.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.TrimsProduction.DailyProductionAchievement" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Daily Production Achievement & Output Entry</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome for Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        .summary-card {
            border-left: 4px solid #198754;
            background: #f8f9fa;
            height: 100%;
        }
        body {
            background-color: #f4f6f9;
        }
        .table-input {
            min-width: 90px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid py-4">

            <!-- Hidden field: tracks the AchievementID currently loaded for edit.
                 "0" = no existing record for this Date+Line+WorkOrder+Item -> Save will INSERT.
                 non-zero = an existing record was found by "Load Target Data" -> Save will UPDATE. -->
            <asp:HiddenField ID="hdnAchievementID" runat="server" Value="0" />

            <!-- Page Header -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card shadow-sm border-0">
                        <div class="card-body bg-white text-dark rounded d-flex justify-content-between align-items-center p-4">
                            <div>
                                <h2 class="h4 mb-1 text-success"><i class="fa-solid fa-chart-line me-2"></i> Daily Production Achievement Entry</h2>
                                <p class="text-muted mb-0 small">Record hourly actual production output, compare with target, and monitor efficiency.</p>
                            </div>
                            <div class="d-flex gap-2 flex-wrap">
                                <asp:Button ID="btnView" runat="server" Text="View Report" CssClass="btn btn-outline-primary px-3" CausesValidation="false" OnClick="btnView_Click" />
                                <asp:Button ID="btnLoadTarget" runat="server" Text="Load Target Data" CssClass="btn btn-outline-success px-3" OnClick="btnLoadTarget_Click" CausesValidation="false" />
                                <asp:Button ID="btnSaveAchievement" runat="server" Text="Save Achievement" CssClass="btn btn-success px-4" OnClick="btnSaveAchievement_Click" CausesValidation="false" />
                                <asp:Button ID="btnClear" runat="server" Text="Clear Form" CssClass="btn btn-secondary px-3" OnClick="btnClear_Click" CausesValidation="false" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Edit-mode banner (shown when Load Target Data finds an already-saved achievement) -->
            <div class="row mb-3">
                <div class="col-12">
                    <asp:Panel ID="pnlEditBanner" runat="server" CssClass="alert alert-warning d-flex align-items-center gap-2 mb-0" Visible="false">
                        <i class="fa-solid fa-pen-to-square"></i>
                        <asp:Label ID="lblEditBanner" runat="server" CssClass="fw-semibold"></asp:Label>
                    </asp:Panel>
                </div>
            </div>

            <!-- Filter & Selection Section -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-success text-white fw-bold">
                    <i class="fa-solid fa-filter me-1"></i> Production Output Criteria
                </div>
                <div class="card-body bg-white">
                    <div class="row g-3">
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Production Date</label>
                            <asp:TextBox ID="txtProdDate" runat="server" CssClass="form-control" TextMode="Date" AutoPostBack="true" OnTextChanged="txtProdDate_TextChanged"></asp:TextBox>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Company</label>
                            <asp:DropDownList ID="ddlCompany" AutoPostBack="true" runat="server" CssClass="form-select" OnSelectedIndexChanged="ddlCompany_SelectedIndexChanged">
                                <asp:ListItem Text="-- Select Company --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Building</label>
                            <asp:DropDownList ID="ddlBuilding" AutoPostBack="true" runat="server" CssClass="form-select" OnSelectedIndexChanged="ddlBuilding_SelectedIndexChanged">
                                <asp:ListItem Text="-- Select Building --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Floor</label>
                            <asp:DropDownList ID="ddlFloor" AutoPostBack="true" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Floor --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Production Line</label>
                            <asp:DropDownList ID="ddlLine" AutoPostBack="true" runat="server" CssClass="form-select" OnSelectedIndexChanged="ddlLine_SelectedIndexChanged">
                                <asp:ListItem Text="-- Select Line --" Value="" />
                            </asp:DropDownList>
                        </div>                        
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Customer / Buyer</label>
                            <asp:DropDownList ID="ddlCustomer" runat="server" AutoPostBack="true" CssClass="form-select" OnSelectedIndexChanged="ddlCustomer_SelectedIndexChanged">
                                <asp:ListItem Text="-- Select Customer --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold small">Work Order No</label>
                            <asp:DropDownList ID="ddlWONo" runat="server" AutoPostBack="true" CssClass="form-select" OnSelectedIndexChanged="ddlWONo_SelectedIndexChanged">
                                <asp:ListItem Text="-- Select Work Order --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold small">Item Name</label>
                            <asp:DropDownList ID="ddlItemName" runat="server" AutoPostBack="true" CssClass="form-select" OnSelectedIndexChanged="ddlItemName_SelectedIndexChanged">
                                <asp:ListItem Text="-- Select Item --" Value="" />
                            </asp:DropDownList>
                            <asp:Label ID="lblItemHint" runat="server" CssClass="text-danger small" Visible="false"></asp:Label>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Total Target Qty</label>
                            <asp:TextBox ID="txtTotalTarget" runat="server" CssClass="form-control form-control-sm text-primary fw-bold" Text="0" ReadOnly="True"></asp:TextBox>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Total Actual Qty</label>
                            <asp:TextBox ID="txtTotalActual" runat="server" CssClass="form-control form-control-sm text-success fw-bold" Text="0" ReadOnly="True"></asp:TextBox>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Achievement (%)</label>
                            <asp:TextBox ID="txtAchievementPercent" runat="server" CssClass="form-control form-control-sm text-danger fw-bold" Text="0%" ReadOnly="True"></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Hourly Output Entry Grid -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                    <span class="fw-bold text-success"><i class="fa-solid fa-table-cells me-1"></i> Hourly Target vs Actual Output Entry</span>
                    <span class="badge bg-success">Live Variance Calculation</span>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <asp:GridView ID="gvHourlyAchievement" runat="server" CssClass="table table-bordered table-striped align-middle" AutoGenerateColumns="false"
                            EmptyDataText="No hourly data loaded. Select Date / Line / Work Order and click 'Load Target Data'.">
                            <Columns>
                                <asp:BoundField DataField="HourSlot" HeaderText="Hour Slot" ItemStyle-Width="20%" />
                                <asp:TemplateField HeaderText="Target Qty" ItemStyle-Width="15%">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtSlotTarget" runat="server" CssClass="form-control form-control-sm slot-target"
                                            Text='<%# Eval("TargetQty") %>' ReadOnly="true" BackColor="#e9ecef"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Actual Output Qty" ItemStyle-Width="20%">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtSlotActual" runat="server" CssClass="form-control form-control-sm slot-actual table-input"
                                            Text='<%# Eval("ActualQty") %>' TextMode="Number"
                                            onchange="calculateAchievementClient()" onkeyup="calculateAchievementClient()"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Difference (+ / -)" ItemStyle-Width="15%">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtSlotVariance" runat="server" CssClass="form-control form-control-sm slot-variance fw-bold text-center"
                                            Text='<%# Eval("Variance") %>' ReadOnly="true"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Downtime / Remarks" ItemStyle-Width="30%">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtSlotRemarks" runat="server" CssClass="form-control form-control-sm" Text='<%# Eval("Remarks") %>' Placeholder="Reason for shortage (if any)"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>

            <!-- General Remarks -->
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <label class="form-label fw-bold">Shift / Line Supervisor Remarks</label>
                    <asp:TextBox ID="txtShiftRemarks" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" Placeholder="Enter overall shift performance notes, machine breakdown details, etc..."></asp:TextBox>
                </div>
            </div>

        </div>
    </form>

    <!-- Bootstrap 5 JS Bundle CDN -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Live Client-Side Calculation Script -->
    <script type="text/javascript">
        // REQ 2: 1st Hour সম্পূর্ণ (Actual Output > 0) না করলে 2nd Hour-এর ইনপুট
        // disabled/লকড থাকবে। প্রতিটা keyup/change-এ এটা রিফ্রেশ হবে।
        function enforceSequentialHourEntry() {
            var rows = document.querySelectorAll('#<%= gvHourlyAchievement.ClientID %> tr');
            var previousHourFilled = true; // 1st hour সবসময় খোলা থাকবে

            for (var i = 1; i < rows.length; i++) {
                var row = rows[i];
                var actualInput = row.querySelector('.slot-actual');
                if (!actualInput) continue;

                if (previousHourFilled) {
                    actualInput.disabled = false;
                    actualInput.title = "";
                } else {
                    actualInput.disabled = true;
                    actualInput.title = "আগের Hour-এর Actual Output আগে দিন";
                }

                var val = parseFloat(actualInput.value) || 0;
                previousHourFilled = (!actualInput.disabled) && val > 0;
            }
        }

        function calculateAchievementClient() {
            var rows = document.querySelectorAll('#<%= gvHourlyAchievement.ClientID %> tr');
            var totalTarget = 0;
            var totalActual = 0;

            for (var i = 1; i < rows.length; i++) {
                var row = rows[i];
                var targetInput = row.querySelector('.slot-target');
                var actualInput = row.querySelector('.slot-actual');
                var varianceInput = row.querySelector('.slot-variance');

                if (targetInput && actualInput && varianceInput) {
                    var targetVal = parseFloat(targetInput.value) || 0;
                    var actualVal = parseFloat(actualInput.value) || 0;
                    var variance = actualVal - targetVal;

                    varianceInput.value = variance;

                    if (variance >= 0) {
                        varianceInput.style.color = '#198754';
                        varianceInput.value = (variance > 0 ? "+" : "") + variance;
                    } else {
                        varianceInput.style.color = '#dc3545';
                    }

                    totalTarget += targetVal;
                    totalActual += actualVal;
                }
            }

            var txtTotalTarget = document.getElementById('<%= txtTotalTarget.ClientID %>');
            var txtTotalActual = document.getElementById('<%= txtTotalActual.ClientID %>');
            var txtAchPercent = document.getElementById('<%= txtAchievementPercent.ClientID %>');

            if (txtTotalTarget) txtTotalTarget.value = totalTarget;
            if (txtTotalActual) txtTotalActual.value = totalActual;

            if (txtAchPercent && totalTarget > 0) {
                var percent = ((totalActual / totalTarget) * 100).toFixed(1);
                txtAchPercent.value = percent + "%";
            } else if (txtAchPercent) {
                txtAchPercent.value = "0%";
            }

            // REQ 2: প্রতিবার calculation refresh হওয়ার সাথে সাথে lock/unlock-ও refresh হবে
            enforceSequentialHourEntry();
        }

        document.addEventListener('DOMContentLoaded', function () {
            calculateAchievementClient();
        });
    </script>
   
</body>
</html>
