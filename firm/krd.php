<?php
/**
 * Halı Yıkamacı - Firma SMS
 */

require_once '../config/app.php';

// EFT Bilgilerini Ayarlardan Çek
$configFile = __DIR__ . '/../config/paytr_settings.php';
$paytrConfig = file_exists($configFile) ? require $configFile : [];
$eftInfo = $paytrConfig['eft_info'] ?? 'Banka bilgileri için lütfen iletişime geçiniz.';
$pageTitle = 'KRD Yönetimi';
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
                <span class="fw-bold">KRD</span>
                <div></div>
            </div>

            <div class="page-header">
                <h4 class="mb-0"><i class="fas fa-coins me-2"></i>KRD Yönetimi</h4>
            </div>

            <div class="page-body">
                <!-- Balance Card -->
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col-md-6">
                                <div class="d-flex align-items-center">
                                    <div class="rounded-circle p-4 me-4" id="balanceIcon"
                                        style="background: rgba(40, 167, 69, 0.1);">
                                        <i class="fas fa-coins fa-3x" style="color: #28a745;"></i>
                                    </div>
                                    <div>
                                        <small class="text-muted d-block">Mevcut Bakiye</small>
                                        <h1 class="mb-0" id="smsBalance">-</h1>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="bg-light rounded p-3">
                                    <h6 class="mb-2">KRD Kullanım Alanları</h6>
                                    <div class="d-flex justify-content-between text-muted small mb-1">
                                        <span><i class="fas fa-tags me-1"></i>Kampanya Oluşturma</span>
                                        <span>5 KRD</span>
                                    </div>
                                    <div class="d-flex justify-content-between text-muted small mb-1">
                                        <span><i class="fas fa-ad me-1"></i>Vitrin Paketi</span>
                                        <span>Pakete Göre</span>
                                    </div>
                                    <div class="d-flex justify-content-between text-muted small">
                                        <span><i class="fas fa-envelope me-1"></i>Müşteriye SMS</span>
                                        <span>1 KRD</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- How It Works -->
                <div class="alert alert-info mb-4">
                    <h6><i class="fas fa-info-circle me-2"></i>Nasıl Çalışır?</h6>
                    <ol class="mb-0 ps-3">
                        <li>Aşağıdan bir KRD paketi seçin</li>
                        <li>"Satın Al" butonuna tıklayın</li>
                        <li>Admin onayından sonra bakiyeniz güncellenir</li>
                    </ol>
                </div>

                <!-- Packages -->
                <h5 class="mb-3">KRD Paketleri</h5>
                <div class="row g-4" id="smsPackages">
                    <div class="col-12 text-center py-4">
                        <div class="spinner"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Purchase Modal -->
    <div class="modal fade" id="purchaseModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">KRD Paketi Satın Al</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <!-- Standard Purchase View -->
                    <div id="purchaseModalBodyContent">
                        <div class="text-center mb-4">
                            <div class="bg-primary bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3"
                                style="width: 80px; height: 80px;">
                                <i class="fas fa-coins fa-2x text-primary"></i>
                            </div>
                            <h4 id="modalPackageName">-</h4>
                            <p class="text-muted" id="modalPackageDetails">-</p>
                        </div>

                        <div class="bg-light rounded p-3 mb-3">
                            <div class="d-flex justify-content-between mb-2">
                                <span>KRD Adedi:</span>
                                <strong id="modalSmsCount">-</strong>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span>Tutar:</span>
                                <strong class="text-primary" id="modalPrice">-</strong>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label d-block fw-bold">Ödeme Yöntemi</label>

                            <div class="form-check p-3 border rounded mb-2 cursor-pointer bg-white">
                                <input class="form-check-input" type="radio" name="paymentMethod" id="methodCC"
                                    value="cc" checked>
                                <label class="form-check-label d-flex justify-content-between w-100 cursor-pointer"
                                    for="methodCC">
                                    <span><i class="fas fa-credit-card me-2 text-primary"></i>Kredi Kartı ile Öde
                                        (Anında Yüklenir)</span>
                                    <i class="fas fa-check-circle text-success" id="iconCC"></i>
                                </label>
                            </div>

                            <div class="form-check p-3 border rounded cursor-pointer bg-white">
                                <input class="form-check-input" type="radio" name="paymentMethod" id="methodEFT"
                                    value="eft">
                                <label class="form-check-label d-flex justify-content-between w-100 cursor-pointer"
                                    for="methodEFT">
                                    <span><i class="fas fa-university me-2 text-secondary"></i>Havale / EFT Bildirimi
                                        (Admin Onayı Gerekir)</span>
                                </label>
                            </div>

                            <!-- Dynamic EFT Info -->
                            <div id="eftInfoBox" class="alert alert-secondary mt-3 border-0 bg-light"
                                style="display: none;">
                                <h6 class="alert-heading fw-bold small text-uppercase"><i
                                        class="fas fa-info-circle me-2"></i>Banka Hesap Bilgileri</h6>
                                <div class="small text-dark mb-2"
                                    style="white-space: pre-wrap; font-family: monospace;">
                                    <?php echo isset($eftInfo) ? $eftInfo : ''; ?>
                                </div>
                                <hr>
                                <p class="mb-0 small text-danger fw-bold"><i
                                        class="fas fa-exclamation-circle me-1"></i>Lütfen ödemeyi yaptıktan sonra "Ödeme
                                    Bildirimi Yap" butonuna basınız.</p>
                            </div>
                            <!-- Legal Agreements -->
                            <div class="mb-3">
                                <div class="form-check">
                                    <input class="form-check-input" type="checkbox" id="agreementCheck">
                                    <label class="form-check-label small" for="agreementCheck">
                                        <a href="#" id="openPreInfoLink" class="text-decoration-underline">Ön
                                            Bilgilendirme Formu</a> ve
                                        <a href="#" id="openAgreementLink" class="text-decoration-underline">Mesafeli
                                            Satış Sözleşmesi</a>'ni okudum ve onaylıyorum.
                                    </label>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- PayTR Iframe Container -->
                    <div id="paytrIframeContainer" style="display: none; min-height: 400px;">
                        <iframe id="paytriframe" frameborder="0" scrolling="no" style="width: 100%;"></iframe>
                    </div>

                </div>
                <div class="modal-footer" id="modalFooter">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                    <button type="button" class="btn btn-primary" id="confirmPurchaseBtn" disabled>
                        <i class="fas fa-check me-1"></i>Ödemeye Geç
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Legal Document Modal -->
    <div class="modal fade" id="legalDocModal" tabindex="-1" style="z-index: 1060;">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="legalModalTitle">Sözleşme</h5>
                    <button type="button" class="btn-close" onclick="closeLegalModal()"></button>
                </div>
                <div class="modal-body">
                    <div id="legalDocContent" class="p-3 bg-light rounded">Yükleniyor...</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primary" onclick="acceptLegalDoc()">Okudum, Anladım</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- Marked.js for Markdown parsing -->
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, query, where, addDoc, doc, getDoc, limit } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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

        window.firebaseAuth = auth;
        window.firebaseDb = db;

        // Mobile Token Check
        const urlParams = new URLSearchParams(window.location.search);
        const mobileToken = urlParams.get('mobile_token');

        async function validateMobileToken(token) {
            try {
                const res = await fetch('../api/check_token.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ token: token })
                });
                const data = await res.json();
                if (data.status === 'success' && data.uid) {
                    return data.uid;
                }
            } catch (e) {
                console.error('Token validation error:', e);
            }
            return null;
        }

        async function loadFirmByUid(uid) {
            const firmsRef = collection(db, 'firms');
            const q = query(firmsRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);
            if (!snapshot.empty) {
                return { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
            }
            return null;
        }

        async function initPage(firm) {
            currentFirm = firm;
            document.getElementById('smsBalance').textContent = (currentFirm.smsBalance || 0);
            document.getElementById('authCheck').classList.add('d-none');
            document.getElementById('mainLayout').style.display = 'block';
            loadPackages();
        }

        // If mobile token exists, validate and load directly
        if (mobileToken) {
            (async () => {
                const uid = await validateMobileToken(mobileToken);
                if (uid) {
                    const firm = await loadFirmByUid(uid);
                    if (firm) {
                        await initPage(firm);
                        return;
                    }
                }
                // Token invalid or firm not found
                alert('Oturum süresi dolmuş. Lütfen tekrar deneyin.');
                window.location.href = './login.php';
            })();
        } else {
            // Normal Firebase Auth Flow
            onAuthStateChanged(auth, async (user) => {
                if (!user) {
                    window.location.href = './login.php';
                    return;
                }

                try {
                    const firm = await loadFirmByUid(user.uid);
                    if (!firm) {
                        window.location.href = './login.php';
                        return;
                    }
                    await initPage(firm);
                } catch (error) {
                    console.error('Error loading firm data:', error);
                    alert('Veriler yüklenirken bir hata oluştu.');
                }
            });
        }

        async function loadPackages() {
            try {
                const packagesRef = collection(db, 'smsPackages'); // Using existing collection
                const snapshot = await getDocs(packagesRef);
                const packages = [];
                snapshot.forEach(doc => packages.push({ id: doc.id, ...doc.data() }));

                // Sort by price (asc) or count
                packages.sort((a, b) => a.smsCount - b.smsCount);

                const container = document.getElementById('smsPackages');
                if (packages.length === 0) {
                    container.innerHTML = '<div class="col-12 text-center p-5 text-muted">Paket bulunamadı.</div>';
                    return;
                }

                container.innerHTML = packages.map(pkg => `
                    <div class="col-md-6 col-lg-4">
                        <div class="card h-100 border-0 shadow-sm ${pkg.isPopular ? 'border-primary border-2' : ''}">
                             ${pkg.isPopular ? '<div class="card-header bg-primary text-white text-center py-2"><small>Popüler</small></div>' : ''}
                            <div class="card-body text-center">
                                <h5>${pkg.name}</h5>
                                <div class="my-3">
                                    <span class="display-4 fw-bold text-primary">${pkg.smsCount}</span>
                                    <span class="text-muted d-block">KRD</span>
                                </div>
                                <h4 class="text-success">${formatPrice(pkg.price)}</h4>
                                <p class="text-muted small mt-2">${pkg.description || ''}</p>
                            </div>
                            <div class="card-footer bg-white border-0 pb-3">
                                <button class="btn btn-primary w-100 btn-purchase" data-id="${pkg.id}">
                                    Satın Al
                                </button>
                            </div>
                        </div>
                    </div>
                `).join('');

                // Attach listeners
                document.querySelectorAll('.btn-purchase').forEach(btn => {
                    btn.addEventListener('click', () => {
                        const pkg = packages.find(p => p.id === btn.dataset.id);
                        openPurchaseModal(pkg);
                    });
                });
            } catch (error) {
                console.error('Error loading packages', error);
            }
        }

        function openPurchaseModal(pkg) {
            selectedPackage = pkg;
            document.getElementById('modalPackageName').textContent = pkg.name;
            document.getElementById('modalPackageDetails').textContent = pkg.description || '';
            document.getElementById('modalSmsCount').textContent = pkg.smsCount;
            document.getElementById('modalPrice').textContent = formatPrice(pkg.price);

            // Default reset
            document.getElementById('agreementCheck').checked = false;
            document.getElementById('confirmPurchaseBtn').disabled = true;
            document.getElementById('methodCC').checked = true;
            document.getElementById('paytrIframeContainer').style.display = 'none';
            document.getElementById('purchaseModalBodyContent').style.display = 'block';
            document.getElementById('modalFooter').style.display = 'flex';

            purchaseModalInstance.show();
        }

        let currentFirm = null;
        let selectedPackage = null;

        // Cache for docs
        let docCache = {
            distance_sales_agreement: '',
            preliminary_info_form: ''
        };

        // Legal Modal Logic
        const purchaseModalEl = document.getElementById('purchaseModal');
        const legalModalEl = document.getElementById('legalDocModal');
        let purchaseModalInstance = null;
        let legalModalInstance = null;

        document.addEventListener('DOMContentLoaded', () => {
            purchaseModalInstance = new bootstrap.Modal(purchaseModalEl);
            legalModalInstance = new bootstrap.Modal(legalModalEl);
        });

        // Toggle Payment Button based on Checkbox
        document.getElementById('agreementCheck').addEventListener('change', (e) => {
            const btn = document.getElementById('confirmPurchaseBtn');
            btn.disabled = !e.target.checked;
        });

        async function openLegalDoc(type, title) {
            document.getElementById('legalModalTitle').textContent = title;
            document.getElementById('legalDocContent').innerHTML = '<div class="text-center"><div class="spinner-border"></div></div>';

            // Stack Modals: Hide Purchase, Show Legal
            purchaseModalInstance.hide();
            legalModalInstance.show();

            let rawContent = '';

            // Fetch content if not cached
            if (!docCache[type]) {
                try {
                    const q = query(
                        collection(db, 'legalDocuments'),
                        where('type', '==', type),
                        where('isActive', '==', true),
                        limit(1)
                    );
                    const snapshot = await getDocs(q);
                    if (!snapshot.empty) {
                        rawContent = snapshot.docs[0].data().content || 'İçerik bulunamadı';
                        docCache[type] = rawContent;
                    } else {
                        rawContent = type === 'preliminary_info_form'
                            ? 'Ön Bilgilendirme Formu henüz tanımlanmamış.'
                            : 'Sözleşme bulunamadı.';
                        docCache[type] = rawContent;
                    }
                } catch (err) {
                    console.error(err);
                    rawContent = 'Doküman yüklenirken hata oluştu.';
                    docCache[type] = rawContent;
                }
            } else {
                rawContent = docCache[type];
            }

            // --- DYNAMIC VARIABLE REPLACEMENT ---
            const dateStr = new Date().toLocaleDateString('tr-TR');
            const priceStr = formatPrice(selectedPackage ? selectedPackage.price : 0);
            const packageName = selectedPackage ? selectedPackage.name : '-';

            let filledContent = rawContent
                .replace(/{FirmaAdi}/g, currentFirm.name || 'Firma')
                .replace(/{Adres}/g, currentFirm.address || '-')
                .replace(/{Telefon}/g, currentFirm.phone || '-')
                .replace(/{Tarih}/g, dateStr)
                .replace(/{Tutar}/g, priceStr)
                .replace(/{PaketAdi}/g, packageName);

            // Parse Markdown
            document.getElementById('legalDocContent').innerHTML = marked.parse(filledContent);
        }

        // Open Agreement Modal
        document.getElementById('openAgreementLink').addEventListener('click', (e) => {
            e.preventDefault();
            openLegalDoc('distance_sales_agreement', 'Mesafeli Satış Sözleşmesi');
        });

        // Open Preliminary Info Modal
        document.getElementById('openPreInfoLink').addEventListener('click', (e) => {
            e.preventDefault();
            openLegalDoc('preliminary_info_form', 'Ön Bilgilendirme Formu');
        });

        window.closeLegalModal = function () {
            legalModalInstance.hide();
            purchaseModalInstance.show();
        }

        window.acceptLegalDoc = function () {
            legalModalInstance.hide();
            purchaseModalInstance.show();
        }


        // GENERATE SNAPSHOTS HELPER
        async function getLegalSnapshots() {
            // Ensure we have the raw content loaded
            if (!docCache['distance_sales_agreement'] || !docCache['preliminary_info_form']) {
                // Fetch both if missing (quick lazy load)
                // For simplicity in this flow, we assume they might not be loaded if user didn't click.
                // Ideally we force load or accept that we save what we have.
                // Correct approach: Fetch fresh for snapshot
                const types = ['distance_sales_agreement', 'preliminary_info_form'];
                for (const t of types) {
                    if (!docCache[t]) {
                        const q = query(collection(db, 'legalDocuments'), where('type', '==', t), limit(1));
                        const snap = await getDocs(q);
                        docCache[t] = !snap.empty ? snap.docs[0].data().content : '';
                    }
                }
            }

            const dateStr = new Date().toLocaleDateString('tr-TR');
            const priceStr = formatPrice(selectedPackage.price);

            const replacer = (text) => text
                .replace(/{FirmaAdi}/g, currentFirm.name || 'Firma')
                .replace(/{Adres}/g, currentFirm.address || '-')
                .replace(/{Telefon}/g, currentFirm.phone || '-')
                .replace(/{Tarih}/g, dateStr)
                .replace(/{Tutar}/g, priceStr)
                .replace(/{PaketAdi}/g, selectedPackage.name);

            return {
                agreementSnapshot: replacer(docCache['distance_sales_agreement'] || ''),
                preInfoSnapshot: replacer(docCache['preliminary_info_form'] || '')
            };
        }


        document.getElementById('confirmPurchaseBtn').addEventListener('click', async () => {
            if (!selectedPackage) return;

            // Double check acceptance
            if (!document.getElementById('agreementCheck').checked) {
                Swal.fire('Uyarı', 'Lütfen Mesafeli Satış Sözleşmesi\'ni onaylayın.', 'warning');
                return;
            }

            const method = document.querySelector('input[name="paymentMethod"]:checked').value;
            const btn = document.getElementById('confirmPurchaseBtn');

            // Generate Legal Snapshots
            const snapshots = await getLegalSnapshots();

            if (method === 'cc') {
                // --- PAYTR ENTGRASYONU ---
                try {
                    btn.disabled = true;
                    btn.innerHTML = '<div class="spinner-border spinner-border-sm"></div> İşlem Başlatılıyor...';

                    // 1. Sipariş Kaydı Oluştur (Pending)
                    const docRef = await addDoc(collection(db, 'smsPurchases'), {
                        firmId: currentFirm.id,
                        firmName: currentFirm.name,
                        packageId: selectedPackage.id,
                        packageName: selectedPackage.name,
                        smsCount: selectedPackage.smsCount,
                        price: selectedPackage.price,
                        status: 'pending_payment', // Ödeme Bekliyor
                        paymentMethod: 'cc',
                        agreementAccepted: true,
                        agreementSnapshot: snapshots.agreementSnapshot, // STORED FOREVER
                        preInfoSnapshot: snapshots.preInfoSnapshot,     // STORED FOREVER
                        createdAt: new Date()
                    });

                    // 2. Token İste (Sipariş ID = Doc ID)
                    const res = await fetch('../api/paytr/get_token.php', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            merchant_oid: docRef.id,
                            email: currentFirm.email || 'info@example.com',
                            payment_amount: selectedPackage.price,
                            user_name: currentFirm.name || 'Firma Sahibi',
                            user_address: currentFirm.address || 'Adres Girilmemiş',
                            user_phone: currentFirm.phone || '05555555555',
                            user_basket: [[selectedPackage.name, selectedPackage.price, 1]]
                        })
                    });

                    const data = await res.json();

                    if (data.status === 'success') {
                        showPayTRIframe(data.token);
                        document.getElementById('modalFooter').style.display = 'none';
                    } else {
                        alert('Ödeme başlatılamadı: ' + data.message);
                        btn.disabled = false;
                        btn.innerHTML = '<i class="fas fa-check me-1"></i>Ödemeye Geç';
                    }
                } catch (e) {
                    console.error(e);
                    alert('Hata oluştu: ' + e.message);
                    btn.disabled = false;
                    btn.innerHTML = '<i class="fas fa-check me-1"></i>Ödemeye Geç';
                }

            } else {
                // --- MANUEL HAVALE ---
                try {
                    await addDoc(collection(db, 'smsPurchases'), {
                        firmId: currentFirm.id,
                        firmName: currentFirm.name,
                        packageId: selectedPackage.id,
                        packageName: selectedPackage.name,
                        smsCount: selectedPackage.smsCount,
                        price: selectedPackage.price,
                        status: 'pending',
                        paymentMethod: 'eft',
                        agreementAccepted: true,
                        agreementSnapshot: snapshots.agreementSnapshot, // STORED FOREVER
                        preInfoSnapshot: snapshots.preInfoSnapshot,     // STORED FOREVER
                        createdAt: new Date()
                    });

                    bootstrap.Modal.getInstance(document.getElementById('purchaseModal')).hide();

                    Swal.fire({
                        title: 'Talep Alındı',
                        text: 'Satın alma talebiniz iletildi. Admin onayından sonra bakiyeniz güncellenecektir.',
                        icon: 'success'
                    });

                } catch (error) {
                    alert('Hata: ' + error.message);
                }
            }
        });

        function showPayTRIframe(token) {
            const container = document.getElementById('paytrIframeContainer');
            const modalBody = document.getElementById('purchaseModalBodyContent');

            modalBody.style.display = 'none';
            container.style.display = 'block';

            const iframe = document.getElementById('paytriframe');
            iframe.src = `https://www.paytr.com/odeme/guvenli/${token}`;

            // Load Iframe Resizer
            // Note: PayTR requires 'iframeResizer.min.js' to be loaded for dynamic height
            if (!window.iFrameResize) {
                const script = document.createElement('script');
                script.src = "https://www.paytr.com/js/iframeResizer.min.js";
                script.onload = function () {
                    window.iFrameResize({}, '#paytriframe');
                };
                document.head.appendChild(script);
            } else {
                window.iFrameResize({}, '#paytriframe');
            }
        }

        function formatPrice(price) {
            return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(price);
        }

        // Payment Method Toggle Logic
        document.querySelectorAll('input[name="paymentMethod"]').forEach(radio => {
            radio.addEventListener('change', (e) => {
                const val = e.target.value;
                const eftBox = document.getElementById('eftInfoBox');
                const btn = document.getElementById('confirmPurchaseBtn');

                if (val === 'eft') {
                    eftBox.style.display = 'block';
                    btn.innerHTML = '<i class="fas fa-paper-plane me-1"></i>Ödeme Bildirimi Yap';
                    btn.classList.replace('btn-primary', 'btn-success');
                } else {
                    eftBox.style.display = 'none';
                    btn.innerHTML = '<i class="fas fa-check me-1"></i>Ödemeye Geç';
                    btn.classList.replace('btn-success', 'btn-primary');
                }
            });
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
    </script>

</body>

</html>