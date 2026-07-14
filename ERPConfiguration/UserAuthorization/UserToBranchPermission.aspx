<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserToBranchPermission.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.UserAuthorization.UserToBranchPermission" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>User To Branch Permission- NexaERP</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        body { background: #f4f6f9; }
        .card { border-radius: 12px; }
        .form-control, .form-select { border-radius: 8px; }
        .btn { border-radius: 8px; }
    </style>


    <script type="text/javascript">
        function toggleColumn(headerChk, itemChkId) {
            var grid = document.getElementById('<%= gvModule.ClientID %>');
            var inputs = grid.getElementsByTagName("input");

            for (var i = 0; i < inputs.length; i++) {
                if (inputs[i].id.indexOf(itemChkId) !== -1) {
                    inputs[i].checked = headerChk.checked;
                }
            }
        }
    </script>
</head>
<body>
<form id="form1" runat="server">
<div class="container mt-4">

    <div class="card shadow">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">User To Branch Permission</h4>
            <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
        </div>

        <div class="card-body">
            <asp:HiddenField ID="hfUserId" runat="server" />

            <div class="row g-3">
                <div class="col-md-6">
                    <label>Branch Name</label>
                    <asp:DropDownList ID="ddlbranch" AutoPostBack="true" runat="server" CssClass="form-control" OnSelectedIndexChanged="ddlbranch_SelectedIndexChanged"></asp:DropDownList>
                </div>
            </div>

            <div class="mt-3 text-end">
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success" OnClick="btnSave_Click"/>
            </div>
        </div>
    </div>

    <div class="card shadow mt-4">
        <div class="card-body">
            <asp:GridView ID="gvModule" runat="server"
                CssClass="table table-bordered table-hover"
                AutoGenerateColumns="False"
                DataKeyNames="user_id"
                OnRowDataBound="gvModule_RowDataBound">

                <Columns>
                    <asp:BoundField DataField="user_id" HeaderText="User ID" />
                    <asp:BoundField DataField="full_name" HeaderText="Name" />
                    <asp:BoundField DataField="email" HeaderText="Email" />

                    <asp:TemplateField HeaderText="Action">
                        <HeaderTemplate>
                            <asp:CheckBox ID="chkAllAction"
                                runat="server"
                                Text=" Action"
                                onclick="toggleColumn(this, 'chkAction')" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="chkAction" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>


        </div>
    </div>

</div>
</form>
</body>
</html>

