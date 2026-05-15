from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "Good job this Friday afternoon 4th attempt!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)