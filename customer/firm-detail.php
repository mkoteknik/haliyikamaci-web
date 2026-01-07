<?php
/**
 * Halı Yıkamacı - Firma Detay
 */

require_once '../config/app.php';
// Add Firebase Service for Server-Side SEO
require_once '../includes/FirebaseService.php';

$firmId = isset($_GET['id']) ? htmlspecialchars($_GET['id']) : '';

if (empty($firmId)) {
    header('Location: ' . SITE_URL . '/firmalar');
    exit;
}

// Default values
$pageTitle = 'Firma Detay';
$pageDescription = SITE_DESCRIPTION;
$ogImage = null;

// Fetch Firm Data Server-Side
try {
    $firebase = new FirebaseService();
    $firm = $firebase->getDocument('firms', $firmId);

    if ($firm) {
        $firmName = isset($firm['name']) ? $firm['name'] : 'Firma';
        $city = isset($firm['address']['city']) ? $firm['address']['city'] : '';
        $district = isset($firm['address']['district']) ? $firm['address']['district'] : '';

        // Location string
        $locationParts = [];
        if ($district)
            $locationParts[] = $district;
        if ($city)
            $locationParts[] = $city;
        $location = implode(', ', $locationParts);

        // Update Page Title: "Firm Name - District, City | Site Name"
        $pageTitle = $firmName;
        if ($location) {
            $pageTitle .= " - " . $location;
        }

        // Update Description
        $desc = "$firmName";
        if ($location) {
            $desc .= ", $location bölgesinde hizmet veren onaylı halı yıkama firmasıdır.";
        } else {
            $desc .= " halı yıkama hizmetleri.";
        }

        if (isset($firm['rating']) && $firm['rating'] > 0) {
            $desc .= " Müşteri puanı: " . number_format((float) $firm['rating'], 1) . ".";
        }

        $desc .= " Hizmetleri ve fiyatları incelemek için hemen tıklayın.";
        $pageDescription = $desc;

        // Update OG Image
        if (isset($firm['logo']) && !empty($firm['logo'])) {
            $ogImage = $firm['logo'];
        } else if (isset($firm['coverUrl']) && !empty($firm['coverUrl'])) {
            $ogImage = $firm['coverUrl'];
        }

        // Schema.org: LocalBusiness
        $pageSchema = [
            "@context" => "https://schema.org",
            "@type" => "HomeAndConstructionBusiness", // More specific than LocalBusiness
            "name" => $firmName,
            "image" => $ogImage ?? SITE_URL . '/assets/img/logo/logo.png',
            "@id" => SITE_URL . $_SERVER['REQUEST_URI'],
            "url" => SITE_URL . $_SERVER['REQUEST_URI'],
            "telephone" => isset($firm['phone']) ? $firm['phone'] : '',
            "priceRange" => "₺₺", // Default price range
            "address" => [
                "@type" => "PostalAddress",
                "streetAddress" => isset($firm['address']['fullAddress']) ? $firm['address']['fullAddress'] : '',
                "addressLocality" => $district,
                "addressRegion" => $city,
                "addressCountry" => "TR"
            ]
        ];

        // Add Aggregate Rating
        if (isset($firm['rating']) && $firm['rating'] > 0 && isset($firm['reviewCount']) && $firm['reviewCount'] > 0) {
            $pageSchema["aggregateRating"] = [
                "@type" => "AggregateRating",
                "ratingValue" => $firm['rating'],
                "reviewCount" => $firm['reviewCount'],
                "bestRating" => "5",
                "worstRating" => "1"
            ];
        }

        // Add GeoCoordinates if available (Optional, if fetched from map)
        // if (isset($firm['location'])) ...
    } else {
        // Firm not found on server side - Send 404 to avoid Soft 404 in Google
        http_response_code(404);
        $pageTitle = "Firma Bulunamadı";
        $pageDescription = "Aradığınız firma bulunamadı.";
    }
} catch (Exception $e) {
    // If error occurs, we fallback to defaults silently, but for critical connection errors, maybe 500?
    // Keeping silent fallback for now to not break UX if just API glitch
}

require_once '../includes/header.php';
?>

<!-- Loading State -->
<div id="loadingState" class="py-5 text-center">
    <div class="spinner"></div>
    <p class="text-muted mt-3">Firma bilgileri yükleniyor...</p>
</div>

<!-- Error State -->
<div id="errorState" class="py-5 text-center" style="display: none;">
    <i class="fas fa-exclamation-circle fa-4x text-danger mb-3"></i>
    <h4>Firma Bulunamadı</h4>
    <p class="text-muted">Aradığınız firma bulunamadı veya artık mevcut değil.</p>
    <a href="<?php echo SITE_URL; ?>/firmalar" class="btn btn-primary">
        <i class="fas fa-arrow-left me-2"></i>Firmalara Dön
    </a>
</div>

<!-- Firm Content -->
<div id="firmContent" style="display: none;">
    <!-- Firm Header -->
    <section class="bg-gradient-primary text-white py-5">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-2 text-center mb-3 mb-md-0">
                    <div id="firmLogo"
                        class="bg-white rounded-circle d-inline-flex align-items-center justify-content-center"
                        style="width: 120px; height: 120px; overflow: hidden;">
                        <i class="fas fa-store fa-3x text-primary"></i>
                    </div>
                </div>
                <div class="col-md-7">
                    <h1 class="fw-bold mb-2" id="firmName">Firma Adı</h1>
                    <p class="mb-2" id="firmAddress">
                        <i class="fas fa-map-marker-alt me-2"></i>Adres
                    </p>
                    <div class="d-flex align-items-center gap-3">
                        <div id="firmRating" class="rating">
                            <i class="fas fa-star text-warning"></i>
                            <span>0.0</span>
                        </div>
                        <span class="opacity-75" id="firmReviewCount">(0 değerlendirme)</span>
                    </div>
                </div>
                <div class="col-md-3 text-md-end mt-3 mt-md-0">
                    <a href="#" id="firmPhone" class="btn btn-warning btn-lg mb-2 w-100">
                        <i class="fas fa-phone me-2"></i>Ara
                    </a>
                    <a href="#" id="firmWhatsapp" class="btn btn-success w-100" style="display: none;">
                        <i class="fab fa-whatsapp me-2"></i>WhatsApp
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Main Content -->
    <section class="section">
        <div class="container">
            <div class="row g-4">
                <!-- Left Column - Services & Info -->
                <div class="col-lg-8">
                    <!-- Services -->
                    <div class="card mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-list-check text-primary me-2"></i>Hizmetler ve Fiyatlar
                            </h5>
                        </div>
                        <div class="card-body">
                            <div id="servicesList" class="table-responsive">
                                <table class="table table-hover mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Hizmet</th>
                                            <th>Birim</th>
                                            <th>Fiyat</th>
                                        </tr>
                                    </thead>
                                    <tbody id="servicesTableBody">
                                        <!-- Services loaded here -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Payment Methods -->
                    <div class="card mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-credit-card text-primary me-2"></i>Ödeme Yöntemleri
                            </h5>
                        </div>
                        <div class="card-body">
                            <div id="paymentMethods" class="d-flex flex-wrap gap-2">
                                <!-- Payment methods loaded here -->
                            </div>
                        </div>
                    </div>

                    <!-- Reviews -->
                    <div class="card">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center">
                            <h5 class="mb-0">
                                <i class="fas fa-star text-primary me-2"></i>Değerlendirmeler
                            </h5>
                            <span class="badge bg-primary" id="reviewsBadge">0</span>
                        </div>
                        <div class="card-body">
                            <div id="reviewsList">
                                <p class="text-muted text-center py-3">Henüz değerlendirme yok.</p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Right Column - Order Form -->
                <div class="col-lg-4">
                    <div class="card sticky-top" style="top: 100px;">
                        <div class="card-header bg-primary text-white">
                            <h5 class="mb-0">
                                <i class="fas fa-shopping-cart me-2"></i>Sipariş Ver
                            </h5>
                        </div>
                        <div class="card-body">
                            <!-- Login Required Message -->
                            <div id="loginRequired">
                                <div class="text-center py-4">
                                    <i class="fas fa-lock fa-3x text-muted mb-3"></i>
                                    <h6>Sipariş vermek için giriş yapın</h6>
                                    <p class="text-muted small">Hesabınıza giriş yaparak sipariş verebilirsiniz.</p>
                                    <a href="login.php?redirect=firm-detail.php?id=<?php echo $firmId; ?>"
                                        class="btn btn-primary w-100">
                                        <i class="fas fa-sign-in-alt me-2"></i>Giriş Yap
                                    </a>
                                </div>
                            </div>

                            <!-- Order Form -->
                            <form id="orderForm" style="display: none;">
                                <input type="hidden" id="firmIdInput" value="<?php echo $firmId; ?>">

                                <!-- Selected Services -->
                                <div class="mb-3">
                                    <div class="form-label fw-bold">Hizmetler</div>
                                    <div id="orderServices">
                                        <!-- Checkboxes for services -->
                                    </div>
                                </div>

                                <!-- Address -->
                                <div class="mb-3">
                                    <label for="addressSelect" class="form-label fw-bold">Adres</label>
                                    <select id="addressSelect" class="form-select" required>
                                        <option value="">Adres Seçin</option>
                                    </select>
                                    <a href="profile.php" class="small text-primary">
                                        <i class="fas fa-plus me-1"></i>Yeni adres ekle
                                    </a>
                                </div>

                                <!-- Payment Method -->
                                <div class="mb-3">
                                    <label for="paymentSelect" class="form-label fw-bold">Ödeme Yöntemi</label>
                                    <select id="paymentSelect" class="form-select" required>
                                        <option value="">Seçin</option>
                                    </select>
                                </div>

                                <!-- Notes -->
                                <div class="mb-3">
                                    <label for="orderNotes" class="form-label fw-bold">Notlar (Opsiyonel)</label>
                                    <textarea id="orderNotes" class="form-control" rows="2"
                                        placeholder="Özel isteklerinizi yazın..."></textarea>
                                </div>

                                <button type="submit" class="btn btn-primary w-100 btn-lg">
                                    <i class="fas fa-check me-2"></i>Sipariş Oluştur
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>

<script type="module">
    const firmId = '<?php echo $firmId; ?>';

    window.addEventListener('firebaseReady', async function () {
        const { collection, getDocs, query, where, doc, getDoc, addDoc, Timestamp } = window.firebaseModules;
        const db = window.firebaseDb;
        const auth = window.firebaseAuth;

        // Import additional modules
        const { doc: docRef, getDoc: getDocFn, addDoc: addDocFn, serverTimestamp } = await import('https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js');

        await loadFirmDetails(db, docRef, getDocFn);
        await loadReviews(db, { collection, getDocs, query, where });

        // Check auth state for order form
        auth.onAuthStateChanged(async (user) => {
            if (user) {
                document.getElementById('loginRequired').style.display = 'none';
                document.getElementById('orderForm').style.display = 'block';
                await loadCustomerAddresses(db, { collection, getDocs, query, where }, user.uid);
            } else {
                document.getElementById('loginRequired').style.display = 'block';
                document.getElementById('orderForm').style.display = 'none';
            }
        });

        // Order form submit
        document.getElementById('orderForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            await submitOrder(db, addDocFn, collection, auth.currentUser);
        });
    });

    // Firma detaylarını yükle
    async function loadFirmDetails(db, docRef, getDocFn) {
        try {
            const firmDoc = await getDocFn(docRef(db, 'firms', firmId));

            if (!firmDoc.exists()) {
                document.getElementById('loadingState').style.display = 'none';
                document.getElementById('errorState').style.display = 'block';
                return;
            }

            const firm = firmDoc.data();
            window.currentFirm = { id: firmId, ...firm };

            // Update UI
            document.getElementById('firmName').textContent = firm.name || 'İsimsiz Firma';
            document.getElementById('firmAddress').innerHTML = `
            <i class="fas fa-map-marker-alt me-2"></i>
            ${firm.address?.fullAddress || ''}, ${firm.address?.district || ''}, ${firm.address?.city || ''}
        `;

            // Logo
            if (firm.logo) {
                document.getElementById('firmLogo').innerHTML = `
                <img src="${firm.logo}" alt="${firm.name}" style="width: 100%; height: 100%; object-fit: cover;">
            `;
            }

            // Rating
            const rating = firm.rating || 0;
            document.getElementById('firmRating').innerHTML = `
            ${createStarRating(rating)}
            <span class="ms-1">${rating.toFixed(1)}</span>
        `;
            document.getElementById('firmReviewCount').textContent = `(${firm.reviewCount || 0} değerlendirme)`;

            // Phone
            if (firm.phone) {
                document.getElementById('firmPhone').href = `tel:${firm.phone}`;
                document.getElementById('firmPhone').innerHTML = `<i class="fas fa-phone me-2"></i>${firm.phone}`;
            }

            // WhatsApp
            if (firm.whatsapp) {
                const wpLink = document.getElementById('firmWhatsapp');
                wpLink.href = `https://wa.me/${firm.whatsapp.replace(/\D/g, '')}`;
                wpLink.style.display = 'block';
            }

            // Services
            const services = firm.services || [];
            if (services.length > 0) {
                const tbody = document.getElementById('servicesTableBody');
                const orderServices = document.getElementById('orderServices');

                tbody.innerHTML = services.filter(s => s.enabled).map(s => `
                <tr>
                    <td><strong>${s.serviceName}</strong></td>
                    <td>${getUnitLabel(s.unit)}</td>
                    <td class="text-primary fw-bold">${formatPrice(s.price)}</td>
                </tr>
            `).join('');

                orderServices.innerHTML = services.filter(s => s.enabled).map((s, i) => `
                <div class="form-check">
                    <input type="checkbox" class="form-check-input service-checkbox" 
                           id="service_${i}" value="${s.serviceId}" 
                           data-name="${s.serviceName}" data-unit="${s.unit}" data-price="${s.price}">
                    <label class="form-check-label" for="service_${i}">
                        ${s.serviceName} (${formatPrice(s.price)}/${getUnitLabel(s.unit)})
                    </label>
                </div>
            `).join('');
            }

            // Payment Methods
            const paymentMethods = firm.paymentMethods || ['cash'];
            const paymentLabels = { cash: 'Nakit', card: 'Kapıda Kredi Kartı', transfer: 'Havale/EFT' };
            const paymentIcons = { cash: 'money-bill', card: 'credit-card', transfer: 'university' };

            document.getElementById('paymentMethods').innerHTML = paymentMethods.map(m => `
            <span class="badge bg-light text-dark border px-3 py-2">
                <i class="fas fa-${paymentIcons[m] || 'wallet'} me-1"></i>${paymentLabels[m] || m}
            </span>
        `).join('');

            document.getElementById('paymentSelect').innerHTML = `
            <option value="">Seçin</option>
            ${paymentMethods.map(m => `<option value="${m}">${paymentLabels[m] || m}</option>`).join('')}
        `;

            // Show content
            document.getElementById('loadingState').style.display = 'none';
            document.getElementById('firmContent').style.display = 'block';

            // Update page title
            document.title = `${firm.name} - Halı Yıkamacı`;

        } catch (error) {
            console.error('Firma yüklenirken hata:', error);
            document.getElementById('loadingState').style.display = 'none';
            document.getElementById('errorState').style.display = 'block';
        }
    }

    // Değerlendirmeleri yükle
    async function loadReviews(db, { collection, getDocs, query, where }) {
        try {
            const reviewsRef = collection(db, 'reviews');
            const q = query(reviewsRef, where('firmId', '==', firmId));
            const snapshot = await getDocs(q);

            document.getElementById('reviewsBadge').textContent = snapshot.size;

            if (snapshot.empty) {
                return;
            }

            let html = '';
            snapshot.forEach(doc => {
                const review = doc.data();
                const date = review.createdAt?.toDate ? review.createdAt.toDate() : new Date();

                html += `
                <div class="border-bottom pb-3 mb-3">
                    <div class="d-flex justify-content-between align-items-start">
                        <div>
                            <strong>${review.customerName || 'Anonim'}</strong>
                            <div class="rating small">
                                ${createStarRating(review.rating || 5)}
                            </div>
                        </div>
                        <small class="text-muted">${formatDate(date)}</small>
                    </div>
                    ${review.comment ? `<p class="mb-0 mt-2">${review.comment}</p>` : ''}
                </div>
            `;
            });

            document.getElementById('reviewsList').innerHTML = html;

        } catch (error) {
            console.error('Değerlendirmeler yüklenirken hata:', error);
        }
    }

    // Müşteri adreslerini yükle
    async function loadCustomerAddresses(db, { collection, getDocs, query, where }, uid) {
        try {
            const customersRef = collection(db, 'customers');
            const q = query(customersRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);

            if (snapshot.empty) return;

            const customer = snapshot.docs[0].data();
            const addresses = customer.savedAddresses || [];
            const currentAddress = customer.address;

            let options = '<option value="">Adres Seçin</option>';

            if (currentAddress && currentAddress.fullAddress) {
                options += `<option value="current" selected>${currentAddress.fullAddress}, ${currentAddress.district}, ${currentAddress.city}</option>`;
            }

            addresses.forEach((addr, i) => {
                options += `<option value="${i}">${addr.title || 'Adres ' + (i + 1)}: ${addr.fullAddress}, ${addr.district}</option>`;
            });

            document.getElementById('addressSelect').innerHTML = options;
            window.customerData = { id: snapshot.docs[0].id, ...customer };

        } catch (error) {
            console.error('Adresler yüklenirken hata:', error);
        }
    }

    // Sipariş oluştur
    async function submitOrder(db, addDocFn, collection, user) {
        const selectedServices = [];
        document.querySelectorAll('.service-checkbox:checked').forEach(cb => {
            selectedServices.push({
                serviceId: cb.value,
                serviceName: cb.dataset.name,
                unit: cb.dataset.unit,
                quantity: 1
            });
        });

        if (selectedServices.length === 0) {
            alert('Lütfen en az bir hizmet seçin.');
            return;
        }

        const addressSelect = document.getElementById('addressSelect').value;
        const paymentMethod = document.getElementById('paymentSelect').value;
        const notes = document.getElementById('orderNotes').value;

        if (!addressSelect || !paymentMethod) {
            alert('Lütfen adres ve ödeme yöntemi seçin.');
            return;
        }

        // Get address data
        let address;
        if (addressSelect === 'current') {
            address = window.customerData.address;
        } else {
            address = window.customerData.savedAddresses[parseInt(addressSelect)];
        }

        const firm = window.currentFirm;
        const customer = window.customerData;

        const orderData = {
            firmId: firm.id,
            firmName: firm.name,
            firmPhone: firm.phone || '',
            customerId: user.uid,
            customerName: `${customer.name} ${customer.surname}`,
            customerPhone: customer.phone,
            customerAddress: address,
            paymentMethod: paymentMethod,
            status: 'pending',
            items: selectedServices,
            notes: notes || null,
            createdAt: new Date(),
            isRated: false
        };

        try {
            const ordersRef = collection(db, 'orders');
            await addDocFn(ordersRef, orderData);

            alert('Siparişiniz başarıyla oluşturuldu! Firma en kısa sürede sizinle iletişime geçecektir.');
            window.location.href = 'my-orders.php';

        } catch (error) {
            console.error('Sipariş oluşturulurken hata:', error);
            alert('Sipariş oluşturulurken bir hata oluştu: ' + error.message);
        }
    }

    // Helper functions
    function createStarRating(rating, maxStars = 5) {
        let stars = '';
        for (let i = 1; i <= maxStars; i++) {
            if (i <= rating) stars += '<i class="fas fa-star text-warning"></i>';
            else if (i - 0.5 <= rating) stars += '<i class="fas fa-star-half-alt text-warning"></i>';
            else stars += '<i class="far fa-star text-warning"></i>';
        }
        return stars;
    }

    function formatPrice(price) {
        return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(price);
    }

    function formatDate(date) {
        return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(date);
    }

    function getUnitLabel(unit) {
        const labels = { m2: 'm²', adet: 'Adet', takim: 'Takım' };
        return labels[unit] || unit;
    }
</script>

<?php require_once '../includes/footer.php'; ?>