<?php
// Database connection configuration
$servername = '192.168.0.5';
$username = 'chitetezo';
$password = 'zuzu';
$dbname = 'chitetezo';

// Connect to MariaDB
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die('Connection failed: ' . $conn->connect_error);
}

// Query to retrieve data from the database
$sql = 'SELECT * FROM air_quality   ';

$result = $conn->query($sql);
$data = array();

if ($result->num_rows > 0) {
    // Fetch data and store it in an array
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

// Close the database connection
$conn->close();

// Return the data as JSON
header('Content-Type: application/json');
echo json_encode($data);
?>
