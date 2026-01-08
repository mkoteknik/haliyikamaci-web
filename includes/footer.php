<?php
// Load Footer Settings
$footerConfigPath = __DIR__ . '/../config/footer-settings.json';
$fSettings = [];
if (file_exists($footerConfigPath)) {
    $decoded = json_decode(file_get_contents($footerConfigPath), true);
    if (is_array($decoded)) {
        $fSettings = $decoded;
    }
}

// Defaults / Fallbacks
$siteDesc = $fSettings['description'] ?? SITE_DESCRIPTION . '. Güvenilir firmalarla halılarınız tertemiz!';
$contactEmail = $fSettings['contact']['email'] ?? 'info@haliyikamaci.com';
$contactPhone = $fSettings['contact']['phone'] ?? '0850 123 45 67';
$contactAddress = $fSettings['contact']['address'] ?? 'İstanbul, Türkiye';
?>

</main>

<!-- Footer -->
<footer class="footer bg-dark text-light py-5 mt-5">
    <div class="container">
        <div class="row g-4">
            <!-- 1. Column: Branding & Social -->
            <div class="col-lg-4 col-md-6">
                <h5 class="text-warning mb-3">
                    <i class="fas fa-broom me-2"></i><?php echo SITE_NAME; ?>
                </h5>
                <p class="text-light">
                    <?php echo htmlspecialchars($siteDesc); ?>
                </p>
                <div class="social-links mt-3">
                    <?php if (!empty($fSettings['socialMedia'])): ?>
                        <?php foreach ($fSettings['socialMedia'] as $sm): ?>
                            <a href="<?php echo htmlspecialchars($sm['url']); ?>" class="text-light me-3" target="_blank">
                                <i class="<?php echo htmlspecialchars($sm['icon']); ?> fa-lg"></i>
                            </a>
                        <?php endforeach; ?>
                    <?php else: ?>
                        <!-- Default Socials -->
                        <a href="#" class="text-light me-3"><i class="fab fa-facebook-f fa-lg"></i></a>
                        <a href="#" class="text-light me-3"><i class="fab fa-instagram fa-lg"></i></a>
                        <a href="#" class="text-light me-3"><i class="fab fa-twitter fa-lg"></i></a>
                    <?php endif; ?>
                </div>
            </div>

            <!-- 2. Column: Quick Links -->
            <div class="col-lg-2 col-md-6">
                <h6 class="text-warning mb-3">Hızlı Linkler</h6>
                <ul class="list-unstyled footer-links">
                    <?php if (!empty($fSettings['quickLinks'])): ?>
                        <?php foreach ($fSettings['quickLinks'] as $link): ?>
                            <li><a href="<?php echo htmlspecialchars($link['url']); ?>"
                                    class="text-light text-decoration-none"><?php echo htmlspecialchars($link['title']); ?></a>
                            </li>
                        <?php endforeach; ?>
                    <?php else: ?>
                        <!-- Default Links -->
                        <li><a href="<?php echo SITE_URL; ?>" class="text-light text-decoration-none">Ana Sayfa</a></li>
                        <li><a href="<?php echo SITE_URL; ?>/customer/firms.php"
                                class="text-light text-decoration-none">Firmalar</a></li>
                        <li><a href="<?php echo SITE_URL; ?>/customer/campaigns.php"
                                class="text-light text-decoration-none">Kampanyalar</a></li>
                        <li><a href="<?php echo SITE_URL; ?>/about.php"
                                class="text-light text-decoration-none">Hakkımızda</a></li>
                    <?php endif; ?>
                </ul>
            </div>

            <!-- 3. Column: Legal / Or Other -->
            <div class="col-lg-2 col-md-6">
                <h6 class="text-warning mb-3">Yasal / Kurumsal</h6>
                <ul class="list-unstyled footer-links">
                    <?php if (!empty($fSettings['legalLinks'])): ?>
                        <?php foreach ($fSettings['legalLinks'] as $link): ?>
                            <li><a href="<?php echo htmlspecialchars($link['url']); ?>"
                                    class="text-light text-decoration-none"><?php echo htmlspecialchars($link['title']); ?></a>
                            </li>
                        <?php endforeach; ?>
                    <?php else: ?>
                        <!-- Default Links -->
                        <li><a href="<?php echo SITE_URL; ?>/firm/login.php" class="text-light text-decoration-none">Firma
                                Girişi</a></li>
                        <li><a href="<?php echo SITE_URL; ?>/firm/register.php"
                                class="text-light text-decoration-none">Firma Kaydı</a></li>
                        <li><a href="<?php echo SITE_URL; ?>/firm-faq.php" class="text-light text-decoration-none">Sıkça
                                Sorulanlar</a></li>
                    <?php endif; ?>
                </ul>
            </div>

            <!-- 4. Column: Contact -->
            <div class="col-lg-4 col-md-6">
                <h6 class="text-warning mb-3">İletişim</h6>
                <ul class="list-unstyled text-light">
                    <li class="mb-2">
                        <i class="fas fa-envelope me-2"></i><?php echo htmlspecialchars($contactEmail); ?>
                    </li>
                    <li class="mb-2">
                        <i class="fas fa-phone me-2"></i><?php echo htmlspecialchars($contactPhone); ?>
                    </li>
                    <li class="mb-2">
                        <i class="fas fa-map-marker-alt me-2"></i><?php echo htmlspecialchars($contactAddress); ?>
                    </li>

                    <?php if (!empty($fSettings['contact']['extra'])): ?>
                        <hr class="border-secondary my-2 w-50" style="opacity: 0.2">
                        <?php foreach ($fSettings['contact']['extra'] as $extra): ?>
                            <li class="mb-1 small">
                                <strong><?php echo htmlspecialchars($extra['label']); ?>:</strong>
                                <?php echo htmlspecialchars($extra['value']); ?>
                            </li>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </ul>
            </div>
        </div>

        <hr class="my-4 border-secondary">

        <div class="row align-items-center">
            <div class="col-md-6 text-center text-md-start">
                <p class="mb-0 text-light small">
                    &copy; <?php echo date('Y'); ?> <?php echo SITE_NAME; ?>. Tüm hakları saklıdır.
                    <span class="mx-2">|</span>
                    Designed by <span class="gold-shine">MKO</span>
                </p>
            </div>
            <div class="col-md-6 text-center text-md-end">
                <!-- If we want dynamic bottom links, we could add them too, 
                     but legalLinks column handles most. 
                     Let's keep these static or use the same legalLinks if specific ones aren't provided?
                     Actually user requested: "3. Yasal Dökümanlar" as a column.
                     The bottom typically has Privacy/Terms.
                     I'll leave these as static for now as they are core to the site structure, 
                     or I could infer them if they exist in legalLinks.
                     Let's leave them static for now to ensure we don't break basic navigation.
                -->
                <ul class="list-inline mb-0">
                    <li class="list-inline-item">
                        <a href="<?php echo SITE_URL; ?>/yasal/gizlilik-politikasi"
                            class="text-light small text-decoration-none">Gizlilik Politikası</a>
                    </li>
                    <li class="list-inline-item">
                        <a href="<?php echo SITE_URL; ?>/yasal/kullanici-sozlesmesi"
                            class="text-light small text-decoration-none">Kullanım Şartları</a>
                    </li>
                    <li class="list-inline-item">
                        <a href="<?php echo SITE_URL; ?>/yasal/kvkk"
                            class="text-light small text-decoration-none">KVKK</a>
                    </li>
                </ul>
            </div>
        </div>
    </div>
</footer>

<style>
    .gold-shine {
        background: linear-gradient(to right, #BF953F, #FCF6BA, #B38728, #FBF5B7, #AA771C);
        -webkit-background-clip: text;
        background-clip: text;
        color: transparent;
        font-weight: 800;
        background-size: 200% auto;
        animation: shine 3s linear infinite;
        font-family: 'Inter', sans-serif;
    }

    @keyframes shine {
        to {
            background-position: 200% center;
        }
    }
</style>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- Firebase Modular SDK -->
<script type="module">
    // Firebase imports
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
    import { getAuth, onAuthStateChanged, signOut } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, collection, getDocs, query, where, orderBy, limit, doc, getDoc, addDoc, updateDoc, setDoc, arrayRemove, arrayUnion } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

    // Firebase configuration
    const firebaseConfig = {
        apiKey: "AIzaSyAZBzUpPtWHnW3mlF38L7YGpiknMB9dZb8",
        authDomain: "halisepetimbl.firebaseapp.com",
        projectId: "halisepetimbl",
        storageBucket: "halisepetimbl.firebasestorage.app",
        messagingSenderId: "782891273844",
        appId: "1:782891273844:web:750619b1bfe1939e52cb21"
    };

    // Initialize Firebase
    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);

    // Initialize Firestore with named database
    const db = getFirestore(app, 'haliyikamacimmbldatabase');

    // Make db available globally for page scripts
    window.firebaseDb = db;
    window.firebaseAuth = auth;
    window.firebaseModules = { collection, getDocs, query, where, orderBy, limit, doc, getDoc, addDoc, updateDoc, setDoc, arrayRemove, arrayUnion };

    // Auth state observer
    onAuthStateChanged(auth, async (user) => {
        const userAuthArea = document.getElementById('userAuthArea');
        if (!userAuthArea) return;

        if (user) {
            // Fetch user role
            try {
                const userDocRef = doc(db, 'users', user.uid);
                const userDocSnap = await getDoc(userDocRef);
                const userData = userDocSnap.exists() ? userDocSnap.data() : { userType: 'customer' };
                const userType = userData.userType || 'customer';

                let menuItems = '';

                if (userType === 'admin') {
                    menuItems = `
                        <li><a class="dropdown-item" href="/admin/index.php">
                            <i class="fas fa-user-shield me-2"></i>Admin Paneli
                        </a></li>
                        <li><a class="dropdown-item" href="/customer/firms.php">
                            <i class="fas fa-store me-2"></i>Firmalar
                        </a></li>
                    `;
                } else if (userType === 'firm') {
                    menuItems = `
                        <li><a class="dropdown-item" href="/firm/index.php">
                            <i class="fas fa-tachometer-alt me-2"></i>Firma Paneli
                        </a></li>
                        <li><a class="dropdown-item" href="/firm/orders.php">
                            <i class="fas fa-box me-2"></i>Siparişler
                        </a></li>
                    `;
                } else {
                    // Customer (default)
                    menuItems = `
                        <li><a class="dropdown-item" href="/customer/my-orders.php">
                            <i class="fas fa-box me-2"></i>Siparişlerim
                        </a></li>
                        <li><a class="dropdown-item" href="/customer/profile.php">
                            <i class="fas fa-user-cog me-2"></i>Profilim
                        </a></li>
                    `;
                }

                userAuthArea.innerHTML = `
                    <div class="dropdown">
                        <button class="btn btn-warning btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <i class="fas fa-user me-1"></i>${user.phoneNumber || user.email || 'Hesabım'}
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end">
                            ${menuItems}
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="#" id="navbarLogoutBtn">
                                <i class="fas fa-sign-out-alt me-2"></i>Çıkış Yap
                            </a></li>
                        </ul>
                    </div>
                `;

                document.getElementById('navbarLogoutBtn')?.addEventListener('click', async (e) => {
                    e.preventDefault();
                    await signOut(auth);
                    window.location.href = '/';
                });
            } catch (error) {
                console.error('Error fetching user role:', error);
                // Fallback to basic view or logout
                userAuthArea.innerHTML = `
                    <div class="dropdown">
                         <button class="btn btn-warning btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <i class="fas fa-user me-1"></i>${user.phoneNumber || user.email || 'Hesabım'}
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end">
                             <li><a class="dropdown-item text-danger" href="#" id="navbarLogoutBtn">
                                <i class="fas fa-sign-out-alt me-2"></i>Çıkış Yap
                            </a></li>
                        </ul>
                    </div>
                `;
                document.getElementById('navbarLogoutBtn')?.addEventListener('click', async (e) => {
                    e.preventDefault();
                    await signOut(auth);
                    window.location.href = '/';
                });
            }
        } else {
            userAuthArea.innerHTML = `
                    <a href="/customer/login.php" class="btn btn-warning btn-sm">
                        <i class="fas fa-user me-1"></i>Giriş Yap
                    </a>
                `;
        }
    });

    // Dispatch event when Firebase is ready
    window.dispatchEvent(new CustomEvent('firebaseReady'));

</script>

<!-- TurkiyeAPI Script -->
<script src="<?php echo SITE_URL; ?>/assets/js/turkiye-api.js"></script>

<!-- Custom JS -->
<script src="<?php echo SITE_URL; ?>/assets/js/main.js"></script>
<!-- Cookie Consent -->
<script src="<?php echo SITE_URL; ?>/assets/js/cookie-consent.js"></script>

</body>

</html>