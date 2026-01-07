<?php
/**
 * Upload Popup Image API
 * Güvenlik: CORS kısıtlı, sadece admin panelinden erişim
 */

header('Content-Type: application/json; charset=utf-8');

// CORS - Sadece izinli origin'ler
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
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Access denied']);
    exit;
}

header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$response = ['success' => false, 'message' => ''];

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response['message'] = 'Invalid request method.';
    echo json_encode($response);
    exit;
}

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
    echo json_encode(['success' => false, 'message' => 'Yetkilendirme hatası (Token yok).']);
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
    echo json_encode(['success' => false, 'message' => 'Geçersiz oturum bileti (Token geçersiz).']);
    exit;
}

$data = json_decode($response, true);
if (!isset($data['users'][0]['localId'])) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Token kullanıcı verisi içermiyor.']);
    exit;
}
// Token geçerli

if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    echo json_encode(['success' => false, 'message' => 'Dosya yüklenemedi veya dosya seçilmedi. Error: ' . ($_FILES['image']['error'] ?? 'Unknown')]);
    exit;
}

$file = $_FILES['image'];
$maxSize = 10 * 1024 * 1024; // 10MB (Processing large files might need memory)

// Klasör Yolu
$uploadDir = '../uploads/popup_ads/';
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// Check GD Library
$gdEnabled = extension_loaded('gd');

$finfo = finfo_open(FILEINFO_MIME_TYPE);
$mimeType = finfo_file($finfo, $file['tmp_name']);
finfo_close($finfo);

$allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
if (!in_array($mimeType, $allowedTypes)) {
    echo json_encode(['success' => false, 'message' => 'Geçersiz dosya formatı. (Desteklenenler: JPG, PNG, GIF, WEBP)']);
    exit;
}

// Resim İşleme ve WebP Dönüşümü
if ($gdEnabled) {
    try {
        $sourceImage = null;
        switch ($mimeType) {
            case 'image/jpeg':
                $sourceImage = imagecreatefromjpeg($file['tmp_name']);
                break;
            case 'image/png':
                $sourceImage = imagecreatefrompng($file['tmp_name']);
                break;
            case 'image/gif':
                $sourceImage = imagecreatefromgif($file['tmp_name']);
                break;
            case 'image/webp':
                $sourceImage = imagecreatefromwebp($file['tmp_name']);
                break;
        }

        if (!$sourceImage) {
            throw new Exception("Resim kaynağı okunamadı, normal yükleme yapılacak.");
        }

        // Orijinal Boyutlar
        $width = imagesx($sourceImage);
        $height = imagesy($sourceImage);

        // Yeni Boyutlar (Max Width: 800px, Mobil uyumlu)
        $targetWidth = 800;
        if ($width > $targetWidth) {
            $ratio = $targetWidth / $width;
            $newWidth = $targetWidth;
            $newHeight = $height * $ratio;
        } else {
            $newWidth = $width;
            $newHeight = $height;
        }

        // Yeni Tuval
        $newImage = imagecreatetruecolor($newWidth, $newHeight);

        // Şeffaflık Koruması (PNG/WebP için)
        imagealphablending($newImage, false);
        imagesavealpha($newImage, true);
        $transparent = imagecolorallocatealpha($newImage, 255, 255, 255, 127);
        imagefilledrectangle($newImage, 0, 0, $newWidth, $newHeight, $transparent);

        // Resize
        imagecopyresampled($newImage, $sourceImage, 0, 0, 0, 0, $newWidth, $newHeight, $width, $height);

        // Dosya Adı (WebP uzantılı)
        $fileName = 'popup_' . time() . '_' . uniqid() . '.webp';
        $targetPath = $uploadDir . $fileName;

        // Save as WebP (Quality: 80)
        if (imagewebp($newImage, $targetPath, 80)) {
            // cleanup
            imagedestroy($sourceImage);
            imagedestroy($newImage);

            // Başarılı Dönüş
            sendResponse(true, getUrl($fileName), 'Resim optimize edildi ve WebP olarak kaydedildi.');
            exit;
        }
    } catch (Exception $e) {
        // Hata durumunda (GD hata verirse) aşağıya, normal yüklemeye devam et
        // echo json_encode(['success' => false, 'message' => 'GD Hatası: ' . $e->getMessage()]); // Debug için açılabilir
    }
}

// FALLBACK: Normal Yükleme (GD yoksa veya hata verdiyse)
$extension = pathinfo($file['name'], PATHINFO_EXTENSION);
$fileName = 'popup_' . time() . '_' . uniqid() . '.' . $extension;
$targetPath = $uploadDir . $fileName;

if (move_uploaded_file($file['tmp_name'], $targetPath)) {
    $msg = $gdEnabled ? 'Resim yüklendi (Optimizasyon başarısız oldu).' : 'Resim yüklendi (GD yüklü olmadığı için optimize edilemedi).';
    sendResponse(true, getUrl($fileName), $msg);
} else {
    sendResponse(false, '', 'Dosya sunucuya kaydedilemedi.');
}

function sendResponse($success, $url, $message)
{
    echo json_encode(['success' => $success, 'url' => $url, 'message' => $message]);
}

function getUrl($fileName)
{
    $protocol = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http";
    $host = $_SERVER['HTTP_HOST'];
    $scriptDir = dirname($_SERVER['SCRIPT_NAME']);
    $rootDir = dirname($scriptDir);
    $rootDir = str_replace('\\', '/', $rootDir);
    if ($rootDir === '/')
        $rootDir = '';
    return $protocol . "://" . $host . $rootDir . "/uploads/popup_ads/" . $fileName;
}
