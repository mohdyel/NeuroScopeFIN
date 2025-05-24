<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// sanitize username
$user = preg_replace('/[^A-Za-z0-9_]/','', $_GET['username'] ?? '');
// directory
$dir  = __DIR__ . '/files';
$files = [];

if ($user && is_dir($dir)) {
  foreach (scandir($dir) as $f) {
    // only real files
    if ($f === '.' || $f === '..') continue;
    // match <something>_<username>_<something>.png
    if (strpos($f, "_{$user}_") !== false) {
      $files[] = $f;
    }
  }
}

// return JSON
echo json_encode(['history' => $files]);
