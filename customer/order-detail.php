<?php
/**
 * Halı Yıkamacı - Sipariş Detay
 */

require_once '../config/app.php';
$pageTitle = 'Sipariş Detay';
$orderId = isset($_GET['id']) ? htmlspecialchars($_GET['id']) : '';

if (empty($orderId)) {
    header('Location: my-orders.php');
    exit;
}

require_once '../includes/header.php';
?>

<!-- Loading State -->
<div id="loadingState" class="py-5 text-center">
    <div class="spinner"></div>
    <p class="text-muted mt-3">Sipariş bilgileri yükleniyor...</p>
</div>

<!-- Auth Required -->
<div id="authCheck" class="py-5 text-center" style="display: none;">
    <i class="fas fa-lock fa-4x text-muted mb-3"></i>
    <h4>Giriş Yapmanız Gerekiyor</h4>
    <a href="login.php?redirect=order-detail.php?id=<?php echo $orderId; ?>" class="btn btn-primary">
        <i class="fas fa-sign-in-alt me-2"></i>Giriş Yap
    </a>
</div>

<!-- Error State -->
<div id="errorState" class="py-5 text-center" style="display: none;">
    <i class="fas fa-exclamation-circle fa-4x text-danger mb-3"></i>
    <h4>Sipariş Bulunamadı</h4>
    <p class="text-muted">Aradığınız sipariş bulunamadı.</p>
    <a href="my-orders.php" class="btn btn-primary">
        <i class="fas fa-arrow-left me-2"></i>Siparişlerime Dön
    </a>
</div>

<!-- Order Content -->
<div id="orderContent" style="display: none;">
    <!-- Header -->
    <section class="bg-gradient-primary text-white py-4">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <a href="my-orders.php" class="text-white text-decoration-none mb-2 d-inline-block">
                        <i class="fas fa-arrow-left me-2"></i>Siparişlerime Dön
                    </a>
                    <h1 class="fw-bold mb-0">Sipariş Detayı</h1>
                </div>
                <div id="orderStatus">
                    <!-- Status badge -->
                </div>
            </div>
        </div>
    </section>

    <!-- Main Content -->
    <section class="section">
        <div class="container">
            <div class="row g-4">
                <!-- Left Column -->
                <div class="col-lg-8">
                    <!-- Order Timeline -->
                    <div class="card mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-history text-primary me-2"></i>Sipariş Durumu
                            </h5>
                        </div>
                        <div class="card-body">
                            <div id="orderTimeline" class="order-timeline">
                                <!-- Timeline steps -->
                            </div>
                        </div>
                    </div>

                    <!-- Order Items -->
                    <div class="card mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-list text-primary me-2"></i>Sipariş Kalemleri
                            </h5>
                        </div>
                        <div class="card-body">
                            <div class="table-responsive">
                                <table class="table mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Hizmet</th>
                                            <th>Miktar</th>
                                            <th>Birim Fiyat</th>
                                            <th>Toplam</th>
                                        </tr>
                                    </thead>
                                    <tbody id="orderItemsTable">
                                        <!-- Items -->
                                    </tbody>
                                    <tfoot class="table-light" id="orderTotalRow" style="display: none;">
                                        <tr>
                                            <td colspan="3" class="text-end fw-bold">Genel Toplam:</td>
                                            <td class="fw-bold text-primary" id="orderTotal">-</td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                            <div id="measuredNote" class="alert alert-info mt-3" style="display: none;">
                                <i class="fas fa-info-circle me-2"></i>
                                Fiyat, halılarınız teslim alınıp ölçüldükten sonra belirlenecektir.
                            </div>
                        </div>
                    </div>

                    <!-- Notes -->
                    <div class="card" id="notesCard" style="display: none;">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-sticky-note text-primary me-2"></i>Notlar
                            </h5>
                        </div>
                        <div class="card-body">
                            <p id="orderNotes" class="mb-0">-</p>
                        </div>
                    </div>
                </div>

                <!-- Right Column -->
                <div class="col-lg-4">
                    <!-- Firm Info -->
                    <div class="card mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-store text-primary me-2"></i>Firma Bilgileri
                            </h5>
                        </div>
                        <div class="card-body">
                            <h6 id="firmName" class="fw-bold">-</h6>
                            <p class="text-muted mb-3" id="firmPhone">-</p>
                            <div class="d-grid gap-2">
                                <a href="#" id="callFirmBtn" class="btn btn-outline-success">
                                    <i class="fas fa-phone me-2"></i>Firmayı Ara
                                </a>
                                <a href="#" id="viewFirmBtn" class="btn btn-outline-primary">
                                    <i class="fas fa-eye me-2"></i>Firmayı İncele
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Delivery Address -->
                    <div class="card mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-map-marker-alt text-primary me-2"></i>Teslimat Adresi
                            </h5>
                        </div>
                        <div class="card-body">
                            <p id="deliveryAddress" class="mb-0">-</p>
                        </div>
                    </div>

                    <!-- Payment Method -->
                    <div class="card mb-4">
                        <div class="card-header bg-white">
                            <h5 class="mb-0">
                                <i class="fas fa-credit-card text-primary me-2"></i>Ödeme Yöntemi
                            </h5>
                        </div>
                        <div class="card-body">
                            <span id="paymentMethod" class="badge bg-light text-dark px-3 py-2">-</span>
                        </div>
                    </div>

                    <!-- Review Button (for delivered orders) -->
                    <div class="card" id="reviewCard" style="display: none;">
                        <div class="card-header bg-success text-white">
                            <h5 class="mb-0">
                                <i class="fas fa-star me-2"></i>Değerlendirme Yap
                            </h5>
                        </div>
                        <div class="card-body">
                            <p class="text-muted small">Siparişiniz teslim edildi. Firmayı değerlendirmek ister misiniz?
                            </p>
                            <button class="btn btn-success w-100" data-bs-toggle="modal" data-bs-target="#reviewModal">
                                <i class="fas fa-star me-2"></i>Değerlendir
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>

<!-- Review Modal -->
<div class="modal fade" id="reviewModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Firmayı Değerlendir</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="reviewForm">
                <div class="modal-body">
                    <div class="mb-4 text-center">
                        <label class="form-label fw-bold">Puanınız</label>
                        <div id="ratingStars" class="rating-input">
                            <i class="far fa-star fa-2x" data-rating="1"></i>
                            <i class="far fa-star fa-2x" data-rating="2"></i>
                            <i class="far fa-star fa-2x" data-rating="3"></i>
                            <i class="far fa-star fa-2x" data-rating="4"></i>
                            <i class="far fa-star fa-2x" data-rating="5"></i>
                        </div>
                        <input type="hidden" id="ratingValue" value="5">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Yorumunuz (Opsiyonel)</label>
                        <textarea id="reviewComment" class="form-control" rows="3"
                            placeholder="Deneyiminizi paylaşın..."></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                    <button type="submit" class="btn btn-success">
                        <i class="fas fa-check me-2"></i>Gönder
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<style>
    .order-timeline {
        position: relative;
        padding-left: 30px;
    }

    .order-timeline::before {
        content: '';
        position: absolute;
        left: 10px;
        top: 0;
        bottom: 0;
        width: 2px;
        background: #e9ecef;
    }

    .timeline-step {
        position: relative;
        padding-bottom: 20px;
    }

    .timeline-step:last-child {
        padding-bottom: 0;
    }

    .timeline-step .step-icon {
        position: absolute;
        left: -30px;
        width: 22px;
        height: 22px;
        border-radius: 50%;
        background: #e9ecef;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 10px;
        color: #6c757d;
    }

    .timeline-step.completed .step-icon {
        background: var(--primary-color);
        color: white;
    }

    .timeline-step.active .step-icon {
        background: var(--secondary-color);
        color: #333;
        box-shadow: 0 0 0 4px rgba(255, 215, 0, 0.3);
    }

    .rating-input i {
        cursor: pointer;
        color: #ffc107;
        margin: 0 5px;
        transition: transform 0.2s;
    }

    .rating-input i:hover {
        transform: scale(1.2);
    }
</style>

<script type="module">
    const orderId = '<?php echo $orderId; ?>';
    let currentOrder = null;

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

    window.addEventListener('firebaseReady', async function () {
        const auth = window.firebaseAuth;
        const db = window.firebaseDb;

        const { doc, getDoc, updateDoc, addDoc, collection } = await import('https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js');

        auth.onAuthStateChanged(async (user) => {
            if (user) {
                await loadOrder(db, doc, getDoc, user.uid);
                setupReviewForm(db, addDoc, updateDoc, collection, user);
            } else {
                document.getElementById('loadingState').style.display = 'none';
                document.getElementById('authCheck').style.display = 'block';
            }
        });
    });

    async function loadOrder(db, doc, getDoc, uid) {
        try {
            const orderDoc = await getDoc(doc(db, 'orders', orderId));

            if (!orderDoc.exists()) {
                showError();
                return;
            }

            const order = orderDoc.data();

            // Fetch user data to check if admin
            const userDocRef = doc(db, 'users', uid);
            const userDocSnap = await getDoc(userDocRef);
            const userData = userDocSnap.exists() ? userDocSnap.data() : {};

            // Check ownership (bypass for admins and firms)
            const isOwner = order.customerId === uid;
            const isFirmOwner = order.firmId === (await getFirmId(db, uid)); // Helper to check if firm user owns this order
            const isAdmin = userData.userType === 'admin';
            const isFirmUser = userData.userType === 'firm';

            if (!isOwner && !isAdmin && !isFirmOwner) {
                // Double check if it is the firm that owns the order
                if (isFirmUser) {
                    const firmDoc = await getDoc(doc(db, 'firms', order.firmId));
                    if (firmDoc.exists() && firmDoc.data().uid === uid) {
                        // Allowed
                    } else {
                        console.warn('Unauthorized access to order detail');
                        showError();
                        return;
                    }
                } else {
                    console.warn('Unauthorized access to order detail');
                    showError();
                    return;
                }
            }

            currentOrder = { id: orderId, ...order };
            renderOrder(order);

        } catch (error) {
            console.error('Sipariş yüklenirken hata:', error);
            showError();
        }
    }

    async function getFirmId(db, uid) {
        // optimistically check if we already know the firm id, or fetch it
        // This is complex to do synchronously here without large changes. 
        // For now, reliance on the isFirmUser check below with specific logic is better.
        return null;
    }


    function renderOrder(order) {
        // Status
        const statusConfig = {
            pending: { text: 'Bekliyor', class: 'warning', icon: 'clock' },
            confirmed: { text: 'Onaylandı', class: 'info', icon: 'check' },
            picked_up: { text: 'Teslim Alındı', class: 'primary', icon: 'truck' },
            measured: { text: 'Ölçüm Yapıldı', class: 'info', icon: 'ruler' },
            out_for_delivery: { text: 'Yolda', class: 'info', icon: 'shipping-fast' },
            delivered: { text: 'Teslim Edildi', class: 'success', icon: 'check-circle' },
            cancelled: { text: 'İptal Edildi', class: 'danger', icon: 'times-circle' }
        };

        const status = statusConfig[order.status] || { text: order.status, class: 'secondary', icon: 'question' };
        document.getElementById('orderStatus').innerHTML = `
        <span class="badge bg-${status.class} fs-5 px-3 py-2">
            <i class="fas fa-${status.icon} me-2"></i>${status.text}
        </span>
    `;

        // Timeline
        const steps = [
            { key: 'pending', label: 'Sipariş Oluşturuldu', date: order.createdAt },
            { key: 'confirmed', label: 'Firma Onayladı', date: order.confirmedAt },
            { key: 'picked_up', label: 'Halılar Teslim Alındı', date: order.pickedUpAt },
            { key: 'measured', label: 'Ölçüm Yapıldı', date: order.measuredAt },
            { key: 'delivered', label: 'Teslim Edildi', date: order.deliveredAt }
        ];

        const statusOrder = ['pending', 'confirmed', 'picked_up', 'measured', 'out_for_delivery', 'delivered'];
        const currentIndex = statusOrder.indexOf(order.status);

        let timelineHtml = '';
        steps.forEach((step, i) => {
            const stepIndex = statusOrder.indexOf(step.key);
            const isCompleted = stepIndex < currentIndex || (stepIndex === currentIndex && step.date);
            const isActive = step.key === order.status;

            const date = step.date?.toDate ? step.date.toDate() : (step.date ? new Date(step.date) : null);

            timelineHtml += `
            <div class="timeline-step ${isCompleted ? 'completed' : ''} ${isActive ? 'active' : ''}">
                <div class="step-icon">
                    <i class="fas fa-${isCompleted || isActive ? 'check' : 'circle'}"></i>
                </div>
                <div class="step-content">
                    <strong>${step.label}</strong>
                    ${date ? `<br><small class="text-muted">${formatDate(date)}</small>` : ''}
                </div>
            </div>
        `;
        });
        document.getElementById('orderTimeline').innerHTML = timelineHtml;

        // Items
        const items = order.measuredItems || order.items || [];
        let itemsHtml = '';
        items.forEach(item => {
            const total = item.quantity && item.unitPrice ? item.quantity * item.unitPrice : null;
            itemsHtml += `
            <tr>
                <td>${item.serviceName}</td>
                <td>${item.quantity || '-'} ${getUnitLabel(item.unit)}</td>
                <td>${item.unitPrice ? formatPrice(item.unitPrice) : '-'}</td>
                <td>${total ? formatPrice(total) : '-'}</td>
            </tr>
        `;
        });
        document.getElementById('orderItemsTable').innerHTML = itemsHtml;

        if (order.totalPrice) {
            document.getElementById('orderTotal').textContent = formatPrice(order.totalPrice);
            document.getElementById('orderTotalRow').style.display = 'table-footer-group';
        } else {
            document.getElementById('measuredNote').style.display = 'block';
        }

        // Firm info
        document.getElementById('firmName').textContent = order.firmName;
        document.getElementById('firmPhone').innerHTML = `<i class="fas fa-phone me-2"></i>${order.firmPhone}`;
        document.getElementById('callFirmBtn').href = `tel:${order.firmPhone}`;
        document.getElementById('viewFirmBtn').href = `../firma/${slugify(order.firmName)}-${order.firmId}`;

        // Address
        const addr = order.customerAddress || {};
        document.getElementById('deliveryAddress').textContent = `${addr.fullAddress || ''}, ${addr.district || ''}, ${addr.city || ''}`;

        // Payment
        const paymentLabels = { cash: 'Nakit', card: 'Kapıda Kredi Kartı', transfer: 'Havale/EFT' };
        document.getElementById('paymentMethod').textContent = paymentLabels[order.paymentMethod] || order.paymentMethod;

        // Notes
        if (order.notes) {
            document.getElementById('orderNotes').textContent = order.notes;
            document.getElementById('notesCard').style.display = 'block';
        }

        // Review card (only for delivered, not rated)
        if (order.status === 'delivered' && !order.isRated) {
            document.getElementById('reviewCard').style.display = 'block';
        }

        // Show content
        document.getElementById('loadingState').style.display = 'none';
        document.getElementById('orderContent').style.display = 'block';
    }

    function setupReviewForm(db, addDoc, updateDoc, collection, user) {
        // Star rating
        const stars = document.querySelectorAll('#ratingStars i');
        stars.forEach(star => {
            star.addEventListener('click', () => {
                const rating = parseInt(star.dataset.rating);
                document.getElementById('ratingValue').value = rating;
                stars.forEach((s, i) => {
                    s.className = i < rating ? 'fas fa-star fa-2x' : 'far fa-star fa-2x';
                });
            });

            star.addEventListener('mouseenter', () => {
                const rating = parseInt(star.dataset.rating);
                stars.forEach((s, i) => {
                    s.className = i < rating ? 'fas fa-star fa-2x' : 'far fa-star fa-2x';
                });
            });
        });

        // Set default 5 stars
        stars.forEach(s => s.className = 'fas fa-star fa-2x');

        // Submit review
        document.getElementById('reviewForm').addEventListener('submit', async (e) => {
            e.preventDefault();

            const rating = parseInt(document.getElementById('ratingValue').value);
            const comment = document.getElementById('reviewComment').value.trim();

            // Profanity check
            if (comment) {
                const hasProfanity = await checkProfanity(db, comment);
                if (hasProfanity) {
                    alert('Yorumunuz uygunsuz kelime içeriyor. Lütfen düzenleyiniz.');
                    return;
                }
            }

            try {
                // Add review
                const reviewsRef = collection(db, 'reviews');
                await addDoc(reviewsRef, {
                    orderId: orderId,
                    customerId: user.uid,
                    customerName: currentOrder.customerName,
                    firmId: currentOrder.firmId,
                    firmName: currentOrder.firmName,
                    rating: rating,
                    comment: comment || null,
                    createdAt: new Date(),
                    isVisible: true
                });

                // Update order
                const { doc: docRef, updateDoc: updateDocFn } = await import('https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js');
                await updateDocFn(docRef(db, 'orders', orderId), { isRated: true });

                // Close modal and hide review card
                bootstrap.Modal.getInstance(document.getElementById('reviewModal')).hide();
                document.getElementById('reviewCard').style.display = 'none';

                alert('Değerlendirmeniz başarıyla gönderildi. Teşekkürler!');

            } catch (error) {
                console.error('Değerlendirme hatası:', error);
                alert('Değerlendirme gönderilemedi: ' + error.message);
            }
        });
    }

    // Profanity check function with word boundary support
    async function checkProfanity(db, text) {
        try {
            const { doc, getDoc } = await import('https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js');
            const settingsDoc = await getDoc(doc(db, 'systemSettings', 'general'));

            if (!settingsDoc.exists()) return false;

            const blockedWords = settingsDoc.data().blockedWords || [];
            if (blockedWords.length === 0) return false;

            const normalizedText = text.toLowerCase();

            for (const word of blockedWords) {
                if (!word) continue;
                const normalizedWord = word.toLowerCase();

                // Word boundary regex - Türkçe karakterleri destekler
                // "yarak" kelimesi "anlayarak" içinde geçerse ENGELLENMEZ
                // "yarak" kelimesi " yarak " gibi bağımsız geçerse ENGELLENİR
                const turkishChars = 'a-zA-ZğüşöçıİĞÜŞÖÇ';
                const pattern = new RegExp(
                    `(?<![${turkishChars}])${escapeRegex(normalizedWord)}(?![${turkishChars}])`,
                    'i'
                );

                if (pattern.test(normalizedText)) {
                    return true;
                }
            }

            return false;
        } catch (e) {
            console.error('Profanity check error:', e);
            return false;
        }
    }

    function escapeRegex(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }

    function showError() {
        document.getElementById('loadingState').style.display = 'none';
        document.getElementById('errorState').style.display = 'block';
    }

    function formatDate(date) {
        return new Intl.DateTimeFormat('tr-TR', {
            day: '2-digit', month: '2-digit', year: 'numeric',
            hour: '2-digit', minute: '2-digit'
        }).format(date);
    }

    function formatPrice(price) {
        return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(price);
    }

    function getUnitLabel(unit) {
        const labels = { m2: 'm²', adet: 'Adet', takim: 'Takım' };
        return labels[unit] || unit || '';
    }
</script>

<?php require_once '../includes/footer.php'; ?>