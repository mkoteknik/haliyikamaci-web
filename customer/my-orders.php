<?php
/**
 * Halı Yıkamacı - Siparişlerim
 */

require_once '../config/app.php';
$pageTitle = 'Siparişlerim';
require_once '../includes/header.php';
?>

<!-- Check Auth -->
<div id="authCheck" class="py-5 text-center" style="display: none;">
    <i class="fas fa-lock fa-4x text-muted mb-3"></i>
    <h4>Giriş Yapmanız Gerekiyor</h4>
    <p class="text-muted">Siparişlerinizi görmek için lütfen giriş yapın.</p>
    <a href="login.php?redirect=my-orders.php" class="btn btn-primary btn-lg">
        <i class="fas fa-sign-in-alt me-2"></i>Giriş Yap
    </a>
</div>

<!-- Main Content -->
<div id="mainContent" style="display: none;">
    <!-- Page Header -->
    <section class="bg-gradient-primary text-white py-4">
        <div class="container">
            <h1 class="fw-bold mb-0">
                <i class="fas fa-box me-2"></i>Siparişlerim
            </h1>
        </div>
    </section>

    <!-- Filters -->
    <section class="py-3 bg-light border-bottom">
        <div class="container">
            <div class="d-flex flex-wrap gap-2">
                <button class="btn btn-primary status-filter active" data-status="all">
                    Tümü <span class="badge bg-white text-primary ms-1" id="countAll">0</span>
                </button>
                <button class="btn btn-outline-warning status-filter" data-status="pending">
                    Bekliyor <span class="badge bg-warning text-dark ms-1" id="countPending">0</span>
                </button>
                <button class="btn btn-outline-info status-filter" data-status="confirmed">
                    Onaylandı <span class="badge bg-info ms-1" id="countConfirmed">0</span>
                </button>
                <button class="btn btn-outline-primary status-filter" data-status="picked_up">
                    Teslim Alındı <span class="badge bg-primary ms-1" id="countPickedUp">0</span>
                </button>
                <button class="btn btn-outline-success status-filter" data-status="delivered">
                    Teslim Edildi <span class="badge bg-success ms-1" id="countDelivered">0</span>
                </button>
                <button class="btn btn-outline-danger status-filter" data-status="cancelled">
                    İptal <span class="badge bg-danger ms-1" id="countCancelled">0</span>
                </button>
            </div>
        </div>
    </section>

    <!-- Orders List -->
    <section class="section">
        <div class="container">
            <div id="ordersList">
                <div class="text-center py-5">
                    <div class="spinner"></div>
                    <p class="text-muted mt-3">Siparişler yükleniyor...</p>
                </div>
            </div>
        </div>
    </section>
</div>

<!-- Chat Modal -->
<div class="modal fade" id="chatModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="chatModalTitle">Firma ile Sohbet</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body p-0">
                <div id="chatMessages" class="p-3" style="height: 400px; overflow-y: auto; background: #f8f9fa;">
                    <!-- Messages -->
                </div>
                <div class="border-top p-3">
                    <form id="chatForm" class="d-flex gap-2">
                        <input type="text" id="chatInput" class="form-control" placeholder="Mesajınız..."
                            autocomplete="off">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-paper-plane"></i>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>



<script type="module">
    let allOrders = [];
    let currentFilter = 'all';
    let currentChatOrder = null;
    let chatUnsubscribe = null;
    let currentUser = null;

    window.addEventListener('firebaseReady', function () {
        const auth = window.firebaseAuth;
        const db = window.firebaseDb;
        const { collection, getDocs, onSnapshot, query, where, orderBy, doc, getDoc, addDoc } = window.firebaseModules;

        auth.onAuthStateChanged(async (user) => {
            if (user) {
                currentUser = user;
                // STRICT RBAC: Check if user is customer
                try {
                    const userDocRef = doc(db, 'users', user.uid);
                    const userDocSnap = await getDoc(userDocRef);

                    if (userDocSnap.exists()) {
                        const userData = userDocSnap.data();
                        if (userData.userType !== 'customer' && userData.userType !== 'admin') {
                            console.warn('Redirecting Firm user to Firm Panel');
                            window.location.href = '../firm/index.php';
                            return;
                        }
                    } else {
                        console.warn('User document not found.');
                    }
                } catch (e) {
                    console.error('RBAC Error:', e);
                }

                document.getElementById('authCheck').style.display = 'none';
                document.getElementById('mainContent').style.display = 'block';
                await loadOrders(db, { collection, getDocs, query, where }, user.uid);
                setupFilters();
                setupChat(db, { collection, addDoc, query, orderBy, onSnapshot });
            } else {
                document.getElementById('authCheck').style.display = 'block';
                document.getElementById('mainContent').style.display = 'none';
            }
        });
    });

    async function loadOrders(db, { collection, getDocs, query, where }, uid) {
        const container = document.getElementById('ordersList');

        try {
            const ordersRef = collection(db, 'orders');
            const q = query(ordersRef, where('customerId', '==', uid));
            const snapshot = await getDocs(q);

            allOrders = [];
            snapshot.forEach(doc => {
                allOrders.push({ id: doc.id, ...doc.data() });
            });

            // Sort by date descending
            allOrders.sort((a, b) => {
                const dateA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt);
                const dateB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt);
                return dateB - dateA;
            });

            updateCounts();
            renderOrders();

        } catch (error) {
            console.error('Siparişler yüklenirken hata:', error);
            container.innerHTML = `
            <div class="text-center py-5">
                <i class="fas fa-exclamation-circle fa-4x text-danger mb-3"></i>
                <h4>Bir Hata Oluştu</h4>
                <p class="text-muted">${error.message}</p>
            </div>
        `;
        }
    }

    function updateCounts() {
        const counts = {
            all: allOrders.length,
            pending: allOrders.filter(o => o.status === 'pending').length,
            confirmed: allOrders.filter(o => o.status === 'confirmed').length,
            picked_up: allOrders.filter(o => o.status === 'picked_up').length,
            delivered: allOrders.filter(o => o.status === 'delivered').length,
            cancelled: allOrders.filter(o => o.status === 'cancelled').length
        };

        document.getElementById('countAll').textContent = counts.all;
        document.getElementById('countPending').textContent = counts.pending;
        document.getElementById('countConfirmed').textContent = counts.confirmed;
        document.getElementById('countPickedUp').textContent = counts.picked_up;
        document.getElementById('countDelivered').textContent = counts.delivered;
        document.getElementById('countCancelled').textContent = counts.cancelled;
    }

    function renderOrders() {
        const container = document.getElementById('ordersList');

        let filtered = currentFilter === 'all'
            ? allOrders
            : allOrders.filter(o => o.status === currentFilter);

        if (filtered.length === 0) {
            container.innerHTML = `
            <div class="text-center py-5">
                <i class="fas fa-box-open fa-4x text-muted mb-3"></i>
                <h4>Sipariş Bulunamadı</h4>
                <p class="text-muted">Bu kategoride sipariş bulunmuyor.</p>
                <a href="<?php echo SITE_URL; ?>/firmalar" class="btn btn-primary">
                    <i class="fas fa-store me-2"></i>Firma Bul
                </a>
            </div>
        `;
            return;
        }

        let html = '';
        filtered.forEach(order => {
            html += createOrderCard(order);
        });

        container.innerHTML = `<div class="row g-4">${html}</div>`;

        // Chat Buttons
        document.querySelectorAll('.btn-chat').forEach(btn => {
            btn.addEventListener('click', () => openChat(btn.dataset.id));
        });
    }

    function createOrderCard(order) {
        const createdAt = order.createdAt?.toDate ? order.createdAt.toDate() : new Date(order.createdAt);
        const statusLabels = {
            pending: { text: 'Bekliyor', class: 'warning', icon: 'clock' },
            confirmed: { text: 'Onaylandı', class: 'info', icon: 'check' },
            picked_up: { text: 'Teslim Alındı', class: 'primary', icon: 'truck' },
            measured: { text: 'Ölçüm Yapıldı', class: 'info', icon: 'ruler' },
            out_for_delivery: { text: 'Yolda', class: 'info', icon: 'shipping-fast' },
            delivered: { text: 'Teslim Edildi', class: 'success', icon: 'check-circle' },
            cancelled: { text: 'İptal', class: 'danger', icon: 'times-circle' }
        };

        const status = statusLabels[order.status] || { text: order.status, class: 'secondary', icon: 'question' };
        const items = order.items || [];

        return `
        <div class="col-md-6">
            <div class="card h-100 order-card">
                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                    <div>
                        <span class="badge bg-${status.class}">
                            <i class="fas fa-${status.icon} me-1"></i>${status.text}
                        </span>
                    </div>
                    <small class="text-muted">${formatDate(createdAt)}</small>
                </div>
                <div class="card-body">
                    <h5 class="card-title">
                        <i class="fas fa-store text-primary me-2"></i>${order.firmName || 'Firma'}
                    </h5>
                    <p class="text-muted mb-2">
                        <i class="fas fa-map-marker-alt me-1"></i>
                        ${order.customerAddress?.district || ''}, ${order.customerAddress?.city || ''}
                    </p>
                    
                    <div class="mb-3">
                        <small class="text-muted">Hizmetler:</small>
                        <div class="mt-1">
                            ${items.map(item => `
                                <span class="badge bg-light text-dark me-1">${item.serviceName}</span>
                            `).join('')}
                        </div>
                    </div>
                    
                    ${order.totalPrice ? `
                        <div class="mb-3">
                            <strong class="text-primary">${formatPrice(order.totalPrice)}</strong>
                        </div>
                    ` : ''}
                </div>
                <div class="card-footer bg-white">
                    <div class="d-flex gap-2">
                        <button class="btn btn-outline-secondary btn-chat" data-id="${order.id}">
                            <i class="fas fa-comment-dots"></i>
                        </button>
                        <a href="order-detail.php?id=${order.id}" class="btn btn-outline-primary flex-grow-1">
                            <i class="fas fa-eye me-1"></i>Detay
                        </a>
                        <a href="tel:${order.firmPhone}" class="btn btn-outline-success">
                            <i class="fas fa-phone"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>
    `;
    }

    // --- CHAT LOGIC ---

    function openChat(orderId) {
        currentChatOrder = allOrders.find(o => o.id === orderId);
        if (!currentChatOrder) return;

        const db = window.firebaseDb;
        const { collection, query, orderBy, onSnapshot } = window.firebaseModules;

        document.getElementById('chatModalTitle').textContent = `Sohbet: ${currentChatOrder.firmName || 'Firma'}`;

        // Clean up previous listener
        if (chatUnsubscribe) {
            chatUnsubscribe();
        }

        const messagesContainer = document.getElementById('chatMessages');
        messagesContainer.innerHTML = '<div class="text-center py-5"><div class="spinner"></div></div>';

        const messagesRef = collection(db, 'orders', orderId, 'messages');
        const q = query(messagesRef, orderBy('timestamp', 'asc'));

        chatUnsubscribe = onSnapshot(q, (snapshot) => {
            const messages = [];
            snapshot.forEach(doc => messages.push({ id: doc.id, ...doc.data() }));

            if (messages.length === 0) {
                messagesContainer.innerHTML = `
                    <div class="text-center text-muted py-5">
                        <i class="far fa-comments fa-2x mb-2"></i>
                        <p>Henüz mesaj yok.<br>Firmaya ilk mesajı gönderebilirsiniz.</p>
                    </div>
                `;
            } else {
                messagesContainer.innerHTML = messages.map(msg => {
                    const isCustomer = msg.senderId === currentUser.uid || msg.senderType === 'customer';

                    let timeStr = '';
                    if (msg.timestamp) {
                        const date = msg.timestamp.toDate ? msg.timestamp.toDate() : new Date(msg.timestamp);
                        timeStr = date.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
                    }

                    return `
                        <div class="d-flex ${isCustomer ? 'justify-content-end' : 'justify-content-start'} mb-2">
                            <div class="p-2 rounded ${isCustomer ? 'bg-primary text-white' : 'bg-white border'}" style="max-width: 75%;">
                                <div class="mb-1">${msg.message}</div>
                                <small class="${isCustomer ? 'text-white-50' : 'text-muted'} display-block text-end" style="font-size: 0.7rem;">
                                    ${timeStr}
                                </small>
                            </div>
                        </div>
                    `;
                }).join('');

                messagesContainer.scrollTop = messagesContainer.scrollHeight;
            }
        });

        new bootstrap.Modal(document.getElementById('chatModal')).show();
    }

    function setupChat(db, { collection, addDoc }) {
        document.getElementById('chatForm').addEventListener('submit', async (e) => {
            e.preventDefault();
            if (!currentChatOrder) return;

            const input = document.getElementById('chatInput');
            const text = input.value.trim();

            if (!text) return;

            try {
                // Send Message
                await addDoc(collection(db, 'orders', currentChatOrder.id, 'messages'), {
                    message: text,
                    senderId: currentUser.uid,
                    senderName: currentUser.displayName || 'Müşteri',
                    senderType: 'customer',
                    timestamp: new Date()
                });

                input.value = '';
            } catch (err) {
                console.error('Mesaj gonderilemedi:', err);
                alert('Mesaj gönderilemedi.');
            }
        });

        document.getElementById('chatModal').addEventListener('hidden.bs.modal', () => {
            if (chatUnsubscribe) {
                chatUnsubscribe();
                chatUnsubscribe = null;
            }
        });
    }

    function setupFilters() {
        document.querySelectorAll('.status-filter').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.status-filter').forEach(b => {
                    b.classList.remove('active', 'btn-primary');
                    b.classList.add('btn-outline-' + (b.dataset.status === 'all' ? 'primary' : getStatusClass(b.dataset.status)));
                });

                btn.classList.add('active', 'btn-primary');
                btn.classList.remove('btn-outline-primary', 'btn-outline-warning', 'btn-outline-info', 'btn-outline-success', 'btn-outline-danger');

                currentFilter = btn.dataset.status;
                renderOrders();
            });
        });
    }

    function getStatusClass(status) {
        const classes = { pending: 'warning', confirmed: 'info', picked_up: 'primary', delivered: 'success', cancelled: 'danger' };
        return classes[status] || 'secondary';
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
</script>

<?php require_once '../includes/footer.php'; ?>