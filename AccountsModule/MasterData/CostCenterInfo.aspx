<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CostCenterInfo.aspx.cs" Inherits="Nexa_ERP.AccountsModule.MasterData.CostCenterInfo" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Cost Center Group Information</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { 
            background-color: #f3f4f6; 
            font-family: 'Inter', sans-serif; 
            padding: 10px;
        }
        
        .main-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            max-width: 1400px;
            margin: 0 auto;
        }

        .header-blue {
            background-color: #2563eb;
            color: white;
            padding: 12px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .header-blue h1 { font-size: 18px; font-weight: 700; }
        .header-blue p { font-size: 12px; opacity: 0.9; }

        .content-wrapper {
            display: grid;
            grid-template-columns: 400px 1fr; /* ফর্মের জন্য ফিক্সড উইডথ যাতে গ্রিড বড় জায়গা পায় */
            gap: 15px;
            padding: 15px;
        }

        .form-label {
            display: block;
            font-size: 12px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 2px;
        }
        .form-control-custom {
            width: 100%;
            padding: 6px 10px;
            border: 1px solid #d1d5db;
            border-radius: 4px;
            font-size: 13px;
            background-color: #f9fafb;
            margin-bottom: 10px;
            outline: none;
        }

        .grid-container {
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            background: white;
            padding: 10px;
            height: fit-content;
        }
        
        .custom-grid {
            width: 100%;
            border-collapse: collapse;
        }
        .custom-grid th {
            background-color: #f9fafb;
            color: #4b5563;
            font-size: 11px;
            text-transform: uppercase;
            padding: 8px;
            border-bottom: 2px solid #e5e7eb;
            text-align: left;
        }
        .custom-grid td {
            padding: 8px;
            border-bottom: 1px solid #f3f4f6;
            font-size: 12px;
        }

        .btn-action {
            padding: 6px 16px;
            border-radius: 4px;
            font-weight: 600;
            font-size: 13px;
            color: white;
            cursor: pointer;
            border: none;
        }
        .btn-save { background-color: #10b981; } 
        .btn-update { background-color: #f59e0b; } 
        .btn-clear { background-color: #64748b; } 
        .btn-delete { background-color: #ef4444; } 
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="main-card">
            <!-- Header Section -->
            <div class="header-blue">
                <div>
                    <h1>Cost Center Information</h1>
                    <p>Manage organization cost center groups</p>
                </div>
                <span class="bg-blue-700 text-[10px] px-2 py-1 rounded">ERP v2.0</span>
            </div>

            <div class="content-wrapper">
                <!-- Left Side: Form (Compact) -->
                <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
                    <div class="flex gap-2">
                        <div class="w-1/3">
                            <label class="form-label">ID</label>
                            <asp:TextBox ID="txtdepartmentID" runat="server" CssClass="form-control-custom bg-gray-200" ReadOnly="true" placeholder="ID"></asp:TextBox>
                        </div>
                        <div class="w-2/3">
                            <label class="form-label">Cost Code</label>
                            <asp:TextBox ID="TextBox2" runat="server" CssClass="form-control-custom" placeholder="e.g. 1"></asp:TextBox>
                        </div>
                    </div>

                    <label class="form-label">Cost Center Name</label>
                    <asp:TextBox ID="TextBox1" runat="server" CssClass="form-control-custom" placeholder="Enter group name"></asp:TextBox>

                    <!-- Row-based Dropdowns to save vertical space -->
                    <div class="space-y-3 mb-4">
                        <div>
                            <div class="flex justify-between items-center">
                                <label class="form-label">Branch</label>
                                <asp:LinkButton ID="LinkButton1" runat="server" OnClick="DropDownList1_SelectedIndexChanged" CssClass="text-[10px] text-blue-600">Refresh</asp:LinkButton>
                            </div>
                            <asp:DropDownList ID="DropDownList1" runat="server" AutoPostBack="True" CssClass="form-control-custom mb-0 h-9">
                                <asp:ListItem Text="Select Branch" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div>
                            <div class="flex justify-between items-center">
                                <label class="form-label">Office Name</label>
                                <asp:LinkButton ID="LinkButton2" runat="server" OnClick="DropDownList2_SelectedIndexChanged" CssClass="text-[10px] text-blue-600">Refresh</asp:LinkButton>
                            </div>
                            <asp:DropDownList ID="DropDownList2" runat="server" AutoPostBack="True" CssClass="form-control-custom mb-0 h-9">
                                <asp:ListItem Text="Select Office" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div>
                            <div class="flex justify-between items-center">
                                <label class="form-label">Department/Section</label>
                                <asp:LinkButton ID="LinkButton3" runat="server" OnClick="DropDownList3_SelectedIndexChanged" CssClass="text-[10px] text-blue-600">Refresh</asp:LinkButton>
                            </div>
                            <asp:DropDownList ID="DropDownList3" runat="server" AutoPostBack="True" CssClass="form-control-custom mb-0 h-9">
                                <asp:ListItem Text="Select Department" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <label class="form-label">Remarks</label>
                    <asp:TextBox ID="TextBox4" runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control-custom" placeholder="Optional notes..."></asp:TextBox>

                    <div class="flex items-center mb-4">
                        <asp:CheckBox ID="CheckBox1" runat="server" class="w-4 h-4 text-blue-600" Checked="True"/>
                        <span class="ml-2 text-xs font-medium text-gray-700">Is Active?</span>
                    </div>

                    <div class="grid grid-cols-2 gap-2">
                        <asp:Button ID="btnsave" runat="server" Text="Save" CssClass="btn-action btn-save w-full" OnClick="btnsave_Click" />
                        <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn-action btn-update w-full" OnClick="btnUpdate_Click" />
                        <asp:Button ID="Button2" runat="server" Text="Clear" CssClass="btn-action btn-clear w-full" OnClick="Button2_Click" />
                        <asp:Button ID="Button3" runat="server" Text="Delete" CssClass="btn-action btn-delete w-full" OnClick="Button3_Click" />
                    </div>
                </div>

                <!-- Right Side: Grid (Expanded) -->
                <div class="grid-container">
                    <div class="flex justify-between items-center mb-2">
                        <h2 class="text-sm font-bold text-gray-800">Cost Center List</h2>
                        <span class="text-[9px] bg-green-100 text-green-700 px-2 py-0.5 rounded-full border border-green-200">LIVE</span>
                    </div>  
                    <div class="overflow-x-auto border rounded border-gray-100">
                        <asp:GridView ID="GridViewCostCenterInfo" runat="server" CssClass="custom-grid"
                            AutoGenerateColumns="False" DataKeyNames="CostCenterID" OnSelectedIndexChanged="GridViewCostCenterInfo_SelectedIndexChanged">
                            <Columns>
                                <asp:CommandField ShowSelectButton="True" SelectText="Edit" ControlStyle-CssClass="text-blue-600 font-medium" />
                                <asp:BoundField DataField="CostCenterID" HeaderText="ID" />
                                <asp:BoundField DataField="CostCenertName" HeaderText="Cost Center Name" />
                                <asp:BoundField DataField="Remarks" HeaderText="Remarks" />
                                <asp:CheckBoxField DataField="iS_Active" HeaderText="Active" />
                            </Columns>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>