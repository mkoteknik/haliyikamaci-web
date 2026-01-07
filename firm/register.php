<?php
/**
 * Halı Yıkamacı - Firma Kayıt (Telefon + Şifre)
 * Dynamic Address with TurkiyeAPI
 */

require_once '../config/app.php';
$pageTitle = 'Firma Kaydı';
require_once '../includes/header.php';
?>

<section class="section">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-7">
                <div class="card shadow-sm">
                    <div class="card-body p-4 p-md-5">
                        <div class="text-center mb-4">
                            <div class="bg-gradient-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3"
                                style="width: 80px; height: 80px;">
                                <i class="fas fa-store fa-2x"></i>
                            </div>
                            <h3 class="fw-bold">Firma Kaydı</h3>
                            <p class="text-muted">Halı yıkama firmanızı kaydedin</p>
                        </div>

                        <!-- Registration Form -->
                        <form id="registerForm">
                            <!-- Firma Bilgileri -->
                            <h6 class="fw-bold text-primary mb-3"><i class="fas fa-building me-2"></i>Firma Bilgileri
                            </h6>
                            <div class="row">
                                <div class="col-12 mb-3">
                                    <label class="form-label fw-bold">Firma Adı *</label>
                                    <input type="text" id="firmName" class="form-control"
                                        placeholder="Örn: Temiz Halı Yıkama" required>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-bold">Telefon Numarası *</label>
                                    <div class="input-group">
                                        <span class="input-group-text">+90</span>
                                        <input type="tel" id="phoneNumber" class="form-control"
                                            placeholder="5XX XXX XX XX" maxlength="10" required pattern="[0-9]{10}">
                                    </div>
                                    <small class="text-muted">Başında 0 olmadan girin</small>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-bold">WhatsApp (Opsiyonel)</label>
                                    <div class="input-group">
                                        <span class="input-group-text">+90</span>
                                        <input type="tel" id="whatsapp" class="form-control" placeholder="5XX XXX XX XX"
                                            maxlength="10">
                                    </div>
                                </div>
                            </div>

                            <hr class="my-4">

                            <!-- Vergi Bilgileri -->
                            <h6 class="fw-bold text-primary mb-3"><i class="fas fa-file-invoice me-2"></i>Vergi
                                Bilgileri</h6>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-bold">Vergi Dairesi *</label>
                                    <input type="text" id="taxOffice" class="form-control"
                                        placeholder="Örn: Kadıköy Vergi Dairesi" required>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-bold">Vergi Numarası *</label>
                                    <input type="text" id="taxNumber" class="form-control"
                                        placeholder="10 haneli vergi no" maxlength="11" required>
                                </div>
                            </div>

                            <hr class="my-4">

                            <!-- Adres Bilgileri -->
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h6 class="fw-bold text-primary mb-0"><i class="fas fa-map-marker-alt me-2"></i>Adres
                                    Bilgileri</h6>
                                <button type="button" class="btn btn-sm btn-outline-primary" id="findLocationBtn">
                                    <i class="fas fa-location-arrow me-1"></i> Konumumu Bul
                                </button>
                            </div>
                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label class="form-label fw-bold">İl *</label>
                                    <select id="province" class="form-select" required>
                                        <option value="">Yükleniyor...</option>
                                    </select>
                                </div>

                                <div class="col-md-4 mb-3">
                                    <label class="form-label fw-bold">İlçe *</label>
                                    <select id="district" class="form-select" required disabled>
                                        <option value="">Önce il seçiniz...</option>
                                    </select>
                                </div>

                                <div class="col-md-4 mb-3">
                                    <label class="form-label fw-bold">Mahalle *</label>
                                    <select id="neighborhood" class="form-select" required disabled>
                                        <option value="">Önce ilçe seçiniz...</option>
                                    </select>
                                </div>

                                <div class="col-12 mb-3">
                                    <label class="form-label fw-bold">Açık Adres</label>
                                    <textarea id="fullAddress" class="form-control" rows="2"
                                        placeholder="Sokak, Cadde, Bina No, Daire No..."></textarea>
                                </div>
                            </div>

                            <hr class="my-4">

                            <!-- Şifre -->
                            <h6 class="fw-bold text-primary mb-3"><i class="fas fa-lock me-2"></i>Şifre Belirleyin</h6>
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-bold">Şifre *</label>
                                    <div class="input-group">
                                        <input type="password" id="password" class="form-control"
                                            placeholder="En az 6 karakter" required minlength="6">
                                        <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="col-md-6 mb-3">
                                    <label class="form-label fw-bold">Şifre Tekrar *</label>
                                    <input type="password" id="passwordConfirm" class="form-control"
                                        placeholder="Şifrenizi tekrar girin" required>
                                </div>
                            </div>

                            <div id="errorMessage" class="alert alert-danger" style="display: none;"></div>
                            <div id="successMessage" class="alert alert-success" style="display: none;"></div>

                            <button type="submit" id="registerBtn" class="btn btn-primary btn-lg w-100 mt-3">
                                <i class="fas fa-user-plus me-2"></i>Kayıt Ol
                            </button>

                            <p class="text-muted text-center mt-3 small">
                                <i class="fas fa-info-circle me-1"></i>
                                Kayıt sonrası admin onayı gereklidir.
                            </p>
                        </form>

                        <!-- Loading State -->
                        <div id="loadingState" style="display: none;" class="text-center py-4">
                            <div class="spinner"></div>
                            <p class="text-muted mt-3">Kayıt oluşturuluyor...</p>
                        </div>

                        <hr class="my-4">

                        <p class="text-center text-muted mb-0">
                            Zaten firma hesabınız var mı?
                            <a href="login.php" class="text-primary fw-bold">Giriş Yapın</a>
                        </p>
                    </div>
                </div>

                <div class="text-center mt-4">
                    <p class="text-muted">
                        Müşteri misiniz?
                        <a href="../customer/login.php" class="fw-bold text-primary">Müşteri Girişi</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- TurkiyeAPI Script -->
<script src="../assets/js/turkiye-api.js"></script>

<script type="module">
    import { getAuth, createUserWithEmailAndPassword } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, doc, setDoc, collection, query, where, getDocs, Timestamp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

    let addressSelector;

    window.addEventListener('firebaseReady', function () {
        const auth = window.firebaseAuth;
        const db = window.firebaseDb;

        // Initialize Address Selector
        addressSelector = new AddressSelector({
            provinceId: 'province',
            districtId: 'district',
            neighborhoodId: 'neighborhood',
            fullAddressId: 'fullAddress'
        });

        // Find Location Button
        document.getElementById('findLocationBtn').addEventListener('click', () => {
            const btn = document.getElementById('findLocationBtn');
            const originalContent = '<i class="fas fa-location-arrow me-1"></i> Konumumu Bul';
            btn.disabled = true;

            addressSelector.autoFillFromLocation((status, message) => {
                if (status === 'loading') {
                    btn.innerHTML = `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> ${message}`;
                } else if (status === 'success') {
                    btn.innerHTML = `<i class="fas fa-check"></i> Veriler Getirildi`;
                    btn.className = 'btn btn-sm btn-success';
                    setTimeout(() => {
                        btn.innerHTML = originalContent;
                        btn.disabled = false;
                        btn.className = 'btn btn-sm btn-outline-primary';
                    }, 2000);
                } else {
                    btn.innerHTML = `<i class="fas fa-exclamation-circle"></i> Hata`;
                    btn.className = 'btn btn-sm btn-danger';
                    alert(message);

                    setTimeout(() => {
                        btn.innerHTML = originalContent;
                        btn.disabled = false;
                        btn.className = 'btn btn-sm btn-outline-primary';
                    }, 3000);
                }
            });
        });

        // Toggle password visibility
        document.getElementById('togglePassword').addEventListener('click', function () {
            const input = document.getElementById('password');
            const icon = this.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
            }
        });

        // Registration form submit
        document.getElementById('registerForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleRegister(auth, db);
        });
    });

    async function handleRegister(auth, db) {
        const firmName = document.getElementById('firmName').value.trim();
        const phone = document.getElementById('phoneNumber').value.replace(/\D/g, '');
        const whatsapp = document.getElementById('whatsapp').value.replace(/\D/g, '');
        const taxOffice = document.getElementById('taxOffice').value.trim();
        const taxNumber = document.getElementById('taxNumber').value.replace(/\D/g, '');
        const password = document.getElementById('password').value;
        const passwordConfirm = document.getElementById('passwordConfirm').value;

        // Get address from selector
        const address = addressSelector.getAddress();

        // Validations
        if (!firmName || firmName.length < 3) {
            showError('Firma adı en az 3 karakter olmalıdır.');
            return;
        }

        if (phone.length !== 10) {
            showError('Lütfen geçerli bir telefon numarası girin (10 haneli).');
            return;
        }

        if (!taxOffice || taxOffice.length < 3) {
            showError('Lütfen geçerli bir vergi dairesi girin.');
            return;
        }

        if (!taxNumber || taxNumber.length < 10) {
            showError('Lütfen geçerli bir vergi numarası girin (10-11 haneli).');
            return;
        }

        if (!addressSelector.isValid()) {
            showError('Lütfen İl, İlçe ve Mahalle seçiniz.');
            return;
        }

        if (password.length < 6) {
            showError('Şifre en az 6 karakter olmalıdır.');
            return;
        }

        if (password !== passwordConfirm) {
            showError('Şifreler eşleşmiyor.');
            return;
        }

        showLoading(true);
        hideError();

        try {
            // Step 1: Check if phone already exists
            const usersRef = collection(db, 'users');
            const q = query(usersRef, where('phone', '==', phone));
            const snapshot = await getDocs(q);

            if (!snapshot.empty) {
                showLoading(false);
                showError('Bu telefon numarası zaten kayıtlı.');
                return;
            }

            // Step 2: Create Firebase Auth user with fake email
            const fakeEmail = phone + '@haliyikamaci.app';
            const userCredential = await createUserWithEmailAndPassword(auth, fakeEmail, password);
            const uid = userCredential.user.uid;

            // Step 3: Create user document
            await setDoc(doc(db, 'users', uid), {
                uid: uid,
                email: fakeEmail,
                phone: phone,
                userType: 'firm',
                isActive: true,
                createdAt: Timestamp.now()
            });

            // Step 4: Create firm document
            await setDoc(doc(db, 'firms', uid), {
                uid: uid,
                name: firmName,
                phone: phone,
                whatsapp: whatsapp || phone,
                address: {
                    city: address.provinceName,
                    district: address.districtName,
                    neighborhood: address.neighborhoodName,
                    fullAddress: address.fullAddress || '',
                    provinceId: parseInt(address.provinceId),
                    districtId: parseInt(address.districtId),
                    neighborhoodId: parseInt(address.neighborhoodId)
                },
                taxInfo: {
                    taxOffice: taxOffice,
                    taxNumber: taxNumber
                },
                isApproved: false,
                isActive: true,
                smsBalance: 0,
                rating: 0,
                reviewCount: 0,
                orderCount: 0,
                services: [],
                workingHours: {
                    monday: { open: '09:00', close: '18:00', isOpen: true },
                    tuesday: { open: '09:00', close: '18:00', isOpen: true },
                    wednesday: { open: '09:00', close: '18:00', isOpen: true },
                    thursday: { open: '09:00', close: '18:00', isOpen: true },
                    friday: { open: '09:00', close: '18:00', isOpen: true },
                    saturday: { open: '09:00', close: '18:00', isOpen: true },
                    sunday: { open: '09:00', close: '18:00', isOpen: false }
                },
                createdAt: Timestamp.now()
            });

            // Success!
            showLoading(false);
            showSuccess('Kayıt başarılı! Admin onayından sonra giriş yapabilirsiniz.');

            // Redirect to login after 2 seconds
            setTimeout(() => {
                window.location.href = 'login.php';
            }, 2500);

        } catch (error) {
            showLoading(false);
            console.error('Registration error:', error);

            if (error.code === 'auth/email-already-in-use') {
                showError('Bu telefon numarası zaten kayıtlı.');
            } else if (error.code === 'auth/weak-password') {
                showError('Şifre çok zayıf. En az 6 karakter kullanın.');
            } else {
                showError('Kayıt başarısız: ' + error.message);
            }
        }
    }

    function showLoading(show) {
        document.getElementById('registerForm').style.display = show ? 'none' : 'block';
        document.getElementById('loadingState').style.display = show ? 'block' : 'none';
    }

    function showError(message) {
        const el = document.getElementById('errorMessage');
        el.textContent = message;
        el.style.display = 'block';
        document.getElementById('successMessage').style.display = 'none';
        el.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }

    function showSuccess(message) {
        const el = document.getElementById('successMessage');
        el.textContent = message;
        el.style.display = 'block';
        document.getElementById('errorMessage').style.display = 'none';
    }

    function hideError() {
        document.getElementById('errorMessage').style.display = 'none';
    }
</script>

<?php require_once '../includes/footer.php'; ?>