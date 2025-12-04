
function x = FindCracksRough(imgName)


% C:\Users\phamk\OneDrive\Desktop\EE 495\1-30-2025 metal no scratch green diode tiff.tif
% C:\Users\phamk\OneDrive\Desktop\EE 495\1-30-2025 metal with scratch green diode tiff.tif
% C:\Users\phamk\OneDrive\Desktop\EE 495\1-30-2025 white card with line green diode tiff.tif
% C:\Users\phamk\OneDrive\Desktop\EE 495\1-30-2025 white card green diode tiff.tif

% Load Image
    img = imread(imgName);

% Define Row Range for Averaging
    numRows = size(img, 1);
    middleRow = round(numRows / 2);
    rowsToAverage = 200; % Increase number of rows to average

    % Compute the Average Intensity Across Multiple Rows
    startRow = max(middleRow - floor(rowsToAverage / 2), 1); % Ensure within bounds
    endRow = min(middleRow + floor(rowsToAverage / 2), numRows);
    avgIntensityRow = mean(img(startRow:endRow, :), 1); % Average across selected rows

    % Apply Smoothing Function
    smoothedIntensity = smoothdata(avgIntensityRow, 'movmean', 20); % Moving average with a window of 10

    % Find Dark Pixels
    threshold = graythresh(img) * 255; % Compute threshold
    darkPixels = smoothedIntensity < threshold; % Identify dark pixels

    % set smoothed array to be returned
    x = smoothedIntensity;

    % Variables for finding dips and bottoms in the for loop below
        dipTop1 = 0;
        dipTop1Col = 0;
        dipTop2 = 0;
        dipTop2Col = 0;
        dipBottom = 0;
        dipBottomCol = 0;
        checkDecrease = false;
        checkIncrease = false;
        potentialCracks = [];
        potentialCrackCol = 0;


for i = 2:length(x)
    % Begin data analysis after 1st element
    if i > 1
        % Check if data begins to decrease
        if x(i) < x(i-1) && ~checkDecrease
            dipTop1 = x(i-1);
            dipTop1Col = i-1;
            checkDecrease = true;
            disp("Found dipTop1: " + dipTop1 + " at column " + dipTop1Col);
        end

        % If the top of a dip is found, watch for any increase
        if x(i) > x(i-1) && checkDecrease
            dipBottom = x(i-1);
            dipBottomCol = i-1;
            potentialCrackCol = i-1;
            checkDecrease = false;
            checkIncrease = true;
            disp("Found dipBottom: " + dipBottom + " at column " + dipBottomCol);
        end

        % Look for the next time data begins to decrease
        if x(i-1) > x(i) && checkIncrease
            checkIncrease = false;
            dipTop2 = x(i-1);
            dipTop2Col = i-1;
            disp("Found dipTop2: " + dipTop2 + " at column " + dipTop2Col);

            % Check if the dip is significant
            if (dipTop1 - dipBottom) > 0.8 * 10^4 && (dipTop2 - dipBottom) > 0.8 * 10^4
                potentialCracks(end+1) = potentialCrackCol;
                disp("Crack Detected at Column " + potentialCrackCol + ' of image');
                disp("DipTop1 = " + dipTop1 + newline + "DipTop1Col = " + dipTop1Col + newline);
                disp("DipTop2 = " + dipTop2 + newline + "DipTop2Col = " + dipTop2Col + newline);
                disp("DipBottom = " + dipBottom + newline + "DipBottomCol = " + dipBottomCol + newline);
                end
            end
        end
    end
end