<?php
require_once 'includes/header.php';
?>

<div class="main-content">
    <div class="page-header">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h2 class="fw-bold mb-0">Slider Ayarları</h2>
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0 text-white-50">
                        <li class="breadcrumb-item"><a href="index.php" class="text-white-50">Dashboard</a></li>
                        <li class="breadcrumb-item active text-white" aria-current="page">Slider Ayarları</li>
                    </ol>
                </nav>
            </div>
        </div>
    </div>

    <div class="page-body">
        <div class="row">
            <!-- Add New Slide -->
            <div class="col-md-4 mb-4">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-header bg-white py-3">
                        <h5 class="mb-0 fw-bold">Yeni Görsel Ekle</h5>
                    </div>
                    <div class="card-body">
                        <form id="addSlideForm">
                            <div class="mb-3">
                                <label class="form-label">Görsel Seçin</label>
                                <input type="file" class="form-control" id="slideImage" accept="image/*" multiple
                                    required>
                                <div class="form-text">Önerilen boyut: 800x800px (Kare format daha iyi durur)</div>
                            </div>
                            <div id="uploadProgress" class="progress mb-3 d-none">
                                <div class="progress-bar progress-bar-striped progress-bar-animated" role="progressbar"
                                    style="width: 0%"></div>
                            </div>
                            <button type="submit" class="btn btn-primary w-100" id="uploadBtn">
                                <i class="fas fa-cloud-upload-alt me-2"></i>Yükle ve Ekle
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Current Slides -->
            <div class="col-md-8 mb-4">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-header bg-white py-3 d-flex justify-content-between align-items-center">
                        <h5 class="mb-0 fw-bold">Mevcut Görseller</h5>
                        <button class="btn btn-sm btn-outline-primary" onclick="loadSlides()">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                    </div>
                    <div class="card-body">
                        <div id="slidesList" class="row g-3">
                            <div class="col-12 text-center py-5">
                                <div class="spinner-border text-primary" role="status"></div>
                                <p class="mt-2 text-muted">Yükleniyor...</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js';
    import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js';
    import {
        getFirestore, doc, getDoc, updateDoc, arrayUnion, arrayRemove, setDoc
    } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";
    import {
        getStorage, ref, uploadBytes, getDownloadURL, deleteObject
    } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-storage.js";

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
    const db = getFirestore(app, 'haliyikamacimmbldatabase'); // Specify database name if needed, assuming default or matched
    const storage = getStorage(app);

    onAuthStateChanged(auth, async (user) => {
        if (!user) {
            window.location.href = 'login.php';
            return;
        }

        // Hide loader, show content
        const authCheck = document.getElementById('authCheck');
        const mainLayout = document.getElementById('mainLayout');

        if (authCheck) authCheck.classList.add('d-none');
        if (mainLayout) mainLayout.style.display = 'block';

        loadSlides();
    });

    // Load Slides
    window.loadSlides = async function () {
        const container = document.getElementById('slidesList');
        container.innerHTML = `
            <div class="col-12 text-center py-5">
                <div class="spinner-border text-primary" role="status"></div>
                <p class="mt-2 text-muted">Yükleniyor...</p>
            </div>`;

        try {
            const docRef = doc(db, 'settings', 'hero_slider');
            const docSnap = await getDoc(docRef);

            if (!docSnap.exists() || !docSnap.data().images || docSnap.data().images.length === 0) {
                container.innerHTML = `
                    <div class="col-12 text-center py-5">
                        <i class="fas fa-images fa-3x text-muted mb-3"></i>
                        <p class="text-muted">Henüz görsel yüklenmemiş.</p>
                        <small>Site şu an varsayılan görselleri kullanıyor.</small>
                    </div>`;
                return;
            }

            const images = docSnap.data().images;
            let html = '';

            images.forEach((url, index) => {
                // Handle Local vs Remote URLs
                // Admin is in /admin folder, so local assets need ../ prefix
                let displayUrl = url;
                if (!url.startsWith('http') && !url.startsWith('data:')) {
                    displayUrl = '../' + url;
                }

                html += `
                <div class="col-md-4 col-sm-6">
                    <div class="card h-100 border">
                        <div class="position-relative" style="height: 150px; background: #eee;">
                            <img src="${displayUrl}" class="w-100 h-100" style="object-fit: cover;">
                        </div>
                        <div class="card-body p-2 text-center">
                            <button class="btn btn-danger btn-sm w-100" onclick="deleteSlide('${url}')">
                                <i class="fas fa-trash-alt me-1"></i>Sil
                            </button>
                        </div>
                    </div>
                </div>`;
            });

            container.innerHTML = html;

        } catch (error) {
            console.error(error);
            container.innerHTML = '<div class="alert alert-danger">Veriler yüklenemedi.</div>';
        }
    };

    // Image Processing Helper (Optimized)
    function processImage(file) {
        return new Promise((resolve, reject) => {
            const MAX_WIDTH = 800;
            const MAX_HEIGHT = 800;

            const reader = new FileReader();
            reader.readAsDataURL(file);
            reader.onload = (event) => {
                const img = new Image();
                img.src = event.target.result;
                img.onload = () => {
                    const canvas = document.createElement('canvas');
                    let width = img.width;
                    let height = img.height;

                    // Logic for Center Crop (Square)
                    const minDim = Math.min(width, height);
                    const sx = (width - minDim) / 2;
                    const sy = (height - minDim) / 2;

                    canvas.width = MAX_WIDTH;
                    canvas.height = MAX_HEIGHT;

                    const ctx = canvas.getContext('2d');
                    ctx.drawImage(img, sx, sy, minDim, minDim, 0, 0, MAX_WIDTH, MAX_HEIGHT);

                    canvas.toBlob((blob) => {
                        if (blob) {
                            resolve(blob);
                        } else {
                            reject(new Error('Conversion failed'));
                        }
                    }, 'image/webp', 0.85);
                };
            };
            reader.onerror = (err) => reject(new Error('File read failed'));
        });
    }

    // Upload Slide (Local Storage - Multiple)
    document.getElementById('addSlideForm').addEventListener('submit', async (e) => {
        e.preventDefault();

        const fileInput = document.getElementById('slideImage');
        const files = fileInput.files;
        if (!files || files.length === 0) return;

        const btn = document.getElementById('uploadBtn');
        const progress = document.getElementById('uploadProgress');
        const progressBar = progress.querySelector('.progress-bar');

        const originalBtnText = btn.innerHTML;
        btn.disabled = true;

        progress.classList.remove('d-none');
        progressBar.style.width = '0%';

        const uploadedUrls = [];
        let successCount = 0;
        let failCount = 0;

        try {
            for (let i = 0; i < files.length; i++) {
                const file = files[i];
                btn.innerHTML = `<span class="spinner-border spinner-border-sm me-2"></span>İşleniyor (${i + 1}/${files.length})...`;

                // Update Progress (Start of file)
                const step = 100 / files.length;
                progressBar.style.width = (i * step) + '%';

                try {
                    // 1. Process Image
                    const webpBlob = await processImage(file);

                    // 2. Upload to Local Server
                    const randomStr = Math.random().toString(36).substring(2, 8);
                    const filename = 'haliyikamacibul-' + randomStr + '.webp';


                    const formData = new FormData();
                    formData.append('file', webpBlob, filename);

                    const token = await auth.currentUser.getIdToken();

                    const uploadResponse = await fetch('api/upload-slider.php', {
                        method: 'POST',
                        headers: {
                            'Authorization': 'Bearer ' + token
                        },
                        body: formData
                    });

                    if (!uploadResponse.ok) throw new Error('Sunucu hatası');
                    const result = await uploadResponse.json();

                    if (!result.success) throw new Error(result.error);

                    uploadedUrls.push(result.url);
                    successCount++;

                } catch (err) {
                    console.error(`File ${i} failed:`, err);
                    failCount++;
                }
            }

            progressBar.style.width = '100%';

            // 3. Add to Firestore (Batch)
            if (uploadedUrls.length > 0) {
                const docRef = doc(db, 'settings', 'hero_slider');
                const docSnap = await getDoc(docRef);

                if (!docSnap.exists()) {
                    await setDoc(docRef, { images: uploadedUrls });
                } else {
                    await updateDoc(docRef, {
                        images: arrayUnion(...uploadedUrls)
                    });
                }
            }

            // Result Message
            if (successCount > 0) {
                Swal.fire({
                    icon: failCount > 0 ? 'warning' : 'success',
                    title: 'İşlem Tamamlandı',
                    text: `${successCount} görsel yüklendi.${failCount > 0 ? ` (${failCount} hata)` : ''}`,
                    timer: 2000,
                    showConfirmButton: false
                });
                fileInput.value = '';
                loadSlides();
            } else {
                Swal.fire('Hata', 'Hiçbir görsel yüklenemedi.', 'error');
            }

        } catch (error) {
            console.error(error);
            Swal.fire('Hata', 'Genel bir hata oluştu: ' + error.message, 'error');
        } finally {
            btn.innerHTML = originalBtnText;
            btn.disabled = false;
            progress.classList.add('d-none');
        }
    });

    // Delete Slide (Local & DB)
    window.deleteSlide = async function (url) {
        const result = await Swal.fire({
            title: 'Emin misiniz?',
            text: "Bu görsel sunucudan silinecek.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: 'Evet, Sil',
            cancelButtonText: 'İptal',
            confirmButtonColor: '#d33'
        });

        if (!result.isConfirmed) return;

        try {
            // 1. Remove from DB first
            const docRef = doc(db, 'settings', 'hero_slider');
            await updateDoc(docRef, {
                images: arrayRemove(url)
            });

            // 2. Delete from Local Server (if it's a local file)
            if (!url.startsWith('http')) {
                await fetch('api/delete-slider.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ path: url })
                });
            }

            Swal.fire('Silindi', 'Görsel kaldırıldı.', 'success');
            loadSlides();

        } catch (error) {
            console.error(error);
            Swal.fire('Hata', 'Silme başarısız.', 'error');
        }
    }
</script>

<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<?php require_once 'includes/footer.php'; ?>