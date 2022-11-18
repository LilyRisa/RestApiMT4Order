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

function send_data($msg, $data_post, $fn = null, $merge = false){
    global $sock;
    
    $data_param_socket = '';
    if(!empty($data_post)){
        foreach($data_post as $k => $v){
            $data_param_socket .= "|$k=$v"; 
        }
    }
    // fwrite(STDOUT, $msg."\n");
    $msgsock = socket_accept($sock);
    // fwrite(STDOUT, $msgsock."\n");
    socket_write($msgsock, $msg.$data_param_socket, strlen($msg.$data_param_socket));
    // $buf = socket_read($msgsock, 2048, PHP_NORMAL_READ);
    $i=0;
    $buf = '';


    if($merge){
        $data_arr = [];
        do{
            $i++;
            fwrite(STDOUT, $i."\n");
            $line = socket_read($msgsock,6048);
            fwrite(STDOUT, "result: ".$line."\n");
            $data_arr[] = $line;
            if (strpos($line, '@end') !== false) break;
        }while(true);

        $data_raw = [];

        if(!empty($data_arr)){
            foreach($data_arr as $item){
                $item = str_replace('@end', '', $item);
                $tmp = explode('}',$item);
                if(count($tmp) >= 2){
                    foreach($tmp as $t){
                        if($t != '}') $data_raw[] = $t.'}';
                    }
                }else{
                    $data_raw[] = $item;
                }
            }
    
            foreach($data_raw as $key => $value){
                $data_raw[$key] = json_decode($value);
            }
        }else{
            if(is_callable($fn)) return $fn([]);
                return [];
        }
        
        if(is_callable($fn)) return $fn($data_raw);
        return $data_raw;
    }
    
    do{
        $i++;
        fwrite(STDOUT, $i."\n");
        $line = socket_read($msgsock,6048);
        fwrite(STDOUT, "result: ".$line."\n");
        $buf = $line;
    }while($line == "");

    // while (($currentByte = socket_read($msgsock,6048, PHP_NORMAL_READ)) != "") {
    //     // Do whatever you wish with the current byte
    //     $buf .= $currentByte;
    // }
   
    fwrite(STDOUT, $buf."\n");
    socket_close($sock);
    if(is_callable($fn)) return $fn($buf);
    return $buf;

}

// send_data('history_order');

