from flask import Flask, render_template, url_for, request
import subprocess

app = Flask(__name__)
app.logger.debug('hello')

@app.route('/', methods=['GET'])
def index():
    warning = ''
    if request.method == 'GET':
        warning = request.args.get('warning', default='Please place a cup and insert a coffee capsule')
    return render_template('main.html', warning=warning)

def brew(request, cuptype='0'):
    if request.method == 'GET':
        return render_template('waiting.html', warning='Please wait...', url=request.path)

    if request.method == 'POST':
        message = 'Enjoy your coffee!'
        try:
            result = subprocess.check_output([ './brew.sh', cuptype ], shell=True)
        except subprocess.CalledProcessError as e:
            app.logger.error('Brew script failed with an error: {0}'.format(e.returncode))
            if e.returncode == 1 or e.returncode == 4 or e.returncode == 5 or e.returncode == 7 or e.returncode == 8 or e.returncode == 9 or e.returncode == 10:
                message = 'Error {0}: something strange occurred'.format(e)
                
            if e.returncode == 2 or e.returncode == 3:
                message = 'BLE connection failed'

            if e.returncode == 6:
                message = 'Authorization code has probably changed. Check it'

            if e.returncode == 11:
                message = 'Unsupported cup size'

            if e.returncode == 12:
                message = 'The slider is open. Please go and close it.'

            if e.returncode == 13:
                message = 'You havent inserted any coffee capsule since last time. Please open the slider, insert a coffee capsule and close the slider'

            if e.returncode == 14:
                message = 'Not enough water. Please fill the water tank'

    app.logger.debug("The message is: {0}".format(message))
    return message

@app.route('/ristretto', methods=['GET', 'POST'])
def brew_ristretto():
    return brew(request, '0')

@app.route('/espresso', methods=['GET', 'POST'])
def brew_espresso():
    return brew(request, '1')

@app.route('/lungo', methods=['GET', 'POST'])
def brew_lungo():
    return brew(request, '2')

if __name__ == "__main__":
    app.run(host='0.0.0.0')
