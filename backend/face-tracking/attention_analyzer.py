import cv2
import mediapipe as mp
import numpy as np
import base64

class AttentionAnalyzer:
    def __init__(self):
        self.mp_face_mesh = mp.solutions.face_mesh
        self.mp_drawing = mp.solutions.drawing_utils
        self.mp_drawing_styles = mp.solutions.drawing_styles
        
        # Initialize face mesh
        self.face_mesh = self.mp_face_mesh.FaceMesh(
            max_num_faces=1,
            refine_landmarks=True,
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )
        
        # Define important landmarks
        self.left_eye_indices = [33, 133, 145, 153, 160, 173]
        self.right_eye_indices = [362, 382, 384, 387, 263]
        
    def process_frame(self, image_b64):
        # Convert base64 to image
        image_data = base64.b64decode(image_b64)
        nparr = np.frombuffer(image_data, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        # Convert to RGB for MediaPipe
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = self.face_mesh.process(frame_rgb)
        
        if not results.multi_face_landmarks:
            return {
                "attention": False,
                "confidence": 0.0,
                "error": "No face detected"
            }
        
        return self.analyze_attention(results.multi_face_landmarks[0], frame.shape)
    
    def analyze_attention(self, landmarks, frame_shape):
        h, w, _ = frame_shape
        
        # Extract eye landmarks
        left_eye = self._get_eye_metrics(landmarks, self.left_eye_indices, w, h)
        right_eye = self._get_eye_metrics(landmarks, self.right_eye_indices, w, h)
        
        # Calculate attention metrics
        attention_score = self._calculate_attention_score(left_eye, right_eye)
        
        return {
            "attention": attention_score > 0.7,  # Threshold can be adjusted
            "confidence": float(attention_score),
            "metrics": {
                "left_eye": left_eye,
                "right_eye": right_eye
            }
        }
    
    def _get_eye_metrics(self, landmarks, indices, width, height):
        points = [(landmarks.landmark[idx].x * width, 
                  landmarks.landmark[idx].y * height) 
                 for idx in indices]
        
        center = np.mean(points, axis=0)
        
        return {
            "center": center.tolist(),
            "points": [point for point in points],
            "openness": self._calculate_eye_openness(points)
        }
    
    def _calculate_eye_openness(self, points):
        # Calculate vertical distance between top and bottom eye points
        # This is a simplified metric - you can make it more sophisticated
        points = np.array(points)
        y_min = np.min(points[:, 1])
        y_max = np.max(points[:, 1])
        return float(y_max - y_min)
    
    def _calculate_attention_score(self, left_eye, right_eye):
        # Implement your attention scoring logic here
        # This is a basic example - you should enhance this based on your requirements
        
        # Check if eyes are open enough
        eye_openness = (left_eye["openness"] + right_eye["openness"]) / 2
        
        # You can add more sophisticated metrics here:
        # - Eye gaze direction
        # - Head pose
        # - Blink rate
        # - etc.
        
        # Normalize score between 0 and 1
        score = min(max(eye_openness / 30.0, 0.0), 1.0)
        
        return score

    def __del__(self):
        self.face_mesh.close()
