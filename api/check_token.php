<?php
/**
 * Check Token API
 * Mobil uygulamadan web paneline güvenli geçiş için token doğrulama
 * Güvenlik: CORS kısıtlı
 */

header('Content-Type: application/json; charset=utf-8');

// CORS - Sadece izinli origin'ler (web ve mobil)
$allowedOrigins = [
    'https://haliyikamacibul.com',
    'https://www.haliyikamacibul.com',
    'http://localhost',
    'http://127.0.0.1'
];

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
$isLocalhost = (strpos($origin, 'localhost') !== false || strpos($origin, '127.0.0.1') !== false);

if (in_array($origin, $allowedOrigins) || $isLocalhost) {
    header("Access-Control-Allow-Origin: $origin");
    header("Access-Control-Allow-Credentials: true");
} elseif (!empty($origin)) {
    // Bilinmeyen origin - ancak mobil app origin göndermeyebilir
    // Bu durumda sadece uyar, engelleme (mobil uyumluluk için)
}

header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

try {
    $input = json_decode(file_get_contents('php://input'), true);

    // Support JSON body or GET parameter
    $token = $input['token'] ?? $_GET['token'] ?? null;

    if (!$token) {
        throw new Exception('Token required', 400);
    }

    // Decode Token
    $decoded = json_decode(base64_decode($token), true);
    if (!$decoded || !isset($decoded['data']) || !isset($decoded['sig'])) {
        throw new Exception('Invalid token format', 400);
    }

    $dataJson = $decoded['data'];
    $requestSig = $decoded['sig'];

    // Verify Signature
    $secret = 'MY_MOBILE_APP_SECRET_KEY_123'; // SAME SECRET AS IN create_payment_link.php
    $calculatedSig = hash_hmac('sha256', $dataJson, $secret);

    if (!hash_equals($calculatedSig, $requestSig)) {
        throw new Exception('Invalid signature', 401);
    }

    // Decode Data
    $data = json_decode($dataJson, true);
    if (!isset($data['uid']) || !isset($data['ts'])) {
        throw new Exception('Invalid token data', 400);
    }

    // Check Expiry (e.g., 1 hour)
    if (time() - $data['ts'] > 3600) {
        throw new Exception('Token expired', 401);
    }

    // Generate Custom Token (Backend -> Frontend Auth)
    require_once '../includes/firebase-jwt.php';
    $serviceAccountPath = __DIR__ . '/../config/halisepetimbl-firebase-adminsdk-fbsvc-cc0fd03f3b.json';

    $tokenGenerator = new FirebaseTokenGenerator($serviceAccountPath);
    $customToken = $tokenGenerator->createCustomToken($data['uid']);

    // Success
    echo json_encode([
        'status' => 'success',
        'uid' => $data['uid'],
        'custom_token' => $customToken, // New field for Firebase Auth
        'package_id' => $data['package_id'] ?? null
    ]);

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
?>