

// id = dropdown নাম, hf = নির্বাচিত মান জমা রাখার HiddenField (মান '|' দিয়ে আলাদা)
const FIELDS = [
    { id: 'branch', hf: 'hfBranch', label: 'Branch', multi: true, ph: 'Select branch…' },
    { id: 'category', hf: 'hfCategory', label: 'Category', multi: true, ph: 'Select category…' },
    { id: 'dept', hf: 'hfDept', label: 'Department', multi: true, ph: 'Select department…' },
    { id: 'section', hf: 'hfSection', label: 'Section', multi: true, ph: 'Select section…' },
    { id: 'subsec', hf: 'hfSubSec', label: 'Sub Section', multi: true, ph: 'Select sub section…' },
    { id: 'floor', hf: 'hfFloor', label: 'Floor', multi: true, ph: 'Select floor…' },
    { id: 'desig', hf: 'hfDesig', label: 'Designation', multi: true, ph: 'Select designation…' },
    { id: 'level', hf: 'hfLevel', label: 'Designation Level', multi: true, ph: 'Select level…' },
    { id: 'blood', hf: 'hfBlood', label: 'Blood Group', multi: false, ph: 'Select blood group…' },
    { id: 'religion', hf: 'hfReligion', label: 'Religion', multi: false, ph: 'Select religion…' },
    { id: 'status', hf: 'hfStatus', label: 'Employee Status', multi: false, ph: 'Select status…' },
    { id: 'rtype', hf: 'hfRType', label: 'Report Type', multi: false, ph: 'Select report type…' }
];
FIELDS.forEach(f => f.opts = OPT[f.id] || []);
const state = {};

const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const fieldOf = id => FIELDS.find(f => f.id === id);

function buildFilters() {
    FIELDS.forEach(f => {
        const host = document.querySelector('[data-dd="' + f.id + '"]');
        if (!host) return;
        host.id = 'wrap-' + f.id; host.classList.add('relative');
        const saved = document.getElementById(f.hf).value;
        state[f.id] = saved ? saved.split('|').filter(Boolean) : [];
        host.innerHTML = `
                    <label class="lbl">${f.label}</label>
                    <div id="fld-${f.id}" class="fld" tabindex="0" onclick="toggleDD('${f.id}')" onkeydown="if(event.key==='Enter'||event.key===' '){event.preventDefault();toggleDD('${f.id}')}">
                        <span class="txt"></span>
                        <span class="clr" onclick="clearField('${f.id}',event)" title="Clear"><i class="fa-solid fa-xmark"></i></span>
                        <i class="fa-solid fa-up-down chev"></i>
                    </div>
                    <div id="panel-${f.id}" class="panel hidden" onclick="event.stopPropagation()">
                        ${f.multi ? `<div class="ph"><span id="cnt-${f.id}"></span><button type="button" onclick="clearField('${f.id}',event)">Clear All</button></div>` : ''}
                        <div class="ps"><i class="fa-solid fa-magnifying-glass"></i>
                            <input type="text" id="q-${f.id}" placeholder="Search ${f.label.toLowerCase()}…" autocomplete="off"
                                   oninput="renderList('${f.id}')" onkeydown="if(event.key==='Enter')return false;"></div>
                        <div class="pl" id="list-${f.id}"></div>
                    </div>`;
        refreshField(f.id);
    });
    // তারিখ ঘরে মান থাকলে date হিসেবে দেখাও
    document.querySelectorAll('input.date').forEach(i => { if (i.value) i.type = 'date'; });
}

function syncHidden(id) {
    document.getElementById(fieldOf(id).hf).value = (state[id] || []).join('|');
}

function refreshField(id) {
    const f = fieldOf(id), vals = state[id] || [];
    const box = document.getElementById('fld-' + id);
    box.classList.toggle('has', vals.length > 0);
    box.querySelector('.txt').textContent = vals.length ? vals.join(', ') : f.ph;
    const cnt = document.getElementById('cnt-' + id);
    if (cnt) cnt.textContent = vals.length + ' selected';
    renderList(id);
}

function renderList(id) {
    const f = fieldOf(id), vals = state[id] || [];
    const q = (document.getElementById('q-' + id).value || '').toLowerCase();
    const list = document.getElementById('list-' + id);
    const match = o => o.toLowerCase().includes(q);
    const row = o => {
        const i = f.opts.indexOf(o), on = vals.includes(o);
        if (f.multi) return `<div class="it" onclick="pick('${id}',${i})"><span class="cb ${on ? 'on' : ''}">${on ? '<i class="fa-solid fa-check"></i>' : ''}</span><span>${esc(o)}</span></div>`;
        return `<div class="it ${on ? 'sel-single' : ''}" onclick="pick('${id}',${i})"><span>${esc(o)}</span>${on ? '<i class="fa-solid fa-check ml-auto text-xs"></i>' : ''}</div>`;
    };
    let html = '';
    if (f.multi) {
        const sel = vals.filter(match), rest = f.opts.filter(o => !vals.includes(o) && match(o));
        if (sel.length) html += `<div class="sec">Selected</div>` + sel.map(row).join('');
        if (rest.length) html += `<div class="sec">${sel.length ? 'Options' : 'All options'}</div>` + rest.map(row).join('');
    } else {
        html = f.opts.filter(match).map(row).join('');
    }
    list.innerHTML = html || '<div class="empty">No results found</div>';
}

function pick(id, i) {
    const f = fieldOf(id), v = f.opts[i];
    if (f.multi) {
        const a = state[id], k = a.indexOf(v);
        if (k > -1) a.splice(k, 1); else a.push(v);
    } else {
        state[id] = [v];
        closeAll();
    }
    syncHidden(id); refreshField(id);
}

function clearField(id, ev) {
    if (ev) ev.stopPropagation();
    state[id] = [];
    syncHidden(id); refreshField(id);
}

function closeAll() {
    document.querySelectorAll('.panel').forEach(p => p.classList.add('hidden'));
    document.querySelectorAll('.fld.open').forEach(b => b.classList.remove('open'));
}

function toggleDD(id) {
    const panel = document.getElementById('panel-' + id);
    const wasOpen = !panel.classList.contains('hidden');
    closeAll();
    if (wasOpen) return;
    panel.classList.remove('hidden');
    document.getElementById('fld-' + id).classList.add('open');
    panel.classList.remove('right');
    if (panel.getBoundingClientRect().right > window.innerWidth - 8) panel.classList.add('right');
    const q = document.getElementById('q-' + id);
    q.value = ''; renderList(id);
    setTimeout(() => q.focus(), 0);
}

document.addEventListener('click', e => { if (!e.target.closest('[id^="wrap-"]')) closeAll(); });
document.addEventListener('keydown', e => { if (e.key === 'Escape') closeAll(); });

// Multi ID ঘরে Enter চাপলে Show বাটন চলবে
document.addEventListener('DOMContentLoaded', function () {
    buildFilters();
    const mi = document.getElementById('txtMultiId');
    if (mi) mi.addEventListener('keydown', e => {
        if (e.key === 'Enter') { e.preventDefault(); const b = document.getElementById('btnShow'); if (b) eval(b.href.replace('javascript:', '')); }
    });
});

// ---------- টেবিলের Quick filter (ব্রাউজারেই, বর্তমান সারিগুলোর উপর) ----------
function searchTable() {
    const q = document.getElementById('tableSearch').value.toLowerCase();
    let shown = 0;
    document.querySelectorAll('#tableBody tr').forEach(tr => {
        if (tr.id && tr.id.indexOf('trEmpty') > -1) return;
        const hit = tr.textContent.toLowerCase().includes(q);
        tr.style.display = hit ? '' : 'none';
        if (hit) shown++;
    });
}
function toggleAllRowCheckboxes(source) {
    document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = source.checked);
}

// ---------- Export / Print ----------
function exportData(format) { showNotification('Exporting report to ' + format.toUpperCase() + ' format...'); } // TODO: Back-End
function printReport() { window.print(); }

function showNotification(message) {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = "bg-slate-900 text-white text-xs px-4 py-2.5 rounded-xl shadow-lg pointer-events-auto flex items-center space-x-2 transition transform translate-y-2 opacity-0";
    toast.innerHTML = `<i class="fa-solid fa-circle-info text-indigo-400"></i><span>${esc(message)}</span>`;
    container.appendChild(toast);
    setTimeout(() => toast.classList.remove('translate-y-2', 'opacity-0'), 10);
    setTimeout(() => { toast.classList.add('translate-y-2', 'opacity-0'); setTimeout(() => toast.remove(), 300); }, 3000);
}