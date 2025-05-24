<?php
// index.php on checkokornot.atwebpages.com

// Allow any client (including your flutter web app) to fetch this
header('Access-Control-Allow-Origin: *');

// If you ever need preflight, also allow:
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header('Access-Control-Allow-Methods: GET');
    header('Access-Control-Allow-Headers: Content-Type');
    exit;
}

header('Content-Type: text/plain');

// update this whenever your ngrok URL rotates
echo 'https://bf14-77-30-198-218.ngrok-free.app';
