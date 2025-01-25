import cv2
import mediapipe as mp

# Initialize MediaPipe Face Mesh
mp_face_detection = mp.solution.face_detection
mp_drawing =  mp.solution.drawing_utils
mp_drawing_styles = mp.solution.drawing_styles


cap = cv2.VideoCapture(0)

with mp_face_detection.FaceDetection(
    max_num_faces = 1,
    refine_landmarks = True,
    min_detection_confidence = 0.5,
    min_tracking_confidence = 0.5
) as face_mesh:
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        #convert frame to RGB
        frame_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        results = face_mesh.process(frame_rgb)

        #Draw face mesh landmarks
        if results.multi_face_landmarks:
            for face_landmarks in results.multi_face_landmarks:
                mp_drawing.dram_landmarks(
                    frame,
                    face_landmarks,
                    mp_face_detection.FACEMESH_CONTOURS,
                    landmark_drawing_spec = None,
                    connection_drawing_spec = mp_drawing_styles.get_default_face_mesh_contours_styles())
                
                left_eye_indicies = [33,133,145,153,160,173]
                right_eye_indicies = [362,382,384,387,263]


                #Higlight left eye
                for idx in left_eye_indicies:
                    landmark = face_landmarks.landmark[idx]
                    h,w,_ = frame.shape
                    x, y = int(landmark.x * w), int(landmark.y * h)
                    cv2.circle(frame, (x,y), 2, (0, 255, 0), -1)
                
                #Highlight right eye
                for idx in right_eye_indicies:
                    landmark = face_landmarks.landmark[idx]
                    h,w,_ = frame.shape
                    x, y = int(landmark.x * w), int(landmark.y * h)
                    cv2.circle(frame, (x,y), 2, (255, 0, 0), -1)

        cv2.imshow('Eye Movement Tracking', frame)

        if cv2.waitKey(1) & 0xFF == 27: # Press ESC to exit
            break

cap.release()
cv2.destroyAllWindows()