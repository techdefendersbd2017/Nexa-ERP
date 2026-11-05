/* POEntry.js — Style→PO অটো-লোড + Searchable Dropdown */

window.POEntry = (function () {

    /* ---------- Searchable Style Dropdown ---------- */
    function initStyleDropdown() {
        const mount = document.querySelector('[data-dd="style"]');
        if (!mount) return;

        const fld = document.createElement('div');
        fld.className = 'dd-fld';
        fld.innerHTML = '<span class="txt">Select Style…</span><span class="chev">▼</span>';
        mount.appendChild(fld);

        const panel = document.createElement('div');
        panel.className = 'dd-panel';
        panel.style.display = 'none';
        panel.innerHTML = `
            <div class="ps"><input type="text" placeholder="Search style…" /></div>
            <div class="pl"></div>`;
        mount.appendChild(panel);

        const search = panel.querySelector('input');
        const list = panel.querySelector('.pl');
        let cache = [];

        fld.addEventListener('click', async () => {
            panel.style.display = 'block';
            fld.classList.add('open');
            if (!cache.length) {
                cache = await fetch('/POEntry.aspx/GetStyleList', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ keyword: '' })
                }).then(r => r.json()).then(x => x.d);
                renderList(cache);
            }
            search.focus();
        });

        search.addEventListener('input', async () => {
            const kw = search.value.trim();
            const data = await fetch('/POEntry.aspx/GetStyleList', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ keyword: kw })
            }).then(r => r.json()).then(x => x.d);
            renderList(data);
        });

        function renderList(items) {
            if (!items.length) { list.innerHTML = '<div class="empty">No style found</div>'; return; }
            list.innerHTML = items.map(it =>
                `<div class="it" data-id="${it.id}" data-label="${it.no} — ${it.name}">
                    <b>${it.no}</b> — ${it.name}
                    <span class="text-muted ms-2">(${it.buyer || ''})</span>
                </div>`).join('');

            list.querySelectorAll('.it').forEach(it => {
                it.addEventListener('click', () => {
                    fld.querySelector('.txt').textContent = it.dataset.label;
                    fld.classList.add('has');
                    panel.style.display = 'none';
                    document.getElementById('hfStyleId').value = it.dataset.id;
                    loadStyleSnapshot(+it.dataset.id);
                });
            });
        }

        document.addEventListener('click', e => {
            if (!mount.contains(e.target)) {
                panel.style.display = 'none';
                fld.classList.remove('open');
            }
        });
    }

    /* ---------- Style Snapshot Auto-load ---------- */
    async function loadStyleSnapshot(styleId) {
        const res = await fetch('/POEntry.aspx/LoadStyleSnapshot', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ styleId })
        }).then(r => r.json()).then(x => x.d);

        if (!res) { alert('Style not found.'); return; }
        const s = res.style;

        /* ---- read-only labels ---- */
        const set = (id, v) => { const el = document.getElementById(id); if (el) el.textContent = v || '—'; };
        set('lblStyleNoName', `${s.no} — ${s.name}`);
        set('lblBuyer', s.buyer);
        set('lblBrand', s.brand);
        set('lblAgent', s.agent);
        set('lblSeason', `${s.season || ''} / ${s.year || ''}`);
        set('lblCategory', s.category);
        set('lblProductType', s.productType);
        set('lblGarmentGender', `${s.garment || ''} / ${s.gender || ''}`);
        set('lblMerch', s.merch);
        set('lblKnitWoven', s.knitWoven);
        set('lblFabric', `${s.fabricType || ''} / ${s.gsm || ''}`);
        set('lblComposition', s.composition);
        set('lblTargetPrice', `${s.currency || ''} ${s.targetPrice || ''}`);
        set('lblStyleRev', s.revision || '00');

        const statBadge = document.getElementById('lblStyleStatus');
        statBadge.textContent = s.status || 'Draft';
        statBadge.className = 'badge ' + (s.status === 'Approved' ? 'bg-success' : 'bg-secondary');

        /* Business rule: Approved ছাড়া PO save করা যাবে না */
        const btnSave = document.getElementById('btnSave');
        if (s.status !== 'Approved') {
            if (btnSave) btnSave.disabled = true;
            alert('⚠️ This style is not Approved. PO cannot be created until style is approved.');
        } else if (btnSave) {
            btnSave.disabled = false;
        }

        /* ---- images ---- */
        const imgF = document.getElementById('imgFront');
        const imgB = document.getElementById('imgBack');
        const imgS = document.getElementById('imgSketch');
        if (s.frontImg) { imgF.src = s.frontImg; imgF.style.display = 'inline-block'; }
        if (s.backImg) { imgB.src = s.backImg; imgB.style.display = 'inline-block'; }
        if (s.sketchImg) { imgS.src = s.sketchImg; imgS.style.display = 'inline-block'; }

        /* ---- qty grid ---- */
        const rows = await fetch('/POEntry.aspx/BuildQtyGrid', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ styleId })
        }).then(r => r.json()).then(x => x.d);

        renderQtyGrid(rows);
        renderFabric(res.fabrics);
        renderAccessories(res.accessories);
    }

    function renderQtyGrid(rows) {
        const tbody = document.querySelector('#qty-tab table tbody');
        if (!tbody) return;
        if (!rows.length) { tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">No color/size in style.</td></tr>'; return; }
        tbody.innerHTML = rows.map((r, i) => `
            <tr>
                <td>${r.ColorCode}</td>
                <td>${r.SizeCode}</td>
                <td><input type="text" class="grid-input" value="${r.Qty}" data-i="${i}" data-f="qty" /></td>
                <td><input type="text" class="grid-input" value="${r.UnitPrice}" data-i="${i}" data-f="price" /></td>
                <td class="lineTotal" data-i="${i}">0.00</td>
            </tr>`).join('');
        tbody.querySelectorAll('input').forEach(inp => inp.addEventListener('input', recalcGrid));
        recalcGrid();
    }

    function recalcGrid() {
        const tbody = document.querySelector('#qty-tab table tbody');
        if (!tbody) return;
        let grand = 0;
        tbody.querySelectorAll('tr').forEach(tr => {
            const q = tr.querySelector('input[data-f="qty"]');
            const p = tr.querySelector('input[data-f="price"]');
            const t = tr.querySelector('.lineTotal');
            if (!q || !p || !t) return;
            const line = (parseFloat(q.value) || 0) * (parseFloat(p.value) || 0);
            t.textContent = line.toFixed(2);
            grand += line;
        });
        const total = document.getElementById('txtTotalValue');
        if (total) total.value = grand.toFixed(2);
    }

    function renderFabric(items) {
        const tbody = document.querySelector('#fabric-tab table tbody');
        if (!tbody) return;
        if (!items || !items.length) { tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted">No fabric in style.</td></tr>'; return; }
        tbody.innerHTML = items.map(f => `
            <tr>
                <td>${f.code}</td><td>${f.name}</td><td>${f.comp}</td><td>${f.gsm}</td>
                <td>${f.color}</td><td>${f.cons}</td><td>${f.unit}</td>
                <td class="fw-bold totalQtyFab" data-cons="${f.cons}">0.00</td>
                <td><input type="checkbox" checked /></td>
            </tr>`).join('');
        recalcFabAcc();
    }

    function renderAccessories(items) {
        const tbody = document.querySelector('#acc-tab table tbody');
        if (!tbody) return;
        if (!items || !items.length) { tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted">No accessories in style.</td></tr>'; return; }
        tbody.innerHTML = items.map(a => `
            <tr>
                <td>${a.code}</td><td>${a.name}</td><td>${a.type}</td><td>${a.sizeColor}</td>
                <td>${a.cons}</td><td>${a.unit}</td><td>${a.waste}</td>
                <td class="fw-bold totalQtyAcc" data-cons="${a.cons}" data-waste="${a.waste || 0}">0.00</td>
                <td><input type="checkbox" checked /></td>
            </tr>`).join('');
        recalcFabAcc();
    }

    function recalcFabAcc() {
        const poQty = parseFloat(document.getElementById('txtPOQty')?.value) || 0;
        document.querySelectorAll('.totalQtyFab').forEach(el => {
            el.textContent = ((parseFloat(el.dataset.cons) || 0) * poQty).toFixed(2);
        });
        document.querySelectorAll('.totalQtyAcc').forEach(el => {
            const c = parseFloat(el.dataset.cons) || 0;
            const w = parseFloat(el.dataset.waste) || 0;
            el.textContent = (c * poQty * (1 + w / 100)).toFixed(2);
        });
    }

    /* ---------- Boot ---------- */
    document.addEventListener('DOMContentLoaded', () => {
        initStyleDropdown();

        const poQty = document.getElementById('txtPOQty');
        if (poQty) poQty.addEventListener('input', recalcFabAcc);

        const adv = document.getElementById('txtAdvance');
        const bal = document.getElementById('txtBalance');
        if (adv && bal) adv.addEventListener('input', () => {
            bal.value = (100 - (parseFloat(adv.value) || 0)).toFixed(0);
        });
    });

})();