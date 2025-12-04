
function x = FindCracks(imgName)

% C:\Users\phamk\OneDrive\Desktop\EE 495\1-30-2025 metal no scratch green diode tiff.tif
% C:\Users\phamk\OneDrive\Desktop\EE 495\1-30-2025 metal with scratch green diode tiff.tif
% C:\Users\phamk\OneDrive\Desktop\EE 495\1-30-2025 white card with line green diode tiff.tif
% C:\Users\phamk\OneDrive\Desktop\EE 495\1-30-2025 white card green diode tiff.tif
% FindCracks('C:\Users\phamk\OneDrive\Desktop\EE 495\1-30-2025 metal with scratch green diode tiff.tif');
% FindCracks('C:\Users\phamk\OneDrive\Desktop\EE 495\1_No0283 (1).tif');
% FindCracks('C:\Users\phamk\OneDrive\Desktop\EE 495\vlcsnap-2025-02-21-with scratch higher magnification.tiff');
% testingCapSmooth('C:\Users\phamk\OneDrive\Desktop\EE 495\vlcsnap-2025-02-21-with scratch higher magnification.tiff');

tic;

% Load Image
    img = imread(imgName);

% Get the number of columns in the image
    [numRows, numCols] = size(img);
    fprintf('Total number of Columns/Rows in the image: %d, %d\n', numCols, numRows);
    

% Define Row Range for Averaging
    numRows = size(img, 1);
    middleRow = round(numRows / 2);
    rowsToAverage = 1; % Increase number of rows to average

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

        %Begin data analysis after 1st element
        if(i>0)
            %checkIncrease = false;
            %check if data begins to decrease
            %if it begins to deacrese, note potential 'top' of dip
            if(x(i) < x(i-1) && checkDecrease == false)
                %fprintf("Assigning value of dipTop1");
                %fprintf(" , CheckIncrease: " + checkIncrease + " CheckDecrease: " + checkDecrease + newline);

                dipTop1 = x(i-1);
                dipTop1Col = i-1;
                checkDecrease = true;
                %fprintf(newline + "Setting checkDecrease to True" + newline);
            end

            %if the top of a dip is found, then a watch for any increase
            %if there is an increase in data, note potential 'bottom' of dip
            if(x(i) > x(i-1) && checkDecrease == true)
                %fprintf("Assigning value of dipBottom" + newline);
                dipBottom = x(i-1);
                dipBottomCol = i-1;
                potentialCrackCol = i-1;
                checkDecrease = false;
                %fprintf(newline + "Setting checkIncrease to False" + newline);

                checkIncrease = true;
                %fprintf(newline + "Setting checkIncrease to True" + newline);

            end


            %look for the next time data begins to decrease
            %then note current data and compare to the previously found bottom of dip.

            %also compare the 1st 'top' of the dip to the previously found
            %bottom of the dip.

            if(x(i-1)>x(i) && checkIncrease == true)
                %fprintf("Assigning value of dipTop2");
                %fprintf(" , CheckIncrease: " + checkIncrease + " CheckDecrease: " + checkDecrease + newline);
                %fprintf("End of for loop iteration: " + i + newline + newline);

                %disp("DipTop2 = " + dipTop2 + newline + "DipTop2Col = " + dipTop2Col + newline);

                checkIncrease = false;
                %fprintf(newline + "Setting checkIncrease to True" + newline);

                dipTop2 = x(i-1);
                dipTop2Col = i-1;
                
                if((dipTop1-dipBottom) > 0.8*10^4 && (dipTop2 - dipBottom) > 0.8*10^4)
                %if((dipTop1-dipBottom) > 30 && (dipTop2 - dipBottom) > 30)

                    potentialCracks(end+1) = potentialCrackCol;
                    fprintf(newline + "Crack Detected at Column " + potentialCrackCol + ' of image' + newline);
                    fprintf("DipTop1 = " + dipTop1 + newline + "DipTop1Col = " + dipTop1Col + newline);
                    fprintf("DipTop2 = " + dipTop2 + newline + "DipTop2Col = " + dipTop2Col + newline);
                    fprintf("DipBottom = " + dipBottom + newline + "DipBottomCol = " + dipBottomCol + newline + newline);
                else
                    checkIncrease = false;
                    %fprintf("Nah the dip aint no good dawg" + newline);
                    %fprintf(newline + "Setting checkIncrease to True" + newline);

                end
            end
        end
    end

    if(isempty(potentialCracks))

    fprintf("No crack detected in picture");

    end

    elapsedTime = toc;
    fprintf("Time Elapsed: " + elapsedTime);

end

