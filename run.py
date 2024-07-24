import os
import glob
import subprocess

def process_images_with_matlab(directory):
    image_files = glob.glob(os.path.join(directory, '*'))
    
    for image_file in image_files:
        if not image_file.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.gif', '.tiff')):
            continue
        
        command = f"matlab -batch \"process_and_save_image('{image_file}')\""
        try:
            subprocess.run(command, check=True, shell=True)
            print(f"Processed and saved results for {image_file}")
        except subprocess.CalledProcessError as e:
            print(f"Failed to process {image_file}: {e}")

if __name__ == "__main__":
    # TODO: add directory as cli argument
    directory = "dataset"
    process_images_with_matlab(directory)
