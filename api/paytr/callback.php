<?php

// PayTR Callback Endpoint

require_once __DIR__ . '/../../includes/PayTRService.php';

// Allow POST only
if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    die(''); // Silence
}

$paytr = new PayTRService();

// You should set keys from DB here if not hardcoded
// $paytr->setKeys($db_merchant_id, $db_merchant_key, $db_merchant_salt);

// Validate Hash
if (!$paytr->validateCallback($_POST)) {
    // Hash mismatch
    // Log error
    file_put_contents(__DIR__ . '/paytr_errors.log', date('Y-m-d H:i:s') . " - Hash Failed: " . json_encode($_POST) . "\n", FILE_APPEND);
    die('PAYTR notification failed: bad hash');
}

// Ensure status is success
if ($_POST['status'] == 'success') {
    // Payment Successful
    $merchant_oid = $_POST['merchant_oid'];
    $amount = $_POST['total_amount'];

    // Log Success (Proof of work)
    $logMsg = date('Y-m-d H:i:s') . " - SUCCESS: Order ID: $merchant_oid - Amount: $amount TL\n";
    file_put_contents(__DIR__ . '/paytr_transactions.log', $logMsg, FILE_APPEND);

    // STORE IN JSON DB for Client-Side Verification
    // This allows success.php to verify the payment and update Firestore
    $jsonFile = __DIR__ . '/../../json_db/transactions.json';
    if (!file_exists(dirname($jsonFile)))
        mkdir(dirname($jsonFile), 0777, true);

    $txs = file_exists($jsonFile) ? json_decode(file_get_contents($jsonFile), true) : [];

    // Use OID as key
    $txs[$merchant_oid] = [
        'status' => 'success',
        'amount' => $amount,
        'ts' => time()
    ];

    // Prune old transactions to keep file size manageable
    if (count($txs) > 1000) {
        // Sort by timestamp if needed, but array_slice is faster
        $txs = array_slice($txs, -1000, 1000, true);
    }

    file_put_contents($jsonFile, json_encode($txs));


} else {
    // Payment Failed
    $merchant_oid = $_POST['merchant_oid'];
    $fail_reason = $_POST['failed_reason_msg'];

    $logMsg = date('Y-m-d H:i:s') . " - FAILED: Order ID: $merchant_oid - Reason: $fail_reason\n";
    file_put_contents(__DIR__ . '/paytr_transactions.log', $logMsg, FILE_APPEND);

    // TODO: Update transaction status to 'failed'
}

// Return OK to acknowledge receipt
echo "OK";
exit;
