<?php
/**
 * Halı Yıkamacı - Firma Panel Sidebar
 */

// Aktif sayfa kontrolü
$currentPage = basename($_SERVER['PHP_SELF']);
?>

<!-- Sidebar -->
<div class="sidebar bg-dark" id="sidebar">
    <div class="sidebar-header py-4 px-3 border-bottom border-secondary">
        <a href="index.php" class="text-decoration-none d-flex align-items-center">
            <div class="bg-gradient-primary rounded-circle d-flex align-items-center justify-content-center me-2"
                style="width: 40px; height: 40px;">
                <i class="fas fa-store text-white"></i>
            </div>
            <div>
                <span class="text-white fw-bold">Firma Paneli</span>
                <br><small class="text-muted" id="firmNameSidebar">Yükleniyor...</small>
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
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'orders.php' || $currentPage === 'order-detail.php' ? 'active' : ''; ?>"
                    href="orders.php">
                    <i class="fas fa-box me-2"></i>Siparişler
                    <span class="badge bg-warning text-dark ms-auto" id="pendingOrdersBadge"
                        style="display: none;">0</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'services.php' ? 'active' : ''; ?>" href="services.php">
                    <i class="fas fa-list-check me-2"></i>Hizmetler
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'marketing.php' ? 'active' : ''; ?>"
                    href="marketing.php">
                    <i class="fas fa-bullhorn me-2"></i>Pazarlama
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'krd.php' ? 'active' : ''; ?>" href="krd.php">
                    <i class="fas fa-coins me-2"></i>KRD Paketleri
                    <span class="badge bg-danger ms-auto" id="smsBadge" style="display: none;">Düşük</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'accounting.php' ? 'active' : ''; ?>"
                    href="accounting.php">
                    <i class="fas fa-calculator me-2"></i>Ön Muhasebe
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <?php echo $currentPage === 'support.php' ? 'active' : ''; ?>" href="support.php">
                    <i class="fas fa-headset me-2"></i>Destek
                    <span class="badge bg-info ms-auto" id="supportBadge" style="display: none;">0</span>
                </a>
            </li>

            <li class="nav-item mt-3 pt-3 border-top border-secondary">
                <a class="nav-link <?php echo $currentPage === 'profile.php' ? 'active' : ''; ?>" href="profile.php">
                    <i class="fas fa-cog me-2"></i>Profil Ayarları
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link text-danger" href="#" id="logoutLink">
                    <i class="fas fa-sign-out-alt me-2"></i>Çıkış Yap
                </a>
            </li>
        </ul>
    </nav>

    <!-- SMS Balance Mini -->
    <div class="sidebar-footer p-3 border-top border-secondary">
        <div class="d-flex align-items-center">
            <div class="bg-success bg-opacity-25 rounded-circle p-2 me-2">
                <i class="fas fa-coins text-success"></i>
            </div>
            <div>
                <small class="text-muted d-block">KRD Bakiye</small>
                <span class="text-white fw-bold" id="smsBalanceSidebar">-</span>
            </div>
        </div>
    </div>
</div>

<style>
    /* Sidebar Styles */
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
        background: var(--primary-color);
    }

    .sidebar-nav .nav-link i {
        width: 20px;
    }

    /* Main content wrapper */
    .main-content {
        margin-left: 260px;
        min-height: 100vh;
        background: #f8f9fa;
    }

    .main-content .page-header {
        background: linear-gradient(135deg, var(--primary-color), var(--primary-dark));
        color: white;
        padding: 20px 30px;
    }

    .main-content .page-body {
        padding: 30px;
    }

    /* Mobile responsive */
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

<script>
    // Logout handler
    document.getElementById('logoutLink')?.addEventListener('click', async (e) => {
        e.preventDefault();
        if (confirm('Çıkış yapmak istediğinize emin misiniz?')) {
            const auth = window.firebaseAuth;
            if (auth) {
                await auth.signOut();
            }
            window.location.href = 'login.php';
        }
    });
</script>