<?php
/**
 * Halı Yıkamacı - Firma Pazarlama (Vitrin + Kampanya)
 */

require_once '../config/app.php';
$pageTitle = 'Pazarlama';
$activeTab = isset($_GET['tab']) ? $_GET['tab'] : 'vitrins';
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
                <span class="fw-bold">Pazarlama</span>
                <div></div>
            </div>

            <div class="page-header">
                <h4 class="mb-0"><i class="fas fa-bullhorn me-2"></i>Pazarlama</h4>
            </div>

            <!-- Tabs -->
            <div class="bg-white border-bottom">
                <div class="container-fluid px-4">
                    <ul class="nav nav-tabs border-0" id="marketingTabs" role="tablist">
                        <li class="nav-item">
                            <button class="nav-link <?php echo $activeTab === 'vitrins' ? 'active' : ''; ?>"
                                id="vitrins-tab" data-bs-toggle="tab" data-bs-target="#vitrins" type="button">
                                <i class="fas fa-ad me-1"></i>Vitrin Paketleri
                            </button>
                        </li>
                        <li class="nav-item">
                            <button class="nav-link <?php echo $activeTab === 'campaigns' ? 'active' : ''; ?>"
                                id="campaigns-tab" data-bs-toggle="tab" data-bs-target="#campaigns" type="button">
                                <i class="fas fa-tags me-1"></i>Kampanyalar
                            </button>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="page-body">
                <div class="tab-content">
                    <!-- Vitrins Tab -->
                    <div class="tab-pane fade <?php echo $activeTab === 'vitrins' ? 'show active' : ''; ?>"
                        id="vitrins">
                        <div class="mb-4" id="vitrinStatus">
                            <!-- Aktif vitrin durumu -->
                        </div>

                        <h5 class="mb-3">Vitrin Paketleri</h5>
                        <div class="row g-4" id="vitrinPackages">
                            <div class="col-12 text-center py-4">
                                <div class="spinner"></div>
                            </div>
                        </div>
                    </div>

                    <!-- Campaigns Tab -->
                    <div class="tab-pane fade <?php echo $activeTab === 'campaigns' ? 'show active' : ''; ?>"
                        id="campaigns">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h5 class="mb-0">Aktif Kampanyalarım</h5>
                            <button class="btn btn-primary" data-bs-toggle="modal"
                                data-bs-target="#createCampaignModal">
                                <i class="fas fa-plus me-1"></i>Yeni Kampanya
                            </button>
                        </div>

                        <div id="myCampaigns">
                            <div class="text-center py-4">
                                <div class="spinner"></div>
                            </div>
                        </div>

                        <hr class="my-5">

                        <h5 class="mb-3">Kampanya Paketleri</h5>
                        <div class="row g-4" id="campaignPackages">
                            <div class="col-12 text-center py-4">
                                <div class="spinner"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Create Campaign Modal -->
    <div class="modal fade" id="createCampaignModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Yeni Kampanya Oluştur</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form id="createCampaignForm">
                    <div class="modal-body">
                        <div class="alert alert-info small">
                            <i class="fas fa-info-circle me-1"></i>
                            Kampanya oluşturmak için <strong>5 KRD</strong> bakiyeniz düşülecektir.
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Kampanya Başlığı</label>
                            <input type="text" id="campaignTitle" class="form-control" required
                                placeholder="Örn: Bahar Temizliği %20 İndirim">
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Açıklama</label>
                            <textarea id="campaignDesc" class="form-control" rows="2"
                                placeholder="Kampanya detaylarını yazın..."></textarea>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">İndirim Yüzdesi (%)</label>
                            <input type="number" id="campaignDiscount" class="form-control" min="1" max="100" value="10"
                                required>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-6">
                                <label class="form-label">Başlangıç</label>
                                <input type="date" id="campaignStart" class="form-control" required>
                            </div>
                            <div class="col-6">
                                <label class="form-label">Bitiş</label>
                                <input type="date" id="campaignEnd" class="form-control" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-check me-1"></i>Oluştur (5 KRD)
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, query, where, doc, updateDoc, addDoc, deleteDoc, increment } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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
            document.getElementById('smsBalanceSidebar').textContent = (currentFirm.smsBalance || 0) + ' KRD';

            // Set default dates
            const today = new Date().toISOString().split('T')[0];
            const nextMonth = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];
            document.getElementById('campaignStart').value = today;
            document.getElementById('campaignEnd').value = nextMonth;

            await loadVitrins();
            await loadCampaigns();

            setupForms();
        });

        async function getFirmData(uid) {
            const firmsRef = collection(db, 'firms');
            const q = query(firmsRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);
            if (snapshot.empty) return null;
            return { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
        }

        async function loadVitrins() {
            // Check active vitrin
            const vitrinStatus = document.getElementById('vitrinStatus');

            try {
                const vitrinsRef = collection(db, 'firm_vitrin_purchases');
                const q = query(vitrinsRef, where('firmId', '==', currentFirm.id), where('isActive', '==', true));
                const snapshot = await getDocs(q);

                if (!snapshot.empty) {
                    const vitrin = snapshot.docs[0].data();
                    const endDate = vitrin.endDate?.toDate ? vitrin.endDate.toDate() : new Date(vitrin.endDate);
                    const daysLeft = Math.ceil((endDate - new Date()) / (1000 * 60 * 60 * 24));

                    vitrinStatus.innerHTML = `
                <div class="alert alert-success">
                    <div class="d-flex align-items-center">
                        <i class="fas fa-check-circle fa-2x me-3"></i>
                        <div>
                            <strong>Vitrinde Görünüyorsunuz!</strong>
                            <br><small>${daysLeft} gün kaldı (${formatDate(endDate)})</small>
                        </div>
                    </div>
                </div>
            `;
                } else {
                    vitrinStatus.innerHTML = `
                <div class="alert alert-warning">
                    <i class="fas fa-info-circle me-2"></i>
                    Henüz aktif vitrininiz yok. Vitrin satın alarak müşterilerin ana sayfasında öne çıkın!
                </div>
            `;
                }

                // Load packages
                const packagesRef = collection(db, 'vitrinPackages');
                const packagesSnapshot = await getDocs(packagesRef);

                let packages = [];
                packagesSnapshot.forEach(doc => {
                    packages.push({ id: doc.id, ...doc.data() });
                });

                packages.sort((a, b) => a.smsCost - b.smsCost);

                const container = document.getElementById('vitrinPackages');

                if (packages.length === 0) {
                    container.innerHTML = '<div class="col-12"><p class="text-muted">Henüz vitrin paketi tanımlanmamış.</p></div>';
                    return;
                }

                container.innerHTML = packages.map(pkg => `
            <div class="col-md-4">
                <div class="card h-100 border-0 shadow-sm ${pkg.isPopular ? 'border-primary' : ''}">
                    ${pkg.isPopular ? '<div class="card-header bg-primary text-white text-center py-1"><small>Popüler</small></div>' : ''}
                    <div class="card-body text-center">
                        <h5 class="card-title">${pkg.name}</h5>
                        <div class="my-3">
                            <span class="display-6 fw-bold text-primary">${pkg.days}</span>
                            <span class="text-muted"> Gün</span>
                        </div>
                        <p class="text-muted">${pkg.description || ''}</p>
                        <div class="bg-light rounded p-2 mb-3">
                            <strong>${pkg.smsCost} KRD</strong>
                        </div>
                        <button class="btn btn-primary w-100 btn-buy-vitrin" 
                                data-pkg-id="${pkg.id}" data-pkg-name="${pkg.name}" 
                                data-pkg-days="${pkg.days}" data-pkg-cost="${pkg.smsCost}"
                                ${currentFirm.smsBalance < pkg.smsCost ? 'disabled' : ''}>
                            ${currentFirm.smsBalance < pkg.smsCost ? 'Yetersiz Bakiye' : 'Satın Al'}
                        </button>
                    </div>
                </div>
            </div>
        `).join('');

                // Setup buy buttons
                document.querySelectorAll('.btn-buy-vitrin').forEach(btn => {
                    btn.addEventListener('click', () => buyVitrin(btn.dataset));
                });

            } catch (error) {
                console.error('Vitrin yüklenirken hata:', error);
            }
        }

        async function buyVitrin(pkg) {
            if (!confirm(`${pkg.pkgName} paketi için ${pkg.pkgCost} KRD bakiyeniz düşülecek. Onaylıyor musunuz?`)) return;

            try {
                const days = parseInt(pkg.pkgDays);
                const endDate = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
                const pkgCost = parseInt(pkg.pkgCost);

                // Create vitrin
                const vitrinDoc = await addDoc(collection(db, 'firm_vitrin_purchases'), {
                    firmId: currentFirm.id,
                    firmName: currentFirm.name,
                    firmCity: currentFirm.address?.city || '',
                    packageId: pkg.pkgId,
                    days: days,
                    startDate: new Date(),
                    endDate: endDate,
                    isActive: true,
                    createdAt: new Date()
                });

                // Deduct SMS balance
                await updateDoc(doc(db, 'firms', currentFirm.id), {
                    smsBalance: increment(-pkgCost)
                });

                // MUHASEBE: Otomatik Gider Kaydı
                try {
                    await addDoc(collection(db, 'firm_accounting'), {
                        firmId: currentFirm.id,
                        type: 'expense',
                        category: 'vitrin',
                        title: 'Vitrin Gideri',
                        amount: pkgCost,
                        description: `${pkg.pkgName} - ${days} Gün`,
                        relatedVitrinId: vitrinDoc.id,
                        isAutomatic: true,
                        date: new Date(),
                        createdAt: new Date()
                    });
                    console.log('✅ Muhasebe: Vitrin gider kaydı oluşturuldu');
                } catch (accError) {
                    console.warn('⚠️ Muhasebe kaydı oluşturulamadı:', accError);
                }

                alert('Vitrin başarıyla satın alındı!');
                window.location.reload();

            } catch (error) {
                alert('Hata: ' + error.message);
            }
        }

        async function loadCampaigns() {
            // Load my campaigns
            const myCampaignsContainer = document.getElementById('myCampaigns');

            try {
                const campaignsRef = collection(db, 'campaigns');
                const q = query(campaignsRef, where('firmId', '==', currentFirm.id));
                const snapshot = await getDocs(q);

                let campaigns = [];
                snapshot.forEach(doc => {
                    campaigns.push({ id: doc.id, ...doc.data() });
                });

                if (campaigns.length === 0) {
                    myCampaignsContainer.innerHTML = `
                <div class="text-center py-4 text-muted">
                    <i class="fas fa-tags fa-3x mb-3"></i>
                    <p>Henüz kampanyanız yok.</p>
                </div>
            `;
                } else {
                    myCampaignsContainer.innerHTML = `
                <div class="row g-3">
                    ${campaigns.map(c => {
                        const endDate = c.endDate?.toDate ? c.endDate.toDate() : new Date(c.endDate);
                        const isActive = c.isActive && endDate > new Date();
                        return `
                            <div class="col-md-6">
                                <div class="card ${isActive ? 'border-success' : 'border-secondary'}">
                                    <div class="card-body">
                                        <div class="d-flex justify-content-between align-items-start">
                                            <div>
                                                <h6 class="mb-1">${c.title}</h6>
                                                <span class="badge bg-warning text-dark">%${c.discountPercent} İndirim</span>
                                            </div>
                                            <span class="badge ${isActive ? 'bg-success' : 'bg-secondary'}">
                                                ${isActive ? 'Aktif' : 'Sona Erdi'}
                                            </span>
                                        </div>
                                        <p class="text-muted small mt-2 mb-2">${c.description || ''}</p>
                                        <small class="text-muted">Bitiş: ${formatDate(endDate)}</small>
                                        <div class="mt-2">
                                            <button class="btn btn-sm btn-outline-danger btn-delete-campaign" data-id="${c.id}">
                                                <i class="fas fa-trash"></i> Sil
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        `;
                    }).join('')}
                </div>
            `;

                    // Setup delete buttons
                    document.querySelectorAll('.btn-delete-campaign').forEach(btn => {
                        btn.addEventListener('click', () => deleteCampaign(btn.dataset.id));
                    });
                }

                // Load campaign packages (for info)
                const packagesRef = collection(db, 'campaignPackages');
                const packagesSnapshot = await getDocs(packagesRef);

                let packages = [];
                packagesSnapshot.forEach(doc => {
                    packages.push({ id: doc.id, ...doc.data() });
                });

                const container = document.getElementById('campaignPackages');

                if (packages.length === 0) {
                    container.innerHTML = `
                <div class="col-12">
                    <div class="alert alert-light">
                        <i class="fas fa-info-circle me-2"></i>
                        Kampanya oluşturmak için <strong>5 KRD</strong> bakiyeniz düşülür.
                    </div>
                </div>
            `;
                } else {
                    container.innerHTML = packages.map(pkg => `
                <div class="col-md-4">
                    <div class="card h-100 border-0 shadow-sm">
                        <div class="card-body text-center">
                            <h5>${pkg.name}</h5>
                            <p class="text-muted">${pkg.description || ''}</p>
                            <div class="bg-light rounded p-2">
                                <strong>${pkg.smsCost} KRD</strong>
                            </div>
                        </div>
                    </div>
                </div>
            `).join('');
                }

            } catch (error) {
                console.error('Kampanyalar yüklenirken hata:', error);
            }
        }

        async function deleteCampaign(campaignId) {
            if (!confirm('Bu kampanyayı silmek istediğinize emin misiniz?')) return;

            try {
                await deleteDoc(doc(db, 'campaigns', campaignId));
                await loadCampaigns();
            } catch (error) {
                alert('Hata: ' + error.message);
            }
        }

        function setupForms() {
            document.getElementById('createCampaignForm').addEventListener('submit', async (e) => {
                e.preventDefault();

                const smsCost = 5;
                if (currentFirm.smsBalance < smsCost) {
                    alert('Yetersiz KRD bakiyesi! Kampanya oluşturmak için en az 5 KRD gerekli.');
                    return;
                }

                const title = document.getElementById('campaignTitle').value.trim();
                const desc = document.getElementById('campaignDesc').value.trim();
                const discount = parseInt(document.getElementById('campaignDiscount').value);
                const startDate = new Date(document.getElementById('campaignStart').value);
                const endDate = new Date(document.getElementById('campaignEnd').value);

                if (endDate <= startDate) {
                    alert('Bitiş tarihi başlangıç tarihinden sonra olmalı.');
                    return;
                }

                try {
                    // Create campaign
                    const campaignDoc = await addDoc(collection(db, 'campaigns'), {
                        firmId: currentFirm.id,
                        title: title,
                        description: desc,
                        discountPercent: discount,
                        startDate: startDate,
                        endDate: endDate,
                        smsCost: smsCost,
                        isActive: true,
                        createdAt: new Date()
                    });

                    // Deduct SMS
                    await updateDoc(doc(db, 'firms', currentFirm.id), {
                        smsBalance: increment(-smsCost)
                    });

                    // MUHASEBE: Otomatik Gider Kaydı
                    try {
                        await addDoc(collection(db, 'firm_accounting'), {
                            firmId: currentFirm.id,
                            type: 'expense',
                            category: 'campaign',
                            title: 'Kampanya Gideri',
                            amount: smsCost,
                            description: `${title} - %${discount} İndirim`,
                            relatedCampaignId: campaignDoc.id,
                            isAutomatic: true,
                            date: new Date(),
                            createdAt: new Date()
                        });
                        console.log('✅ Muhasebe: Kampanya gider kaydı oluşturuldu');
                    } catch (accError) {
                        console.warn('⚠️ Muhasebe kaydı oluşturulamadı:', accError);
                    }

                    bootstrap.Modal.getInstance(document.getElementById('createCampaignModal')).hide();
                    alert('Kampanya başarıyla oluşturuldu!');
                    window.location.reload();

                } catch (error) {
                    alert('Hata: ' + error.message);
                }
            });
        }

        function formatDate(date) {
            return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(date);
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