<?php
/**
 * Halı Yıkamacı - Yasal Dokümanlar
 */
require_once '../config/app.php';
$pageTitle = 'Yasal Dokümanlar';
require_once 'includes/header.php';
?>

<div class="page-header">
    <div class="d-flex justify-content-between align-items-center">
        <h4 class="mb-0"><i class="fas fa-file-contract me-2"></i>Yasal Dokümanlar</h4>
        <button class="btn btn-light" data-bs-toggle="modal" data-bs-target="#editDocModal" onclick="resetForm()">
            <i class="fas fa-plus me-2"></i>Yeni Doküman Ekle
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
            <i class="fas fa-file-invoice fa-3x text-muted"></i>
        </div>
        <h4>Henüz Yasal Doküman Eklenmedi</h4>
        <p class="text-muted">Gizlilik politikası, KVKK ve sözleşmelerinizi buradan yönetebilirsiniz.</p>
        <button class="btn btn-primary mt-2" onclick="initializeDefaultDocs()">
            <i class="fas fa-magic me-2"></i>Varsayılanları Oluştur
        </button>
    </div>

    <div class="row" id="docsList">
        <!-- Javascript will populate this -->
    </div>
</div>

<!-- Edit/Add Modal -->
<div class="modal fade" id="editDocModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">Yeni Doküman</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="docForm">
                    <input type="hidden" id="docId">

                    <div class="alert alert-info py-2 small">
                        <i class="fas fa-info-circle me-1"></i>
                        <strong>Kullanılabilir Değişkenler:</strong><br>
                        <code>{FirmaAdi}</code>, <code>{Adres}</code>, <code>{Telefon}</code>, <code>{Tarih}</code>,
                        <code>{Tutar}</code>, <code>{PaketAdi}</code>
                        <br><span class="text-muted" style="font-size:11px;">(Bu kodları metin içine eklediğinizde
                            otomatik olarak değişecektir.)</span>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label">Doküman Tipi</label>
                            <select class="form-select" id="docType" required>
                                <option value="privacy_policy">Gizlilik Politikası</option>
                                <option value="kvkk">KVKK Aydınlatma Metni</option>
                                <option value="user_agreement">Kullanıcı Sözleşmesi</option>
                                <option value="terms_of_service">Hizmet Şartları</option>
                                <option value="distance_sales_agreement">Mesafeli Satış Sözleşmesi</option>
                                <option value="preliminary_info_form">Ön Bilgilendirme Formu</option>
                                <option value="cookie_policy">Çerez Politikası (Cookie Policy)</option>
                                <option value="usage_guide">Kullanım ve Bilgiler (KRD)</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Versiyon</label>
                            <input type="text" class="form-control" id="docVersion" placeholder="1.0" value="1.0">
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Başlık</label>
                        <input type="text" class="form-control" id="docTitle" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">İçerik (Markdown destekler)</label>
                        <textarea class="form-control" id="docContent" rows="12" required></textarea>
                    </div>

                    <div class="form-check form-switch mb-3">
                        <input class="form-check-input" type="checkbox" id="docIsActive" checked>
                        <label class="form-check-label" for="docIsActive">Aktif</label>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                <button type="button" class="btn btn-primary" onclick="saveDocument()">Kaydet</button>
            </div>
        </div>
    </div>
</div>

</div> <!-- Closing Main Content -->
</div> <!-- Closing Main Layout -->

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<script>
    $(document).ready(function () {
        $('#docContent').summernote({
            placeholder: 'İçeriği buraya yazın...',
            tabsize: 2,
            height: 400,
            toolbar: [
                ['style', ['style']],
                ['font', ['bold', 'underline', 'clear']],
                ['color', ['color']],
                ['para', ['ul', 'ol', 'paragraph']],
                ['table', ['table']],
                ['insert', ['link', 'picture']],
                ['view', ['fullscreen', 'codeview', 'help']]
            ]
        });
    });
</script>

<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js';
    import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, collection, getDocs, addDoc, doc, updateDoc, deleteDoc, query, orderBy, Timestamp } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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
    const COLLECTION_NAME = 'legalDocuments';

    let currentDocs = [];
    let modalInstance = null;

    onAuthStateChanged(auth, async (user) => {
        if (!user) { window.location.href = 'login.php'; return; }
        document.getElementById('authCheck').classList.add('d-none');
        document.getElementById('mainLayout').style.display = 'block';
        loadDocuments();

        modalInstance = new bootstrap.Modal(document.getElementById('editDocModal'));
    });

    window.loadDocuments = async function () {
        try {
            const q = query(collection(db, COLLECTION_NAME), orderBy('type'));
            const snapshot = await getDocs(q);

            currentDocs = [];
            snapshot.forEach(doc => {
                currentDocs.push({ id: doc.id, ...doc.data() });
            });

            renderDocuments();
        } catch (error) {
            console.error("Error loading docs:", error);
            Swal.fire('Hata', 'Dokümanlar yüklenemedi', 'error');
        } finally {
            document.getElementById('loading').classList.add('d-none');
        }
    }

    function renderDocuments() {
        const container = document.getElementById('docsList');
        const emptyState = document.getElementById('emptyState');

        container.innerHTML = '';

        if (currentDocs.length === 0) {
            emptyState.classList.remove('d-none');
            return;
        }

        emptyState.classList.add('d-none');

        currentDocs.forEach(doc => {
            const typeLabels = {
                'privacy_policy': 'Gizlilik Politikası',
                'kvkk': 'KVKK Aydınlatma Metni',
                'user_agreement': 'Kullanıcı Sözleşmesi',
                'terms_of_service': 'Hizmet Şartları',
                'distance_sales_agreement': 'Mesafeli Satış Sözleşmesi',
                'preliminary_info_form': 'Ön Bilgilendirme Formu',
                'cookie_policy': 'Çerez Politikası',
                'usage_guide': 'Kullanım ve Bilgiler'
            };

            const typeName = typeLabels[doc.type] || doc.type;
            const updatedDate = doc.updatedAt?.toDate ? doc.updatedAt.toDate().toLocaleDateString('tr-TR') : '-';
            const statusBadge = doc.isActive ? '<span class="badge bg-success">Aktif</span>' : '<span class="badge bg-secondary">Pasif</span>';
            const shortContent = doc.content.length > 200 ? doc.content.substring(0, 200) + '...' : doc.content;

            const html = `
                <div class="col-12 mb-4">
                    <div class="card shadow-sm border-0">
                        <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                            <div class="d-flex align-items-center">
                                <div class="bg-primary bg-opacity-10 rounded p-2 me-3">
                                    <i class="fas fa-file-alt text-primary"></i>
                                </div>
                                <div>
                                    <h5 class="mb-0">${doc.title}</h5>
                                    <small class="text-muted">${typeName} • v${doc.version}</small>
                                </div>
                            </div>
                            <div>
                                ${statusBadge}
                                <button class="btn btn-sm btn-outline-primary ms-2" onclick="editDoc('${doc.id}')">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-sm btn-outline-danger ms-1" onclick="deleteDocItem('${doc.id}')">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                        <div class="card-body">
                            <p class="text-muted small mb-2">Son Güncelleme: ${updatedDate}</p>
                            <div class="bg-light p-3 rounded" style="max-height: 150px; overflow-y: hidden;">
                                <small class="text-secondary">${shortContent.replace(/</g, "&lt;").replace(/>/g, "&gt;")}</small>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            container.innerHTML += html;
        });
    }

    window.resetForm = function () {
        document.getElementById('docForm').reset();
        $('#docContent').summernote('code', ''); // Reset summernote
        document.getElementById('docId').value = '';
        document.getElementById('modalTitle').textContent = 'Yeni Doküman Ekle';
        document.getElementById('docType').disabled = false;
    }

    window.editDoc = function (id) {
        const doc = currentDocs.find(d => d.id === id);
        if (!doc) return;

        document.getElementById('docId').value = doc.id;
        document.getElementById('docType').value = doc.type;
        document.getElementById('docTitle').value = doc.title;
        document.getElementById('docVersion').value = doc.version;
        // document.getElementById('docContent').value = doc.content; // Old text way
        $('#docContent').summernote('code', doc.content);
        document.getElementById('docIsActive').checked = doc.isActive;

        // document.getElementById('docType').disabled = true; // Optional: prevent type change
        document.getElementById('modalTitle').textContent = 'Dokümanı Düzenle';

        modalInstance.show();
    }

    window.saveDocument = async function () {
        const id = document.getElementById('docId').value;
        const typeVal = document.getElementById('docType').value;
        const titleVal = document.getElementById('docTitle').value;
        const contentVal = $('#docContent').summernote('code');
        const versionVal = document.getElementById('docVersion').value;
        const isActiveVal = document.getElementById('docIsActive').checked;

        if (!titleVal || !contentVal || contentVal === '<p><br></p>') {
            Swal.fire('Uyarı', 'Lütfen başlık ve içerik alanlarını doldurun.', 'warning');
            return;
        }

        const data = {
            type: typeVal,
            title: titleVal,
            content: contentVal,
            version: versionVal,
            isActive: isActiveVal,
            updatedAt: Timestamp.now()
        };

        try {
            if (id) {
                await updateDoc(doc(db, COLLECTION_NAME, id), data);
            } else {
                await addDoc(collection(db, COLLECTION_NAME), data);
            }

            modalInstance.hide();
            Swal.fire('Başarılı', 'Doküman kaydedildi.', 'success');
            loadDocuments();
        } catch (error) {
            console.error("Error saving:", error);
            Swal.fire('Hata', 'Kaydetme sırasında bir hata oluştu.', 'error');
        }
    }

    window.deleteDocItem = async function (id) {
        const result = await Swal.fire({
            title: 'Emin misiniz?',
            text: "Bu doküman kalıcı olarak silinecek!",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Evet, Sil',
            cancelButtonText: 'İptal'
        });

        if (result.isConfirmed) {
            try {
                await deleteDoc(doc(db, COLLECTION_NAME, id));
                Swal.fire('Silindi', 'Doküman silindi.', 'success');
                loadDocuments();
            } catch (error) {
                console.error("Error deleting:", error);
                Swal.fire('Hata', 'Silme işlemi başarısız.', 'error');
            }
        }
    }

    // Initialize Default Docs (Helpers)
    window.initializeDefaultDocs = async function () {
        const defaults = [
            { type: 'privacy_policy', title: 'Gizlilik Politikası', content: 'Standart Gizlilik Politikası metni...' },
            { type: 'kvkk', title: 'KVKK Aydınlatma Metni', content: 'Standart KVKK metni...' },
            { type: 'user_agreement', title: 'Kullanıcı Sözleşmesi', content: 'Standart Kullanıcı Sözleşmesi...' },
            { type: 'distance_sales_agreement', title: 'Mesafeli Satış Sözleşmesi', content: 'Standart Mesafeli Satış Sözleşmesi...' },
            { type: 'preliminary_info_form', title: 'Ön Bilgilendirme Formu', content: 'Standart Ön Bilgilendirme Formu...' },
            {
                type: 'usage_guide',
                title: 'Kullanım ve Bilgiler',
                content: '# KRD (Kredi) Sistemi Nedir?\n\nKRD, platformumuzda geçerli olan dijital para birimidir. Firmalar; SMS bildirimi göndermek, kampanya oluşturmak ve vitrin özelliklerini kullanmak için KRD bakiyelerini kullanırlar.\n\n### KRD Nerelerde Kullanılır?\n\n1. **Sipariş Bildirimleri (SMS):**\n   Müşterilerinize sipariş alındı, yıkandı, teslim edildi gibi durum bildirimleri gönderirken her işlem için belirlenen miktarda KRD bakiyenizden düşülür.\n\n2. **Kampanya Oluşturma:**\n   Bölgenizdeki potansiyel müşterilere ulaşmak için oluşturacağınız kampanyalar KRD ile ücretlendirilir. Etkileşim başına veya kampanya başına KRD harcanır.\n\n3. **Vitrin Paketleri:**\n   Firmanızı aramalarda üst sıralara taşımak ve "Öne Çıkanlar" listesine girmek için Vitrin Paketlerini KRD kullanarak satın alabilirsiniz.\n\n### Nasıl KRD Yüklenir?\n\nFirma panelinizdeki **"KRD Paketleri"** menüsünden ihtiyacınıza uygun paketi seçerek kredi kartınızla güvenli bir şekilde anında yükleme yapabilirsiniz. Yüklenen KRD\'lerin kullanım süresi yoktur, dilediğiniz zaman kullanabilirsiniz.'
            }
        ];

        try {
            for (const d of defaults) {
                await addDoc(collection(db, COLLECTION_NAME), {
                    ...d,
                    version: '1.0',
                    isActive: true,
                    updatedAt: Timestamp.now()
                });
            }
            loadDocuments();
        } catch (e) {
            console.error(e);
        }
    }
</script>
</body>

</html>