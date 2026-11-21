<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CostingEntry.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.BasicSetup.CostingEntry" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Garments ERP - Costing</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        :root { --erp-primary:#0f172a; --erp-secondary:#3b82f6; --erp-bg:#f8fafc; --erp-border:#e2e8f0; }
        body { background:var(--erp-bg); font-size:.875rem; font-family:'Segoe UI',Tahoma,sans-serif; color:#334155; }
        .navbar-erp { background:var(--erp-primary); color:#fff; padding:.75rem 1.5rem; }
        .card-erp { background:#fff; border:1px solid var(--erp-border); border-radius:.375rem; margin-bottom:1rem; }
        .card-header-erp { background:#f1f5f9; border-bottom:1px solid var(--erp-border); font-weight:600; padding:.75rem 1rem; }
        .required::after { content:" *"; color:#ef4444; }
        .form-label { font-size:.72rem; font-weight:600; color:#64748b; text-transform:uppercase; letter-spacing:.3px; margin-bottom:.2rem; }
        .form-control, .form-select { height:31px; font-size:.82rem; }
        .sect-title { font-size:.74rem; font-weight:700; color:#3b82f6; text-transform:uppercase; letter-spacing:.5px;
                      border-bottom:1px dashed #cbd5e1; padding-bottom:.25rem; margin:.25rem 0 .75rem; }
        .stock-note { font-size:.75rem; color:#0f5132; background:#d1e7dd; border-radius:4px; padding:2px 8px; }
        .booking-no { font-weight:700; color:#0f172a; background:#f1f5f9; }
        .grid-input { width:80px; padding:.15rem .35rem; font-size:.8rem; border:1px solid #ced4da; border-radius:4px; text-align:right; }
        .cost-tbl th { white-space:nowrap; font-size:.78rem; }
        .cost-tbl td { font-size:.8rem; }
        .sum-box { background:#eef3ff; border:1px solid #d6e0ff; border-radius:.375rem; padding:.75rem; }
        .sum-row { display:flex; justify-content:space-between; padding:3px 0; border-bottom:1px dotted #cbd5e1; }
        .sum-row:last-child { border-bottom:none; }
        .sum-big { font-size:1.05rem; font-weight:700; color:#0f172a; }
        .fob-box { background:#0f172a; color:#fff; border-radius:.375rem; padding:.75rem 1rem; }
        .fob-box .v { font-size:1.35rem; font-weight:700; }
        .fob-box .l { font-size:.72rem; text-transform:uppercase; letter-spacing:.4px; color:#94a3b8; }
        .pos { color:#16a34a; font-weight:700; } .neg { color:#dc2626; font-weight:700; }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <asp:HiddenField ID="hfCostingId" runat="server" Value="0" />
    <asp:HiddenField ID="hfPOId" runat="server" Value="0" />
    <asp:HiddenField ID="hfStyleId" runat="server" Value="0" />
    <asp:HiddenField ID="hfOrderQty" runat="server" Value="0" />

    <nav class="navbar navbar-erp navbar-expand-lg">
        <div class="container-fluid">
            <span class="navbar-brand mb-0 h1 text-white"><i class="bi bi-calculator me-2"></i>Garments ERP &gt; Costing</span>
            <span class="text-light small">Logged in as: <b><asp:Label ID="lblUser" runat="server" /></b></span>
        </div>
    </nav>

    <div class="container-fluid py-3">

        <!-- ============ 1. COSTING HEADER ============ -->
        <div class="card card-erp">
            <div class="card-header-erp d-flex justify-content-between align-items-center">
                <span><i class="bi bi-journal-text"></i> Costing Information</span>
                <span>
                    <asp:LinkButton ID="btnNew" runat="server" CssClass="btn btn-sm btn-outline-secondary" CausesValidation="false"
                        OnClick="btnNew_Click"><i class="bi bi-file-earmark-plus"></i> New</asp:LinkButton>
                    <asp:LinkButton ID="btnSave" runat="server" CssClass="btn btn-sm btn-primary ms-1"
                        OnClick="btnSave_Click"><i class="bi bi-save"></i> Save Costing</asp:LinkButton>
                </span>
            </div>
            <div class="card-body">
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">Open Existing Costing</label>
                        <asp:DropDownList ID="ddlCosting" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlCosting_SelectedIndexChanged" />
                    </div>
                    <div class="col-md-3">
                        <label class="form-label">Costing No</label>
                        <asp:TextBox ID="txtCostingNo" runat="server" CssClass="form-control booking-no" ReadOnly="true" Text="(Auto Generated)" />
                    </div>
                    <div class="col-md-2">
                        <label class="form-label required">Costing Date</label>
                        <asp:TextBox ID="txtCostingDate" runat="server" CssClass="form-control" TextMode="Date" />
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
                    <div class="col-md-4">
                        <label class="form-label required">PO</label>
                        <asp:DropDownList ID="ddlPO" runat="server" CssClass="form-select"
                            AutoPostBack="true" OnSelectedIndexChanged="ddlPO_SelectedIndexChanged" />
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Order Qty (pcs)</label>
                        <asp:TextBox ID="txtOrderQty" runat="server" CssClass="form-control booking-no text-end" ReadOnly="true" Text="0" />
                    </div>
                </div>
            </div>
        </div>

        <!-- ============ 3. COST ITEM ENTRY ============ -->
        <asp:Panel ID="pnlEntry" runat="server" Visible="false">
            <div class="card card-erp">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-2 flex-wrap gap-1">
                        <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-plus-square"></i> Cost Item Entry (per Dozen)</h6>
                        <span class="stock-note"><i class="bi bi-info-circle"></i> Amount / Dzn = Cons × (1 + Wastage % / 100) × Rate। CM ও Commercial-এ Cons ফাঁকা রাখলে ১ ধরা হবে।</span>
                    </div>
                    <div class="row g-3 align-items-end">
                        <div class="col-md-2">
                            <label class="form-label required">Category</label>
                            <asp:DropDownList ID="ddlCat" runat="server" CssClass="form-select" />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label required">Item / Description</label>
                            <asp:TextBox ID="txtItem" runat="server" CssClass="form-control" MaxLength="150" placeholder="e.g. Main Label, Sewing Thread" autocomplete="off" />
                        </div>
                        <div class="col-md-1">
                            <label class="form-label">Unit</label>
                            <asp:DropDownList ID="ddlUnit" runat="server" CssClass="form-select">
                                <asp:ListItem>Pcs</asp:ListItem>
                                <asp:ListItem>Kg</asp:ListItem>
                                <asp:ListItem>Yds</asp:ListItem>
                                <asp:ListItem>Mtr</asp:ListItem>
                                <asp:ListItem>Cone</asp:ListItem>
                                <asp:ListItem>Set</asp:ListItem>
                                <asp:ListItem>Dzn</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Cons / Dzn</label>
                            <asp:TextBox ID="txtCons" runat="server" CssClass="form-control c-in" placeholder="0" autocomplete="off" />
                        </div>
                        <div class="col-md-1">
                            <label class="form-label">Waste %</label>
                            <asp:TextBox ID="txtWaste" runat="server" CssClass="form-control c-in" placeholder="0" autocomplete="off" />
                        </div>
                        <div class="col-md-1">
                            <label class="form-label">Rate (USD)</label>
                            <asp:TextBox ID="txtRate" runat="server" CssClass="form-control c-in" placeholder="0.00" autocomplete="off" />
                        </div>
                        <div class="col-md-2 text-end">
                            <asp:LinkButton ID="btnAdd" runat="server" CssClass="btn btn-sm btn-success px-3" OnClick="btnAdd_Click"><i class="bi bi-plus-lg"></i> Add</asp:LinkButton>
                            <asp:LinkButton ID="btnImportFab" runat="server" CssClass="btn btn-sm btn-outline-primary" CausesValidation="false"
                                OnClick="btnImportFab_Click" ToolTip="এই PO-র Fabric Booking থেকে ফেব্রিক Cons এনে বসাও"><i class="bi bi-download"></i> Fabric</asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <div class="row">
            <!-- ============ 4. COST LINES ============ -->
            <div class="col-lg-8">
                <div class="card card-erp">
                    <div class="card-body">
                        <h6 class="text-uppercase text-secondary fw-bold mb-2"><i class="bi bi-list-check"></i> Cost Lines</h6>
                        <div class="table-responsive">
                            <asp:GridView ID="gvCost" runat="server" AutoGenerateColumns="false"
                                CssClass="table table-bordered table-sm align-middle cost-tbl"
                                HeaderStyle-CssClass="table-light" GridLines="None"
                                OnRowCommand="gvCost_RowCommand"
                                EmptyDataText="No cost item added. Select Buyer → Style → PO, then add items.">
                                <Columns>
                                    <asp:TemplateField HeaderText="Category">
                                        <ItemTemplate><span class="badge bg-dark c-cat"><asp:Literal ID="litCat" runat="server" Mode="Encode" Text='<%# Eval("Category") %>' /></span></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Item / Description">
                                        <ItemTemplate><asp:Literal ID="litItem" runat="server" Mode="Encode" Text='<%# Eval("ItemName") %>' /></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Unit">
                                        <ItemTemplate><asp:Literal ID="litUnit" runat="server" Mode="Encode" Text='<%# Eval("Unit") %>' /></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Cons / Dzn">
                                        <ItemTemplate><asp:TextBox ID="txtConsRow" runat="server" CssClass="grid-input c-num c-cons" Text='<%# Eval("ConsDzn", "{0:0.####}") %>' autocomplete="off" /></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Waste %">
                                        <ItemTemplate><asp:TextBox ID="txtWasteRow" runat="server" CssClass="grid-input c-num c-waste" Style="width:60px" Text='<%# Eval("WastePct", "{0:0.##}") %>' autocomplete="off" /></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Rate (USD)">
                                        <ItemTemplate><asp:TextBox ID="txtRateRow" runat="server" CssClass="grid-input c-num c-rate" Text='<%# Eval("Rate", "{0:0.####}") %>' autocomplete="off" /></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Amount / Dzn" ItemStyle-CssClass="text-end fw-bold">
                                        <ItemTemplate><asp:Label ID="lblAmt" runat="server" CssClass="c-amt" Text='<%# Eval("AmountDzn", "{0:N4}") %>' /></ItemTemplate>
                                    </asp:TemplateField>
                                    <asp:TemplateField HeaderText="Action" ItemStyle-Width="70px">
                                        <ItemTemplate>
                                            <asp:LinkButton runat="server" CommandName="CopyRow" CommandArgument='<%# Container.DataItemIndex %>'
                                                CausesValidation="false" CssClass="text-primary me-2" ToolTip="Duplicate"><i class="bi bi-files"></i></asp:LinkButton>
                                            <asp:LinkButton runat="server" CommandName="RemoveRow" CommandArgument='<%# Container.DataItemIndex %>'
                                                CausesValidation="false" CssClass="text-danger" ToolTip="Remove"
                                                OnClientClick="return confirm('Remove this row?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ============ 5. SUMMARY ============ -->
            <div class="col-lg-4">
                <div class="card card-erp">
                    <div class="card-header-erp"><i class="bi bi-pie-chart"></i> Cost Summary (per Dozen, USD)</div>
                    <div class="card-body">
                        <div class="sum-box mb-3">
                            <div class="sum-row"><span>Fabric</span><b><asp:Label ID="lblCatFabric" runat="server" CssClass="cat-sum" data-cat="Fabric" Text="0.0000" /></b></div>
                            <div class="sum-row"><span>Trims &amp; Accessories</span><b><asp:Label ID="lblCatTrims" runat="server" CssClass="cat-sum" data-cat="Trims" Text="0.0000" /></b></div>
                            <div class="sum-row"><span>Print / Embroidery</span><b><asp:Label ID="lblCatEmb" runat="server" CssClass="cat-sum" data-cat="Print/Embroidery" Text="0.0000" /></b></div>
                            <div class="sum-row"><span>Wash</span><b><asp:Label ID="lblCatWash" runat="server" CssClass="cat-sum" data-cat="Wash" Text="0.0000" /></b></div>
                            <div class="sum-row"><span>CM (Cutting &amp; Making)</span><b><asp:Label ID="lblCatCM" runat="server" CssClass="cat-sum" data-cat="CM" Text="0.0000" /></b></div>
                            <div class="sum-row"><span>Commercial / Overhead</span><b><asp:Label ID="lblCatCom" runat="server" CssClass="cat-sum" data-cat="Commercial" Text="0.0000" /></b></div>
                            <div class="sum-row"><span>Other</span><b><asp:Label ID="lblCatOther" runat="server" CssClass="cat-sum" data-cat="Other" Text="0.0000" /></b></div>
                            <div class="sum-row sum-big"><span>Total Cost / Dzn</span><span><asp:Label ID="lblTotalCost" runat="server" Text="0.0000" /></span></div>
                        </div>

                        <div class="row g-2 mb-3">
                            <div class="col-4">
                                <label class="form-label">Profit %</label>
                                <asp:TextBox ID="txtProfit" runat="server" CssClass="form-control c-in" Text="10" autocomplete="off" />
                            </div>
                            <div class="col-4">
                                <label class="form-label">Commission %</label>
                                <asp:TextBox ID="txtComm" runat="server" CssClass="form-control c-in" Text="5" autocomplete="off" />
                            </div>
                            <div class="col-4">
                                <label class="form-label">Buyer Target FOB/Dzn</label>
                                <asp:TextBox ID="txtTarget" runat="server" CssClass="form-control c-in" Text="0" autocomplete="off" />
                            </div>
                        </div>

                        <div class="sum-box mb-3">
                            <div class="sum-row"><span>Profit Amount / Dzn</span><b><asp:Label ID="lblProfitAmt" runat="server" Text="0.0000" /></b></div>
                            <div class="sum-row"><span>Buying Commission / Dzn</span><b><asp:Label ID="lblCommAmt" runat="server" Text="0.0000" /></b></div>
                            <div class="sum-row"><span>Target vs FOB (Dzn)</span><b><asp:Label ID="lblVariance" runat="server" Text="-" /></b></div>
                        </div>

                        <div class="fob-box">
                            <div class="row">
                                <div class="col-6"><div class="l">FOB / Dzn</div><div class="v"><asp:Label ID="lblFobDzn" runat="server" Text="0.00" /></div></div>
                                <div class="col-6"><div class="l">FOB / Pc</div><div class="v"><asp:Label ID="lblFobPc" runat="server" Text="0.0000" /></div></div>
                            </div>
                            <div class="mt-2"><div class="l">Total Order Value</div><div class="v"><asp:Label ID="lblOrderValue" runat="server" Text="0.00" /></div></div>
                        </div>
                        <div class="text-muted small mt-2">FOB = (Cost + Profit) ÷ (1 − Commission%)</div>
                    </div>
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
    function el(id) { return document.querySelector('[id$="' + id + '"]'); }

    function recalc() {
        var cats = {}, total = 0;
        document.querySelectorAll('.cost-tbl tr').forEach(function (tr) {
            var cons = tr.querySelector('.c-cons'); if (!cons) return;
            var amt = num(cons.value) * (1 + num(tr.querySelector('.c-waste').value) / 100) * num(tr.querySelector('.c-rate').value);
            tr.querySelector('.c-amt').textContent = fmt(amt, 4);
            var cat = tr.querySelector('.c-cat').textContent.trim();
            cats[cat] = (cats[cat] || 0) + amt;
            total += amt;
        });
        document.querySelectorAll('.cat-sum').forEach(function (s) {
            s.textContent = fmt(cats[s.getAttribute('data-cat')] || 0, 4);
        });
        var profitPct = num(el('txtProfit').value), commPct = num(el('txtComm').value), target = num(el('txtTarget').value);
        var profit = total * profitPct / 100, pre = total + profit;
        var fob = commPct < 100 ? pre / (1 - commPct / 100) : pre;
        var comm = fob - pre, qty = num(el('hfOrderQty').value), fobPc = fob / 12;
        el('lblTotalCost').textContent = fmt(total, 4);
        el('lblProfitAmt').textContent = fmt(profit, 4);
        el('lblCommAmt').textContent = fmt(comm, 4);
        el('lblFobDzn').textContent = fmt(fob, 2);
        el('lblFobPc').textContent = fmt(fobPc, 4);
        el('lblOrderValue').textContent = fmt(fobPc * qty, 2);
        var v = el('lblVariance');
        if (target > 0) {
            var d = target - fob;
            v.textContent = (d >= 0 ? '+' : '') + fmt(d, 2);
            v.className = d >= 0 ? 'pos' : 'neg';
        } else { v.textContent = '-'; v.className = ''; }
    }

    document.addEventListener('input', function (e) {
        var t = e.target;
        if (t.classList.contains('c-num') || t.classList.contains('c-in')) {
            var clean = t.value.replace(/[^0-9.]/g, '');
            if (clean !== t.value) t.value = clean;
            recalc();
        }
    });
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        var t = e.target;
        if (t.classList && t.classList.contains('c-num')) {
            e.preventDefault();
            var all = [].slice.call(document.querySelectorAll('.cost-tbl .c-num'));
            var i = all.indexOf(t);
            if (i >= 0 && i < all.length - 1) { all[i + 1].focus(); all[i + 1].select(); }
        }
    });
    document.addEventListener('focusin', function (e) {
        if (e.target.classList && e.target.classList.contains('c-num')) e.target.select();
    });
    recalc();
})();
</script>
</body>
</html>
