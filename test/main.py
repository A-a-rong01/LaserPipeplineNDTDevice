
import matplotlib.pyplot as plt
import cv2

# Load image in grayscale
image = cv2.imread("scratch 2(left to right).tiff",cv2.IMREAD_GRAYSCALE)

numberOfRows, numberOfColumns = image.shape
print("Number of Rows:", numberOfRows)
print("Number of Columns:", numberOfColumns)
# Display the image

middleRow = numberOfRows // 2


