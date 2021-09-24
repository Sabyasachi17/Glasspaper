const loginForm = document.getElementById("login-form");
const loginButton = document.getElementById("login-form-submit");
const loginErrorMsg = document.getElementById("login-error-msg");

loginButton.addEventListener("click", (e) => {
    e.preventDefault();
    const username = loginForm.username.value;
    const password = loginForm.password.value;

    if (username === "sabyasachi" && password === "password") {
        alert("You have successfully logged in.");
         window.location.replace("http://localhost:3000")
    } 
    else if(username === "satyaprakash" && password === "password2")
    {
        alert("You have successfully logged in.");
        window.location.replace("http://localhost:3000")

    }
        else {
        loginErrorMsg.style.opacity = 1;
    }
})