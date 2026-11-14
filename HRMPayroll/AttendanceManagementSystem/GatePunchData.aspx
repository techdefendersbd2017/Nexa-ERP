<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GatePunchData.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.AttendanceManagementSystem.GatePunchData" ClientIDMode="Static" ResponseEncoding="utf-8" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <title>Gate Punch Data - NexaERP</title>
    <meta name="viewport" content="width=device-width, initial-scale=1" />

<style>
    :root {
        --brand-primary: #0d6efd;
        --brand-primary-dark: #0b5ed7;
        --brand-success: #198754;
        --brand-success-dark: #157347;
        --surface: #ffffff;
        --page-bg: #f2f4f8;
        --border-soft: #e6e9ef;
        --text-muted: #6b7280;
    }

    * { box-sizing: border-box; }

    body {
        background: var(--page-bg);
        margin: 0;
        padding: 0;
        color: #1f2937;
        font-family: 'Inter', 'Segoe UI', Roboto, Arial, 'Nirmala UI', sans-serif;
        font-size: 15px;
        line-height: 1.5;
    }

    button, input, select, textarea { font-family: inherit; }

    .pd-main { min-height: 100vh; padding: 20px; }

    /* ---------- Page heading ---------- */
    .pd-heading { display: flex; align-items: center; gap: 10px; margin-bottom: 16px; }
    .pd-heading svg { width: 26px; height: 26px; color: var(--brand-primary); flex: none; }
    .pd-heading h3 { margin: 0; font-weight: 700; font-size: 1.35rem; color: #111827; }
    .pd-heading small { display: block; color: var(--text-muted); font-weight: 400; font-size: 0.8rem; }

    /* ---------- Layout ---------- */
    .pd-row { display: grid; grid-template-columns: minmax(300px, 4fr) 8fr; gap: 16px; align-items: start; }
    .pd-col-right { min-width: 0; }

    /* ---------- Card ---------- */
    .pd-card {
        background: var(--surface);
        border: 1px solid var(--border-soft);
        border-radius: 14px;
        overflow: hidden;
        box-shadow: 0 2px 10px rgba(17, 24, 39, 0.06);
    }

    .pd-card-header { padding: 14px 20px; display: flex; align-items: center; gap: 10px; color: #fff; }
    .pd-card-header.bg-primary { background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)); }
    .pd-card-header.bg-success { background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)); }
    .pd-card-header h4 { margin: 0; font-size: 1.05rem; font-weight: 600; letter-spacing: 0.2px; }
    .pd-card-header svg { width: 20px; height: 20px; flex: none; }

    .pd-badge {
        margin-left: auto;
        background: rgba(255, 255, 255, 0.22);
        border-radius: 999px;
        padding: 2px 12px;
        font-size: 0.8rem;
        font-weight: 600;
        white-space: nowrap;
    }

    /* ---------- Form ---------- */
    .pd-left-panel { padding: 22px; }
    .pd-fields { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
    .pd-span2 { grid-column: 1 / -1; }
    .pd-fields label { font-weight: 600; font-size: 0.85rem; color: #374151; margin-bottom: 6px; display: block; }

    .pd-control {
        width: 100%;
        border-radius: 8px;
        border: 1px solid #d7dce3;
        padding: 9px 12px;
        font-size: 0.92rem;
        background: #fff;
        color: #1f2937;
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .pd-control:focus { outline: none; border-color: var(--brand-primary); box-shadow: 0 0 0 0.2rem rgba(13, 110, 253, 0.15); }
    .pd-control[readonly], .pd-control:disabled { background-color: #f3f4f6; color: #6b7280; }
    .pd-control:disabled { cursor: not-allowed; }
    textarea.pd-control { resize: vertical; min-height: 90px; }

    .pd-hint { margin: 6px 0 0; font-size: 0.78rem; color: var(--text-muted); }

    .pd-alert {
        margin-top: 14px;
        padding: 10px 14px;
        border-radius: 8px;
        font-size: 0.88rem;
        font-weight: 500;
        word-break: break-word;
    }
    .pd-alert-error { background: #fdecea; border: 1px solid #f5c2c0; color: #a3261f; }
    .pd-alert-ok { background: #e8f5ee; border: 1px solid #b7e0c7; color: #146c43; }

    .pd-action-bar {
        border-top: 1px solid var(--border-soft);
        margin-top: 20px;
        padding-top: 16px;
        display: flex;
        flex-wrap: wrap;
        justify-content: flex-end;
        gap: 8px;
    }

    /* ---------- Buttons ---------- */
    .pd-btn {
        border-radius: 8px;
        border: 1px solid transparent;
        font-weight: 600;
        font-size: 0.9rem;
        padding: 8px 20px;
        cursor: pointer;
        line-height: 1.5;
        transition: filter 0.15s ease, background-color 0.15s ease;
    }
    .pd-btn:disabled { opacity: 0.55; cursor: not-allowed; }
    .pd-btn:focus-visible { outline: 2px solid var(--brand-primary); outline-offset: 2px; }
    .pd-btn-primary { background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark)); color: #fff; }
    .pd-btn-success { background: linear-gradient(135deg, var(--brand-success), var(--brand-success-dark)); color: #fff; }
    .pd-btn-primary:hover:not(:disabled), .pd-btn-success:hover:not(:disabled) { filter: brightness(1.08); }
    .pd-btn-secondary { background-color: #eef0f3; border-color: #d7dce3; color: #374151; }
    .pd-btn-secondary:hover:not(:disabled) { background-color: #e2e5ea; color: #111827; }
    .pd-btn-sm { padding: 5px 14px; font-size: 0.85rem; }

    /* ---------- Grid ---------- */
    .pd-toolbar { padding: 12px 16px; border-bottom: 1px solid var(--border-soft); display: flex; flex-wrap: wrap; align-items: center; gap: 8px; }
    .pd-toolbar .pd-control { max-width: 340px; flex: 1 1 220px; }
    .pd-toolbar .pd-sel { margin-left: auto; font-size: 0.85rem; color: var(--text-muted); white-space: nowrap; }

    .pd-grid-wrapper { position: relative; min-height: 260px; max-height: calc(100vh - 300px); overflow: auto; }
    .pd-grid-wrapper table { width: 100%; border-collapse: separate; border-spacing: 0; white-space: nowrap; font-size: 0.88rem; }

    .pd-grid-wrapper th {
        position: sticky;
        top: 0;
        z-index: 100;
        padding: 12px 14px;
        text-align: left;
        background: linear-gradient(135deg, var(--brand-primary), var(--brand-primary-dark));
        color: #fff;
        font-weight: 600;
        font-size: 0.82rem;
        text-transform: uppercase;
        letter-spacing: 0.4px;
    }

    .pd-grid-wrapper td {
        padding: 10px 14px;
        vertical-align: middle;
        color: #374151;
        border-bottom: 1px solid var(--border-soft);
        font-variant-numeric: tabular-nums;
    }
    .pd-grid-wrapper td.pd-chk, .pd-grid-wrapper th.pd-chk { width: 1%; text-align: center; }
    .pd-grid-wrapper td.pd-chk input { width: 16px; height: 16px; cursor: pointer; }
    .pd-grid-wrapper td.pd-no, .pd-grid-wrapper th.pd-no { width: 1%; text-align: right; }
    .pd-grid-wrapper td.pd-no { color: #9ca3af; border-right: 1px solid var(--border-soft); }
    .pd-grid-wrapper td.pd-null { color: #b6bcc6; }
    .pd-grid-wrapper tbody tr:hover { background-color: #f0f6ff; }
    .pd-grid-wrapper tbody tr.pd-off td { color: #9ca3af; }
    .pd-grid-wrapper td.pd-empty-row {
        padding: 70px 24px;
        text-align: center;
        white-space: normal;
        color: var(--text-muted);
        border-bottom: 0;
    }
    .pd-grid-wrapper td.pd-empty-row strong { display: block; color: #374151; font-size: 1rem; margin-bottom: 4px; }
    .pd-grid-wrapper tbody tr:hover td.pd-empty-row { background: transparent; }

    .pd-footer {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 10px 18px;
        padding: 10px 16px;
        border-top: 1px solid var(--border-soft);
        font-size: 0.86rem;
        color: var(--text-muted);
    }
    .pd-footer .pd-range { margin-right: auto; }
    .pd-pager { display: flex; flex-wrap: wrap; align-items: center; gap: 8px 12px; }
    .pd-pager label { display: inline-flex; align-items: center; gap: 8px; }
    .pd-pager select { border: 1px solid #d7dce3; border-radius: 8px; padding: 4px 8px; background: #fff; color: #1f2937; font-size: 0.85rem; }
    .pd-pageinfo { min-width: 90px; text-align: center; font-variant-numeric: tabular-nums; }

    .pd-toast {
        position: fixed;
        left: 50%;
        bottom: 24px;
        transform: translate(-50%, 12px);
        opacity: 0;
        pointer-events: none;
        padding: 10px 18px;
        border-radius: 8px;
        background: #111827;
        color: #fff;
        font-size: 0.9rem;
        font-weight: 600;
        transition: opacity 0.18s ease, transform 0.18s ease;
        z-index: 1000;
    }
    .pd-toast.pd-show { opacity: 1; transform: translate(-50%, 0); }

    [hidden] { display: none !important; }

    @media (max-width: 991.98px) {
        .pd-main { padding: 14px; }
        .pd-row { grid-template-columns: 1fr; }
        .pd-grid-wrapper { max-height: none; overflow-x: auto; }
        .pd-action-bar .pd-btn { flex: 1 1 100%; }
    }
    @media (max-width: 575.98px) {
        .pd-heading h3 { font-size: 1.1rem; }
        .pd-card-header h4 { font-size: 0.95rem; }
        .pd-left-panel { padding: 16px; }
        .pd-fields { grid-template-columns: 1fr; }
    }
    @media (prefers-reduced-motion: reduce) {
        * { transition: none !important; }
    }
</style>
</head>
<body>
<form id="form1" runat="server">
<div class="pd-main" id="pdMain">

    <div class="pd-heading">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <rect x="4" y="3" width="16" height="18" rx="2"></rect><path d="M9 21V12h6v9"></path><circle cx="12" cy="8" r="1.2"></circle>
        </svg>
        <div>
            <h3>Gate Punch Data</h3>
            <small>HRM Configuration &rsaquo; Attendance &rsaquo; Gate Punch Data</small>
        </div>
    </div>

    <div class="pd-row">

        <!-- Left Side Form -->
        <div class="pd-col-left">
            <div class="pd-card">

                <div class="pd-card-header bg-primary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                        <path d="M4 6h16M4 12h16M4 18h10"></path>
                    </svg>
                    <h4>Get Punch Data</h4>
                </div>

                <div class="pd-left-panel">
                    <div class="pd-fields">

                        <div class="pd-span2">
                            <label for="ddlMachine">Punch Machine Database</label>
                            <asp:DropDownList ID="ddlMachine" runat="server" CssClass="pd-control">
                                <asp:ListItem Text="Zk Tech" Value="Zk" Selected="True"></asp:ListItem>
                                <asp:ListItem Text="Hikvision" Value="Hik"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div>
                            <label for="txtFrom">From Date</label>
                            <asp:TextBox ID="txtFrom" runat="server" TextMode="Date" CssClass="pd-control"></asp:TextBox>
                        </div>

                        <div>
                            <label for="txtTill">Till Date</label>
                            <asp:TextBox ID="txtTill" runat="server" TextMode="Date" CssClass="pd-control"></asp:TextBox>
                        </div>

                        <div class="pd-span2">
                            <label for="txtIds">ID</label>
                            <asp:TextBox ID="txtIds" runat="server" TextMode="MultiLine" Rows="4" CssClass="pd-control"
                                placeholder="e.g. 101, 102, 103"></asp:TextBox>
                            <p class="pd-hint">Optional. Separate IDs with comma, space or new line. Leave empty to load all employees.</p>
                        </div>

                        <div class="pd-span2">
                            <label for="txtTotal">Total Data</label>
                            <input type="text" id="txtTotal" class="pd-control" readonly="readonly" value="0" />
                        </div>

                    </div>

                    <div id="pdError" class="pd-alert pd-alert-error" role="alert" hidden="hidden"></div>
                    <div id="pdOk" class="pd-alert pd-alert-ok" role="status" hidden="hidden"></div>

                    <div class="pd-action-bar">
                        <asp:Button ID="btnLoad" runat="server" Text="Load Punch Data From Machine" CssClass="pd-btn pd-btn-success"
                            OnClick="btnLoad_Click" OnClientClick="return prepareLoad();" />
                        <asp:Button ID="btnTransfer" runat="server" Text="Transfer To Payroll Database" CssClass="pd-btn pd-btn-primary"
                            OnClick="btnTransfer_Click" OnClientClick="return prepareTransfer();" />
                    </div>
                </div>

            </div>
        </div>

        <!-- Right Side Grid -->
        <div class="pd-col-right">
            <div class="pd-card">

                <div class="pd-card-header bg-success">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                        <path d="M9 6h11M9 12h11M9 18h11"></path><path d="M3.5 6l1.2 1.2L7 4.8M3.5 12l1.2 1.2L7 10.8M3.5 18l1.2 1.2L7 16.8"></path>
                    </svg>
                    <h4>Gate Punch Data List</h4>
                    <span class="pd-badge" id="pdBadge">0 rows</span>
                </div>

                <div class="pd-toolbar">
                    <input type="search" id="txtSearch" class="pd-control" placeholder="Search in all columns..." aria-label="Search in all columns" autocomplete="off" disabled="disabled" />
                    <button type="button" id="btnAll" class="pd-btn pd-btn-secondary pd-btn-sm" disabled="disabled">All</button>
                    <button type="button" id="btnNone" class="pd-btn pd-btn-secondary pd-btn-sm" disabled="disabled">None</button>
                    <span class="pd-sel" id="pdSel">0 selected</span>
                </div>

                <div class="pd-grid-wrapper" id="pdGridWrap" tabindex="0" role="region" aria-label="Gate punch data grid">
                    <table id="gvPunch">
                        <thead>
                            <tr>
                                <th class="pd-chk" scope="col">&#10003;</th>
                                <th class="pd-no" scope="col">No.</th>
                                <th scope="col">ID No</th>
                                <th scope="col">Name</th>
                                <th scope="col">Machine</th>
                                <th scope="col">Check Time</th>
                            </tr>
                        </thead>
                        <tbody id="gvBody"></tbody>
                    </table>
                </div>

                <div class="pd-footer">
                    <span class="pd-range" id="pdRange">0 rows</span>
                    <div class="pd-pager">
                        <label>Rows per page
                            <select id="ddlPageSize">
                                <option>25</option>
                                <option selected="selected">50</option>
                                <option>100</option>
                                <option>200</option>
                            </select>
                        </label>
                        <button type="button" id="btnPrev" class="pd-btn pd-btn-secondary pd-btn-sm" disabled="disabled">Previous</button>
                        <span class="pd-pageinfo" id="pdPageInfo">Page 1 of 1</span>
                        <button type="button" id="btnNext" class="pd-btn pd-btn-secondary pd-btn-sm" disabled="disabled">Next</button>
                    </div>
                </div>

            </div>
        </div>

    </div>
</div>

<%-- Rows loaded from the machine (server -> browser) --%>
<asp:HiddenField ID="hfRows" runat="server" />
<%-- Rows ticked for transfer (browser -> server) --%>
<asp:HiddenField ID="hfSelected" runat="server" />

<div class="pd-toast" id="pdToast" role="status" aria-live="polite"></div>
</form>

<script>
(function () {
    "use strict";

    var $ = function (id) { return document.getElementById(id); };
    var MAX_ROWS = 50000;

    var state = { rows: [], query: "", page: 1, pageSize: 50, view: [] };

    /* ---------- helpers ---------- */
    function esc(s) {
        return String(s).replace(/[&<>"']/g, function (c) {
            return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
        });
    }
    function plural(n, word) { return n + " " + word + (n === 1 ? "" : "s"); }
    function errMsg(ex) { return (ex && ex.message) ? ex.message : "unknown error"; }

    var toastTimer = null;
    function toast(msg) {
        var t = $("pdToast");
        t.textContent = msg;
        t.classList.add("pd-show");
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { t.classList.remove("pd-show"); }, 2800);
    }
    function showError(msg) { $("pdOk").hidden = true; var e = $("pdError"); e.textContent = msg; e.hidden = false; }
    function showOk(msg) { $("pdError").hidden = true; var e = $("pdOk"); e.textContent = msg; e.hidden = false; }
    function clearMsg() { $("pdError").hidden = true; $("pdOk").hidden = true; }

    // Called by the server after Load / Transfer.
    window.pdNotify = function (type, msg) {
        if (type === "error") showError(msg);
        else { showOk(msg); toast(msg); }
    };

    window.addEventListener("error", function (e) {
        var m = e && e.message ? String(e.message) : "";
        if (m.indexOf("ResizeObserver") !== -1) return;
        showError("Unexpected error: " + (m || "unknown"));
    }, true);

    /* ---------- data from server ---------- */
    function loadFromHidden() {
        var raw = $("hfRows").value;
        state.rows = [];
        if (!raw) return;
        try {
            var arr = JSON.parse(raw);
            state.rows = arr.map(function (r, i) {
                return {
                    k: i, n: i + 1, sel: true,
                    id: String(r.id), name: String(r.name || ""), machine: String(r.machine || ""), time: String(r.time),
                    hay: [r.id, r.name, r.machine, r.time].join("\u0001").toLowerCase()
                };
            });
        } catch (ex) {
            console.error(ex);
            showError("Unable to read loaded data: " + errMsg(ex));
        }
    }

    /* ---------- view ---------- */
    function recompute() {
        try {
            var tokens = state.query.toLowerCase().split(/\s+/).filter(Boolean);
            var list = state.rows;
            if (tokens.length) {
                list = list.filter(function (r) {
                    return tokens.every(function (t) { return r.hay.indexOf(t) !== -1; });
                });
            }
            state.view = list;
            var pages = Math.max(1, Math.ceil(state.view.length / state.pageSize));
            if (state.page > pages) state.page = pages;
            render();
        } catch (ex) {
            console.error(ex);
            showError("Unable to display data: " + errMsg(ex));
        }
    }

    function emptyRow(title, text) {
        return '<tr><td class="pd-empty-row" colspan="6"><strong>' + esc(title) + "</strong>" + esc(text) + "</td></tr>";
    }

    function render() {
        var total = state.rows.length, shown = state.view.length;
        var has = total > 0;
        var filtered = has && shown !== total;
        var selected = 0;
        for (var i = 0; i < total; i++) if (state.rows[i].sel) selected++;

        var start = (state.page - 1) * state.pageSize;
        var body = "";
        if (!has) {
            body = emptyRow("No data loaded", "Choose the machine and dates, then click \u201CLoad Punch Data From Machine\u201D.");
        } else if (shown === 0) {
            body = emptyRow("No matching rows", "Try a different search word.");
        } else {
            state.view.slice(start, start + state.pageSize).forEach(function (r) {
                body += '<tr' + (r.sel ? "" : ' class="pd-off"') + '>' +
                    '<td class="pd-chk"><input type="checkbox" data-k="' + r.k + '"' + (r.sel ? ' checked="checked"' : "") + ' aria-label="Select row ' + r.n + '" /></td>' +
                    '<td class="pd-no">' + r.n + '</td>' +
                    '<td>' + esc(r.id) + '</td>' +
                    '<td' + (r.name ? "" : ' class="pd-null"') + '>' + (r.name ? esc(r.name) : "\u2014") + '</td>' +
                    '<td' + (r.machine ? "" : ' class="pd-null"') + '>' + (r.machine ? esc(r.machine) : "\u2014") + '</td>' +
                    '<td>' + esc(r.time) + '</td></tr>';
            });
        }
        $("gvBody").innerHTML = body;

        $("txtTotal").value = total;
        $("pdBadge").textContent = has ? (filtered ? shown + " of " + plural(total, "row") : plural(total, "row")) : "0 rows";
        $("pdSel").textContent = selected + " selected";

        var end = Math.min(start + state.pageSize, shown);
        $("pdRange").textContent = !has ? "0 rows"
            : shown === 0 ? "0 rows found"
                : "Showing " + (start + 1) + "\u2013" + end + " of " + plural(shown, "row") + (filtered ? " (total " + total + ")" : "");
        var pages = Math.max(1, Math.ceil(shown / state.pageSize));
        $("pdPageInfo").textContent = "Page " + state.page + " of " + pages;
        $("btnPrev").disabled = state.page <= 1;
        $("btnNext").disabled = state.page >= pages;

        $("txtSearch").disabled = !has;
        $("btnAll").disabled = $("btnNone").disabled = !has || shown === 0;
        $("btnTransfer").disabled = !has;
    }

    /* ---------- server buttons ---------- */
    window.prepareLoad = function () {
        clearMsg();
        var f = $("txtFrom").value, t = $("txtTill").value;
        if (!f || !t) { showError("Please select From Date and Till Date."); return false; }
        if (f > t) { showError("From Date cannot be later than Till Date."); return false; }
        var ids = $("txtIds").value;
        if (ids && !/^[\d\s,;]*$/.test(ids)) { showError("ID can contain only numbers separated by comma, space or new line."); return false; }
        $("hfRows").value = "";      // old list is replaced by the new result
        return true;
    };

    window.prepareTransfer = function () {
        try {
            clearMsg();
            var picked = state.rows.filter(function (r) { return r.sel; });
            if (!picked.length) { showError("Please select at least one row to transfer."); return false; }
            if (picked.length > MAX_ROWS) {
                showError("Too many rows (" + picked.length + "). Maximum " + MAX_ROWS + " rows can be transferred at a time.");
                return false;
            }
            $("hfSelected").value = JSON.stringify(picked.map(function (r) { return { id: r.id, time: r.time }; }));
            return true;
        } catch (ex) {
            console.error(ex);
            showError("Unable to prepare data for transfer: " + errMsg(ex));
            return false;
        }
    };

    /* ---------- events ---------- */
    $("gvBody").addEventListener("change", function (e) {
        var cb = e.target;
        if (!cb || cb.type !== "checkbox") return;
        var row = state.rows[+cb.getAttribute("data-k")];
        if (row) { row.sel = cb.checked; render(); }
    });

    $("btnAll").addEventListener("click", function () { state.view.forEach(function (r) { r.sel = true; }); render(); });
    $("btnNone").addEventListener("click", function () { state.view.forEach(function (r) { r.sel = false; }); render(); });

    var qTimer = null;
    $("txtSearch").addEventListener("input", function (e) {
        clearTimeout(qTimer);
        var v = e.target.value;
        qTimer = setTimeout(function () { state.query = v; state.page = 1; recompute(); }, 120);
    });
    $("txtSearch").addEventListener("keydown", function (e) { if (e.key === "Enter") e.preventDefault(); });

    $("ddlPageSize").addEventListener("change", function (e) {
        state.pageSize = +e.target.value; state.page = 1; recompute();
    });
    $("btnPrev").addEventListener("click", function () { if (state.page > 1) { state.page--; render(); } });
    $("btnNext").addEventListener("click", function () { state.page++; render(); });

    /* ---------- start ---------- */
    loadFromHidden();
    recompute();
})();
</script>
</body>
</html>
