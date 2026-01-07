<?php
/**
 * Halı Yıkamacı - Firma Girişi (Telefon + Şifre)
 */

require_once '../config/app.php';
$pageTitle = 'Firma Girişi';
require_once '../includes/header.php';
?>

<section class="section">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="card shadow-sm">
                    <div class="card-body p-5">
                        <div class="text-center mb-4">
                            <div class="bg-gradient-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3"
                                style="width: 80px; height: 80px;">
                                <i class="fas fa-store fa-2x"></i>
                            </div>
                            <h3 class="fw-bold">Firma Girişi</h3>
                            <p class="text-muted">Telefon ve şifrenizle giriş yapın</p>
                        </div>

                        <!-- Login Form -->
                        <form id="loginForm">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Telefon Numarası</label>
                                <div class="input-group">
                                    <span class="input-group-text">+90</span>
                                    <input type="tel" id="phoneNumber" class="form-control" placeholder="5XX XXX XX XX"
                                        maxlength="10" required pattern="[0-9]{10}">
                                </div>
                                <small class="text-muted">Başında 0 olmadan girin</small>
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-bold">Şifre</label>
                                <div class="input-group">
                                    <input type="password" id="password" class="form-control"
                                        placeholder="Şifrenizi girin" required>
                                    <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <div id="errorMessage" class="alert alert-danger" style="display: none;"></div>

                            <button type="submit" id="loginBtn" class="btn btn-primary btn-lg w-100">
                                <i class="fas fa-sign-in-alt me-2"></i>Giriş Yap
                            </button>
                        </form>

                        <!-- Loading State -->
                        <!-- Loading State -->
                        <div id="loadingState" style="display: none;">
                            <div class="text-center py-4">
                                <div class="spinner mb-3"></div>
                                <p class="text-muted">Giriş yapılıyor...</p>
                            </div>
                        </div>

                        <hr class="my-4">

                        <p class="text-center text-muted mb-0">
                            Henüz firma hesabınız yok mu?
                            <a href="register.php" class="text-primary fw-bold">Kayıt Olun</a>
                        </p>
                        <p class="text-center mt-2 mb-0">
                            <a href="forgot-password.php" class="text-secondary">Şifremi Unuttum</a>
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

<script type="module">
    import { getAuth, signInWithEmailAndPassword, onAuthStateChanged, signOut } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, collection, query, where, getDocs, doc, getDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

    window.addEventListener('firebaseReady', function () {
        const auth = window.firebaseAuth;
        const db = window.firebaseDb;

        // Check if already logged in as firm
        onAuthStateChanged(auth, async (user) => {
            console.log('AuthStateChanged triggered:', user ? user.uid : 'No user');
            if (user) {
                // Strict RBAC: Check User Type first
                try {
                    console.log('Checking user params...');
                    const userDoc = await getDoc(doc(db, 'users', user.uid));

                    if (!userDoc.exists()) {
                        console.warn('User doc does not exist for uid:', user.uid);
                        await signOut(auth);
                        return;
                    }

                    const userData = userDoc.data();
                    console.log('User data loaded:', userData);

                    if (userData.userType !== 'firm') {
                        console.warn('Invalid user type:', userData.userType, 'Signing out...');
                        await signOut(auth);
                        return;
                    }

                    // If firm, check if firm profile exists
                    const isFirm = await checkIsFirm(db, user.uid);
                    if (isFirm) {
                        window.location.href = 'index.php';
                    } else {
                        console.warn('No associated firm found, signing out...');
                        await signOut(auth);
                    }
                } catch (error) {
                    console.error('Auth check error:', error);
                    await signOut(auth);
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

        // Login form submit
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleLogin(auth, db);
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

        showLoading(true);
        hideError();

        try {
            // Step 1: Check if phone is registered and get user data
            const usersRef = collection(db, 'users');
            const q = query(usersRef, where('phone', '==', phone));
            const snapshot = await getDocs(q);

            if (snapshot.empty) {
                showLoading(false);
                showError('Bu numara kayıtlı değil. Firma Kaydı Oluşturun.');
                return;
            }

            const userData = snapshot.docs[0].data();

            // Step 2: Check if user is firm
            if (userData.userType !== 'firm') {
                showLoading(false);
                showError('Bu numara Müşteri olarak kayıtlı. Müşteri Girişi seçeneğini kullanın.');
                return;
            }

            // Step 3: Try to login with email (phone@haliyikamaci.app) and password
            const fakeEmail = phone + '@haliyikamaci.app';

            await signInWithEmailAndPassword(auth, fakeEmail, password);

            // Success - redirect to dashboard
            window.location.href = 'index.php';

        } catch (error) {
            showLoading(false);
            console.error('Login error:', error);

            if (error.code === 'auth/wrong-password' || error.code === 'auth/invalid-credential') {
                showError('Şifre hatalı. Lütfen tekrar deneyin.');
            } else if (error.code === 'auth/user-not-found') {
                showError('Kullanıcı bulunamadı.');
            } else if (error.code === 'auth/too-many-requests') {
                showError('Çok fazla deneme yapıldı. Lütfen bir süre bekleyin.');
            } else {
                showError('Giriş başarısız: ' + error.message);
            }
        }
    }

    async function checkIsFirm(db, uid) {
        try {
            const firmsRef = collection(db, 'firms');
            const q = query(firmsRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);
            return !snapshot.empty;
        } catch (error) {
            console.error('Firma kontrolü hatası:', error);
            return false;
        }
    }

    function showLoading(show) {
        document.getElementById('loginForm').style.display = show ? 'none' : 'block';
        document.getElementById('loadingState').style.display = show ? 'block' : 'none';
    }

    function showError(message) {
        const el = document.getElementById('errorMessage');
        el.textContent = message;
        el.style.display = 'block';
    }

    function hideError() {
        document.getElementById('errorMessage').style.display = 'none';
    }
</script>

<?php require_once '../includes/footer.php'; ?>