<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RoleBasedPermission.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.RoleBasedPermission" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Role-based Permission- NexaERP</title>

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
            <h4 class="mb-0">Role-based Permission</h4>
            <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
        </div>

        <div class="card-body">
            <asp:HiddenField ID="hfUserId" runat="server" />

            <div class="row g-3">
                <div class="col-md-6">
                    <label>Role Name</label>
                    <asp:DropDownList ID="ddlRole" AutoPostBack="true" runat="server" CssClass="form-control" OnSelectedIndexChanged="ddlRole_SelectedIndexChanged"></asp:DropDownList>
                </div>

                <div class="col-md-6">
                    <label>Module Name</label>
                    <asp:DropDownList ID="ddlmodule" AutoPostBack="true" runat="server" CssClass="form-control" OnSelectedIndexChanged="ddlmodule_SelectedIndexChanged"></asp:DropDownList>
                </div>

                <div class="col-md-6">
                    <label>Menu Name</label>
                    <asp:DropDownList ID="ddlMenu" AutoPostBack="true" runat="server" CssClass="form-control" OnSelectedIndexChanged="ddlMenu_SelectedIndexChanged"></asp:DropDownList>
                </div>
            </div>

            <div class="mt-3 text-end">
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success" OnClick="btnSave_Click"/>
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary"/>
            </div>
        </div>
    </div>

    <div class="card shadow mt-4">
        <div class="card-body">
            <asp:GridView ID="gvModule" runat="server" CssClass="table table-bordered table-hover"
                AutoGenerateColumns="False" DataKeyNames="Form_ID" OnRowDataBound="gvModule_RowDataBound1">
                <Columns>


                    <asp:BoundField DataField="Form_ID" HeaderText="ID" />
                    <asp:BoundField DataField="Form_Name" HeaderText="Menu Name" />

                    
                    <asp:TemplateField HeaderText="View">
                        <HeaderTemplate>
                            <asp:CheckBox ID="chkViewAll"  runat="server" Text=" View" OnClick="toggleColumn(this, 'chkViewAll')" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="chkViewAll" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    
                    <asp:TemplateField HeaderText="Add/Save">
                        <HeaderTemplate>
                            <asp:CheckBox ID="chkAddAll" runat="server" Text=" Add" OnClick="toggleColumn(this, 'chkAdd')" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="chkAdd" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>

                    
                    <asp:TemplateField HeaderText="Edit/Update">
                        <HeaderTemplate>
                            <asp:CheckBox ID="chkEditAll" runat="server" Text=" Edit"  OnClick="toggleColumn(this, 'chkEdit')" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="chkEdit" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>

                   
                    <asp:TemplateField HeaderText="Delete">
                        <HeaderTemplate>
                            <asp:CheckBox ID="chkDeleteAll" runat="server" Text=" Delete"  OnClick="toggleColumn(this, 'chkDelete')" />
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:CheckBox ID="chkDelete" runat="server" />
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
