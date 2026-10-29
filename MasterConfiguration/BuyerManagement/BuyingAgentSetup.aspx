<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BuyingAgentSetup.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.BasicSetup.BuyingAgentSetup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Buying Agent</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <asp:HiddenField ID="hfUserId" runat="server" />
            <asp:HiddenField ID="hfBuyingAgentId" runat="server" Value="0" />

            <%-- ============================================================ --%>
            <%-- LIST PANEL : Buying Agent List (opens first, always) --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlList" runat="server">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Buying Agent List</p>
                    </div>
                    <asp:LinkButton ID="btnAddNew" runat="server" OnClick="btnAddNew_Click" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                        <i class="fa-solid fa-plus"></i>
                        <span>Add Buying Agent</span>
                    </asp:LinkButton>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- search box --%>
                    <div class="flex items-center gap-2 mb-3">
                        <div class="flex flex-col gap-0.5 w-72">
                            <label class="text-sm font-medium">Search</label>
                            <asp:TextBox ID="txtSearch" placeholder="Search by code, name or country..." runat="server" AutoPostBack="true" OnTextChanged="txtSearch_TextChanged" CssClass="w-full border rounded outline-none border-gray-300 px-3 py-1.5 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="w-max pt-5">
                            <asp:LinkButton ID="btnClearFilter" runat="server" OnClick="btnClearFilter_Click" CssClass="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-eraser"></i> <span>Clear</span>
                            </asp:LinkButton>
                        </div>
                    </div>

                    <!--Gridview-->
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-96 flex-1 overflow-y-auto overflow-x-auto">
                        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="false" DataKeyNames="AgentID"
                            CssClass="w-full text-sm bg-white" OnRowCommand="GridView1_RowCommand"
                            HeaderStyle-CssClass="bg-[#255C8C] text-white text-left" HeaderStyle-Height="32px"
                            RowStyle-CssClass="border-b hover:bg-gray-50" EmptyDataText="No buying agent found.">
                            <Columns>
                                <asp:TemplateField HeaderText="SL" ItemStyle-CssClass="px-2 py-1 w-12" HeaderStyle-CssClass="px-2">
                                    <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="AgentCode" HeaderText="Code" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:BoundField DataField="AgentName" HeaderText="Name" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:BoundField DataField="Country" HeaderText="Country" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:BoundField DataField="ContactPerson" HeaderText="Contact Person" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:BoundField DataField="ContactEmail" HeaderText="Contact Email" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="px-2 py-1 w-24" HeaderStyle-CssClass="px-2">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "text-green-700 bg-green-100" : "text-red-700 bg-red-100" %> px-2 py-0.5 rounded text-xs font-medium'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action" ItemStyle-CssClass="px-2 py-1 w-28" HeaderStyle-CssClass="px-2">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditRow" CommandArgument='<%# Eval("AgentID") %>' CssClass="text-blue-600 hover:text-blue-800 mr-3" ToolTip="Edit"><i class="fa-solid fa-pen-to-square"></i></asp:LinkButton>
                                        <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteRow" CommandArgument='<%# Eval("AgentID") %>' CssClass="text-red-600 hover:text-red-800" ToolTip="Delete" OnClientClick="return confirm('Are you sure you want to delete this buying agent?');"><i class="fa-solid fa-trash"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                </div>
            </asp:Panel>

            <%-- ============================================================ --%>
            <%-- ENTRY PANEL : Buying Agent Info --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlEntry" runat="server" Visible="false">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Buying Agent Entry</p>
                    </div>
                    <div class="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] transition-all duration-200 px-2 py-1 rounded cursor-pointer">
                        <div class="cursor-pointer hover:bg-[#f1f5f9] transition-all duration-200">
                            <i class="fa-solid fa-arrow-left text-gray-500 flex justify-center items-center"></i>
                        </div>
                        <asp:LinkButton ID="btnBackToList" runat="server" OnClick="btnBackToList_Click">Back To List</asp:LinkButton>
                    </div>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- Buying Agent Info --%>
                    <div class="bg-[#FBFCFE] p-3 rounded border border-gray-400">
                        <p class="text-sm font-semibold border-b border-gray-300 pb-1 mb-2">Buying Agent Info</p>
                        <div class="grid grid-cols-2 gap-3">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Agent Code</label>
                                <asp:TextBox ID="txtCode" placeholder="Agent Code" MaxLength="50" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Agent Name</label>
                                <asp:TextBox ID="txtName" placeholder="Agent Name" MaxLength="200" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
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
                                <label class="text-sm font-medium">Contact Email</label>
                                <asp:TextBox ID="txtContactEmail" placeholder="Contact Email" MaxLength="150" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex items-end pb-1">
                                <asp:CheckBox ID="chkIsActive" runat="server" Text="Is Active" Checked="true" CssClass="text-sm font-medium" />
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
