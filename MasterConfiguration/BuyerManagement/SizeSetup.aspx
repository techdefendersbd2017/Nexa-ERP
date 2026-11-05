<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SizeSetup.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.BasicSetup.SizeSetup" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Size Setup</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

    <style>
        /* custom check icon for Active Status card */
        .chk-card input[type=checkbox] { display: none; }
        .chk-card .chk-icon { width: 20px; height: 20px; border-radius: 9999px; border: 2px solid #cbd5e1; background: #fff; display: flex; align-items: center; justify-content: center; color: transparent; font-size: 11px; }
        .chk-card:has(input:checked) .chk-icon { background: #2563eb; border-color: #2563eb; color: #fff; }
        .chk-card:has(input:checked) { border-color: #2563eb; background: #eff6ff; }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <asp:HiddenField ID="hfUserId" runat="server" />
            <%-- hfSizeId  =>  SizeMaster.SizeID --%>
            <asp:HiddenField ID="hfSizeId" runat="server" Value="0" />

            <%-- ============================================================ --%>
            <%-- LIST PANEL --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlList" runat="server">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Size List</p>
                    </div>
                    <asp:LinkButton ID="btnAddNew" runat="server" OnClick="btnAddNew_Click" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                        <i class="fa-solid fa-plus"></i>
                        <span>Add New Size</span>
                    </asp:LinkButton>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- filter box --%>
                    <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400">
                        <div class="grid grid-cols-3 gap-x-3 gap-y-2">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Size Code / Name / Range</label>
                                <asp:TextBox ID="txtSearch" placeholder="Search size code, name or range" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Status</label>
                                <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Text="All" Value="-1"></asp:ListItem>
                                    <asp:ListItem Text="Active" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="Inactive" Value="0"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex items-end justify-end gap-3">
                                <asp:LinkButton ID="btnClearFilter" runat="server" OnClick="btnClearFilter_Click" CssClass="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                    <i class="fa-solid fa-eraser"></i>
                                    <span>Clear</span>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnSearch" runat="server" OnClick="btnSearch_Click" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                    <i class="fa-solid fa-magnifying-glass"></i>
                                    <span>Search</span>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </div>

                    <!--Gridview (List Panel)-->
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-96 flex-1 overflow-y-auto overflow-x-auto mt-3">
                        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="false" DataKeyNames="SizeID"
                            CssClass="w-full text-sm bg-white" OnRowCommand="Grid_RowCommand"
                            HeaderStyle-CssClass="bg-[#255C8C] text-white text-left" HeaderStyle-Height="32px"
                            RowStyle-CssClass="border-b hover:bg-gray-50" EmptyDataText="No size found.">
                            <Columns>
                                <asp:TemplateField HeaderText="SL" ItemStyle-CssClass="px-2 py-1 w-12" HeaderStyle-CssClass="px-2">
                                    <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="SizeCode" HeaderText="Size Code" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:BoundField DataField="SizeName" HeaderText="Size Name" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:BoundField DataField="SizeRange" HeaderText="Size Range" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:BoundField DataField="SortOrder" HeaderText="Sort Order" ItemStyle-CssClass="px-2 py-1 w-24" HeaderStyle-CssClass="px-2" />
                                <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="px-2 py-1 w-24" HeaderStyle-CssClass="px-2">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "text-green-700 bg-green-100" : "text-red-700 bg-red-100" %> px-2 py-0.5 rounded text-xs font-medium'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action" ItemStyle-CssClass="px-2 py-1 w-28" HeaderStyle-CssClass="px-2">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditRow" CommandArgument='<%# Eval("SizeID") %>' CssClass="text-blue-600 hover:text-blue-800 mr-3" ToolTip="Edit"><i class="fa-solid fa-pen-to-square"></i></asp:LinkButton>
                                        <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteRow" CommandArgument='<%# Eval("SizeID") %>' CssClass="text-red-600 hover:text-red-800" ToolTip="Delete" OnClientClick="return confirm('Are you sure you want to delete this size?');"><i class="fa-solid fa-trash"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                </div>
            </asp:Panel>

            <%-- ============================================================ --%>
            <%-- ENTRY PANEL : Size Info --%>
            <%-- ============================================================ --%>
            <asp:Panel ID="pnlEntry" runat="server" Visible="false">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Size Setup</p>
                    </div>
                    <div class="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] transition-all duration-200 px-2 py-1 rounded cursor-pointer">
                        <div class="cursor-pointer hover:bg-[#f1f5f9] transition-all duration-200">
                            <i class="fa-solid fa-arrow-left text-gray-500 flex justify-center items-center"></i>
                        </div>
                        <asp:LinkButton ID="btnBackToList" runat="server" OnClick="btnBackToList_Click">Back To List</asp:LinkButton>
                    </div>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <div class="max-w-[640px] bg-[#F8F9FB] border border-gray-200 rounded-lg p-4">
                        <h3 class="text-base font-semibold pb-2 mb-3 border-b-2 border-gray-200">Size Info</h3>

                        <div class="flex flex-col gap-3">

                            <div class="grid grid-cols-[170px_1fr] items-center gap-2">
                                <label class="text-sm">Size Code</label>
                                <asp:TextBox ID="txtSizeCode" runat="server" placeholder="Size Code" MaxLength="50" CssClass="w-full border border-gray-400 rounded-lg bg-green-50/60 outline-none px-3 py-1.5 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="grid grid-cols-[170px_1fr] items-center gap-2">
                                <label class="text-sm">Size Name</label>
                                <asp:TextBox ID="txtSizeName" runat="server" placeholder="Size Name" MaxLength="100" CssClass="w-full border border-gray-400 rounded-lg bg-green-50/60 outline-none px-3 py-1.5 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="grid grid-cols-[170px_1fr] items-center gap-2">
                                <label class="text-sm">Size Range</label>
                                <asp:TextBox ID="txtSizeRange" runat="server" placeholder="Size Range (e.g. S-XL)" MaxLength="100" CssClass="w-full border border-gray-400 rounded-lg bg-green-50/60 outline-none px-3 py-1.5 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="grid grid-cols-[170px_1fr] items-center gap-2">
                                <label class="text-sm">Sort Order</label>
                                <asp:TextBox ID="txtSortOrder" runat="server" Text="0" TextMode="Number" placeholder="Sort Order" CssClass="w-full border border-gray-400 rounded-lg bg-green-50/60 outline-none px-3 py-1.5 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="grid grid-cols-[170px_1fr] items-start gap-2">
                                <span></span>
                                <label for="chkIsActive" class="chk-card block cursor-pointer border border-gray-400 rounded-lg px-3 py-2 bg-white transition duration-200">
                                    <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" />
                                    <span class="chk-wrap flex items-start gap-3">
                                        <span class="chk-icon mt-0.5"><i class="fa-solid fa-check"></i></span>
                                        <span>
                                            <span class="block text-sm font-medium">Active Status</span>
                                            <span class="block text-sm text-gray-500 mt-1">This item will show other pages when it checked.</span>
                                        </span>
                                    </span>
                                </label>
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

                    <%-- Gridview (Entry Panel) : Save এর পরে List এ না গিয়ে এখানেই দেখাবে --%>
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-80 flex-1 overflow-y-auto overflow-x-auto mt-4">
                        <asp:GridView ID="GridView2" runat="server" AutoGenerateColumns="false" DataKeyNames="SizeID"
                            CssClass="w-full text-sm bg-white" OnRowCommand="Grid_RowCommand"
                            HeaderStyle-CssClass="bg-[#255C8C] text-white text-left" HeaderStyle-Height="32px"
                            RowStyle-CssClass="border-b hover:bg-gray-50" EmptyDataText="No size found.">
                            <Columns>
                                <asp:TemplateField HeaderText="SL" ItemStyle-CssClass="px-2 py-1 w-12" HeaderStyle-CssClass="px-2">
                                    <ItemTemplate><%# Container.DataItemIndex + 1 %></ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="SizeCode" HeaderText="Size Code" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:BoundField DataField="SizeName" HeaderText="Size Name" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:BoundField DataField="SizeRange" HeaderText="Size Range" ItemStyle-CssClass="px-2 py-1" HeaderStyle-CssClass="px-2" />
                                <asp:BoundField DataField="SortOrder" HeaderText="Sort Order" ItemStyle-CssClass="px-2 py-1 w-24" HeaderStyle-CssClass="px-2" />
                                <asp:TemplateField HeaderText="Status" ItemStyle-CssClass="px-2 py-1 w-24" HeaderStyle-CssClass="px-2">
                                    <ItemTemplate>
                                        <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "text-green-700 bg-green-100" : "text-red-700 bg-red-100" %> px-2 py-0.5 rounded text-xs font-medium'>
                                            <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                        </span>
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderText="Action" ItemStyle-CssClass="px-2 py-1 w-28" HeaderStyle-CssClass="px-2">
                                    <ItemTemplate>
                                        <asp:LinkButton ID="lnkEdit2" runat="server" CommandName="EditRow" CommandArgument='<%# Eval("SizeID") %>' CssClass="text-blue-600 hover:text-blue-800 mr-3" ToolTip="Edit"><i class="fa-solid fa-pen-to-square"></i></asp:LinkButton>
                                        <asp:LinkButton ID="lnkDelete2" runat="server" CommandName="DeleteRow" CommandArgument='<%# Eval("SizeID") %>' CssClass="text-red-600 hover:text-red-800" ToolTip="Delete" OnClientClick="return confirm('Are you sure you want to delete this size?');"><i class="fa-solid fa-trash"></i></asp:LinkButton>
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>
                    </div>

                </div>
            </asp:Panel>

        </div>
    </form>
</body>
</html>
