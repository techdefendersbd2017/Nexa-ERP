<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BookingInformation.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports.BookingInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Budget & Booking Information</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f4f6f9; color: #333; }
        .card { background: #fff; padding: 20px; border-radius: 6px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); margin-bottom: 20px; }
        h2 { margin-top: 0; color: #007bff; border-bottom: 2px solid #007bff; padding-bottom: 8px; }
        .form-row { display: flex; flex-wrap: wrap; gap: 15px; margin-bottom: 12px; }
        .form-group { flex: 1; min-width: 220px; display: flex; flex-direction: column; }
        .form-group label { font-weight: bold; margin-bottom: 5px; font-size: 13px; }
        .form-control { padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px; }
        .btn { padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; font-size: 14px; }
        .btn-primary { background-color: #007bff; color: #white; }
        .btn-success { background-color: #28a745; color: white; }
        .btn-danger { background-color: #dc3545; color: white; }
        .btn-secondary { background-color: #6c757d; color: white; }
        .btn:hover { opacity: 0.9; }
        .tab-menu { display: flex; border-bottom: 2px solid #ddd; margin-bottom: 15px; }
        .tab-btn { padding: 10px 20px; background: none; border: none; cursor: pointer; font-weight: bold; font-size: 14px; color: #555; }
        .tab-btn.active { border-bottom: 3px solid #007bff; color: #007bff; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; font-size: 13px; }
        th { background-color: #007bff; color: white; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .text-right { text-align: right; }
    </style>

    <script type="text/javascript">
        function openTab(evt, tabName) {
            var i, tabcontent, tablinks;
            tabcontent = document.getElementsByClassName("tab-content");
            for (i = 0; i < tabcontent.length; i++) {
                tabcontent[i].style.display = "none";
            }
            tablinks = document.getElementsByClassName("tab-btn");
            for (i = 0; i < tablinks.length; i++) {
                tablinks[i].className = tablinks[i].className.replace(" active", "");
            }
            document.getElementById(tabName).style.display = "block";
            evt.currentTarget.className += " active";
            document.getElementById('<%= hdnActiveTab.ClientID %>').value = tabName;
        }

        function switchPanel(panelId) {
            document.getElementById('pnlList').style.display = (panelId === 'pnlList') ? 'block' : 'none';
            document.getElementById('pnlForm').style.display = (panelId === 'pnlForm') ? 'block' : 'none';
            document.getElementById('<%= hdnActivePanel.ClientID %>').value = panelId;
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        
        <!-- Hidden fields for maintaining state -->
        <asp:HiddenField ID="hdnActivePanel" runat="server" Value="pnlList" />
        <asp:HiddenField ID="hdnActiveTab" runat="server" Value="tabMasterInfo" />

        <!-- ================= LIST PANEL ================= -->
        <asp:Panel ID="pnlList" runat="server" CssClass="card">
            <h2>Booking Information List</h2>
            
            <div class="form-row">
                <div class="form-group">
                    <label>From Date</label>
                    <asp:TextBox ID="txtFromDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Till Date</label>
                    <asp:TextBox ID="txtTillDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label>Customer</label>
                    <asp:DropDownList ID="ddlSearchCustomer" runat="server" CssClass="form-control"></asp:DropDownList>
                </div>
                <div class="form-group" style="justify-content: flex-end;">
                    <asp:Button ID="btnSearchFilter" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnAddNew" runat="server" Text="Add New Booking" CssClass="btn btn-success" OnClientClick="switchPanel('pnlForm'); return false;" style="margin-left: 5px;" />
                </div>
            </div>

            <asp:GridView ID="gvBookingList" runat="server" AutoGenerateColumns="False" OnRowCommand="gvBookingList_RowCommand">
                <Columns>
                    <asp:BoundField DataField="BookingID" HeaderText="ID" />
                    <asp:BoundField DataField="BookingCode" HeaderText="Booking Code" />
                    <asp:BoundField DataField="BookingDate" HeaderText="Booking Date" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="DeliveryDate" HeaderText="Delivery Date" DataFormatString="{0:yyyy-MM-dd}" />
                    <asp:BoundField DataField="GrandTotal" HeaderText="Grand Total" DataFormatString="{0:N2}" />
                    <asp:TemplateField HeaderText="Action">
                        <ItemTemplate>
                            <asp:Button ID="btnEdit" runat="server" Text="Edit" CommandName="EditRow" CommandArgument='<%# Eval("BookingCode") %>' CssClass="btn btn-primary" OnClientClick="switchPanel('pnlForm');" />
                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CommandName="DeleteRow" CommandArgument='<%# Eval("BookingCode") %>' CssClass="btn btn-danger" OnClientClick="return confirm('Are you sure to delete?');" />
                            <asp:Button ID="btnPrint" runat="server" Text="Report" CommandName="ReportView" CommandArgument='<%# Eval("BookingCode") %>' CssClass="btn btn-secondary" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </asp:Panel>

        <!-- ================= FORM / ENTRY PANEL ================= -->
        <asp:Panel ID="pnlForm" runat="server" CssClass="card" style="display:none;">
            <h2>Budget & Booking Entry Form</h2>

            <!-- Tab Navigation -->
            <div class="tab-menu">
                <button type="button" class="tab-btn active" onclick="openTab(event, 'tabMasterInfo')">Master Information</button>
                <button type="button" class="tab-btn" onclick="openTab(event, 'tabOrderInfo')">Budget & Items Details</button>
            </div>

            <!-- Tab 1: Master Info -->
            <div id="tabMasterInfo" class="tab-content active">
                <div class="form-row">
                    <div class="form-group">
                        <label>Branch <span style="color:red;">*</span></label>
                        <asp:DropDownList ID="ddlBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label>Auto No</label>
                        <asp:TextBox ID="txtAutoNo" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Booking Code <span style="color:red;">*</span></label>
                        <asp:TextBox ID="txtBookingCode" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Booking Date <span style="color:red;">*</span></label>
                        <asp:TextBox ID="txtBookingDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Booking Name</label>
                        <asp:TextBox ID="txtBookingName" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Customer <span style="color:red;">*</span></label>
                        <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="form-control"></asp:DropDownList>
                    </div>
                </div>
            </div>

            <!-- Tab 2: Order & Budget Info -->
            <div id="tabOrderInfo" class="tab-content">
                <div class="form-row" style="align-items: flex-end;">
                    <div class="form-group">
                        <label>Quotation Ref / Filter</label>
                        <asp:TextBox ID="txtQuotationRef" runat="server" CssClass="form-control" placeholder="Enter Quotation No"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <asp:Button ID="btnLoadItems" runat="server" Text="Load Quotation Items" CssClass="btn btn-primary" OnClick="btnLoadItems_Click" />
                    </div>
                </div>

                <!-- Item Details Grid -->
                <asp:GridView ID="gvBookingItems" runat="server" AutoGenerateColumns="False">
                    <Columns>
                        <asp:TemplateField HeaderText="Select">
                            <ItemTemplate>
                                <asp:CheckBox ID="chkIncludeItem" runat="server" AutoPostBack="true" OnCheckedChanged="chkIncludeItem_CheckedChanged" />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="ItemID" HeaderText="Item ID" />
                        <asp:BoundField DataField="ItemName" HeaderText="Item Description" />
                        <asp:TemplateField HeaderText="Rate">
                            <ItemTemplate>
                                <asp:Label ID="lblRate" runat="server" Text='<%# Eval("Rate") %>'></asp:Label>
                                <asp:HiddenField ID="hdnRate" runat="server" Value='<%# Eval("Rate") %>' />
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Booking Qty">
                            <ItemTemplate>
                                <asp:TextBox ID="txtBookingQty" runat="server" CssClass="form-control" Text="0" AutoPostBack="true" OnTextChanged="txtBookingQty_TextChanged" Width="80px"></asp:TextBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total Amount">
                            <ItemTemplate>
                                <asp:Label ID="lblAmount" runat="server" Text="0.00"></asp:Label>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>

                <div style="margin-top: 15px; text-align: right;">
                    <label style="font-weight: bold; font-size: 15px; margin-right: 10px;">Grand Total:</label>
                    <asp:TextBox ID="txtGTotal" runat="server" CssClass="form-control" ReadOnly="true" style="width: 150px; display: inline-block; text-align: right; font-weight: bold;" Text="0.00"></asp:TextBox>
                </div>
            </div>

            <!-- Form Footer / Actions -->
            <div style="margin-top: 20px; border-top: 1px solid #ddd; padding-top: 15px;">
                <asp:Button ID="btnSave" runat="server" Text="Save Booking" CssClass="btn btn-success" OnClick="btnSave_Click" />
                <asp:Button ID="btnCancel" runat="server" Text="Back to List" CssClass="btn btn-secondary" OnClientClick="switchPanel('pnlList'); return false;" style="margin-left: 5px;" />
            </div>
        </asp:Panel>
    </form>
</body>
</html>