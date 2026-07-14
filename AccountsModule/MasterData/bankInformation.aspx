<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="bankInformation.aspx.cs" Inherits="Nexa_ERP.AccountsModule.MasterData.bankInformation" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Bank Information</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .custom-grid { width: 100%; border-collapse: collapse; }
        .custom-grid th { background-color: #f3f4f6; color: #374151; padding: 6px; text-align: left; border-bottom: 2px solid #e5e7eb; font-size: 12px; }
        .custom-grid td { padding: 6px; border-bottom: 1px solid #e5e7eb; font-size: 12px; }
        body { background-color: #f3f4f6; }
    </style>
</head>
<body class="text-sm">
    <form id="form" runat="server" class="p-2 md:p-6">
        <div class="bg-white border border-gray-200 rounded-xl shadow-xl overflow-hidden max-w-[1200px] mx-auto">
            
            <!-- Main Header -->
            <div class="bg-gradient-to-r from-slate-800 to-slate-900 text-white px-6 py-4 flex justify-between items-center">
                <h1 class="text-xl font-bold tracking-tight uppercase">Bank Management System</h1>
                <div class="flex gap-4">
                     <asp:LinkButton ID="btnShowBank" runat="server" CssClass="text-xs bg-white/10 hover:bg-white/20 px-3 py-1 rounded" OnClick="btnShowBank_Click">Bank Entry</asp:LinkButton>
                     <asp:LinkButton ID="LinkButton3" runat="server" CssClass="text-xs bg-blue-500 hover:bg-blue-600 px-3 py-1 rounded font-semibold text-white" OnClick="LinkButton3_Click">Branch Information</asp:LinkButton>
                </div>
            </div>

            <!-- PANEL 1: BANK ENTRY -->
            <asp:Panel ID="PanelBankEntry" runat="server" Visible="true">
                <div class="p-5">
                    <div class="grid grid-cols-1 xl:grid-cols-12 gap-6">
                        <!-- Left Section: Form -->
                        <div class="xl:col-span-8 space-y-4 bg-gray-50 p-6 rounded-xl border border-gray-200 shadow-sm">
                            <h2 class="text-lg font-bold text-gray-800 border-b pb-2 mb-4">Bank Entry Details</h2>
                            
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">ID</label>
                                    <asp:TextBox ID="txtdepartmentID" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg bg-gray-100 outline-none" ReadOnly="true"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Bank Code</label>
                                    <asp:TextBox ID="TextBox1" runat="server" placeholder="Enter code" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Bank Prefix</label>
                                    <asp:TextBox ID="TextBox2" runat="server" placeholder="e.g. BBL" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"></asp:TextBox>
                                </div>
                                <div class="md:col-span-2">
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Bank Name (English)</label>
                                    <asp:TextBox ID="TextBox3" runat="server" placeholder="Full English Name" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Bank Name (Bangla)</label>
                                    <asp:TextBox ID="TextBox5" runat="server" placeholder="বাংলা নাম" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"></asp:TextBox>
                                </div>
                                <div>
                                    <asp:LinkButton ID="LinkButton1" class="block text-xs font-bold text-blue-600 mb-1" runat="server" OnClick="LinkButton1_Click">Country</asp:LinkButton>
                                    <asp:DropDownList ID="DropDownList1" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg bg-white focus:ring-2 focus:ring-blue-500 outline-none">
                                        <asp:ListItem Text="Select Country" Value=""></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Swift Code</label>
                                    <asp:TextBox ID="TextBox7" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Call Center No</label>
                                    <asp:TextBox ID="TextBox8" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">IBM No</label>
                                    <asp:TextBox ID="TextBox9" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"></asp:TextBox>
                                </div>

                                <div class="md:col-span-3">
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Web URL</label>
                                    <asp:TextBox ID="TextBox10" runat="server" placeholder="https://..." CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"></asp:TextBox>
                                </div>
                            </div>

                            <!-- Status Checkboxes -->
                            <div class="flex flex-wrap gap-6 p-4 bg-white rounded-lg border border-gray-200 shadow-sm">
                                <label class="flex items-center space-x-2 cursor-pointer group">
                                    <asp:CheckBox ID="CheckBox1" runat="server" class="w-4 h-4 text-blue-600" Checked="True"/>
                                    <span class="text-xs font-semibold text-gray-700 group-hover:text-blue-600">Available</span>
                                </label>
                                <label class="flex items-center space-x-2 cursor-pointer group">
                                    <asp:CheckBox ID="CheckBox2" runat="server" class="w-4 h-4 text-blue-600" Checked="True"/>
                                    <span class="text-xs font-semibold text-gray-700 group-hover:text-blue-600">Is Local</span>
                                </label>
                                <label class="flex items-center space-x-2 cursor-pointer group">
                                    <asp:CheckBox ID="CheckBox3" runat="server" class="w-4 h-4 text-blue-600" Checked="True"/>
                                    <span class="text-xs font-semibold text-gray-700 group-hover:text-blue-600">Is Treasury</span>
                                </label>
                            </div>
                        </div>

                        <!-- Right Section: List -->
                        <div class="xl:col-span-4 border border-gray-200 rounded-xl bg-white p-4 shadow-sm">
                            <h2 class="text-md font-bold text-gray-700 border-b pb-2 mb-4 uppercase tracking-wider">Bank List</h2>
                            <div class="overflow-y-auto max-h-[450px]">
                                <asp:GridView ID="GridViewBankList" runat="server" CssClass="custom-grid"
                                    AutoGenerateColumns="False" DataKeyNames="BankEntryID" OnSelectedIndexChanged="GridViewBankList_SelectedIndexChanged">
                                    <Columns>
                                        <asp:CommandField ShowSelectButton="True" SelectText="View" ControlStyle-CssClass="text-blue-600 font-bold" />
                                        <asp:BoundField DataField="BankEntryID" HeaderText="ID" />
                                        <asp:BoundField DataField="BankNameEn" HeaderText="Bank Name" />
                                        <asp:CheckBoxField DataField="IsActive" HeaderText="St" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="flex flex-wrap justify-end gap-3 mt-6 pt-4 border-t border-gray-100">
                        <asp:Button ID="btnsave" runat="server" Text="Save Bank" CssClass="px-8 bg-blue-600 hover:bg-blue-700 text-white font-bold h-10 rounded-lg shadow-md transition transform active:scale-95 cursor-pointer" OnClick="btnsave_Click"/>
                        <asp:Button ID="btnupdate" runat="server" Text="Update" CssClass="px-8 bg-amber-500 hover:bg-amber-600 text-white font-bold h-10 rounded-lg shadow-md transition transform active:scale-95 cursor-pointer" OnClick="btnupdate_Click"/>
                        <asp:Button ID="Button2" runat="server" Text="Clear" CssClass="px-8 bg-gray-500 hover:bg-gray-600 text-white font-bold h-10 rounded-lg shadow-md cursor-pointer" OnClick="Button2_Click"/>
                        <asp:Button ID="Button3" runat="server" Text="Delete" CssClass="px-8 bg-red-500 hover:bg-red-600 text-white font-bold h-10 rounded-lg shadow-md cursor-pointer" OnClick="Button3_Click"/>
                    </div>
                </div>
            </asp:Panel>

            <!-- PANEL 2: BRANCH INFORMATION -->
            <asp:Panel ID="PanelBranchInfo" runat="server" Visible="false">
                <div class="p-5">
                    <div class="grid grid-cols-1 xl:grid-cols-12 gap-6">
                        <!-- Left Section: Branch Form -->
                        <div class="xl:col-span-8 space-y-4 bg-indigo-50 p-6 rounded-xl border border-indigo-100 shadow-sm">
                            <div class="flex justify-between items-center border-b border-indigo-200 pb-3 mb-4">
                                <h2 class="text-lg font-bold text-indigo-900">Branch Entry Details</h2>
                                <div class="flex items-center gap-2">
                                    <span class="text-xs font-bold text-indigo-600 uppercase">Bank ID:</span>
                                    <asp:TextBox ID="txtYourBranchID" runat="server" CssClass="w-24 h-8 px-2 border border-indigo-300 rounded font-bold text-center bg-white" ReadOnly="true"></asp:TextBox>
                                </div>
                            </div>

                            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Branch ID</label>
                                    <asp:TextBox ID="txtID" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none" ReadOnly="True"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Branch Code</label>
                                    <asp:TextBox ID="txtBranchCode" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Swift Code</label>
                                    <div class="flex gap-1">
                                        <asp:TextBox ID="txtSwift" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"></asp:TextBox>
                                        <asp:TextBox ID="txtExt" runat="server" placeholder="Ext" CssClass="w-16 h-10 px-1 border border-gray-300 rounded-lg text-center focus:ring-2 focus:ring-indigo-500 outline-none"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="md:col-span-2">
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Branch Name (EN)</label>
                                    <asp:TextBox ID="txtBranchName" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Routing Number</label>
                                    <asp:TextBox ID="txtRouting" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"></asp:TextBox>
                                </div>
                                <div class="md:col-span-3">
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Address (Full)</label>
                                    <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="1" CssClass="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Phone / Ext</label>
                                    <div class="flex gap-1">
                                        <asp:TextBox ID="txtPhone" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"></asp:TextBox>
                                        <asp:TextBox ID="txtPhoneExt" runat="server" placeholder="Ext" CssClass="w-16 h-10 px-1 border border-gray-300 rounded-lg text-center focus:ring-2 focus:ring-indigo-500 outline-none"></asp:TextBox>
                                    </div>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Fax Number</label>
                                    <asp:TextBox ID="txtFax" runat="server" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-bold text-gray-600 mb-1">Web URL</label>
                                    <asp:TextBox ID="txtWeb" runat="server" placeholder="https://..." CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 outline-none"></asp:TextBox>
                                </div>
                            </div>

                            <div class="flex flex-wrap gap-6 p-4 bg-white rounded-lg border border-indigo-100 shadow-sm">
                                <label class="flex items-center space-x-2 cursor-pointer">
                                    <asp:CheckBox ID="chkCorpL" runat="server" class="w-4 h-4 text-indigo-600" />
                                    <span class="text-xs font-bold text-gray-700">Corporate Local</span>
                                </label>
                                <label class="flex items-center space-x-2 cursor-pointer">
                                    <asp:CheckBox ID="chkCorpF" runat="server" class="w-4 h-4 text-indigo-600" />
                                    <span class="text-xs font-bold text-gray-700">Corporate Foreign</span>
                                </label>
                                <label class="flex items-center space-x-2 cursor-pointer">
                                    <asp:CheckBox ID="chkActive" runat="server" class="w-4 h-4 text-green-600" Checked="true" />
                                    <span class="text-xs font-bold text-gray-700">Active Status</span>
                                </label>
                            </div>
                        </div>

                        <!-- Right Section: Branch Selector -->
                        <div class="xl:col-span-4 border border-gray-200 rounded-xl bg-white p-4 shadow-sm flex flex-col">
                            <h2 class="text-md font-bold text-gray-700 border-b pb-2 mb-4 uppercase">Existing Branches</h2>
                            <div class="overflow-y-auto max-h-[450px]">
                                <asp:GridView ID="GridViewBranchInfo" runat="server" CssClass="custom-grid"
                                    AutoGenerateColumns="False" DataKeyNames="BranchID" OnSelectedIndexChanged="GridViewBankList_SelectedIndexChanged">
                                    <Columns>
                                        <asp:CommandField ShowSelectButton="True" SelectText="View" ControlStyle-CssClass="text-blue-600 font-bold" />
                                        <asp:BoundField DataField="BranchID" HeaderText="ID" />
                                        <asp:BoundField DataField="BranchName" HeaderText="Branch Name" />
                                        <asp:CheckBoxField DataField="IsActive" HeaderText="St" />
                                    </Columns>
                                </asp:GridView>
                            </div>
                        </div>
                    </div>

                    <!-- Branch Actions -->
                    <div class="flex flex-wrap justify-end gap-3 mt-6 pt-4 border-t border-gray-100">
                        <asp:Button ID="Button1" runat="server" Text="Save Branch" CssClass="px-8 bg-blue-600 hover:bg-blue-700 text-white font-bold h-10 rounded-lg shadow-md cursor-pointer" OnClick="btnsave_Click"/>
                        <asp:Button ID="Button4" runat="server" Text="Update" CssClass="px-8 bg-amber-500 hover:bg-amber-600 text-white font-bold h-10 rounded-lg shadow-md cursor-pointer" OnClick="btnupdate_Click"/>
                        <asp:Button ID="Button5" runat="server" Text="Clear All" CssClass="px-8 bg-gray-500 hover:bg-gray-600 text-white font-bold h-10 rounded-lg shadow-md cursor-pointer" OnClick="Button2_Click"/>
                        <asp:Button ID="Button6" runat="server" Text="Delete" CssClass="px-8 bg-red-500 hover:bg-red-600 text-white font-bold h-10 rounded-lg shadow-md cursor-pointer" OnClick="Button3_Click"/>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </form>
</body>
</html>