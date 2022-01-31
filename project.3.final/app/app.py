from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
@app.route("/KoffeeLuv")
def hello():
    return "Give me a hit of Koffee Luv"

@app.route("/test")
def test():
    return "OK"

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(debug=True,host='0.0.0.0',port=port)
