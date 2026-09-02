<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeemedExportLC.aspx.cs" Inherits="Nexa_ERP.Shipment.DeemedExportLC" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Deemed Export LC.</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">  

            <asp:HiddenField ID="hfUserId" runat="server" />
            <asp:HiddenField ID="hfLCId" runat="server" />

            <%-- LIST PANEL : Deemed Export LC List (opens first, always) --%>
            <asp:Panel ID="pnlList" runat="server">

                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Deemed Export LC List</p>
                    </div>
                    <div class="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] transition-all duration-200 px-2 py-1 rounded cursor-pointer">
                        <div class="cursor-pointer hover:bg-[#f1f5f9] transition-all duration-200">
                            <i class="fa-solid fa-plus text-gray-500 flex justify-center items-center"></i>
                        </div>

                        <asp:LinkButton ID="btnAddNew" runat="server" OnClick="btnAddNew_Click">Add New Deemed Export LC</asp:LinkButton>
                    </div>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- Input section --%>
                    <div class="flex flex-col gap-y-2 mb-2">

                        <%--1st row input --%>
                        <div class="flex gap-3">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Company</label>
                                <asp:DropDownList ID="ddlCompany" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Company--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Customer</label>
                                <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Customer--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">DMD Export LC No</label>
                                <asp:TextBox ID="txtDMDExportLCNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                        </div>

                        <%-- row 2 input --%>
                        <div class="flex gap-3 items-end">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">From</label>
                                <asp:TextBox ID="txtFromDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">To</label>
                                <asp:TextBox ID="txtToDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="w-full">
                                <asp:LinkButton ID="btnSearch" runat="server" CssClass="flex items-center justify-center rounded px-4 py-1.5 shadow-sm bg-[#2EB85C] text-white hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline w-full">
                                    <span>Search</span>
                                </asp:LinkButton>
                            </div>
                        </div>

                    </div>

                    <!--Gridview-->
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-96 flex-1 overflow-y-auto overflow-x-auto mt-2 mb-2">
                        <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                    </div>

                </div>
            </asp:Panel>

            <%-- ENTRY PANEL : Deemed Export LC Entry Page --%>
            <asp:Panel ID="pnlEntry" runat="server" Visible="false">

                <!--card name and button-->
                <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                    <div class="text-white">
                        <p class="text-xl mb-1 font-medium">Deemed Export LC Entry Page</p>
                    </div>
                    <div class="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] transition-all duration-200 px-2 py-1 rounded cursor-pointer">
                        <div class="cursor-pointer hover:bg-[#f1f5f9] transition-all duration-200">
                            <i class="fa-solid fa-arrow-left text-gray-500 flex justify-center items-center"></i>
                        </div>
                        <asp:LinkButton ID="btnBackToListHeader" runat="server" OnClick="btnBackToList_Click">Back To Deemed Export LC List</asp:LinkButton>
                    </div>
                </div>

                <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">

                    <%-- main container --%>
                    <div class="grid grid-cols-12 gap-2 rounded">

                        <%-- left : main LC info box --%>
                        <div class="col-span-7 bg-[#FBFCFE] p-2 rounded border border-gray-400 mt-3">
                            <div class="grid grid-cols-2 gap-x-3 gap-y-2">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Benificiary</label>
                                    <asp:DropDownList ID="ddlBeneficiary" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Commodity</label>
                                    <asp:TextBox ID="txtCommodity" runat="server" Text="Trims &amp; Accessories" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 shadow-sm"></asp:TextBox>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">LC No</label>
                                    <asp:TextBox ID="txtLCNo" placeholder="e.g LC No" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Issue Date</label>
                                    <asp:TextBox ID="txtIssueDate" placeholder="e.g Issue Date" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Export Date</label>
                                    <asp:TextBox ID="txtExportDate" placeholder="e.g Export Date" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Expeiry Date</label>
                                    <asp:TextBox ID="txtExpiryDate" placeholder="e.g Expeiry Date" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">LC Value</label>
                                    <asp:TextBox ID="txtLCValue" placeholder="e.g LC Value" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex gap-0.5 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">LC Qty</label>
                                        <asp:TextBox ID="txtLCQty" placeholder="e.g LC Qty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                    </div>
                                    <asp:DropDownList ID="ddlLCQtyUnit" runat="server" CssClass="w-28 shrink-0 border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Currency</label>
                                    <asp:DropDownList ID="DropDownList1" runat="server" CssClass="w-full shrink-0 border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex gap-0.5 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium">Inco Term</label>
                                        <asp:TextBox ID="txtIncoTerm" Text="" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-32 shrink-0">
                                        <label class="text-sm font-medium">Credit Toll %</label>
                                        <asp:TextBox ID="txtCreditTollPercent" runat="server" CssClass="w-full border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 shadow-sm"></asp:TextBox>
                                    </div>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Payment Term</label>
                                    <asp:TextBox ID="txtPaymentTerm" Text="" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Shipping Mode</label>
                                    <asp:TextBox ID="txtShippingMode" Text="By Track" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Port Of Loading</label>
                                    <asp:DropDownList ID="ddlPortOfLoading" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Port Of Discharge</label>
                                    <asp:DropDownList ID="ddlPortOfDischarge" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Receiving Bank</label>
                                    <asp:DropDownList ID="ddlReceivingBank" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Sender Bank</label>
                                    <asp:DropDownList ID="ddlSenderBank" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Shipment Type</label>
                                    <asp:TextBox ID="txtShipmentType" Text="" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Trans Shipment</label>
                                    <asp:TextBox ID="txtTransShipment" Text="" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full col-span-2">
                                    <label class="text-sm font-medium">Trans &amp; Condition</label>
                                    <asp:TextBox ID="txtTransCondition" runat="server" TextMode="MultiLine" placeholder="Text Here!" Rows="4" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out resize-none"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full col-span-2">
                                    <label class="text-sm font-medium">Remarks</label>
                                    <asp:TextBox ID="txtRemarks" placeholder="e.g Remarks" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>

                            </div>
                        </div>

                        <%-- right : PI Information box --%>
                        <fieldset class="col-span-5 bg-[#FBFCFE] p-2 rounded border border-gray-400">
                            <legend runat="server" class="font-semibold underline text-lg px-3">PI Information</legend>

                            <div class="flex items-center gap-2 w-full h-fit py-1">
                                <label class="text-sm font-medium block whitespace-nowrap leading-none mb-0">Attach File</label>
                                <asp:TextBox ID="txtAttachFileName" runat="server" placeholder="File Name" CssClass="border rounded outline-none border-gray-300 px-2 py-1.5 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out w-full text-sm leading-none"></asp:TextBox>
                                <asp:LinkButton ID="btnAttachFile" runat="server" CssClass="flex items-center justify-center rounded bg-[#2EB85C] text-white w-8 h-8 flex-shrink-0 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out no-underline">
                                    <i class="fa-solid fa-plus text-xs"></i>
                                </asp:LinkButton>
                            </div>

                            <!--Gridview Attach File-->
                            <div class="border border-gray-400 bg-gray-300 rounded w-full h-48 flex-1 overflow-y-auto overflow-x-auto mt-2 mb-2">
                                <asp:GridView ID="gvAttachFile" runat="server"></asp:GridView>
                            </div>

                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Customer</label>
                                <asp:TextBox ID="txtCustomer" placeholder="e.g Customer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="flex flex-col gap-0.5 w-full mt-1 mb-2">
                                <label class="text-sm font-medium">Export PI</label>
                                <asp:TextBox ID="txtExportPI" placeholder="e.g Export PI" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="">
                                <asp:LinkButton ID="btnAddPI" runat="server" CssClass="rounded bg-[#2EB85C] text-white px-3 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm whitespace-nowrap">Add PI</asp:LinkButton>
                            </div>

                            <!--Gridview-->
                            <div class="border border-gray-400 bg-gray-300 rounded w-full h-48 flex-1 overflow-y-auto overflow-x-auto mt-4 mb-2">
                                <asp:GridView ID="gvPIInformation" runat="server"></asp:GridView>
                            </div>

                            <div class="flex flex-col gap-1.5 mt-1">
                                <div class="flex items-center justify-between gap-2">
                                    <label class="text-sm font-medium">LC Value</label>
                                    <asp:TextBox ID="txtLCValueDisplay" runat="server" ReadOnly="true" Text="0" CssClass="w-40 border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 text-right shadow-sm"></asp:TextBox>
                                </div>
                                <div class="flex items-center justify-between gap-2">
                                    <label class="text-sm font-medium">PI Value</label>
                                    <asp:TextBox ID="txtPIValueDisplay" runat="server" ReadOnly="true" Text="0" CssClass="w-40 border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 text-right shadow-sm"></asp:TextBox>
                                </div>
                                <div class="flex items-center justify-between gap-2">
                                    <label class="text-sm font-medium">Difference</label>
                                    <asp:TextBox ID="txtDifferenceDisplay" runat="server" ReadOnly="true" Text="0" CssClass="w-40 border rounded outline-none border-gray-300 bg-gray-100 text-red-600 font-semibold px-2 py-1 text-right shadow-sm"></asp:TextBox>
                                </div>
                                <div class="flex items-center justify-between gap-2">
                                    <label class="text-sm font-medium">LC Charge</label>
                                    <asp:TextBox ID="txtLCCharge" Text="0" runat="server" CssClass="w-40 border rounded outline-none border-gray-300 px-2 py-1 text-right focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                            </div>
                        </fieldset>
                    </div>

                    <!-- btn : Save & Print Work Order / Cancel / Back to List -->
                    <div class="space-x-4 flex justify-end items-end mt-3">

                        <asp:LinkButton ID="btnSaveAndPrint" runat="server" OnClick="btnSaveAndPrint_Click" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-print"></i>
                            <span>Save &amp; Print</span>
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnCancel" runat="server" OnClick="btnCancel_Click" CssClass="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-ban"></i>
                            <span>Cancel</span>
                        </asp:LinkButton>

                        <asp:LinkButton ID="btnBackToListFooter" runat="server" OnClick="btnBackToList_Click" CssClass="flex items-center gap-1.5 rounded bg-cyan-500 text-white px-4 py-1.5 shadow-sm hover:bg-cyan-600 cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-list"></i>
                            <span>Back to List</span>
                        </asp:LinkButton>

                    </div>

                </div>
            </asp:Panel>

        </div>
    </form>
</body>
</html>

