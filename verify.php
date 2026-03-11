<?php

$valid = [
"SyftaIsAngel",
"VerokiHub",
"GardenHorizons"
];

$key = $_GET['key'] ?? '';

if(in_array($key,$valid)){
echo "ok";
}else{
echo "no";
}
