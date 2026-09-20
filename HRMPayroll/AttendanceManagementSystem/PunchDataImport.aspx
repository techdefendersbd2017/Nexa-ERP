<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PunchDataImport.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting.PunchDataImport" ClientIDMode="Static" ResponseEncoding="utf-8" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <meta charset="utf-8" />
    <title>Punch Data Import - NexaERP</title>
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

    button, input, select { font-family: inherit; }

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
        transition: border-color 0.15s ease, box-shadow 0.15s ease;
    }
    .pd-dragging .pd-card { border-color: var(--brand-primary); box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.18); }

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

    .pd-group { display: flex; }
    .pd-group .pd-control { border-top-right-radius: 0; border-bottom-right-radius: 0; cursor: pointer; text-overflow: ellipsis; }
    .pd-group .pd-btn { border-top-left-radius: 0; border-bottom-left-radius: 0; }

    .pd-hint { margin: 6px 0 0; font-size: 0.78rem; color: var(--text-muted); }

    .pd-alert {
        margin-top: 14px;
        padding: 10px 14px;
        border-radius: 8px;
        background: #fdecea;
        border: 1px solid #f5c2c0;
        color: #a3261f;
        font-size: 0.88rem;
        font-weight: 500;
        word-break: break-word;
    }

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

    /* ---------- Grid (normal, fixed columns) ---------- */
    .pd-toolbar { padding: 12px 16px; border-bottom: 1px solid var(--border-soft); }
    .pd-toolbar .pd-control { max-width: 340px; }

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
    .pd-grid-wrapper td.pd-no, .pd-grid-wrapper th.pd-no { width: 1%; text-align: right; }
    .pd-grid-wrapper td.pd-no { color: #9ca3af; border-right: 1px solid var(--border-soft); }
    .pd-grid-wrapper td.pd-null { color: #b6bcc6; }
    .pd-grid-wrapper tbody tr:hover { background-color: #f0f6ff; }
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

    /* Tablet & Mobile */
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
            <circle cx="12" cy="12" r="9"></circle><path d="M12 7v5l3 2"></path>
        </svg>
        <div>
            <h3>Punch Data Import</h3>
            <small>HRM Configuration &rsaquo; Attendance &rsaquo; Punch Data Import</small>
        </div>
    </div>

    <div class="pd-row">

        <!-- Left Side Form -->
        <div class="pd-col-left">
            <div class="pd-card">

                <div class="pd-card-header bg-primary">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                        <path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"></path><path d="M14 3v5h5"></path><path d="M9 13h6M9 17h6"></path>
                    </svg>
                    <h4>Import File</h4>
                </div>

                <div class="pd-left-panel">
                    <div class="pd-fields">

                        <div class="pd-span2">
                            <label for="txtFileName">Select File</label>
                            <div class="pd-group">
                                <input type="text" id="txtFileName" class="pd-control" readonly="readonly" placeholder="No file chosen" />
                                <button type="button" id="btnBrowse" class="pd-btn pd-btn-primary">Browse</button>
                            </div>
                            <p class="pd-hint">Supported: .xlsx, .xls, .csv (max 20 MB). You can also drag &amp; drop a file onto this page.</p>
                            <div class="pd-alert" id="pdError" role="alert" hidden="hidden"></div>
                        </div>

                        <div class="pd-span2">
                            <label for="ddlSheet">Sheet</label>
                            <select id="ddlSheet" class="pd-control" disabled="disabled">
                                <option>-</option>
                            </select>
                        </div>

                        <div>
                            <label for="txtFileSize">File Size</label>
                            <input type="text" id="txtFileSize" class="pd-control" readonly="readonly" />
                        </div>

                        <div>
                            <label for="txtTotalRows">Total Rows</label>
                            <input type="text" id="txtTotalRows" class="pd-control" readonly="readonly" />
                        </div>

                        <div class="pd-span2">
                            <label for="txtExportRows">Rows to Export</label>
                            <input type="text" id="txtExportRows" class="pd-control" readonly="readonly" />
                        </div>

                        <div class="pd-span2">
                            <label for="txtMissingCols">Columns Not Found in File</label>
                            <input type="text" id="txtMissingCols" class="pd-control" readonly="readonly" />
                        </div>

                    </div>

                    <div class="pd-action-bar">
                        <button type="button" id="btnCsv" class="pd-btn pd-btn-success" disabled="disabled">Export CSV</button>
                        <button type="button" id="btnJson" class="pd-btn pd-btn-secondary" disabled="disabled">Export JSON</button>
                        <button type="button" id="btnClear" class="pd-btn pd-btn-secondary" disabled="disabled">Clear</button>
                        <asp:Button ID="btnImport" runat="server" Text="Import" CssClass="pd-btn pd-btn-primary"
                            OnClick="btnImport_Click" OnClientClick="return prepareImport();" Enabled="true" />
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
                    <h4>Punch Data List</h4>
                    <span class="pd-badge" id="pdBadge">0 rows</span>
                </div>

                <div class="pd-toolbar">
                    <input type="search" id="txtSearch" class="pd-control" placeholder="Search in all columns..." aria-label="Search in all columns" autocomplete="off" disabled="disabled" />
                </div>

                <div class="pd-grid-wrapper" id="pdGridWrap" tabindex="0" role="region" aria-label="Punch data grid">
                    <table id="gvPunch">
                        <thead>
                            <tr>
                                <th class="pd-no" scope="col">No.</th>
                                <th scope="col">Staff Code</th>
                                <th scope="col">Name</th>
                                <th scope="col">Department</th>
                                <th scope="col">User ID</th>
                                <th scope="col">Week</th>
                                <th scope="col">Date</th>
                                <th scope="col">Time</th>
                                <th scope="col">Machine ID</th>
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

<%-- All imported rows are copied into this field when Import is clicked --%>
<asp:HiddenField ID="hfPunchData" runat="server" />

<input type="file" id="fuPunch" hidden="hidden" accept=".xlsx,.xls,.xlsm,.ods,.csv" />
<div class="pd-toast" id="pdToast" role="status" aria-live="polite"></div>
</form>

<script src="xlsx.full.min.js"></script>
<script>window.XLSX || document.write('<scr' + 'ipt src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></scr' + 'ipt>');</script>
<script>
(function () {
    "use strict";

    var $ = function (id) { return document.getElementById(id); };

    /* ---------- settings ---------- */
    var MAX_MB = 20;
    var MAX_IMPORT_ROWS = 50000;           // safety limit for one Import click
    var ALLOWED_EXT = ["xlsx", "xls", "xlsm", "ods", "csv"];

    // Grid columns, in display order. "keys" are accepted header names in the file
    // (compared case-insensitively, ignoring spaces, dots and symbols).
    var COLUMNS = [
        { name: "No.",        json: "No",         keys: ["no", "sl", "slno", "serial", "sn", "srno"] },
        { name: "Staff Code", json: "StaffCode",  keys: ["staffcode", "staffid", "empcode", "employeecode", "empid", "employeeid", "cardno"] },
        { name: "Name",       json: "Name",       keys: ["name", "staffname", "employeename", "empname"] },
        { name: "Department", json: "Department", keys: ["department", "dept", "departmentname"] },
        { name: "User ID",    json: "UserID",     keys: ["userid", "user", "userno"] },
        { name: "Week",       json: "Week",       keys: ["week", "weekday", "day"] },
        { name: "Date",       json: "Date",       keys: ["date", "punchdate", "attendancedate"] },
        { name: "Time",       json: "Time",       keys: ["time", "punchtime", "intime"] },
        { name: "Machine ID", json: "MachineID",  keys: ["machineid", "machine", "machineno", "deviceid", "device"] }
    ];
    var NCOL = COLUMNS.length;

    var state = {
        wb: null, fileName: "", fileSize: 0, sheetIndex: 0,
        rows: [], missing: [], loaded: false,
        query: "", page: 1, pageSize: 50, view: []
    };

    /* ---------- helpers ---------- */
    function esc(s) {
        return String(s).replace(/[&<>"']/g, function (c) {
            return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c];
        });
    }
    function fmtSize(n) {
        if (n < 1024) return n + " B";
        if (n < 1048576) return (n / 1024).toFixed(1) + " KB";
        return (n / 1048576).toFixed(1) + " MB";
    }
    function plural(n, word) { return n + " " + word + (n === 1 ? "" : "s"); }
    function norm(s) { return String(s).toLowerCase().replace(/[^a-z0-9]/g, ""); }
    function errMsg(ex) { return (ex && ex.message) ? ex.message : "unknown error"; }

    var toastTimer = null;
    function toast(msg) {
        var t = $("pdToast");
        t.textContent = msg;
        t.classList.add("pd-show");
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { t.classList.remove("pd-show"); }, 2800);
    }
    function showError(msg) { var e = $("pdError"); e.textContent = msg; e.hidden = false; }
    function clearError() { $("pdError").hidden = true; }

    /* ---------- global error catch ---------- */
    window.addEventListener("error", function (e) {
        var m = e && e.message ? String(e.message) : "";
        if (m.indexOf("ResizeObserver") !== -1) return;
        if (e && e.target && e.target !== window && e.target.tagName === "SCRIPT") {
            showError("A required script failed to load: " + (e.target.src || "unknown") + ". Check that xlsx.full.min.js is available.");
            return;
        }
        showError("Unexpected error: " + (m || "unknown"));
    }, true);
    window.addEventListener("unhandledrejection", function (e) {
        showError("Unexpected error: " + errMsg(e && e.reason));
    });

    /* ---------- parsing ---------- */
    function sheetToAoa(ws) {
        var aoa = XLSX.utils.sheet_to_json(ws, { header: 1, raw: false, defval: "", blankrows: false });
        return aoa.map(function (r) {
            return r.map(function (c) { return String(c == null ? "" : c).trim(); });
        }).filter(function (r) {
            return r.some(function (c) { return c !== ""; });
        });
    }

    // Returns, for each grid column, the file column index (or -1).
    function mapColumns(headerRow) {
        var heads = headerRow.map(norm);
        var map = COLUMNS.map(function (col) {
            for (var i = 0; i < heads.length; i++) {
                if (heads[i] && col.keys.indexOf(heads[i]) !== -1) return i;
            }
            return -1;
        });
        var matched = map.filter(function (x) { return x !== -1; }).length;
        if (matched >= 3) return { map: map, mode: "name" };

        // Headers not recognised: fall back to column order.
        var width = headerRow.length;
        if (width >= NCOL) {
            return { map: COLUMNS.map(function (_, k) { return k; }), mode: "position" };
        }
        if (width === NCOL - 1) {   // file has no "No." column
            return { map: COLUMNS.map(function (_, k) { return k === 0 ? -1 : k - 1; }), mode: "position" };
        }
        return null;
    }

    function loadSheet(index) {
        var aoa = sheetToAoa(state.wb.Sheets[state.wb.SheetNames[index]]);
        if (!aoa.length) { showError("No data found in this sheet."); return false; }
        if (aoa.length < 2) { showError("This sheet has a header row but no data rows."); return false; }

        var m = mapColumns(aoa[0]);
        if (!m) {
            showError("Columns not recognised. Expected: " + COLUMNS.map(function (c) { return c.name; }).join(", ") + ".");
            return false;
        }

        var rows = [];
        for (var r = 1; r < aoa.length; r++) {
            var src = aoa[r], out = [], any = false;
            for (var k = 0; k < NCOL; k++) {
                var v = m.map[k] === -1 ? "" : (src[m.map[k]] || "");
                if (k !== 0 && v !== "") any = true;
                out.push(v);
            }
            if (!any) continue;
            out[0] = String(rows.length + 1);             // No. is always a running serial
            rows.push({ i: rows.length + 1, v: out, hay: out.join("\u0001").toLowerCase() });
        }
        if (!rows.length) { showError("No data rows found in this sheet."); return false; }

        state.sheetIndex = index;
        state.rows = rows;
        state.missing = COLUMNS.filter(function (c, k) { return k !== 0 && m.map[k] === -1; })
                               .map(function (c) { return c.name; });
        state.loaded = true;
        state.query = ""; $("txtSearch").value = "";
        state.page = 1;
        if (m.mode === "position") toast("Header names not recognised, columns were read by position");
        return true;
    }

    function handleFile(file) {
        clearError();
        if (!file) { showError("No file was selected."); return; }

        if (typeof XLSX === "undefined") {
            showError("Excel reader could not be loaded. Make sure xlsx.full.min.js is in the same folder as this page.");
            return;
        }
        var ext = (file.name.split(".").pop() || "").toLowerCase();
        if (ALLOWED_EXT.indexOf(ext) === -1) {
            showError("Unable to read this file. Please choose an .xlsx, .xls or .csv file.");
            return;
        }
        if (file.size === 0) { showError("The selected file is empty."); return; }
        if (file.size > MAX_MB * 1048576) {
            showError("File is too large (" + fmtSize(file.size) + "). Maximum allowed size is " + MAX_MB + " MB.");
            return;
        }

        readFile(file, ext).then(function (wb) {
            if (!wb || !wb.SheetNames || !wb.SheetNames.length) {
                showError("This file does not contain any sheets.");
                return;
            }
            var found = false, opened = false;
            for (var s = 0; s < wb.SheetNames.length; s++) {
                if (sheetToAoa(wb.Sheets[wb.SheetNames[s]]).length) {
                    found = true;
                    state.wb = wb;
                    opened = loadSheet(s);       // shows its own error on failure
                    break;
                }
            }
            if (!found) { showError("No data found in this file."); return; }
            if (!opened) { if (!state.loaded) state.wb = null; render(); return; }
            state.fileName = file.name; state.fileSize = file.size;
            fillSheetList();
            recompute();
        }).catch(function (ex) {
            console.error(ex);
            showError("Unable to read this file (" + errMsg(ex) + "). Check that it is not corrupted or password protected, then try again.");
        });
    }

    function readFile(file, ext) {
        return file.arrayBuffer().then(function (buf) {
            if (ext === "csv") {
                var text = new TextDecoder("utf-8").decode(buf).replace(/^\uFEFF/, "");
                return XLSX.read(text, { type: "string", raw: true });
            }
            return XLSX.read(buf, { type: "array", cellDates: false });
        });
    }

    function fillSheetList() {
        var sel = $("ddlSheet");
        sel.innerHTML = state.wb.SheetNames.map(function (n, i) {
            return '<option value="' + i + '"' + (i === state.sheetIndex ? ' selected="selected"' : "") + ">" + esc(n) + "</option>";
        }).join("");
        sel.disabled = state.wb.SheetNames.length < 2;
    }

    function resetAll() {
        state.wb = null; state.fileName = ""; state.fileSize = 0; state.sheetIndex = 0;
        state.rows = []; state.missing = []; state.loaded = false;
        state.query = ""; state.page = 1; state.view = [];
        $("txtSearch").value = "";
        $("ddlSheet").innerHTML = "<option>-</option>";
        $("ddlSheet").disabled = true;
        $("hfPunchData").value = "";
        clearError();
        render();
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
        return '<tr><td class="pd-empty-row" colspan="' + NCOL + '"><strong>' + esc(title) + "</strong>" + esc(text) + "</td></tr>";
    }

    function render() {
        var has = state.loaded;
        var total = state.rows.length, shown = state.view.length;
        var filtered = has && shown !== total;

        // body
        var start = (state.page - 1) * state.pageSize;
        var body = "";
        if (!has) {
            body = emptyRow("No data loaded", "Select an Excel or CSV file to preview its rows here.");
        } else if (shown === 0) {
            body = emptyRow("No matching rows", "Try a different search word.");
        } else {
            state.view.slice(start, start + state.pageSize).forEach(function (r) {
                body += "<tr>";
                r.v.forEach(function (c, k) {
                    var cls = k === 0 ? ' class="pd-no"' : (c === "" ? ' class="pd-null"' : "");
                    body += "<td" + cls + ">" + (c === "" && k !== 0 ? "\u2014" : esc(c)) + "</td>";
                });
                body += "</tr>";
            });
        }
        $("gvBody").innerHTML = body;

        // info fields
        $("txtFileName").value = state.fileName;
        $("txtFileSize").value = has ? fmtSize(state.fileSize) : "";
        $("txtTotalRows").value = has ? total : "";
        $("txtExportRows").value = has ? shown + (filtered ? " (filtered)" : "") : "";
        $("txtMissingCols").value = has ? (state.missing.length ? state.missing.join(", ") : "None") : "";

        // badge, footer, pager
        $("pdBadge").textContent = has ? (filtered ? shown + " of " + plural(total, "row") : plural(total, "row")) : "0 rows";
        var end = Math.min(start + state.pageSize, shown);
        $("pdRange").textContent = !has ? "0 rows"
            : shown === 0 ? "0 rows found"
            : "Showing " + (start + 1) + "\u2013" + end + " of " + plural(shown, "row") + (filtered ? " (total " + total + ")" : "");
        var pages = Math.max(1, Math.ceil(shown / state.pageSize));
        $("pdPageInfo").textContent = "Page " + state.page + " of " + pages;
        $("btnPrev").disabled = state.page <= 1;
        $("btnNext").disabled = state.page >= pages;

        // controls
        $("txtSearch").disabled = !has;
        $("btnCsv").disabled = $("btnJson").disabled = !has || shown === 0;
        $("btnClear").disabled = !has;
        $("btnImport").disabled = !has || total === 0;
    }

    /* ---------- export ---------- */
    function baseName() {
        return (state.fileName.replace(/\.[^.]+$/, "") || "punch-data").replace(/[\\\/:*?"<>|]/g, "_");
    }
    function csvCell(v) {
        return /[",\r\n]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v;
    }
    function buildCsv() {
        var lines = [COLUMNS.map(function (c) { return csvCell(c.name); }).join(",")];
        state.view.forEach(function (r) { lines.push(r.v.map(csvCell).join(",")); });
        return "\uFEFF" + lines.join("\r\n");
    }
    function rowsToObjects(list, useJsonKeys) {
        return list.map(function (r) {
            var o = {};
            COLUMNS.forEach(function (c, k) { o[useJsonKeys ? c.json : c.name] = r.v[k]; });
            return o;
        });
    }
    function buildJson() {
        return JSON.stringify(rowsToObjects(state.view, false), null, 2);
    }
    function saveFile(filename, text, mime, label) {
        var blob = new Blob([text], { type: mime });
        if (window.navigator && window.navigator.msSaveBlob) {
            window.navigator.msSaveBlob(blob, filename);
        } else {
            var url = URL.createObjectURL(blob);
            var a = document.createElement("a");
            a.href = url; a.download = filename;
            document.body.appendChild(a); a.click(); document.body.removeChild(a);
            setTimeout(function () { URL.revokeObjectURL(url); }, 1000);
        }
        toast(label + " downloaded");
    }
    function doExport(label, build, ext, mime) {
        try {
            clearError();
            if (!state.loaded) { showError("Please import a file first."); return; }
            if (!state.view.length) { showError("No rows to export."); return; }
            saveFile(baseName() + "." + ext, build(), mime, label);
        } catch (ex) {
            console.error(ex);
            showError(label + " export failed: " + errMsg(ex));
        }
    }

    /* ---------- server Import (called by the ASP.NET button's OnClientClick) ---------- */
    window.prepareImport = function () {
        try {
            clearError();
            if (!state.loaded || !state.rows.length) {
                showError("Please select a file with data before importing.");
                return false;
            }
            if (state.rows.length > MAX_IMPORT_ROWS) {
                showError("Too many rows (" + state.rows.length + "). Maximum " + MAX_IMPORT_ROWS + " rows can be imported at a time.");
                return false;
            }
            // All rows are imported, not only the filtered/visible ones.
            $("hfPunchData").value = JSON.stringify(rowsToObjects(state.rows, true));
            return true;
        } catch (ex) {
            console.error(ex);
            showError("Unable to prepare data for import: " + errMsg(ex));
            return false;
        }
    };

    /* ---------- events ---------- */
    var fileInput = $("fuPunch");
    function browse() { fileInput.click(); }
    $("btnBrowse").addEventListener("click", browse);
    $("txtFileName").addEventListener("click", browse);
    fileInput.addEventListener("change", function () {
        var f = fileInput.files && fileInput.files[0];
        fileInput.value = "";
        if (f) handleFile(f);
    });

    var dragDepth = 0, main = $("pdMain");
    function hasFiles(e) {
        return e.dataTransfer && Array.prototype.indexOf.call(e.dataTransfer.types || [], "Files") !== -1;
    }
    window.addEventListener("dragenter", function (e) {
        if (!hasFiles(e)) return;
        e.preventDefault(); dragDepth++; main.classList.add("pd-dragging");
    });
    window.addEventListener("dragover", function (e) { if (hasFiles(e)) e.preventDefault(); });
    window.addEventListener("dragleave", function (e) {
        if (!hasFiles(e)) return;
        dragDepth = Math.max(0, dragDepth - 1);
        if (!dragDepth) main.classList.remove("pd-dragging");
    });
    window.addEventListener("drop", function (e) {
        if (!hasFiles(e)) return;
        e.preventDefault(); dragDepth = 0; main.classList.remove("pd-dragging");
        var files = e.dataTransfer.files;
        if (!files || !files.length) { showError("No file was detected in the drop."); return; }
        if (files.length > 1) { showError("Please drop only one file at a time."); return; }
        handleFile(files[0]);
    });

    $("ddlSheet").addEventListener("change", function (e) {
        clearError();
        if (loadSheet(+e.target.value)) recompute();
        else e.target.value = String(state.sheetIndex);
    });

    var qTimer = null;
    $("txtSearch").addEventListener("input", function (e) {
        clearTimeout(qTimer);
        var v = e.target.value;
        qTimer = setTimeout(function () { state.query = v; state.page = 1; recompute(); }, 120);
    });
    // keep Enter in the search box from posting the ASP.NET form
    $("txtSearch").addEventListener("keydown", function (e) {
        if (e.key === "Enter") e.preventDefault();
    });

    $("ddlPageSize").addEventListener("change", function (e) {
        state.pageSize = +e.target.value; state.page = 1; recompute();
    });
    $("btnPrev").addEventListener("click", function () { if (state.page > 1) { state.page--; render(); } });
    $("btnNext").addEventListener("click", function () { state.page++; render(); });

    $("btnCsv").addEventListener("click", function () { doExport("CSV", buildCsv, "csv", "text/csv;charset=utf-8"); });
    $("btnJson").addEventListener("click", function () { doExport("JSON", buildJson, "json", "application/json"); });
    $("btnClear").addEventListener("click", resetAll);

    render();
})();
</script>
</body>
</html>
