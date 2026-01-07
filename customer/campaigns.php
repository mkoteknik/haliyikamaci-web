<?php
/**
 * Halı Yıkamacı - Kampanyalar
 */

require_once '../config/app.php';
$pageTitle = 'Aktif Kampanyalar';
require_once '../includes/header.php';
?>

<!-- Page Header -->
<section class="bg-gradient-primary text-white py-5">
    <div class="container">
        <h1 class="fw-bold mb-2">
            <i class="fas fa-tags me-2"></i>Aktif Kampanyalar
        </h1>
        <p class="opacity-75 mb-0">
            Halı yıkama firmalarından kaçırılmayacak fırsatlar
        </p>
    </div>
</section>

<!-- Campaigns Grid -->
<section class="section">
    <div class="container">
        <div class="row g-4" id="campaignsList">
            <div class="col-12 text-center py-5">
                <div class="spinner"></div>
                <p class="text-muted mt-3">Kampanyalar yükleniyor...</p>
            </div>
        </div>
    </div>
</section>

<script type="module">
    window.addEventListener('firebaseReady', async function () {
        const { collection, getDocs, query, where } = window.firebaseModules;
        const db = window.firebaseDb;

        await loadCampaigns(db, { collection, getDocs, query, where });
    });

    // Helper: Slugify
    function slugify(text) {
        if (!text) return 'firma';
        const trMap = {
            'ç': 'c', 'Ç': 'c', 'ğ': 'g', 'Ğ': 'g',
            'ş': 's', 'Ş': 's', 'ü': 'u', 'Ü': 'u',
            'ı': 'i', 'İ': 'i', 'ö': 'o', 'Ö': 'o'
        };
        return text.toString().toLowerCase()
            .replace(/[çÇğĞşŞüÜıİöÖ]/g, c => trMap[c])
            .replace(/\s+/g, '-')
            .replace(/[^\w\-]+/g, '')
            .replace(/\-\-+/g, '-')
            .replace(/^-+/, '')
            .replace(/-+$/, '');
    }

    async function loadCampaigns(db, { collection, getDocs, query, where }) {
        const container = document.getElementById('campaignsList');
        const now = new Date();

        try {
            const campaignsRef = collection(db, 'campaigns');
            const q = query(campaignsRef, where('isActive', '==', true));
            const snapshot = await getDocs(q);

            // Filter by endDate > now
            let campaigns = [];
            snapshot.forEach(doc => {
                const data = doc.data();
                const endDate = data.endDate?.toDate ? data.endDate.toDate() : new Date(data.endDate);
                if (endDate > now) {
                    campaigns.push({ id: doc.id, ...data, endDate });
                }
            });

            // Sort by endDate
            campaigns.sort((a, b) => a.endDate - b.endDate);

            if (campaigns.length === 0) {
                container.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-tags fa-4x text-muted mb-3"></i>
                    <h4>Aktif Kampanya Yok</h4>
                    <p class="text-muted">Şu an aktif kampanya bulunmuyor. Yeni kampanyalar için takipte kalın!</p>
                    <a href="<?php echo SITE_URL; ?>/firmalar" class="btn btn-primary">
                        <i class="fas fa-store me-2"></i>Firmaları İncele
                    </a>
                </div>
            `;
                return;
            }

            // We need to get firm names for each campaign
            const firmsRef = collection(db, 'firms');
            const firmsSnapshot = await getDocs(firmsRef);
            const firmsMap = {};
            firmsSnapshot.forEach(doc => {
                firmsMap[doc.id] = doc.data();
            });

            let html = '';
            campaigns.forEach(campaign => {
                const firm = firmsMap[campaign.firmId] || {};
                html += createCampaignCard(campaign, firm);
            });

            container.innerHTML = html;

        } catch (error) {
            console.error('Kampanyalar yüklenirken hata:', error);
            container.innerHTML = `
            <div class="col-12 text-center py-5">
                <i class="fas fa-exclamation-circle fa-4x text-danger mb-3"></i>
                <h4>Bir Hata Oluştu</h4>
                <p class="text-muted">${error.message}</p>
            </div>
        `;
        }
    }

    function createCampaignCard(campaign, firm) {
        const daysLeft = Math.ceil((campaign.endDate - new Date()) / (1000 * 60 * 60 * 24));
        const startDate = campaign.startDate?.toDate ? campaign.startDate.toDate() : new Date(campaign.startDate);

        return `
        <div class="col-md-6 col-lg-4">
            <div class="card h-100 border-0 shadow-sm overflow-hidden">
                <!-- Campaign Image -->
                <div class="position-relative">
                    ${campaign.image
                ? `<img src="${campaign.image}" class="card-img-top" alt="${campaign.title}" loading="lazy" style="height: 200px; object-fit: cover;" onerror="this.parentElement.innerHTML='<div class=\\'bg-gradient-primary text-white d-flex align-items-center justify-content-center\\' style=\\'height: 200px;\\'><i class=\\'fas fa-percentage fa-4x opacity-50\\'></i></div>'">`
                : `<div class="bg-gradient-primary text-white d-flex align-items-center justify-content-center" style="height: 200px;">
                               <i class="fas fa-percentage fa-4x opacity-50"></i>
                           </div>`
            }
                    <span class="position-absolute top-0 end-0 m-3 badge bg-warning text-dark fs-5">
                        %${campaign.discountPercent} İndirim
                    </span>
                </div>
                
                <div class="card-body">
                    <h5 class="card-title fw-bold">${campaign.title}</h5>
                    <p class="text-muted">${campaign.description || ''}</p>
                    
                    <!-- Firm Info -->
                    <div class="d-flex align-items-center mb-3">
                        <div class="bg-light rounded-circle d-flex align-items-center justify-content-center me-2" style="width: 40px; height: 40px;">
                            ${firm.logo
                ? `<img src="${firm.logo}" alt="${firm.name}" class="rounded-circle" loading="lazy" style="width: 100%; height: 100%; object-fit: cover;">`
                : `<i class="fas fa-store text-muted"></i>`
            }
                        </div>
                        <div>
                            <strong>${firm.name || 'Firma'}</strong>
                            <br><small class="text-muted">${firm.address?.district || ''}, ${firm.address?.city || ''}</small>
                        </div>
                    </div>
                    
                    <!-- Date Info -->
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="badge ${daysLeft <= 3 ? 'bg-danger' : 'bg-success'} px-3 py-2">
                            <i class="fas fa-clock me-1"></i>${daysLeft} gün kaldı
                        </span>
                        <small class="text-muted">
                            ${formatDate(startDate)} - ${formatDate(campaign.endDate)}
                        </small>
                    </div>
                </div>
                
                <div class="card-footer bg-white border-0">
                    <a href="../firma/${slugify(firm.name)}-${campaign.firmId}" class="btn btn-primary w-100">
                        <i class="fas fa-store me-2"></i>Firmaya Git
                    </a>
                </div>
            </div>
        </div>
    `;
    }

    function formatDate(date) {
        return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(date);
    }
</script>

<?php require_once '../includes/footer.php'; ?>