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
}

.branch-popup li:hover {
    background: #f1f5f9;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(-5px); }
    to { opacity: 1; transform: translateY(0); }
}

/* ============================================================
   নতুন সংযোজন: মডিউল ড্যাশবোর্ড (হোম পেজ কার্ড ভিউ)
   - এই কার্ডগুলো ডানপাশে (mainContent) সব মডিউল দেখাবে
   - প্রতিটি কার্ডে মডিউলের আইকন, নাম এবং মেনু সংখ্যা দেখাবে
   ============================================================ */
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

/* ============================================================
   নতুন সংযোজন: "সকল মডিউলে ফিরে যান" বাটন (সাইডবারে)
   - যখন কোনো একটি মডিউল সিলেক্ট করা হয়, তখন এই বাটন দেখা যাবে
   - এতে ক্লিক করলে আবার সব মডিউল সাইডবারে ফিরে আসবে
   ============================================================ */
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

/* ============================================================
   নতুন সংযোজন: পেজ টাইটেল বার
   - কোনো ফর্মে ক্লিক করলে এখানে "মডিউল / মেনু" নাম দেখাবে
   ============================================================ */
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

    </style>
</head>

<body>
<form id="form1" runat="server">

    <!-- NAVBAR -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark px-3" style="height:56px">

        <!-- ✅ type="button" দেওয়া হয়েছে যাতে form submit না হয় -->
        <button id="navbarToggleBtn" type="button" onclick="toggleSidebar(); return false;">
            <i id="toggleIcon" class="bi bi-layout-sidebar"></i>
        </button>

        <!-- ✅ "NexaERP Home" এ ক্লিক করলে আবার সব মডিউলের ড্যাশবোর্ড (হোম কার্ড ভিউ) দেখাবে -->
        <a class="navbar-brand fw-bold" onclick="backToModules(); return false;"> NexaERP Home</a>

        <div class="ms-auto">
            <span class="text-white me-3">Welcome, <asp:Label ID="lblUser" runat="server" Text="Admin" /></span>
            <!-- ✅ OnClientClick="return false;" দেওয়া হয়েছে যাতে Logout postback না করে -->
            <asp:Button ID="btnLogout" runat="server" Text="Logout" CssClass="btn btn-outline-light btn-sm" />
        </div>
    </nav>

    <!-- LAYOUT -->
    <div class="layout-wrapper">

        <!-- SIDEBAR -->
        <div id="sidebarPanel">

            <h6 class="text-info px-3 position-relative">

                <a class="navbar-brand fw-bold d-flex align-items-center gap-2"
                   onclick="toggleBranchPopup(); return false;"
                   style="cursor:pointer; color:inherit;">

                    <!-- Company Logo -->
                    <img src="Images/company-logo.png" class="company-logo" />

                    <span>Pantex Limited</span>

                    <i class="bi bi-chevron-down small ms-auto" id="branchArrow"></i>
                </a>

                <!-- Popup List View -->
                <div id="branchPopup" class="branch-popup">
                    <ul>
                        <li onclick="loadPage('Dashboard.aspx')">🏢 Head Office</li>
                        <li onclick="loadPage('Branch1.aspx')">🏭 Gazipur Branch</li>
                        <li onclick="loadPage('Branch2.aspx')">🏬 Chittagong Branch</li>
                    </ul>
                </div>

            </h6>

            <div class="tree-menu px-4">

                <!-- ✅ নতুন সংযোজন: এই বাটনটি ডিফল্টভাবে লুকানো থাকবে।
                     যখন ডানপাশের কোনো মডিউল কার্ডে ক্লিক করা হবে, তখন এটি দেখা যাবে।
                     এতে ক্লিক করলে সাইডবারে আবার সব মডিউল দেখা যাবে। -->
                <div id="backToModulesBtn"
                     class="d-flex align-items-center gap-2 text-info mb-3"
                     style="display:none; cursor:pointer;"
                     onclick="backToModules(); return false;">
                    <i class="bi bi-arrow-left-circle"></i>
                    <span>Return to Main Dashboard</span>
                </div>

                <ul class="tree-root">
                    <asp:Repeater ID="rptModules" runat="server">
                        <ItemTemplate>
                            <!-- ✅ "module-item" ক্লাস এবং "data-module-id" যোগ করা হয়েছে
                                 যাতে জাভাস্ক্রিপ্ট দিয়ে সহজে এই লিস্ট আইটেমটিকে
                                 খুঁজে বের করে দেখানো/লুকানো (filter) করা যায় -->
                            <li class="module-item" data-module-id="mod_<%# Eval("Module_ID") %>">
                                <a onclick="toggleMenu('mod_<%# Eval("Module_ID") %>', this); return false;"
                                   class="d-flex justify-content-between align-items-center">
                                    <span>
                                        <i class='<%# Eval("Icon_Class") %> me-1'></i>
                                        <%# Eval("Module_Name") %>
                                    </span>
                                    <i class="bi bi-chevron-down toggle-icon"></i>
                                </a>

                                <!-- ✅ "data-module-name" যোগ করা হয়েছে যাতে ফর্মে ক্লিক করার সময়
                                     আমরা জানতে পারি এটি কোন মডিউলের অন্তর্গত (title bar এ দেখানোর জন্য) -->
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

                                                <!-- ✅ "data-menu-name" যোগ করা হয়েছে যাতে ফর্মে ক্লিক করলে
                                                     পেজ টাইটেল বার-এ এই মেনুর নাম দেখানো যায় -->
                                                <ul id="menu_<%# Eval("Menu_ID") %>" class="pages"
                                                    data-menu-name="<%# Eval("Menu_Name") %>"
                                                    style="display:none; padding-left:20px;">
                                                    <asp:Repeater ID="rptForms" runat="server" DataSource='<%# Eval("Forms") %>'>
                                                        <ItemTemplate>
                                                            <li>
                                                                <!-- ✅ "this" পাঠানো হচ্ছে যাতে loadPage() ফাংশনটি
                                                                     ঠিক কোন মডিউল/মেনু থেকে ক্লিক হয়েছে তা বুঝতে পারে -->
                                                                <a onclick="loadPage('<%# Eval("Form_Url") %>', this); return false;">
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

        <!-- MAIN CONTENT (ডানপাশ) -->
        <div id="mainContent">

            <!-- ✅ নতুন সংযোজন: মডিউল ড্যাশবোর্ড (হোম ভিউ)
                 এখানে সব মডিউল কার্ড আকারে দেখানো হবে। এটি জাভাস্ক্রিপ্ট দিয়ে
                 সাইডবারের ডেটা থেকে অটোমেটিক তৈরি হয় (buildModuleDashboard ফাংশন)। -->
            <div id="moduleDashboard" class="row g-3 p-2">
                <div class="text-muted p-4">মডিউল লোড হচ্ছে...</div>
            </div>

            <!-- ✅ নতুন সংযোজন: ফর্ম/পেজ ভিউ (ডিফল্টভাবে লুকানো)
                 কোনো ফর্মে ক্লিক করলে এটি দেখানো হবে এবং উপরে টাইটেল বার-এ
                 কোন মেনুর ফর্ম খোলা হয়েছে তা দেখাবে। -->
            <div id="pageViewWrapper" style="display:none;">
                <div id="pageTitleBar"></div>
                <iframe id="mainFrame" src="about:blank"></iframe>
            </div>

        </div>

    </div>

</form>

<script>
    // ✅ সব script form এর বাইরে এবং body শেষে রাখা হয়েছে

    /* ============================================================
       পেজ লোড হওয়ার সাথে সাথে সাইডবারের (hidden) ডেটা থেকে
       ডানপাশের "মডিউল ড্যাশবোর্ড" কার্ডগুলো তৈরি করা হয়
       ============================================================ */
    document.addEventListener("DOMContentLoaded", buildModuleDashboard);

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

            // এই মডিউলের অধীনে কতগুলো মেনু আছে তা গণনা করা হচ্ছে
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

    /* ============================================================
       ডানপাশে কোনো মডিউল কার্ডে ক্লিক করলে এই ফাংশন কাজ করবে:
       ১) সাইডবারে শুধুমাত্র সিলেক্ট করা মডিউলটি দেখাবে (বাকিগুলো লুকাবে)
       ২) সিলেক্ট করা মডিউলের সাব-মেনু অটোমেটিক ওপেন করে দিবে
       ৩) "সকল মডিউলে ফিরে যান" বাটন দেখাবে
       ৪) ডানপাশে ফর্ম ভিউ প্লেসহোল্ডার দেখাবে (ফর্ম সিলেক্ট করার আগ পর্যন্ত)
       ============================================================ */
    function selectModule(moduleId) {

        // ১) সাইডবারের সব মডিউল থেকে শুধু সিলেক্টেড মডিউলটি দৃশ্যমান রাখা
        document.querySelectorAll(".tree-root > li.module-item").forEach(function (li) {
            li.style.display = (li.getAttribute("data-module-id") === moduleId) ? "" : "none";
        });

        // ২) সিলেক্টেড মডিউলের সাব-মেনু (menu list) খুলে দেওয়া
        var submenu = document.getElementById(moduleId);
        if (submenu) {
            submenu.style.display = "block";
            var parentLink = submenu.previousElementSibling;
            var icon = parentLink ? parentLink.querySelector(".toggle-icon") : null;
            if (icon) icon.classList.add("rotate");
        }

        // ৩) "সকল মডিউলে ফিরে যান" বাটন দেখানো
        document.getElementById("backToModulesBtn").style.display = "flex";

        // ৪) ডানপাশে ড্যাশবোর্ড কার্ড লুকিয়ে ফর্ম ভিউ (খালি অবস্থায়) দেখানো
        document.getElementById("moduleDashboard").style.display = "none";
        document.getElementById("pageViewWrapper").style.display = "block";
        document.getElementById("pageTitleBar").innerHTML =
            '<i class="bi bi-info-circle text-primary"></i> Please select a form from the left menu.';
        document.getElementById("mainFrame").src = "about:blank";
    }

    /* ============================================================
       "সকল মডিউলে ফিরে যান" বাটনে বা "NexaERP Home" এ ক্লিক করলে
       আবার সব মডিউল সাইডবার এবং ডানপাশের ড্যাশবোর্ডে দেখানো হবে
       ============================================================ */
    function backToModules() {
        document.querySelectorAll(".tree-root > li.module-item").forEach(function (li) {
            li.style.display = "";

            // প্রতিটি মডিউলের সাব-মেনু আবার বন্ধ (collapsed) করে দেওয়া হচ্ছে
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

    /* ============================================================
       কোনো ফর্মে ক্লিক করলে এই ফাংশন কাজ করে:
       - iframe এ ফর্মের পেজ লোড করে
       - পেজ টাইটেল বার-এ "মডিউলের নাম / মেনুর নাম" দেখায়
       - প্যারামিটার "el" হলো যে <a> ট্যাগে ক্লিক করা হয়েছে সেটি
       ============================================================ */
    function loadPage(url, el) {
        var lbl = document.getElementById('<%= lblUser.ClientID %>');
        var userName = lbl ? lbl.innerText : '';

        var menuName = '';
        var moduleName = '';

        if (el) {
            // el (ক্লিক করা ফর্মের লিংক) থেকে উপরের দিকে খুঁজে
            // সংশ্লিষ্ট মেনু ও মডিউলের নাম বের করা হচ্ছে
            var pagesUl = el.closest('.pages');
            if (pagesUl) menuName = pagesUl.getAttribute('data-menu-name') || '';

            var submenuUl = el.closest('.submenu');
            if (submenuUl) moduleName = submenuUl.getAttribute('data-module-name') || '';
        }

        // টাইটেল বার-এ "মডিউল / মেনু" আকারে ব্রেডক্রাম্ব দেখানো
        var breadcrumb = [moduleName, menuName].filter(Boolean).join(' / ');
        var titleBar = document.getElementById('pageTitleBar');
        if (titleBar) {
            titleBar.innerHTML = breadcrumb
                ? '<i class="bi bi-file-earmark-text text-primary"></i> ' + breadcrumb
                : '';
        }

        // ড্যাশবোর্ড কার্ড লুকিয়ে ফর্ম ভিউ দেখানো
        document.getElementById('moduleDashboard').style.display = 'none';
        document.getElementById('pageViewWrapper').style.display = 'block';

        document.getElementById("mainFrame").src = url + "?user=" + encodeURIComponent(userName);
    }

    // Tree menu open/close — ✅ return false দেওয়া আছে যাতে form submit না হয়
    function toggleMenu(id, el) {
        var submenu = document.getElementById(id);
        if (!submenu) return;
        submenu.style.display = submenu.style.display === "block" ? "none" : "block";
        var icon = el.querySelector(".toggle-icon");
        if (icon) icon.classList.toggle("rotate");
    }

    // ✅ Sidebar toggle — CSS width দিয়ে কাজ করে, কোনো class conflict নেই
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
    function toggleBranchPopup() {
        var popup = document.getElementById("branchPopup");
        var arrow = document.getElementById("branchArrow");

        if (popup.style.display === "block") {
            popup.style.display = "none";
            arrow.classList.remove("rotate");
        } else {
            popup.style.display = "block";
            arrow.classList.add("rotate");
        }
    }

    // Outside click করলে auto close
    document.addEventListener("click", function (e) {
        var popup = document.getElementById("branchPopup");
        if (!e.target.closest(".navbar-brand")) {
            popup.style.display = "none";
        }
    });

</script>

</body>
</html>
