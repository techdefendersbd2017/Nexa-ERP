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

    <style>
        #editor-container {
            height: 150px;
            background: #fff;
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
                    <%-- TODO: bind this GridView from code-behind (e.g. gvPIList_Bind()) to list saved PI/PO records --%>
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
                            
                            <!-- Document Type List (Added Here) -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="ddlDocType" class="text-sm font-medium">Document Type *</label>
                                <asp:DropDownList ID="ddlDocType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out" required="true">
                                    <asp:ListItem Value="PI">Proforma Invoice (PI)</asp:ListItem>
                                    <asp:ListItem Value="PO">Purchase Order (PO)</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <!-- Supplier -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="ddlSupplier" class="text-sm font-medium">Select Supplier *</label>
                                <asp:DropDownList ID="ddlSupplier" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out" required="true">
                                    <asp:ListItem Value="">--Choose Supplier--</asp:ListItem>
                                    <asp:ListItem Value="1">Supplier A Limited</asp:ListItem>
                                    <asp:ListItem Value="2">Supplier B Traders</asp:ListItem>
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

                            <!-- Payment Terms -->
                            <div class="flex flex-col gap-0.5 w-full">
                                <label for="ddlPaymentTerms" class="text-sm font-medium">Payment Terms</label>
                                <asp:DropDownList ID="ddlPaymentTerms" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="Advance">Advance</asp:ListItem>
                                    <asp:ListItem Value="Credit">Credit (30 Days)</asp:ListItem>
                                    <asp:ListItem Value="LC">Letter of Credit (LC)</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                        </div>
                    </div>
                </fieldset>
            </div>

            <!-- Dynamic Items Table Fieldset -->
            <fieldset class="border border-gray-400 rounded p-3 mb-6">
                <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Item List</legend>
                
                <div class="border border-gray-400 bg-gray-300 rounded w-full overflow-y-auto overflow-x-auto p-2">
                    <table class="w-full border-collapse bg-white text-left text-sm" id="itemTable">
                        <thead class="bg-gray-100 text-gray-700">
                            <tr>
                                <th class="p-2 border border-gray-300" width="30%">Item Name / Description</th>
                                <th class="p-2 border border-gray-300" width="15%">UOM</th>
                                <th class="p-2 border border-gray-300" width="15%">Quantity</th>
                                <th class="p-2 border border-gray-300" width="15%">Unit Price (BDT)</th>
                                <th class="p-2 border border-gray-300" width="20%">Total Amount</th>
                                <th class="p-2 border border-gray-300 text-center" width="5%">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td class="p-2 border border-gray-300">
                                    <input type="text" class="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C]" name="item_name[]" placeholder="Item name" required />
                                </td>
                                <td class="p-2 border border-gray-300">
                                    <input type="text" class="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C]" name="uom[]" placeholder="Pcs/Kg/Box" required />
                                </td>
                                <td class="p-2 border border-gray-300">
                                    <input type="number" class="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] qty" name="quantity[]" value="1" min="1" oninput="calculateTotal(this)" required />
                                </td>
                                <td class="p-2 border border-gray-300">
                                    <input type="number" class="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] price" name="unit_price[]" value="0" min="0" step="0.01" oninput="calculateTotal(this)" required />
                                </td>
                                <td class="p-2 border border-gray-300">
                                    <input type="text" class="w-full border rounded outline-none border-gray-300 px-2 py-1 bg-gray-100 total" name="total_price[]" value="0.00" readonly />
                                </td>
                                <td class="p-2 border border-gray-300 text-center">
                                    <button type="button" class="bg-[#EF4444] hover:bg-[#DC2626] text-white px-2 py-1 rounded text-xs transition duration-200" onclick="removeRow(this)"><i class="fa-solid fa-trash"></i></button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="mt-3">
                    <button type="button" class="flex items-center gap-1.5 rounded bg-[#16A34A] text-white px-3 py-1.5 shadow-sm hover:bg-[#15803D] cursor-pointer transition duration-200 font-medium text-sm" onclick="addRow()">
                        <i class="fa-solid fa-plus text-xs"></i>
                        <span>Add New Row</span>
                    </button>
                </div>
            </fieldset>

            <!-- Bottom Section / Summary -->
            <div class="flex justify-end mb-6">
                <div class="w-full md:w-1/3 bg-gray-50 p-4 border border-gray-300 rounded shadow-sm">
                    <div class="mb-2 flex justify-between text-sm">
                        <span>Subtotal:</span>
                        <strong id="subTotal">0.00</strong>
                    </div>
                    <div class="mb-2 flex justify-between items-center text-sm">
                        <span>VAT / Tax (%):</span>
                        <input type="number" id="taxRate" name="tax_rate" class="border rounded outline-none border-gray-300 px-2 py-1 w-24 text-right focus:border-[#255C8C]" value="0" oninput="calculateGrandTotal()" />
                    </div>
                    <div class="flex justify-between border-t border-gray-300 pt-2 text-base font-semibold text-[#255C8C]">
                        <span>Grand Total:</span>
                        <strong id="grandTotal">0.00</strong>
                    </div>
                </div>
            </div>

            <!-- Terms and Conditions Section with Rich Text Editor -->
            <fieldset class="border border-gray-400 rounded p-3 mb-6">
                <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Terms & Conditions</legend>
                <div class="w-full">
                    <!-- Quill Editor Container -->
                    <div id="editor-container" class="border border-gray-300 rounded">
                        <p>1. Goods must be delivered within the stipulated time.</p>
                        <p>2. Products will be returned if they do not meet quality standards.</p>
                    </div>
                    <!-- Hidden input to pass editor HTML to backend -->
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

    <!-- JavaScript for Dynamic Calculations & Editor -->
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

        // Set today's date automatically if empty
        window.addEventListener('DOMContentLoaded', (event) => {
            let dateField = document.getElementById('<%= txtPiDate.ClientID %>');
            if (dateField && !dateField.value) {
                dateField.valueAsDate = new Date();
            }
        });

        // Add new row function with Tailwind styling
        function addRow() {
            let table = document.getElementById('itemTable').getElementsByTagName('tbody')[0];
            let newRow = table.insertRow();
            newRow.innerHTML = `
                <td class="p-2 border border-gray-300">
                    <input type="text" class="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C]" name="item_name[]" placeholder="Item name" required />
                </td>
                <td class="p-2 border border-gray-300">
                    <input type="text" class="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C]" name="uom[]" placeholder="Pcs/Kg/Box" required />
                </td>
                <td class="p-2 border border-gray-300">
                    <input type="number" class="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] qty" name="quantity[]" value="1" min="1" oninput="calculateTotal(this)" required />
                </td>
                <td class="p-2 border border-gray-300">
                    <input type="number" class="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] price" name="unit_price[]" value="0" min="0" step="0.01" oninput="calculateTotal(this)" required />
                </td>
                <td class="p-2 border border-gray-300">
                    <input type="text" class="w-full border rounded outline-none border-gray-300 px-2 py-1 bg-gray-100 total" name="total_price[]" value="0.00" readonly />
                </td>
                <td class="p-2 border border-gray-300 text-center">
                    <button type="button" class="bg-[#EF4444] hover:bg-[#DC2626] text-white px-2 py-1 rounded text-xs transition duration-200" onclick="removeRow(this)"><i class="fa-solid fa-trash"></i></button>
                </td>
            `;
        }

        // Remove row function
        function removeRow(button) {
            let row = button.closest('tr');
            if (document.getElementById('itemTable').rows.length > 2) {
                row.remove();
                calculateGrandTotal();
            } else {
                alert('At least one item is required!');
            }
        }

        // Calculate individual row total
        function calculateTotal(element) {
            let row = element.closest('tr');
            let qty = parseFloat(row.querySelector('.qty').value) || 0;
            let price = parseFloat(row.querySelector('.price').value) || 0;
            let total = qty * price;
            row.querySelector('.total').value = total.toFixed(2);
            calculateGrandTotal();
        }

        // Calculate grand total
        function calculateGrandTotal() {
            let totals = document.querySelectorAll('.total');
            let subTotal = 0;
            totals.forEach(t => {
                subTotal += parseFloat(t.value) || 0;
            });

            document.getElementById('subTotal').innerText = subTotal.toFixed(2);

            let taxRate = parseFloat(document.getElementById('taxRate').value) || 0;
            let taxAmount = (subTotal * taxRate) / 100;
            let grandTotal = subTotal + taxAmount;

            document.getElementById('grandTotal').innerText = grandTotal.toFixed(2);
        }
    </script>

</body>
</html>
