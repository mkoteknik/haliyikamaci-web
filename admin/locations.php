<?php
/**
 * Halı Yıkamacı - Lokasyonlar
 */
require_once '../config/app.php';
$pageTitle = 'Lokasyonlar';
require_once 'includes/header.php';
?>

<div class="page-header">
    <h4 class="mb-0"><i class="fas fa-map-marker-alt me-2"></i>Lokasyon Yönetimi</h4>
</div>

<div class="page-body">
    <div class="row">
        <div class="col-12">
            <div class="card shadow-sm border-0">
                <div class="card-body text-center py-5">
                    <div class="mb-4">
                        <i class="fas fa-tools fa-3x text-muted"></i>
                    </div>
                    <h4>Henüz Hazır Değil</h4>
                    <p class="text-muted">İl, İlçe ve Mahalle yönetimi bu sayfadan yapılacaktır.</p>
                </div>
            </div>
        </div>
    </div>
</div>

</div> <!-- Closing Main Content -->
</div> <!-- Closing Main Layout -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
    import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, doc, getDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

    // ... Using common logic or similar to header ...
    // For brevity in placeholder, we just do basic auth check
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
            const docSnap = await getDoc(doc(db, 'users', uid));
            return docSnap.exists() && docSnap.data().userType === 'admin';
        } catch (e) {
            return false;
        }
    }
</script>
</body>

</html>