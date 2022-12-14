<?php
include './socket.php';
$route = explode('api/', $_SERVER["REQUEST_URI"]);
$endpoint = end($route);

header('Content-Type: application/json; charset=utf-8');

if($endpoint == 'history_order'){
    $data = send_data($endpoint, $_POST , function($result){
        $data = array_filter($result);
        if(!empty($data)) return array_values($data);
        return $data;
    }, true);
    
    echo json_encode($data);
    die();
}


$data = send_data($endpoint, $_POST , function($result){
    $data = json_decode($result);
    if(!is_array($data)) return $data;
    foreach($data as $key => $item){
        if(!isset($item->order_symbol)) return $data;
        if($item->order_symbol == ''){
            unset($data[$key]);
        }
    }
    return array_values($data);
});

echo json_encode($data);


die();

?>