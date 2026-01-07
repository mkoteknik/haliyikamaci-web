<?php
/**
 * Halı Yıkamacı - Admin SMS Paketleri
 */

require_once '../config/app.php';
$pageTitle = 'SMS Paketleri';
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
                <h4 class="mb-0">KRD Paketleri</h4>
                <div></div>
            </div>

            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center">
                    <h4 class="mb-0"><i class="fas fa-coins me-2"></i>KRD Paketleri</h4>
                    <button class="btn btn-light" data-bs-toggle="modal" data-bs-target="#packageModal"
                        id="addPackageBtn">
                        <i class="fas fa-plus me-1"></i>Yeni Paket
                    </button>
                </div>
            </div>

            <div class="page-body">
                <div class="row g-4" id="packagesList">
                    <div class="col-12 text-center py-5">
                        <div class="spinner"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Package Modal -->
    <div class="modal fade" id="packageModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="packageModalTitle">KRD Paketi Ekle/Düzenle</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="packageForm">
                    <div class="modal-body">
                        <input type="hidden" id="packageId">

                        <div class="mb-3">
                            <label class="form-label">Paket Adı</label>
                            <input type="text" id="packageName" class="form-control" required
                                placeholder="Örn: Başlangıç Paketi">
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label">KRD Adedi</label>
                                <input type="number" id="packageSmsCount" class="form-control" min="1" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label">Fiyat (₺)</label>
                                <input type="number" id="packagePrice" class="form-control" min="0" step="0.01"
                                    required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Açıklama</label>
                            <textarea id="packageDescription" class="form-control" rows="2"></textarea>
                        </div>

                        <div class="form-check">
                            <input type="checkbox" class="form-check-input" id="packageIsPopular">
                            <label class="form-check-label" for="packageIsPopular">Popüler olarak işaretle</label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save me-1"></i>Kaydet
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged, signOut } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, query, where, doc, getDoc, addDoc, updateDoc, deleteDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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

        let packages = [];
        let editingPackageId = null;

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

        window.editPackage = function (packageId) {
            const pkg = packages.find(p => p.id === packageId);
            if (!pkg) return;

            editingPackageId = packageId;
            document.getElementById('packageModalTitle').textContent = 'KRD Paketi Düzenle';
            document.getElementById('packageName').value = pkg.name;
            document.getElementById('packageSmsCount').value = pkg.smsCount;
            document.getElementById('packagePrice').value = pkg.price;
            document.getElementById('packageDescription').value = pkg.description || '';
            document.getElementById('packageIsPopular').checked = pkg.isPopular || false;

            new bootstrap.Modal(document.getElementById('packageModal')).show();
        };

        window.deletePackage = async function (packageId) {
            const result = await Swal.fire({
                title: 'Kalıcı Olarak Sil?',
                text: "Bu paketi kalıcı olarak silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Evet, Sil',
                cancelButtonText: 'İptal'
            });

            if (result.isConfirmed) {
                try {
                    await deleteDoc(doc(db, 'smsPackages', packageId));

                    await Swal.fire(
                        'Silindi!',
                        'Paket başarıyla silindi.',
                        'success'
                    );
                    // Kullanıcının isteği üzerine sayfa yenileme
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

            await loadPackages();
            setupForm();
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

        async function loadPackages() {
            try {
                const packagesRef = collection(db, 'smsPackages');
                const snapshot = await getDocs(packagesRef);

                packages = [];
                snapshot.forEach(doc => {
                    packages.push({ id: doc.id, ...doc.data() });
                });

                packages.sort((a, b) => a.smsCount - b.smsCount);
                renderPackages();

            } catch (error) {
                console.error('Paketler yüklenirken hata:', error);
            }
        }

        function renderPackages() {
            const container = document.getElementById('packagesList');

            if (packages.length === 0) {
                container.innerHTML = `
                    <div class="col-12 text-center py-5">
                        <i class="fas fa-coins fa-4x text-muted mb-3"></i>
                        <h5>Henüz KRD paketi eklenmemiş</h5>
                        <p class="text-muted">Yeni paket eklemek için "Yeni Paket" butonunu kullanın.</p>
                    </div>`;
                return;
            }

            container.innerHTML = packages.map(pkg => `
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm ${pkg.isPopular ? 'border-primary border-2' : ''}">
                        ${pkg.isPopular ? '<div class="card-header bg-primary text-white text-center py-2"><i class="fas fa-star me-1"></i>Popüler</div>' : ''}
                        <div class="card-body text-center">
                            <h5>${pkg.name}</h5>
                            <div class="my-3">
                                <span class="display-4 fw-bold text-primary">${pkg.smsCount}</span>
                                <span class="text-muted d-block">KRD</span>
                            </div>
                            <h4 class="text-success">${window.formatPrice(pkg.price)}</h4>
                            <p class="text-muted small">${pkg.description || ''}</p>
                        </div>
                        <div class="card-footer bg-white border-0">
                            <div class="d-flex gap-2">
                                <button class="btn btn-outline-primary flex-grow-1" onclick="window.editPackage('${pkg.id}')">
                                    <i class="fas fa-edit me-1"></i>Düzenle
                                </button>
                                <button class="btn btn-outline-danger" onclick="window.deletePackage('${pkg.id}')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `).join('');
        }

        function setupForm() {
            document.getElementById('addPackageBtn').addEventListener('click', () => {
                editingPackageId = null;
                document.getElementById('packageModalTitle').textContent = 'Yeni KRD Paketi';
                document.getElementById('packageForm').reset();
            });

            document.getElementById('packageForm').addEventListener('submit', async (e) => {
                e.preventDefault();

                const data = {
                    name: document.getElementById('packageName').value.trim(),
                    smsCount: parseInt(document.getElementById('packageSmsCount').value),
                    price: parseFloat(document.getElementById('packagePrice').value),
                    description: document.getElementById('packageDescription').value.trim(),
                    isPopular: document.getElementById('packageIsPopular').checked
                };

                try {
                    if (editingPackageId) {
                        await updateDoc(doc(db, 'smsPackages', editingPackageId), data);
                        await Swal.fire('Başarılı', 'Paket güncellendi.', 'success');
                    } else {
                        data.createdAt = new Date();
                        await addDoc(collection(db, 'smsPackages'), data);
                        await Swal.fire('Başarılı', 'Yeni paket eklendi.', 'success');
                    }

                    bootstrap.Modal.getInstance(document.getElementById('packageModal')).hide();
                    await loadPackages();

                } catch (error) {
                    Swal.fire('Hata', error.message, 'error');
                }
            });
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