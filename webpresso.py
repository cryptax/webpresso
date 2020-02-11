from flask import Flask, render_template, url_for, request
import subprocess

app = Flask(__name__)
app.logger.debug('hello webpresso')

@app.route('/', methods=['GET'])
def index():
    warning = ''
    if request.method == 'GET':
        warning = request.args.get('warning', default='Please place a cup and insert a coffee capsule')
    return render_template('main.html', warning=warning)

def volume(cuptype='0', cupsize='0'):
    app.logger.debug("volume(): cuptype={0} cupsize={1}".format(cuptype, cupsize))
    message = 'Successfully modified cup size'
    try:
        result = subprocess.check_output([ './custom-volume.sh', cuptype, cupsize ])
        app.logger.debug('volume(): custom-volume.sh returned: {0}'.format(result))
    except subprocess.CalledProcessError as e:
        app.logger.error('Volume script failed with an error: {0}'.format(e))
        message = 'Error when setting cup size'

        if e.returncode == 2 or e.returncode == 3:
            message = 'BLE connection failed'

        if e.returncode == 6:
            message = 'Authorization code has probably changed. Check it'


    app.logger.debug("volume(): message={0}".format(message))
    return message
    

def brew(request, cuptype='0'):
    app.logger.debug("brew(): cuptype={0}".format(cuptype))
    if request.method == 'GET':
        return render_template('waiting.html', warning='Please wait...', url=request.path)

    if request.method == 'POST':
        message = 'Enjoy your coffee!'
        try:
            result = subprocess.check_output([ './brew.sh', cuptype ])
            app.logger.debug("brew(): ./brew.sh returned {0}".format(result))
        except subprocess.CalledProcessError as e:
            app.logger.error('Brew script failed with an error: {0}'.format(e.returncode))
            message = 'Error: something strange occurred:  {0}'.format(e)
                
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

@app.route('/volume', methods=['GET', 'POST'])
def customize_volume():
    try:
        cupsize = int(request.args.get('volume', default='110'))
        cuptype = request.args.get('cuptype')
        message = volume( cuptype, "%02x" % (cupsize))
    except ValueError as e:
        message = 'Bad input value'
        app.logger.error("Bad input value: {0}".format(e))
    return render_template('main.html', warning=message)    


if __name__ == "__main__":
    app.run(host='0.0.0.0')
