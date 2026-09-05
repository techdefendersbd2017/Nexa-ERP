<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VoucherEntry.aspx.cs" Inherits="Nexa_ERP.AccountsModule.VoucherEntry" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Voucher Entry</title>
    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />


</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">


        <%-- ========================= purachase  order open ============================ --%>

        <div class="max-w-[1320px] w-full m-auto rounded-lg border" id="Color">

            <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                <div class="text-white">
                    <p class="text-xl mb-1 font-medium">Voucher Entry</p>

                </div>

            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class=" w-full grid grid-cols-12 space-x-3">

                    <%-- left container --%>
                    <fieldset class="col-span-12 border border-gray-400 rounded p-2 bg-[#FBFCFE]">
                        <%--<legend class="text-sm font-medium px-2 text-[#255C8C] italic">Master Information</legend>--%>

                        <div class="grid grid-cols-3 gap-3">

                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Company</label>
                                <asp:DropDownList ID="ddlCompany" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Company--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Voucher Type</label>
                                <asp:DropDownList ID="ddlVoucherType" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Voucer Type--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Voucher No</label>
                                <asp:TextBox ID="txtVoucherNo" placeholder="XXX-XXXXX" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Trans. Source</label>
                                <asp:TextBox ID="txtTransSource" placeholder="e.g Transaction Source" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Voucher Date</label>
                                <asp:DropDownList ID="ddlVoucherDate" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Voucher Date--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Voucher Ref. No</label>
                                <asp:TextBox ID="txtVoucherRefaranceNo" placeholder="XXX-XXXXX" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Payment Mode</label>
                                <asp:DropDownList ID="ddlPaymentMode" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Payment Mode--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Cheque No</label>
                                <asp:TextBox ID="txtChequeNo" placeholder="XXX-XXXXX" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex items-end gap-4">
                                <!-- Cash Option -->
                                <div class="flex items-center gap-1">
                                    <asp:RadioButton ID="rbCash" runat="server" GroupName="PaymentMethod" Checked="true" CssClass="cursor-pointer accent-[#255C8C]" />
                                    <asp:Label ID="lblCash" runat="server" AssociatedControlID="rbCash" Text="Cash" CssClass="cursor-pointer whitespace-nowrap"></asp:Label>
                                </div>
                                <!-- Bank Option -->
                                <div class="flex items-center gap-1">
                                    <asp:RadioButton ID="rbBank" runat="server" GroupName="PaymentMethod" CssClass="cursor-pointer accent-[#255C8C]" />
                                    <asp:Label ID="lblBank" runat="server" AssociatedControlID="rbBank" Text="Bank" CssClass="cursor-pointer whitespace-nowrap"></asp:Label>
                                </div>

                            </div>

                        </div>

                    </fieldset>
                </div>

                <%-- ======== search with  Grid ======== --%>
                <fieldset class="col-span-12 border border-gray-400 p-2 rounded bg-[#FBFCFE] mt-6">
                    <%--<legend class="text-sm font-medium px-2 text-[#255C8C] italic">Style Color</legend>--%>
                    <div class="grid grid-cols-4 gap-3">

                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Accounts Head</label>
                            <asp:TextBox ID="txtAccountsHead" placeholder="e.g Accounts Head" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Bill No</label>
                            <asp:DropDownList ID="ddlBillNo" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select Bill No--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Cost Center</label>
                            <asp:DropDownList ID="ddlCostCenter" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select Cost Center--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Value</label>
                            <asp:TextBox ID="txtValue" placeholder="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Currency</label>
                            <asp:TextBox ID="txtCurrency" placeholder="e.g Currency" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Conv. RT</label>
                            <asp:TextBox ID="txtConvRate" placeholder="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">DR</label>
                            <asp:TextBox ID="txtDr" placeholder="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">CR</label>
                            <asp:TextBox ID="txtCr" placeholder="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full col-span-3">
                            <label class="text-sm font-medium">Note</label>
                            <asp:TextBox ID="txtNote" placeholder="e.g Note" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>

                        <div class="flex gap-3 items-end">
                            <!-- Add Item Button -->
                            <asp:LinkButton ID="btnAddItem" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#16A34A] text-white px-4 py-1.5 shadow-sm hover:bg-[#15803D] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center whitespace-nowrap">
                                        <i class="fa-solid fa-plus text-xs"></i>
                                        <span>Add</span>
                            </asp:LinkButton>

                            <!-- Reset Button -->
                            <asp:LinkButton ID="btnReset" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#DC2626] text-white px-4 py-1.5 shadow-sm hover:bg-[#B91C1C] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                        <i class="fa-solid fa-rotate-right text-xs"></i>
                                        <span>Reset</span>
                            </asp:LinkButton>
                        </div>
                    </div>
                </fieldset>




                <%-- List view --%>
                <div class="mt-6">
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-36 overflow-y-auto overflow-x-auto">
                        <asp:ListView ID="ListView3" runat="server"></asp:ListView>
                    </div>
                </div>

                <div class="grid grid-cols-4 gap-3 mt-6">
                    <div class="flex flex-col gap-0.5 w-full">
                        <label class="text-sm font-medium">Account Name</label>
                        <asp:TextBox ID="txtAccountName" placeholder="e.g Account Name" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full col-span-3">
                        <label class="text-sm font-medium">Narration</label>
                        <asp:TextBox ID="txtNarration" placeholder="e.g Narration" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                    </div>
                </div>

                <!-- below btn -->
                <div class=" mt-3">

                    <div class="flex gap-4 items-end justify-between">
                        <div class="flex items-center gap-2 mt-4">
                            <!-- Cheque Print Button -->
                            <asp:LinkButton ID="btnPrintCheque" runat="server"
                                CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-2 shadow-sm hover:bg-[#1d476d] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-print"></i>
                                <span>Cheque Print</span>
                            </asp:LinkButton>

                            <!-- Post Button -->
                            <asp:LinkButton ID="btnPost" runat="server"
                                CssClass="flex items-center gap-1.5 rounded bg-[#198754] text-white px-4 py-2 shadow-sm hover:bg-[#146c43] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-paper-plane"></i>
                                <span>Post</span>
                            </asp:LinkButton>
                        </div>


                        <div class="flex gap-3">

                            <!-- Save Button -->
                            <asp:LinkButton ID="btnSave" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-2 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-save"></i>
                                <span>Save</span>
                            </asp:LinkButton>

                            <!-- Cancel Button -->
                            <asp:LinkButton ID="btnCancel" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#DC2626] text-white px-4 py-2 shadow-sm hover:bg-[#B91C1C] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-regular fa-calendar-minus"></i>
                                <span>Clear</span>
                            </asp:LinkButton>

                            <!-- Print Button -->
                            <asp:LinkButton ID="btnPrint" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-2 shadow-sm hover:bg-[#1d4970] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-print"></i>
                            <span>Print</span>
                            </asp:LinkButton>
                        </div>



                    </div>
                </div>
            </div>


        </div>

    </form>
</body>
</html>


