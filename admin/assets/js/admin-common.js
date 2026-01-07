/**
 * Admin Panel Common Functions
 * Bu dosya tüm admin sayfalarında ortak kullanılan fonksiyonları içerir
 */

import { signOut } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';

/**
 * Logout fonksiyonu - sidebar'dan çağrılır
 * @param {Object} auth - Firebase auth instance
 */
export function setupLogout(auth) {
    window.doLogout = async function () {
        if (confirm('Çıkış yapmak istediğinize emin misiniz?')) {
            try {
                await signOut(auth);
            } catch (error) {
                console.error('Logout error:', error);
            }
            window.location.href = 'login.php';
        }
    };
}

/**
 * Sidebar toggle fonksiyonu
 */
export function setupSidebar() {
    document.getElementById('sidebarToggle')?.addEventListener('click', () => {
        document.getElementById('sidebar').classList.toggle('show');
        document.getElementById('sidebarOverlay').classList.toggle('show');
    });

    document.getElementById('sidebarOverlay')?.addEventListener('click', () => {
        document.getElementById('sidebar').classList.remove('show');
        document.getElementById('sidebarOverlay').classList.remove('show');
    });
}

/**
 * Fiyat formatlama
 */
export function formatPrice(price) {
    return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(price);
}

/**
 * Tarih formatlama
 */
export function formatDate(date) {
    return new Intl.DateTimeFormat('tr-TR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    }).format(date);
}
