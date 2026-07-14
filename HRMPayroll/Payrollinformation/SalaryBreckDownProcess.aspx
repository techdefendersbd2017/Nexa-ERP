<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SalaryBreckDownProcess.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.Payrollinformation.SalaryBreckDownProcess" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Salary Breck Down Process</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Salary Breck Down Process</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="">
                    <asp:HiddenField ID="HiddenField1" runat="server" />

                    <div class="grid grid-cols-6 gap-x-4 gap-y-2">

                        <!-- text grid 1st -->
                        <div class="border border-gray-400 bg-gray-50 shadow-xl rounded w-full min-h-screen overflow-y-auto col-span-5">
                            <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                        </div>

                        <!-- btn -->
                        <div class="space-y-4 flex flex-col my-4">
                            <div class="flex items-center gap-3">
                                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#2BBBAD] text-white px-4 py-1 shadow-sm hover:bg-[#239A8D] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <div class="flex items-center gap-1">
                                    <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                    <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                                </div>
                            </div>
                            <div class="flex flex-col gap-3">

                                <asp:Button ID="btnSelectAll" runat="server" Text="Select All" CssClass="rounded bg-[#3b82f6] text-white px-4 py-1 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnNoSelect" runat="server" Text="No Select" CssClass="rounded bg-[#3b82f6] text-white px-4 py-1 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnProcess" runat="server" Text="Process" CssClass="rounded bg-[#2FBF71] text-white px-4 py-1 shadow-sm hover:bg-[#26A65B] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            </div>
                        </div>


                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
