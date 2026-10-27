<%@ Page Language="C#" AutoEventWireup="true" ClientIDMode="Static" CodeBehind="IncrementEntry.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.Payrollinformation.IncrementEntry" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Increment Entry</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        ::-webkit-scrollbar{width:6px;height:6px}
        ::-webkit-scrollbar-track{background:#f1f5f9}
        ::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:3px}
        ::-webkit-scrollbar-thumb:hover{background:#94a3b8}

        .fld{display:flex;align-items:center;justify-content:space-between;gap:6px;height:32px;padding:0 10px;
             border:1px solid #d9dce5;border-radius:6px;background:#f6f7fb;font-size:13px;color:#1e293b;
             transition:border-color .15s, box-shadow .15s, background .15s;width:100%}
        .fld:hover{border-color:#b6bccb}
        .fld:focus{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15)}
        input.fld::placeholder{color:#a0a7b5}
        .lbl{display:block;font-size:13px;color:#334155;margin-bottom:6px}
        .lbl.act{color:#dc2626}

        .page{display:none}
        .page.active{display:flex;flex-direction:column;flex:1 1 0%;min-height:0}
        .tab-btn{padding:0 18px;height:40px;font-size:13px;font-weight:500;color:#475569;border-bottom:2px solid transparent;transition:.15s}
        .tab-btn:hover{color:#1e293b;background:#f8fafc}
        .tab-btn.on{color:#2563eb;border-bottom-color:#2563eb;background:#fff}

        .gv th{position:sticky;top:0;z-index:5;background:#f8fafc;border-bottom:1px solid #e2e8f0;padding:12px 16px;
               font-size:11px;font-weight:600;color:#475569;text-transform:uppercase;letter-spacing:.05em;white-space:nowrap;text-align:left}
        .gv td{padding:10px 16px;font-size:12px;color:#475569;border-bottom:1px solid #f1f5f9;white-space:nowrap}
        .gv tr:hover td{background:rgba(248,250,252,.9)}

        @media print {
            .no-print{display:none !important}
            body,form{height:auto !important;overflow:visible !important}
            .print-area{overflow:visible !important;height:auto !important}
        }
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">
    <asp:HiddenField ID="hfUserId" runat="server" />
    <asp:HiddenField ID="hfActiveTab" runat="server" Value="increment" />

    <!-- ================= Title + Tabs ================= -->
    <header class="bg-white border-b border-slate-200 px-6 pt-3 shrink-0 no-print">
        <div class="flex items-center justify-between">
            <h1 class="text-base font-bold text-slate-800">Increment Entry</h1>
        </div>
        <div class="flex mt-2 -mb-px">
            <button type="button" class="tab-btn" data-page="increment">Increment</button>
            <button type="button" class="tab-btn" data-page="promotion">Promotion</button>
            <button type="button" class="tab-btn" data-page="incrementWithPromotion">Increment With Promotion</button>
        </div>
    </header>

    <!-- =====================================================================
         INCREMENT
         ===================================================================== -->
    <div id="increment" class="page">
        <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 no-print">
            <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3">
                    <div><label class="lbl">Emp. Status</label><asp:DropDownList ID="ddlIncStatus" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Catagory</label><asp:DropDownList ID="ddlIncCategory" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Department</label><asp:DropDownList ID="ddlIncDepartment" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Section</label><asp:DropDownList ID="ddlIncSection" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Line</label><asp:DropDownList ID="ddlIncLine" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Designation</label><asp:DropDownList ID="ddlIncDesignation" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">From Month</label><asp:DropDownList ID="ddlIncFromMonth" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">ID No</label><asp:TextBox ID="txtIncId" runat="server" CssClass="fld" placeholder="e.g. 1001, 1002…" autocomplete="off" /></div>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3 mt-4 pt-4 border-t border-dashed border-slate-300">
                    <div><label class="lbl act">Increment Type</label><asp:DropDownList ID="ddlIncType" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Increment Value</label><asp:TextBox ID="txtIncValue" runat="server" CssClass="fld" Text="0" /></div>
                    <div><label class="lbl act">Increment From</label><asp:DropDownList ID="ddlIncFrom" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Effective Date</label><asp:TextBox ID="txtIncEffDate" runat="server" TextMode="Date" CssClass="fld" /></div>
                </div>
            </div>
            <div class="flex flex-wrap justify-end items-center gap-2 mt-3">
                <asp:LinkButton ID="btnIncShow" runat="server" OnClick="btnIncShow_Click" CssClass="h-9 px-4 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-eye text-xs"></i><span>Show</span></asp:LinkButton>
                <button type="button" onclick="selectAllRows('increment')" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition"><i class="fa-solid fa-check-double text-xs"></i><span>All</span></button>
                <button type="button" onclick="clearSelection('increment')" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition"><i class="fa-solid fa-eraser text-xs"></i><span>Clear</span></button>
                <asp:LinkButton ID="btnIncOpenList" runat="server" OnClick="btnIncOpenList_Click" CssClass="h-9 px-4 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-folder-open text-xs"></i><span>View Open List</span></asp:LinkButton>
                <asp:LinkButton ID="btnIncExport" runat="server" OnClick="btnIncExport_Click" CssClass="h-9 px-4 rounded-lg bg-teal-500 hover:bg-teal-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-file-excel text-xs"></i><span>Export To Excel</span></asp:LinkButton>
                <button type="button" onclick="window.print()" class="h-9 px-4 rounded-lg bg-orange-500 hover:bg-orange-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-solid fa-print text-xs"></i><span>Print View</span></button>
                <asp:LinkButton ID="btnIncSave" runat="server" OnClick="btnIncSave_Click" OnClientClick="return doSave('increment','txtIncEffDate','Increment');" CssClass="h-9 px-5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-floppy-disk text-xs"></i><span>Save</span></asp:LinkButton>
                <asp:LinkButton ID="btnIncRefresh" runat="server" OnClick="btnRefresh_Click" CausesValidation="false" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition"><i class="fa-solid fa-rotate text-xs"></i><span>Refresh</span></asp:LinkButton>
            </div>
        </section>

        <main class="flex-1 flex flex-col min-h-0 bg-slate-100 overflow-hidden">
            <div class="bg-white border-b border-slate-200 px-6 py-3 flex flex-wrap items-center justify-between gap-4 shrink-0 no-print">
                <div class="flex items-center space-x-2">
                    <h2 class="text-base font-bold text-slate-800">Increment List</h2>
                    <asp:Label ID="lblIncCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                    <span class="sel-count bg-amber-50 text-amber-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-amber-100">0 Selected</span>
                </div>
                <div class="relative">
                    <input type="text" onkeyup="searchTable(this,'increment')" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter table..." class="bg-slate-50 border border-slate-300 rounded-lg pl-8 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-48 sm:w-64">
                    <i class="fa-solid fa-search absolute left-2.5 top-2 text-slate-400 text-xs"></i>
                </div>
            </div>
            <div class="flex-1 p-6 overflow-auto print-area">
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col h-full">
                    <div class="overflow-auto flex-1">
                        <asp:GridView ID="gvIncrement" runat="server" AutoGenerateColumns="true" GridLines="None" UseAccessibleHeader="true" CssClass="gv w-full text-left border-collapse">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate><input type="checkbox" class="chk-all rounded w-4 h-4" onchange="toggleAllRows(this,'increment')"></HeaderTemplate>
                                    <ItemTemplate><input type="checkbox" name="selIdInc" checked class="row-cb rounded w-4 h-4" onchange="updateSelCount('increment')" value='<%# Server.HtmlEncode(Convert.ToString(Eval("ID_no"))) %>'></ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate><div class="text-center py-8 text-slate-400 text-xs">No records found. Select filters and press Show.</div></EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- =====================================================================
         PROMOTION
         ===================================================================== -->
    <div id="promotion" class="page">
        <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 no-print">
            <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3">
                    <div><label class="lbl">Emp. Status</label><asp:DropDownList ID="ddlProStatus" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Catagory</label><asp:DropDownList ID="ddlProCategory" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Department</label><asp:DropDownList ID="ddlProDepartment" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Section</label><asp:DropDownList ID="ddlProSection" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Line</label><asp:DropDownList ID="ddlProLine" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Designation</label><asp:DropDownList ID="ddlProDesignation" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">From Month</label><asp:DropDownList ID="ddlProFromMonth" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">ID No</label><asp:TextBox ID="txtProId" runat="server" CssClass="fld" placeholder="e.g. 1001, 1002…" autocomplete="off" /></div>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3 mt-4 pt-4 border-t border-dashed border-slate-300">
                    <div><label class="lbl act">Promotion Type (Yes/No)</label><asp:DropDownList ID="ddlProType" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Pro. Designation</label><asp:DropDownList ID="ddlProNewDesignation" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Pro. Catagory</label><asp:DropDownList ID="ddlProNewCategory" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Pro. Department</label><asp:DropDownList ID="ddlProNewDepartment" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Pro. Section</label><asp:DropDownList ID="ddlProNewSection" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Effective Date</label><asp:TextBox ID="txtProEffDate" runat="server" TextMode="Date" CssClass="fld" /></div>
                </div>
            </div>
            <div class="flex flex-wrap justify-end items-center gap-2 mt-3">
                <asp:LinkButton ID="btnProShow" runat="server" OnClick="btnProShow_Click" CssClass="h-9 px-4 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-eye text-xs"></i><span>Show</span></asp:LinkButton>
                <button type="button" onclick="selectAllRows('promotion')" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition"><i class="fa-solid fa-check-double text-xs"></i><span>All</span></button>
                <button type="button" onclick="clearSelection('promotion')" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition"><i class="fa-solid fa-eraser text-xs"></i><span>Clear</span></button>
                <asp:LinkButton ID="btnProExport" runat="server" OnClick="btnProExport_Click" CssClass="h-9 px-4 rounded-lg bg-teal-500 hover:bg-teal-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-file-excel text-xs"></i><span>Export To Excel</span></asp:LinkButton>
                <button type="button" onclick="window.print()" class="h-9 px-4 rounded-lg bg-orange-500 hover:bg-orange-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-solid fa-print text-xs"></i><span>Print View</span></button>
                <asp:LinkButton ID="btnProSave" runat="server" OnClick="btnProSave_Click" OnClientClick="return doSave('promotion','txtProEffDate','Promotion');" CssClass="h-9 px-5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-floppy-disk text-xs"></i><span>Save</span></asp:LinkButton>
                <asp:LinkButton ID="btnProRefresh" runat="server" OnClick="btnRefresh_Click" CausesValidation="false" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition"><i class="fa-solid fa-rotate text-xs"></i><span>Refresh</span></asp:LinkButton>
            </div>
        </section>

        <main class="flex-1 flex flex-col min-h-0 bg-slate-100 overflow-hidden">
            <div class="bg-white border-b border-slate-200 px-6 py-3 flex flex-wrap items-center justify-between gap-4 shrink-0 no-print">
                <div class="flex items-center space-x-2">
                    <h2 class="text-base font-bold text-slate-800">Promotion List</h2>
                    <asp:Label ID="lblProCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                    <span class="sel-count bg-amber-50 text-amber-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-amber-100">0 Selected</span>
                </div>
                <div class="relative">
                    <input type="text" onkeyup="searchTable(this,'promotion')" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter table..." class="bg-slate-50 border border-slate-300 rounded-lg pl-8 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-48 sm:w-64">
                    <i class="fa-solid fa-search absolute left-2.5 top-2 text-slate-400 text-xs"></i>
                </div>
            </div>
            <div class="flex-1 p-6 overflow-auto print-area">
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col h-full">
                    <div class="overflow-auto flex-1">
                        <asp:GridView ID="gvPromotion" runat="server" AutoGenerateColumns="true" GridLines="None" UseAccessibleHeader="true" CssClass="gv w-full text-left border-collapse">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate><input type="checkbox" class="chk-all rounded w-4 h-4" onchange="toggleAllRows(this,'promotion')"></HeaderTemplate>
                                    <ItemTemplate><input type="checkbox" name="selIdPro" checked class="row-cb rounded w-4 h-4" onchange="updateSelCount('promotion')" value='<%# Server.HtmlEncode(Convert.ToString(Eval("ID_no"))) %>'></ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate><div class="text-center py-8 text-slate-400 text-xs">No records found. Select filters and press Show.</div></EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- =====================================================================
         INCREMENT WITH PROMOTION
         ===================================================================== -->
    <div id="incrementWithPromotion" class="page">
        <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 no-print">
            <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3">
                    <div><label class="lbl">Emp. Status</label><asp:DropDownList ID="ddlIwpStatus" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Catagory</label><asp:DropDownList ID="ddlIwpCategory" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Department</label><asp:DropDownList ID="ddlIwpDepartment" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Section</label><asp:DropDownList ID="ddlIwpSection" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Line</label><asp:DropDownList ID="ddlIwpLine" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">Designation</label><asp:DropDownList ID="ddlIwpDesignation" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">From Month</label><asp:DropDownList ID="ddlIwpFromMonth" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl">ID No</label><asp:TextBox ID="txtIwpId" runat="server" CssClass="fld" placeholder="e.g. 1001, 1002…" autocomplete="off" /></div>
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3 mt-4 pt-4 border-t border-dashed border-slate-300">
                    <div><label class="lbl act">Inc. Type</label><asp:DropDownList ID="ddlIwpIncType" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Inc. Value</label><asp:TextBox ID="txtIwpIncValue" runat="server" CssClass="fld" Text="0" /></div>
                    <div><label class="lbl act">Inc. With</label><asp:DropDownList ID="ddlIwpIncWith" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Effective Date</label><asp:TextBox ID="txtIwpEffDate" runat="server" TextMode="Date" CssClass="fld" /></div>
                    <div><label class="lbl act">Pro. Designation</label><asp:DropDownList ID="ddlIwpNewDesignation" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Pro. Catagory</label><asp:DropDownList ID="ddlIwpNewCategory" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Pro. Department</label><asp:DropDownList ID="ddlIwpNewDepartment" runat="server" CssClass="fld" /></div>
                    <div><label class="lbl act">Pro. Section</label><asp:DropDownList ID="ddlIwpNewSection" runat="server" CssClass="fld" /></div>
                </div>
            </div>
            <div class="flex flex-wrap justify-end items-center gap-2 mt-3">
                <asp:LinkButton ID="btnIwpShow" runat="server" OnClick="btnIwpShow_Click" CssClass="h-9 px-4 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-eye text-xs"></i><span>Show</span></asp:LinkButton>
                <button type="button" onclick="selectAllRows('incrementWithPromotion')" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition"><i class="fa-solid fa-check-double text-xs"></i><span>All</span></button>
                <button type="button" onclick="clearSelection('incrementWithPromotion')" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition"><i class="fa-solid fa-eraser text-xs"></i><span>Clear</span></button>
                <asp:LinkButton ID="btnIwpPending" runat="server" OnClick="btnIwpPending_Click" CssClass="h-9 px-4 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-clock text-xs"></i><span>View Pending</span></asp:LinkButton>
                <asp:LinkButton ID="btnIwpExport" runat="server" OnClick="btnIwpExport_Click" CssClass="h-9 px-4 rounded-lg bg-teal-500 hover:bg-teal-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-file-excel text-xs"></i><span>Export To Excel</span></asp:LinkButton>
                <button type="button" onclick="window.print()" class="h-9 px-4 rounded-lg bg-orange-500 hover:bg-orange-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-solid fa-print text-xs"></i><span>Print View</span></button>
                <asp:LinkButton ID="btnIwpSave" runat="server" OnClick="btnIwpSave_Click" OnClientClick="return doSave('incrementWithPromotion','txtIwpEffDate','Increment with Promotion');" CssClass="h-9 px-5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition"><i class="fa-regular fa-floppy-disk text-xs"></i><span>Save</span></asp:LinkButton>
                <asp:LinkButton ID="btnIwpRefresh" runat="server" OnClick="btnRefresh_Click" CausesValidation="false" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition"><i class="fa-solid fa-rotate text-xs"></i><span>Refresh</span></asp:LinkButton>
            </div>
        </section>

        <main class="flex-1 flex flex-col min-h-0 bg-slate-100 overflow-hidden">
            <div class="bg-white border-b border-slate-200 px-6 py-3 flex flex-wrap items-center justify-between gap-4 shrink-0 no-print">
                <div class="flex items-center space-x-2">
                    <h2 class="text-base font-bold text-slate-800">Increment With Promotion List</h2>
                    <asp:Label ID="lblIwpCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                    <span class="sel-count bg-amber-50 text-amber-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-amber-100">0 Selected</span>
                </div>
                <div class="relative">
                    <input type="text" onkeyup="searchTable(this,'incrementWithPromotion')" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter table..." class="bg-slate-50 border border-slate-300 rounded-lg pl-8 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-48 sm:w-64">
                    <i class="fa-solid fa-search absolute left-2.5 top-2 text-slate-400 text-xs"></i>
                </div>
            </div>
            <div class="flex-1 p-6 overflow-auto print-area">
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col h-full">
                    <div class="overflow-auto flex-1">
                        <asp:GridView ID="gvIwp" runat="server" AutoGenerateColumns="true" GridLines="None" UseAccessibleHeader="true" CssClass="gv w-full text-left border-collapse">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate><input type="checkbox" class="chk-all rounded w-4 h-4" onchange="toggleAllRows(this,'incrementWithPromotion')"></HeaderTemplate>
                                    <ItemTemplate><input type="checkbox" name="selIdIwp" checked class="row-cb rounded w-4 h-4" onchange="updateSelCount('incrementWithPromotion')" value='<%# Server.HtmlEncode(Convert.ToString(Eval("ID_no"))) %>'></ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                            <EmptyDataTemplate><div class="text-center py-8 text-slate-400 text-xs">No records found. Select filters and press Show.</div></EmptyDataTemplate>
                        </asp:GridView>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none no-print"></div>
</form>

<script>
// @ts-nocheck
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const $ = id => document.getElementById(id);
const PAGES = ['increment', 'promotion', 'incrementWithPromotion'];

/* ---------- Tabs ---------- */
function showTab(name) {
    PAGES.forEach(p => $(p).classList.toggle('active', p === name));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('on', b.dataset.page === name));
    $('hfActiveTab').value = name;
}

/* ---------- Selection ---------- */
function rowChecks(page) { return $(page).querySelectorAll('.row-cb'); }
function updateSelCount(page) {
    const n = $(page).querySelectorAll('.row-cb:checked').length;
    const el = $(page).querySelector('.sel-count');
    if (el) el.textContent = n + ' Selected';
}
function toggleAllRows(src, page) { rowChecks(page).forEach(c => c.checked = src.checked); updateSelCount(page); }
function selectAllRows(page) {
    rowChecks(page).forEach(c => c.checked = true);
    const a = $(page).querySelector('.chk-all'); if (a) a.checked = true;
    updateSelCount(page);
}
function clearSelection(page) {
    rowChecks(page).forEach(c => c.checked = false);
    const a = $(page).querySelector('.chk-all'); if (a) a.checked = false;
    updateSelCount(page);
}

/* ---------- Quick filter ---------- */
function searchTable(input, page) {
    const q = input.value.toLowerCase();
    $(page).querySelectorAll('table tr').forEach(tr => {
        if (!tr.querySelector('td')) return;            // header row
        tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}

/* ---------- Save validation ---------- */
function doSave(page, dateId, label) {
    const n = $(page).querySelectorAll('.row-cb:checked').length;
    if (n === 0) { showNotification('কমপক্ষে একজন কর্মচারী নির্বাচন করুন।'); return false; }
    const d = $(dateId);
    if (!d || !d.value) { showNotification('Effective Date দিন।'); return false; }
    return confirm(n + ' জনের ' + label + ' ' + d.value + ' তারিখ থেকে Save করতে চান?');
}

/* ---------- Field lock (desktop এর Enabled=false এর মতো; সার্ভারে value যায়) ---------- */
function lockField(el, on) {
    if (!el) return;
    el.style.pointerEvents = on ? 'none' : '';
    el.style.opacity = on ? '.6' : '';
    el.tabIndex = on ? -1 : 0;
}
function selText(id) { const e = $(id); return e && e.selectedIndex >= 0 ? e.options[e.selectedIndex].text : ''; }

function wireFixedType(typeId, fromId) {
    const t = $(typeId), f = $(fromId); if (!t || !f) return;
    const apply = () => { const fixed = selText(typeId) === 'Fixed'; if (fixed) f.value = '0'; lockField(f, fixed); };
    t.addEventListener('change', apply); apply();
}
function wirePromotionType() {
    const t = $('ddlProType'); if (!t) return;
    const apply = () => {
        const off = selText('ddlProType') !== 'Yes';
        lockField($('ddlProNewDesignation'), off);
        lockField($('ddlProNewCategory'), off);
    };
    t.addEventListener('change', apply); apply();
}

/* ---------- Toast ---------- */
function showNotification(message, ok) {
    const c = $('toastContainer');
    const t = document.createElement('div');
    t.className = "bg-slate-900 text-white text-xs px-4 py-2.5 rounded-xl shadow-lg pointer-events-auto flex items-center space-x-2 transition transform translate-y-2 opacity-0";
    const icon = ok === false ? 'fa-circle-xmark text-red-400' : (ok === true ? 'fa-circle-check text-emerald-400' : 'fa-circle-info text-indigo-400');
    t.innerHTML = `<i class="fa-solid ${icon}"></i><span>${esc(message)}</span>`;
    c.appendChild(t);
    setTimeout(() => t.classList.remove('translate-y-2', 'opacity-0'), 10);
    setTimeout(() => { t.classList.add('translate-y-2', 'opacity-0'); setTimeout(() => t.remove(), 300); }, 4000);
}

document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.tab-btn').forEach(b => b.addEventListener('click', () => showTab(b.dataset.page)));
    showTab($('hfActiveTab').value || 'increment');

    // ID ঘরে Enter চাপলে সংশ্লিষ্ট ট্যাবের Show চলবে
    [['txtIncId', 'btnIncShow'], ['txtProId', 'btnProShow'], ['txtIwpId', 'btnIwpShow']].forEach(([i, b]) => {
        const el = $(i);
        if (el) el.addEventListener('keydown', e => { if (e.key === 'Enter') { e.preventDefault(); $(b).click(); } });
    });

    wireFixedType('ddlIncType', 'ddlIncFrom');
    wireFixedType('ddlIwpIncType', 'ddlIwpIncWith');
    wirePromotionType();
    PAGES.forEach(updateSelCount);
});
</script>
</body>
</html>
