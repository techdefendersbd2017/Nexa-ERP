/* ============================================================
   StyleInformationForGarments.js
   Searchable Dropdown Engine for Nexa ERP Style Entry Master
   ============================================================ */

(function () {
    "use strict";

    /* ------------------------------------------------------------
       MASTER DATA  (এখানে আপনার ড্রপডাউনের ডেটা বসান)
       ------------------------------------------------------------ */
    var DD_DATA = {

        /* ---------- Search Filter (List Panel) ---------- */
        buyerFilter: [
            { v: "1", t: "H&M" },
            { v: "2", t: "Zara" },
            { v: "3", t: "Primark" },
            { v: "4", t: "C&A" },
            { v: "5", t: "Mango" }
        ],
        statusFilter: [
            { v: "D", t: "Draft" },
            { v: "A", t: "Active" },
            { v: "I", t: "Inactive" },
            { v: "C", t: "Closed" }
        ],

        /* ---------- Basic Info ---------- */
        buyer: [
            { v: "1", t: "H&M" },
            { v: "2", t: "Zara" },
            { v: "3", t: "Primark" },
            { v: "4", t: "C&A" },
            { v: "5", t: "Mango" }
        ],
        brand: [
            { v: "1", t: "H&M" },
            { v: "2", t: "Zara" },
            { v: "3", t: "Primark" },
            { v: "4", t: "Divided" },
            { v: "5", t: "LOG" }
        ],
        agent: [
            { v: "1", t: "Li & Fung" },
            { v: "2", t: "MAF" },
            { v: "3", t: "Buying House Ltd" },
            { v: "4", t: "Direct" }
        ],
        season: [
            { v: "SS", t: "Spring-Summer" },
            { v: "AW", t: "Autumn-Winter" },
            { v: "HO", t: "Holiday" },
            { v: "RE", t: "Resort" }
        ],
        seasonYear: [
            { v: "2024", t: "2024" },
            { v: "2025", t: "2025" },
            { v: "2026", t: "2026" },
            { v: "2027", t: "2027" }
        ],
        productCategory: [
            { v: "APP", t: "Apparel" },
            { v: "ACC", t: "Accessories" },
            { v: "FTW", t: "Footwear" },
            { v: "HOM", t: "Home Textile" }
        ],
        productType: [
            { v: "TOP", t: "Top" },
            { v: "BOT", t: "Bottom" },
            { v: "SET", t: "Set" },
            { v: "ONP", t: "One Piece" }
        ],
        garmentType: [
            { v: "TSH", t: "T-Shirt" },
            { v: "PNT", t: "Pant" },
            { v: "SHT", t: "Shirt" },
            { v: "JKT", t: "Jacket" },
            { v: "DRS", t: "Dress" },
            { v: "SWT", t: "Sweater" }
        ],
        gender: [
            { v: "M", t: "Men" },
            { v: "W", t: "Women" },
            { v: "K", t: "Kids" },
            { v: "B", t: "Baby" },
            { v: "U", t: "Unisex" }
        ],
        merchandiser: [
            { v: "1", t: "Rahim Uddin" },
            { v: "2", t: "Karim Ahmed" },
            { v: "3", t: "Nasrin Akter" },
            { v: "4", t: "Sabbir Hossain" }
        ],
        mainStatus: [
            { v: "D", t: "Draft" },
            { v: "A", t: "Active" },
            { v: "I", t: "Inactive" },
            { v: "C", t: "Closed" }
        ],

        /* ---------- Specification ---------- */
        knitWoven: [
            { v: "K", t: "Knit" },
            { v: "W", t: "Woven" }
        ],

        /* ---------- Color & Size ---------- */
        color: [
            { v: "BLK", t: "Black" },
            { v: "WHT", t: "White" },
            { v: "RED", t: "Red" },
            { v: "NVY", t: "Navy" },
            { v: "GRY", t: "Grey" },
            { v: "BLU", t: "Blue" }
        ],
        size: [
            { v: "XS", t: "XS" },
            { v: "S", t: "S" },
            { v: "M", t: "M" },
            { v: "L", t: "L" },
            { v: "XL", t: "XL" },
            { v: "XXL", t: "XXL" }
        ],

        /* ---------- Fabric / Accessories ---------- */
        fabUnit: [
            { v: "KG", t: "KG" },
            { v: "MTR", t: "Meter" },
            { v: "YDS", t: "Yard" }
        ],
        accType: [
            { v: "TRM", t: "Trim" },
            { v: "PKG", t: "Packaging" },
            { v: "LBL", t: "Label" },
            { v: "THR", t: "Thread" }
        ],
        accUnit: [
            { v: "PCS", t: "PCS" },
            { v: "DZN", t: "Dozen" },
            { v: "GRS", t: "Gross" }
        ],

        /* ---------- Set Mapping ---------- */
        mapComp: [
            { v: "TOP", t: "Top" },
            { v: "BOT", t: "Bottom" },
            { v: "INR", t: "Inner" }
        ],
        mapType: [
            { v: "S", t: "Size" },
            { v: "C", t: "Color" }
        ]
    };

    /* ------------------------------------------------------------
       Map data-dd key  →  HiddenField ID
       ------------------------------------------------------------ */
    var HF_MAP = {
        buyerFilter: "hfBuyerFilter",
        statusFilter: "hfStatusFilter",
        buyer: "hfBuyer",
        brand: "hfBrand",
        agent: "hfAgent",
        season: "hfSeason",
        seasonYear: "hfSeasonYear",
        productCategory: "hfProductCategory",
        productType: "hfProductType",
        garmentType: "hfGarmentType",
        gender: "hfGender",
        merchandiser: "hfMerchandiser",
        mainStatus: "hfMainStatus",
        knitWoven: "hfKnitWoven",
        color: "hfColor",
        size: "hfSize",
        fabUnit: "hfFabUnit",
        accType: "hfAccType",
        accUnit: "hfAccUnit",
        mapComp: "hfMapComp",
        mapType: "hfMapType"
    };

    /* ------------------------------------------------------------
       Build one dropdown inside a [data-dd] placeholder
       ------------------------------------------------------------ */
    function buildDropdown(host) {

        var key = host.getAttribute("data-dd");
        var items = DD_DATA[key] || [];
        var hfId = HF_MAP[key];
        var hf = hfId ? document.getElementById(hfId) : null;

        // Already built? skip
        if (host.querySelector(".dd-ctl")) return;

        host.innerHTML =
            '<div class="dd-ctl">' +
            '<div class="dd-fld" tabindex="0">' +
            '<span class="txt">-- Select --</span>' +
            '<span class="clr" title="Clear"><i class="bi bi-x"></i></span>' +
            '<i class="bi bi-chevron-down chev"></i>' +
            '</div>' +
            '<div class="dd-panel" style="display:none">' +
            '<div class="ps">' +
            '<i class="bi bi-search"></i>' +
            '<input type="text" placeholder="Search..." />' +
            '</div>' +
            '<div class="pl"></div>' +
            '</div>' +
            '</div>';

        var fld = host.querySelector(".dd-fld");
        var txt = host.querySelector(".txt");
        var panel = host.querySelector(".dd-panel");
        var list = host.querySelector(".pl");
        var search = host.querySelector("input");
        var clr = host.querySelector(".clr");

        /* ---- render list ---- */
        function render(filter) {
            filter = (filter || "").toLowerCase();
            var html = "";
            for (var i = 0; i < items.length; i++) {
                var it = items[i];
                if (it.t.toLowerCase().indexOf(filter) === -1) continue;
                var sel = hf && hf.value === it.v ? " sel-single" : "";
                html += '<div class="it' + sel + '" data-v="' + it.v +
                    '" data-t="' + it.t + '">' + it.t + '</div>';
            }
            list.innerHTML = html || '<div class="empty">No result</div>';
        }

        /* ---- open / close ---- */
        function open() {
            panel.style.display = "block";
            fld.classList.add("open");
            render("");
            search.value = "";
            search.focus();
        }
        function close() {
            panel.style.display = "none";
            fld.classList.remove("open");
        }

        fld.addEventListener("click", function (e) {
            if (e.target === clr || clr.contains(e.target)) return;
            panel.style.display === "block" ? close() : open();
        });

        clr.addEventListener("click", function (e) {
            e.stopPropagation();
            txt.textContent = "-- Select --";
            fld.classList.remove("has");
            if (hf) hf.value = "";
            close();
        });

        search.addEventListener("input", function () {
            render(search.value);
        });

        list.addEventListener("click", function (e) {
            var it = e.target.closest(".it");
            if (!it) return;
            txt.textContent = it.getAttribute("data-t");
            fld.classList.add("has");
            if (hf) hf.value = it.getAttribute("data-v");
            close();
        });

        /* ---- close on outside click ---- */
        document.addEventListener("click", function (e) {
            if (!host.contains(e.target)) close();
        });

        /* ---- keyboard ---- */
        fld.addEventListener("keydown", function (e) {
            if (e.key === "Enter" || e.key === " ") {
                e.preventDefault();
                panel.style.display === "block" ? close() : open();
            }
            if (e.key === "Escape") close();
        });

        /* ---- restore value from hidden field (postback) ---- */
        if (hf && hf.value) {
            var found = items.filter(function (x) { return x.v === hf.value; })[0];
            if (found) {
                txt.textContent = found.t;
                fld.classList.add("has");
            }
        }
    }

    /* ------------------------------------------------------------
       Initialize all placeholders
       ------------------------------------------------------------ */
    function initAll() {
        document.querySelectorAll("[data-dd]").forEach(buildDropdown);
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", initAll);
    } else {
        initAll();
    }

    /* ------------------------------------------------------------
       Expose helper for server-side reset (called from code-behind)
       ------------------------------------------------------------ */
    window.NexaDD = {
        resetAll: function () {
            document.querySelectorAll("[data-dd]").forEach(function (host) {
                var key = host.getAttribute("data-dd");
                var hfId = HF_MAP[key];
                var hf = hfId ? document.getElementById(hfId) : null;
                if (hf) hf.value = "";
                var fld = host.querySelector(".dd-fld");
                var txt = host.querySelector(".txt");
                if (fld) fld.classList.remove("has");
                if (txt) txt.textContent = "-- Select --";
            });
        },
        setValue: function (key, value) {
            var host = document.querySelector('[data-dd="' + key + '"]');
            if (!host) return;
            var items = DD_DATA[key] || [];
            var hfId = HF_MAP[key];
            var hf = hfId ? document.getElementById(hfId) : null;
            var found = items.filter(function (x) { return x.v === value; })[0];
            if (found) {
                host.querySelector(".txt").textContent = found.t;
                host.querySelector(".dd-fld").classList.add("has");
                if (hf) hf.value = value;
            }
        }
    };

})();