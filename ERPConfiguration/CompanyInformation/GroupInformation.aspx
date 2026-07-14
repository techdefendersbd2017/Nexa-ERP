<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GroupInformation.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.CompanyInformation.GroupInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Group Information - NexaERP</title>

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
            <h4 class="mb-0">Group Information</h4>
            <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
        </div>

        <div class="card-body">
            <asp:HiddenField ID="hfUserId" runat="server" />

            <div class="row g-3">
                <div class="col-md-6">
                    <label>Group ID</label>
                    <asp:TextBox ID="txtGroupID" runat="server" CssClass="form-control" Text="0" ReadOnly="True" />
                </div>

                <div class="col-md-6">
                    <label>Group Name</label>
                    <asp:TextBox ID="txtGroupName" runat="server" CssClass="form-control" />
                </div>
                
                <div class="col-md-6">
                    <label>Prefix</label>
                    <asp:TextBox ID="txtPrefix" runat="server" CssClass="form-control" />
                </div>

                <div class="col-md-6">
                    <label>E-Mail</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" />
                </div>

                <div class="col-md-6">
                    <label>Phone No</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                </div>

                <div class="col-md-6">
                    <label>Web</label>
                    <asp:TextBox ID="txtWeb" runat="server" CssClass="form-control"/>
                </div>

                <div class="col-md-6">
                    <label>Address</label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine"/>
                </div>

                <div class="col-md-6">
                    <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                    <label class="form-check-label ms-2" for="chkIsActive">Is Active</label>
                </div>
            </div>

            <div class="mt-3 text-end">
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success" OnClick="btnSave_Click"/>
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary" OnClick="btnClear_Click"/>
            </div>
        </div>
    </div>

    <div class="card shadow mt-4">
        <div class="card-body">
            <asp:GridView ID="gvGroup" runat="server" CssClass="table table-bordered table-hover"
                AutoGenerateColumns="False" DataKeyNames="Group_ID" OnSelectedIndexChanged="gvGroup_SelectedIndexChanged">

                <Columns>
                    <asp:CommandField ShowSelectButton="True" SelectText="Select" />

                    <asp:BoundField DataField="Group_ID" HeaderText="ID" />
                    <asp:BoundField DataField="Group_Name" HeaderText="Group Name" />
                    <asp:BoundField DataField="Prifix" HeaderText="Prefix" />
                    <asp:BoundField DataField="Address" HeaderText="Address" />
                    <asp:CheckBoxField DataField="Is_Active" HeaderText="Status" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

</div>
</form>
</body>
</html>