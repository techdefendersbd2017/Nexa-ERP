<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StyleRegistrationSystem.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.OrderInformation.StyleRegistrationSystem" %>

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
            font-size: 12px;
            padding: 2px 6px;
        }

        .form-check-input {
            transform: scale(0.9);
            margin-top: 2px;
            font-weight: 700;
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


/* ── MAIN NAV TABS (like reference image) ── */
.main-nav-wrap {
  background: #fff;
  border-bottom: 2px solid #1a6fa8;
  padding: 0 0 0 0;
  position: sticky; top: 0; z-index: 999;
  box-shadow: 0 2px 5px rgba(0,0,0,0.08);
}
.main-nav {
  display: flex;
  flex-wrap: wrap;
  margin: 0;
  padding: 0;
  list-style: none;
}
.main-nav li { margin: 0; }
.main-nav li button {
  padding: 10px 18px;
  border: none;
  border-right: 1px solid #d0d8e0;
  background: #fff;
  color: #333;
  font-size: 13px;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
  white-space: nowrap;
  height: 42px;
  display: flex; align-items: center; gap: 6px;
}
.main-nav li button:hover { background: #e8f4ff; color: #1a5276; }
.main-nav li button.active {
  background: #1a6fa8;
  color: #fff;
  border-right-color: #1a6fa8;
}
.main-nav li:first-child button { border-left: none; }

/* ── SIDEBAR LIST ── */
.list-box { background: #f5f8fc; border: 1px solid #c5d5e5; border-radius: 4px; min-height: 180px; }
.list-box-title { padding: 7px 11px; font-weight: 700; font-size: 12px; color: #1a6fa8; border-bottom: 1px solid #c5d5e5; text-decoration: underline; }
.list-box ul { list-style: none; padding: 4px 0; margin: 0; }
.list-box ul li { padding: 5px 11px; font-size: 12px; cursor: pointer; display: flex; align-items: center; gap: 5px; }
.list-box ul li:hover { background: #dceefb; }
.list-box ul li a { color: #1a6fa8; text-decoration: none; font-size: 12px; }
.list-box ul li a:hover { text-decoration: underline; }
.ln { color: #888; font-size: 11px; }





.grid-container {
    width: 100%;
    overflow-x: auto;
}

.grid-container table {
    white-space: nowrap;
}
    </style>

</head>

    <body>
        <form id="form1" runat="server">
            <div class="container-fluid py-2 px-3">

                <div class="card shadow-sm">
                    <div class="card-header bg-primary text-white">
                        <h4 class="mb-0">Order Information</h4>
                        <asp:Label ID="Label1" runat="server" Text=""></asp:Label>
                    </div>

                    <div class="card-body">

                        <!-- Entry Panel -->
                        <asp:Panel ID="PanelEntry" runat="server">
                            <div class="row g-2">

                                <div class="col-md-3">
                                    <label>Order ID</label>
                                    <asp:TextBox ID="txtOrderID" runat="server" CssClass="form-control" ReadOnly="True" />
                                </div>               

                                <div class="col-md-3">
                                    <label>Buying House Name</label>
                                    <asp:DropDownList ID="ddlBuyingHouseName" AutoPostBack="true" runat="server" CssClass="form-control" OnSelectedIndexChanged="ddlBuyingHouseName_SelectedIndexChanged"></asp:DropDownList>
                                </div>

                                <div class="col-md-3">
                                    <label>Buyer Name</label>
                                    <asp:DropDownList ID="ddlBuyer" CssClass="form-control" runat="server"></asp:DropDownList>
                                </div>

                                <div class="col-md-3">
                                    <label>Artical No:</label>
                                    <asp:TextBox ID="txtArticalNo" runat="server" CssClass="form-control" />
                                </div>                

                                <div class="col-md-9">
                                    <label>Artical Description</label>                                    
                                    <asp:TextBox ID="txtArticalDescription" runat="server" CssClass="form-control" />
                                </div>            

                                <div class="col-md-3">
                                    <asp:CheckBox ID="ChkSetItem" Text="Set Item " runat="server" AutoPostBack="true" CssClass="form-check-input" OnCheckedChanged="CheckBox1_CheckedChanged"/>
                                    <asp:CheckBox ID="chkModel" Text="Model" runat="server" AutoPostBack="true" CssClass="form-check-input" OnCheckedChanged="chkModel_CheckedChanged"/>
                                    <asp:TextBox ID="txtNumberOfSetPcs" runat="server" placeholder="No of Set Pcs" CssClass="form-control" Enabled="False"></asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <label>Factory/Supplier</label>
                                    <asp:DropDownList ID="ddlFactorySupplier" CssClass="form-control" runat="server"></asp:DropDownList>
                                </div>  
                                <div class="col-md-3">
                                    <label>Season</label>
                                    <asp:DropDownList ID="txtSeason" CssClass="form-control" runat="server"></asp:DropDownList>
                                </div>
                                <div class="col-md-3">
                                    <label>Season (A,B,C)</label>
                                    <asp:TextBox ID="TextBox2" runat="server" CssClass="form-control" ></asp:TextBox>
                                </div>
                                <div class="col-md-3">
                                    <label>Artical Status</label>
                                    <asp:DropDownList ID="ddlArticalStatus" CssClass="form-control" runat="server"></asp:DropDownList>
                                </div>  
                                
                            <asp:Panel ID="PanelStyleInformation" runat="server">
                                <div class="card shadow-sm">
                                    <div class="card-header bg-primary text-white">
                                        <h4 class="mb-0">Style Information</h4>
                                        <asp:Label ID="Label2" runat="server" Text=""></asp:Label>
                                    </div>
                                    <div class="row g-2.5">
                                        <div class="col-md-3">
                                            <label>Style No</label>
                                            <asp:TextBox ID="txtStyleNo" runat="server" CssClass="form-control" ></asp:TextBox>
                                        </div>  
                                        
                                        <div class="col-md-3">
                                            <label>Style Description</label>
                                            <asp:TextBox ID="txtStyleDescription" runat="server" CssClass="form-control" ></asp:TextBox>
                                        </div>    
                                        
                                        <div class="col-md-3">
                                            <div class="form-group">
                                                <label><b>Select Sizes</b></label>
<div class="grid-container">

                                        <asp:GridView ID="gvSizeList" runat="server" 
                                            CssClass="table table-sm table-bordered table-hover table-striped text-center align-middle"
                                            AutoGenerateColumns="False" 
                                            DataKeyNames="SizeName" OnSelectedIndexChanged="gvBuyerInformation_SelectedIndexChanged" >

                                            <Columns>
                                                <asp:BoundField DataField="SizeName" HeaderText="Size Name" />
                                                <asp:CheckBoxField />
                                            </Columns>

                                        </asp:GridView>


</div>
                                                <%--<asp:ListBox ID="ddlSizeList"
                                                    runat="server"
                                                    SelectionMode="Multiple"
                                                    CssClass="form-control"  Height="100%">
                                                </asp:ListBox>--%>
                                            </div>
                                        </div>
                                        <div class="col-md-2">  
                                            <br/>
                                            <asp:LinkButton ID="LinkButton2" runat="server" CssClass="btn btn-success d-inline-flex align-items-center">
                                                <i class="bi bi-plus-circle me-2"></i>Add to List
                                            </asp:LinkButton>
                                        </div>
                                        
                                        <div class="col-md-8">  
                                            <asp:GridView ID="gvSelectedSize" runat="server" AutoGenerateColumns="false"
                                                CssClass="table table-sm table-bordered table-hover table-striped text-center align-middle">
                                                <Columns>
                                                    <asp:CommandField ShowSelectButton="True" SelectText="Select" />
                                                    <asp:BoundField DataField="role_id" HeaderText="Entry ID" />
                                                    <asp:BoundField DataField="role_name" HeaderText="Style No" />
                                                    <asp:BoundField DataField="description" HeaderText="Style Description" />
                                                    <asp:BoundField DataField="description" HeaderText="Size List" />
                                                </Columns>
                                            </asp:GridView>
                                        </div>
                                    </div>
                                    <br/>
                                </div>

                            </asp:Panel>




                                <div class="col-md-3">
                                    <div>
                                        <asp:Button ID="Button1" runat="server" Text="Clear" CssClass="btn btn-secondary"/>
                                        <asp:LinkButton ID="LinkButton1" runat="server" CssClass="btn btn-success d-inline-flex align-items-center" OnClick="LinkButton1_Click">
                                            <i class="bi bi-save me-1"></i>Save
                                        </asp:LinkButton>
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>
                        <!-- ══ MAIN NAV TABS ══ -->
                        <asp:Panel ID="PanelLinkPage" runat="server">
                            <div class="card shadow-sm mt-3">
                                <div class="card-body p-2"> 
                                    <div class="main-nav-wrap">
                                      <ul class="main-nav">
                                        <li><asp:LinkButton ID="LinkButton4" CssClass="btn btn-outline-primary w-100 text-start" runat="server" OnClick="LinkButton3_Click">Item/Model Entry Information</asp:LinkButton></li>
                                        <li><asp:LinkButton ID="LinkButton5" CssClass="btn btn-outline-primary w-100 text-start" runat="server" OnClick="LinkButton5_Click">Fabrication List</asp:LinkButton></li>
                                        <li><asp:LinkButton ID="LinkButton6" CssClass="btn btn-outline-primary w-100 text-start" runat="server" OnClick="LinkButton6_Click">Color Info</asp:LinkButton></li>
                                        <li><asp:LinkButton ID="LinkButton7" CssClass="btn btn-outline-primary w-100 text-start" runat="server" OnClick="LinkButton7_Click">Order Information</asp:LinkButton></li>
                                        <li><asp:LinkButton ID="LinkButton3" CssClass="btn btn-outline-primary w-100 text-start" runat="server" OnClick="LinkButton3_Click1">Order Details Entry</asp:LinkButton></li>
                                      </ul>
                                    </div>
                                </div>
                            </div>
                        </asp:Panel>                        
                        <br />

                        <asp:Panel ID="PanelItemModelEntryInformation" runat="server" Visible="false">
                            <div class="card shadow-sm">
                                <div class="card-header bg-primary text-white">
                                    <h4 class="mb-0">Item/Model Entry Information</h4>
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-3">
                                        <div class="list-box">
                                            <div class="list-box-title">Item/Model List</div>
                                            <asp:GridView ID="gvItemsList" runat="server" CssClass="table table-bordered table-hover"
                                                AutoGenerateColumns="False" DataKeyNames="Branch_ID">
                                                <Columns>
                                                    <asp:CommandField ShowSelectButton="True" SelectText="Select" />
                                                    <asp:BoundField DataField="Branch_ID" HeaderText="ID" />
                                                </Columns>
                                            </asp:GridView>
                                            <%--<ul id="p2_item_list"></ul>--%>
                                        </div>
                                    </div>
                                    <div class="col-md-9">
                                        <div class="row g-2">
                                            <div class="col-md-4">
                                                <%--column 1--%> 
                                                <div class="col-md">
                                                    <label>For Style</label>
                                                    <asp:TextBox ID="TextBox1" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                                <div class="col-md">
                                                    <label>Items Type</label>
                                                    <asp:TextBox ID="TextBox8" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                                <div class="col-md">
                                                    <label>Model</label>
                                                    <asp:TextBox ID="TextBox3" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                                <div class="col-md">
                                                    <label>Nature</label>
                                                    <asp:TextBox ID="TextBox4" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                                <div class="col-md">
                                                    <label>Items Group</label>
                                                    <asp:TextBox ID="TextBox7" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                                <div class="col-md">
                                                    <label>Items</label>
                                                    <asp:TextBox ID="TextBox9" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                                <div class="col-md">
                                                    <label>Items Name (Full)</label>
                                                    <asp:TextBox ID="TextBox10" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                            </div>   
                                            <div class="col-md-4">
                                                <%--column 2--%> 
                                                <div class="col-md">
                                                    <label>Division</label>
                                                    <asp:TextBox ID="TextBox5" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                                <div class="col-md">
                                                    <label>Neck Type</label>
                                                    <asp:TextBox ID="TextBox11" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                                <div class="col-md">
                                                    <label>Sleeve Type</label>
                                                    <asp:TextBox ID="TextBox12" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                                <div class="col-md">
                                                    <label>Item Status</label>
                                                    <asp:TextBox ID="TextBox13" runat="server" CssClass="form-control" ></asp:TextBox>
                                                </div>
                                            </div>  
                                            <div class="col-md-4">
                                                <%--column 3--%>                                                 
                                                <div class="col-md">
                                                    <asp:Image ID="Image1" runat="server" Height="150px" Width="350px" />
                                                    <asp:Button ID="Button2" runat="server" Width="350px" Text="Load Front/Top Part" />
                                                    <asp:Image ID="Image2" runat="server" Height="150px" Width="350px" />
                                                    <asp:Button ID="Button3" runat="server" Width="350px" Text="Load Back/Buttom Part" />
                                                </div>

                                            </div> 
                                        </div>
                                    </div>
                                </div>
                                <br/>
                            </div>
                        </asp:Panel>
                        <asp:Panel ID="PanelFabricationList" runat="server"> Under Design & Development Fabrication List</asp:Panel>
                        <asp:Panel ID="PanelColorInfo" runat="server"> Under Design & Development Color Info</asp:Panel>
                        <asp:Panel ID="PanelOrderEntry" runat="server"> Under Design & Development Order Entry</asp:Panel>
                        <asp:Panel ID="PanelOrderInformation" runat="server"> Under Design & Development Order Information</asp:Panel>
                    </div>
                </div>
            </div>


        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

        <!-- MultiSelect JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap-multiselect@0.9.15/dist/js/bootstrap-multiselect.js"></script>

<%--        <script>
            function loadMultiSelect() {
                $('#<%= ddlSizeList.ClientID %>').multiselect({
                    includeSelectAllOption: true,
                    selectAllText: 'Select All',
                    nonSelectedText: 'Select Sizes',
                    buttonWidth: '100%',
                    enableFiltering: true,
                    enableCaseInsensitiveFiltering: true
                });
            }

            $(document).ready(function () {
                loadMultiSelect();
            });
        </script>--%>





        </form>
    </body>
</html>