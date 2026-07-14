<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateShift.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.AttendanceSetting.CreateShift" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Create Shift - NexaERP</title>
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
                    <i class="fa-solid fa-business-time text-lg text-[#0d6efd]"></i>
                </div>
                <div>
                    <h3 class="m-0 font-bold text-[#111827] text-xl tracking-tight">Shift Management</h3>
                    <small class="block text-[#6b7280] font-normal text-xs mt-0.5">HRM Configuration &rsaquo; Attendance Setting &rsaquo; Create Shift</small>
                </div>
            </div>

            <!-- UpdatePanel to prevent screen shaking -->
            <asp:UpdatePanel ID="UPCreateShift" runat="server">
                <ContentTemplate>

                    <!-- Grid Layout (Form: 7 Columns, Grid: 5 Columns) -->
                    <div class="grid grid-cols-1 lg:grid-cols-12 gap-5 items-start">

                        <!-- Left Side Form -->
                        <div class="col-span-1 lg:col-span-7">
                            <div class="bg-white border border-[#e6e9ef] rounded-xl overflow-hidden shadow-sm flex flex-col">
                                
                                <!-- Card Header -->
                                <div class="bg-gradient-to-r from-[#0d6efd] to-[#0b5ed7] text-white px-5 py-4 flex items-center justify-between">
                                    <div class="flex items-center gap-2.5">
                                        <i class="fa-solid fa-file-pen text-base"></i>
                                        <h4 class="mb-0 text-[1rem] font-semibold tracking-wide">Shift Information</h4>
                                    </div>
                                    <asp:Label ID="Label8" runat="server" CssClass="text-xs bg-white/20 px-2 py-1 rounded" Text="Label"></asp:Label>
                                </div>

                                <!-- Card Body -->
                                <div class="p-5 overflow-y-auto lg:max-h-[calc(100vh-210px)]">
                                    <asp:HiddenField ID="hfUserId" runat="server" />

                                    <!-- Main Form Grid (Changed to md:grid-cols-4 for true 4-column layout) -->
                                    <div class="grid grid-cols-1 md:grid-cols-4 gap-x-4 gap-y-4">
                                        
                                        <!-- Top Row Elements (Col-span managed smoothly) -->
                                        <div class="flex flex-col md:col-span-2">
                                            <asp:Label ID="Label1" runat="server" AssociatedControlID="txtShiftId" Text="Shift ID" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:TextBox ID="txtShiftId" ReadOnly="true" runat="server" 
                                                CssClass="w-full bg-[#f3f4f6] text-[#6b7280] border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none shadow-sm cursor-not-allowed" />
                                        </div>

                                        <div class="flex flex-col md:col-span-2">
                                            <asp:Label ID="Label2" runat="server" AssociatedControlID="ddlNightPolicy" Text="Shift Type" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:DropDownList ID="ddlNightPolicy" runat="server"
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm appearance-none bg-[url('data:image/svg+xml;charset=US-ASCII,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22292.4%22%20height%3D%22292.4%22%3E%3Cpath%20fill%3D%22%236b7280%22%20d%3D%22M287%2069.4a17.6%2017.6%200%200%200-13-5.4H18.4c-5%200-9.3%201.8-12.9%205.4A17.6%2017.6%200%200%200%200%2082.2c0%205%201.8%209.3%205.4%2012.9l128%20127.9c3.6%203.6%207.8%205.4%2012.8%205.4s9.2-1.8%2012.8-5.4L287%2095c3.5-3.5%205.4-7.8%205.4-12.8%200-5-1.9-9.2-5.5-12.8z%22%2F%3E%3C%2Fsvg%3E')] bg-[length:12px_12px] bg-[right_12px_center] bg-no-repeat pr-10">
                                                <asp:ListItem Text="-- Select --" Value="0" />                            
                                                <asp:ListItem Text="Day" Value="1" />
                                                <asp:ListItem Text="Night" Value="2" />                                            
                                            </asp:DropDownList>
                                        </div>

                                        <div class="flex flex-col md:col-span-4">
                                            <asp:Label ID="Label4" runat="server" AssociatedControlID="txtShiftName" Text="Shift Name" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:TextBox ID="txtShiftName" runat="server" 
                                                CssClass="w-full bg-white text-[#1f2937] border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" 
                                                placeholder="Enter shift name">
                                            </asp:TextBox>
                                        </div>                       

                                        <!-- Time Grid - Row 1 -->
                                        <div class="flex flex-col">
                                            <asp:Label ID="Label3" runat="server" AssociatedControlID="txtShiftStart" Text="Shift In Time" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:TextBox ID="txtShiftStart" textMode="Time" runat="server" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <div class="flex flex-col">
                                            <asp:Label ID="Label9" runat="server" AssociatedControlID="txtShiftEnd" Text="Shift Out Time" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:TextBox ID="txtShiftEnd" textMode="Time" runat="server" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <div class="flex flex-col">
                                            <asp:Label ID="Label10" runat="server" AssociatedControlID="txtOutTime" Text="Shift Start Time" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:TextBox ID="txtInTime" textMode="Time" runat="server" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <div class="flex flex-col">
                                            <asp:Label ID="Label5" runat="server" AssociatedControlID="txtOutTime" Text="Shift End Time" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:TextBox ID="txtOutTime" textMode="Time" runat="server" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <!-- Time Grid - Row 2 -->
                                        <div class="flex flex-col">
                                            <asp:Label ID="Label6" runat="server" AssociatedControlID="txtLunchStart" Text="Lunch Start" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:TextBox ID="txtLunchStart" textMode="Time" runat="server" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <div class="flex flex-col">
                                            <asp:Label ID="Label11" runat="server" AssociatedControlID="txtLunchEnd" Text="Lunch End" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:TextBox ID="txtLunchEnd" textMode="Time" runat="server" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <div class="flex flex-col">
                                            <asp:Label ID="Label7" runat="server" AssociatedControlID="txtLateStart" Text="Late Start" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:TextBox ID="txtLateStart" textMode="Time" runat="server" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <div class="flex flex-col">
                                            <asp:Label ID="Label12" runat="server" AssociatedControlID="txtEarlyExit" Text="Early Exit" class="font-semibold text-[0.85rem] text-[#374151] mb-1.5"></asp:Label>
                                            <asp:TextBox ID="txtEarlyExit" textMode="Time" runat="server" 
                                                CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all shadow-sm" />
                                        </div>

                                        <!-- Status Checkbox Row -->
                                        <div class="flex items-center md:col-span-4 pt-2">
                                            <div class="flex items-center gap-2 bg-gray-50 border border-dashed border-[#d7dce3] px-3 py-2 rounded-lg">
                                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="w-4 h-4 rounded text-[#198754] border-gray-300 accent-[#198754] cursor-pointer" />
                                                <asp:Label runat="server" AssociatedControlID="chkIsActive" Text="Is Active?" class="font-semibold text-[0.85rem] text-[#374151] cursor-pointer select-none" />
                                            </div>
                                        </div>

                                    </div>

                                    <!-- Action Buttons -->
                                    <div class="border-t border-[#e6e9ef] mt-5 pt-4 flex flex-col sm:flex-row justify-between items-center gap-3">
                                        <div class="flex gap-2 w-full sm:w-auto">
                                            <asp:Button ID="btnRefresh" runat="server" Text="Refresh" 
                                                CssClass="w-full sm:w-auto font-semibold text-[0.9rem] px-5 py-2.5 rounded-lg text-white bg-gradient-to-r from-[#20c997] to-[#1aa179] border-none cursor-pointer hover:shadow-sm active:scale-95 transition-all" OnClick="btnRefresh_Click" />
                                        </div>

                                        <div class="flex gap-3 w-full sm:w-auto">
                                            <asp:Button ID="btnClose" runat="server" Text="Close" 
                                                CssClass="w-full sm:w-auto font-semibold text-[0.9rem] px-5 py-2.5 rounded-lg text-white bg-gradient-to-r from-[#dc3545] to-[#bb2d3b] border-none cursor-pointer hover:shadow-sm active:scale-95 transition-all" />
                                            
                                            <asp:Button ID="btnSave" runat="server" Text="Save" 
                                                CssClass="w-full sm:w-auto font-semibold text-[0.9rem] px-5 py-2.5 rounded-lg text-white bg-gradient-to-r from-[#198754] to-[#157347] border-none cursor-pointer hover:shadow-sm active:scale-95 transition-all" OnClick="btnSave_Click" />
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
                                    <i class="fa-solid fa-list-check text-base"></i>
                                    <h4 class="mb-0 text-[1rem] font-semibold tracking-wide">Shift List</h4>
                                </div>

                                <asp:GridView ID="gvShift" runat="server" AutoGenerateColumns="false" CssClass="w-full border-collapse text-[0.88rem]" Width="100%" OnSelectedIndexChanged="gvShift_SelectedIndexChanged">
                                    <Columns>
                                        <%-- ১. Select বাটন কলাম --%>
                                        <asp:TemplateField HeaderText="Action" HeaderStyle-CssClass="w-[80px] text-center" ItemStyle-CssClass="text-center">
                                            <ItemTemplate>
                                                <asp:LinkButton ID="btnSelect" runat="server" CommandName="Select" 
                                                    CssClass="inline-flex items-center justify-center bg-blue-50 text-[#0d6efd] hover:bg-[#0d6efd] hover:text-white px-2.5 py-1 rounded font-medium text-xs transition-colors shadow-sm">
                                                    <i class="fa-solid fa-arrow-pointer mr-1"></i> Select
                                                </asp:LinkButton>
                                            </ItemTemplate>
                                        </asp:TemplateField>

                                        <%-- ২. Shift ID কলাম (ডেটাবেজের Shift_Code) --%>
                                        <asp:BoundField DataField="Shift_Code" HeaderText="Shift ID" 
                                            HeaderStyle-CssClass="text-left font-semibold" 
                                            ItemStyle-CssClass="text-left font-mono font-medium text-gray-700" />

                                        <%-- ৩. Shift Name কলাম (ডেটাবেজের Shift_Name) --%>
                                        <asp:BoundField DataField="Shift_Name" HeaderText="Shift Name" 
                                            HeaderStyle-CssClass="text-left font-semibold" 
                                            ItemStyle-CssClass="text-left text-gray-800" />

                                        <%-- ৪. Is Active কলাম (কুয়েরি থেকে জেনারেট হওয়া IsActive ফ্ল্যাগ) --%>
                                        <asp:TemplateField HeaderText="Is Active" HeaderStyle-CssClass="w-[100px] text-center" ItemStyle-CssClass="text-center">
                                            <ItemTemplate>
                                                <span class='<%# Convert.ToBoolean(Eval("IsActive")) ? "inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-green-100 text-green-800" : "inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-red-100 text-red-800" %>'>
                                                    <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Inactive" %>
                                                </span>
                                            </ItemTemplate>
                                        </asp:TemplateField>
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