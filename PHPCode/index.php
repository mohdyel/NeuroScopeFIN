<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>EEG Uploads</title>
</head>
<body>
  <h1>EEG Upload Receiver</h1>
  <p>POST your image + patientid, username, prediction to <code>/upload.php</code>.</p>
  <p>Fetch any file at <code>/files/&lt;filename&gt;</code>.</p>

  <h2>Existing uploads</h2>
  <ul>
  <?php
    $list = glob(__DIR__ . '/files/*');
    foreach ($list as $path) {
      $name = basename($path);
      echo "<li><a href=\"files/{$name}\">{$name}</a></li>";
    }
  ?>
  </ul>
</body>
</html>
