<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="fiscalsyearsInformation.aspx.cs" Inherits="Nexa_ERP.AccountsModule.MasterData.fiscalsyearsInformation" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Fiscal Years Information</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .gv-container table { width: 100%; border-collapse: collapse; background: white; border-radius: 6px; overflow: hidden; }
        .gv-container th { background-color: #f8fafc; color: #1e293b; padding: 8px 10px; border-bottom: 2px solid #e2e8f0; text-align: left; font-size: 12px; }
        .gv-container td { padding: 6px 10px; border-bottom: 1px solid #f1f5f9; color: #475569; font-size: 12px; }
        .gv-container tr:hover { background-color: #f1f5f9; }
    </style>
</head>
<body class="bg-gray-100 font-sans">
    <form id="form" runat="server" class="p-2 md:p-4">
        <div class="bg-white border border-gray-200 rounded-xl shadow-md overflow-hidden max-w-7xl mx-auto">
            
            <!-- Header: Shorter Height -->
            <div class="bg-gradient-to-r from-blue-600 to-blue-700 text-white px-5 py-3 flex justify-between items-center">
                <div>
                    <h1 class="text-lg font-bold uppercase tracking-tight">Fiscal Years Information</h1>
                    <asp:Label ID="Label5" runat="server" Text="Manage accounting periods" CssClass="text-[10px] text-blue-100 opacity-90"></asp:Label>
                </div>
                <div class="bg-white/20 px-2 py-0.5 rounded text-[9px] font-semibold uppercase">Setup</div>
            </div>

            <div class="p-4 space-y-4">
                <!-- Top Section: Compact Form Layout -->
                <div class="bg-gray-50 border border-gray-200 rounded-lg p-4 shadow-sm">
                    <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-4 items-end">
                        
                        <!-- ID -->
                        <div>
                            <label class="block text-[10px] font-bold text-gray-600 mb-1 uppercase">ID</label>
                            <asp:TextBox ID="txtdepartmentID" runat="server" ReadOnly="true" CssClass="w-full h-8 px-2 rounded border border-gray-300 bg-gray-100 text-gray-500 text-sm outline-none"></asp:TextBox>
                        </div>

                        <!-- Year Name -->
                        <div class="md:col-span-1">
                            <label class="block text-[10px] font-bold text-gray-600 mb-1 uppercase">Year Name</label>
                            <asp:TextBox ID="TextBox3" runat="server" placeholder="FY 2025-26" CssClass="w-full h-8 px-2 rounded border border-gray-300 focus:ring-1 focus:ring-blue-400 text-sm outline-none transition"></asp:TextBox>
                        </div>

                        <!-- Company Name -->
                        <div class="md:col-span-1 lg:col-span-2">
                            <label class="block text-[10px] font-bold text-gray-600 mb-1 uppercase">Company Name</label>
                            <asp:TextBox ID="TextBox1" runat="server" CssClass="w-full h-8 px-2 rounded border border-gray-300 focus:ring-1 focus:ring-blue-400 text-sm outline-none transition"></asp:TextBox>
                        </div>

                        <!-- Fiscal Period -->
                        <div class="grid grid-cols-2 gap-2 bg-blue-50/50 p-2 rounded border border-blue-100">
                            <div class="col-span-2 text-[10px] font-bold text-blue-700 uppercase mb-1">Fiscal (From - To)</div>
                            <asp:DropDownList ID="DropDownList1" runat="server" CssClass="h-7 text-xs rounded border border-gray-300 outline-none">
                                <asp:ListItem Text="July" Value="7"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:DropDownList ID="DropDownList2" runat="server" CssClass="h-7 text-xs rounded border border-gray-300 outline-none">
                                <asp:ListItem Text="June" Value="6"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <!-- Calendar Period -->
                        <div class="grid grid-cols-2 gap-2 bg-orange-50/50 p-2 rounded border border-orange-100">
                            <div class="col-span-2 text-[10px] font-bold text-orange-700 uppercase mb-1">Calendar (From - To)</div>
                            <asp:DropDownList ID="DropDownList3" runat="server" CssClass="h-7 text-xs rounded border border-gray-300 outline-none">
                                <asp:ListItem Text="Jan" Value="1"></asp:ListItem>
                            </asp:DropDownList>
                            <asp:DropDownList ID="DropDownList4" runat="server" CssClass="h-7 text-xs rounded border border-gray-300 outline-none">
                                <asp:ListItem Text="Dec" Value="12"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <!-- Remarks -->
                        <div class="md:col-span-1 lg:col-span-1">
                            <label class="block text-[10px] font-bold text-gray-600 mb-1 uppercase">Remarks</label>
                            <asp:TextBox ID="TextBox4" runat="server" CssClass="w-full h-8 px-2 rounded border border-gray-300 focus:ring-1 focus:ring-blue-400 text-sm outline-none transition"></asp:TextBox>
                        </div>

                        <!-- Status & Buttons -->
                        <div class="md:col-span-3 lg:col-span-1 flex flex-col justify-end">
                             <div class="flex items-center mb-1"> 
                                <input type="checkbox" id="isActive" class="w-3.5 h-3.5 text-blue-600 rounded border-gray-300 cursor-pointer"/>
                                <label for="isActive" class="ml-2 text-[11px] font-medium text-gray-700 cursor-pointer">Active Fiscal Year</label>
                            </div>
                            <div class="grid grid-cols-4 gap-1">
                                <asp:Button ID="btnsave" runat="server" Text="Save" CssClass="bg-green-600 hover:bg-green-700 text-white py-1.5 rounded font-bold text-[11px] cursor-pointer"/>
                                <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="bg-blue-500 hover:bg-blue-600 text-white py-1.5 rounded font-bold text-[11px] cursor-pointer"/>
                                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="bg-gray-400 hover:bg-gray-500 text-white py-1.5 rounded font-bold text-[11px] cursor-pointer"/>
                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="bg-red-500 hover:bg-red-600 text-white py-1.5 rounded font-bold text-[11px] cursor-pointer"/>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Bottom Section: Grid View -->
                <div class="bg-white border border-gray-200 rounded-lg shadow-sm">
                    <div class="flex items-center justify-between px-4 py-2 border-b">
                        <h3 class="text-xs font-bold text-gray-700 uppercase tracking-wider">Registered Fiscal Years List</h3>
                    </div>
                    <div class="overflow-x-auto gv-container p-2">
                        <asp:GridView ID="GridView1" runat="server" GridLines="None" CssClass="min-w-full"></asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>