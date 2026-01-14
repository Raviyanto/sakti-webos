from flask import Flask, render_template, request, jsonify, redirect, url_for
import subprocess
import os
import shutil

app = Flask(__name__, 
            template_folder='../frontend/templates',
            static_folder='../frontend/static')

BASE_DIR = "/home/kioskuser"

def jalankan(perintah):
    env = os.environ.copy()
    env["DISPLAY"] = ":0"
    env["XAUTHORITY"] = "/home/kioskuser/.Xauthority"
    subprocess.Popen(perintah, shell=True, env=env)

def jalankan_sistem(perintah):
    env = os.environ.copy()
    env["DISPLAY"] = ":0"
    env["XAUTHORITY"] = "/home/kioskuser/.Xauthority"
    subprocess.Popen(f"sudo {perintah}", shell=True, env=env)

# --- FITUR BARU: SPLASH SCREEN ---
@app.route('/')
def start():
    return render_template('splash.html')

@app.route('/homepage')
def index(): 
    return render_template('index.html')

# --- FITUR LAMA (TETAP PATEN) ---
@app.route('/kalkulator')
def ui_calc(): return render_template('kalkulator.html')

@app.route('/notepad')
def ui_notepad(): return render_template('notepad.html')

@app.route('/filemanager')
def ui_fm(): return render_template('filemanager.html')

@app.route('/browser')
def ui_browser(): return render_template('browser.html')

@app.route('/api/open-native-browser')
def api_open_browser():
    jalankan("python3 /home/kioskuser/browser_sakti.py")
    return jsonify({"status": "success"})

@app.route('/reboot-page')
def ui_reboot(): return render_template('reboot.html')

@app.route('/shutdown-page')
def ui_shutdown(): return render_template('shutdown.html')

@app.route('/api/reboot')
def api_reboot():
    jalankan_sistem("/sbin/reboot -f")
    return "<h1>SaktiOS sedang Reboot...</h1>"

@app.route('/api/shutdown')
def api_shutdown():
    jalankan_sistem("/sbin/poweroff -f")
    return "<h1>SaktiOS sedang Shutdown...</h1>"

@app.route('/api/files')
def list_files():
    files = [{"name": e.name, "is_dir": e.is_dir(), "size": e.stat().st_size if e.is_file() else 0} for e in os.scandir(BASE_DIR)]
    return jsonify(files)

@app.route('/api/read-file')
def read_file():
    filename = request.args.get('file')
    path = os.path.join(BASE_DIR, filename)
    with open(path, 'r') as f:
        return jsonify({"content": f.read()})

@app.route('/api/save-note', methods=['POST'])
def save_note():
    data = request.json
    filename = data.get('filename', 'catatanbaru.txt')
    content = data.get('content', '')
    path = os.path.join(BASE_DIR, filename)
    with open(path, 'w') as f:
        f.write(content)
    return jsonify({"status": "success"})

@app.route('/api/delete-file', methods=['POST'])
def del_file():
    path = os.path.join(BASE_DIR, request.json.get('file'))
    if os.path.isfile(path): os.remove(path)
    return jsonify({"status": "success"})

@app.route('/api/rename-file', methods=['POST'])
def ren_file():
    data = request.json
    os.rename(os.path.join(BASE_DIR, data.get('old_name')), os.path.join(BASE_DIR, data.get('new_name')))
    return jsonify({"status": "success"})

if __name__ == '__main__':
    if os.environ.get('WERKZEUG_RUN_MAIN') != 'true':
        os.system("rm -f /home/kioskuser/.serverauth.* > /dev/null 2>&1")
        os.system("fuser -k 5000/tcp > /dev/null 2>&1")
    app.run(host='0.0.0.0', port=5000, debug=True)
