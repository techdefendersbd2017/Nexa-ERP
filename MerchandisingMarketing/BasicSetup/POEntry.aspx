<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="POEntry.aspx.cs" Inherits="Nexa_ERP.MasterConfiguration.BuyerManagement.POEntry" MaintainScrollPositionOnPostBack="true" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Garments ERP - PO Entry</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        :root { --erp-primary:#0f172a; --erp-secondary:#3b82f6; --erp-bg:#f8fafc; --erp-border:#e2e8f0; }
        body { background:var(--erp-bg); font-size:.875rem; font-family:'Segoe UI',Tahoma,sans-serif; color:#334155; }
        .navbar-erp { background:var(--erp-primary); color:#fff; padding:.75rem 1.5rem; }
        .card-erp { background:#fff; border:1px solid var(--erp-border); border-radius:.375rem; margin-bottom:1rem; }
        .card-header-erp { background:#f1f5f9; border-bottom:1px solid var(--erp-border); font-weight:600; padding:.75rem 1rem; }
        .required::after { content:" *"; color:#ef4444; }
        .ro { background:#f1f5f9 !important; }
        .nav-tabs .nav-link { color:#64748b; font-weight:500; border:none; padding:.75rem 1rem; }
        .nav-tabs .nav-link.active { color:var(--erp-secondary); border-bottom:2px solid var(--erp-secondary); background:transparent; }
        .sec-title { border-bottom:1px solid var(--erp-border); padding-bottom:.25rem; margin-top:.5rem; }
        .style-card { background:#eef3ff; border:1px solid #d6e0ff; border-radius:.375rem; padding:.75rem; }
        .style-card .lbl { font-size:.72rem; color:#64748b; text-transform:uppercase; letter-spacing:.3px; }
        .style-card .val { font-weight:600; color:#1e293b; font-size:.85rem; }
        .img-thumb { width:70px; height:70px; object-fit:cover; border:1px solid var(--erp-border); border-radius:6px; margin-right:6px; }
        .grid-input { width:90px; padding:.15rem .35rem; font-size:.8rem; border:1px solid #ced4da; border-radius:4px; }
        .stock-note { font-size:.75rem; color:#0f5132; background:#d1e7dd; border-radius:4px; padding:2px 8px; }

        /* multi-select dropdown */
        .ms-dd .ms-btn { text-align:left; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
        .ms-dd .dropdown-menu { min-width:100%; max-height:260px; overflow:auto; padding:.5rem .75rem; }
        .ms-list input { margin-right:6px; }
        .ms-list label { cursor:pointer; }
        .ms-list br { display:none; }
        .ms-list span { display:block; padding:2px 0; }

        /* qty matrix */
        .matrix-tbl th, .matrix-tbl td { vertical-align:middle; }
        .matrix-tbl input.qty-input { width:72px; text-align:center; }
        .matrix-tbl thead th { white-space:nowrap; background:#f1f5f9; }
        .emb-tbl .form-select, .emb-tbl .form-control { min-width:110px; }
        .emb-tbl input.grid-input { width:90px; text-align:right; }
        .emb-tbl th { white-space:nowrap; }
        .fab-in .input-group .form-control { min-width:0; }

        /* fabric booking grid (wide) */
        .fab-tbl .form-select, .fab-tbl .form-control { min-width:0; }
        .fab-tbl select.form-select { min-width:84px; }
        .fab-tbl input.grid-input { width:72px; text-align:right; }
        .fab-tbl input.fab-txt { width:80px; text-align:left; }
        .fab-tbl th { white-space:nowrap; font-size:.78rem; }
        .fab-tbl td { font-size:.8rem; }
        .part-badge { font-size:.7rem; }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <asp:HiddenField ID="hfPOId" runat="server" Value="0" />
    <asp:HiddenField ID="hfStyleId" runat="server" Value="0" />
    <asp:HiddenField ID="hfActiveTab" runat="server" Value="#qty-tab" />

    <nav class="navbar navbar-erp navbar-expand-lg">
        <div class="container-fluid">
            <span class="navbar-brand mb-0 h1 text-white"><i class="bi bi-file-earmark-text me-2"></i>Garments ERP &gt; PO Entry</span>
            <span class="text-light small">Logged in as: <b><asp:Label ID="lblUser" runat="server" /></b></span>
        </div>
    </nav>

    <div class="container-fluid py-3">

        <!-- ====================== LIST PANEL ====================== -->
        <asp:Panel ID="pnlList" runat="server">
            <div class="card card-erp">
                <div class="card-header-erp d-flex justify-content-between align-items-center">
                    <span><i class="bi bi-list-ul"></i> PO List</span>
                    <asp:LinkButton ID="btnAddNew" runat="server" CssClass="btn btn-sm btn-primary"
                        OnClick="btnAddNew_Click"><i class="bi bi-plus-lg"></i> Add New PO</asp:LinkButton>
                </div>
                <div class="card-body">
                    <div class="row g-2 mb-3 align-items-end">
                        <div class="col-md-3">
                            <label class="form-label">Search (PO No / Buyer Ref)</label>
                            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control form-control-sm" />
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Status</label>
                            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select form-select-sm">
                                <asp:ListItem Value="">-- All --</asp:ListItem>
                                <asp:ListItem Value="0">Draft</asp:ListItem>
                                <asp:ListItem Value="1">Confirmed</asp:ListItem>
                                <asp:ListItem Value="2">Running</asp:ListItem>
                                <asp:ListItem Value="3">Shipped</asp:ListItem>
                                <asp:ListItem Value="4">Closed</asp:ListItem>
                                <asp:ListItem Value="5">Cancelled</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <asp:LinkButton ID="btnSearch" runat="server" CssClass="btn btn-sm btn-primary"
                                OnClick="btnSearch_Click"><i class="bi bi-search"></i> Search</asp:LinkButton>
                            <asp:LinkButton ID="btnClearFilter" runat="server" CssClass="btn btn-sm btn-outline-secondary"
                                OnClick="btnClearFilter_Click"><i class="bi bi-x-lg"></i> Clear</asp:LinkButton>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="false"
                            CssClass="table table-bordered table-sm align-middle"
                            HeaderStyle-CssClass="table-light" GridLines="None"
                            OnRowCommand="GridView1_RowCommand" EmptyDataText="No PO found.">
                            <Columns>
                                <asp:BoundField DataField="PONo" HeaderText="PO No" />
                                <asp:BoundField DataField="PODate" HeaderText="Date" DataFormatString="{0:yyyy-MM-dd}" />
                                <asp:BoundField DataField="StyleNo" HeaderText="Style No" />
                                <asp:BoundField DataField="BuyerName" HeaderText="Buyer" />
                                <asp:BoundField DataField="POQty" HeaderText="Qty" />
                                <asp:BoundField DataField="Currency" HeaderText="Cur" />
                                <asp:BoundField DataField="UnitPrice" HeaderText="Price" DataFormatString="{0:N2}" />
                                <asp:TemplateField HeaderText="Status">
                                    <ItemTemplate>
                                        <span class='badge <%# GetPOStatusCss(Eval("POStatus")) %>'><%# GetPOStatusText(Eval("POStatus")) %></span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action" ItemStyle-Width="110px">
                                    <ItemTemplate>
                                        <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("POID") %>'
                                            CssClass="btn btn-xs btn-outline-primary"><i class="bi bi-pencil"></i></asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="DeleteRow" CommandArgument='<%# Eval("POID") %>'
                                            CssClass="btn btn-xs btn-outline-danger" OnClientClick="return confirm('Delete this PO?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- ====================== ENTRY PANEL ====================== -->
        <asp:Panel ID="pnlEntry" runat="server" Visible="false">

            <!-- Top Header -->
            <div class="card card-erp">
                <div class="card-body py-2">
                    <div class="row g-2 align-items-end">
                        <div class="col-md-2">
                            <label class="form-label required">PO No</label>
                            <asp:TextBox ID="txtPONo" runat="server" CssClass="form-control form-control-sm fw-bold text-primary" MaxLength="30" />
                        </div>
                        <div class="col-md-2">
                            <label class="form-label required">PO Date</label>
                            <asp:TextBox ID="txtPODate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">Buyer PO Ref</label>
                            <asp:TextBox ID="txtBuyerPORef" runat="server" CssClass="form-control form-control-sm" MaxLength="50" />
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">PO Type</label>
                            <asp:DropDownList ID="ddlPOType" runat="server" CssClass="form-select form-select-sm">
                                <asp:ListItem Value="">-- Select --</asp:ListItem>
                                <asp:ListItem>Bulk</asp:ListItem>
                                <asp:ListItem>Sample</asp:ListItem>
                                <asp:ListItem>Repeat</asp:ListItem>
                                <asp:ListItem>Development</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">PO Status</label>
                            <asp:DropDownList ID="ddlPOStatus" runat="server" CssClass="form-select form-select-sm">
                                <asp:ListItem Value="0">Draft</asp:ListItem>
                                <asp:ListItem Value="1">Confirmed</asp:ListItem>
                                <asp:ListItem Value="2">Running</asp:ListItem>
                                <asp:ListItem Value="3">Shipped</asp:ListItem>
                                <asp:ListItem Value="4">Closed</asp:ListItem>
                                <asp:ListItem Value="5">Cancelled</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-2 text-end">
                            <div class="btn-group btn-group-sm">
                                <asp:LinkButton ID="btnSave" runat="server" CssClass="btn btn-primary"
                                    OnClick="btnSave_Click"><i class="bi bi-save"></i> Save</asp:LinkButton>
                                <asp:LinkButton ID="btnClear" runat="server" CssClass="btn btn-outline-secondary"
                                    OnClick="btnClear_Click"><i class="bi bi-x-lg"></i></asp:LinkButton>
                                <asp:LinkButton ID="btnBackToList" runat="server" CssClass="btn btn-outline-dark"
                                    OnClick="btnBackToList_Click"><i class="bi bi-arrow-left"></i> Back</asp:LinkButton>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- STYLE SELECTOR -->
            <div class="card card-erp">
                <div class="card-header-erp d-flex justify-content-between align-items-center">
                    <span><i class="bi bi-tags"></i> Style Selection <span class="text-muted small fw-normal">(select once — rest auto from Style)</span></span>
                    <a href="StyleInformationForGarments.aspx" target="_blank" class="btn btn-xs btn-outline-secondary"><i class="bi bi-box-arrow-up-right"></i> Open Style Master</a>
                </div>
                <div class="card-body">
                    <div class="row g-2 align-items-end mb-3">
                        <div class="col-md-6">
                            <label class="form-label required">Style</label>
                            <asp:DropDownList ID="ddlStyle" runat="server" CssClass="form-select form-select-sm"
                                AutoPostBack="true" OnSelectedIndexChanged="ddlStyle_SelectedIndexChanged" />
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Style Status</label>
                            <div><asp:Label ID="lblStyleStatus" runat="server" CssClass="badge bg-secondary" Text="—" /></div>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">Revision</label>
                            <div><asp:Label ID="lblStyleRev" runat="server" CssClass="fw-bold" Text="00" /></div>
                        </div>
                    </div>

                    <div class="style-card">
                        <div class="row g-2">
                            <div class="col-md-3"><div class="lbl">Style No / Name</div><div class="val"><asp:Label ID="lblStyleNoName" runat="server" Text="—" /></div></div>
                            <div class="col-md-2"><div class="lbl">Buyer</div><div class="val"><asp:Label ID="lblBuyer" runat="server" Text="—" /></div></div>
                            <div class="col-md-2"><div class="lbl">Brand</div><div class="val"><asp:Label ID="lblBrand" runat="server" Text="—" /></div></div>
                            <div class="col-md-2"><div class="lbl">Agent</div><div class="val"><asp:Label ID="lblAgent" runat="server" Text="—" /></div></div>
                            <div class="col-md-3"><div class="lbl">Season / Year</div><div class="val"><asp:Label ID="lblSeason" runat="server" Text="—" /></div></div>
                            <div class="col-md-2"><div class="lbl">Merchandiser</div><div class="val"><asp:Label ID="lblMerch" runat="server" Text="—" /></div></div>
                            <div class="col-md-2"><div class="lbl">Knit/Woven</div><div class="val"><asp:Label ID="lblKnitWoven" runat="server" Text="—" /></div></div>
                            <div class="col-md-3"><div class="lbl">Fabric / GSM</div><div class="val"><asp:Label ID="lblFabric" runat="server" Text="—" /></div></div>
                            <div class="col-md-5"><div class="lbl">Composition</div><div class="val"><asp:Label ID="lblComposition" runat="server" Text="—" /></div></div>
                            <div class="col-md-3"><div class="lbl">Target Price</div><div class="val"><asp:Label ID="lblTargetPrice" runat="server" Text="—" /></div></div>
                            <div class="col-md-9"><div class="lbl">Images</div>
                                <div>
                                    <asp:Image ID="imgFront" runat="server" CssClass="img-thumb" Visible="false" />
                                    <asp:Image ID="imgBack" runat="server" CssClass="img-thumb" Visible="false" />
                                    <asp:Image ID="imgSketch" runat="server" CssClass="img-thumb" Visible="false" />
                                    <span class="text-muted small">Style-এ যুক্ত ছবি এখানে দেখাবে</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- TABBED DETAILS -->
            <div class="card card-erp">
                <div class="card-header bg-white pb-0 pt-2 border-bottom-0">
                    <ul class="nav nav-tabs card-header-tabs">
                        <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#qty-tab" type="button"><i class="bi bi-grid-3x3 me-1"></i> Qty &amp; Price</button></li>
                        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#emb-tab" type="button"><i class="bi bi-stars me-1"></i> Embellishment Work Order</button></li>
                        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#fabric-tab" type="button"><i class="bi bi-layers me-1"></i> Fabric Booking</button></li>
                        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#acc-tab" type="button"><i class="bi bi-tag me-1"></i> Accessories Booking</button></li>
                        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#ship-tab" type="button"><i class="bi bi-truck me-1"></i> Shipment &amp; Commercial</button></li>
                        <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#pay-tab" type="button"><i class="bi bi-cash-coin me-1"></i> Payment</button></li>
                    </ul>
                </div>
                <div class="card-body">
                    <div class="tab-content">

                        <!-- QTY & PRICE -->
                        <div class="tab-pane fade show active" id="qty-tab">

                            <div class="d-flex flex-wrap gap-2 align-items-end mb-3">
                                <div style="width:105px">
                                    <label class="form-label required">PO Qty (pcs)</label>
                                    <asp:TextBox ID="txtPOQty" runat="server" CssClass="form-control form-control-sm ro fw-bold" Text="0" />
                                </div>
                                <div style="width:165px">
                                    <label class="form-label required">Unit Price</label>
                                    <div class="input-group input-group-sm">
                                        <asp:TextBox ID="txtUnitPrice" runat="server" CssClass="form-control" Text="0.00" />
                                        <asp:DropDownList ID="ddlCurrency" runat="server" CssClass="form-select" Style="max-width:75px">
                                            <asp:ListItem>USD</asp:ListItem><asp:ListItem>EUR</asp:ListItem>
                                            <asp:ListItem>GBP</asp:ListItem><asp:ListItem>BDT</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                                <div style="width:125px">
                                    <label class="form-label">Total Value</label>
                                    <asp:TextBox ID="txtTotalValue" runat="server" CssClass="form-control form-control-sm ro fw-bold" Text="0.00" />
                                </div>

                                <div style="width:220px" class="ms-dd dropdown">
                                    <label class="form-label">Style Colors</label>
                                    <button type="button" class="form-select form-select-sm ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="Select colors">Select colors</button>
                                    <div class="dropdown-menu">
                                        <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                        <asp:CheckBoxList ID="cblColors" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                                    </div>
                                </div>

                                <div style="width:200px" class="ms-dd dropdown">
                                    <label class="form-label">Style Sizes</label>
                                    <button type="button" class="form-select form-select-sm ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="Select sizes">Select sizes</button>
                                    <div class="dropdown-menu">
                                        <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                        <asp:CheckBoxList ID="cblSizes" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                                    </div>
                                </div>

                                <div>
                                    <asp:LinkButton ID="btnAddQty" runat="server" CssClass="btn btn-sm btn-success"
                                        OnClick="btnAddQty_Click"><i class="bi bi-plus-lg"></i> Add</asp:LinkButton>
                                </div>
                            </div>

                            <h6 class="text-uppercase text-secondary fw-bold mb-2 sec-title">Color × Size Qty <span class="text-muted small fw-normal text-lowercase">(Enter চাপলে পরের ঘরে যাবে)</span></h6>

                            <asp:Label ID="lblMatrixEmpty" runat="server" CssClass="text-muted d-block py-3"
                                Text="Select a Style, then choose Colors &amp; Sizes and click Add." />

                            <asp:Panel ID="pnlMatrix" runat="server" CssClass="d-none">
                                <div class="table-responsive">
                                    <table id="matrixTbl" class="table table-bordered table-sm align-middle matrix-tbl">
                                        <thead>
                                            <tr>
                                                <th>Color</th>
                                                <asp:Repeater ID="rptSizeHead" runat="server" OnItemCommand="rptSizeHead_ItemCommand">
                                                    <ItemTemplate>
                                                        <th class="text-center">
                                                            <asp:Literal ID="litSize" runat="server" Mode="Encode" Text='<%# Container.DataItem %>' />
                                                            <asp:LinkButton runat="server" CommandName="RemoveSize" CommandArgument='<%# Container.DataItem %>'
                                                                CausesValidation="false" CssClass="text-danger ms-1" ToolTip="Remove size"
                                                                OnClientClick="return confirm('Remove this size column?');"><i class="bi bi-x-circle"></i></asp:LinkButton>
                                                        </th>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                                <th class="text-end">Total</th>
                                                <th class="text-end">Value</th>
                                                <th></th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <asp:Repeater ID="rptMatrix" runat="server" OnItemDataBound="rptMatrix_ItemDataBound" OnItemCommand="rptMatrix_ItemCommand">
                                                <ItemTemplate>
                                                    <tr>
                                                        <td class="fw-semibold"><asp:Literal ID="litColor" runat="server" Mode="Encode" /></td>
                                                        <asp:Repeater ID="rptCells" runat="server">
                                                            <ItemTemplate>
                                                                <td class="text-center">
                                                                    <asp:TextBox ID="txtCell" runat="server" CssClass="grid-input qty-input"
                                                                        Text='<%# Container.DataItem %>' autocomplete="off" />
                                                                </td>
                                                            </ItemTemplate>
                                                        </asp:Repeater>
                                                        <td class="text-end fw-bold"><asp:Label ID="lblRowTotal" runat="server" CssClass="row-total" Text="0" /></td>
                                                        <td class="text-end"><asp:Label ID="lblRowValue" runat="server" CssClass="row-value" Text="0.00" /></td>
                                                        <td class="text-center">
                                                            <asp:LinkButton ID="btnRemoveColor" runat="server" CommandName="RemoveColor" CausesValidation="false"
                                                                CssClass="text-danger" ToolTip="Remove color row"
                                                                OnClientClick="return confirm('Remove this color row?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                                        </td>
                                                    </tr>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </tbody>
                                        <tfoot>
                                            <tr class="table-light fw-bold">
                                                <td>Total</td>
                                                <asp:Repeater ID="rptSizeFoot" runat="server">
                                                    <ItemTemplate>
                                                        <td class="text-center"><asp:Label ID="lblColTotal" runat="server" CssClass="col-total" Text="0" /></td>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                                <td class="text-end"><asp:Label ID="lblGrandQty" runat="server" CssClass="grand-total" Text="0" /></td>
                                                <td class="text-end"><asp:Label ID="lblGrandValue" runat="server" CssClass="grand-value" Text="0.00" /></td>
                                                <td></td>
                                            </tr>
                                        </tfoot>
                                    </table>
                                </div>
                            </asp:Panel>
                        </div>

                        <!-- EMBELLISHMENT WORK ORDER -->
                        <div class="tab-pane fade" id="emb-tab">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-stars"></i> Embellishment Work Order (Color wise)</h6>
                                <span class="stock-note"><i class="bi bi-info-circle"></i> Color সিলেক্ট করে Add দিন, তারপর প্রতি Color-এ Embellishment সেট করুন</span>
                            </div>

                            <div class="d-flex flex-wrap gap-2 align-items-end mb-3">
                                <div style="width:260px" class="ms-dd dropdown">
                                    <label class="form-label">Style Colors</label>
                                    <button type="button" class="form-select form-select-sm ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="Select colors">Select colors</button>
                                    <div class="dropdown-menu">
                                        <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                        <asp:CheckBoxList ID="cblEmbColors" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                                    </div>
                                </div>
                                <div>
                                    <asp:LinkButton ID="btnAddEmb" runat="server" CssClass="btn btn-sm btn-success"
                                        OnClick="btnAddEmb_Click"><i class="bi bi-plus-lg"></i> Add</asp:LinkButton>
                                </div>
                            </div>

                            <div class="table-responsive">
                                <asp:GridView ID="gvEmb" runat="server" AutoGenerateColumns="false"
                                    CssClass="table table-bordered table-sm align-middle emb-tbl"
                                    HeaderStyle-CssClass="table-light" GridLines="None"
                                    OnRowCommand="gvEmb_RowCommand" OnRowDataBound="gvEmb_RowDataBound"
                                    EmptyDataText="No embellishment added. Select colors and click Add.">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Color">
                                            <ItemTemplate>
                                                <b><asp:Literal ID="litEmbColor" runat="server" Mode="Encode" Text='<%# Eval("ColorCode") %>' /></b>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Embellishment Type">
                                            <ItemTemplate>
                                                <asp:DropDownList ID="ddlEmbType" runat="server" CssClass="form-select form-select-sm">
                                                    <asp:ListItem Value="">-- Select --</asp:ListItem>
                                                    <asp:ListItem>Print</asp:ListItem>
                                                    <asp:ListItem>Embroidery</asp:ListItem>
                                                    <asp:ListItem>Wash</asp:ListItem>
                                                    <asp:ListItem>Applique</asp:ListItem>
                                                    <asp:ListItem>Heat Transfer</asp:ListItem>
                                                    <asp:ListItem>Patch / Badge</asp:ListItem>
                                                    <asp:ListItem>Other</asp:ListItem>
                                                </asp:DropDownList>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Design / Description">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtEmbDesc" runat="server" CssClass="form-control form-control-sm" MaxLength="200" Text='<%# Eval("Description") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Placement">
                                            <ItemTemplate>
                                                <asp:DropDownList ID="ddlEmbPlace" runat="server" CssClass="form-select form-select-sm">
                                                    <asp:ListItem Value="">-- Select --</asp:ListItem>
                                                    <asp:ListItem>Front</asp:ListItem>
                                                    <asp:ListItem>Back</asp:ListItem>
                                                    <asp:ListItem>Left Chest</asp:ListItem>
                                                    <asp:ListItem>Right Chest</asp:ListItem>
                                                    <asp:ListItem>Sleeve</asp:ListItem>
                                                    <asp:ListItem>Neck</asp:ListItem>
                                                    <asp:ListItem>Pocket</asp:ListItem>
                                                    <asp:ListItem>All Over</asp:ListItem>
                                                    <asp:ListItem>Other</asp:ListItem>
                                                </asp:DropDownList>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Supplier">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtEmbSupplier" runat="server" CssClass="form-control form-control-sm" MaxLength="150" Text='<%# Eval("Supplier") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Qty (pcs)">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtEmbQty" runat="server" CssClass="grid-input emb-qty" Text='<%# Eval("Qty") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Rate">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtEmbRate" runat="server" CssClass="grid-input emb-rate" Text='<%# Eval("Rate", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Amount" ItemStyle-CssClass="text-end fw-bold">
                                            <ItemTemplate>
                                                <asp:Label ID="lblEmbAmt" runat="server" CssClass="emb-amt" Text='<%# Eval("Amount", "{0:N2}") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Action" ItemStyle-Width="80px">
                                            <ItemTemplate>
                                                <asp:LinkButton runat="server" CommandName="CopyRow" CommandArgument='<%# Container.DataItemIndex %>'
                                                    CausesValidation="false" CssClass="text-primary me-2" ToolTip="Add another embellishment for this color"><i class="bi bi-files"></i></asp:LinkButton>
                                                <asp:LinkButton runat="server" CommandName="RemoveRow" CommandArgument='<%# Container.DataItemIndex %>'
                                                    CausesValidation="false" CssClass="text-danger" ToolTip="Remove"
                                                    OnClientClick="return confirm('Remove this row?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                            <div class="text-end fw-bold">Total Amount: <asp:Label ID="lblEmbTotal" runat="server" CssClass="emb-total" Text="0.00" /></div>
                        </div>

                        <!-- FABRIC BOOKING -->
                        <div class="tab-pane fade" id="fabric-tab">
                            <div class="d-flex justify-content-between align-items-center mb-2 flex-wrap gap-1">
                                <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-layers"></i> Fabric Booking (Color × Part × Size wise)</h6>
                                <span class="stock-note"><i class="bi bi-info-circle"></i> Color, Fabric ও Part সিলেক্ট করুন। Size ফাঁকা = সব সাইজ (ALL); সাইজ সিলেক্ট করলে প্রতি সাইজে আলাদা লাইন হবে (আলাদা Cons / Dia)। Dzn দিলে Pc, Pc দিলে Dzn নিজে হবে</span>
                            </div>

                            <div class="d-flex flex-wrap gap-2 align-items-end mb-2 fab-in">
                                <div style="width:190px" class="ms-dd dropdown">
                                    <label class="form-label">Style Colors</label>
                                    <button type="button" class="form-select form-select-sm ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="Select colors">Select colors</button>
                                    <div class="dropdown-menu">
                                        <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                        <asp:CheckBoxList ID="cblFabColors" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                                    </div>
                                </div>

                                <div style="width:230px" class="ms-dd dropdown">
                                    <label class="form-label">Style Fabrics</label>
                                    <button type="button" class="form-select form-select-sm ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="Select fabrics">Select fabrics</button>
                                    <div class="dropdown-menu">
                                        <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                        <asp:CheckBoxList ID="cblFabrics" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                                    </div>
                                </div>

                                <div style="width:150px">
                                    <label class="form-label required">Part</label>
                                    <asp:DropDownList ID="ddlFabPart" runat="server" CssClass="form-select form-select-sm">
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

                                <div style="width:170px" class="ms-dd dropdown">
                                    <label class="form-label">Sizes <span class="text-muted">(ফাঁকা = ALL)</span></label>
                                    <button type="button" class="form-select form-select-sm ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="All sizes">All sizes</button>
                                    <div class="dropdown-menu">
                                        <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                        <asp:CheckBoxList ID="cblFabSizes" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                                    </div>
                                </div>

                                <div style="width:105px">
                                    <label class="form-label">Fabric Form</label>
                                    <asp:DropDownList ID="ddlFabForm" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Value="">-- Select --</asp:ListItem>
                                        <asp:ListItem>Open</asp:ListItem>
                                        <asp:ListItem>Tube</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div style="width:80px">
                                    <label class="form-label">Dia (inch)</label>
                                    <asp:TextBox ID="txtFabDia" runat="server" CssClass="form-control form-control-sm" MaxLength="20" placeholder="e.g. 32" autocomplete="off" />
                                </div>

                                <div style="width:130px">
                                    <label class="form-label">Part Size</label>
                                    <asp:TextBox ID="txtFabPartSize" runat="server" CssClass="form-control form-control-sm" MaxLength="50" placeholder="Collar/Cuff/Btm size" autocomplete="off" />
                                </div>

                                <div style="width:105px">
                                    <label class="form-label" title="Cuff + Double হলে Total Kg / Yds ×২ হবে">Ply (Cuff ×2)</label>
                                    <asp:DropDownList ID="ddlFabPly" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Value="">--</asp:ListItem>
                                        <asp:ListItem>Single</asp:ListItem>
                                        <asp:ListItem>Double</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>

                            <div class="d-flex flex-wrap gap-2 align-items-end mb-3 fab-in">
                                <div>
                                    <label class="form-label">Cons (Kg)</label>
                                    <div class="input-group input-group-sm" style="width:240px">
                                        <asp:TextBox ID="txtFabKgDzn" runat="server" CssClass="form-control fab-num" placeholder="Kg / Dzn" data-grp="kg" data-role="dzn" autocomplete="off" />
                                        <span class="input-group-text">Dzn</span>
                                        <asp:TextBox ID="txtFabKgPc" runat="server" CssClass="form-control fab-num" placeholder="Kg / Pc" data-grp="kg" data-role="pc" autocomplete="off" />
                                        <span class="input-group-text">Pc</span>
                                    </div>
                                </div>

                                <div>
                                    <label class="form-label">Cons (Yds)</label>
                                    <div class="input-group input-group-sm" style="width:240px">
                                        <asp:TextBox ID="txtFabYdDzn" runat="server" CssClass="form-control fab-num" placeholder="Yds / Dzn" data-grp="yd" data-role="dzn" autocomplete="off" />
                                        <span class="input-group-text">Dzn</span>
                                        <asp:TextBox ID="txtFabYdPc" runat="server" CssClass="form-control fab-num" placeholder="Yds / Pc" data-grp="yd" data-role="pc" autocomplete="off" />
                                        <span class="input-group-text">Pc</span>
                                    </div>
                                </div>

                                <div>
                                    <label class="form-label">Rate</label>
                                    <div class="input-group input-group-sm" style="width:240px">
                                        <asp:TextBox ID="txtFabRateDzn" runat="server" CssClass="form-control fab-num" placeholder="Rate / Dzn" data-grp="rate" data-role="dzn" autocomplete="off" />
                                        <span class="input-group-text">Dzn</span>
                                        <asp:TextBox ID="txtFabRatePc" runat="server" CssClass="form-control fab-num" placeholder="Rate / Pc" data-grp="rate" data-role="pc" autocomplete="off" />
                                        <span class="input-group-text">Pc</span>
                                    </div>
                                </div>

                                <div>
                                    <label class="form-label">Process Loss %</label>
                                    <asp:TextBox ID="txtFabLoss" runat="server" CssClass="form-control form-control-sm fab-num" placeholder="0" Width="90px" autocomplete="off" />
                                </div>
                                <div>
                                    <asp:LinkButton ID="btnAddFab" runat="server" CssClass="btn btn-sm btn-success"
                                        OnClick="btnAddFab_Click"><i class="bi bi-plus-lg"></i> Add</asp:LinkButton>
                                    <asp:LinkButton ID="btnSyncFabQty" runat="server" CssClass="btn btn-sm btn-outline-secondary ms-1"
                                        CausesValidation="false" OnClick="btnSyncFabQty_Click"
                                        ToolTip="Qty &amp; Price ট্যাবের Color×Size Qty থেকে সব লাইনের Qty নতুন করে বসাও"><i class="bi bi-arrow-repeat"></i> Sync Qty</asp:LinkButton>
                                </div>
                            </div>

                            <div class="table-responsive">
                                <asp:GridView ID="gvFab" runat="server" AutoGenerateColumns="false"
                                    CssClass="table table-bordered table-sm align-middle emb-tbl fab-tbl"
                                    HeaderStyle-CssClass="table-light" GridLines="None"
                                    OnRowCommand="gvFab_RowCommand" OnRowDataBound="gvFab_RowDataBound"
                                    EmptyDataText="No fabric booking added. Select colors, fabrics &amp; part, enter consumption and click Add.">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Color">
                                            <ItemTemplate>
                                                <b><asp:Literal ID="litFabColor" runat="server" Mode="Encode" Text='<%# Eval("ColorCode") %>' /></b>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Part">
                                            <ItemTemplate>
                                                <span class="badge bg-dark part-badge fab-part"><asp:Literal ID="litFabPart" runat="server" Mode="Encode" Text='<%# Eval("PartName") %>' /></span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Size">
                                            <ItemTemplate>
                                                <asp:Literal ID="litFabSize" runat="server" Mode="Encode" Text='<%# Eval("SizeCode") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Fabric">
                                            <ItemTemplate>
                                                <asp:Literal ID="litFabCode" runat="server" Mode="Encode" Text='<%# Eval("FabricCode") %>' />
                                                <asp:HiddenField ID="hfFabName" runat="server" Value='<%# Eval("FabricName") %>' />
                                                <div class="text-muted small"><%# Server.HtmlEncode(Convert.ToString(Eval("FabricName"))) %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="GSM">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabGsm" runat="server" CssClass="grid-input fab-txt" Style="width:55px" MaxLength="20" Text='<%# Eval("GSM") %>' autocomplete="off" />
                                            </ItemTemplate>
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
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabDiaRow" runat="server" CssClass="grid-input fab-txt" Style="width:55px" MaxLength="20" Text='<%# Eval("Dia") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Part Size">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabPartSizeRow" runat="server" CssClass="grid-input fab-txt" MaxLength="50" Text='<%# Eval("PartSize") %>' autocomplete="off" />
                                            </ItemTemplate>
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

                                        <asp:TemplateField HeaderText="Kg / Dzn">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabKgDzn" runat="server" CssClass="grid-input fab-num" data-grp="kg" data-role="dzn"
                                                    Text='<%# Eval("KgDzn", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Kg / Pc">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabKgPc" runat="server" CssClass="grid-input fab-num" data-grp="kg" data-role="pc"
                                                    Text='<%# Eval("KgPc", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Yds / Dzn">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabYdDzn" runat="server" CssClass="grid-input fab-num" data-grp="yd" data-role="dzn"
                                                    Text='<%# Eval("YdDzn", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Yds / Pc">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabYdPc" runat="server" CssClass="grid-input fab-num" data-grp="yd" data-role="pc"
                                                    Text='<%# Eval("YdPc", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Rate / Dzn">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabRateDzn" runat="server" CssClass="grid-input fab-num" data-grp="rate" data-role="dzn"
                                                    Text='<%# Eval("RateDzn", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Rate / Pc">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabRatePc" runat="server" CssClass="grid-input fab-num" data-grp="rate" data-role="pc"
                                                    Text='<%# Eval("RatePc", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Qty (pcs)">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabQty" runat="server" CssClass="grid-input fab-qty" Text='<%# Eval("Qty") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Loss %">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtFabLoss" runat="server" CssClass="grid-input fab-num" Width="50px" Text='<%# Eval("LossPct", "{0:0.##}") %>' autocomplete="off" />
                                            </ItemTemplate>
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
                                                    CausesValidation="false" CssClass="text-primary me-2" ToolTip="Duplicate this line (then change Size / Dia / Cons)"><i class="bi bi-files"></i></asp:LinkButton>
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

                        <!-- ACCESSORIES BOOKING -->
                        <div class="tab-pane fade" id="acc-tab">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-tag"></i> Trims &amp; Accessories Booking (Color wise)</h6>
                                <span class="stock-note"><i class="bi bi-info-circle"></i> Color ও Accessories সিলেক্ট করুন, Consumption ও Rate দিয়ে Add চাপুন (ফাঁকা রাখলে Style-এর Consumption / Wastage / Unit বসবে)</span>
                            </div>

                            <div class="d-flex flex-wrap gap-2 align-items-end mb-3 fab-in">
                                <div style="width:200px" class="ms-dd dropdown">
                                    <label class="form-label">Style Colors</label>
                                    <button type="button" class="form-select form-select-sm ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="Select colors">Select colors</button>
                                    <div class="dropdown-menu">
                                        <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                        <asp:CheckBoxList ID="cblAccColors" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                                    </div>
                                </div>

                                <div style="width:260px" class="ms-dd dropdown">
                                    <label class="form-label">Style Accessories</label>
                                    <button type="button" class="form-select form-select-sm ms-btn" data-bs-toggle="dropdown" data-bs-auto-close="outside" data-ph="Select accessories">Select accessories</button>
                                    <div class="dropdown-menu">
                                        <label class="d-block border-bottom pb-1 mb-1 fw-semibold"><input type="checkbox" class="ms-all me-1" />Select All</label>
                                        <asp:CheckBoxList ID="cblAccItems" runat="server" CssClass="ms-list" RepeatLayout="Flow" />
                                    </div>
                                </div>

                                <div>
                                    <label class="form-label">Consumption</label>
                                    <div class="input-group input-group-sm" style="width:240px">
                                        <asp:TextBox ID="txtAccConsDzn" runat="server" CssClass="form-control acc-num" placeholder="Cons / Dzn" data-grp="acons" data-role="dzn" autocomplete="off" />
                                        <span class="input-group-text">Dzn</span>
                                        <asp:TextBox ID="txtAccConsPc" runat="server" CssClass="form-control acc-num" placeholder="Cons / Pc" data-grp="acons" data-role="pc" autocomplete="off" />
                                        <span class="input-group-text">Pc</span>
                                    </div>
                                </div>

                                <div style="width:110px">
                                    <label class="form-label">Unit</label>
                                    <asp:DropDownList ID="ddlAccUnit" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Value="">Style Unit</asp:ListItem>
                                        <asp:ListItem>Pcs</asp:ListItem>
                                        <asp:ListItem>Set</asp:ListItem>
                                        <asp:ListItem>Mtr</asp:ListItem>
                                        <asp:ListItem>Yds</asp:ListItem>
                                        <asp:ListItem>Cone</asp:ListItem>
                                        <asp:ListItem>Kg</asp:ListItem>
                                        <asp:ListItem>Roll</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div>
                                    <label class="form-label">Rate</label>
                                    <div class="input-group input-group-sm" style="width:240px">
                                        <asp:TextBox ID="txtAccRateDzn" runat="server" CssClass="form-control acc-num" placeholder="Rate / Dzn" data-grp="arate" data-role="dzn" autocomplete="off" />
                                        <span class="input-group-text">Dzn</span>
                                        <asp:TextBox ID="txtAccRatePc" runat="server" CssClass="form-control acc-num" placeholder="Rate / Pc" data-grp="arate" data-role="pc" autocomplete="off" />
                                        <span class="input-group-text">Pc</span>
                                    </div>
                                </div>

                                <div>
                                    <label class="form-label">Wastage %</label>
                                    <asp:TextBox ID="txtAccLoss" runat="server" CssClass="form-control form-control-sm acc-num" placeholder="0" Width="90px" autocomplete="off" />
                                </div>

                                <div>
                                    <asp:LinkButton ID="btnAddAcc" runat="server" CssClass="btn btn-sm btn-success"
                                        OnClick="btnAddAcc_Click"><i class="bi bi-plus-lg"></i> Add</asp:LinkButton>
                                </div>
                            </div>

                            <div class="table-responsive">
                                <asp:GridView ID="gvAcc" runat="server" AutoGenerateColumns="false"
                                    CssClass="table table-bordered table-sm align-middle emb-tbl"
                                    HeaderStyle-CssClass="table-light" GridLines="None"
                                    OnRowCommand="gvAcc_RowCommand"
                                    EmptyDataText="No accessories booking added. Select colors &amp; accessories, enter consumption and click Add.">
                                    <Columns>
                                        <asp:TemplateField HeaderText="Color">
                                            <ItemTemplate>
                                                <b><asp:Literal ID="litAccColor" runat="server" Mode="Encode" Text='<%# Eval("ColorCode") %>' /></b>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Accessories">
                                            <ItemTemplate>
                                                <asp:Literal ID="litAccCode" runat="server" Mode="Encode" Text='<%# Eval("ItemCode") %>' />
                                                <asp:HiddenField ID="hfAccName" runat="server" Value='<%# Eval("ItemName") %>' />
                                                <asp:HiddenField ID="hfAccType" runat="server" Value='<%# Eval("ItemType") %>' />
                                                <asp:HiddenField ID="hfAccSize" runat="server" Value='<%# Eval("SizeColor") %>' />
                                                <div class="text-muted small"><%# Server.HtmlEncode(Convert.ToString(Eval("ItemName"))) %> <%# Server.HtmlEncode(Convert.ToString(Eval("ItemType"))) %> <%# Server.HtmlEncode(Convert.ToString(Eval("SizeColor"))) %></div>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Cons / Dzn">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtAccConsDzn" runat="server" CssClass="grid-input acc-num" data-grp="acons" data-role="dzn"
                                                    Text='<%# Eval("ConsDzn", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Cons / Pc">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtAccConsPc" runat="server" CssClass="grid-input acc-num" data-grp="acons" data-role="pc"
                                                    Text='<%# Eval("ConsPc", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Unit">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtAccUnit" runat="server" CssClass="grid-input" Width="60px" MaxLength="20" Text='<%# Eval("Unit") %>' />
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Rate / Dzn">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtAccRateDzn" runat="server" CssClass="grid-input acc-num" data-grp="arate" data-role="dzn"
                                                    Text='<%# Eval("RateDzn", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Rate / Pc">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtAccRatePc" runat="server" CssClass="grid-input acc-num" data-grp="arate" data-role="pc"
                                                    Text='<%# Eval("RatePc", "{0:0.####}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Wastage %">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtAccLoss" runat="server" CssClass="grid-input acc-num" Width="60px" Text='<%# Eval("WastePct", "{0:0.##}") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Qty (pcs)">
                                            <ItemTemplate>
                                                <asp:TextBox ID="txtAccQty" runat="server" CssClass="grid-input acc-qty" Text='<%# Eval("Qty") %>' autocomplete="off" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Total Qty" ItemStyle-CssClass="text-end fw-bold">
                                            <ItemTemplate><asp:Label ID="lblAccTotalQty" runat="server" CssClass="acc-tqty" Text='<%# Eval("TotalQty", "{0:N2}") %>' /></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Amount" ItemStyle-CssClass="text-end fw-bold">
                                            <ItemTemplate><asp:Label ID="lblAccAmt" runat="server" CssClass="acc-amt" Text='<%# Eval("Amount", "{0:N2}") %>' /></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Book?">
                                            <ItemTemplate><asp:CheckBox ID="chkBookAcc" runat="server" Checked='<%# Eval("IsBooked") %>' /></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Action" ItemStyle-Width="60px">
                                            <ItemTemplate>
                                                <asp:LinkButton runat="server" CommandName="RemoveRow" CommandArgument='<%# Container.DataItemIndex %>'
                                                    CausesValidation="false" CssClass="text-danger" ToolTip="Remove"
                                                    OnClientClick="return confirm('Remove this row?');"><i class="bi bi-trash"></i></asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                            <div class="text-end fw-bold">
                                Total Amount: <asp:Label ID="lblAccSumAmt" runat="server" CssClass="acc-sum-amt" Text="0.00" />
                            </div>
                        </div>

                        <!-- SHIPMENT -->
                        <div class="tab-pane fade" id="ship-tab">
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label class="form-label required">Ship Mode</label>
                                    <asp:DropDownList ID="ddlShipMode" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Value="">-- Select --</asp:ListItem>
                                        <asp:ListItem>Sea</asp:ListItem><asp:ListItem>Air</asp:ListItem><asp:ListItem>Road</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label required">Incoterms</label>
                                    <asp:DropDownList ID="ddlIncoterms" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Value="">-- Select --</asp:ListItem>
                                        <asp:ListItem>FOB</asp:ListItem><asp:ListItem>CIF</asp:ListItem>
                                        <asp:ListItem>CFR</asp:ListItem><asp:ListItem>EXW</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label required">Port of Loading</label>
                                    <asp:TextBox ID="txtPOL" runat="server" CssClass="form-control form-control-sm" Text="Chattogram" MaxLength="100" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label required">Port of Discharge</label>
                                    <asp:TextBox ID="txtPOD" runat="server" CssClass="form-control form-control-sm" MaxLength="100" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label required">Final Ship Date</label>
                                    <asp:TextBox ID="txtShipDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label required">Delivery Date</label>
                                    <asp:TextBox ID="txtDeliveryDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Partial Shipment</label>
                                    <asp:DropDownList ID="ddlPartial" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem>Allowed</asp:ListItem><asp:ListItem>Not Allowed</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label">Transhipment</label>
                                    <asp:DropDownList ID="ddlTranship" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem>Allowed</asp:ListItem><asp:ListItem>Not Allowed</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Freight Forwarder</label>
                                    <asp:TextBox ID="txtForwarder" runat="server" CssClass="form-control form-control-sm" MaxLength="150" />
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Export LC No</label>
                                    <asp:TextBox ID="txtLCNo" runat="server" CssClass="form-control form-control-sm" MaxLength="50" />
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Inspection Type</label>
                                    <asp:DropDownList ID="ddlInspection" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Value="">-- Select --</asp:ListItem>
                                        <asp:ListItem>Internal</asp:ListItem><asp:ListItem>Buyer QC</asp:ListItem>
                                        <asp:ListItem>SGS</asp:ListItem><asp:ListItem>BV</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-12">
                                    <label class="form-label">PO Remarks</label>
                                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control form-control-sm" MaxLength="500" />
                                </div>
                            </div>
                        </div>

                        <!-- PAYMENT -->
                        <div class="tab-pane fade" id="pay-tab">
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label required">Payment Terms</label>
                                    <asp:DropDownList ID="ddlPaymentTerms" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem Value="">-- Select --</asp:ListItem>
                                        <asp:ListItem>LC at Sight</asp:ListItem>
                                        <asp:ListItem>TT 30 Days</asp:ListItem>
                                        <asp:ListItem>TT 60 Days</asp:ListItem>
                                        <asp:ListItem>TT 90 Days</asp:ListItem>
                                        <asp:ListItem>DA</asp:ListItem>
                                        <asp:ListItem>DP</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Advance %</label>
                                    <asp:TextBox ID="txtAdvance" runat="server" CssClass="form-control form-control-sm" Text="0" />
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">Balance %</label>
                                    <asp:TextBox ID="txtBalance" runat="server" CssClass="form-control form-control-sm ro" ReadOnly="true" Text="100" />
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">Bank Charge Bear By</label>
                                    <asp:DropDownList ID="ddlBankCharge" runat="server" CssClass="form-select form-select-sm">
                                        <asp:ListItem>Buyer</asp:ListItem><asp:ListItem>Seller</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

        </asp:Panel>

    </div>
</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
(function () {
    var unitPriceId = '<%= txtUnitPrice.ClientID %>';
    var poQtyId     = '<%= txtPOQty.ClientID %>';
    var totalValId  = '<%= txtTotalValue.ClientID %>';
    var tabHfId = '<%= hfActiveTab.ClientID %>';

    function num(v) { v = parseFloat(String(v).replace(/,/g, '')); return isNaN(v) ? 0 : v; }
    function fmt(v, d) { return v.toLocaleString('en-US', { minimumFractionDigits: d, maximumFractionDigits: d }); }

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

    /* ---------- qty matrix : live totals ---------- */
    function recalcMatrix() {
        var tbl = document.getElementById('matrixTbl');
        if (!tbl) return;
        var price = num(document.getElementById(unitPriceId).value);
        var colTotals = [], grand = 0;
        tbl.querySelectorAll('tbody tr').forEach(function (tr) {
            var rowTot = 0;
            tr.querySelectorAll('input.qty-input').forEach(function (inp, j) {
                var q = parseInt(inp.value, 10); if (isNaN(q)) q = 0;
                rowTot += q; colTotals[j] = (colTotals[j] || 0) + q;
            });
            grand += rowTot;
            var rt = tr.querySelector('.row-total'), rv = tr.querySelector('.row-value');
            if (rt) rt.textContent = fmt(rowTot, 0);
            if (rv) rv.textContent = fmt(rowTot * price, 2);
        });
        tbl.querySelectorAll('tfoot .col-total').forEach(function (s, j) { s.textContent = fmt(colTotals[j] || 0, 0); });
        var g = tbl.querySelector('.grand-total'), gv = tbl.querySelector('.grand-value');
        if (g) g.textContent = fmt(grand, 0);
        if (gv) gv.textContent = fmt(grand * price, 2);
        document.getElementById(poQtyId).value = grand;
        document.getElementById(totalValId).value = fmt(grand * price, 2);
    }

    /* ---------- embellishment : live amount ---------- */
    function recalcEmb(tr) {
        if (tr) {
            var q = num((tr.querySelector('.emb-qty') || {}).value), r = num((tr.querySelector('.emb-rate') || {}).value);
            var a = tr.querySelector('.emb-amt'); if (a) a.textContent = fmt(q * r, 2);
        }
        var sum = 0;
        document.querySelectorAll('.emb-amt').forEach(function (s) { sum += num(s.textContent); });
        var t = document.querySelector('.emb-total'); if (t) t.textContent = fmt(sum, 2);
    }

    document.addEventListener('input', function (e) {
        var t = e.target;
        if (t.classList.contains('qty-input')) {
            var clean = t.value.replace(/[^0-9]/g, '');
            if (clean !== t.value) t.value = clean;
            recalcMatrix();
        } else if (t.id === unitPriceId) {
            recalcMatrix();
        } else if (t.classList.contains('emb-qty') || t.classList.contains('emb-rate')) {
            recalcEmb(t.closest('tr'));
        }
    });

    /* Enter → next input (row by row, left to right) */
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        var t = e.target;
        if (t.classList && t.classList.contains('qty-input')) {
            e.preventDefault();
            var all = [].slice.call(document.querySelectorAll('#matrixTbl input.qty-input'));
            var i = all.indexOf(t);
            if (i >= 0 && i < all.length - 1) { all[i + 1].focus(); all[i + 1].select(); }
        } else if (t.classList && (t.classList.contains('emb-qty') || t.classList.contains('emb-rate'))) {
            e.preventDefault();
            var all2 = [].slice.call(document.querySelectorAll('.emb-qty, .emb-rate'));
            var k = all2.indexOf(t);
            if (k >= 0 && k < all2.length - 1) { all2[k + 1].focus(); all2[k + 1].select(); }
        }
    });
    document.addEventListener('focusin', function (e) {
        if (e.target.classList && (e.target.classList.contains('qty-input') || e.target.classList.contains('emb-qty') || e.target.classList.contains('emb-rate')))
            e.target.select();
    });

    /* ---------- fabric booking : Dzn <-> Pc sync + live totals ---------- */
    function r4(v) { return Math.round(v * 10000) / 10000; }

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
        var f = 1 + val('[id$="txtFabLoss"]') / 100;
        /* Cuff + Double ply → x2 */
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

    /* Ply changed (Single/Double) → recalc that row */
    document.addEventListener('change', function (e) {
        var t = e.target;
        if (t.id && t.id.indexOf('ddlFabPlyRow') >= 0) {
            recalcFabRow(t.closest('tr')); recalcFabTotals();
        }
    });

    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        var t = e.target;
        if (t.classList && (t.classList.contains('fab-num') || t.classList.contains('fab-qty'))) {
            e.preventDefault();
            var all = [].slice.call(document.querySelectorAll('#fabric-tab .fab-num, #fabric-tab .fab-qty'));
            var i = all.indexOf(t);
            if (i >= 0 && i < all.length - 1) { all[i + 1].focus(); all[i + 1].select(); }
        }
    });
    document.addEventListener('focusin', function (e) {
        if (e.target.classList && (e.target.classList.contains('fab-num') || e.target.classList.contains('fab-qty')))
            e.target.select();
    });

    /* ---------- accessories booking : Dzn <-> Pc sync + live totals ---------- */
    function recalcAccRow(tr) {
        if (!tr) return;
        function val(sel) { var el = tr.querySelector(sel); return el ? num(el.value) : 0; }
        var qty = parseInt((tr.querySelector('.acc-qty') || {}).value, 10); if (isNaN(qty)) qty = 0;
        var f = 1 + val('[id$="txtAccLoss"]') / 100;
        var tq = qty * f * val('[data-grp="acons"][data-role="pc"]');
        var amt = qty * val('[data-grp="arate"][data-role="pc"]');
        var a = tr.querySelector('.acc-tqty'); if (a) a.textContent = fmt(tq, 2);
        var b = tr.querySelector('.acc-amt'); if (b) b.textContent = fmt(amt, 2);
    }

    function recalcAccTotals() {
        var amt = 0;
        document.querySelectorAll('.acc-amt').forEach(function (s) { amt += num(s.textContent); });
        var z = document.querySelector('.acc-sum-amt'); if (z) z.textContent = fmt(amt, 2);
    }

    document.addEventListener('input', function (e) {
        var t = e.target;
        if (t.classList.contains('acc-num')) {
            var clean = t.value.replace(/[^0-9.]/g, '');
            if (clean !== t.value) t.value = clean;
            fabSync(t);
            var tr = t.closest('tr');
            if (tr) { recalcAccRow(tr); recalcAccTotals(); }
        } else if (t.classList.contains('acc-qty')) {
            var clean2 = t.value.replace(/[^0-9]/g, '');
            if (clean2 !== t.value) t.value = clean2;
            recalcAccRow(t.closest('tr')); recalcAccTotals();
        }
    });

    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        var t = e.target;
        if (t.classList && (t.classList.contains('acc-num') || t.classList.contains('acc-qty'))) {
            e.preventDefault();
            var all = [].slice.call(document.querySelectorAll('#acc-tab .acc-num, #acc-tab .acc-qty'));
            var i = all.indexOf(t);
            if (i >= 0 && i < all.length - 1) { all[i + 1].focus(); all[i + 1].select(); }
        }
    });
    document.addEventListener('focusin', function (e) {
        if (e.target.classList && (e.target.classList.contains('acc-num') || e.target.classList.contains('acc-qty')))
            e.target.select();
    });

    /* ---------- keep active tab across postbacks ---------- */
    document.addEventListener('shown.bs.tab', function (e) {
        var target = e.target.getAttribute('data-bs-target');
        var hf = document.getElementById(tabHfId);
        if (hf && target) hf.value = target;
    });
    window.addEventListener('load', function () {
        var hf = document.getElementById(tabHfId);
        if (!hf || !hf.value || hf.value === '#qty-tab') return;
        var btn = document.querySelector('[data-bs-target="' + hf.value + '"]');
        if (btn) bootstrap.Tab.getOrCreateInstance(btn).show();
    });
})();
</script>
</body>
</html>
