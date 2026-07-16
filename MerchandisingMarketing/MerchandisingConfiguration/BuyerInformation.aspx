<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BuyerInformation.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration.BuyerInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">

    <title>Buyer Info - NexaERP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    
    <!-- আপনার বিদ্যমান CSS টি এখানে ব্যবহার করুন -->
    <style>
        .page-heading {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 16px;
        }

        .page-heading i {
            font-size: 1.4rem;
            color: var(--brand-primary);
        }

        .page-heading h3 {
            margin: 0;
            font-weight: 700;
            font-size: 1.35rem;
            color: #111827;
        }

        .page-heading small {
            display: block;
            color: var(--text-muted);
            font-weight: 400;
            font-size: 0.8rem;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid main-container">
            <div class="page-heading">
                <!-- আইকনটি সরাসরি হেডিংয়ের বাম পাশে -->
                <i class="bi bi-person-lines-fill" style="font-size: 2rem; color: #0d6efd; margin-right: 15px;"></i>
                <div>
                    <h3>Buyer Info</h3>
                    <small>Commercial &rsaquo; Setup &rsaquo; Buyer Info</small>
                </div>
            </div>

            <div class="row">
                <!-- বাম পাশের ইনপুট প্যানেল -->
                <div class="col-12 col-lg-5 mb-3">
                    <div class="card shadow">
                        <div class="card-header bg-primary text-white" style="display: flex; align-items: center; gap: 10px;">
                            <i class="bi bi-pencil-square" style="font-size: 1.1rem;"></i>
                            <h4 class="mb-0" style="font-size: 1.05rem; font-weight: 600;">Buyer Information</h4>
                        </div>
                        <div class="card-body left-panel">
                            <div class="row g-2">
                                <div class="col-md-6"><label>Buyer Code</label><asp:TextBox ID="txtBuyerCode" runat="server" CssClass="form-control" /></div>
                                <div class="col-md-6"><label>Buyer Name</label><asp:TextBox ID="txtBuyerName" runat="server" CssClass="form-control" /></div>
                                <div class="col-12"><label>Buyer Display Name</label><asp:TextBox ID="txtDisplayName" runat="server" CssClass="form-control" /></div>
                                <div class="col-md-6"><label>Currency</label><asp:TextBox ID="txtCurrency" runat="server" CssClass="form-control" /></div>
                                <div class="col-md-6"><label>Contact No</label><asp:TextBox ID="txtContact" runat="server" CssClass="form-control" /></div>
                                <div class="col-12"><label>Email</label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" /></div>
                                <div class="col-md-6"><label>Main Buyer</label><asp:DropDownList ID="ddlMainBuyer" runat="server" CssClass="form-select"></asp:DropDownList></div>
                                <div class="col-12"><label>Country</label><asp:DropDownList ID="ddlCountry" runat="server" CssClass="form-select"></asp:DropDownList></div>
                                <div class="col-12"><label>Address</label><asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control" /></div>
                                
                                <!-- চেক বক্সগুলো একলাইনে আনার জন্য CSS ক্লাস ব্যবহার -->
                                <div class="col-12 mt-2 d-flex flex-wrap gap-3">
                                    <div class="form-check">
                                        <asp:CheckBox ID="chkActive" runat="server" CssClass="form-check-input" />
                                        <label class="form-check-label">Is Active</label>
                                    </div>
                                    <div class="form-check">
                                        <asp:CheckBox ID="chkLocal" runat="server" CssClass="form-check-input" />
                                        <label class="form-check-label">Is Local</label>
                                    </div>
                                </div>
                                <!-- নিচের বাটনস -->
                                <div class="card-footer bg-light d-flex justify-content-between">
                                    <div class="d-flex gap-1">
                                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-success btn-sm" />
                                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-danger btn-sm" />
                                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-warning btn-sm" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ডান পাশের সার্চ ও গ্রিড প্যানেল -->
                <div class="col-12 col-lg-7 mb-3">
                    <div class="card shadow right-panel">
                        <div class="card-header bg-success text-white d-flex justify-content-between align-items-center">
                            <div><i class="bi bi-search"></i> Search & List</div>
                            <div class="d-flex gap-2">
                                <asp:TextBox ID="txtSearchLc" runat="server" placeholder="LC Name" CssClass="form-control form-control-sm" />
                                <asp:TextBox ID="txtSearchBuyer" runat="server" placeholder="Buyer" CssClass="form-control form-control-sm" />
                                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-sm btn-light" />
                            </div>
                        </div>
                        <div class="grid-wrapper">
                            <!-- গ্রিড ভিউতে Select বাটন যুক্ত -->
                            <asp:GridView ID="gvBuyer" runat="server" CssClass="table table-bordered table-hover" AutoGenerateColumns="False">
                                <Columns>
                                    <asp:CommandField ShowSelectButton="True" SelectText="Select" ButtonType="Button" ControlStyle-CssClass="btn btn-sm btn-outline-primary" />
                                    <asp:BoundField DataField="Code" HeaderText="Code" />
                                    <asp:BoundField DataField="BuyerName" HeaderText="Buyer Name" />
                                    <asp:BoundField DataField="DisplayName" HeaderText="Display Name" />
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