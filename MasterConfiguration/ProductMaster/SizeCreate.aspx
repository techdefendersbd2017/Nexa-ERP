<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SizeCreate.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.MsterSetup.SizeCreate" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Size and Group Creation</title>
    <!-- Bootstrap CSS for modern styling -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body { background-color: #f8f9fa; font-size: 14px; }
        .card-header-custom { background-color: #1f4e78; color: white; font-weight: bold; }
    </style>
    <script type="text/javascript">
        // পেজ লোড হওয়ার পর সেভ করা scroll position এ ফিরে যাওয়া
        window.onload = function () {
            var hf = document.getElementById('<%= hfScrollPosition.ClientID %>');
            if (hf && hf.value && parseInt(hf.value) > 0) {
                window.scrollTo(0, parseInt(hf.value));
            }
        };

        // বাটনে ক্লিক করার মুহূর্তে বর্তমান scroll position hidden field এ সেভ করা
        function saveScrollPos() {
            document.getElementById('<%= hfScrollPosition.ClientID %>').value =
                (window.pageYOffset || document.documentElement.scrollTop);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
        
        <asp:HiddenField ID="hfScrollPosition" runat="server" Value="0" />
        <div class="container-fluid my-4 px-4">
            <div class="card shadow-sm">
                <div class="card-header card-header-custom py-2">
                    <h5 class="mb-0">Size & Group Creation</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-5 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Size Group & Size</h6>
                            
                            <!-- Hidden ID for Edit/Update -->
                            <asp:TextBox ID="txtSizeId" runat="server" Visible="false"></asp:TextBox>

                            <!-- Size Group Section -->
                            <div class="card p-3 bg-light mb-3">
                                <h6 class="text-secondary fw-bold mb-2">Size Group Setup</h6>
                                <div class="mb-2">
                                    <label class="form-label fw-bold small">Size Group Name (e.g., Apparel, Shoes)</label>
                                    <asp:TextBox ID="txtGroupName" runat="server" CssClass="form-control form-control-sm" placeholder="Enter Group Name"></asp:TextBox>
                                </div>
                                <div>
                                    <asp:Button ID="btnSaveGroup" runat="server" CssClass="btn btn-sm btn-secondary px-3" Text="Save Group" OnClick="btnSaveGroup_Click" OnClientClick="saveScrollPos();" />
                                </div>
                            </div>

                            <hr />

                            <!-- Size Setup Section -->
                            <div class="mb-3">
                                <label class="form-label fw-bold">Select Size Group</label>
                                <asp:DropDownList ID="ddlSizeGroup" runat="server" AutoPostBack="true" CssClass="form-select" OnSelectedIndexChanged="ddlSizeGroup_SelectedIndexChanged">
                                </asp:DropDownList>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Size Name (e.g., XL, 42, Medium)</label>
                                <asp:TextBox ID="txtSizeName" runat="server" CssClass="form-control" placeholder="Enter Size Name"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Active" Value="Active" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="d-flex gap-2">
                                <asp:Button ID="btnSaveSize" runat="server" CssClass="btn btn-success px-4" Text="Save" OnClick="btnSaveSize_Click" OnClientClick="saveScrollPos();" />
                                <asp:Button ID="btnRefresh" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel" OnClick="btnRefresh_Click" OnClientClick="saveScrollPos();" CausesValidation="false" />
                            </div>
                        </div>

                        <!-- ডান সাইড: গ্রিড ভিউ (সাইজ এবং গ্রুপ লিস্ট) -->
                        <div class="col-md-7 ps-md-4 mt-4 mt-md-0">
                            
                            <!-- Existing Sizes List -->
                            <h6 class="text-primary fw-bold mb-3">Existing Sizes List</h6>
                            <div class="table-responsive mb-4">
                                <asp:GridView ID="gvSizes" runat="server" CssClass="table table-bordered table-striped table-hover align-middle" 
                                    AutoGenerateColumns="False" EmptyDataText="No sizes found." OnSelectedIndexChanged="gvSizes_SelectedIndexChanged">
                                    <Columns>
                                        <asp:BoundField DataField="SizeID" HeaderText="ID" />
                                        <asp:BoundField DataField="GroupName" HeaderText="Size Group" />
                                        <asp:BoundField DataField="SizeName" HeaderText="Size Name" />
                                        <asp:BoundField DataField="Status" HeaderText="Status" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-sm btn-primary" Text="Edit" CommandName="Select" OnClientClick="saveScrollPos();" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </div>

                            <!-- Existing Size Groups List -->
                            <h6 class="text-secondary fw-bold mb-3">Existing Size Groups List</h6>
                            <div class="table-responsive">
                                <asp:GridView ID="gvSizeGroups" runat="server" CssClass="table table-bordered table-striped table-hover align-middle" 
                                    AutoGenerateColumns="False" EmptyDataText="No size groups found." OnSelectedIndexChanged="gvSizeGroups_SelectedIndexChanged">
                                    <Columns>
                                        <asp:BoundField DataField="GroupID" HeaderText="Group ID" />
                                        <asp:BoundField DataField="GroupName" HeaderText="Group Name" />
                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnEditGroup" runat="server" CssClass="btn btn-sm btn-secondary" Text="Edit" CommandName="Select" OnClientClick="saveScrollPos();" />
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
</body>
</html>