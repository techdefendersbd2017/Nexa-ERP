<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PaymentMode.aspx.cs" Inherits="Nexa_ERP.AccountsModule.MasterData.PaymentMode" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Payment Mode</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .custom-grid { width: 100%; border-collapse: collapse; }
        .custom-grid th { background-color: #f8fafc; color: #475569; padding: 6px 10px; text-align: left; border-bottom: 2px solid #e2e8f0; font-size: 0.75rem; }
        .custom-grid td { padding: 6px 10px; border-bottom: 1px solid #e2e8f0; font-size: 0.75rem; color: #1e293b; }
        #voucherListPanel { transition: all 0.3s ease-in-out; }
        .form-input { width: 100%; height: 34px; padding: 0 10px; border: 1px solid #d1d5db; border-radius: 6px; outline: none; font-size: 0.875rem; }
    </style>
</head>
<body class="bg-gray-100 font-sans">
    <form id="form" runat="server" class="p-2 md:p-4">
        <div class="bg-white border border-gray-200 rounded-xl shadow-lg overflow-hidden max-w-[1600px] mx-auto">

            <!-- Header Section (Slightly Slimmer) -->
            <div class="bg-gradient-to-r from-blue-600 to-blue-700 text-white px-5 py-3 flex justify-between items-center">
                <div>
                    <h1 class="text-xl font-bold tracking-tight">Payment Mode</h1>
                    <asp:Label ID="Label5" runat="server" Text="Configure transaction methods" CssClass="text-xs opacity-80"></asp:Label>
                </div>
            </div>

            <!-- Main Content Body -->
            <div class="p-4 grid grid-cols-1 lg:grid-cols-12 gap-4">
                
                <!-- Left Section: Entry Form (Compact 2-Column internally) -->
                <div class="lg:col-span-5 flex flex-col space-y-3 bg-gray-50 p-4 rounded-xl border border-gray-200 shadow-sm">
                    
                    <!-- ID & Short Name (In one row) -->
                    <div class="grid grid-cols-12 gap-3">
                        <div class="col-span-4">
                            <label class="block text-xs font-semibold text-gray-600 mb-1">ID</label>
                            <asp:TextBox ID="txtdepartmentID" runat="server" ReadOnly="true" CssClass="form-input bg-gray-100"></asp:TextBox>
                            <asp:TextBox ID="txtdepartmentID0" runat="server" ReadOnly="true" Visible="False"></asp:TextBox>
                        </div>
                        <div class="col-span-8">
                            <label class="block text-xs font-semibold text-gray-600 mb-1">Short Name</label>
                            <asp:TextBox ID="TextBox2" runat="server" placeholder="e.g. CASH" CssClass="form-input focus:ring-2 focus:ring-blue-500"></asp:TextBox>
                        </div>
                    </div>

                    <!-- Full Name -->
                    <div>
                        <label class="block text-xs font-semibold text-gray-600 mb-1">Full Name</label>
                        <asp:TextBox ID="TextBox1" runat="server" placeholder="Enter payment mode name" CssClass="form-input focus:ring-2 focus:ring-blue-500"></asp:TextBox>
                    </div>

                    <!-- Voucher Type & Add Button (Tighter) -->
                    <div>
                        <label class="block text-xs font-semibold text-gray-600 mb-1">Voucher Type</label>
                        <div class="flex gap-2">
                            <asp:DropDownList ID="DropDownList1" runat="server" CssClass="form-input flex-1"></asp:DropDownList>
                            <asp:Button ID="Button4" runat="server" CssClass="bg-blue-600 hover:bg-blue-700 text-white px-3 h-[34px] rounded-lg shadow text-xs font-medium cursor-pointer" Text="Add" OnClick="Button1_Click" />
                        </div>
                    </div>

                    <!-- Remarks & Status (Side by Side) -->
                    <div class="grid grid-cols-12 gap-3">
                        <div class="col-span-8">
                            <label class="block text-xs font-semibold text-gray-600 mb-1">Remarks</label>
                            <asp:TextBox ID="TextBox4" runat="server" placeholder="Optional..." CssClass="form-input focus:ring-2 focus:ring-blue-500"></asp:TextBox>
                        </div>
                        <div class="col-span-4 flex items-end">
                            <div class="flex items-center h-[34px] px-2 bg-white rounded-lg border border-gray-300 w-full">
                                <asp:CheckBox ID="CheckBox1" runat="server" class="w-4 h-4 text-blue-600 cursor-pointer" Checked="True"/>
                                <span class="ml-2 text-xs font-medium text-gray-700">Active?</span>
                            </div>
                        </div>
                    </div>

                    <!-- Action Buttons Area (Compact) -->
                    <div class="grid grid-cols-4 gap-2 pt-2">
                        <asp:Button ID="btnsave" runat="server" Text="Save" CssClass="bg-green-600 hover:bg-green-700 text-white py-1.5 rounded-md text-sm transition active:scale-95 cursor-pointer font-semibold" OnClick="btnsave_Click"/>
                        <asp:Button ID="btnupdate" runat="server" Text="Update" CssClass="bg-amber-500 hover:bg-amber-600 text-white py-1.5 rounded-md text-sm transition active:scale-95 cursor-pointer font-semibold" OnClick="btnupdate_Click"/>
                        <asp:Button ID="Button2" runat="server" Text="Clear" CssClass="bg-gray-500 hover:bg-gray-600 text-white py-1.5 rounded-md text-sm transition active:scale-95 cursor-pointer font-semibold" OnClick="Button2_Click"/>
                        <asp:Button ID="Button3" runat="server" Text="Delete" CssClass="bg-red-500 hover:bg-red-600 text-white py-1.5 rounded-md text-sm transition active:scale-95 cursor-pointer font-semibold" OnClick="Button3_Click"/>
                    </div>

                    <!-- Voucher Type List Section (Height reduced) -->
                    <div id="voucherListPanel" class="bg-white border border-gray-300 rounded-lg overflow-hidden shadow-inner mt-2">
                        <div class="bg-gray-100 px-3 py-1.5 border-b border-gray-300 flex justify-between items-center">
                            <span class="text-[11px] font-bold text-gray-700 uppercase">Voucher Type List</span>
                             <asp:Button ID="btnRemove" runat="server" Text="Remove" CssClass="text-red-600 text-[10px] font-bold hover:underline" OnClick="btnRemove_Click" />
                        </div>
                        <div class="max-h-[120px] overflow-y-auto">
                            <asp:GridView ID="GridViewVoucherList" runat="server" CssClass="custom-grid"
                                AutoGenerateColumns="False" DataKeyNames="VoucherID" OnSelectedIndexChanged="GridViewVoucherList_SelectedIndexChanged">
                                <Columns>
                                    <asp:CommandField ShowSelectButton="True" SelectText="Select" />
                                    <asp:BoundField DataField="VoucherID" HeaderText="ID" />
                                    <asp:BoundField DataField="VoucherName" HeaderText="Name" />
                                    <asp:CheckBoxField DataField="IsActive" HeaderText="ST" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

                <!-- Right Section: Data Table -->
                <div class="lg:col-span-7 flex flex-col bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden">
                    <div class="bg-gray-50 px-4 py-2 border-b border-gray-200 flex justify-between items-center">
                        <h2 class="text-md font-semibold text-gray-700">Payment Mode List</h2>
                        <span class="text-[10px] font-bold text-gray-500 bg-gray-200 px-2 py-0.5 rounded-full uppercase">Live</span>
                    </div>
                    <div class="overflow-x-auto p-2">
                        <asp:GridView ID="GridViewPaymentModeList" runat="server" CssClass="custom-grid"
                            AutoGenerateColumns="False" DataKeyNames="PaymentModeID" OnSelectedIndexChanged="GridViewPaymentModeList_SelectedIndexChanged">
                            <Columns>
                                <asp:CommandField ShowSelectButton="True" SelectText="Edit" />
                                <asp:BoundField DataField="PaymentModeID" HeaderText="ID" />
                                <asp:BoundField DataField="Name" HeaderText="Name" />
                                <asp:BoundField DataField="Short_Name" HeaderText="Short" />
                                <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                                <asp:CheckBoxField DataField="Is_Active" HeaderText="Status" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>

            </div>
        </div>
    </form>

    <script type="text/javascript">
        function showVoucherPanel() {
            var panel = document.getElementById('voucherListPanel');
            if (panel) { panel.classList.remove('hidden'); }
        }
    </script>
</body>
</html>