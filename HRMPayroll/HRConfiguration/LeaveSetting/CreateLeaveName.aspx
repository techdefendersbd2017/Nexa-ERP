<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateLeaveName.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.LeaveSetting.CreateLeaveName" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Create Leave Name</title>
</head>

<!-- tailwind css link -->
<script src="https://cdn.tailwindcss.com"></script>

<style>
    /* GridView Custom Styling */
    .grid-view {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.85rem;
    }

    .grid-view th {
        position: sticky;
        top: 0;
        background: #0d6efd;
        color: #fff;
        font-weight: 600;
        font-size: 0.78rem;
        text-transform: uppercase;
        letter-spacing: 0.4px;
        padding: 10px 12px;
        text-align: left;
        border-bottom: 1px solid #e5e7eb;
        z-index: 10;
    }

    .grid-view td {
        padding: 8px 12px;
        border-bottom: 1px solid #e5e7eb;
        color: #374151;
        vertical-align: middle;
    }

    .grid-view tbody tr:hover {
        background-color: #eff6ff;
    }

    .grid-view a {
        color: #0d6efd;
        font-weight: 600;
        text-decoration: none;
        padding: 3px 10px;
        border: 1px solid #0d6efd;
        border-radius: 5px;
        font-size: 0.78rem;
        transition: all 0.15s ease;
    }

    .grid-view a:hover {
        background-color: #0d6efd;
        color: #fff;
    }
</style>

<body class="bg-gray-100">
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Create Leave Name</p>
                <p class="">HRM Configuration &rsaquo; Leave Setting &rsaquo; Leave Name</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="grid grid-cols-3 gap-x-4 gap-y-1.5">
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label9" runat="server" Text="Leave ID"></asp:Label>
                        <asp:TextBox ID="txtLeaveId" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out bg-gray-100"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label1" runat="server" Text="Leave Name"></asp:Label>
                        <asp:TextBox ID="txtLeaveNameEnglish" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label2" runat="server" Text="Bangla Name"></asp:Label>
                        <asp:TextBox ID="txtLeaveNameBangla" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label3" runat="server" Text="Short Name"></asp:Label>
                        <asp:TextBox ID="txtLeaveNameShort" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label7" runat="server" Text="Leave Days"></asp:Label>
                        <asp:TextBox ID="txtTotalLeaveDays" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Labe8" runat="server" Text="Sex"></asp:Label>
                        <asp:DropDownList ID="ddlSex" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out bg-white"></asp:DropDownList>
                    </div>                    
                </div>

                <!-- btn -->
                <div class="space-x-4 flex justify-between items-center my-4">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="inline-block rounded bg-[#20c997] text-white px-4 py-1 shadow-sm hover:bg-[#1aa179] cursor-pointer transition delay-150 duration-300 ease-in-out" OnClick="btnRefresh_Click" />

                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="rounded bg-[#198754] text-white px-4 py-1 shadow-sm hover:bg-[#146c43] cursor-pointer transition delay-150 duration-300 ease-in-out" OnClick="btnSave_Click" />
                    </div>
                </div>

                <!-- text grid 1st -->
                <div class="border border-gray-400 bg-gray-50 rounded w-full h-72 overflow-auto">
                    <asp:GridView ID="GridView1"
                        runat="server"
                        CssClass="grid-view"
                        AutoGenerateColumns="False"
                        DataKeyNames="Leave_code"
                        GridLines="None"
                        Width="100%"
                        OnSelectedIndexChanged="GridView1_SelectedIndexChanged">

                        <Columns>
                            <asp:CommandField ShowSelectButton="True" SelectText="Select">
                                <ItemStyle Width="90px" />
                            </asp:CommandField>

                            <asp:BoundField DataField="Leave_code" HeaderText="ID" />

                            <asp:BoundField DataField="Leave_Name" HeaderText="Leave Name" />

                            <asp:BoundField DataField="Leave_Name_Bangla" HeaderText="Bangla Name" />

                            <asp:BoundField DataField="Short_Name" HeaderText="Short Name" />

                            <asp:BoundField DataField="Leave_Days" HeaderText="Days" />
                        </Columns>

                    </asp:GridView>
                </div>

            </div>
        </div>
    </form>
</body>
</html>