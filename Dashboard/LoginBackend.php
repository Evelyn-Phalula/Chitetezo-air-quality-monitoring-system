<?php

// Start a session
session_start();

// Check if the user is already logged in
if (isset($_SESSION['logged_in']) && $_SESSION['logged_in'] == true) {
  // Redirect to the dashboard page
  header('Location: dashboard.php');
  exit;
}

// Check if the form has been submitted
if (isset($_POST['submit'])) {
  // Connect to the database
  $conn = mysqli_connect('localhost', 'username', 'password', 'database');

  // Check the connection
  if (!$conn) {
    die('Connection failed: ' . mysqli_connect_error());
  }

  // Escape the input to prevent SQL injection attacks
  $username = mysqli_real_escape_string($conn, $_POST['username']);
  $password = mysqli_real_escape_string($conn, $_POST['password']);

  // Check if the user exists in the database
  $query = "SELECT * FROM users WHERE username = '$username' AND password = '$password'";
  $result = mysqli_query($conn, $query);
  if (mysqli_num_rows($result) == 1) {
    // Set the session variable and redirect to the dashboard page
    $_SESSION['logged_in'] = true;
    header('Location: dashboard.php');
    exit;
  } else {
    // Display an error message
    $error = 'Invalid username or password';
  }

  // Close the connection
  mysqli_close($conn);
}

?>
<!DOCTYPE html>
<html>
<head>
  <title>Login</title>
</head>
<body>
  <form method="post" action="<?php echo htmlspecialchars($_SERVER['PHP_SELF']); ?>">
    <?php if (isset($error)) { ?>
      <p><?php echo $error; ?></p>
    <?php } ?>
    <label for="username">Username:</label><br>
    <input type="text" name="username" required><br>
    <label for="password">Password:</label><br>
    <input type="password" name="password" required><br><br>
    <input type="submit" name="submit" value="Login">
  </form> 
</body>
</html>
