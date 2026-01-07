<?php
require_once 'includes/header.php';
// Sidebar is already included in header.php
?>

<!-- Page Header -->
<div class="page-header">
    <div class="d-flex justify-content-between align-items-center">
        <div>
            <h4 class="mb-1"><i class="fas fa-wallet me-2"></i>Ön Muhasebe</h4>
            <p class="mb-0 opacity-75">Gelir ve Gider Takibi</p>
        </div>
        <div class="text-end d-none d-md-block">
            <p class="mb-0 small opacity-75"><?php echo date('d F Y, l'); ?></p>
        </div>
    </div>
</div>

<div class="page-body">
    <!-- Summary Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100 bg-primary text-white">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-white-50">Toplam Gelir (TL)</h6>
                            <h3 class="mb-0" id="totalRevenue">0.00 ₺</h3>
                        </div>
                        <div class="fs-1 text-white-50"><i class="fas fa-wallet"></i></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100 bg-success text-white">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-white-50">Satılan KRD</h6>
                            <h3 class="mb-0" id="totalKrdSold">0 KRD</h3>
                        </div>
                        <div class="fs-1 text-white-50"><i class="fas fa-coins"></i></div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card border-0 shadow-sm h-100 bg-info text-white">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="text-white-50">Harcanan KRD</h6>
                            <h3 class="mb-0" id="totalKrdSpent">0 KRD</h3>
                        </div>
                        <div class="fs-1 text-white-50"><i class="fas fa-chart-line"></i></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Actions & Filters -->
    <div class="card border-0 shadow-sm mb-4">
        <div class="card-body">
            <div class="d-flex flex-column flex-md-row gap-3 justify-content-between align-items-center">
                <div class="d-flex gap-2">
                    <button id="deleteSelectedBtn" class="btn btn-danger d-none">
                        <i class="fas fa-trash me-2"></i>Seçilenleri Sil
                    </button>
                    <select class="form-select" id="dateFilter">
                        <option value="all">Tüm Zamanlar</option>
                        <option value="this_month">Bu Ay</option>
                        <option value="last_month">Geçen Ay</option>
                    </select>
                    <select class="form-select" id="typeFilter">
                        <option value="all">Tüm İşlemler</option>
                        <option value="income">Gelirler</option>
                        <option value="expense">Giderler</option>
                    </select>
                </div>
                <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addEntryModal">
                    <i class="fas fa-plus me-2"></i>Manuel Giriş Ekle
                </button>
            </div>
        </div>
    </div>

    <!-- Transactions Table -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white py-3">
            <h6 class="mb-0 fw-bold">İşlem Geçmişi</h6>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0" id="transactionsTable">
                <thead class="table-light">
                    <tr>
                        <th style="width: 40px;"><input type="checkbox" class="form-check-input" id="selectAll"></th>
                        <th>Tarih</th>
                        <th>Tür</th>
                        <th>Kategori</th>
                        <th>Açıklama</th>
                        <th class="text-end">Tutar (TL)</th>
                        <th class="text-end">KRD</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="6" class="text-center py-4">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">Loading...</span>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Closing divs opened in header.php -->
</div> <!-- .main-content -->
</div> <!-- #mainLayout -->

<!-- Add Entry Modal -->
<div class="modal fade" id="addEntryModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Yeni İşlem Ekle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="addEntryForm">
                    <div class="mb-3">
                        <label class="form-label">İşlem Türü</label>
                        <select class="form-select" id="entryType" required>
                            <option value="income">Gelir (Income)</option>
                            <option value="expense">Gider (Expense)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Kategori</label>
                        <select class="form-select" id="entryCategory" required>
                            <option value="ads">Reklam Geliri</option>
                            <option value="other">Diğer</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Tutar (TL)</label>
                        <input type="number" step="0.01" class="form-control" id="entryAmount" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Açıklama</label>
                        <textarea class="form-control" id="entryDescription" rows="2" required></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                <button type="button" class="btn btn-primary" id="saveEntryBtn">Kaydet</button>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
    import { getAuth, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";
    import { getFirestore, collection, addDoc, query, orderBy, onSnapshot, where, Timestamp, doc, getDoc, getDocs, deleteDoc } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";
    import { firebaseConfig } from './includes/firebase-config.js';

    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);
    const db = getFirestore(app, 'haliyikamacimmbldatabase');
    
    // Auth Check Logic
    onAuthStateChanged(auth, async (user) => {
        if (!user) {
            window.location.href = 'login.php';
            return;
        }

        const isAdmin = await checkIsAdmin(user.uid);
        if (!isAdmin) {
            await auth.signOut();
            window.location.href = 'login.php';
            return;
        }

        // Show UI
        document.getElementById('authCheck').classList.add('d-none');
        document.getElementById('mainLayout').style.display = 'block';
        
        // Sidebar Toggle Logic (Since we are in mainLayout now)
        document.getElementById('sidebarToggle')?.addEventListener('click', () => {
            document.getElementById('sidebar').classList.toggle('show');
            document.getElementById('sidebarOverlay').classList.toggle('show');
        });

        document.getElementById('sidebarOverlay')?.addEventListener('click', () => {
            document.getElementById('sidebar').classList.remove('show');
            document.getElementById('sidebarOverlay').classList.remove('show');
        });

        // Load Data
        loadData();
    });

    async function checkIsAdmin(uid) {
        try {
            const userDocRef = doc(db, 'users', uid);
            const userDoc = await getDoc(userDocRef);
            if (userDoc.exists()) return userDoc.data().userType === 'admin';
            
            const usersRef = collection(db, 'users');
            const q = query(usersRef, where('uid', '==', uid));
            const snapshot = await getDocs(q);
            if (!snapshot.empty) return snapshot.docs[0].data().userType === 'admin';
            return false;
        } catch (error) {
            console.error(error);
            return false;
        }
    }

    // Data References
    const accountingRef = collection(db, 'accounting_entries');
    const smsPurchasesRef = collection(db, 'smsPurchases');
    const vitrinRef = collection(db, 'firm_vitrin_purchases');
    const campaignsRef = collection(db, 'campaigns');

    let allTransactions = [];
    let unsubscribes = [];

    // Load Data Function
    function loadData() {
        // Clear previous listeners
        unsubscribes.forEach(unsub => unsub());
        unsubscribes = [];

        const q1 = query(accountingRef, orderBy('date', 'desc'));
        const q2 = query(smsPurchasesRef, where('status', '==', 'approved')); 
        const q3 = query(vitrinRef);
        const q4 = query(campaignsRef);

        const updateTable = () => {
            allTransactions.sort((a, b) => b.date - a.date);
            renderTable(allTransactions);
            calculateTotals(allTransactions);
        };

        // 1. Accounting Entries
        unsubscribes.push(onSnapshot(q1, (snapshot) => {
            allTransactions = allTransactions.filter(t => t.source !== 'accounting');
            snapshot.forEach(doc => {
                const data = doc.data();
                allTransactions.push({
                    id: doc.id,
                    source: 'accounting',
                    type: data.type,
                    category: data.category,
                    description: data.description,
                    amount: data.amount || 0,
                    krdAmount: data.krdAmount || 0,
                    date: data.date ? data.date.toDate() : new Date(),
                    originalData: data
                });
            });
            updateTable();
        }));

        // 2. SMS Purchases
        unsubscribes.push(onSnapshot(q2, (snapshot) => {
            allTransactions = allTransactions.filter(t => t.source !== 'sms_purchase');
            snapshot.forEach(doc => {
                const data = doc.data();
                allTransactions.push({
                    id: doc.id,
                    source: 'sms_purchase',
                    type: 'income',
                    category: 'krd_package',
                    description: `${data.firmName} - ${data.packageName}`,
                    amount: data.price || 0,
                    krdAmount: data.smsCount || 0,
                    date: data.approvedAt ? data.approvedAt.toDate() : (data.createdAt ? data.createdAt.toDate() : new Date()),
                    originalData: data
                });
            });
            updateTable();
        }));

        // 3. Vitrin Items
        unsubscribes.push(onSnapshot(q3, (snapshot) => {
            allTransactions = allTransactions.filter(t => t.source !== 'vitrin');
            snapshot.forEach(doc => {
                const data = doc.data();
                if(!data.smsCost) return;
                allTransactions.push({
                    id: doc.id,
                    source: 'vitrin',
                    type: 'krd_usage',
                    category: 'vitrin',
                    description: `${data.firmName} - ${data.packageName}`,
                    amount: 0,
                    krdAmount: data.smsCost,
                    date: data.createdAt ? data.createdAt.toDate() : new Date(),
                    originalData: data
                });
            });
            updateTable();
        }));

        // 4. Campaigns
        unsubscribes.push(onSnapshot(q4, (snapshot) => {
            allTransactions = allTransactions.filter(t => t.source !== 'campaign');
            snapshot.forEach(doc => {
                const data = doc.data();
                if(!data.smsCost) return;
                allTransactions.push({
                    id: doc.id,
                    source: 'campaign',
                    type: 'krd_usage',
                    category: 'campaign',
                    description: `${data.firmName} - ${data.packageName || 'Kampanya'}`,
                    amount: 0,
                    krdAmount: data.smsCost,
                    date: data.createdAt ? data.createdAt.toDate() : new Date(),
                    originalData: data
                });
            });
            updateTable();
        }));
    }

    function renderTable(transactions) {
        const tableBody = document.querySelector('#transactionsTable tbody');
        let rows = '';

        if(transactions.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="6" class="text-center py-4 text-muted">Kayıt bulunamadı.</td></tr>';
            return;
        }

        const dateFilter = document.getElementById('dateFilter').value;
        const typeFilter = document.getElementById('typeFilter').value;
        const now = new Date();

        const filtered = transactions.filter(t => {
            if(dateFilter === 'this_month') {
                if(t.date.getMonth() !== now.getMonth() || t.date.getFullYear() !== now.getFullYear()) return false;
            } else if (dateFilter === 'last_month') {
                const lastMonth = new Date();
                lastMonth.setMonth(now.getMonth() - 1);
                if(t.date.getMonth() !== lastMonth.getMonth() || t.date.getFullYear() !== lastMonth.getFullYear()) return false;
            }

            if(typeFilter !== 'all') {
                if(typeFilter === 'income' && t.type !== 'income') return false;
                if(typeFilter === 'expense' && t.type !== 'expense') return false;
            }
            return true;
        });

        filtered.forEach(t => {
            const dateStr = t.date.toLocaleString('tr-TR');
            const typeLabel = getTypeLabel(t.type);
            const categoryLabel = getCategoryLabel(t.category);
            
            let amountHtml = '-';
            if(t.type === 'income') amountHtml = `<span class="text-success fw-bold">+${t.amount.toLocaleString('tr-TR', {minimumFractionDigits: 2})} ₺</span>`;
            if(t.type === 'expense') amountHtml = `<span class="text-danger fw-bold">-${t.amount.toLocaleString('tr-TR', {minimumFractionDigits: 2})} ₺</span>`;
            
            let krdHtml = '-';
            if(t.krdAmount > 0) {
                if(t.source === 'sms_purchase') krdHtml = `<span class="text-success">+${t.krdAmount} KRD</span>`;
                else if(t.type === 'krd_usage') krdHtml = `<span class="text-secondary">-${t.krdAmount} KRD</span>`;
                else krdHtml = `${t.krdAmount} KRD`;
            }

            rows += `
                <tr>
                    <td><input type="checkbox" class="form-check-input entry-checkbox" data-id="${t.id}" data-source="${t.source}"></td>
                    <td>${dateStr}</td>
                    <td>${typeLabel}</td>
                    <td>${categoryLabel}</td>
                    <td>${t.description}</td>
                    <td class="text-end">${amountHtml}</td>
                    <td class="text-end">${krdHtml}</td>
                </tr>
            `;
        });
        tableBody.innerHTML = rows;
    }

    function calculateTotals(transactions) {
        let totalRevenue = 0;
        let totalKrdSold = 0;
        let totalKrdSpent = 0;

        transactions.forEach(t => {
            if(t.type === 'income') {
                totalRevenue += parseFloat(t.amount);
                if(t.source === 'sms_purchase') totalKrdSold += parseInt(t.krdAmount);
            }
            if(t.type === 'expense') totalRevenue -= parseFloat(t.amount);
            if(t.type === 'krd_usage') totalKrdSpent += parseInt(t.krdAmount);
        });

        document.getElementById('totalRevenue').textContent = totalRevenue.toLocaleString('tr-TR', { minimumFractionDigits: 2 }) + ' ₺';
        document.getElementById('totalKrdSold').textContent = totalKrdSold + ' KRD';
        document.getElementById('totalKrdSpent').textContent = totalKrdSpent + ' KRD';
    }

    function getTypeLabel(type) {
        if(type === 'income') return '<span class="badge bg-success">Gelir</span>';
        if(type === 'expense') return '<span class="badge bg-danger">Gider</span>';
        if(type === 'krd_usage') return '<span class="badge bg-info">KRD Harcama</span>';
        return type;
    }

    function getCategoryLabel(cat) {
        const map = {
            'ads': 'Reklam',
            'krd_package': 'KRD Paketi',
            'vitrin': 'Vitrin',
            'campaign': 'Kampanya',
            'other': 'Diğer'
        };
        return map[cat] || cat;
    }

    document.getElementById('dateFilter').addEventListener('change', () => renderTable(allTransactions));
    document.getElementById('typeFilter').addEventListener('change', () => renderTable(allTransactions));

    // --- Bulk Selection & Delete Logic ---
    
    // Select All
    document.getElementById('selectAll').addEventListener('change', (e) => {
        const checkboxes = document.querySelectorAll('.entry-checkbox');
        checkboxes.forEach(cb => cb.checked = e.target.checked);
        updateDeleteButton();
    });

    // Individual Select (Delegated)
    document.getElementById('transactionsTable').addEventListener('change', (e) => {
        if (e.target.classList.contains('entry-checkbox')) {
            updateDeleteButton();
            // Update Select All state
            const all = document.querySelectorAll('.entry-checkbox');
            const checked = document.querySelectorAll('.entry-checkbox:checked');
            document.getElementById('selectAll').checked = all.length > 0 && all.length === checked.length;
        }
    });

    function updateDeleteButton() {
        const count = document.querySelectorAll('.entry-checkbox:checked').length;
        const btn = document.getElementById('deleteSelectedBtn');
        if (count > 0) {
            btn.classList.remove('d-none');
            btn.innerHTML = `<i class="fas fa-trash me-2"></i>Seçilenleri Sil (${count})`;
        } else {
            btn.classList.add('d-none');
        }
    }

    // Delete Selected Action
    document.getElementById('deleteSelectedBtn').addEventListener('click', async () => {
        const selected = document.querySelectorAll('.entry-checkbox:checked');
        if (selected.length === 0) return;

        const result = await Swal.fire({
            title: 'Emin misiniz?',
            text: `${selected.length} adet kayıt silinecek. Bu işlem geri alınamaz!`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Evet, Sil',
            cancelButtonText: 'İptal'
        });

        if (!result.isConfirmed) return;

        Swal.fire({
            title: 'Siliniyor...',
            allowOutsideClick: false,
            didOpen: () => Swal.showLoading()
        });

        try {
            const promises = Array.from(selected).map(cb => {
                const id = cb.dataset.id;
                const source = cb.dataset.source;
                let colName = '';

                if (source === 'accounting') colName = 'accounting_entries';
                else if (source === 'sms_purchase') colName = 'smsPurchases';
                else if (source === 'vitrin') colName = 'firm_vitrin_purchases';
                else if (source === 'campaign') colName = 'campaigns';

                if (colName) {
                    return deleteDoc(doc(db, colName, id));
                }
                return Promise.resolve();
            });

            await Promise.all(promises);
            
            Swal.fire('Başarılı', 'Seçilen kayıtlar silindi.', 'success');
            // Checkboxes will be cleared on re-render by onSnapshot listeners
            document.getElementById('selectAll').checked = false;
            document.getElementById('deleteSelectedBtn').classList.add('d-none');
            
        } catch (error) {
            console.error(error);
            Swal.fire('Hata', 'Silme işlemi sırasında bir sorun oluştu: ' + error.message, 'error');
        }
    });

    // Add Entry
    document.getElementById('saveEntryBtn').addEventListener('click', async () => {
        const type = document.getElementById('entryType').value;
        const category = document.getElementById('entryCategory').value;
        const amount = parseFloat(document.getElementById('entryAmount').value);
        const description = document.getElementById('entryDescription').value;

        if (!amount || !description) {
            Swal.fire('Hata', 'Lütfen tüm alanları doldurun.', 'error');
            return;
        }

        try {
            await addDoc(accountingRef, {
                type,
                category,
                amount,
                description,
                date: Timestamp.now(),
                createdBy: auth.currentUser.uid
            });

            const modal = bootstrap.Modal.getInstance(document.getElementById('addEntryModal'));
            modal.hide();
            document.getElementById('addEntryForm').reset();
            Swal.fire('Başarılı', 'İşlem kaydedildi.', 'success');
        } catch (error) {
            console.error(error);
            Swal.fire('Hata', 'Kaydedilirken bir sorun oluştu.', 'error');
        }
    });

</script>
</body>
</html>
    <!-- Content -->
    <div class="container-fluid py-4">
        <!-- Summary Cards -->
        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100 bg-primary text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-white-50">Toplam Gelir (TL)</h6>
                                <h3 class="mb-0" id="totalRevenue">0.00 ₺</h3>
                            </div>
                            <div class="fs-1 text-white-50"><i class="fas fa-wallet"></i></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100 bg-success text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-white-50">Satılan KRD</h6>
                                <h3 class="mb-0" id="totalKrdSold">0 KRD</h3>
                            </div>
                            <div class="fs-1 text-white-50"><i class="fas fa-coins"></i></div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100 bg-info text-white">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h6 class="text-white-50">Harcanan KRD</h6>
                                <h3 class="mb-0" id="totalKrdSpent">0 KRD</h3>
                            </div>
                            <div class="fs-1 text-white-50"><i class="fas fa-chart-line"></i></div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Actions & Filters -->
        <div class="card border-0 shadow-sm mb-4">
            <div class="card-body">
                <div class="d-flex flex-column flex-md-row gap-3 justify-content-between align-items-center">
                    <div class="d-flex gap-2">
                        <select class="form-select" id="dateFilter">
                            <option value="all">Tüm Zamanlar</option>
                            <option value="this_month">Bu Ay</option>
                            <option value="last_month">Geçen Ay</option>
                        </select>
                        <select class="form-select" id="typeFilter">
                            <option value="all">Tüm İşlemler</option>
                            <option value="income">Gelirler</option>
                            <option value="expense">Giderler</option>
                        </select>
                    </div>
                    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addEntryModal">
                        <i class="fas fa-plus me-2"></i>Manuel Giriş Ekle
                    </button>
                </div>
            </div>
        </div>

        <!-- Transactions Table -->
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-white py-3">
                <h6 class="mb-0 fw-bold">İşlem Gemişi</h6>
            </div>
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0" id="transactionsTable">
                    <thead class="table-light">
                        <tr>
                            <th>Tarih</th>
                            <th>Tür</th>
                            <th>Kategori</th>
                            <th>Açıklama</th>
                            <th class="text-end">Tutar (TL)</th>
                            <th class="text-end">KRD</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colspan="6" class="text-center py-4">
                                <div class="spinner-border text-primary" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Add Entry Modal -->
<div class="modal fade" id="addEntryModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Yeni İşlem Ekle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="addEntryForm">
                    <div class="mb-3">
                        <label class="form-label">İşlem Türü</label>
                        <select class="form-select" id="entryType" required>
                            <option value="income">Gelir (Income)</option>
                            <option value="expense">Gider (Expense)</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Kategori</label>
                        <select class="form-select" id="entryCategory" required>
                            <option value="ads">Reklam Geliri</option>
                            <option value="other">Diğer</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Tutar (TL)</label>
                        <input type="number" step="0.01" class="form-control" id="entryAmount" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Açıklama</label>
                        <textarea class="form-control" id="entryDescription" rows="2" required></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                <button type="button" class="btn btn-primary" id="saveEntryBtn">Kaydet</button>
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
    import { getFirestore, collection, addDoc, query, orderBy, onSnapshot, where, Timestamp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";
    import firebaseConfig from './includes/firebase-config.js';

    const app = initializeApp(firebaseConfig);
    const db = getFirestore(app);
    const accountingRef = collection(db, 'accounting_entries');
    const smsPurchasesRef = collection(db, 'smsPurchases');
    const vitrinRef = collection(db, 'vitrinItems');
    const campaignsRef = collection(db, 'campaigns');

    let allTransactions = [];
    let unsubscribes = [];

    // Load Data
    function loadData() {
        // Clear previous listeners
        unsubscribes.forEach(unsub => unsub());
        unsubscribes = [];

        const q1 = query(accountingRef, orderBy('date', 'desc'));
        const q2 = query(smsPurchasesRef, where('status', '==', 'approved')); // Only approved sales
        const q3 = query(vitrinRef);
        const q4 = query(campaignsRef);

        // We listen to all and merge client-side (Not efficient for huge data, but fine for now)
        
        const updateTable = () => {
            // Sort by date desc
            allTransactions.sort((a, b) => b.date - a.date);
            renderTable(allTransactions);
            calculateTotals(allTransactions);
        };

        // 1. Accounting Entries
        unsubscribes.push(onSnapshot(q1, (snapshot) => {
            // Remove old entries of this type
            allTransactions = allTransactions.filter(t => t.source !== 'accounting');
            
            snapshot.forEach(doc => {
                const data = doc.data();
                allTransactions.push({
                    id: doc.id,
                    source: 'accounting',
                    type: data.type, // income, expense
                    category: data.category,
                    description: data.description,
                    amount: data.amount || 0, // TL
                    krdAmount: data.krdAmount || 0,
                    date: data.date ? data.date.toDate() : new Date(),
                    originalData: data
                });
            });
            updateTable();
        }));

        // 2. SMS Purchases (Income)
        unsubscribes.push(onSnapshot(q2, (snapshot) => {
            allTransactions = allTransactions.filter(t => t.source !== 'sms_purchase');
            
            snapshot.forEach(doc => {
                const data = doc.data();
                allTransactions.push({
                    id: doc.id,
                    source: 'sms_purchase',
                    type: 'income', // Sales are income
                    category: 'krd_package',
                    description: `${data.firmName} - ${data.packageName}`,
                    amount: data.price || 0, // TL
                    krdAmount: data.smsCount || 0, // Sold KRD
                    date: data.approvedAt ? data.approvedAt.toDate() : (data.createdAt ? data.createdAt.toDate() : new Date()),
                    originalData: data
                });
            });
            updateTable();
        }));

        // 3. Vitrin Items (Expense / Usage)
        unsubscribes.push(onSnapshot(q3, (snapshot) => {
            allTransactions = allTransactions.filter(t => t.source !== 'vitrin');
            
            snapshot.forEach(doc => {
                const data = doc.data();
                if(!data.smsCost) return; // Skip if no cost
                
                allTransactions.push({
                    id: doc.id,
                    source: 'vitrin',
                    type: 'krd_usage', // Usage is KRD expense for firm (but strictly it's not TL expense for admin. It's KRD Usage)
                    category: 'vitrin',
                    description: `${data.firmName} - ${data.packageName}`,
                    amount: 0, // No TL change
                    krdAmount: data.smsCost,
                    date: data.createdAt ? data.createdAt.toDate() : new Date(),
                    originalData: data
                });
            });
            updateTable();
        }));

        // 4. Campaigns (Expense / Usage)
        unsubscribes.push(onSnapshot(q4, (snapshot) => {
            allTransactions = allTransactions.filter(t => t.source !== 'campaign');
            
            snapshot.forEach(doc => {
                const data = doc.data();
                if(!data.smsCost) return;

                allTransactions.push({
                    id: doc.id,
                    source: 'campaign',
                    type: 'krd_usage',
                    category: 'campaign',
                    description: `${data.firmName} - ${data.packageName || 'Kampanya'}`,
                    amount: 0,
                    krdAmount: data.smsCost,
                    date: data.createdAt ? data.createdAt.toDate() : new Date(),
                    originalData: data
                });
            });
            updateTable();
        }));
    }

    function renderTable(transactions) {
        const tableBody = document.querySelector('#transactionsTable tbody');
        let rows = '';

        if(transactions.length === 0) {
            tableBody.innerHTML = '<tr><td colspan="6" class="text-center py-4 text-muted">Kayıt bulunamadı.</td></tr>';
            return;
        }

        // Filters (Client side for now)
        const dateFilter = document.getElementById('dateFilter').value;
        const typeFilter = document.getElementById('typeFilter').value;
        const now = new Date();

        const filtered = transactions.filter(t => {
            // Date Filter
            if(dateFilter === 'this_month') {
                if(t.date.getMonth() !== now.getMonth() || t.date.getFullYear() !== now.getFullYear()) return false;
            } else if (dateFilter === 'last_month') {
                const lastMonth = new Date();
                lastMonth.setMonth(now.getMonth() - 1);
                if(t.date.getMonth() !== lastMonth.getMonth() || t.date.getFullYear() !== lastMonth.getFullYear()) return false;
            }

            // Type Filter
            if(typeFilter !== 'all') {
                if(typeFilter === 'income' && (t.type !== 'income')) return false;
                if(typeFilter === 'expense' && (t.type !== 'expense')) return false;
            }
            return true;
        });

        filtered.forEach(t => {
            const dateStr = t.date.toLocaleString('tr-TR');
            const typeLabel = getTypeLabel(t.type);
            const categoryLabel = getCategoryLabel(t.category);
            
            // Amount Formatting
            let amountHtml = '-';
            if(t.type === 'income') amountHtml = `<span class="text-success fw-bold">+${t.amount.toFixed(2)} ₺</span>`;
            if(t.type === 'expense') amountHtml = `<span class="text-danger fw-bold">-${t.amount.toFixed(2)} ₺</span>`;
            
            // KRD Formatting
            let krdHtml = '-';
            if(t.krdAmount > 0) {
                if(t.source === 'sms_purchase') krdHtml = `<span class="text-success">+${t.krdAmount} KRD</span>`;
                else if(t.type === 'krd_usage') krdHtml = `<span class="text-secondary">-${t.krdAmount} KRD</span>`;
                else krdHtml = `${t.krdAmount} KRD`;
            }

            rows += `
                <tr>
                    <td>${dateStr}</td>
                    <td>${typeLabel}</td>
                    <td>${categoryLabel}</td>
                    <td>${t.description}</td>
                    <td class="text-end">${amountHtml}</td>
                    <td class="text-end">${krdHtml}</td>
                </tr>
            `;
        });
        tableBody.innerHTML = rows;
    }

    function calculateTotals(transactions) {
        let totalRevenue = 0;
        let totalKrdSold = 0;
        let totalKrdSpent = 0;

        transactions.forEach(t => {
            if(t.type === 'income') {
                totalRevenue += parseFloat(t.amount);
                if(t.source === 'sms_purchase') totalKrdSold += parseInt(t.krdAmount);
            }
            if(t.type === 'expense') {
                totalRevenue -= parseFloat(t.amount);
            }
            if(t.type === 'krd_usage') {
                totalKrdSpent += parseInt(t.krdAmount);
            }
        });

        document.getElementById('totalRevenue').textContent = totalRevenue.toLocaleString('tr-TR', { minimumFractionDigits: 2 }) + ' ₺';
        document.getElementById('totalKrdSold').textContent = totalKrdSold + ' KRD';
        document.getElementById('totalKrdSpent').textContent = totalKrdSpent + ' KRD';
    }

    // Helpers
    function getTypeLabel(type) {
        if(type === 'income') return '<span class="badge bg-success">Gelir</span>';
        if(type === 'expense') return '<span class="badge bg-danger">Gider</span>';
        if(type === 'krd_usage') return '<span class="badge bg-info">KRD Harcama</span>';
        return type;
    }

    // Listens for filter changes
    document.getElementById('dateFilter').addEventListener('change', () => {
         // Re-render with existing data
         renderTable(allTransactions); 
         // Note: Totals usually reflect ALL time or filtered? Usually Dashboard shows Totals (All Time) and Table shows filtered. 
         // But user might want filtered totals. For now, keeping totals as ALL TIME based on loaded data.
    });

    document.getElementById('typeFilter').addEventListener('change', () => renderTable(allTransactions));

    function getCategoryLabel(cat) {
        const map = {
            'ads': 'Reklam',
            'krd_package': 'KRD Paketi',
            'vitrin': 'Vitrin',
            'campaign': 'Kampanya',
            'other': 'Diğer'
        };
        return map[cat] || cat;
    }

    // Add Entry
    document.getElementById('saveEntryBtn').addEventListener('click', async () => {
        const type = document.getElementById('entryType').value;
        const category = document.getElementById('entryCategory').value;
        const amount = parseFloat(document.getElementById('entryAmount').value);
        const description = document.getElementById('entryDescription').value;

        if (!amount || !description) {
            Swal.fire('Hata', 'Lütfen tüm alanları doldurun.', 'error');
            return;
        }

        try {
            await addDoc(accountingRef, {
                type,
                category,
                amount,
                description,
                date: Timestamp.now(),
                createdBy: 'admin_manual' // TODO: Get actual admin ID if available
            });

            // Close Modal
            // Close Modal
            const modalEl = document.getElementById('addEntryModal');
            const modal = bootstrap.Modal.getOrCreateInstance(modalEl);
            modal.hide();
            
            // Force verify backdrop removal
            setTimeout(() => {
                const backdrops = document.querySelectorAll('.modal-backdrop');
                backdrops.forEach(backdrop => backdrop.remove());
                document.body.classList.remove('modal-open');
                document.body.style.overflow = '';
                document.body.style.paddingRight = '';
            }, 300);

            document.getElementById('addEntryForm').reset();
            Swal.fire('Başarılı', 'İşlem kaydedildi.', 'success');

        } catch (error) {
            console.error(error);
            Swal.fire('Hata', 'Kaydedilirken bir sorun oluştu.', 'error');
        }
    });

    // Init
    loadData();

</script>
</body>

</html>