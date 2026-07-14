<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ColorInformation.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration.ColorInformation" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Color Master</title>
    <style>
        * { font-family: Arial, sans-serif; font-size: 13px; box-sizing: border-box; }
        body { background: #f0f0f0; padding: 15px; }

        /* Page Header */
        .page-header { background: #1a9ab1; color: #fff; padding: 8px 12px; font-size: 15px; font-weight: bold; margin-bottom: 10px; border-radius: 3px; }

        /* Card / Section */
        .card { background: #fff; border: 1px solid #ddd; border-radius: 3px; padding: 15px; margin-bottom: 15px; }
        .section-title { color: #1a9ab1; font-weight: bold; text-decoration: underline; margin-bottom: 12px; font-size: 13px; }

        /* Form */
        .form-row { display: flex; align-items: center; margin-bottom: 10px; }
        .form-label { width: 120px; text-align: right; padding-right: 10px; font-weight: bold; }
        .form-control { width: 320px; padding: 4px 6px; border: 1px solid #aaa; border-radius: 2px; height: 26px; }
        .form-control[disabled], .form-control.readonly { background: #e8e8e8; }
        .btn-add { background: #1a9ab1; color: #fff; border: none; padding: 3px 8px; cursor: pointer; margin-left: 5px; font-size: 16px; font-weight: bold; border-radius: 2px; }
        .checkbox-row { margin-left: 130px; margin-bottom: 10px; }
        .btn-save  { background: #5cb85c; color: #fff; border: none; padding: 5px 14px; cursor: pointer; border-radius: 3px; margin-right: 5px; }
        .btn-reset { background: #d9534f; color: #fff; border: none; padding: 5px 14px; cursor: pointer; border-radius: 3px; }
        .msg-label { margin-left: 130px; font-weight: bold; }

        /* Grid */
        .grid-title { color: #1a9ab1; font-weight: bold; text-decoration: underline; margin-bottom: 8px; }
        table.grid { width: 100%; border-collapse: collapse; }
        table.grid th { background: #1a9ab1; color: #fff; padding: 6px 8px; text-align: left; }
        table.grid td { padding: 5px 8px; border-bottom: 1px solid #eee; }
        table.grid tr:nth-child(even) td { background: #f7f7f7; }
        .btn-edit { background: #5cb85c; color: #fff; border: none; padding: 2px 8px; cursor: pointer; border-radius: 2px; margin-right: 3px; }
        .btn-del  { background: #d9534f; color: #fff; border: none; padding: 2px 6px; cursor: pointer; border-radius: 2px; }

        /* Pagination */
        .pager { margin-top: 8px; font-size: 12px; color: #555; display: flex; align-items: center; gap: 4px; }
        .pager a, .pager span { padding: 2px 7px; border: 1px solid #ccc; border-radius: 2px; text-decoration: none; color: #333; }
        .pager .current { background: #1a9ab1; color: #fff; border-color: #1a9ab1; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server" />

    <!-- Page Header -->
    <div class="page-header">Color Master</div>

    <!-- Master Data Form -->
    <asp:UpdatePanel ID="upForm" runat="server">
    <ContentTemplate>
    <div class="card">
        <div class="section-title"><a href="#">Master Data</a></div>

        <!-- Color Code -->
        <div class="form-row">
            <span class="form-label">Color Code</span>
            <asp:TextBox ID="txtColorCode" runat="server" CssClass="form-control readonly" ReadOnly="true" placeholder="[Auto Generated]" />
        </div>

        <!-- Color Type -->
        <div class="form-row">
            <span class="form-label">Color Type</span>
            <asp:DropDownList ID="ddlColorType" runat="server" CssClass="form-control">
                <asp:ListItem Value="">--Select Type--</asp:ListItem>
            </asp:DropDownList>
            <asp:Button ID="btnAddType" runat="server" Text="+" CssClass="btn-add" OnClick="btnAddType_Click" ToolTip="Add New Color Type" />
        </div>

        <!-- Color Name -->
        <div class="form-row">
            <span class="form-label">Color Name</span>
            <asp:TextBox ID="txtColorName" runat="server" CssClass="form-control" placeholder="Color Name" MaxLength="100" />
        </div>

         <!-- pENTON Name -->
        <div class="form-row">
            <span class="form-label">Panton Name</span>
            <asp:TextBox ID="txtPantenName" runat="server" CssClass="form-control" placeholder="Color Name" MaxLength="100" />
        </div>

        <!-- Is Active -->
        <div class="checkbox-row">
            <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" Text="Is Active?" />
        </div>

        <!-- Buttons -->
        <div style="margin-left:120px; margin-bottom:8px;">
            <asp:Button ID="btnSave"  runat="server" Text="Save"  CssClass="btn-save"  OnClick="btnSave_Click" />
            <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn-reset" OnClick="btnReset_Click" />
        </div>

        <!-- Message -->
        <div class="msg-label">
            <asp:Label ID="lblMessage" runat="server" />
        </div>

        <asp:HiddenField ID="hfColorID" runat="server" Value="0" />
    </div>
    </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Color List Grid -->
    <asp:UpdatePanel ID="upGrid" runat="server">
    <ContentTemplate>
    <div class="card">
        <div class="grid-title"><a href="#">Color List</a></div>

        <asp:GridView ID="gvColorList" runat="server" CssClass="grid" AutoGenerateColumns="false"
            DataKeyNames="ColorID" OnRowCommand="gvColorList_RowCommand">
            <Columns>
                <asp:BoundField DataField="ColorCode" HeaderText="Color Code" />
                <asp:BoundField DataField="ColorType" HeaderText="Color Type" />
                <asp:BoundField DataField="ColorName" HeaderText="Color Name" />
                <asp:BoundField DataField="IsActive"  HeaderText="Is Active?" />
                <asp:TemplateField HeaderText="Action">
                    <ItemTemplate>
                        <asp:Button runat="server" Text="Edit" CssClass="btn-edit"
                            CommandName="EditRow" CommandArgument='<%# Eval("ColorID") %>' />
                        <asp:Button runat="server" Text="X" CssClass="btn-del"
                            CommandName="DeleteRow" CommandArgument='<%# Eval("ColorID") %>'
                            OnClientClick="return confirm('Are you sure you want to delete this record?');" />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate><p style="color:#888;">No records found.</p></EmptyDataTemplate>
        </asp:GridView>

        <!-- Pager -->
        <div class="pager" style="margin-top:10px; justify-content:space-between;">
            <div>
                <asp:LinkButton ID="lbFirst" runat="server" OnClick="lbFirst_Click">1at page</asp:LinkButton>
                <asp:LinkButton ID="lbPrev"  runat="server" OnClick="lbPrev_Click">‹</asp:LinkButton>
                <asp:Label ID="lblCurrentPage" runat="server" CssClass="current" />
                <asp:LinkButton ID="lbNext" runat="server" OnClick="lbNext_Click">›</asp:LinkButton>
                <asp:LinkButton ID="lbLast" runat="server" OnClick="lbLast_Click">»</asp:LinkButton>
                &nbsp;
                <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_Changed">
                    <asp:ListItem Value="10">10</asp:ListItem>
                    <asp:ListItem Value="25">25</asp:ListItem>
                    <asp:ListItem Value="50">50</asp:ListItem>
                </asp:DropDownList>
                items per page
            </div>
            <asp:Label ID="lblRecordInfo" runat="server" />
        </div>
    </div>
    </ContentTemplate>
    </asp:UpdatePanel>

</form>
</body>
</html>
