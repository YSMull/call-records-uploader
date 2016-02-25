<?php
if($_SERVER["REQUEST_METHOD"] == "POST") {
	include "connection.php";
	insert();
}

function insert()
{
	global $connect;
	$date = $_POST["date"];
	$number = $_POST["number"];
	$duration = $_POST["duration"];
	$type = $_POST["type"];
	$query = " insert into phone_data values ('$date','$number', '$duration', '$type')";
	mysqli_query($connect, $query) or die(mysqli_error($connect));
	mysqli_close($connect);	
}
?>

