<?php
/**
 * Halı Yıkamacı - Şifre Güncelleme API
 * Firebase Identity Toolkit REST API kullanarak şifre güncelleme
 * 
 * POST: { phone: "5321234567", newPassword: "yeniSifre123" }
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
$newPassword = $input['newPassword'] ?? '';

// Validations
if (empty($phone) || empty($newPassword)) {
    echo json_encode(['success' => false, 'message' => 'Telefon ve şifre gerekli']);
    exit;
}

$phone = preg_replace('/\D/', '', $phone);
if (strlen($phone) !== 10) {
    echo json_encode(['success' => false, 'message' => 'Geçersiz telefon numarası']);
    exit;
}

if (strlen($newPassword) < 6) {
    echo json_encode(['success' => false, 'message' => 'Şifre en az 6 karakter olmalı']);
    exit;
}

// Load service account
$serviceAccountFile = __DIR__ . '/../config/halisepetimbl-firebase-adminsdk-fbsvc-cc0fd03f3b.json';
if (!file_exists($serviceAccountFile)) {
    echo json_encode(['success' => false, 'message' => 'Service account bulunamadı']);
    exit;
}

$serviceAccount = json_decode(file_get_contents($serviceAccountFile), true);

// Generate JWT for Google OAuth
function generateJwt($serviceAccount)
{
    $header = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));

    $now = time();
    $payload = base64_encode(json_encode([
        'iss' => $serviceAccount['client_email'],
        'sub' => $serviceAccount['client_email'],
        'aud' => 'https://oauth2.googleapis.com/token',
        'iat' => $now,
        'exp' => $now + 3600,
        'scope' => 'https://www.googleapis.com/auth/identitytoolkit https://www.googleapis.com/auth/datastore'
    ]));

    $signatureInput = $header . '.' . $payload;
    $privateKey = openssl_pkey_get_private($serviceAccount['private_key']);
    openssl_sign($signatureInput, $signature, $privateKey, OPENSSL_ALGO_SHA256);

    return $signatureInput . '.' . base64_encode($signature);
}

// Get access token from Google
function getAccessToken($jwt)
{
    $ch = curl_init('https://oauth2.googleapis.com/token');
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POSTFIELDS => http_build_query([
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion' => $jwt
        ]),
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => 0
    ]);
    $response = curl_exec($ch);
    curl_close($ch);

    $data = json_decode($response, true);
    // The following line was a duplicate and has been removed.
    // $data = json_decode($response, true);
    if (!isset($data['access_token'])) {
        return 'err_' . ($data['error_description'] ?? $data['error'] ?? $response);
    }
    return $data['access_token'] ?? null;
}

// Get user by email using Admin API
function getUserByEmail($email, $accessToken, $projectId)
{
    $url = "https://identitytoolkit.googleapis.com/v1/projects/$projectId/accounts:lookup";

    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'Authorization: Bearer ' . $accessToken,
            'Content-Type: application/json'
        ],
        CURLOPT_POSTFIELDS => json_encode(['email' => [$email]]),
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => 0
    ]);
    $response = curl_exec($ch);
    curl_close($ch);

    $data = json_decode($response, true);
    return $data['users'][0] ?? null;
}

// Update user password using Admin API
function updateUserPassword($localId, $newPassword, $accessToken, $projectId)
{
    $url = "https://identitytoolkit.googleapis.com/v1/projects/$projectId/accounts:update";

    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'Authorization: Bearer ' . $accessToken,
            'Content-Type: application/json'
        ],
        CURLOPT_POSTFIELDS => json_encode([
            'localId' => $localId,
            'password' => $newPassword
        ]),
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => 0
    ]);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return ['code' => $httpCode, 'response' => json_decode($response, true)];
}

try {
    // 1. Check if OTP was verified in Firestore
    $firestoreUrl = "https://firestore.googleapis.com/v1/projects/{$serviceAccount['project_id']}/databases/haliyikamacimmbldatabase/documents/password_reset_requests/{$phone}";

    // (JWT, AccessToken alma kısımları aradaki satırlarda, replace ile ezmeyelim)
    // En iyisi replace bloğunu sadece URL ve IF bloğu için yapalım.

    // Generate JWT and get access token (assuming these are already defined or handled earlier in the script)
    $jwt = generateJwt($serviceAccount);
    $accessToken = getAccessToken($jwt);

    if (strpos($accessToken, 'err_') === 0) {
        error_log('Access Token Error: ' . $accessToken);
        echo json_encode(['success' => false, 'message' => 'Sunucu hatası (Token). Lütfen daha sonra tekrar deneyin.']);
        exit;
    }

    // Check OTP verification status
    $ch = curl_init($firestoreUrl);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => ['Authorization: Bearer ' . $accessToken],
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => 0
    ]);
    $firestoreResponse = curl_exec($ch);
    $firestoreCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if (curl_errno($ch)) {
        error_log('Firestore CURL Error: ' . curl_error($ch));
        echo json_encode(['success' => false, 'message' => 'Sunucu bağlantı hatası.']);
        exit;
    }
    curl_close($ch);

    if ($firestoreCode !== 200) {
        error_log('Firestore Error (' . $firestoreCode . '): ' . $firestoreResponse);
        echo json_encode(['success' => false, 'message' => 'Şifre sıfırlama süresi dolmuş veya geçersiz istek.']);
        exit;
    }

    $resetDoc = json_decode($firestoreResponse, true);
    $verified = $resetDoc['fields']['verified']['booleanValue'] ?? false;

    if (!$verified) {
        echo json_encode(['success' => false, 'message' => 'Önce doğrulama kodunu girin']);
        exit;
    }

    // 2. Get user by email
    $email = $phone . '@haliyikamaci.app';
    $user = getUserByEmail($email, $accessToken, $serviceAccount['project_id']);

    if (!$user) {
        echo json_encode(['success' => false, 'message' => 'Kullanıcı bulunamadı']);
        exit;
    }

    // 3. Update password
    $result = updateUserPassword($user['localId'], $newPassword, $accessToken, $serviceAccount['project_id']);

    if ($result['code'] !== 200) {
        error_log('Password update error: ' . json_encode($result['response']));
        echo json_encode(['success' => false, 'message' => 'Şifre güncellenemedi']);
        exit;
    }

    // 4. Delete the reset request from Firestore
    $ch = curl_init($firestoreUrl);
    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => 'DELETE',
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => ['Authorization: Bearer ' . $accessToken]
    ]);
    curl_exec($ch);
    curl_close($ch);

    // 5. Also delete from pending_password_changes if exists
    $pendingUrl = "https://firestore.googleapis.com/v1/projects/{$serviceAccount['project_id']}/databases/haliyikamacimmbldatabase/documents/pending_password_changes/{$phone}";
    $ch = curl_init($pendingUrl);
    curl_setopt_array($ch, [
        CURLOPT_CUSTOMREQUEST => 'DELETE',
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => ['Authorization: Bearer ' . $accessToken]
    ]);
    curl_exec($ch);
    curl_close($ch);

    echo json_encode(['success' => true, 'message' => 'Şifreniz güncellendi. Yeni şifrenizle giriş yapabilirsiniz.']);

} catch (Exception $e) {
    error_log('Update password error: ' . $e->getMessage());
    echo json_encode(['success' => false, 'message' => 'Sunucu hatası: ' . $e->getMessage()]);
}
