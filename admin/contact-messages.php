<?php
require_once 'includes/header.php';
?>

<div class="page-header">
    <div class="d-flex justify-content-between align-items-center">
        <div>
            <h2 class="fw-bold mb-0">İletişim Mesajları</h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0 text-white-50">
                    <li class="breadcrumb-item"><a href="index.php" class="text-white-50">Dashboard</a></li>
                    <li class="breadcrumb-item active text-white" aria-current="page">İletişim Mesajları</li>
                </ol>
            </nav>
        </div>
        <button class="btn btn-light" onclick="loadMessages()">
            <i class="fas fa-sync-alt me-2"></i>Yenile
        </button>
    </div>
</div>

<div class="page-body">
    <div class="card border-0 shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead class="table-light">
                        <tr>
                            <th>Durum</th>
                            <th>Tarih</th>
                            <th>Gönderen</th>
                            <th>Konu</th>
                            <th>Aksiyon</th>
                        </tr>
                    </thead>
                    <tbody id="messagesTable">
                        <tr>
                            <td colspan="5" class="text-center py-4">
                                <div class="spinner-border text-primary" role="status">
                                    <span class="visually-hidden">Yükleniyor...</span>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Message Detail Modal -->
<div class="modal fade" id="messageModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Mesaj Detayı</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="fw-bold text-muted small">GÖNDEREN</label>
                    <p id="msgSender" class="mb-0 fs-5">-</p>
                    <small id="msgEmail" class="text-muted">-</small>
                </div>
                <div class="mb-3">
                    <label class="fw-bold text-muted small">TARİH</label>
                    <p id="msgDate">-</p>
                </div>
                <div class="mb-3">
                    <label class="fw-bold text-muted small">KONU</label>
                    <p id="msgSubject" class="fw-bold">-</p>
                </div>
                <div class="bg-light p-3 rounded">
                    <label class="fw-bold text-muted small mb-2">MESAJ İÇERİĞİ</label>
                    <p id="msgContent" style="white-space: pre-line;">-</p>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-danger me-auto" onclick="deleteMessage()">
                    <i class="fas fa-trash me-2"></i>Sil
                </button>
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Kapat</button>
                <a id="replyBtn" href="#" class="btn btn-primary">
                    <i class="fas fa-reply me-2"></i>Yanıtla (E-Posta)
                </a>
            </div>
        </div>
    </div>
</div>

<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js';
    import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js';
    import { getFirestore, collection, query, orderBy, getDocs, doc, updateDoc, deleteDoc } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

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

    let currentMessageId = null;
    let messages = [];

    onAuthStateChanged(auth, (user) => {
        if (!user) {
            window.location.href = 'login.php';
        } else {
            // Hide Loader
            document.getElementById('authCheck').classList.add('d-none');
            document.getElementById('mainLayout').style.display = 'block';

            loadMessages();
        }
    });

    window.loadMessages = async function () {
        const tbody = document.getElementById('messagesTable');
        tbody.innerHTML = `<tr><td colspan="5" class="text-center py-4"><div class="spinner-border text-primary"></div></td></tr>`;

        try {
            const q = query(collection(db, 'contactMessages'), orderBy('createdAt', 'desc'));
            const snapshot = await getDocs(q);

            messages = [];
            snapshot.forEach(doc => {
                messages.push({ id: doc.id, ...doc.data() });
            });

            renderMessages();
        } catch (error) {
            console.error(error);
            tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger py-4">Veriler yüklenirken hata oluştu: ${error.message}</td></tr>`;
        }
    }

    function renderMessages() {
        const tbody = document.getElementById('messagesTable');
        if (messages.length === 0) {
            tbody.innerHTML = `<tr><td colspan="5" class="text-center text-muted py-4">Henüz hiç mesaj yok.</td></tr>`;
            return;
        }

        let html = '';
        messages.forEach(msg => {
            const isRead = msg.isRead ? '' : '<span class="badge bg-danger rounded-pill">Yeni</span>';
            const rowClass = msg.isRead ? '' : 'fw-bold bg-light';
            const date = msg.createdAt?.seconds ? new Date(msg.createdAt.seconds * 1000).toLocaleString('tr-TR') : '-';

            html += `
                <tr class="${rowClass}" style="cursor: pointer;" onclick="viewMessage('${msg.id}')">
                    <td>${isRead}</td>
                    <td>${date}</td>
                    <td>
                        <div>${msg.name}</div>
                        <small class="text-muted">${msg.email}</small>
                    </td>
                    <td>${msg.subject}</td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary" onclick="event.stopPropagation(); viewMessage('${msg.id}')">
                            <i class="fas fa-eye"></i>
                        </button>
                    </td>
                </tr>
            `;
        });
        tbody.innerHTML = html;
    }

    window.viewMessage = async function (id) {
        const msg = messages.find(m => m.id === id);
        if (!msg) return;

        currentMessageId = id;
        document.getElementById('msgSender').textContent = msg.name;
        document.getElementById('msgEmail').textContent = msg.email;
        document.getElementById('msgDate').textContent = msg.createdAt?.seconds ? new Date(msg.createdAt.seconds * 1000).toLocaleString('tr-TR') : '-';
        document.getElementById('msgSubject').textContent = msg.subject;
        document.getElementById('msgContent').textContent = msg.message;

        document.getElementById('replyBtn').href = `mailto:${msg.email}?subject=Ynt: ${msg.subject}`;

        const modal = new bootstrap.Modal(document.getElementById('messageModal'));
        modal.show();

        // Mark as read if needs to
        if (!msg.isRead) {
            try {
                await updateDoc(doc(db, 'contactMessages', id), { isRead: true });
                // Update local state
                msg.isRead = true;
                // Refresh list UI without full reload (keeping modal open)
                renderMessages();
            } catch (e) {
                console.error("Okundu işaretlenemedi", e);
            }
        }
    }

    window.deleteMessage = async function () {
        if (!confirm('Bu mesajı silmek istediğinize emin misiniz?')) return;

        const btn = document.querySelector('button[onclick="deleteMessage()"]');
        btn.disabled = true;

        try {
            await deleteDoc(doc(db, 'contactMessages', currentMessageId));

            // Remove from local array
            messages = messages.filter(m => m.id !== currentMessageId);
            renderMessages();

            bootstrap.Modal.getInstance(document.getElementById('messageModal')).hide();

            Swal.fire({
                icon: 'success',
                title: 'Silindi',
                timer: 1500,
                showConfirmButton: false
            });
        } catch (error) {
            Swal.fire('Hata', error.message, 'error');
        } finally {
            btn.disabled = false;
        }
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<?php require_once 'includes/footer.php'; ?>