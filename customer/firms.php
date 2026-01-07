<?php
/**
 * Halı Yıkamacı - Firma Listesi
 */

require_once '../config/app.php';
$pageTitle = 'Firmalar';
require_once '../includes/header.php';

// URL parametreleri
$city = isset($_GET['city']) ? htmlspecialchars($_GET['city']) : '';
$query = isset($_GET['q']) ? htmlspecialchars($_GET['q']) : '';
?>

<!-- Page Header -->
<section class="bg-gradient-primary text-white py-5">
    <div class="container">
        <h1 class="fw-bold mb-2">
            <i class="fas fa-store me-2"></i>Halı Yıkama Firmaları
        </h1>
        <p class="opacity-75 mb-0">
            Bölgenizdeki güvenilir halı yıkama firmalarını keşfedin
        </p>
    </div>
</section>

<!-- Search & Filter -->
<section class="py-4 bg-light border-bottom">
    <div class="container">
        <?php
        $searchFormId = 'filterForm';
        include '../includes/search-bar.php';
        ?>
    </div>
</section>

<!-- Firms Grid -->
<section class="section">
    <div class="container">
        <!-- Sort Options -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <p class="mb-0 text-muted">
                <span id="firmCount">0</span> firma bulundu
            </p>
            <select id="sortOrder" class="form-select w-auto">
                <option value="rating">En Yüksek Puan</option>
                <option value="name">İsme Göre (A-Z)</option>
                <option value="reviews">En Çok Değerlendirilen</option>
            </select>
        </div>

        <!-- Firms List -->
        <div class="row g-4" id="firmsList">
            <div class="col-12 text-center py-5">
                <div class="spinner"></div>
                <p class="text-muted mt-3">Firmalar yükleniyor...</p>
            </div>
        </div>

        <!-- Load More -->
        <div class="text-center mt-4" id="loadMoreContainer" style="display: none;">
            <button id="loadMoreBtn" class="btn btn-outline-primary btn-lg">
                Daha Fazla Göster <i class="fas fa-chevron-down ms-2"></i>
            </button>
        </div>
    </div>
</section>

<script type="module">
    const SITE_URL = '<?php echo SITE_URL; ?>';

    // Firebase hazır olduğunda
    window.addEventListener('firebaseReady', async function () {
        const { collection, getDocs, query, where } = window.firebaseModules;
        const db = window.firebaseDb;

        // İlk yükleme
        await loadFirms(db, { collection, getDocs, query, where });

        // Filter form
        document.getElementById('filterForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            await loadFirms(db, { collection, getDocs, query, where });
        });

        // Clear filters logic could be added to a button if we had one in the component.
        // The new component doesn't have a clear button.
        // If user wants to clear, they select "Seçiniz" options.
        // Or I could add a clear button to the component?
        // User didn't ask for it specifically in the component, but it was there in firms.php.
        // For now, I'll rely on dropdowns "İl Seçin" value which is empty.

        // Sort change
        document.getElementById('sortOrder').addEventListener('change', async () => {
            await loadFirms(db, { collection, getDocs, query, where });
        });
    });

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

    // Tüm firmaları yükle
    async function loadFirms(db, { collection, getDocs, query, where }) {
        const container = document.getElementById('firmsList');
        const countEl = document.getElementById('firmCount');

        const cityFilter = document.getElementById('searchCity').value;
        const districtFilter = document.getElementById('searchDistrict').value;
        const searchQuery = document.getElementById('searchQuery').value.toLowerCase();
        const sortOrder = document.getElementById('sortOrder').value;

        try {
            const firmsRef = collection(db, 'firms');
            const q = query(firmsRef, where('isApproved', '==', true));
            const snapshot = await getDocs(q);

            let firms = [];
            snapshot.forEach(doc => {
                const data = doc.data();
                firms.push({ id: doc.id, ...data });
            });

            // Client-side filtering
            if (cityFilter) {
                firms = firms.filter(f => f.address?.city === cityFilter);
            }

            if (districtFilter) {
                firms = firms.filter(f => f.address?.district === districtFilter);
            }

            if (searchQuery) {
                firms = firms.filter(f =>
                    f.name?.toLowerCase().includes(searchQuery)
                );
            }

            // Sorting
            switch (sortOrder) {
                case 'rating':
                    firms.sort((a, b) => (b.rating || 0) - (a.rating || 0));
                    break;
                case 'name':
                    firms.sort((a, b) => (a.name || '').localeCompare(b.name || ''));
                    break;
                case 'reviews':
                    firms.sort((a, b) => (b.reviewCount || 0) - (a.reviewCount || 0));
                    break;
            }

            countEl.textContent = firms.length;

            if (firms.length === 0) {
                container.innerHTML = `
                <div class="col-12 text-center py-5">
                    <i class="fas fa-search fa-4x text-muted mb-3"></i>
                    <h4>Firma Bulunamadı</h4>
                    <p class="text-muted">Arama kriterlerinize uygun firma bulunamadı.</p>
                </div>
            `;
                return;
            }

            // Default cover image definition for Firm Listings
            const DEFAULT_COVER = '../assets/img/default-firm-cover.png';
            const ERROR_HANDLER = `this.onerror=null;this.src='${DEFAULT_COVER}';`;

            let html = '';
            firms.forEach(firm => {
                html += createFirmCard(firm.id, firm, DEFAULT_COVER, ERROR_HANDLER);
            });

            container.innerHTML = html;

        } catch (error) {
            console.error('Firmalar yüklenirken hata:', error);
            container.innerHTML = `
            <div class="col-12 text-center py-5">
                <i class="fas fa-exclamation-circle fa-4x text-danger mb-3"></i>
                <h4>Bir Hata Oluştu</h4>
                <p class="text-muted">${error.message}</p>
            </div>
        `;
        }
    }

    // Firma kartı
    function createFirmCard(id, firm, defaultCover, errorHandler) {
        const rating = firm.rating || 0;
        const address = firm.address || {};
        const services = firm.services || [];
        const slug = slugify(firm.name);
        const detailLink = `${SITE_URL}/firma/${slug}-${id}`;

        return `
        <div class="col-md-6 col-lg-4">
            <div class="card firm-card h-100">
                <span class="badge-approved">
                    <i class="fas fa-check me-1"></i>Onaylı
                </span>
                <div class="card-img-top position-relative" style="height: 180px; overflow: hidden;">
                    <img src="${firm.coverUrl || defaultCover}" 
                         class="w-100 h-100" 
                         style="object-fit: cover;" 
                         alt="${firm.name}"
                         loading="lazy"
                         onerror="${errorHandler}">
                </div>
                <div class="card-body">
                    <h5 class="card-title mb-2">${firm.name || 'İsimsiz Firma'}</h5>
                    <p class="location mb-2">
                        <i class="fas fa-map-marker-alt me-1 text-primary"></i>
                        ${address.district || ''}, ${address.city || ''}
                    </p>
                    <div class="rating mb-2">
                        ${createStarRating(rating)}
                        <span class="text-muted ms-1">(${firm.reviewCount || 0} değerlendirme)</span>
                    </div>
                    ${services.length > 0 ? `
                        <div class="services-preview mb-3">
                            ${services.slice(0, 3).map(s =>
            `<span class="badge bg-light text-dark me-1">${s.serviceName || s.name || 'Hizmet'}</span>`
        ).join('')}
                            ${services.length > 3 ? `<span class="badge bg-secondary">+${services.length - 3}</span>` : ''}
                        </div>
                    ` : ''}
                    <a href="${detailLink}" class="btn btn-primary w-100">
                        <i class="fas fa-eye me-1"></i>Detayları Gör
                    </a>
                </div>
            </div>
        </div>
    `;
    }

    // Yıldız rating
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
</script>

<?php require_once '../includes/footer.php'; ?>