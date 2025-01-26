import os
import json
from datetime import datetime

def create_timestamps_for_photos(folder_path, output_file):
    if not os.path.exists(folder_path):
        print(f"Error: The folder '{folder_path}' does not exist.")
        return
    
    photo_files = [
        f for f in os.listdir(folder_path)
        if isinstance(f, str) and f.lower().endswith(('.jpeg', '.jpg', '.png', '.bmp', '.gif'))
    ]

    if not photo_files:
        print(f"No image files found in the folder '{folder_path}'.")
        return
    
    photo_timestamps = []

    for photo in photo_files:
        photo_path = os.path.join(folder_path, photo)
        mod_time = os.path.getmtime(photo_path)
        timestamp = datetime.fromtimestamp(mod_time).strftime('%Y-%m-%d %H:%M:%S')
        photo_timestamps.append({"filename": photo, "timestamp": timestamp})

    with open(output_file, "w") as f:
        json.dump(photo_timestamps, f, indent=4)
    
    print(f"Timestamps for photos in '{folder_path}' have been saved to '{output_file}'.")

folder_path = os.path.abspath("../../frontend/desktop/StudyForge/screenshots")
output_file = "photo_timestamps.json"
create_timestamps_for_photos(folder_path, output_file)