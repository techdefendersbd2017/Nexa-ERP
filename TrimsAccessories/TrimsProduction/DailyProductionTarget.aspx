<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyProductionTarget.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.TrimsProduction.DailyProductionTarget" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Daily Production Target & Planning</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome for Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        .summary-card {
            border-left: 4px solid #0d6efd;
            background: #f8f9fa;
            height: 100%;
        }
        body {
            background-color: #f4f6f9;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid py-4">

            <!-- Page Header -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card shadow-sm border-0">
                        <div class="card-body bg-white text-dark rounded d-flex justify-content-between align-items-center p-4">
                            <div>
                                <h2 class="h4 mb-1 text-primary"><i class="fa-solid fa-bullseye me-2"></i> Daily Production Target</h2>
                                <p class="text-muted mb-0 small">Set, distribute and monitor daily production targets by line/section efficiently.</p>
                            </div>
                            <div class="d-flex gap-2 flex-wrap">
                                <asp:Button ID="btnView" runat="server" Text="View Report" CssClass="btn btn-outline-primary px-3" CausesValidation="false" OnClick="btnView_Click" />
                                <asp:Button ID="btnCalculate" runat="server" Text="Calculate SMV/Capacity" CssClass="btn btn-outline-primary px-3" OnClick="btnCalculate_Click" CausesValidation="false" />
                                <asp:Button ID="btnAddItem" runat="server" Text="+ Add Item to List" CssClass="btn btn-primary px-3" OnClick="btnAddItem_Click" CausesValidation="false" />
                                <asp:Button ID="btnSaveTarget" runat="server" Text="Save All Targets" CssClass="btn btn-success px-4" OnClick="btnSaveTarget_Click" CausesValidation="false" />

                                <!-- Edit-mode only buttons: hidden by default, shown by SetEditModeUI() -->
                                <asp:Button ID="btnUpdateTarget" runat="server" Text="Update Entry" CssClass="btn btn-warning px-4" OnClick="btnUpdateTarget_Click" CausesValidation="false" Visible="false" />
                                <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel Edit" CssClass="btn btn-outline-secondary px-3" OnClick="btnCancelEdit_Click" CausesValidation="false" Visible="false" />

                                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary px-3" OnClick="btnClear_Click" CausesValidation="false" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Edit-mode banner -->
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
                <div class="card-header bg-primary text-white fw-bold">
                    <i class="fa-solid fa-filter me-1"></i> Target Configuration Criteria
                </div>
                <div class="card-body bg-white">
                    <div class="row g-3">
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Target Date</label>
                            <asp:TextBox ID="txtTargetDate" runat="server" CssClass="form-control" TextMode="Date" AutoPostBack="true" OnTextChanged="txtTargetDate_TextChanged"></asp:TextBox>
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
                            <label class="form-label fw-bold small">Customer</label>
                            <asp:DropDownList ID="ddlCustomer" runat="server" AutoPostBack="true" CssClass="form-select" OnSelectedIndexChanged="ddlBuyer_SelectedIndexChanged">
                                <asp:ListItem Text="-- Select Customer --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Work Order No</label>
                            <asp:DropDownList ID="ddlWONo" runat="server" AutoPostBack="true" CssClass="form-select" OnSelectedIndexChanged="ddlWONo_SelectedIndexChanged">
                                <asp:ListItem Text="-- Select Work Order --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Item / Product Name</label>
                            <asp:DropDownList ID="ddlItemName" runat="server"  CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlItemName_SelectedIndexChanged">
                                <asp:ListItem Text="-- Select Item --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Order Quantity</label>                            
                            <asp:TextBox ID="txtOrderQty" runat="server" CssClass="form-control form-control-sm" TextMode="Number" Text="0" Placeholder="e.g., 10" ReadOnly="True"></asp:TextBox>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Production Complete Qty</label>                            
                            <asp:TextBox ID="txtProductionCompleteQty" runat="server" CssClass="form-control form-control-sm" TextMode="Number" Text="0" Placeholder="e.g., 10" ReadOnly="True"></asp:TextBox>
                        </div>                        
                        <div class="col-md-2">
                            <label class="form-label fw-bold small">Production Due Qty</label>                            
                            <asp:TextBox ID="txtProductionDueQty" runat="server" CssClass="form-control form-control-sm" TextMode="Number" Text="0" Placeholder="e.g., 10" ReadOnly="True"></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Existing Entries for Selected Date & Section -->
            <div class="row mb-4">
                <div class="col-12">
                    <asp:Panel ID="pnlExistingEntries" runat="server" Visible="false">
                        <div class="card shadow-sm border-0">
                            <div class="card-header bg-warning-subtle fw-bold">
                                <i class="fa-solid fa-clock-rotate-left me-1"></i> Previous entry for this date and section
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <asp:GridView ID="gvExistingEntries" runat="server" CssClass="table table-sm table-bordered align-middle mb-0" AutoGenerateColumns="false" OnRowCommand="gvExistingEntries_RowCommand">
                                        <Columns>
                                            <asp:BoundField DataField="TargetID" HeaderText="ID" ItemStyle-Width="5%" />
                                            <asp:BoundField DataField="ItemName" HeaderText="Item" />
                                            <asp:BoundField DataField="Operator" HeaderText="Operator" />
                                            <asp:BoundField DataField="Helper" HeaderText="Helper" />
                                            <asp:BoundField DataField="WorkingHours" HeaderText="Working Hrs" />
                                            <asp:BoundField DataField="PerHourTarget" HeaderText="Per Hr Target" />
                                            <asp:BoundField DataField="TotalTargetQty" HeaderText="Total Qty" />
                                            <asp:TemplateField HeaderText="Action" ItemStyle-Width="10%">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkEditEntry" runat="server" CssClass="btn btn-sm btn-outline-primary me-1"
                                                        CommandName="EditEntry" CommandArgument='<%# Eval("TargetID") %>'
                                                        ToolTip="Edit this entry" CausesValidation="false">
                                                        <i class="fa-solid fa-pen"></i>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="lnkDeleteEntry" runat="server" CssClass="btn btn-sm btn-outline-danger"
                                                        CommandName="DeleteEntry" CommandArgument='<%# Eval("TargetID") %>'
                                                        OnClientClick="return confirm('Are you sure you want to permanently delete this entry?');"
                                                        ToolTip="Delete this entry" CausesValidation="false">
                                                        <i class="fa-solid fa-trash"></i>
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </div>
                        </div>
                    </asp:Panel>
                </div>
            </div>

            <!-- Target Metrics & Calculation Panel -->
            <div class="row g-3 mb-4">
                <!-- Manpower Card -->
                <div class="col-md-3">
                    <div class="card summary-card shadow-sm p-3">
                        <div class="fw-bold text-primary mb-2 small"><i class="fa-solid fa-users me-1"></i> Total Manpower</div>
                        <div class="row g-2 mb-2">
                            <div class="col-6">
                                <label class="text-muted small mb-1 d-block">Operator</label>
                                <asp:TextBox ID="txtOperator" runat="server" CssClass="form-control form-control-sm" TextMode="Number" Placeholder="e.g., 25"></asp:TextBox>
                            </div>
                            <div class="col-6">
                                <label class="text-muted small mb-1 d-block">Helper</label>
                                <asp:TextBox ID="txtHelper" runat="server" CssClass="form-control form-control-sm" TextMode="Number" Placeholder="e.g., 10"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Hours & Per Hour Target -->
                <div class="col-md-3">
                    <div class="card summary-card shadow-sm p-3" style="border-left-color: #198754;">
                        <div class="fw-bold text-success mb-2 small"><i class="fa-solid fa-clock me-1"></i> Working & Hourly Plan</div>
                        <div class="row g-2 mb-2">
                            <div class="col-6">
                                <label class="text-muted small mb-1 d-block">Working Hours</label>
                                <asp:TextBox ID="txtWorkingHours" runat="server" CssClass="form-control form-control-sm" Text="0" TextMode="Number"
                                    AutoPostBack="true" OnTextChanged="txtWorkingHours_TextChanged"></asp:TextBox>
                            </div>
                            <div class="col-6">
                                <label class="text-muted small mb-1 d-block">Per Hour Target</label>
                                <asp:TextBox ID="txtParHRTaget" runat="server" CssClass="form-control form-control-sm" Text="0" TextMode="Number"
                                    AutoPostBack="true" OnTextChanged="txtParHRTaget_TextChanged"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SMV & Efficiency -->
                <div class="col-md-3">
                    <div class="card summary-card shadow-sm p-3" style="border-left-color: #ffc107;">
                        <div class="fw-bold text-warning mb-2 small"><i class="fa-solid fa-gauge-high me-1"></i> Performance Metrics</div>
                        <div class="row g-2 mb-2">
                            <div class="col-6">
                                <label class="text-muted small mb-1 d-block">Style SMV</label>
                                <asp:TextBox ID="txtSMV" runat="server" CssClass="form-control form-control-sm" TextMode="Number" step="0.01" Placeholder="e.g., 18.5"></asp:TextBox>
                            </div>
                            <div class="col-6">
                                <label class="text-muted small mb-1 d-block">Efficiency (%)</label>
                                <asp:TextBox ID="txtEfficiency" runat="server" CssClass="form-control form-control-sm" Text="0" TextMode="Number" step="1"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Output Summary -->
                <div class="col-md-3">
                    <div class="card summary-card shadow-sm p-3" style="border-left-color: #dc3545;">
                        <div class="fw-bold text-danger mb-2 small"><i class="fa-solid fa-flag-checkered me-1"></i> Output Summary</div>
                        <div class="row g-2 mb-2">
                            <div class="col-6">
                                <label class="text-muted small mb-1 d-block">Total Target Hours</label>
                                <asp:TextBox ID="txtTotalHours" runat="server" CssClass="form-control form-control-sm" Text="0" TextMode="Number" step="1" ReadOnly="true" style="background-color: #fff; font-size: 1.1rem; font-weight: bold; color: #dc3545;"></asp:TextBox>
                            </div>
                            <div class="col-6">
                                <label class="text-muted small mb-1 d-block">Total Target Qty</label>
                                <asp:TextBox ID="txtTotalTargetQty" runat="server" CssClass="form-control form-control-sm" Text="0" TextMode="Number" step="1" ReadOnly="true" style="background-color: #fff; font-size: 1.1rem; font-weight: bold; color: #dc3545;"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Calculate SMV/Capacity Result Banner -->
            <div class="row mb-4">
                <div class="col-12">
                    <asp:Panel ID="pnlCalcResult" runat="server" CssClass="alert alert-info d-flex align-items-center gap-2 mb-0" Visible="false">
                        <i class="fa-solid fa-circle-info"></i>
                        <asp:Label ID="lblCalcResult" runat="server" CssClass="fw-semibold"></asp:Label>
                    </asp:Panel>
                </div>
            </div>
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                    <span class="fw-bold text-primary"><i class="fa-solid fa-table-list me-1"></i> Hourly Production Breakdown Target</span>
                    <span class="badge bg-secondary">Total Target Auto-Distributed</span>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <asp:GridView ID="gvHourlyTarget" runat="server" CssClass="table table-bordered table-striped align-middle" AutoGenerateColumns="false">
                            <Columns>
                                <asp:BoundField DataField="HourSlot" HeaderText="Hour Slot" ItemStyle-Width="30%" />
                                <asp:TemplateField HeaderText="Target Qty" ItemStyle-Width="30%">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtHourlyQty" runat="server" CssClass="form-control form-control-sm hourly-qty-input"
                                            Text='<%# Eval("TargetQty") %>' TextMode="Number"
                                            onchange="calculateSummaryClient()" onkeyup="calculateSummaryClient()"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Remarks / Plan Note" ItemStyle-Width="40%">
                                    <ItemTemplate>
                                        <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control form-control-sm" Placeholder="Optional note"></asp:TextBox>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <!-- Pending Items (Add করা Item গুলো, Save All চাপার আগ পর্যন্ত এখানে জমা থাকবে) -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
                    <span class="fw-bold"><i class="fa-solid fa-list-check me-1"></i> Pending Items </span>
                    <span class="badge bg-light text-dark">Total: <asp:Label ID="lblPendingCount" runat="server" Text="0" /></span>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <asp:GridView ID="gvPendingItems" runat="server" CssClass="table table-sm table-bordered align-middle mb-0"
                            AutoGenerateColumns="false" OnRowCommand="gvPendingItems_RowCommand"
                            EmptyDataText="No items have been added yet. Please fill in the form and click Add Item to List.">
                            <Columns>
                                <asp:BoundField DataField="ItemName" HeaderText="Item" />
                                <asp:BoundField DataField="Operator" HeaderText="Operator" />
                                <asp:BoundField DataField="Helper" HeaderText="Helper" />
                                <asp:BoundField DataField="WorkingHours" HeaderText="Working Hrs" />
                                <asp:BoundField DataField="PerHourTarget" HeaderText="Per Hr Target" />
                                <asp:BoundField DataField="TotalTargetQty" HeaderText="Total Qty" />
                                <asp:TemplateField HeaderText="Action" ItemStyle-Width="8%">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkRemove" runat="server" CssClass="btn btn-sm btn-outline-danger"
                                            CommandName="RemovePending" CommandArgument='<%# Eval("SL") %>'
                                            OnClientClick="return confirm('Are you sure you want to remove this item from the list?');"
                                            CausesValidation="false">
                                            <i class="fa-solid fa-trash"></i>
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
            <!-- Additional Remarks -->
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <label class="form-label fw-bold">General Target Remarks / Management Notes</label>
                    <asp:TextBox ID="txtTargetRemarks" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" Placeholder="Enter any special instruction regarding today's target..."></asp:TextBox>
                </div>
            </div>

        </div>
    </form>

    <!-- Bootstrap 5 JS Bundle CDN -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Live (no-postback) Output Summary calculation as the user types in the hourly grid -->
    <script type="text/javascript">
        function calculateSummaryClient() {
            var qtyInputs = document.querySelectorAll('.hourly-qty-input');
            var totalQty = 0;
            var totalHours = qtyInputs.length;

            qtyInputs.forEach(function (input) {
                var val = parseFloat(input.value);
                if (!isNaN(val)) {
                    totalQty += val;
                }
            });

            var totalHoursBox = document.getElementById('<%= txtTotalHours.ClientID %>');
            var totalQtyBox = document.getElementById('<%= txtTotalTargetQty.ClientID %>');

            if (totalHoursBox) totalHoursBox.value = totalHours;
            if (totalQtyBox) totalQtyBox.value = totalQty;
        }

        document.addEventListener('DOMContentLoaded', function () {
            calculateSummaryClient();
        });
    </script>
</body>
</html>
