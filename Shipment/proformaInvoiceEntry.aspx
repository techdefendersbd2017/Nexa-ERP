<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="proformaInvoiceEntry.aspx.cs" Inherits="Nexa_ERP.Shipment.proformaInvoiceEntry" %>



<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Proforma Invoice Entry List</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

    <style>
        #Entry {
            display: none !important;
        }

            #Entry.active {
                display: block !important;
            }

        #Entry-List {
            display: block !important;
        }

            #Entry-List.active {
                display: none !important;
            }
    </style>

</head>
<body>

    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">


        <%-- ========================== proforma invoice Entry List page ================================ --%>


        <div class="max-w-[1320px] w-full m-auto rounded-lg border" id="Entry-List">

            <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                <div class="text-white">
                    <p class="text-xl mb-1 font-medium">Proforma Invoice Entry List</p>

                </div>
                <!-- Green Add New Button -->
                <asp:LinkButton ID="lnkAddNew" runat="server" CssClass="flex gap-1.5 items-center bg-[#16A34A] hover:bg-[#15803D] text-white transition-all duration-200 px-3 py-2 rounded cursor-pointer shadow-md font-medium text-sm no-underline justify-center ">
            <i class="fa-solid fa-plus text-xs"></i>
            <span>Add New</span>
                </asp:LinkButton>
            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="HiddenField1" runat="server" />

                <%-- main container --%>
                <div class="bg-[#FBFCFE] w-full">

                    <%-- left container --%>
                    <fieldset class="grid grid-cols-12 gap-x-3 gap-y-2 border border-gray-400 rounded p-2">
                        <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Search</legend>
                        <div class="col-span-12 flex flex-col">

                            <div class="grid grid-cols-4 gap-x-3 gap-y-2 w-full">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">From</label>
                                    <asp:DropDownList ID="ddlFrom1" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select From--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">To</label>
                                    <asp:DropDownList ID="ddlTo1" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select To--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="text-sm font-medium"></label>
                                        <asp:TextBox ID="TextBox1" placeholder="" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition  duration-200 ease-in-out"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="flex gap-3 items-end">
                                    <div class="flex items-center gap-1">
                                        <asp:CheckBox ID="chkConfirmedPI" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkConfirmedPI" AssociatedControlID="chkConfirmedPI" runat="server" Text="Confirmed PI" CssClass="cursor-pointer text-xs font-medium"></asp:Label>
                                    </div>

                                    <!-- Search Button -->
                                    <div class="flex items-end">
                                        <asp:LinkButton ID="btnSearch" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#4F46E5] text-white px-4 py-1.5 shadow-sm hover:bg-[#4338CA] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                            <i class="fa-solid fa-magnifying-glass text-xs"></i>
                                            <span>Search</span>
                                        </asp:LinkButton>
                                    </div>

                                </div>
                            </div>
                        </div>
                    </fieldset>

                </div>



                <%-- ========== List Grid ============ --%>

                <fieldset class="border border-gray-400 rounded p-2 mt-6">

                    <div class="">
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-full  overflow-y-auto overflow-x-auto pt-6">
                            <asp:ListView ID="ListView1" runat="server"></asp:ListView>
                        </div>

                    </div>
                </fieldset>
            </div>
        </div>






        <%-- =========================== Proforma Invoice Entry page =============================== --%>


        <div class="max-w-[1320px] w-full m-auto rounded-lg border" id="Entry">

            <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                <div class="text-white">
                    <p class="text-xl mb-1 font-medium">Proforma Invoice Entry</p>

                </div>
                <asp:LinkButton ID="lnkBackToList" runat="server" CssClass="flex gap-2 items-center bg-[#f0f0f0] hover:bg-[#cbd5e1] text-gray-700 transition-all duration-200 px-3 py-2 rounded cursor-pointer no-underline font-medium text-sm">
                    <i class="fa-solid fa-arrow-left text-gray-500"></i>
                    <span>Back To List</span>
                </asp:LinkButton>

            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="bg-[#FBFCFE] w-full">

                    <%-- left container --%>
                    <fieldset class="grid grid-cols-12 gap-x-3 gap-y-2 border border-gray-400 rounded p-2">


                        <div class="col-span-7 flex flex-col">

                            <div class="grid grid-cols-2 gap-x-3 gap-y-2 w-full">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Company</label>
                                    <asp:DropDownList ID="ddlCompany" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Company--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">PI NO</label>
                                    <asp:TextBox ID="txtPiNo" placeholder="e.g PI No" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">PI Date</label>
                                    <asp:DropDownList ID="ddlPiDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select PI Date--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Expiry Date</label>
                                    <asp:DropDownList ID="ddlExpiryDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Expiry Date--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Customer</label>
                                    <asp:DropDownList ID="ddlCustomer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Customer--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Origin</label>
                                    <asp:TextBox ID="txtOrigin1" placeholder="e.g Origin" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Currency</label>
                                    <asp:TextBox ID="txtCurrency1" placeholder="e.g Currency" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Buyer</label>
                                    <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Buyer--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Work Order*</label>
                                    <asp:DropDownList ID="ddlWOrkOrder" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                        <asp:ListItem Value="" Selected="True">--Select Work Order--</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="flex items-end">
                                    <asp:LinkButton ID="btnAdd" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#16A34A] text-white px-4 py-1.5 shadow-sm hover:bg-[#15803D] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                            <i class="fa-solid fa-plus text-xs"></i>
                                            <span>Add</span>
                                        </asp:LinkButton>
                                </div>
                            </div>
                        </div>


                        <%-- ==== Attach File ==== --%>

                        <div class="col-span-5 flex flex-col h-full">
                            <div class="flex gap-1 items-end">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="text-sm font-medium">Attach File</label>
                                    <asp:TextBox ID="txtAttachFile" placeholder="e.g Attach File" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                                </div>
                                <asp:LinkButton ID="btnBrowse" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#16A34A] text-white px-4 py-1.5 shadow-sm hover:bg-[#15803D] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                    <i class="fa-solid fa-folder-open text-xs"></i>
                                    <span>Browse</span>
                                </asp:LinkButton>
                                <asp:LinkButton ID="btnAdd2" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#16A34A] text-white px-4 py-1.5 shadow-sm hover:bg-[#15803D] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                    <i class="fa-solid fa-plus text-xs"></i>
                                    <span>Add</span>
                                 </asp:LinkButton>

                            </div>


                            <div class="mt-2 h-full">
                                <div class="border border-gray-400 bg-gray-300 rounded w-full h-full  overflow-y-auto overflow-x-auto pt-6">
                                    <asp:ListView ID="ListView3" runat="server"></asp:ListView>
                                </div>
                            </div>
                        </div>
                    </fieldset>

                </div>



                <%-- ========== Work Order Details ============ --%>

                <fieldset class="border border-gray-400 rounded p-2 mt-6">
                    <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Work Order Details</legend>

                    <div class="">
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-full  overflow-y-auto overflow-x-auto pt-6">
                            <asp:ListView ID="ListView5" runat="server"></asp:ListView>
                        </div>

                    </div>

                </fieldset>



                <%-- ==========  PI Details ============ --%>

                <fieldset class="border border-gray-400 rounded p-2 mt-6">
                    <legend class="text-sm font-medium px-2 text-[#255C8C] italic">PI Details</legend>

                    <div class="">
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-full  overflow-y-auto overflow-x-auto pt-6">
                            <asp:ListView ID="ListView2" runat="server"></asp:ListView>
                        </div>

                    </div>
                </fieldset>


                <%-- ============= Nicher Input =============== --%>
                <div class="grid grid-cols-3 mt-3">
                    <div class="flex flex-col gap-0.5 w-full">
                        <label class="text-sm font-medium">Grand Total</label>
                        <asp:TextBox ID="txtGrandTotal" placeholder="e.g Grand Total" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                    </div>

                </div>


                <!-- below btn -->
                <div class="space-x-4 flex justify-between items-center mt-6">

                    <div class="flex gap-4 items-center">

                        <%-- ========= Confirm btn============ --%>
                        <div class="flex items-end">
                            <asp:LinkButton ID="btnConfirm" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#10B981] text-white px-4 py-1.5 shadow-sm hover:bg-[#059669] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-check text-xs"></i>
                                <span>Confirm</span>
                            </asp:LinkButton>
                        </div>


                    </div>

                    <div class="flex gap-3 items-center">

                        <%-- ========= Show Btn ========== --%>
                        <div class="flex items-end">
                            <asp:LinkButton ID="btnShow" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#3B82F6] text-white px-4 py-1.5 shadow-sm hover:bg-[#2563EB] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-eye text-xs"></i>
                                <span>Show</span>
                            </asp:LinkButton>
                        </div>

                        <!--=========== Save Button ===========-->
                        <asp:LinkButton ID="btnSave" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-save"></i>
                            <span>Save</span>
                        </asp:LinkButton>

                        <!--========= Cancel Button ============-->
                        <asp:LinkButton ID="btnCancel" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#DC2626] text-white px-4 py-1.5 shadow-sm hover:bg-[#B91C1C] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                            <i class="fa-solid fa-x"></i>
                            <span>Cancel</span>
                        </asp:LinkButton>

                        <!--=============== Delete Button ========= -->
                        <div class="flex items-end">
                            <asp:LinkButton ID="btnDelete" runat="server" OnClientClick="return confirm('Are you sure you want to delete this item?');" CssClass="flex items-center gap-1.5 rounded bg-[#EF4444] text-white px-4 py-1.5 shadow-sm hover:bg-[#DC2626] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <i class="fa-solid fa-trash text-xs"></i>
                                <span>Delete</span>
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        const entryPage = document.getElementById('Entry');
        const addNewBtn = document.getElementById('lnkAddNew');
        const entryListPage = document.getElementById('Entry-List');
        const backToListBtn = document.getElementById('lnkBackToList');


        addNewBtn.addEventListener('click', function (e) {
            e.preventDefault();

            entryPage.classList.add('active');
            entryListPage.classList.add('active');
        });


        backToListBtn.addEventListener('click', function (e) {
            e.preventDefault();

            entryPage.classList.remove('active');
            entryListPage.classList.remove('active');
        });
    </script>
</body>
</html>
