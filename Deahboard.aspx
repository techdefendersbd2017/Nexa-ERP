<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Deahboard.aspx.cs" Inherits="Nexa_ERP.Deahboard" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>ERP Dashboard</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <%--Push puul Home pc--%>
    <%--Push puul Office pc--%>

    <style>
        * { box-sizing: border-box; }
        body { background-color: #f4f6f9; margin: 0; padding: 0; }

        /* ===== LAYOUT ===== */
        .layout-wrapper {
            display: flex;
            height: calc(100vh - 56px);
            overflow: hidden;
        }

        /* ===== SIDEBAR ===== */
        #sidebarPanel {    
            display: inline-block;
            width: fit-content;            /* fixed width remove */
            min-width: 300px;         /* minimum width থাকবে */
            max-width: 400px;         /* চাইলে limit দিতে পারেন */
            white-space: nowrap;      /* text wrap হবে না */
            background: #1f2933;
            color: #fff;
            padding-top: 20px;
            height: 100%;
            overflow-y: auto;
            overflow-x: hidden;
            transition: width 0.3s ease, min-width 0.3s ease, padding 0.3s ease;
        }

        #sidebarPanel.collapsed {
            width: 0px;
            min-width: 0px;
            padding: 0;
        }

        #sidebarPanel.collapsed * {
            display: none !important;
        }

        /* ===== MAIN CONTENT ===== */
        #mainContent {
            flex: 1;
            padding: 8px;
            overflow: auto;
            transition: all 0.3s ease;
        }

        /* ===== TREE MENU ===== */
.tree-menu ul {
    list-style: none;
    padding-left: 22px;
    position: relative;
}

/* Vertical Dotted Line */
.tree-menu ul::before {
    content: '';
    position: absolute;
    top: 0;
    left: 10px;
    width: 1px;
    height: 100%;
    border-left: 1px dashed #0d6efd;
}

/* Horizontal Connector Line */
.tree-menu li {
    position: relative;
    margin: 6px 0;
    padding-left: 18px;
}

.tree-menu li::before {
    content: '';
    position: absolute;
    top: 12px;
    left: 0;
    width: 10px;
    border-top: 1px dashed #0d6efd;
}
.tree-menu ul::before,
.tree-menu li::before {
    transition: all 1s ease;
}



        .tree-menu a { color: #cfd8dc; text-decoration: none; font-size: 14px; cursor: pointer; }
        .tree-menu a:hover { color: #fff; }

        .submenu, .pages { display: none; }
        iframe { width: 100%; height: 78vh; border: none; background: #fff; }

        .toggle-icon { transition: transform 0.3s; }
        .rotate { transform: rotate(180deg); }

        /* ===== NAVBAR TOGGLE BUTTON ===== */
        #navbarToggleBtn {
            background: transparent;
            border: 1px solid rgba(255,255,255,0.3);
            color: #fff;
            font-size: 18px;
            cursor: pointer;
            padding: 4px 10px;
            border-radius: 4px;
            margin-right: 10px;
            line-height: 1;
        }
        #navbarToggleBtn:hover {
            background: rgba(255,255,255,0.2);
        }
.company-logo {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #0d6efd;
    box-shadow: 0 0 8px rgba(13,110,253,0.6);
}

/* Popup List View */
.branch-popup {
    position: absolute;
    top: 55px;
    left: 10px;
    width: 220px;
    background: #ffffff;
    border-radius: 10px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.15);
    display: none;
    z-index: 9999;
    animation: fadeIn 0.2s ease-in-out;
}

.branch-popup ul {
    list-style: none;
    margin: 0;
    padding: 8px 0;
}

.branch-popup li {
    padding: 10px 15px;
    cursor: pointer;
    font-size: 14px;
    transition: 0.2s;
    color: #1f2933;
}

.branch-popup li:hover {
    background: #f1f5f9;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(-5px); }
    to { opacity: 1; transform: translateY(0); }
}

#moduleDashboard {
    animation: fadeIn 0.25s ease-in-out;
}

.module-card {
    background: #ffffff;
    border-radius: 14px;
    padding: 22px 16px;
    text-align: center;
    cursor: pointer;
    box-shadow: 0 4px 14px rgba(0,0,0,0.06);
    border: 1px solid #eef0f3;
    transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
    height: 100%;
}

.module-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 10px 22px rgba(13,110,253,0.18);
    border-color: #0d6efd;
}

.module-card-icon {
    font-size: 32px;
    color: #0d6efd;
    margin-bottom: 10px;
}

.module-card-title {
    font-weight: 600;
    color: #1f2933;
    font-size: 15px;
    margin-bottom: 4px;
}

.module-card-sub {
    font-size: 12px;
    color: #8a97a5;
}

#backToModulesBtn {
    background: rgba(13,110,253,0.15);
    padding: 8px 10px;
    border-radius: 6px;
    font-size: 13px;
    transition: background 0.2s;
}
#backToModulesBtn:hover {
    background: rgba(13,110,253,0.3);
}

#pageTitleBar {
    background: #ffffff;
    border: 1px solid #e5e9ef;
    border-left: 4px solid #0d6efd;
    border-radius: 8px;
    padding: 10px 16px;
    margin-bottom: 8px;
    font-weight: 600;
    color: #1f2933;
    font-size: 15px;
    min-height: 20px;
}

/* ===== HOME ICON (navbar) ===== */
#homeIconBtn {
    cursor: pointer;
    font-size: 20px;
    color: #fff;
    margin-right: 8px;
    transition: color 0.2s;
}
#homeIconBtn:hover {
    color: #0d6efd;
}

/* ===== USER PROFILE (sidebar) ===== */
.user-profile-trigger {
    cursor: pointer;
    color: inherit;
}
.user-avatar {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    object-fit: cover;
    border: 2px solid #0d6efd;
    box-shadow: 0 0 8px rgba(13,110,253,0.6);
}

    </style>
</head>

<body>
<form id="form1" runat="server">

    <!-- NAVBAR -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark px-3" style="height:56px">

        <button id="navbarToggleBtn" type="button" onclick="toggleSidebar(); return false;">
            <i id="toggleIcon" class="bi bi-layout-sidebar"></i>
        </button>

        <span class="navbar-brand fw-bold d-flex align-items-center gap-2 mb-0">
            <i id="homeIconBtn" class="bi bi-house-door-fill" title="Home" onclick="backToModules(); return false;"></i>
            <span>NexaERP</span>
        </span>

        <div class="ms-auto">
            <span class="text-white me-3">Welcome, <asp:Label ID="lblUser" runat="server" Text="Admin" /></span>
            <asp:Button ID="btnLogout" runat="server" Text="Logout" CssClass="btn btn-outline-light btn-sm" OnClick="btnLogout_Click" />
        </div>
    </nav>

    <!-- LAYOUT -->
    <div class="layout-wrapper">

        <!-- SIDEBAR -->
        <div id="sidebarPanel">

            <h6 class="text-info px-3 position-relative">

                <a class="navbar-brand fw-bold d-flex align-items-center gap-2 user-profile-trigger"
                   onclick="toggleUserPopup(); return false;">

                    <img src="Images/user-avatar.png" class="user-avatar" id="userAvatarImg" />

                    <span><asp:Label ID="lblUserName" runat="server" Text="Admin" /></span>

                    <i class="bi bi-chevron-down small ms-auto" id="userArrow"></i>
                </a>

                <div id="userPopup" class="branch-popup">
                    <ul>
                        <li onclick="doLogout(); return false;">
                            <i class="bi bi-box-arrow-right me-2"></i> Logout
                        </li>
                    </ul>
                </div>

            </h6>

            <div class="tree-menu px-4">

                <div id="backToModulesBtn"
                     class="d-flex align-items-center gap-2 text-info mb-3"
                     style="display:none; cursor:pointer;"
                     onclick="backToModules(); return false;">
                    <i class="bi bi-arrow-left-circle"></i>
                    <span>Return to Main Dashboard</span>
                </div>

                <div>
                    <asp:TextBox ID="txtFormNameSearch" runat="server" CssClass="form-control form-control-sm mb-2" 
                        placeholder="Search form..." onkeyup="searchMenu()"></asp:TextBox>
                </div>

                <ul class="tree-root">
                    <asp:Repeater ID="rptModules" runat="server">
                        <ItemTemplate>

                            <li class="module-item" data-module-id="mod_<%# Eval("Module_ID") %>">
                                <a onclick="toggleMenu('mod_<%# Eval("Module_ID") %>', this); return false;"
                                   class="d-flex justify-content-between align-items-center">
                                    <span>
                                        <i class='<%# Eval("Icon_Class") %> me-1'></i>
                                        <%# Eval("Module_Name") %>
                                    </span>
                                    <i class="bi bi-chevron-down toggle-icon"></i>
                                </a>

                                <ul id="mod_<%# Eval("Module_ID") %>" class="submenu"
                                    data-module-name="<%# Eval("Module_Name") %>"
                                    style="display:none; padding-left:20px;">
                                    <asp:Repeater ID="rptMenus" runat="server" DataSource='<%# Eval("Menus") %>'>
                                        <ItemTemplate>
                                            <li>
                                                <a onclick="toggleMenu('menu_<%# Eval("Menu_ID") %>', this); return false;"
                                                   class="d-flex justify-content-between align-items-center">
                                                    <span>
                                                        <i class='<%# Eval("Icon_Class") %> me-1'></i>
                                                        <%# Eval("Menu_Name") %>
                                                    </span>
                                                    <i class="bi bi-chevron-down toggle-icon"></i>
                                                </a>

                                                <ul id="menu_<%# Eval("Menu_ID") %>" class="pages"
                                                    data-menu-name="<%# Eval("Menu_Name") %>"
                                                    style="display:none; padding-left:20px;">
                                                    <asp:Repeater ID="rptForms" runat="server" DataSource='<%# Eval("Forms") %>'>
                                                        <ItemTemplate>
                                                            <li>

                                                                <a href='Deahboard.aspx?form=<%# System.Web.HttpUtility.UrlEncode(Eval("Form_Url").ToString()) %>'
                                                                   data-formurl='<%# Eval("Form_Url") %>'
                                                                   onclick="return loadPage(event, this);">
                                                                    <i class='<%# Eval("Icon_Class") %> me-1'></i>
                                                                    <%# Eval("Form_Name") %>
                                                                </a>
                                                            </li>
                                                        </ItemTemplate>
                                                    </asp:Repeater>
                                                </ul>
                                            </li>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </ul>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
            </div>
        </div>

        <div id="mainContent">

            <div id="moduleDashboard" class="row g-3 p-2">
                <div class="text-muted p-4">মডিউল লোড হচ্ছে...</div>
            </div>

            <div id="pageViewWrapper" style="display:none;">
                <div id="pageTitleBar"></div>
                <iframe id="mainFrame" src="about:blank"></iframe>
            </div>

        </div>

    </div>

</form>

<script>

    document.addEventListener("DOMContentLoaded", function () {
        buildModuleDashboard();
        autoOpenFromQueryString();
    });

    function buildModuleDashboard() {
        var dashboard = document.getElementById("moduleDashboard");
        dashboard.innerHTML = "";

        var modules = document.querySelectorAll(".tree-root > li.module-item");

        if (modules.length === 0) {
            dashboard.innerHTML = '<div class="text-muted p-4">কোনো মডিউল পাওয়া যায়নি।</div>';
            return;
        }

        modules.forEach(function (modLi) {
            var moduleId = modLi.getAttribute("data-module-id");
            var link = modLi.querySelector(":scope > a");
            var iconEl = link.querySelector("i");
            var iconClass = iconEl ? iconEl.className.replace("me-1", "").trim() : "bi bi-folder";
            var nameSpan = link.querySelector("span");
            var moduleName = nameSpan ? nameSpan.textContent.trim() : "Module";

            var submenu = document.getElementById(moduleId);
            var menuCount = submenu ? submenu.querySelectorAll(":scope > li").length : 0;

            var col = document.createElement("div");
            col.className = "col-6 col-md-3 col-lg-2";
            col.innerHTML =
                '<div class="module-card" onclick="selectModule(\'' + moduleId + '\')">' +
                    '<div class="module-card-icon"><i class="' + iconClass + '"></i></div>' +
            '<div class="module-card-title">' + moduleName + '</div>' +
            '<div class="module-card-sub">' + menuCount + ' Total Menus:</div>' +
                '</div>';

            dashboard.appendChild(col);
        });
    }

    function selectModule(moduleId) {

        document.querySelectorAll(".tree-root > li.module-item").forEach(function (li) {
            li.style.display = (li.getAttribute("data-module-id") === moduleId) ? "" : "none";
        });

        var submenu = document.getElementById(moduleId);
        if (submenu) {
            submenu.style.display = "block";
            var parentLink = submenu.previousElementSibling;
            var icon = parentLink ? parentLink.querySelector(".toggle-icon") : null;
            if (icon) icon.classList.add("rotate");
        }

        document.getElementById("backToModulesBtn").style.display = "flex";

        document.getElementById("moduleDashboard").style.display = "none";
        document.getElementById("pageViewWrapper").style.display = "block";
        document.getElementById("pageTitleBar").innerHTML =
            '<i class="bi bi-info-circle text-primary"></i> Please select a form from the left menu.';
        document.getElementById("mainFrame").src = "about:blank";
    }

    function backToModules() {
        document.querySelectorAll(".tree-root > li.module-item").forEach(function (li) {li.style.display = "";
            var link = li.querySelector(":scope > a");
            var submenu = li.querySelector(":scope > ul.submenu");
            if (submenu) submenu.style.display = "none";
            var icon = link ? link.querySelector(".toggle-icon") : null;
            if (icon) icon.classList.remove("rotate");
        });
        document.getElementById("backToModulesBtn").style.display = "none";
        document.getElementById("moduleDashboard").style.display = "flex";
        document.getElementById("pageViewWrapper").style.display = "none";
        document.getElementById("mainFrame").src = "about:blank";
    }

    /**
     * Fires on click of a form link.
     * - Plain left click: loads the page inside the iframe (SPA-style), same as before.
     * - Ctrl/Cmd+Click or Shift+Click: browser's native "open link in new tab" behavior
     *   is allowed to run (we do NOT call preventDefault). The href points back at
     *   THIS dashboard page (Deahboard.aspx?form=...), not the raw child page, so the
     *   new tab still shows the full dashboard shell (sidebar + navbar) -
     *   autoOpenFromQueryString() then loads the requested form into its iframe.
     * - Right click -> "Open link in new tab" from the context menu works the same way,
     *   since a real href is present.
     */
    function loadPage(e, el) {
        if (e && (e.ctrlKey || e.metaKey || e.shiftKey)) {
            // Let the browser handle it natively (opens Deahboard.aspx?form=... in a new tab)
            return true;
        }

        if (e && e.preventDefault) e.preventDefault();

        openFormInDashboard(el.getAttribute('data-formurl'), el);

        return false;
    }

    /**
     * Actually loads a form's URL into the dashboard's iframe, updates the breadcrumb,
     * and switches from the module-cards view to the page view. Shared by loadPage()
     * (normal click) and autoOpenFromQueryString() (page opened via ?form=... in a new tab).
     */
    function openFormInDashboard(url, el) {
        if (!url) return;

        var lbl = document.getElementById('<%= lblUser.ClientID %>');
        var userName = lbl ? lbl.innerText : '';

        var menuName = '';
        var moduleName = '';

        if (el) {
            var pagesUl = el.closest('.pages');
            if (pagesUl) menuName = pagesUl.getAttribute('data-menu-name') || '';

            var submenuUl = el.closest('.submenu');
            if (submenuUl) moduleName = submenuUl.getAttribute('data-module-name') || '';
        }

        var breadcrumb = [moduleName, menuName].filter(Boolean).join(' / ');
        var titleBar = document.getElementById('pageTitleBar');
        if (titleBar) {
            titleBar.innerHTML = breadcrumb
                ? '<i class="bi bi-file-earmark-text text-primary"></i> ' + breadcrumb
                : '';
        }

        document.getElementById('moduleDashboard').style.display = 'none';
        document.getElementById('pageViewWrapper').style.display = 'block';

        var sep = url.indexOf('?') > -1 ? '&' : '?';
        document.getElementById("mainFrame").src = url + sep + "user=" + encodeURIComponent(userName);
    }

    /**
     * If the dashboard was opened as Deahboard.aspx?form=<url> (i.e. from Ctrl+Click /
     * "Open in new tab" on a menu link), automatically expand the right module/menu in
     * the sidebar and load that page into the iframe - so the new tab looks exactly like
     * the original tab would after clicking that same link.
     */
    function autoOpenFromQueryString() {
        var params = new URLSearchParams(window.location.search);
        var formUrl = params.get('form');
        if (!formUrl) return;

        var links = document.querySelectorAll('.pages a[data-formurl]');
        var target = null;
        links.forEach(function (a) {
            if (a.getAttribute('data-formurl') === formUrl) target = a;
        });

        if (!target) {
            // Link not found in the current menu tree - still load the page so the user isn't stuck.
            openFormInDashboard(formUrl, null);
            return;
        }

        var moduleLi = target.closest('li.module-item');
        if (moduleLi) {
            selectModule(moduleLi.getAttribute('data-module-id'));
        }

        var pagesUl = target.closest('.pages');
        if (pagesUl) {
            pagesUl.style.display = 'block';
            var menuLink = pagesUl.previousElementSibling;
            var icon = menuLink ? menuLink.querySelector('.toggle-icon') : null;
            if (icon) icon.classList.add('rotate');
        }

        openFormInDashboard(formUrl, target);
    }

    function toggleMenu(id, el) {
        var submenu = document.getElementById(id);
        if (!submenu) return;
        submenu.style.display = submenu.style.display === "block" ? "none" : "block";
        var icon = el.querySelector(".toggle-icon");
        if (icon) icon.classList.toggle("rotate");
    }

    function toggleSidebar() {
        var sidebar = document.getElementById("sidebarPanel");
        var icon = document.getElementById("toggleIcon");

        if (sidebar.classList.contains("collapsed")) {
            sidebar.classList.remove("collapsed");
            icon.className = "bi bi-layout-sidebar";
        } else {
            sidebar.classList.add("collapsed");
            icon.className = "bi bi-layout-sidebar-reverse";
        }
    }

    function toggleUserPopup() {
        var popup = document.getElementById("userPopup");
        var arrow = document.getElementById("userArrow");

        if (popup.style.display === "block") {
            popup.style.display = "none";
            arrow.classList.remove("rotate");
        } else {
            popup.style.display = "block";
            arrow.classList.add("rotate");
        }
    }

    function doLogout() {
        // Server-side btnLogout ক্লিক করে দেয়, তাহলে code-behind এ থাকা
        // Session clear + Login পেজে redirect করার লজিক কাজ করবে।
        var logoutBtn = document.getElementById('<%= btnLogout.ClientID %>');
        if (logoutBtn) {
            logoutBtn.click();
        } else {
            window.location.href = "Login.aspx";
        }
    }

    document.addEventListener("click", function (e) {
        var popup = document.getElementById("userPopup");
        if (popup && !e.target.closest(".user-profile-trigger") && !e.target.closest("#userPopup")) {
            popup.style.display = "none";
            var arrow = document.getElementById("userArrow");
            if (arrow) arrow.classList.remove("rotate");
        }
    });
function searchMenu() {
    var input = document.getElementById('<%= txtFormNameSearch.ClientID %>');
    var term = input.value.trim().toLowerCase();

    var moduleItems = document.querySelectorAll('.tree-root > li.module-item');

    // সার্চ বক্স খালি হলে সব কিছু আগের অবস্থায় (collapsed) ফিরিয়ে দেওয়া
    if (term === '') {
        moduleItems.forEach(function(modLi) {
            modLi.style.display = '';
            var subUl = modLi.querySelector(':scope > ul.submenu');
            if (subUl) {
                subUl.style.display = 'none';
                subUl.querySelectorAll('li').forEach(function(li) { li.style.display = ''; });
                subUl.querySelectorAll('ul.pages').forEach(function(pagesUl) {
                    pagesUl.style.display = 'none';
                });
                var icon = modLi.querySelector(':scope > a .toggle-icon');
                if (icon) icon.classList.remove('rotate');
            }
        });
        return;
    }

    moduleItems.forEach(function(modLi) {
        var subUl = modLi.querySelector(':scope > ul.submenu');
        var moduleHasMatch = false;

        if (subUl) {
            var menuLis = subUl.querySelectorAll(':scope > li');
            menuLis.forEach(function(menuLi) {
                var pagesUl = menuLi.querySelector(':scope > ul.pages');
                var menuHasMatch = false;

                if (pagesUl) {
                    var formLis = pagesUl.querySelectorAll(':scope > li');
                    formLis.forEach(function(formLi) {
                        var a = formLi.querySelector('a[data-formurl]');
                        var formName = a ? a.textContent.trim().toLowerCase() : '';
                        var isMatch = formName.indexOf(term) > -1;
                        formLi.style.display = isMatch ? '' : 'none';
                        if (isMatch) menuHasMatch = true;
                    });
                }

                menuLi.style.display = menuHasMatch ? '' : 'none';
                if (pagesUl) pagesUl.style.display = menuHasMatch ? 'block' : 'none';
                if (menuHasMatch) moduleHasMatch = true;
            });
        }

        modLi.style.display = moduleHasMatch ? '' : 'none';
        if (subUl) subUl.style.display = moduleHasMatch ? 'block' : subUl.style.display;
    });
}

</script>

</body>
</html>
