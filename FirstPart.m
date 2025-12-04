data = imread("C:\Users\User\Documents\GitHub\LaserPipeplineNDTDevice\Images\RecentTest\small hole.tiff");
imshow(data);


% Determine the middle 200 rows
[numRows, ~] = size(data);
startRow = floor((numRows - 200)/2) + 1;
endRow = startRow + 199;

% Average the middle 200 rows
average_profile = mean(data(startRow:endRow, :), 1);

% Plot the averaged intensity profile
plot(average_profile);
xlabel('Pixel Position');
ylabel('Average Intensity');
title('Average Light Intensity of Middle 200 Rows');
grid on;