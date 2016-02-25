<?php
	
header("Access-Control-Allow-Origin: *");
if($_SERVER["REQUEST_METHOD"] == "POST") {
    include 'connection.php';
    show();
}

function show()
{
    global $connect;
    $query = "select date from phone_data order by date desc limit 0,1;";
    $result = mysqli_query($connect, $query);
    $number_of_rows = mysqli_num_rows($result);

    $temp_array = array();
	if($number_of_rows > 0) {
		while($row = mysqli_fetch_assoc($result)) {
			$temp_array[] = $row;
		}
	}
	header('Content-Type: application/json');
	echo json_encode(array("last_date" => $temp_array));
	//var_dump($temp_array);
	mysqli_close($connect);
}







?>
