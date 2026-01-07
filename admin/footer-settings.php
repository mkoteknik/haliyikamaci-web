<?php
require_once 'includes/header.php';
?>


<div class="page-header">
    <div class="d-flex justify-content-between align-items-center">
        <div>
            <h2 class="fw-bold mb-0">Site & İletişim Ayarları</h2>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0 text-white-50">
                    <li class="breadcrumb-item"><a href="index.php" class="text-white-50">Dashboard</a></li>
                    <li class="breadcrumb-item active text-white" aria-current="page">Site & İletişim Ayarları</li>
                </ol>
            </nav>
        </div>
        <button class="btn btn-warning" onclick="saveSettings()">
            <i class="fas fa-save me-2"></i>Kaydet
        </button>
    </div>
</div>

<div class="page-body">
    <div class="row">
        <div class="col-12">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-white">
                    <ul class="nav nav-tabs card-header-tabs" role="tablist">
                        <li class="nav-item">
                            <a class="nav-link active" data-bs-toggle="tab" href="#tabGeneral">
                                <i class="fas fa-cog me-2"></i>Genel & Sosyal
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-bs-toggle="tab" href="#tabQuickLinks">
                                <i class="fas fa-link me-2"></i>Hızlı Linkler
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-bs-toggle="tab" href="#tabLegal">
                                <i class="fas fa-file-contract me-2"></i>Yasal Dokümanlar
                            </a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link" data-bs-toggle="tab" href="#tabContact">
                                <i class="fas fa-address-book me-2"></i>İletişim
                            </a>
                        </li>
                    </ul>
                </div>
                <div class="card-body">
                    <div class="tab-content">
                        <!-- GENERAL TAB -->
                        <div class="tab-pane fade show active" id="tabGeneral">
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <h5 class="fw-bold mb-3">Site Bilgileri</h5>
                                    <div class="mb-3">
                                        <label class="form-label">Slogan</label>
                                        <textarea class="form-control" id="siteDescription" rows="3"
                                            placeholder="Site altındaki açıklama metni..."></textarea>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <h5 class="fw-bold mb-3">Sosyal Medya</h5>
                                    <div id="socialMediaContainer">
                                        <!-- Dynamic Items -->
                                    </div>
                                    <button type="button" class="btn btn-sm btn-outline-primary mt-2"
                                        onclick="addSocialMediaItem()">
                                        <i class="fas fa-plus me-1"></i>Ekle
                                    </button>
                                </div>
                            </div>
                        </div>

                        <!-- QUICK LINKS TAB -->
                        <div class="tab-pane fade" id="tabQuickLinks">
                            <h5 class="fw-bold mb-3">Hızlı Linkler Menüsü</h5>
                            <div class="alert alert-info py-2 small">
                                <i class="fas fa-info-circle me-2"></i>Sürükle bırak sıralama henüz aktif değildir.
                            </div>
                            <div id="quickLinksContainer"></div>
                            <button type="button" class="btn btn-sm btn-outline-primary mt-3"
                                onclick="addLinkItem('quickLinksContainer')">
                                <i class="fas fa-plus me-1"></i>Link Ekle
                            </button>
                        </div>

                        <!-- LEGAL TAB -->
                        <div class="tab-pane fade" id="tabLegal">
                            <h5 class="fw-bold mb-3">Yasal Dokümanlar Menüsü</h5>
                            <div id="legalLinksContainer"></div>
                            <button type="button" class="btn btn-sm btn-outline-primary mt-3"
                                onclick="addLinkItem('legalLinksContainer')">
                                <i class="fas fa-plus me-1"></i>Link Ekle
                            </button>
                        </div>

                        <!-- CONTACT TAB -->
                        <div class="tab-pane fade" id="tabContact">
                            <div class="row g-4">
                                <div class="col-md-6">
                                    <h5 class="fw-bold mb-3">İletişim Bilgileri</h5>
                                    <div class="mb-3">
                                        <label class="form-label">E-Posta</label>
                                        <input type="email" class="form-control" id="contactEmail">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Telefon</label>
                                        <input type="text" class="form-control" id="contactPhone">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Adres</label>
                                        <textarea class="form-control" id="contactAddress" rows="2"></textarea>
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Harita Embed Kodu (Iframe)</label>
                                        <textarea class="form-control" id="contactMapEmbed" rows="3"
                                            placeholder='<iframe src="https://www.google.com/maps/embed?..."></iframe>'></textarea>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <h5 class="fw-bold mb-3">Ekstra Bilgiler (Mersis, Vd.)</h5>
                                    <div id="extraInfoContainer"></div>
                                    <button type="button" class="btn btn-sm btn-outline-primary mt-2"
                                        onclick="addExtraInfoItem()">
                                        <i class="fas fa-plus me-1"></i>Ekle
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
</div>

<!-- TEMPLATES -->
<template id="tplSocial">
    <div class="input-group mb-2 item-row">
        <select class="form-select" style="max-width: 140px;" name="icon">
            <option value="fab fa-facebook-f">Facebook</option>
            <option value="fab fa-instagram">Instagram</option>
            <option value="fab fa-twitter">Twitter/X</option>
            <option value="fab fa-linkedin-in">LinkedIn</option>
            <option value="fab fa-youtube">Youtube</option>
            <option value="fab fa-tiktok">TikTok</option>
            <option value="fab fa-whatsapp">WhatsApp</option>
        </select>
        <input type="text" class="form-control" placeholder="URL (https://...)" name="url">
        <button type="button" class="btn btn-outline-danger" onclick="removeRow(this)"><i
                class="fas fa-times"></i></button>
    </div>
</template>

<template id="tplLink">
    <div class="input-group mb-2 item-row">
        <input type="text" class="form-control" placeholder="Başlık" name="title">
        <input type="text" class="form-control" placeholder="URL (/hakkimizda.php)" name="url">
        <button type="button" class="btn btn-outline-danger" onclick="removeRow(this)"><i
                class="fas fa-times"></i></button>
    </div>
</template>

<template id="tplExtra">
    <div class="input-group mb-2 item-row">
        <input type="text" class="form-control" placeholder="Etiket (Örn: Mersis No)" name="label">
        <input type="text" class="form-control" placeholder="Değer" name="value">
        <button type="button" class="btn btn-outline-danger" onclick="removeRow(this)"><i
                class="fas fa-times"></i></button>
    </div>
</template>

<script type="module">
    import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js';
    import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js';
    import { getFirestore, doc, getDoc, setDoc } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

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

        loadSettings();
    });

    window.saveSettings = async function () {
        const btn = document.querySelector('button[onclick="saveSettings()"]');
        const oldHtml = btn.innerHTML;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Kaydediliyor...';
        btn.disabled = true;

        try {
            const data = gatherData();

            // Get Token (Force Refresh)
            const token = await auth.currentUser.getIdToken(true);

            // Add token to payload (More reliable than headers in shared hosting)
            data.authToken = token;

            // 1. Save to JSON (PHP API)
            const response = await fetch('../api/save-footer-settings.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            });

            if (!response.ok) {
                let errorMsg = 'Sunucu / JSON dosyası güncellenemedi.';
                try {
                    const errData = await response.json();
                    if (errData.error) errorMsg = errData.error;
                } catch (e) {
                    errorMsg += ' (JSON Parse Hatası)';
                }
                throw new Error(errorMsg);
            }

            // 2. Save to Firestore (Backup/Sync)
            await setDoc(doc(db, 'settings', 'footer'), data);

            Swal.fire({
                icon: 'success',
                title: 'Başarılı',
                text: 'Ayarlar kaydedildi.',
                timer: 1500,
                showConfirmButton: false
            });

        } catch (error) {
            console.error(error);
            Swal.fire('Hata', 'Kaydetme başarısız: ' + error.message, 'error');
        } finally {
            btn.innerHTML = oldHtml;
            btn.disabled = false;
        }
    }

    async function loadSettings() {
        // First try to load from JSON file (faster/server side config source)
        // If not, try firestore
        // Actually, let's load from Firestore to ensure admin sees "cloud" state, 
        // or load from JSON. Let's try JSON first as it is the SSOT for frontend.
        try {
            const res = await fetch('../config/footer-settings.json?t=' + Date.now());
            if (res.ok) {
                const data = await res.json();
                fillForm(data);
                return;
            }
        } catch (e) { console.log('JSON load failed, trying firestore'); }

        try {
            const docSnap = await getDoc(doc(db, 'settings', 'footer'));
            if (docSnap.exists()) {
                fillForm(docSnap.data());
            }
        } catch (e) {
            console.error('Firestore load error', e);
        }
    }

    function gatherData() {
        return {
            description: document.getElementById('siteDescription').value,
            socialMedia: getListItems('socialMediaContainer', ['icon', 'url']),
            quickLinks: getListItems('quickLinksContainer', ['title', 'url']),
            legalLinks: getListItems('legalLinksContainer', ['title', 'url']),
            contact: {
                email: document.getElementById('contactEmail').value,
                phone: document.getElementById('contactPhone').value,
                address: document.getElementById('contactAddress').value,
                mapEmbed: document.getElementById('contactMapEmbed').value,
                extra: getListItems('extraInfoContainer', ['label', 'value'])
            }
        };
    }

    function fillForm(data) {
        if (!data) return;
        document.getElementById('siteDescription').value = data.description || '';
        document.getElementById('contactEmail').value = data.contact?.email || '';
        document.getElementById('contactPhone').value = data.contact?.phone || '';
        document.getElementById('contactAddress').value = data.contact?.address || '';
        document.getElementById('contactMapEmbed').value = data.contact?.mapEmbed || '';

        // Clear Lists
        document.getElementById('socialMediaContainer').innerHTML = '';
        document.getElementById('quickLinksContainer').innerHTML = '';
        document.getElementById('legalLinksContainer').innerHTML = '';
        document.getElementById('extraInfoContainer').innerHTML = '';

        // Fill Lists
        if (data.socialMedia) data.socialMedia.forEach(item => addSocialMediaItem(item));
        if (data.quickLinks) data.quickLinks.forEach(item => addLinkItem('quickLinksContainer', item));
        if (data.legalLinks) data.legalLinks.forEach(item => addLinkItem('legalLinksContainer', item));
        if (data.contact?.extra) data.contact.extra.forEach(item => addExtraInfoItem(item));
    }

    // -- Global Helpers exposed for HTML onclicks --
    window.getListItems = function (containerId, fields) {
        const container = document.getElementById(containerId);
        const rows = container.querySelectorAll('.item-row');
        const items = [];
        rows.forEach(row => {
            const item = {};
            let hasValue = false;
            fields.forEach(field => {
                const el = row.querySelector(`[name="${field}"]`);
                if (el) {
                    item[field] = el.value;
                    if (el.value) hasValue = true;
                }
            });
            if (hasValue) items.push(item);
        });
        return items;
    }

    window.removeRow = function (btn) {
        btn.closest('.item-row').remove();
    }

    window.addSocialMediaItem = function (data = {}) {
        const tpl = document.getElementById('tplSocial');
        const clone = tpl.content.cloneNode(true);
        if (data.icon) clone.querySelector('[name="icon"]').value = data.icon;
        if (data.url) clone.querySelector('[name="url"]').value = data.url;
        document.getElementById('socialMediaContainer').appendChild(clone);
    }

    window.addLinkItem = function (containerId, data = {}) {
        const tpl = document.getElementById('tplLink');
        const clone = tpl.content.cloneNode(true);
        if (data.title) clone.querySelector('[name="title"]').value = data.title;
        if (data.url) clone.querySelector('[name="url"]').value = data.url;
        document.getElementById(containerId).appendChild(clone);
    }

    window.addExtraInfoItem = function (data = {}) {
        const tpl = document.getElementById('tplExtra');
        const clone = tpl.content.cloneNode(true);
        if (data.label) clone.querySelector('[name="label"]').value = data.label;
        if (data.value) clone.querySelector('[name="value"]').value = data.value;
        document.getElementById('extraInfoContainer').appendChild(clone);

        if (!data.label) { // If adding new empty row, default focus
            // (optional)
        }
    }

    // Logout function
    window.doLogout = async function () {
        try {
            await auth.signOut();
            window.location.href = 'login.php';
        } catch (error) {
            console.error('Logout error:', error);
            alert('Çıkış yapılamadı: ' + error.message);
        }
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<!-- Close #mainLayout -->
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>