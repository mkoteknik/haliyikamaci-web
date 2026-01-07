<?php
require_once 'includes/header.php';
?>

<!-- Header.php opens .main-content, so we are inside it -->
<div class="page-header">
    <div class="d-flex justify-content-between align-items-center">
        <div>
            <h2 class="fw-bold mb-0">Demo / Vitrin Yönetimi</h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0 text-white-50">
                    <li class="breadcrumb-item"><a href="index.php" class="text-white-50">Dashboard</a></li>
                    <li class="breadcrumb-item active text-white" aria-current="page">Demo Ayarları</li>
                </ol>
            </nav>
        </div>
        <div class="form-check form-switch ps-0">
            <input class="form-check-input ms-0 me-2 float-none" type="checkbox" id="demoModeToggle"
                style="width: 3em; height: 1.5em;">
            <label class="form-check-label text-white fw-bold h5 mb-0 align-middle" for="demoModeToggle">Demo Modu
                Aktif</label>
        </div>
    </div>
</div>

<div class="page-body">
    <!-- Local Loader (for internal content) -->
    <div id="pageLoader" class="text-center py-5">
        <div class="spinner-border text-primary" role="status"></div>
        <p class="mt-2 text-muted">Ayarlar yükleniyor...</p>
    </div>

    <div id="settingsContent" class="d-none">
        <div class="row">
            <!-- Vitrin Firms -->
            <div class="col-lg-4 mb-4">
                <div class="card h-100 border-0 shadow-sm">
                    <div class="card-header bg-white py-3">
                        <h5 class="mb-0 fw-bold text-warning"><i class="fas fa-crown me-2"></i>Vitrin Firmaları</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label">Firma Ekle</label>
                            <div class="input-group">
                                <select class="form-select" id="vitrinFirmSelect">
                                    <option value="">Firma Seçin...</option>
                                </select>
                                <button class="btn btn-warning" type="button"
                                    onclick="addToList('vitrin')">Ekle</button>
                            </div>
                        </div>
                        <ul class="list-group" id="vitrinList">
                            <!-- Items will be here -->
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Featured Firms -->
            <div class="col-lg-4 mb-4">
                <div class="card h-100 border-0 shadow-sm">
                    <div class="card-header bg-white py-3">
                        <h5 class="mb-0 fw-bold text-primary"><i class="fas fa-star me-2"></i>Öne Çıkan Firmalar</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label">Firma Ekle</label>
                            <div class="input-group">
                                <select class="form-select" id="featuredFirmSelect">
                                    <option value="">Firma Seçin...</option>
                                </select>
                                <button class="btn btn-primary" type="button"
                                    onclick="addToList('featured')">Ekle</button>
                            </div>
                        </div>
                        <ul class="list-group" id="featuredList">
                            <!-- Items will be here -->
                        </ul>
                    </div>
                </div>
            </div>

            <!-- Manual Campaigns -->
            <div class="col-lg-4 mb-4">
                <div class="card h-100 border-0 shadow-sm">
                    <div class="card-header bg-white py-3">
                        <h5 class="mb-0 fw-bold text-danger"><i class="fas fa-tags me-2"></i>Manuel Kampanyalar</h5>
                    </div>
                    <div class="card-body">
                        <div class="mb-3 border p-3 rounded bg-light">
                            <label class="form-label fw-bold">Yeni Kampanya</label>
                            <select class="form-select mb-2" id="campaignFirmSelect">
                                <option value="">Firma Seçin...</option>
                            </select>
                            <input type="text" class="form-control mb-2" id="campaignTitle"
                                placeholder="Kampanya Başlığı (Örn: Bahar İndirimi)">
                            <input type="text" class="form-control mb-2" id="campaignDesc" placeholder="Açıklama">
                            <div class="input-group mb-2">
                                <span class="input-group-text">%</span>
                                <input type="number" class="form-control" id="campaignPercent" placeholder="İndirim"
                                    min="1" max="99">
                                <button class="btn btn-danger" type="button" onclick="addCampaign()">Ekle</button>
                            </div>
                        </div>
                        <ul class="list-group" id="campaignList">
                            <!-- Items will be here -->
                        </ul>
                    </div>
                </div>
            </div>
        </div>

        <!-- Save Button -->
        <div class="fixed-bottom p-3 bg-white border-top shadow-lg" style="left: 260px; z-index: 1000;">
            <div class="container-fluid d-flex justify-content-between align-items-center">
                <span class="text-muted small">Değişikliklerin sitede görünmesi için "Kaydet" butonuna basın.</span>
                <button class="btn btn-success btn-lg px-5" onclick="saveSettings()">
                    <i class="fas fa-save me-2"></i>Kaydet ve Yayınla
                </button>
            </div>
        </div>
        <div style="height: 80px;"></div> <!-- Spacer -->
    </div>
</div> <!-- Close page-body -->

<!-- Close main-content opened in header.php -->
</div>

<script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
    import { getAuth, onAuthStateChanged } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";
    import { getFirestore, doc, getDoc, setDoc, collection, getDocs, query, where } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";
    import { firebaseConfig } from './includes/firebase-config.js';

    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);
    const db = getFirestore(app, 'haliyikamacimmbldatabase');

    // State
    let allFirms = [];
    let state = {
        isActive: false,
        vitrinFirms: [], // {id, name}
        featuredFirms: [], // {id, name}
        campaigns: [] // {firmId, firmName, title, description, discountPercent}
    };

    // Auth Listener to Hide Loader
    onAuthStateChanged(auth, async (user) => {
        if (!user) {
            window.location.href = 'login.php';
            return;
        }

        // Hide Global Loader & Show Main Layout
        const authCheck = document.getElementById('authCheck');
        const mainLayout = document.getElementById('mainLayout');
        if (authCheck) authCheck.classList.add('d-none');
        if (mainLayout) mainLayout.style.display = 'block';

        // Initialize Page
        await loadFirms();
        await loadSettings();
        renderAll();

        // Hide Local Page Loader
        const pageLoader = document.getElementById('pageLoader');
        const settingsContent = document.getElementById('settingsContent');
        if (pageLoader) pageLoader.classList.add('d-none');
        if (settingsContent) settingsContent.classList.remove('d-none');
    });

    // Load available firms for dropdowns
    async function loadFirms() {
        try {
            const q = query(collection(db, 'firms'), where('isApproved', '==', true));
            const snapshot = await getDocs(q);
            allFirms = [];
            snapshot.forEach(doc => {
                allFirms.push({ id: doc.id, name: doc.data().name });
            });
            // Sort
            allFirms.sort((a, b) => a.name.localeCompare(b.name));

            // Populate Selects
            const selects = ['vitrinFirmSelect', 'featuredFirmSelect', 'campaignFirmSelect'];
            selects.forEach(id => {
                const sel = document.getElementById(id);
                // Clear existing options except first
                sel.innerHTML = '<option value="">Firma Seçin...</option>';
                allFirms.forEach(f => {
                    const opt = document.createElement('option');
                    opt.value = f.id;
                    opt.textContent = f.name;
                    sel.appendChild(opt);
                });
            });
        } catch (e) {
            console.error(e);
        }
    }

    // Load existing settings
    async function loadSettings() {
        try {
            const docRef = doc(db, 'system_settings', 'demo_content');
            const docSnap = await getDoc(docRef);
            if (docSnap.exists()) {
                const data = docSnap.data();
                state.isActive = data.isActive || false;
                state.vitrinFirms = data.vitrinFirms || [];
                state.featuredFirms = data.featuredFirms || [];
                state.campaigns = data.campaigns || [];

                document.getElementById('demoModeToggle').checked = state.isActive;
            }
        } catch (e) {
            console.error(e);
        }
    }

    // Render Lists
    function renderAll() {
        renderList('vitrinList', state.vitrinFirms, 'vitrin');
        renderList('featuredList', state.featuredFirms, 'featured');
        renderCampaigns();
    }

    function renderList(elementId, items, type) {
        const ul = document.getElementById(elementId);
        ul.innerHTML = '';
        items.forEach((item, index) => {
            // Find name if not in item (backward compat)
            let name = item.name;
            if (!name) {
                const f = allFirms.find(f => f.id === item.id);
                name = f ? f.name : 'Unknown Firm';
            }

            const li = document.createElement('li');
            li.className = 'list-group-item d-flex justify-content-between align-items-center';
            li.innerHTML = `
                <span>${name}</span>
                <button class="btn btn-sm btn-outline-danger" onclick="removeFromList('${type}', ${index})">
                    <i class="fas fa-trash"></i>
                </button>
            `;
            ul.appendChild(li);
        });
    }

    function renderCampaigns() {
        const ul = document.getElementById('campaignList');
        ul.innerHTML = '';
        state.campaigns.forEach((camp, index) => {
            const li = document.createElement('li');
            li.className = 'list-group-item';
            li.innerHTML = `
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <div class="fw-bold text-danger">%${camp.discountPercent} - ${camp.title}</div>
                        <div class="small text-muted">${camp.firmName}</div>
                    </div>
                    <button class="btn btn-sm btn-outline-danger" onclick="removeCampaign(${index})">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            `;
            ul.appendChild(li);
        });
    }

    // Actions attached to window for HTML access
    window.addToList = function (type) {
        const selectId = type === 'vitrin' ? 'vitrinFirmSelect' : 'featuredFirmSelect';
        const select = document.getElementById(selectId);
        const id = select.value;
        if (!id) return;

        const name = select.options[select.selectedIndex].text;

        // Check duplicate
        const list = type === 'vitrin' ? state.vitrinFirms : state.featuredFirms;
        if (list.find(x => x.id === id)) {
            Swal.fire('Uyarı', 'Bu firma zaten listede', 'warning');
            return;
        }

        list.push({ id, name });
        renderAll();
        select.value = '';
    };

    window.removeFromList = function (type, index) {
        const list = type === 'vitrin' ? state.vitrinFirms : state.featuredFirms;
        list.splice(index, 1);
        renderAll();
    };

    window.addCampaign = function () {
        const firmId = document.getElementById('campaignFirmSelect').value;
        if (!firmId) {
            Swal.fire('Uyarı', 'Firma seçmelisiniz', 'warning');
            return;
        }
        const firmName = document.getElementById('campaignFirmSelect').options[document.getElementById('campaignFirmSelect').selectedIndex].text;
        const title = document.getElementById('campaignTitle').value;
        const desc = document.getElementById('campaignDesc').value;
        const percent = document.getElementById('campaignPercent').value;

        if (!title || !percent) return;

        state.campaigns.push({
            firmId,
            firmName,
            title,
            description: desc,
            discountPercent: percent,
            isActive: true,
            // Add fake date for sorting
            endDate: new Date(new Date().setFullYear(new Date().getFullYear() + 1)).toISOString()
        });

        renderAll();

        // Clear form
        document.getElementById('campaignTitle').value = '';
        document.getElementById('campaignDesc').value = '';
        document.getElementById('campaignPercent').value = '';
        document.getElementById('campaignFirmSelect').value = '';
    };

    window.removeCampaign = function (index) {
        state.campaigns.splice(index, 1);
        renderAll();
    };

    window.saveSettings = async function () {
        const isActive = document.getElementById('demoModeToggle').checked;
        state.isActive = isActive;

        try {
            await setDoc(doc(db, 'system_settings', 'demo_content'), state);
            Swal.fire({
                icon: 'success',
                title: 'Kaydedildi',
                text: isActive ? 'Demo modu AKTİF hale getirildi.' : 'Demo modu KAPATILDI, gerçek veriler gösteriliyor.',
                timer: 2000
            });
        } catch (e) {
            console.error(e);
            Swal.fire('Hata', 'Kaydedilemedi: ' + e.message, 'error');
        }
    };
</script>

<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<?php require_once 'includes/footer.php'; ?>