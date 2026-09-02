<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateForProformaInvoiceEntry.aspx.cs" Inherits="Nexa_ERP.Shipment.CreateForProformaInvoiceEntry" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Supplier PI / PO Form - Nexa ERP</title>

    <!-- Tailwind CSS Link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Font Awesome Icon Link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

    <!-- Quill Rich Text Editor CSS -->
    <link href="https://cdn.jsdelivr.net/npm/quill@1.3.7/dist/quill.snow.css" rel="stylesheet" />

    <!-- Select2 CSS CDN for Searchable Dropdowns -->
    <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />

    <!-- jQuery (Required for Select2) -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <style>
        #editor-container {
            height: 150px;
            background: #fff;
        }
        /* Select2 Tailwind compatibility fix */
        .select2-container .select2-selection--single {
            height: 38px !important;
            border: 1px solid #d1d5db !important;
            border-radius: 0.375rem !important;
            padding-top: 4px;
        }
        .select2-container--default .select2-selection--single .select2-selection__arrow {
            height: 36px !important;
        }
    </style>
</head>
<body class="min-h-screen p-2 mt-2 bg-[#f8f9fa]">

    <form id="form1" runat="server" onsubmit="prepareData()" class="max-w-[1320px] w-full m-auto rounded-lg border bg-white shadow-xl">

        <%-- =========================================================
             LIST VIEW (shown first)
        ========================================================== --%>
        <div id="listView" class="block">

            <!-- List Header -->
            <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                <div class="text-white">
                    <p class="text-xl mb-1 font-medium">Supplier Proforma Invoice / Purchase Order List</p>
                </div>
                <div>
                    <span class="bg-indigo-600 text-white text-xs px-2.5 py-1 rounded font-medium">Nexa ERP System</span>
                </div>
            </div>

            <div class="p-4 bg-white rounded-b-lg">

                <div class="flex justify-end mb-3">
                    <button type="button" id="btnAddNew" class="flex items-center gap-1.5 rounded bg-[#16A34A] text-white px-4 py-1.5 shadow-sm hover:bg-[#15803D] transition duration-200 font-medium text-sm" onclick="showFormView()">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span>Add New</span>
                    </button>
                </div>

                <div class="border border-gray-400 bg-gray-300 rounded w-full overflow-x-auto p-2">
                    <asp:GridView ID="gvPIList" runat="server" CssClass="w-full border-collapse bg-white text-left text-sm" AutoGenerateColumns="false" GridLines="None"
                        HeaderStyle-CssClass="bg-gray-100 text-gray-700" RowStyle-CssClass="border-b border-gray-300">
                        <Columns>
                            <asp:BoundField DataField="DocNo" HeaderText="Document No" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" />
                            <asp:BoundField DataField="DocType" HeaderText="Type" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" />
                            <asp:BoundField DataField="SupplierName" HeaderText="Supplier" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" />
                            <asp:BoundField DataField="DocDate" HeaderText="Date" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" />
                            <asp:BoundField DataField="GrandTotal" HeaderText="Grand Total" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" />
                            <asp:TemplateField HeaderText="Action" ItemStyle-CssClass="p-2 border border-gray-300 text-center" HeaderStyle-CssClass="p-2 border border-gray-300 text-center">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" CssClass="bg-[#255C8C] hover:bg-[#1d4a70] text-white px-2 py-1 rounded text-xs" CommandName="EditPI" CommandArgument='<%# Eval("DocNo") %>'>
                                        <i class="fa-solid fa-pen"></i>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="p-4 text-center text-gray-500 text-sm">No records found.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
        </div>

        <%-- =========================================================
             FORM VIEW (hidden until "Add New" is clicked)
        ========================================================== --%>
        <div id="formView" class="hidden">

        <!-- Form Header -->
        <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
            <div class="text-white">
                <p class="text-xl mb-1 font-medium">Supplier Proforma Invoice / Purchase Order</p>
            </div>
            <div>
                <span class="bg-indigo-600 text-white text-xs px-2.5 py-1 rounded font-medium">Nexa ERP System</span>
            </div>
        </div>

        <div class="p-4 bg-[#ffffff] rounded-b-lg">
            
            <!-- Main Container / General Info -->
            <div class="bg-[#FBFCFE] w-full">
                <fieldset class="grid grid-cols-12 gap-x-3 gap-y-2 border border-gray-400 rounded p-3 mb-6">
                    <legend class="text-sm font-medium px-2 text-[#255C8C] italic">General & Delivery Information</legend>
                    
                    <div class="col-span-12">
                        <div class="grid grid-cols-4 gap-x-3 gap-y-2 w-full">

                            <!-- Branch -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="ddlBranch" class="text-sm font-medium">Branch *</label>
                                <asp:DropDownList ID="ddlBranch" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out" required="true">
                                </asp:DropDownList>
                            </div>
                            
                            <!-- Document Type -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="ddlDocType" class="text-sm font-medium">Document Type *</label>
                                <asp:DropDownList ID="ddlDocType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out" required="true">
                                    <asp:ListItem Text="Proforma Invoice (PI)" Value="1"></asp:ListItem>
                                    <asp:ListItem Text="Purchase Order (PO)" Value="2"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <!-- Ref Work Order -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="txtRefWorkOrder" class="text-sm font-medium">Ref. Work Order</label>
                                <asp:TextBox ID="txtRefWorkOrder" runat="server" Placeholder="Ref. Work Order" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 bg-gray-100 shadow-sm"></asp:TextBox>
                            </div>

                            <!-- Supplier (Searchable DropDownList) -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="ddlSupplier" class="text-sm font-medium">Select Supplier *</label>
                                <asp:DropDownList ID="ddlSupplier" runat="server" CssClass="searchable-dropdown w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out" required="true">
                                    <asp:ListItem Value="">--Choose Supplier--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <!-- PI Number -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="txtPiNo" class="text-sm font-medium">Document Number</label>
                                <asp:TextBox ID="txtPiNo" runat="server" Text="PI-2026-001" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 bg-gray-100 shadow-sm"></asp:TextBox>
                            </div>

                            <!-- Date -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="txtPiDate" class="text-sm font-medium">Date</label>
                                <asp:TextBox ID="txtPiDate" runat="server" TextMode="Date" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out" required="true"></asp:TextBox>
                            </div>

                            <!-- Expected Delivery Date -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="txtDeliveryDate" class="text-sm font-medium">Expected Delivery Date</label>
                                <asp:TextBox ID="txtDeliveryDate" runat="server" TextMode="Date" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                            </div>

                            <!-- Payment Terms (Searchable DropDownList) -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="ddlPaymentTerms" class="text-sm font-medium">Payment Terms</label>
                                <asp:DropDownList ID="ddlPaymentTerms" runat="server" CssClass="searchable-dropdown w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                </asp:DropDownList>
                            </div>

                        </div>
                    </div>
                </fieldset>
            </div>

            <!-- Dynamic Items Table Fieldset -->
            <fieldset class="border border-gray-400 rounded p-3 mb-6">
                <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Item List</legend>

                <!-- Add Item Row -->
                <div class="grid grid-cols-12 gap-2 mb-3">
                    <div class="col-span-4">
                        <!-- Item Name Changed from TextBox to DropDownList with Searchable support -->
                        <asp:DropDownList ID="ddlItemName" runat="server" CssClass="searchable-dropdown w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C]" AutoPostBack="true" OnSelectedIndexChanged="ddlItemName_SelectedIndexChanged">
                            <asp:ListItem Value="">--Select Item--</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-span-2">
                        <asp:TextBox ID="txtUOM" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C]" placeholder="Pcs/Kg/Box"></asp:TextBox>
                    </div>
                    <div class="col-span-2">
                        <asp:TextBox ID="txtQuantity" runat="server" TextMode="Number" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C]" placeholder="Qty"></asp:TextBox>
                    </div>
                    <div class="col-span-2">
                        <asp:TextBox ID="txtUnitPrice" runat="server" TextMode="Number" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C]" placeholder="Unit Price"></asp:TextBox>
                    </div>
                    <div class="col-span-2">
                        <asp:TextBox ID="txttotalAmount" runat="server" TextMode="Number" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C]" placeholder="Unit Price"></asp:TextBox>
                    </div>
                    <div class="col-span-2">
                        <asp:LinkButton ID="btnAddItem" runat="server" CssClass="flex items-center justify-center gap-1.5 w-full rounded bg-[#16A34A] text-white px-3 py-1.5 shadow-sm hover:bg-[#15803D] transition duration-200 font-medium text-sm no-underline" OnClick="btnAddItem_Click">
                            <i class="fa-solid fa-plus text-xs"></i>
                            <span>Add</span>
                        </asp:LinkButton>
                    </div>
                </div>

                <div class="border border-gray-400 bg-gray-300 rounded w-full overflow-y-auto overflow-x-auto p-2" style="max-height: 300px;">
                    <asp:GridView ID="gvItemList" runat="server" CssClass="w-full border-collapse bg-white text-left text-sm" AutoGenerateColumns="false" GridLines="None" DataKeyNames="RowId"
                        HeaderStyle-CssClass="bg-gray-100 text-gray-700" RowStyle-CssClass="border-b border-gray-300" OnRowCommand="gvItemList_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="ItemName" HeaderText="Item Name / Description" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" ItemStyle-Width="30%" />
                            <asp:BoundField DataField="UOM" HeaderText="UOM" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" ItemStyle-Width="15%" />
                            <asp:BoundField DataField="Quantity" HeaderText="Quantity" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" ItemStyle-Width="15%" />
                            <asp:BoundField DataField="UnitPrice" HeaderText="Unit Price (BDT)" DataFormatString="{0:N2}" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" ItemStyle-Width="15%" />
                            <asp:BoundField DataField="TotalAmount" HeaderText="Total Amount" DataFormatString="{0:N2}" ItemStyle-CssClass="p-2 border border-gray-300" HeaderStyle-CssClass="p-2 border border-gray-300" ItemStyle-Width="20%" />
                            <asp:TemplateField HeaderText="Action" ItemStyle-CssClass="p-2 border border-gray-300 text-center" HeaderStyle-CssClass="p-2 border border-gray-300 text-center" ItemStyle-Width="5%">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkRemoveItem" runat="server" CssClass="bg-[#EF4444] hover:bg-[#DC2626] text-white px-2 py-1 rounded text-xs" CommandName="RemoveItem" CommandArgument='<%# Eval("RowId") %>' OnClientClick="return confirm('Remove this item?');">
                                        <i class="fa-solid fa-trash"></i>
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="p-4 text-center text-gray-500 text-sm">No items added yet.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </fieldset>

            <!-- Bottom Section / Summary -->
            <div class="flex justify-end mb-6">
                <div class="w-full md:w-1/3 bg-gray-50 p-4 border border-gray-300 rounded shadow-sm">
                    <div class="mb-2 flex justify-between text-sm">
                        <span>Subtotal:</span>
                        <strong><asp:Label ID="lblSubTotal" runat="server" Text="0.00"></asp:Label></strong>
                    </div>
                    <div class="mb-2 flex justify-between items-center text-sm">
                        <span>VAT / Tax (%):</span>
                        <asp:TextBox ID="txtTaxRate" runat="server" TextMode="Number" CssClass="border rounded outline-none border-gray-300 px-2 py-1 w-24 text-right focus:border-[#255C8C]" Text="0" AutoPostBack="true" OnTextChanged="txtTaxRate_TextChanged"></asp:TextBox>
                    </div>
                    <div class="flex justify-between border-t border-gray-300 pt-2 text-base font-semibold text-[#255C8C]">
                        <span>Grand Total:</span>
                        <strong><asp:Label ID="lblGrandTotal" runat="server" Text="0.00"></asp:Label></strong>
                    </div>
                </div>
            </div>

            <!-- Terms and Conditions Section with Rich Text Editor -->
            <fieldset class="border border-gray-400 rounded p-3 mb-6">
                <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Terms & Conditions</legend>
                <div class="w-full">
                    <div id="editor-container" class="border border-gray-300 rounded">
                        <p>1. Goods must be delivered within the stipulated time.</p>
                        <p>2. Products will be returned if they do not meet quality standards.</p>
                    </div>
                    <asp:HiddenField ID="terms_hidden" runat="server" />
                </div>
            </fieldset>

            <!-- Action Buttons -->
            <div class="flex justify-end gap-3 border-t pt-4">
                <button type="button" id="btnBackToList" class="flex items-center gap-1.5 rounded bg-gray-500 text-white px-4 py-1.5 shadow-sm hover:bg-gray-600 transition duration-200 font-medium text-sm" onclick="showListView()">
                    <i class="fa-solid fa-arrow-left text-xs"></i>
                    <span>Back to List</span>
                </button>
                <asp:LinkButton ID="btnReset" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#DC2626] text-white px-4 py-1.5 shadow-sm hover:bg-[#B91C1C] transition duration-200 font-medium text-sm no-underline">
                    <i class="fa-solid fa-xmark text-xs"></i>
                    <span>Reset</span>
                </asp:LinkButton>
                <asp:LinkButton ID="btnSave" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1.5 shadow-sm hover:bg-[#1E7E34] transition duration-200 font-medium text-sm no-underline">
                    <i class="fa-solid fa-save text-xs"></i>
                    <span>Save & Print</span>
                </asp:LinkButton>
            </div>

        </div>
        </div>
        <%-- end formView --%>

    </form>

    <!-- Quill Rich Text Editor JS CDN -->
    <script src="https://cdn.jsdelivr.net/npm/quill@1.3.7/dist/quill.min.js"></script>

    <!-- Select2 JS CDN -->
    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

    <!-- JavaScript for Editor, View Toggle & Select2 Activation -->
    <script>
        // Initialize Quill Editor
        var quill = new Quill('#editor-container', {
            theme: 'snow',
            modules: {
                toolbar: [
                    ['bold', 'underline', 'italic'],
                    [{ 'list': 'ordered' }, { 'list': 'bullet' }],
                    ['clean']
                ]
            }
        });

        // Toggle: List <-> Form
        function showFormView() {
            document.getElementById('listView').classList.add('hidden');
            document.getElementById('formView').classList.remove('hidden');
            // Re-initialize Select2 when form becomes visible (fixes hidden rendering issues)
            $('.searchable-dropdown').select2({
                width: '100%'
            });
        }

        function showListView() {
            document.getElementById('formView').classList.add('hidden');
            document.getElementById('listView').classList.remove('hidden');
        }

        // Form submit preparation for ASP.NET HiddenField
        function prepareData() {
            var termsHtml = quill.root.innerHTML;
            document.getElementById('<%= terms_hidden.ClientID %>').value = termsHtml;
        }

        // Initialize Select2 & Date on page load
        $(document).ready(function () {
            $('.searchable-dropdown').select2({
                width: '100%'
            });

            let dateField = document.getElementById('<%= txtPiDate.ClientID %>');
            if (dateField && !dateField.value) {
                dateField.valueAsDate = new Date();
            }
        });

        // Re-initialize Select2 after ASP.NET UpdatePanel or PostBacks if applicable
        function pageLoad() {
            $('.searchable-dropdown').select2({
                width: '100%'
            });
        }
    </script>

</body>
</html>