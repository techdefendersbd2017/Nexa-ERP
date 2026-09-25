

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
        document.querySelectorAll(".tree-root > li.module-item").forEach(function (li) {
            li.style.display = "";
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
            moduleItems.forEach(function (modLi) {
                modLi.style.display = '';
                var subUl = modLi.querySelector(':scope > ul.submenu');
                if (subUl) {
                    subUl.style.display = 'none';
                    subUl.querySelectorAll('li').forEach(function (li) { li.style.display = ''; });
                    subUl.querySelectorAll('ul.pages').forEach(function (pagesUl) {
                        pagesUl.style.display = 'none';
                    });
                    var icon = modLi.querySelector(':scope > a .toggle-icon');
                    if (icon) icon.classList.remove('rotate');
                }
            });
        return;
    }

        moduleItems.forEach(function (modLi) {
        var subUl = modLi.querySelector(':scope > ul.submenu');
        var moduleHasMatch = false;

        if (subUl) {
            var menuLis = subUl.querySelectorAll(':scope > li');
        menuLis.forEach(function (menuLi) {
                var pagesUl = menuLi.querySelector(':scope > ul.pages');
        var menuHasMatch = false;

        if (pagesUl) {
                    var formLis = pagesUl.querySelectorAll(':scope > li');
        formLis.forEach(function (formLi) {
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
