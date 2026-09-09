<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BuyerSetup.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.BasicSetup.BuyerSetup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Buyer Setup</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <asp:HiddenField ID="hfUserId" runat="server" />
            <asp:HiddenField ID="hfBuyerId" runat="server" />

            <%-- LIST PANEL : Buyer List (opens first, always) --%>
            <asp:Panel ID="pnlList" runat="server">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Buyer List</p>
                    </div>
                    <asp:LinkButton ID="btnAddNew" runat="server" OnClick="btnAddNew_Click" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] border border-white text-white px-4 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                        <i class="fa-solid fa-plus"></i>
                        <span>Add Buyer Entry</span>
                    </asp:LinkButton>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- filter box --%>
                    <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400">
                        <div class="flex items-end gap-3">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Search</label>
                                <asp:TextBox ID="txtSearchBuyer" placeholder="Search by buyer name..." runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-56 shrink-0">
                                <label class="text-sm font-medium">Buyer Type</label>
                                <asp:DropDownList ID="ddlBuyerType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">All</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="w-max shrink-0">
                                <asp:LinkButton ID="btnClearFilter" runat="server" OnClick="btnClearFilter_Click" CssClass="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                    <i class="fa-solid fa-eraser"></i>
                                    <span>Clear</span>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>

                    <!--Gridview-->
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-96 flex-1 overflow-y-auto overflow-x-auto mt-3">
                        <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                    </div>

                </div>
            </asp:Panel>

            <%-- ============================================================ --%>
            <%-- ENTRY PANEL : Buyer Information --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlEntry" runat="server" Visible="false">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Buyer Information</p>
                    </div>
                    <div class="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] transition-all duration-200 px-2 py-1 rounded cursor-pointer">
                        <div class="cursor-pointer hover:bg-[#f1f5f9] transition-all duration-200">
                            <i class="fa-solid fa-arrow-left text-gray-500 flex justify-center items-center"></i>
                        </div>
                        <asp:LinkButton ID="btnBackToList" runat="server" OnClick="btnBackToList_Click">Back To List</asp:LinkButton>
                    </div>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- Buyer Information box --%>
                    <div class="bg-[#FBFCFE] p-3 rounded border border-gray-400">
                        <div class="flex items-center gap-2 border-b border-gray-300 pb-2 mb-3">
                            <i class="fa-solid fa-user text-[#255C8C]"></i>
                            <p class="font-semibold text-gray-700">Buyer Information</p>
                        </div>

                        <div class="grid grid-cols-3 gap-x-3 gap-y-2">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Buyer Code<span class="text-red-500">*</span></label>
                                <asp:TextBox ID="txtBuyerCode" placeholder="Buyer Code" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Main Buyer</label>
                                <asp:DropDownList ID="ddlMainBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Main Buyer--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Knit Outside Buyer Name</label>
                                <asp:TextBox ID="txtKnitOutsideBuyerName" placeholder="Knit Outside Buyer Name" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Buyer Name<span class="text-red-500">*</span></label>
                                <asp:TextBox ID="txtBuyerName" placeholder="Buyer Name" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Contact</label>
                                <asp:TextBox ID="txtContact" placeholder="Contact" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Dyeing Outside Buyer Name</label>
                                <asp:TextBox ID="txtDyeingOutsideBuyerName" placeholder="Dyeing Outside Buyer Name" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Display Name<span class="text-red-500">*</span></label>
                                <asp:TextBox ID="txtDisplayName" placeholder="Display Name" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Email</label>
                                <asp:TextBox ID="txtEmail" placeholder="Email" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Garments Outside Buyer Name</label>
                                <asp:TextBox ID="txtGarmentsOutsideBuyerName" placeholder="Garments Outside Buyer Name" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">LC/SC Name</label>
                                <asp:TextBox ID="txtLCSCName" placeholder="LC/SC Name" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Commission (%)</label>
                                <asp:TextBox ID="txtCommission" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Licence No</label>
                                <asp:TextBox ID="txtLicenceNo" placeholder="Licence No" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Address</label>
                                <asp:TextBox ID="txtAddress" placeholder="Address" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Country</label>
                                <asp:DropDownList ID="ddlCountry" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Country--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex items-center gap-6 pt-5">
                                <div class="flex items-center gap-1.5">
                                    <asp:RadioButton ID="rbIsActive" runat="server" GroupName="grpBuyerFlags" Text="Is Active" CssClass="text-sm" />
                                </div>
                                <div class="flex items-center gap-1.5">
                                    <asp:RadioButton ID="rbIsLocal" runat="server" GroupName="grpBuyerFlags" Text="Is Local" CssClass="text-sm" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Buyer Ledger box --%>
                    <div class="bg-[#FBFCFE] p-3 rounded border border-gray-400 mt-3">
                        <div class="flex items-center gap-2 border-b border-gray-300 pb-2 mb-3">
                            <i class="fa-solid fa-dollar-sign text-[#255C8C]"></i>
                            <p class="font-semibold text-gray-700">Buyer Ledger</p>
                        </div>

                        <div class="grid grid-cols-3 gap-x-3 gap-y-2">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Asset Ledger</label>
                                <asp:TextBox ID="txtAssetLedger" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Sales Ledger</label>
                                <asp:TextBox ID="txtSalesLedger" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Liability Ledger</label>
                                <asp:TextBox ID="txtLiabilityLedger" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <%-- footer buttons : Clear + Save (same as before) --%>
                    <div class="space-x-3 flex justify-end items-end mt-4">
                        <asp:LinkButton ID="btnClear" runat="server" OnClick="btnClear_Click" CssClass="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-eraser"></i>
                            <span>Clear</span>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnSave" runat="server" OnClick="btnSave_Click" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-save"></i>
                            <span>Save</span>
                        </asp:LinkButton>
                    </div>

                </div>
            </asp:Panel>

        </div>
    </form>
</body>
</html>