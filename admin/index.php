<?php
/**
 * Halı Yıkamacı - Admin Dashboard
 */

require_once '../config/app.php';
$pageTitle = 'Admin Dashboard';
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
            <p class="text-muted">Yetki kontrol ediliyor...</p>
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
                <span class="fw-bold">Admin Panel</span>
                <div></div>
            </div>

            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h4 class="mb-1"><i class="fas fa-tachometer-alt me-2"></i>Dashboard</h4>
                        <p class="mb-0 opacity-75">Halı Yıkamacı Yönetim Paneli</p>
                    </div>
                    <div class="text-end d-none d-md-block">
                        <p class="mb-0 small opacity-75"><?php echo date('d F Y, l'); ?></p>
                    </div>
                </div>
            </div>

            <div class="page-body">
                <!-- Stats Row -->
                <div class="row g-4 mb-4">
                    <div class="col-6 col-lg-3">
                        <div class="card h-100 border-0 shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-2">
                                    <div class="bg-primary bg-opacity-10 rounded p-2 me-2">
                                        <i class="fas fa-store text-primary"></i>
                                    </div>
                                </div>
                                <h3 class="mb-1" id="statFirms">-</h3>
                                <small class="text-muted">Toplam Firma</small>
                                <div class="mt-2">
                                    <span class="badge bg-warning" id="pendingFirmsCount">0 bekliyor</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-6 col-lg-3">
                        <div class="card h-100 border-0 shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-2">
                                    <div class="bg-success bg-opacity-10 rounded p-2 me-2">
                                        <i class="fas fa-users text-success"></i>
                                    </div>
                                </div>
                                <h3 class="mb-1" id="statCustomers">-</h3>
                                <small class="text-muted">Toplam Müşteri</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-6 col-lg-3">
                        <div class="card h-100 border-0 shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-2">
                                    <div class="bg-info bg-opacity-10 rounded p-2 me-2">
                                        <i class="fas fa-box text-info"></i>
                                    </div>
                                </div>
                                <h3 class="mb-1" id="statOrders">-</h3>
                                <small class="text-muted">Toplam Sipariş</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-6 col-lg-3">
                        <div class="card h-100 border-0 shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-2">
                                    <div class="bg-warning bg-opacity-10 rounded p-2 me-2">
                                        <i class="fas fa-shopping-cart text-warning"></i>
                                    </div>
                                </div>
                                <h3 class="mb-1" id="statPurchases">-</h3>
                                <small class="text-muted">Bekleyen Satın Alma</small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-4">
                    <!-- Pending Firms -->
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm h-100">
                            <div
                                class="card-header bg-white border-0 d-flex justify-content-between align-items-center">
                                <h6 class="mb-0"><i class="fas fa-clock text-warning me-2"></i>Onay Bekleyen Firmalar
                                </h6>
                                <a href="firms.php?status=pending" class="btn btn-sm btn-outline-primary">Tümü</a>
                            </div>
                            <div class="card-body p-0">
                                <div class="list-group list-group-flush" id="pendingFirmsList">
                                    <div class="text-center py-4">
                                        <div class="spinner"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Pending Purchases -->
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm h-100">
                            <div
                                class="card-header bg-white border-0 d-flex justify-content-between align-items-center">
                                <h6 class="mb-0"><i class="fas fa-shopping-cart text-info me-2"></i>Bekleyen Satın
                                    Almalar</h6>
                                <a href="purchases.php" class="btn btn-sm btn-outline-primary">Tümü</a>
                            </div>
                            <div class="card-body p-0">
                                <div class="list-group list-group-flush" id="pendingPurchasesList">
                                    <div class="text-center py-4">
                                        <div class="spinner"></div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Orders -->
                <div class="card border-0 shadow-sm mt-4">
                    <div class="card-header bg-white border-0 d-flex justify-content-between align-items-center">
                        <h6 class="mb-0"><i class="fas fa-history text-primary me-2"></i>Son Siparişler</h6>
                        <a href="orders.php" class="btn btn-sm btn-outline-primary">Tümü</a>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>KRD Miktarı</th>
                                        <th>Firma</th>
                                        <th>Tarih</th>
                                        <th>Durum</th>
                                    </tr>
                                </thead>
                                <tbody id="recentOrdersTable">
                                    <tr>
                                        <td colspan="4" class="text-center py-4">
                                            <div class="spinner"></div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, query, where, orderBy, limit, doc, getDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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

        // Initialize global functions
        window.doLogout = async function () {
            try {
                await auth.signOut();
                window.location.href = 'login.php';
            } catch (error) {
                console.error('Logout failed:', error);
            }
        };

        onAuthStateChanged(auth, async (user) => {
            if (!user) {
                window.location.href = 'login.php';
                return;
            }

            const isAdmin = await checkIsAdmin(user.uid);


            if (!isAdmin) {

                await auth.signOut();
                window.location.href = 'login.php';
                return;
            }


            document.getElementById('authCheck').classList.add('d-none');
            document.getElementById('mainLayout').style.display = 'block';


            try {
                await loadDashboard();

            } catch (err) {
                console.error('Dashboard load failed:', err);
            }
        });

        async function checkIsAdmin(uid) {
            try {


                // First try direct document access (if doc ID = uid)
                const userDocRef = doc(db, 'users', uid);
                const userDoc = await getDoc(userDocRef);

                if (userDoc.exists()) {
                    const data = userDoc.data();

                    return data.userType === 'admin';
                }

                // Fallback: Query by uid field

                const usersRef = collection(db, 'users');
                const q = query(usersRef, where('uid', '==', uid));
                const snapshot = await getDocs(q);

                if (!snapshot.empty) {
                    const data = snapshot.docs[0].data();

                    return data.userType === 'admin';
                }


                return false;
            } catch (error) {
                console.error('Admin check error:', error);
                return false;
            }
        }

        async function loadDashboard() {
            try {
                // Firms count
                const firmsRef = collection(db, 'firms');
                const firmsSnapshot = await getDocs(firmsRef);
                let totalFirms = 0;
                let pendingFirms = [];

                firmsSnapshot.forEach(doc => {
                    totalFirms++;
                    const data = doc.data();
                    if (!data.isApproved) {
                        pendingFirms.push({ id: doc.id, ...data });
                    }
                });

                document.getElementById('statFirms').textContent = totalFirms;
                document.getElementById('pendingFirmsCount').textContent = pendingFirms.length + ' bekliyor';

                // Update sidebar badge
                if (pendingFirms.length > 0) {
                    const badge = document.getElementById('pendingFirmsBadge');
                    if (badge) {
                        badge.textContent = pendingFirms.length;
                        badge.style.display = 'inline';
                    }
                }

                // Customers count
                const customersRef = collection(db, 'customers');
                const customersSnapshot = await getDocs(customersRef);
                document.getElementById('statCustomers').textContent = customersSnapshot.size;

                // Orders count
                const ordersRef = collection(db, 'orders');
                const ordersSnapshot = await getDocs(ordersRef);
                const statOrdersEl = document.getElementById('statOrders');
                if (statOrdersEl) statOrdersEl.textContent = ordersSnapshot.size;

                // Pending purchases
                const purchasesRef = collection(db, 'smsPurchases');
                const purchasesQ = query(purchasesRef, where('status', '==', 'pending'));
                const purchasesSnapshot = await getDocs(purchasesQ);
                document.getElementById('statPurchases').textContent = purchasesSnapshot.size;

                if (purchasesSnapshot.size > 0) {
                    const pBadge = document.getElementById('pendingPurchasesBadge');
                    if (pBadge) {
                        pBadge.textContent = purchasesSnapshot.size;
                        pBadge.style.display = 'inline';
                    }
                }

                // Render pending firms
                renderPendingFirms(pendingFirms.slice(0, 5));

                // Render pending purchases
                let purchases = [];
                purchasesSnapshot.forEach(doc => {
                    purchases.push({ id: doc.id, ...doc.data() });
                });
                renderPendingPurchases(purchases.slice(0, 5));

                // Render recent orders
                let orders = [];
                ordersSnapshot.forEach(doc => {
                    orders.push({ id: doc.id, ...doc.data() });
                });
                orders.sort((a, b) => {
                    const dateA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt);
                    const dateB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt);
                    return dateB - dateA;
                });
                renderRecentOrders(orders.slice(0, 10));

            } catch (error) {
                console.error('Dashboard load error:', error);
            }
        }

        function renderPendingFirms(firms) {
            const container = document.getElementById('pendingFirmsList');

            if (firms.length === 0) {
                container.innerHTML = `
            <div class="list-group-item text-center text-muted py-4">
                <i class="fas fa-check-circle fa-2x mb-2 text-success"></i>
                <p class="mb-0">Bekleyen firma yok</p>
            </div>
        `;
                return;
            }

            container.innerHTML = firms.map(firm => {
                const addr = firm.address || {};
                return `
            <a href="firms.php?id=${firm.id}" class="list-group-item list-group-item-action">
                <div class="d-flex align-items-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-2 me-3">
                        <i class="fas fa-store text-warning"></i>
                    </div>
                    <div class="flex-grow-1">
                        <h6 class="mb-0">${firm.name}</h6>
                        <small class="text-muted">${addr.city || ''} - ${firm.phone || ''}</small>
                    </div>
                    <i class="fas fa-chevron-right text-muted"></i>
                </div>
            </a>
        `;
            }).join('');
        }

        function renderPendingPurchases(purchases) {
            const container = document.getElementById('pendingPurchasesList');

            if (purchases.length === 0) {
                container.innerHTML = `
            <div class="list-group-item text-center text-muted py-4">
                <i class="fas fa-check-circle fa-2x mb-2 text-success"></i>
                <p class="mb-0">Bekleyen satın alma yok</p>
            </div>
        `;
                return;
            }

            container.innerHTML = purchases.map(p => {
                return `
            <a href="purchases.php?id=${p.id}" class="list-group-item list-group-item-action">
                <div class="d-flex align-items-center">
                    <div class="bg-info bg-opacity-10 rounded-circle p-2 me-3">
                        <i class="fas fa-sms text-info"></i>
                    </div>
                    <div class="flex-grow-1">
                        <h6 class="mb-0">${p.firmName}</h6>
                        <small class="text-muted">${p.packageName} - ${p.smsCount} SMS</small>
                    </div>
                    <span class="badge bg-warning">Bekliyor</span>
                </div>
            </a>
        `;
            }).join('');
        }

        function renderRecentOrders(orders) {
            const tbody = document.getElementById('recentOrdersTable');

            if (orders.length === 0) {
                tbody.innerHTML = `
            <tr>
                <td colspan="4" class="text-center text-muted py-4">Henüz sipariş yok</td>
            </tr>
        `;
                return;
            }

            tbody.innerHTML = orders.map(order => {
                const date = order.createdAt?.toDate ? order.createdAt.toDate() : new Date(order.createdAt);
                const status = getStatusBadge(order.status);

                return `
            <tr>
                <td>
                    <strong>${order.customerName}</strong>
                    <br><small class="text-muted">${order.customerPhone}</small>
                </td>
                <td>${order.firmName || '-'}</td>
                <td><small>${formatDate(date)}</small></td>
                <td>${status}</td>
            </tr>
        `;
            }).join('');
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