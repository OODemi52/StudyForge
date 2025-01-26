import os
from datetime import datetime

print("Python envorinment is working!")
def create_timestamps_for_photos(folder_path, output_file = "timestamp.txt"):
    #Check if folder exist
    if not os.path.exists(folder_path):
        print(f"Error: The folder '{folder_path}' does not exist.")
        return
    

    photo_files = [
        f for f in os.listdir(folder_path)
        if isinstance(f,str) and f.lower().endswith(('.jpeg','.jpg', '.png','.bmp','.gif'))
        ]

    if not photo_files:
        print(f"No image files found in the folder '{folder_path}'.")
        return
    
    #Create or overwrite the output file
    with open(output_file, "w") as f:
        f.write("Filename, Timestamp\n")

        for photo in photo_files:
            photo_path = os.path.join(folder_path, photo)


            mod_time = os.path.getmtime(photo_path)
            timestamp = datetime.fromtimestamp(mod_time).strftime('%Y-%m-%d %H:%M:%S')

            f.write(f"{photo},{timestamp}\n")
    
    print(f"Timestamps for photo in '{folder_path}' have been saved to '{output_file}'.")



folder_path = "frontend/desktop/StudyForge/screenshots"
output_file = "photo_timestamp.txt"
create_timestamps_for_photos(folder_path, output_file)

