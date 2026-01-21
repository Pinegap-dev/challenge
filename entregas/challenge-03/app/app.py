"""
Just a simple hello-world app.
"""

import os
from flask import Flask


app = Flask(__name__)


def get_name() -> str:
    return os.getenv("NAME", "World")


@app.route("/")
def hello_world():
    name = get_name()
    return f"Hello, {name}!"


if __name__ == "__main__":
    app.run()
