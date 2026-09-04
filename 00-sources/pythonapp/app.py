from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def home():
    return render_template('home.html')

@app.route("/health")
def health():
    return {"status": "healthy", "version": "12.0", "environment": "production"}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)