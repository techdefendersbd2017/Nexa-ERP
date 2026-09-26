<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChartOfMenus.aspx.cs" Inherits="Nexa_ERP.AccountsModule.MasterData.ChartOfMenus" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Chart of Accounts</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .custom-tree a { color: #1e293b; text-decoration: none; font-size: 0.95rem; }
        .custom-tree a:hover { color: #2563eb; }
        .tree-node-selected { background-color: #dbeafe !important; border-radius: 4px; padding: 2px 8px; color: #1d4ed8 !important; font-weight: 600; }
        .custom-tree table td { padding: 0; }
        .tree-container::-webkit-scrollbar { width: 5px; }
        .tree-container::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 10px; }
        .text-xs {
            height: 26px;
        }
    </style>
</head>
<body class="bg-gray-100 font-sans">
    <form id="form1" runat="server" class="p-2 md:p-4">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div class="max-w-[1600px] mx-auto bg-white border border-gray-200 rounded-2xl shadow-lg overflow-hidden">

            <!-- Header Section -->
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
                    <div class="tree-container p-4 overflow-y-auto h-[500px] lg:h-[720px]">
                        <asp:TreeView ID="tvAccounts" runat="server" CssClass="custom-tree"
                            OnSelectedNodeChanged="tvAccounts_SelectedNodeChanged"
                            ShowLines="True"
                            ExpandDepth="1"
                            NodeIndent="30"
                            AutoPostBack="true">
                            <SelectedNodeStyle CssClass="tree-node-selected" />
                            <NodeStyle VerticalPadding="3px" HorizontalPadding="5px" />
                        </asp:TreeView>
                    </div>
                </div>

                <!-- Right Section: Entry Form -->
                <div class="col-span-12 lg:col-span-7 p-6 bg-white flex flex-col">
                    <div class="space-y-4">
                        <div class="bg-white rounded-xl border border-gray-200 p-5 space-y-3 shadow-sm">
                            <h3 class="text-sm font-bold text-gray-800 border-b pb-2 mb-3">Ledger Information</h3>

                            <!-- IDs Row -->
                            <div class="grid grid-cols-3 gap-3">
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">COA ID</label>
                                    <asp:TextBox ID="txtCoaID" runat="server" ReadOnly="true" CssClass="w-full h-9 px-3 border border-gray-300 rounded-lg bg-gray-50 text-xs outline-none" placeholder="Auto"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">Parent ID</label>
                                    <asp:TextBox ID="txtParentID" runat="server" ReadOnly="true" CssClass="w-full h-9 px-3 border border-gray-300 rounded-lg bg-gray-50 text-xs outline-none" Text="0"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">Node Code</label>
                                    <asp:TextBox ID="txtNodeCode" runat="server" ReadOnly="true" CssClass="w-full h-9 px-3 border border-gray-300 rounded-lg bg-gray-50 text-xs outline-none" placeholder="Auto"></asp:TextBox>
                                </div>
                            </div>

                            <!-- Account Name -->
                            <div>
                                <label class="block text-xs font-semibold text-gray-600 mb-1">Node Name (Account Name)</label>
                                <asp:TextBox ID="txtAccountName" runat="server" placeholder="Enter ledger name" CssClass="w-full h-9 px-3 border border-gray-300 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 text-xs"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvAccountName" runat="server" ControlToValidate="txtAccountName"
                                    ErrorMessage="Node Name is required" Display="Dynamic" CssClass="text-[10px] text-red-600" ValidationGroup="COA" />
                            </div>

                            <!-- Node Type, Level & Sorting No -->
                            <div class="grid grid-cols-3 gap-3">
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">Node Type</label>
                                    <asp:TextBox ID="txtNodeType" runat="server" CssClass="w-full h-9 px-3 border border-gray-300 rounded-lg text-xs outline-none focus:ring-2 focus:ring-blue-500" placeholder="e.g. Group/Ledger"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">Node Level</label>
                                    <asp:TextBox ID="txtNodeLevel" runat="server" ReadOnly="true" CssClass="w-full h-9 px-3 border border-gray-300 rounded-lg bg-gray-50 text-xs outline-none" Text="0"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">Sorting No</label>
                                    <asp:TextBox ID="txtSortingNo" runat="server" CssClass="w-full h-9 px-3 border border-gray-300 rounded-lg text-xs outline-none focus:ring-2 focus:ring-blue-500" Text="0"></asp:TextBox>
                                </div>
                            </div>

                            <!-- Reference ID & URL -->
                            <div class="grid grid-cols-2 gap-3">
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">Reference ID</label>
                                    <asp:TextBox ID="txtReferenceID" runat="server" placeholder="Reference code" CssClass="w-full h-9 px-3 border border-gray-300 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 text-xs"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">URL</label>
                                    <asp:TextBox ID="txtURL" runat="server" placeholder="Page URL if any" CssClass="w-full h-9 px-3 border border-gray-300 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 text-xs"></asp:TextBox>
                                </div>
                            </div>

                            <!-- Icon Class & Checkboxes -->
                            <div class="grid grid-cols-3 gap-3 items-center pt-1">
                                <div>
                                    <label class="block text-xs font-semibold text-gray-600 mb-1">Icon Class</label>
                                    <asp:TextBox ID="txtIconClass" runat="server" placeholder="fa fa-folder" CssClass="w-full h-9 px-3 border border-gray-300 rounded-lg outline-none focus:ring-2 focus:ring-blue-500 text-xs"></asp:TextBox>
                                </div>
                                <div class="flex items-center space-x-2 pt-5">
                                    <asp:CheckBox ID="chkIsActive" runat="server" CssClass="rounded text-blue-600 focus:ring-blue-500" Checked="true" />
                                    <label class="text-xs font-semibold text-gray-600">Is Active</label>
                                </div>
                                <div class="flex items-center space-x-2 pt-5">
                                    <asp:CheckBox ID="chkIsLeaf" runat="server" CssClass="rounded text-blue-600 focus:ring-blue-500" Checked="true" />
                                    <label class="text-xs font-semibold text-gray-600">Is Leaf</label>
                                </div>
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div class="bg-gray-50 p-4 rounded-xl border border-gray-200 shadow-sm">
                            <div class="grid grid-cols-2 sm:grid-cols-4 gap-2">
                                <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" ValidationGroup="COA"
                                    CssClass="bg-green-600 hover:bg-green-700 text-white py-2 rounded-lg shadow transition active:scale-95 cursor-pointer font-bold text-xs" />

                                <asp:Button ID="btnUpdate" runat="server" Text="Update" OnClick="btnUpdate_Click" ValidationGroup="COA"
                                    CssClass="bg-amber-500 hover:bg-amber-600 text-white py-2 rounded-lg shadow transition active:scale-95 cursor-pointer font-bold text-xs" />

                                <asp:Button ID="btnDelete" runat="server" Text="Delete" OnClick="btnDelete_Click"
                                    OnClientClick="return confirm('Are you sure you want to delete this account?');"
                                    CssClass="bg-red-500 hover:bg-red-600 text-white py-2 rounded-lg shadow transition active:scale-95 cursor-pointer font-bold text-xs" />

                                <asp:Button ID="btnClear" runat="server" Text="Clear" OnClick="btnClear_Click" CausesValidation="false"
                                    CssClass="bg-gray-500 hover:bg-gray-600 text-white py-2 rounded-lg shadow transition active:scale-95 cursor-pointer font-bold text-xs" />
                            </div>
                        </div>
                    </div>

                    <!-- Helpful Tip -->
                    <div class="mt-4 p-3 bg-blue-50 text-blue-700 rounded-lg border border-blue-100 text-xs">
                        <strong>Tip:</strong> Select an account from the left tree to view/edit it, or click Clear then Save to add a new root/child account under the currently selected node.
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
