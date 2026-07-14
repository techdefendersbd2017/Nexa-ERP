<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JobDescription.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting.JobDescription" MaintainScrollPositionOnPostback="true" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Job Description - NexaERP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- Font Awesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    
    <!-- Google Font -->
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />

    <!-- jQuery & Select2 CSS -->
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
            background: linear-gradient(135deg, #0d6efd, #0b5ed7) !important;
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
            background-color: #f0f6ff;
        }

        /* Select2 Match with Tailwind */
        .select2-container--default .select2-selection--single {
            border-color: #d7dce3 !important;
            border-radius: 0.5rem !important;
            height: 42px !important;
            display: flex;
            align-items: center;
        }
        .select2-container--default .select2-selection--single .select2-selection__arrow {
            height: 40px !important;
        }
        .select2-container--default .select2-selection--single .select2-selection__rendered {
            color: #374151 !important;
            font-size: 0.92rem !important;
            padding-left: 12px !important;
        }
        .select2-dropdown {
            border-color: #d7dce3 !important;
            border-radius: 0.75rem !important;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
            z-index: 9999;
            padding: 6px !important;
        }
        .select2-container--default .select2-search--dropdown {
            padding: 6px 4px 8px 4px !important;
        }
        .select2-container--default .select2-search--dropdown .select2-search__field {
            border-color: #d7dce3 !important;
            border-radius: 9999px !important;
            padding: 8px 16px !important;
            outline: none !important;
            font-size: 0.88rem !important;
        }
        .select2-container--default .select2-search--dropdown .select2-search__field:focus {
            border-color: #0d6efd !important;
            box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.15) !important;
        }
        .select2-container--default .select2-results>.select2-results__options {
            max-height: 200px;
            overflow-y: auto;
        }
        .select2-results__option {
            padding: 8px 12px !important;
            border-radius: 0.375rem !important;
            font-size: 0.9rem;
        }
        .select2-container--default .select2-results__option--highlighted[aria-selected] {
            background-color: #0d6efd !important;
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
                <i class="fa-solid fa-briefcase text-lg text-[#0d6efd]"></i>
            </div>
            <div>
                <h3 class="m-0 font-bold text-[#111827] text-xl tracking-tight">Job Description</h3>
                <small class="block text-[#6b7280] font-normal text-xs mt-0.5">HRM Configuration &rsaquo; HRM Setting &rsaquo; Job Description</small>
                <asp:Label ID="Label99" runat="server" Text="Label" Visible="false"></asp:Label>
            </div>
        </div>

        <!-- UpdatePanel to prevent screen shaking -->
        <asp:UpdatePanel ID="UPJobDescription" runat="server">
            <ContentTemplate>

                <!-- Grid Layout (Form: 7 Columns, Grid: 5 Columns on Large Screens) -->
                <div class="grid grid-cols-1 lg:grid-cols-12 gap-5 items-start">

                    <!-- Left Side Form -->
                    <div class="col-span-1 lg:col-span-7">
                        <div class="bg-white border border-[#e6e9ef] rounded-xl overflow-hidden shadow-sm flex flex-col">
                            
                            <!-- Card Header -->
                            <div class="bg-gradient-to-r from-[#0d6efd] to-[#0b5ed7] text-white px-5 py-4 flex items-center gap-2.5">
                                <i class="fa-solid fa-file-pen text-base"></i>
                                <h4 class="mb-0 text-[1rem] font-semibold tracking-wide">Job Description Details</h4>
                            </div>

                            <!-- Card Body -->
                            <div class="p-5 overflow-y-auto lg:max-h-[calc(100vh-210px)]">
                                <asp:HiddenField ID="hfUserId" runat="server" />

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-x-4 gap-y-4">
                                    
                                    <div class="flex flex-col">
                                        <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Job Description ID</label>
                                        <asp:TextBox ID="txtJobDescriptionId" ReadOnly="true" runat="server" 
                                            CssClass="w-full bg-[#f3f4f6] text-[#6b7280] border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all" />
                                    </div>

                                    <div class="flex flex-col">
                                        <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Designation</label>
                                        <asp:DropDownList ID="ddlDesignation" runat="server" 
                                            CssClass="searchable-dropdown w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none transition-all" />
                                    </div>

                                    <div class="flex flex-col">
                                        <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Report To 1</label>
                                        <asp:DropDownList ID="ddlReportTo1" runat="server" 
                                            CssClass="searchable-dropdown w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none transition-all" />
                                    </div>

                                    <div class="flex flex-col">
                                        <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Report To 2</label>
                                        <asp:DropDownList ID="ddlReportTo2" runat="server" 
                                            CssClass="searchable-dropdown w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none transition-all" />
                                    </div>

                                    <div class="flex flex-col md:col-span-2">
                                        <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Purpose of The Work</label>
                                        <asp:TextBox ID="txtPurposeTheWork" TextMode="MultiLine" Rows="2" runat="server" 
                                            CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all resize-none" />
                                    </div>

                                    <div class="flex flex-col md:col-span-2">
                                        <label class="font-semibold text-[0.85rem] text-[#374151] mb-1.5">Responsibilities</label>
                                        <asp:TextBox ID="txtResponsibilities" TextMode="MultiLine" Rows="4" runat="server" 
                                            CssClass="w-full bg-white border border-[#d7dce3] rounded-lg px-3 py-2 text-[0.92rem] outline-none focus:border-[#0d6efd] focus:ring-2 focus:ring-blue-100 transition-all resize-none" />
                                    </div>

                                    <div class="flex items-center md:col-span-2 pt-1">
                                        <div class="flex items-center gap-2">
                                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="w-4 h-4 rounded text-[#198754] border-gray-300 accent-[#198754] cursor-pointer" />
                                            <asp:Label runat="server" AssociatedControlID="chkIsActive" Text="Is Active?" class="font-semibold text-[0.85rem] text-[#374151] cursor-pointer selective-none" />
                                        </div>
                                    </div>

                                </div>

                                <!-- Action Bar Buttons (Responsive Layout) -->
                                <div class="border-t border-[#e6e9ef] mt-5 pt-4 flex flex-col sm:flex-row justify-between items-center gap-3">
                                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" 
                                        CssClass="w-full sm:w-auto font-semibold text-[0.9rem] px-5 py-2.5 rounded-lg text-white bg-gradient-to-r from-[#198754] to-[#157347] border-none cursor-pointer hover:shadow-sm active:scale-95 transition-all" OnClick="btnRefresh_Click" />

                                    <div class="flex gap-3 w-full sm:w-auto">
                                        <asp:Button ID="btnUpdate" runat="server" Text="Update" 
                                            CssClass="w-full sm:w-auto flex-1 sm:flex-none font-semibold text-[0.9rem] px-5 py-2.5 rounded-lg text-white bg-gradient-to-r from-[#f59e0b] to-[#d97706] border-none cursor-pointer hover:shadow-sm active:scale-95 transition-all" OnClick="btnUpdate_Click" />
                                        
                                        <asp:Button ID="btnSave" runat="server" Text="Save" 
                                            CssClass="w-full sm:w-auto flex-1 sm:flex-none font-semibold text-[0.9rem] px-5 py-2.5 rounded-lg text-white bg-gradient-to-r from-[#198754] to-[#157347] border-none cursor-pointer hover:shadow-sm active:scale-95 transition-all" OnClick="btnSave_Click" />
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
                                <h4 class="mb-0 text-[1rem] font-semibold tracking-wide">Description List</h4>
                            </div>

                            <!-- Grid Wrapper with Responsive Max Height -->
                            <div class="grid-wrapper overflow-y-auto overflow-x-auto lg:max-h-[calc(100vh-210px)] min-h-[250px]">
                                <asp:GridView ID="gvJobDescription" runat="server" CssClass="w-full border-collapse text-[0.88rem]"
                                    AutoGenerateColumns="False" DataKeyNames="JobDescription_ID" Width="100%" OnSelectedIndexChanged="gvJobDescription_SelectedIndexChanged">
                                    <Columns>
                                        <asp:CommandField ShowSelectButton="True" SelectText="Select">
                                            <ItemStyle Width="70px" CssClass="text-blue-600 font-medium hover:underline cursor-pointer" />
                                        </asp:CommandField>
                                        <asp:BoundField DataField="JobDescription_ID" HeaderText="ID" />
                                        <asp:BoundField DataField="Desigation_name" HeaderText="Designation" />
                                        <asp:CheckBoxField DataField="IsActive" HeaderText="Status" />
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

<!-- Select2 Initialization Script -->
<script type="text/javascript">
    function initSelect2() {
        $('.searchable-dropdown').select2({
            width: '100%'
        });

        $('.searchable-dropdown').off('select2:open').on('select2:open', function () {
            setTimeout(function () {
                var searchField = document.querySelector('.select2-search__field');
                if (searchField) {
                    searchField.setAttribute('placeholder', 'Search...');
                }
            }, 1);
        });
    }

    $(document).ready(function () {
        initSelect2();
    });

    // Integrated perfectly with UpdatePanel PostBacks
    var prm = Sys.WebForms.PageRequestManager.getInstance();
    if (prm) {
        prm.add_endRequest(function () {
            initSelect2();
        });
    }
</script>
</body>
</html>