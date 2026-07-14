<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Nexa_ERP.Default" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>ERP Home</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        .bg-slideshow {
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            z-index: -1;
        }

        .bg-slideshow .slide {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background-size: cover;
            background-position: center;
            opacity: 0;
            transition: opacity 1.5s ease-in-out;
        }

        .bg-slideshow .slide.active {
            opacity: 1;
        }

        /* আপনার images folder থেকে ছবি */
        .slide-1 { background-image: url('images/Loginbg1.jpg'); }
        .slide-2 { background-image: url('images/Loginbg2.jpg'); }
        .slide-3 { background-image: url('images/Loginbg3.jpg'); }
        .slide-4 { background-image: url('images/Loginbg4.jpg'); }

        /* Dark overlay */
        .overlay {
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(10, 30, 80, 0.60);
            z-index: 0;
        }

        form {
            position: relative;
            z-index: 1;
        }

        .login-panel {
            display: none;
            max-width: 400px;
            margin: auto;
            margin-top: 80px;
            background: rgba(255, 255, 255, 0.95);
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.3);
        }

        .home-box {
            text-align: center;
            color: white;
            margin-top: 120px;
        }
    </style>
</head>
<body>

    <!-- Background Slideshow -->
    <div class="bg-slideshow">
        <div class="slide slide-1 active"></div>
        <div class="slide slide-2"></div>
        <div class="slide slide-3"></div>
        <div class="slide slide-4"></div>
    </div>

    <!-- Dark Overlay -->
    <div class="overlay"></div>

    <form id="form1" runat="server">
        <div class="home-box" id="homeBox">
            <h1>Welcome to ERP System</h1>
            <p>Smart Business Management</p>
            <button type="button" class="btn btn-warning btn-lg mt-3" onclick="showLogin()">Login</button>
        </div>

        <div class="login-panel" id="loginPanel">
            <h4 class="text-center mb-3">ERP Login</h4>
            <div class="mb-3">
                <label>User Name</label>
                <asp:TextBox ID="txtUser" runat="server" CssClass="form-control" />
            </div>
            <div class="mb-3">
                <label>Password</label>
                <asp:TextBox ID="txtPass" runat="server" TextMode="Password" CssClass="form-control" />
            </div>
            <asp:Button ID="btnLogin" runat="server" Text="Login" OnClick="btnLogin_Click" CssClass="btn btn-primary w-100" />
            <asp:Label ID="lblMessage" runat="server" Text=""></asp:Label>
            <button type="button" class="btn btn-link w-100 mt-2" onclick="hideLogin()">Cancel</button>
        </div>
    </form>

    <script>
        // ========== Slideshow ==========
        const slides = document.querySelectorAll('.bg-slideshow .slide');
        let current = 0;

        setInterval(() => {
            slides[current].classList.remove('active');
            current = (current + 1) % slides.length;
            slides[current].classList.add('active');
        }, 10000); // 10000ms = 10 seconds

        // ========== Login Panel ==========
        function showLogin() {
            document.getElementById("loginPanel").style.display = "block";
        }
        function hideLogin() {
            document.getElementById("loginPanel").style.display = "none";
        }
    </script>
</body>
</html>