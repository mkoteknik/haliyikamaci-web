<?php
/**
 * Halı Yıkamacı - Müşteri Profili
 */

require_once '../config/app.php';
$pageTitle = 'Profilim';
require_once '../includes/header.php';
?>

<!-- Auth Check -->
<div id="authCheck" class="py-5 text-center" style="display: none;">
    <i class="fas fa-lock fa-4x text-muted mb-3"></i>
    <h4>Giriş Yapmanız Gerekiyor</h4>
    <p class="text-muted">Profilinizi görmek için lütfen giriş yapın.</p>
    <a href="login.php?redirect=profile.php" class="btn btn-primary btn-lg">
        <i class="fas fa-sign-in-alt me-2"></i>Giriş Yap
    </a>
</div>

<!-- Main Content -->
<div id="mainContent" style="display: none;">
    <!-- Page Header -->
    <section class="bg-gradient-primary text-white py-4">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <h1 class="fw-bold mb-0">
                    <i class="fas fa-user me-2"></i>Profilim
                </h1>
                <button id="profileLogoutBtn" class="btn btn-outline-light">
                    <i class="fas fa-sign-out-alt me-2"></i>Çıkış Yap
                </button>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="row g-4">
                <!-- Left Column - Profile Info -->
                <div class="col-lg-4">
                    <!-- Profile Card -->
                    <div class="card mb-4">
                        <div class="card-body text-center">
                            <div class="profile-avatar bg-gradient-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3"
                                style="width: 100px; height: 100px; font-size: 2rem;">
                                <span id="avatarInitials">?</span>
                            </div>
                            <h4 id="profileName" class="fw-bold">-</h4>
                            <p id="profilePhone" class="text-muted">-</p>
                            <div class="d-flex justify-content-center gap-3 mt-3">
                                <div class="text-center">
                                    <h5 class="mb-0 text-primary" id="orderCount">0</h5>
                                    <small class="text-muted">Sipariş</small>
                                </div>
                                <div class="text-center">
                                    <h5 class="mb-0 text-warning" id="loyaltyPoints">0</h5>
                                    <small class="text-muted">Puan</small>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Quick Links -->
                    <div class="card">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-link text-primary me-2"></i>Hızlı Erişim
                            </h5>
                        </div>
                        <div class="list-group list-group-flush">
                            <a href="my-orders.php" class="list-group-item list-group-item-action">
                                <i class="fas fa-box me-2 text-primary"></i>Siparişlerim
                            </a>
                            <a href="<?php echo SITE_URL; ?>/firmalar" class="list-group-item list-group-item-action">
                                <i class="fas fa-store me-2 text-primary"></i>Firmalar
                            </a>
                            <a href="campaigns.php" class="list-group-item list-group-item-action">
                                <i class="fas fa-tags me-2 text-primary"></i>Kampanyalar
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Right Column - Settings -->
                <div class="col-lg-8">
                    <!-- Personal Info -->
                    <div class="card mb-4">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="fas fa-user-edit text-primary me-2"></i>Kişisel Bilgiler
                            </h5>
                            <button class="btn btn-sm btn-outline-primary" data-bs-toggle="collapse"
                                data-bs-target="#editPersonalInfo">
                                <i class="fas fa-edit"></i>
                            </button>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label text-muted small">Ad</label>
                                    <p id="displayName" class="fw-bold mb-0">-</p>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label text-muted small">Soyad</label>
                                    <p id="displaySurname" class="fw-bold mb-0">-</p>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label text-muted small">Telefon</label>
                                    <p id="displayPhone" class="fw-bold mb-0">-</p>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label text-muted small">Kayıt Tarihi</label>
                                    <p id="displayCreatedAt" class="fw-bold mb-0">-</p>
                                </div>
                            </div>

                            <!-- Edit Form -->
                            <div class="collapse mt-4" id="editPersonalInfo">
                                <hr>
                                <form id="personalInfoForm">
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label">Ad</label>
                                            <input type="text" id="editName" class="form-control" required>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label">Soyad</label>
                                            <input type="text" id="editSurname" class="form-control" required>
                                        </div>
                                        <div class="col-12">
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-save me-2"></i>Kaydet
                                            </button>
                                        </div>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Addresses -->
                    <div class="card mb-4">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="fas fa-map-marker-alt text-primary me-2"></i>Adreslerim
                            </h5>
                            <button class="btn btn-sm btn-primary" data-bs-toggle="modal"
                                data-bs-target="#addAddressModal">
                                <i class="fas fa-plus me-1"></i>Yeni Adres
                            </button>
                        </div>
                        <div class="card-body">
                            <div id="addressesList">
                                <p class="text-muted text-center py-3">Adres yükleniyor...</p>
                            </div>
                        </div>
                    </div>

                    <!-- Notification Settings -->
                    <div class="card">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-bell text-primary me-2"></i>Bildirim Ayarları
                            </h5>
                        </div>
                        <div class="card-body">
                            <form id="notificationForm">
                                <div class="form-check form-switch mb-3">
                                    <input type="checkbox" class="form-check-input" id="notifyOrders" checked>
                                    <label class="form-check-label" for="notifyOrders">
                                        <strong>Sipariş Bildirimleri</strong>
                                        <br><small class="text-muted">Sipariş durumu değişikliklerinden haberdar
                                            olun</small>
                                    </label>
                                </div>
                                <div class="form-check form-switch mb-3">
                                    <input type="checkbox" class="form-check-input" id="notifyCampaigns" checked>
                                    <label class="form-check-label" for="notifyCampaigns">
                                        <strong>Kampanya Bildirimleri</strong>
                                        <br><small class="text-muted">Yeni kampanyalardan haberdar olun</small>
                                    </label>
                                </div>
                                <div class="form-check form-switch">
                                    <input type="checkbox" class="form-check-input" id="notifyNews">
                                    <label class="form-check-label" for="notifyNews">
                                        <strong>Haberler ve Duyurular</strong>
                                        <br><small class="text-muted">Platform güncellemelerinden haberdar olun</small>
                                    </label>
                                </div>
                                <button type="submit" class="btn btn-primary mt-3">
                                    <i class="fas fa-save me-2"></i>Ayarları Kaydet
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>

<!-- Add Address Modal -->
<div class="modal fade" id="addAddressModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Yeni Adres Ekle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="addAddressForm">
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Adres Başlığı</label>
                        <input type="text" id="addressTitle" class="form-control" placeholder="Örn: Ev, İş" required>
                    </div>
                    <div class="mb-3 d-flex justify-content-end">
                        <button type="button" class="btn btn-sm btn-outline-primary" id="findLocationBtn">
                            <i class="fas fa-location-arrow me-1"></i> Konumumu Bul
                        </button>
                    </div>
                    <div class="row g-3 mb-3">
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
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Açık Adres</label>
                        <textarea id="addressFull" class="form-control" rows="2" required
                            placeholder="Sokak, bina no, daire no"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="fas fa-plus me-2"></i>Ekle
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="../assets/js/turkiye-api.js"></script>

<script type="module">
    let customerDocId = null;
    let customerData = null;
    let addressSelector = null;

    window.addEventListener('firebaseReady', function () {
        const auth = window.firebaseAuth;
        const db = window.firebaseDb;
        const { collection, getDocs, query, where, doc, getDoc } = window.firebaseModules;

        // Initialize Address Selector
        addressSelector = new AddressSelector({
            provinceId: 'addressCity',
            districtId: 'addressDistrict',
            neighborhoodId: 'addressNeighborhood',
            fullAddressId: 'addressFull'
        });

        // Find Location Button
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

        auth.onAuthStateChanged(async (user) => {
            if (user) {
                // STRICT RBAC: Check if user is customer
                try {
                    const userDocRef = doc(db, 'users', user.uid);
                    const userDocSnap = await getDoc(userDocRef);

                    if (userDocSnap.exists()) {
                        const userData = userDocSnap.data();
                        if (userData.userType !== 'customer' && userData.userType !== 'admin') {
                            console.warn('Redirecting Firm user to Firm Panel');
                            window.location.href = '../firm/index.php';
                            return;
                        }
                    }
                } catch (e) {
                    console.error('RBAC Error:', e);
                }

                document.getElementById('authCheck').style.display = 'none';
                document.getElementById('mainContent').style.display = 'block';
                await loadProfile(db, { collection, getDocs, query, where }, user.uid);
                setupForms(db, user.uid);
                setupLogout(auth);
            } else {
                document.getElementById('authCheck').style.display = 'block';
                document.getElementById('mainContent').style.display = 'none';
            }
        });
    });

    async function loadProfile(db, { collection, getDocs, query, where }, uid) {
        try {
            // Load customer data
            const customersRef = collection(db, 'customers');
            const q = query(customersRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);

            if (snapshot.empty) {
                console.error('Müşteri bulunamadı');
                return;
            }

            customerDocId = snapshot.docs[0].id;
            customerData = snapshot.docs[0].data();

            renderProfile(customerData);

            // Load order count
            const ordersRef = collection(db, 'orders');
            const ordersQ = query(ordersRef, where('customerId', '==', uid));
            const ordersSnapshot = await getDocs(ordersQ);
            document.getElementById('orderCount').textContent = ordersSnapshot.size;

        } catch (error) {
            console.error('Profil yüklenirken hata:', error);
        }
    }

    function renderProfile(data) {
        // Avatar
        const initials = ((data.name?.[0] || '') + (data.surname?.[0] || '')).toUpperCase();
        document.getElementById('avatarInitials').textContent = initials || '?';

        // Profile card
        const fullName = data.name + (data.surname ? ' ' + data.surname : '');
        document.getElementById('profileName').textContent = fullName;
        document.getElementById('profilePhone').textContent = data.phone;
        document.getElementById('loyaltyPoints').textContent = data.loyaltyPoints || 0;

        // Personal info
        document.getElementById('displayName').textContent = data.name;
        document.getElementById('displaySurname').textContent = data.surname || '';
        document.getElementById('displayPhone').textContent = data.phone;

        const createdAt = data.createdAt?.toDate ? data.createdAt.toDate() : new Date(data.createdAt);
        document.getElementById('displayCreatedAt').textContent = formatDate(createdAt);

        // Edit form values
        document.getElementById('editName').value = data.name;
        document.getElementById('editSurname').value = data.surname || '';

        // Addresses
        renderAddresses(data);

        // Notification settings
        const settings = data.notificationSettings || {};
        document.getElementById('notifyOrders').checked = settings.orders !== false;
        document.getElementById('notifyCampaigns').checked = settings.campaigns !== false;
        document.getElementById('notifyNews').checked = settings.news === true;
    }

    function renderAddresses(data) {
        const container = document.getElementById('addressesList');
        const addresses = data.savedAddresses || [];
        const currentAddress = data.address;

        let html = '';

        // Current/Primary address
        if (currentAddress && currentAddress.fullAddress) {
            html += `
            <div class="border rounded p-3 mb-3">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <span class="badge bg-primary mb-2">Aktif Adres</span>
                        <p class="mb-0"><strong>${currentAddress.district}, ${currentAddress.city}</strong></p>
                        <p class="text-muted mb-0">${currentAddress.fullAddress}</p>
                    </div>
                </div>
            </div>
        `;
        }

        // Saved addresses
        addresses.forEach((addr, i) => {
            html += `
            <div class="border rounded p-3 mb-3">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <span class="badge bg-light text-dark mb-2">${addr.title || 'Adres ' + (i + 1)}</span>
                        <p class="mb-0"><strong>${addr.district}, ${addr.city}</strong></p>
                        <p class="text-muted mb-0">${addr.fullAddress}</p>
                    </div>
                    <button class="btn btn-sm btn-outline-danger delete-address" data-index="${i}">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
        `;
        });

        if (!html) {
            html = '<p class="text-muted text-center py-3">Henüz kayıtlı adres yok.</p>';
        }

        container.innerHTML = html;

        // Setup delete buttons
        document.querySelectorAll('.delete-address').forEach(btn => {
            btn.addEventListener('click', async () => {
                if (confirm('Bu adresi silmek istediğinize emin misiniz?')) {
                    await deleteAddress(parseInt(btn.dataset.index));
                }
            });
        });
    }

    async function setupForms(db, uid) {
        const { doc, updateDoc, arrayUnion, arrayRemove } = await import('https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js');

        // Personal info form
        document.getElementById('personalInfoForm').addEventListener('submit', async (e) => {
            e.preventDefault();

            const name = document.getElementById('editName').value.trim();
            const surname = document.getElementById('editSurname').value.trim();

            try {
                await updateDoc(doc(db, 'customers', customerDocId), { name, surname });

                customerData.name = name;
                customerData.surname = surname;
                renderProfile(customerData);

                // Close collapse
                const collapse = bootstrap.Collapse.getInstance(document.getElementById('editPersonalInfo'));
                if (collapse) collapse.hide();

                alert('Bilgileriniz güncellendi!');
            } catch (error) {
                console.error('Güncelleme hatası:', error);
                alert('Güncelleme başarısız: ' + error.message);
            }
        });

        // Add address form
        document.getElementById('addAddressForm').addEventListener('submit', async (e) => {
            e.preventDefault();

            if (!addressSelector.isValid()) {
                alert('Lütfen İl, İlçe ve Mahalle seçiniz.');
                return;
            }

            const address = addressSelector.getAddress();

            const newAddress = {
                title: document.getElementById('addressTitle').value.trim(),
                city: address.provinceName,
                district: address.districtName,
                neighborhood: address.neighborhoodName,
                fullAddress: address.fullAddress || '',
                provinceId: parseInt(address.provinceId),
                districtId: parseInt(address.districtId),
                neighborhoodId: parseInt(address.neighborhoodId)
            };

            try {
                await updateDoc(doc(db, 'customers', customerDocId), {
                    savedAddresses: arrayUnion(newAddress)
                });

                customerData.savedAddresses = customerData.savedAddresses || [];
                customerData.savedAddresses.push(newAddress);
                renderAddresses(customerData);

                // Close modal and reset form
                bootstrap.Modal.getInstance(document.getElementById('addAddressModal')).hide();
                document.getElementById('addAddressForm').reset();

                alert('Adres eklendi!');
            } catch (error) {
                console.error('Adres ekleme hatası:', error);
                alert('Adres eklenemedi: ' + error.message);
            }
        });

        // Notification settings form
        document.getElementById('notificationForm').addEventListener('submit', async (e) => {
            e.preventDefault();

            const settings = {
                orders: document.getElementById('notifyOrders').checked,
                campaigns: document.getElementById('notifyCampaigns').checked,
                news: document.getElementById('notifyNews').checked
            };

            try {
                await updateDoc(doc(db, 'customers', customerDocId), { notificationSettings: settings });
                customerData.notificationSettings = settings;
                alert('Ayarlar kaydedildi!');
            } catch (error) {
                console.error('Ayar güncelleme hatası:', error);
                alert('Ayarlar kaydedilemedi: ' + error.message);
            }
        });

        // Delete address function
        window.deleteAddress = async function (index) {
            try {
                const addressToRemove = customerData.savedAddresses[index];
                await updateDoc(doc(db, 'customers', customerDocId), {
                    savedAddresses: arrayRemove(addressToRemove)
                });

                customerData.savedAddresses.splice(index, 1);
                renderAddresses(customerData);
                alert('Adres silindi!');
            } catch (error) {
                console.error('Adres silme hatası:', error);
                alert('Adres silinemedi: ' + error.message);
            }
        };
    }

    function setupLogout(auth) {
        document.getElementById('profileLogoutBtn').addEventListener('click', async () => {
            if (confirm('Çıkış yapmak istediğinize emin misiniz?')) {
                await auth.signOut();
                window.location.href = '../';
            }
        });
    }

    function formatDate(date) {
        return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(date);
    }
</script>

<?php require_once '../includes/footer.php'; ?>