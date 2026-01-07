<?php
/**
 * Halı Yıkamacı - Müşteri Girişi/Kayıt (Telefon + Şifre)
 * Dynamic Address with TurkiyeAPI
 */

require_once '../config/app.php';
$pageTitle = 'Müşteri Girişi';
require_once '../includes/header.php';
?>

<section class="section">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <div class="card shadow-sm">
                    <div class="card-body p-4 p-md-5">
                        <div class="text-center mb-4">
                            <div class="bg-gradient-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3"
                                style="width: 80px; height: 80px;">
                                <i class="fas fa-user fa-2x"></i>
                            </div>
                            <h3 class="fw-bold" id="pageTitle">Müşteri Girişi</h3>
                            <p class="text-muted" id="pageSubtitle">Telefon ve şifrenizle giriş yapın</p>
                        </div>

                        <!-- Login/Register Form -->
                        <form id="loginForm">
                            <!-- Name field (only for register) -->
                            <div class="mb-3" id="nameField" style="display: none;">
                                <label class="form-label fw-bold">Ad Soyad *</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="fas fa-user"></i></span>
                                    <input type="text" id="fullName" class="form-control"
                                        placeholder="Adınız Soyadınız">
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Telefon Numarası *</label>
                                <div class="input-group">
                                    <span class="input-group-text">+90</span>
                                    <input type="tel" id="phoneNumber" class="form-control" placeholder="5XX XXX XX XX"
                                        maxlength="10" required pattern="[0-9]{10}">
                                </div>
                                <small class="text-muted">Başında 0 olmadan girin</small>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Şifre *</label>
                                <div class="input-group">
                                    <input type="password" id="password" class="form-control"
                                        placeholder="Şifrenizi girin" required>
                                    <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <!-- Address fields (only for register) -->
                            <div id="addressFields" style="display: none;">
                                <hr class="my-4">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <h6 class="fw-bold text-primary mb-0"><i
                                            class="fas fa-map-marker-alt me-2"></i>Adres Bilgileri</h6>
                                    <button type="button" class="btn btn-sm btn-outline-primary" id="findLocationBtn">
                                        <i class="fas fa-location-arrow me-1"></i> Konumumu Bul
                                    </button>
                                </div>
                                <div class="row">
                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-bold">İl *</label>
                                        <select id="province" class="form-select">
                                            <option value="">Yükleniyor...</option>
                                        </select>
                                    </div>

                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-bold">İlçe *</label>
                                        <select id="district" class="form-select" disabled>
                                            <option value="">Önce il seçiniz...</option>
                                        </select>
                                    </div>

                                    <div class="col-md-4 mb-3">
                                        <label class="form-label fw-bold">Mahalle *</label>
                                        <select id="neighborhood" class="form-select" disabled>
                                            <option value="">Önce ilçe seçiniz...</option>
                                        </select>
                                    </div>

                                    <div class="col-12 mb-3">
                                        <label class="form-label fw-bold">Açık Adres</label>
                                        <textarea id="fullAddress" class="form-control" rows="2"
                                            placeholder="Sokak, Cadde, Bina No, Daire No..."></textarea>
                                    </div>
                                </div>
                            </div>

                            <div id="errorMessage" class="alert alert-danger" style="display: none;"></div>
                            <div id="successMessage" class="alert alert-success" style="display: none;"></div>

                            <button type="submit" id="loginBtn" class="btn btn-primary btn-lg w-100 mt-3">
                                <span id="btnText"><i class="fas fa-sign-in-alt me-2"></i>Giriş Yap</span>
                            </button>
                        </form>

                        <!-- Loading State -->
                        <div id="loadingState" style="display: none;">
                            <div class="text-center py-4 d-flex flex-column align-items-center justify-content-center">
                                <style>
                                    @keyframes pulse-custom {
                                        0% {
                                            transform: scale(0.95);
                                            opacity: 0.8;
                                        }

                                        50% {
                                            transform: scale(1.1);
                                            opacity: 1;
                                        }

                                        100% {
                                            transform: scale(0.95);
                                            opacity: 0.8;
                                        }
                                    }

                                    .loader-icon {
                                        animation: pulse-custom 1.5s infinite ease-in-out;
                                        border-radius: 20px;
                                        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
                                    }
                                </style>
                                <img src="../assets/img/loader.jpg" class="loader-icon mb-3" width="80"
                                    alt="Yükleniyor...">
                                <p class="text-muted mt-3" id="loadingText">İşlem yapılıyor...</p>
                            </div>
                        </div>

                        <hr class="my-4">

                        <p class="text-center text-muted mb-0">
                            <button type="button" class="btn btn-link text-primary fw-bold p-0" id="toggleMode">
                                Henüz hesabınız yok mu? Kayıt Olun
                            </button>
                        </p>
                        <p class="text-center mt-2 mb-0">
                            <a href="forgot-password.php" class="text-secondary">Şifremi Unuttum</a>
                        </p>
                    </div>
                </div>

                <div class="text-center mt-4">
                    <p class="text-muted">
                        Firma mısınız?
                        <a href="../firm/login.php" class="fw-bold text-primary">Firma Girişi</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- TurkiyeAPI Script -->
<script src="../assets/js/turkiye-api.js"></script>

<script type="module">
    import { getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, collection, query, where, getDocs, doc, setDoc, Timestamp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

    let isRegisterMode = false;
    let addressSelector = null;

    window.addEventListener('firebaseReady', function () {
        const auth = window.firebaseAuth;
        const db = window.firebaseDb;

        // Check if already logged in as customer
        onAuthStateChanged(auth, async (user) => {
            if (user) {
                const isCustomer = await checkIsCustomer(db, user.uid);
                if (isCustomer) {
                    window.location.href = 'my-orders.php';
                }
            }
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

        // Toggle mode
        document.getElementById('toggleMode').addEventListener('click', function () {
            isRegisterMode = !isRegisterMode;

            if (isRegisterMode) {
                document.getElementById('pageTitle').textContent = 'Müşteri Kaydı';
                document.getElementById('pageSubtitle').textContent = 'Yeni hesap oluşturun';
                document.getElementById('btnText').innerHTML = '<i class="fas fa-user-plus me-2"></i>Kayıt Ol';
                document.getElementById('nameField').style.display = 'block';
                document.getElementById('addressFields').style.display = 'block';
                this.textContent = 'Zaten hesabınız var mı? Giriş Yapın';

                // Initialize address selector if not already done
                if (!addressSelector) {
                    addressSelector = new AddressSelector({
                        provinceId: 'province',
                        districtId: 'district',
                        neighborhoodId: 'neighborhood',
                        fullAddressId: 'fullAddress'
                    });
                }
            } else {
                document.getElementById('pageTitle').textContent = 'Müşteri Girişi';
                document.getElementById('pageSubtitle').textContent = 'Telefon ve şifrenizle giriş yapın';
                document.getElementById('btnText').innerHTML = '<i class="fas fa-sign-in-alt me-2"></i>Giriş Yap';
                document.getElementById('nameField').style.display = 'none';
                document.getElementById('addressFields').style.display = 'none';
                this.textContent = 'Henüz hesabınız yok mu? Kayıt Olun';
            }

            hideError();
        });

        // Find Location Button
        document.getElementById('findLocationBtn').addEventListener('click', () => {
            // Ensure addressSelector is ready
            if (!addressSelector) {
                addressSelector = new AddressSelector({
                    provinceId: 'province',
                    districtId: 'district',
                    neighborhoodId: 'neighborhood',
                    fullAddressId: 'fullAddress'
                });
            }

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

        // Login/Register form submit
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();

            if (isRegisterMode) {
                await handleRegister(auth, db);
            } else {
                await handleLogin(auth, db);
            }
        });
    });

    async function handleLogin(auth, db) {
        const phone = document.getElementById('phoneNumber').value.replace(/\D/g, '');
        const password = document.getElementById('password').value;

        if (phone.length !== 10) {
            showError('Lütfen geçerli bir telefon numarası girin.');
            return;
        }

        if (!password) {
            showError('Lütfen şifrenizi girin.');
            return;
        }

        showLoading(true, 'Giriş yapılıyor...');
        hideError();

        try {
            // Check if phone is registered
            const usersRef = collection(db, 'users');
            const q = query(usersRef, where('phone', '==', phone));
            const snapshot = await getDocs(q);

            if (snapshot.empty) {
                showLoading(false);
                showError('Bu numara kayıtlı değil. Kayıt olun.');
                return;
            }

            const userData = snapshot.docs[0].data();

            if (userData.userType !== 'customer') {
                showLoading(false);
                showError('Bu numara Müşteri olarak kayıtlı değil.');
                return;
            }

            // Login
            const fakeEmail = phone + '@haliyikamaci.app';
            await signInWithEmailAndPassword(auth, fakeEmail, password);

            window.location.href = 'my-orders.php';

        } catch (error) {
            showLoading(false);
            console.error('Login error:', error);

            if (error.code === 'auth/wrong-password' || error.code === 'auth/invalid-credential') {
                showError('Şifre hatalı. Lütfen tekrar deneyin.');
            } else {
                showError('Giriş başarısız: ' + error.message);
            }
        }
    }

    async function handleRegister(auth, db) {
        const fullNameInput = document.getElementById('fullName').value.trim();
        const phone = document.getElementById('phoneNumber').value.replace(/\D/g, '');
        const password = document.getElementById('password').value;
        const address = addressSelector ? addressSelector.getAddress() : null;

        // Validations
        if (!fullNameInput || fullNameInput.length < 3) {
            showError('Lütfen adınızı ve soyadınızı girin.');
            return;
        }

        if (phone.length !== 10) {
            showError('Lütfen geçerli bir telefon numarası girin.');
            return;
        }

        if (password.length < 6) {
            showError('Şifre en az 6 karakter olmalıdır.');
            return;
        }

        if (!address || !addressSelector.isValid()) {
            showError('Lütfen İl, İlçe ve Mahalle seçiniz.');
            return;
        }

        // Name Split Logic
        const nameParts = fullNameInput.split(' ');
        let firstName = fullNameInput;
        let lastName = '';

        if (nameParts.length > 1) {
            lastName = nameParts.pop(); // Last part is surname
            firstName = nameParts.join(' '); // Rest is name
        }

        showLoading(true, 'Kayıt oluşturuluyor...');
        hideError();

        try {
            // Check if phone already exists
            const usersRef = collection(db, 'users');
            const q = query(usersRef, where('phone', '==', phone));
            const snapshot = await getDocs(q);

            if (!snapshot.empty) {
                showLoading(false);
                showError('Bu telefon numarası zaten kayıtlı.');
                return;
            }

            // Create Firebase Auth user
            const fakeEmail = phone + '@haliyikamaci.app';
            const userCredential = await createUserWithEmailAndPassword(auth, fakeEmail, password);
            const uid = userCredential.user.uid;

            // Create user document
            await setDoc(doc(db, 'users', uid), {
                uid: uid,
                email: fakeEmail,
                phone: phone,
                userType: 'customer',
                isActive: true,
                createdAt: Timestamp.now()
            });

            // Create customer document with address
            await setDoc(doc(db, 'customers', uid), {
                uid: uid,
                name: firstName,
                surname: lastName,
                phone: phone,
                email: '',
                addresses: [{
                    title: 'Ev Adresi',
                    city: address.provinceName,
                    district: address.districtName,
                    neighborhood: address.neighborhoodName,
                    fullAddress: address.fullAddress || '',
                    provinceId: parseInt(address.provinceId),
                    districtId: parseInt(address.districtId),
                    neighborhoodId: parseInt(address.neighborhoodId),
                    isDefault: true
                }],
                loyaltyPoints: 0,
                favoriteFirmIds: [],
                notificationSettings: {
                    campaign: true,
                    order: true
                },
                createdAt: Timestamp.now()
            });

            // Success
            showLoading(false);
            showSuccess('Kayıt başarılı! Yönlendiriliyorsunuz...');

            // Redirect to profile.php
            setTimeout(() => {
                window.location.href = 'profile.php';
            }, 1000);

        } catch (error) {
            showLoading(false);
            console.error('Registration error:', error);

            if (error.code === 'auth/email-already-in-use') {
                showError('Bu telefon numarası zaten kayıtlı.');
            } else {
                showError('Kayıt başarısız: ' + error.message);
            }
        }
    }

    async function checkIsCustomer(db, uid) {
        try {
            const customersRef = collection(db, 'customers');
            const q = query(customersRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);
            return !snapshot.empty;
        } catch (error) {
            console.error('Customer check error:', error);
            return false;
        }
    }

    function showLoading(show, text = 'İşlem yapılıyor...') {
        document.getElementById('loginForm').style.display = show ? 'none' : 'block';
        document.getElementById('loadingState').style.display = show ? 'block' : 'none';
        document.getElementById('loadingText').textContent = text;
    }

    function showError(message) {
        const el = document.getElementById('errorMessage');
        el.textContent = message;
        el.style.display = 'block';
        document.getElementById('successMessage').style.display = 'none';
    }

    function showSuccess(message) {
        const el = document.getElementById('successMessage');
        el.textContent = message;
        el.style.display = 'block';
        document.getElementById('errorMessage').style.display = 'none';
    }

    function hideError() {
        document.getElementById('errorMessage').style.display = 'none';
        document.getElementById('successMessage').style.display = 'none';
    }
</script>

<?php require_once '../includes/footer.php'; ?>