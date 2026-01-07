<?php
/**
 * Halı Yıkamacı - Firma Hizmetler
 */

require_once '../config/app.php';
$pageTitle = 'Hizmetler';
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
                <span class="fw-bold">Hizmetler</span>
                <div></div>
            </div>

            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h4 class="mb-1"><i class="fas fa-list-check me-2"></i>Hizmetler ve Fiyatlar</h4>
                        <p class="mb-0 opacity-75 small">Sunduğunuz hizmetleri ve fiyatları ayarlayın</p>
                    </div>
                </div>
            </div>

            <div class="page-body">
                <div class="alert alert-info mb-4">
                    <i class="fas fa-info-circle me-2"></i>
                    Aktif olarak işaretlediğiniz hizmetler müşterilere gösterilir. Fiyatlar otomatik kaydedilir.
                </div>

                <div id="servicesList">
                    <div class="text-center py-5">
                        <div class="spinner"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, query, where, doc, updateDoc } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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

        let currentFirm = null;
        let allServices = [];
        let firmServices = [];
        let saveTimeout = null;

        onAuthStateChanged(auth, async (user) => {
            if (!user) {
                window.location.href = 'login.php';
                return;
            }

            currentFirm = await getFirmData(user.uid);
            if (!currentFirm || !currentFirm.isApproved) {
                window.location.href = 'index.php';
                return;
            }

            document.getElementById('authCheck').classList.add('d-none');
            document.getElementById('mainLayout').style.display = 'block';
            document.getElementById('firmNameSidebar').textContent = currentFirm.name;
            document.getElementById('smsBalanceSidebar').textContent = (currentFirm.smsBalance || 0) + ' SMS';

            await loadServices();
        });

        async function getFirmData(uid) {
            const firmsRef = collection(db, 'firms');
            const q = query(firmsRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);
            if (snapshot.empty) return null;
            return { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
        }

        async function loadServices() {
            const container = document.getElementById('servicesList');

            try {
                // Load available services from admin
                const servicesRef = collection(db, 'services');
                const servicesSnapshot = await getDocs(servicesRef);

                allServices = [];
                servicesSnapshot.forEach(doc => {
                    allServices.push({ id: doc.id, ...doc.data() });
                });

                // Firma'nın mevcut hizmetleri
                firmServices = currentFirm.services || [];

                renderServices();

            } catch (error) {
                console.error('Hizmetler yüklenirken hata:', error);
                container.innerHTML = `<div class="alert alert-danger">Hata: ${error.message}</div>`;
            }
        }

        function renderServices() {
            const container = document.getElementById('servicesList');

            if (allServices.length === 0) {
                container.innerHTML = `
            <div class="text-center py-5">
                <i class="fas fa-list fa-4x text-muted mb-3"></i>
                <h5>Henüz hizmet tanımlanmamış</h5>
                <p class="text-muted">Admin tarafından hizmetler eklendikten sonra burada görünecek.</p>
            </div>
        `;
                return;
            }

            // Sort services by admin order or name
            allServices.sort((a, b) => (a.order || 0) - (b.order || 0));

            let html = '<div class="row g-4">';

            allServices.forEach(service => {
                // Find firm's current setting for this service
                // Find firm's current setting for this service
                const firmService = firmServices.find(fs => fs.serviceId === service.id);
                // Fix: Check isActive first, fallback to enabled (legacy)
                const isActive = firmService ? (firmService.isActive !== undefined ? firmService.isActive : (firmService.enabled || false)) : false;
                const price = firmService ? firmService.price : 0;

                html += `
            <div class="col-md-6 col-lg-4">
                <div class="card h-100 border-0 shadow-sm service-card ${isActive ? 'border-primary' : ''}" 
                     data-service-id="${service.id}">
                    <div class="card-body">
                        <div class="d-flex align-items-start justify-content-between mb-3">
                            <div class="d-flex align-items-center">
                                <div class="bg-primary bg-opacity-10 rounded-circle p-3 me-3">
                                    <i class="${getServiceIcon(service.icon)} text-primary fa-lg"></i>
                                </div>
                                <div>
                                    <h6 class="mb-0">${service.name}</h6>
                                    <small class="text-muted">${getUnitLabel(service.unit)}</small>
                                </div>
                            </div>
                            <div class="form-check form-switch">
                                <input type="checkbox" class="form-check-input service-toggle" 
                                       id="toggle_${service.id}" data-service-id="${service.id}"
                                       ${isActive ? 'checked' : ''}>
                            </div>
                        </div>
                        
                        <div class="input-group">
                            <span class="input-group-text">₺</span>
                            <input type="number" class="form-control service-price" 
                                   id="price_${service.id}" data-service-id="${service.id}"
                                   value="${price}" step="0.01" min="0"
                                   ${!isActive ? 'disabled' : ''}>
                            <span class="input-group-text">/ ${getUnitLabel(service.unit)}</span>
                        </div>
                        
                        ${service.description ? `<p class="text-muted small mt-2 mb-0">${service.description}</p>` : ''}
                    </div>
                    <div class="card-footer bg-white border-0 pt-0">
                        <small class="text-muted save-status" id="status_${service.id}"></small>
                    </div>
                </div>
            </div>
        `;
            });

            html += '</div>';
            container.innerHTML = html;

            // Setup event listeners
            document.querySelectorAll('.service-toggle').forEach(toggle => {
                toggle.addEventListener('change', (e) => {
                    const serviceId = e.target.dataset.serviceId;
                    const priceInput = document.getElementById('price_' + serviceId);
                    priceInput.disabled = !e.target.checked;

                    if (e.target.checked && parseFloat(priceInput.value) === 0) {
                        priceInput.focus();
                    }

                    scheduleAutoSave();

                    // Update border
                    const card = toggle.closest('.card');
                    if (e.target.checked) card.classList.add('border-primary');
                    else card.classList.remove('border-primary');
                });
            });

            document.querySelectorAll('.service-price').forEach(input => {
                input.addEventListener('input', () => scheduleAutoSave());
            });
        }

        function scheduleAutoSave() {
            if (saveTimeout) clearTimeout(saveTimeout);

            // Show saving indicator
            document.querySelectorAll('.save-status').forEach(el => {
                el.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i>Kaydediliyor...';
            });

            saveTimeout = setTimeout(async () => {
                await saveServices();
            }, 1000);
        }

        async function saveServices() {
            try {
                const newServices = [];

                allServices.forEach(service => {
                    const toggle = document.getElementById('toggle_' + service.id);
                    const priceInput = document.getElementById('price_' + service.id);

                    newServices.push({
                        serviceId: service.id,
                        serviceName: service.name,
                        icon: service.icon || 'cleaning',
                        unit: service.unit || 'm2',
                        isActive: toggle.checked, // FIXED: Changed 'enabled' to 'isActive'
                        price: parseFloat(priceInput.value) || 0
                    });
                });

                await updateDoc(doc(db, 'firms', currentFirm.id), {
                    services: newServices
                });

                firmServices = newServices;

                document.querySelectorAll('.save-status').forEach(el => {
                    el.innerHTML = '<i class="fas fa-check text-success me-1"></i>Kaydedildi';
                    setTimeout(() => { el.innerHTML = ''; }, 2000);
                });

            } catch (error) {
                console.error('Kaydetme hatası:', error);
                document.querySelectorAll('.save-status').forEach(el => {
                    el.innerHTML = '<i class="fas fa-times text-danger me-1"></i>Hata!';
                });
            }
        }

        function getServiceIcon(iconName) {
            const icons = {
                'cleaning': 'fas fa-broom',
                'carpet': 'fas fa-rug',
                'wash': 'fas fa-tint',
                'dry': 'fas fa-wind',
                'stain': 'fas fa-eraser',
                'sofa': 'fas fa-couch',
                'curtain': 'fas fa-border-all',
                'mattress': 'fas fa-bed',
                'default': 'fas fa-check-circle'
            };
            return icons[iconName] || icons.default;
        }

        function getUnitLabel(unit) {
            return { m2: 'm²', adet: 'Adet', takim: 'Takım', meter: 'Metre' }[unit] || unit || 'm²';
        }

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