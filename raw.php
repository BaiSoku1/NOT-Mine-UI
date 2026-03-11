<?php

$token = $_GET['token'] ?? '';

$key = base64_decode($token);

$valid = [
"SyftaIsAngel",
"VerokiHub",
"GardenHorizons"
];

if(!in_array($key,$valid)){
die("denied");
}

header("Content-Type: text/plain");

echo file_get_contents("../data/script.lua");
