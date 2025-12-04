import cv2
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import CheckButtons
from scipy.ndimage import gaussian_filter1d
import time

# Start timer
start_time = time.time()

# Load grayscale image
image_path = 'scratch 4.tiff'
img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

# Image dimensions
height, width = img.shape

# Define center row and average band
center_row = height // 2
num_rows_to_average = 20
half_band = num_rows_to_average // 2

# Average a band of rows around the center
row_band = img[center_row - half_band : center_row + half_band + 1, :]
avg_intensity_profile = row_band.mean(axis=0)

# Sigma values for smoothing
sigma_values = [5, 10, 25, 50]
colors = ['blue', 'green', 'orange', 'red']

# Plot setup
fig, ax = plt.subplots(figsize=(12, 6))
plt.subplots_adjust(left=0.2)

x = np.arange(len(avg_intensity_profile))

# Plot original profile
orig_line, = ax.plot(x, avg_intensity_profile, color='gray', linewidth=1, label='Original Averaged')

# Plot smoothed profiles
smoothed_lines = []
for sigma, color in zip(sigma_values, colors):
    smoothed = gaussian_filter1d(avg_intensity_profile, sigma=sigma)
    line, = ax.plot(x, smoothed, label=f'Sigma = {sigma}', color=color, linewidth=2)
    smoothed_lines.append(line)

# --- Local variance computation ---
window_size = 25
pad = window_size // 2
padded_profile = np.pad(avg_intensity_profile, pad, mode='reflect')
local_variance = np.array([
    np.var(padded_profile[i:i+window_size])
    for i in range(len(avg_intensity_profile))
])

# --- Shade high and low variance regions ---
high_threshold = np.percentile(local_variance, 90)
low_threshold = np.percentile(local_variance, 10)

# Create masks
high_var_mask = local_variance > high_threshold
low_var_mask = local_variance < low_threshold

# Fill between where high/low variance is true
ax.fill_between(x, avg_intensity_profile.min(), avg_intensity_profile.max(),
                where=high_var_mask, color='red', alpha=0.2, label='High Variance')

ax.fill_between(x, avg_intensity_profile.min(), avg_intensity_profile.max(),
                where=low_var_mask, color='green', alpha=0.2, label='Low Variance')

# Labeling
ax.set_title(f"Smoothed Intensity Profiles (Rows {center_row - half_band} to {center_row + half_band})")
ax.set_xlabel("Distance (pixels)")
ax.set_ylabel("Gray Value")
ax.grid(True)

# Checkboxes
labels = ['Original Averaged'] + [f'Sigma = {s}' for s in sigma_values]
lines = [orig_line] + smoothed_lines

rax = plt.axes([0.01, 0.3, 0.15, 0.4])
check = CheckButtons(rax, labels, [True] * len(labels))

def toggle_visibility(label):
    index = labels.index(label)
    lines[index].set_visible(not lines[index].get_visible())
    plt.draw()

check.on_clicked(toggle_visibility)

# Runtime output
print(f"Runtime: {time.time() - start_time:.4f} seconds")

# Show plot
plt.legend(loc='lower right')
plt.show()
