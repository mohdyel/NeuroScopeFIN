<?php
// Allow CORS from anywhere
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

// preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// ensure upload dir
$uploadDir = __DIR__ . '/files';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}
if (!is_writable($uploadDir)) {
    http_response_code(500);
    echo json_encode(['error' => 'Upload directory not writable']);
    exit;
}

// validate input
if (
    empty($_POST['patientid']) ||
    empty($_POST['username']) ||
    empty($_POST['prediction']) ||
    empty($_FILES['image'])
) {
    http_response_code(400);
    echo json_encode(['error' => 'missing fields']);
    exit;
}

$patientid  = preg_replace('/[^A-Za-z0-9_]/', '', $_POST['patientid']);
$username   = preg_replace('/[^A-Za-z0-9_]/', '', $_POST['username']);
$prediction = preg_replace('/[^A-Za-z0-9_]/', '', $_POST['prediction']);
$file       = $_FILES['image'];

// build a safe filename
$ext      = pathinfo($file['name'], PATHINFO_EXTENSION);
$ts       = time();
$filename = "{$patientid}_{$username}_{$prediction}_{$ts}.{$ext}";
$target   = "{$uploadDir}/{$filename}";

// move uploaded file
if (!move_uploaded_file($file['tmp_name'], $target)) {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to save upload']);
    exit;
}

// respond with JSON
echo json_encode([
    'message'    => 'received',
    'filename'   => $filename,
    'patientid'  => $patientid,
    'username'   => $username,
    'prediction' => $prediction
]);

