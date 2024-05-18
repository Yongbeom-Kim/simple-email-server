from flask import Flask, jsonify

app = Flask(__name__)


@app.route('/')
def landing():
    return jsonify(message="Hello World")