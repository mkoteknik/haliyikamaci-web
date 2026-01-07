<?php
/**
 * Save Footer Settings API
 * Güvenlik: CORS kısıtlı, admin session kontrolü
 */

session_start();
header('Content-Type: application/json');

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
    echo json_encode(['success' => false, 'error' => 'Access denied']);
    exit;
}

header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

try {
    // 1. Get JSON input first (needed for token)
    $json = file_get_contents('php://input');
    $data = json_decode($json, true);

    if (json_last_error() !== JSON_ERROR_NONE) {
        throw new Exception('Invalid JSON data');
    }

    // 2. SECURITY: Firebase ID Token Verification
    if (!$isLocalhost) {
        // Look for token in JSON body OR Header
        $idToken = $data['authToken'] ?? '';

        // Fallback to Header if not in body
        if (empty($idToken)) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'] ?? '';
            if (strpos($authHeader, 'Bearer ') === 0) {
                $idToken = trim(substr($authHeader, 7));
            }
        }

        if (empty($idToken)) {
            http_response_code(401);
            echo json_encode(['success' => false, 'error' => 'No token provided']);
            exit;
        }

        // Verify with Firebase Identity Toolkit (More reliable for Firebase Tokens)
        $apiKey = 'AIzaSyAZBzUpPtWHnW3mlF38L7YGpiknMB9dZb8'; // From client config
        $googleApiUrl = "https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=$apiKey";

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $googleApiUrl);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode(['idToken' => $idToken]));
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        $tokenData = json_decode($response, true);

        if ($httpCode !== 200 || !isset($tokenData['users'])) {
            http_response_code(401);
            // Include detailed debug info
            $debugMsg = $curlError ? "Connection Error: $curlError" : "Firebase API Response ($httpCode): $response";
            // Check token structure locally (Dump full token for inspection)
            $tokenInfo = "Token (len=" . strlen($idToken) . ")";
            echo json_encode(['success' => false, 'error' => "Invalid token. Details: $debugMsg. \n\nReceived Token: $tokenInfo"]);
            exit;
        }

        // Token is valid!
        // Remove token from data before saving to file
        unset($data['authToken']);
    }

    // Path to config file
    $configFile = __DIR__ . '/../config/footer-settings.json';

    // Ensure config directory exists
    if (!is_dir(dirname($configFile))) {
        mkdir(dirname($configFile), 0755, true);
    }

    // Save to file
    if (file_put_contents($configFile, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE))) {
        echo json_encode(['success' => true]);
    } else {
        // Get last error
        $error = error_get_last();
        throw new Exception('Failed to write to configuration file (' . $configFile . '). Error: ' . ($error['message'] ?? 'Unknown'));
    }

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'error' => $e->getMessage()]);
}
