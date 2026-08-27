<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeliveryBill.aspx.cs" Inherits="Nexa_ERP.Shipment.DeliveryBill" %>

<!DOCTYPE html>
<html lang="bn">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Delivery Challan &amp; Commercial Bill</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- Select2 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/select2-bootstrap-5-theme@1.3.0/dist/select2-bootstrap-5-theme.min.css" rel="stylesheet" />

    <style>
        body { background-color: #f4f6f9; font-size: 14px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .card-header-custom { background: linear-gradient(135deg, #2e7d32 0%, #1b5e20 100%); color: #fff; font-weight: bold; }
        .card { border: none; border-radius: 10px; overflow: hidden; width: 100%; }
        .grid { width: 100%; background: white; border: 1px solid #dee2e6; border-radius: 6px; }
        .grid th { background-color: #2e7d32; color: white; padding: 10px; text-align: center; }
        .grid td { padding: 8px; border-bottom: 1px solid #eef0f2; vertical-align: middle; }

        fieldset.section-box {
            background-color: #fbfcfe; border: 1px solid #e1e6ec !important;
            border-radius: 10px !important; padding: 18px 20px !important; margin-bottom: 22px !important;
        }
        fieldset.section-box legend {
            background-color: #e8f5e9; padding: 4px 14px !important;
            border-radius: 20px; color: #2e7d32 !important; font-size: 0.95rem !important; font-weight: bold; width: auto; float: none;
        }

        .summary-box .input-group-text { background-color: #eef2f7; color: #1f4e78; }
        .summary-box .input-group-text.grand-total { background-color: #1f4e78 !important; color: #fff !important; }
        .summary-box .form-control { font-weight: 600; }

        .list-toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; }
        .list-title { font-size: 1.3rem; font-weight: 700; color: #2e7d32; }

        .empty-hint { color: #94a3b8; font-size: 12.5px; padding: 10px; text-align: center; }

        .row-already-billed { background-color: #f1f3f5 !important; color: #94a3b8; }
        .row-already-billed td { color: #94a3b8; }
        .billed-badge {
            display: inline-block; font-size: 11px; font-weight: 600; color: #b45309;
            background-color: #fef3c7; border-radius: 10px; padding: 2px 8px; margin-left: 6px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />
        <div class="container-fluid px-4 my-4">
            <!-- ================= 1. LIST PANEL ================= -->
            <asp:Panel ID="pnlList" runat="server" CssClass="panel">
                <div class="list-toolbar">
                    <div class="list-title">Delivery Challan &amp; Bill List</div>
                    <asp:LinkButton ID="btnNewChallan" runat="server" CssClass="btn btn-success btn-sm" OnClick="btnNewChallan_Click">+ Create New Challan &amp; Bill</asp:LinkButton>
                </div>
                <div class="table-responsive w-100">
                    <asp:GridView ID="gvChallanList" runat="server" CssClass="grid" AutoGenerateColumns="false"
                        GridLines="None" EmptyDataText="No bill has been created yet."
                        OnRowDataBound="gvChallanList_RowDataBound">
                        <Columns>
                            <asp:TemplateField HeaderText="SL">
                                <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="InvoiceNo" HeaderText="Invoice No" />
                            <asp:BoundField DataField="BillDate" HeaderText="Bill Date" DataFormatString="{0:dd-MMM-yyyy}" />
                            <asp:BoundField DataField="PartyName" HeaderText="Customer" />
                            <asp:BoundField DataField="GrandTotalAmount" HeaderText="Bill Amount" DataFormatString="{0:0.00}" />
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <asp:HyperLink ID="lnkView" runat="server" CssClass="btn btn-sm btn-outline-primary"
                                        Target="_blank" Text="View"
                                        NavigateUrl='<%# "BillInvoiceReport.aspx?BillId=" + Eval("CommercialBillHeaderID") %>' />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </asp:Panel>

            <!-- ================= 2. FORM PANEL ================= -->
            <asp:Panel ID="pnlForm" runat="server" CssClass="panel" Visible="true">
                <div class="card shadow-sm">
                    <div class="card-header card-header-custom py-2 d-flex justify-content-between align-items-center">
                        <span>Delivery Challan &amp; Commercial Bill Entry</span>
                        <asp:LinkButton ID="btnBackList" runat="server" CssClass="btn btn-light btn-sm text-dark fw-bold"
                            OnClick="btnBackList_Click">&#8592; Back to List</asp:LinkButton>
                    </div>

                    <div class="card-body p-4">

                        <asp:UpdatePanel ID="upForm" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                                                    <!-- SECTION 1: COMMERCIAL BILL REF INFO -->
                        <fieldset class="section-box">
                            <legend>Commercial Bill / Invoice Info</legend>
                            <div class="row g-3">
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Bill / Invoice No.[Auto]</label>
                                    <asp:TextBox ID="txtInvoiceNo" runat="server" CssClass="form-control form-control-sm" ReadOnly="true" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Bill Date</label>
                                    <asp:TextBox ID="txtBillDate" runat="server" TextMode="Date" CssClass="form-control form-control-sm" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Payment Terms</label>
                                    <asp:TextBox ID="txtPaymentTerms" runat="server" CssClass="form-control form-control-sm" />
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Remarks</label>
                                    <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control form-control-sm" placeholder="Delivery Remarks" />
                                </div>
                            </div>
                        </fieldset>

                        <!-- SECTION 2: REFERENCE WORK ORDER -->
                        <fieldset class="section-box">
                            <legend>Select Work Order</legend>
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Receiving Branch</label>
                                    <asp:DropDownList ID="ddlReceivingBranch" runat="server" CssClass="form-select form-select-sm searchable-dropdown">
                                        <asp:ListItem Text="-- Select Branch --" Value="" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Customer Name</label>
                                    <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="form-select form-select-sm searchable-dropdown"
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlCustomer_SelectedIndexChanged">
                                        <asp:ListItem Text="-- Select Customer --" Value="" />
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-bold">Work Order No</label>
                                    <asp:DropDownList ID="ddlWorkOrder" runat="server" CssClass="form-select form-select-sm searchable-dropdown"
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlWorkOrder_SelectedIndexChanged">
                                        <asp:ListItem Text="-- Select Work Order --" Value="" />
                                    </asp:DropDownList>
                                </div>
                            </div>
                        </fieldset>

                        <!-- PENDING CHALLANS GRID -->
                        <fieldset class="section-box">
                            <legend>Pending Delivery Challans for Billing</legend>
                            <div class="text-muted mb-2" style="font-size:12px;">
                                <span class="billed-badge">Already Billed</span> The checkbox for the selected row is intentionally disabled because the bill for that challan has already been created.
                            </div>
                            <div class="table-responsive w-100 mb-3">
                                <asp:GridView ID="gvPendingChallans" runat="server" CssClass="table table-bordered table-hover table-sm text-center align-middle w-100"
                                    AutoGenerateColumns="false" GridLines="None" DataKeyNames="DeliveryChallanHeaderID"
                                    EmptyDataText="Please select a Work Order"
                                    OnRowDataBound="gvPendingChallans_RowDataBound">
                                    <Columns>
                                        <asp:TemplateField>
                                            <HeaderTemplate>
                                                <asp:CheckBox ID="chkAcction" runat="server" Text=" " onclick="selectAllChallans(this);" />
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:CheckBox ID="chkRow" runat="server" CssClass="chk-challan" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:BoundField DataField="DeliveryChallanHeaderID" HeaderText="Challan ID" />
                                        <asp:BoundField DataField="DeliveryChallanNumber" HeaderText="Challan No" />
                                        <asp:BoundField DataField="DeliveryChallanDate" HeaderText="Challan Date" />
                                        <asp:BoundField DataField="RefWorkOrderNo" HeaderText="WO Ref No" />
                                        <asp:BoundField DataField="PartyName" HeaderText="Customer" />
                                        <asp:BoundField DataField="GrandTotalAmount" HeaderText="Bill Amount" DataFormatString="{0:0.00}" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                            <div class="text-end">
                                <asp:Button ID="btnAddSelectedChallans" runat="server" CssClass="btn btn-primary btn-sm px-3"
                                    Text="Add Selected Challans to Bill ↓" OnClick="btnAddSelectedChallans_Click" />
                            </div>
                        </fieldset>



                        <!-- SECTION 3: ITEMS BILLING GRID -->
                        <fieldset class="section-box">
                            <legend>Billed Items &amp; Financial Details</legend>
                            <div class="table-responsive w-100">
<asp:GridView ID="gvSelectedChallans" runat="server" CssClass="table table-bordered table-hover table-sm text-center align-middle w-100"
    AutoGenerateColumns="False" GridLines="None" DataKeyNames="DeliveryChallanHeaderID"
    EmptyDataText="Please select a Work Order"
    OnRowDataBound="gvPendingChallans_RowDataBound"
    OnRowCommand="gvSelectedChallans_RowCommand">
    <Columns>
        <asp:TemplateField>
            <HeaderTemplate>
            </HeaderTemplate>
            <ItemTemplate>
                <asp:CheckBox ID="chkRow" runat="server" Checked="true" CssClass="chk-challan" />
            </ItemTemplate>
        </asp:TemplateField>
        <asp:BoundField DataField="DeliveryChallanHeaderID" HeaderText="Challan ID" />
        <asp:BoundField DataField="DeliveryChallanNumber" HeaderText="Challan No" />
        <asp:BoundField DataField="DeliveryChallanDate" HeaderText="Challan Date" />
        <asp:BoundField DataField="RefWorkOrderNo" HeaderText="WO Ref No" />
        <asp:BoundField DataField="PartyName" HeaderText="Customer" />
        <asp:BoundField DataField="GrandTotalAmount" HeaderText="Bill Amount" DataFormatString="{0:0.00}" />
        <asp:TemplateField HeaderText="Action">
            <ItemTemplate>
                <asp:LinkButton ID="btnRemoveRow" runat="server" CssClass="btn btn-sm btn-outline-danger rounded-circle"
                    CommandName="Delete" CommandArgument='<%# Container.DataItemIndex %>'
                    ToolTip="Remove" Style="width:26px; height:26px; padding:0; line-height:1; font-weight:bold;">&times;</asp:LinkButton>
            </ItemTemplate>
        </asp:TemplateField>
    </Columns>
</asp:GridView>
                            </div>

                            <!-- Summary / Totals -->
                            <div class="row justify-content-end mt-3">
                                <div class="col-md-4 summary-box">
                                    <div class="input-group input-group-sm mb-2">
                                        <span class="input-group-text fw-bold w-50">Sub Total Amount</span>
                                        <asp:TextBox ID="txtSubTotal" runat="server" CssClass="form-control text-end" ReadOnly="true" />
                                    </div>
                                    <div class="input-group input-group-sm mb-2">
                                        <span class="input-group-text fw-bold w-50">Transport Cost</span>
                                        <asp:TextBox ID="txtTransport" runat="server" CssClass="form-control text-end" Text="0.00"
                                            AutoPostBack="true" />
                                    </div>
                                    <div class="input-group input-group-sm mb-2">
                                        <span class="input-group-text fw-bold w-50">VAT / Tax (%)</span>
                                        <asp:TextBox ID="txtVat" runat="server" CssClass="form-control text-end" Text="0"
                                            AutoPostBack="true"/>
                                    </div>
                                    <div class="input-group input-group-sm">
                                        <span class="input-group-text fw-bold w-50 grand-total">Grand Total Amount</span>
                                        <asp:TextBox ID="txtGrandTotal" runat="server" CssClass="form-control text-end fw-bold" ReadOnly="true" />
                                    </div>
                                </div>
                            </div>
                        </fieldset>

                        <!-- Action Buttons -->
                        <div class="d-flex gap-2">
                            <asp:Button ID="btnSave" runat="server" CssClass="btn btn-success px-4" Text="Save & Print Bill" OnClick="btnSave_Click" />
                            <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel"
                                OnClick="btnCancel_Click" CausesValidation="false" />
                        </div>

                        </ContentTemplate>
                        </asp:UpdatePanel>

                    </div>
                </div>
            </asp:Panel>

        </div>

        <!-- jQuery & Select2 JS -->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

        <script>
            function initSelect2() {
                $('.searchable-dropdown').select2({
                    theme: "bootstrap-5",
                    placeholder: "Select Option",
                    allowClear: true,
                    width: '100%'
                });
            }

            // হেডার চেকবক্স দিয়ে সব পেন্ডিং চালানের রো সিলেক্ট বা আনসিলেক্ট করার ফাংশন
            function selectAllChallans(headerChk) {
                var checked = $(headerChk).is(':checked');
                $('#<%= gvPendingChallans.ClientID %> input[type="checkbox"]:not(:disabled)').each(function () {
                    $(this).prop('checked', checked);
                });
            }

            // রো-এর চেক বক্স পরিবর্তন হলে হেডার স্টেট আপডেট করার লজিক (ঐচ্ছিক)
            function updateSelectAllState() {
                var $enabledBoxes = $('#<%= gvPendingChallans.ClientID %> input[type="checkbox"].chk-challan:not(:disabled)');
                var $checkedBoxes = $enabledBoxes.filter(':checked');
                var headerChk = document.getElementById('<%= gvPendingChallans.ClientID %>_chkAcction');
                
                if (headerChk && $enabledBoxes.length > 0) {
                    if ($checkedBoxes.length === $enabledBoxes.length) {
                        headerChk.checked = true;
                        headerChk.indeterminate = false;
                    } else if ($checkedBoxes.length === 0) {
                        headerChk.checked = false;
                        headerChk.indeterminate = false;
                    } else {
                        headerChk.checked = false;
                        headerChk.indeterminate = true;
                    }
                }
            }

            $(function () {
                initSelect2();

                $(document).on('change', '#<%= gvPendingChallans.ClientID %> input[type="checkbox"].chk-challan', function () {
                    updateSelectAllState();
                });

                if (typeof Sys !== 'undefined' && Sys.WebForms) {
                    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                        initSelect2();
                    });
                }
            });
        </script>
    </form>
</body>
</html>