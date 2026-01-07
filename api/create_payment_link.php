<?php
// api/create_payment_link.php
// Generates a checkout URL for mobile apps

header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/../config/app.php';

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Method not allowed', 405);
    }

    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input)
        throw new Exception('Invalid JSON', 400);

    // Required: uid. package_id is optional (for general entry)
    if (empty($input['uid'])) {
        throw new Exception('Missing uid', 400);
    }

    $uid = $input['uid'];
    $package_id = $input['package_id'] ?? null;

    // Create a secure token
    // Payload contains data + timestamp + signature
    $payload = [
        'uid' => $uid,
        'package_id' => $package_id,
        'ts' => time()
    ];

    // Simple signature with a secret key (You should move this to config)
    $secret = 'MY_MOBILE_APP_SECRET_KEY_123';
    $json = json_encode($payload);
    $signature = hash_hmac('sha256', $json, $secret);

    $tokenArray = [
        'data' => $json,
        'sig' => $signature
    ];

    $token = base64_encode(json_encode($tokenArray));

    // URL
    $url = SITE_URL . "/firm/krd.php?mobile_token=" . urlencode($token);

    echo json_encode(['status' => 'success', 'url' => $url]);

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}
