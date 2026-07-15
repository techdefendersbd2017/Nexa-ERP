<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyPieceCuttingEntry.aspx.cs" Inherits="Nexa_ERP.Production.Cutting.DailyPieceCuttingEntry" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Piece Cutting Entry</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Piece Cutting Entry</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="grid grid-cols-12 gap-y-1">

                    <div class="flex flex-col gap-0.5 w-full col-span-4">
                        <label class="whitespace-nowrap">Piece Cutting ID</label>
                        <asp:TextBox ID="txtPieceCuttingId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>

                </div>

                <div class="grid grid-cols-12 space-x-3 mt-2 h-full">

                    <%-- Master info --%>
                    <div class="col-span-4">
                        <fieldset class="border border-gray-400 rounded w-full p-2 flex flex-1 h-full">
                            <legend class="italic text-sm px-2 font-medium">Master Info</legend>

                            <div class="grid grid-cols-2 gap-x-2 gap-y-1 w-full">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Cutting Floor</label>
                                    <asp:DropDownList ID="ddlCuttingFloor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Line</label>
                                    <asp:TextBox ID="txtLine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Emp. Details</label>
                                    <asp:TextBox ID="txtEmployeeDetails" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Cutting Date</label>
                                    <asp:DropDownList ID="ddlCuttingDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Cutting Type</label>
                                    <asp:DropDownList ID="ddlCuttingType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Cutting No</label>
                                    <asp:TextBox ID="txtCuttingNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full col-span-2">
                                    <label>Remarks</label>
                                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                            </div>

                        </fieldset>
                    </div>

                    <%-- Details info --%>
                    <div class="col-span-8">
                        <fieldset class="border border-gray-400 rounded w-full p-2">
                            <legend class="italic text-sm px-2 font-medium">Details Info</legend>

                            <div class="grid grid-cols-4 gap-x-2 gap-y-1 w-full">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Buyer</label>
                                    <asp:TextBox ID="txtBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>PO No</label>
                                    <asp:TextBox ID="txtPoNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Style No</label>
                                    <asp:TextBox ID="txtStyleNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Color</label>
                                    <asp:DropDownList ID="ddlColor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Size</label>
                                    <asp:DropDownList ID="ddlSize" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Roll No</label>
                                    <asp:TextBox ID="txtRollNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>GSM</label>
                                    <asp:TextBox ID="txtGSM" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Weight</label>
                                    <asp:TextBox ID="txtWeight" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Qty</label>
                                    <asp:TextBox ID="txtQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Bundle Qty</label>
                                    <asp:TextBox ID="txtBundleQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Min Bundle</label>
                                    <asp:TextBox ID="txtMinBundle" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Order Place.</label>
                                    <asp:DropDownList ID="ddlOrdePLace" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Delivery</label>
                                    <asp:DropDownList ID="ddlDelivery" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Lot/Batch</label>
                                    <asp:TextBox ID="txtLotOrBatch" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex gap-x-0.5 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Length</label>
                                        <asp:TextBox ID="txtLength" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <asp:DropDownList ID="ddlLength" runat="server" CssClass="w-32 border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex gap-x-0.5 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Width</label>
                                        <asp:TextBox ID="txtWidth" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <asp:DropDownList ID="ddlWidth" runat="server" CssClass="w-32 border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex justify-end items-end col-span-4">
                                    <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#0d6efd] text-white px-4 py-0.5 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                            </div>
                        </fieldset>
                    </div>
                </div>



                <%-- middle Container --%>
                <div class="mt-3 grid grid-cols-12 space-x-3">

                    <%-- search --%>

                    <div class="col-span-12 flex flex-col space-y-0.5 items-center">

                        <div class="border border-gray-400 rounded w-full bg-[#2BBBAD] text-white text-center">
                            <asp:Label ID="Label1" runat="server" Text="Search"></asp:Label>
                        </div>

                        <div class="grid grid-cols-12 border border-gray-400 rounded w-full">

                            <div class="col-span-4 w-full p-2">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Search Type</label>
                                    <asp:DropDownList ID="ddlSearchType" runat="server" CssClass="border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                            </div>

                            <div class="col-span-8 p-2 w-full">
                                <div class="border border-gray-400 bg-gray-300 rounded w-full h-72 flex-1 flex-grow overflow-y-auto overflow-x-auto">
                                    <asp:ListView ID="ListView50" runat="server"></asp:ListView>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>



                <%-- total grid view --%>
                <div class="border border-gray-400 bg-gray-300 rounded w-full h-80 overflow-y-auto overflow-x-auto mt-2 mb-1">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                </div>


                <%-- total input --%>
                <div class="flex flex-col gap-0.5 w-full">
                    <label>Total Cutting Qty</label>
                    <asp:TextBox ID="txtTotalCuttingQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                </div>

                <!--below  btn -->
                <div class="space-x-4 flex justify-between items-center mt-3">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#2BBBAD] text-white px-4 py-1 shadow-sm hover:bg-[#239A8D] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">

                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="rounded bg-[#22C55E] text-white px-4 py-1 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#E55353] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="rounded bg-[#E55353] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                    </div>
                </div>

            </div>


        </div>
    </form>
</body>
</html>







