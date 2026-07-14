<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="chequeBookRegistration.aspx.cs" Inherits="Nexa_ERP.AccountsModule.MasterData.chequeBookRegistration" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Cheque Book Registration</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .gv-container table { width: 100%; border-collapse: collapse; background: white; font-size: 13px; }
        .gv-container th { background-color: #f3f4f6; color: #374151; padding: 8px; border: 1px solid #d1d5db; text-align: left; }
        .gv-container td { padding: 6px 8px; border: 1px solid #e5e7eb; color: #4b5563; }
        .gv-container tr:hover { background-color: #eff6ff; }
        /* কাস্টম ইনপুট সাইজ */
        .form-input { height: 34px !important; font-size: 13px !important; }
    </style>
</head>
<body class="bg-gray-100 font-sans text-sm">
    <form id="form" runat="server" class="p-2 md:p-4">
        <div class="bg-white border border-gray-200 rounded-xl shadow-md overflow-hidden max-w-6xl mx-auto">
            
            <!-- Header (Compact) -->
            <div class="bg-gradient-to-r from-blue-700 to-blue-900 text-white px-5 py-3 flex justify-between items-center">
                <div>
                    <h1 class="text-lg font-bold uppercase tracking-tight">Cheque Book Registration</h1>
                </div>
                <div class="bg-white/20 px-3 py-0.5 rounded-full text-[10px] font-semibold uppercase">
                    ERP Module
                </div>
            </div>

            <div class="p-4">
                <!-- Unified Info Card -->
                <div class="bg-gray-50 border border-gray-200 rounded-lg p-4 shadow-sm">
                    <h3 class="text-blue-700 font-bold border-b pb-1 mb-4 text-sm">Registration Details</h3>
                    
                    <div class="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-x-4 gap-y-3">
                        <!-- Row 1 -->
                        <div>
                            <label class="block text-xs font-semibold text-gray-600 mb-1">ID</label>
                            <asp:TextBox ID="txtdepartmentID" runat="server" ReadOnly="true" CssClass="bg-gray-100 border border-gray-300 px-3 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                        </div>
                        <div class="lg:col-span-2">
                                <asp:LinkButton ID="LinkButton1" runat="server" OnClick="DropDownList1_SelectedIndexChanged" 
                                    CssClass="block text-xs font-semibold text-gray-600 mb-1">Company Name</asp:LinkButton>
                            <asp:DropDownList ID="DropDownList1" runat="server" AutoPostBack="True"
                                CssClass="border border-gray-300 px-3 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition">
                                <asp:ListItem Text="Select Branch" Value=""></asp:ListItem>
                            </asp:DropDownList>                            
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-gray-600 mb-1">Account Number</label>
                            <asp:TextBox ID="TextBox3" runat="server" placeholder="Enter Account Number" CssClass="border border-gray-300 px-3 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                        </div>

                        <!-- Row 2 -->
                        <div>
                            <label class="block text-xs font-semibold text-gray-600 mb-1">Cheque Book No.</label>
                            <asp:TextBox ID="TextBox6" runat="server" CssClass="border border-gray-300 px-3 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                        </div>
                        <div class="grid grid-cols-3 gap-2 lg:col-span-1">
                            <div class="col-span-1">
                                <label class="block text-xs font-semibold text-gray-600 mb-1">Prefix</label>
                                <asp:TextBox ID="TextBox7" runat="server" placeholder="CD" CssClass="border border-gray-300 px-2 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                            </div>
                            <div class="col-span-1">
                                <label class="block text-xs font-semibold text-gray-600 mb-1">From</label>
                                <asp:TextBox ID="TextBox11" runat="server" CssClass="border border-gray-300 px-2 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                            </div>
                            <div class="col-span-1">
                                <label class="block text-xs font-semibold text-gray-600 mb-1">To</label>
                                <asp:TextBox ID="TextBox12" runat="server" CssClass="border border-gray-300 px-2 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                            </div>
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-gray-600 mb-1">Req. Leaf / Total Leaf</label>
                            <div class="flex space-x-2">
                                <asp:TextBox ID="TextBox5" runat="server" placeholder="Req" CssClass="border border-gray-300 px-2 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                                <asp:TextBox ID="TextBox2" runat="server" placeholder="Total" CssClass="border border-gray-300 px-2 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                            </div>
                        </div>
                         <div>
                            <label class="block text-xs font-semibold text-gray-600 mb-1 text-blue-600">Active Status</label>
                            <div class="col-span-4 flex items-end">
                                <div class="flex items-center h-[34px] px-2 bg-white rounded-lg border border-gray-300 w-full">
                                    <asp:CheckBox ID="CheckBox1" runat="server" class="w-4 h-4 text-blue-600 cursor-pointer" Checked="True"/>
                                    <span class="ml-2 text-xs font-medium text-gray-700">Available for use</span>
                                </div>
                            </div>
                        </div>

                        <!-- Row 3 (Dates) -->
                        <div>
                            <label class="block text-xs font-semibold text-gray-600 mb-1">Requisition Date</label>
                            <asp:TextBox ID="TextBox9" runat="server" TextMode="Date" CssClass="border border-gray-300 px-2 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-gray-600 mb-1">Est. Receive Date</label>
                            <asp:TextBox ID="TextBox8" runat="server" TextMode="Date" CssClass="border border-gray-300 px-2 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                        </div>
                        <div>
                            <label class="block text-xs font-semibold text-gray-600 mb-1 text-green-600">Receive Date</label>
                            <asp:TextBox ID="TextBox10" runat="server" TextMode="Date" CssClass="border border-gray-300 px-2 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                        </div>
                        <div class="lg:col-span-1">
                             <label class="block text-xs font-semibold text-gray-600 mb-1">Remarks</label>
                             <asp:TextBox ID="TextBox4" runat="server" placeholder="Short note..." CssClass="border border-gray-300 px-3 w-full rounded form-input outline-none focus:ring-1 focus:ring-blue-500 transition"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <!-- Actions Row -->
                <div class="flex flex-wrap justify-end gap-2 mt-4 pb-4 border-b border-gray-100">
                    <asp:Button ID="btnsave" runat="server" Text="Save" CssClass="bg-green-600 hover:bg-green-700 text-white font-bold py-1.5 px-5 rounded shadow-sm text-xs transition active:scale-95 cursor-pointer" OnClick="btnsave_Click"/>
                    <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="bg-blue-600 hover:bg-blue-700 text-white font-bold py-1.5 px-5 rounded shadow-sm text-xs transition active:scale-95 cursor-pointer" OnClick="btnUpdate_Click"/>
                    <asp:Button ID="Button2" runat="server" Text="Clear" CssClass="bg-gray-500 hover:bg-gray-600 text-white font-bold py-1.5 px-5 rounded shadow-sm text-xs transition active:scale-95 cursor-pointer" OnClick="Button2_Click"/>
                    <asp:Button ID="Button3" runat="server" Text="Delete" CssClass="bg-red-500 hover:bg-red-600 text-white font-bold py-1.5 px-5 rounded shadow-sm text-xs transition active:scale-95 cursor-pointer" OnClick="Button3_Click"/>
                </div>

                <!-- Grid View Section -->
                <div class="mt-4">
                    <div class="flex items-center mb-2">
                        <div class="h-4 w-1 bg-blue-600 rounded-full mr-2"></div>
                        <h3 class="text-sm font-bold text-gray-800">Records List</h3>
                    </div>
                    <div class="border border-gray-200 rounded-lg overflow-hidden shadow-sm bg-white gv-container max-h-[250px] overflow-y-auto">
                        <asp:GridView ID="GridViewChequeBookRegister" runat="server" CssClass="custom-grid"
                            AutoGenerateColumns="False" DataKeyNames="ChequeBookRegisterID" OnSelectedIndexChanged="GridViewChequeBookRegister_SelectedIndexChanged">
                            <Columns>
                                <asp:CommandField ShowSelectButton="True" SelectText="Select" />
                                <asp:BoundField DataField="ChequeBookRegisterID" HeaderText="ID" />
                                <asp:BoundField DataField="AccountNumber" HeaderText="Account Number" />
                                <asp:BoundField DataField="ChequeBookNo" HeaderText="Cheque Book No" />
                                <asp:CheckBoxField DataField="IsActive" HeaderText="Status" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>