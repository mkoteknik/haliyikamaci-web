<?php
/**
 * Halı Yıkamacı - Admin Kampanya Paketleri
 */

require_once '../config/app.php';
$pageTitle = 'Kampanya Paketleri';
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
                <span class="fw-bold">Kampanya Paketleri</span>
                <div></div>
            </div>

            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center">
                    <h4 class="mb-0"><i class="fas fa-tags me-2"></i>Kampanya Paketleri</h4>
                    <button class="btn btn-light" data-bs-toggle="modal" data-bs-target="#packageModal"
                        id="addPackageBtn">
                        <i class="fas fa-plus me-1"></i>Yeni Paket
                    </button>
                </div>
            </div>

            <div class="page-body">
                <div class="alert alert-info mb-4">
                    <i class="fas fa-info-circle me-2"></i>
                    Kampanya paketleri, firmaların kendi kampanyalarını oluşturarak müşterilere sunmasını sağlar.
                    Firmalar KRD bakiyelerinden bu paketleri satın alır ve kampanya başlığı/açıklaması girer.
                </div>

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
                    <h5 class="modal-title" id="packageModalTitle">Yeni Kampanya Paketi</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="packageForm">
                    <div class="modal-body">
                        <input type="hidden" id="packageId">

                        <div class="mb-3">
                            <label class="form-label">Paket Adı</label>
                            <input type="text" id="packageName" class="form-control" required
                                placeholder="Örn: 30 Günlük Kampanya">
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label">Süre (Gün)</label>
                                <input type="number" id="packageDays" class="form-control" min="1" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label">KRD Maliyeti</label>
                                <input type="number" id="packageSmsCost" class="form-control" min="1" required>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Açıklama</label>
                            <textarea id="packageDescription" class="form-control" rows="2"
                                placeholder="Firmalar bu paketi alarak kampanya oluşturabilir"></textarea>
                        </div>

                        <div class="form-check">
                            <input type="checkbox" class="form-check-input" id="packageIsActive" checked>
                            <label class="form-check-label" for="packageIsActive">Aktif</label>
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
            if (confirm('Çıkış yapmak istediğinize emin misiniz?')) {
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
            document.getElementById('packageModalTitle').textContent = 'Kampanya Paketi Düzenle';
            document.getElementById('packageName').value = pkg.name;
            document.getElementById('packageDays').value = pkg.durationDays || pkg.days || 0;
            document.getElementById('packageSmsCost').value = pkg.smsCost;
            document.getElementById('packageDescription').value = pkg.description || '';
            document.getElementById('packageIsActive').checked = pkg.isActive !== false;

            new bootstrap.Modal(document.getElementById('packageModal')).show();
        };

        window.deletePackage = async function (packageId) {
            if (!confirm('Bu paketi silmek istediğinize emin misiniz?')) return;

            try {
                await deleteDoc(doc(db, 'campaignPackages', packageId));
                await loadPackages();
            } catch (error) {
                console.error('Silme hatası:', error);
                alert('Hata: ' + error.message);
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
                const packagesRef = collection(db, 'campaignPackages');
                const snapshot = await getDocs(packagesRef);

                packages = [];
                snapshot.forEach(doc => {
                    packages.push({ id: doc.id, ...doc.data() });
                });

                // Sort by order or durationDays
                packages.sort((a, b) => (a.order || a.durationDays || 0) - (b.order || b.durationDays || 0));
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
                        <i class="fas fa-tags fa-4x text-muted mb-3"></i>
                        <h5>Henüz kampanya paketi eklenmemiş</h5>
                        <p class="text-muted">Yeni paket eklemek için "Yeni Paket" butonunu kullanın.</p>
                    </div>
                `;
                return;
            }

            container.innerHTML = packages.map(pkg => `
                <div class="col-md-6 col-lg-4">
                    <div class="card h-100 border-0 shadow-sm ${pkg.isActive === false ? 'opacity-50' : ''}">
                        <div class="card-header bg-success text-white text-center py-2">
                            <i class="fas fa-tags me-1"></i>Kampanya Paketi
                        </div>
                        <div class="card-body text-center">
                            <h5>${pkg.name}</h5>
                            <div class="my-3">
                                <span class="display-4 fw-bold text-success">${pkg.durationDays || pkg.days || 0}</span>
                                <span class="text-muted d-block">Gün</span>
                            </div>
                            <div class="bg-light rounded p-2 mb-3">
                                <strong>${pkg.smsCost} KRD</strong>
                            </div>
                            <p class="text-muted small">${pkg.description || ''}</p>
                            <span class="badge ${pkg.isActive !== false ? 'bg-success' : 'bg-secondary'}">
                                ${pkg.isActive !== false ? 'Aktif' : 'Pasif'}
                            </span>
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
                document.getElementById('packageModalTitle').textContent = 'Yeni Kampanya Paketi';
                document.getElementById('packageForm').reset();
                document.getElementById('packageIsActive').checked = true;
            });

            document.getElementById('packageForm').addEventListener('submit', async (e) => {
                e.preventDefault();

                const data = {
                    name: document.getElementById('packageName').value.trim(),
                    durationDays: parseInt(document.getElementById('packageDays').value),
                    smsCost: parseInt(document.getElementById('packageSmsCost').value),
                    description: document.getElementById('packageDescription').value.trim(),
                    isActive: document.getElementById('packageIsActive').checked,
                    order: 0
                };

                try {
                    if (editingPackageId) {
                        await updateDoc(doc(db, 'campaignPackages', editingPackageId), data);
                    } else {
                        data.createdAt = new Date();
                        await addDoc(collection(db, 'campaignPackages'), data);
                    }

                    bootstrap.Modal.getInstance(document.getElementById('packageModal')).hide();
                    await loadPackages();

                } catch (error) {
                    console.error('Kaydetme hatası:', error);
                    alert('Hata: ' + error.message);
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