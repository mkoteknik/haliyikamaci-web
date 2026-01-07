<?php
/**
 * Upload Media API
 * Güvenlik: CORS kısıtlı, sadece izinli domain'lerden erişim
 */

header('Content-Type: application/json');

// CORS - Sadece izinli origin'ler
$allowedOrigins = [
    'https://haliyikamacibul.com',
    'https://www.haliyikamacibul.com',
    'http://localhost',
    'http://127.0.0.1'
];

$origin = $_SERVER['HTTP_ORIGIN'] ?? '';

// Localhost için geniş eşleşme (port numarasına bakılmaksızın)
$isLocalhost = (strpos($origin, 'localhost') !== false || strpos($origin, '127.0.0.1') !== false);

if (in_array($origin, $allowedOrigins) || $isLocalhost) {
    header("Access-Control-Allow-Origin: $origin");
    header("Access-Control-Allow-Credentials: true");
} else {
    // Origin yoksa veya izinsizse, aynı-origin isteklerine izin ver
    // (Tarayıcıdan aynı domain'den gelen istekler Origin göndermeyebilir)
    if (!empty($origin)) {
        http_response_code(403);
        echo json_encode(['error' => 'Origin not allowed']);
        exit;
    }
}

header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Preflight request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

if (!isset($_FILES['file'])) {
    http_response_code(400);
    echo json_encode(['error' => 'No file uploaded']);
    exit;
}

$type = $_POST['type'] ?? 'misc'; // slider, logo, document
$allowedTypes = ['slider', 'logo', 'misc'];

// 1. GÜVENLİK: Token Doğrulama (Google Public API)
$authHeader = null;
if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
    $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
} elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
    $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
} elseif (function_exists('apache_request_headers')) {
    $requestHeaders = apache_request_headers();
    $requestHeaders = array_change_key_case($requestHeaders, CASE_LOWER);
    if (isset($requestHeaders['authorization'])) {
        $authHeader = $requestHeaders['authorization'];
    }
}

if (!$authHeader || strpos($authHeader, 'Bearer ') !== 0) {
    http_response_code(401);
    echo json_encode(['error' => 'No token provided']);
    exit;
}

$idToken = trim(substr($authHeader, 7));
$apiKey = "AIzaSyAZBzUpPtWHnW3mlF38L7YGpiknMB9dZb8";
$googleApiUrl = "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=" . $apiKey;

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $googleApiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(['idToken' => $idToken]));
curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode !== 200) {
    http_response_code(401);
    echo json_encode(['error' => 'Invalid token']);
    exit;
}

$data = json_decode($response, true);
if (!isset($data['users'][0]['localId'])) {
    http_response_code(401);
    echo json_encode(['error' => 'Invalid token data']);
    exit;
}
// Token geçerli

if (!in_array($type, $allowedTypes)) {
    $type = 'misc';
}

$uploadBase = '../assets/img/';
$targetDir = $uploadBase . $type . '/';

if (!file_exists($targetDir)) {
    mkdir($targetDir, 0777, true);
}

$file = $_FILES['file'];
$ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
$validExts = ['webp', 'png', 'jpg', 'jpeg', 'pdf'];

if (!in_array($ext, $validExts)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid file extension']);
    exit;
}

// Generate unique name
$filename = uniqid($type . '_') . '.' . $ext;
// If user provided a specific name (e.g. for SEO), use it but sanitize STRICTLY
if (isset($_POST['filename']) && !empty($_POST['filename'])) {
    $rawName = $_POST['filename'];
    // Remove directory separators and dangerous characters
    $safeName = preg_replace('/[^a-zA-Z0-9\-\._]/', '', basename($rawName));
    if (!empty($safeName)) {
        $filename = $safeName . '.' . $ext;
    }
}

$targetPath = $targetDir . $filename;
$publicPath = 'assets/img/' . $type . '/' . $filename;

// Full URL for mobile compatibility (guesswork for localhost vs prod)
$protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
$host = $_SERVER['HTTP_HOST'];
// Handle if we are in a subdirectory (e.g. localhost/haliyikamaci-web)
// Script is in /api/upload-media.php, so root is 1 levels up from api parent?
// actually script is in /admin/api/ (if I put it there) or /api/
// User logic: admin/api/upload-slider.php exists.
// I will place this in `api/upload-media.php` (root api folder i saw earlier).
// No, the previous `upload-slider.php` I put in `admin/api`.
// I'll stick to `api/upload-media.php` in the valid `api` folder since it's for the whole site.

if (move_uploaded_file($file['tmp_name'], $targetPath)) {
    $fullUrl = "$protocol://$host/haliyikamaci-web/$publicPath"; // Adjust subdir if needed

    echo json_encode([
        'success' => true,
        'path' => $publicPath,
        'url' => $fullUrl
    ]);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Upload failed']);
    exit;
}
