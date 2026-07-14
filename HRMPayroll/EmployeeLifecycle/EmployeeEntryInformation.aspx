<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeEntryInformation.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.EmployeeEntryInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Employee Entry</title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>

<body>
    <form id="form" runat="server" class="p-2">
        <!-- Outer Card -->
        <div class="bg-white border border-gray-400 rounded-xl shadow-md overflow-hidden max-w-full mx-auto">

            <!-- Header -->
            <div class="bg-[#0d6efd] text-white px-6 py-4">
                <h1 class="text-2xl mx-2 mb-2">Employee Entry</h1>
                <asp:Label ID="Label27" runat="server" Text="Label" CssClass="mx-2"></asp:Label>
            </div>

            <!-- Body -->
            <div class="p-2 space-y-6 text-right">

                <!-- Top Section -->
                <div class="flex flex-wrap justify-between items-center border-b-2 border-gray-400
                      p-1 gap-4">
                    <!-- Left Part-->
                    <div class="flex-1 space-y-2">
                        <div class="flex items-center">
                            <asp:Label ID="Label1" runat="server" Text="Label" CssClass="w-[110px] mx-2">Employee ID</asp:Label>
                            <asp:TextBox ID="TextBox1" runat="server" CssClass="border border-gray-400 h-9 w-full px-1 outline-none flex-1 rounded bg-white focus:border-blue-500 transition"></asp:TextBox>
                            <asp:Button ID="Button1" runat="server" Text="Search" CssClass="bg-gray-500 hover:bg-gray-600 text-white rounded shadow-sm transition duration-200 px-4 h-9 ml-2 cursor-pointer" />
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label2" runat="server" Text="Label" CssClass="w-[110px] mx-2">Name</asp:Label>
                            <asp:TextBox ID="TextBox2" runat="server" CssClass="border border-gray-400 h-9 w-full px-1 outline-none flex-1 rounded bg-white focus:border-blue-500 transition"></asp:TextBox>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label3" runat="server" Text="Label" CssClass="w-[110px] mx-2">Bangla Name</asp:Label>
                            <asp:TextBox ID="TextBox3" runat="server" CssClass="border border-gray-400 h-9 w-full px-1 outline-none flex-1 rounded bg-white focus:border-blue-500 transition"></asp:TextBox>
                        </div>

                        <div class="flex items-center ">
                            <asp:Label ID="Label4" runat="server" Text="Label" CssClass="w-[110px] mx-2">Blood Group</asp:Label>
                            <asp:DropDownList ID="DropDownList1" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full px-1 outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="--" Value=""></asp:ListItem>
                            </asp:DropDownList>

                            <asp:Label ID="Label5" runat="server" Text="Label" CssClass="w-[110px] text-right mx-2">Gross Salary</asp:Label>
                            <asp:TextBox type="number" value="--" ID="TextBox4" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full px-1 outline-none rounded bg-white focus:border-blue-500 transition"></asp:TextBox>
                        </div>
                    </div>

                    <!-- Middle part-->
                    <div class="space-y-2">
                        <div class="flex justify-between items-center">
                            <asp:Label ID="Label6" runat="server" Text="Label" CssClass="w-[120px] mx-2">Joining Date</asp:Label>
                            <asp:TextBox type="date" value=" " ID="TextBox5" runat="server" CssClass="border border-gray-400 h-9 w-full px-2 flex-1 outline-none rounded bg-white focus:border-blue-500 transition text-gray-800"></asp:TextBox>
                        </div>

                        <div class="flex justify-between items-center">
                            <asp:Label ID="Label7" runat="server" Text="Label" CssClass="w-[120px] mx-2">Probation Period</asp:Label>
                            <asp:TextBox type="date" value=" " ID="TextBox6" runat="server" CssClass="border border-gray-400 h-9 w-full px-2 flex-1 outline-none rounded bg-white focus:border-blue-500 transition text-gray-800"></asp:TextBox>
                        </div>

                        <div class="flex justify-between items-center">
                            <asp:Label ID="Label8" runat="server" Text="Label" CssClass="w-[120px] mx-2">Employee Status:</asp:Label>
                            <asp:DropDownList ID="DropDownList2" runat="server" CssClass="border border-gray-400 h-9 w-full bg-white px-2 flex-1 outline-none rounded bg-white focus:border-blue-500 transition text-gray-800">
                                <asp:ListItem Text="Select" Value="">Unlock</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex justify-end">
                            <asp:TextBox type="date" value="" ID="TextBox7" runat="server" CssClass="border border-gray-400 h-9 px-2 text-center text-gray-400 outline-none rounded bg-white focus:border-blue-500 transition"></asp:TextBox>
                        </div>
                    </div>

                    <!-- Right Photo -->
                    <div class=" flex flex-col items-center mx-2 mb-3 w-[130px] shrink-0">
                        <div class="w-32 h-36 border-t-2 border-l-2 border-gray-400 bg-white flex items-center justify-center overflow-hidden">
                            <asp:Image ID="Image1" runat="server" CssClass="w-full h-full object-cover" />
                        </div>
                        <asp:Button ID="Button2" runat="server" Text="Photo" CssClass="w-32 h-9 mt-2 bg-gray-500 hover:bg-gray-600 text-white rounded shadow-sm transition duration-200 cursor-pointer" />
                    </div>
                </div>

                <!-- Bottom Section -->
                <div class="flex flex-wrap justify-between gap-4 px-3">
                    <!-- Left Box -->
                    <div class=" flex-1 min-w-[550px] border border-gray-400 rounded-lg p-2 space-y-2">

                        <div class="flex items-center">
                            <asp:Label ID="Label9" runat="server" Text="Label" CssClass="w-[120px] mx-2">Branch</asp:Label>
                            <asp:DropDownList ID="DropDownList3" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label10" runat="server" Text="Label" CssClass="w-[120px] mx-2">Department</asp:Label>
                            <asp:DropDownList ID="DropDownList4" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label11" runat="server" Text="Label" CssClass="w-[120px] mx-2">Section</asp:Label>
                            <asp:DropDownList ID="DropDownList5" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label12" runat="server" Text="Label" CssClass="w-[120px] mx-2">Line</asp:Label>
                            <asp:DropDownList ID="DropDownList6" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label13" runat="server" Text="Label" CssClass="w-[120px] mx-2">Designation</asp:Label>
                            <asp:DropDownList ID="DropDownList7" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label14" runat="server" Text="Label" CssClass="w-[120px] mx-2">Category</asp:Label>
                            <asp:DropDownList ID="DropDownList8" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label15" runat="server" Text="Label" CssClass="w-[120px] mx-2">Shift</asp:Label>
                            <asp:DropDownList ID="DropDownList9" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label16" runat="server" Text="Label" CssClass="w-[120px] mx-2">Floor</asp:Label>
                            <asp:DropDownList ID="DropDownList10" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="flex items-center">
                            <asp:Label ID="Label50" runat="server" Text="" CssClass="w-[120px] mx-2 whitespace-nowrap">Machine Name</asp:Label>
                            <asp:DropDownList ID="ddlMachineName" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label51" runat="server" Text="" CssClass="w-[120px] mx-2">Skill Grade</asp:Label>
                            <asp:DropDownList ID="ddlSkilGrade" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>


                    <!-- Right Box -->
                    <div class="flex1 min-w-[350px] border border-gray-400 rounded-lg p-2  space-y-2">
                        <div class="flex items-center">
                            <asp:Label ID="Label17" runat="server" Text="Label" CssClass="w-[120px] mx-2">Weekly Holiday</asp:Label>
                            <asp:DropDownList ID="DropDownList11" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label18" runat="server" Text="Label" CssClass="w-[120px] mx-2">Break Down</asp:Label>
                            <asp:DropDownList ID="DropDownList12" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="--" Value=""></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label19" runat="server" Text="Label" CssClass="w-[120px] mx-2">Pay Type</asp:Label>
                            <asp:DropDownList ID="DropDownList13" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">

                            <asp:Label ID="Label20" runat="server" Text="Label" CssClass="w-[120px] mx-2">Cash Gross</asp:Label>
                            <asp:TextBox ID="TextBox8" runat="server" type="number" value="--" CssClass="border border-gray-400 h-9 w-[130px] px-1 outline-none rounded bg-white focus:border-blue-500 transition"></asp:TextBox>

                            <asp:Label ID="Label21" runat="server" Text="Label" CssClass="w-[120px] ml-6 mx-2">Cash Gross</asp:Label>
                            <asp:TextBox ID="TextBox9" runat="server" type="number" value="--" CssClass="border border-gray-400 h-9 w-[130px] px-1 outline-none rounded bg-white focus:border-blue-500 transition"></asp:TextBox>

                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label22" runat="server" Text="Label" CssClass="w-[120px] mx-2">Tex Holder</asp:Label>
                            <asp:DropDownList ID="DropDownList14" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>

                            <asp:Label ID="Label23" runat="server" Text="Label" CssClass="w-[120px] ml-6 mx-2">Amount</asp:Label>
                            <asp:TextBox ID="TextBox10" runat="server" type="number" value="--" CssClass="border border-gray-400 h-9 w-[130px] px-1 outline-none rounded bg-white focus:border-blue-500 transition"></asp:TextBox>

                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label24" runat="server" Text="Label" CssClass="w-[120px] mx-2">Bank Holder</asp:Label>
                            <asp:DropDownList ID="DropDownList15" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label25" runat="server" Text="Label" CssClass="w-[120px] mx-2">Bank Name</asp:Label>
                            <asp:DropDownList ID="DropDownList16" runat="server" CssClass="flex-1 border border-gray-400 h-9 w-full bg-white outline-none rounded bg-white focus:border-blue-500 transition">
                                <asp:ListItem Text="Select" Value="">--</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center">
                            <asp:Label ID="Label26" runat="server" Text="Label" CssClass="w-[120px] mx-2">A/C No</asp:Label>
                            <asp:TextBox ID="TextBox11" runat="server" type="text" CssClass="flex-1 border border-gray-400 h-9 w-[130px] px-1 outline-none rounded bg-white focus:border-blue-500 transition"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <!-- Footer Buttons -->
                <div class="flex justify-between items-center flex-wrap gap-2 mb-2 mt-5 px-3">
                    <!-- Left buttons and Checkboxes -->
                    <div class="flex items-center gap-6">
                        <div>
                            <asp:Button ID="Button6" runat="server" Text="Increment History" CssClass="bg-gray-500 hover:bg-gray-600 text-white rounded shadow-sm transition duration-200 h-10 w-full px-3 cursor-pointer" />
                        </div>
                        <div class="flex items-center space-x-2">
                            <asp:CheckBox ID="CheckBox2" runat="server" CssClass="" />
                            <asp:Label ID="Label28" runat="server" Text="Label" CssClass=" mx-1">Is Active?</asp:Label>
                        </div>

                    </div>

                    <!-- Right Buttons -->
                    <div class="flex gap-3">
                        <asp:Button ID="Button4" runat="server" Text="Save"
                            CssClass="bg-green-600 hover:bg-green-700 text-white h-10 w-24 rounded shadow-sm transition duration-200 cursor-pointer" />

                        <asp:Button ID="Button5" runat="server" Text="Clear"
                            CssClass="bg-gray-500 hover:bg-gray-600 text-white h-10 w-24 rounded shadow-sm transition duration-200 cursor-pointer" />
                    </div>

                </div>

            </div>
        </div>
    </form>
</body>
</html>
