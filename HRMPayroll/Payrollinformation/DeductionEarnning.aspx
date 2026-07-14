<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeductionEarnning.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.Payrollinformation.DeductionEarnning" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Deducting Or Earning</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Deduction Or Earning</p>
                <p class="">Label</p>
            </div>



            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="grid grid-cols-2 gap-x-4 gap-y-1.5">
                    <div class="space-y-4 flex flex-col flex-grow">
                        <div class="grid grid-cols-2 gap-x-4 gap-y-1.5">

                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Deducting Or Earning ID</label>
                                <asp:TextBox ID="txtDeductingOrEarningId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Mode</label>
                                <asp:DropDownList ID="ddlMode" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Type</label>
                                <asp:DropDownList ID="ddlType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Eff. Date</label>
                                <asp:DropDownList ID="ddlEffDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex gap-x-3 col-span-2">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Amount</label>
                                    <asp:TextBox ID="txtAmount" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex gap-3 items-end">
                                    <div class="flex items-center gap-1 whitespace-nowrap">
                                        <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                                    </div>
                                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#22c55e] text-white px-4 py-0.5 shadow-sm hover:bg-[#16a34a] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#3b82f6] text-white px-4 py-0.5 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                    <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#ef4444] text-white px-4 py-0.5 shadow-sm hover:bg-[#dc2626] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                            </div>

                            <div class="col-span-2">
                                <fieldset class="border border-gray-400 rounded shadow-sm p-2">
                                    <legend class="px-2 text-sm font-medium italic">Group Box 1</legend>

                                    <div class="flex gap-x-3">
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label>Type</label>
                                            <asp:DropDownList ID="ddlGroupType1" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label>Type</label>
                                            <asp:DropDownList ID="ddlGroupType2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label>ID No</label>
                                            <asp:TextBox ID="txtIdNo" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex gap-3 items-end">
                                            <asp:Button ID="btnSelect" runat="server" Text="Select" CssClass="rounded bg-[#3b82f6] text-white px-4 py-0.5 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                            <asp:Button ID="clear" runat="server" Text="Clear" CssClass="rounded bg-[#6b7280] text-white px-4 py-0.5 shadow-sm hover:bg-[#4b5563] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                        </div>
                                    </div>
                                </fieldset>
                            </div>
                        </div>

                        <!-- text grid 1st -->
                        <div class="border border-gray-400 bg-gray-50 rounded w-full min-h-screen overflow-y-auto">
                            <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                        </div>
                    </div>


                    <!-- text grid 2st -->
                    <div>
                        <div class="border border-gray-400 bg-gray-50 rounded w-full h-full overflow-y-auto">
                            <asp:GridView ID="GridView2" runat="server"></asp:GridView>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </form>
</body>
</html>