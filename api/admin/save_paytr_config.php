<?php
// Simple API to save PayTR status to a file
// WARNING: In production, add authentication check here!

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['status' => 'error', 'message' => 'Method not allowed']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    http_response_code(400);
    echo json_encode(['status' => 'error', 'message' => 'Invalid JSON']);
    exit;
}

$merchant_id = $input['merchant_id'] ?? '';
$merchant_key = $input['merchant_key'] ?? '';
$merchant_salt = $input['merchant_salt'] ?? '';
$eft_info = $input['eft_info'] ?? '';
$test_mode = isset($input['test_mode']) ? (int) $input['test_mode'] : 1;

$configContent = "<?php\n\nreturn [\n";
$configContent .= "    'merchant_id' => '" . addslashes($merchant_id) . "',\n";
$configContent .= "    'merchant_key' => '" . addslashes($merchant_key) . "',\n";
$configContent .= "    'merchant_salt' => '" . addslashes($merchant_salt) . "',\n";
$configContent .= "    'eft_info' => '" . addslashes($eft_info) . "',\n";
$configContent .= "    'test_mode' => " . $test_mode . "\n";
$configContent .= "];\n";

$configFile = __DIR__ . '/../../config/paytr_settings.php';

if (file_put_contents($configFile, $configContent)) {
    echo json_encode(['status' => 'success', 'message' => 'Ayarlar kaydedildi']);
} else {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Dosya yazılamadı']);
}
