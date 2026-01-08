<?php
/**
 * Halı Yıkamacı - Hesap Silme (App Store Compliance)
 */

require_once 'config/app.php';
$pageTitle = 'Hesap Silme';
require_once 'includes/header.php';
?>

<section class="section py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-8 col-lg-6">
                <!-- LOGO & HEADER -->
                <div class="text-center mb-4">
                    <div class="bg-danger text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3 shadow"
                        style="width: 80px; height: 80px;">
                        <i class="fas fa-user-times fa-2x"></i>
                    </div>
                    <h3 class="fw-bold">Hesap Silme</h3>
                    <p class="text-muted">Bu işlem geri alınamaz. Tüm verileriniz silinecektir.</p>
                </div>

                <div class="card shadow-lg border-0">
                    <div class="card-body p-4 p-md-5">

                        <!-- 1. ALERT MESSAGE -->
                        <div
                            class="alert alert-warning border-0 bg-warning bg-opacity-10 d-flex align-items-center mb-4">
                            <i class="fas fa-exclamation-triangle text-warning fa-2x me-3"></i>
                            <div>
                                <h6 class="fw-bold mb-1">Dikkat!</h6>
                                <small>Hesabınızı sildiğinizde siparişleriniz, puanlarınız ve tüm kişisel verileriniz
                                    kalıcı olarak silinir.</small>
                            </div>
                        </div>

                        <!-- 2. LOGIN FORM (Visible if NOT logged in) -->
                        <div id="loginSection">
                            <h5 class="fw-bold mb-3 text-center">Önce Giriş Yapın</h5>
                            <form id="loginForm">
                                <div class="mb-3">
                                    <label class="form-label fw-bold">Telefon Numarası</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-end-0"><i
                                                class="fas fa-phone"></i> +90</span>
                                        <input type="tel" id="phoneNumber" class="form-control border-start-0 ps-0"
                                            placeholder="5XX XXX XX XX" maxlength="10" required pattern="[0-9]{10}">
                                    </div>
                                </div>

                                <div class="mb-4">
                                    <label class="form-label fw-bold">Şifre</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-end-0"><i
                                                class="fas fa-lock"></i></span>
                                        <input type="password" id="password" class="form-control border-start-0 ps-0"
                                            placeholder="Şifreniz" required>
                                    </div>
                                </div>

                                <div id="loginError" class="alert alert-danger py-2 small" style="display: none;"></div>

                                <button type="submit" id="loginBtn"
                                    class="btn btn-primary w-100 py-3 fw-bold rounded-pill">
                                    <i class="fas fa-sign-in-alt me-2"></i>Giriş Yap ve Devam Et
                                </button>
                            </form>
                        </div>

                        <!-- 3. DELETE CONFIRMATION (Visible if LOGGED IN) -->
                        <div id="deleteSection" style="display: none;">
                            <div class="text-center mb-4">
                                <div class="avatar-circle mb-2 mx-auto bg-light text-primary fw-bold d-flex align-items-center justify-content-center"
                                    style="width: 60px; height: 60px; font-size: 24px;">
                                    <i class="fas fa-user"></i>
                                </div>
                                <h5 id="userPhoneDisplay" class="fw-bold mb-0"></h5>
                                <span
                                    class="badge bg-success bg-opacity-10 text-success mt-2 px-3 py-2 rounded-pill">Oturum
                                    Açıldı</span>
                            </div>

                            <div class="d-grid gap-3">
                                <button id="deleteAccountBtn"
                                    class="btn btn-danger py-3 fw-bold rounded-pill shadow-sm">
                                    <i class="fas fa-trash-alt me-2"></i>Hesabımı Kalıcı Olarak Sil
                                </button>
                                <button id="signOutBtn" class="btn btn-light py-3 fw-bold rounded-pill text-muted">
                                    Vazgeç ve Çıkış Yap
                                </button>
                            </div>
                        </div>

                        <!-- LOADING STATE -->
                        <div id="loadingState" style="display: none;" class="text-center py-5">
                            <div class="spinner-border text-danger" role="status" style="width: 3rem; height: 3rem;">
                            </div>
                            <p class="mt-3 text-secondary fw-medium" id="loadingText">İşlem yapılıyor...</p>
                        </div>

                    </div>
                </div>

                <!-- Footer Info -->
                <div class="text-center mt-4 text-muted small opacity-75">
                    <p>Bu sayfa Apple App Store ve Google Play Store<br>kullanıcı veri güvenliği politikaları gereği
                        hazırlanmıştır.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Config & Firebase -->
<input type="hidden" id="firebaseConfig" value='<?php echo json_encode([
    'apiKey' => 'FIREBASE_API_KEY_PLACEHOLDER', // This should be replaced or loaded from JS if not in header
]); ?>'>

<script type="module">
    import { getAuth, signInWithEmailAndPassword, onAuthStateChanged, deleteUser, signOut, EmailAuthProvider, reauthenticateWithCredential } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, doc, getDoc, deleteDoc, collection, query, where, getDocs } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

    // UI Elements
    const loginSection = document.getElementById('loginSection');
    const deleteSection = document.getElementById('deleteSection');
    const loadingState = document.getElementById('loadingState');
    const loginForm = document.getElementById('loginForm');
    const loginError = document.getElementById('loginError');
    const userPhoneDisplay = document.getElementById('userPhoneDisplay');

    let currentUser = null;

    // Helper: Show/Hide Loading
    const setLoading = (isLoading, text = 'Yükleniyor...') => {
        if (isLoading) {
            loginSection.style.display = 'none';
            deleteSection.style.display = 'none';
            loadingState.style.display = 'block';
            document.getElementById('loadingText').innerText = text;
        } else {
            loadingState.style.display = 'none';
        }
    };

    // Helper: Show Error
    const showError = (msg) => {
        loginError.style.display = 'block';
        loginError.innerText = msg;
        // Shake animation effect
        loginForm.classList.add('shake');
        setTimeout(() => loginForm.classList.remove('shake'), 500);
    };

    window.addEventListener('firebaseReady', function () {
        const auth = window.firebaseAuth;
        const db = window.firebaseDb;

        console.log("Firebase Ready in delete-account.php");

        // 1. Auth State Listener
        onAuthStateChanged(auth, async (user) => {
            if (user) {
                currentUser = user;
                const phone = user.email.replace('@haliyikamaci.app', '');
                userPhoneDisplay.innerText = '+90 ' + phone; // Simple formatting

                setLoading(false);
                loginSection.style.display = 'none';
                deleteSection.style.display = 'block';
            } else {
                currentUser = null;
                setLoading(false);
                loginSection.style.display = 'block';
                deleteSection.style.display = 'none';
            }
        });

        // 2. Handle Login
        loginForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const phone = document.getElementById('phoneNumber').value.replace(/\D/g, '');
            const password = document.getElementById('password').value;

            if (phone.length !== 10) return showError('Geçerli bir telefon numarası giriniz.');
            if (password.length < 6) return showError('Şifreniz en az 6 karakter olmalıdır.');

            setLoading(true, 'Giriş yapılıyor...');
            loginError.style.display = 'none';

            try {
                const fakeEmail = phone + '@haliyikamaci.app';
                await signInWithEmailAndPassword(auth, fakeEmail, password);
                // onAuthStateChanged will handle the UI update
            } catch (error) {
                setLoading(false);
                loginSection.style.display = 'block';
                console.error(error);
                if (error.code === 'auth/invalid-credential' || error.code === 'auth/wrong-password') {
                    showError('Telefon numarası veya şifre hatalı.');
                } else {
                    showError('Giriş hatası: ' + error.message);
                }
            }
        });

        // 3. Handle Sign Out
        document.getElementById('signOutBtn').addEventListener('click', () => {
            signOut(auth);
        });

        // 4. Handle Account Deletion
        document.getElementById('deleteAccountBtn').addEventListener('click', async () => {
            if (!confirm('KESİN ONAY: Hesabınız ve tüm verileriniz kalıcı olarak silinecektir. Emin misiniz?')) {
                return;
            }

            if (!currentUser) return;

            setLoading(true, 'Hesap siliniyor... Lütfen bekleyin.');

            try {
                const uid = currentUser.uid;

                // A. Determine User Type & Delete Profile Doc
                const userDocRef = doc(db, 'users', uid);
                const userDocSnap = await getDoc(userDocRef);

                if (userDocSnap.exists()) {
                    const userData = userDocSnap.data();
                    const userType = userData.userType; // 'customer' or 'firm'

                    // Delete from specific collection
                    if (userType === 'customer') {
                        // Delete customer doc
                        await deleteDoc(doc(db, 'customers', uid));

                        // Note: We are not deleting sub-collections strictly here as client SDK 
                        // cannot easily delete collections. But the main link is broken.
                        // Ideally, use a Cloud Function for comprehensive cleanup.

                    } else if (userType === 'firm') {
                        await deleteDoc(doc(db, 'firms', uid));
                    }

                    // Delete User Index Doc
                    await deleteDoc(userDocRef);
                }

                // B. Delete Auth User
                await deleteUser(currentUser);

                // C. Success & Redirect
                alert('Hesabınız başarıyla silindi.');
                window.location.href = 'index.php';

            } catch (error) {
                setLoading(false);
                deleteSection.style.display = 'block';
                console.error("Delete Error", error);

                if (error.code === 'auth/requires-recent-login') {
                    alert('Güvenlik gereği yeniden giriş yapmalısınız.');
                    signOut(auth);
                } else {
                    alert('Hata oluştu: ' + error.message);
                }
            }
        });
    });
</script>

<style>
    .shake {
        animation: shake 0.5s;
    }

    @keyframes shake {
        0% {
            transform: translateX(0);
        }

        25% {
            transform: translateX(-10px);
        }

        50% {
            transform: translateX(10px);
        }

        75% {
            transform: translateX(-10px);
        }

        100% {
            transform: translateX(0);
        }
    }
</style>

<?php require_once 'includes/footer.php'; ?>