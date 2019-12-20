# Smart coffee machine on local network

Prodigio smart coffee machines are only accessible through BLE.
This project makes it possible to access it via Web, using a RPi 3 as BLE relay.

This is a research project, as always, use at your own risk.

- brew.sh: Expect script to communicate with the coffee machine
- ph0wn-hack.sh: hack to prepare a 70mL coffee
- ph0wn-reset.sh: reset Lungo cup size to the normal value.
- ph0wn-lungo.sh: prepare a Lungo
- webpresso.py: main Flask app

## Flask

Be sure to activate the flask venv:

```
export FLASK_ENV=development
export FLASK_APP=webpresso.py
python3 -m flask run
```

To deploy:

- In the flask venv: `pip3 install gunicorn `

- Then, `./venv/bin/gunicorn --bind 0.0.0.0:8000 webpresso:app`

