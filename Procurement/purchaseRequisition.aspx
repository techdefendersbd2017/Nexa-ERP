<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="purchaseRequisition.aspx.cs" Inherits="Nexa_ERP.Procurement.purchaseRequisition" %>



<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Purchase Requisition</title>
    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />


</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                <div class="text-white">
                    <p class="text-xl mb-1 font-medium">Purchase Requisition</p>

                </div>
                <asp:LinkButton ID="lnkBackToList" runat="server" PostBackUrl="~/eSTrimCode/purchaseRequisitionList.aspx" CssClass="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] text-gray-700 transition-all duration-200 px-3 py-2 rounded cursor-pointer no-underline font-medium text-sm">
                    <i class="fa-solid fa-arrow-left text-gray-500"></i>
                    <span>Back To List</span>
                </asp:LinkButton>

            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="bg-[#FBFCFE] w-full">

                    <%-- left container --%>
                    <fieldset class="grid grid-cols-12 gap-x-3 gap-y-2 border border-gray-400 rounded p-2">
                        <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Master Information</legend>

                        <div class="col-span-12 flex flex-col">

                            <div class="grid grid-cols-3 gap-x-3 gap-y-2 w-full">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Company</label>
                                    <asp:DropDownList ID="ddlCompany" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Company--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Requisition Type</label>
                                    <asp:TextBox ID="txtRequisitionType" placeholder="e.g Requisition Type" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Requisition No</label>
                                    <asp:TextBox ID="txtRequisionNo" placeholder="e.g Requisition No" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition  duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Requisition Date</label>
                                    <asp:DropDownList ID="ddlRequisitionDate" placeholder="e.g Requisition Type" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Req. Date--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Purchase Type</label>
                                    <asp:TextBox ID="txtPurchaseType" placeholder="e.g Purchase Type" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Receiving Store</label>
                                    <asp:TextBox ID="txtReceivingStore" placeholder="e.g Receiving Store" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Priority Type</label>
                                    <asp:TextBox ID="txtPriorityType" placeholder="e.g Priority Type" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Requisition By</label>
                                    <asp:TextBox ID="txtRequisionBy" placeholder="e.g Requisition By" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition  duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex gap-1 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Currency</label>
                                        <asp:TextBox ID="txtCurrency" placeholder="e.g Currency" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>

                                    </div>
                                    <asp:TextBox ID="txtconvRate" placeholder="Conv. Rate" ReadOnly="true" runat="server" CssClass="w-[85px] border rounded outline-none border-gray-300 p-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Remarks</label>
                                    <asp:TextBox ID="txtRemarks1" placeholder="e.g Remarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>

                                <%-- ========  Grid ======== --%>

                                <div class="col-span-2">
                                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-full  overflow-y-auto overflow-x-auto pt-6">
                                        <asp:GridView ID="GridView22" runat="server"></asp:GridView>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </fieldset>

                </div>

                <%-- ========== Requisition Details ============ --%>

                <fieldset class="border border-gray-400 rounded p-2 mt-6">
                    <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Requisition Details</legend>

                    <div class="grid grid-cols-4 gap-x-3 gap-y-2">

                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Item Name</label>
                            <asp:TextBox ID="txtItemName" placeholder="e.g Item Name" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Req. Qty</label>
                            <asp:TextBox ID="txtRequisitionQty" placeholder="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Stokc Qty</label>
                            <asp:TextBox ID="txtStockQty" placeholder="0" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Unit</label>
                            <asp:TextBox ID="txtUnit" placeholder="e.g Unit" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Origin</label>
                            <asp:TextBox ID="txtOrigin" placeholder="e.g Origin" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Item Specification</label>
                            <asp:TextBox ID="txtItemSpecification" placeholder="e.g Item Specification" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Remarks</label>
                            <asp:TextBox ID="txtRemarks" placeholder="e.g Remarks" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>

                        <div class="flex gap-3 items-end">

                            <!-- Add Item Button -->
                            <asp:LinkButton ID="btnAddItem" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#16A34A] text-white px-4 py-1.5 shadow-sm hover:bg-[#15803D] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
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

                </fieldset>



                <%-- ========== Requisition Information ============ --%>

                <fieldset class="border border-gray-400 rounded p-2 mt-6">
                    <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Requisition Information</legend>

                    <div class="">
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-full  overflow-y-auto overflow-x-auto pt-6">
                            <asp:ListView ID="ListView2" runat="server"></asp:ListView>
                        </div>

                    </div>
                </fieldset>


                <!-- below btn -->
                <div class="space-x-4 flex justify-between items-center mt-6">

                    <div class="flex gap-4 items-center">
                        <!-- Create New Button  -->
                        <asp:LinkButton ID="btnCreateNew" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#16A34A] text-white px-4 py-1.5 shadow-sm hover:bg-[#15803D] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-plus"></i>
                            <span>Create New</span>
                        </asp:LinkButton>

                        <!-- Print Button -->
                        <asp:LinkButton ID="btnPrint" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1d4970] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-print"></i>
                            <span>Print</span>
                        </asp:LinkButton>

                        <!-- Cancel Button -->
                        <asp:LinkButton ID="btnCancel" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#DC2626] text-white px-4 py-1.5 shadow-sm hover:bg-[#B91C1C] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-x"></i>
                            <span>Cancel</span>
                        </asp:LinkButton>
                    </div>

                    <div class="flex gap-4 items-center">

                        <!-- Save Button -->
                        <asp:LinkButton ID="btnSave" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-save"></i>
                            <span>Save</span>
                        </asp:LinkButton>

                        <!-- Submit Button -->
                        <asp:LinkButton ID="btnSubmitted" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#4F46E5] text-white px-4 py-1.5 shadow-sm hover:bg-[#4338CA] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-paper-plane"></i>
                            <span>Submitted</span>
                        </asp:LinkButton>

                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

