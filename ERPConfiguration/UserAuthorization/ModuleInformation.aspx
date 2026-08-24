<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ModuleInformation.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.UserAuthorization.ModuleInformation" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Module Information - NexaERP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    
    <!-- Google Font -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />

    <!-- jQuery & Select2 -->
    <script src="https://code.jquery.com/jquery-3.6.4.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

    <style>
        * {
            font-family: 'Inter', 'Segoe UI', Roboto, Arial, sans-serif;
        }
        /* GridView Header & Row Styles */
        .grid-wrapper th {
            position: sticky;
            top: 0;
            background: linear-gradient(135deg, #198754, #146c43) !important;
            color: #fff !important;
            z-index: 10;
            font-weight: 600;
            font-size: 0.82rem;
            text-transform: uppercase;
            letter-spacing: 0.4px;
            padding: 12px 14px;
            border: none;
        }
        .grid-wrapper td {
            padding: 10px 14px;
            vertical-align: middle;
            color: #374151;
            border-bottom: 1px solid #e6e9ef;
        }
        .grid-wrapper tr:hover {
            background-color: #f0f7f4;
        }
    </style>
</head>
<body class="bg-[#f2f4f8] text-[#1f2937] m-0 p-0 antialiased">
    <form id="form1" runat="server">
        <!-- Ajax Support and Scroll Fix -->
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <div class="container-fluid min-h-screen p-4 lg:p-6">

            <!-- Page Heading -->
            <div class="flex items-center gap-3 mb-5">
                <div class="w-10 h-10 rounded-lg bg-blue-50 flex items-center justify-center shadow-sm">
                    <i class="fa-solid fa-cube text-lg text-[#0d6efd]"></i>
                </div>
                <div>
                    <h3 class="m-0 font-bold text-[#111827] text-xl tracking-tight">Module Configuration</h3>
                    <small class="block text-[#6b7280] font-normal text-xs mt-0.5">ERP Configuration &rsaquo; Core Setting &rsaquo; Module Information</small>
                </div>
            </div>

            <!-- UpdatePanel to prevent screen shaking -->
            <asp:UpdatePanel ID="UPModuleInfo" runat="server">
                <ContentTemplate>

                    <!-- Grid Layout (Form: 7 Columns, Grid: 5 Columns) -->
                    <div class="grid grid-cols-1 lg:grid-cols-12 gap-5 items-start">

                        <!-- Left Side Form -->
                        <div class="col-span-1 lg:col-span-7">
                            <div class="bg-white border border-[#e6e9ef] rounded-xl overflow-hidden shadow-sm flex flex-col">
                                
                                <!-- Card Header -->
                                <div class="bg-gradient-to-r from-[#0d6efd] to-[#0b5ed7] text-white px-5 py-4 flex items-center justify-between">
                                    <div class="flex items-center gap-2.5">
                                        <i class="fa-solid fa-pen-to-square text-base"></i>
                                        <h4 class="mb-0 text-[1rem] font-semibold tracking-wide">Module Entry</h4>
                                    </div>
                                    <asp:Label ID="lblStatusInfo" runat="server" CssClass="text-xs bg-white/20 px-2 py-1 rounded" Text="New Entry"></asp:Label>
                                </div>

                                <!-- Card Body -->
                                <div class="p-5 overflow-y-auto lg:max-h-[calc(100vh-210px)]">
                                    <asp:HiddenField ID="hfModuleID" runat="server" />

                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-x-4 gap-y-4">
                                        
                                        <!-- Module ID -->
                                        <div class="flex flex-col">
                                            <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Module ID</label>
                                            <asp:TextBox ID="txtModuleID" runat="server" Text="0" ReadOnly="True" 
                                                CssClass="w-full bg-[#f3f4f6] text-[#6b7280] border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none shadow-sm cursor-not-allowed" />
                                        </div>

                                        <!-- Sorting No -->
                                        <div class="flex flex-col">
                                            <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Sorting No</label>
                                            <asp:TextBox ID="txtSortingNo" runat="server" Text="0" TextMode="Number"
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <!-- Module Name -->
                                        <div class="flex flex-col md:col-span-2">
                                            <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Module Name</label>
                                            <asp:TextBox ID="txtModuleName" runat="server" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>       

                                        <!-- Module Code -->
                                        <div class="flex flex-col">
                                            <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Module Code</label>
                                            <asp:TextBox ID="txtModuleCode" runat="server" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <!-- Icon Class -->
                                        <div class="flex flex-col">
                                            <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Icon Class (FontAwesome)</label>
                                            <asp:TextBox ID="txtIconClass" runat="server" placeholder="fa-solid fa-folder" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <!-- Is Active Checkbox -->
                                        <div class="flex items-center md:col-span-2 pt-1">
                                            <div class="flex items-center gap-2">
                                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="w-4 h-4 rounded text-[#198754] border-gray-300 accent-[#198754] cursor-pointer" Checked="true" />
                                                <asp:Label runat="server" AssociatedControlID="chkIsActive" Text="Is Active?" class="font-semibold text-[0.85rem] text-[#374151] cursor-pointer select-none" />
                                            </div>
                                        </div>

                                    </div>

                                    <!-- Action Buttons -->
                                    <div class="border-t border-[#e6e9ef] mt-5 pt-4 flex flex-col sm:flex-row justify-end items-center gap-3">
                                        <div class="flex gap-3 w-full sm:w-auto">
                                            <asp:Button ID="btnClear" runat="server" Text="Clear" OnClick="btnClear_Click"
                                                CssClass="w-full sm:w-auto font-semibold text-[0.9rem] px-5 py-2.5 rounded-lg text-white bg-gradient-to-r from-[#6c757d] to-[#5c636a] border-none cursor-pointer hover:shadow-sm active:scale-95 transition-all" />
                                            
                                            <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click"
                                                CssClass="w-full sm:w-auto font-semibold text-[0.9rem] px-5 py-2.5 rounded-lg text-white bg-gradient-to-r from-[#198754] to-[#157347] border-none cursor-pointer hover:shadow-sm active:scale-95 transition-all" />
                                        </div>
                                    </div>

                                </div>
                            </div>
                        </div>

                        <!-- Right Side Grid -->
                        <div class="col-span-1 lg:col-span-5">
                            <div class="bg-white border border-[#e6e9ef] rounded-xl overflow-hidden shadow-sm flex flex-col">
                                
                                <!-- Card Header -->
                                <div class="bg-gradient-to-r from-[#198754] to-[#157347] text-white px-5 py-4 flex items-center gap-2.5">
                                    <i class="fa-solid fa-list text-base"></i>
                                    <h4 class="mb-0 text-[1rem] font-semibold tracking-wide">Module List</h4>
                                </div>

                                <!-- Grid Wrapper -->
                                <div class="grid-wrapper overflow-y-auto overflow-x-auto lg:max-h-[calc(100vh-210px)] min-h-[250px]">
                                    <asp:GridView ID="gvModuleInfo" runat="server" CssClass="w-full border-collapse text-[0.88rem]"
                                        AutoGenerateColumns="False" DataKeyNames="Module_ID" Width="100%" OnSelectedIndexChanged="gvModuleInfo_SelectedIndexChanged">
                                        <Columns>
                                            <asp:CommandField ShowSelectButton="True" SelectText="Select">
                                                <ItemStyle Width="70px" CssClass="text-blue-600 font-medium hover:underline cursor-pointer" />
                                            </asp:CommandField>
                                            <asp:BoundField DataField="Module_ID" HeaderText="ID" />
                                            <asp:BoundField DataField="Module_Name" HeaderText="Module Name" />
                                            <asp:BoundField DataField="Module_Code" HeaderText="Code" />
                                            <asp:BoundField DataField="SortingNo" HeaderText="Sort" />
                                            <asp:CheckBoxField DataField="is_Active" HeaderText="Status" />
                                        </Columns>
                                    </asp:GridView>
                                </div>

                            </div>
                        </div>

                    </div>

                </ContentTemplate>
            </asp:UpdatePanel>

        </div>
    </form>
</body>
</html>