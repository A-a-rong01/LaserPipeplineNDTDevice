import cv2
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import CheckButtons
from scipy.ndimage import gaussian_filter1d
import time
from scipy.signal import find_peaks

# Start timer
start_time = time.time()

# Load the image
image_path = 'scratch 2.tiff'
img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

# Get image dimensions
height, width = img.shape

# Define a few rows around the center row for averaging
center_row = height // 2
num_rows_to_average = 20
half_band = num_rows_to_average // 2

# Get the band of rows and compute the average across them
row_band = img[center_row - half_band : center_row + half_band + 1, :]
avg_intensity_profile = row_band.mean(axis=0)

# Define sigma values for smoothing
sigma_values = [5, 10, 25, 50]
colors = ['blue', 'green', 'orange', 'red']

# Create figure and axis
fig, ax = plt.subplots(figsize=(12, 6))
plt.subplots_adjust(left=0.2)  # Make space for checkboxes

x = np.arange(len(avg_intensity_profile))

# Plot original line
orig_line, = ax.plot(x, avg_intensity_profile, color='gray', linewidth=1, label='Original Averaged')

# Plot smoothed lines and store their Line2D objects
smoothed_lines = []
for sigma, color in zip(sigma_values, colors):
    smoothed = gaussian_filter1d(avg_intensity_profile, sigma=sigma)
    line, = ax.plot(x, smoothed, label=f'Sigma = {sigma}', color=color, linewidth=2)
    smoothed_lines.append(line)

# Set plot labels and title
ax.set_title(f"Smoothed Intensity Profiles (Rows {center_row - half_band} to {center_row + half_band}) for {image_path}")
ax.set_xlabel("Distance (pixels)")
ax.set_ylabel("Gray Value")
ax.grid(True)

# Create check buttons
labels = ['Original Averaged'] + [f'Sigma = {s}' for s in sigma_values]
lines = [orig_line] + smoothed_lines

rax = plt.axes([0.01, 0.3, 0.15, 0.4])  # Position: [left, bottom, width, height]
check = CheckButtons(rax, labels, [True] * len(labels))

# Define function to toggle visibility
def toggle_visibility(label):
    index = labels.index(label)
    line = lines[index]
    line.set_visible(not line.get_visible())
    plt.draw()

check.on_clicked(toggle_visibility)

# End timer
end_time = time.time()
runtime = end_time - start_time
print(f"Runtime: {runtime:.4f} seconds")


# Use the same smoothed signal as before (e.g., sigma = 25)
selected_sigma_index = sigma_values.index(25)
smoothed_profile = gaussian_filter1d(avg_intensity_profile, sigma=sigma_values[selected_sigma_index])

# Define the range boundaries
one_fifth = len(smoothed_profile) // 5

# First 1/5
first_segment = smoothed_profile[:one_fifth]
first_max_idx = np.argmax(first_segment)
first_max_val = first_segment[first_max_idx]

# Last 1/5
last_segment = smoothed_profile[-one_fifth:]
last_max_idx = np.argmax(last_segment) + (len(smoothed_profile) - one_fifth)
last_max_val = last_segment[last_max_idx - (len(smoothed_profile) - one_fifth)]


# Print to console
print(f"Max in first 1/5: index = {first_max_idx}, value = {first_max_val:.2f}")
print(f"Max in last 1/5: index = {last_max_idx}, value = {last_max_val:.2f}")

# Get the index range between the two maxima
min_search_start = min(first_max_idx, last_max_idx)
min_search_end = max(first_max_idx, last_max_idx)

# Slice the region between the two maxima
between_segment = smoothed_profile[min_search_start:min_search_end + 1]
min_idx_rel = np.argmin(between_segment)
min_idx = min_search_start + min_idx_rel
min_val = smoothed_profile[min_idx]


# Draw vertical dashed lines at each key location
ax.axvline(first_max_idx, color='magenta', linestyle='--', label='First Max Line')
ax.axvline(last_max_idx, color='cyan', linestyle='--', label='Last Max Line')
ax.axvline(min_idx, color='black', linestyle='--', label='Min Line')

# Print details to console
print(f"Global minimum between maxima: index = {min_idx}, value = {min_val:.2f}")

# --- Local variance (jumpiness) around the minimum ---
window_half_size = 250
window_start = max(min_idx - window_half_size, 0)
window_end = min(min_idx + window_half_size, len(smoothed_profile) - 1)

# Slice local region and compute squared differences
local_segment = smoothed_profile[window_start:window_end + 1]
diffs = np.diff(local_segment)
local_variance = np.mean(diffs**2)

# Display local variance on the graph
ax.text(0.95, 0.95, f'Local Variance (Jumpy): {local_variance:.5f}', transform=ax.transAxes,
        fontsize=12, verticalalignment='top', horizontalalignment='right',
        bbox=dict(facecolor='white', alpha=0.8, edgecolor='gray'))

# Highlight the local window used for variance calculation
ax.axvspan(window_start, window_end, color='yellow', alpha=0.2, label='Variance Window')

# Determine if a pit is detected
has_min_between_maxima = min_search_start < min_idx < min_search_end
is_variance_low = local_variance < 0.0200
pit_detected = has_min_between_maxima and is_variance_low

# Print and annotate pit detection result
print(f"Pit detected: {pit_detected}")
ax.text(0.05, 0.95, f'Pit Detected: {pit_detected}', transform=ax.transAxes,
        fontsize=14, verticalalignment='top', horizontalalignment='left',
        bbox=dict(facecolor='lightgreen' if pit_detected else 'lightcoral',
                  alpha=0.8, edgecolor='gray'))

# Show the plot
plt.legend(loc='lower right')
plt.show()
