<?php
/**
 * Halı Yıkamacı - Firma Destek
 */

require_once '../config/app.php';
$pageTitle = 'Müşteri Destek';
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
                <span class="fw-bold">Destek</span>
                <div></div>
            </div>

            <div class="page-header">
                <h4 class="mb-0"><i class="fas fa-headset me-2"></i>Müşteri Destek Talepleri</h4>
            </div>

            <!-- Tabs -->
            <div class="bg-white border-bottom">
                <div class="container-fluid px-4">
                    <ul class="nav nav-tabs border-0">
                        <li class="nav-item">
                            <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#customerTickets">
                                <i class="fas fa-users me-1"></i>Müşteri Talepleri
                                <span class="badge bg-info ms-1" id="customerTicketCount">0</span>
                            </button>
                        </li>
                        <li class="nav-item">
                            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#adminChat">
                                <i class="fas fa-user-shield me-1"></i>Admin İletişim
                            </button>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="page-body">
                <div class="tab-content">
                    <!-- Customer Tickets -->
                    <div class="tab-pane fade show active" id="customerTickets">
                        <div id="ticketsList">
                            <div class="text-center py-5">
                                <div class="spinner"></div>
                            </div>
                        </div>
                    </div>

                    <!-- Admin Chat -->
                    <div class="tab-pane fade" id="adminChat">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-primary text-white">
                                <h6 class="mb-0"><i class="fas fa-user-shield me-2"></i>Admin ile İletişim</h6>
                            </div>
                            <div class="card-body">
                                <div class="alert alert-info">
                                    <i class="fas fa-info-circle me-2"></i>
                                    Teknik destek veya hesap sorunları için admin ile iletişime geçebilirsiniz.
                                </div>
                                <form id="adminMessageForm">
                                    <div class="mb-3">
                                        <label class="form-label">Mesajınız</label>
                                        <textarea id="adminMessage" class="form-control" rows="4"
                                            placeholder="Sorununuzu detaylı açıklayın..." required></textarea>
                                    </div>
                                    <button type="submit" class="btn btn-primary">
                                        <i class="fas fa-paper-plane me-1"></i>Gönder
                                    </button>
                                </form>
                            </div>
                        </div>
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
                    <h5 class="modal-title" id="chatModalTitle">Destek Talebi</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-0">
                    <div id="chatMessages" class="p-3" style="height: 400px; overflow-y: auto; background: #f8f9fa;">
                        <!-- Messages -->
                    </div>
                    <div class="border-top p-3">
                        <form id="chatForm" class="d-flex gap-2">
                            <input type="text" id="chatInput" class="form-control" placeholder="Mesajınızı yazın...">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        </form>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-success" id="closeTicketBtn">
                        <i class="fas fa-check me-1"></i>Talebi Kapat
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, getDocs, query, where, doc, updateDoc, addDoc, orderBy } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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
        let currentTicket = null;

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

            await loadTickets();
            setupForms();
        });

        async function getFirmData(uid) {
            const firmsRef = collection(db, 'firms');
            const q = query(firmsRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);
            if (snapshot.empty) return null;
            return { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
        }

        async function loadTickets() {
            const container = document.getElementById('ticketsList');

            try {
                const ticketsRef = collection(db, 'tickets');
                const q = query(ticketsRef, where('receiverId', '==', currentFirm.id), where('channel', '==', 'customer_firm'));
                const snapshot = await getDocs(q);

                let tickets = [];
                snapshot.forEach(doc => {
                    tickets.push({ id: doc.id, ...doc.data() });
                });

                // Sort by date
                tickets.sort((a, b) => {
                    const dateA = a.updatedAt?.toDate ? a.updatedAt.toDate() : new Date(a.updatedAt || a.createdAt);
                    const dateB = b.updatedAt?.toDate ? b.updatedAt.toDate() : new Date(b.updatedAt || b.createdAt);
                    return dateB - dateA;
                });

                document.getElementById('customerTicketCount').textContent = tickets.filter(t => t.status !== 'closed').length;

                if (tickets.length === 0) {
                    container.innerHTML = `
                <div class="text-center py-5">
                    <i class="fas fa-inbox fa-4x text-muted mb-3"></i>
                    <h5>Destek Talebi Yok</h5>
                    <p class="text-muted">Müşterilerden gelen destek talebi bulunmuyor.</p>
                </div>
            `;
                    return;
                }

                container.innerHTML = `
            <div class="list-group">
                ${tickets.map(ticket => {
                    const updatedAt = ticket.updatedAt?.toDate ? ticket.updatedAt.toDate() : new Date(ticket.updatedAt || ticket.createdAt);
                    const statusConfig = getStatusConfig(ticket.status);

                    return `
                        <div class="list-group-item list-group-item-action d-flex justify-content-between align-items-start ticket-item"
                             data-ticket='${JSON.stringify(ticket)}'>
                            <div class="me-3">
                                <div class="bg-${statusConfig.bgClass} bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center"
                                     style="width: 50px; height: 50px;">
                                    <i class="fas fa-${statusConfig.icon} text-${statusConfig.bgClass}"></i>
                                </div>
                            </div>
                            <div class="flex-grow-1">
                                <div class="d-flex justify-content-between align-items-start">
                                    <div>
                                        <h6 class="mb-1">${ticket.senderName}</h6>
                                        <p class="text-muted mb-1">${ticket.subject}</p>
                                        <small class="text-muted">${ticket.lastMessage || ''}</small>
                                    </div>
                                    <div class="text-end">
                                        <span class="badge bg-${statusConfig.bgClass}">${statusConfig.text}</span>
                                        <br><small class="text-muted">${formatDate(updatedAt)}</small>
                                        ${ticket.unreadCount > 0 ? `<br><span class="badge bg-danger">${ticket.unreadCount} yeni</span>` : ''}
                                    </div>
                                </div>
                            </div>
                        </div>
                    `;
                }).join('')}
            </div>
        `;

                // Setup click handlers
                document.querySelectorAll('.ticket-item').forEach(item => {
                    item.addEventListener('click', () => {
                        currentTicket = JSON.parse(item.dataset.ticket);
                        openChat(currentTicket);
                    });
                });

            } catch (error) {
                console.error('Talepler yüklenirken hata:', error);
                container.innerHTML = `<div class="alert alert-danger">Hata: ${error.message}</div>`;
            }
        }

        async function openChat(ticket) {
            document.getElementById('chatModalTitle').textContent = ticket.subject + ' - ' + ticket.senderName;

            // Load messages
            const messagesContainer = document.getElementById('chatMessages');
            messagesContainer.innerHTML = '<div class="text-center"><div class="spinner"></div></div>';

            try {
                const messagesRef = collection(db, 'tickets', ticket.id, 'messages');
                const snapshot = await getDocs(messagesRef);

                let messages = [];
                snapshot.forEach(doc => {
                    messages.push({ id: doc.id, ...doc.data() });
                });

                // Sort by date
                messages.sort((a, b) => {
                    const dateA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt);
                    const dateB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt);
                    return dateA - dateB;
                });

                if (messages.length === 0) {
                    messagesContainer.innerHTML = `
                <div class="text-center text-muted py-4">
                    <i class="fas fa-comments fa-2x mb-2"></i>
                    <p>Henüz mesaj yok</p>
                </div>
            `;
                } else {
                    messagesContainer.innerHTML = messages.map(msg => {
                        const isFromFirm = msg.senderId === currentFirm.id;
                        const time = msg.createdAt?.toDate ? msg.createdAt.toDate() : new Date(msg.createdAt);

                        return `
                    <div class="d-flex ${isFromFirm ? 'justify-content-end' : 'justify-content-start'} mb-3">
                        <div class="p-3 rounded ${isFromFirm ? 'bg-primary text-white' : 'bg-white border'}" 
                             style="max-width: 70%;">
                            <p class="mb-1">${msg.message}</p>
                            <small class="${isFromFirm ? 'opacity-75' : 'text-muted'}">${formatTime(time)}</small>
                        </div>
                    </div>
                `;
                    }).join('');

                    messagesContainer.scrollTop = messagesContainer.scrollHeight;
                }

                // Clear unread
                if (ticket.unreadCount > 0) {
                    await updateDoc(doc(db, 'tickets', ticket.id), { unreadCount: 0 });
                }

            } catch (error) {
                messagesContainer.innerHTML = `<div class="alert alert-danger">Hata: ${error.message}</div>`;
            }

            new bootstrap.Modal(document.getElementById('chatModal')).show();
        }

        function setupForms() {
            // Chat form
            document.getElementById('chatForm').addEventListener('submit', async (e) => {
                e.preventDefault();

                const input = document.getElementById('chatInput');
                const message = input.value.trim();
                if (!message || !currentTicket) return;

                try {
                    // Add message
                    const messagesRef = collection(db, 'tickets', currentTicket.id, 'messages');
                    await addDoc(messagesRef, {
                        senderId: currentFirm.id,
                        senderName: currentFirm.name,
                        senderType: 'firm',
                        message: message,
                        createdAt: new Date()
                    });

                    // Update ticket
                    await updateDoc(doc(db, 'tickets', currentTicket.id), {
                        lastMessage: message,
                        status: 'answered',
                        updatedAt: new Date()
                    });

                    input.value = '';
                    await openChat(currentTicket); // Refresh messages

                } catch (error) {
                    alert('Hata: ' + error.message);
                }
            });

            // Close ticket
            document.getElementById('closeTicketBtn').addEventListener('click', async () => {
                if (!currentTicket) return;
                if (!confirm('Talebi kapatmak istediğinize emin misiniz?')) return;

                try {
                    await updateDoc(doc(db, 'tickets', currentTicket.id), {
                        status: 'closed',
                        updatedAt: new Date()
                    });

                    bootstrap.Modal.getInstance(document.getElementById('chatModal')).hide();
                    await loadTickets();

                } catch (error) {
                    alert('Hata: ' + error.message);
                }
            });

            // Admin message
            document.getElementById('adminMessageForm').addEventListener('submit', async (e) => {
                e.preventDefault();

                const message = document.getElementById('adminMessage').value.trim();
                if (!message) return;

                try {
                    // Create ticket to admin
                    await addDoc(collection(db, 'tickets'), {
                        channel: 'firm_admin',
                        senderId: currentFirm.id,
                        senderName: currentFirm.name,
                        senderType: 'firm',
                        receiverId: 'admin',
                        receiverName: 'Admin',
                        subject: 'Destek Talebi',
                        lastMessage: message,
                        status: 'open',
                        unreadCount: 1,
                        createdAt: new Date(),
                        updatedAt: new Date()
                    });

                    document.getElementById('adminMessage').value = '';
                    alert('Mesajınız admin\'e iletildi. En kısa sürede geri dönüş yapılacaktır.');

                } catch (error) {
                    alert('Hata: ' + error.message);
                }
            });
        }

        function getStatusConfig(status) {
            const config = {
                open: { text: 'Açık', bgClass: 'warning', icon: 'clock' },
                answered: { text: 'Yanıtlandı', bgClass: 'info', icon: 'reply' },
                closed: { text: 'Kapalı', bgClass: 'success', icon: 'check' }
            };
            return config[status] || { text: status, bgClass: 'secondary', icon: 'question' };
        }

        function formatDate(date) {
            return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' }).format(date);
        }

        function formatTime(date) {
            return new Intl.DateTimeFormat('tr-TR', { hour: '2-digit', minute: '2-digit' }).format(date);
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