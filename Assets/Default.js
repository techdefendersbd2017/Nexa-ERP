
    function togglePassword() {
            var pass = document.getElementById("txtPass");
    var eye = document.getElementById("eyeToggle");
    if (pass.type === "password") {
        pass.type = "text";
    eye.textContent = "HIDE";
            } else {
        pass.type = "password";
    eye.textContent = "SHOW";
            }
        }
