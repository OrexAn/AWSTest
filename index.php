<?php

$os_info = php_uname();

$disk_free_space = disk_free_space("/");
$disk_total_space = disk_total_space("/");


function formatSize($size) {
    $units = array('B', 'KB', 'MB', 'GB', 'TB');
    $unit = 0;
    while ($size >= 1024 && $unit < 4) {
        $size /= 1024;
        $unit++;
    }
    return round($size, 2) . " " . $units[$unit];
}


$server_ip = $_SERVER['SERVER_ADDR'];

и
echo "<h1>Информация о сервере</h1>";
echo "<p><strong>Операционная система:</strong> $os_info</p>";
echo "<p><strong>Свободное место на диске:</strong> " . formatSize($disk_free_space) . "</p>";
echo "<p><strong>Общий объем диска:</strong> " . formatSize($disk_total_space) . "</p>";
echo "<p><strong>IP адрес сервера:</strong> $server_ip</p>";
?>
