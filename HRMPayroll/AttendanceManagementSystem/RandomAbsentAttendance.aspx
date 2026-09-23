<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RandomAbsentAttendance.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.AttendanceManagementSystem.RandomAbsentAttendance" ClientIDMode="Static" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Random Absent - NexaERP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
        :root { --primary:#0d6efd; --primary-dark:#0b5ed7; --border:#e6e9ef; --muted:#6b7280; }
        * { box-sizing: border-box; }
        body { margin:0; background:#f2f4f8; color:#1f2937; font-family:'Inter','Segoe UI',Roboto,Arial,'Nirmala UI',sans-serif; font-size:15px; }
        .page { padding:20px; }
        h3 { margin:0 0 16px; font-size:1.35rem; }
        .row { display:grid; grid-template-columns:minmax(300px,4fr) 8fr; gap:16px; align-items:start; }
        .stack { display:grid; gap:16px; }
        .card { background:#fff; border:1px solid var(--border); border-radius:14px; overflow:hidden; box-shadow:0 2px 10px rgba(17,24,39,.06); }
        .card-h { padding:14px 20px; color:#fff; font-weight:600; background:linear-gradient(135deg,var(--primary),var(--primary-dark)); }
        .card-b { padding:20px; }
        .field { margin-bottom:14px; }
        .field label { display:block; font-weight:600; font-size:.85rem; margin-bottom:6px; }
        .hint { color:var(--muted); font-size:.78rem; margin-top:4px; }
        .req { color:#dc3545; }
        .ctl { width:100%; padding:9px 12px; border:1px solid #d7dce3; border-radius:8px; font-size:.92rem; background:#fff; }
        .ctl:focus { outline:none; border-color:var(--primary); box-shadow:0 0 0 .2rem rgba(13,110,253,.15); }
        .ctl.invalid { border-color:#dc3545; box-shadow:0 0 0 .2rem rgba(220,53,69,.15); }
        .err { color:#a3261f; font-size:.78rem; margin-top:4px; min-height:1em; }
        .alert { display:none; margin-bottom:14px; padding:10px 14px; border-radius:8px; background:#fdecea; border:1px solid #f5c2c0; color:#a3261f; font-size:.88rem; font-weight:500; }
        .note { display:block; padding:10px 14px; border-radius:8px; background:#eaf2ff; border:1px solid #c5dbff; color:#0b4fb3; font-size:.88rem; font-weight:500; }
        .note.ok { background:#e8f6ee; border-color:#b9e2c8; color:#1e6b3a; }
        .warn { margin-bottom:14px; padding:10px 14px; border-radius:8px; background:#fff6e0; border:1px solid #f3dc9b; color:#7a5a00; font-size:.82rem; }
        .actions { display:flex; flex-wrap:wrap; gap:8px; justify-content:flex-end; border-top:1px solid var(--border); padding-top:16px; margin-top:6px; }
        .btn { border:0; border-radius:8px; padding:8px 22px; font-weight:600; cursor:pointer; }
        .btn-p { background:linear-gradient(135deg,var(--primary),var(--primary-dark)); color:#fff; }
        .btn-d { background:linear-gradient(135deg,#dc3545,#b02a37); color:#fff; }
        .btn-s { background:#eef0f3; color:#374151; border:1px solid #d7dce3; }
        .grid-wrap { overflow:auto; max-height:340px; }
        .grid { width:100%; border-collapse:collapse; font-size:.88rem; white-space:nowrap; }
        .grid th { position:sticky; top:0; background:linear-gradient(135deg,var(--primary),var(--primary-dark)); color:#fff; text-align:left; padding:11px 14px; }
        .grid td { padding:9px 14px; border-bottom:1px solid var(--border); }
        .grid tr:hover td { background:#f0f6ff; }
        @media (max-width:991px) { .row { grid-template-columns:1fr; } }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="page">
    <h3>Random Absent (Manual Attendance)</h3>

    <div class="row">

        <!-- Left: form -->
        <div class="card">
            <div class="card-h">Absent Setting</div>
            <div class="card-b">

                <div class="alert" id="jsError" role="alert"></div>

                <div class="warn">
                    <b>Preview</b> does not change any data. <b>Apply &amp; Delete</b> permanently removes the punch rows
                    of the randomly selected employees &mdash; take a backup of Manual_Attendance_Data first.
                </div>

                <div class="field">
                    <label for="txtFromDate">From Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtFromDate" runat="server" CssClass="ctl" TextMode="Date" />
                    <div class="err" id="err_txtFromDate"></div>
                </div>

                <div class="field">
                    <label for="txtToDate">To Date <span class="req">*</span></label>
                    <asp:TextBox ID="txtToDate" runat="server" CssClass="ctl" TextMode="Date" />
                    <div class="err" id="err_txtToDate"></div>
                </div>

                <div class="field">
                    <label for="txtMinAbsent">Minimum Absent Per Day <span class="req">*</span></label>
                    <asp:TextBox ID="txtMinAbsent" runat="server" CssClass="ctl" inputmode="numeric" Text="15" />
                    <div class="err" id="err_txtMinAbsent"></div>
                </div>

                <div class="field">
                    <label for="txtMaxAbsent">Maximum Absent Per Day <span class="req">*</span></label>
                    <asp:TextBox ID="txtMaxAbsent" runat="server" CssClass="ctl" inputmode="numeric" Text="20" />
                    <div class="err" id="err_txtMaxAbsent"></div>
                </div>

                <div class="field">
                    <label for="txtMaxAbsentDays">Max Absent Days Per Employee <span class="req">*</span></label>
                    <asp:TextBox ID="txtMaxAbsentDays" runat="server" CssClass="ctl" inputmode="numeric" Text="3" />
                    <div class="hint">One employee can be absent at most this many days in the selected range.</div>
                    <div class="err" id="err_txtMaxAbsentDays"></div>
                </div>

                <div class="field">
                    <label>
                        <asp:CheckBox ID="chkNoConsecutive" runat="server" Checked="true" /> No consecutive absent days
                    </label>
                    <div class="hint">An employee who was absent on the previous day is skipped.</div>
                </div>

                <div class="actions">
                    <asp:Button ID="btnPreview" runat="server" Text="Preview" CssClass="btn btn-p"
                        OnClick="btnPreview_Click" OnClientClick="return validateAbsent();" />
                    <asp:Button ID="btnApply" runat="server" Text="Apply & Delete" CssClass="btn btn-d"
                        OnClick="btnApply_Click"
                        OnClientClick="return validateAbsent() && confirm('This will permanently delete the punch data of randomly selected employees for the selected dates.\n\nHave you taken a backup? Continue?');" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-s"
                        OnClick="btnClear_Click" CausesValidation="false" />
                </div>

            </div>
        </div>

        <!-- Right: results -->
        <div class="stack">

            <asp:Label ID="lblStatus" runat="server" CssClass="note" Visible="false" />

            <div class="card">
                <div class="card-h">Date Wise Absent</div>
                <div class="grid-wrap">
                    <asp:GridView ID="gvDate" runat="server" CssClass="grid" AutoGenerateColumns="false"
                        GridLines="None" EmptyDataText="Run Preview to see the result.">
                        <Columns>
                            <asp:BoundField DataField="Work_Date" HeaderText="Work Date" DataFormatString="{0:dd-MMM-yyyy}" HtmlEncode="false" />
                            <asp:BoundField DataField="Absent_Count" HeaderText="Absent Employees" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

            <div class="card">
                <div class="card-h">Employee Wise Absent</div>
                <div class="grid-wrap">
                    <asp:GridView ID="gvEmp" runat="server" CssClass="grid" AutoGenerateColumns="false"
                        GridLines="None" EmptyDataText="Run Preview to see the result.">
                        <Columns>
                            <asp:BoundField DataField="ID_No" HeaderText="ID No" />
                            <asp:BoundField DataField="Absent_Days" HeaderText="Absent Days" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>

        </div>

    </div>
</div>
</form>
</body>
</html>
