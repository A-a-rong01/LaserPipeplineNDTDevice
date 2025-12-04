% Load and display image
data = imread("C:\Users\User\Documents\GitHub\LaserPipeplineNDTDevice\Images\RecentTest\small hole.tiff");
imshow(data);

% Determine the middle 200 rows
[numRows, ~] = size(data);
startRow = floor((numRows - 200)/2) + 1;
endRow = startRow + 199;

% Average the middle 200 rows
average_profile = mean(data(startRow:endRow, :), 1);

% Prepare x-values
x = 1:length(average_profile);
xq = linspace(1, length(average_profile), 10 * length(average_profile));  % finer resolution

% Smooth with interpolation (makima)
interp_profile = interp1(x, average_profile, xq, 'makima');

% Smooth with Gaussian filter (1D)
gaussian_profile = smoothdata(average_profile, 'gaussian', 21);  % 21-point window

% Plot only the final smoothed result (Gaussian)
figure;
plot(x, gaussian_profile, 'g-', 'LineWidth', 1.5, 'DisplayName', 'Gaussian Smooth');
xlabel('Pixel Position');
ylabel('Intensity');
title('Smoothed Light Intensity Profile (Gaussian Filter)');
grid on;
legend;
