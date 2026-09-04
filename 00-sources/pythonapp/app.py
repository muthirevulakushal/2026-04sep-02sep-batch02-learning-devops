from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    html_content = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>DevOps Platform - Kubernetes & Docker</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }
            .container {
                width: 100%;
                max-width: 900px;
                background: white;
                border-radius: 10px;
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
                padding: 40px;
                text-align: center;
            }
            h1 {
                color: #667eea;
                font-size: 2.5em;
                margin-bottom: 10px;
            }
            p {
                color: #666;
                font-size: 1.1em;
                margin-bottom: 20px;
            }
            .info {
                background: #f0f4ff;
                border-left: 4px solid #667eea;
                padding: 15px;
                margin: 20px 0;
                text-align: left;
                border-radius: 5px;
            }
            .status {
                display: inline-block;
                background: #4caf50;
                color: white;
                padding: 10px 20px;
                border-radius: 5px;
                margin-top: 20px;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 DevOps Platform</h1>
            <p>Kubernetes & Docker Deployment</p>
            <div class="info">
                <p><strong>Release:</strong> V11.0</p>
                <p><strong>Date:</strong> 04 September 2026</p>
                <p><strong>Batch:</strong> Batch 2 - Learning DevOps</p>
                <p><strong>Engineer:</strong> Kumarans (DevOps)</p>
            </div>
            <p style="color: #764ba2; font-weight: bold; font-size: 1.3em;">✨ You are AWSome ✨</p>
            <div class="status">✓ Application Running</div>
        </div>
    </body>
    </html>
    """
    return html_content

@app.route("/health")
def health():
    return {"status": "healthy", "version": "12.0", "environment": "production"}, 200