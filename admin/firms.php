<?php
/**
 * Halı Yıkamacı - Admin Firma Yönetimi
 */

require_once '../config/app.php';
$pageTitle = 'Firma Yönetimi';
require_once 'includes/header.php';
?>

<div class="page-header">
    <h4 class="mb-0"><i class="fas fa-store me-2"></i>Firma Yönetimi</h4>
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
        <button class="btn btn-outline-success status-filter" data-status="approved">
            Onaylı <span class="badge bg-success ms-1" id="countApproved">0</span>
        </button>
    </div>
</div>

<div class="page-body">
    <div id="firmsList">
        <div class="text-center py-5">
            <div class="spinner"></div>
        </div>
    </div>
</div>

<!-- Firm Detail Modal -->
<div class="modal fade" id="firmModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="firmModalTitle">Firma Detayı</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body" id="firmModalBody">
                <!-- Dynamic content -->
            </div>
            <div class="modal-footer" id="firmModalFooter">
                <!-- Dynamic buttons -->
            </div>
        </div>
    </div>
</div>

<!-- SMS Balance Modal -->
<div class="modal fade" id="smsModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">SMS Bakiye Ekle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Firma: <strong id="smsFirmName">-</strong></p>
                <p>Mevcut Bakiye: <strong id="smsCurrentBalance">0</strong> SMS</p>
                <div class="mb-3">
                    <label class="form-label">Eklenecek SMS</label>
                    <input type="number" id="smsAmount" class="form-control" min="1" value="100">
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                <button type="button" class="btn btn-primary" id="addSmsBtn">
                    <i class="fas fa-plus me-1"></i>Ekle
                </button>
            </div>
        </div>
    </div>
</div>

</div> <!-- Closing Main Content -->
</div> <!-- Closing Main Layout -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
    import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, collection, getDocs, query, where, doc, getDoc, updateDoc, deleteDoc, increment } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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

    let allFirms = [];
    let currentFilter = 'all';
    let selectedFirm = null;

    onAuthStateChanged(auth, async (user) => {
        if (!user) {
            window.location.href = 'login.php';
            return;
        }

        const isAdmin = await checkIsAdmin(user.uid);
        if (!isAdmin) {
            window.location.href = 'login.php';
            return;
        }

        document.getElementById('authCheck').classList.add('d-none');
        document.getElementById('mainLayout').style.display = 'block';

        await loadFirms();
        setupFilters();
    });

    async function checkIsAdmin(uid) {
        try {
            const userDocRef = doc(db, 'users', uid);
            const userDoc = await getDoc(userDocRef);

            if (userDoc.exists()) {
                return userDoc.data().userType === 'admin';
            }
            return false;
        } catch (error) {
            console.error('Admin check error:', error);
            return false;
        }
    }

    async function loadFirms() {
        try {
            const firmsRef = collection(db, 'firms');
            const snapshot = await getDocs(firmsRef);

            allFirms = [];
            snapshot.forEach(doc => {
                allFirms.push({ id: doc.id, ...doc.data() });
            });

            // Sort by date
            allFirms.sort((a, b) => {
                const dateA = a.createdAt?.toDate ? a.createdAt.toDate() : new Date(a.createdAt);
                const dateB = b.createdAt?.toDate ? b.createdAt.toDate() : new Date(b.createdAt);
                return dateB - dateA;
            });

            updateCounts();
            renderFirms();

        } catch (error) {
            console.error('Firmalar yüklenirken hata:', error);
        }
    }

    function updateCounts() {
        const counts = {
            all: allFirms.length,
            pending: allFirms.filter(f => !f.isApproved).length,
            approved: allFirms.filter(f => f.isApproved).length
        };

        document.getElementById('countAll').textContent = counts.all;
        document.getElementById('countPending').textContent = counts.pending;
        document.getElementById('countApproved').textContent = counts.approved;
    }

    function renderFirms() {
        const container = document.getElementById('firmsList');

        let filtered = currentFilter === 'all' ? allFirms :
            currentFilter === 'pending' ? allFirms.filter(f => !f.isApproved) :
                allFirms.filter(f => f.isApproved);

        if (filtered.length === 0) {
            container.innerHTML = `
        <div class="text-center py-5">
            <i class="fas fa-store fa-4x text-muted mb-3"></i>
            <h5>Firma Bulunamadı</h5>
        </div>
    `;
            return;
        }

        container.innerHTML = `
    <div class="table-responsive">
        <table class="table table-hover">
            <thead class="table-light">
                <tr>
                    <th>Firma</th>
                    <th>Telefon</th>
                    <th>Şehir</th>
                    <th>SMS</th>
                    <th>Puan</th>
                    <th>Durum</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                ${filtered.map(firm => {
            const addr = firm.address || {};
            return `
                        <tr>
                            <td>
                                <strong>${firm.name}</strong>
                            </td>
                            <td>${firm.phone}</td>
                            <td>${addr.city || '-'}</td>
                            <td>
                                <span class="badge ${firm.smsBalance > 50 ? 'bg-success' : 'bg-danger'}">${firm.smsBalance || 0}</span>
                            </td>
                            <td>
                                <i class="fas fa-star text-warning"></i> ${(firm.rating || 0).toFixed(1)}
                                <small class="text-muted">(${firm.reviewCount || 0})</small>
                            </td>
                            <td>
                                ${firm.isApproved
                    ? '<span class="badge bg-success">Onaylı</span>'
                    : '<span class="badge bg-warning text-dark">Bekliyor</span>'}
                            </td>
                            <td>
                                <div class="btn-group btn-group-sm">
                                    <button class="btn btn-outline-primary btn-view" data-id="${firm.id}">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="btn btn-outline-info btn-sms" data-id="${firm.id}">
                                        <i class="fas fa-sms"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    `;
        }).join('')}
            </tbody>
        </table>
    </div>
`;

        // Setup action buttons
        document.querySelectorAll('.btn-view').forEach(btn => {
            btn.addEventListener('click', () => showFirmDetail(btn.dataset.id));
        });

        document.querySelectorAll('.btn-sms').forEach(btn => {
            btn.addEventListener('click', () => showSmsModal(btn.dataset.id));
        });
    }

    function showFirmDetail(firmId) {
        selectedFirm = allFirms.find(f => f.id === firmId);
        if (!selectedFirm) return;

        const addr = selectedFirm.address || {};
        const createdAt = selectedFirm.createdAt?.toDate ? selectedFirm.createdAt.toDate() : new Date(selectedFirm.createdAt);

        document.getElementById('firmModalTitle').textContent = selectedFirm.name;

        document.getElementById('firmModalBody').innerHTML = `
    <div class="row">
        <div class="col-md-6">
            <h6>Temel Bilgiler</h6>
            <table class="table table-sm">
                <tr><td class="text-muted">Telefon</td><td><strong>${selectedFirm.phone}</strong></td></tr>
                <tr><td class="text-muted">WhatsApp</td><td>${selectedFirm.whatsapp || '-'}</td></tr>
                <tr><td class="text-muted">Kayıt Tarihi</td><td>${formatDate(createdAt)}</td></tr>
            </table>
        </div>
        <div class="col-md-6">
            <h6>Adres</h6>
            <p>${addr.city || ''}, ${addr.district || ''}</p>
            <p class="text-muted">${addr.fullAddress || ''}</p>
        </div>
    </div>
    <hr>
    <div class="row">
        <div class="col-4 text-center">
            <h4 class="mb-0">${selectedFirm.smsBalance || 0}</h4>
            <small class="text-muted">SMS Bakiye</small>
        </div>
        <div class="col-4 text-center">
            <h4 class="mb-0">${(selectedFirm.rating || 0).toFixed(1)}</h4>
            <small class="text-muted">Puan</small>
        </div>
        <div class="col-4 text-center">
            <h4 class="mb-0">${selectedFirm.reviewCount || 0}</h4>
            <small class="text-muted">Yorum</small>
        </div>
    </div>
    <hr>
    <h6>Hizmetler</h6>
    <div class="d-flex flex-wrap gap-1">
        ${(selectedFirm.services || []).filter(s => s.isActive).map(s =>
            `<span class="badge bg-light text-dark">${s.serviceName} - ₺${s.price}</span>`
        ).join('') || '<span class="text-muted">Hizmet eklenmemiş</span>'}
    </div>
`;

        document.getElementById('firmModalFooter').innerHTML = `
    ${!selectedFirm.isApproved ? `
        <button class="btn btn-success" id="approveFirmBtn">
            <i class="fas fa-check me-1"></i>Onayla
        </button>
    ` : ''}
    <button class="btn btn-outline-danger" id="deleteFirmBtn">
        <i class="fas fa-trash me-1"></i>Sil
    </button>
    <button class="btn btn-secondary" data-bs-dismiss="modal">Kapat</button>
`;

        // Setup buttons
        document.getElementById('approveFirmBtn')?.addEventListener('click', async () => {
            await updateDoc(doc(db, 'firms', selectedFirm.id), { isApproved: true });
            bootstrap.Modal.getInstance(document.getElementById('firmModal')).hide();
            await loadFirms();
        });

        document.getElementById('deleteFirmBtn')?.addEventListener('click', async () => {
            if (confirm('Bu firmayı silmek istediğinize emin misiniz?')) {
                await deleteDoc(doc(db, 'firms', selectedFirm.id));
                bootstrap.Modal.getInstance(document.getElementById('firmModal')).hide();
                await loadFirms();
            }
        });

        new bootstrap.Modal(document.getElementById('firmModal')).show();
    }

    function showSmsModal(firmId) {
        selectedFirm = allFirms.find(f => f.id === firmId);
        if (!selectedFirm) return;

        document.getElementById('smsFirmName').textContent = selectedFirm.name;
        document.getElementById('smsCurrentBalance').textContent = selectedFirm.smsBalance || 0;
        document.getElementById('smsAmount').value = 100;

        new bootstrap.Modal(document.getElementById('smsModal')).show();
    }

    document.getElementById('addSmsBtn').addEventListener('click', async () => {
        if (!selectedFirm) return;

        const amount = parseInt(document.getElementById('smsAmount').value) || 0;
        if (amount <= 0) {
            alert('Geçerli bir miktar girin.');
            return;
        }

        try {
            await updateDoc(doc(db, 'firms', selectedFirm.id), {
                smsBalance: increment(amount)
            });

            bootstrap.Modal.getInstance(document.getElementById('smsModal')).hide();
            alert(`${amount} SMS başarıyla eklendi!`);
            await loadFirms();

        } catch (error) {
            alert('Hata: ' + error.message);
        }
    });

    function setupFilters() {
        document.querySelectorAll('.status-filter').forEach(btn => {
            btn.addEventListener('click', () => {
                document.querySelectorAll('.status-filter').forEach(b => {
                    b.classList.remove('active', 'btn-primary');
                    b.classList.add('btn-outline-' + getFilterClass(b.dataset.status));
                });
                btn.classList.add('active', 'btn-primary');
                btn.classList.remove('btn-outline-primary', 'btn-outline-warning', 'btn-outline-success');

                currentFilter = btn.dataset.status;
                renderFirms();
            });
        });
    }

    function getFilterClass(status) {
        return { all: 'primary', pending: 'warning', approved: 'success' }[status] || 'secondary';
    }

    function formatDate(date) {
        return new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' }).format(date);
    }
</script>
</body>

</html>