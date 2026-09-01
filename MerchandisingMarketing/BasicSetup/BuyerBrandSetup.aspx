<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BuyerBrandSetup.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.BasicSetup.BuyerBrandSetup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Buyer Brand Setup</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <asp:HiddenField ID="hfUserId" runat="server" />
            <asp:HiddenField ID="hfSetBreakdownId" runat="server" />

            <%-- ============================================================ --%>
            <%-- LIST PANEL : Set Breakdown Filters / List (opens first, always) --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlList" runat="server">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Set Breakdown List</p>
                    </div>
                    <asp:LinkButton ID="btnAddNew" runat="server" OnClick="btnAddNew_Click" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                        <i class="fa-solid fa-plus"></i>
                        <span>Add New Set Breakdown</span>
                    </asp:LinkButton>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- filter box --%>
                    <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400">
                        <div class="grid grid-cols-5 gap-x-3 gap-y-2">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">From</label>
                                <asp:TextBox ID="txtFromDate" placeholder="From" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">To</label>
                                <asp:TextBox ID="txtToDate" placeholder="To" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Buyer</label>
                                <asp:DropDownList ID="ddlBuyerFilter" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Buyer--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Style</label>
                                <asp:DropDownList ID="ddlStyleFilter" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Style--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">PO</label>
                                <asp:DropDownList ID="ddlPOFilter" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select PO--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>

                        <div class="flex justify-end gap-3 mt-3">
                            <asp:LinkButton ID="btnClearFilter" runat="server" OnClick="btnClearFilter_Click" CssClass="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-eraser"></i>
                                <span>Clear</span>
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnSearch" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-magnifying-glass"></i>
                                <span>Search</span>
                            </asp:LinkButton>
                        </div>
                    </div>

                    <!--Gridview-->
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-96 flex-1 overflow-y-auto overflow-x-auto mt-3">
                        <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                    </div>

                </div>
            </asp:Panel>

            <%-- ============================================================ --%>
            <%-- ENTRY PANEL : Master Information --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlEntry" runat="server" Visible="false">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Master Information</p>
                    </div>
                    <div class="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] transition-all duration-200 px-2 py-1 rounded cursor-pointer">
                        <div class="cursor-pointer hover:bg-[#f1f5f9] transition-all duration-200">
                            <i class="fa-solid fa-arrow-left text-gray-500 flex justify-center items-center"></i>
                        </div>
                        <asp:LinkButton ID="btnBackToList" runat="server" OnClick="btnBackToList_Click">Back To List</asp:LinkButton>
                    </div>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg px-3 py-2">

                    <%-- Buyer / Main Style / PO No + PO list --%>
                    <div class="grid grid-cols-12 gap-3">

                        <%-- left : Buyer, Main Style No, PO No + Add --%>
                        <div class="col-span-5 bg-[#FBFCFE] p-2 rounded border border-gray-400">
                            <div class="flex flex-col gap-2">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Buyer</label>
                                    <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Buyer--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Main Style No</label>
                                    <asp:DropDownList ID="ddlMainStyleNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Main Style No--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">PO No</label>
                                    <div class="flex gap-2">
                                        <asp:DropDownList ID="ddlPONo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select PO No--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                </div>
                            </div>
                            <div class="flex justify-end mt-3">
                                <asp:LinkButton ID="btnAddPO" runat="server" OnClick="btnAddPO_Click" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                    <i class="fa-solid fa-plus"></i>
                                    <span>Add</span>
                                </asp:LinkButton>
                            </div>
                        </div>

                        <%-- Right Grid view--%>
                        <div class="col-span-7 bg-[#FBFCFE] p-1 rounded border border-gray-400">
                            <div class="border border-gray-400 bg-gray-300 rounded w-full h-64 overflow-y-auto overflow-x-auto">
                                <asp:GridView ID="gvPOList" runat="server"></asp:GridView>
                            </div>
                        </div>

                    </div>

                    <%-- Main Color / Style No / Color / Ratio / CM(PCS) / FOB(PCS) + Add --%>
                    <div class="bg-[#FBFCFE] px-2 py-1 rounded border border-gray-400 mt-3">
                        <div class="grid grid-cols-6 gap-x-3 gap-y-2">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Main Color</label>
                                <asp:DropDownList ID="ddlMainColor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Main Color--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Style No</label>
                                <asp:DropDownList ID="ddlStyleNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Style No--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Color</label>
                                <asp:DropDownList ID="ddlColor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Color--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Ratio</label>
                                <asp:TextBox ID="txtRatio" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">CM (PCS)</label>
                                <asp:TextBox ID="txtCMPcs" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">FOB (PCS)</label>
                                <asp:TextBox ID="txtFOBPcs" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                        </div>

                        <div class="flex justify-end mt-2">
                            <asp:LinkButton ID="btnAddColorLine" runat="server" OnClick="btnAddColorLine_Click" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-plus"></i>
                                <span>Add</span>
                            </asp:LinkButton>
                        </div>
                    </div>

                    <%-- Color Grid view --%>
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-80 overflow-y-auto overflow-x-auto mt-3">
                        <asp:GridView ID="gvColorBreakdown" runat="server"></asp:GridView>
                    </div>

                    <%-- footer buttons --%>
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
