<?php
// payment/fail.php
require_once __DIR__ . '/../config/app.php';

$reason = $_POST['failed_reason_msg'] ?? 'İşlem tamamlanamadı.';
?>
<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ödeme Başarısız - <?php echo SITE_NAME; ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>

<body class="bg-light">

    <div class="container mt-5">
        <div class="card border-0 shadow-sm mx-auto" style="max-width: 500px;">
            <div class="card-body text-center p-5">
                <div class="text-danger mb-4">
                    <i class="fas fa-times-circle fa-5x"></i>
                </div>
                <h3 class="mb-3">Ödeme Başarısız</h3>
                <p class="text-muted mb-4"><?php echo htmlspecialchars($reason); ?></p>

                <a href="../index.php" class="btn btn-outline-primary">Ana Sayfaya Dön</a>
            </div>
        </div>
    </div>

</body>

</html>