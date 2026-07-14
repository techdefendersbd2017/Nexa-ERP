<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BuyerInformation.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration.BuyerInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Buyer Information - NexaERP</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
        body { 
            background: #f4f6f9; 
            font-size: 13px;
        }

        .card { 
            border-radius: 10px; 
        }

        .card-header {
            padding: 8px 15px;
        }

        .card-header h4 {
            font-size: 16px;
            margin: 0;
        }

        label {
            font-size: 12px;
            font-weight: 500;
            margin-bottom: 2px;
        }

        .form-control, .form-select {
            border-radius: 6px;
            height: 30px;
            font-size: 12px;
            padding: 2px 6px;
        }

        .form-check-input {
            transform: scale(0.9);
            margin-top: 2px;
        }

        .btn {
            border-radius: 6px;
            font-size: 12px;
            padding: 4px 12px;
        }

        .table {
            font-size: 12px;
        }

        .table th, .table td {
            padding: 4px 6px;
        }

        .row.g-3 > * {
            padding-top: 6px;
            padding-bottom: 6px;
        }

        .card-body {
            padding: 12px 15px;
        }
    </style>
</head>

    <body>
        <form id="form1" runat="server">
            <div class="container-fluid py-2 px-3">

                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">Buyer Information</h4>
                        <asp:Label ID="Label1" runat="server" Text=""></asp:Label>
                    </div>

                    <div class="card-body">

                        <!-- Entry Panel -->
                        <asp:Panel ID="PanelEntry" runat="server">
                            <div class="row g-3">

                                <div class="col-md-2">
                                    <label>Buyer ID</label>
                                    <asp:TextBox ID="txtBuyerID" runat="server" CssClass="form-control" ReadOnly="True" />
                                </div>               

                                <div class="col-md-2">
                                    <label>Buying House Name</label>
                                    <asp:DropDownList ID="ddlBuyingHouseName" AutoPostBack="true" runat="server" CssClass="form-control" OnSelectedIndexChanged="ddlBuyingHouseName_SelectedIndexChanged"></asp:DropDownList>
                                </div>

                                <div class="col-md-2">
                                    <label>Buyer Name</label>
                                    <asp:TextBox ID="txtBuyerName" runat="server" CssClass="form-control" />
                                </div>

                                <div class="col-md-2">
                                    <label>Prefix</label>
                                    <asp:TextBox ID="txtPrefix" runat="server" CssClass="form-control" />
                                </div>                

                                <div class="col-md-2">
                                    <label>Buyer Type</label>
                                    <asp:DropDownList ID="ddlBuyerType" AutoPostBack="true" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>

                                <div class="col-md-2">
                                    <label>Buyer Contary Country</label>
                                    <asp:DropDownList ID="ddlCountryName" runat="server" CssClass="form-control"></asp:DropDownList>
                                </div>

                                <div class="col-md-2">
                                    <label>Contact Person</label>
                                    <asp:TextBox ID="txtContractPerson" runat="server" CssClass="form-control" />
                                </div>

                                <div class="col-md-2">
                                    <label>Contact No</label>
                                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" />
                                </div>                

                                <div class="col-md-2">
                                    <label>E-mail</label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" />
                                </div>               

                                <div class="col-md-6">
                                    <label>Address</label>
                                    <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" />
                                </div>              

                                <div class="col-md-6">
                                    <asp:CheckBox ID="CheckBox1" runat="server" AutoPostBack="true" CssClass="form-check-input" OnCheckedChanged="CheckBox1_CheckedChanged"/>
                                    <label class="form-check-label ms-2" for="CheckBox1">If Address & Local Address Same</label>
                                    <asp:TextBox ID="txtAddressLocal" runat="server" CssClass="form-control mt-1" />
                                </div>

                                <div class="col-md-6">
                                    <div>
                                        <asp:CheckBox ID="chkIsActive" runat="server" CssClass="form-check-input" />
                                        <label class="form-check-label ms-2" for="chkIsActive">Is Active</label>

                                        <div class="mt-3 text-end">
                                            <asp:Button ID="Button1" runat="server" Text="Clear" CssClass="btn btn-secondary" OnClick="Button1_Click"/>
                                            <asp:LinkButton ID="LinkButton1" runat="server" CssClass="btn btn-success d-inline-flex align-items-center" OnClick="LinkButton1_Click">
                                                <i class="bi bi-save me-1"></i>Save
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </div>

                            </div>

                        </asp:Panel>

                        <!-- Grid Panel -->
                        <asp:Panel ID="PanelBuyingAgent" runat="server">
                            <div class="card shadow-sm mt-3">
                                <div class="card-body p-2">

                                    <div class="table-responsive">
                                        <asp:GridView ID="gvBuyerInformation" runat="server" 
                                            CssClass="table table-sm table-bordered table-hover table-striped text-center align-middle"
                                            AutoGenerateColumns="False" 
                                            DataKeyNames="BuyerID" OnSelectedIndexChanged="gvBuyerInformation_SelectedIndexChanged" >

                                            <Columns>
                                                <asp:CommandField ShowSelectButton="True" SelectText="Select" />

                                                <asp:BoundField DataField="BuyerID" HeaderText="ID" />
                                                <asp:BoundField DataField="BuyerName" HeaderText="Branch Name" />
                                                <asp:BoundField DataField="Prefix" HeaderText="Prifix" />
                                                <asp:CheckBoxField DataField="IsActive" HeaderText="Status" />
                                            </Columns>

                                        </asp:GridView>
                                    </div>

                                </div>
                            </div>
                        </asp:Panel>

                    </div>
                </div>

            </div>
        </form>
    </body>
</html>