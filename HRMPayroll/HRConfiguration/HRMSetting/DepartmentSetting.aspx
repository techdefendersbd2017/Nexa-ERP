<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DepartmentSetting.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting.DepartmentSetting" ClientIDMode="Static" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Department Setting - NexaERP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style>
        :root { --primary:#0d6efd; --primary-dark:#0b5ed7; --border:#e6e9ef; --muted:#6b7280; }
        * { box-sizing: border-box; }
        body { margin:0; background:#f2f4f8; color:#1f2937; font-family:'Inter','Segoe UI',Roboto,Arial,'Nirmala UI',sans-serif; font-size:15px; }
        .page { padding:20px; }
        h3 { margin:0 0 16px; font-size:1.35rem; }
        .row { display:grid; grid-template-columns:minmax(300px,4fr) 8fr; gap:16px; align-items:start; }
        .card { background:#fff; border:1px solid var(--border); border-radius:14px; overflow:hidden; box-shadow:0 2px 10px rgba(17,24,39,.06); }
        .card-h { padding:14px 20px; color:#fff; font-weight:600; background:linear-gradient(135deg,var(--primary),var(--primary-dark)); }
        .card-b { padding:20px; }
        .field { margin-bottom:14px; }
        .field label { display:block; font-weight:600; font-size:.85rem; margin-bottom:6px; }
        .req { color:#dc3545; }
        .ctl { width:100%; padding:9px 12px; border:1px solid #d7dce3; border-radius:8px; font-size:.92rem; }
        .ctl:focus { outline:none; border-color:var(--primary); box-shadow:0 0 0 .2rem rgba(13,110,253,.15); }
        .ctl[readonly] { background:#f3f4f6; color:var(--muted); }
        .ctl.invalid { border-color:#dc3545; box-shadow:0 0 0 .2rem rgba(220,53,69,.15); }
        .err { color:#a3261f; font-size:.78rem; margin-top:4px; min-height:1em; }
        .alert { display:none; margin-bottom:14px; padding:10px 14px; border-radius:8px; background:#fdecea; border:1px solid #f5c2c0; color:#a3261f; font-size:.88rem; font-weight:500; }
        .actions { display:flex; gap:8px; justify-content:flex-end; border-top:1px solid var(--border); padding-top:16px; margin-top:6px; }
        .btn { border:0; border-radius:8px; padding:8px 22px; font-weight:600; cursor:pointer; }
        .btn-p { background:linear-gradient(135deg,var(--primary),var(--primary-dark)); color:#fff; }
        .btn-s { background:#eef0f3; color:#374151; border:1px solid #d7dce3; }
        .grid-wrap { overflow:auto; max-height:calc(100vh - 160px); }
        .grid { width:100%; border-collapse:collapse; font-size:.88rem; white-space:nowrap; }
        .grid th { position:sticky; top:0; background:linear-gradient(135deg,var(--primary),var(--primary-dark)); color:#fff; text-align:left; padding:11px 14px; }
        .grid td { padding:9px 14px; border-bottom:1px solid var(--border); }
        .grid tr:hover td { background:#f0f6ff; }
        .grid a { color:var(--primary); font-weight:600; text-decoration:none; }
        @media (max-width:991px) { .row { grid-template-columns:1fr; } }
    </style>
</head>
<body>
<form id="form1" runat="server">
<div class="page">
    <h3>Department Setting</h3>

    <div class="row">

        <!-- Left: form -->
        <div class="card">
            <div class="card-h">Department Information</div>
            <div class="card-b">

                <div class="alert" id="jsError" role="alert"></div>

                <div class="field">
                    <label for="txtDepartmentID">Department Code</label>
                    <asp:TextBox ID="txtDepartmentID" runat="server" CssClass="ctl" ReadOnly="true" placeholder="Auto" />
                </div>

                <div class="field">
                    <label for="txtDepartmentName">Department Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtDepartmentName" runat="server" CssClass="ctl" MaxLength="200" />
                    <div class="err" id="err_txtDepartmentName"></div>
                </div>

                <div class="field">
                    <label for="txtDepartmentNameLocal">Bangla Name</label>
                    <asp:TextBox ID="txtDepartmentNameLocal" runat="server" CssClass="ctl" MaxLength="200" />
                    <div class="err" id="err_txtDepartmentNameLocal"></div>
                </div>

                <div class="field">
                    <label for="txtPrefix">Prefix <span class="req">*</span></label>
                    <asp:TextBox ID="txtPrefix" runat="server" CssClass="ctl" MaxLength="50" />
                    <div class="err" id="err_txtPrefix"></div>
                </div>

                <div class="field">
                    <label for="txtRequiredManpower">Required Manpower</label>
                    <asp:TextBox ID="txtRequiredManpower" runat="server" CssClass="ctl" inputmode="numeric" />
                    <div class="err" id="err_txtRequiredManpower"></div>
                </div>

                <div class="field">
                    <label for="txtExtraRequiredManpower">Extra Required Manpower</label>
                    <asp:TextBox ID="txtExtraRequiredManpower" runat="server" CssClass="ctl" inputmode="numeric" />
                    <div class="err" id="err_txtExtraRequiredManpower"></div>
                </div>

                <div class="field">
                    <label>
                        <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" /> Is Active
                    </label>
                </div>

                <div class="actions">
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-p"
                        OnClick="btnSave_Click" OnClientClick="return validateDepartment();" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-s"
                        OnClick="btnClear_Click" CausesValidation="false" />
                </div>

            </div>
        </div>

        <!-- Right: grid -->
        <div class="card">
            <div class="card-h">Department List</div>
            <div class="grid-wrap">
                <asp:GridView ID="gvDepartment" runat="server" CssClass="grid" AutoGenerateColumns="false"
                    DataKeyNames="Department_Code" GridLines="None" EmptyDataText="No department found."
                    OnSelectedIndexChanged="gvDepartment_SelectedIndexChanged">
                    <Columns>
                        <%-- Cells[0] = Select link, Cells[1] = Department_Code (code-behind reads Cells[1]) --%>
                        <asp:CommandField ShowSelectButton="true" SelectText="Select" HeaderText="" />
                        <asp:BoundField DataField="Department_Code" HeaderText="Code" />
                        <asp:BoundField DataField="Department_Name" HeaderText="Department Name" />
                        <asp:BoundField DataField="Bangla_Name" HeaderText="Bangla Name" />
                        <asp:BoundField DataField="DptPrefix" HeaderText="Prefix" />
                        <asp:BoundField DataField="RequiredManpower" HeaderText="Required Manpower" />
                        <asp:BoundField DataField="Extra_Required_Manpower" HeaderText="Extra Manpower" />
                        <asp:CheckBoxField DataField="IsActive" HeaderText="Active" ReadOnly="true" />
                    </Columns>
                </asp:GridView>
            </div>
        </div>

    </div>
</div>
</form>

<script>
(function () {
    "use strict";

    var $ = function (id) { return document.getElementById(id); };

    function setError(id, msg) {
        var el = $(id), out = $("err_" + id);
        if (el) el.classList.toggle("invalid", !!msg);
        if (out) out.textContent = msg || "";
    }

    function checkRequired(id, label) {
        var v = $(id).value.trim();
        if (!v) { setError(id, label + " is required."); return false; }
        setError(id, ""); return true;
    }

    function checkNumber(id, label) {
        var v = $(id).value.trim();
        if (v === "") { setError(id, ""); return true; }          // optional; server treats blank as 0
        if (!/^\d+$/.test(v)) { setError(id, label + " must be a whole number (0 or more)."); return false; }
        if (+v > 2147483647) { setError(id, label + " is too large."); return false; }
        setError(id, ""); return true;
    }

    function checkLength(id, label, max) {
        if ($(id).value.trim().length > max) { setError(id, label + " cannot exceed " + max + " characters."); return false; }
        return true;
    }

    window.validateDepartment = function () {
        var box = $("jsError");
        box.style.display = "none";

        try {
            var ok = true;
            ok = checkRequired("txtDepartmentName", "Department Name") && checkLength("txtDepartmentName", "Department Name", 200) && ok;
            ok = checkLength("txtDepartmentNameLocal", "Bangla Name", 200) && ok;
            ok = checkRequired("txtPrefix", "Prefix") && checkLength("txtPrefix", "Prefix", 50) && ok;
            ok = checkNumber("txtRequiredManpower", "Required Manpower") && ok;
            ok = checkNumber("txtExtraRequiredManpower", "Extra Required Manpower") && ok;

            if (!ok) {
                box.textContent = "Please correct the highlighted fields before saving.";
                box.style.display = "block";
                var first = document.querySelector(".ctl.invalid");
                if (first) first.focus();
                return false;
            }
            return true;
        } catch (ex) {
            box.textContent = "Validation error: " + (ex && ex.message ? ex.message : "unknown");
            box.style.display = "block";
            return false;
        }
    };

    // clear a field's error as the user types
    ["txtDepartmentName", "txtDepartmentNameLocal", "txtPrefix", "txtRequiredManpower", "txtExtraRequiredManpower"]
        .forEach(function (id) {
            var el = $(id);
            if (el) el.addEventListener("input", function () { setError(id, ""); });
        });

    // catch any unexpected script error
    window.addEventListener("error", function (e) {
        var box = $("jsError");
        if (box) { box.textContent = "Unexpected error: " + (e.message || "unknown"); box.style.display = "block"; }
    });
})();
</script>
</body>
</html>
