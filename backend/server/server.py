import json
from multiprocessing import Process
import subprocess
from flask import Flask, request, jsonify
import os
import sys
import logging

from flask_cors import CORS

app = Flask(__name__)
CORS(app)

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from face_tracking.analyzer import AttentionAnalyzer

app = Flask(__name__)
analyzer = AttentionAnalyzer()

@app.route('/')
def index():
    return "Attention Analysis Server Running"

@app.route('/detect', methods=['POST'])
def handle_detect():
    try:
        data = request.get_json()
        if not data or 'image' not in data:
            logger.error("Invalid request data")
            return jsonify({"error": "Invalid request data"}), 400
            
        image_b64 = data['image']
        if not image_b64:
            logger.error("Empty image data")
            return jsonify({"error": "Empty image data"}), 400
        
        result = analyzer.process_frame(image_b64)
        
        # Log the results of the face detection
        logger.info(f"Face detection result: {result}")
        
        # Save result to the aggregated JSON file asynchronously
        save_process = Process(target=save_to_aggregated_data, args=(result,))
        save_process.start()
        
        return jsonify(result)
    except Exception as e:
        logger.error(f"Server error: {str(e)}", exc_info=True)
        return jsonify({"error": str(e)}), 500

@app.route('/save', methods=['POST'])
def handle_save():
    try:
        data = request.get_json()
        if not data:
            logger.error("Invalid request data")
            return jsonify({"error": "Invalid request data"}), 400
        
        save_to_aggregated_data(data)
        return jsonify({"status": "success"})
    except Exception as e:
        logger.error(f"Server error: {str(e)}", exc_info=True)
        return jsonify({"error": str(e)}), 500

@app.route('/start_test_analyzer', methods=['GET'])
def run_test_analyzer():
    try:
        python_executable = os.path.join(os.path.dirname(sys.executable), 'python')
        script_path = os.path.join(os.path.dirname(__file__), 'test_analyzer.py')
        subprocess.Popen([python_executable, script_path])
        script_abs_path = os.path.abspath(script_path)
        subprocess.Popen(['../../venv/bin/python', script_abs_path])
        return jsonify({"status": "Test analyzer started"})
    except Exception as e:
        logger.error(f"Failed to start test analyzer: {str(e)}", exc_info=True)
        return jsonify({"error": str(e)}), 500
        
    
@app.route('/stop_test_analyzer', methods=['GET'])
def stop_test_analyzer():
    try:
        subprocess.run(['pkill', '-f', 'test_analyzer.py'])
        return jsonify({"status": "Test analyzer stopped"})
    except Exception as e:
        logger.error(f"Failed to stop test analyzer: {str(e)}", exc_info=True)
        return jsonify({"error": str(e)}), 500

aggregated_data_file = os.path.join(os.path.dirname(__file__), '..', 'data', 'aggregated_data.json')

def save_to_aggregated_data(data):
    try:
        if os.path.exists(aggregated_data_file):
            try:
                with open(aggregated_data_file, 'r') as f:
                    aggregated_data = json.load(f)
            except json.JSONDecodeError:
                aggregated_data = []
        else:
            aggregated_data = []

        aggregated_data.append(data)

        with open(aggregated_data_file, 'w') as f:
            json.dump(aggregated_data, f, indent=4)
        
        logger.info("Data saved to aggregated JSON file.")
    except Exception as e:
        logger.error(f"Failed to save data to file: {str(e)}")

if __name__ == '__main__':
    app.run(port=5000, threaded=True)

