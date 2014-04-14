<?php

$zip_source = 'data/xml/';
$zip_file = 'data/phonebooks.zip';

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
header('Content-disposition: attachment; filename="phonebooks.zip"');
readfile($zip_file);
