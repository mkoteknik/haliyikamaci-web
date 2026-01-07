<?php
// Prevent HTML errors from breaking JSON
ini_set('display_errors', 0);
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');

try {
    require_once __DIR__ . '/../../includes/PayTRService.php';

    // Allow CORS for local dev
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");

    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit;
    }

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        throw new Exception('Method not allowed', 405);
    }

    // Get input data
    $input = json_decode(file_get_contents('php://input'), true);

    if (!$input) {
        throw new Exception('Invalid JSON', 400);
    }

    // Validate required fields
    $required = ['merchant_oid', 'email', 'payment_amount', 'user_name', 'user_address', 'user_phone', 'user_basket'];
    foreach ($required as $field) {
        if (empty($input[$field])) {
            throw new Exception("Field required: $field", 400);
        }
    }

    // Initialize Service
    $paytr = new PayTRService();

    // Prepare data for token generation
    $orderData = [
        'merchant_oid' => $input['merchant_oid'],
        'email' => $input['email'],
        'payment_amount' => $input['payment_amount'],
        'user_name' => $input['user_name'],
        'user_address' => $input['user_address'],
        'user_phone' => $input['user_phone'],
        'merchant_ok_url' => 'http://localhost/haliyikamaci-web/paytr/success.php', // Update for prod
        'merchant_fail_url' => 'http://localhost/haliyikamaci-web/paytr/fail.php',    // Update for prod
        'user_basket' => $input['user_basket'],
        'no_installment' => 1,
        'max_installment' => 0
    ];

    // Generate Token
    $result = $paytr->generateToken($orderData);

    echo json_encode($result);

} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
} catch (Error $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Server Error: ' . $e->getMessage()]);
}
?>