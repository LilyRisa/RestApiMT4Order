<?php
include './socket.php';
$route = explode('api/', $_SERVER["REQUEST_URI"]);
$endpoint = end($route);


switch($endpoint){
    case 'history_order':
        $data = send_data('history_order', function($result){
            $data = json_decode($result);
            var_dump($data);
            foreach($data as $key => $item){
                if($item->order_symbol == ''){
                    unset($data[$key]);
                }
            }
            return $data;
        });
        
    break;
}
die();

?>