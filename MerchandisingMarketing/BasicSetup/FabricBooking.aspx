<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FabricBooking.aspx.cs" Inherits="Nexa_ERP.MasterConfiguration.BuyerManagement.FabricBooking" MaintainScrollPositionOnPostBack="true" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Garments ERP - Fabric Booking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        :root { --erp-primary:#0f172a; --erp-secondary:#3b82f6; --erp-bg:#f8fafc; --erp-border:#e2e8f0; }
        body { background:var(--erp-bg); font-size:.875rem; font-family:'Segoe UI',Tahoma,sans-serif; color:#334155; }
        .navbar-erp { background:var(--erp-primary); color:#fff; padding:.75rem 1.5rem; }
        .card-erp { background:#fff; border:1px solid var(--erp-border); border-radius:.375rem; margin-bottom:1rem; }
        .card-header-erp { background:#f1f5f9; border-bottom:1px solid var(--erp-border); font-weight:600; padding:.75rem 1rem; }
        .required::after { content:" *"; color:#ef4444; }

        /* uniform labels + controls */
        .form-label { font-size:.72rem; font-weight:600; color:#64748b; text-transform:uppercase; letter-spacing:.3px; margin-bottom:.2rem; }
        .form-control, .form-select, .ms-btn { height:31px; font-size:.82rem; }
        .sect-title { font-size:.74rem; font-weight:700; color:#3b82f6; text-transform:uppercase; letter-spacing:.5px;
                      border-bottom:1px dashed #cbd5e1; padding-bottom:.25rem; margin:.25rem 0 .75rem; }

        .style-card { background:#eef3ff; border:1px solid #d6e0ff; border-radius:.375rem; padding:.75rem; }
        .style-card .lbl { font-size:.72rem; color:#64748b; text-transform:uppercase; letter-spacing:.3px; }
        .style-card .val { font-weight:600; color:#1e293b; font-size:.85rem; }
        .grid-input { width:90px; padding:.15rem .35rem; font-size:.8rem; border:1px solid #ced4da; border-radius:4px; }
        .stock-note { font-size:.75rem; color:#0f5132; background:#d1e7dd; border-radius:4px; padding:2px 8px; }

        .ms-dd .ms-btn { text-align:left; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; width:100%; }
        .ms-dd .dropdown-menu { min-width:100%; max-height:260px; overflow:auto; padding:.5rem .75rem; }
        .ms-list input { margin-right:6px; }
        .ms-list label { cursor:pointer; }
        .ms-list br { display:none; }
        .ms-list span { display:block; padding:2px 0; }

        .fab-in .input-group .form-control { min-width:0; }
        .fab-in .input-group-text { font-size:.75rem; padding:0 .5rem; }
        .fab-tbl .form-select, .fab-tbl .form-control { min-width:0; }
        .fab-tbl select.form-select { min-width:84px; height:auto; }
        .fab-tbl input.grid-input { width:72px; text-align:right; height:auto; }
        .fab-tbl input.fab-txt { width:80px; text-align:left; }
        .fab-tbl th { white-space:nowrap; font-size:.78rem; }
        .fab-tbl td { font-size:.8rem; }
        .part-badge { font-size:.7rem; }
        .fab-tbl th.fab-col, .fab-tbl td.fab-col { min-width:200px; width:200px; }
        .fab-tbl th.po-col, .fab-tbl td.po-col { min-width:170px; }
        .booking-no { font-weight:700; color:#0f172a; background:#f1f5f9; }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <asp:HiddenField ID="hfBookingId" runat="server" Value="0" />
    <asp:HiddenField ID="hfPOId" runat="server" Value="0" />
    <asp:HiddenField ID="hfStyleId" runat="server" Value="0" />

    <nav class="navbar navbar-erp navbar-expand-lg">
        <div class="container-fluid">
            <span class="navbar-brand mb-0 h1 text-white"><i class="bi bi-layers me-2"></i>Garments ERP &gt; Fabric Booking</span>
            <span class="text-light small">Logged in as: <b><asp:Label ID="lblUser" runat="server" /></b></span>
        </div>
    </nav>

    <div class="container-fluid py-3">

        <!-- ============ 1. BOOKING HEADER ============ -->
        <div class="card card-erp">
            <div class="card-header-erp d-flex justify-content-between align-items-center">
                <span><i class="bi bi-journal-text"></i> Booking Information</span>
                <span>
                    <asp:LinkButton ID="btnNew" runat="server" CssClass="btn btn-sm btn-outline-secondary" CausesValidation="false"
                        OnClick="btnNew_Click"><i class="bi bi-file-earmark-plus"></i> New</asp:LinkButton>
                    <asp:LinkButton ID="btnSave" runat="server" CssClass="btn btn-sm btn-primary ms-1"
                        OnClick="btnSave_Click"><i class="bi bi-save"></i> Save Booking</asp:LinkButton>
                </span>
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">Open Existing Booking</label>
                        <asp:DropDownList ID="ddlBooking" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlBooking_SelectedIndexChanged" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Booking No</label>
                        <asp:TextBox ID="txtBookingNo" runat="server" CssClass="form-control booking-no" ReadOnly="true" Text="(Auto Generated)" />
                    </div>
                    <div class="col-md-2">
                        <label class="form-label required">Booking Date</label>
                        <asp:TextBox ID="txtBookingDate" runat="server" CssClass="form-control" TextMode="Date" />
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">Remarks</label>
                        <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control" MaxLength="500" autocomplete="off" />
                    </div>
                </div>
            </div>
        </div>

        <!-- ============ 2. BUYER → STYLE → PO ============ -->
        <div class="card card-erp">
            <div class="card-header-erp"><i class="bi bi-search"></i> Select Buyer &rarr; Style &rarr; PO</div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label required">Buyer</label>
                        <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlBuyer_SelectedIndexChanged" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label required">Style</label>
                        <asp:DropDownList ID="ddlStyle" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlStyle_SelectedIndexChanged" />
                    </div>
                    <div class="col-md-6">
                        <label class="form-label required">PO</label>
                        <asp:DropDownList ID="ddlPO" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlPO_SelectedIndexChanged" />
                    </div>
                </div>
            </div>
        </div>

        <!-- ============ 3. ENTRY (shown after PO selected) ============ -->
        <asp:Panel ID="pnlEntry" runat="server" Visible="false">
            <div class="card card-erp">
                <div class="card-body fab-in">
                    <div class="d-flex justify-content-between align-items-center mb-2 flex-wrap gap-1">
                        <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-layers"></i> Fabric Entry (Color × Part × Size wise)</h6>
                        <span class="stock-note"><i class="bi bi-info-circle"></i> Size ফাঁকা = সব সাইজ (ALL)। Dzn দিলে Pc, Pc দিলে Dzn নিজে হবে। Total = Qty × Cons × (1 + (Process Loss % + Extra Cutting %) / 100)</span>
                    </div>

                    <div class="sect-title">Fabric &amp; Part</div>
                    <div class="row g-3 mb-2">
                        <div class="col-md-3 ms-dd dropdown">
                            <label class="form-label">Colors</label>
                            <button type="button" class="form-select ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="Select colors">Select colors</button>
                            <div class="dropdown-menu">
                                <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                <asp:CheckBoxList ID="cblFabColors" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                            </div>
                        </div>
                        <div class="col-md-3 ms-dd dropdown">
                            <label class="form-label">Style Fabrics</label>
                            <button type="button" class="form-select ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="Select fabrics">Select fabrics</button>
                            <div class="dropdown-menu">
                                <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                <asp:CheckBoxList ID="cblFabrics" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                            </div>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label required">Part</label>
                            <asp:DropDownList ID="ddlFabPart" runat="server" CssClass="form-select">
                                <asp:ListItem>Body</asp:ListItem>
                                <asp:ListItem>Sleeve</asp:ListItem>
                                <asp:ListItem>Collar</asp:ListItem>
                                <asp:ListItem>Cuff</asp:ListItem>
                                <asp:ListItem>Flat Knit Bottom</asp:ListItem>
                                <asp:ListItem>Rib</asp:ListItem>
                                <asp:ListItem>Pocket</asp:ListItem>
                                <asp:ListItem>Other</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2 ms-dd dropdown">
                            <label class="form-label">Sizes <span class="text-muted text-lowercase">(ফাঁকা = ALL)</span></label>
                            <button type="button" class="form-select ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="All sizes">All sizes</button>
                            <div class="dropdown-menu">
                                <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                <asp:CheckBoxList ID="cblFabSizes" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                            </div>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Fabric Form</label>
                            <asp:DropDownList ID="ddlFabForm" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">-- Select --</asp:ListItem>
                                <asp:ListItem>Open</asp:ListItem>
                                <asp:ListItem>Tube</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="row g-3 mb-2">
                        <div class="col-md-2">
                            <label class="form-label">Dia (inch)</label>
                            <asp:TextBox ID="txtFabDia" runat="server" CssClass="form-control" MaxLength="20" placeholder="e.g. 32" autocomplete="off" />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Part Size</label>
                            <asp:TextBox ID="txtFabPartSize" runat="server" CssClass="form-control" MaxLength="50" placeholder="Collar / Cuff / Btm size" autocomplete="off" />
                        </div>
                        <div class="col-md-2">
                            <label class="form-label" title="Cuff + Double হলে Total Kg / Yds ×২ হবে">Ply (Cuff ×2)</label>
                            <asp:DropDownList ID="ddlFabPly" runat="server" CssClass="form-select">
                                <asp:ListItem Value="">--</asp:ListItem>
                                <asp:ListItem>Single</asp:ListItem>
                                <asp:ListItem>Double</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Yarn Dyed</label>
                            <asp:DropDownList ID="ddlFabYarnDyed" runat="server" CssClass="form-select">
                                <asp:ListItem Value="Yes">Yes</asp:ListItem>
                                <asp:ListItem Value="No" Selected="True">No</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-1">
                            <label class="form-label">Loss %</label>
                            <asp:TextBox ID="txtFabLoss" runat="server" CssClass="form-control fab-num" placeholder="0" autocomplete="off" />
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Extra Cutting %</label>
                            <asp:TextBox ID="txtFabExtra" runat="server" CssClass="form-control fab-num" placeholder="0" autocomplete="off" />
                        </div>
                    </div>

                    <div class="sect-title mt-3">Consumption &amp; Rate</div>
                    <div class="row g-3 align-items-end mb-3">
                        <div class="col-md-3">
                            <label class="form-label">Cons (Kg)</label>
                            <div class="input-group input-group-sm">
                                <asp:TextBox ID="txtFabKgDzn" runat="server" CssClass="form-control fab-num" placeholder="Kg / Dzn" data-grp="kg" data-role="dzn" autocomplete="off" />
                                <span class="input-group-text">Dzn</span>
                                <asp:TextBox ID="txtFabKgPc" runat="server" CssClass="form-control fab-num" placeholder="Kg / Pc" data-grp="kg" data-role="pc" autocomplete="off" />
                                <span class="input-group-text">Pc</span>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Cons (Yds)</label>
                            <div class="input-group input-group-sm">
                                <asp:TextBox ID="txtFabYdDzn" runat="server" CssClass="form-control fab-num" placeholder="Yds / Dzn" data-grp="yd" data-role="dzn" autocomplete="off" />
                                <span class="input-group-text">Dzn</span>
                                <asp:TextBox ID="txtFabYdPc" runat="server" CssClass="form-control fab-num" placeholder="Yds / Pc" data-grp="yd" data-role="pc" autocomplete="off" />
                                <span class="input-group-text">Pc</span>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Rate</label>
                            <div class="input-group input-group-sm">
                                <asp:TextBox ID="txtFabRateDzn" runat="server" CssClass="form-control fab-num" placeholder="Rate / Dzn" data-grp="rate" data-role="dzn" autocomplete="off" />
                                <span class="input-group-text">Dzn</span>
                                <asp:TextBox ID="txtFabRatePc" runat="server" CssClass="form-control fab-num" placeholder="Rate / Pc" data-grp="rate" data-role="pc" autocomplete="off" />
                                <span class="input-group-text">Pc</span>
                            </div>
                        </div>
                        <div class="col-md-3 text-end">
                            <asp:LinkButton ID="btnAddFab" runat="server" CssClass="btn btn-sm btn-success px-3"
                                OnClick="btnAddFab_Click"><i class="bi bi-plus-lg"></i> Add to Booking</asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- ============ 4. BOOKING LINES (all PO) ============ -->
        <div class="card card-erp">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-list-check"></i> Booking Lines</h6>
                    <asp:LinkButton ID="btnSyncFabQty" runat="server" CssClass="btn btn-sm btn-outline-secondary"
                        CausesValidation="false" OnClick="btnSyncFabQty_Click"
                        ToolTip="প্রতিটি PO-র Color×Size Qty থেকে সব লাইনের Qty নতুন করে বসাও"><i class="bi bi-arrow-repeat"></i> Sync Qty</asp:LinkButton>
                </div>

                <div class="table-responsive">
                    <asp:GridView ID="gvFab" runat="server" AutoGenerateColumns="false"
                        CssClass="table table-bordered table-sm align-middle fab-tbl"
                        HeaderStyle-CssClass="table-light" GridLines="None"
                        OnRowCommand="gvFab_RowCommand" OnRowDataBound="gvFab_RowDataBound"
                        EmptyDataText="No fabric booking added. Select Buyer → Style → PO, choose colors &amp; fabrics, enter consumption and click Add.">
                        <Columns>
                            <asp:TemplateField HeaderText="PO / Style / Buyer" HeaderStyle-CssClass="po-col" ItemStyle-CssClass="po-col">
                                <ItemTemplate>
                                    <asp:HiddenField ID="hfPOIdRow" runat="server" Value='<%# Eval("POID") %>' />
                                    <asp:HiddenField ID="hfStyleIdRow" runat="server" Value='<%# Eval("StyleID") %>' />
                                    <asp:HiddenField ID="hfPONoRow" runat="server" Value='<%# Eval("PONo") %>' />
                                    <asp:HiddenField ID="hfStyleNoRow" runat="server" Value='<%# Eval("StyleNo") %>' />
                                    <asp:HiddenField ID="hfBuyerRow" runat="server" Value='<%# Eval("BuyerName") %>' />
                                    <b><%# Server.HtmlEncode(Convert.ToString(Eval("PONo"))) %></b>
                                    <div class="text-muted small"><%# Server.HtmlEncode(Convert.ToString(Eval("StyleNo"))) %> | <%# Server.HtmlEncode(Convert.ToString(Eval("BuyerName"))) %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Color">
                                <ItemTemplate><b><asp:Literal ID="litFabColor" runat="server" Mode="Encode" Text='<%# Eval("ColorCode") %>' /></b></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Part">
                                <ItemTemplate><span class="badge bg-dark part-badge fab-part"><asp:Literal ID="litFabPart" runat="server" Mode="Encode" Text='<%# Eval("PartName") %>' /></span></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Size">
                                <ItemTemplate><asp:Literal ID="litFabSize" runat="server" Mode="Encode" Text='<%# Eval("SizeCode") %>' /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Fabric" HeaderStyle-CssClass="fab-col" ItemStyle-CssClass="fab-col">
                                <ItemTemplate>
                                    <asp:Literal ID="litFabCode" runat="server" Mode="Encode" Text='<%# Eval("FabricCode") %>' />
                                    <asp:HiddenField ID="hfFabName" runat="server" Value='<%# Eval("FabricName") %>' />
                                    <div class="text-muted small"><%# Server.HtmlEncode(Convert.ToString(Eval("FabricName"))) %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="GSM">
                                <ItemTemplate><asp:TextBox ID="txtFabGsm" runat="server" CssClass="grid-input fab-txt" Style="width:55px" MaxLength="20" Text='<%# Eval("GSM") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Form">
                                <ItemTemplate>
                                    <asp:DropDownList ID="ddlFabFormRow" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Value="">--</asp:ListItem>
                                        <asp:ListItem>Open</asp:ListItem>
                                        <asp:ListItem>Tube</asp:ListItem>
                                    </asp:DropDownList>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Dia">
                                <ItemTemplate><asp:TextBox ID="txtFabDiaRow" runat="server" CssClass="grid-input fab-txt" Style="width:55px" MaxLength="20" Text='<%# Eval("Dia") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Part Size">
                                <ItemTemplate><asp:TextBox ID="txtFabPartSizeRow" runat="server" CssClass="grid-input fab-txt" MaxLength="50" Text='<%# Eval("PartSize") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Ply">
                                <ItemTemplate>
                                    <asp:DropDownList ID="ddlFabPlyRow" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Value="">--</asp:ListItem>
                                        <asp:ListItem>Single</asp:ListItem>
                                        <asp:ListItem>Double</asp:ListItem>
                                    </asp:DropDownList>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Yarn Dyed">
                                <ItemTemplate>
                                    <asp:DropDownList ID="ddlFabYarnRow" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Value="Yes">Yes</asp:ListItem>
                                        <asp:ListItem Value="No">No</asp:ListItem>
                                    </asp:DropDownList>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Kg / Dzn">
                                <ItemTemplate><asp:TextBox ID="txtFabKgDzn" runat="server" CssClass="grid-input fab-num" data-grp="kg" data-role="dzn" Text='<%# Eval("KgDzn", "{0:0.####}") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Kg / Pc">
                                <ItemTemplate><asp:TextBox ID="txtFabKgPc" runat="server" CssClass="grid-input fab-num" data-grp="kg" data-role="pc" Text='<%# Eval("KgPc", "{0:0.####}") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Yds / Dzn">
                                <ItemTemplate><asp:TextBox ID="txtFabYdDzn" runat="server" CssClass="grid-input fab-num" data-grp="yd" data-role="dzn" Text='<%# Eval("YdDzn", "{0:0.####}") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Yds / Pc">
                                <ItemTemplate><asp:TextBox ID="txtFabYdPc" runat="server" CssClass="grid-input fab-num" data-grp="yd" data-role="pc" Text='<%# Eval("YdPc", "{0:0.####}") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Rate / Dzn">
                                <ItemTemplate><asp:TextBox ID="txtFabRateDzn" runat="server" CssClass="grid-input fab-num" data-grp="rate" data-role="dzn" Text='<%# Eval("RateDzn", "{0:0.####}") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Rate / Pc">
                                <ItemTemplate><asp:TextBox ID="txtFabRatePc" runat="server" CssClass="grid-input fab-num" data-grp="rate" data-role="pc" Text='<%# Eval("RatePc", "{0:0.####}") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Qty (pcs)">
                                <ItemTemplate><asp:TextBox ID="txtFabQty" runat="server" CssClass="grid-input fab-qty" Text='<%# Eval("Qty") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Loss %">
                                <ItemTemplate><asp:TextBox ID="txtFabLoss" runat="server" CssClass="grid-input fab-num" Width="50px" Text='<%# Eval("LossPct", "{0:0.##}") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Extra Cut %">
                                <ItemTemplate><asp:TextBox ID="txtFabExtra" runat="server" CssClass="grid-input fab-num" Width="50px" Text='<%# Eval("ExtraPct", "{0:0.##}") %>' autocomplete="off" /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Total Kg" ItemStyle-CssClass="text-end fw-bold">
                                <ItemTemplate><asp:Label ID="lblFabTotalKg" runat="server" CssClass="fab-tkg" Text='<%# Eval("TotalKg", "{0:N2}") %>' /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Total Yds" ItemStyle-CssClass="text-end fw-bold">
                                <ItemTemplate><asp:Label ID="lblFabTotalYd" runat="server" CssClass="fab-tyd" Text='<%# Eval("TotalYd", "{0:N2}") %>' /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Amount" ItemStyle-CssClass="text-end fw-bold">
                                <ItemTemplate><asp:Label ID="lblFabAmt" runat="server" CssClass="fab-amt" Text='<%# Eval("Amount", "{0:N2}") %>' /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Book?">
                                <ItemTemplate><asp:CheckBox ID="chkBookFab" runat="server" Checked='<%# Eval("IsBooked") %>' /></ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField HeaderText="Action" ItemStyle-Width="70px">
                                <ItemTemplate>
                                    <asp:LinkButton runat="server" CommandName="CopyRow" CommandArgument='<%# Container.DataItemIndex %>'
                                        CausesValidation="false" CssClass="text-primary me-2" ToolTip="Duplicate this line"><i class="bi bi-files"></i></asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="RemoveRow" CommandArgument='<%# Container.DataItemIndex %>'
                                        CausesValidation="false" CssClass="text-danger" ToolTip="Remove"
                                        OnClientClick="return confirm('Remove this row?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
                <div class="text-end fw-bold">
                    Total Kg: <asp:Label ID="lblFabSumKg" runat="server" CssClass="fab-sum-kg" Text="0.00" />
                    &nbsp;|&nbsp; Total Yds: <asp:Label ID="lblFabSumYd" runat="server" CssClass="fab-sum-yd" Text="0.00" />
                    &nbsp;|&nbsp; Amount: <asp:Label ID="lblFabSumAmt" runat="server" CssClass="fab-sum-amt" Text="0.00" />
                </div>
            </div>
        </div>

    </div>
</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
(function () {
    function num(v) { v = parseFloat(String(v).replace(/,/g, '')); return isNaN(v) ? 0 : v; }
    function fmt(v, d) { return v.toLocaleString('en-US', { minimumFractionDigits: d, maximumFractionDigits: d }); }
    function r4(v) { return Math.round(v * 10000) / 10000; }

    /* ---------- multi-select dropdowns ---------- */
    function msRefresh(dd) {
        var btn = dd.querySelector('.ms-btn');
        var boxes = dd.querySelectorAll('.ms-list input[type=checkbox]');
        var names = [], chk = 0;
        boxes.forEach(function (b) {
            if (b.checked) {
                chk++;
                var l = dd.querySelector('label[for="' + b.id + '"]');
                names.push(l ? l.textContent : '');
            }
        });
        btn.textContent = chk === 0 ? btn.getAttribute('data-ph') : (chk <= 3 ? names.join(', ') : chk + ' selected');
        var all = dd.querySelector('.ms-all');
        if (all) all.checked = boxes.length > 0 && chk === boxes.length;
    }
    document.querySelectorAll('.ms-dd').forEach(msRefresh);
    document.addEventListener('change', function (e) {
        var dd = e.target.closest ? e.target.closest('.ms-dd') : null;
        if (!dd) return;
        if (e.target.classList.contains('ms-all')) {
            dd.querySelectorAll('.ms-list input[type=checkbox]').forEach(function (b) { b.checked = e.target.checked; });
        }
        msRefresh(dd);
    });

    /* ---------- Dzn <-> Pc sync ---------- */
    function fabSync(t) {
        var g = t.getAttribute('data-grp'); if (!g) return;
        var scope = t.closest('tr') || t.closest('.fab-in'); if (!scope) return;
        var role = t.getAttribute('data-role');
        var other = scope.querySelector('[data-grp="' + g + '"][data-role="' + (role === 'dzn' ? 'pc' : 'dzn') + '"]');
        if (!other) return;
        if (t.value.trim() === '') { other.value = ''; return; }
        var v = num(t.value);
        other.value = r4(role === 'dzn' ? v / 12 : v * 12);
    }

    function recalcFabRow(tr) {
        if (!tr) return;
        function val(sel) { var el = tr.querySelector(sel); return el ? num(el.value) : 0; }
        var qty = parseInt((tr.querySelector('.fab-qty') || {}).value, 10); if (isNaN(qty)) qty = 0;
        var f = 1 + (val('[id$="txtFabLoss"]') + val('[id$="txtFabExtra"]')) / 100;
        var partEl = tr.querySelector('.fab-part'), plyEl = tr.querySelector('[id$="ddlFabPlyRow"]');
        if (partEl && plyEl && partEl.textContent.trim() === 'Cuff' && plyEl.value === 'Double') f *= 2;
        var kg = qty * f * val('[data-grp="kg"][data-role="pc"]');
        var yd = qty * f * val('[data-grp="yd"][data-role="pc"]');
        var amt = qty * val('[data-grp="rate"][data-role="pc"]');
        var a = tr.querySelector('.fab-tkg'); if (a) a.textContent = fmt(kg, 2);
        var b = tr.querySelector('.fab-tyd'); if (b) b.textContent = fmt(yd, 2);
        var c = tr.querySelector('.fab-amt'); if (c) c.textContent = fmt(amt, 2);
    }

    function recalcFabTotals() {
        var kg = 0, yd = 0, amt = 0;
        document.querySelectorAll('.fab-tkg').forEach(function (s) { kg += num(s.textContent); });
        document.querySelectorAll('.fab-tyd').forEach(function (s) { yd += num(s.textContent); });
        document.querySelectorAll('.fab-amt').forEach(function (s) { amt += num(s.textContent); });
        var x = document.querySelector('.fab-sum-kg'); if (x) x.textContent = fmt(kg, 2);
        var y = document.querySelector('.fab-sum-yd'); if (y) y.textContent = fmt(yd, 2);
        var z = document.querySelector('.fab-sum-amt'); if (z) z.textContent = fmt(amt, 2);
    }

    document.addEventListener('input', function (e) {
        var t = e.target;
        if (t.classList.contains('fab-num')) {
            var clean = t.value.replace(/[^0-9.]/g, '');
            if (clean !== t.value) t.value = clean;
            fabSync(t);
            var tr = t.closest('tr');
            if (tr) { recalcFabRow(tr); recalcFabTotals(); }
        } else if (t.classList.contains('fab-qty')) {
            var clean2 = t.value.replace(/[^0-9]/g, '');
            if (clean2 !== t.value) t.value = clean2;
            recalcFabRow(t.closest('tr')); recalcFabTotals();
        }
    });

    document.addEventListener('change', function (e) {
        var t = e.target;
        if (t.id && t.id.indexOf('ddlFabPlyRow') >= 0) { recalcFabRow(t.closest('tr')); recalcFabTotals(); }
    });

    /* Enter -> next input (grid) */
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        var t = e.target;
        if (t.classList && (t.classList.contains('fab-num') || t.classList.contains('fab-qty'))) {
            e.preventDefault();
            var all = [].slice.call(document.querySelectorAll('.fab-tbl .fab-num, .fab-tbl .fab-qty'));
            var i = all.indexOf(t);
            if (i >= 0 && i < all.length - 1) { all[i + 1].focus(); all[i + 1].select(); }
        }
    });
    document.addEventListener('focusin', function (e) {
        if (e.target.classList && (e.target.classList.contains('fab-num') || e.target.classList.contains('fab-qty')))
            e.target.select();
    });
})();
</script>
</body>
</html>
