<?php
// serve.php
header("Access-Control-Allow-Origin: *");

// sanitize & locate
$fname = basename($_GET['file'] ?? '');
$path  = __DIR__ . '/files/' . $fname;
if (!file_exists($path)) {
  http_response_code(404);
  exit;
}

// send correct MIME
$ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
switch ($ext) {
  case 'png':  $type = 'image/png';  break;
  case 'jpg':  
  case 'jpeg': $type = 'image/jpeg'; break;
  case 'gif':  $type = 'image/gif';   break;
  default:     $type = 'application/octet-stream';
}
header("Content-Type: $type");
readfile($path);
