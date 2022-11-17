<?php

define('STDOUT', fopen('php://stdout', 'w'));
error_reporting(E_ALL);

/* Allow the script to hang around waiting for connections. */
set_time_limit(0);


$address = '127.0.0.1';
$port = 8000;

if (($sock = socket_create(AF_INET, SOCK_STREAM, SOL_TCP)) === false) {
    echo "socket_create() failed: reason: " . socket_strerror(socket_last_error()) . "\n";
}

if (socket_bind($sock, $address, $port) === false) {
    echo "socket_bind() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
}

if (socket_listen($sock, 5) === false) {
    echo "socket_listen() failed: reason: " . socket_strerror(socket_last_error($sock)) . "\n";
}

function send_data($msg, $fn = null){
    global $sock;
    
    fwrite(STDOUT, $msg."\n");
    $msgsock = socket_accept($sock);
    fwrite(STDOUT, $msgsock."\n");
    socket_write($msgsock, $msg, strlen($msg));
    // $buf = socket_read($msgsock, 2048, PHP_NORMAL_READ);
    $i=0;
    do{
        $i++;
        fwrite(STDOUT, $i."\n");
        $line = socket_read($msgsock,2048);
        fwrite(STDOUT, "result: ".$line."\n");
        $buf = $line;
    }while($line == "");

    fwrite(STDOUT, $buf."\n");
    socket_close($sock);
    if(is_callable($fn)) return $fn($buf);
    return $buf;
    // $process = 1;
    // $status = true;
    // do{
    //     if($process >= 10){
    //         $status = false;
    //     }
    //     fwrite(STDOUT, $process);
    //     if (($msgsock = socket_accept($sock)) === false) {
    //         $process++;
    //         break;
    //     }
    //     socket_write($msgsock, $msg, strlen($msg));
    //     do{

    //         if (false === ($buf = socket_read($msgsock, 2048, PHP_NORMAL_READ))) {
    //             $process++;
    //             break;
    //         }
    //         if (!$buf = trim($buf)) {
    //             continue;
    //         }

    //         socket_close($sock);

    //         if(is_callable($fn)) return $fn($buf);
    //         return $buf;

    //     }while($status);
    // }while($status);
    // socket_close($sock);

    // if(is_callable($fn)) return $fn(false);
    // return false;

}

// send_data('history_order');

