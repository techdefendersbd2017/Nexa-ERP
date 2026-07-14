<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductionBuilding.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.CompanyInformation.ProductionBuilding" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Building Information - NexaERP</title>

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
            <h4 class="mb-0">Building Information</h4>
            <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>
        </div>

        <div class="card-body">
            <asp:HiddenField ID="hfUserId" runat="server" />

            <div class="row g-3">
                <div class="col-md-6">
                    <label>Building ID</label>
                    <asp:TextBox ID="txtBuildingID" runat="server" CssClass="form-control" ReadOnly="True" />
                </div>

                <div class="col-md-6">
                    <label>Branch Name</label>
                    <asp:DropDownList ID="ddlBranch" runat="server" CssClass="form-control"></asp:DropDownList>
                </div>

                <div class="col-md-6">
                    <label>Building Name</label>
                    <asp:TextBox ID="txtBuilding" runat="server" CssClass="form-control" />
                </div>

                <div class="col-md-6">
                    <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                    <label class="form-check-label ms-2" for="chkIsActive">Is Active</label>
                </div>
            </div>

            <div class="mt-3 d-flex align-items-center justify-content-end">
                <!-- Action Dropdown -->
                <label class="me-2 mb-0">Action</label>
                <asp:DropDownList ID="ddlAction" runat="server" CssClass="form-control me-3" style="width:120px;">
                    <asp:ListItem Text="Insert" Value="Save"></asp:ListItem>
                    <asp:ListItem Text="Update" Value="UPDATE"></asp:ListItem>
                    <asp:ListItem Text="Delete" Value="DELETE"></asp:ListItem>
                </asp:DropDownList>

                <!-- Save Button -->
                <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success me-2" OnClick="btnSave_Click"/>

                <!-- Clear Button -->
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary"/>
            </div>

        </div>
    </div>

    <div class="card shadow mt-4">
        <div class="card-body">
            <asp:GridView ID="gvBuilding" runat="server" CssClass="table table-bordered table-hover"
                AutoGenerateColumns="False" DataKeyNames="Building_ID" OnSelectedIndexChanged="gvBuilding_SelectedIndexChanged">

                <Columns>
                    <asp:CommandField ShowSelectButton="True" SelectText="Select" />

                    <asp:BoundField DataField="Building_ID" HeaderText="ID" />
                    <asp:BoundField DataField="Building_Name" HeaderText="Building Name" />
                    <asp:CheckBoxField DataField="is_active" HeaderText="Status" />
                </Columns>
            </asp:GridView>
        </div>
    </div>

</div>
</form>
</body>
</html>