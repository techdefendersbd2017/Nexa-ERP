<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DashboardNew.aspx.cs" Inherits="Nexa_ERP.DashboardNew" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>ERP Dashboard</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <script src="Assets/Dashboard.js"></script>
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

                <%-- আগে এখানে rptModules > rptMenus > rptForms — তিনটা fixed-level nested Repeater ছিল।
                     এখন পুরো ট্রি recursive-ভাবে code-behind-এ (TreeMenuHelper.RenderTree) বানিয়ে
                     এই একটা Literal-এ বসানো হচ্ছে, তাই depth যত গভীরই হোক automatic সামলাবে। --%>
                <asp:Literal ID="ltrMenu" runat="server"></asp:Literal>

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



</body>
</html>
