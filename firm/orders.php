<?php
/**
 * Halı Yıkamacı - Firma Siparişler
 */

require_once '../config/app.php';
$pageTitle = 'Siparişler';
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
            <!-- Mobile Header -->
            <div class="d-lg-none bg-dark text-white p-3 d-flex justify-content-between align-items-center">
                <button class="btn btn-outline-light btn-sm" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>
                <span class="fw-bold">Siparişler</span>
                <div></div>
            </div>

            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <h4 class="mb-0"><i class="fas fa-box me-2"></i>Siparişler</h4>
                </div>
            </div>

            <!-- Filters -->
            <div class="bg-white border-bottom py-3 px-4">
                <div class="d-flex flex-wrap gap-2">
                    <button class="btn btn-primary status-filter active" data-status="all">
                        Tümü <span class="badge bg-white text-primary ms-1" id="countAll">0</span>
                    </button>
                    <button class="btn btn-outline-warning status-filter" data-status="pending">
                        <i class="fas fa-clock me-1"></i>Bekliyor <span class="badge bg-warning text-dark ms-1"
                            id="countPending">0</span>
                    </button>
                    <button class="btn btn-outline-info status-filter" data-status="confirmed">
                        Onaylandı <span class="badge bg-info ms-1" id="countConfirmed">0</span>
                    </button>
                    <button class="btn btn-outline-primary status-filter" data-status="picked_up">
                        Alındı <span class="badge bg-primary ms-1" id="countPickedUp">0</span>
                    </button>
                    <button class="btn btn-outline-success status-filter" data-status="delivered">
                        Teslim <span class="badge bg-success ms-1" id="countDelivered">0</span>
                    </button>
                </div>
            </div>

            <div class="page-body">
                <div id="ordersList">
                    <div class="text-center py-5">
                        <div class="spinner"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Status Update Modal -->
    <div class="modal fade" id="statusModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Sipariş Durumu Güncelle</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="statusModalContent">
                        <!-- Dynamic content -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Chat Modal -->
    <div class="modal fade" id="chatModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="chatModalTitle">Müşteri ile Sohbet</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-0">
                    <div id="chatMessages" class="p-3" style="height: 400px; overflow-y: auto; background: #f8f9fa;">
                        <!-- Messages -->
                    </div>
                    <div class="border-top p-3">
                        <form id="chatForm" class="d-flex gap-2">
                            <input type="text" id="chatInput" class="form-control" placeholder="Mesajınız..." autocomplete="off">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, onSnapshot, query, where, doc, updateDoc, deleteDoc, addDoc, orderBy } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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

        let allOrders = [];
        let currentFirm = null;
        let currentFilter = 'all';
        let currentChatOrder = null;
        let chatUnsubscribe = null;

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

            await loadOrders();
            setupFilters();
            setupChat();
        });

        async function getFirmData(uid) {
            const firmsRef = collection(db, 'firms');
            const q = query(firmsRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);
            if (snapshot.empty) return null;
            return { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
        }

        async function loadOrders() {
            const container = document.getElementById('ordersList');

            try {
                const ordersRef = collection(db, 'orders');
                const q = query(ordersRef, where('firmId', '==', currentFirm.id));
                const snapshot = await getDocs(q);

                allOrders = [];
                snapshot.forEach(doc => {
                    allOrders.push({ id: doc.id, ...doc.data() });
                });

                // Sort by date
                allOrders.sort((a, b) => {
                    const dateA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt);
                    const dateB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt);
                    return dateB - dateA;
                });

                updateCounts();
                renderOrders();

            } catch (error) {
                console.error('Siparişler yüklenirken hata:', error);
                container.innerHTML = `<div class="alert alert-danger">Hata: ${error.message}</div>`;
            }
        }

        function updateCounts() {
            const counts = {
                all: allOrders.length,
                pending: allOrders.filter(o => o.status === 'pending').length,
                confirmed: allOrders.filter(o => o.status === 'confirmed').length,
                picked_up: allOrders.filter(o => o.status === 'picked_up' || o.status === 'measured').length,
                delivered: allOrders.filter(o => o.status === 'delivered').length
            };

            document.getElementById('countAll').textContent = counts.all;
            document.getElementById('countPending').textContent = counts.pending;
            document.getElementById('countConfirmed').textContent = counts.confirmed;
            document.getElementById('countPickedUp').textContent = counts.picked_up;
            document.getElementById('countDelivered').textContent = counts.delivered;
        }

        function renderOrders() {
            const container = document.getElementById('ordersList');

            let filtered = currentFilter === 'all' ? allOrders : allOrders.filter(o => {
                if (currentFilter === 'picked_up') return o.status === 'picked_up' || o.status === 'measured';
                return o.status === currentFilter;
            });

            if (filtered.length === 0) {
                container.innerHTML = `
            <div class="text-center py-5">
                <i class="fas fa-inbox fa-4x text-muted mb-3"></i>
                <h5>Sipariş Bulunamadı</h5>
                <p class="text-muted">Bu kategoride sipariş bulunmuyor.</p>
            </div>
        `;
                return;
            }

            container.innerHTML = `<div class="row g-4">${filtered.map(order => createOrderCard(order)).join('')}</div>`;

            // Setup action buttons
            document.querySelectorAll('.btn-status').forEach(btn => {
                btn.addEventListener('click', () => showStatusModal(btn.dataset.id));
            });
            // Chat Buttons
            document.querySelectorAll('.btn-chat').forEach(btn => {
                btn.addEventListener('click', () => openChat(btn.dataset.id));
            });

            document.querySelectorAll('.btn-call').forEach(btn => {
                btn.addEventListener('click', () => window.open('tel:' + btn.dataset.phone));
            });

            document.querySelectorAll('.btn-map').forEach(btn => {
                btn.addEventListener('click', () => {
                    const addr = btn.dataset.address;
                    window.open(`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(addr)}`);
                });
            });
        }

        function createOrderCard(order) {
            const date = order.createdAt?.toDate ? order.createdAt.toDate() : new Date(order.createdAt);
            const status = getStatusConfig(order.status);
            const items = order.items || [];
            const addr = order.customerAddress || {};
            const fullAddress = `${addr.fullAddress || ''}, ${addr.district || ''}, ${addr.city || ''}`;

            return `
        <div class="col-md-6">
            <div class="card h-100 border-0 shadow-sm">
                <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                    <span class="badge bg-${status.class} px-3 py-2">
                        <i class="fas fa-${status.icon} me-1"></i>${status.text}
                    </span>
                    <small class="text-muted">${formatDate(date)}</small>
                </div>
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-start mb-3">
                        <div>
                            <h5 class="mb-1">${order.customerName}</h5>
                            <p class="text-muted mb-0">
                                <i class="fas fa-phone me-1"></i>${order.customerPhone}
                            </p>
                        </div>
                        ${order.totalPrice ? `<h5 class="text-primary mb-0">${formatPrice(order.totalPrice)}</h5>` : ''}
                    </div>
                    
                    <p class="text-muted small mb-2">
                        <i class="fas fa-map-marker-alt me-1"></i>${fullAddress}
                    </p>
                    
                    <div class="mb-3">
                        <small class="text-muted">Hizmetler:</small>
                        <div class="mt-1">
                            ${items.map(i => `<span class="badge bg-light text-dark me-1">${i.serviceName}</span>`).join('')}
                        </div>
                    </div>
                    
                    ${order.notes ? `<div class="alert alert-light small py-2 mb-3"><i class="fas fa-sticky-note me-1"></i>${order.notes}</div>` : ''}
                </div>
                <div class="card-footer bg-white border-0 pt-0">
                    <div class="d-flex gap-2 flex-wrap">
                        <button class="btn btn-primary btn-sm flex-grow-1 btn-status" data-id="${order.id}">
                            <i class="fas fa-edit me-1"></i>Durum
                        </button>
                        <button class="btn btn-outline-secondary btn-sm btn-chat" data-id="${order.id}">
                            <i class="fas fa-comment-dots"></i>
                        </button>
                        <button class="btn btn-outline-success btn-sm btn-call" data-phone="${order.customerPhone}">
                            <i class="fas fa-phone"></i>
                        </button>
                        <button class="btn btn-outline-info btn-sm btn-map" data-address="${fullAddress}">
                            <i class="fas fa-map-marked-alt"></i>
                        </button>
                        <a href="order-detail.php?id=${order.id}" class="btn btn-outline-primary btn-sm">
                            <i class="fas fa-eye"></i>
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

            document.getElementById('chatModalTitle').textContent = `Sohbet: ${currentChatOrder.customerName}`;
            
            // Clean up previous listener
            if (chatUnsubscribe) {
                chatUnsubscribe();
            }

            const messagesContainer = document.getElementById('chatMessages');
            messagesContainer.innerHTML = '<div class="text-center py-5"><div class="spinner"></div></div>';

            // Unread flag clear logic could go here if we tracked it on the order doc

            const messagesRef = collection(db, 'orders', orderId, 'messages');
            const q = query(messagesRef, orderBy('timestamp', 'asc'));

            chatUnsubscribe = onSnapshot(q, (snapshot) => {
                const messages = [];
                snapshot.forEach(doc => messages.push({ id: doc.id, ...doc.data() }));

                if (messages.length === 0) {
                    messagesContainer.innerHTML = `
                        <div class="text-center text-muted py-5">
                            <i class="far fa-comments fa-2x mb-2"></i>
                            <p>Henüz mesaj yok.<br>Müşteriye ilk mesajı gönderebilirsiniz.</p>
                        </div>
                    `;
                } else {
                    messagesContainer.innerHTML = messages.map(msg => {
                        const isFirm = msg.senderId === currentFirm.id || msg.senderType === 'firm';
                        // Timestamp handling: Firestore timestamp or ISO string or Date
                        let timeStr = '';
                        if (msg.timestamp) {
                            const date = msg.timestamp.toDate ? msg.timestamp.toDate() : new Date(msg.timestamp);
                            timeStr = date.toLocaleTimeString('tr-TR', {hour: '2-digit', minute:'2-digit'});
                        }

                        return `
                            <div class="d-flex ${isFirm ? 'justify-content-end' : 'justify-content-start'} mb-2">
                                <div class="p-2 rounded ${isFirm ? 'bg-primary text-white' : 'bg-white border'}" style="max-width: 75%;">
                                    <div class="mb-1">${msg.message}</div>
                                    <small class="${isFirm ? 'text-white-50' : 'text-muted'} display-block text-end" style="font-size: 0.7rem;">
                                        ${timeStr}
                                    </small>
                                </div>
                            </div>
                        `;
                    }).join('');
                    
                    // Auto scroll to bottom
                    messagesContainer.scrollTop = messagesContainer.scrollHeight;
                }
            });

            new bootstrap.Modal(document.getElementById('chatModal')).show();
        }

        function setupChat() {
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
                        senderId: currentFirm.id,
                        senderName: currentFirm.name,
                        senderType: 'firm',
                        timestamp: new Date() // ServerTimestamp is better but Date is fine for now
                    });
                    
                    input.value = '';
                } catch (err) {
                    console.error('Mesaj gonderilemedi:', err);
                    alert('Mesaj gönderilemedi.');
                }
            });
            
            // Cleanup on modal close if desired, but bootstrap handles focus well. 
            // We might want to unsubscribe when modal is hidden completely.
            document.getElementById('chatModal').addEventListener('hidden.bs.modal', () => {
                if (chatUnsubscribe) {
                    chatUnsubscribe();
                    chatUnsubscribe = null;
                }
            });
        }

        function showStatusModal(orderId) {
            const order = allOrders.find(o => o.id === orderId);
            if (!order) return;

            // Full status list with labels
            const statuses = [
                { key: 'pending', label: 'Bekliyor' },
                { key: 'confirmed', label: 'Onaylandı' },
                { key: 'picked_up', label: 'Teslim Alındı' },
                { key: 'measured', label: 'Ölçüm Yapıldı' },
                { key: 'washing', label: 'Yıkanıyor' }, // Added washing
                { key: 'drying', label: 'Kurutuluyor' }, // Added drying
                { key: 'out_for_delivery', label: 'Dağıtıma Çıktı' },
                { key: 'delivered', label: 'Teslim Edildi' },
                { key: 'cancelled', label: 'İptal' }
            ];

            // Render Modal Wrapper
            let html = `
                <div class="mb-4">
                    <h6>Mevcut Durum</h6>
                    <span class="badge bg-${getStatusConfig(order.status).class} fs-6 px-3 py-2">
                        ${getStatusConfig(order.status).text}
                    </span>
                </div>

                <h6>Durum Güncelle</h6>
                <div class="mb-3">
                    <label class="form-label text-muted small">Yeni Durum Seçin</label>
                    <select class="form-select mb-3" id="statusSelect">
                        <option value="" selected disabled>Durum Seçiniz...</option>
                        ${statuses.map(s => `
                            <option value="${s.key}" ${s.key === order.status ? 'disabled' : ''}>
                                ${s.label}
                            </option>
                        `).join('')}
                    </select>
                </div>

                <!-- Dynamic Content Area -->
                <div id="dynamicFormContent"></div>
            `;

            document.getElementById('statusModalContent').innerHTML = html;

            const statusSelect = document.getElementById('statusSelect');
            const contentDiv = document.getElementById('dynamicFormContent');

            // Event Listener for Dynamic Change
            statusSelect.addEventListener('change', (e) => {
                const selected = e.target.value;
                contentDiv.innerHTML = ''; // Clear previous

                if (selected === 'measured') {
                    // Show Measurement Form
                    renderMeasurementForm(contentDiv, order);
                } else if (selected === 'cancelled') {
                    // Show Cancel Warning
                    contentDiv.innerHTML = `
                         <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle me-2"></i>
                            Siparişi iptal etmek üzeresiniz. Bu işlem geri alınamaz.
                        </div>
                        <button class="btn btn-danger w-100" id="btnConfirmCancel">
                            <i class="fas fa-times me-2"></i>Siparişi İptal Et
                        </button>
                    `;
                    document.getElementById('btnConfirmCancel').addEventListener('click', async () => {
                        if (confirm('Emin misiniz?')) await updateOrderStatus(orderId, 'cancelled');
                    });
                } else {
                    // Standard Update Button
                    contentDiv.innerHTML = `
                        <button class="btn btn-primary w-100" id="btnStandardUpdate">
                            Durumu Güncelle
                        </button>
                    `;
                    document.getElementById('btnStandardUpdate').addEventListener('click', async () => {
                        await updateOrderStatus(orderId, selected);
                    });
                }
            });

            if (typeof bootstrap !== 'undefined') {
                new bootstrap.Modal(document.getElementById('statusModal')).show();
            } else {
                alert('Bootstrap yüklenemedi.');
            }
        }

        function renderMeasurementForm(container, order) {
            container.innerHTML = `
                <div class="card bg-light border-0 mb-3">
                    <div class="card-body">
                        <h6 class="card-title fw-bold text-primary">
                            <i class="fas fa-ruler-combined me-2"></i>Ölçüm Girişi
                        </h6>
                        <p class="text-muted small">Lütfen ürünlerin net ölçülerini ve birim fiyatlarını girin.</p>
                        
                        <form id="measurementForm">
                            <div id="measurementItems">
                                ${(order.items || []).map((item, i) => `
                                    <div class="card mb-3 shadow-sm border-0">
                                        <div class="card-body p-3">
                                            <div class="d-flex justify-content-between mb-2">
                                                 <span class="fw-bold">${item.serviceName}</span>
                                                 <span class="badge bg-secondary">${getUnitLabel(item.unit)}</span>
                                            </div>
                                            <div class="row g-2">
                                                <div class="col-6">
                                                    <label class="form-label small text-muted">Miktar</label>
                                                    <div class="input-group input-group-sm">
                                                        <input type="number" class="form-control measure-qty" 
                                                            data-index="${i}" step="0.01" min="0" value="${item.quantity || 0}" required>
                                                    </div>
                                                </div>
                                                <div class="col-6">
                                                    <label class="form-label small text-muted">Birim Fiyat (₺)</label>
                                                    <div class="input-group input-group-sm">
                                                        <input type="number" class="form-control measure-price" 
                                                            data-index="${i}" step="0.01" min="0" value="${item.unitPrice || 0}" required>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                `).join('')}
                            </div>
                            
                            <div class="bg-white p-3 rounded shadow-sm mb-3 border">
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="text-muted">Toplam Tutar:</span>
                                    <strong class="text-success fs-5" id="measurementTotal">₺0.00</strong>
                                </div>
                            </div>

                            <button type="submit" class="btn btn-success w-100 py-2">
                                <i class="fas fa-save me-2"></i>Ölçümü Kaydet ve Güncelle
                            </button>
                        </form>
                    </div>
                </div>
            `;

            // Add Logic
            const form = container.querySelector('#measurementForm');

            // Calculate Logic
            const calculateTotal = () => {
                let total = 0;
                container.querySelectorAll('.measure-qty').forEach((qtyInput, i) => {
                    const priceInput = container.querySelectorAll('.measure-price')[i];
                    const qty = parseFloat(qtyInput.value) || 0;
                    const price = parseFloat(priceInput.value) || 0;
                    total += qty * price;
                });
                container.querySelector('#measurementTotal').textContent = formatPrice(total);
            };

            container.querySelectorAll('.measure-qty, .measure-price').forEach(input => {
                input.addEventListener('input', calculateTotal);
            });
            calculateTotal(); // Initial calc

            // Submit Logic
            form.addEventListener('submit', async (e) => {
                e.preventDefault();
                await saveMeasurement(order.id, order);
            });
        }

        // Helper function (moved logic inside renderMeasurementForm but kept here if global calls occur, though ideally scoped)
        // Kept for backward compatibility if needed, but main logic is now inside renderMeasurementForm
        function calculateTotal() {
            // Logic moved inside renderMeasurementForm
        }

        async function saveMeasurement(orderId, order) {
            const measuredItems = [];
            let total = 0;

            document.querySelectorAll('.measure-qty').forEach((qtyInput, i) => {
                const priceInput = document.querySelectorAll('.measure-price')[i];
                const originalItem = order.items[i];
                const qty = parseFloat(qtyInput.value) || 0;
                const price = parseFloat(priceInput.value) || 0;

                measuredItems.push({
                    ...originalItem,
                    quantity: qty,
                    unitPrice: price
                });

                total += qty * price;
            });

            try {
                await updateDoc(doc(db, 'orders', orderId), {
                    status: 'measured',
                    measuredItems: measuredItems,
                    totalPrice: total,
                    measuredAt: new Date()
                });

                bootstrap.Modal.getInstance(document.getElementById('statusModal')).hide();
                await loadOrders();

            } catch (error) {
                alert('Hata: ' + error.message);
            }
        }

        async function updateOrderStatus(orderId, newStatus) {
            try {
                const updateData = { status: newStatus };

                if (newStatus === 'confirmed') updateData.confirmedAt = new Date();
                if (newStatus === 'picked_up') updateData.pickedUpAt = new Date();
                if (newStatus === 'delivered') updateData.deliveredAt = new Date();

                await updateDoc(doc(db, 'orders', orderId), updateData);

                bootstrap.Modal.getInstance(document.getElementById('statusModal')).hide();
                await loadOrders();

            } catch (error) {
                alert('Hata: ' + error.message);
            }
        }

        function setupFilters() {
            document.querySelectorAll('.status-filter').forEach(btn => {
                btn.addEventListener('click', () => {
                    document.querySelectorAll('.status-filter').forEach(b => {
                        b.classList.remove('active', 'btn-primary');
                        b.classList.add('btn-outline-' + getFilterClass(b.dataset.status));
                    });
                    btn.classList.add('active', 'btn-primary');
                    btn.classList.remove('btn-outline-primary', 'btn-outline-warning', 'btn-outline-info', 'btn-outline-success');

                    currentFilter = btn.dataset.status;
                    renderOrders();
                });
            });
        }

        function getFilterClass(status) {
            const map = { all: 'primary', pending: 'warning', confirmed: 'info', picked_up: 'primary', delivered: 'success' };
            return map[status] || 'secondary';
        }

        function getStatusConfig(status) {
            const config = {
                pending: { class: 'warning', text: 'Bekliyor', icon: 'clock' },
                confirmed: { class: 'info', text: 'Onaylandı', icon: 'check' },
                picked_up: { class: 'primary', text: 'Teslim Alındı', icon: 'truck' },
                measured: { class: 'info', text: 'Ölçüm Yapıldı', icon: 'ruler' },
                washing: { class: 'primary', text: 'Yıkanıyor', icon: 'soap' },
                drying: { class: 'primary', text: 'Kurutuluyor', icon: 'sun' },
                out_for_delivery: { class: 'info', text: 'Dağıtıma Çıktı', icon: 'shipping-fast' },
                delivered: { class: 'success', text: 'Teslim Edildi', icon: 'check-circle' },
                cancelled: { class: 'danger', text: 'İptal', icon: 'times-circle' }
            };
            return config[status] || { class: 'secondary', text: status, icon: 'question' };
        }

        function getUnitLabel(unit) {
            return { m2: 'm²', adet: 'Adet', takim: 'Takım' }[unit] || unit;
        }

        function formatDate(date) {
            return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }).format(date);
        }

        function formatPrice(price) {
            return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(price);
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