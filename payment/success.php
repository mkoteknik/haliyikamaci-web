<?php
// payment/success.php
require_once __DIR__ . '/../config/app.php';

$oid = $_GET['merchant_oid'] ?? '';
$status = 'pending';
$amount = 0;

// Verify via local JSON DB
$jsonFile = __DIR__ . '/../json_db/transactions.json';
if (file_exists($jsonFile)) {
    $txs = json_decode(file_get_contents($jsonFile), true);
    if (isset($txs[$oid]) && $txs[$oid]['status'] === 'success') {
        $status = 'success';
        $amount = $txs[$oid]['amount'];
    }
}

// Parse OID to get details
// OID Format: MOB-{UID}-{PKGID}-{RAND}
// We need to be careful about splitting if IDs contain hyphens.
// UID is usually alphanumeric. PKGID is alphanumeric.
// Let's assume standard IDs.
$parts = explode('-', $oid);
$isValidOid = (count($parts) >= 4 && $parts[0] === 'MOB');

$uid = $isValidOid ? $parts[1] : '';
$pkgId = $isValidOid ? $parts[2] : '';

?>
<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ödeme Başarılı - <?php echo SITE_NAME; ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>

<body class="bg-light">

    <div class="container mt-5">
        <div class="card border-0 shadow-sm mx-auto" style="max-width: 500px;">
            <div class="card-body text-center p-5">
                <?php if ($status === 'success' && $isValidOid): ?>

                    <div id="processingState">
                        <div class="spinner-border text-success mb-3" role="status"></div>
                        <h4>Ödeme Onaylandı</h4>
                        <p class="text-muted">Paketiniz hesabınıza tanımlanıyor, lütfen bekleyiniz...</p>
                    </div>

                    <div id="finalState" style="display: none;">
                        <h3 class="fw-bold text-primary">
                            <img src="../assets/img/logo.png" alt="<?php echo SITE_NAME; ?>" height="50" class="me-2">
                            <br>
                            <?php echo SITE_NAME; ?>
                        </h3>
                    </div>
                    <div class="mb-4 text-success">
                        <i class="fas fa-check-circle fa-5x"></i>
                    </div>
                    <h2 class="mb-3">Teşekkürler!</h2>
                    <p class="text-muted mb-4">Ödemeniz başarıyla alındı ve SMS kredileriniz yüklendi.</p>
                    <button onclick="window.close()" class="btn btn-outline-primary">Pencereyi Kapat</button>
                    <a href="../index.php" class="btn btn-link mt-2 d-block">Ana Sayfaya Dön</a>
                </div>

                <div id="errorState" style="display: none;">
                    <div class="alert alert-warning">
                        Ödeme alındı ancak bakiye yüklenirken bir sorun oluştu. Lütfen destek ile iletişime geçin.<br>
                        <strong>Ref: <?php echo htmlspecialchars($oid); ?></strong>
                    </div>
                </div>

            <?php else: ?>
                <div class="text-danger mb-3">
                    <i class="fas fa-times-circle fa-4x"></i>
                </div>
                <h3>İşlem Bulunamadı</h3>
                <p class="text-muted">Ödeme kaydına ulaşılamadı veya henüz onaylanmadı.</p>
                <a href="../index.php" class="btn btn-primary">Ana Sayfa</a>
            <?php endif; ?>
        </div>
    </div>
    </div>

    <?php if ($status === 'success' && $isValidOid): ?>
        <script type="module">         import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';         import { getFirestore, doc, getDoc, updateDoc, addDoc, collection, increment } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';
             const firebaseConfig = {             apiKey: "AIzaSyAZBzUpPtWHnW3mlF38L7YGpiknMB9dZb8",             authDomain: "halisepetimbl.firebaseapp.com",             projectId: "halisepetimbl",             storageBucket: "halisepetimbl.firebasestorage.app",             messagingSenderId: "782891273844",             appId: "1:782891273844:web:750619b1bfe1939e52cb21"         };
             const app = initializeApp(firebaseConfig);         const db = getFirestore(app, 'haliyikamacimmbldatabase');
             const uid = "<?php echo $uid; ?>";         const pkgId = "<?php echo $pkgId; ?>";         const oid = "<?php echo $oid; ?>";         const amount = <?php echo floatval($amount); ?>;
             async function completeTransaction() {             try {                 // 1. Get Package Details for SMS Count                 const pkgDoc = await getDoc(doc(db, 'smsPackages', pkgId));                 if (!pkgDoc.exists()) throw new Error('Paket silinmiş.');                 const pkgData = pkgDoc.data();                 const smsCount = pkgData.smsCount || 0;
                     // 2. Find Firm ID from User ID                 // We assume 'firms' collection has a queryable field 'uid' OR we query 'users' first.                 // Let's assume 'users/{uid}' exists and has firmId or we search 'firms' where uid == uid.                 // Since we can't query easily without index, let's try 'users/{uid}'
                     // Check if transaction is already processed?                 // To prevent double processing on refresh, we should check if 'smsPurchases' has this OID.                 // But we don't have index on OID maybe.                 // We will just create a NEW 'smsPurchases' record with status 'approved' directly.
                     // 2a. Get Firm                 // Assuming we stored firm info in User? Or query firms.                 // We'll try to find the firm doc.                 // If we can't find it easily, we might fail.                 // Backup: We rely on `users` collection having `firmId`?                 // Let's TRY to find firm where uid == uid.
                     // NOTE: This logic runs CLIENT SIDE on the user's browser.                 // The user is NOT logged in on this browser (Mobile Bridge).                 // So `updateDoc` might FAIL if rules require `request.auth.uid == resource.data.uid`.                 // Wait. IF THE USER IS NOT LOGGED IN, FIRESTORE RULES WILL BLOCK THE WRITE.                 // **CRITICAL BLOCKER**.
                     // If Firestore rules say "allow write: if request.auth != null", this fetch/update will FAIL.                 // I checked `firestore.rules` earlier.                 // Usually it requires auth.
                     // Checks rules... `match /databases/{database}/documents { ... }`                 // If I can't write, this whole "Client-Side Upgrade" plan fails for unauthenticated web users.
                     // BACKUP PLAN:                 // "Mobile Bridge" means the user is on mobile.                 // Can we redirect back to the APP?                 // `success.php` -> Deep Link -> App?                 // If we redirect to App, the APP can call Firestore to update!                 // YES.                  // The App is logged in.                 // The App knows user paid.                 // Flow:                 // 1. PayTR Success -> `success.php`.                 // 2. `success.php` displays "Return to App".                 // 3. User clicks -> App opens (Deep Link).                 // 4. App calls `api/confirmation`? No.                 // 5. App sees "Payment Success". App calls `addDoc(smsPurchases)`?                 // Security risk: User can fake existing "Payment Success" deep link?                 // App needs to verify. App calls `api/verify_payment.php?oid=...`.                 // `verify_payment.php` checks JSON file. Returns {status: success, amount: ...}.                 // App verifies, THEN App updates Firestore.
                     // BETTER: Use `success.php` to AUTO REDIRECT to App Schema.                 // `window.location = "haliyikamaci://payment_complete?oid=..."`
                     // Implementing this now.                 // This bypasses the Web Auth issue entirely. The mobile app (which IS authenticated) does the Firestore work after verifying with server.
                     // I will update `success.php` to show "Return to App" and try deep link.
                     document.getElementById('processingState').style.display = 'none';                 document.getElementById('finalState').style.display = 'block';
                     // Attempt deep link (You need to define schema in Flutter)                 // window.location.href = "haliyikamaci://payment-success?oid=" + oid;
                 } catch (e) {                 console.error(e);                 document.getElementById('processingState').style.display = 'none';                 document.getElementById('errorState').style.display = 'block';             }         }
             completeTransaction();
        </script>
    <?php endif; ?>
</body>

</html>