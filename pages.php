<?php
/**
 * Halı Yıkamacı - Dinamik Sayfa Görüntüleyici
 * Örn: /yasal/gizlilik-politikasi -> pages.php?slug=gizlilik-politikasi
 */

require_once 'config/app.php';

// Slug Mapping (SEO URL -> DB Type)
$slugMapping = [
    'gizlilik-politikasi' => 'privacy_policy',
    'kvkk' => 'kvkk',
    'kullanici-sozlesmesi' => 'user_agreement',
    'hizmet-sartlari' => 'terms_of_service',
    'cerez-politikasi' => 'cookie_policy',
    'mesafeli-satis-sozlesmesi' => 'distance_sales_agreement',
    'on-bilgilendirme-formu' => 'preliminary_info_form',
    'kullanim-bilgileri' => 'usage_guide'
];

$slug = isset($_GET['slug']) ? htmlspecialchars($_GET['slug']) : '';
$docType = isset($slugMapping[$slug]) ? $slugMapping[$slug] : $slug; // Fallback to slug if not mapped

$pageTitle = ucwords(str_replace('-', ' ', $slug)); // Default title
require_once 'includes/header.php';
?>

<!-- Content Section -->
<section class="section">
    <div class="container">
        <!-- Loading State -->
        <div id="loadingState" class="text-center py-5">
            <div class="spinner"></div>
            <p class="text-muted mt-3">İçerik yükleniyor...</p>
        </div>

        <!-- Error State -->
        <div id="errorState" class="text-center py-5" style="display: none;">
            <i class="fas fa-file-excel fa-4x text-muted mb-3"></i>
            <h4>Sayfa Bulunamadı</h4>
            <p class="text-muted">Aradığınız sayfa mevcut değil veya taşınmış olabilir.</p>
            <a href="<?php echo SITE_URL; ?>" class="btn btn-primary mt-3">Ana Sayfaya Dön</a>
        </div>

        <!-- Content -->
        <div id="pageContent" class="card shadow-sm border-0" style="display: none;">
            <div class="card-body p-4 p-md-5">
                <h1 class="mb-4" id="docTitle"></h1>
                <div class="meta-info mb-4 text-muted small border-bottom pb-3">
                    <span id="docVersion" class="me-3"></span>
                    <span id="docDate"></span>
                </div>
                <!-- Markdown Content Container -->
                <div id="docBody" class="typography"></div>
            </div>
        </div>
    </div>
</section>

<style>
    .typography {
        line-height: 1.8;
        color: #333;
    }

    .typography h1,
    .typography h2,
    .typography h3 {
        margin-top: 1.5rem;
        margin-bottom: 1rem;
        color: #1a1a1a;
    }

    .typography ul,
    .typography ol {
        margin-bottom: 1rem;
        padding-left: 1.5rem;
    }

    .typography p {
        margin-bottom: 1rem;
    }
</style>


<script type="module">
    const docType = '<?php echo $docType; ?>';

    window.addEventListener('firebaseReady', async function () {
        const { collection, getDocs, query, where } = window.firebaseModules;
        const db = window.firebaseDb;

        await loadDocument(db, { collection, getDocs, query, where });
    });

    async function loadDocument(db, { collection, getDocs, query, where }) {
        try {
            // Find document by type
            const docsRef = collection(db, 'legalDocuments');
            // We query by 'type' field
            const q = query(docsRef, where('type', '==', docType), where('isActive', '==', true));
            const snapshot = await getDocs(q);

            if (snapshot.empty) {
                // Try fallback: maybe the slug IS the direct type?
                // But for now, just show error
                document.getElementById('loadingState').style.display = 'none';
                document.getElementById('errorState').style.display = 'block';
                return;
            }

            // Get the first matching document (there should be only one active per type)
            const docData = snapshot.docs[0].data();

            // Render
            document.title = `${docData.title} - ${document.title}`;
            document.getElementById('docTitle').textContent = docData.title;

            if (docData.version) document.getElementById('docVersion').textContent = `Versiyon: ${docData.version}`;
            if (docData.updatedAt?.toDate) {
                const date = docData.updatedAt.toDate().toLocaleDateString('tr-TR');
                document.getElementById('docDate').textContent = `Son Güncelleme: ${date}`;
            }

            // Render Content (HTML supported)
            document.getElementById('docBody').innerHTML = docData.content || '';

            document.getElementById('loadingState').style.display = 'none';
            document.getElementById('pageContent').style.display = 'block';

        } catch (error) {
            console.error('Error loading page:', error);
            document.getElementById('loadingState').style.display = 'none';
            document.getElementById('errorState').style.display = 'block';
        }
    }
</script>

<?php require_once 'includes/footer.php'; ?>