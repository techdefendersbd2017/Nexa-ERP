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
            <asp:HiddenField ID="hfBuyerId" runat="server" Value="0" />

            <%-- LIST PANEL --%>
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
                                <asp:TextBox ID="txtSearchBuyer" placeholder="Search by buyer code / name / country / contact person..." runat="server" AutoPostBack="true" OnTextChanged="txtSearchBuyer_TextChanged" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-56 shrink-0">
                                <label class="text-sm font-medium">Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">All</asp:ListItem>
                                    <asp:ListItem Value="1">Active</asp:ListItem>
                                    <asp:ListItem Value="0">Inactive</asp:ListItem>
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
                        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="false" DataKeyNames="BuyerID"
                            OnRowCommand="GridView1_RowCommand"
                            CssClass="w-full text-sm bg-white border-collapse"
                            HeaderStyle-CssClass="bg-[#255C8C] text-white text-left sticky top-0"
                            RowStyle-CssClass="border-b border-gray-200 hover:bg-gray-50"
                            AlternatingRowStyle-CssClass="bg-[#FBFCFE] border-b border-gray-200 hover:bg-gray-50"
                            EmptyDataText="No buyer found." EmptyDataRowStyle-CssClass="p-3 text-center text-gray-500">
                            <Columns>
                                <asp:TemplateField HeaderText="SL" ItemStyle-CssClass="px-2 py-1 w-12" HeaderStyle-CssClass="px-2 py-1">
                                    <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="BuyerCode" HeaderText="Buyer Code" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2 py-1" />
                                <asp:BoundField DataField="BuyerName" HeaderText="Buyer Name" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2 py-1" />
                                <asp:BoundField DataField="Country" HeaderText="Country" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2 py-1" />
                                <asp:BoundField DataField="ContactPerson" HeaderText="Contact Person" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2 py-1" />
                                <asp:BoundField DataField="ContactPhone" HeaderText="Phone" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2 py-1" />
                                <asp:BoundField DataField="ContactEmail" HeaderText="Email" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2 py-1" />
                                <asp:BoundField DataField="StatusName" HeaderText="Status" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2 py-1" />
                                <asp:TemplateField HeaderText="Action" ItemStyle-CssClass="px-2 py-1 whitespace-nowrap" HeaderStyle-CssClass="px-2 py-1">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditBuyer" CommandArgument='<%# Eval("BuyerID") %>' CssClass="text-[#255C8C] hover:underline mr-3 no-underline">
                                            <i class="fa-solid fa-pen-to-square"></i> Edit
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteBuyer" CommandArgument='<%# Eval("BuyerID") %>' OnClientClick="return confirm('Are you sure you want to delete this buyer?');" CssClass="text-red-600 hover:underline no-underline">
                                            <i class="fa-solid fa-trash"></i> Delete
                                        </asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                </div>
            </asp:Panel>

            <%-- ENTRY PANEL --%>
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
                                <asp:TextBox ID="txtBuyerCode" placeholder="Buyer Code" MaxLength="50" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Buyer Name<span class="text-red-500">*</span></label>
                                <asp:TextBox ID="txtBuyerName" placeholder="Buyer Name" MaxLength="200" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Country</label>
                                <asp:TextBox ID="txtCountry" placeholder="Country" MaxLength="100" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Contact Person</label>
                                <asp:TextBox ID="txtContactPerson" placeholder="Contact Person" MaxLength="150" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Contact Phone</label>
                                <asp:TextBox ID="txtContactPhone" placeholder="Contact Phone" MaxLength="50" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Contact Email</label>
                                <asp:TextBox ID="txtContactEmail" placeholder="Contact Email" MaxLength="150" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="flex items-center gap-6 pt-1">
                                <div class="flex items-center gap-1.5">
                                    <asp:CheckBox ID="chkIsActive" runat="server" Text="Is Active" Checked="true" CssClass="text-sm" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- footer buttons : Clear + Save --%>
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