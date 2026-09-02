<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PaymentConfiguration.aspx.cs" Inherits="Nexa_ERP.MasterConfiguration.CommercialMaster.PaymentConfiguration" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Payment Configuration - Nexa ERP</title>

    <!-- Tailwind CSS Link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Font Awesome Icon Link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />
</head>
<body class="min-h-screen p-2 mt-2 bg-[#f8f9fa]">

    <form id="form1" runat="server" class="max-w-[1320px] w-full m-auto rounded-lg border bg-white shadow-xl">

        <!-- View toggle functions defined here (top of form) so they exist
             before any server-injected startup script (e.g. after Edit/Update/Delete postback) calls them -->
        <script>
            function showFormView() {
                document.getElementById('listView').classList.add('hidden');
                document.getElementById('formView').classList.remove('hidden');
            }

            function showListView() {
                document.getElementById('formView').classList.add('hidden');
                document.getElementById('listView').classList.remove('hidden');
            }
        </script>

        <%-- =========================================================
             LIST VIEW (shown first)
        ========================================================== --%>
        <div id="listView" class="block">

            <!-- List Header -->
            <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                <div class="text-white">
                    <p class="text-xl mb-1 font-medium">Payment Term List</p>
                </div>
                <div>
                    <span class="bg-indigo-600 text-white text-xs px-2.5 py-1 rounded font-medium">Nexa ERP System</span>
                </div>
            </div>

            <div class="p-4 bg-white rounded-b-lg">

                <div class="flex justify-end mb-3">
                    <asp:LinkButton ID="btnAddNew" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#16A34A] text-white px-4 py-1.5 shadow-sm hover:bg-[#15803D] transition duration-200 font-medium text-sm no-underline" OnClick="btnAddNew_Click">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span>Add New</span>
                    </asp:LinkButton>
                </div>

                <div class="border border-gray-400 bg-gray-300 rounded w-full overflow-x-auto p-2">
                    <%-- TODO: bind this GridView from code-behind (e.g. gvPaymentTermList_Bind()) to list saved payment terms --%>
                    <asp:GridView ID="gvPaymentTermList" runat="server" CssClass="w-full border-collapse bg-white text-left text-sm" AutoGenerateColumns="false" GridLines="None"
                        HeaderStyle-CssClass="bg-gray-100 text-gray-700" RowStyle-CssClass="border-b border-gray-300" OnRowCommand="gvPaymentTermList_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="TermName" HeaderText="Term Name" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" />
                            <asp:BoundField DataField="DueDay" HeaderText="Due Day" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" />
                            <asp:TemplateField HeaderText="Action" ItemStyle-CssClass="p-2 border border-gray-300 text-center" HeaderStyle-CssClass="p-2 border border-gray-300 text-center">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" CssClass="bg-[#255C8C] hover:bg-[#1d4a70] text-white px-2 py-1 rounded text-xs" CommandName="EditPaymentTerm" CommandArgument='<%# Eval("TermId") %>'>
                                        <i class="fa-solid fa-pen"></i>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="p-4 text-center text-gray-500 text-sm">No records found.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
        </div>

        <%-- =========================================================
             FORM VIEW (hidden until "Add New" is clicked)
        ========================================================== --%>
        <div id="formView" class="hidden">

        <!-- Form Header -->
        <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
            <div class="text-white">
                <p class="text-xl mb-1 font-medium">Payment Parameter Setup</p>
            </div>
            <div>
                <span class="bg-indigo-600 text-white text-xs px-2.5 py-1 rounded font-medium">Nexa ERP System</span>
            </div>
        </div>

        <div class="p-4 bg-[#ffffff] rounded-b-lg">

            <!-- General Info -->
            <div class="bg-[#FBFCFE] w-full">
                <fieldset class="grid grid-cols-12 gap-x-3 gap-y-2 border border-gray-400 rounded p-3 mb-6">
                    <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Term Information</legend>

                    <div class="col-span-12">
                        <div class="grid grid-cols-2 gap-x-3 gap-y-2 w-full">

                            <!-- Term Name -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="txtTermName" class="text-sm font-medium">Term Name *</label>
                                <asp:TextBox ID="txtTermName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out" required="true"></asp:TextBox>
                            </div>

                            <!-- Due Day -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="txtDueDay" class="text-sm font-medium">Due Day *</label>
                                <asp:TextBox ID="txtDueDay" runat="server" TextMode="Number" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out" required="true"></asp:TextBox>
                            </div>

                        </div>
                    </div>
                </fieldset>
            </div>

            <!-- Action Buttons -->
            <div class="flex justify-end gap-3 border-t pt-4">
                <button type="button" id="btnBackToList" class="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 transition duration-200 font-medium text-sm" onclick="showListView()">
                    <i class="fa-solid fa-arrow-left text-xs"></i>
                    <span>Back To List</span>
                </button>
                <asp:LinkButton ID="btnClear" runat="server" CssClass="flex items-center gap-1.5 rounded bg-gray-400 text-white px-4 py-1.5 shadow-sm hover:bg-gray-500 transition duration-200 font-medium text-sm no-underline" OnClientClick="return confirm('Clear all fields?');" OnClick="btnClear_Click">
                    <i class="fa-solid fa-broom text-xs"></i>
                    <span>Clear</span>
                </asp:LinkButton>
                <asp:LinkButton ID="btnDelete" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#DC2626] text-white px-4 py-1.5 shadow-sm hover:bg-[#B91C1C] transition duration-200 font-medium text-sm no-underline" OnClientClick="return confirm('Delete this payment term?');" OnClick="btnDelete_Click">
                    <i class="fa-solid fa-xmark text-xs"></i>
                    <span>Delete</span>
                </asp:LinkButton>
                <asp:LinkButton ID="btnUpdate" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] transition duration-200 font-medium text-sm no-underline" OnClick="btnUpdate_Click">
                    <i class="fa-solid fa-save text-xs"></i>
                    <span>Save</span>
                </asp:LinkButton>
            </div>

        </div>
        </div>
        <%-- end formView --%>

    </form>

</body>
</html>
