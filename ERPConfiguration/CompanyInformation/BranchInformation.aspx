<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BranchInformation.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.CompanyInformation.BranchInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Branch Information - NexaERP</title>

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
            <h4 class="mb-0">Branch Information</h4>
            <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
        </div>

        <div class="card-body">
            <asp:HiddenField ID="hfUserId" runat="server" />

            <div class="row g-3">
                <div class="col-md-6">
                    <label>Branch ID</label>
                    <asp:TextBox ID="txtBranchID" runat="server" CssClass="form-control" ReadOnly="True" />
                </div>

                <div class="col-md-6">
                    <label>Branch Name</label>
                    <asp:DropDownList ID="ddlGroup" runat="server" CssClass="form-control"></asp:DropDownList>
                </div>

                <div class="col-md-6">
                    <label>Branch Name</label>
                    <asp:TextBox ID="txtBranch" runat="server" CssClass="form-control" />
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
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary"/>
            </div>
        </div>
    </div>

    <div class="card shadow mt-4">
        <div class="card-body">
            <asp:GridView ID="gvBranch" runat="server" CssClass="table table-bordered table-hover"
                AutoGenerateColumns="False" DataKeyNames="Branch_ID">

                <Columns>
                    <asp:CommandField ShowSelectButton="True" SelectText="Select" />

                    <asp:BoundField DataField="Branch_ID" HeaderText="ID" />
                    <asp:BoundField DataField="Branch_Name" HeaderText="Branch Name" />
                    <asp:BoundField DataField="Prifix" HeaderText="Prifix" />
                    <asp:BoundField DataField="Address" HeaderText="Address" />
                    <asp:CheckBoxField DataField="is_active" HeaderText="Status" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

</div>
</form>
</body>
</html>