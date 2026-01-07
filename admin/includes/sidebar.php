<?php
/**
 * Halı Yıkamacı - Admin Panel Sidebar
 */

$currentPage = basename($_SERVER['PHP_SELF']);
?>

<div class="sidebar bg-dark" id="sidebar">
    <div class="sidebar-header py-4 px-3 border-bottom border-secondary">
        <a href="index.php" class="text-decoration-none d-flex align-items-center">
            <div class="bg-danger rounded-circle d-flex align-items-center justify-content-center me-2"
                style="width: 40px; height: 40px;">
                <i class="fas fa-shield-alt text-white"></i>
            </div>
            <div>
                <span class="text-white fw-bold">Admin Panel</span>
                <br><small class="text-danger">Yönetici</small>
            </div>
        </a>
    </div>

    <nav class="sidebar-nav py-3">
        <ul class="nav flex-column">
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'index.php' ? 'active' : ''; ?>" href="index.php">
                    <i class="fas fa-tachometer-alt me-2"></i>Dashboard
                </a>
            </li>

            <li class="nav-item mt-2">
                <small class="text-muted px-3">YÖNETİM</small>
            </li>


            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'services.php' ? 'active' : ''; ?>" href="services.php">
                    <i class="fas fa-list-check me-2"></i>Hizmetler
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'promo-codes.php' ? 'active' : ''; ?>"
                    href="promo-codes.php">
                    <i class="fas fa-percent me-2"></i>Kampanya Kodları
                </a>
            </li>

            <li class="nav-item mt-2">
                <small class="text-muted px-3">PAKETLER</small>
            </li>

            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'sms-packages.php' ? 'active' : ''; ?>"
                    href="sms-packages.php">
                    <i class="fas fa-coins me-2"></i>KRD Paketleri
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'vitrin-packages.php' ? 'active' : ''; ?>"
                    href="vitrin-packages.php">
                    <i class="fas fa-store me-2"></i>Vitrin Paketleri
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'campaign-packages.php' ? 'active' : ''; ?>"
                    href="campaign-packages.php">
                    <i class="fas fa-tags me-2"></i>Kampanya Paketleri
                </a>
            </li>

            <li class="nav-item mt-2">
                <small class="text-muted px-3">KULLANICILAR</small>
            </li>

            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'firms.php' || $currentPage === 'firm-detail.php' ? 'active' : ''; ?>"
                    href="firms.php">
                    <i class="fas fa-building me-2"></i>Firmalar
                    <span class="badge bg-warning text-dark ms-auto" id="pendingFirmsBadge"
                        style="display: none;">0</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'customers.php' ? 'active' : ''; ?>"
                    href="customers.php">
                    <i class="fas fa-users me-2"></i>Müşteriler
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'orders.php' ? 'active' : ''; ?>" href="orders.php">
                    <i class="fas fa-receipt me-2"></i>Siparişler
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'purchases.php' ? 'active' : ''; ?>"
                    href="purchases.php">
                    <i class="fas fa-shopping-cart me-2"></i>Satın Almalar
                    <span class="badge bg-info ms-auto" id="pendingPurchasesBadge" style="display: none;">0</span>
                </a>
            </li>

            <li class="nav-item mt-2">
                <small class="text-muted px-3">DESTEK & AYARLAR</small>
            </li>

            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'support.php' ? 'active' : ''; ?>" href="support.php">
                    <i class="fas fa-headset me-2"></i>Müşteri Desteği
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'firm-support.php' ? 'active' : ''; ?>"
                    href="firm-support.php">
                    <i class="fas fa-building-circle-check me-2"></i>Firma Desteği
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'faq.php' ? 'active' : ''; ?>" href="faq.php">
                    <i class="fas fa-robot me-2"></i>Bot / SSS
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'contact-messages.php' ? 'active' : ''; ?>"
                    href="contact-messages.php">
                    <i class="fas fa-envelope-open-text me-2"></i>İletişim Mesajları
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'reports.php' ? 'active' : ''; ?>" href="reports.php">
                    <i class="fas fa-chart-bar me-2"></i>Raporlar
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'legal.php' ? 'active' : ''; ?>" href="legal.php">
                    <i class="fas fa-file-contract me-2"></i>Yasal Dokümanlar
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link <?php echo ($currentPage == 'slider-settings.php') ? 'active' : ''; ?>"
                    href="slider-settings.php">
                    <i class="fas fa-images me-2"></i>Slider Ayarları
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo ($currentPage == 'footer-settings.php') ? 'active' : ''; ?>"
                    href="footer-settings.php">
                    <i class="fas fa-shoe-prints me-2"></i>Footer Ayarları
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo ($currentPage == 'demo-settings.php') ? 'active' : ''; ?>"
                    href="demo-settings.php">
                    <i class="fas fa-magic me-2"></i>Demo / Vitrin
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'ad-settings.php' ? 'active' : ''; ?>"
                    href="ad-settings.php">
                    <i class="fas fa-ad me-2"></i>Reklam Ayarları
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'popup-ads.php' ? 'active' : ''; ?>"
                    href="popup-ads.php">
                    <i class="fas fa-images me-2"></i>Popup Yönetimi
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'accounting.php' ? 'active' : ''; ?>"
                    href="accounting.php">
                    <i class="fas fa-wallet me-2"></i>Ön Muhasebe
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'paytr-settings.php' ? 'active' : ''; ?>"
                    href="paytr-settings.php">
                    <i class="fas fa-credit-card me-2"></i>PayTR Ayarları
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'profanity-settings.php' ? 'active' : ''; ?>"
                    href="profanity-settings.php">
                    <i class="fas fa-ban me-2"></i>Küfür Filtresi
                </a>
            </li>

            <li class="nav-item mt-3 pt-3 border-top border-secondary">
                <a class="nav-link <?php echo $currentPage === 'account-settings.php' ? 'active' : ''; ?>"
                    href="account-settings.php">
                    <i class="fas fa-user-cog me-2"></i>Hesap Ayarları
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-danger" href="javascript:void(0)" onclick="window.doLogout()">
                    <i class="fas fa-sign-out-alt me-2"></i>Çıkış Yap
                </a>
            </li>
        </ul>
    </nav>
</div>

<style>
    .sidebar {
        position: fixed;
        top: 0;
        left: 0;
        height: 100vh;
        width: 260px;
        overflow-y: auto;
        z-index: 1000;
        transition: transform 0.3s ease;
    }

    .sidebar-nav .nav-link {
        color: rgba(255, 255, 255, 0.7);
        padding: 12px 20px;
        display: flex;
        align-items: center;
        transition: all 0.2s;
    }

    .sidebar-nav .nav-link:hover {
        color: #fff;
        background: rgba(255, 255, 255, 0.1);
    }

    .sidebar-nav .nav-link.active {
        color: #fff;
        background: #dc3545;
    }

    .sidebar-nav .nav-link i {
        width: 20px;
    }

    .main-content {
        margin-left: 260px;
        min-height: 100vh;
        background: #f8f9fa;
    }

    .main-content .page-header {
        background: linear-gradient(135deg, #dc3545, #b02a37);
        color: white;
        padding: 20px 30px;
    }

    .main-content .page-body {
        padding: 30px;
    }

    @media (max-width: 991px) {
        .sidebar {
            transform: translateX(-100%);
        }

        .sidebar.show {
            transform: translateX(0);
        }

        .main-content {
            margin-left: 0;
        }

        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 999;
        }

        .sidebar-overlay.show {
            display: block;
        }
    }
</style>