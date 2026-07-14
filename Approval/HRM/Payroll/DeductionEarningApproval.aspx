<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeductionEarningApproval.aspx.cs" Inherits="Nexa_ERP.Approval.HRM.Payroll.DeductionEarningApproval" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Deduction Or Earning Approval</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Deduction Or Earning Approval</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />


                <div class="grid grid-cols-4 gap-x-4 gap-y-1.5">

                    <div class="flex flex-col gap-0.5 w-full col-span-2">
                        <asp:Label ID="Label1" runat="server" Text="Deduction ID"></asp:Label>
                        <asp:TextBox ID="txtDeductionId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Effe. Date</label>
                        <asp:DropDownList ID="ddlEffeDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Status</label>
                        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                </div>

                <!-- btn -->
                <div class="space-x-4 flex justify-between items-center my-4">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnShow" runat="server" Text="Show" CssClass="rounded bg-[#3b82f6] text-white px-4 py-1 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                       
                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">

                        <asp:Button ID="btnSelect" runat="server" Text="Select" CssClass="rounded bg-[#6366f1] text-white px-4 py-1 shadow-sm hover:bg-[#4f46e5] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="rounded bg-[#6b7280] text-white px-4 py-1 shadow-sm hover:bg-[#4b5563] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnConfirm" runat="server" Text="Confirm" CssClass="rounded bg-[#22c55e] text-white px-4 py-1 shadow-sm hover:bg-[#16a34a] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnReOpen" runat="server" Text="Re-Open" CssClass="rounded bg-[#f59e0b] text-white px-4 py-1 shadow-sm hover:bg-[#d97706] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#ef4444] text-white px-4 py-1 shadow-sm hover:bg-[#dc2626] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                    </div>
                </div>

                <!-- text grid 1st -->
                <div class="border border-gray-400 bg-gray-50 rounded w-full h-72 overflow-y-scroll">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                </div>

            </div>
        </div>
    </form>
</body>
</html>

