<?php
session_start();

// If user is already logged in as admin, redirect to dashboard
if (isset($_SESSION['admin_uid'])) {
    header('Location: index.php');
    exit;
}
?>

<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Girişi - Halı Yıkamacı</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #1a3867;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            width: 100%;
            max-width: 400px;
            padding: 2rem;
        }

        .brand-logo {
            text-align: center;
            margin-bottom: 2rem;
            color: #1a3867;
        }

        .brand-logo i {
            font-size: 3rem;
            margin-bottom: 1rem;
        }

        .form-control {
            padding: 0.75rem 1rem;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        .form-control:focus {
            border-color: #1a3867;
            box-shadow: 0 0 0 3px rgba(26, 56, 103, 0.1);
        }

        .btn-primary {
            background-color: #1a3867;
            border-color: #1a3867;
            padding: 0.75rem;
            border-radius: 8px;
            font-weight: 600;
        }

        .btn-primary:hover {
            background-color: #142c52;
            border-color: #142c52;
        }

        #errorMessage {
            display: none;
        }

        #loadingState {
            display: none;
            text-align: center;
            padding: 1rem;
        }

        .totp-input {
            font-size: 1.5rem;
            letter-spacing: 10px;
            text-align: center;
            font-family: monospace;
        }
    </style>
</head>

<body>

    <div class="login-card">
        <div class="brand-logo">
            <i class="fas fa-shield-alt"></i>
            <h4 class="fw-bold mb-1" id="pageTitle">Admin Girişi</h4>
            <p class="text-muted small mb-0" id="pageSubtitle">Halı Yıkamacı Yönetim Paneli</p>
        </div>

        <!-- Error Alert -->
        <div class="alert alert-danger" id="errorMessage" role="alert"></div>

        <!-- Login Form -->
        <form id="loginForm">
            <div class="mb-3">
                <label class="form-label text-muted small fw-bold">E-POSTA</label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0"><i
                            class="fas fa-envelope text-muted"></i></span>
                    <input type="text" class="form-control border-start-0 ps-0" id="email" placeholder="ornek@email.com"
                        required autocomplete="email">
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label text-muted small fw-bold">ŞİFRE</label>
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0"><i class="fas fa-lock text-muted"></i></span>
                    <input type="password" class="form-control border-start-0 ps-0" id="password" placeholder="••••••"
                        required autocomplete="current-password">
                </div>
            </div>

            <button type="submit" class="btn btn-primary w-100 mb-3" id="loginBtn">
                <span id="loginBtnText"><i class="fas fa-sign-in-alt me-2"></i>Giriş Yap</span>
            </button>
        </form>

        <!-- TOTP Form (2FA Step) -->
        <form id="totpForm" style="display: none;">
            <div class="text-center mb-4">
                <div class="bg-success bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center"
                    style="width: 60px; height: 60px;">
                    <i class="fas fa-mobile-alt fa-2x text-success"></i>
                </div>
                <h5 class="mt-3 mb-1">İki Faktörlü Doğrulama</h5>
                <p class="text-muted small">Google Authenticator uygulamanızdaki 6 haneli kodu girin.</p>
            </div>

            <div class="mb-4">
                <input type="text" class="form-control totp-input" id="totpCode" placeholder="000000" maxlength="6"
                    autocomplete="one-time-code" inputmode="numeric">
            </div>

            <button type="submit" class="btn btn-success w-100 mb-3">
                <i class="fas fa-check me-2"></i>Doğrula
            </button>

            <button type="button" class="btn btn-outline-secondary w-100" onclick="cancelTotp()">
                <i class="fas fa-arrow-left me-2"></i>Geri
            </button>
        </form>

        <!-- Loading State -->
        <div id="loadingState">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Yükleniyor...</span>
            </div>
            <p class="mt-2 text-muted small">İşlem yapılıyor...</p>
        </div>

        <div class="text-center mt-3">
            <a href="../index.php" class="text-muted small text-decoration-none">
                <i class="fas fa-arrow-left me-1"></i> Siteye Dön
            </a>
        </div>
    </div>

    <!-- OTPAuth Library for TOTP verification -->
    <script src="https://cdn.jsdelivr.net/npm/otpauth@9.2.2/dist/otpauth.umd.min.js"></script>

    <!-- Firebase SDKs -->
    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
        import { getAuth, signInWithEmailAndPassword, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js";
        import { getFirestore, doc, getDoc, setDoc } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js";

        import { firebaseConfig } from './includes/firebase-config.js';

        const app = initializeApp(firebaseConfig);
        const auth = getAuth(app);
        const db = getFirestore(app, 'haliyikamacimmbldatabase');

        let pendingUser = null;
        let pendingTotpSecret = null;

        // Login form submit
        document.getElementById('loginForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            await handleLogin();
        });

        // TOTP form submit
        document.getElementById('totpForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            await verifyTotp();
        });

        async function handleLogin() {
            let email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value;

            if (!email || !password) {
                showError('E-posta ve şifre gereklidir.');
                return;
            }

            // Auto-append email domain
            if (!email.includes('@')) {
                const phoneOnly = email.replace(/\D/g, '');
                if (phoneOnly.length === 10 && email === phoneOnly) {
                    email = email + '@haliyikamaci.app';
                } else {
                    email = email + '@gmail.com';
                }
            }

            showLoading(true);
            hideError();

            try {
                const userCredential = await signInWithEmailAndPassword(auth, email, password);
                const user = userCredential.user;

                // Check if user is admin
                const userDoc = await getDoc(doc(db, 'users', user.uid));

                if (!userDoc.exists() || userDoc.data().userType !== 'admin') {
                    // Try to create admin record for migrated accounts
                    try {
                        await setDoc(doc(db, 'users', user.uid), {
                            uid: user.uid,
                            email: email,
                            userType: 'admin',
                            createdAt: new Date(),
                            isActive: true,
                            migratedAt: new Date()
                        });
                    } catch (createError) {
                        await auth.signOut();
                        showLoading(false);
                        showError('Bu hesap admin yetkisine sahip değil.');
                        return;
                    }
                }

                // Check if 2FA is enabled
                const userData = userDoc.exists() ? userDoc.data() : {};

                if (userData.totpEnabled && userData.totpSecret) {
                    // Show TOTP form
                    pendingUser = user;
                    pendingTotpSecret = userData.totpSecret;

                    showLoading(false);
                    document.getElementById('loginForm').style.display = 'none';
                    document.getElementById('totpForm').style.display = 'block';
                    document.getElementById('pageTitle').textContent = '2FA Doğrulama';
                    document.getElementById('pageSubtitle').textContent = 'Güvenlik kodu gerekli';
                    document.getElementById('totpCode').focus();
                } else {
                    // No 2FA, proceed to dashboard
                    window.location.href = 'index.php';
                }

            } catch (error) {
                showLoading(false);
                console.error('Login error:', error);

                if (error.code === 'auth/wrong-password' || error.code === 'auth/invalid-credential') {
                    showError('E-posta veya şifre hatalı.');
                } else if (error.code === 'auth/user-not-found') {
                    showError('Kullanıcı bulunamadı.');
                } else if (error.code === 'auth/too-many-requests') {
                    showError('Çok fazla deneme yapıldı. Lütfen bir süre bekleyin.');
                } else {
                    showError('Giriş başarısız: ' + error.message);
                }
            }
        }

        async function verifyTotp() {
            const code = document.getElementById('totpCode').value.trim();

            if (!code || code.length !== 6) {
                showError('Lütfen 6 haneli kodu girin.');
                return;
            }

            showLoading(true);
            hideError();

            try {
                // Use OTPAuth library for verification
                const totp = new OTPAuth.TOTP({
                    issuer: 'HaliYikamaci',
                    label: pendingUser.email,
                    algorithm: 'SHA1',
                    digits: 6,
                    period: 30,
                    secret: OTPAuth.Secret.fromBase32(pendingTotpSecret)
                });

                // Validate with 1 step window (allows 30 seconds drift)
                const delta = totp.validate({ token: code, window: 1 });

                if (delta !== null) {
                    // Success!
                    window.location.href = 'index.php';
                } else {
                    showLoading(false);
                    showError('Geçersiz kod. Lütfen tekrar deneyin.');
                    document.getElementById('totpCode').value = '';
                    document.getElementById('totpCode').focus();
                }
            } catch (error) {
                showLoading(false);
                console.error('TOTP verification error:', error);
                showError('Doğrulama hatası: ' + error.message);
            }
        }

        window.cancelTotp = async function () {
            // Sign out and go back to login
            await auth.signOut();
            pendingUser = null;
            pendingTotpSecret = null;

            document.getElementById('loginForm').style.display = 'block';
            document.getElementById('totpForm').style.display = 'none';
            document.getElementById('pageTitle').textContent = 'Admin Girişi';
            document.getElementById('pageSubtitle').textContent = 'Halı Yıkamacı Yönetim Paneli';
            document.getElementById('totpCode').value = '';
            hideError();
        }

        function showLoading(show) {
            if (show) {
                document.getElementById('loginForm').style.display = 'none';
                document.getElementById('totpForm').style.display = 'none';
                document.getElementById('loadingState').style.display = 'block';
            } else {
                document.getElementById('loadingState').style.display = 'none';
                if (pendingUser) {
                    document.getElementById('totpForm').style.display = 'block';
                } else {
                    document.getElementById('loginForm').style.display = 'block';
                }
            }
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

</body>

</html>