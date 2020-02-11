# Smart coffee machine on local network

[Prodigio smart coffee machines](https://www.nespresso.com/fr/fr/prodigio-machines-range) are only accessible through **Bluetooth Low Energy (BLE)**.
This project makes it possible to access them via HTTP/HTTPS, using a RPi 3 as BLE relay.

Additionally, this project allows to **customize the volume of cups**, a feature which is not currently available through the smartphone app.

*This is a research project, as always, use at your own risk.*

## Webpresso

The idea is to use a **RPi 3 (or +) to handle all BLE communications**.
You **no longer pair your smartphone with the coffee machine**.

On the RPi 3,

- [Install Raspbian](https://www.raspberrypi.org/downloads/raspbian/)
- `sudo apt-get install python3-pip bluez expect`
- Install **Flask** and **Gunicorn** (better: do it a virtual environment using `venv`): `pip3 install flask gunicorn`
- **Get your own authorization code** (see section below) and patch `brew.sh` and `custom-volume.sh`:

```
send_user "Sending authorization code..."
send "char-write-req 0x0014 YOUR-CODE-HERE\r"
```

- Launch Flask: `gunicorn --bind 0.0.0.0:8000 webpresso:app`
- Connect to `http://your-host:port`

## Getting the authorization code

To get your authorization code, I suggest:

1. Install the mobile app on your phone
2. Sniff Bluetooth communication on your smartphone. [On Android, this is how to do it](https://www.bluetooth.com/blog/debugging-bluetooth-with-an-android-app/)
3. Use the mobile app to discover the coffee machine and connect to it
4. Brew  a coffee using the app
5. Collect the Bluetooth traces and view them with Wireshark for instance
6. Locate an ATT Write Request on handle 0x0014. Its value contains the authorization code.

## Troubleshooting

- If you get BLE errors (disconnects, or any strange error), install **bluez 5.50+**. I encountered many errors with older versions, they solved with 5.50.
- Make sure your coffee machine is within BLE range
- Power on your coffee machine by opening/closing the slider
- Ensure the slider is closed
- Ensure **no other device is paired with the coffee machine**
- If you manage to connect and pair to the coffee machine but are unable to brew a coffee, it's likely that your authorization code is incorrect. Check it again: it changes when the coffee machine is reset.
- Try to brew coffee using the scripts rather that the web interface to rule out Flask issues
- Use the development version of Flask, instead of deploying with gunicorn.

```
export FLASK_ENV=development
export FLASK_APP=webpresso.py
python3 -m flask run
```


## Scripts

- `brew.sh`: Expect script to communicate with the coffee machine and brew coffee. This script expects one argument: 0 for ristretto, 1 for espresso and 2 for Lungo.

```
./brew.sh 0
```

It is possible to comment out `bluetoothctl` output by uncommenting this line of `brew.sh`:

```
#log_user 0
```

- `custom-volume.sh`: Expect script to customized the volume of cups. This script expects 2 arguments: the first one is the cup to customize (0 for ristretto, 1 for espresso and 2 for Lungo). The second argument should be the hexadecimal value of the volume in ml.

```
./custom-volume 2 6e
```

- `webpresso.py`: main Flask app

The other scripts are solutions to Ph0wn CTF challenge:

- `ph0wn-hack.sh`: hack to prepare a 70mL coffee
- `ph0wn-reset.sh`: reset Lungo cup size to the normal value.
- `ph0wn-lungo.sh`: prepare a Lungo

## Documentation

- `technotes.md`: tech notes on the coffee machine.

