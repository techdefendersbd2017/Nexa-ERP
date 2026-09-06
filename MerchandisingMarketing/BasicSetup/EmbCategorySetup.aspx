<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmbCategorySetup.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.BasicSetup.EmbCategorySetup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Emb Category</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <asp:HiddenField ID="hfUserId" runat="server" />
            <asp:HiddenField ID="hfEmbCategoryId" runat="server" />

            <%-- LIST PANEL : Emb Category List (opens first, always) --%>

            <asp:Panel ID="pnlList" runat="server">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Emb Category List</p>
                    </div>
                    <asp:LinkButton ID="btnAddNew" runat="server" OnClick="btnAddNew_Click" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                        <i class="fa-solid fa-plus"></i>
                        <span>Add Emb Category</span>
                    </asp:LinkButton>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- search box --%>
                    <div class="flex items-center gap-2 mb-3"> 
                        <div class="flex flex-col gap-0.5 w-72"> 
                            <label class="text-sm font-medium">Search</label> 
                            <asp:TextBox ID="txtSearchBuyer" placeholder="Search by buyer name..." runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-3 py-1.5 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox> 
                        </div> 
                        <div class="w-max pt-5"> 
                            <asp:LinkButton ID="btnClearFilter" runat="server" CssClass="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center"> 
                                <i class="fa-solid fa-eraser"></i> <span>Clear</span> 
                            </asp:LinkButton> 
                        </div> 
                    </div>

                    <!--Gridview-->
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-96 flex-1 overflow-y-auto overflow-x-auto">
                        <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                    </div>

                </div>
            </asp:Panel>

            <%-- ============================================================ --%>
            <%-- ENTRY PANEL : Emb Category Info --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlEntry" runat="server" Visible="false">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2 ">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Emb Category Entry</p>
                    </div>
                    <div class="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] transition-all duration-200 px-2 py-1 rounded cursor-pointer">
                        <div class="cursor-pointer hover:bg-[#f1f5f9] transition-all duration-200">
                            <i class="fa-solid fa-arrow-left text-gray-500 flex justify-center items-center"></i>
                        </div>
                        <asp:LinkButton ID="btnBackToList" runat="server" OnClick="btnBackToList_Click">Back To List</asp:LinkButton>
                    </div>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- Emb Category Info box --%>
                    <div class="flex justify-center py-2">
                        <div class="w-full max-w-md bg-[#FBFCFE] p-3 rounded border border-gray-400">
                            <p class="text-sm font-semibold border-b border-gray-300 pb-1 mb-2">Emb Category Info</p>
                            <div class="flex flex-col gap-2">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="font-medium">Embellishment Type</label>
                                    <asp:DropDownList ID="ddlEmbellishmentType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Embellishment Type--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="font-medium">Category Code</label>
                                    <asp:TextBox ID="txtCategoryCode" placeholder="Category Code" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="font-medium">Category Name</label>
                                    <asp:TextBox ID="txtCategoryName" placeholder="Category Name" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class=" font-medium">Remarks</label>
                                    <asp:TextBox ID="txtRemarks" placeholder="Remarks" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>

                                <%-- Active Status highlighted card --%>
                                <div class="flex items-start gap-2 border border-[#255C8C] bg-[#EEF4FB] rounded p-2">
                                    <asp:CheckBox ID="chkActiveStatus" runat="server" Checked="true" CssClass="mt-0.5" />
                                    <div>
                                        <label class="text-sm font-medium block">Active Status</label>
                                        <p class="text-xs text-gray-500">This item will show other pages when it checked.</p>
                                    </div>
                                </div>

                            </div>
                        </div>
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
