<?php

class PayTRService
{
    private $merchant_id;
    private $merchant_key;
    private $merchant_salt;
    private $test_mode;

    public function __construct()
    {
        // Load dynamic configuration
        $configFile = __DIR__ . '/../config/paytr_settings.php';

        if (file_exists($configFile)) {
            $config = require $configFile;
            $this->merchant_id = $config['merchant_id'];
            $this->merchant_key = $config['merchant_key'];
            $this->merchant_salt = $config['merchant_salt'];
            $this->test_mode = $config['test_mode'];
        } else {
            // Fallback / Placeholders
            $this->merchant_id = 'YOUR_MERCHANT_ID';
            $this->merchant_key = 'YOUR_MERCHANT_KEY';
            $this->merchant_salt = 'YOUR_MERCHANT_SALT';
            $this->test_mode = 1; // 1 for Test Mode, 0 for Production
        }
    }

    /**
     * Generate PayTR Iframe Token
     */
    public function generateToken($orderData)
    {
        $merchant_oid = $orderData['merchant_oid'];
        $email = $orderData['email'];
        $payment_amount = $orderData['payment_amount'] * 100; // Convert to kuruş (e.g., 10.00 TL -> 1000)
        $user_basket = base64_encode(json_encode($orderData['user_basket']));
        $no_installment = isset($orderData['no_installment']) ? $orderData['no_installment'] : 0;
        $max_installment = isset($orderData['max_installment']) ? $orderData['max_installment'] : 0;
        $user_name = $orderData['user_name'];
        $user_address = $orderData['user_address'];
        $user_phone = $orderData['user_phone'];
        $currency = 'TL';
        $merchant_ok_url = $orderData['merchant_ok_url'];
        $merchant_fail_url = $orderData['merchant_fail_url'];
        $user_ip = isset($_SERVER['HTTP_X_FORWARDED_FOR']) ? $_SERVER['HTTP_X_FORWARDED_FOR'] : $_SERVER['REMOTE_ADDR'];
        $timeout_limit = 30;
        $debug_on = 1;

        // Hash String Construction
        $hash_str = $this->merchant_id . $user_ip . $merchant_oid . $email . $payment_amount . $user_basket . $no_installment . $max_installment . $currency . $this->test_mode;

        // Generate Token
        $paytr_token = base64_encode(hash_hmac('sha256', $hash_str . $this->merchant_salt, $this->merchant_key, true));

        // Prepare POST fields
        $post_fields = array(
            'merchant_id' => $this->merchant_id,
            'user_ip' => $user_ip,
            'merchant_oid' => $merchant_oid,
            'email' => $email,
            'payment_amount' => $payment_amount,
            'paytr_token' => $paytr_token,
            'user_basket' => $user_basket,
            'debug_on' => $debug_on,
            'no_installment' => $no_installment,
            'max_installment' => $max_installment,
            'user_name' => $user_name,
            'user_address' => $user_address,
            'user_phone' => $user_phone,
            'merchant_ok_url' => $merchant_ok_url,
            'merchant_fail_url' => $merchant_fail_url,
            'timeout_limit' => $timeout_limit,
            'currency' => $currency,
            'test_mode' => $this->test_mode
        );

        // Fetch Token from PayTR
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, "https://www.paytr.com/odeme/api/get-token");
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        curl_setopt($ch, CURLOPT_POST, 1);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $post_fields);
        curl_setopt($ch, CURLOPT_FRESH_CONNECT, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 20);

        $result = @curl_exec($ch);

        if (curl_errno($ch)) {
            return ['status' => 'error', 'message' => 'PAYTR IFRAME connection error: ' . curl_error($ch)];
        }

        curl_close($ch);

        $result = json_decode($result, 1);

        if ($result['status'] == 'success') {
            return ['status' => 'success', 'token' => $result['token']];
        } else {
            return ['status' => 'error', 'message' => 'PAYTR API error: ' . $result['reason']];
        }
    }

    /**
     * Validate Callback Hash
     */
    public function validateCallback($post)
    {
        if (!isset($post['merchant_oid']) || !isset($post['status']) || !isset($post['total_amount']) || !isset($post['hash'])) {
            return false;
        }

        $hash_str = $post['merchant_oid'] . $this->merchant_salt . $post['status'] . $post['total_amount'];
        $hash = base64_encode(hash_hmac('sha256', $hash_str, $this->merchant_key, true));

        return $hash === $post['hash'];
    }

    /**
     * Set Keys dynamically (e.g., from DB)
     */
    public function setKeys($id, $key, $salt)
    {
        $this->merchant_id = $id;
        $this->merchant_key = $key;
        $this->merchant_salt = $salt;
    }
}
