<?php
/**
 * Halı Yıkamacı - Ana Sayfa
 */

require_once 'config/app.php';
$pageTitle = 'Ana Sayfa';
require_once 'includes/header.php';
?>

<!-- Hero Section -->
<section class="hero-section">
    <div class="container position-relative">
        <div class="row align-items-center">
            <div class="col-lg-6">
                <h1 class="hero-title animate-fadeInUp">
                    Halılarınız <span class="text-warning">Tertemiz</span> Olsun!
                </h1>
                <p class="hero-subtitle animate-fadeInUp">
                    Türkiye'nin en büyük halı yıkama platformu. Güvenilir firmalarla tanışın,
                    en uygun fiyatlarla halılarınızı yıkatın.
                </p>
                <div class="d-flex gap-3 animate-fadeInUp">
                    <a href="firmalar" class="btn btn-warning btn-lg">
                        <i class="fas fa-search me-2"></i>Firma Bul
                    </a>
                    <a href="customer/login.php" class="btn btn-outline-light btn-lg">
                        <i class="fas fa-mobile-alt me-2"></i>Uygulamayı İndir
                    </a>
                </div>
            </div>
            <!-- CSS for Clean Modern Portal -->
            <style>
                .slider-portal {
                    width: 420px;
                    height: 420px;
                    /* Organic Blob Shape */
                    border-radius: 42% 58% 40% 60% / 55% 45% 55% 45%;

                    /* Gold Border (Matching 'Firma Bul' Button) */
                    border: 8px solid rgba(255, 215, 0, 0.9);
                    /* #FFD700 */

                    /* White Inner Outline for Contrast */
                    outline: 1px solid rgba(255, 255, 255, 0.5);
                    outline-offset: -10px;

                    /* Animation */
                    animation: morph 8s ease-in-out infinite;

                    /* Gold Glow Shadow */
                    box-shadow:
                        0 20px 50px rgba(255, 215, 0, 0.3),
                        /* Gold Glow */
                        inset 0 0 40px rgba(0, 0, 0, 0.2);
                    /* Depth */

                    overflow: hidden;
                    text-align: center;
                    position: relative;
                    margin: 0 auto;
                    transform: translateZ(0);
                    background: rgba(255, 215, 0, 0.05);
                    /* Faint Gold Tint */
                }

                @keyframes morph {
                    0% {
                        border-radius: 42% 58% 40% 60% / 55% 45% 55% 45%;
                    }

                    50% {
                        border-radius: 60% 40% 58% 42% / 45% 55% 45% 55%;
                    }

                    100% {
                        border-radius: 42% 58% 40% 60% / 55% 45% 55% 45%;
                    }
                }

                .slider-track {
                    width: 100%;
                    height: 100%;
                    position: relative;
                }

                .slider-image {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    position: absolute;
                    top: 0;
                    left: 0;
                    opacity: 0;
                    transition: opacity 0.8s ease-in-out, transform 5s linear;
                    transform: scale(1);
                }

                .slider-image.active {
                    opacity: 1;
                    transform: scale(1.15);
                    /* Dynamic zoom */
                    z-index: 2;
                }

                .slider-image.last-active {
                    opacity: 1;
                    z-index: 1;
                }
            </style>
            <div class="col-lg-6 d-none d-lg-block text-center">
                <div class="slider-portal" id="heroSlider">
                    <div class="slider-track" id="sliderTrack">
                        <!-- Default static images with LCP & CLS Optimization -->
                        <img src="assets/img/slider/slide1.png" class="slider-image active" alt="Halı Yıkama"
                            width="420" height="420" loading="eager">
                        <img src="assets/img/slider/slide2.png" class="slider-image" alt="Temiz Halı" width="420"
                            height="420" loading="lazy">
                        <img src="assets/img/slider/slide3.png" class="slider-image" alt="Yıkama İşlemi" width="420"
                            height="420" loading="lazy">
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Search Box -->
<section class="py-4" style="margin-top: -50px; position: relative; z-index: 10;">
    <div class="container">
        <?php include 'includes/search-bar.php'; ?>
    </div>
</section>

<!-- Vitrin Section -->
<section class="section py-5 bg-light d-none" id="vitrinWrapper">
    <div class="container">
        <div class="text-center mb-4">
            <h3 class="fw-bold text-dark"><i class="fas fa-crown text-warning me-2"></i>Vitrindeki Firmalar</h3>
            <p class="text-muted small">Bölgenizin en seçkin işletmeleri</p>
        </div>
        <div class="row g-4 justify-content-center" id="vitrinContainer">
            <!-- Dynamic Content -->
            <div class="col-12 text-center">
                <div class="spinner-border text-primary" role="status"></div>
            </div>
        </div>
    </div>
</section>

<!-- Stats Section -->
<section class="section bg-white">
    <div class="container">
        <div class="row g-4" id="statsSection">
            <div class="col-6 col-md-3">
                <div class="stat-card">
                    <span class="stat-number" id="statFirms">0</span>
                    <span class="stat-label">Kayıtlı Firma</span>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="stat-card">
                    <span class="stat-number" id="statCustomers">0</span>
                    <span class="stat-label">Mutlu Müşteri</span>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="stat-card">
                    <span class="stat-number" id="statOrders">0</span>
                    <span class="stat-label">Tamamlanan Sipariş</span>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="stat-card">
                    <span class="stat-number" id="statCities">81</span>
                    <span class="stat-label">Şehir</span>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Active Campaigns Section -->
<section class="section bg-light" style="padding: 40px 0;" aria-labelledby="campaignsHeading">
    <div class="container">
        <div class="text-center mb-4">
            <h3 id="campaignsHeading" class="fw-bold text-dark"><i class="fas fa-tags text-danger me-2"></i>Fırsatları
                Yakala</h3>
            <p class="text-muted small">Sınırlı süreli indirimler</p>
        </div>

        <div class="row g-3 justify-content-center" id="activeCampaigns">
            <div class="col-12 text-center py-4">
                <div class="spinner-border text-danger" role="status">
                    <span class="visually-hidden">Yükleniyor...</span>
                </div>
                <p class="text-muted mt-2 small">Fırsatlar yükleniyor...</p>
            </div>
        </div>
    </div>
</section>

<!-- Featured Firms Section -->
<section class="section">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="section-title">Öne Çıkan Firmalar</h2>
            <p class="section-subtitle">En çok tercih edilen halı yıkama firmaları</p>
        </div>

        <div class="row g-4" id="featuredFirms">
            <div class="col-12 text-center py-5">
                <div class="spinner"></div>
                <p class="text-muted mt-3">Firmalar yükleniyor...</p>
            </div>
        </div>

        <div class="text-center mt-4">
            <a href="customer/firms.php" class="btn btn-outline-primary btn-lg">
                Tüm Firmaları Gör <i class="fas fa-arrow-right ms-2"></i>
            </a>
        </div>
    </div>
</section>



<!-- How It Works Section -->
<section class="section bg-white">
    <div class="container">
        <div class="text-center mb-5">
            <h2 class="section-title">Nasıl Çalışır?</h2>
            <p class="section-subtitle">3 kolay adımda halılarınızı yıkatın</p>
        </div>

        <div class="row g-4">
            <div class="col-md-4">
                <div class="text-center p-4">
                    <div class="bg-gradient-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-4"
                        style="width: 100px; height: 100px;">
                        <i class="fas fa-search fa-2x"></i>
                    </div>
                    <h4 class="fw-bold">1. Firma Seçin</h4>
                    <p class="text-muted">
                        Bölgenizdeki firmaları inceleyin, fiyatları karşılaştırın ve size uygun olanı seçin.
                    </p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="text-center p-4">
                    <div class="bg-gradient-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-4"
                        style="width: 100px; height: 100px;">
                        <i class="fas fa-clipboard-list fa-2x"></i>
                    </div>
                    <h4 class="fw-bold">2. Sipariş Verin</h4>
                    <p class="text-muted">
                        Yıkatmak istediğiniz halıları belirtin, adres bilgilerinizi girin ve siparişi oluşturun.
                    </p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="text-center p-4">
                    <div class="bg-gradient-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-4"
                        style="width: 100px; height: 100px;">
                        <i class="fas fa-truck fa-2x"></i>
                    </div>
                    <h4 class="fw-bold">3. Teslim Alın</h4>
                    <p class="text-muted">
                        Firma halılarınızı gelip alsın, yıkasın ve tertemiz bir şekilde kapınıza getirsin.
                    </p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- CTA Section -->
<section class="section bg-gradient-primary text-white">
    <div class="container text-center">
        <h2 class="fw-bold mb-3">Firma mısınız?</h2>
        <p class="lead mb-4 opacity-90">
            Halı Yıkamacı platformuna katılın, binlerce müşteriye ulaşın!
        </p>
        <a href="firm/register.php" class="btn btn-warning btn-lg">
            <i class="fas fa-store me-2"></i>Hemen Kayıt Olun
        </a>
    </div>
</section>

<!-- Campaign Detail Modal -->
<div class="modal fade" id="campaignModal" tabindex="-1" aria-hidden="true" style="z-index: 1055;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header border-0 bg-warning bg-opacity-10">
                <h5 class="modal-title fw-bold text-dark" id="campaignModalTitle">Kampanya Detayı</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Kapat"></button>
            </div>
            <div class="modal-body p-4 text-center">
                <div class="mb-3">
                    <span class="badge bg-danger p-2 fs-6 shadow-sm mb-3" id="campaignModalBadge">%0 İndirim</span>
                    <h4 class="fw-bold mb-2 text-dark" id="campaignModalName">Kampanya Başlığı</h4>
                    <p class="text-primary fw-medium mb-3" id="campaignModalFirm">Firma Adı</p>
                </div>

                <div class="p-3 bg-light rounded text-start mb-4 border">
                    <p class="mb-0 text-muted" id="campaignModalDesc">Kampanya açıklaması burada yer alacak...</p>
                </div>

                <div class="d-flex justify-content-between align-items-center bg-white border rounded p-2 mb-3">
                    <span class="small text-muted"><i class="fas fa-clock me-1"></i>Son Geçerlilik:</span>
                    <span class="fw-bold text-danger" id="campaignModalDate">01.01.2024</span>
                </div>

                <a href="#" id="campaignModalLink" class="btn btn-primary w-100 py-2 rounded-pill shadow-sm">
                    <i class="fas fa-store me-2"></i>Firmayı Ziyaret Et
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Add TurkiyeAPI Script -->
<script type="module">
    // Firebase hazır olduğunda verileri yükle
    window.addEventListener('firebaseReady', async function () {
        const { collection, getDocs, query, where, orderBy, limit, doc, getDoc } = window.firebaseModules;
        const db = window.firebaseDb;

        // Check Demo Mode Status
        let demoSettings = null;
        try {
            const demoSnap = await getDoc(doc(db, 'system_settings', 'demo_content'));
            if (demoSnap.exists()) {
                demoSettings = demoSnap.data();
            }
        } catch (e) { console.log('Demo check error', e); }

        await loadFeaturedFirms(db, { collection, getDocs, query, where, doc, getDoc }, demoSettings);
        await loadActiveCampaigns(db, { collection, getDocs, query, where, orderBy, limit }, demoSettings);
        animateStats();

        // Initialize Hero Slider
        initHeroSlider(db, window.firebaseModules);

        // Load Vitrins
        loadVitrinFirms(db, window.firebaseModules, demoSettings);
    });

    // Vitrin Firmalarını Yükle
    // Helper: Slugify (Türkçe karakter destekli)
    function slugify(text) {
        if (!text) return 'firma';
        const trMap = {
            'ç': 'c', 'Ç': 'c', 'ğ': 'g', 'Ğ': 'g',
            'ş': 's', 'Ş': 's', 'ü': 'u', 'Ü': 'u',
            'ı': 'i', 'İ': 'i', 'ö': 'o', 'Ö': 'o'
        };
        return text.toString().toLowerCase()
            .replace(/[çÇğĞşŞüÜıİöÖ]/g, c => trMap[c])
            .replace(/\s+/g, '-')     // space to -
            .replace(/[^\w\-]+/g, '') // remove non-word chars
            .replace(/\-\-+/g, '-')   // replace multiple - with single -
            .replace(/^-+/, '')       // trim - from start
            .replace(/-+$/, '');      // trim - from end
    }

    // Vitrindeki firmaları yükle
    async function loadVitrinFirms(db, { collection, getDocs, query, where, doc, getDoc }, demoSettings) {
        // Wait, step 92 showed loadFeaturedFirms and createFirmCard, but NOT loadVitrinFirms.
        // Step 107 shows loadVitrinFirms.
        // I need to be careful with the target content.
        const wrapper = document.getElementById('vitrinWrapper');
        const container = document.getElementById('vitrinContainer');

        try {
            let firmsToRender = [];

            // DEMO MODE CHECK
            if (demoSettings && demoSettings.isActive && demoSettings.vitrinFirms && demoSettings.vitrinFirms.length > 0) {
                // Fetch listed firms directly
                const promises = demoSettings.vitrinFirms.map(async (item) => {
                    try {
                        const snap = await getDoc(doc(db, 'firms', item.id));
                        if (snap.exists()) return { id: snap.id, ...snap.data() };
                    } catch (e) { }
                    return null;
                });
                firmsToRender = (await Promise.all(promises)).filter(f => f !== null);

            } else {
                // NORMAL LOGIC
                const vitrinsRef = collection(db, 'firm_vitrin_purchases');
                const q = query(vitrinsRef, where('isActive', '==', true));
                const snapshot = await getDocs(q);

                if (!snapshot.empty) {
                    const activeVitrins = [];
                    const now = new Date();

                    snapshot.forEach(doc => {
                        const data = doc.data();
                        const endDate = data.endDate?.toDate ? data.endDate.toDate() : new Date(data.endDate);
                        if (endDate > now) {
                            activeVitrins.push({ ...data, id: doc.id });
                        }
                    });

                    if (activeVitrins.length > 0) {
                        const firmPromises = activeVitrins.map(async (vitrin) => {
                            try {
                                const firmRef = doc(db, 'firms', vitrin.firmId);
                                const firmSnap = await getDoc(firmRef);
                                if (firmSnap.exists()) {
                                    return { ...firmSnap.data(), id: vitrin.firmId, vitrinData: vitrin };
                                }
                            } catch (e) { }
                            return null;
                        });
                        firmsToRender = (await Promise.all(firmPromises)).filter(f => f !== null && f.isApproved);
                    }
                }
            }

            if (firmsToRender.length === 0) {
                wrapper.classList.add('d-none');
                return;
            }

            // Render
            wrapper.classList.remove('d-none');
            let html = '';
            firmsToRender.forEach(firm => {
                const rating = firm.rating || 0;
                const address = firm.address || {};
                const cover = firm.coverUrl || firm.logo || 'assets/img/default-firm-cover.png';

                html += `
                <div class="col-md-6 col-lg-3">
                    <div class="card h-100 border-0 shadow-sm hover-elevate">
                        <div class="position-absolute top-0 start-0 w-100 p-2 d-flex justify-content-between z-1">
                            <span class="badge bg-warning text-dark shadow-sm">
                                <i class="fas fa-crown me-1"></i>Vitrin
                            </span>
                            <span class="badge bg-white text-dark shadow-sm">
                                <i class="fas fa-star text-warning me-1"></i>${rating.toFixed(1)}
                            </span>
                        </div>
                        
                        <div class="card-img-top position-relative" style="height: 180px; overflow: hidden;">
                             <img src="${cover}" class="w-100 h-100" style="object-fit: cover;" alt="${firm.name}" loading="lazy"
                                  onerror="this.onerror=null;this.src='assets/img/default-firm-cover.png';">
                        </div>
                        
                        <div class="card-body text-center">
                            <h5 class="card-title fw-bold text-truncate mb-1">${firm.name}</h5>
                            <p class="small text-muted mb-2">
                                <i class="fas fa-map-marker-alt me-1"></i>${address.district || ''}, ${address.city || ''}
                            </p>
                            
                            <a href="firma/${slugify(firm.name)}-${firm.id}" class="btn btn-outline-primary btn-sm w-100 rounded-pill">
                                <i class="fas fa-eye me-1"></i>İncele
                            </a>
                        </div>
                    </div>
                </div>`;
            });

            container.innerHTML = html;

        } catch (error) {
            console.error('Vitrin error:', error);
            wrapper.classList.add('d-none');
        }
    }

    // Öne çıkan firmaları yükle
    async function loadFeaturedFirms(db, { collection, getDocs, query, where, doc, getDoc }, demoSettings) {
        const container = document.getElementById('featuredFirms');

        try {
            let firmsToRender = [];

            // DEMO MODE
            if (demoSettings && demoSettings.isActive && demoSettings.featuredFirms && demoSettings.featuredFirms.length > 0) {
                const promises = demoSettings.featuredFirms.map(async (item) => {
                    try {
                        const snap = await getDoc(doc(db, 'firms', item.id));
                        if (snap.exists()) return { id: snap.id, ...snap.data() };
                    } catch (e) { }
                    return null;
                });
                firmsToRender = (await Promise.all(promises)).filter(f => f !== null);
            } else {
                // NORMAL MODE
                const firmsRef = collection(db, 'firms');
                const q = query(firmsRef, where('isApproved', '==', true));
                const snapshot = await getDocs(q);

                if (!snapshot.empty) {
                    const firms = [];
                    snapshot.forEach(doc => {
                        firms.push({ id: doc.id, ...doc.data() });
                    });
                    firms.sort((a, b) => (b.rating || 0) - (a.rating || 0));
                    firmsToRender = firms.slice(0, 4);
                }
            }

            if (firmsToRender.length === 0) {
                container.innerHTML = `
                <div class="col-12 text-center py-4">
                    <p class="text-muted">Henüz firma bulunmuyor.</p>
                </div>`;
                return;
            }

            let html = '';
            firmsToRender.forEach(firm => {
                html += createFirmCard(firm.id, firm);
            });

            container.innerHTML = html;

        } catch (error) {
            console.error('Firmalar yüklenirken hata:', error);
            container.innerHTML = `<div class="col-12 text-center py-4"><p class="text-danger">...</p></div>`;
        }
    }

    // Firma kartı oluştur
    function createFirmCard(id, firm) {
        const rating = firm.rating || 0;
        const address = firm.address || {};
        const DEFAULT_COVER = 'assets/img/default-firm-cover.png';
        const onError = `this.onerror=null;this.src='${DEFAULT_COVER}';`;

        return `
        <div class="col-md-6 col-lg-3">
            <div class="card firm-card h-100">
                <span class="badge-approved">
                    <i class="fas fa-check me-1"></i>Onaylı
                </span>
                <div class="card-img-top position-relative" style="height: 150px; overflow: hidden;">
                    <img src="${firm.coverUrl || DEFAULT_COVER}" 
                         class="w-100 h-100" 
                         style="object-fit: cover;" 
                         alt="${firm.name}"
                         loading="lazy"
                         onerror="${onError}">
                </div>
                <div class="card-body">
                    <h5 class="card-title text-truncate">${firm.name || 'İsimsiz Firma'}</h5>
                    <p class="location mb-2 small text-muted">
                        <i class="fas fa-map-marker-alt me-1"></i>
                        ${address.district || ''}, ${address.city || ''}
                    </p>
                    <div class="rating mb-3">
                        ${createStarRating(rating)}
                        <span class="text-muted ms-1">(${firm.reviewCount || 0})</span>
                    </div>
                    <a href="firma/${slugify(firm.name)}-${id}" class="btn btn-primary btn-sm w-100">
                        <i class="fas fa-eye me-1"></i>İncele
                    </a>
                </div>
            </div>
        </div>
    `;
    }

    // Aktif kampanyaları yükle
    async function loadActiveCampaigns(db, { collection, getDocs, query, where, doc, getDoc }, demoSettings) {
        const container = document.getElementById('activeCampaigns');
        const now = new Date();

        try {
            let campaignsToRender = [];

            // DEMO MODE
            if (demoSettings && demoSettings.isActive && demoSettings.campaigns && demoSettings.campaigns.length > 0) {
                campaignsToRender = demoSettings.campaigns.map(c => {
                    const id = 'demo_' + Math.random().toString(36).substr(2, 9);
                    return {
                        id: id,
                        ...c,
                        endDate: new Date(c.endDate || new Date().setDate(new Date().getDate() + 30))
                    };
                });
            } else {
                // NORMAL MODE
                const campaignsRef = collection(db, 'campaigns');
                const q = query(campaignsRef, where('isActive', '==', true));
                const snapshot = await getDocs(q);

                const campaigns = [];
                snapshot.forEach(doc => {
                    const data = doc.data();
                    const endDate = data.endDate?.toDate ? data.endDate.toDate() : new Date(data.endDate);
                    if (endDate > now) {
                        campaigns.push({ id: doc.id, ...data, endDate });
                    }
                });
                campaigns.sort((a, b) => a.endDate - b.endDate);
                campaignsToRender = campaigns.slice(0, 3);
            }

            if (campaignsToRender.length === 0) {
                container.innerHTML = `
                <div class="col-12 text-center py-4">
                    <p class="text-muted">Aktif kampanya yok.</p>
                </div>`;
                return;
            }

            let html = '';
            for (const campaign of campaignsToRender) {
                window.campaignData[campaign.id] = campaign;

                // Fetch firm name if missing
                if (!campaign.firmName && campaign.firmId) {
                    try {
                        getDoc(doc(db, 'firms', campaign.firmId)).then(snap => {
                            if (snap.exists() && window.campaignData[campaign.id]) {
                                window.campaignData[campaign.id].firmName = snap.data().name;
                            }
                        });
                    } catch (e) { }
                }

                html += createCampaignCard(campaign.id, campaign);
            }

            container.innerHTML = html;

        } catch (error) {
            console.error('Kampanyalar yüklenirken hata:', error);
            container.innerHTML = `<div class="col-12 text-center py-4"><p class="text-warning">...</p></div>`;
        }
    }


    // Kampanya kartı oluştur
    function createCampaignCard(id, campaign) {
        const endDate = campaign.endDate instanceof Date ? campaign.endDate : new Date(campaign.endDate);
        const daysLeft = Math.ceil((endDate - new Date()) / (1000 * 60 * 60 * 24));

        return `
        <div class="col-6 col-md-3 col-lg-3">
            <div class="card h-100 border-0 shadow-sm hover-elevate" style="background-color: #FFF8E7;">
                <div class="position-absolute top-0 end-0 p-2 z-1">
                     <span class="badge bg-danger shadow-sm small">%${campaign.discountPercent || 0} İndirim</span>
                </div>
                
                <div class="card-body p-3 text-center d-flex flex-column justify-content-between">
                    <div class="mt-3">
                         <h6 class="card-title fw-bold text-dark mb-1 text-truncate">${campaign.title || 'Kampanya'}</h6>
                         <p class="small text-muted mb-2 text-truncate" style="max-width: 100%;">${campaign.description || ''}</p>
                    </div>
                    
                    <div>
                        <div class="small text-danger fw-bold mb-2">
                            <i class="fas fa-clock me-1"></i>${daysLeft} gün kaldı
                        </div>
                        <button onclick="openCampaignDetails('${id}')" class="btn btn-outline-dark btn-sm w-100 rounded-pill" style="font-size: 0.75rem;">
                            Fırsatı Gör
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `;
    }


    // Yıldız rating oluştur
    function createStarRating(rating, maxStars = 5) {
        let stars = '';
        for (let i = 1; i <= maxStars; i++) {
            if (i <= rating) {
                stars += '<i class="fas fa-star text-warning"></i>';
            } else if (i - 0.5 <= rating) {
                stars += '<i class="fas fa-star-half-alt text-warning"></i>';
            } else {
                stars += '<i class="far fa-star text-warning"></i>';
            }
        }
        return stars;
    }

    // İstatistikleri animasyonlu göster
    function animateStats() {
        animateValue('statFirms', 0, 150, 2000);
        animateValue('statCustomers', 0, 5000, 2000);
        animateValue('statOrders', 0, 12500, 2000);
    }

    function animateValue(elementId, start, end, duration) {
        const element = document.getElementById(elementId);
        if (!element) return;

        const range = end - start;
        const startTime = performance.now();

        function update(currentTime) {
            const elapsed = currentTime - startTime;
            const progress = Math.min(elapsed / duration, 1);
            const easeOutQuart = 1 - Math.pow(1 - progress, 4);
            const current = Math.floor(start + range * easeOutQuart);
            element.textContent = current.toLocaleString('tr-TR');
            if (progress < 1) requestAnimationFrame(update);
        }

        requestAnimationFrame(update);
    }

    // Hero Slider Logic
    async function initHeroSlider(db, { collection, getDocs, doc, getDoc }) {
        const track = document.getElementById('sliderTrack');
        if (!track) return;

        let slides = Array.from(track.getElementsByClassName('slider-image'));
        let currentIndex = 0;

        // --- Fetch from Admin (Firestore) ---
        if (db && collection && getDocs && doc && getDoc) {
            try {
                // Fetch settings/hero_slider document
                const sliderDocRef = doc(db, 'settings', 'hero_slider');
                const sliderDoc = await getDoc(sliderDocRef);

                if (sliderDoc.exists() && sliderDoc.data().images && sliderDoc.data().images.length > 0) {
                    // Start from scratch with new images
                    track.innerHTML = '';

                    sliderDoc.data().images.forEach((url, i) => {
                        const img = document.createElement('img');
                        img.src = url;
                        // First one active
                        img.className = 'slider-image' + (i === 0 ? ' active' : '');
                        img.alt = 'Slider ' + (i + 1);
                        track.appendChild(img);
                    });

                    // Update slides array
                    slides = Array.from(track.getElementsByClassName('slider-image'));
                    currentIndex = 0;
                }
            } catch (e) {
                console.log('Slider fetch error:', e);
            }
        }

        if (slides.length <= 1) return;

        // Auto Cycle
        setInterval(() => {
            const currentSlide = slides[currentIndex];

            // Calc next index
            currentIndex = (currentIndex + 1) % slides.length;
            const nextSlide = slides[currentIndex];

            // Transitions
            // Remove active from all, add last-active to current for smooth exit if needed
            // Actually, my CSS logic:
            // active: opacity 1, z-index 2
            // normal: opacity 0, z-index 0
            // I need to keep the "previous" one visible for a moment while the new one fades in?
            // With standard opacity fade on absolute elements:
            // If New goes to Opacity 1 (on top), Old stays Opacity 1 (below)? No.
            // Old needs to fade out?
            // CSS: .slider-image { opacity: 0; transition: opacity 1s }
            // .active { opacity: 1 }
            // So if I switch classes:
            // Old: Remove active -> fades to 0
            // New: Add active -> fades to 1
            // If both happen same time, and background is visible, it might cross-fade through background color.
            // To prevent background flash, we can use a "last-active" class or just ensure the next one is on top before fading prev out?
            // Simple approach:

            slides.forEach(s => s.classList.remove('active', 'last-active'));
            currentSlide.classList.add('last-active'); // Keep it visible-ish or just fading out
            nextSlide.classList.add('active');

        }, 4000); // 4 seconds per slide
    }

    // Store campaigns globally for modal access
    window.campaignData = {};

    // Modal Açma Fonksiyonu
    window.openCampaignDetails = function (id) {
        const campaign = window.campaignData[id];
        if (!campaign) return;

        const dateStr = campaign.endDate instanceof Date
            ? campaign.endDate.toLocaleDateString('tr-TR')
            : new Date(campaign.endDate).toLocaleDateString('tr-TR');

        document.getElementById('campaignModalBadge').textContent = '%' + (campaign.discountPercent || 0) + ' İndirim';
        document.getElementById('campaignModalName').textContent = campaign.title || 'Kampanya';
        document.getElementById('campaignModalFirm').textContent = campaign.firmName || 'Kampanyayı İncele';
        document.getElementById('campaignModalDesc').textContent = campaign.description || 'Bu kampanya için detaylı açıklama bulunmuyor.';
        document.getElementById('campaignModalDate').textContent = dateStr;

        const link = document.getElementById('campaignModalLink');
        link.href = `customer/firm-detail.php?id=${campaign.firmId}`;

        const modal = new bootstrap.Modal(document.getElementById('campaignModal'));
        modal.show();
    };
</script>
<script>
    // Call slider manually if firebase module doesn't trigger fast enough or for static fallback
    document.addEventListener('DOMContentLoaded', () => {
        // Basic fallback init if firebase logic is delayed, 
        // but wait, the main logic is in the module.
        // Let's just rely on the module or a separate non-module script tag if needed.
        // Actually, I can just append `initHeroSlider(null, {})` to the module execution.
    });
</script>

<?php require_once 'includes/footer.php'; ?>