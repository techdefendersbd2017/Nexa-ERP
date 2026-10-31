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

                        <!-- FABRIC -->
                        <div class="tab-pane fade" id="fabric-tab">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-layers"></i> Fabric Requirement (auto from Style)</h6>
                                <span class="stock-note"><i class="bi bi-info-circle"></i> Consumption Style থেকে — শুধু "Book" টিক দিন</span>
                            </div>
                            <div class="table-responsive">
                                <asp:GridView ID="gvFabric" runat="server" AutoGenerateColumns="false"
                                    CssClass="table table-bordered table-sm align-middle"
                                    HeaderStyle-CssClass="table-light" GridLines="None"
                                    EmptyDataText="No fabric in style.">
                                    <Columns>
                                        <asp:BoundField DataField="FabricCode" HeaderText="Code" />
                                        <asp:BoundField DataField="FabricName" HeaderText="Name" />
                                        <asp:BoundField DataField="Composition" HeaderText="Composition" />
                                        <asp:BoundField DataField="GSM" HeaderText="GSM" />
                                        <asp:BoundField DataField="ColorName" HeaderText="Color" />
                                        <asp:BoundField DataField="Consumption" HeaderText="Cons/pc" DataFormatString="{0:0.000}" />
                                        <asp:BoundField DataField="Unit" HeaderText="Unit" />
                                        <asp:BoundField DataField="TotalQty" HeaderText="Total Qty (auto)" DataFormatString="{0:N2}" ItemStyle-CssClass="fw-bold" />
                                        <asp:TemplateField HeaderText="Book?">
                                            <ItemTemplate><asp:CheckBox runat="server" ID="chkBookFab" Checked="true" /></ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>

                        <!-- ACCESSORIES -->
                        <div class="tab-pane fade" id="acc-tab">
                            <div class="d-flex justify-content-between align-items-center mb-2">
                                <h6 class="text-uppercase text-secondary fw-bold m-0"><i class="bi bi-tag"></i> Trims &amp; Accessories (auto from Style)</h6>
                                <span class="stock-note"><i class="bi bi-info-circle"></i> Style-এর Accessories লিস্ট — শুধু Book টিক দিন</span>
                            </div>
                            <div class="table-responsive">
                                <asp:GridView ID="gvAcc" runat="server" AutoGenerateColumns="false"
                                    CssClass="table table-bordered table-sm align-middle"
                                    HeaderStyle-CssClass="table-light" GridLines="None"
                                    EmptyDataText="No accessories in style.">
                                    <Columns>
                                        <asp:BoundField DataField="ItemCode" HeaderText="Item Code" />
                                        <asp:BoundField DataField="ItemName" HeaderText="Item Name" />
                                        <asp:BoundField DataField="ItemType" HeaderText="Type" />
                                        <asp:BoundField DataField="SizeColor" HeaderText="Size/Color" />
                                        <asp:BoundField DataField="Consumption" HeaderText="Cons/pc" DataFormatString="{0:0.000}" />
                                        <asp:BoundField DataField="Unit" HeaderText="Unit" />
                                        <asp:BoundField DataField="WastagePercent" HeaderText="Waste %" DataFormatString="{0:0.00}" />
                                        <asp:BoundField DataField="TotalQty" HeaderText="Total Qty (auto)" DataFormatString="{0:N2}" ItemStyle-CssClass="fw-bold" />
                                        <asp:TemplateField HeaderText="Book?">
                                            <ItemTemplate><asp:CheckBox runat="server" ID="chkBookAcc" Checked="true" /></ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
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
