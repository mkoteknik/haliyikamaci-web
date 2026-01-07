<?php
/**
 * Halı Yıkamacı - Admin Hizmetler
 */

require_once '../config/app.php';
$pageTitle = 'Hizmetler';
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
                <span class="fw-bold">Hizmetler</span>
                <div></div>
            </div>

            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center">
                    <h4 class="mb-0"><i class="fas fa-list-check me-2"></i>Hizmetler</h4>
                    <button class="btn btn-light" data-bs-toggle="modal" data-bs-target="#serviceModal"
                        id="addServiceBtn">
                        <i class="fas fa-plus me-1"></i>Yeni Hizmet
                    </button>
                </div>
            </div>

            <div class="page-body">
                <div class="alert alert-info mb-4">
                    <i class="fas fa-info-circle me-2"></i>
                    Burada tanımlanan hizmetler tüm firmalar tarafından kullanılabilir. Firmalar kendi fiyatlarını
                    belirler.
                </div>

                <div class="row g-4" id="servicesList">
                    <div class="col-12 text-center py-5">
                        <div class="spinner"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Service Modal -->
    <div class="modal fade" id="serviceModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="serviceModalTitle">Yeni Hizmet</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="serviceForm">
                    <div class="modal-body">
                        <input type="hidden" id="serviceId">

                        <div class="mb-3">
                            <label class="form-label">Hizmet Adı</label>
                            <input type="text" id="serviceName" class="form-control" required
                                placeholder="Örn: Halı Yıkama">
                        </div>

                        <div class="mb-3">
                            <div class="mb-3">
                                <label class="form-label">Birimler</label>
                                <div class="card p-3 bg-light border-0">
                                    <div class="row g-2">
                                        <div class="col-6">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="serviceUnits"
                                                    value="m2" id="unit_m2">
                                                <label class="form-check-label" for="unit_m2">m² (Metrekare)</label>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="serviceUnits"
                                                    value="adet" id="unit_adet">
                                                <label class="form-check-label" for="unit_adet">Adet</label>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="serviceUnits"
                                                    value="takim" id="unit_takim">
                                                <label class="form-check-label" for="unit_takim">Takım</label>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" name="serviceUnits"
                                                    value="meter" id="unit_meter">
                                                <label class="form-check-label" for="unit_meter">Metre</label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">İkon</label>
                                <select id="serviceIcon" class="form-select">
                                    <option value="carpet">🧹 Halı</option>
                                    <option value="sofa">🛋️ Koltuk</option>
                                    <option value="curtain">🪟 Perde</option>
                                    <option value="mattress">🛏️ Yatak</option>
                                    <option value="cleaning">🧼 Temizlik</option>
                                    <option value="wash">💧 Yıkama</option>
                                </select>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Açıklama</label>
                                <textarea id="serviceDescription" class="form-control" rows="2"></textarea>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Sıralama</label>
                                <input type="number" id="serviceOrder" class="form-control" value="1" min="1">
                            </div>

                            <div class="form-check form-switch mb-3">
                                <input class="form-check-input" type="checkbox" id="serviceIsActive" checked>
                                <label class="form-check-label" for="serviceIsActive">Hizmet Mobilde Görünsün
                                    (Aktif)</label>
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

        let services = [];
        let editingServiceId = null;

        const iconMap = {
            carpet: '🧹', sofa: '🛋️', curtain: '🪟', mattress: '🛏️', cleaning: '🧼', wash: '💧'
        };

        const unitLabels = {
            m2: 'm²', adet: 'Adet', takim: 'Takım', meter: 'Metre'
        };

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

        window.editService = function (serviceId) {
            const svc = services.find(s => s.id === serviceId);
            if (!svc) return;

            editingServiceId = serviceId;
            document.getElementById('serviceModalTitle').textContent = 'Hizmet Düzenle';
            document.getElementById('serviceName').value = svc.name;

            // Clear all checks first
            document.querySelectorAll('input[name="serviceUnits"]').forEach(cb => cb.checked = false);

            // Check specific units
            // Handle legacy String unit vs new Array units
            const units = Array.isArray(svc.units) ? svc.units : (svc.unit ? [svc.unit] : ['adet']);
            units.forEach(unit => {
                const cb = document.querySelector(`input[name="serviceUnits"][value="${unit}"]`);
                if (cb) cb.checked = true;
            });

            document.getElementById('serviceIcon').value = svc.icon || 'cleaning';
            document.getElementById('serviceDescription').value = svc.description || '';
            document.getElementById('serviceOrder').value = svc.order || 1;
            document.getElementById('serviceIsActive').checked = svc.isActive !== false; // Default true if undefined

            new bootstrap.Modal(document.getElementById('serviceModal')).show();
        };

        window.deleteService = async function (serviceId) {
            if (!confirm('Bu hizmeti silmek istediğinize emin misiniz?')) return;

            try {
                await deleteDoc(doc(db, 'services', serviceId));
                await loadServices();
            } catch (error) {
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

            await loadServices();
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

        async function loadServices() {
            try {
                const servicesRef = collection(db, 'services');
                const snapshot = await getDocs(servicesRef);

                services = [];
                snapshot.forEach(doc => {
                    services.push({ id: doc.id, ...doc.data() });
                });

                services.sort((a, b) => (a.order || 0) - (b.order || 0));
                renderServices();

            } catch (error) {
                console.error('Hizmetler yüklenirken hata:', error);
            }
        }

        function renderServices() {
            const container = document.getElementById('servicesList');

            if (services.length === 0) {
                container.innerHTML = `
            <div class="col-12 text-center py-5">
                <i class="fas fa-list-check fa-4x text-muted mb-3"></i>
                <h5>Henüz hizmet eklenmemiş</h5>
                <p class="text-muted">Yeni hizmet eklemek için "Yeni Hizmet" butonunu kullanın.</p>
            </div>
        `;
                return;
            }

            container.innerHTML = services.map(svc => `
        <div class="col-md-6 col-lg-4">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-body">
                    <div class="d-flex align-items-center mb-3">
                        <div class="bg-primary bg-opacity-10 rounded-circle p-3 me-3">
                            <span class="fs-4">${iconMap[svc.icon] || '✓'}</span>
                        </div>
                        <div>
                            <h5 class="mb-0">${svc.name}</h5>
                            <small class="text-muted">
                                Birimler: ${(Array.isArray(svc.units) ? svc.units : [svc.unit || 'adet'])
                    .map(u => unitLabels[u] || u)
                    .join(', ')
                }
                            </small>
                        </div>
                    </div>
                    <p class="text-muted small">${svc.description || 'Açıklama yok'}</p>
                    <span class="badge bg-light text-dark">Sıra: ${svc.order || 1}</span>
                </div>
                <div class="card-footer bg-white border-0">
                    <div class="d-flex gap-2">
                        <button class="btn btn-outline-primary flex-grow-1" onclick="window.editService('${svc.id}')">
                            <i class="fas fa-edit me-1"></i>Düzenle
                        </button>
                        <button class="btn btn-outline-danger" onclick="window.deleteService('${svc.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
        }

        function setupForm() {
            document.getElementById('addServiceBtn').addEventListener('click', () => {
                editingServiceId = null;
                document.getElementById('serviceModalTitle').textContent = 'Yeni Hizmet';
                document.getElementById('serviceForm').reset();
                document.getElementById('serviceOrder').value = services.length + 1;
            });

            document.getElementById('serviceForm').addEventListener('submit', async (e) => {
                e.preventDefault();

                const data = {
                    name: document.getElementById('serviceName').value.trim(),
                    // Collect selected units
                    units: Array.from(document.querySelectorAll('input[name="serviceUnits"]:checked'))
                        .map(cb => cb.value),
                    icon: document.getElementById('serviceIcon').value,
                    description: document.getElementById('serviceDescription').value.trim(),
                    order: parseInt(document.getElementById('serviceOrder').value) || 1,
                    isActive: document.getElementById('serviceIsActive').checked
                };

                // Validate units
                if (data.units.length === 0) {
                    alert('Lütfen en az bir birim seçiniz.');
                    return;
                }

                try {
                    if (editingServiceId) {
                        await updateDoc(doc(db, 'services', editingServiceId), data);
                    } else {
                        data.createdAt = new Date();
                        await addDoc(collection(db, 'services'), data);
                    }

                    bootstrap.Modal.getInstance(document.getElementById('serviceModal')).hide();
                    await loadServices();

                } catch (error) {
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