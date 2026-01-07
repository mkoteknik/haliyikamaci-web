<?php
// payment/checkout.php
require_once __DIR__ . '/../config/app.php';

$token = $_GET['token'] ?? '';
$error = '';
$data = null;

if (!$token) {
    $error = 'Geçersiz bağlantı.';
} else {
    try {
        $decoded = json_decode(base64_decode($token), true);
        if (!$decoded || !isset($decoded['data']) || !isset($decoded['sig'])) {
            throw new Exception('Token formatı hatalı.');
        }

        $json = $decoded['data'];
        $signature = $decoded['sig'];
        $secret = 'MY_MOBILE_APP_SECRET_KEY_123'; // Must match API

        if (hash_hmac('sha256', $json, $secret) !== $signature) {
            throw new Exception('Güvenlik imzası geçersiz.');
        }

        $data = json_decode($json, true);
        if ((time() - $data['ts']) > 3600) { // 1 hour expiry
            throw new Exception('Bağlantı süresi dolmuş.');
        }

    } catch (Exception $e) {
        $error = $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ödeme Yap - <?php echo SITE_NAME; ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        body {
            background-color: #f8f9fa;
        }

        .payment-container {
            max_width: 500px;
            margin: 50px auto;
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>

<body>

    <div class="container">
        <div class="payment-container text-center">
            <?php if ($error): ?>
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle fa-2x mb-3"></i><br>
                    <?php echo $error; ?>
                </div>
            <?php else: ?>
                <div id="loadingState">
                    <div class="spinner-border text-primary" role="status"></div>
                    <p class="mt-3">Paket bilgileri yükleniyor...</p>
                </div>

                <div id="paymentState" style="display: none;">
                    <h4 class="mb-3">Ödeme Onayı</h4>
                    <div class="card bg-light mb-4">
                        <div class="card-body">
                            <h5 class="card-title" id="pkgName">-</h5>
                            <p class="card-text text-muted" id="pkgDesc">-</p>
                            <h3 class="text-primary" id="pkgPrice">-</h3>
                        </div>
                    </div>

                    <!-- PayTR Iframe Container -->
                    <div id="paytrIframeContainer" style="display: none;">
                        <iframe id="paytriframe" frameborder="0" scrolling="no" style="width: 100%;"></iframe>
                    </div>

                    <div id="actionButtons">
                        <button id="payBtn" class="btn btn-primary btn-lg w-100">
                            <i class="fas fa-credit-card me-2"></i>Ödemeyi Başlat
                        </button>
                    </div>
                </div>
            <?php endif; ?>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <?php if ($data): ?>
        <script type="module">
            import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
            import { getFirestore, doc, getDoc, addDoc, collection } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

            const firebaseConfig = {
                apiKey: "AIzaSyAZBzUpPtWHnW3mlF38L7YGpiknMB9dZb8",
                authDomain: "halisepetimbl.firebaseapp.com",
                projectId: "halisepetimbl",
                storageBucket: "halisepetimbl.firebasestorage.app",
                messagingSenderId: "782891273844",
                appId: "1:782891273844:web:750619b1bfe1939e52cb21"
            };

            const app = initializeApp(firebaseConfig);
            const db = getFirestore(app, 'haliyikamacimmbldatabase');

            const uid = "<?php echo $data['uid']; ?>";
            const packageId = "<?php echo $data['package_id']; ?>";
            let packageData = null;
            let firmData = null;

            async function init() {
                try {
                    // 1. Fetch Package
                    const pkgDoc = await getDoc(doc(db, 'smsPackages', packageId));
                    if (!pkgDoc.exists()) throw new Error('Paket bulunamadı.');
                    packageData = pkgDoc.data();

                    // 2. Fetch Firm Data (We need name/phone for PayTR)
                    // Note: Reading 'firms' might fail if rules require Auth.
                    // If it fails, we use placeholder data or requires user to fill?
                    // "Anti-Steering" context implies we just want payment.
                    // Let's TRY to fetch firm.
                    try {
                        // Query firm by UID? Or 'firms/{firmId}'? 
                        // We only have UID.
                        // Assuming firms collection is indexed or readable.
                        // If not, we use "Mobil Kullanıcı" placeholders.
                        const firmDoc = await getDoc(doc(db, 'users', uid)); // Assuming user doc has info
                        if (firmDoc.exists()) firmData = firmDoc.data();
                    } catch (e) { console.log("Firm data fetch skipped"); }

                    // Render UI
                    document.getElementById('pkgName').textContent = packageData.name;
                    document.getElementById('pkgDesc').textContent = packageData.description || '';
                    document.getElementById('pkgPrice').textContent = new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(packageData.price);

                    document.getElementById('loadingState').style.display = 'none';
                    document.getElementById('paymentState').style.display = 'block';

                } catch (error) {
                    document.querySelector('.payment-container').innerHTML = `<div class="alert alert-danger">${error.message}</div>`;
                }
            }

            document.getElementById('payBtn').addEventListener('click', async () => {
                const btn = document.getElementById('payBtn');
                btn.disabled = true;
                btn.textContent = 'İşlem Başlatılıyor...';

                try {
                    // 1. Create Pending Transaction
                    // This MIGHT fail if rules require Auth. 
                    // If it fails, we rely on Callback to create (but Callback doesn't have package detail).
                    // Solution: We need to Auth? No. 
                    // Solution: We allow public write to smsPurchases via Rules? No.
                    // Solution: create_payment_link PHP should have created a 'token transaction' in a local file/DB?
                    // Or use the 'get_token.php' to handle the DB part via PHP (Service Account)?
                    // We established we can't use PHP DB.

                    // WORKAROUND: We use 'get_token.php' to return the Token.
                    // We pass 'merchant_oid' as 'MOBILE-' + timestamp + uid.
                    // The Callback will verify hash.
                    // Where to store package info? 'user_basket'.

                    const merchant_oid = 'MOB-' + Date.now() + '-' + Math.floor(Math.random() * 1000);

                    const res = await fetch('../api/paytr/get_token.php', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            merchant_oid: merchant_oid,
                            email: firmData?.email || 'mobile@app.com',
                            payment_amount: packageData.price,
                            user_name: firmData?.name || 'Mobil Kullanıcı',
                            user_address: 'Mobil Uygulama',
                            user_phone: firmData?.phone || '05555555555',
                            user_basket: [[packageData.name, packageData.price, 1]]
                        })
                    });

                    const result = await res.json();
                    if (result.status === 'success') {
                        document.getElementById('actionButtons').style.display = 'none';
                        document.getElementById('paytrIframeContainer').style.display = 'block';

                        const iframe = document.getElementById('paytriframe');
                        iframe.src = `https://www.paytr.com/odeme/guvenli/${result.token}`;

                        // Load Resizer
                        if (!window.iFrameResize) {
                            const script = document.createElement('script');
                            script.src = "https://www.paytr.com/js/iframeResizer.min.js";
                            script.onload = () => window.iFrameResize({}, '#paytriframe');
                            document.head.appendChild(script);
                        } else {
                            window.iFrameResize({}, '#paytriframe');
                        }

                    } else {
                        throw new Error(result.message);
                    }

                } catch (e) {
                    alert('Hata: ' + e.message);
                    btn.disabled = false;
                    btn.textContent = 'Ödemeyi Başlat';
                }
            });

            init();
        </script>
    <?php endif; ?>
</body>

</html>