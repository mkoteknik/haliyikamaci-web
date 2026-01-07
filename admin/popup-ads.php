<?php
require_once 'includes/header.php';
?>

<div class="page-header">
    <div class="d-flex justify-content-between align-items-center">
        <div>
            <h2 class="fw-bold mb-0">Popup Reklam Yönetimi</h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0 text-white-50">
                    <li class="breadcrumb-item"><a href="index.php" class="text-white-50">Dashboard</a></li>
                    <li class="breadcrumb-item active text-white" aria-current="page">Popup Reklamlar</li>
                </ol>
            </nav>
        </div>
        <button class="btn btn-primary" onclick="openModal()">
            <i class="fas fa-plus me-2"></i>Yeni Reklam Ekle
        </button>
    </div>
</div>

<div class="page-body">
    <div class="row">
        <div class="col-12">
            <div class="card border-0 shadow-sm">
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="bg-light">
                                <tr>
                                    <th style="width: 100px;">Görsel</th>
                                    <th>Başlık</th>
                                    <th>Hedef Kitle</th>
                                    <th>Limitler (G/T)</th>
                                    <th>Durum</th>
                                    <th class="text-end">İşlemler</th>
                                </tr>
                            </thead>
                            <tbody id="adsTableBody">
                                <tr>
                                    <td colspan="6" class="text-center py-4">
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
</div>

<!-- Modal -->
<div class="modal fade" id="adModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">Reklam Ekle/Düzenle</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form id="adForm">
                    <input type="hidden" id="adId">

                    <div class="row g-3">
                        <!-- Görsel Yükleme -->
                        <div class="col-12">
                            <label class="form-label">Reklam Görseli</label>
                            <div class="d-flex align-items-center gap-3">
                                <div id="imagePreview"
                                    style="width: 100px; height: 100px; border: 1px dashed #ccc; border-radius: 8px; background-size: cover; background-position: center; display: flex; align-items: center; justify-content: center; color: #aaa;">
                                    <i class="fas fa-image fa-2x"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <input type="file" class="form-control" id="imageInput" accept="image/*">
                                    <input type="hidden" id="imageUrl">
                                    <div class="form-text">JPG, PNG veya WebP. Önerilen: 800x800px kare veya dikey.
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-8">
                            <label class="form-label">Reklam Başlığı (Panel için)</label>
                            <input type="text" class="form-control" id="title" required
                                placeholder="Örn: Yılbaşı İndirimi">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Hedef Kitle</label>
                            <select class="form-select" id="targetAudience">
                                <option value="all">Herkes</option>
                                <option value="firm">Sadece Firmalar</option>
                                <option value="customer">Sadece Müşteriler</option>
                            </select>
                        </div>

                        <div class="col-12">
                            <div class="card bg-light border-0">
                                <div class="card-body">
                                    <h6 class="fw-bold mb-3"><i class="fas fa-chart-line me-2"></i>Gösterim Limitleri
                                    </h6>
                                    <div class="row g-3">
                                        <div class="col-md-4">
                                            <label class="form-label">Kişi Başı Günlük</label>
                                            <input type="number" class="form-control" id="perUserDailyLimit" value="0"
                                                min="0">
                                            <div class="form-text small">0 = Limitsiz. Örn: 3 girilirse 1 kişi günde max
                                                3 kez görür.</div>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label">Global Günlük Limit</label>
                                            <input type="number" class="form-control" id="globalDailyLimit" value="0"
                                                min="0">
                                            <div class="form-text small">Tüm sistemde günlük toplam gösterim hakkı.
                                            </div>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label">Global Toplam Limit</label>
                                            <input type="number" class="form-control" id="globalTotalLimit" value="0"
                                                min="0">
                                            <div class="form-text small">Ömür boyu toplam gösterim hakkı.</div>
                                        </div>
                                    </div>
                                    <div class="alert alert-info mt-3 mb-0 py-2 small" id="limitInfo">
                                        <i class="fas fa-info-circle me-1"></i>0 girilen alanlar limitsiz kabul edilir.
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="col-12">
                            <label class="form-label">Yönlendirilecek Link (Opsiyonel)</label>
                            <input type="url" class="form-control" id="actionUrl" placeholder="https://...">
                        </div>

                        <div class="col-12">
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" id="isActive" checked>
                                <label class="form-check-label" for="isActive">Reklam Aktif</label>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">İptal</button>
                <button type="button" class="btn btn-primary" onclick="saveAd()">Kaydet</button>
            </div>
        </div>
    </div>
</div>

<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js';
    import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js';
    import { getFirestore, collection, addDoc, updateDoc, deleteDoc, doc, onSnapshot, query, orderBy, serverTimestamp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

    // Firebase Config (Footer settings'den alındı)
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
    let modalInstance = null;

    onAuthStateChanged(auth, (user) => {
        if (!user) {
            window.location.href = 'login.php';
        } else {
            // Loader gizle
            const authCheck = document.getElementById('authCheck');
            const mainLayout = document.getElementById('mainLayout');
            if (authCheck) authCheck.classList.add('d-none');
            if (mainLayout) mainLayout.style.display = 'block';

            initPage();
        }
    });

    function initPage() {
        modalInstance = new bootstrap.Modal(document.getElementById('adModal'));
        loadAds();
    }

    // --- Table & Data ---
    function loadAds() {
        const q = query(collection(db, "popup_ads"), orderBy("createdAt", "desc"));
        onSnapshot(q, (snapshot) => {
            const tbody = document.getElementById("adsTableBody");

            if (snapshot.empty) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center py-4 text-muted">Henüz reklam eklenmemiş.</td></tr>';
                return;
            }

            let html = "";
            snapshot.forEach((docSnap) => {
                const data = docSnap.data();
                const id = docSnap.id;

                // Limits text
                let limitsText = [];
                if (data.perUserDailyLimit > 0) limitsText.push(`Kişi: ${data.perUserDailyLimit}/Gün`);
                if (data.globalDailyLimit > 0) {
                    const today = data.currentViewsToday || 0;
                    limitsText.push(`Global: ${today}/${data.globalDailyLimit} (Bugün)`);
                }
                if (data.globalTotalLimit > 0) {
                    const total = data.currentViewsTotal || 0;
                    limitsText.push(`Toplam: ${total}/${data.globalTotalLimit}`);
                }
                if (limitsText.length === 0) limitsText.push("Limitsiz");

                // Target
                const targetMap = { "all": "Herkes", "firm": "Firmalar", "customer": "Müşteriler" };

                // Image
                const imgThumb = data.imageUrl
                    ? `<img src="${data.imageUrl}" class="rounded" style="width: 50px; height: 50px; object-fit: cover;">`
                    : '<i class="fas fa-image text-muted"></i>';

                html += `
                    <tr>
                        <td>${imgThumb}</td>
                        <td class="fw-bold">${data.title}</td>
                        <td><span class="badge bg-secondary">${targetMap[data.targetAudience] || data.targetAudience}</span></td>
                        <td><small class="text-muted d-block" style="line-height:1.2">${limitsText.join('<br>')}</small></td>
                        <td>
                            <div class="form-check form-switch">
                                <input class="form-check-input" type="checkbox" ${data.isActive ? 'checked' : ''} 
                                    onchange="toggleActive('${id}', this.checked)">
                            </div>
                        </td>
                        <td class="text-end">
                            <button class="btn btn-sm btn-outline-primary me-1" onclick='editAd(${JSON.stringify({ id, ...data })})'>
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-danger" onclick="deleteAd('${id}')">
                                <i class="fas fa-trash"></i>
                            </button>
                        </td>
                    </tr>
                `;
            });
            tbody.innerHTML = html;
        });
    }

    // --- Actions Exposed to Window ---
    window.openModal = function () {
        document.getElementById('adForm').reset();
        document.getElementById('adId').value = '';
        document.getElementById('modalTitle').innerText = 'Yeni Reklam Ekle';
        document.getElementById('imageUrl').value = '';
        document.getElementById('imagePreview').innerHTML = '<i class="fas fa-image fa-2x"></i>';
        document.getElementById('imagePreview').style.backgroundImage = 'none';
        modalInstance.show();
    }

    window.editAd = function (data) {
        document.getElementById('adId').value = data.id;
        document.getElementById('modalTitle').innerText = 'Reklam Düzenle';
        document.getElementById('title').value = data.title;
        document.getElementById('targetAudience').value = data.targetAudience;
        document.getElementById('perUserDailyLimit').value = data.perUserDailyLimit || 0;
        document.getElementById('globalDailyLimit').value = data.globalDailyLimit || 0;
        document.getElementById('globalTotalLimit').value = data.globalTotalLimit || 0;
        document.getElementById('actionUrl').value = data.actionUrl || '';
        document.getElementById('isActive').checked = data.isActive;

        document.getElementById('imageUrl').value = data.imageUrl || '';
        if (data.imageUrl) {
            document.getElementById('imagePreview').innerHTML = '';
            document.getElementById('imagePreview').style.backgroundImage = `url('${data.imageUrl}')`;
        } else {
            document.getElementById('imagePreview').innerHTML = '<i class="fas fa-image fa-2x"></i>';
            document.getElementById('imagePreview').style.backgroundImage = 'none';
        }

        modalInstance.show();
    }

    // --- File Upload Logic ---
    document.getElementById('imageInput').addEventListener('change', async function (e) {
        const file = e.target.files[0];
        if (!file) return;

        const formData = new FormData();
        formData.append('image', file);

        const previewDiv = document.getElementById('imagePreview');
        previewDiv.innerHTML = '<div class="spinner-border spinner-border-sm text-secondary"></div>';

        try {
            const token = await auth.currentUser.getIdToken();
            const res = await fetch('../api/upload-popup-image.php', {
                method: 'POST',
                headers: {
                    'Authorization': 'Bearer ' + token
                },
                body: formData
            });
            const json = await res.json();

            if (json.success) {
                document.getElementById('imageUrl').value = json.url;
                previewDiv.innerHTML = '';
                previewDiv.style.backgroundImage = `url('${json.url}')`;
            } else {
                alert('Hata: ' + json.message);
                previewDiv.innerHTML = '<i class="fas fa-exclamation-circle text-danger"></i>';
            }
        } catch (err) {
            console.error(err);
            alert('Yükleme hatası oluştu.');
            previewDiv.innerHTML = '<i class="fas fa-exclamation-circle text-danger"></i>';
        }
    });

    window.saveAd = async function () {
        const id = document.getElementById('adId').value;
        const title = document.getElementById('title').value;
        const imageUrl = document.getElementById('imageUrl').value;
        const targetAudience = document.getElementById('targetAudience').value;
        const perUserDailyLimit = parseInt(document.getElementById('perUserDailyLimit').value) || 0;
        const globalDailyLimit = parseInt(document.getElementById('globalDailyLimit').value) || 0;
        const globalTotalLimit = parseInt(document.getElementById('globalTotalLimit').value) || 0;
        const actionUrl = document.getElementById('actionUrl').value;
        const isActive = document.getElementById('isActive').checked;

        if (!title) {
            Swal.fire('Hata', 'Başlık zorunludur.', 'warning');
            return;
        }

        if (!imageUrl) {
            Swal.fire('Hata', 'Lütfen bir reklam görseli yükleyin.', 'warning');
            return;
        }

        const data = {
            title,
            imageUrl,
            targetAudience,
            perUserDailyLimit,
            globalDailyLimit,
            globalTotalLimit,
            actionUrl,
            isActive,
            updatedAt: serverTimestamp()
        };

        const btn = document.querySelector('button[onclick="saveAd()"]');
        btn.disabled = true;
        btn.innerHTML = 'Kaydediliyor...';

        try {
            if (id) {
                await updateDoc(doc(db, "popup_ads", id), data);
            } else {
                await addDoc(collection(db, "popup_ads"), {
                    ...data,
                    createdAt: serverTimestamp(),
                    currentViewsToday: 0,
                    currentViewsTotal: 0,
                    lastViewDate: new Date().toISOString().split('T')[0] // YYYY-MM-DD
                });
            }

            modalInstance.hide();
            Swal.fire({ icon: 'success', title: 'Kaydedildi', timer: 1500, showConfirmButton: false });
        } catch (e) {
            console.error(e);
            Swal.fire('Hata', 'Kaydetme başarısız: ' + e.message, 'error');
        } finally {
            btn.disabled = false;
            btn.innerHTML = 'Kaydet';
        }
    }

    window.deleteAd = async function (id) {
        const confirm = await Swal.fire({
            title: 'Emin misiniz?',
            text: "Bu reklam silinecek.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Sil',
            cancelButtonText: 'İptal'
        });

        if (confirm.isConfirmed) {
            try {
                await deleteDoc(doc(db, "popup_ads", id));
                Swal.fire('Silindi', '', 'success');
            } catch (e) {
                Swal.fire('Hata', e.message, 'error');
            }
        }
    }

    window.toggleActive = async function (id, newState) {
        try {
            await updateDoc(doc(db, "popup_ads", id), { isActive: newState });
            const toast = Swal.mixin({
                toast: true, position: 'top-end', showConfirmButton: false, timer: 1500
            });
            toast.fire({ icon: 'success', title: 'Durum güncellendi' });
        } catch (e) {
            console.error(e);
            Swal.fire('Hata', 'Güncelleme başarısız', 'error');
            // Revert checkbox state
            loadAds(); // Reload to reset table
        }
    }
</script>

<!-- Close #mainLayout -->
</div>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>