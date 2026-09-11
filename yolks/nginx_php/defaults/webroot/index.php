<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web server is running</title>
    <style>
        body { margin: 0; min-height: 100vh; display: grid; place-items: center; font-family: system-ui, sans-serif; background: #f4f6f8; color: #1f2933; }
        main { max-width: 32rem; margin: 1rem; padding: 2rem; background: #fff; border-radius: 12px; box-shadow: 0 2px 8px rgba(0, 0, 0, .08); text-align: center; }
        h1 { margin-top: 0; font-size: 1.6rem; }
        code { background: #eef1f4; padding: .1rem .35rem; border-radius: 4px; }
    </style>
</head>
<body>
<main>
    <h1>Web server is running</h1>
    <p>PHP <?= htmlspecialchars(PHP_VERSION) ?></p>
    <p>Upload your website into the <code>webroot</code> folder to replace this page.</p>
</main>
</body>
</html>
