<?php
/**
 * Firebase Custom Token Generator (Native PHP implementation)
 * No Composer/External dependencies required.
 */

class FirebaseTokenGenerator
{
    private $serviceAccountEmail;
    private $privateKey;

    public function __construct(string $serviceAccountPath)
    {
        if (!file_exists($serviceAccountPath)) {
            throw new Exception("Service account file not found: $serviceAccountPath");
        }

        $data = json_decode(file_get_contents($serviceAccountPath), true);
        if (!$data || !isset($data['client_email']) || !isset($data['private_key'])) {
            throw new Exception("Invalid service account JSON");
        }

        $this->serviceAccountEmail = $data['client_email'];
        $this->privateKey = $data['private_key'];
    }

    public function createCustomToken(string $uid, array $claims = []): string
    {
        $now = time();
        $payload = [
            'iss' => $this->serviceAccountEmail,
            'sub' => $this->serviceAccountEmail,
            'aud' => 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit',
            'iat' => $now - 60, // Adjust for clock skew (1 minute back)
            'exp' => $now + 3600, // 1 hour
            'uid' => (string) $uid
        ];

        if (!empty($claims)) {
            $payload['claims'] = $claims;
        }

        return $this->encode($payload);
    }

    private function encode(array $payload): string
    {
        $header = ['alg' => 'RS256', 'typ' => 'JWT'];

        $encodedHeader = $this->base64UrlEncode(json_encode($header));
        $encodedPayload = $this->base64UrlEncode(json_encode($payload));

        $signatureInput = "$encodedHeader.$encodedPayload";
        $signature = '';

        if (!openssl_sign($signatureInput, $signature, $this->privateKey, 'SHA256')) {
            throw new Exception("OpenSSL signing failed");
        }

        $encodedSignature = $this->base64UrlEncode($signature);

        return "$signatureInput.$encodedSignature";
    }

    private function base64UrlEncode(string $data): string
    {
        return str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($data));
    }
}
