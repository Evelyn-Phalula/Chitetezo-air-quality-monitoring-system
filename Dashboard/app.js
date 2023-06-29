
    // Initialize Firebase
    const firebaseConfig = {
      apiKey: "AIzaSyB2Q6xo_lzKKa_BwSEFXms_IXkA8GB1-Fc",
      authDomain: "chitetezodashboard.firebaseapp.com",
      projectId: "chitetezodashboard",
      storageBucket: "chitetezodashboard.appspot.com",
      messagingSenderId: "593870165377",
      appId: "1:593870165377:web:f0f81c7d2c70218ddf4480",
      measurementId: "G-53MJN4R477"
    };
    
    firebase.initializeApp(firebaseConfig);
  // Register form submission
var registerForm = document.getElementById("register-form");
if (registerForm) {
  registerForm.addEventListener("submit", function (event) {
    event.preventDefault();
  
    var phone = document.getElementById("phone").value;
  
    var appVerifier = new firebase.auth.RecaptchaVerifier('recaptcha-container', {
      size: 'invisible',
    });
  
    firebase
      .auth()
      .signInWithPhoneNumber(phone, appVerifier)
      .then(function (confirmationResult) {
        window.confirmationResult = confirmationResult; // Store confirmation result for later use
  
        // SMS verification sent
        console.log("SMS verification sent.");
  
        // Prompt for verification code
        var verificationCode = window.prompt("Enter the verification code we sent to your phone:");
  
        confirmationResult
          .confirm(verificationCode)
          .then(function (result) {
            // Phone number registration or login successful, do something (e.g., redirect to another page)
            window.location.href = "../login.html";
          })
          .catch(function (error) {
            // Handle verification errors
            console.log(error.message);
          });
      })
      .catch(function (error) {
        // Handle sending SMS verification errors
        console.log(error.message);
      });
  });
}

// Login form submission
var loginForm = document.getElementById("login-form");
if (loginForm) {
  loginForm.addEventListener("submit", function (event) {
    event.preventDefault();
  
    var phone = document.getElementById("login-phone").value;
  
    var appVerifier = new firebase.auth.RecaptchaVerifier('recaptcha-container', {
      size: 'invisible',
    });
  
    firebase
      .auth()
      .signInWithPhoneNumber(phone, appVerifier)
      .then(function (confirmationResult) {
        window.confirmationResult = confirmationResult; // Store confirmation result for later use
  
        // SMS verification sent
        console.log("SMS verification sent.");
  
        // Prompt for verification code
        var verificationCode = window.prompt("Enter the verification code we sent to your phone:");
  
        confirmationResult
          .confirm(verificationCode)
          .then(function (result) {
            // Phone number login successful, do something (e.g., redirect to another page)
            window.location.href = "../home.html";
          })
          .catch(function (error) {
            // Handle verification errors
            console.log(error.message);
          });
      })
      .catch(function (error) {
        // Handle sending SMS verification errors
        console.log(error.message);
      });
  });
}