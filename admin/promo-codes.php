<?php
/**
 * Halı Yıkamacı - Admin Kampanya Kodları
 */

require_once '../config/app.php';
$pageTitle = 'Kampanya Kodları';
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
                <span class="fw-bold">Kampanya Kodları</span>
                <div></div>
            </div>

            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center">
                    <h4 class="mb-0"><i class="fas fa-percent me-2"></i>Kampanya Kodları</h4>
                    <button class="btn btn-light" data-bs-toggle="modal" data-bs-target="#promoModal" id="addPromoBtn">
                        <i class="fas fa-plus me-1"></i>Yeni Kod
                    </button>
                </div>
            </div>

            <div class="page-body">
                <div class="alert alert-info mb-4">
                    <i class="fas fa-info-circle me-2"></i>
                    Burada oluşturduğunuz kodlar <strong>tüm firmaların siparişleri</strong> için geçerli olacaktır.
                </div>

                <div class="card border-0 shadow-sm">
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="bg-light">
                                    <tr>
                                        <th class="ps-4">Kod</th>
                                        <th>İndirim</th>
                                        <th>Limit / Kullanılan</th>
                                        <th>Geçerlilik</th>
                                        <th>Durum</th>
                                        <th class="text-end pe-4">İşlemler</th>
                                    </tr>
                                </thead>
                                <tbody id="promoList">
                                    <tr>
                                        <td colspan="6" class="text-center py-5">
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

    <!-- Promo Code Modal -->
    <div class="modal fade" id="promoModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="promoModalTitle">Yeni Kampanya Kodu</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="promoForm">
                    <div class="modal-body">
                        <input type="hidden" id="promoId">

                        <div class="mb-3">
                            <label class="form-label">Kampanya Kodu</label>
                            <input type="text" id="promoCode" class="form-control text-uppercase" required
                                placeholder="Örn: YAZ10">
                            <div class="form-text">Büyük harf ve rakamlardan oluşmalıdır.</div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label">İndirim Türü</label>
                                <select id="promoType" class="form-select">
                                    <option value="percent">Yüzde (%)</option>
                                    <option value="fixed">Sabit Tutar (₺)</option>
                                </select>
                            </div>
                            <div class="col-6">
                                <label class="form-label">Değer</label>
                                <input type="number" id="promoValue" class="form-control" required min="1">
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label">Başlangıç Tarihi</label>
                                <input type="date" id="validFrom" class="form-control">
                            </div>
                            <div class="col-6">
                                <label class="form-label">Bitiş Tarihi</label>
                                <input type="date" id="validUntil" class="form-control">
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Kullanım Limiti (Opsiyonel)</label>
                            <input type="number" id="usageLimit" class="form-control"
                                placeholder="Sınırsız için boş bırakın">
                        </div>

                        <div class="form-check form-switch mb-3">
                            <input class="form-check-input" type="checkbox" id="isActive" checked>
                            <label class="form-check-label" for="isActive">Aktif</label>
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
        import { getFirestore, collection, getDocs, query, where, doc, getDoc, addDoc, updateDoc, deleteDoc, Timestamp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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

        let promoList = [];
        let editingId = null;

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

        window.editPromo = function (id) {
            const promo = promoList.find(p => p.id === id);
            if (!promo) return;

            editingId = id;
            document.getElementById('promoModalTitle').textContent = 'Kodu Düzenle';
            document.getElementById('promoCode').value = promo.code;
            document.getElementById('promoType').value = promo.type;
            document.getElementById('promoValue').value = promo.value;

            // Dates - convert Timestamp to YYYY-MM-DD
            if (promo.validFrom) {
                document.getElementById('validFrom').value = new Date(promo.validFrom.seconds * 1000).toISOString().split('T')[0];
            } else {
                document.getElementById('validFrom').value = '';
            }

            if (promo.validUntil) {
                document.getElementById('validUntil').value = new Date(promo.validUntil.seconds * 1000).toISOString().split('T')[0];
            } else {
                document.getElementById('validUntil').value = '';
            }

            document.getElementById('usageLimit').value = promo.totalUsageLimit || '';
            document.getElementById('isActive').checked = promo.isActive !== false;

            new bootstrap.Modal(document.getElementById('promoModal')).show();
        };

        window.deletePromo = async function (id) {
            if (!confirm('Bu kodu silmek istediğinize emin misiniz?')) return;

            try {
                await deleteDoc(doc(db, 'promoCodes', id));
                await loadPromoCodes();
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

            await loadPromoCodes();
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

        async function loadPromoCodes() {
            try {
                const ref = collection(db, 'promoCodes');
                // Sadece global kodları (firmId == null) çek
                const q = query(ref, where('firmId', '==', null));
                const snapshot = await getDocs(q);

                promoList = [];
                snapshot.forEach(doc => {
                    promoList.push({ id: doc.id, ...doc.data() });
                });

                // Client side sort (created at descending)
                promoList.sort((a, b) => (b.createdAt?.seconds || 0) - (a.createdAt?.seconds || 0));
                renderPromoCodes();

            } catch (error) {
                console.error('Kodlar yüklenirken hata:', error);
                document.getElementById('promoList').innerHTML = `
                    <tr><td colspan="6" class="text-center text-danger">Yükleme hatası: ${error.message}</td></tr>
                `;
            }
        }

        function renderPromoCodes() {
            const container = document.getElementById('promoList');

            if (promoList.length === 0) {
                container.innerHTML = `
                    <tr>
                        <td colspan="6" class="text-center py-5">
                            <i class="fas fa-search fa-3x text-muted mb-3"></i>
                            <h5 class="text-muted">Kayıtlı kampanya kodu yok</h5>
                        </td>
                    </tr>
                `;
                return;
            }

            container.innerHTML = promoList.map(p => {
                const discountText = p.type === 'percent' ? `%${p.value}` : `₺${p.value}`;
                const usage = p.usedCount || 0;
                const limit = p.totalUsageLimit || '∞';

                let dateText = 'Süresiz';
                if (p.validUntil) {
                    const d = new Date(p.validUntil.seconds * 1000);
                    dateText = d.toLocaleDateString('tr-TR');
                }

                const statusBadge = p.isActive
                    ? '<span class="badge bg-success">Aktif</span>'
                    : '<span class="badge bg-secondary">Pasif</span>';

                return `
                <tr>
                    <td class="ps-4 fw-bold font-monospace">${p.code}</td>
                    <td><span class="badge bg-info text-dark">${discountText}</span></td>
                    <td>${usage} / ${limit}</td>
                    <td>${dateText}</td>
                    <td>${statusBadge}</td>
                    <td class="text-end pe-4">
                        <button class="btn btn-sm btn-outline-primary me-1" onclick="window.editPromo('${p.id}')">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-danger" onclick="window.deletePromo('${p.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </td>
                </tr>
                `;
            }).join('');
        }

        function setupForm() {
            document.getElementById('addPromoBtn').addEventListener('click', () => {
                editingId = null;
                document.getElementById('promoModalTitle').textContent = 'Yeni Kampanya Kodu';
                document.getElementById('promoForm').reset();
                // Defaults
                document.getElementById('isActive').checked = true;
            });

            document.getElementById('promoForm').addEventListener('submit', async (e) => {
                e.preventDefault();

                // Parse Dates
                const validFromVal = document.getElementById('validFrom').value;
                const validUntilVal = document.getElementById('validUntil').value;

                const data = {
                    code: document.getElementById('promoCode').value.toUpperCase().trim(),
                    type: document.getElementById('promoType').value,
                    value: parseFloat(document.getElementById('promoValue').value),
                    isActive: document.getElementById('isActive').checked,
                    firmId: null, // GLOBAL CODE
                    totalUsageLimit: document.getElementById('usageLimit').value ? parseInt(document.getElementById('usageLimit').value) : null,
                    validFrom: validFromVal ? Timestamp.fromDate(new Date(validFromVal)) : null,
                    validUntil: validUntilVal ? Timestamp.fromDate(new Date(validUntilVal)) : null,
                };

                try {
                    if (editingId) {
                        await updateDoc(doc(db, 'promoCodes', editingId), data);
                    } else {
                        data.createdAt = Timestamp.now();
                        data.usedCount = 0;
                        await addDoc(collection(db, 'promoCodes'), data);
                    }

                    bootstrap.Modal.getInstance(document.getElementById('promoModal')).hide();
                    await loadPromoCodes();

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