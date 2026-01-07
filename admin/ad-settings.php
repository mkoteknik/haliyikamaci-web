<?php
/**
 * Halı Yıkamacı - Reklam Ayarları
 */
require_once '../config/app.php';
$pageTitle = 'Reklam Ayarları';
require_once 'includes/header.php';
?>

<div class="page-header">
    <h4 class="mb-0"><i class="fas fa-ad me-2"></i>Reklam Yönetimi</h4>
</div>

<div class="page-body">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card shadow-sm border-0">
                <div class="card-body p-4">

                    <div class="d-flex align-items-center mb-4">
                        <div class="bg-primary bg-opacity-10 rounded p-3 me-3">
                            <i class="fas fa-cog fa-2x text-primary"></i>
                        </div>
                        <div>
                            <h5 class="mb-1">Genel Ayarlar</h5>
                            <p class="text-muted mb-0 small">Uygulama genel ayarlarını ve reklam kimliklerini buradan
                                yönetebilirsiniz.</p>
                        </div>
                    </div>

                    <form id="adSettingsForm">
                        <!-- Firm Panel URL -->
                        <div class="mb-4">
                            <label class="form-label">Firma Panel Linki (Web Arayüzü)</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-link"></i></span>
                                <input type="url" class="form-control" id="firmPanelUrl"
                                    placeholder="https://haliyikamaci.app/panel">
                            </div>
                            <div class="form-text">Firma profilindeki "Web Arayüzü" butonu bu adrese yönlendirir.</div>
                        </div>

                        <hr class="my-4">

                        <h5 class="mb-3">Reklam Ayarları</h5>
                        <div class="alert alert-info d-flex align-items-center mb-4">
                            <i class="fas fa-info-circle me-2 flex-shrink-0"></i>
                            <small>Önemli Not: Uygulama Kimliği (App ID) genellikle sabittir. Banner ID dinamik olarak
                                değişebilir.</small>
                        </div>

                        <!-- App ID (Read-only/Editable) -->
                        <div class="mb-3">
                            <label class="form-label">Uygulama Kimliği (App ID)</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-fingerprint"></i></span>
                                <input type="text" class="form-control" id="adAppId" placeholder="ca-app-pub-...">
                            </div>
                        </div>

                        <!-- Banner Unit ID -->
                        <div class="mb-4">
                            <label class="form-label">Banner Reklam Birimi Kimliği</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="fas fa-ad"></i></span>
                                <input type="text" class="form-control" id="adBannerId" placeholder="ca-app-pub-...">
                            </div>
                            <div class="form-text">Sayfaların altında görünen banner reklamları için kullanılır.</div>
                        </div>

                        <!-- Test Mode Switch -->
                        <div class="mb-4">
                            <div class="form-check form-switch ps-0">
                                <label class="form-check-label ms-5 fw-bold" for="isTestMode">Test Modu</label>
                                <input class="form-check-input ms-0" type="checkbox" id="isTestMode"
                                    style="width: 3em; height: 1.5em;">
                                <div class="form-text mt-2 ms-0">Geliştirme sırasında gerçek reklamlar yerine test
                                    reklamları gösterilir. Yayına alırken kapatın.</div>
                            </div>
                        </div>

                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary" id="saveBtn">
                                <i class="fas fa-save me-2"></i>Kaydet ve Güncelle
                            </button>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </div>
</div>

</div> <!-- Closing Main Content -->
</div> <!-- Closing Main Layout -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
    import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, doc, getDoc, setDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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

    const SETTINGS_DOC_REF = doc(db, 'system_settings', 'config');

    onAuthStateChanged(auth, async (user) => {
        if (!user) { window.location.href = 'login.php'; return; }
        document.getElementById('authCheck').classList.add('d-none');
        document.getElementById('mainLayout').style.display = 'block';
        loadSettings();
    });

    async function loadSettings() {
        try {
            const docSnap = await getDoc(SETTINGS_DOC_REF);
            if (docSnap.exists()) {
                const data = docSnap.data();

                // Firm Panel URL
                document.getElementById('firmPanelUrl').value = data.firmPanelUrl || '';

                // AdMob Settings
                const admob = data.admob || {};
                document.getElementById('adAppId').value = admob.appId || '';
                document.getElementById('adBannerId').value = admob.bannerUnitId || '';
                document.getElementById('isTestMode').checked = admob.isTestMode === true;
            }
        } catch (error) {
            console.error("Error loading settings:", error);
            Swal.fire('Hata', 'Ayarlar yüklenirken bir sorun oluştu.', 'error');
        }
    }

    document.getElementById('adSettingsForm').addEventListener('submit', async (e) => {
        e.preventDefault();

        const btn = document.getElementById('saveBtn');
        const originalText = btn.innerHTML;
        btn.disabled = true;
        btn.innerHTML = '<div class="spinner-border spinner-border-sm me-2"></div>Kaydediliyor...';

        try {
            const settingsData = {
                firmPanelUrl: document.getElementById('firmPanelUrl').value.trim(),
                admob: {
                    appId: document.getElementById('adAppId').value.trim(),
                    bannerUnitId: document.getElementById('adBannerId').value.trim(),
                    isTestMode: document.getElementById('isTestMode').checked
                }
            };

            await setDoc(SETTINGS_DOC_REF, settingsData, { merge: true });

            Swal.fire({
                icon: 'success',
                title: 'Başarılı',
                text: 'Ayarlar başarıyla güncellendi!',
                timer: 1500,
                showConfirmButton: false
            });

        } catch (error) {
            console.error("Error saving settings:", error);
            Swal.fire('Hata', 'Kaydetme sırasında bir hata oluştu: ' + error.message, 'error');
        } finally {
            btn.disabled = false;
            btn.innerHTML = originalText;
        }
    });
</script>
</body>

</html>