import io
import subprocess
from flask import Flask, request, send_file, jsonify
import soundfile as sf
from dia.model import Dia

app = Flask(__name__)

@app.route('/hello', methods=['GET'])
def hello():
    return 'Hello World', 200

# Load the model once at startup (GPU-enabled)
model = Dia.from_pretrained("nari-labs/Dia-1.6B")

@app.route('/generate', methods=['POST'])
def generate():
    data = request.get_json()
    if not data or 'text' not in data:
        return jsonify({'error': 'No text provided'}), 400
    text = data['text']

    # Generate raw audio samples (numpy array)
    audio = model.generate(text)

    # Write to in-memory WAV
    wav_buf = io.BytesIO()
    sf.write(wav_buf, audio, 44100, format='WAV')
    wav_buf.seek(0)

    # Convert WAV to MP3 via ffmpeg subprocess
    proc = subprocess.Popen(
        ['ffmpeg', '-i', 'pipe:0', '-f', 'mp3', '-codec:a', 'libmp3lame', 'pipe:1'],
        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    mp3_data, _ = proc.communicate(wav_buf.read())

    # Return MP3 to client
    return send_file(
        io.BytesIO(mp3_data),
        mimetype='audio/mpeg',
        as_attachment=True,
        download_name='output.mp3'
    )

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5023)