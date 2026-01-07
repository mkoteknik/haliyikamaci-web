<?php
require_once 'includes/header.php';
?>

<div class="page-header">
    <div class="d-flex justify-content-between align-items-center">
        <div>
            <h2 class="fw-bold mb-0">Hesap Ayarları</h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0 text-white-50">
                    <li class="breadcrumb-item"><a href="index.php" class="text-white-50">Dashboard</a></li>
                    <li class="breadcrumb-item active text-white" aria-current="page">Hesap Ayarları</li>
                </ol>
            </nav>
        </div>
    </div>
</div>

<div class="page-body">
    <div class="row g-4">
        <!-- İki Faktörlü Doğrulama (TOTP) -->
        <div class="col-12">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <h5 class="mb-0"><i class="fas fa-shield-alt text-success me-2"></i>İki Faktörlü Doğrulama (2FA)
                    </h5>
                    <span class="badge" id="totpStatusBadge">Yükleniyor...</span>
                </div>
                <div class="card-body">
                    <!-- TOTP Aktif Değil -->
                    <div id="totpSetupSection">
                        <p class="text-muted mb-3">
                            Google Authenticator veya benzeri bir uygulama ile hesabınızı daha güvenli hale getirin.
                        </p>

                        <div id="totpSetupStep1" style="display: none;">
                            <div class="row align-items-center">
                                <div class="col-md-6">
                                    <h6>1. QR Kodu Tarayın</h6>
                                    <p class="text-muted small">Google Authenticator veya benzeri uygulamanızla
                                        aşağıdaki QR kodu tarayın.</p>
                                    <div class="text-center my-3" id="qrCodeContainer"></div>
                                    <p class="text-muted small mt-2">
                                        <strong>Manuel Giriş:</strong> <code id="totpSecretDisplay"></code>
                                        <button class="btn btn-sm btn-outline-secondary ms-2" onclick="copySecret()">
                                            <i class="fas fa-copy"></i>
                                        </button>
                                    </p>
                                </div>
                                <div class="col-md-6">
                                    <h6>2. Kodu Doğrulayın</h6>
                                    <p class="text-muted small">Uygulamadaki 6 haneli kodu girin.</p>
                                    <div class="input-group mb-3">
                                        <input type="text" class="form-control form-control-lg text-center"
                                            id="totpVerifyCode" maxlength="6" placeholder="000000"
                                            style="letter-spacing: 8px; font-family: monospace;">
                                    </div>
                                    <button class="btn btn-success w-100" onclick="verifyAndEnable2FA()">
                                        <i class="fas fa-check me-2"></i>2FA'yı Etkinleştir
                                    </button>
                                </div>
                            </div>
                        </div>

                        <button class="btn btn-primary" id="startSetupBtn" onclick="startTotpSetup()">
                            <i class="fas fa-plus me-2"></i>2FA Kurulumunu Başlat
                        </button>
                    </div>

                    <!-- TOTP Aktif -->
                    <div id="totpActiveSection" style="display: none;">
                        <div class="alert alert-success mb-3">
                            <i class="fas fa-check-circle me-2"></i>
                            İki faktörlü doğrulama aktif. Hesabınız güvende.
                        </div>
                        <button class="btn btn-outline-danger" onclick="disable2FA()">
                            <i class="fas fa-times me-2"></i>2FA'yı Devre Dışı Bırak
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- E-Posta Değiştirme -->
        <div class="col-md-6">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white">
                    <h5 class="mb-0"><i class="fas fa-envelope text-primary me-2"></i>E-Posta Değiştir</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">Mevcut E-Posta</label>
                        <input type="email" class="form-control bg-light" id="currentEmail" readonly>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Yeni E-Posta</label>
                        <input type="email" class="form-control" id="newEmail" placeholder="yeni@email.com">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Mevcut Şifre (Onay için)</label>
                        <input type="password" class="form-control" id="emailPassword" placeholder="••••••">
                    </div>
                    <button class="btn btn-primary" onclick="changeEmail()">
                        <i class="fas fa-save me-2"></i>E-Posta Değiştir
                    </button>
                </div>
            </div>
        </div>

        <!-- Şifre Değiştirme -->
        <div class="col-md-6">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white">
                    <h5 class="mb-0"><i class="fas fa-key text-warning me-2"></i>Şifre Değiştir</h5>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <label class="form-label">Mevcut Şifre</label>
                        <input type="password" class="form-control" id="currentPassword" placeholder="••••••">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Yeni Şifre</label>
                        <input type="password" class="form-control" id="newPassword" placeholder="En az 6 karakter">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Yeni Şifre Tekrar</label>
                        <input type="password" class="form-control" id="confirmPassword"
                            placeholder="Şifreyi tekrar girin">
                    </div>
                    <button class="btn btn-warning text-white" onclick="changePassword()">
                        <i class="fas fa-key me-2"></i>Şifre Değiştir
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
</div>

<!-- QR Code Library -->
<script src="https://cdn.jsdelivr.net/npm/qrcode@1.5.3/build/qrcode.min.js"></script>
<!-- OTPAuth Library for TOTP -->
<script src="https://cdn.jsdelivr.net/npm/otpauth@9.2.2/dist/otpauth.umd.min.js"></script>

<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js';
    import { getAuth, onAuthStateChanged, updateEmail, updatePassword, reauthenticateWithCredential, EmailAuthProvider } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js';
    import { getFirestore, doc, getDoc, setDoc, updateDoc, deleteField } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

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

    let currentUser = null;
    let totpSecret = null;

    onAuthStateChanged(auth, async (user) => {
        if (!user) {
            window.location.href = 'login.php';
            return;
        }

        currentUser = user;

        // Show current email
        document.getElementById('currentEmail').value = user.email;

        // Check 2FA status
        await check2FAStatus();

        // Hide loader, show content
        const authCheck = document.getElementById('authCheck');
        const mainLayout = document.getElementById('mainLayout');

        if (authCheck) authCheck.classList.add('d-none');
        if (mainLayout) mainLayout.style.display = 'block';
    });

    // Check if 2FA is enabled
    async function check2FAStatus() {
        try {
            const userDoc = await getDoc(doc(db, 'users', currentUser.uid));
            const data = userDoc.data();

            if (data && data.totpEnabled) {
                // 2FA is active
                document.getElementById('totpStatusBadge').className = 'badge bg-success';
                document.getElementById('totpStatusBadge').textContent = 'Aktif';
                document.getElementById('totpSetupSection').style.display = 'none';
                document.getElementById('totpActiveSection').style.display = 'block';
            } else {
                // 2FA not active
                document.getElementById('totpStatusBadge').className = 'badge bg-warning';
                document.getElementById('totpStatusBadge').textContent = 'Pasif';
                document.getElementById('totpSetupSection').style.display = 'block';
                document.getElementById('totpActiveSection').style.display = 'none';
            }
        } catch (e) {
            console.error('2FA status check error:', e);
        }
    }

    // Generate random secret (Base32)
    function generateSecret(length = 16) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        let secret = '';
        const array = new Uint8Array(length);
        crypto.getRandomValues(array);
        array.forEach(x => {
            secret += chars[x % chars.length];
        });
        return secret;
    }

    // Start TOTP Setup
    window.startTotpSetup = function () {
        totpSecret = generateSecret(20);

        // Show setup UI
        document.getElementById('startSetupBtn').style.display = 'none';
        document.getElementById('totpSetupStep1').style.display = 'block';

        // Display secret
        document.getElementById('totpSecretDisplay').textContent = totpSecret;

        // Generate QR code
        const otpAuthUrl = `otpauth://totp/HaliYikamaci:${currentUser.email}?secret=${totpSecret}&issuer=HaliYikamaci&algorithm=SHA1&digits=6&period=30`;

        const container = document.getElementById('qrCodeContainer');

        // Use QR Server API (reliable and free)
        const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(otpAuthUrl)}`;
        container.innerHTML = `<img src="${qrUrl}" alt="QR Code" style="border: 1px solid #ddd; border-radius: 8px; width: 200px; height: 200px;">`;
    }

    // Copy secret to clipboard
    window.copySecret = function () {
        navigator.clipboard.writeText(totpSecret);
        Swal.fire({
            icon: 'success',
            title: 'Kopyalandı!',
            timer: 1000,
            showConfirmButton: false
        });
    }

    // TOTP Generation (for verification)
    function generateTOTP(secret, time = Math.floor(Date.now() / 1000)) {
        // Implement TOTP algorithm
        const base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

        // Decode Base32
        let bits = '';
        for (let i = 0; i < secret.length; i++) {
            const val = base32Chars.indexOf(secret[i].toUpperCase());
            if (val === -1) continue;
            bits += val.toString(2).padStart(5, '0');
        }

        const bytes = [];
        for (let i = 0; i + 8 <= bits.length; i += 8) {
            bytes.push(parseInt(bits.slice(i, i + 8), 2));
        }
        const keyBytes = new Uint8Array(bytes);

        // Time step
        const step = 30;
        const counter = Math.floor(time / step);

        // Counter to bytes (8 bytes, big endian)
        const counterBytes = new Uint8Array(8);
        let temp = counter;
        for (let i = 7; i >= 0; i--) {
            counterBytes[i] = temp & 0xff;
            temp = Math.floor(temp / 256);
        }

        // We need to use SubtleCrypto for HMAC-SHA1
        // Since this is async, we'll use a simple verification approach
        return null; // Will verify server-side or use simpler check
    }

    // Verify and Enable 2FA
    window.verifyAndEnable2FA = async function () {
        const code = document.getElementById('totpVerifyCode').value.trim();

        if (!code || code.length !== 6) {
            Swal.fire('Hata', 'Lütfen 6 haneli kodu girin.', 'error');
            return;
        }

        // Verify using OTPAuth library
        try {
            const totp = new OTPAuth.TOTP({
                issuer: 'HaliYikamaci',
                label: currentUser.email,
                algorithm: 'SHA1',
                digits: 6,
                period: 30,
                secret: OTPAuth.Secret.fromBase32(totpSecret)
            });
            
            const delta = totp.validate({ token: code, window: 1 });
            
            if (delta === null) {
                Swal.fire('Hata', 'Geçersiz kod. Lütfen doğru kodu girin.', 'error');
                return;
            }

            // Code is valid, save to Firestore
            await updateDoc(doc(db, 'users', currentUser.uid), {
                totpEnabled: true,
                totpSecret: totpSecret,
                totpEnabledAt: new Date()
            });

            Swal.fire({
                icon: 'success',
                title: '2FA Etkinleştirildi!',
                text: 'Bir sonraki girişinizde Google Authenticator kodu isteyeceğiz.',
                confirmButtonColor: '#28a745'
            }).then(() => {
                check2FAStatus();
            });

        } catch (error) {
            console.error('2FA enable error:', error);
            Swal.fire('Hata', '2FA etkinleştirilemedi: ' + error.message, 'error');
        }
    }

    // Disable 2FA
    window.disable2FA = async function () {
        const result = await Swal.fire({
            icon: 'warning',
            title: '2FA Devre Dışı Bırak',
            text: 'İki faktörlü doğrulamayı devre dışı bırakmak istediğinizden emin misiniz?',
            showCancelButton: true,
            confirmButtonColor: '#dc3545',
            confirmButtonText: 'Evet, Devre Dışı Bırak',
            cancelButtonText: 'İptal'
        });

        if (!result.isConfirmed) return;

        try {
            await updateDoc(doc(db, 'users', currentUser.uid), {
                totpEnabled: false,
                totpSecret: deleteField(),
                totpEnabledAt: deleteField()
            });

            Swal.fire('Başarılı', '2FA devre dışı bırakıldı.', 'success');
            check2FAStatus();

            // Reset setup UI
            document.getElementById('startSetupBtn').style.display = 'block';
            document.getElementById('totpSetupStep1').style.display = 'none';

        } catch (error) {
            console.error('2FA disable error:', error);
            Swal.fire('Hata', '2FA devre dışı bırakılamadı: ' + error.message, 'error');
        }
    }

    // Change Email
    window.changeEmail = async function () {
        const newEmail = document.getElementById('newEmail').value.trim();
        const password = document.getElementById('emailPassword').value;

        if (!newEmail || !password) {
            Swal.fire('Hata', 'Yeni e-posta ve şifre gereklidir.', 'error');
            return;
        }

        try {
            const credential = EmailAuthProvider.credential(currentUser.email, password);
            await reauthenticateWithCredential(currentUser, credential);
            await updateEmail(currentUser, newEmail);
            await updateDoc(doc(db, 'users', currentUser.uid), { email: newEmail });

            Swal.fire('Başarılı', 'E-posta adresiniz güncellendi.', 'success');
            document.getElementById('currentEmail').value = newEmail;
            document.getElementById('newEmail').value = '';
            document.getElementById('emailPassword').value = '';

        } catch (error) {
            console.error('Email change error:', error);
            if (error.code === 'auth/wrong-password') {
                Swal.fire('Hata', 'Mevcut şifre hatalı.', 'error');
            } else {
                Swal.fire('Hata', 'E-posta güncellenemedi: ' + error.message, 'error');
            }
        }
    }

    // Change Password
    window.changePassword = async function () {
        const currentPwd = document.getElementById('currentPassword').value;
        const newPwd = document.getElementById('newPassword').value;
        const confirmPwd = document.getElementById('confirmPassword').value;

        if (!currentPwd || !newPwd || !confirmPwd) {
            Swal.fire('Hata', 'Tüm alanları doldurun.', 'error');
            return;
        }

        if (newPwd !== confirmPwd) {
            Swal.fire('Hata', 'Yeni şifreler eşleşmiyor.', 'error');
            return;
        }

        if (newPwd.length < 6) {
            Swal.fire('Hata', 'Şifre en az 6 karakter olmalıdır.', 'error');
            return;
        }

        try {
            const credential = EmailAuthProvider.credential(currentUser.email, currentPwd);
            await reauthenticateWithCredential(currentUser, credential);
            await updatePassword(currentUser, newPwd);

            Swal.fire('Başarılı', 'Şifreniz güncellendi.', 'success');
            document.getElementById('currentPassword').value = '';
            document.getElementById('newPassword').value = '';
            document.getElementById('confirmPassword').value = '';

        } catch (error) {
            console.error('Password change error:', error);
            if (error.code === 'auth/wrong-password') {
                Swal.fire('Hata', 'Mevcut şifre hatalı.', 'error');
            } else {
                Swal.fire('Hata', 'Şifre güncellenemedi: ' + error.message, 'error');
            }
        }
    }

    // Logout function
    window.doLogout = async function () {
        try {
            await auth.signOut();
            window.location.href = 'login.php';
        } catch (error) {
            console.error('Logout error:', error);
            alert('Çıkış yapılamadı: ' + error.message);
        }
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<!-- Close #mainLayout -->
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>