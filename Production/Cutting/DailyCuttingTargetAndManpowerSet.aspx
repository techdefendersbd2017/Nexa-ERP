<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyCuttingTargetAndManpowerSet.aspx.cs" Inherits="Nexa_ERP.Production.Cutting.DailyCuttingTargetAndManpowerSet" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Daily Cutting Target</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet" />

    <style>
        :root {
            --primary: #4f46e5;
            --primary-soft: #eef2ff;
            --success: #059669;
            --success-soft: #ecfdf5;
            --danger: #e11d48;
            --warning-soft: #fffbeb;
            --ink: #0f172a;
            --muted: #64748b;
            --line: #e2e8f0;
            --page: #f1f5f9;
            --card: #ffffff;
            --radius: 16px;
        }
        * { font-family: 'Plus Jakarta Sans', 'Segoe UI', Arial, sans-serif; }
        body { background: var(--page); color: var(--ink); margin: 0; }
        .wrap { padding: 20px 24px 40px; max-width: 1800px; margin: 0 auto; }

        .page-head { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 18px; }
        .page-head .title { display: flex; align-items: center; gap: 14px; }
        .page-head .icon { width: 46px; height: 46px; border-radius: 14px; display: grid; place-items: center; color: #fff; font-size: 1.3rem;
            background: linear-gradient(135deg, #6366f1, #4338ca); box-shadow: 0 8px 18px rgba(79, 70, 229, .3); }
        .page-head h1 { font-size: 1.3rem; font-weight: 700; margin: 0; }
        .page-head small { color: var(--muted); }
        .badge-date { background: var(--card); border: 1px solid var(--line); border-radius: 999px; padding: 6px 14px; font-size: .82rem; font-weight: 600; color: var(--muted); }

        .panel { background: var(--card); border: 1px solid var(--line); border-radius: var(--radius); box-shadow: 0 1px 2px rgba(15, 23, 42, .04), 0 6px 20px rgba(15, 23, 42, .04); height: 100%; }
        .panel-head { display: flex; align-items: center; gap: 8px; padding: 12px 18px; border-bottom: 1px solid var(--line); font-weight: 700; font-size: .92rem; }
        .panel-head i { color: var(--primary); }
        .panel-body { padding: 16px 18px; }

        label.lbl { font-size: .72rem; font-weight: 600; text-transform: uppercase; letter-spacing: .4px; color: var(--muted); margin-bottom: 4px; display: block; }
        label.lbl .req { color: var(--danger); }
        .form-control, .form-select { border-radius: 10px; border: 1px solid #cbd5e1; font-size: .88rem; padding: 7px 11px; background-color: #fff; }
        .form-control:focus, .form-select:focus { border-color: var(--primary); box-shadow: 0 0 0 4px rgba(79, 70, 229, .12); }
        .form-control[readonly], .form-control:disabled { background: #f8fafc; color: #475569; }

        .btn { border-radius: 10px; font-weight: 600; font-size: .85rem; padding: 8px 18px; border: 0; display: inline-flex; align-items: center; gap: 6px; transition: transform .1s, box-shadow .15s; }
        .btn:hover { transform: translateY(-1px); }
        .btn-primary { background: linear-gradient(135deg, #6366f1, #4338ca); color: #fff; box-shadow: 0 6px 14px rgba(79, 70, 229, .25); }
        .btn-success { background: linear-gradient(135deg, #10b981, #059669); color: #fff; box-shadow: 0 6px 14px rgba(5, 150, 105, .25); }
        .btn-danger { background: var(--danger); color: #fff; }
        .btn-ghost { background: #fff; border: 1px solid #cbd5e1; color: #334155; }
        .btn-icon { width: 38px; height: 38px; padding: 0; justify-content: center; border-radius: 10px; }

        .balance { display: grid; grid-template-columns: repeat(6, 1fr); gap: 12px; }
        .stat { background: var(--primary-soft); border-radius: 12px; padding: 10px 14px; }
        .stat span { display: block; font-size: .7rem; text-transform: uppercase; letter-spacing: .4px; color: var(--muted); font-weight: 600; }
        .stat .form-control { border: 0; background: transparent; padding: 0; font-weight: 700; font-size: 1.1rem; color: var(--primary); box-shadow: none; }
        .stat.warn { background: var(--warning-soft); }
        .stat.warn .form-control { color: #b45309; }
        .stat.ok { background: var(--success-soft); }
        .stat.ok .form-control { color: var(--success); }

        .grid-scroll { overflow-x: auto; }
        .grid-scroll table { width: 100%; white-space: nowrap; font-size: .86rem; margin: 0; border-collapse: separate; border-spacing: 0; }
        .grid-scroll th { background: #f8fafc; color: var(--muted); font-size: .72rem; text-transform: uppercase; letter-spacing: .4px; padding: 11px 14px; border-bottom: 1px solid var(--line); text-align: left; }
        .grid-scroll td { padding: 10px 14px; border-bottom: 1px solid #f1f5f9; }
        .grid-scroll tr:hover td { background: #fafbff; }
        .grid-scroll a.act { color: var(--primary); margin-right: 8px; }
        .grid-scroll a.act.del { color: var(--danger); }

        .total-bar { display: flex; justify-content: flex-end; padding: 12px 18px; }
        .total-pill { background: var(--primary-soft); color: var(--primary); font-weight: 700; padding: 8px 18px; border-radius: 999px; }

        .action-bar { position: sticky; bottom: 0; background: rgba(255, 255, 255, .9); backdrop-filter: blur(8px); border: 1px solid var(--line); border-radius: var(--radius);
            padding: 12px 18px; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 10px; margin-top: 16px; box-shadow: 0 -4px 20px rgba(15, 23, 42, .06); }
        .action-bar .grp { display: flex; flex-wrap: wrap; gap: 10px; align-items: center; }

        @media (max-width: 991.98px) { .balance { grid-template-columns: repeat(2, 1fr); } .wrap { padding: 14px; } }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfUserId" runat="server" />

        <div class="wrap">

            <!-- Page Header -->
            <div class="page-head">
                <div class="title">
                    <div class="icon"><i class="bi bi-scissors"></i></div>
                    <div>
                        <h1>Daily Cutting Target &amp; Manpower</h1>
                        <small>Production &rsaquo; Cutting &rsaquo; Daily Target Set</small>
                    </div>
                </div>
                <span class="badge-date"><i class="bi bi-calendar3 me-1"></i>Cutting Section</span>
            </div>

            <div class="row g-3">

                <!-- LEFT: main area -->
                <div class="col-12">
                    <div class="row g-3">

                        <!-- Filter -->
                        <div class="col-12 col-lg-6">
                            <div class="panel">
                                <div class="panel-head"><i class="bi bi-funnel"></i> Filter</div>
                                <div class="panel-body">
                                    <div class="row g-3">
                                        <div class="col-12 col-md-6">
                                            <label class="lbl">Date</label>
                                            <div class="d-flex gap-2">
                                                <asp:TextBox ID="txtDate" runat="server" CssClass="form-control" TextMode="Date" />
                                                <asp:Button ID="btnCopy" runat="server" Text="Copy" CssClass="btn btn-ghost"
                                                    OnClick="btnCopy_Click" />
                                            </div>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <label class="lbl">Floor</label>
                                            <asp:DropDownList ID="ddlFloor" runat="server" CssClass="form-select"
                                                AutoPostBack="true" OnSelectedIndexChanged="ddlFloor_SelectedIndexChanged"></asp:DropDownList>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <label class="lbl">Table</label>
                                            <asp:DropDownList ID="ddlTable" runat="server" CssClass="form-select"
                                                AutoPostBack="true" OnSelectedIndexChanged="ddlTable_SelectedIndexChanged"></asp:DropDownList>
                                        </div>
                                        <div class="col-12 col-md-6">
                                            <label class="lbl">Remarks</label>
                                            <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control" placeholder="Remarks" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Target & Manpower -->
                        <div class="col-12 col-lg-6">
                            <div class="panel">
                                <div class="panel-head"><i class="bi bi-bullseye"></i> Target &amp; Manpower</div>
                                <div class="panel-body">
                                    <div class="row g-3">
                                        <div class="col-4">
                                            <label class="lbl">Tgt Hour</label>
                                            <asp:TextBox ID="txtTargetHour" runat="server" CssClass="form-control"
                                                AutoPostBack="true" OnTextChanged="txtTargetHour_TextChanged" />
                                        </div>
                                        <div class="col-4">
                                            <label class="lbl">Calc. Hour</label>
                                            <asp:TextBox ID="txtCalculativeHour" runat="server" CssClass="form-control" ReadOnly="true" />
                                        </div>
                                        <div class="col-4">
                                            <label class="lbl">Tgt Effi %</label>
                                            <asp:TextBox ID="txtTargetEfficiency" runat="server" CssClass="form-control" ReadOnly="true" />
                                        </div>
                                        <div class="col-6">
                                            <label class="lbl">Cutting Man</label>
                                            <asp:TextBox ID="txtCuttingMan" runat="server" CssClass="form-control" />
                                        </div>
                                        <div class="col-6">
                                            <label class="lbl">Cutting Assistant</label>
                                            <asp:TextBox ID="txtCuttingAssistant" runat="server" CssClass="form-control" />
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Balance -->
                        <div class="col-12">
                            <div class="panel">
                                <div class="panel-body">
                                    <div class="balance">
                                        <div class="stat"><span>Order Qty</span><asp:TextBox ID="txtOrderQty" runat="server" CssClass="form-control" Text="0" ReadOnly="true" /></div>
                                        <div class="stat"><span>Plan Cut Qty</span><asp:TextBox ID="txtPlanCutQty" runat="server" CssClass="form-control" Text="0" ReadOnly="true" /></div>
                                        <div class="stat"><span>Cut Qty</span><asp:TextBox ID="txtCutQty" runat="server" CssClass="form-control" Text="0" ReadOnly="true" /></div>
                                        <div class="stat ok"><span>Cut Balance</span><asp:TextBox ID="txtCutBalance" runat="server" CssClass="form-control" Text="0" ReadOnly="true" /></div>
                                        <div class="stat warn"><span>Upper Limit</span><asp:TextBox ID="txtUpperLimit" runat="server" CssClass="form-control" Text="0" ReadOnly="true" /></div>
                                        <div class="stat"><span>Cut. SMV</span><asp:TextBox ID="txtCutSMV" runat="server" CssClass="form-control" Text="0.00" ReadOnly="true" /></div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Entry form -->
                        <div class="col-12">
                            <div class="panel">
                                <div class="panel-head"><i class="bi bi-plus-square"></i> Order &amp; Table Entry</div>
                                <div class="panel-body">
                                    <div class="row g-3">
                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Buyer</label>
                                            <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="form-select"
                                                AutoPostBack="true" OnSelectedIndexChanged="ddlBuyer_SelectedIndexChanged"></asp:DropDownList>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Style No</label>
                                            <asp:DropDownList ID="ddlStyleNo" runat="server" CssClass="form-select"
                                                AutoPostBack="true" OnSelectedIndexChanged="ddlStyleNo_SelectedIndexChanged"></asp:DropDownList>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <label class="lbl">PO No</label>
                                            <asp:DropDownList ID="ddlPoNo" runat="server" CssClass="form-select"
                                                AutoPostBack="true" OnSelectedIndexChanged="ddlPoNo_SelectedIndexChanged"></asp:DropDownList>
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Color</label>
                                            <asp:DropDownList ID="ddlColor" runat="server" CssClass="form-select"
                                                AutoPostBack="true" OnSelectedIndexChanged="ddlColor_SelectedIndexChanged"></asp:DropDownList>
                                        </div>

                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Day Target</label>
                                            <asp:TextBox ID="txtDayTarget" runat="server" CssClass="form-control" Text="0" />
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Marker Pcs <span class="req">*</span></label>
                                            <asp:TextBox ID="txtMarkerPcs" runat="server" CssClass="form-control" Text="0" />
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Lay Qty <span class="req">*</span></label>
                                            <asp:TextBox ID="txtLayQty" runat="server" CssClass="form-control" Text="0" />
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Req. Min <span class="req">*</span></label>
                                            <asp:TextBox ID="txtReqMin" runat="server" CssClass="form-control" Text="0" />
                                        </div>

                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Hour</label>
                                            <asp:TextBox ID="txtHour" runat="server" CssClass="form-control" Text="0" ReadOnly="true" />
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Plan Start Time</label>
                                            <asp:TextBox ID="txtPlanStartTime" runat="server" CssClass="form-control" TextMode="Time" />
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Plan End Time</label>
                                            <asp:TextBox ID="txtPlanEndTime" runat="server" CssClass="form-control" TextMode="Time" />
                                        </div>
                                        <div class="col-6 col-md-3">
                                            <label class="lbl">Remarks</label>
                                            <asp:TextBox ID="txtRemark" runat="server" CssClass="form-control" placeholder="Remarks" />
                                        </div>

                                        <div class="col-12 d-flex gap-2">
                                            <asp:LinkButton ID="btnAdd" runat="server" CssClass="btn btn-primary"
                                                OnClick="btnAdd_Click"><i class="bi bi-plus-circle"></i> Add</asp:LinkButton>
                                            <asp:LinkButton ID="btnClearRow" runat="server" CssClass="btn btn-ghost"
                                                OnClick="btnClearRow_Click"><i class="bi bi-trash3"></i> Clear</asp:LinkButton>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- List -->
                        <div class="col-12">
                            <div class="panel">
                                <div class="panel-head"><i class="bi bi-list-check"></i> Cutting Target &amp; Manpower List</div>
                                <div class="grid-scroll">
                                    <asp:GridView ID="GridView2" runat="server" AutoGenerateColumns="false"
                                        GridLines="None" ShowHeaderWhenEmpty="true" EmptyDataText="No data added yet."
                                        OnRowCommand="GridView2_RowCommand">
                                        <Columns>
                                            <asp:TemplateField HeaderText="SL"><ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate></asp:TemplateField>
                                            <asp:BoundField DataField="Buyer" HeaderText="Buyer" />
                                            <asp:BoundField DataField="StyleNo" HeaderText="Style No" />
                                            <asp:BoundField DataField="PoNo" HeaderText="PO No" />
                                            <asp:BoundField DataField="Color" HeaderText="Color" />
                                            <asp:BoundField DataField="SMV" HeaderText="SMV" />
                                            <asp:BoundField DataField="OrderQty" HeaderText="Order Qty" />
                                            <asp:BoundField DataField="CutQty" HeaderText="Cut Qty" />
                                            <asp:BoundField DataField="CutBalance" HeaderText="Cut Balance" />
                                            <asp:BoundField DataField="DayTarget" HeaderText="Day Target" />
                                            <asp:BoundField DataField="MarkerPcs" HeaderText="Marker Pcs" />
                                            <asp:BoundField DataField="LayQty" HeaderText="Lay Qty" />
                                            <asp:BoundField DataField="ReqMin" HeaderText="Req. Min" />
                                            <asp:BoundField DataField="Hour" HeaderText="Hour" />
                                            <asp:BoundField DataField="StartTime" HeaderText="Start Time" />
                                            <asp:BoundField DataField="EndTime" HeaderText="End Time" />
                                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                                            <asp:TemplateField HeaderText="Action">
                                                <ItemTemplate>
                                                    <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Container.DataItemIndex %>' CssClass="act"><i class="bi bi-pencil"></i></asp:LinkButton>
                                                    <asp:LinkButton runat="server" CommandName="DeleteRow" CommandArgument='<%# Container.DataItemIndex %>' CssClass="act del" OnClientClick="return confirm('Delete this row?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                                <div class="total-bar">
                                    <span class="total-pill">Total Day Target: <asp:Label ID="lblTotalDayTarget" runat="server" Text="0"></asp:Label></span>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>

            </div>

            <!-- Action bar -->
            <div class="action-bar">
                <div class="grp">
                    <asp:LinkButton ID="btnRefresh" runat="server" CssClass="btn btn-ghost"
                        OnClick="btnRefresh_Click"><i class="bi bi-arrow-clockwise"></i> Refresh</asp:LinkButton>
                    <div class="form-check form-switch mb-0 ms-2">
                        <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" CssClass="form-check-input" />
                        <label class="form-check-label fw-semibold" for="<%= chkIsActive.ClientID %>">Is Active?</label>
                    </div>
                </div>
                <div class="grp">
                    <asp:LinkButton ID="btnCutingTargetSheet" runat="server" CssClass="btn btn-ghost"
                        OnClick="btnCutingTargetSheet_Click"><i class="bi bi-file-earmark-text"></i> Cutting Target Sheet</asp:LinkButton>
                    <asp:LinkButton ID="btnShow" runat="server" CssClass="btn btn-primary"
                        OnClick="btnShow_Click"><i class="bi bi-eye"></i> Show</asp:LinkButton>
                    <asp:LinkButton ID="btnSave" runat="server" CssClass="btn btn-success"
                        OnClick="btnSave_Click"><i class="bi bi-check2-circle"></i> Save</asp:LinkButton>
                    <asp:LinkButton ID="btnDelete" runat="server" CssClass="btn btn-danger"
                        OnClick="btnDelete_Click"><i class="bi bi-trash"></i> Delete</asp:LinkButton>
                    <asp:LinkButton ID="btnClear" runat="server" CssClass="btn btn-ghost"
                        OnClick="btnClear_Click"><i class="bi bi-x-circle"></i> Clear</asp:LinkButton>
                </div>
            </div>

        </div>
    </form>
</body>
</html>