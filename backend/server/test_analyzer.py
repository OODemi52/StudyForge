import cv2
import base64
import requests
import numpy as np
from time import sleep

def test_with_webcam():
    cap = cv2.VideoCapture(0)
    
    while True:
        ret, frame = cap.read()
        if not ret:
            break

        _, buffer = cv2.imencode('.jpg', frame)
        image_b64 = base64.b64encode(buffer).decode('utf-8')

        try:
            response = requests.post('http://127.0.0.1:5000/detect',
                                     json={'image': image_b64})
            result = response.json()

            attention_status = "Attentive" if result.get('attention', False) else "Not Attentive"
            confidence = result.get('confidence', 0.0)
            
            cv2.putText(frame, f"Status: {attention_status}", (10, 30),
                        cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
            cv2.putText(frame, f"Confidence: {confidence:.2f}", (10, 70),
                        cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
           
            save_response = requests.post('http://127.0.0.1:5000/save', json=result)
            if save_response.status_code != 200:
                print(f"Failed to save data: {save_response.json()}")
            
        except Exception as e:
            print(f"Error: {e}")
            
        cv2.imshow('Attention Analysis Test', frame)
        
        if cv2.waitKey(1) & 0xFF == 27:
            break
            
        sleep(0.1)
    
    cap.release()
    cv2.destroyAllWindows()

if __name__ == "__main__":
    test_with_webcam()