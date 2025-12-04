import cv2
import numpy as np
import matplotlib.pyplot as plt

# Load the image
image_path = 'small hole.tiff' 
img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

# Get image dimensions
height, width = img.shape

# Extract horizontal line (center row)
center_row = height // 2
intensity_profile = img[center_row, :]  # All columns at center row

# Plotting the profile
plt.figure(figsize=(10, 5))
plt.plot(range(width), intensity_profile, color='black')
plt.title("Gray Value vs. Distance (Center Row)")
plt.xlabel("Distance (pixels)")
plt.ylabel("Gray Value")
plt.grid(True)
plt.tight_layout()
plt.show()