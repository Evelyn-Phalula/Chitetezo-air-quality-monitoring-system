<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $name = $_POST["name"];
    $email = $_POST["email"];
    $subject = $_POST["subject"];
    $message = $_POST["message"];
  
    $to = "zuzutech200@gmail.com";
    $headers = "From: " . $email . "\r\n";
    $headers .= "Content-Type: text/plain; charset=UTF-8\r\n";
  
    if (mail($to, $subject, $message, $headers)) {
      echo "Email sent successfully.";
    } else {
      echo "Email sending failed.";
    }
  }
  
?>
