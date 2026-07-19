<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Deahboard.aspx.cs" Inherits="Nexa_ERP.Deahboard" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>ERP Dashboard</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>


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
        /*.tree-menu ul { list-style: none; padding-left: 20px; position: relative; }
        .tree-menu ul::before {
            content: ''; position: absolute; top: 0; left: 8px;
            width: 2px; height: 100%; background: #0d6efd;
        }
        .tree-menu li { margin: 6px 0; padding-left: 15px; position: relative; }
        .tree-menu li::before {
            content: ''; position: absolute; top: 12px; left: 0;
            width: 10px; height: 2px; background: #0d6efd;
        }*/
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
        iframe { width: 100%; height: 82vh; border: none; background: #fff; }

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
        <a class="navbar-brand fw-bold" onclick="loadPage('Welcome.aspx')"> NexaERP Home</a> 
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
                <ul class="tree-root">
                    <asp:Repeater ID="rptModules" runat="server">
                        <ItemTemplate>
                            <li>
                                <a onclick="toggleMenu('mod_<%# Eval("Module_ID") %>', this); return false;"
                                   class="d-flex justify-content-between align-items-center">
                                    <span>
                                        <i class='<%# Eval("Icon_Class") %> me-1'></i>
                                        <%# Eval("Module_Name") %>
                                    </span>
                                    <i class="bi bi-chevron-down toggle-icon"></i>
                                </a>

                                <ul id="mod_<%# Eval("Module_ID") %>" class="submenu" style="display:none; padding-left:20px;">
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

                                                <ul id="menu_<%# Eval("Menu_ID") %>" class="pages" style="display:none; padding-left:20px;">
                                                    <asp:Repeater ID="rptForms" runat="server" DataSource='<%# Eval("Forms") %>'>
                                                        <ItemTemplate>
                                                            <li>
                                                                <a onclick="loadPage('<%# Eval("Form_Url") %>'); return false;">
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

        <!-- MAIN CONTENT -->
        <div id="mainContent">
            <iframe id="mainFrame" src="Welcome.aspx"></iframe>
        </div>

    </div>

</form>

<script>
    // ✅ সব script form এর বাইরে এবং body শেষে রাখা হয়েছে

    function loadPage(url) {
        var lbl = document.getElementById('<%= lblUser.ClientID %>');
        var userName = lbl ? lbl.innerText : '';
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




