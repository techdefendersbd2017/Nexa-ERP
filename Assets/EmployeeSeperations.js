const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

function collectIds() {
    const ids = [];
    document.querySelectorAll('.row-checkbox:checked').forEach(c => ids.push(c.getAttribute('data-id') || c.value));
    document.getElementById('hfSelIds').value = ids.join(',');
    return ids.length;
}
function onSaveClick() {
    if (collectIds() === 0) { showNotification('কমপক্ষে একজন কর্মচারী টিক দিন।'); return false; }
    var t = document.getElementById('toddStatus');
    if (t && t.selectedIndex < 0) { showNotification('To Employee Status নির্বাচন করুন।'); return false; }
    var d = document.getElementById('txtEffectiveDate');
    if (d && !d.value) { showNotification('Resign Date দিন।'); return false; }
    return true;
}
function updateSelCount() {
    const n = document.querySelectorAll('.row-checkbox:checked').length;
    const el = document.getElementById('selCount'); if (el) el.textContent = n + ' selected';
}
function toggleAll(src) {
    document.querySelectorAll('.row-checkbox').forEach(cb => { if (cb.closest('tr').style.display !== 'none') cb.checked = src.checked; });
    updateSelCount();
}
function searchTable() {
    const q = document.getElementById('tableSearch').value.toLowerCase();
    document.querySelectorAll('#tableBody tr').forEach(tr => {
        if (tr.id && tr.id.indexOf('trEmpty') > -1) return;
        tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
function exportData(format) { showNotification('Exporting list to ' + format.toUpperCase() + ' format...'); } // TODO: Back-End

function closeAllPanels() {
    document.querySelectorAll('.panel').forEach(function (p) { p.style.display = 'none'; });
    document.querySelectorAll('.fld.open').forEach(function (f) { f.classList.remove('open'); });
}

// ---------- Multi-select (ListBox -> checkbox panel). data-single="1" হলে একটিই টিক ----------
function initMulti() {
    document.querySelectorAll('select.ms-src').forEach(function (sel) {
        try {
            var single = sel.getAttribute('data-single') === '1';
            var ph = sel.getAttribute('data-ph') || '-- All --';

            var wrap = document.createElement('div'); wrap.style.position = 'relative';
            sel.parentNode.insertBefore(wrap, sel); wrap.appendChild(sel);
            var fld = document.createElement('div'); fld.className = 'fld'; fld.tabIndex = 0;
            fld.innerHTML = '<span class="txt"></span><i class="fa-solid fa-xmark clr" title="Clear"></i><i class="fa-solid fa-chevron-down chev"></i>';
            wrap.appendChild(fld);
            var panel = document.createElement('div'); panel.className = 'panel'; panel.style.display = 'none';
            panel.innerHTML = '<div class="ph"><span class="cnt"></span><button type="button" class="clrAll">Clear all</button></div>' +
                '<div class="ps"><i class="fa-solid fa-search"></i><input type="text" placeholder="Search..."></div><div class="pl"></div>';
            wrap.appendChild(panel);
            var txt = fld.querySelector('.txt'), list = panel.querySelector('.pl'), cnt = panel.querySelector('.cnt'), q = panel.querySelector('input');

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
                txt.textContent = picked.length === 0 ? ph : (picked.length <= 2 ? picked.join(', ') : picked.length + ' selected');
                fld.classList.toggle('has', picked.length > 0);
            }
            function clearAll() { for (var i = 0; i < sel.options.length; i++) sel.options[i].selected = false; render(); }

            list.addEventListener('click', function (e) {
                var it = e.target.closest('.it'); if (!it) return;
                var o = sel.options[+it.getAttribute('data-i')];
                if (single && !o.selected) {
                    for (var k = 0; k < sel.options.length; k++) sel.options[k].selected = false;
                }
                o.selected = !o.selected;
                render();
                if (single) closeAllPanels();
            });
            panel.querySelector('.clrAll').addEventListener('click', clearAll);
            fld.querySelector('.clr').addEventListener('click', function (e) { e.stopPropagation(); clearAll(); });
            fld.addEventListener('click', function () {
                var open = panel.style.display === 'none';
                closeAllPanels();
                panel.style.display = open ? 'block' : 'none'; fld.classList.toggle('open', open);
                if (open) { q.value = ''; render(); q.focus(); }
            });
            panel.addEventListener('click', function (e) { e.stopPropagation(); });
            q.addEventListener('keydown', function (e) { if (e.key === 'Enter') e.preventDefault(); });
            render(); sel.style.display = 'none';
        } catch (err) { console.error('multi-select init failed', sel.id, err); sel.style.display = ''; }
    });
}

document.addEventListener('DOMContentLoaded', function () {
    try { initMulti(); } catch (err) { console.error(err); }
    document.addEventListener('click', function (e) {
        if (e.target.closest('.panel') || e.target.closest('.fld')) return;
        closeAllPanels();
    });
    document.querySelectorAll('input.date').forEach(i => { if (i.value) i.type = 'date'; });
    updateSelCount();
    const f = document.forms[0], old = f.onsubmit;
    f.onsubmit = function () { collectIds(); return old ? old.apply(this, arguments) : true; };
    const mi = document.getElementById('txtMultiId');
    if (mi) mi.addEventListener('keydown', e => { if (e.key === 'Enter') { e.preventDefault(); document.getElementById('btnShow').click(); } });
});

function showNotification(message) {
    const c = document.getElementById('toastContainer'), t = document.createElement('div');
    t.className = "bg-slate-900 text-white text-xs px-4 py-2.5 rounded-xl shadow-lg pointer-events-auto flex items-center space-x-2 transition transform translate-y-2 opacity-0";
    t.innerHTML = `<i class="fa-solid fa-circle-info text-indigo-400"></i><span>${esc(message)}</span>`;
    c.appendChild(t);
    setTimeout(() => t.classList.remove('translate-y-2', 'opacity-0'), 10);
    setTimeout(() => { t.classList.add('translate-y-2', 'opacity-0'); setTimeout(() => t.remove(), 300); }, 3500);
}