<?php
/**
 * Halı Yıkamacı - İletişim Sayfası
 */

require_once 'config/app.php';
$pageTitle = 'İletişim';
require_once 'includes/header.php';

// Load Settings
$settingsPath = __DIR__ . '/config/footer-settings.json';
$settings = [];
if (file_exists($settingsPath)) {
    $settings = json_decode(file_get_contents($settingsPath), true);
}

$contact = $settings['contact'] ?? [];
?>

<!-- Page Header -->
<section class="bg-gradient-primary text-white py-5">
    <div class="container">
        <h1 class="fw-bold mb-2">
            <i class="fas fa-envelope-open-text me-2"></i>İletişim
        </h1>
        <p class="opacity-75 mb-0">
            Bizimle iletişime geçin, sorularınızı yanıtlayalım.
        </p>
    </div>
</section>

<!-- Content -->
<section class="section">
    <div class="container">
        <div class="row g-5">
            <!-- Contact Info -->
            <div class="col-lg-5">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body p-4">
                        <h4 class="fw-bold mb-4 text-primary">İletişim Bilgileri</h4>

                        <div class="d-flex mb-4">
                            <div class="flex-shrink-0">
                                <div class="bg-light rounded-circle d-flex align-items-center justify-content-center"
                                    style="width: 50px; height: 50px;">
                                    <i class="fas fa-map-marker-alt text-primary fa-lg"></i>
                                </div>
                            </div>
                            <div class="ms-3">
                                <h6 class="fw-bold mb-1">Adres</h6>
                                <p class="text-muted mb-0">
                                    <?php echo nl2br(htmlspecialchars($contact['address'] ?? 'Adres bilgisi girilmemiş.')); ?>
                                </p>
                            </div>
                        </div>

                        <div class="d-flex mb-4">
                            <div class="flex-shrink-0">
                                <div class="bg-light rounded-circle d-flex align-items-center justify-content-center"
                                    style="width: 50px; height: 50px;">
                                    <i class="fas fa-phone text-primary fa-lg"></i>
                                </div>
                            </div>
                            <div class="ms-3">
                                <h6 class="fw-bold mb-1">Telefon</h6>
                                <p class="text-muted mb-0">
                                    <a href="tel:<?php echo htmlspecialchars($contact['phone'] ?? ''); ?>"
                                        class="text-decoration-none text-muted">
                                        <?php echo htmlspecialchars($contact['phone'] ?? '-'); ?>
                                    </a>
                                </p>
                            </div>
                        </div>

                        <div class="d-flex mb-4">
                            <div class="flex-shrink-0">
                                <div class="bg-light rounded-circle d-flex align-items-center justify-content-center"
                                    style="width: 50px; height: 50px;">
                                    <i class="fas fa-envelope text-primary fa-lg"></i>
                                </div>
                            </div>
                            <div class="ms-3">
                                <h6 class="fw-bold mb-1">E-Posta</h6>
                                <p class="text-muted mb-0">
                                    <a href="mailto:<?php echo htmlspecialchars($contact['email'] ?? ''); ?>"
                                        class="text-decoration-none text-muted">
                                        <?php echo htmlspecialchars($contact['email'] ?? '-'); ?>
                                    </a>
                                </p>
                            </div>
                        </div>

                        <?php if (!empty($contact['extra'])): ?>
                            <hr class="my-4">
                            <?php foreach ($contact['extra'] as $extra): ?>
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="fw-medium text-dark"><?php echo htmlspecialchars($extra['label']); ?>:</span>
                                    <span class="text-muted"><?php echo htmlspecialchars($extra['value']); ?></span>
                                </div>
                            <?php endforeach; ?>
                        <?php endif; ?>


                    </div>
                </div>
            </div>

            <!-- Contact Form -->
            <div class="col-lg-7">
                <div class="card border-0 shadow-sm">
                    <div class="card-body p-4 p-md-5">
                        <h4 class="fw-bold mb-4 text-primary">Bize Ulaşın</h4>
                        <form id="contactForm">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Adınız Soyadınız</label>
                                    <input type="text" class="form-control" id="name" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">E-Posta Adresiniz</label>
                                    <input type="email" class="form-control" id="email" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Konu</label>
                                    <input type="text" class="form-control" id="subject" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Mesajınız</label>
                                    <textarea class="form-control" id="message" rows="5" required></textarea>
                                </div>
                                <div class="col-12">
                                    <button type="submit" class="btn btn-primary btn-lg w-100" id="submitBtn">
                                        <i class="fas fa-paper-plane me-2"></i>Mesajı Gönder
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>



<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<script type="module">
    window.addEventListener('firebaseReady', function () {
        const { collection, addDoc } = window.firebaseModules;
        const db = window.firebaseDb;

        const form = document.getElementById('contactForm');
        form.addEventListener('submit', async (e) => {
            e.preventDefault();

            const btn = document.getElementById('submitBtn');
            const originalContent = btn.innerHTML;
            btn.innerHTML = '<div class="spinner-border spinner-border-sm me-2"></div>Gönderiliyor...';
            btn.disabled = true;

            const data = {
                name: document.getElementById('name').value.trim(),
                email: document.getElementById('email').value.trim(),
                subject: document.getElementById('subject').value.trim(),
                message: document.getElementById('message').value.trim(),
                createdAt: new Date(),
                isRead: false
            };

            try {
                await addDoc(collection(db, 'contactMessages'), data);

                Swal.fire({
                    icon: 'success',
                    title: 'Mesajınız Gönderildi!',
                    text: 'En kısa sürede size dönüş yapacağız.',
                    confirmButtonColor: '#E91E63'
                });

                form.reset();
            } catch (error) {
                console.error('Mesaj gönderme hatası:', error);
                Swal.fire({
                    icon: 'error',
                    title: 'Hata',
                    text: 'Mesajınız gönderilemedi. Lütfen daha sonra tekrar deneyin.',
                    confirmButtonColor: '#E91E63'
                });
            } finally {
                btn.innerHTML = originalContent;
                btn.disabled = false;
            }
        });
    });
</script>

<?php require_once 'includes/footer.php'; ?>