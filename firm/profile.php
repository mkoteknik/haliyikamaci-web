<?php
/**
 * Halı Yıkamacı - Firma Profil
 */

require_once '../config/app.php';
$pageTitle = 'Profil Ayarları';
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
                <span class="fw-bold">Profil</span>
                <div></div>
            </div>

            <div class="page-header">
                <h4 class="mb-0"><i class="fas fa-cog me-2"></i>Profil Ayarları</h4>
            </div>

            <div class="page-body">
                <div class="row g-4">
                    <!-- Left Column - Profile Card -->
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm mb-4">
                            <div class="card-body text-center">
                                <div class="position-relative d-inline-block mb-3">
                                    <div class="bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center"
                                        style="width: 120px; height: 120px;" id="logoPreview">
                                        <i class="fas fa-store fa-4x text-primary"></i>
                                    </div>
                                </div>
                                <h4 id="firmNameDisplay">-</h4>
                                <p class="text-muted" id="firmAddressDisplay">-</p>
                                <div class="d-flex justify-content-center gap-3">
                                    <div class="text-center">
                                        <h5 class="mb-0 text-warning" id="ratingDisplay">-</h5>
                                        <small class="text-muted">Puan</small>
                                    </div>
                                    <div class="text-center">
                                        <h5 class="mb-0 text-info" id="reviewCountDisplay">-</h5>
                                        <small class="text-muted">Yorum</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Stats -->
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white">
                                <h6 class="mb-0">Hızlı Bilgiler</h6>
                            </div>
                            <div class="list-group list-group-flush">
                                <div class="list-group-item d-flex justify-content-between">
                                    <span>SMS Bakiye</span>
                                    <strong id="smsBalanceDisplay">-</strong>
                                </div>
                                <div class="list-group-item d-flex justify-content-between">
                                    <span>Toplam Sipariş</span>
                                    <strong id="totalOrdersDisplay">-</strong>
                                </div>
                                <div class="list-group-item d-flex justify-content-between">
                                    <span>Kayıt Tarihi</span>
                                    <strong id="createdAtDisplay">-</strong>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Column - Settings -->
                    <div class="col-lg-8">
                        <!-- Basic Info -->
                        <div class="card border-0 shadow-sm mb-4">
                            <div class="card-header bg-white">
                                <h6 class="mb-0"><i class="fas fa-info-circle text-primary me-2"></i>Temel Bilgiler</h6>
                            </div>
                            <div class="card-body">
                                <form id="basicInfoForm">
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Firma Adı</label>
                                            <input type="text" id="firmName" class="form-control" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Telefon</label>
                                            <input type="tel" id="firmPhone" class="form-control" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">WhatsApp</label>
                                            <input type="tel" id="firmWhatsapp" class="form-control"
                                                placeholder="Opsiyonel">
                                        </div>
                                        <div class="col-12">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-save me-1"></i>Kaydet
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <!-- Address -->
                        <div class="card border-0 shadow-sm mb-4">
                            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                <h6 class="mb-0"><i class="fas fa-map-marker-alt text-primary me-2"></i>Adres</h6>
                                <button type="button" class="btn btn-sm btn-outline-primary" id="findLocationBtn">
                                    <i class="fas fa-location-arrow me-1"></i> Konumumu Bul
                                </button>
                            </div>
                            <div class="card-body">
                                <form id="addressForm">
                                    <div class="row g-3">
                                        <div class="col-md-4">
                                            <label class="form-label">İl</label>
                                            <select id="addressCity" class="form-select" required>
                                                <option value="">Yükleniyor...</option>
                                            </select>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label">İlçe</label>
                                            <select id="addressDistrict" class="form-select" required disabled>
                                                <option value="">Önce il seçiniz...</option>
                                            </select>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label">Mahalle</label>
                                            <select id="addressNeighborhood" class="form-select" required disabled>
                                                <option value="">Önce ilçe seçiniz...</option>
                                            </select>
                                        </div>
                                        <div class="col-12">
                                            <label class="form-label">Açık Adres</label>
                                            <textarea id="addressFull" class="form-control" rows="2"></textarea>
                                        </div>
                                        <div class="col-12">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-save me-1"></i>Adresi Kaydet
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <!-- Payment Methods -->
                        <div class="card border-0 shadow-sm mb-4">
                            <div class="card-header bg-white">
                                <h6 class="mb-0"><i class="fas fa-credit-card text-primary me-2"></i>Ödeme Yöntemleri
                                </h6>
                            </div>
                            <div class="card-body">
                                <form id="paymentForm">
                                    <div class="d-flex flex-wrap gap-3">
                                        <div class="form-check">
                                            <input type="checkbox" class="form-check-input" id="payCash" value="cash">
                                            <label class="form-check-label" for="payCash">
                                                <i class="fas fa-money-bill me-1"></i>Nakit
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input type="checkbox" class="form-check-input" id="payCard" value="card">
                                            <label class="form-check-label" for="payCard">
                                                <i class="fas fa-credit-card me-1"></i>Kredi Kartı
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input type="checkbox" class="form-check-input" id="payTransfer"
                                                value="transfer">
                                            <label class="form-check-label" for="payTransfer">
                                                <i class="fas fa-university me-1"></i>Havale/EFT
                                            </label>
                                        </div>
                                    </div>
                                    <button type="submit" class="btn btn-primary mt-3">
                                        <i class="fas fa-save me-1"></i>Kaydet
                                    </button>
                                </form>
                            </div>
                        </div>

                        <!-- Loyalty Program -->
                        <div class="card border-0 shadow-sm mb-4">
                            <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                <h6 class="mb-0"><i class="fas fa-star text-primary me-2"></i>Sadakat Programı</h6>
                                <div class="form-check form-switch">
                                    <input type="checkbox" class="form-check-input" id="loyaltyEnabled">
                                </div>
                            </div>
                            <div class="card-body" id="loyaltySettings" style="display: none;">
                                <form id="loyaltyForm">
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Kazanma Oranı (%)</label>
                                            <input type="number" id="loyaltyEarnRate" class="form-control" min="1"
                                                max="50" value="10">
                                            <small class="text-muted">Müşteri sipariş tutarının bu kadarını puan olarak
                                                kazanır</small>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Min. Sipariş Tutarı (₺)</label>
                                            <input type="number" id="loyaltyMinOrder" class="form-control" min="0"
                                                value="0">
                                            <small class="text-muted">Puanların kullanılabileceği minimum tutar</small>
                                        </div>
                                        <div class="col-12">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-save me-1"></i>Kaydet
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <!-- Danger Zone -->
                        <div class="card border-danger">
                            <div class="card-header bg-danger text-white">
                                <h6 class="mb-0"><i class="fas fa-exclamation-triangle me-2"></i>Tehlikeli Bölge</h6>
                            </div>
                            <div class="card-body">
                                <p class="text-muted small">Bu işlemler geri alınamaz. Dikkatli olun.</p>
                                <button class="btn btn-outline-danger" id="deleteAccountBtn">
                                    <i class="fas fa-trash me-1"></i>Hesabı Sil
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="../assets/js/turkiye-api.js"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged, deleteUser } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, query, where, doc, updateDoc, deleteDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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

        let addressSelector;
        let currentFirm = null;

        // Initialize Address Selector
        addressSelector = new AddressSelector({
            provinceId: 'addressCity',
            districtId: 'addressDistrict',
            neighborhoodId: 'addressNeighborhood',
            fullAddressId: 'addressFull'
        });

        // Find Location Button Logic
        const findLocationBtn = document.getElementById('findLocationBtn');
        if (findLocationBtn) {
            findLocationBtn.addEventListener('click', () => {
                const originalContent = '<i class="fas fa-location-arrow me-1"></i> Konumumu Bul';
                findLocationBtn.disabled = true;

                addressSelector.autoFillFromLocation((status, message) => {
                    if (status === 'loading') {
                        findLocationBtn.innerHTML = `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> ${message}`;
                    } else if (status === 'success') {
                        findLocationBtn.innerHTML = `<i class="fas fa-check"></i> Veriler Getirildi`;
                        findLocationBtn.className = 'btn btn-sm btn-success';
                        setTimeout(() => {
                            findLocationBtn.innerHTML = originalContent;
                            findLocationBtn.disabled = false;
                            findLocationBtn.className = 'btn btn-sm btn-outline-primary';
                        }, 2000);
                    } else {
                        findLocationBtn.innerHTML = `<i class="fas fa-exclamation-circle"></i> Hata`;
                        findLocationBtn.className = 'btn btn-sm btn-danger';
                        alert(message);
                        setTimeout(() => {
                            findLocationBtn.innerHTML = originalContent;
                            findLocationBtn.disabled = false;
                            findLocationBtn.className = 'btn btn-sm btn-outline-primary';
                        }, 3000);
                    }
                });
            });
        }

        onAuthStateChanged(auth, async (user) => {
            if (!user) {
                window.location.href = 'login.php';
                return;
            }

            currentFirm = await getFirmData(user.uid);
            if (!currentFirm) {
                window.location.href = 'login.php';
                return;
            }

            document.getElementById('authCheck').classList.add('d-none');
            document.getElementById('mainLayout').style.display = 'block';
            document.getElementById('firmNameSidebar').textContent = currentFirm.name;
            document.getElementById('smsBalanceSidebar').textContent = (currentFirm.smsBalance || 0) + ' SMS';

            await loadProfile();
            setupForms();
        });

        async function getFirmData(uid) {
            const firmsRef = collection(db, 'firms');
            const q = query(firmsRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);
            if (snapshot.empty) return null;
            return { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
        }

        async function loadProfile() {
            const firm = currentFirm;

            // Profile card
            document.getElementById('firmNameDisplay').textContent = firm.name;
            const addr = firm.address || {};
            document.getElementById('firmAddressDisplay').textContent = `${addr.district || ''}, ${addr.city || ''}`;
            document.getElementById('ratingDisplay').textContent = (firm.rating || 0).toFixed(1);
            document.getElementById('reviewCountDisplay').textContent = firm.reviewCount || 0;
            document.getElementById('smsBalanceDisplay').textContent = (firm.smsBalance || 0) + ' SMS';

            const createdAt = firm.createdAt?.toDate ? firm.createdAt.toDate() : new Date(firm.createdAt);
            document.getElementById('createdAtDisplay').textContent = formatDate(createdAt);

            // Load order count
            const ordersRef = collection(db, 'orders');
            const ordersQ = query(ordersRef, where('firmId', '==', firm.id));
            const ordersSnapshot = await getDocs(ordersQ);
            document.getElementById('totalOrdersDisplay').textContent = ordersSnapshot.size;

            // Basic info form
            document.getElementById('firmName').value = firm.name || '';
            document.getElementById('firmPhone').value = firm.phone || '';
            document.getElementById('firmWhatsapp').value = firm.whatsapp || '';

            // Address form
            if (addr.city) {
                const citySelect = document.getElementById('addressCity');
                // Wait for provinces to load
                let attempts = 0;
                while (citySelect.options.length <= 1 && attempts < 20) {
                    await new Promise(r => setTimeout(r, 100));
                    attempts++;
                }

                if (await addressSelector.selectOptionByName(citySelect, addr.city)) {
                    await addressSelector.loadDistricts();

                    if (addr.district) {
                        if (await addressSelector.selectOptionByName(document.getElementById('addressDistrict'), addr.district)) {
                            await addressSelector.loadNeighborhoods();

                            if (addr.neighborhood) {
                                await addressSelector.selectOptionByName(document.getElementById('addressNeighborhood'), addr.neighborhood);
                            }
                        }
                    }
                }
            }
            document.getElementById('addressFull').value = addr.fullAddress || '';

            // Payment methods
            const payments = firm.paymentMethods || [];
            document.getElementById('payCash').checked = payments.includes('cash');
            document.getElementById('payCard').checked = payments.includes('card');
            document.getElementById('payTransfer').checked = payments.includes('transfer');

            // Loyalty
            const loyalty = firm.loyaltyConfig || {};
            document.getElementById('loyaltyEnabled').checked = loyalty.isEnabled || false;
            document.getElementById('loyaltySettings').style.display = loyalty.isEnabled ? 'block' : 'none';
            document.getElementById('loyaltyEarnRate').value = (loyalty.earnRate || 0.1) * 100;
            document.getElementById('loyaltyMinOrder').value = loyalty.minOrderAmountForUsage || 0;

            // Logo
            const logoContainer = document.getElementById('logoPreview');
            // Add input if not exists
            if (!document.getElementById('logoInput')) {
                const input = document.createElement('input');
                input.type = 'file';
                input.id = 'logoInput';
                input.accept = 'image/*';
                input.style.display = 'none';
                document.body.appendChild(input);

                // Click trigger
                logoContainer.style.cursor = 'pointer';
                logoContainer.title = 'Logoyu değiştirmek için tıklayın';
                logoContainer.addEventListener('click', () => input.click());

                // Change handler
                input.addEventListener('change', async (e) => {
                    const file = e.target.files[0];
                    if (!file) return;

                    // Show loading
                    const originalContent = logoContainer.innerHTML;
                    logoContainer.innerHTML = '<div class="spinner-border text-primary"></div>';

                    try {

                        // 1. Get Token
                        const token = await auth.currentUser.getIdToken();

                        // 2. Upload to Local Server
                        const formData = new FormData();
                        formData.append('file', file);
                        formData.append('type', 'logo');
                        // Use firm name for SEO friendly filename
                        const cleanName = firm.name.toLowerCase().replace(/[^a-z0-9]/g, '-');
                        formData.append('filename', cleanName + '-' + Math.random().toString(36).substr(2, 5));

                        const res = await fetch('../api/upload-media.php', {
                            method: 'POST',
                            headers: {
                                'Authorization': 'Bearer ' + token
                            },
                            body: formData
                        });

                        const result = await res.json();
                        if (!result.success) throw new Error(result.error);

                        // 2. Save path to DB
                        // Note: We save the relative path: assets/img/logo/...
                        // The web app needs to handle displaying this. 
                        // For firm panel (inside firm/), path needs ../ prefix
                        await updateDoc(doc(db, 'firms', currentFirm.id), {
                            logo: result.path
                        });

                        // 3. Update UI
                        // result.path is "assets/img/logo/..."
                        // We are in "firm/", so we need "../assets/..."
                        const info = "Mobilde görünmesi için app güncellemesi gerekebilir.";
                        logoContainer.innerHTML = `
                            <img src="../${result.path}" alt="Logo" class="rounded-circle" 
                                 style="width: 120px; height: 120px; object-fit: cover;">
                        `;
                        alert('Logo güncellendi!');

                    } catch (error) {
                        console.error(error);
                        alert('Yükleme başarısız: ' + error.message);
                        logoContainer.innerHTML = originalContent;
                    }
                });
            }

            if (firm.logo) {
                // Check if it's a legacy Firebase URL or new Local Path
                let src = firm.logo;
                if (!src.startsWith('http')) {
                    src = '../' + src;
                }
                logoContainer.innerHTML = `
            <img src="${src}" alt="Logo" class="rounded-circle" 
                 style="width: 120px; height: 120px; object-fit: cover;">
        `;
            }
        }

        function setupForms() {
            // Basic info
            document.getElementById('basicInfoForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                await saveField({
                    name: document.getElementById('firmName').value.trim(),
                    phone: document.getElementById('firmPhone').value.trim(),
                    whatsapp: document.getElementById('firmWhatsapp').value.trim() || null
                });
            });

            // Address
            document.getElementById('addressForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                await saveField({
                    address: {
                        city: document.getElementById('addressCity').value,
                        district: document.getElementById('addressDistrict').value.trim(),
                        neighborhood: document.getElementById('addressNeighborhood').value.trim(),
                        fullAddress: document.getElementById('addressFull').value.trim()
                    }
                });
            });

            // Payment methods
            document.getElementById('paymentForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                const methods = [];
                if (document.getElementById('payCash').checked) methods.push('cash');
                if (document.getElementById('payCard').checked) methods.push('card');
                if (document.getElementById('payTransfer').checked) methods.push('transfer');

                if (methods.length === 0) {
                    alert('En az bir ödeme yöntemi seçmelisiniz.');
                    return;
                }

                await saveField({ paymentMethods: methods });
            });

            // Loyalty toggle
            document.getElementById('loyaltyEnabled').addEventListener('change', (e) => {
                document.getElementById('loyaltySettings').style.display = e.target.checked ? 'block' : 'none';

                if (!e.target.checked) {
                    saveField({ 'loyaltyConfig.isEnabled': false });
                }
            });

            // Loyalty form
            document.getElementById('loyaltyForm').addEventListener('submit', async (e) => {
                e.preventDefault();
                await saveField({
                    loyaltyConfig: {
                        isEnabled: true,
                        earnRate: parseFloat(document.getElementById('loyaltyEarnRate').value) / 100,
                        minOrderAmountForUsage: parseFloat(document.getElementById('loyaltyMinOrder').value) || 0
                    }
                });
            });

            // Delete account
            document.getElementById('deleteAccountBtn').addEventListener('click', async () => {
                if (!confirm('Hesabınızı silmek istediğinize emin misiniz?\n\nBu işlem GERİ ALINAMAZ!')) return;
                if (!confirm('GERÇEKTEN EMİN MİSİNİZ?')) return;

                try {
                    // Delete firm document
                    await deleteDoc(doc(db, 'firms', currentFirm.id));

                    // Delete user document
                    const usersRef = collection(db, 'users');
                    const q = query(usersRef, where('uid', '==', auth.currentUser.uid));
                    const snapshot = await getDocs(q);
                    if (!snapshot.empty) {
                        await deleteDoc(doc(db, 'users', snapshot.docs[0].id));
                    }

                    // Delete auth user
                    await deleteUser(auth.currentUser);

                    alert('Hesabınız silindi.');
                    window.location.href = 'login.php';

                } catch (error) {
                    alert('Hata: ' + error.message);
                }
            });
        }

        async function saveField(data) {
            try {
                await updateDoc(doc(db, 'firms', currentFirm.id), data);

                // Update local data
                Object.assign(currentFirm, data);

                alert('Kaydedildi!');
            } catch (error) {
                alert('Hata: ' + error.message);
            }
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