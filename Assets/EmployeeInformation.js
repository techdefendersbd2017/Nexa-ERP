var MAX_PHOTO_SIZE_BYTES = 300 * 1024;

// ছবি সিলেক্ট করার সাথে সাথে photo-box-এ প্রিভিউ দেখানো হয়
function previewEmployeePhoto(input) {
    var img = document.getElementById('imgPhotoPreview');
    var placeholder = document.getElementById('photoPlaceholderText');

    if (input.files && input.files[0]) {
        var file = input.files[0];

        if (file.size > MAX_PHOTO_SIZE_BYTES) {
            alert('ছবির সাইজ 300KB-এর বেশি হতে পারবে না। আপনার ফাইলের সাইজ: ' + (file.size / 1024).toFixed(1) + 'KB');
            input.value = ''; // সিলেকশন বাতিল
            img.removeAttribute('src');
            img.style.display = 'none';
            placeholder.style.display = 'block';
            return;
        }

        var reader = new FileReader();
        reader.onload = function (e) {
            img.src = e.target.result;
            img.style.display = 'block';
            placeholder.style.display = 'none';
        };
        reader.readAsDataURL(file);
    } else {
        img.removeAttribute('src');
        img.style.display = 'none';
        placeholder.style.display = 'block';
    }
}

document.addEventListener("DOMContentLoaded", function () {
    var defaultTab = '#tab1';
    var selectedTab = localStorage.getItem('activeTab') || defaultTab;
    var tabEl = document.querySelector(`button[data-bs-target="${selectedTab}"]`);
    if (tabEl) new bootstrap.Tab(tabEl).show();

    var tabLinks = document.querySelectorAll('.nav-link');
    tabLinks.forEach(function (tab) {
        tab.addEventListener('shown.bs.tab', function (e) {
            localStorage.setItem('activeTab', e.target.getAttribute('data-bs-target'));
        });
    });

    document.querySelectorAll('.tab-nav-btns [data-goto]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var targetSelector = btn.getAttribute('data-goto');
            var targetTabBtn = document.querySelector('button[data-bs-target="' + targetSelector + '"]');
            if (targetTabBtn) {
                new bootstrap.Tab(targetTabBtn).show();
                var contentArea = document.querySelector('.content-area');
                if (contentArea) {
                    contentArea.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            }
        });
    });
});

$(function () {
    function humanize(name) {
        // Convert "ddlDepartment" -> "Department", "ddlSkillGrade" -> "Skill Grade"
        var base = (name || 'Option').replace(/^ddl/i, '');
        base = base.replace(/([a-z0-9])([A-Z])/g, '$1 $2').trim();
        return base || 'Option';
    }
    function initSelect2($el) {
        var label = $el.closest('.form-row-custom').find('label').first().text().trim();
        var placeholderText = 'Select ' + (label || humanize($el.attr('id')));
        var hasEmptyOption = $el.find('option[value=""]').length > 0;
        var $pane = $el.closest('.tab-pane');

        var options = {
            width: '100%',
            dropdownParent: $pane.length ? $pane : $(document.body),
            minimumResultsForSearch: 0 // always show the search box, like the reference image
        };

        if (hasEmptyOption) {
            options.placeholder = placeholderText;
            options.allowClear = false;
        }

        $el.select2(options);
    }

    $('select').each(function () {
        initSelect2($(this));
    });

    // Bootstrap tabs hide inactive panes with display:none, so Select2
    // (which measures width on init) can render 0-width the first time
    // a tab is opened. Force a re-calc when a tab becomes visible.
    $('button[data-bs-toggle="tab"]').on('shown.bs.tab', function (e) {
        var target = $(e.target).attr('data-bs-target');
        $(target).find('select').each(function () {
            if ($(this).hasClass('select2-hidden-accessible')) {
                $(this).select2('destroy');
            }
        });
        $(target).find('select').each(function () {
            initSelect2($(this));
        });
    });

    // =====================================================
    // chkSame / CheckNominee live inside <asp:UpdatePanel>s,
    // so toggling them causes an ASYNC (AJAX) postback that
    // replaces only that panel's HTML — the page itself never
    // reloads, so the active tab no longer resets. But the
    // replaced <select> elements need Select2 re-initialized,
    // since the plain DOM Select2 built earlier is discarded
    // along with the old markup.
    // =====================================================
    if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function (sender, args) {
            var panel = args.get_panelsUpdated && args.get_panelsUpdated()[0];
            var $scope = panel ? $(panel) : $(document);
            $scope.find('select').each(function () {
                if ($(this).hasClass('select2-hidden-accessible')) {
                    $(this).select2('destroy');
                }
                initSelect2($(this));
            });
        });
    }
});