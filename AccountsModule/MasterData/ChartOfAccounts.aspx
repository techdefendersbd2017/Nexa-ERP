<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChartOfAccounts.aspx.cs" Inherits="Nexa_ERP.AccountsModule.MasterData.ChartOfAccounts" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Chart of Accounts</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        /* আপনার অরিজিনাল ট্রি-ভিউ স্টাইল */
        .custom-tree a { color: #1e293b; text-decoration: none; font-size: 0.95rem; }
        .custom-tree a:hover { color: #2563eb; }
        .tree-node-selected { background-color: #dbeafe !important; border-radius: 4px; padding: 2px 8px; color: #1d4ed8 !important; font-weight: 600; }
        .custom-tree table td { padding: 0; }
        
        /* কাস্টম স্ক্রলবার */
        .tree-container::-webkit-scrollbar { width: 5px; }
        .tree-container::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
    </style>
</head>
<body class="bg-gray-100 font-sans">
    <form id="form1" runat="server" class="p-2 md:p-4">
        <div class="max-w-[1600px] mx-auto bg-white border border-gray-200 rounded-2xl shadow-lg overflow-hidden">

            <!-- Header Section (আপনার অরিজিনাল Slate-800 থিম) -->
            <div class="bg-gradient-to-r from-slate-700 to-slate-800 text-white px-6 py-4 flex justify-between items-center border-b border-slate-600">
                <div>
                    <h1 class="text-xl font-bold tracking-tight">Chart of Accounts</h1>
                    <p class="text-xs opacity-80">Manage your ledger hierarchy and financial structure</p>
                </div>
                <div class="hidden md:block bg-white/10 px-3 py-1 rounded text-[10px]">System: Nexa ERP</div>
            </div>

            <!-- Main Content -->
            <div class="grid grid-cols-12 gap-0">
                
                <!-- Left Section: Accounts Tree View -->
                <div class="col-span-12 lg:col-span-5 border-r border-gray-200 bg-gray-50 flex flex-col">
                    <div class="bg-gray-100 px-4 py-3 border-b border-gray-200 flex justify-between items-center">
                        <h2 class="text-xs font-bold text-gray-700 uppercase tracking-wider">Account Type List</h2>
                        <div class="flex gap-1">
                            <asp:LinkButton ID="btnExpand" runat="server" OnClick="btnExpand_Click" CssClass="text-[10px] font-bold bg-blue-500 text-white px-2 py-1 rounded hover:bg-blue-600 transition">Expand All</asp:LinkButton>
                            <asp:LinkButton ID="btnCollapse" runat="server" OnClick="btnCollapse_Click" CssClass="text-[10px] font-bold bg-gray-500 text-white px-2 py-1 rounded hover:bg-gray-600 transition">Close All</asp:LinkButton>
                            <asp:LinkButton ID="btnOffDuty" runat="server" OnClick="btnOffDuty_Click" CssClass="text-[10px] font-bold bg-red-500 text-white px-2 py-1 rounded hover:bg-red-600 transition">Reset</asp:LinkButton>
                        </div>
                    </div>
                    <div class="tree-container p-4 overflow-y-auto h-[500px] lg:h-[650px]">
                        <asp:TreeView ID="tvAccounts" runat="server" CssClass="custom-tree" 
                            OnSelectedNodeChanged="tvAccounts_SelectedNodeChanged"
                            ShowLines="True" 
                            ExpandDepth="1" 
                            NodeIndent="30">
                            <SelectedNodeStyle CssClass="tree-node-selected" />
                            <NodeStyle VerticalPadding="3px" HorizontalPadding="5px" />
                        </asp:TreeView>
                    </div>
                </div>

                <!-- Right Section: Entry Form -->
                <div class="col-span-12 lg:col-span-7 p-6 bg-white flex flex-col">
                    <div class="space-y-6">
                        <div class="bg-white rounded-xl border border-gray-200 p-5 space-y-4 shadow-sm">
                            <h3 class="text-sm font-bold text-gray-800 border-b pb-2 mb-4">Ledger Information</h3>
                            
                            <!-- ID Row -->
                            <div class="grid grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">Parent ID</label>
                                    <asp:TextBox ID="txtParentID" runat="server" ReadOnly="true" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg bg-gray-50 text-sm outline-none" Text="0"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">Child ID/Code</label>
                                    <asp:TextBox ID="txtChildID" runat="server" ReadOnly="true" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg bg-gray-50 text-sm outline-none" Text="0" placeholder="Auto-generated"></asp:TextBox>
                                </div>
                            </div>

                            <!-- Name -->
                            <div>
                                <label class="block text-xs font-semibold text-gray-600 mb-1">Account Name</label>
                                <asp:TextBox ID="txtAccountName" runat="server" placeholder="Enter ledger name" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 text-sm"></asp:TextBox>
                            </div>

                            <!-- Ref -->
                            <div>
                                <label class="block text-xs font-semibold text-gray-600 mb-1">Voucher Ref.</label>
                                <asp:TextBox ID="txtVoucherRef" runat="server" placeholder="Reference code" CssClass="w-full h-10 px-3 border border-gray-300 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 text-sm"></asp:TextBox>
                            </div>
                        </div>

                        <!-- Action Buttons (অরিজিনাল কালার কোড অনুযায়ী) -->
                        <div class="bg-gray-50 p-4 rounded-xl border border-gray-200 shadow-sm">
                            <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
                                <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click"
                                    CssClass="bg-green-600 hover:bg-green-700 text-white py-2.5 rounded-lg shadow transition active:scale-95 cursor-pointer font-bold text-sm" />
                                
                                <asp:Button ID="btnUpdate" runat="server" Text="Edit" OnClick="btnUpdate_Click"
                                    CssClass="bg-amber-500 hover:bg-amber-600 text-white py-2.5 rounded-lg shadow transition active:scale-95 cursor-pointer font-bold text-sm" />
                                
                                <asp:Button ID="Button1" runat="server" Text="Update" OnClick="Button1_Click" Visible="False"
                                    CssClass="bg-amber-500 hover:bg-amber-600 text-white py-2.5 rounded-lg shadow transition active:scale-95 cursor-pointer font-bold text-sm" />
                                
                                <asp:Button ID="btnDelete" runat="server" Text="Delete" 
                                    CssClass="bg-red-500 hover:bg-red-600 text-white py-2.5 rounded-lg shadow transition active:scale-95 cursor-pointer font-bold text-sm" />
                                
                                <asp:Button ID="btnClear" runat="server" Text="Clear" 
                                    CssClass="bg-gray-500 hover:bg-gray-600 text-white py-2.5 rounded-lg shadow transition active:scale-95 cursor-pointer font-bold text-sm" />
                            </div>
                        </div>
                    </div>

                    <!-- Helpful Tip -->
                    <div class="mt-auto p-4 bg-blue-50 text-blue-700 rounded-lg border border-blue-100 text-xs">
                        <strong>Tip:</strong> Select an account from the left tree to edit it or to add a child account under it.
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>