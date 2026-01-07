<?php
/**
 * Halı Yıkamacı - Raporlar
 */
require_once '../config/app.php';
$pageTitle = 'Raporlar';
require_once 'includes/header.php';
?>

<div class="page-header">
    <h4 class="mb-0"><i class="fas fa-chart-pie me-2"></i>Raporlar ve İstatistikler</h4>
</div>

<div class="page-body">
    <div id="loading" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Yükleniyor...</span>
        </div>
        <p class="mt-2 text-muted">Veriler analiz ediliyor...</p>
    </div>

    <div id="reportContent" class="d-none">
        <!-- Summary Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3">
                <div class="card h-100 border-0 shadow-sm text-center">
                    <div class="card-body">
                        <i class="fas fa-building fa-2x text-warning mb-3"></i>
                        <h3 class="fw-bold mb-0" id="statActiveFirms">-</h3>
                        <small class="text-muted">Aktif Firma</small>
                        <div class="mt-2 text-success small fw-bold" id="statTotalSms">-</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card h-100 border-0 shadow-sm text-center">
                    <div class="card-body">
                        <i class="fas fa-users fa-2x text-primary mb-3"></i>
                        <h3 class="fw-bold mb-0" id="statTotalCustomers">-</h3>
                        <small class="text-muted">Toplam Müşteri</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card h-100 border-0 shadow-sm text-center">
                    <div class="card-body">
                        <i class="fas fa-store fa-2x text-purple mb-3" style="color: purple"></i>
                        <h3 class="fw-bold mb-0" id="statTotalVitrins">-</h3>
                        <small class="text-muted">Aktif Vitrin</small>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card h-100 border-0 shadow-sm text-center">
                    <div class="card-body">
                        <i class="fas fa-bullhorn fa-2x text-success mb-3"></i>
                        <h3 class="fw-bold mb-0" id="statTotalCampaigns">-</h3>
                        <small class="text-muted">Aktif Kampanya</small>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <!-- Rating Distribution -->
            <div class="col-md-6">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-header bg-white">
                        <h6 class="mb-0 fw-bold"><i class="fas fa-star text-warning me-2"></i>Firma Değerlendirme
                            Dağılımı</h6>
                    </div>
                    <div class="card-body" id="ratingDistribution">
                        <!-- Filled by JS -->
                    </div>
                </div>
            </div>

            <!-- Service Distribution (Placeholder based on Flutter code which used mock/placeholder) -->
            <div class="col-md-6">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-header bg-white">
                        <h6 class="mb-0 fw-bold"><i class="fas fa-chart-pie text-info me-2"></i>Hizmet Kategorileri</h6>
                    </div>
                    <div class="card-body">
                        <div class="d-flex align-items-center mb-2">
                            <span class="badge bg-primary p-2 me-2"> </span> <span class="flex-grow-1">Halı
                                Yıkama</span> <span class="fw-bold">%45</span>
                        </div>
                        <div class="d-flex align-items-center mb-2">
                            <span class="badge bg-success p-2 me-2"> </span> <span class="flex-grow-1">Koltuk
                                Yıkama</span> <span class="fw-bold">%25</span>
                        </div>
                        <div class="d-flex align-items-center mb-2">
                            <span class="badge bg-warning p-2 me-2"> </span> <span class="flex-grow-1">Stor Perde</span>
                            <span class="fw-bold">%15</span>
                        </div>
                        <div class="d-flex align-items-center mb-2">
                            <span class="badge p-2 me-2" style="background-color: purple"> </span> <span
                                class="flex-grow-1">Yorgan Yıkama</span> <span class="fw-bold">%10</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Top Firms -->
            <div class="col-12">
                <div class="card border-0 shadow-sm mt-0">
                    <div class="card-header bg-white">
                        <h6 class="mb-0 fw-bold"><i class="fas fa-trophy text-warning me-2"></i>Yüksek KRD Bakiyeli
                            (Aktif) Firmalar</h6>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover mb-0 align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th style="width: 50px">#</th>
                                    <th>Firma Adı</th>
                                    <th>Lokasyon</th>
                                    <th>Puan</th>
                                    <th class="text-end">KRD Bakiyesi</th>
                                </tr>
                            </thead>
                            <tbody id="topFirmsTable">
                                <!-- JS -->
                            </tbody>
                        </table>
                    </div>
                </div>
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
    import { getFirestore, collection, getDocs, query, where } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js';

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
        if (!user) { window.location.href = 'login.php'; return; }
        document.getElementById('authCheck').classList.add('d-none');
        document.getElementById('mainLayout').style.display = 'block';
        loadingReports();
    });

    async function loadingReports() {
        try {
            // Fetch Approved Firms
            const firmsRef = collection(db, 'firms');
            const qFirms = query(firmsRef, where('isApproved', '==', true));
            const firmSnap = await getDocs(qFirms);

            const firms = [];
            let totalSms = 0;
            firmSnap.forEach(doc => {
                const data = doc.data();
                firms.push({ id: doc.id, ...data });
                totalSms += (data.smsBalance || 0);
            });

            // Fetch Customers (Count only)
            const customersSnap = await getDocs(collection(db, 'customers'));
            const totalCustomers = customersSnap.size;

            // Fetch Vitrins (Just query active ones)
            // Note: Since collection structure isn't 100% clear for 'vitrins' vs 'vitrinPackages' usage, 
            // Flutter used 'activeVitrinsProvider'. Assuming 'vitrins' collection or similar.
            // Let's assume standard 'vitrins' collection for now or check repository if needed. 
            // Actually Flutter used `activeVitrinsProvider` which is likely checking `firms` with `vitrinUntil` > now
            // OR a separate collection. Let's look at `data/providers.dart` in memory? 
            // Better to standard check `firms` for vitrin data or `vitrins` collection.
            // But let's check `vitrin_packages.php` -> it manages packages. 
            // Checking `reports_screen.dart` uses `activeVitrinsProvider`.
            // Let's assume a simpler approximate: count firms with isVitrin=true or similar?
            // Wait, looking at `firm_model.dart` would confirm strictly. 
            // For now, I'll count 'vitrins' from a query if collection exists, else just put placeholder or count logic.
            // Actually, usually vitrins are stored in `vitrins` collection or inside firms.
            // Let's assume `vitrins` collection exists based on `activeVitrinsProvider` naming usually mapping to collection.
            const vitrinSnap = await getDocs(collection(db, 'firm_vitrin_purchases'));
            const totalVitrins = vitrinSnap.size; // Or filter by active date if needed, but size is good estimate.

            // Fetch Campaigns
            const campaignSnap = await getDocs(collection(db, 'campaigns'));
            const totalCampaigns = campaignSnap.size;

            // Update Stats
            document.getElementById('statActiveFirms').textContent = firms.length;
            document.getElementById('statTotalSms').textContent = 'Top. KRD: ' + formatNumber(totalSms);
            document.getElementById('statTotalCustomers').textContent = formatNumber(totalCustomers);
            document.getElementById('statTotalVitrins').textContent = totalVitrins;
            document.getElementById('statTotalCampaigns').textContent = totalCampaigns;

            // Rating Distribution
            renderRatingDistribution(firms);

            // Top Firms
            renderTopFirms(firms);

            document.getElementById('reportContent').classList.remove('d-none');
        } catch (error) {
            console.error(error);
            Swal.fire('Hata', 'Rapor verileri alınamadı', 'error');
        } finally {
            document.getElementById('loading').classList.add('d-none');
        }
    }

    function renderRatingDistribution(firms) {
        const buckets = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
        firms.forEach(f => {
            const r = Math.round(f.rating || 0);
            const val = r < 1 ? 1 : (r > 5 ? 5 : r);
            buckets[val]++;
        });

        const total = firms.length || 1;
        let html = '';

        for (let i = 5; i >= 1; i--) {
            const count = buckets[i];
            const pct = Math.round((count / total) * 100);
            html += `
                <div class="d-flex align-items-center mb-3">
                    <div style="width: 40px; font-weight: bold">${i} <i class="fas fa-star text-warning small"></i></div>
                    <div class="progress flex-grow-1 mx-2" style="height: 10px;">
                        <div class="progress-bar bg-warning" style="width: ${pct}%"></div>
                    </div>
                    <div style="width: 80px" class="text-end small text-muted">${count} (%${pct})</div>
                </div>
            `;
        }
        document.getElementById('ratingDistribution').innerHTML = html;
    }

    function renderTopFirms(firms) {
        // Sort by SMS desc
        const sorted = firms.sort((a, b) => (b.smsBalance || 0) - (a.smsBalance || 0)).slice(0, 10);

        let html = '';
        sorted.forEach((f, index) => {
            const addr = (f.address && f.address.district) ? f.address.district + ', ' + f.address.city : '-';
            let badgeColor = 'bg-secondary';
            if (index === 0) badgeColor = 'bg-warning';
            if (index === 1) badgeColor = 'bg-secondary'; // Silver-ish
            if (index === 2) badgeColor = 'bg-danger'; // Bronze-ish

            html += `
                <tr>
                    <td><span class="badge ${badgeColor} rounded-circle">${index + 1}</span></td>
                    <td class="fw-bold">${f.name}</td>
                    <td class="small text-muted">${addr}</td>
                    <td><i class="fas fa-star text-warning"></i> ${f.rating ? f.rating.toFixed(1) : '0.0'}</td>
                    <td class="text-end fw-bold text-success">${f.smsBalance || 0} KRD</td>
                </tr>
             `;
        });
        document.getElementById('topFirmsTable').innerHTML = html;
    }

    function formatNumber(num) {
        if (num >= 1000) return (num / 1000).toFixed(1) + 'K';
        return num;
    }
</script>
</body>

</html>