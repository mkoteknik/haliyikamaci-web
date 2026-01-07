<?php
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);
$path = $data['path'] ?? '';

if (empty($path)) {
    http_response_code(400);
    echo json_encode(['error' => 'Path is required']);
    exit;
}

// Security: Prevent directory traversal
if (strpos($path, '..') !== false || strpos($path, 'assets/img/slider/') === false) {
    http_response_code(403);
    echo json_encode(['error' => 'Invalid path']);
    exit;
}

$fullPath = '../../' . $path;

if (file_exists($fullPath)) {
    if (unlink($fullPath)) {
        echo json_encode(['success' => true]);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Failed to delete file']);
    }
} else {
    // File not found is "success" technically (already gone)
    echo json_encode(['success' => true, 'message' => 'File already gone']);
}
