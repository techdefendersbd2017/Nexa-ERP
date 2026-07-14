<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MenuEntry.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.MenuEntry" %>


<!DOCTYPE html>
<html>
<head runat="server">
    <title>Menu Management - NexaERP</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        body { background: #f4f6f9; }
        .card { border-radius: 12px; }
        .form-control, .form-select { border-radius: 8px; }
        .btn { border-radius: 8px; }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="container mt-4">

    <div class="card shadow">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">Menu Management</h4>
            <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
        </div>

        <div class="card-body">
            <asp:HiddenField ID="hfUserId" runat="server" />

            <div class="row g-3">
                <div class="col-md-6">
                    <label>Menu ID</label>
                    <asp:TextBox ID="txtMenuID" runat="server" CssClass="form-control" Text="0" ReadOnly="True" />
                </div>

                <div class="col-md-6">
                    <label>Module Name</label>
                    <asp:DropDownList ID="ddlmodule" AutoPostBack="true" runat="server" CssClass="form-control" OnSelectedIndexChanged="ddlmodule_SelectedIndexChanged" ></asp:DropDownList>
                </div>
                
                <div class="col-md-6">
                    <label>Menu Name</label>
                    <asp:TextBox ID="txtmenu" runat="server" CssClass="form-control" />
                </div>

                <div class="col-md-6">
                    <label>Icon CSS Name</label>
                    <asp:TextBox ID="txtCss" runat="server" CssClass="form-control" />
                </div>

                <div class="col-md-6">
                    <label>Menu Description</label>
                    <asp:TextBox ID="txtMenudiscription" runat="server" CssClass="form-control" TextMode="MultiLine" />
                </div>

                <div class="col-md-6">
                    <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                    <label class="form-check-label ms-2" for="chkIsActive">Is Active</label>
                </div>
            </div>

            <div class="mt-3 text-end">
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success" OnClick="btnSave_Click" />
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary" OnClick="btnClear_Click" />
            </div>
        </div>
    </div>

    <div class="card shadow mt-4">
        <div class="card-body">
            <asp:GridView ID="gvModule" runat="server" CssClass="table table-bordered table-hover"
                AutoGenerateColumns="False" DataKeyNames="Menu_ID" OnSelectedIndexChanged="gvModule_SelectedIndexChanged">

                <Columns>
                    <asp:CommandField ShowSelectButton="True" SelectText="Select" />

                    <asp:BoundField DataField="Menu_ID" HeaderText="ID" />
                    <asp:BoundField DataField="Menu_Name" HeaderText="Menu Name" />
                    <asp:BoundField DataField="Menu_description" HeaderText="Description" />
                    <asp:CheckBoxField DataField="is_active" HeaderText="Status" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

</div>
</form>
</body>
</html>
