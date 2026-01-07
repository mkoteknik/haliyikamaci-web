<?php
/**
 * Şifre Sıfırlama OTP SMS Gönderimi
 * POST: { phone: "5321234567", otp: "123456" }
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

$phone = $input['phone'] ?? '';
$otp = $input['otp'] ?? '';

if (empty($phone) || empty($otp)) {
    echo json_encode(['success' => false, 'message' => 'Phone and OTP required']);
    exit;
}

// Clean phone number
$phone = preg_replace('/\D/', '', $phone);
if (strlen($phone) !== 10) {
    echo json_encode(['success' => false, 'message' => 'Invalid phone number']);
    exit;
}

// SMS message
$message = "Halı Yıkamacı - Şifre sıfırlama kodunuz: $otp\nBu kod 10 dakika geçerlidir.";

// Tapsin SMS API
require_once '../config/sms_config.php';

$url = TAPSIN_URL . '?' . http_build_query([
    'user' => TAPSIN_USER,
    'pass' => TAPSIN_PASS,
    'mesaj' => $message,
    'numara' => $phone,
    'origin' => TAPSIN_ORIGIN
]);

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

// Tapsin error codes: 01, 02, 10, 20 = error
$errorCodes = ['01', '02', '10', '20'];

if ($httpCode === 200 && !in_array(trim($response), $errorCodes)) {
    echo json_encode(['success' => true, 'message' => 'SMS gönderildi']);
} else {
    error_log("SMS Error: HTTP $httpCode, Response: $response");
    echo json_encode(['success' => false, 'message' => 'SMS gönderilemedi']);
}
