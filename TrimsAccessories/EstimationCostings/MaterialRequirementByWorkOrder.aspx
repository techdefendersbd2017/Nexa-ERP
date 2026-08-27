<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialRequirementByWorkOrder.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.MaterialRequirementByWorkOrder" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Material Requirement (Work Order + Costing Link)</title>
    <style>
        :root{
            --brand-900:#0f3352;
            --brand-800:#123a5c;
            --brand-700:#1f4e78;
            --brand-100:#e7eef5;
            --ink:#1e293b;
            --muted:#64748b;
            --line:#dbe2ea;
            --bg:#eef1f5;
            --card:#ffffff;
            --ok:#2e7d32;
            --ok-dark:#256428;
            --danger:#c62828;
            --danger-dark:#a92222;
            --neutral:#455163;
            --neutral-dark:#37404d;
            --info:#0277bd;
            --info-dark:#02669f;
            --radius:8px;
            --radius-sm:5px;
            --shadow:0 1px 2px rgba(15,51,82,.06), 0 4px 14px rgba(15,51,82,.06);
        }
        *{ box-sizing:border-box; }
        body{
            font-family:"Segoe UI", Arial, sans-serif;
            font-size:13px;
            color:var(--ink);
            background:var(--bg);
            margin:0;
            padding:24px 16px;
        }
        .container{
            background:var(--card);
            border:1px solid var(--line);
            border-radius:var(--radius);
            max-width:1200px;
            margin:auto;
            box-shadow:var(--shadow);
            overflow:hidden;
        }
        .header-title{
            background:linear-gradient(135deg, var(--brand-900), var(--brand-700));
            color:#fff;
            padding:16px 22px;
            font-weight:600;
            font-size:16px;
        }
        .body-pad{ padding:20px 22px 24px; }
        .panel{ display:none; }
        .panel.active{ display:block; }
        .section-label{
            font-weight:700;
            color:var(--brand-700);
            text-transform:uppercase;
            letter-spacing:.4px;
            font-size:11.5px;
            border-bottom:2px solid var(--brand-700);
            padding-bottom:6px;
            margin-bottom:14px;
        }
        .form-grid{
            display:grid;
            grid-template-columns:repeat(4, 1fr);
            gap:14px 22px;
            margin-bottom:18px;
        }
        .field{ display:flex; flex-direction:column; gap:5px; }
        .field.span-2{ grid-column:span 2; }
        .field label{ font-weight:600; font-size:12px; color:var(--muted); }
        .form-control{
            padding:8px 10px;
            border:1px solid #cbd5e1;
            border-radius:var(--radius-sm);
            font-size:13px;
            width:100%;
            background:#fff;
            color:var(--ink);
        }
        .info-box{
            background:var(--brand-100);
            border:1px dashed var(--brand-700);
            border-radius:var(--radius-sm);
            padding:12px 16px;
            margin-bottom:18px;
            display:grid;
            grid-template-columns:repeat(4,1fr);
            gap:10px 20px;
            font-size:12.5px;
        }
        .info-box .k{ color:var(--muted); font-weight:600; display:block; }
        .info-box .v{ font-weight:700; color:var(--brand-900); }
        table.grid, .grid{
            width:100%;
            border-collapse:collapse;
            margin-top:10px;
            border-radius:var(--radius-sm);
            overflow:hidden;
        }
        table.grid th, table.grid td, .grid th, .grid td{
            border:1px solid var(--line);
            padding:9px 8px;
            text-align:center;
            font-size:12.5px;
        }
        table.grid th, .grid th{
            background:var(--brand-700);
            color:#fff;
            font-weight:600;
            text-transform:uppercase;
            letter-spacing:.3px;
            font-size:12px;
        }
        table.grid tr:nth-child(even) td, .grid tr:nth-child(even) td{ background:#f8fafc; }
        .btn{
            padding:8px 18px;
            border:none;
            border-radius:var(--radius-sm);
            color:#fff;
            font-weight:600;
            cursor:pointer;
            font-size:13px;
        }
        .btn:hover{ filter:brightness(1.08); }
        .btn-save{ background:var(--ok); }
        .btn-cancel{ background:var(--neutral); }
        .btn-delete{ background:var(--danger); }
        .btn-back{ background:var(--info); }
        .btn-new{ background:var(--ok); }
        .btn-load{ background:var(--brand-700); }
        .btn-print{ background:var(--neutral); }
        .list-toolbar{ display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; }
        .list-title{ font-weight:700; color:var(--brand-700); font-size:14.5px; }
        .action-bar{ margin-top:22px; border-top:1px solid var(--line); padding-top:16px; display:flex; gap:10px; }
        .totals-section{
            width:340px;
            max-width:100%;
            float:right;
            margin-top:16px;
            background:#f8fafc;
            border:1px solid var(--line);
            border-radius:var(--radius-sm);
            padding:10px 14px;
            font-weight:700;
            display:flex;
            justify-content:space-between;
        }
        .clearfix::after{ content:""; clear:both; display:table; }

        @media print{
            body *{ visibility:hidden; }
            #pnlReport, #pnlReport *{ visibility:visible; }
            #pnlReport{ position:absolute; left:0; top:0; width:100%; }
            .no-print{ display:none !important; }
        }
    </style>
    <script type="text/javascript">
        function showPanel(panelId) {
            document.getElementById("pnlList").classList.remove("active");
            document.getElementById("pnlForm").classList.remove("active");
            document.getElementById("pnlReport").classList.remove("active");
            document.getElementById(panelId).classList.add("active");
        }
        function printReport() {
            window.print();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hdnWORcvID" runat="server" />
        <asp:HiddenField ID="hdnQuotationID" runat="server" />
        <asp:HiddenField ID="hdnMRID" runat="server" />

        <div class="container active">
            <div class="header-title">Material Requirement &mdash; Work Order + Costing Link</div>
            <div class="body-pad">

                <!-- ================= 1. LIST PANEL ================= -->
                <div id="pnlList" runat="server" class="panel active">
                    <div class="list-toolbar">
                        <div class="list-title">Material Requirement List</div>
                        <asp:Button ID="btnAddNew" runat="server" Text="+ New Material Requirement" CssClass="btn btn-new" OnClick="btnAddNew_Click"/>
                    </div>

                    <asp:GridView ID="gvMRList" runat="server" AutoGenerateColumns="False" CssClass="grid" ShowHeaderWhenEmpty="True" OnRowCommand="gvMRList_RowCommand">
                        <EmptyDataTemplate>
                            <div style="color:#777;padding:12px;text-align:center;">No records found. Click "+ New Material Requirement" to add one.</div>
                        </EmptyDataTemplate>
                        <Columns>
                            <asp:TemplateField HeaderText="SL">
                                <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                <ItemStyle Width="40px" />
                            </asp:TemplateField>
                            <asp:BoundField DataField="MRNo" HeaderText="MR No" />
                            <asp:BoundField DataField="MRDate" HeaderText="MR Date" DataFormatString="{0:dd-MM-yyyy}" />
                            <asp:BoundField DataField="WORcvNo" HeaderText="Work Order No" />
                            <asp:BoundField DataField="QuotationCode" HeaderText="Quotation No" />
                            <asp:BoundField DataField="Customer" HeaderText="Customer" />
                            <asp:BoundField DataField="TotalMaterials" HeaderText="Total Materials" />
                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" Text="Edit" CommandName="EditRow" CommandArgument='<%# Eval("MRID") %>'
                                        Style="background:#e3f2fd;color:#1976d2;padding:4px 10px;border-radius:4px;font-weight:600;text-decoration:none;border:1px solid #90caf9;" />
                                    <asp:LinkButton ID="lnkReport" runat="server" Text="Report" CommandName="ViewReport" CommandArgument='<%# Eval("MRID") %>'
                                        Style="background:#e8f5e9;color:#2e7d32;padding:4px 10px;border-radius:4px;font-weight:600;text-decoration:none;border:1px solid #a5d6a7;" />
                                    <asp:LinkButton ID="lnkDelete" runat="server" Text="Delete" CommandName="DeleteRow" CommandArgument='<%# Eval("MRID") %>'
                                        Style="background:#ffebee;color:#c62828;padding:4px 10px;border-radius:4px;font-weight:600;text-decoration:none;border:1px solid #ef9a9a;"
                                        OnClientClick="return confirm('Are you sure you want to delete this record?');" />
                                </ItemTemplate>
                                <ItemStyle Width="220px" />
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- ================= 2. FORM PANEL ================= -->
                <div id="pnlForm" runat="server" class="panel">
                    <div class="section-label">Select Work Order (already linked to a Quotation)</div>
                    <div class="form-grid">
                        <div class="field span-2">
                            <label for="<%= ddlWorkOrder.ClientID %>">Work Order Receive No</label>
                            <asp:DropDownList ID="ddlWorkOrder" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlWorkOrder_SelectedIndexChanged">
                                <asp:ListItem Text="--Select Work Order--" Value="0" />
                            </asp:DropDownList>
                        </div>
                        <div class="field">
                            <label for="<%= txtMRNo.ClientID %>">MR No</label>
                            <asp:TextBox ID="txtMRNo" runat="server" CssClass="form-control" ReadOnly="true" placeholder="Auto Generate" />
                        </div>
                        <div class="field">
                            <label for="<%= txtMRDate.ClientID %>">MR Date</label>
                            <asp:TextBox ID="txtMRDate" runat="server" CssClass="form-control" TextMode="Date" />
                        </div>
                    </div>

                    <div class="info-box">
                        <div><span class="k">Work Order No</span><span class="v"><asp:Label ID="lblWONo" runat="server" Text="-" /></span></div>
                        <div><span class="k">Quotation No</span><span class="v"><asp:Label ID="lblQuotationCode" runat="server" Text="-" /></span></div>
                        <div><span class="k">Customer</span><span class="v"><asp:Label ID="lblCustomer" runat="server" Text="-" /></span></div>
                        <div><span class="k">Delivery Date</span><span class="v"><asp:Label ID="lblDeliveryDate" runat="server" Text="-" /></span></div>
                    </div>

                    <div class="list-toolbar">
                        <div class="section-label" style="margin-bottom:0;border:none;">Aggregated Raw Material Requirement</div>
                        <asp:Button ID="btnCalculate" runat="server" Text="Calculate Material Requirement" CssClass="btn btn-load" OnClick="btnCalculate_Click"/>
                    </div>

                    <asp:GridView ID="gvMaterialRequirement" runat="server" AutoGenerateColumns="False" CssClass="grid" DataKeyNames="RawMaterialID"
                        EmptyDataText="No data yet. Select a Work Order and click Calculate.">
                        <Columns>
                            <asp:TemplateField HeaderText="SL">
                                <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                <ItemStyle Width="40px" />
                            </asp:TemplateField>
                            <asp:BoundField DataField="RawMaterialID" HeaderText="Material ID" ItemStyle-Width="90px" />
                            <asp:BoundField DataField="RawMaterialName" HeaderText="Raw Material Name" />
                            <asp:BoundField DataField="Unit" HeaderText="Unit" ItemStyle-Width="80px" />
                            <asp:BoundField DataField="RequiredQty" HeaderText="Required Qty" DataFormatString="{0:0.###}" ItemStyle-Width="120px" />
                            <asp:TemplateField HeaderText="Remarks">
                                <ItemTemplate>
                                    <asp:TextBox ID="txtRemarks" runat="server" CssClass="form-control" Text='<%# Eval("Remarks") %>' />
                                </ItemTemplate>
                                <ItemStyle Width="180px" />
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>

                    <div class="clearfix" style="margin-top:15px;">
                        <div class="totals-section">
                            <span>Total Distinct Materials</span>
                            <asp:Label ID="lblTotalMaterials" runat="server" Text="0" />
                        </div>
                    </div>

                    <div class="action-bar">
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-save" OnClick="btnSave_Click" />
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-cancel" CausesValidation="false" OnClick="btnCancel_Click" />
                        <asp:Button ID="btnBackToList" runat="server" Text="Back To List" CssClass="btn btn-back" CausesValidation="false" OnClick="btnBackToList_Click" />
                    </div>
                </div>

                <!-- ================= 3. REPORT / PRINT PANEL ================= -->
                <div id="pnlReport" runat="server" class="panel">
                    <div class="report-header" style="text-align:center; margin-bottom:18px;">
                        <h3 style="margin:0 0 4px; color:var(--brand-900);">Material Requirement Report</h3>
                    </div>
                    <div class="report-meta" style="display:grid; grid-template-columns:repeat(3,1fr); gap:6px 20px; margin-bottom:16px; font-size:12.5px;">
                        <div><span class="k" style="font-weight:600; color:var(--muted);">MR No: </span><asp:Label ID="lblRptMRNo" runat="server" /></div>
                        <div><span class="k" style="font-weight:600; color:var(--muted);">MR Date: </span><asp:Label ID="lblRptMRDate" runat="server" /></div>
                        <div><span class="k" style="font-weight:600; color:var(--muted);">Work Order No: </span><asp:Label ID="lblRptWONo" runat="server" /></div>
                        <div><span class="k" style="font-weight:600; color:var(--muted);">Quotation No: </span><asp:Label ID="lblRptQuotationCode" runat="server" /></div>
                        <div><span class="k" style="font-weight:600; color:var(--muted);">Customer: </span><asp:Label ID="lblRptCustomer" runat="server" /></div>
                        <div><span class="k" style="font-weight:600; color:var(--muted);">Delivery Date: </span><asp:Label ID="lblRptDeliveryDate" runat="server" /></div>
                    </div>

                    <asp:GridView ID="gvReportMaterials" runat="server" AutoGenerateColumns="False" CssClass="grid">
                        <Columns>
                            <asp:TemplateField HeaderText="SL">
                                <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                <ItemStyle Width="40px" />
                            </asp:TemplateField>
                            <asp:BoundField DataField="RawMaterialID" HeaderText="Material ID" />
                            <asp:BoundField DataField="RawMaterialName" HeaderText="Raw Material Name" />
                            <asp:BoundField DataField="Unit" HeaderText="Unit" />
                            <asp:BoundField DataField="RequiredQty" HeaderText="Required Qty" DataFormatString="{0:0.###}" />
                            <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                        </Columns>
                    </asp:GridView>

                    <div class="action-bar no-print">
                        <button type="button" class="btn btn-print" onclick="printReport()">Print</button>
                        <asp:Button ID="btnReportBack" runat="server" Text="Back To List" CssClass="btn btn-back" CausesValidation="false" />
                    </div>
                </div>

            </div>
        </div>
    </form>
</body>
</html>