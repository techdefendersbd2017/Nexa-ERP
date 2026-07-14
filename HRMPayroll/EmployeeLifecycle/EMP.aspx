<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EMP.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.EMP" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Employee Entry Form</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        .custom-grid { width: 100%; border-collapse: collapse; }
        .custom-grid th { 
            background-color: #f1f5f9; 
            color: #475569; 
            padding: 10px; 
            text-align: left; 
            border: 1px solid #cbd5e1; 
            font-size: 0.75rem; 
            font-weight: 700; 
            text-transform: uppercase;
        }
        .custom-grid td { 
            padding: 8px; 
            border: 1px solid #cbd5e1; 
            font-size: 0.8rem; 
            color: #334155; 
        }
        
        .input-box { 
            width: 100%; 
            height: 2.2rem; 
            padding: 0 0.75rem; 
            border: 1px solid #d1d5db; 
            border-radius: 0.375rem; 
            outline: none; 
            transition: all 0.2s;
            font-size: 0.875rem;
        }
        .input-box:focus { 
            border-color: #3b82f6; 
            box-shadow: 0 0 0 2px rgba(59, 130, 246, 0.1); 
        }
        
        .form-label-fixed {
            width: 130px;
            font-size: 0.875rem;
            font-weight: 600;
            color: #374151;
            flex-shrink: 0;
        }
    </style>
</head>
<body class="bg-slate-100 font-sans">
    <form id="form1" runat="server" class="p-4 md:p-6">
        
        <div class="max-w-[1100px] mx-auto bg-white border border-gray-300 rounded-xl shadow-2xl overflow-hidden">
            
            <!-- Header -->
            <div class="bg-blue-700 text-white text-center py-3 border-b-4 border-blue-800">
                <h1 class="text-2xl font-serif italic font-bold tracking-widest uppercase">Employee Entry</h1>
            </div>

            <div class="p-6 space-y-6">
                
                <!-- LAYER 1: Basic Info & Photo -->
                <div class="grid grid-cols-12 gap-6 items-start border-b border-gray-100 pb-6">
                    
                    <!-- Left: Inputs -->
                    <div class="col-span-12 lg:col-span-8 grid grid-cols-1 md:grid-cols-2 gap-x-8 gap-y-3">
                        
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Employee ID</label>
                            <div class="flex flex-grow gap-1">
                                <asp:TextBox ID="txtEmpID" runat="server" CssClass="input-box"></asp:TextBox>
                                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="bg-gray-100 border border-gray-300 px-3 rounded hover:bg-gray-200 transition font-bold text-xs" />
                            </div>
                        </div>

                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Joining Date</label>
                            <asp:TextBox ID="txtJoiningDate" runat="server" TextMode="Date" CssClass="input-box"></asp:TextBox>
                        </div>

                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Name</label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="input-box"></asp:TextBox>
                        </div>

                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Probation Period</label>
                            <asp:TextBox ID="txtProbation" runat="server" TextMode="Date" CssClass="input-box"></asp:TextBox>
                        </div>

                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Bangla Name</label>
                            <asp:TextBox ID="txtNameBangla" runat="server" CssClass="input-box"></asp:TextBox>
                        </div>

                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Employee Status</label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="input-box">
                                <asp:ListItem>Unlock</asp:ListItem>
                                <asp:ListItem>Lock</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Blood Group</label>
                            <asp:DropDownList ID="ddlBloodGroup" runat="server" CssClass="input-box">
                                <asp:ListItem>Select Group</asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Joining Salary</label>
                            <asp:TextBox ID="txtJoiningSalary" runat="server" CssClass="input-box" placeholder="0.00"></asp:TextBox>
                        </div>

                        <div class="flex items-center gap-2 md:col-span-2 mt-2">
                            <span class="text-lg font-black text-gray-800 italic uppercase mr-4">Gross Salary</span>
                            <asp:TextBox ID="txtGrossSalary" runat="server" CssClass="input-box w-48 text-blue-700 font-bold text-xl" Text="0"></asp:TextBox>
                        </div>
                    </div>

                    <!-- Right: Photo Section -->
                    <div class="col-span-12 lg:col-span-4 flex flex-col items-center justify-center border-2 border-dashed border-gray-300 p-4 rounded-xl bg-gray-50 self-stretch">
                        <div class="w-32 h-36 bg-gray-200 border border-gray-400 rounded shadow-inner flex items-center justify-center mb-2 overflow-hidden">
                             <asp:Image ID="imgEmployee" runat="server" ImageUrl="https://via.placeholder.com/150" AlternateText="Photo" CssClass="object-cover w-full h-full" />
                        </div>
                        <asp:FileUpload ID="fileUploadPhoto" runat="server" CssClass="text-[10px] mb-2 w-full" />
                        <asp:Button ID="btnPhoto" runat="server" Text="Photo" CssClass="w-full bg-blue-50 border border-blue-200 py-1 rounded font-bold text-blue-700 hover:bg-blue-100 transition" />
                    </div>
                </div>

                <!-- LAYER 2: Organization & Work Details -->
                <div class="grid grid-cols-1 lg:grid-cols-2 gap-x-12 gap-y-4 border-b border-gray-100 pb-6">
                    <!-- Left Column -->
                    <div class="space-y-3">
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Branch</label>
                            <asp:DropDownList ID="ddlBranch" runat="server" CssClass="input-box"></asp:DropDownList>
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Department</label>
                            <asp:DropDownList ID="ddlDept" runat="server" CssClass="input-box"></asp:DropDownList>
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Section</label>
                            <asp:DropDownList ID="ddlSection" runat="server" CssClass="input-box"></asp:DropDownList>
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Line</label>
                            <asp:DropDownList ID="ddlLine" runat="server" CssClass="input-box"></asp:DropDownList>
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Designation</label>
                            <asp:DropDownList ID="ddlDesignation" runat="server" CssClass="input-box"></asp:DropDownList>
                        </div>
                    </div>

                    <!-- Right Column -->
                    <div class="space-y-3">
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Weekly Holiday</label>
                            <asp:DropDownList ID="ddlHoliday" runat="server" CssClass="input-box"></asp:DropDownList>
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Break Down</label>
                            <asp:DropDownList ID="ddlBreakDown" runat="server" CssClass="input-box"></asp:DropDownList>
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Tax Holder</label>
                            <div class="flex flex-grow gap-2">
                                <asp:DropDownList ID="ddlTax" runat="server" CssClass="input-box"></asp:DropDownList>
                                <asp:TextBox ID="txtTaxAmount" runat="server" placeholder="Amount" CssClass="input-box"></asp:TextBox>
                            </div>
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Bank Holder</label>
                            <asp:DropDownList ID="ddlBankHolder" runat="server" CssClass="input-box"></asp:DropDownList>
                        </div>
                        <div class="flex items-center gap-2">
                            <label class="form-label-fixed">Bank Name</label>
                            <asp:DropDownList ID="ddlBankName" runat="server" CssClass="input-box"></asp:DropDownList>
                        </div>
                    </div>
                </div>

                <!-- LAYER 3: Action Buttons -->
                <div class="grid grid-cols-2 sm:grid-cols-4 gap-4 pt-2">
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="bg-blue-50 border-2 border-blue-400 py-2 rounded-lg shadow-md hover:bg-blue-100 font-bold text-blue-800 transition cursor-pointer" />
                    
                    <!-- Toggle Logic for History -->
                    <asp:Button ID="btnIncHistory" runat="server" Text="Increment History" OnClientClick="return toggleHistory();" CssClass="bg-blue-50 border-2 border-blue-400 py-2 rounded-lg shadow-md hover:bg-blue-100 font-bold text-blue-800 transition cursor-pointer" />
                    
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="bg-blue-50 border-2 border-blue-400 py-2 rounded-lg shadow-md hover:bg-blue-100 font-bold text-blue-800 transition cursor-pointer" />
                    <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="bg-blue-50 border-2 border-blue-400 py-2 rounded-lg shadow-md hover:bg-blue-100 font-bold text-blue-800 transition cursor-pointer" />
                </div>

                <!-- LAYER 4: Hidden GridView History -->
                <div id="historyLayer" class="hidden transition-all duration-300 border rounded-xl overflow-hidden shadow-inner bg-slate-50">
                    <asp:GridView ID="GridViewHistory" runat="server" CssClass="custom-grid" AutoGenerateColumns="False">
                        <Columns>
                            <asp:BoundField DataField="EffectiveDate" HeaderText="Effective Date" ItemStyle-Width="120px" />
                            <asp:BoundField DataField="OldGross" HeaderText="Old Gross" />
                            <asp:BoundField DataField="IncrementAmount" HeaderText="Incr. Amt" />
                            <asp:BoundField DataField="NewGross" HeaderText="New Gross" />
                            <asp:BoundField DataField="PromotionStatus" HeaderText="Prom. Status" />
                            <asp:BoundField DataField="StatusName" HeaderText="Status" />
                            <asp:BoundField DataField="OldDesignation" HeaderText="Old Desig." />
                            <asp:BoundField DataField="NewDesignation" HeaderText="New Desig." />
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="p-8 text-center text-gray-400 font-medium italic">No records found.</div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>

            </div>
            <!-- Footer Line -->
            <div class="h-2 bg-blue-700"></div>
        </div>
    </form>

    <script type="text/javascript">
        function toggleHistory() {
            var layer = document.getElementById('historyLayer');
            if (layer.classList.contains('hidden')) {
                layer.classList.remove('hidden');
                layer.scrollIntoView({ behavior: 'smooth' });
            } else {
                layer.classList.add('hidden');
            }
            return false; // সার্ভার পোস্টব্যাক বন্ধ রাখতে
        }
    </script>
</body>
</html>