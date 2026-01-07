<?php
/**
 * Halı Yıkamacı - Admin Satın Alma Yönetimi
 */

require_once '../config/app.php';
$pageTitle = 'Satın Almalar';
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
                <h4 class="mb-0">KRD Satın Alımları</h4>
                <div></div>
            </div>

            <div class="page-header">
                <h4 class="mb-0"><i class="fas fa-shopping-cart me-2"></i>KRD Satın Alma Talepleri</h4>
            </div>

            <!-- Tabs -->
            <div class="bg-white border-bottom">
                <div class="container-fluid px-4">
                    <ul class="nav nav-tabs border-0">
                        <li class="nav-item">
                            <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#pendingTab">
                                <i class="fas fa-clock me-1"></i>Bekleyenler
                                <span class="badge bg-warning text-dark ms-1" id="pendingCount">0</span>
                            </button>
                        </li>
                        <li class="nav-item">
                            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#historyTab">
                                <i class="fas fa-history me-1"></i>Geçmiş
                            </button>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="page-body">
                <div class="tab-content">
                    <div class="tab-pane fade show active" id="pendingTab">
                        <div id="pendingList">
                            <div class="text-center py-5">
                                <div class="spinner"></div>
                            </div>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="historyTab">
                        <div id="historyList">
                            <div class="text-center py-5">
                                <div class="spinner"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged, signOut } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, query, where, doc, getDoc, updateDoc, deleteDoc, increment } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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

        let pendingPurchases = [];
        let historyPurchases = [];

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

        window.approvePurchase = async function (purchaseId) {
            const purchase = pendingPurchases.find(p => p.id === purchaseId);
            if (!purchase) return;

            const result = await Swal.fire({
                title: 'Onaylıyor musunuz?',
                text: `${purchase.firmName} firmasına ${purchase.smsCount} SMS eklenecek.`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Evet, Onayla',
                cancelButtonText: 'İptal'
            });

            if (result.isConfirmed) {
                try {
                    await updateDoc(doc(db, 'smsPurchases', purchaseId), {
                        status: 'approved',
                        approvedAt: new Date()
                    });

                    await updateDoc(doc(db, 'firms', purchase.firmId), {
                        smsBalance: increment(purchase.smsCount)
                    });

                    await Swal.fire(
                        'Başarılı!',
                        'SMS bakiyesi eklendi.',
                        'success'
                    );
                    await loadPurchases();

                } catch (error) {
                    Swal.fire('Hata', error.message, 'error');
                }
            }
        };

        window.rejectPurchase = async function (purchaseId) {
            const result = await Swal.fire({
                title: 'Reddediyor musunuz?',
                text: "Bu talep reddedilecek.",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Evet, Reddet',
                cancelButtonText: 'İptal'
            });

            if (result.isConfirmed) {
                try {
                    await updateDoc(doc(db, 'smsPurchases', purchaseId), {
                        status: 'rejected',
                        rejectedAt: new Date()
                    });

                    await Swal.fire('Reddedildi!', 'Talep reddedildi.', 'success');
                    await loadPurchases();

                } catch (error) {
                    Swal.fire('Hata', error.message, 'error');
                }
            }
        };

        window.deletePurchase = async function (purchaseId) {
            const result = await Swal.fire({
                title: 'Kalıcı Olarak Sil?',
                text: "Bu işlem geri alınamaz! Kayıt tamamen silinecek.",
                icon: 'error',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Evet, Sil',
                cancelButtonText: 'İptal'
            });

            if (result.isConfirmed) {
                try {
                    await deleteDoc(doc(db, 'smsPurchases', purchaseId));
                    await Swal.fire(
                        'Silindi!',
                        'Belge başarıyla silindi.',
                        'success'
                    );
                    window.location.reload();
                } catch (error) {
                    console.error("Silme hatası: ", error);
                    Swal.fire('Hata', error.message, 'error');
                }
            }
        };

        window.formatPrice = function (price) {
            return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(price);
        };

        window.formatDate = function (date) {
            try {
                const d = date && date.toDate ? date.toDate() : new Date(date);
                return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' }).format(d);
            } catch (e) {
                return '-';
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

            await loadPurchases();
        });

        async function checkIsAdmin(uid) {
            try {
                const userDoc = await getDoc(doc(db, 'users', uid));
                if (userDoc.exists()) {
                    return userDoc.data().userType === 'admin';
                }
                return false;
            } catch (error) {
                console.error('Admin check error:', error);
                return false;
            }
        }

        async function loadPurchases() {
            try {
                const q = query(collection(db, 'smsPurchases'));
                const snapshot = await getDocs(q);

                pendingPurchases = [];
                historyPurchases = [];

                snapshot.forEach(doc => {
                    const data = { id: doc.id, ...doc.data() };
                    if (data.createdAt && data.createdAt.toDate) {
                        data.createdAt = data.createdAt.toDate();
                    } else if (data.createdAt) {
                        data.createdAt = new Date(data.createdAt);
                    }

                    if (data.status === 'pending') {
                        pendingPurchases.push(data);
                    } else {
                        historyPurchases.push(data);
                    }
                });

                pendingPurchases.sort((a, b) => b.createdAt - a.createdAt);
                historyPurchases.sort((a, b) => b.createdAt - a.createdAt);

                document.getElementById('pendingCount').textContent = pendingPurchases.length;

                renderPending();
                renderHistory();

            } catch (error) {
                console.error('Veri yükleme hatası:', error);
            }
        }

        function renderPending() {
            const container = document.getElementById('pendingList');
            if (pendingPurchases.length === 0) {
                container.innerHTML = `
                    <div class="col-12 text-center py-5 text-muted">
                        <i class="fas fa-check-circle fa-3x mb-3"></i>
                        <p>Bekleyen onay işlemi yok</p>
                    </div>`;
                return;
            }

            container.innerHTML = `
                <div class="row g-4">
                    ${pendingPurchases.map(p => `
                        <div class="col-md-6 col-lg-4">
                            <div class="card h-100 border-0 shadow-sm border-start border-warning border-3">
                                <div class="card-body">
                                    <div class="d-flex justify-content-between align-items-start mb-3">
                                        <h5 class="card-title mb-0">${p.firmName}</h5>
                                        <span class="badge bg-warning text-dark">Bekliyor</span>
                                    </div>
                                    <div class="mb-3">
                                        <h3 class="text-primary mb-0">${p.smsCount} SMS</h3>
                                        <small class="text-muted">${window.formatPrice(p.price)}</small>
                                    </div>
                                    <div class="mb-3 small text-muted">
                                        <div class="mb-1"><i class="far fa-clock me-2"></i>${window.formatDate(p.createdAt)}</div>
                                        <div><i class="fas fa-box me-2"></i>${p.packageName || 'Paket Bilgisi Yok'}</div>
                                    </div>
                                    <div class="d-grid gap-2">
                                        <button class="btn btn-success" onclick="window.approvePurchase('${p.id}')">
                                            <i class="fas fa-check me-2"></i>Onayla
                                        </button>
                                        <button class="btn btn-outline-danger" onclick="window.rejectPurchase('${p.id}')">
                                            <i class="fas fa-times me-2"></i>Reddet
                                        </button>

                                    </div>
                                </div>
                            </div>
                        </div>
                    `).join('')}
                </div>`;
        }

        function renderHistory() {
            const container = document.getElementById('historyList');
            if (historyPurchases.length === 0) {
                container.innerHTML = `
                    <div class="col-12 text-center py-5 text-muted">
                        <i class="fas fa-history fa-3x mb-3"></i>
                        <p>Geçmiş işlem bulunamadı</p>
                    </div>`;
                return;
            }

            container.innerHTML = `
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Firma</th>
                                <th>Paket/KRD</th>
                                <th>Tutar</th>
                                <th>Tarih</th>
                                <th>Durum</th>

                            </tr>
                        </thead>
                        <tbody>
                            ${historyPurchases.map(p => `
                                <tr>
                                    <td>${p.firmName}</td>
                                    <td>
                                        <span class="fw-bold text-primary">${p.smsCount} SMS</span>
                                        <div class="small text-muted">${p.packageName || '-'}</div>
                                    </td>
                                    <td>${window.formatPrice(p.price)}</td>
                                    <td>${window.formatDate(p.createdAt)}</td>
                                    <td>
                                        ${p.status === 'approved'
                    ? '<span class="badge bg-success">Onaylandı</span>'
                    : '<span class="badge bg-danger">Reddedildi</span>'}
                                    </td>

                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>`;
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