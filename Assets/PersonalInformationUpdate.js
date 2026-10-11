function $id(id) { return document.getElementById(id); }
function val(id) { var e = $id(id); return e ? (e.value || '').trim() : ''; }
function setv(id, v) { var e = $id(id); if (e) e.value = v == null ? '' : v; }
function esc(s) { return String(s).replace(/[&<>"']/g, function (c) { return ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]; }); }

function showNotification(message) {
    var c = $id('toastContainer'), t = document.createElement('div');
    t.className = 'app-toast';
    t.innerHTML = '<i class="bi bi-info-circle-fill"></i><span>' + esc(message) + '</span>';
    c.appendChild(t);
    setTimeout(function () { t.classList.add('show'); }, 10);
    setTimeout(function () { t.classList.remove('show'); setTimeout(function () { t.remove(); }, 300); }, 3500);
}

window.addEventListener('error', function (ev) {
    var b = $id('errBox'); b.classList.remove('d-none');
    b.textContent = 'JS error: ' + ev.message + ' (line ' + ev.lineno + ')';
});

// ---- Page Method কল (EmployeeInformation.aspx/Suggest, Lookup, Subjects) ----
var PM = location.pathname.replace(/\/$/, '');
function callPM(method, data) {
    return fetch(PM + '/' + method, {
        method: 'POST', credentials: 'same-origin',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify(data)
    }).then(function (r) { if (!r.ok) throw new Error('HTTP ' + r.status); return r.json(); })
        .then(function (j) { return j.d; });
}

// ---- Autocomplete ----
function doLookup(inp) {
    var kind = inp.getAttribute('data-ac');
    if (['village', 'post', 'thana', 'district', 'factory'].indexOf(kind) < 0) return;
    var v = inp.value.trim(); if (!v) return;
    callPM('Lookup', { kind: kind, value: v }).then(function (d) {
        if (!d) return;
        var ba = inp.getAttribute('data-ba');
        if (ba && d.ba !== undefined) setv(ba, d.ba);
        var de = inp.getAttribute('data-dive'), db = inp.getAttribute('data-divb');
        if (de && d.divEn !== undefined) setv(de, d.divEn);
        if (db && d.divBa !== undefined) setv(db, d.divBa);
        if (kind === 'factory' && d.en !== undefined) {
            setv('txtFactoryName', d.en); setv('txtFactoryNameBangla', d.ba);
            setv('txtFactoryAddress', d.addrEn); setv('txtFactoryAddressBangla', d.addrBa);
        }
    }).catch(function () { });
}

function initAC(inp) {
    var kind = inp.getAttribute('data-ac');
    var parent = inp.closest('.pair') || inp.parentNode;
    parent.style.position = 'relative';
    var box = document.createElement('div'); box.className = 'ac-list d-none'; parent.appendChild(box);
    var timer = null, items = [], idx = -1;

    function hide() { box.classList.add('d-none'); idx = -1; }
    function show(list) {
        items = list || [];
        if (!items.length) { hide(); return; }
        box.innerHTML = items.map(function (s, i) { return '<div class="it" data-i="' + i + '">' + esc(s) + '</div>'; }).join('');
        box.style.left = inp.offsetLeft + 'px';
        box.style.top = (inp.offsetTop + inp.offsetHeight + 2) + 'px';
        box.style.minWidth = inp.offsetWidth + 'px';
        box.classList.remove('d-none'); idx = -1;
    }
    function choose(v) {
        inp.value = v; hide();
        if (kind === 'vstatus') covidLogic();
        doLookup(inp);
    }
    function mark() {
        var els = box.querySelectorAll('.it');
        els.forEach(function (e, i) { e.classList.toggle('act', i === idx); });
        if (els[idx]) els[idx].scrollIntoView({ block: 'nearest' });
    }

    inp.addEventListener('input', function () {
        clearTimeout(timer);
        var t = inp.value.trim();
        if (!t) { hide(); return; }
        timer = setTimeout(function () { callPM('Suggest', { kind: kind, term: t }).then(show).catch(hide); }, 200);
    });
    inp.addEventListener('keydown', function (e) {
        if (box.classList.contains('d-none')) { if (e.key === 'Enter') doLookup(inp); return; }
        if (e.key === 'ArrowDown') { idx = Math.min(idx + 1, items.length - 1); mark(); e.preventDefault(); }
        else if (e.key === 'ArrowUp') { idx = Math.max(idx - 1, 0); mark(); e.preventDefault(); }
        else if (e.key === 'Enter') { if (idx >= 0) choose(items[idx]); else { hide(); doLookup(inp); } }
        else if (e.key === 'Escape') hide();
    });
    box.addEventListener('mousedown', function (e) {
        var el = e.target.closest('.it'); if (!el) return;
        e.preventDefault(); choose(items[+el.getAttribute('data-i')]);
    });
    inp.addEventListener('blur', function () { setTimeout(hide, 150); });
    inp.addEventListener('change', function () { if (kind === 'vstatus') covidLogic(); doLookup(inp); });
}

// Enter চাপলে শুধু Employee ID বক্সে Search হবে, অন্য ঘরে ফর্ম সাবমিট হবে না
document.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && e.target.tagName === 'INPUT' && e.target.id !== 'txtEmpID' && e.target.type !== 'submit' && e.target.type !== 'button') e.preventDefault();
});

// ---- ঠিকানা কপি ----
var PRE_MAP = [['txtPerVillageEn', 'txtPreVillageEn'], ['txtPerVillageBa', 'txtPreVillageBa'], ['txtPerPostEn', 'txtPrePostEn'], ['txtPerPostBa', 'txtPrePostBa'],
['txtPerThanaEn', 'txtPreThanaEn'], ['txtPerThanaBa', 'txtPreThanaBa'], ['txtPerDistrictEn', 'txtPreDistrictEn'], ['txtPerDistrictBa', 'txtPreDistrictBa']];
var NOM_MAP = [['txtPerVillageEn', 'txtNomVillageEn'], ['txtPerVillageBa', 'txtNomVillageBa'], ['txtPerPostEn', 'txtNomPostEn'], ['txtPerPostBa', 'txtNomPostBa'],
['txtPerThanaEn', 'txtNomThanaEn'], ['txtPerThanaBa', 'txtNomThanaBa'], ['txtPerDistrictEn', 'txtNomDistrictEn'], ['txtPerDistrictBa', 'txtNomDistrictBa']];
function copyMap(map) { map.forEach(function (p) { setv(p[1], val(p[0])); }); }

// ---- Job Experience: From/Till তারিখ ----
function expLogic() {
    var on = $id('chkExpDates').checked;
    $id('txtExpFrom').readOnly = !on; $id('txtExpTill').readOnly = !on;
}

// ---- Covid logic (Desktop এর মতো) ----
function covidLogic() {
    var st = val('txtVaccineStatus');
    var off = (st === 'No' || st === 'Registered');
    [1, 2, 3, 4].forEach(function (n) {
        var c = $id('chkDose' + n);
        if (off) { c.checked = false; c.disabled = true; } else if ($id('hfLock').value !== '1') { c.disabled = false; }
        $id('txtDose' + n + 'Date').readOnly = !c.checked;
    });
    $id('txtVaccineName').readOnly = off;
    $id('rowVaccineReg').classList.toggle('d-none', st !== 'Registered');
}

// ---- Reference Search ----
$id('btnRefSearch').addEventListener('click', function () {
    var id = val('txtRefID');
    if (!id) { showNotification('Please enter Reference Employee ID.'); return; }
    callPM('Lookup', { kind: 'refemp', value: id }).then(function (d) {
        if (!d || d.name === undefined) {
            showNotification("This ID- '" + id + "' Not Exists In your Database.");
            ['txtRefName', 'txtRefDesignation', 'txtRefCompany', 'txtRefEmail', 'txtRefPhone'].forEach(function (x) { setv(x, ''); });
            return;
        }
        setv('txtRefName', d.name); setv('txtRefDesignation', d.designation); setv('txtRefCompany', d.company);
        setv('txtRefEmail', d.email); setv('txtRefPhone', d.phone);
    }).catch(function (e) { showNotification('Error: ' + e.message); });
});

// ---- Photo: 300 KB ----
var MAX_PHOTO = 300 * 1024;
$id('fuPhoto').addEventListener('change', function () {
    var f = this.files && this.files[0]; if (!f) return;
    if (f.size > MAX_PHOTO) {
        showNotification('ছবির সাইজ 300 KB এর বেশি (' + Math.round(f.size / 1024) + ' KB)। ছোট ছবি দিন।');
        this.value = ''; $id('photoInfo').textContent = 'সর্বোচ্চ 300KB (JPG/PNG/BMP)'; return;
    }
    $id('photoInfo').textContent = f.name + ' (' + Math.round(f.size / 1024) + ' KB)';
    var r = new FileReader(); r.onload = function (e) { $id('imgEmp').src = e.target.result; }; r.readAsDataURL(f);
});

function validateForm() {
    if (!val('txtEmpID')) { showNotification('Please enter ID No.'); return false; }
    return true;
}

// ---- Training subject (Head অনুযায়ী) ----
function loadSubjects() {
    var head = $('#ddlTrainingHead').val();
    var sel = $id('selSubject');
    if (!head) { sel.innerHTML = ''; setv('hfSubjectId', ''); return; }
    callPM('Subjects', { trainingId: head }).then(function (list) {
        sel.innerHTML = (list || []).map(function (x) { return '<option value="' + esc(x[0]) + '">' + esc(x[1]) + '</option>'; }).join('');
        setv('hfSubjectId', sel.value);
    }).catch(function () { });
}

document.addEventListener('DOMContentLoaded', function () {
    // Select2
    $('select.sel2').select2({ width: '100%' });

    document.querySelectorAll('[data-ac]').forEach(initAC);

    // ঠিকানা এক হলে
    $id('chkSame').addEventListener('change', function () { if (this.checked) copyMap(PRE_MAP); });
    $id('chkNomSame').addEventListener('change', function () { if (this.checked) copyMap(NOM_MAP); });

    // Relation বদলালে Bangla + Nominee নাম
    $('#ddlNomineeRelation').on('change', function () {
        var rel = $(this).find('option:selected').text().trim();
        if (rel && rel !== 'Select') {
            callPM('Lookup', { kind: 'relation', value: rel }).then(function (d) { if (d && d.ba !== undefined) setv('txtRelationBangla', d.ba); }).catch(function () { });
        } else setv('txtRelationBangla', '');
        var map = {
            'Father': ['txtFatherEnglish', 'txtFatherBangla'], 'Mother': ['txtMotherEnglish', 'txtMotherBangla'],
            'Husband': ['txtHusbandEnglish', 'txtHusbandBangla'], 'Wife': ['txtSpouseEnglish', 'txtSpouseBangla']
        };
        if (map[rel]) { setv('txtNomineeNameEn', val(map[rel][0])); setv('txtNomineeNameBa', val(map[rel][1])); }
        else { setv('txtNomineeNameEn', ''); setv('txtNomineeNameBa', ''); }
    });

    // Training
    $('#ddlTrainingHead').on('change', loadSubjects);
    $id('selSubject').addEventListener('change', function () { setv('hfSubjectId', this.value); });
    loadSubjects();

    // চেকবক্স অনুযায়ী তারিখ
    $id('chkExpDates').addEventListener('change', expLogic);
    [1, 2, 3, 4].forEach(function (n) {
        $id('chkDose' + n).addEventListener('change', function () { $id('txtDose' + n + 'Date').readOnly = !this.checked; });
    });
    expLogic(); covidLogic();

    // Lock হলে ক্লায়েন্ট-সাইড চেকবক্সও বন্ধ
    if ($id('hfLock').value === '1') { $id('chkSame').disabled = true; $id('chkNomSame').disabled = true; }

    // ট্যাব মনে রাখা (Search/Save এর পরেও একই ট্যাব থাকবে)
    document.getElementById('hrTabs').addEventListener('shown.bs.tab', function (e) { setv('hfTab', e.target.getAttribute('data-bs-target')); });
    document.querySelectorAll('[data-goto]').forEach(function (b) {
        b.addEventListener('click', function () { showTab(this.getAttribute('data-goto')); });
    });
    var last = $id('hfTab').value; if (last) showTab(last);
    checkHash();
});

function showTab(target) {
    var t = document.querySelector('[data-bs-target="' + target + '"]');
    if (t) bootstrap.Tab.getOrCreateInstance(t).show();
}
function checkHash() { if (location.hash === '#p4') showTab('#tab7'); }
window.addEventListener('hashchange', checkHash);