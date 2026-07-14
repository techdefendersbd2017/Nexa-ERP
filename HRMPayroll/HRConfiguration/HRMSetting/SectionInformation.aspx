<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SectionInformation.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting.SectionInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Section Information - NexaERP</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        body {
    background: #f4f6f9;
    margin: 0;
}

.main-container {
    padding: 15px;
    min-height: 100vh;
}

.card {
    border-radius: 12px;
}

.left-panel {
    max-height: calc(100vh - 180px);
    overflow-y: auto;
}

.right-panel {
    height: 100%;
}

.grid-wrapper {
    max-height: calc(100vh - 180px);
    overflow-y: auto;
    overflow-x: auto;
}

.grid-wrapper th {
    position: sticky;
    top: 0;
    background: #0d6efd !important;
    color: #fff !important;
    z-index: 10;
}

/* Mobile & Tablet */
@media (max-width: 991.98px) {

    .left-panel,
    .grid-wrapper {
        max-height: none;
        overflow: visible;
    }

    .card {
        height: auto !important;
        margin-bottom: 15px;
    }
}
    </style>
</head>
<body>

<form id="form1" runat="server">

<div class="container-fluid main-container">

    <div class="row">

        <!-- Left Side Form -->
        <div class="col-12 col-lg-6 mb-3">

            <div class="card shadow">

                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0">Section Information</h4>
                    <asp:Label ID="Label1" runat="server"></asp:Label>
                </div>

                <div class="card-body left-panel">

                    <asp:HiddenField ID="hfUserId" runat="server" />

                    <div class="row g-3">

                        <div class="col-md-6">
                            <label>Section ID</label>
                            <asp:TextBox ID="txtSectionID" runat="server"
                                CssClass="form-control"
                                ReadOnly="True" />
                        </div>

                        <div class="col-md-6">
                            <label>Section Name</label>
                            <asp:TextBox ID="txtSectionName" runat="server"
                                CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <label>Prefix (Code)</label>
                            <asp:TextBox ID="txtPrefix" runat="server"
                                CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <label>Section Name Local</label>
                            <asp:TextBox ID="txtSectionNameLocal" runat="server"
                                CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <label>Required Manpower</label>
                            <asp:TextBox ID="txtRequiredManpower" runat="server"
                                CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <label>Extra Required Manpower</label>
                            <asp:TextBox ID="txtExtraRequiredManpower" runat="server"
                                CssClass="form-control" />
                        </div>

                        <div class="col-md-6">
                            <div class="form-check mt-4">
                                <asp:CheckBox ID="chkIsActive" runat="server"
                                    CssClass="form-check-input" />
                                <label class="form-check-label ms-2">
                                    Is Active
                                </label>
                            </div>
                        </div>

                    </div>

                    <div class="mt-4 text-end">
                        <asp:Button ID="btnSave" runat="server"
                            Text="Save"
                            CssClass="btn btn-success"
                            OnClick="btnSave_Click" />

                        <asp:Button ID="btnClear" runat="server"
                            Text="Clear"
                            CssClass="btn btn-secondary"
                            OnClick="btnClear_Click" />
                    </div>

                </div>

            </div>

        </div>

        <!-- Right Side Grid -->
        <div class="col-12 col-lg-6 mb-3">

            <div class="card shadow right-panel">

                <div class="card-header bg-success text-white">
                    <h4 class="mb-0">Section List</h4>
                </div>

                <div class="grid-wrapper">

                    <asp:GridView ID="gvSection"
                        runat="server"
                        CssClass="table table-bordered table-hover"
                        AutoGenerateColumns="False"
                        Width="100%"
                        DataKeyNames="Section_Code"
                        OnSelectedIndexChanged="gvSection_SelectedIndexChanged">

                        <Columns>

                            <asp:CommandField ShowSelectButton="True"
                                SelectText="Select">
                                <ItemStyle Width="80px" />
                            </asp:CommandField>

                            <asp:BoundField DataField="Section_Code"
                                HeaderText="ID" />

                            <asp:BoundField DataField="Section_Name"
                                HeaderText="Section Name" />

                            <asp:BoundField DataField="SecPrefix"
                                HeaderText="Prefix" />

                            <asp:BoundField DataField="SectionRequiredManpower"
                                HeaderText="Required Manpower" />

                            <asp:BoundField DataField="SectionExtra_Required_Manpower"
                                HeaderText="Extra Required Manpower" />

                            <asp:CheckBoxField DataField="IsActive"
                                HeaderText="Status" />

                        </Columns>

                    </asp:GridView>

                </div>

            </div>

        </div>

    </div>

</div>

</form>

</body>
</html>