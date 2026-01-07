<!DOCTYPE html>
<html lang="tr">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="<?php echo isset($pageDescription) ? $pageDescription : SITE_DESCRIPTION; ?>">
    <title><?php echo isset($pageTitle) ? $pageTitle . ' - ' . SITE_NAME : SITE_NAME; ?></title>

    <!-- Canonical URL -->
    <link rel="canonical" href="<?php echo SITE_URL . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH); ?>">

    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website">
    <meta property="og:url" content="<?php echo SITE_URL . $_SERVER['REQUEST_URI']; ?>">
    <meta property="og:title" content="<?php echo isset($pageTitle) ? $pageTitle . ' - ' . SITE_NAME : SITE_NAME; ?>">
    <meta property="og:description"
        content="<?php echo isset($pageDescription) ? $pageDescription : SITE_DESCRIPTION; ?>">
    <meta property="og:image"
        content="<?php echo isset($ogImage) && !empty($ogImage) ? $ogImage : SITE_URL . '/assets/img/logo/logo.png'; ?>">

    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image">
    <meta property="twitter:url" content="<?php echo SITE_URL . $_SERVER['REQUEST_URI']; ?>">
    <meta property="twitter:title"
        content="<?php echo isset($pageTitle) ? $pageTitle . ' - ' . SITE_NAME : SITE_NAME; ?>">
    <meta property="twitter:description"
        content="<?php echo isset($pageDescription) ? $pageDescription : SITE_DESCRIPTION; ?>">
    <meta property="twitter:image"
        content="<?php echo isset($ogImage) && !empty($ogImage) ? $ogImage : SITE_URL . '/assets/img/logo/logo.png'; ?>">

    <!-- Schema.org JSON-LD -->
    <?php
    // Load existing settings for Schema if not already loaded (header is usually first)
    $schemaSettings = [];
    $schemaFile = __DIR__ . '/../config/footer-settings.json';
    if (file_exists($schemaFile)) {
        $json = file_get_contents($schemaFile);
        $schemaSettings = json_decode($json, true) ?? [];
    }

    $schemaPhone = $schemaSettings['contact']['phone'] ?? '0850 123 45 67';
    $schemaSocials = [];
    if (!empty($schemaSettings['socialMedia'])) {
        foreach ($schemaSettings['socialMedia'] as $sm) {
            if (!empty($sm['url']) && $sm['url'] !== '#') {
                $schemaSocials[] = $sm['url'];
            }
        }
    }
    // Organization Schema
    $orgSchema = [
        "@context" => "https://schema.org",
        "@type" => "Organization",
        "name" => SITE_NAME,
        "url" => SITE_URL,
        "logo" => SITE_URL . "/assets/img/logo/logo.png",
        "description" => SITE_DESCRIPTION,
        "contactPoint" => [
            "@type" => "ContactPoint",
            "telephone" => $schemaPhone,
            "contactType" => "Customer Service",
            "areaServed" => "TR",
            "availableLanguage" => "Turkish"
        ]
    ];
    if (!empty($schemaSocials)) {
        $orgSchema["sameAs"] = $schemaSocials;
    }

    // WebSite Schema
    $webSiteSchema = [
        "@context" => "https://schema.org",
        "@type" => "WebSite",
        "name" => SITE_NAME,
        "url" => SITE_URL,
        "potentialAction" => [
            "@type" => "SearchAction",
            "target" => SITE_URL . "/customer/firms.php?q={search_term_string}",
            "query-input" => "required name=search_term_string"
        ]
    ];
    ?>
    <script type="application/ld+json">
        <?php echo json_encode($orgSchema, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE); ?>
    </script>
    <script type="application/ld+json">
        <?php echo json_encode($webSiteSchema, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE); ?>
    </script>

    <!-- Dynamic Page Schema -->
    <?php if (isset($pageSchema) && !empty($pageSchema)): ?>
        <script type="application/ld+json">
                    <?php echo json_encode($pageSchema, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE); ?>
                </script>
    <?php endif; ?>

    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap"
        rel="stylesheet">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome 6 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <!-- Custom CSS -->
    <link rel="apple-touch-icon" sizes="180x180" href="<?php echo SITE_URL; ?>/assets/favicon/apple-touch-icon.png">
    <link rel="icon" type="image/png" sizes="32x32" href="<?php echo SITE_URL; ?>/assets/favicon/favicon-32x32.png">
    <link rel="icon" type="image/png" sizes="16x16" href="<?php echo SITE_URL; ?>/assets/favicon/favicon-16x16.png">
    <link rel="manifest" href="<?php echo SITE_URL; ?>/assets/favicon/site.webmanifest">
    <link rel="mask-icon" href="<?php echo SITE_URL; ?>/assets/favicon/safari-pinned-tab.svg" color="#5bbad5">
    <meta name="msapplication-TileColor" content="#2b5797">
    <meta name="theme-color" content="#ffffff">
    <link rel="stylesheet" href="<?php echo SITE_URL; ?>/assets/css/style.css">
</head>

<body>
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-gradient-primary sticky-top">
        <div class="container">
            <a class="navbar-brand fw-bold d-flex align-items-center" href="<?php echo SITE_URL; ?>">
                <img src="<?php echo SITE_URL; ?>/assets/images/icon.png" alt="Logo" style="height: 30px; width: auto;"
                    class="me-2 rounded">
                <?php echo SITE_NAME; ?>
            </a>

            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarMain">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="navbarMain">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="nav-link" href="<?php echo SITE_URL; ?>">
                            <i class="fas fa-home me-1"></i>Ana Sayfa
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<?php echo SITE_URL; ?>/firmalar">
                            <i class="fas fa-store me-1"></i>Firmalar
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<?php echo SITE_URL; ?>/kampanyalar">
                            <i class="fas fa-tags me-1"></i>Kampanyalar
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<?php echo SITE_URL; ?>/iletisim">
                            <i class="fas fa-envelope me-1"></i>İletişim
                        </a>
                    </li>
                </ul>

                <div class="d-flex align-items-center gap-2">
                    <!-- Firma Girişi -->
                    <a href="<?php echo SITE_URL; ?>/firma-girisi" class="btn btn-outline-light btn-sm">
                        <i class="fas fa-briefcase me-1"></i>Firma Girişi
                    </a>

                    <!-- Kullanıcı Durumu -->
                    <div id="userAuthArea">
                        <a href="<?php echo SITE_URL; ?>/customer/login.php" class="btn btn-warning btn-sm">
                            <i class="fas fa-user me-1"></i>Giriş Yap
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main>