<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="costCenterGroupInfo.aspx.cs" Inherits="Nexa_ERP.AccountsModule.MasterData.costCenterGroupInfo" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Cost Center Group Information</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .custom-grid { width: 100%; border-collapse: collapse; background: white; }
        .custom-grid th { background-color: #2563eb; color: white; padding: 8px; text-align: left; font-size: 12px; text-transform: uppercase; }
        .custom-grid td { padding: 6px 8px; border-bottom: 1px solid #e5e7eb; font-size: 13px; color: #374151; }
        .custom-grid tr:hover { background-color: #eff6ff; cursor: pointer; }
        
        /* Scrollbar styling for list */
        .grid-scroll { max-height: 500px; overflow-y: auto; }
    </style>
</head>
<body class="bg-slate-50 font-sans p-2">
    <form id="form" runat="server">
        <div class="max-w-[1600px] mx-auto bg-white shadow-xl rounded-xl overflow-hidden border border-gray-200">
            
            <!-- Compact Header -->
            <div class="bg-blue-700 px-5 py-3 flex justify-between items-center text-white">
                <div>
                    <h1 class="text-lg font-bold tracking-tight">COST CENTER GROUP</h1>
                    <p class="text-[10px] text-blue-100 uppercase opacity-80">Setup & Management</p>
                </div>
                <div class="flex gap-2">
                    <span class="bg-blue-800 px-3 py-1 rounded text-[10px] font-mono border border-blue-500/50">Nexa ERP v2.0</span>
                </div>
            </div>

            <div class="grid grid-cols-12 gap-0">
                
                <!-- Left Side: Compact Form (4 Columns) -->
                <div class="col-span-12 lg:col-span-4 p-5 bg-gray-50 border-r border-gray-100">
                    <div class="space-y-3">
                        
                        <!-- Row 1: ID & Sorting -->
                        <div class="grid grid-cols-2 gap-3">
                            <div>
                                <label class="text-[11px] font-bold text-gray-500 uppercase">Group ID</label>
                                <asp:TextBox ID="txtdepartmentID" runat="server" ReadOnly="true"
                                    CssClass="w-full h-9 px-3 rounded border border-gray-300 bg-gray-100 text-sm outline-none"></asp:TextBox>
                            </div>
                            <div>
                                <label class="text-[11px] font-bold text-gray-500 uppercase">Sorting No</label>
                                <asp:TextBox ID="TextBox2" runat="server" placeholder="0"
                                    CssClass="w-full h-9 px-3 rounded border border-gray-300 text-sm focus:border-blue-500 outline-none"></asp:TextBox>
                            </div>
                        </div>

                        <!-- Name -->
                        <div>
                            <label class="text-[11px] font-bold text-gray-500 uppercase">Group Name <span class="text-red-500">*</span></label>
                            <asp:TextBox ID="TextBox1" runat="server" placeholder="Enter name..."
                                CssClass="w-full h-9 px-3 rounded border border-gray-300 focus:border-blue-500 outline-none text-sm"></asp:TextBox>
                        </div>

                        <!-- Remarks -->
                        <div>
                            <label class="text-[11px] font-bold text-gray-500 uppercase">Remarks</label>
                            <asp:TextBox ID="TextBox4" runat="server" TextMode="MultiLine" Rows="2" 
                                CssClass="w-full px-3 py-2 rounded border border-gray-300 focus:border-blue-500 outline-none text-sm resize-none"></asp:TextBox>
                        </div>

                        <!-- Status Check -->
                        <div class="flex items-center gap-2 py-1">
                           <asp:CheckBox ID="CheckBox1" runat="server" Checked="True" />
                           <span class="text-sm font-semibold text-gray-600">Active Status</span>
                        </div>

                        <!-- Action Buttons (Arranged in 2 rows for better space) -->
                        <div class="grid grid-cols-2 gap-2 pt-2">
                            <asp:Button ID="btnsave" runat="server" Text="Save" OnClick="btnsave_Click"
                                CssClass="bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-bold py-2 rounded shadow-sm cursor-pointer transition-all"/>
                            
                            <asp:Button ID="btnUpdate" runat="server" Text="Update" OnClick="btnUpdate_Click"
                                CssClass="bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold py-2 rounded shadow-sm cursor-pointer transition-all"/>
                            
                            <asp:Button ID="Button2" runat="server" Text="Clear" OnClick="Button2_Click"
                                CssClass="bg-slate-500 hover:bg-slate-600 text-white text-xs font-bold py-2 rounded shadow-sm cursor-pointer transition-all"/>
                            
                            <asp:Button ID="Button3" runat="server" Text="Delete" OnClick="Button3_Click"
                                CssClass="bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold py-2 rounded shadow-sm cursor-pointer transition-all"/>
                        </div>
                    </div>
                </div>

                <!-- Right Side: Data List (8 Columns) -->
                <div class="col-span-12 lg:col-span-8 p-0 bg-white">
                    <div class="flex flex-col h-full">
                        <!-- Table Toolbar -->
                        <div class="p-4 border-b border-gray-100 flex justify-between items-center bg-white">
                            <h3 class="text-sm font-bold text-gray-700 uppercase tracking-tight">Recent Groups</h3>
                            <div class="flex items-center">
                                <span class="text-[10px] text-gray-400 mr-2 uppercase font-bold">Search:</span>
                                <asp:TextBox ID="TextBox3" placeholder="Filter..." runat="server" AutoPostBack="True" OnTextChanged="TextBox3_TextChanged"
                                    CssClass="text-xs border border-gray-300 rounded-md px-3 py-1.5 w-48 focus:ring-1 focus:ring-blue-500 outline-none transition-all"></asp:TextBox>
                            </div>
                        </div>
                        
                        <!-- Grid with Scroll -->
                        <div class="grid-scroll p-4">
                            <asp:GridView ID="GridViewCostCenterList" runat="server" CssClass="custom-grid"
                                AutoGenerateColumns="False" DataKeyNames="CostCenterGroupID" OnSelectedIndexChanged="GridViewCostCenterList_SelectedIndexChanged">
                                <Columns>
                                    <asp:CommandField ShowSelectButton="True" SelectText="Select" ControlStyle-CssClass="text-blue-600 font-bold hover:underline" />
                                    <asp:BoundField DataField="CostCenterGroupID" HeaderText="ID" ItemStyle-Width="60px" />
                                    <asp:BoundField DataField="CostCenterGroupName" HeaderText="Group Name" />
                                    <asp:BoundField DataField="ShortingName" HeaderText="Sort" ItemStyle-Width="50px" />
                                    <asp:CheckBoxField DataField="IsActive" HeaderText="Active" ItemStyle-Width="60px" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </form>
</body>
</html>