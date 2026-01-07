<?php
/**
 * Halı Yıkamacı - Uygulama Sabitleri
 */

// Site bilgileri
define('SITE_NAME', 'Halı Yıkamacı Bul®');

// Ortam tespiti - localhost veya canlı
$host = $_SERVER['HTTP_HOST'] ?? 'localhost';
if (strpos($host, 'localhost') !== false || strpos($host, '127.0.0.1') !== false) {
    define('SITE_URL', 'http://localhost/haliyikamaci-web');
} else {
    define('SITE_URL', 'https://www.haliyikamacibul.com');
}

define('SITE_DESCRIPTION', 'Türkiye\'nin en büyük halı yıkama platformu');

// Tema renkleri
define('COLOR_PRIMARY', '#E91E63');
define('COLOR_SECONDARY', '#FFD700');
define('COLOR_DARK', '#1a1a2e');
define('COLOR_LIGHT', '#f8f9fa');

// Sayfalama
define('ITEMS_PER_PAGE', 12);

// Sipariş durumları
define('ORDER_STATUSES', [
    'pending' => 'Bekliyor',
    'confirmed' => 'Onaylandı',
    'picked_up' => 'Teslim Alındı',
    'measured' => 'Ölçüm Yapıldı',
    'out_for_delivery' => 'Dağıtıma Çıktı',
    'delivered' => 'Teslim Edildi',
    'cancelled' => 'İptal'
]);

// Ödeme yöntemleri
define('PAYMENT_METHODS', [
    'cash' => 'Nakit',
    'card' => 'Kapıda Kredi Kartı',
    'transfer' => 'Havale/EFT'
]);
