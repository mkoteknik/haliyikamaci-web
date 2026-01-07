<?php
/**
 * Halı Yıkamacı - Küfür Filtresi Ayarları
 */
require_once '../config/app.php';
$pageTitle = 'Küfür Filtresi';
require_once 'includes/header.php';
?>

<div class="page-header">
    <h4 class="mb-0"><i class="fas fa-shield-alt me-2"></i>Küfür/Argo Filtresi</h4>
</div>

<div class="page-body">
    <div class="row justify-content-center">
        <div class="col-md-10">
            <div class="card shadow-sm border-0">
                <div class="card-body p-4">

                    <div class="d-flex align-items-center mb-4">
                        <div class="bg-danger bg-opacity-10 rounded p-3 me-3">
                            <i class="fas fa-ban fa-2x text-danger"></i>
                        </div>
                        <div>
                            <h5 class="mb-1">Yasaklı Kelime Listesi</h5>
                            <p class="text-muted mb-0 small">Uygulama genelinde engellenecek kelimeleri buradan yönetebilirsiniz.</p>
                        </div>
                    </div>

                    <!-- Add New Word Section -->
                    <div class="card bg-light border-0 mb-4">
                        <div class="card-body">
                            <form id="addWordForm" class="row g-2 align-items-center">
                                <div class="col-auto flex-grow-1">
                                    <div class="input-group">
                                        <span class="input-group-text bg-white border-end-0"><i class="fas fa-plus"></i></span>
                                        <input type="text" class="form-control border-start-0 ps-0" id="newWordInput" 
                                            placeholder="Yasaklanacak kelimeyi yazın..." required>
                                    </div>
                                </div>
                                <div class="col-auto">
                                    <button type="submit" class="btn btn-danger px-4" id="addBtn">
                                        <i class="fas fa-save me-2"></i>Ekle
                                    </button>
                                </div>
                            </form>
                            <div class="form-text mt-2 ms-1">
                                <i class="fas fa-info-circle me-1"></i>
                                Kelimeler tüm formlarda (yorum, profil vb.) otomatik olarak engellenecektir.
                            </div>
                        </div>
                    </div>

                    <hr class="my-4">

                    <!-- Word List -->
                    <h6 class="mb-3 text-uppercase text-muted small fw-bold ls-1">Kayıtlı Kelimeler (<span id="wordCount">0</span>)</h6>
                    
                    <div id="loading" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status"></div>
                        <p class="mt-2 text-muted">Liste yükleniyor...</p>
                    </div>
                    
                    <div id="wordListContainer" class="d-flex flex-wrap gap-2" style="display: none !important;">
                        <!-- Words will be injected here via JS -->
                    </div>

                    <div id="emptyState" class="text-center py-5" style="display: none;">
                        <i class="fas fa-check-circle fa-3x text-success mb-3 opacity-50"></i>
                        <h5>Liste Temiz</h5>
                        <p class="text-muted">Henüz hiç yasaklı kelime eklenmemiş.</p>
                    </div>

                </div>
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
    import { getFirestore, doc, getDoc, setDoc, updateDoc, arrayUnion, arrayRemove } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

    // Firebase Config (Same as other pages)
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

    const SETTINGS_DOC_REF = doc(db, 'system_settings', 'config');

    let blockedWords = [];

    // Auth & Init
    onAuthStateChanged(auth, async (user) => {
        if (!user) { window.location.href = 'login.php'; return; }
        document.getElementById('authCheck').classList.add('d-none');
        document.getElementById('mainLayout').style.display = 'block';
        loadBlockedWords();
    });

    async function loadBlockedWords() {
        const loadingEl = document.getElementById('loading');
        const listContainer = document.getElementById('wordListContainer');
        const emptyState = document.getElementById('emptyState');
        const countSpan = document.getElementById('wordCount');

        try {
            const docSnap = await getDoc(SETTINGS_DOC_REF);
            
            if (docSnap.exists() && docSnap.data().blockedWords) {
                blockedWords = docSnap.data().blockedWords || [];
                // Sort alphabetically
                blockedWords.sort((a, b) => a.localeCompare(b, 'tr'));
            } else {
                blockedWords = [];
            }

            renderWords();

        } catch (error) {
            console.error("Error loading words:", error);
            Swal.fire('Hata', 'Liste yüklenirken sorun oluştu.', 'error');
        } finally {
            loadingEl.style.setProperty('display', 'none', 'important');
        }
    }

    function renderWords() {
        const listContainer = document.getElementById('wordListContainer');
        const emptyState = document.getElementById('emptyState');
        const countSpan = document.getElementById('wordCount');

        listContainer.innerHTML = '';
        countSpan.textContent = blockedWords.length;

        if (blockedWords.length === 0) {
            listContainer.style.setProperty('display', 'none', 'important');
            emptyState.style.display = 'block';
            return;
        }

        emptyState.style.display = 'none';
        listContainer.style.display = 'flex';

        blockedWords.forEach(word => {
            const badge = document.createElement('div');
            badge.className = 'badge bg-white border text-dark p-2 d-flex align-items-center shadow-sm';
            badge.style.fontSize = '14px';
            badge.innerHTML = `
                <span class="me-2">${escapeHtml(word)}</span>
                <span class="cursor-pointer text-danger hover-opacity" onclick="removeWord('${escapeHtml(word)}')" title="Sil">
                    <i class="fas fa-times-circle"></i>
                </span>
            `;
            // Attach event listener specifically to the delete icon wrapper
            const deleteIcon = badge.querySelector('.cursor-pointer');
            deleteIcon.addEventListener('click', () => deleteWord(word));
            
            listContainer.appendChild(badge);
        });
    }

    // Add Word
    document.getElementById('addWordForm').addEventListener('submit', async (e) => {
        e.preventDefault();
        const input = document.getElementById('newWordInput');
        const word = input.value.trim().toLowerCase(); // Always store lowercase for easier comparison
        const btn = document.getElementById('addBtn');

        if (!word) return;

        if (blockedWords.includes(word)) {
            Swal.fire('Uyarı', 'Bu kelime zaten listede var.', 'warning');
            input.value = '';
            return;
        }

        const originalText = btn.innerHTML;
        btn.disabled = true;
        btn.innerHTML = '<div class="spinner-border spinner-border-sm"></div>';

        try {
            // If document doesn't exist, set it first (though it should exist from previous steps)
            await setDoc(SETTINGS_DOC_REF, { blockedWords: arrayUnion(word) }, { merge: true });
            
            blockedWords.push(word);
            blockedWords.sort((a, b) => a.localeCompare(b, 'tr'));
            renderWords();
            
            input.value = '';
            const Toast = Swal.mixin({
                toast: true, position: 'top-end', showConfirmButton: false, timer: 1500,
                timerProgressBar: true
            });
            Toast.fire({ icon: 'success', title: 'Eklendi' });

        } catch (error) {
            console.error("Add error:", error);
            Swal.fire('Hata', 'Kayıt sırasında hata: ' + error.message, 'error');
        } finally {
            btn.disabled = false;
            btn.innerHTML = originalText;
        }
    });

    // Delete Word
    window.deleteWord = async (word) => {
        const result = await Swal.fire({
            title: 'Emin misiniz?',
            text: `"${word}" kelimesi filtre listesinden kaldırılacak.`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Evet, Sil',
            cancelButtonText: 'İptal'
        });

        if (result.isConfirmed) {
            try {
                await updateDoc(SETTINGS_DOC_REF, {
                    blockedWords: arrayRemove(word)
                });

                blockedWords = blockedWords.filter(w => w !== word);
                renderWords();

                const Toast = Swal.mixin({
                    toast: true, position: 'top-end', showConfirmButton: false, timer: 1500
                });
                Toast.fire({ icon: 'success', title: 'Silindi' });

            } catch (error) {
                console.error("Delete error:", error);
                Swal.fire('Hata', 'Silme işlemi başarısız: ' + error.message, 'error');
            }
        }
    };

    function escapeHtml(text) {
        if (!text) return text;
        return text
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&#039;");
    }

    // Styles for hover effect
    const style = document.createElement('style');
    style.innerHTML = `
        .hover-opacity:hover { opacity: 0.7; }
        .cursor-pointer { cursor: pointer; }
    `;
    document.head.appendChild(style);

</script>
