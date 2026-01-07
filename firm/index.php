<?php
/**
 * Halı Yıkamacı - Firma Dashboard
 */

require_once '../config/app.php';
$pageTitle = 'Firma Paneli';
?>
<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $pageTitle . ' - ' . SITE_NAME; ?></title>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <!-- Custom CSS -->
    <link rel="stylesheet" href="<?php echo SITE_URL; ?>/assets/css/style.css">
</head>

<body>

    <!-- Auth Check -->
    <div id="authCheck" class="d-flex align-items-center justify-content-center vh-100"
        style="display: none !important;">
        <div class="text-center">
            <div class="spinner mb-3"></div>
            <p class="text-muted">Yetkilendirme kontrol ediliyor...</p>
        </div>
    </div>

    <!-- Pending Approval Screen -->
    <div id="pendingApproval" class="d-flex align-items-center justify-content-center vh-100 d-none">
        <div class="text-center">
            <div class="bg-warning text-dark rounded-circle d-inline-flex align-items-center justify-content-center mb-4"
                style="width: 100px; height: 100px;">
                <i class="fas fa-clock fa-3x"></i>
            </div>
            <h2>Onay Bekleniyor</h2>
            <p class="text-muted mb-4">Firma hesabınız henüz onaylanmamış.<br>Admin tarafından onaylandıktan sonra
                panele erişebilirsiniz.</p>
            <a href="login.php" class="btn btn-outline-secondary" onclick="window.firebaseAuth.signOut()">
                <i class="fas fa-sign-out-alt me-2"></i>Çıkış Yap
            </a>
        </div>
    </div>

    <!-- Main Layout -->
    <div id="mainLayout" style="display: none;">
        <?php require_once 'includes/sidebar.php'; ?>

        <!-- Sidebar Overlay (mobile) -->
        <div class="sidebar-overlay" id="sidebarOverlay"></div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Mobile Header -->
            <div class="d-lg-none bg-dark text-white p-3 d-flex justify-content-between align-items-center">
                <button class="btn btn-outline-light btn-sm" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>
                <span class="fw-bold">Firma Paneli</span>
                <div></div>
            </div>

            <!-- Page Header -->
            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h4 class="mb-1">Hoş Geldiniz!</h4>
                        <p class="mb-0 opacity-75" id="firmNameHeader">Firma Adı</p>
                    </div>
                    <div class="text-end d-none d-md-block">
                        <p class="mb-0 small opacity-75"><?php echo date('d F Y, l'); ?></p>
                    </div>
                </div>
            </div>

            <!-- Page Body -->
            <div class="page-body">
                <!-- Stats Row -->
                <div class="row g-4 mb-4">
                    <div class="col-6 col-lg-3">
                        <div class="card h-100 border-0 shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-2">
                                    <div class="bg-primary bg-opacity-10 rounded p-2 me-2">
                                        <i class="fas fa-eye text-primary"></i>
                                    </div>
                                </div>
                                <h3 class="mb-1" id="statViews">-</h3>
                                <small class="text-muted">Görüntülenme</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-6 col-lg-3">
                        <div class="card h-100 border-0 shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-2">
                                    <div class="bg-success bg-opacity-10 rounded p-2 me-2">
                                        <i class="fas fa-box text-success"></i>
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
                                        <i class="fas fa-star text-warning"></i>
                                    </div>
                                </div>
                                <h3 class="mb-1" id="statRating">-</h3>
                                <small class="text-muted" id="statReviews">0 değerlendirme</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-6 col-lg-3">
                        <div class="card h-100 border-0 shadow-sm">
                            <div class="card-body">
                                <div class="d-flex align-items-center mb-2">
                                    <div class="bg-info bg-opacity-10 rounded p-2 me-2">
                                        <i class="fas fa-clock text-info"></i>
                                    </div>
                                </div>
                                <h3 class="mb-1" id="statPending">-</h3>
                                <small class="text-muted">Bekleyen Sipariş</small>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- SMS Status & Quick Actions -->
                <div class="row g-4 mb-4">
                    <!-- SMS Balance -->
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="rounded-circle p-3 me-3" id="smsIconWrapper"
                                        style="background: rgba(40, 167, 69, 0.1);">
                                        <i class="fas fa-coins fa-2x" id="smsIcon" style="color: #28a745;"></i>
                                    </div>
                                    <div class="flex-grow-1">
                                        <small class="text-muted d-block">KRD Bakiyeniz</small>
                                        <h2 class="mb-0" id="smsBalance">-</h2>
                                    </div>
                                    <a href="krd.php" class="btn btn-primary">
                                        <i class="fas fa-plus me-1"></i>KRD Al
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Quick Actions -->
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-header bg-white border-0">
                                <h6 class="mb-0">Hızlı İşlemler</h6>
                            </div>
                            <div class="card-body">
                                <div class="row g-2">
                                    <div class="col-4">
                                        <a href="marketing.php" class="btn btn-outline-primary w-100 py-3">
                                            <i class="fas fa-ad d-block mb-1"></i>
                                            <small>Vitrin</small>
                                        </a>
                                    </div>
                                    <div class="col-4">
                                        <a href="marketing.php?tab=campaigns"
                                            class="btn btn-outline-success w-100 py-3">
                                            <i class="fas fa-tags d-block mb-1"></i>
                                            <small>Kampanya</small>
                                        </a>
                                    </div>
                                    <div class="col-4">
                                        <a href="services.php" class="btn btn-outline-warning w-100 py-3">
                                            <i class="fas fa-list d-block mb-1"></i>
                                            <small>Hizmetler</small>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Orders -->
                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-white border-0 d-flex justify-content-between align-items-center">
                        <h6 class="mb-0">Son Siparişler</h6>
                        <a href="orders.php" class="btn btn-sm btn-outline-primary">
                            Tümünü Gör <i class="fas fa-arrow-right ms-1"></i>
                        </a>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Müşteri</th>
                                        <th>Hizmetler</th>
                                        <th>Tarih</th>
                                        <th>Durum</th>
                                        <th></th>
                                    </tr>
                                </thead>
                                <tbody id="recentOrdersTable">
                                    <tr>
                                        <td colspan="5" class="text-center py-4 text-muted">
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

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Firebase Modular SDK -->
    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged, signOut } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
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

        let currentFirm = null;

        onAuthStateChanged(auth, async (user) => {
            if (!user) {
                window.location.href = 'login.php';
                return;
            }

            // STRICT RBAC: Check User Type via 'users' collection
            try {
                const userDocRef = doc(db, 'users', user.uid);
                const userDocSnap = await getDoc(userDocRef);

                if (userDocSnap.exists()) {
                    const userData = userDocSnap.data();
                    if (userData.userType !== 'firm' && userData.userType !== 'admin') {
                        console.warn('Unauthorized access: User is not a firm. Redirecting to Customer Panel.');
                        window.location.href = '../customer/my-orders.php';
                        return;
                    }
                } else {
                    console.warn('User document not found inside users collection.');
                    // Maybe new user? But they should have a user doc. Redirect to Login to be safe.
                    window.location.href = 'login.php';
                    return;
                }
            } catch (error) {
                console.error('RBAC Check Error:', error);
                window.location.href = 'login.php';
                return;
            }

            // Get firm data
            const firm = await getFirmData(user.uid);

            if (!firm) {
                window.location.href = 'login.php';
                return;
            }

            currentFirm = firm;

            console.log('Firma verisi:', firm);
            console.log('isApproved değeri:', firm.isApproved);

            // Check approval status
            if (firm.isApproved !== true) {
                console.log('Firma onaylı değil veya isApproved undefined');
                document.getElementById('authCheck').classList.add('d-none');
                document.getElementById('pendingApproval').classList.remove('d-none');
                return;
            }

            // Show main layout
            console.log('Firma onaylı, dashboard yükleniyor...');
            document.getElementById('authCheck').classList.add('d-none');
            document.getElementById('pendingApproval').classList.add('d-none');
            document.getElementById('mainLayout').style.display = 'block';

            // Load dashboard data
            await loadDashboard(firm);
        });

        async function getFirmData(uid) {
            try {
                const firmsRef = collection(db, 'firms');
                const q = query(firmsRef, where('uid', '==', uid));
                const snapshot = await getDocs(q);

                if (snapshot.empty) return null;

                return { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
            } catch (error) {
                console.error('Firma verisi alınamadı:', error);
                return null;
            }
        }

        async function loadDashboard(firm) {
            try {
                // Update header
                document.getElementById('firmNameHeader').textContent = firm.name;
                document.getElementById('firmNameSidebar')?.textContent && (document.getElementById('firmNameSidebar').textContent = firm.name);

                // Stats
                document.getElementById('statViews').textContent = firm.viewCount || 0;
                document.getElementById('statRating').textContent = (firm.rating || 0).toFixed(1);
                document.getElementById('statReviews').textContent = `${firm.reviewCount || 0} değerlendirme`;

                // SMS Balance
                const smsBalance = firm.smsBalance || 0;
                document.getElementById('smsBalance').textContent = smsBalance + ' KRD';

                const smsBalanceSidebar = document.getElementById('smsBalanceSidebar');
                if (smsBalanceSidebar) smsBalanceSidebar.textContent = smsBalance + ' KRD';

                if (smsBalance < 50) {
                    const smsIconWrapper = document.getElementById('smsIconWrapper');
                    const smsIcon = document.getElementById('smsIcon');
                    const smsBadge = document.getElementById('smsBadge');

                    if (smsIconWrapper) smsIconWrapper.style.background = 'rgba(220, 53, 69, 0.1)';
                    if (smsIcon) smsIcon.style.color = '#dc3545';
                    if (smsBadge) smsBadge.style.display = 'inline';
                }

                // Load orders
                await loadRecentOrders(firm.id);
                console.log('Dashboard yüklendi!');
            } catch (error) {
                console.error('Dashboard yüklenirken hata:', error);
            }
        }

        async function loadRecentOrders(firmId) {
            try {
                const ordersRef = collection(db, 'orders');
                const q = query(ordersRef, where('firmId', '==', firmId));
                const snapshot = await getDocs(q);

                let orders = [];
                let pendingCount = 0;

                snapshot.forEach(doc => {
                    const order = { id: doc.id, ...doc.data() };
                    orders.push(order);
                    if (order.status === 'pending') pendingCount++;
                });

                // Sort by date and take last 5
                orders.sort((a, b) => {
                    const dateA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt);
                    const dateB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt);
                    return dateB - dateA;
                });

                const recentOrders = orders.slice(0, 5);

                // Update stats
                document.getElementById('statOrders').textContent = orders.length;
                document.getElementById('statPending').textContent = pendingCount;

                if (pendingCount > 0) {
                    document.getElementById('pendingOrdersBadge').textContent = pendingCount;
                    document.getElementById('pendingOrdersBadge').style.display = 'inline';
                }

                // Render table
                const tbody = document.getElementById('recentOrdersTable');

                if (recentOrders.length === 0) {
                    tbody.innerHTML = `
                <tr>
                    <td colspan="5" class="text-center py-4 text-muted">
                        <i class="fas fa-inbox fa-2x mb-2"></i>
                        <p class="mb-0">Henüz sipariş yok</p>
                    </td>
                </tr>
            `;
                    return;
                }

                tbody.innerHTML = recentOrders.map(order => {
                    const date = order.createdAt?.toDate ? order.createdAt.toDate() : new Date(order.createdAt);
                    const items = order.items || [];
                    const status = getStatusBadge(order.status);

                    return `
                <tr>
                    <td>
                        <strong>${order.customerName}</strong>
                        <br><small class="text-muted">${order.customerPhone}</small>
                    </td>
                    <td>
                        ${items.slice(0, 2).map(i => `<span class="badge bg-light text-dark me-1">${i.serviceName}</span>`).join('')}
                        ${items.length > 2 ? `<span class="badge bg-secondary">+${items.length - 2}</span>` : ''}
                    </td>
                    <td><small>${formatDate(date)}</small></td>
                    <td>${status}</td>
                    <td>
                        <a href="order-detail.php?id=${order.id}" class="btn btn-sm btn-outline-primary">
                            <i class="fas fa-eye"></i>
                        </a>
                    </td>
                </tr>
            `;
                }).join('');

            } catch (error) {
                console.error('Siparişler yüklenirken hata:', error);
            }
        }

        function getStatusBadge(status) {
            const config = {
                pending: { class: 'warning', text: 'Bekliyor' },
                confirmed: { class: 'info', text: 'Onaylandı' },
                picked_up: { class: 'primary', text: 'Alındı' },
                measured: { class: 'info', text: 'Ölçüldü' },
                delivered: { class: 'success', text: 'Teslim' }, cancelled: { class: 'danger', text: 'İptal' }
            };

            const s = config[status] || { class: 'secondary', text: status };
            return `<span class="badge bg-${s.class}">${s.text}</span>`;
        }

        function formatDate(date) {
            return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }).format(date);
        }

        // Sidebar toggle (mobile)
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