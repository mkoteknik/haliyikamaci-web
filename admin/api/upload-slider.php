<?php
header('Content-Type: application/json');

// Check method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

// Check file
if (!isset($_FILES['file']) || $_FILES['file']['error'] !== UPLOAD_ERR_OK) {
    http_response_code(400);
    echo json_encode(['error' => 'No file uploaded or upload error']);
    exit;
}

// 1. GÜVENLİK: Token Doğrulama
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
// Firebase ID Token validasyonu için Identity Toolkit API kullanılmalı
// tokeninfo endpoint'i sadece Google Sign-In (iss=accounts.google.com) tokenlarını kabul eder.
$apiKey = "AIzaSyAZBzUpPtWHnW3mlF38L7YGpiknMB9dZb8"; // Web API Key
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
    // Güvenlik: Detaylı hatayı prodüksiyonda gizlemek daha iyidir ama şimdilik bırakıyorum.
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

$file = $_FILES['file'];
$uploadDir = '../../assets/img/slider/';

// Create directory if not exists
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

// Generate secure filename
// We expect pre-optimized WebP from client, but safety first
$info = pathinfo($file['name']);
$ext = strtolower($info['extension']);
$allowed = ['webp', 'png', 'jpg', 'jpeg'];

if (!in_array($ext, $allowed)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid file type']);
    exit;
}

// Use the name client provided (it has the SEO random logic) OR generate new
$targetName = $file['name'];
// Security: Remove special chars just in case
$targetName = preg_replace('/[^a-zA-Z0-9\-\._]/', '', $targetName);

$targetPath = $uploadDir . $targetName;
$publicPath = 'assets/img/slider/' . $targetName;

if (move_uploaded_file($file['tmp_name'], $targetPath)) {
    echo json_encode([
        'success' => true,
        'url' => $publicPath,
        'full_path' => (isset($_SERVER['HTTPS']) ? "https" : "http") . "://$_SERVER[HTTP_HOST]/haliyikamaci-web/$publicPath"
    ]);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to move uploaded file']);
}
