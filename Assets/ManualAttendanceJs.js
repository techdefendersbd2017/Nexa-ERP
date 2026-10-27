const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// ---------- গ্রিডের সব রো সিলেক্ট / আনসিলেক্ট ----------
function selectAllGrid(state) {
    document.querySelectorAll('input[name="rowChk"]').forEach(function (cb) { cb.checked = state; });
    var h = document.getElementById('chkSelectAll');
    if (h) h.checked = state;
}

// ---------- Multi Date টিক না থাকলে To Date লুকানো (Desktop এর মতো) ----------
function syncMultiDate() {
    var chk = document.getElementById('<%= chkMultiDate.ClientID %>');
    var to = document.getElementById('<%= txtToDate.ClientID %>');
    if (chk && to) to.style.visibility = chk.checked ? 'visible' : 'hidden';
}

// ---------- Hidden বাটন: Alt+O দিয়ে দেখানো/লুকানো, আর অবস্থা মনে রাখা ----------
// প্রতিটি বাটন ক্লিকে পেজ পোস্টব্যাক হয়ে নতুন করে লোড হয়, তাই বাটনের অবস্থা (দেখা/লুকানো)
// ব্রাউজারের sessionStorage এ জমা থাকে। পেজ লোডের সময়ই সেটি ফিরিয়ে আনা হয়।
// আবার Alt+O চাপলে লুকাবে। ট্যাব বন্ধ করলে অবস্থা মুছে যায় (সব সময়ের জন্য মনে রাখতে চাইলে
// নিচের sessionStorage কে localStorage করুন)।
var ORG_KEY = 'manAtt_orgBtnVisible';

function setOrgBtn(show) {
    var b = document.getElementById('btnOrg');
    if (b) b.style.display = show ? 'inline-flex' : 'none';
    try { sessionStorage.setItem(ORG_KEY, show ? '1' : '0'); } catch (err) { }
}

function orgBtnVisible() {
    var b = document.getElementById('btnOrg');
    return !!b && b.style.display !== 'none';
}

// পেজ লোডের সময় আগের অবস্থা ফেরানো (স্ক্রিপ্ট বডির শেষে, তাই বাটন আগেই আছে, কোনো ঝিলিক দেখা যায় না)
(function restoreOrgBtn() {
    var saved = null;
    try { saved = sessionStorage.getItem(ORG_KEY); } catch (err) { }
    if (saved === '1') {
        var b = document.getElementById('btnOrg');
        if (b) b.style.display = 'inline-flex';
    }
})();

document.addEventListener('keydown', function (e) {
    if (e.altKey && !e.ctrlKey && !e.shiftKey && (e.code === 'KeyO' || e.key === 'o' || e.key === 'O')) {
        e.preventDefault();
        setOrgBtn(!orgBtnVisible());
    }
});

// ---------- Multi-select ড্রপডাউন (ListBox → চেকবক্স প্যানেল) ----------
function initMulti() {
    document.querySelectorAll('select.ms-src').forEach(function (sel) {
        try {
            var wrap = document.createElement('div');
            wrap.style.position = 'relative';
            sel.parentNode.insertBefore(wrap, sel);
            wrap.appendChild(sel);

            var fld = document.createElement('div');
            fld.className = 'msf'; fld.tabIndex = 0;
            fld.innerHTML = '<span class="txt"></span><i class="fa-solid fa-xmark clr" title="Clear"></i><i class="fa-solid fa-chevron-down chev"></i>';
            wrap.appendChild(fld);

            var panel = document.createElement('div');
            panel.className = 'msp'; panel.style.display = 'none';
            panel.innerHTML =
                '<div class="ph"><span class="cnt"></span><button type="button" class="clrAll">Clear all</button></div>' +
                '<div class="ps"><i class="fa-solid fa-search"></i><input type="text" placeholder="Search..."></div>' +
                '<div class="pl"></div>';
            wrap.appendChild(panel);

            var txt = fld.querySelector('.txt'), list = panel.querySelector('.pl'),
                cnt = panel.querySelector('.cnt'), q = panel.querySelector('input');

            function render() {
                var term = q.value.toLowerCase(), html = '', picked = [];
                for (var i = 0; i < sel.options.length; i++) {
                    var o = sel.options[i];
                    if (o.selected) picked.push(o.text);
                    if (term && o.text.toLowerCase().indexOf(term) < 0) continue;
                    html += '<div class="it" data-i="' + i + '"><span class="cb' + (o.selected ? ' on' : '') + '">' +
                        (o.selected ? '<i class="fa-solid fa-check"></i>' : '') + '</span><span>' + esc(o.text) + '</span></div>';
                }
                list.innerHTML = html || '<div class="empty">No options</div>';
                cnt.textContent = picked.length + ' selected';
                txt.textContent = picked.length === 0 ? '-- All --' : (picked.length <= 2 ? picked.join(', ') : picked.length + ' selected');
                fld.classList.toggle('has', picked.length > 0);
            }
            function clearAll() {
                for (var i = 0; i < sel.options.length; i++) sel.options[i].selected = false;
                render();
            }
            list.addEventListener('click', function (e) {
                var it = e.target.closest('.it'); if (!it) return;
                var o = sel.options[+it.getAttribute('data-i')];
                o.selected = !o.selected; render();
            });
            panel.querySelector('.clrAll').addEventListener('click', clearAll);
            fld.querySelector('.clr').addEventListener('click', function (e) { e.stopPropagation(); clearAll(); });
            fld.addEventListener('click', function () {
                var open = panel.style.display === 'none';
                document.querySelectorAll('.msp').forEach(function (p) { p.style.display = 'none'; });
                document.querySelectorAll('.msf.open').forEach(function (f) { f.classList.remove('open'); });
                panel.style.display = open ? 'block' : 'none';
                fld.classList.toggle('open', open);
                if (open) { q.value = ''; render(); q.focus(); }
            });
            panel.addEventListener('click', function (e) { e.stopPropagation(); });
            q.addEventListener('keydown', function (e) { if (e.key === 'Enter') e.preventDefault(); });
            render();
            sel.style.display = 'none';
        } catch (err) { console.error('multi-select init failed for', sel.id, err); sel.style.display = ''; }
    });
    document.addEventListener('click', function (e) {
        if (e.target.closest('.msp') || e.target.closest('.msf')) return;
        document.querySelectorAll('.msp').forEach(function (p) { p.style.display = 'none'; });
        document.querySelectorAll('.msf.open').forEach(function (f) { f.classList.remove('open'); });
    });
}

document.addEventListener('DOMContentLoaded', function () {
    try { initMulti(); } catch (err) { console.error('initMulti error:', err); }
    var chk = document.getElementById('<%= chkMultiDate.ClientID %>');
    if (chk) chk.addEventListener('change', syncMultiDate);
    syncMultiDate();
});