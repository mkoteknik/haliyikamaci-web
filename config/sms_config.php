<?php
/**
 * Tapsin SMS API Yapılandırması
 * 
 * ÖNEMLİ: Bu dosyayı production'da .env veya güvenli bir yöntemle yapılandırın!
 * Şu anki değerler örnek/placeholder değerlerdir.
 */

// Tapsin SMS API Bilgileri
// Firebase Remote Config'den de alınabilir
define('TAPSIN_URL', 'https://tapsin.tr/gonder.php');
define('TAPSIN_USER', 'YOUR_TAPSIN_USER');  // Gerçek kullanıcı adınızı girin
define('TAPSIN_PASS', 'YOUR_TAPSIN_PASS');  // Gerçek şifrenizi girin
define('TAPSIN_ORIGIN', 'HALIYIKAMACI');    // Gönderici adı/başlık
