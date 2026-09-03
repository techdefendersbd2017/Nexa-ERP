<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="colorSetup.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.BuyerPurchaseOrder.colorSetup" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Color Group</title>
    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

    <style>
        #Color {
            display: none !important;
        }

            #Color.active {
                display: block !important;
            }

        #Color-list {
            display: block !important;
        }

            #Color-list.active {
                display: none !important;
            }
    </style>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">


        <%-- ========================= purachase Order list open ============================ --%>

        <div class="max-w-[1320px] w-full m-auto rounded-lg border" id="Color-list">

            <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                <div class="text-white">
                    <p class="text-xl mb-1 font-medium">Color Group List</p>

                </div>

            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="HiddenField1" runat="server" />

                <%-- main container --%>
                <div class="bg-[#FBFCFE] w-full">

                    <%-- left container --%>

                    <div class="flex justify-between w-full">

                        <%-- search input btn --%>
                        <div class="relative flex items-center w-full max-w-xs">

                            <span class="absolute left-3 text-gray-400 pointer-events-none">
                                <i class="fa-solid fa-magnifying-glass text-sm"></i>
                            </span>

                            <asp:TextBox ID="TextBox1"
                                placeholder="Search..."
                                runat="server"
                                CssClass="w-full pl-9 pr-3 py-1.5 border border-gray-300 rounded-lg outline-none text-sm text-gray-900 placeholder-gray-400 focus:border-[#255C8C] transition duration-150">
                                    </asp:TextBox>
                        </div>

                        <!-- Green Add New Button -->
                        <asp:LinkButton ID="lnkAddNew" runat="server" PostBackUrl="~/eSTrimCode/purchaseRequisition.aspx" CssClass="flex gap-1.5 items-center bg-[#16A34A] hover:bg-[#15803D] text-white transition-all duration-200 px-3 py-2 rounded cursor-pointer shadow-md font-medium text-sm no-underline justify-center ">
                                    <i class="fa-solid fa-plus text-xs"></i>
                                    <span>Add Color Group</span>
                        </asp:LinkButton>
                    </div>

                </div>



                <%-- ========== Requisition Details ============ --%>

                <fieldset class="border border-gray-400 rounded p-1 mt-3">

                    <div class="">
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-full  overflow-y-auto overflow-x-auto pt-6">
                            <asp:ListView ID="ListView1" runat="server"></asp:ListView>
                        </div>

                    </div>
                </fieldset>
            </div>
        </div>

        <%-- ========================= purachase order list close============================ --%>







        <%-- ========================= purachase  order open ============================ --%>

        <div class="max-w-[1320px] w-full m-auto rounded-lg border" id="Color">

            <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                <div class="text-white">
                    <p class="text-xl mb-1 font-medium">Purchase Order</p>

                </div>
                <asp:LinkButton ID="lnkBackToList" runat="server" PostBackUrl="~/eSTrimCode/purchaseRequisitionList.aspx" CssClass="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] text-gray-700 transition-all duration-200 px-3 py-2 rounded cursor-pointer no-underline font-medium text-sm">
                    <i class="fa-solid fa-arrow-left text-gray-500"></i>
                    <span>Back To List</span>
                </asp:LinkButton>

            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="bg-[#FBFCFE] w-full grid grid-cols-12 space-x-3">

                    <%-- left container --%>
                    <fieldset class="col-span-6 border border-gray-400 rounded p-2">
                        <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Master Information</legend>

                        <div class=" flex flex-col">

                            <div class="flex flex-col gap-x-3 gap-y-2 w-full">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Group Name*</label>
                                    <asp:TextBox ID="txtGroupName" placeholder="e.g Group Name" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Fabric Description*</label>
                                    <asp:TextBox ID="txtFabricDescription" placeholder="e.g Fabric Description" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition  duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">GSM*</label>
                                    <asp:TextBox ID="txtGsm" placeholder="e.g GSM" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Buyer*</label>
                                    <asp:DropDownList ID="ddlBuyer" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Buyer--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Style*</label>
                                    <asp:DropDownList ID="ddlStyle" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Style--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>


                            </div>
                        </div>

                    </fieldset>

                    <%-- ======== search with  Grid ======== --%>
                    <fieldset class="col-span-6 border border-gray-400 p-2 rounded">
                        <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Style Color</legend>
                        <div class=" space-y-2 flex flex-col h-full">
                            <div class="flex gap-1 items-end">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Color</label>
                                    <asp:DropDownList ID="DropDownList1" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Color--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <!-- Add Button -->
                                <asp:LinkButton ID="LinkButton1" runat="server" PostBackUrl="~/eSTrimCode/purchaseRequisition.aspx" CssClass="flex gap-1.5 items-center bg-[#16A34A] hover:bg-[#15803D] text-white transition-all duration-200 px-3 py-1.5 rounded cursor-pointer shadow-md font-medium text-sm no-underline justify-center ">
                                    <i class="fa-solid fa-plus text-xs"></i>
                                    <span>Add</span>
                                </asp:LinkButton>

                            </div>
                            <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1  overflow-y-auto overflow-x-auto">
                                <asp:ListView ID="ListView3" runat="server"></asp:ListView>
                            </div>

                        </div>
                    </fieldset>

                </div>


                <!-- below btn -->
                <div class=" mt-3">

                    <div class="flex gap-4 items-end justify-end">

                        <!-- Save Button -->
                        <asp:LinkButton ID="btnSave" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-save"></i>
                            <span>Save</span>
                        </asp:LinkButton>

                        <!-- Cancel Button -->
                        <asp:LinkButton ID="btnCancel" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#DC2626] text-white px-4 py-1.5 shadow-sm hover:bg-[#B91C1C] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-regular fa-calendar-minus"></i>
                            <span>Clear</span>
                        </asp:LinkButton>

                    </div>
                </div>
            </div>
        </div>
    </form>




    <script>
        const colorPage = document.getElementById('Color');
        const addNewBtn = document.getElementById('lnkAddNew');
        const colorListPage = document.getElementById('Color-list');
        const backToListBtn = document.getElementById('lnkBackToList');


        addNewBtn.addEventListener('click', function (e) {
            e.preventDefault();

            colorPage.classList.add('active');
            colorListPage.classList.add('active');


            sessionStorage.setItem('PI_Page', 'Color')
        });


        backToListBtn.addEventListener('click', function (e) {
            e.preventDefault();

            colorPage.classList.remove('active');
            colorListPage.classList.remove('active');


            sessionStorage.setItem('PI_Page', 'List');
        });



        if (sessionStorage.getItem('PI_Page') === 'Color') {

            colorPage.classList.add('active');
            colorListPage.classList.add('active');

        } else {

            colorPage.classList.remove('active');
            colorListPage.classList.remove('active');

        }
    </script>
</body>
</html>


