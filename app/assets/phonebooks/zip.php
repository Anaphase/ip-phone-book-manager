<?php

$type = 'cisco';

if (isset($_GET['menu_type']) && $_GET['menu_type'] === 'yealink') {
  $type = 'yealink';
}

$zip_source = "data/xml/$type/";
$zip_name = "$type-phonebooks.zip";
$zip_file = "data/$zip_name";

$zip = new ZipArchive();

$zip->open($zip_file, ZIPARCHIVE::OVERWRITE);

$files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($zip_source), RecursiveIteratorIterator::LEAVES_ONLY);

foreach ($files as $name => $file) {
  if (is_dir($file)) continue;
  $local_file = str_replace($zip_source, '', $file);
  $zip->addFile($file, $local_file);
}

$zip->close();

header('Content-Type: application/octet-stream');
header('Content-Transfer-Encoding: Binary');
header('Content-disposition: attachment; filename="' . $zip_name . '"');
readfile($zip_file);
