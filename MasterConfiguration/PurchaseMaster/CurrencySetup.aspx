<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CurrencySetup.aspx.cs" Inherits="Nexa_ERP.MasterConfiguration.PurchaseMaster.CurrencySetup" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Currency Setup</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        body {
            background-color: #f8f9fa;
            font-size: 14px;
        }
        .card-header-custom {
            background-color: #1f4e78;
            color: white;
            font-weight: bold;
        }
        .text-danger.field-error {
            display: block;
            font-size: 12px;
            margin-top: 2px;
        }
    </style>
    <script type="text/javascript">
        // পেজ লোড হওয়ার পর স্ক্রোল পজিশন সেট করা
        window.onload = function () {
            var scrollPos = document.getElementById('<%= hfScrollPosition.ClientID %>').value;
            if (scrollPos) {
                window.scrollTo(0, scrollPos);
            }
        };

        // সেভ বা আপডেট বাটনে ক্লিক করার সময় বর্তমান স্ক্রোল পজিশন সেভ করা
        window.onscroll = function () {
            var scrollPos = window.pageYOffset || document.documentElement.scrollTop;
            document.getElementById('<%= hfScrollPosition.ClientID %>').value = scrollPos;
        };
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfScrollPosition" runat="server" Value="0" />
        <div class="container-fluid my-4 px-4">
            <div class="card shadow-sm">
                <!-- হেডার -->
                <div class="card-header card-header-custom py-2">
                    <h5 class="mb-0">Currency Setup</h5>
                </div>
                <div class="card-body">

                    <asp:ValidationSummary ID="valSummary" runat="server" CssClass="alert alert-danger py-2"
                        HeaderText="নিচের সমস্যাগুলো ঠিক করুন:" DisplayMode="BulletList"
                        ValidationGroup="CurrencyGroup" />

                    <div class="row">
                        <!-- বাম সাইড: ইনপুট ফর্ম -->
                        <div class="col-md-5 border-end pe-md-4">
                            <h6 class="text-primary fw-bold mb-3">Add / Update Currency</h6>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Currency ID</label>
                                <asp:TextBox ID="txtCurrencyID" runat="server" CssClass="form-control" placeholder="Auto Generated" ReadOnly="true"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Currency Name <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtCurrencyName" runat="server" CssClass="form-control" placeholder="e.g. Bangladeshi Taka, US Dollar" MaxLength="100"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvCurrencyName" runat="server"
                                    ControlToValidate="txtCurrencyName" ErrorMessage="Currency Name আবশ্যক!"
                                    CssClass="text-danger field-error" Display="Dynamic"
                                    ValidationGroup="CurrencyGroup" />
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Currency Code <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtCurrencyCode" runat="server" CssClass="form-control text-uppercase" placeholder="e.g. BDT, USD" MaxLength="5"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvCurrencyCode" runat="server"
                                    ControlToValidate="txtCurrencyCode" ErrorMessage="Currency Code আবশ্যক!"
                                    CssClass="text-danger field-error" Display="Dynamic"
                                    ValidationGroup="CurrencyGroup" />
                                <asp:RegularExpressionValidator ID="revCurrencyCode" runat="server"
                                    ControlToValidate="txtCurrencyCode" ValidationExpression="^[A-Za-z]{3,5}$"
                                    ErrorMessage="Code শুধু ৩-৫ অক্ষরের (A-Z) হতে হবে, যেমন BDT, USD!"
                                    CssClass="text-danger field-error" Display="Dynamic"
                                    ValidationGroup="CurrencyGroup" />
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Symbol</label>
                                <asp:TextBox ID="txtSymbol" runat="server" CssClass="form-control" placeholder="e.g. ৳, $" MaxLength="5"></asp:TextBox>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Exchange Rate (Against Base) <span class="text-danger">*</span></label>
                                <asp:TextBox ID="txtExchangeRate" runat="server" CssClass="form-control" placeholder="e.g. 1.00 or 117.50" MaxLength="15"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvExchangeRate" runat="server"
                                    ControlToValidate="txtExchangeRate" ErrorMessage="Exchange Rate আবশ্যক!"
                                    CssClass="text-danger field-error" Display="Dynamic"
                                    ValidationGroup="CurrencyGroup" />
                                <asp:RegularExpressionValidator ID="revExchangeRate" runat="server"
                                    ControlToValidate="txtExchangeRate" ValidationExpression="^\d+(\.\d{1,4})?$"
                                    ErrorMessage="Exchange Rate শুধু সংখ্যা হতে হবে (যেমন 1.00 বা 117.5000)!"
                                    CssClass="text-danger field-error" Display="Dynamic"
                                    ValidationGroup="CurrencyGroup" />
                                <asp:CompareValidator ID="cmpExchangeRate" runat="server"
                                    ControlToValidate="txtExchangeRate" ValueToCompare="0" Operator="GreaterThan" Type="Double"
                                    ErrorMessage="Exchange Rate ০ এর বেশি হতে হবে!"
                                    CssClass="text-danger field-error" Display="Dynamic"
                                    ValidationGroup="CurrencyGroup" />
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                                    <asp:ListItem Text="Active" Value="Active" Selected="True"></asp:ListItem>
                                    <asp:ListItem Text="Inactive" Value="Inactive"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="d-flex gap-2 mt-4">
                                <asp:Button ID="btnSave" runat="server" CssClass="btn btn-success px-4" Text="Save"
                                    OnClick="btnSave_Click" ValidationGroup="CurrencyGroup" CausesValidation="true" />
                                <asp:Button ID="btnCancel" runat="server" CssClass="btn btn-secondary px-4" Text="Cancel"
                                    OnClick="btnCancel_Click" CausesValidation="false" />
                            </div>
                        </div>

                        <!-- ডান সাইড: গ্রিড ভিউ ও সার্চ -->
                        <div class="col-md-7 ps-md-4 mt-4 mt-md-0">
                            <!-- হেডার এবং সার্চ বক্সের জন্য ফ্লেক্স লেআউট -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h6 class="text-primary fw-bold m-0">Currency List</h6>

                                <!-- সার্চ বক্স -->
                                <div class="input-group input-group-sm w-50">
                                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search currencies..."
                                        AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" CausesValidation="false"></asp:TextBox>
                                    <asp:Button ID="btnSearch" runat="server" CssClass="btn btn-outline-primary" Text="Search"
                                        OnClick="btnSearch_Click" CausesValidation="false" />
                                </div>
                            </div>

                            <div class="table-responsive">
                                <asp:GridView ID="gvCurrency" runat="server" CssClass="table table-bordered table-striped table-hover align-middle" AutoGenerateColumns="False" EmptyDataText="No currencies found." OnSelectedIndexChanged="gvCurrency_SelectedIndexChanged" DataKeyNames="CurrencyID">
                                    <Columns>
                                        <asp:BoundField DataField="CurrencyID" HeaderText="ID"/>
                                        <asp:BoundField DataField="CurrencyName" HeaderText="Currency Name" />
                                        <asp:BoundField DataField="CurrencyCode" HeaderText="Code" />
                                        <asp:BoundField DataField="Symbol" HeaderText="Symbol" />
                                        <asp:BoundField DataField="ExchangeRate" HeaderText="Ex. Rate" />
                                        <asp:BoundField DataField="Status" HeaderText="Status" />

                                        <asp:TemplateField HeaderText="Action">
                                            <ItemTemplate>
                                                <asp:Button ID="btnEdit" runat="server" CssClass="btn btn-sm btn-primary" Text="Edit"
                                                    CommandName="Select" CausesValidation="false" />
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
