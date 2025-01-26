from flask import Flask, request, jsonify
import base64
from attention_analyzer import AttentionAnalyzer

app = Flask(__name__)
analyzer = AttentionAnalyzer()

@app.route('/')
def index():
    return "Attention Analysis Server Running"

@app.route('/detect', methods=['POST'])
def handle_detect():
    try:
        data = request.json
        image_b64 = data['image']
        
        # Process frame and get attention analysis
        result = analyzer.process_frame(image_b64)
        return jsonify(result)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(port=5000, threaded=True)
