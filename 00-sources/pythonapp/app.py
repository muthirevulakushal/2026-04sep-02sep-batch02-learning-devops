from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello Kushal from Docker + Kubernetes! for V03.0.....Release by Kushal , DevOps Engg...04Sep2026 for Batch2.....You are Awesome"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)