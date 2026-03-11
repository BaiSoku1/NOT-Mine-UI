<?php

$key = $_GET['key'];

$valid = "SYFTA_ACCESS";

if($key !== $valid){
    die("invalid key");
}

header("Content-Type: text/plain");

$script = file_get_contents("script.lua");

echo $script;

?>
