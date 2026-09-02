<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyTargetEntry.aspx.cs" Inherits="Nexa_ERP.Production.ProductionListEntryDashboard.DailyTargetEntry" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Daily Target Entry</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#255C8C] flex justify-center items-center rounded-t-lg px-4 py-2">
                <p class="text-white text-xl font-medium">Daily Target Entry</p>
            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />
                <asp:HiddenField ID="hfTargetId" runat="server" />

                <%-- main entry fields box --%>
                <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400">
                    <div class="grid grid-cols-6 gap-x-2">

                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Company</label>
                            <asp:TextBox ID="txtCompany" placeholder="Company" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Section</label>
                            <asp:TextBox ID="txtSection" placeholder="Section" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Floor</label>
                            <asp:TextBox ID="txtFloor" placeholder="Floor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Target Date</label>
                            <asp:TextBox ID="txtTargetDate" placeholder="Target Date" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>

                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Target Hour</label>
                            <asp:TextBox ID="txtTargetHour" placeholder="Target Hour" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Target Eff%</label>
                            <asp:TextBox ID="txtTargetEff" placeholder="Target Eff%" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <%-- Details Info + GridView --%>
                <div class="flex gap-3 mt-3">

                    <%-- Details Info left Side --%>
                    <div class="w-64 shrink-0 bg-gray-50 p-2 rounded border border-gray-400">
                        <p class="text-sm font-semibold text-center mb-2 text-gray-700">Details Info</p>
                        <div class="flex flex-col gap-2">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">WO Qty</label>
                                <asp:TextBox ID="txtWOQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Pro. Done</label>
                                <asp:TextBox ID="txtProDone" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Balance</label>
                                <asp:TextBox ID="txtBalance" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <%-- Gridview  --%>
                    <div class="border border-gray-400 bg-gray-100 rounded w-full h-64 flex-1 overflow-y-auto overflow-x-auto">
                        <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                    </div>
                </div>

                <%-- Bottom Input box --%>
                <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400 mt-5">
                    <div class="flex gap-x-2 gap-y-1 items-end">
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">WO Ref. No</label>
                            <asp:TextBox ID="TextBox1" placeholder="WO Ref. No" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <div class="flex items-center gap-5">
                                <label class="text-sm font-medium">Item</label>
                                <asp:CheckBox ID="CheckBox1" runat="server" Text="Load All" CssClass="text-sm whitespace-nowrap" />
                            </div>
                            <asp:TextBox ID="TextBox2" placeholder="Item" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Color</label>
                            <asp:TextBox ID="TextBox3" placeholder="Color" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <div class="flex items-center gap-5">
                                <label class="text-sm font-medium">Size</label>
                                <asp:CheckBox ID="CheckBox2" runat="server" Text="Load All" CssClass="text-sm whitespace-nowrap" />
                            </div>
                            <asp:TextBox ID="TextBox4" placeholder="Size" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Req. Qty</label>
                            <asp:TextBox ID="TextBox5" placeholder="Req. Qty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Req. Hour</label>
                            <asp:TextBox ID="TextBox6" placeholder="Req. Hour" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>

                        <%-- add button --%>
                        <div class="flex flex-col gap-0.5 w-max shrink-0">
                            <asp:LinkButton ID="btnAdd" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center h-[34px] whitespace-nowrap">
                                <i class="fa-solid fa-plus"></i>
                                <span>Add</span>
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>

                <%-- Bottom Gridview  --%>
                <div class="border border-gray-400 bg-gray-100 rounded w-full h-64 flex-1 overflow-y-auto overflow-x-auto mt-3">
                    <asp:GridView ID="GridView2" runat="server"></asp:GridView>
                </div>

                <%-- bottom action buttons + Total Target --%>
                <div class="flex justify-between items-center mt-4">

                    <div class="space-x-3 flex items-end">
                        <asp:LinkButton ID="btnSave" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-save"></i>
                            <span>Save</span>
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnClear" runat="server" CssClass="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-eraser"></i>
                            <span>Clear</span>
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnPrint" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#E0A800] text-white px-4 py-1.5 shadow-sm hover:bg-[#c69500] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-print"></i>
                            <span>Print</span>
                        </asp:LinkButton>
                    </div>

                    <div class="flex items-center gap-2">
                        <label class="text-sm font-semibold">Total Target</label>
                        <asp:TextBox ID="txtTotalTarget" runat="server" ReadOnly="true" Text="0" CssClass="w-20 border rounded outline-none border-gray-300 bg-gray-200 px-2 py-1 text-center font-semibold shadow-sm"></asp:TextBox>
                    </div>

                </div>

            </div>
        </div>
    </form>
</body>
</html>
