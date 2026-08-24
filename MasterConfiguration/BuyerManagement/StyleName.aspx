<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StyleName.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.OrderInformation.StyleName" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Style Name Setup - Nexa ERP</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background-color: #f8f9fa; font-size: 14px; }
        .card-header-custom { background-color: #1f4e78; color: white; font-weight: bold; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid my-4 px-4">
            <div class="card shadow-sm">
                <div class="card-header card-header-custom py-2">
                    <h5 class="mb-0">Style Name Setup</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-5 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Style Name</h6>
                            
                            <div class="mb-3">
                                <label class="form-label fw-bold">Style ID</label>
                                <asp:TextBox ID="txtStyleID" runat="server" CssClass="form-control" placeholder="Style ID Auto Generated" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Buyer Name <span class="text-danger">*</span></label>
                                <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="form-select" required="true">
                                    <asp:ListItem Value="">--Select Buyer--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Style Name <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtStyleName" runat="server" CssClass="form-control" placeholder="Enter style name"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Style / Article No <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtArticleNo" runat="server" CssClass="form-control" placeholder="Enter article number"></asp:TextBox>
                            </div>

                            <div class="d-flex gap-2 mt-4">
                                <asp:Button ID="btnSave" runat="server" CssClass="btn btn-success px-4" Text="Save" OnClick="btnSave_Click" />
                                <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel" OnClick="btnCancel_Click" CausesValidation="false" />
                            </div>
                        </div>

                        <!-- ডান সাইড: গ্রিড ভিউ / স্টাইল লিস্ট -->
                        <div class="col-md-7 ps-md-4 mt-4 mt-md-0">
                            <h6 class="text-primary fw-bold mb-3">Style List</h6>
                            <div class="table-responsive">
                                <asp:GridView ID="gvStyleList" runat="server" CssClass="table table-bordered table-striped table-hover align-middle" AutoGenerateColumns="False" EmptyDataText="No styles found." OnSelectedIndexChanged="gvStyleList_SelectedIndexChanged" OnRowCommand="gvStyleList_RowCommand">
                                    <Columns>
                                        <asp:BoundField DataField="StyleId" HeaderText="ID"/>
                                        <asp:BoundField DataField="BuyerName" HeaderText="Buyer" />
                                        <asp:BoundField DataField="StyleName" HeaderText="Style Name" />
                                        <asp:BoundField DataField="ArticleNo" HeaderText="Article No" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-sm btn-primary" Text="Edit" 
                                                    CommandName="EditStyle" 
                                                    CommandArgument='<%# Eval("StyleId") %>' 
                                                    CausesValidation="false" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>