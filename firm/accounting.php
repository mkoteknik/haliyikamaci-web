<?php
/**
 * Halı Yıkamacı - Firma Ön Muhasebe
 */

require_once '../config/app.php';
$pageTitle = 'Ön Muhasebe';
?>
<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo $pageTitle . ' - ' . SITE_NAME; ?></title>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <!-- Custom CSS -->
    <link rel="stylesheet" href="<?php echo SITE_URL; ?>/assets/css/style.css">
</head>

<body>

    <!-- Auth Check -->
    <div id="authCheck" class="d-flex align-items-center justify-content-center vh-100">
        <div class="text-center">
            <div class="spinner mb-3"></div>
            <p class="text-muted">Yetkilendirme kontrol ediliyor...</p>
        </div>
    </div>

    <!-- Main Layout -->
    <div id="mainLayout" style="display: none;">
        <?php require_once 'includes/sidebar.php'; ?>

        <!-- Sidebar Overlay (mobile) -->
        <div class="sidebar-overlay" id="sidebarOverlay"></div>

        <!-- Main Content -->
        <div class="main-content">
            <!-- Mobile Header -->
            <div class="d-lg-none bg-dark text-white p-3 d-flex justify-content-between align-items-center">
                <button class="btn btn-outline-light btn-sm" id="sidebarToggle">
                    <i class="fas fa-bars"></i>
                </button>
                <span class="fw-bold">Ön Muhasebe</span>
                <div></div>
            </div>

            <!-- Page Header -->
            <div class="page-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h4 class="mb-1"><i class="fas fa-calculator me-2"></i>Ön Muhasebe</h4>
                        <p class="mb-0 opacity-75">Gelir ve Gider Takibi</p>
                    </div>
                    <div class="text-end d-none d-md-block">
                        <p class="mb-0 small opacity-75"><?php echo date('d F Y, l'); ?></p>
                    </div>
                </div>
            </div>

            <!-- Page Body -->
            <div class="page-body">
                <!-- Summary Cards -->
                <div class="row g-3 mb-4">
                    <div class="col-md-4">
                        <div class="card border-0 shadow-sm h-100 bg-success text-white">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="text-white-50">Toplam Gelir</h6>
                                        <h3 class="mb-0" id="totalIncome">0.00 ₺</h3>
                                    </div>
                                    <div class="fs-1 text-white-50"><i class="fas fa-arrow-up"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card border-0 shadow-sm h-100 bg-danger text-white">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="text-white-50">Toplam Gider</h6>
                                        <h3 class="mb-0" id="totalExpense">0.00 ₺</h3>
                                    </div>
                                    <div class="fs-1 text-white-50"><i class="fas fa-arrow-down"></i></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card border-0 shadow-sm h-100 bg-primary text-white">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6 class="text-white-50">Net Bakiye</h6>
                                        <h3 class="mb-0" id="netBalance">0.00 ₺</h3>
                                    </div>
                                    <div class="fs-1 text-white-50"><i class="fas fa-wallet"></i></div>
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
                                <select class="form-select" id="typeFilter">
                                    <option value="all">Tüm İşlemler</option>
                                    <option value="income">Gelirler</option>
                                    <option value="expense">Giderler</option>
                                </select>
                            </div>
                            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addEntryModal">
                                <i class="fas fa-plus me-2"></i>Yeni Kayıt Ekle
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
                        <table class="table table-hover align-middle mb-0" id="entriesTable">
                            <thead class="table-light">
                                <tr>
                                    <th>Tarih</th>
                                    <th>Tür</th>
                                    <th>Başlık</th>
                                    <th>Açıklama</th>
                                    <th class="text-end">Tutar</th>
                                    <th>Kaynak</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td colspan="7" class="text-center py-4">
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
    </div>

    <!-- Add Entry Modal -->
    <div class="modal fade" id="addEntryModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Yeni Kayıt Ekle</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="addEntryForm">
                        <div class="mb-3">
                            <label class="form-label">İşlem Türü</label>
                            <div class="btn-group w-100" role="group">
                                <input type="radio" class="btn-check" name="entryType" id="typeIncome" value="income"
                                    checked>
                                <label class="btn btn-outline-success" for="typeIncome">
                                    <i class="fas fa-arrow-up me-1"></i>Gelir
                                </label>
                                <input type="radio" class="btn-check" name="entryType" id="typeExpense" value="expense">
                                <label class="btn btn-outline-danger" for="typeExpense">
                                    <i class="fas fa-arrow-down me-1"></i>Gider
                                </label>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Başlık</label>
                            <input type="text" class="form-control" id="entryTitle" placeholder="Örn: Nakit Tahsilat"
                                required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Tutar (₺)</label>
                            <input type="number" step="0.01" class="form-control" id="entryAmount" placeholder="0.00"
                                required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Açıklama (Opsiyonel)</label>
                            <textarea class="form-control" id="entryDescription" rows="2"
                                placeholder="Not ekleyin..."></textarea>
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

    <!-- Edit Entry Modal -->
    <div class="modal fade" id="editEntryModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Kaydı Düzenle</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="editEntryForm">
                        <input type="hidden" id="editEntryId">
                        <div class="mb-3">
                            <label class="form-label">İşlem Türü</label>
                            <div class="btn-group w-100" role="group">
                                <input type="radio" class="btn-check" name="editEntryType" id="editTypeIncome"
                                    value="income">
                                <label class="btn btn-outline-success" for="editTypeIncome">
                                    <i class="fas fa-arrow-up me-1"></i>Gelir
                                </label>
                                <input type="radio" class="btn-check" name="editEntryType" id="editTypeExpense"
                                    value="expense">
                                <label class="btn btn-outline-danger" for="editTypeExpense">
                                    <i class="fas fa-arrow-down me-1"></i>Gider
                                </label>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Başlık</label>
                            <input type="text" class="form-control" id="editEntryTitle" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Tutar (₺)</label>
                            <input type="number" step="0.01" class="form-control" id="editEntryAmount" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Açıklama (Opsiyonel)</label>
                            <textarea class="form-control" id="editEntryDescription" rows="2"></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                    <button type="button" class="btn btn-primary" id="updateEntryBtn">Güncelle</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <!-- Firebase Modular SDK -->
    <script type="module">
        import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
        import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
        import { getFirestore, collection, addDoc, updateDoc, deleteDoc, doc, query, where, orderBy, onSnapshot, Timestamp, getDocs } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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
        let allEntries = [];
        let unsubscribe = null;

        onAuthStateChanged(auth, async (user) => {
            if (!user) {
                window.location.href = 'login.php';
                return;
            }

            // Get firm data
            const firm = await getFirmData(user.uid);

            if (!firm || firm.isApproved !== true) {
                window.location.href = 'index.php';
                return;
            }

            currentFirm = firm;

            // Show main layout
            document.getElementById('authCheck').classList.add('d-none');
            document.getElementById('mainLayout').style.display = 'block';

            // Load data
            loadEntries(firm.id);
        });

        async function getFirmData(uid) {
            try {
                const firmsRef = collection(db, 'firms');
                const q = query(firmsRef, where('uid', '==', uid));
                const snapshot = await getDocs(q);

                if (snapshot.empty) return null;

                return { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
            } catch (error) {
                console.error('Firma verisi alınamadı:', error);
                return null;
            }
        }

        function loadEntries(firmId) {
            const accountingRef = collection(db, 'firm_accounting');
            // Not: İlk sorgu basit tutalım, index gerekmez
            const q = query(accountingRef, where('firmId', '==', firmId));

            if (unsubscribe) unsubscribe();

            unsubscribe = onSnapshot(q, (snapshot) => {
                allEntries = [];
                snapshot.forEach(docSnap => {
                    allEntries.push({ id: docSnap.id, ...docSnap.data() });
                });
                // Client-side sıralama (index gerektirmez)
                allEntries.sort((a, b) => {
                    const dateA = a.date?.toDate ? a.date.toDate() : new Date(a.date || 0);
                    const dateB = b.date?.toDate ? b.date.toDate() : new Date(b.date || 0);
                    return dateB - dateA;
                });
                renderTable(allEntries);
                calculateTotals(allEntries);
            }, (error) => {
                console.error('Muhasebe verileri yüklenirken hata:', error);
                const tableBody = document.querySelector('#entriesTable tbody');
                tableBody.innerHTML = `
                    <tr>
                        <td colspan="7" class="text-center py-4 text-muted">
                            <i class="fas fa-exclamation-triangle fa-2x mb-2 d-block text-warning"></i>
                            Veri yüklenirken hata oluştu
                        </td>
                    </tr>
                `;
            });
        }

        function renderTable(entries) {
            const tableBody = document.querySelector('#entriesTable tbody');
            const typeFilter = document.getElementById('typeFilter').value;

            const filtered = entries.filter(e => {
                if (typeFilter === 'all') return true;
                return e.type === typeFilter;
            });

            if (filtered.length === 0) {
                tableBody.innerHTML = `
                    <tr>
                        <td colspan="7" class="text-center py-4 text-muted">
                            <i class="fas fa-inbox fa-2x mb-2 d-block"></i>
                            Kayıt bulunamadı
                        </td>
                    </tr>
                `;
                return;
            }

            tableBody.innerHTML = filtered.map(entry => {
                const date = entry.date?.toDate ? entry.date.toDate() : new Date(entry.date);
                const isIncome = entry.type === 'income';
                const typeLabel = isIncome
                    ? '<span class="badge bg-success">Gelir</span>'
                    : '<span class="badge bg-danger">Gider</span>';
                const amountClass = isIncome ? 'text-success' : 'text-danger';
                const amountPrefix = isIncome ? '+' : '-';
                const sourceLabel = entry.isAutomatic
                    ? '<span class="badge bg-info">Otomatik</span>'
                    : '<span class="badge bg-secondary">Manuel</span>';

                return `
                    <tr>
                        <td><small>${formatDate(date)}</small></td>
                        <td>${typeLabel}</td>
                        <td><strong>${entry.title || '-'}</strong></td>
                        <td><small class="text-muted">${entry.description || '-'}</small></td>
                        <td class="text-end ${amountClass} fw-bold">${amountPrefix}${formatCurrency(entry.amount)}</td>
                        <td>${sourceLabel}</td>
                        <td>
                            ${!entry.isAutomatic ? `
                                <div class="btn-group btn-group-sm">
                                    <button class="btn btn-outline-primary" onclick="editEntry('${entry.id}')">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-outline-danger" onclick="deleteEntry('${entry.id}')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            ` : ''}
                        </td>
                    </tr>
                `;
            }).join('');
        }

        function calculateTotals(entries) {
            let totalIncome = 0;
            let totalExpense = 0;

            entries.forEach(e => {
                if (e.type === 'income') {
                    totalIncome += parseFloat(e.amount) || 0;
                } else {
                    totalExpense += parseFloat(e.amount) || 0;
                }
            });

            const netBalance = totalIncome - totalExpense;

            document.getElementById('totalIncome').textContent = formatCurrency(totalIncome);
            document.getElementById('totalExpense').textContent = formatCurrency(totalExpense);
            document.getElementById('netBalance').textContent = formatCurrency(netBalance);

            // Update net balance card color
            const netCard = document.getElementById('netBalance').closest('.card');
            if (netCard) {
                netCard.classList.remove('bg-success', 'bg-danger', 'bg-primary');
                if (netBalance >= 0) {
                    netCard.classList.add('bg-primary');
                } else {
                    netCard.classList.add('bg-warning');
                }
            }
        }

        function formatCurrency(amount) {
            return new Intl.NumberFormat('tr-TR', {
                style: 'currency',
                currency: 'TRY',
                minimumFractionDigits: 2
            }).format(amount);
        }

        function formatDate(date) {
            return new Intl.DateTimeFormat('tr-TR', {
                day: '2-digit',
                month: '2-digit',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            }).format(date);
        }

        // Filter change
        document.getElementById('typeFilter').addEventListener('change', () => {
            renderTable(allEntries);
        });

        // Add Entry
        document.getElementById('saveEntryBtn').addEventListener('click', async () => {
            const type = document.querySelector('input[name="entryType"]:checked').value;
            const title = document.getElementById('entryTitle').value.trim();
            const amount = parseFloat(document.getElementById('entryAmount').value);
            const description = document.getElementById('entryDescription').value.trim();

            if (!title || isNaN(amount) || amount <= 0) {
                Swal.fire('Hata', 'Başlık ve geçerli bir tutar girin.', 'error');
                return;
            }

            try {
                const accountingRef = collection(db, 'firm_accounting');
                await addDoc(accountingRef, {
                    firmId: currentFirm.id,
                    type: type,
                    category: type === 'income' ? 'manual_income' : 'manual_expense',
                    title: title,
                    amount: amount,
                    description: description || null,
                    isAutomatic: false,
                    date: Timestamp.now(),
                    createdAt: Timestamp.now()
                });

                const modal = bootstrap.Modal.getInstance(document.getElementById('addEntryModal'));
                modal.hide();
                document.getElementById('addEntryForm').reset();
                Swal.fire('Başarılı', 'Kayıt eklendi.', 'success');
            } catch (error) {
                console.error(error);
                Swal.fire('Hata', 'Kayıt eklenemedi.', 'error');
            }
        });

        // Edit Entry
        window.editEntry = function (id) {
            const entry = allEntries.find(e => e.id === id);
            if (!entry || entry.isAutomatic) return;

            document.getElementById('editEntryId').value = id;
            document.getElementById('editEntryTitle').value = entry.title || '';
            document.getElementById('editEntryAmount').value = entry.amount;
            document.getElementById('editEntryDescription').value = entry.description || '';

            if (entry.type === 'income') {
                document.getElementById('editTypeIncome').checked = true;
            } else {
                document.getElementById('editTypeExpense').checked = true;
            }

            const modal = new bootstrap.Modal(document.getElementById('editEntryModal'));
            modal.show();
        };

        // Update Entry
        document.getElementById('updateEntryBtn').addEventListener('click', async () => {
            const id = document.getElementById('editEntryId').value;
            const type = document.querySelector('input[name="editEntryType"]:checked').value;
            const title = document.getElementById('editEntryTitle').value.trim();
            const amount = parseFloat(document.getElementById('editEntryAmount').value);
            const description = document.getElementById('editEntryDescription').value.trim();

            if (!title || isNaN(amount) || amount <= 0) {
                Swal.fire('Hata', 'Başlık ve geçerli bir tutar girin.', 'error');
                return;
            }

            try {
                const docRef = doc(db, 'firm_accounting', id);
                await updateDoc(docRef, {
                    type: type,
                    category: type === 'income' ? 'manual_income' : 'manual_expense',
                    title: title,
                    amount: amount,
                    description: description || null
                });

                const modal = bootstrap.Modal.getInstance(document.getElementById('editEntryModal'));
                modal.hide();
                Swal.fire('Başarılı', 'Kayıt güncellendi.', 'success');
            } catch (error) {
                console.error(error);
                Swal.fire('Hata', 'Kayıt güncellenemedi.', 'error');
            }
        });

        // Delete Entry
        window.deleteEntry = async function (id) {
            const entry = allEntries.find(e => e.id === id);
            if (!entry || entry.isAutomatic) return;

            const result = await Swal.fire({
                title: 'Silmek istediğinize emin misiniz?',
                text: 'Bu işlem geri alınamaz!',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Evet, Sil',
                cancelButtonText: 'İptal'
            });

            if (!result.isConfirmed) return;

            try {
                const docRef = doc(db, 'firm_accounting', id);
                await deleteDoc(docRef);
                Swal.fire('Başarılı', 'Kayıt silindi.', 'success');
            } catch (error) {
                console.error(error);
                Swal.fire('Hata', 'Kayıt silinemedi.', 'error');
            }
        };

        // Sidebar toggle (mobile)
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