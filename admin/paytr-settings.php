<?php
/**
 * Halı Yıkamacı - Admin PayTR Ayarları
 */

require_once '../config/app.php';
$pageTitle = 'PayTR Ayarları';

// Mevcut ayarları yükle
$configFile = __DIR__ . '/../config/paytr_settings.php';
$config = file_exists($configFile) ? require $configFile : [];

// Varsayılan değerler
$merchant_id = $config['merchant_id'] ?? '';
$merchant_key = $config['merchant_key'] ?? '';
$merchant_salt = $config['merchant_salt'] ?? '';
$eft_info = $config['eft_info'] ?? '';
$test_mode = $config['test_mode'] ?? 1;
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
                <span class="fw-bold">PayTR Ayarları</span>
                <div></div>
            </div>

            <div class="page-header">
                <h4 class="mb-0"><i class="fas fa-credit-card me-2"></i>PayTR ve Ödeme Ayarları</h4>
            </div>

            <div class="page-body">
                <div class="row">
                    <div class="col-lg-8">
                        <div class="card border-0 shadow-sm">
                            <div class="card-body p-4">
                                <div class="alert alert-info mb-4">
                                    <i class="fas fa-info-circle me-2"></i>
                                    Bu bilgiler PayTR Mağaza Paneli > <strong>Bilgi</strong> sayfasında yer almaktadır.
                                </div>

                                <form id="paytrSettingsForm">
                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Mağaza No (Merchant ID)</label>
                                        <input type="text" class="form-control" id="merchant_id" required
                                            placeholder="Örn: 123456"
                                            value="<?php echo htmlspecialchars($merchant_id); ?>">
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Mağaza Parola (Merchant Key)</label>
                                        <div class="input-group">
                                            <input type="password" class="form-control" id="merchant_key" required
                                                value="<?php echo htmlspecialchars($merchant_key); ?>">
                                            <button class="btn btn-outline-secondary" type="button"
                                                onclick="toggleVisibility('merchant_key')">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="mb-3">
                                        <label class="form-label fw-bold">Mağaza Gizli Anahtar (Merchant Salt)</label>
                                        <div class="input-group">
                                            <input type="password" class="form-control" id="merchant_salt" required
                                                value="<?php echo htmlspecialchars($merchant_salt); ?>">
                                            <button class="btn btn-outline-secondary" type="button"
                                                onclick="toggleVisibility('merchant_salt')">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="mb-4">
                                        <label class="form-label fw-bold">Çalışma Modu</label>
                                        <select class="form-select" id="test_mode">
                                            <option value="1" <?php echo $test_mode == 1 ? 'selected' : ''; ?>>Test Modu
                                                (Gerçek para çekilmez)</option>
                                            <option value="0" <?php echo $test_mode == 0 ? 'selected' : ''; ?>>Canlı Mod
                                                (Gerçek Ödeme)</option>
                                        </select>
                                        <small class="text-muted">Entegrasyonu test ederken "Test Modu" kullanın.
                                            Canlıya geçmeden önce PayTR panelinden canlı mod onayı almalısınız.</small>
                                    </div>

                                    <hr class="my-4">

                                    <h5 class="mb-3 text-secondary"><i class="fas fa-university me-2"></i>Havale / EFT
                                        Bilgileri</h5>
                                    <div class="mb-4">
                                        <label class="form-label fw-bold">Banka Hesap Bilgileri (IBAN)</label>
                                        <textarea class="form-control" id="eft_info" rows="5"
                                            placeholder="Banka Adı, IBAN, Alıcı Adı vb. bilgileri buraya giriniz..."><?php echo htmlspecialchars($eft_info); ?></textarea>
                                        <div class="form-text">Müşteriye Havale/EFT seçeneğinde gösterilecek metin. HTML
                                            etiketi kullanabilirsiniz (örn: &lt;br&gt;).</div>
                                    </div>

                                    <div class="d-grid">
                                        <button type="submit" class="btn btn-primary btn-lg" id="saveBtn">
                                            <i class="fas fa-save me-1"></i>Ayarları Kaydet
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm bg-light mb-3">
                            <div class="card-body">
                                <h6 class="fw-bold">Bildirim URL (Callback)</h6>
                                <p class="small text-muted">PayTR mağaza panelinizde "Bildirim URL" ayarını aşağıdaki
                                    adres yapmalısınız:</p>
                                <div class="bg-white p-2 rounded border font-monospace small mb-2 text-break">
                                    <?php echo SITE_URL; ?>/api/paytr/callback.php
                                </div>
                                <div class="alert alert-warning small mb-0">
                                    <i class="fas fa-exclamation-triangle me-1"></i>
                                    Localhost'ta çalışıyorsanız bu adres PayTR tarafından erişilemez. Canlı sunucuya
                                    geçtiğinizde çalışacaktır.
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged, signOut } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, doc, getDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

        // Firebase Config (Kopyaladım)
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

        onAuthStateChanged(auth, async (user) => {
            if (!user) {
                window.location.href = 'login.php';
                return;
            }

            const isAdmin = await checkIsAdmin(user.uid);
            if (!isAdmin) {
                window.location.href = 'login.php';
                return;
            }

            document.getElementById('authCheck').classList.add('d-none');
            document.getElementById('mainLayout').style.display = 'block';
        });

        async function checkIsAdmin(uid) {
            try {
                const userDoc = await getDoc(doc(db, 'users', uid));
                if (userDoc.exists()) {
                    return userDoc.data().userType === 'admin';
                }
                return false;
            } catch (error) {
                return false;
            }
        }

        window .toggleVisibility = function (id) {
            const el = document.getElementById(id);
            el.type = el.type === 'password' ? 'text' : 'password';
        }

        document.getElementById('paytrSettingsForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            
            const btn = document.getElementById('saveBtn');
            btn.disabled = true;
            btn.textContent = 'Kaydediliyor...';

            const data = {
                merchant_id: document.getElementById('merchant_id').value.trim(),
                merchant_key: document.getElementById('merchant_key').value.trim(),
                merchant_salt: document.getElementById('merchant_salt').value.trim(),
                eft_info: document.getElementById('eft_info').value.trim(),
                test_mode: document.getElementById('test_mode').value
            };

            try {
                const response = await fetch('../api/admin/save_paytr_config.php', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(data)
                });
                
                const result = await response.json();
                
                if (result.status === 'success') {
                    Swal.fire('Başarılı', 'Ayarlar kaydedildi.', 'success');
                } else {
                    Swal.fire('Hata', result.message || 'Bir sorun oluştu', 'error');
                }
            } catch (error) {
                Swal.fire('Hata', 'Sunucu hatası', 'error');
            } finally {
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-save me-1"></i>Ayarları Kaydet';
            }
        });

        // Sidebar toggle
        document.getElementById('sidebarToggle')?.addEventListener('click', () => {
            document.getElementById('sidebar').classList.toggle('show');
            document.getElementById('sidebarOverlay').classList.toggle('show');
        });

        document.getElementById('sidebarOverlay')?.addEventListener('click', () => {
            document.getElementById('sidebar').classList.remove('show');
            document.getElementById('sidebarOverlay').classList.remove('show');
        });

        window.doLogout = async function () {
            await signOut(auth);
            window.location.href = 'login.php';
        };
    </script>
</body>
</html>