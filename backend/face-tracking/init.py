import cv2
import mediapipe as mp

# Initialize MediaPipe Face Mesh
mp_face_mesh = mp.solutions.face_mesh
mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles

# Define eye landmarks indices (correct for Face Mesh)
LEFT_EYE_INDICES = list(set([idx for connection in mp_face_mesh.FACEMESH_LEFT_EYE for idx in connection]))
RIGHT_EYE_INDICES = list(set([idx for connection in mp_face_mesh.FACEMESH_RIGHT_EYE for idx in connection]))

# Initialize the video capture
cap = cv2.VideoCapture(0)

with mp_face_mesh.FaceMesh(
    max_num_faces=1,
    refine_landmarks=True,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5
) as face_mesh:
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        # Convert frame to RGB
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = face_mesh.process(frame_rgb)

        if results.multi_face_landmarks:
            for face_landmarks in results.multi_face_landmarks:

                # Draw all face landmarks
                mp_drawing.draw_landmarks(
                    image=frame,
                    landmark_list=face_landmarks,
                    connections=mp_face_mesh.FACEMESH_TESSELATION,
                    landmark_drawing_spec=None,
                    connection_drawing_spec=mp_drawing_styles.get_default_face_mesh_tesselation_style()
                )

                # Highlight left eye (green)
                for idx in LEFT_EYE_INDICES:
                    landmark = face_landmarks.landmark[idx[0]]
                    h, w, _ = frame.shape
                    x, y = int(landmark.x * w), int(landmark.y * h)
                    cv2.circle(frame, (x, y), 2, (0, 255, 0), -1)

                # Highlight right eye (blue)
                for idx in RIGHT_EYE_INDICES:
                    landmark = face_landmarks.landmark[idx[0]]
                    h, w, _ = frame.shape
                    x, y = int(landmark.x * w), int(landmark.y * h)
                    cv2.circle(frame, (x, y), 2, (255, 0, 0), -1)

        # Show the output frame
        cv2.imshow('Eye Movement Tracking', frame)

        # Press ESC to exit
        if cv2.waitKey(1) & 0xFF == 27:
            break

# Release the video capture and close all OpenCV windows
cap.release()
cv2.destroyAllWindows()


cap.release()
cv2.destroyAllWindows()
