<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="supplierRateEntry.aspx.cs" Inherits="Nexa_ERP.Procurement.supplierRateEntry" %>



<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Supplier Rate Entry</title>
    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />



</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">


        <%-- ========================= supplier rate entry ============================ --%>

        <div class="max-w-[1320px] w-full m-auto rounded-lg border" id="Requisition">

            <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                <div class="text-white">
                    <p class="text-xl mb-1 font-medium">Supplier Rate Entry</p>

                </div>

            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="bg-[#FBFCFE] w-full">

                    <%-- Mater data --%>

                    <fieldset class="grid grid-cols-12 gap-x-3 gap-y-2 border border-gray-400 rounded p-2">
                        <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Master Data</legend>

                        <div class="col-span-12 flex flex-col">

                            <div class="grid grid-cols-12 gap-x-3 gap-y-2 w-full">

                                <div class="flex flex-col gap-0.5 w-full col-span-4">
                                    <label class="text-sm font-medium">Supplier</label>
                                    <asp:DropDownList ID="ddlSupplier" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Supplier--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <!-- Load Button -->
                                <div class="flex items-end w-full col-span-2">
                                    <asp:LinkButton ID="btnLoad" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#4F46E5] text-white px-4 py-1.5 shadow-sm hover:bg-[#4338CA] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center w-full">
                                        <i class="fa-solid fa-rotate text-xs"></i>
                                        <span>Load</span>
                                     </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </fieldset>

                </div>

                <%-- ========== Rate Details ============ --%>

                <fieldset class="border border-gray-400 rounded p-2 mt-6">
                    <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Rate Details</legend>

                    <div class="grid grid-cols-3 gap-x-3 gap-y-2">

                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Item Name</label>
                            <asp:DropDownList ID="ddlItemName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select Item--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Unit</label>
                            <asp:TextBox ID="txtUnit" placeholder="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Rate Type</label>
                            <asp:TextBox ID="txtRateType" placeholder="Purchase/Service" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Rate</label>
                            <asp:TextBox ID="txtRate" placeholder="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Date</label>
                            <asp:DropDownList ID="ddlDate" placeholder="e.g Requisition Type" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select Date--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex gap-3 items-end">

                            <%-- chk is active --%>
                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer whitespace-nowrap"></asp:Label>
                            </div>

                            <!-- Add Item Button -->
                            <asp:LinkButton ID="btnAddItem" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#16A34A] text-white px-4 py-1.5 shadow-sm hover:bg-[#15803D] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center whitespace-nowrap">
                                <i class="fa-solid fa-plus text-xs"></i>
                                <span>Add Item</span>
                            </asp:LinkButton>

                            <!-- Reset Button -->
                            <asp:LinkButton ID="btnReset" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#DC2626] text-white px-4 py-1.5 shadow-sm hover:bg-[#B91C1C] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-rotate-right text-xs"></i>
                                <span>Reset</span>
                            </asp:LinkButton>

                        </div>
                    </div>

                    <div class="mt-6">
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-full  overflow-y-auto overflow-x-auto pt-6">
                            <asp:ListView ID="ListView2" runat="server"></asp:ListView>
                        </div>

                    </div>
                </fieldset>

                <!-- below btn -->
                <div class="space-x-4 mt-6">


                    <div class="flex gap-4 items-center justify-end">

                        <!-- Save Button -->
                        <asp:LinkButton ID="btnSave" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-save"></i>
                            <span>Save</span>
                        </asp:LinkButton>

                        <!-- Cancel Button -->
                        <asp:LinkButton ID="btnCancel" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#DC2626] text-white px-4 py-1.5 shadow-sm hover:bg-[#B91C1C] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-x"></i>
                            <span>Cancel</span>
                        </asp:LinkButton>

                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

