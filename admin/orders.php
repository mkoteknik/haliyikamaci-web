<?php
/**
 * Halı Yıkamacı - Admin Siparişler
 */

require_once '../config/app.php';
$pageTitle = 'Siparişler';
?>
<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $pageTitle . ' - ' . SITE_NAME; ?></title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link rel="stylesheet" href="<?php echo SITE_URL; ?>/assets/css/style.css">
</head>

<body>

    <div id="authCheck" class="d-flex align-items-center justify-content-center vh-100">
        <div class="text-center">
            <div class="spinner mb-3"></div>
            <p class="text-muted">Yükleniyor...</p>
        </div>
    </div>

    <div id="mainLayout" style="display: none;">
        <?php require_once 'includes/sidebar.php'; ?>
        <div class="sidebar-overlay" id="sidebarOverlay"></div>

        <div class="main-content">
            <div class="d-lg-none bg-dark text-white p-3 d-flex justify-content-between align-items-center">
                <button class="btn btn-outline-light btn-sm" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>
                <span class="fw-bold">Siparişler</span>
                <div></div>
            </div>

            <div class="page-header">
                <h4 class="mb-0"><i class="fas fa-box me-2"></i>Sipariş Takibi</h4>
            </div>

            <!-- Filters -->
            <div class="bg-white border-bottom py-3 px-4">
                <div class="d-flex flex-wrap gap-2">
                    <button class="btn btn-primary status-filter active" data-status="all">
                        Tümü <span class="badge bg-white text-primary ms-1" id="countAll">0</span>
                    </button>
                    <button class="btn btn-outline-warning status-filter" data-status="pending">
                        Bekliyor <span class="badge bg-warning text-dark ms-1" id="countPending">0</span>
                    </button>
                    <button class="btn btn-outline-info status-filter" data-status="confirmed">
                        Onaylandı <span class="badge bg-info ms-1" id="countConfirmed">0</span>
                    </button>
                    <button class="btn btn-outline-success status-filter" data-status="delivered">
                        Teslim Edildi <span class="badge bg-success ms-1" id="countDelivered">0</span>
                    </button>
                </div>
            </div>

            <div class="page-body">
                <div id="ordersList">
                    <div class="text-center py-5">
                        <div class="spinner"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, query, where, doc, getDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

        const firebaseConfig = {
            apiKey: "AIzaSyAZBzUpPtWHnW3mlF38L7YGpiknMB9dZb8",
            authDomain: "halisepetimbl.firebaseapp.com",
            projectId: "halisepetimbl",
            storageBucket: "halisepetimbl.firebasestorage.app",
            messagingSenderId: "782891273844",
            appId: "1:782891273844:web:750619b1bfe1939e52cb21"
        };

        const app = initializeApp(firebaseConfig);
        const auth = getAuth(app);
        const db = getFirestore(app, 'haliyikamacimmbldatabase');

        window.firebaseAuth = auth;
        window.firebaseDb = db;

        let allOrders = [];
        let currentFilter = 'all';

        onAuthStateChanged(auth, async (user) => {
            if (!user) {
                window.location.href = 'login.php';
                return;
            }

            const isAdmin = await checkIsAdmin(user.uid);
            if (!isAdmin) {
                window.location.href = 'login.php';
                return;
            }

            document.getElementById('authCheck').classList.add('d-none');
            document.getElementById('mainLayout').style.display = 'block';

            await loadOrders();
            setupFilters();
        });

        async function checkIsAdmin(uid) {
            try {
                const userDocRef = doc(db, 'users', uid);
                const userDoc = await getDoc(userDocRef);

                if (userDoc.exists()) {
                    return userDoc.data().userType === 'admin';
                }
                return false;
            } catch (error) {
                console.error('Admin check error:', error);
                return false;
            }
        }

        async function loadOrders() {
            try {
                const ordersRef = collection(db, 'orders');
                const snapshot = await getDocs(ordersRef);

                allOrders = [];
                snapshot.forEach(doc => {
                    allOrders.push({ id: doc.id, ...doc.data() });
                });

                // Sort by date
                allOrders.sort((a, b) => {
                    const dateA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt);
                    const dateB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt);
                    return dateB - dateA;
                });

                updateCounts();
                renderOrders();

            } catch (error) {
                console.error('Siparişler yüklenirken hata:', error);
            }
        }

        function updateCounts() {
            const counts = {
                all: allOrders.length,
                pending: allOrders.filter(o => o.status === 'pending').length,
                confirmed: allOrders.filter(o => ['confirmed', 'picked_up', 'measured'].includes(o.status)).length,
                delivered: allOrders.filter(o => o.status === 'delivered').length
            };

            document.getElementById('countAll').textContent = counts.all;
            document.getElementById('countPending').textContent = counts.pending;
            document.getElementById('countConfirmed').textContent = counts.confirmed;
            document.getElementById('countDelivered').textContent = counts.delivered;
        }

        function renderOrders() {
            const container = document.getElementById('ordersList');

            let filtered = allOrders;
            if (currentFilter === 'pending') {
                filtered = allOrders.filter(o => o.status === 'pending');
            } else if (currentFilter === 'confirmed') {
                filtered = allOrders.filter(o => ['confirmed', 'picked_up', 'measured'].includes(o.status));
            } else if (currentFilter === 'delivered') {
                filtered = allOrders.filter(o => o.status === 'delivered');
            }

            if (filtered.length === 0) {
                container.innerHTML = `
            <div class="text-center py-5">
                <i class="fas fa-box fa-4x text-muted mb-3"></i>
                <h5>Sipariş Bulunamadı</h5>
            </div>
        `;
                return;
            }

            container.innerHTML = `
        <div class="table-responsive">
            <table class="table table-hover">
                <thead class="table-light">
                    <tr>
                        <th>Müşteri</th>
                        <th>Firma</th>
                        <th>Hizmetler</th>
                        <th>Tutar</th>
                        <th>Tarih</th>
                        <th>Durum</th>
                    </tr>
                </thead>
                <tbody>
                    ${filtered.map(order => {
                const createdAt = order.createdAt?.toDate ? order.createdAt.toDate() : new Date(order.createdAt);
                const items = order.items || [];
                const services = items.map(i => i.serviceName).join(', ');

                return `
                            <tr>
                                <td>
                                    <strong>${order.customerName}</strong>
                                    <br><small class="text-muted">${order.customerPhone}</small>
                                </td>
                                <td>${order.firmName || '-'}</td>
                                <td><small>${services.substring(0, 30)}${services.length > 30 ? '...' : ''}</small></td>
                                <td>${formatPrice(order.totalPrice || 0)}</td>
                                <td>${formatDate(createdAt)}</td>
                                <td>${getStatusBadge(order.status)}</td>
                            </tr>
                        `;
            }).join('')}
                </tbody>
            </table>
        </div>
    `;
        }

        function setupFilters() {
            document.querySelectorAll('.status-filter').forEach(btn => {
                btn.addEventListener('click', () => {
                    document.querySelectorAll('.status-filter').forEach(b => {
                        b.classList.remove('active', 'btn-primary');
                        b.classList.add('btn-outline-' + getFilterClass(b.dataset.status));
                    });
                    btn.classList.add('active', 'btn-primary');
                    btn.classList.remove('btn-outline-primary', 'btn-outline-warning', 'btn-outline-info', 'btn-outline-success');

                    currentFilter = btn.dataset.status;
                    renderOrders();
                });
            });
        }

        function getFilterClass(status) {
            return { all: 'primary', pending: 'warning', confirmed: 'info', delivered: 'success' }[status] || 'secondary';
        }

        function getStatusBadge(status) {
            const config = {
                pending: { class: 'warning', text: 'Bekliyor' },
                confirmed: { class: 'info', text: 'Onaylandı' },
                picked_up: { class: 'primary', text: 'Alındı' },
                measured: { class: 'info', text: 'Ölçüldü' },
                delivered: { class: 'success', text: 'Teslim' },
                cancelled: { class: 'danger', text: 'İptal' }
            };
            const s = config[status] || { class: 'secondary', text: status };
            return `<span class="badge bg-${s.class}">${s.text}</span>`;
        }

        function formatPrice(price) {
            return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(price);
        }

        function formatDate(date) {
            return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }).format(date);
        }

        // Sidebar toggle
        document.getElementById('sidebarToggle')?.addEventListener('click', () => {
            document.getElementById('sidebar').classList.toggle('show');
            document.getElementById('sidebarOverlay').classList.toggle('show');
        });

        document.getElementById('sidebarOverlay')?.addEventListener('click', () => {
            document.getElementById('sidebar').classList.remove('show');
            document.getElementById('sidebarOverlay').classList.remove('show');
        });
    </script>

</body>

</html>