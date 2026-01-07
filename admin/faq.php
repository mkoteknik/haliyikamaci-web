<?php
/**
 * Halı Yıkamacı - Bot / SSS Yönetimi
 */
require_once '../config/app.php';
$pageTitle = 'Bot / SSS Yönetimi';
require_once 'includes/header.php';
?>

<div class="page-header">
    <div class="d-flex justify-content-between align-items-center">
        <div>
            <h4 class="mb-1"><i class="fas fa-robot me-2"></i>Bot / SSS Yönetimi</h4>
            <p class="mb-0 opacity-75 small">Destek botu için soru ve cevapları düzenleyin</p>
        </div>
        <button class="btn btn-light" data-bs-toggle="modal" data-bs-target="#editFaqModal" onclick="resetForm()">
            <i class="fas fa-plus me-2"></i>Yeni Soru Ekle
        </button>
    </div>
</div>

<div class="page-body">
    <div id="loading" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Yükleniyor...</span>
        </div>
    </div>

    <div id="emptyState" class="text-center py-5 d-none">
        <div class="mb-3">
            <i class="fas fa-comments fa-3x text-muted"></i>
        </div>
        <h4>Henüz Soru Eklenmedi</h4>
        <p class="text-muted">Müşterilerin sık sorduğu soruları ve bot yanıtlarını buradan yönetebilirsiniz.</p>
    </div>

    <div class="row" id="faqList">
        <!-- Javascript will populate this -->
    </div>
</div>

<!-- Edit/Add Modal -->
<div class="modal fade" id="editFaqModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">Yeni Soru Ekle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="faqForm">
                    <input type="hidden" id="faqId">

                    <div class="mb-3">
                        <label class="form-label">Soru</label>
                        <input type="text" class="form-control" id="faqQuestion"
                            placeholder="Örn: Ödeme yöntemleri neler?" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Cevap</label>
                        <textarea class="form-control" id="faqAnswer" rows="4" placeholder="Botun vereceği cevap..."
                            required></textarea>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Anahtar Kelimeler</label>
                        <input type="text" class="form-control" id="faqKeywords"
                            placeholder="Virgülle ayırın: ödeme, kredi kartı, nakit">
                        <div class="form-text">Bot bu kelimeleri görünce bu cevabı önerir.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Kategori</label>
                        <select class="form-select" id="faqCategory">
                            <option value="general">Genel</option>
                            <option value="teslimat">Teslimat</option>
                            <option value="fiyat">Fiyat</option>
                            <option value="odeme">Ödeme</option>
                            <option value="siparis">Sipariş</option>
                            <option value="iptal">İptal/İade</option>
                        </select>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                <button type="button" class="btn btn-primary" onclick="saveFaq()">Kaydet</button>
            </div>
        </div>
    </div>
</div>

</div> <!-- Closing Main Content -->
</div> <!-- Closing Main Layout -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
    import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, collection, getDocs, addDoc, doc, updateDoc, deleteDoc, query, orderBy, where } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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
    const COLLECTION_NAME = 'faq'; // Matches support_repository.dart singular 'faq'

    let currentFaqs = [];
    let modalInstance = null;

    onAuthStateChanged(auth, async (user) => {
        if (!user) { window.location.href = 'login.php'; return; }
        document.getElementById('authCheck').classList.add('d-none');
        document.getElementById('mainLayout').style.display = 'block';
        loadFaqs();

        modalInstance = new bootstrap.Modal(document.getElementById('editFaqModal'));
    });

    window.loadFaqs = async function () {
        try {
            // Using logic from SupportRepository: where('isActive', isEqualTo: true) .orderBy('order')
            // But for admin we probably want to see inactive ones too? Flutter admin shows 'activeFaqsProvider' which fetches active ones.
            // Let's stick to active ones for now to prevent index errors if not indexed, or just list all if index allows.
            // The logic: getActiveFaqs -> orderBy('order').

            const faqRef = collection(db, COLLECTION_NAME);
            const q = query(faqRef, where('isActive', '==', true)); // Simple active check first
            const snapshot = await getDocs(q);

            currentFaqs = [];
            snapshot.forEach(doc => {
                currentFaqs.push({ id: doc.id, ...doc.data() });
            });

            // Client side sort by order if needed
            currentFaqs.sort((a, b) => (a.order || 99) - (b.order || 99));

            renderFaqs();
        } catch (error) {
            console.error("Error loading faqs:", error);
            Swal.fire('Hata', 'Veriler yüklenemedi', 'error');
        } finally {
            document.getElementById('loading').classList.add('d-none');
        }
    }

    function renderFaqs() {
        const container = document.getElementById('faqList');
        const emptyState = document.getElementById('emptyState');

        container.innerHTML = '';

        if (currentFaqs.length === 0) {
            emptyState.classList.remove('d-none');
            return;
        }

        emptyState.classList.add('d-none');

        currentFaqs.forEach(faq => {
            const keywords = Array.isArray(faq.keywords) ? faq.keywords.join(', ') : '';
            const html = `
                <div class="col-12 mb-3">
                    <div class="card shadow-sm border-0">
                        <div class="card-body">
                            <div class="d-flex justify-content-between align-items-start">
                                <div>
                                    <h6 class="fw-bold mb-1">${faq.question}</h6>
                                    <p class="mb-2 text-muted small">${faq.answer}</p>
                                    <div>
                                        ${faq.keywords && faq.keywords.length > 0
                    ? faq.keywords.map(k => `<span class="badge bg-light text-dark border me-1">${k}</span>`).join('')
                    : ''}
                                    </div>
                                </div>
                                <div class="d-flex ms-3">
                                    <button class="btn btn-sm btn-light text-primary me-2" onclick="editFaq('${faq.id}')">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-light text-danger" onclick="deleteFaq('${faq.id}')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            container.innerHTML += html;
        });
    }

    window.resetForm = function () {
        document.getElementById('faqForm').reset();
        document.getElementById('faqId').value = '';
        document.getElementById('modalTitle').textContent = 'Yeni Soru Ekle';
    }

    window.editFaq = function (id) {
        const faq = currentFaqs.find(f => f.id === id);
        if (!faq) return;

        document.getElementById('faqId').value = faq.id;
        document.getElementById('faqQuestion').value = faq.question;
        document.getElementById('faqAnswer').value = faq.answer;
        document.getElementById('faqCategory').value = faq.category || 'general';
        document.getElementById('faqKeywords').value = Array.isArray(faq.keywords) ? faq.keywords.join(', ') : '';

        document.getElementById('modalTitle').textContent = 'Soruyu Düzenle';
        modalInstance.show();
    }

    window.saveFaq = async function () {
        const id = document.getElementById('faqId').value;
        const question = document.getElementById('faqQuestion').value;
        const answer = document.getElementById('faqAnswer').value;
        const category = document.getElementById('faqCategory').value;
        const keywordsText = document.getElementById('faqKeywords').value;

        if (!question || !answer) {
            Swal.fire('Uyarı', 'Soru ve cevap alanları zorunludur.', 'warning');
            return;
        }

        const keywords = keywordsText.split(',').map(k => k.trim().toLowerCase()).filter(k => k.length > 0);

        const data = {
            question,
            answer,
            category,
            keywords,
            isActive: true, // Default active
            order: 99 // Default order
        };

        try {
            if (id) {
                await updateDoc(doc(db, COLLECTION_NAME, id), data);
            } else {
                await addDoc(collection(db, COLLECTION_NAME), data);
            }

            modalInstance.hide();
            Swal.fire('Başarılı', 'Kayıt edildi.', 'success');
            loadFaqs();
        } catch (error) {
            console.error("Error saving:", error);
            Swal.fire('Hata', 'Kaydetme sırasında bir hata oluştu.', 'error');
        }
    }

    window.deleteFaq = async function (id) {
        const result = await Swal.fire({
            title: 'Silinsin mi?',
            text: "Bu soru silinecek!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Evet, Sil',
            cancelButtonText: 'İptal',
            confirmButtonColor: '#d33'
        });

        if (result.isConfirmed) {
            try {
                await deleteDoc(doc(db, COLLECTION_NAME, id));
                Swal.fire('Silindi', 'Soru silindi.', 'success');
                loadFaqs();
            } catch (error) {
                console.error("Error deleting:", error);
                Swal.fire('Hata', 'Silme işlemi başarısız.', 'error');
            }
        }
    }
</script>
</body>

</html>