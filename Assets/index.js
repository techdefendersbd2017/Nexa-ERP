const validPages = [
    'home', 'erp', 'hrm', 'advocate', 'school', 'inventory',
    'medical', 'custom', 'clients', 'about', 'contact',
    'admin-login', 'user-login'
];

function navigateTo(pageId) {
    if (!validPages.includes(pageId)) pageId = 'home';

    // Hide all page views (Bootstrap-এ 'd-none' ক্লাস ব্যবহার করা হয়)
    document.querySelectorAll('.page-view').forEach(el => {
        el.classList.add('d-none');
    });

    // Show target page view
    const targetPage = document.getElementById(`page-${pageId}`);
    if (targetPage) {
        targetPage.classList.remove('d-none');
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // Update URL hash without standard jumping
    if (window.location.hash !== `#${pageId}`) {
        history.pushState(null, null, `#${pageId}`);
    }
}

// Toggle Mobile Menu
const mobileMenuBtn = document.getElementById('mobile-menu-btn');
const mobileMenu = document.getElementById('mobile-menu');

if (mobileMenuBtn && mobileMenu) {
    mobileMenuBtn.addEventListener('click', () => {
        mobileMenu.classList.toggle('d-none');
    });
}

function toggleMobileMenu() {
    if (mobileMenu) {
        mobileMenu.classList.add('d-none');
    }
}

// Toast Notification Helper (Bootstrap Toast অথবা কাস্টম অ্যালার্ট)
function showToast(message, isSuccess = true) {
    const toast = document.getElementById('notification-toast');
    const toastMessage = document.getElementById('toast-message');
    const toastIcon = document.getElementById('toast-icon');

    if (!toast) return;

    toastMessage.innerText = message;
    toastIcon.className = isSuccess ? 'fa-solid fa-circle-check text-success fs-5' : 'fa-solid fa-circle-exclamation text-warning fs-5';

    // Tailwind এর অ্যানিমেশন ক্লাস বাদ দিয়ে বুটস্ট্রাপের ফেইড ক্লাস বা স্টাইল ব্যবহার করা যেতে পারে
    toast.classList.remove('d-none');
    toast.classList.add('show');

    setTimeout(() => {
        toast.classList.remove('show');
        toast.classList.add('d-none');
    }, 3500);
}

function handleLoginSubmit(e, role) {
    e.preventDefault();
    showToast(`${role} login successful! Redirecting to dashboard.`);
    setTimeout(() => navigateTo('home'), 1500);
}

function handleContactSubmit(e) {
    e.preventDefault();
    e.target.reset();
    showToast('Thank you! Your inquiry has been sent successfully.');
}

// Handle browser back/forward and initial load
window.addEventListener('popstate', () => {
    const hash = window.location.hash.replace('#', '');
    navigateTo(hash || 'home');
});

window.addEventListener('DOMContentLoaded', () => {
    const hash = window.location.hash.replace('#', '');
    navigateTo(hash && validPages.includes(hash) ? hash : 'home');
});