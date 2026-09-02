<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyProduction&RejectionEntry.aspx.cs" Inherits="Nexa_ERP.Production.ProductionListEntryDashboard.DailyProduction_RejectionEntry" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Daily Production & Rejection Entry</title>
    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />
</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2" >
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#255C8C] flex justify-center items-center rounded-t-lg px-4 py-2">
                <p class="text-white text-xl font-medium">Daily Production & Rejection Entry</p>
            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />
                <asp:HiddenField ID="hfTargetId" runat="server" />

                <%-- Filter / Entry section --%>
                <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400">

                    <div class="grid grid-cols-6 gap-x-3 gap-y-2">

                        <%-- row 1 : Prod. Type, Company, Section, Floor, MC/Line, Date --%>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Prod. Type</label>
                            <asp:DropDownList ID="DropDownList1" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select Type--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Company</label>
                            <asp:DropDownList ID="DropDownList2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select Company--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Section</label>
                            <asp:DropDownList ID="DropDownList3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select Section--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Floor</label>
                            <asp:DropDownList ID="DropDownList4" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">MC/Line</label>
                            <asp:TextBox ID="TextBox1" placeholder="MC/Line" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Date</label>
                            <asp:TextBox ID="TextBox2" placeholder="Date" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>

                        <%-- row 2 : Item, Customer, WO Ref. No (2 cols), WO No (2 cols) --%>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Item</label>
                            <asp:DropDownList ID="DropDownList5" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select Item--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Customer</label>
                            <asp:DropDownList ID="DropDownList6" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select Customer--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full col-span-2">
                            <label class="text-sm font-medium">WO Ref. No</label>
                            <asp:TextBox ID="TextBox3" placeholder="--Search WO Ref. No--" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full col-span-2">
                            <label class="text-sm font-medium">WO No</label>
                            <asp:TextBox ID="TextBox4" placeholder="--Search WO No--" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>

                        <%-- row 3 : Previous, Balance, Process, Prod. Qty (+Pcs), Rejection (+Pcs), Add --%>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Previous</label>
                            <asp:TextBox ID="TextBox5" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 bg-gray-200 px-2 py-1 shadow-sm"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Balance</label>
                            <asp:TextBox ID="TextBox6" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 bg-gray-200 px-2 py-1 shadow-sm"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Process</label>
                            <asp:DropDownList ID="DropDownList7" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                <asp:ListItem Value="" Selected="True">--Select Process--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Prod. Qty</label>
                            <div class="flex gap-1">
                                <asp:TextBox ID="TextBox7" placeholder="Prod. Qty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                <asp:TextBox ID="TextBox8" runat="server" Text="Pcs" CssClass="w-14 shrink-0 border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 text-center shadow-sm"></asp:TextBox>
                            </div>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Rejection</label>
                            <div class="flex gap-1">
                                <asp:TextBox ID="TextBox9" placeholder="Rejection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                <asp:TextBox ID="TextBox10" runat="server" Text="Pcs" CssClass="w-14 shrink-0 border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 text-center shadow-sm"></asp:TextBox>
                            </div>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full justify-end">
                            <asp:LinkButton ID="LinkButton1" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center h-[34px] w-full">
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

                </div>
            </div>
        </div>
    </form>
</body>
</html>

