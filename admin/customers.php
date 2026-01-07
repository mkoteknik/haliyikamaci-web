<?php
/**
 * Halı Yıkamacı - Admin Müşteriler
 */

require_once '../config/app.php';
$pageTitle = 'Müşteriler';
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
                <span class="fw-bold">Müşteriler</span>
                <div></div>
            </div>

            <div class="page-header">
                <h4 class="mb-0"><i class="fas fa-users me-2"></i>Müşteri Yönetimi</h4>
            </div>

            <div class="page-body">
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body">
                        <div class="row g-3 align-items-center">
                            <div class="col-md-6">
                                <input type="text" id="searchInput" class="form-control"
                                    placeholder="Müşteri ara (isim veya telefon)...">
                            </div>
                            <div class="col-md-6 text-md-end">
                                <span class="text-muted">Toplam: <strong id="totalCount">0</strong> müşteri</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div id="customersList">
                    <div class="text-center py-5">
                        <div class="spinner"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Customer Detail Modal -->
    <div class="modal fade" id="customerModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="customerModalTitle">Müşteri Detayı</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="customerModalBody">
                    <!-- Dynamic content -->
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged, signOut } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, query, where, doc, getDoc, deleteDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

        console.log('🔵 Customers page script loaded');

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

        let allCustomers = [];
        let filteredCustomers = [];

        // --- GLOBAL FONKSİYONLAR ---

        window.doLogout = async function () {
            const result = await Swal.fire({
                title: 'Çıkış Yap',
                text: "Çıkış yapmak istediğinize emin misiniz?",
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Evet, Çıkış Yap',
                cancelButtonText: 'İptal'
            });

            if (result.isConfirmed) {
                try {
                    await signOut(auth);
                    window.location.href = 'login.php';
                } catch (error) {
                    console.error('Logout error:', error);
                    window.location.href = 'login.php';
                }
            }
        };

        window.deleteCustomer = async function (customerId) {
            const result = await Swal.fire({
                title: 'Müşteriyi Sil?',
                text: "Bu müşteriyi ve ilgili tüm verilerini silmek istediğinize emin misiniz? Bu işlem geri alınamaz!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Evet, Sil',
                cancelButtonText: 'İptal'
            });

            if (result.isConfirmed) {
                try {
                    // Müşteri profilini sil
                    await deleteDoc(doc(db, 'customers', customerId));
                    // User kaydını da sil (giriş yapamaması için)
                    await deleteDoc(doc(db, 'users', customerId));

                    await Swal.fire(
                        'Silindi!',
                        'Müşteri kaydı başarıyla silindi.',
                        'success'
                    );

                    // Listeyi yenile
                    await loadCustomers();
                } catch (error) {
                    console.error("Silme hatası: ", error);
                    Swal.fire('Hata', 'Silme işlemi sırasında bir hata oluştu: ' + error.message, 'error');
                }
            }
        };

        // --- ANA MANTIK ---

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

            await loadCustomers();
            setupSearch();
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

        async function loadCustomers() {
            try {
                const customersRef = collection(db, 'customers');
                const snapshot = await getDocs(customersRef);

                allCustomers = [];
                snapshot.forEach(doc => {
                    allCustomers.push({ id: doc.id, ...doc.data() });
                });

                // Sort by date
                allCustomers.sort((a, b) => {
                    const dateA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt);
                    const dateB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt);
                    return dateB - dateA;
                });

                filteredCustomers = [...allCustomers];
                document.getElementById('totalCount').textContent = allCustomers.length;
                renderCustomers();

            } catch (error) {
                console.error('Müşteriler yüklenirken hata:', error);
            }
        }

        function renderCustomers() {
            const container = document.getElementById('customersList');

            if (filteredCustomers.length === 0) {
                container.innerHTML = `
            <div class="text-center py-5">
                <i class="fas fa-users fa-4x text-muted mb-3"></i>
                <h5>Müşteri Bulunamadı</h5>
            </div>
        `;
                return;
            }

            container.innerHTML = `
        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead class="table-light">
                    <tr>
                        <th>Müşteri</th>
                        <th>Telefon</th>
                        <th>Adres Sayısı</th>
                        <th>Kayıt Tarihi</th>
                        <th class="text-end">İşlemler</th>
                    </tr>
                </thead>
                <tbody>
                    ${filteredCustomers.map(customer => {
                const createdAt = customer.createdAt?.toDate ? customer.createdAt.toDate() : new Date(customer.createdAt);
                const addresses = customer.addresses || [];

                return `
                            <tr>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center me-2"
                                             style="width: 40px; height: 40px;">
                                            <i class="fas fa-user text-primary"></i>
                                        </div>
                                        <strong>${customer.name || 'İsimsiz'}</strong>
                                    </div>
                                </td>
                                <td>${customer.phone}</td>
                                <td>${addresses.length}</td>
                                <td>${formatDate(createdAt)}</td>
                                <td>
                                    <div class="d-flex justify-content-end gap-2">
                                        <button class="btn btn-sm btn-outline-primary btn-view" data-id="${customer.id}" title="Detay">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <button class="btn btn-sm btn-outline-danger" onclick="window.deleteCustomer('${customer.id}')" title="Sil">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        `;
            }).join('')}
                </tbody>
            </table>
        </div>
    `;

            // Setup view buttons
            document.querySelectorAll('.btn-view').forEach(btn => {
                btn.addEventListener('click', () => showCustomerDetail(btn.dataset.id));
            });
        }

        function showCustomerDetail(customerId) {
            const customer = allCustomers.find(c => c.id === customerId);
            if (!customer) return;

            const createdAt = customer.createdAt?.toDate ? customer.createdAt.toDate() : new Date(customer.createdAt);
            const addresses = customer.addresses || [];

            document.getElementById('customerModalTitle').textContent = customer.name || 'Müşteri Detayı';

            document.getElementById('customerModalBody').innerHTML = `
        <div class="row">
            <div class="col-md-6">
                <h6>Temel Bilgiler</h6>
                <table class="table table-sm">
                    <tr><td class="text-muted">İsim</td><td><strong>${customer.name || '-'}</strong></td></tr>
                    <tr><td class="text-muted">Telefon</td><td>${customer.phone}</td></tr>
                    <tr><td class="text-muted">E-posta</td><td>${customer.email || '-'}</td></tr>
                    <tr><td class="text-muted">Kayıt Tarihi</td><td>${formatDate(createdAt)}</td></tr>
                </table>
            </div>
            <div class="col-md-6">
                <h6>İstatistikler</h6>
                <div class="row g-2">
                    <div class="col-6">
                        <div class="bg-light rounded p-3 text-center">
                            <h4 class="mb-0">${addresses.length}</h4>
                            <small class="text-muted">Adres</small>
                        </div>
                    </div>
                    <div class="col-6">
                        <div class="bg-light rounded p-3 text-center">
                            <h4 class="mb-0" id="orderCount">-</h4>
                            <small class="text-muted">Sipariş</small>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        ${addresses.length > 0 ? `
            <hr>
            <h6>Kayıtlı Adresler</h6>
            <div class="list-group">
                ${addresses.map((addr, i) => `
                    <div class="list-group-item">
                        <div class="d-flex justify-content-between">
                            <strong>${addr.title || 'Adres ' + (i + 1)}</strong>
                            ${addr.isDefault ? '<span class="badge bg-primary">Varsayılan</span>' : ''}
                        </div>
                        <small class="text-muted">${addr.fullAddress || ''}</small>
                    </div>
                `).join('')}
            </div>
        ` : ''}
    `;

            loadCustomerOrderCount(customer.id);
            new bootstrap.Modal(document.getElementById('customerModal')).show();
        }

        async function loadCustomerOrderCount(customerId) {
            try {
                const ordersRef = collection(db, 'orders');
                const q = query(ordersRef, where('customerId', '==', customerId));
                const snapshot = await getDocs(q);
                document.getElementById('orderCount').textContent = snapshot.size;
            } catch (error) {
                document.getElementById('orderCount').textContent = '-';
            }
        }

        function setupSearch() {
            document.getElementById('searchInput').addEventListener('input', (e) => {
                const search = e.target.value.toLowerCase().trim();

                if (!search) {
                    filteredCustomers = [...allCustomers];
                } else {
                    filteredCustomers = allCustomers.filter(c =>
                        (c.name || '').toLowerCase().includes(search) ||
                        (c.phone || '').includes(search)
                    );
                }

                renderCustomers();
            });
        }

        function formatDate(date) {
            return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(date);
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