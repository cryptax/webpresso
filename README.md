# Smart coffee machine on local network

[Prodigio smart coffee machines](https://www.nespresso.com/fr/fr/prodigio-machines-range) are only accessible through BLE.
This project makes it possible to access it via HTTP/HTTPS, using a RPi 3 as BLE relay.

*This is a research project, as always, use at your own risk.*

- `brew.sh`: Expect script to communicate with the coffee machine
- `ph0wn-hack.sh`: hack to prepare a 70mL coffee
- `ph0wn-reset.sh`: reset Lungo cup size to the normal value.
- `ph0wn-lungo.sh`: prepare a Lungo
- `webpresso.py`: main Flask app
- `technotes.md`: tech notes on the coffee machine.

## Scripts

- Install **Bluez 5.50+**. Note that I encountered several errors / disconnect issues with older versions.
- `sudo apt-get install expect`
- Plug the smart coffee machine within BLE range
- **Get your own authorization code and patch the script:

```
send_user "Sending authorization code..."
send "char-write-req 0x0014 YOUR-CODE-HERE\r"
```

- Ensure no other device is paired with the smart coffee machine
- Insert a capsule
- Launch a script, for example `ph0wn-lungo.sh` will prepare a Lungo for  you.

### Getting the authorization code

To get your authorization code, I suggest:

1. Install the mobile app on your phone
2. Sniff Bluetooth communication on your smartphone. [On Android, this is how to do it](https://www.bluetooth.com/blog/debugging-bluetooth-with-an-android-app/)
3. Use the mobile app to discover the coffee machine and connect to it
4. Brew  a coffee using the app
5. Collect the Bluetooth traces and view them with Wireshark for instance
6. Locate an ATT Write Request on handle 0x0014. Its value contains the authorization code.



## Web interface for the coffee machine

This is a small web interface to the coffee machine. The idea is to pilot the coffee machine via HTTP/HTTPS, so that people with access to this web interface may brew coffee.
The host that hosts the web interface acts the unique BLE client to the smart coffee machine, and therefore *expands* BLE range to Web/Wifi range.
Typically, the host is intended to be a Raspberry Pi 3 (or +). It can be any host which supports BLE, python and Flask.

On the host which runs this web interface:

1. Ensure the scripts work
2. Then deploy the web interface
3. Ensure the host is available on your Intranet or wherever you want the functionality (probably **not** on Internet!).


Be sure to activate the flask venv:

```
export FLASK_ENV=development
export FLASK_APP=webpresso.py
python3 -m flask run
```

To deploy:

- In the flask venv: `pip3 install gunicorn `
- Then, `./venv/bin/gunicorn --bind 0.0.0.0:8000 webpresso:app`

