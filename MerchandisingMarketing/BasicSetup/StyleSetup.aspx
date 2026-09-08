<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StyleSetup.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.BasicSetup.StyleSetup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Style Setup</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <asp:HiddenField ID="hfUserId" runat="server" />
            <asp:HiddenField ID="hfStyleId" runat="server" />
            <asp:HiddenField ID="hfPOId" runat="server" />
            <asp:HiddenField ID="hfPOCombineId" runat="server" />
            <asp:HiddenField ID="hfActivePOTab" runat="server" Value="Master" />
            <asp:HiddenField ID="hfActiveCombineTab" runat="server" Value="Detail" />

            <%-- ============================================================ --%>
            <%-- PANEL 1 : Style List (opens first, always) --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlStyleList" runat="server">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Style List</p>
                    </div>
                    <asp:LinkButton ID="btnAddNewStyle" runat="server" OnClick="btnAddNewStyle_Click" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                        <i class="fa-solid fa-plus"></i>
                        <span>Add New Style</span>
                    </asp:LinkButton>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- filter row --%>
                    <div class="flex items-end gap-3 mb-3">
                        <div class="flex flex-col gap-0.5 w-56">
                            <label class="text-sm font-medium">Buyer</label>
                            <asp:DropDownList ID="ddlBuyerNameFilter" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select buyer name--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-56">
                            <label class="text-sm font-medium">Style No</label>
                            <asp:TextBox ID="txtStyleNoFilter" placeholder="Style No" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-40">
                            <label class="text-sm font-medium">Status</label>
                            <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">All</asp:ListItem>
                                <asp:ListItem Value="Active">Active</asp:ListItem>
                                <asp:ListItem Value="Inactive">Inactive</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <asp:LinkButton ID="btnSearchStyle" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-magnifying-glass"></i>
                            <span>Search</span>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnClearStyleFilter" runat="server" CssClass="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-eraser"></i>
                            <span>Clear</span>
                        </asp:LinkButton>
                    </div>

                    <!--Gridview-->
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-80 flex-1 overflow-y-auto overflow-x-auto">
                        <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                    </div>

                </div>
            </asp:Panel>

            <%-- ============================================================ --%>
            <%-- PANEL 2 : Style Details --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlStyleDetails" runat="server" Visible="false">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] transition-all duration-200 px-2 py-1 rounded cursor-pointer">
                        <i class="fa-solid fa-arrow-left text-gray-500"></i>
                        <asp:LinkButton ID="btnBackToStyleList" runat="server" OnClick="btnBackToStyleList_Click">Back</asp:LinkButton>
                    </div>
                    <div class="space-x-2">
                        <asp:LinkButton ID="btnAddNewPurchaseOrder" runat="server" OnClick="btnAddNewPurchaseOrder_Click" CssClass="inline-flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-plus"></i>
                            <span>Add New Purchase Order</span>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnClearStyleDetails" runat="server" OnClick="btnClearStyleDetails_Click" CssClass="inline-flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-eraser"></i>
                            <span>Clear</span>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnSaveStyle" runat="server" OnClick="btnSaveStyle_Click" CssClass="inline-flex items-center gap-1.5 rounded bg-white text-[#255C8C] px-4 py-1.5 shadow-sm hover:bg-gray-100 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-save"></i>
                            <span>Save</span>
                        </asp:LinkButton>
                    </div>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <div class="grid grid-cols-12 gap-3">

                        <%-- left column : Style Details + Financial + Fabric + Embellishment --%>
                        <div class="col-span-8 flex flex-col gap-3">

                            <%-- Style Details --%>
                            <div class="bg-[#FBFCFE] p-3 rounded border border-gray-400">
                                <p class="text-sm font-semibold border-b border-gray-300 pb-1 mb-2">Style Details</p>
                                <div class="grid grid-cols-2 gap-x-3 gap-y-2">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Product Type*</label>
                                        <asp:DropDownList ID="ddlProductType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="KNIT" Selected="True">KNIT</asp:ListItem>
                                            <asp:ListItem Value="WOVEN">WOVEN</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Product Dept.*</label>
                                        <asp:DropDownList ID="ddlProductDept" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select product dept.--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Buyer Name*</label>
                                        <asp:DropDownList ID="ddlBuyerName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select buyer name--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Item Type*</label>
                                        <asp:DropDownList ID="ddlItemType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select item type--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Style No*</label>
                                        <asp:TextBox ID="txtStyleNo" placeholder="Style No" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Item UOM*</label>
                                        <asp:DropDownList ID="ddlItemUOM" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="PCS" Selected="True">PCS</asp:ListItem>
                                            <asp:ListItem Value="DZN">DZN</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Style Description</label>
                                        <asp:TextBox ID="txtStyleDescription" placeholder="Style Description" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex items-end gap-3 w-full">
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="text-sm font-medium">Marketing SMV</label>
                                            <asp:TextBox ID="txtMarketingSMV" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                        </div>
                                        <asp:CheckBox ID="chkIsActiveStyle" runat="server" Text="Is Active" Checked="true" CssClass="text-sm font-medium whitespace-nowrap" />
                                    </div>
                                </div>
                            </div>

                            <%-- Financial Info + Fabric Details --%>
                            <div class="grid grid-cols-2 gap-3">
                                <div class="bg-[#FBFCFE] p-3 rounded border border-gray-400">
                                    <p class="text-sm font-semibold border-b border-gray-300 pb-1 mb-2">Financial Info</p>
                                    <div class="grid grid-cols-2 gap-x-3 gap-y-2">
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="text-sm font-medium">FOB (USD)</label>
                                            <asp:TextBox ID="txtFOBUsd" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="text-sm font-medium">CM (DZN)</label>
                                            <asp:TextBox ID="txtCMDzn" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="text-sm font-medium">PO FOB</label>
                                            <asp:TextBox ID="txtPOFOB" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="text-sm font-medium">Currency</label>
                                            <asp:DropDownList ID="ddlCurrencyStyle" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                                <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full col-span-2">
                                            <label class="text-sm font-medium">Po Exchange Rate</label>
                                            <asp:TextBox ID="txtPoExchangeRate" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>

                                <div class="bg-[#FBFCFE] p-3 rounded border border-gray-400">
                                    <p class="text-sm font-semibold border-b border-gray-300 pb-1 mb-2">Fabric Details</p>
                                    <div class="flex flex-col gap-2">
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="text-sm font-medium">Fabric GSM</label>
                                            <asp:TextBox ID="txtFabricGSM" placeholder="Fabric GSM" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="text-sm font-medium">Fabrication</label>
                                            <asp:TextBox ID="txtFabrication" placeholder="Fabrication" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <%-- Embellishment Details + Image --%>
                            <div class="grid grid-cols-2 gap-3">
                                <div class="bg-[#FBFCFE] p-3 rounded border border-gray-400">
                                    <p class="text-sm font-semibold border-b border-gray-300 pb-1 mb-2">Embellishment Details</p>
                                    <div class="flex flex-col gap-2">
                                        <div class="flex items-center gap-2">
                                            <asp:CheckBox ID="chkIsPrint" runat="server" Text="Is Print" CssClass="text-sm w-32 whitespace-nowrap" />
                                            <asp:DropDownList ID="ddlPrintType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                                <asp:ListItem Value="" Selected="True">--Select print type--</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                        <div class="flex items-center gap-2">
                                            <asp:CheckBox ID="chkIsEmbroidery" runat="server" Text="Is Embroidery" CssClass="text-sm w-32 whitespace-nowrap" />
                                            <asp:DropDownList ID="ddlEmbroideryType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                                <asp:ListItem Value="" Selected="True">--Select embroidery ...--</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                        <div class="flex items-center gap-2">
                                            <asp:CheckBox ID="chkIsWashing" runat="server" Text="Is Washing" CssClass="text-sm w-32 whitespace-nowrap" />
                                            <asp:DropDownList ID="ddlWashingType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                                <asp:ListItem Value="" Selected="True">--Select washing type--</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                        <div class="flex items-center gap-2">
                                            <asp:CheckBox ID="chkIsSmock" runat="server" Text="Is Smock" CssClass="text-sm w-32 whitespace-nowrap" />
                                            <asp:DropDownList ID="ddlSmockType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                                <asp:ListItem Value="" Selected="True">--Select smock type--</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>
                                </div>

                                <div class="bg-[#FBFCFE] p-3 rounded border border-gray-400 flex flex-col items-center justify-center relative" style="min-height:180px;">
                                    <asp:Image ID="imgStyle" runat="server" Visible="false" CssClass="max-h-32" />
                                    <asp:Label ID="lblNoImage" runat="server" Text="N/A" CssClass="text-gray-400 text-lg" />
                                    <div class="absolute bottom-2 right-2">
                                        <asp:LinkButton ID="btnUpdateImage" runat="server" OnClick="btnUpdateImage_Click" CssClass="flex items-center gap-1.5 rounded border border-gray-300 bg-white text-gray-700 px-3 py-1 shadow-sm hover:bg-gray-100 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline">
                                            <i class="fa-solid fa-image"></i>
                                            <span>Update Image</span>
                                            <i class="fa-solid fa-chevron-down text-xs"></i>
                                        </asp:LinkButton>
                                    </div>
                                    <asp:FileUpload ID="fuStyleImage" runat="server" Visible="false" />
                                </div>
                            </div>

                        </div>

                        <%-- right column : Size + Color panels --%>
                        <div class="col-span-4 grid grid-cols-2 gap-3">

                            <%-- Size panel --%>
                            <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400 flex flex-col">
                                <div class="flex flex-col gap-1.5 mb-2">
                                    <asp:LinkButton ID="btnSelectSize" runat="server" OnClick="btnSelectSize_Click" CssClass="flex items-center justify-center gap-1.5 rounded border border-[#255C8C] bg-[#EEF4FB] text-[#255C8C] px-2 py-1 text-sm font-medium no-underline">
                                        <i class="fa-solid fa-plus"></i>
                                        <span>Select Size</span>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnSizeEntry" runat="server" OnClick="btnSizeEntry_Click" CssClass="flex items-center justify-center gap-1.5 rounded border border-gray-300 bg-white text-gray-700 px-2 py-1 text-sm font-medium no-underline">
                                        <i class="fa-solid fa-plus"></i>
                                        <span>Size Entry</span>
                                    </asp:LinkButton>
                                </div>
                                <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 overflow-y-auto overflow-x-auto" style="min-height:220px;">
                                    <asp:GridView ID="gvStyleSizes" runat="server" EmptyDataText='No sizes added. Click "Select Size" to add.'></asp:GridView>
                                </div>
                            </div>

                            <%-- Color panel --%>
                            <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400 flex flex-col">
                                <div class="flex flex-col gap-1.5 mb-2">
                                    <asp:LinkButton ID="btnSelectColor" runat="server" OnClick="btnSelectColor_Click" CssClass="flex items-center justify-center gap-1.5 rounded border border-[#255C8C] bg-[#EEF4FB] text-[#255C8C] px-2 py-1 text-sm font-medium no-underline">
                                        <i class="fa-solid fa-plus"></i>
                                        <span>Select Color</span>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnColorEntry" runat="server" OnClick="btnColorEntry_Click" CssClass="flex items-center justify-center gap-1.5 rounded border border-gray-300 bg-white text-gray-700 px-2 py-1 text-sm font-medium no-underline">
                                        <i class="fa-solid fa-plus"></i>
                                        <span>Color Entry</span>
                                    </asp:LinkButton>
                                </div>
                                <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 overflow-y-auto overflow-x-auto" style="min-height:220px;">
                                    <asp:GridView ID="gvStyleColors" runat="server" EmptyDataText='No colors added. Click "Select Color" to add.'></asp:GridView>
                                </div>
                            </div>

                        </div>

                    </div>
                </div>
            </asp:Panel>

            <%-- ============================================================ --%>
            <%-- PANEL 3 : Purchase Order container (PO Master / PO Details / File Upload tabs) --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlPOContainer" runat="server" Visible="false">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] transition-all duration-200 px-2 py-1 rounded cursor-pointer">
                        <i class="fa-solid fa-arrow-left text-gray-500"></i>
                        <asp:LinkButton ID="btnBackToStyleDetailsFromPO" runat="server" OnClick="btnBackToStyleDetailsFromPO_Click">Back To Style Details</asp:LinkButton>
                    </div>
                    <p class="text-white text-lg font-medium">Purchase Order</p>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- tabs --%>
                    <div class="flex gap-1 border-b border-gray-300 mb-3">
                        <asp:LinkButton ID="btnTabPOMaster" runat="server" OnClick="btnTabPOMaster_Click" CssClass="px-4 py-2 text-sm font-medium no-underline rounded-t">PO Master</asp:LinkButton>
                        <asp:LinkButton ID="btnTabPODetails" runat="server" OnClick="btnTabPODetails_Click" CssClass="px-4 py-2 text-sm font-medium no-underline rounded-t">PO Details</asp:LinkButton>
                        <asp:LinkButton ID="btnTabFileUpload" runat="server" OnClick="btnTabFileUpload_Click" CssClass="px-4 py-2 text-sm font-medium no-underline rounded-t">File Upload</asp:LinkButton>
                    </div>

                    <%-- ============ PO MASTER TAB ============ --%>
                    <asp:Panel ID="pnlPOMaster" runat="server">
                        <div class="grid grid-cols-12 gap-3">

                            <div class="col-span-8 bg-[#FBFCFE] p-3 rounded border border-gray-400">
                                <div class="grid grid-cols-2 gap-x-3 gap-y-2">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Factory (Com)*</label>
                                        <asp:DropDownList ID="ddlFactoryMaster" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select factory--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">PO Receive Date</label>
                                        <asp:TextBox ID="txtPOReceiveDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Buyer*</label>
                                        <asp:DropDownList ID="ddlBuyerMaster" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select buyer--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Team Leader</label>
                                        <asp:DropDownList ID="ddlTeamLeader" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Buyer Brand</label>
                                        <asp:DropDownList ID="ddlBuyerBrand" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select buyer brand--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Dealing Merchant</label>
                                        <asp:DropDownList ID="ddlDealingMerchant" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Buying Agent</label>
                                        <asp:DropDownList ID="ddlBuyingAgentMaster" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select buying agent--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Follow Up Merchant</label>
                                        <asp:DropDownList ID="ddlFollowUpMerchant" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">PO No*</label>
                                        <asp:TextBox ID="txtPONoMaster" placeholder="Enter PO number manually" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Customer Order No (Auto-Synced)</label>
                                        <asp:TextBox ID="txtCustomerOrderNo" ReadOnly="true" placeholder="Auto-synced from PO No" runat="server" CssClass="w-full border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 shadow-sm"></asp:TextBox>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Season No</label>
                                        <div class="flex gap-1">
                                            <asp:DropDownList ID="ddlSeasonNoMaster" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                                <asp:ListItem Value="" Selected="True">--Select season no--</asp:ListItem>
                                            </asp:DropDownList>
                                            <asp:LinkButton ID="btnAddSeasonNo" runat="server" CssClass="flex items-center justify-center rounded bg-[#255C8C] text-white w-8 h-8 shrink-0 shadow-sm hover:bg-[#1a4569] no-underline">
                                                <i class="fa-solid fa-plus"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Currency</label>
                                        <asp:DropDownList ID="ddlCurrencyMaster" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="US Dollar" Selected="True">US Dollar</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Order Type*</label>
                                        <asp:DropDownList ID="ddlOrderType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="Retail" Selected="True">Retail</asp:ListItem>
                                            <asp:ListItem Value="Sample">Sample</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Exchange Rate (BDT)</label>
                                        <asp:TextBox ID="txtExchangeRateBDT" ReadOnly="true" Text="121.35" runat="server" CssClass="w-full border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 shadow-sm"></asp:TextBox>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Order Confirm Date</label>
                                        <asp:TextBox ID="txtOrderConfirmDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">PO Currency</label>
                                        <asp:DropDownList ID="ddlPOCurrency" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select po currency--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Payment Term</label>
                                        <asp:DropDownList ID="ddlPaymentTermMaster" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select payment term--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">PO Exchange Rate (USD)</label>
                                        <asp:TextBox ID="txtPOExchangeRateUSD" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Extra Cut Percent</label>
                                        <asp:TextBox ID="txtExtraCutPercent" Text="5" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Inco Term</label>
                                        <asp:DropDownList ID="ddlIncoTermMaster" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="FOB" Selected="True">FOB</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Shipping Mode</label>
                                        <asp:DropDownList ID="ddlShippingModeMaster" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select shipping mode--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Country</label>
                                        <asp:DropDownList ID="ddlCountryMaster" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                            <asp:ListItem Value="" Selected="True">--Select country--</asp:ListItem>
                                        </asp:DropDownList>
                                    </div>

                                    <div class="flex flex-col gap-0.5 w-full col-span-2">
                                        <label class="text-sm font-medium">Remarks</label>
                                        <asp:TextBox ID="txtRemarksMaster" TextMode="MultiLine" Rows="2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out resize-none"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                            <%-- PO Summary --%>
                            <div class="col-span-4 bg-[#FBFCFE] p-3 rounded border border-gray-400 flex flex-col">
                                <p class="text-sm font-semibold border-b border-gray-300 pb-1 mb-2">PO Summary</p>
                                <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 overflow-y-auto overflow-x-auto" style="min-height:200px;">
                                    <asp:GridView ID="gvPOSummary" runat="server" EmptyDataText="No data available."></asp:GridView>
                                </div>
                                <div class="flex flex-col gap-0.5 text-sm mt-2 border-t border-gray-300 pt-2">
                                    <div class="flex justify-between"><span>Total PO Qty:</span> <asp:Label ID="lblTotalPOQty" runat="server" Text="0"></asp:Label></div>
                                    <div class="flex justify-between"><span>Total CM:</span> <asp:Label ID="lblTotalCM" runat="server" Text="0.000000"></asp:Label></div>
                                    <div class="flex justify-between"><span>Total FOB:</span> <asp:Label ID="lblTotalFOB" runat="server" Text="0.000000"></asp:Label></div>
                                </div>
                            </div>

                        </div>
                    </asp:Panel>

                    <%-- ============ PO DETAILS TAB ============ --%>
                    <asp:Panel ID="pnlPODetails" runat="server" Visible="false">

                        <div class="flex items-center justify-between mb-3">
                            <div class="flex gap-2">
                                <asp:LinkButton ID="btnAddNewPOCombine" runat="server" OnClick="btnAddNewPOCombine_Click" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                    <i class="fa-solid fa-plus"></i>
                                    <span>Add New Purchase Order Combine</span>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnAddNewStyleFromPODetails" runat="server" OnClick="btnAddNewStyleFromPODetails_Click" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                    <i class="fa-solid fa-plus"></i>
                                    <span>Add New Style</span>
                                </asp:LinkButton>
                            </div>
                            <div class="text-sm text-[#255C8C] font-medium space-x-4">
                                <span>Buyer: <asp:Label ID="lblSelectedBuyerPODetails" runat="server" Text="Not Selected"></asp:Label></span>
                                <span>PO No: <asp:Label ID="lblSelectedPONoPODetails" runat="server" Text="Not Entered"></asp:Label></span>
                            </div>
                        </div>

                        <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400">
                            <div class="grid grid-cols-6 gap-x-3 gap-y-2">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Style No*</label>
                                    <asp:DropDownList ID="ddlStyleNoPODetails" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select style no*--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">CM/Dz</label>
                                    <asp:TextBox ID="txtCMDzPODetails" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">FOB/PC</label>
                                    <asp:TextBox ID="txtFOBPCPODetails" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">PO FOB</label>
                                    <asp:TextBox ID="txtPOFOBPODetails" Text="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Color*</label>
                                    <asp:DropDownList ID="ddlColorPODetails" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select color*--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Size*</label>
                                    <asp:DropDownList ID="ddlSizePODetails" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select size*--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Actual ETD</label>
                                    <asp:TextBox ID="txtActualETD" placeholder="Pick a date" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Asking Del Date</label>
                                    <asp:TextBox ID="txtAskingDelDate" placeholder="Pick a date" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Del Month</label>
                                    <asp:TextBox ID="txtDelMonth" placeholder="Pick a month" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex items-end">
                                    <asp:LinkButton ID="btnAddPODetailRow" runat="server" OnClick="btnAddPODetailRow_Click" CssClass="w-full flex items-center justify-center gap-1.5 rounded bg-[#255C8C] text-white px-3 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline">
                                        <i class="fa-solid fa-right-to-bracket"></i>
                                        <span>Add</span>
                                    </asp:LinkButton>
                                </div>
                                <div class="flex items-end">
                                    <asp:LinkButton ID="btnAddAllSize" runat="server" OnClick="btnAddAllSize_Click" CssClass="w-full flex items-center justify-center gap-1.5 rounded bg-[#255C8C] text-white px-3 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline">
                                        <i class="fa-solid fa-right-to-bracket"></i>
                                        <span>Add All Size</span>
                                    </asp:LinkButton>
                                </div>
                                <div class="flex items-end">
                                    <asp:LinkButton ID="btnChangeStyleRow" runat="server" CssClass="w-full flex items-center justify-center gap-1.5 rounded border border-gray-300 bg-white text-gray-700 px-3 py-1.5 shadow-sm hover:bg-gray-100 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline">
                                        <i class="fa-solid fa-rotate"></i>
                                        <span>Change Style Row</span>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>

                        <!--Gridview-->
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-80 flex-1 overflow-y-auto overflow-x-auto mt-3">
                            <asp:GridView ID="gvPODetails" runat="server"></asp:GridView>
                        </div>

                    </asp:Panel>

                    <%-- ============ FILE UPLOAD TAB ============ --%>
                    <asp:Panel ID="pnlFileUpload" runat="server" Visible="false">
                        <div class="bg-[#FBFCFE] p-3 rounded border border-gray-400">
                            <p class="text-sm font-semibold border-b border-gray-300 pb-1 mb-3">File Upload</p>

                            <div class="flex items-center gap-2 mb-3">
                                <asp:LinkButton ID="btnUploadPDF" runat="server" OnClick="btnUploadPDF_Click" CssClass="flex items-center gap-1.5 rounded border border-gray-300 bg-white text-gray-700 px-3 py-1.5 shadow-sm hover:bg-gray-100 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline">
                                    <i class="fa-solid fa-file-arrow-up"></i>
                                    <span>Upload PDF</span>
                                    <i class="fa-solid fa-chevron-down text-xs"></i>
                                </asp:LinkButton>
                                <asp:FileUpload ID="fuPO" runat="server" CssClass="hidden" />
                            </div>

                            <div class="border border-gray-400 bg-gray-300 rounded w-full h-48 overflow-y-auto overflow-x-auto">
                                <asp:GridView ID="gvUploadedPDFs" runat="server" EmptyDataText="No PDFs uploaded yet"></asp:GridView>
                            </div>
                        </div>
                    </asp:Panel>

                </div>
            </asp:Panel>

            <%-- ============================================================ --%>
            <%-- PANEL 4 : Purchase Order Combine --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlPOCombine" runat="server" Visible="false">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] transition-all duration-200 px-2 py-1 rounded cursor-pointer">
                        <i class="fa-solid fa-arrow-left text-gray-500"></i>
                        <asp:LinkButton ID="btnBackToPODetails" runat="server" OnClick="btnBackToPODetails_Click">Back To PO Details</asp:LinkButton>
                    </div>
                    <div class="space-x-2">
                        <asp:LinkButton ID="btnAddNewPurchaseOrderFromCombine" runat="server" OnClick="btnAddNewPurchaseOrderFromCombine_Click" CssClass="inline-flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-plus"></i>
                            <span>Add New Purchase Order</span>
                        </asp:LinkButton>
                        <asp:LinkButton ID="btnSaveCombine" runat="server" OnClick="btnSaveCombine_Click" CssClass="inline-flex items-center gap-1.5 rounded bg-white text-[#255C8C] px-4 py-1.5 shadow-sm hover:bg-gray-100 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-save"></i>
                            <span>Save</span>
                        </asp:LinkButton>
                    </div>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <div class="bg-[#FBFCFE] p-3 rounded border border-gray-400">
                        <p class="text-sm font-semibold border-b border-gray-300 pb-1 mb-2">Purchase Order Combine</p>
                        <div class="grid grid-cols-4 gap-x-3 gap-y-2">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Factory (Com)*</label>
                                <asp:DropDownList ID="ddlFactoryCombine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="Pantex Dress Ltd." Selected="True">Pantex Dress Ltd.</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Buyer*</label>
                                <asp:DropDownList ID="ddlBuyerCombine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select buyer*--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Season*</label>
                                <asp:DropDownList ID="ddlSeasonCombine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select season*--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Style No.*</label>
                                <asp:DropDownList ID="ddlStyleNoCombine" runat="server" Enabled="false" CssClass="w-full border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 shadow-sm">
                                    <asp:ListItem Value="" Selected="True">--Select style no.*--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Job No. (Auto-Generated)</label>
                                <asp:TextBox ID="txtJobNo" ReadOnly="true" Text="PDL-26-000035" runat="server" CssClass="w-full border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 shadow-sm"></asp:TextBox>
                                <span class="text-xs text-gray-500">Format: Factory Prefix-Year Prefix-000001</span>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Ship Date</label>
                                <asp:TextBox ID="txtShipDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Placement Month</label>
                                <asp:TextBox ID="txtPlacementMonth" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Brand</label>
                                <asp:DropDownList ID="ddlBrandCombine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select brand--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                    </div>

                    <%-- Detail / Summary tabs --%>
                    <div class="flex gap-1 border-b border-gray-300 mt-3 mb-3">
                        <asp:LinkButton ID="btnTabDetail" runat="server" OnClick="btnTabDetail_Click" CssClass="px-4 py-2 text-sm font-medium no-underline rounded-t">Detail</asp:LinkButton>
                        <asp:LinkButton ID="btnTabSummary" runat="server" OnClick="btnTabSummary_Click" CssClass="px-4 py-2 text-sm font-medium no-underline rounded-t">Summary</asp:LinkButton>
                    </div>

                    <asp:Panel ID="pnlCombineDetail" runat="server">
                        <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400">
                            <div class="flex items-end gap-2">
                                <div class="flex flex-col gap-0.5 w-64">
                                    <label class="text-sm font-medium">PO No</label>
                                    <asp:DropDownList ID="ddlPONoCombine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select po no...--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <asp:LinkButton ID="btnAddCombineDetailRow" runat="server" OnClick="btnAddCombineDetailRow_Click" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline">
                                    <i class="fa-solid fa-right-to-bracket"></i>
                                    <span>Add</span>
                                </asp:LinkButton>
                            </div>
                        </div>

                        <!--Gridview-->
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-80 flex-1 overflow-y-auto overflow-x-auto mt-3">
                            <asp:GridView ID="gvCombineDetail" runat="server"></asp:GridView>
                        </div>
                    </asp:Panel>

                    <asp:Panel ID="pnlCombineSummary" runat="server" Visible="false">
                        <!--Gridview-->
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-80 flex-1 overflow-y-auto overflow-x-auto">
                            <asp:GridView ID="gvCombineSummary" runat="server" EmptyDataText="No data available."></asp:GridView>
                        </div>
                    </asp:Panel>

                </div>
            </asp:Panel>

        </div>
    </form>
</body>
</html>