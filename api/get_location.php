<?php
header('Content-Type: application/json; charset=utf-8');

// Allow CORS if needed (for development)
header("Access-Control-Allow-Origin: *");

if (!isset($_GET['lat']) || !isset($_GET['lon'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Latitude and Longitude required']);
    exit;
}

$lat = $_GET['lat'];
$lon = $_GET['lon'];

// Validate inputs
if (!is_numeric($lat) || !is_numeric($lon)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid coordinates']);
    exit;
}

$url = "https://nominatim.openstreetmap.org/reverse?format=json&lat={$lat}&lon={$lon}&zoom=18&addressdetails=1&accept-language=tr";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
// IMPORTANT: User-Agent is required by Nominatim
curl_setopt($ch, CURLOPT_USERAGENT, "HaliYikamaciWeb/1.0");
curl_setopt($ch, CURLOPT_REFERER, "http://localhost");
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // For local dev, might need true in prod

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if (curl_errno($ch)) {
    http_response_code(500);
    echo json_encode(['error' => 'Curl error: ' . curl_error($ch)]);
    curl_close($ch);
    exit;
}

curl_close($ch);

if ($httpCode !== 200) {
    http_response_code($httpCode);
    echo json_encode(['error' => 'Nominatim API error', 'details' => $response]);
    exit;
}

echo $response;
