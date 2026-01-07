<?php
/**
 * Halı Yıkamacı - Firma Şifre Sıfırlama
 * 3 Aşamalı: Telefon → OTP Doğrulama → Yeni Şifre
 */

require_once '../config/app.php';
$pageTitle = 'Şifremi Unuttum - Firma';
require_once '../includes/header.php';
?>

<section class="section">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="card shadow-sm">
                    <div class="card-body p-5">
                        <!-- Progress Steps -->
                        <div class="d-flex justify-content-between mb-4">
                            <div class="text-center flex-fill step-item" id="step1Indicator">
                                <div class="step-circle bg-primary text-white mx-auto mb-2">1</div>
                                <small>Telefon</small>
                            </div>
                            <div class="text-center flex-fill step-item" id="step2Indicator">
                                <div class="step-circle bg-secondary text-white mx-auto mb-2">2</div>
                                <small>Doğrulama</small>
                            </div>
                            <div class="text-center flex-fill step-item" id="step3Indicator">
                                <div class="step-circle bg-secondary text-white mx-auto mb-2">3</div>
                                <small>Yeni Şifre</small>
                            </div>
                        </div>

                        <!-- Step 1: Phone -->
                        <div id="step1" class="step-content">
                            <div class="text-center mb-4">
                                <i class="fas fa-mobile-alt fa-4x text-primary mb-3"></i>
                                <h4 class="fw-bold">Telefon Numaranızı Girin</h4>
                                <p class="text-muted">Kayıtlı telefon numaranıza doğrulama kodu göndereceğiz.</p>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Telefon Numarası</label>
                                <div class="input-group">
                                    <span class="input-group-text">+90</span>
                                    <input type="tel" id="phoneNumber" class="form-control" placeholder="5XX XXX XX XX"
                                        maxlength="10" required>
                                </div>
                            </div>

                            <div id="step1Error" class="alert alert-danger" style="display: none;"></div>

                            <button type="button" id="sendOtpBtn" class="btn btn-primary btn-lg w-100">
                                <i class="fas fa-paper-plane me-2"></i>Doğrulama Kodu Gönder
                            </button>
                        </div>

                        <!-- Step 2: OTP Verification -->
                        <div id="step2" class="step-content" style="display: none;">
                            <div class="text-center mb-4">
                                <i class="fas fa-sms fa-4x text-success mb-3"></i>
                                <h4 class="fw-bold">Doğrulama Kodu</h4>
                                <p class="text-muted">Telefonunuza gönderilen 6 haneli kodu girin.</p>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Doğrulama Kodu</label>
                                <input type="text" id="otpCode" class="form-control form-control-lg text-center"
                                    maxlength="6" placeholder="• • • • • •"
                                    style="letter-spacing: 8px; font-size: 1.5rem;">
                            </div>

                            <div id="step2Error" class="alert alert-danger" style="display: none;"></div>

                            <button type="button" id="verifyOtpBtn" class="btn btn-success btn-lg w-100 mb-3">
                                <i class="fas fa-check me-2"></i>Doğrula
                            </button>

                            <button type="button" id="resendOtpBtn" class="btn btn-link w-100">
                                Kodu Tekrar Gönder
                            </button>
                        </div>

                        <!-- Step 3: New Password -->
                        <div id="step3" class="step-content" style="display: none;">
                            <div class="text-center mb-4">
                                <i class="fas fa-lock fa-4x text-primary mb-3"></i>
                                <h4 class="fw-bold">Yeni Şifre Belirleyin</h4>
                                <p class="text-muted">En az 6 karakter uzunluğunda yeni şifrenizi girin.</p>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Yeni Şifre</label>
                                <div class="input-group">
                                    <input type="password" id="newPassword" class="form-control"
                                        placeholder="Yeni şifreniz" minlength="6" required>
                                    <button class="btn btn-outline-secondary" type="button" id="togglePassword1">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold">Yeni Şifre Tekrar</label>
                                <input type="password" id="confirmPassword" class="form-control"
                                    placeholder="Şifrenizi tekrar girin" minlength="6" required>
                            </div>

                            <div id="step3Error" class="alert alert-danger" style="display: none;"></div>

                            <button type="button" id="resetPasswordBtn" class="btn btn-success btn-lg w-100">
                                <i class="fas fa-save me-2"></i>Şifreyi Güncelle
                            </button>
                        </div>

                        <!-- Success Message -->
                        <div id="successStep" class="step-content" style="display: none;">
                            <div class="text-center py-4">
                                <i class="fas fa-check-circle fa-5x text-success mb-4"></i>
                                <h4 class="fw-bold text-success">Şifreniz Güncellendi!</h4>
                                <p class="text-muted">Yeni şifrenizle giriş yapabilirsiniz.</p>
                                <a href="login.php" class="btn btn-primary btn-lg mt-3">
                                    <i class="fas fa-sign-in-alt me-2"></i>Giriş Yap
                                </a>
                            </div>
                        </div>

                        <!-- Loading State -->
                        <div id="loadingState" style="display: none;">
                            <div class="text-center py-4">
                                <div class="spinner mb-3"></div>
                                <p class="text-muted" id="loadingText">İşlem yapılıyor...</p>
                            </div>
                        </div>

                        <hr class="my-4">

                        <p class="text-center text-muted mb-0">
                            <a href="login.php" class="text-primary"><i class="fas fa-arrow-left me-1"></i>Giriş
                                Sayfasına Dön</a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<style>
    .step-circle {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
    }

    .step-item.active .step-circle {
        background-color: var(--bs-primary) !important;
    }

    .step-item.completed .step-circle {
        background-color: var(--bs-success) !important;
    }
</style>

<script type="module">
    import { getFirestore, collection, doc, getDoc, setDoc, updateDoc, deleteDoc, Timestamp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';
    import { getAuth, createUserWithEmailAndPassword } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';

    let currentPhone = '';

    window.addEventListener('firebaseReady', function () {
        const db = window.firebaseDb;
        const auth = window.firebaseAuth;

        // Send OTP Button
        document.getElementById('sendOtpBtn').addEventListener('click', () => handleSendOtp(db));

        // Verify OTP Button
        document.getElementById('verifyOtpBtn').addEventListener('click', () => handleVerifyOtp(db));

        // Resend OTP Button
        document.getElementById('resendOtpBtn').addEventListener('click', () => handleSendOtp(db));

        // Reset Password Button
        document.getElementById('resetPasswordBtn').addEventListener('click', () => handleResetPassword(db, auth));

        // Toggle Password Visibility
        document.getElementById('togglePassword1').addEventListener('click', function () {
            const input = document.getElementById('newPassword');
            const icon = this.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.classList.replace('fa-eye', 'fa-eye-slash');
            } else {
                input.type = 'password';
                icon.classList.replace('fa-eye-slash', 'fa-eye');
            }
        });
    });

    async function handleSendOtp(db) {
        const phone = document.getElementById('phoneNumber').value.replace(/\D/g, '');

        if (phone.length !== 10) {
            showError('step1Error', 'Lütfen geçerli bir telefon numarası girin.');
            return;
        }

        showLoading(true, 'Kontrol ediliyor...');
        hideError('step1Error');

        try {
            // Check if phone exists in users collection
            const usersRef = collection(db, 'users');
            const { query, where, getDocs } = await import('https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js');
            const q = query(usersRef, where('phone', '==', phone));
            const snapshot = await getDocs(q);

            if (snapshot.empty) {
                showLoading(false);
                showError('step1Error', 'Bu numara ile kayıtlı hesap bulunamadı.');
                return;
            }

            // Check user type
            const userData = snapshot.docs[0].data();
            if (userData.userType !== 'firm') {
                showLoading(false);
                showError('step1Error', 'Bu numara firma hesabı değil. Müşteri şifre sıfırlama için müşteri sayfasını kullanın.');
                return;
            }

            // Check rate limiting
            const resetDocRef = doc(db, 'password_reset_requests', phone);
            const resetDoc = await getDoc(resetDocRef);
            const now = new Date();
            const todayStr = now.toISOString().split('T')[0];

            if (resetDoc.exists()) {
                const data = resetDoc.data();
                const lastRequest = data.createdAt?.toDate();

                // 20 minute limit
                if (lastRequest && (now - lastRequest) / 60000 < 20) {
                    const remaining = Math.ceil(20 - (now - lastRequest) / 60000);
                    showLoading(false);
                    showError('step1Error', `Çok sık deneme. ${remaining} dakika sonra tekrar deneyin.`);
                    return;
                }

                // Daily limit
                if (data.dailyResetDate === todayStr && data.dailyCount >= 5) {
                    showLoading(false);
                    showError('step1Error', 'Günlük limit aşıldı. Yarın tekrar deneyin.');
                    return;
                }
            }

            // Generate OTP
            const otp = Math.floor(100000 + Math.random() * 900000).toString();
            const dailyCount = resetDoc.exists() && resetDoc.data()?.dailyResetDate === todayStr
                ? (resetDoc.data()?.dailyCount || 0) + 1
                : 1;

            // Save to Firestore
            await setDoc(resetDocRef, {
                phone: phone,
                otp: otp,
                createdAt: Timestamp.now(),
                expiresAt: Timestamp.fromDate(new Date(now.getTime() + 10 * 60000)),
                verified: false,
                attempts: 0,
                dailyCount: dailyCount,
                dailyResetDate: todayStr
            });

            // Send SMS via Tapsin (using PHP proxy)
            const smsResponse = await fetch('../api/send-reset-sms.php', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ phone: phone, otp: otp })
            });

            const smsResult = await smsResponse.json();

            if (!smsResult.success) {
                showLoading(false);
                showError('step1Error', 'SMS gönderilemedi. Lütfen tekrar deneyin.');
                return;
            }

            currentPhone = phone;
            showLoading(false);
            goToStep(2);

        } catch (error) {
            console.error('Send OTP Error:', error);
            showLoading(false);
            showError('step1Error', 'Bir hata oluştu. Lütfen tekrar deneyin.');
        }
    }

    async function handleVerifyOtp(db) {
        const otp = document.getElementById('otpCode').value.trim();

        if (otp.length !== 6) {
            showError('step2Error', 'Lütfen 6 haneli kodu girin.');
            return;
        }

        showLoading(true, 'Doğrulanıyor...');
        hideError('step2Error');

        try {
            const resetDocRef = doc(db, 'password_reset_requests', currentPhone);
            const resetDoc = await getDoc(resetDocRef);

            if (!resetDoc.exists()) {
                showLoading(false);
                showError('step2Error', 'Şifre sıfırlama isteği bulunamadı.');
                return;
            }

            const data = resetDoc.data();

            // Check attempts
            if (data.attempts >= 3) {
                showLoading(false);
                showError('step2Error', 'Çok fazla yanlış deneme. Yeniden kod isteyin.');
                return;
            }

            // Check expiration
            if (data.expiresAt?.toDate() < new Date()) {
                showLoading(false);
                showError('step2Error', 'Kodun süresi dolmuş. Yeniden kod isteyin.');
                return;
            }

            // Verify OTP
            if (data.otp !== otp) {
                await updateDoc(resetDocRef, { attempts: (data.attempts || 0) + 1 });
                showLoading(false);
                showError('step2Error', `Yanlış kod. ${2 - data.attempts} deneme hakkınız kaldı.`);
                return;
            }

            // Mark as verified
            await updateDoc(resetDocRef, { verified: true });

            showLoading(false);
            goToStep(3);

        } catch (error) {
            console.error('Verify OTP Error:', error);
            showLoading(false);
            showError('step2Error', 'Bir hata oluştu.');
        }
    }

    async function handleResetPassword(db, auth) {
        const newPassword = document.getElementById('newPassword').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        if (newPassword.length < 6) {
            showError('step3Error', 'Şifre en az 6 karakter olmalı.');
            return;
        }

        if (newPassword !== confirmPassword) {
            showError('step3Error', 'Şifreler eşleşmiyor.');
            return;
        }

        showLoading(true, 'Şifre güncelleniyor...');
        hideError('step3Error');

        try {
            const resetDocRef = doc(db, 'password_reset_requests', currentPhone);
            const resetDoc = await getDoc(resetDocRef);

            if (!resetDoc.exists() || !resetDoc.data().verified) {
                showLoading(false);
                showError('step3Error', 'Önce doğrulama kodunu girin.');
                return;
            }

            // Store new password in pending_password_changes collection
            // This will be processed when user tries to login
            await setDoc(doc(db, 'pending_password_changes', currentPhone), {
                email: currentPhone + '@haliyikamaci.app',
                newPassword: newPassword,
                createdAt: Timestamp.now(),
                processed: false
            });

            // Clean up reset request
            await deleteDoc(resetDocRef);

            showLoading(false);

            // Show success
            document.querySelectorAll('.step-content').forEach(el => el.style.display = 'none');
            document.getElementById('successStep').style.display = 'block';

        } catch (error) {
            console.error('Reset Password Error:', error);
            showLoading(false);
            showError('step3Error', 'Şifre güncellenirken hata oluştu.');
        }
    }

    function goToStep(step) {
        document.querySelectorAll('.step-content').forEach(el => el.style.display = 'none');
        document.getElementById(`step${step}`).style.display = 'block';

        // Update indicators
        for (let i = 1; i <= 3; i++) {
            const indicator = document.getElementById(`step${i}Indicator`);
            const circle = indicator.querySelector('.step-circle');
            indicator.classList.remove('active', 'completed');
            circle.classList.remove('bg-primary', 'bg-success', 'bg-secondary');

            if (i < step) {
                indicator.classList.add('completed');
                circle.classList.add('bg-success');
            } else if (i === step) {
                indicator.classList.add('active');
                circle.classList.add('bg-primary');
            } else {
                circle.classList.add('bg-secondary');
            }
        }
    }

    function showLoading(show, text = 'İşlem yapılıyor...') {
        document.querySelectorAll('.step-content').forEach(el => {
            if (show) el.style.display = 'none';
        });
        document.getElementById('loadingState').style.display = show ? 'block' : 'none';
        document.getElementById('loadingText').textContent = text;
        if (!show) {
            // Re-show current step
            const activeStep = document.querySelector('.step-item.active');
            if (activeStep) {
                const stepNum = activeStep.id.replace('step', '').replace('Indicator', '');
                document.getElementById(`step${stepNum}`).style.display = 'block';
            } else {
                document.getElementById('step1').style.display = 'block';
            }
        }
    }

    function showError(elementId, message) {
        const el = document.getElementById(elementId);
        el.textContent = message;
        el.style.display = 'block';
    }

    function hideError(elementId) {
        document.getElementById(elementId).style.display = 'none';
    }
</script>

<?php require_once '../includes/footer.php'; ?>