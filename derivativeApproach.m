data = imread("C:\Users\User\Documents\GitHub\LaserPipeplineNDTDevice\Images\vlcsnap-2025-02-21-with scratch low magnification.tiff");
imshow(data);
row = 100;  % Choose a row
intensity_profile = data(row, :);  

plot(intensity_profile);  
xlabel('Pixel Position');  
ylabel('Intensity');  
title('Light Intensity Along Row 100');
grid on;
