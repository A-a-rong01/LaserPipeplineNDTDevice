function x = testingCapSmooth(imgName)
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

    FindCracks(imgName);

    %{
    for i = 2:length(x)

        dipTop1 = 0;
        dipTop2 = 0;
        dipBottom = 0;
        checkDecrease = false;
        checkIncrease = false;
        potentialCracks = [];
        potentialCrackCol = 0;

        %Begin data analysis after 1st element
        if(i>0)

            %check if data begins to decrease
            %if it begins to deacrese, note potential 'top' of dip
            if(x(i) < x(i-1) && checkDecrease == false)
                dipTop1 = x(i-1);
                checkDecrease = true;
            end

            %if the top of a dip is found, then a watch for any increase
            %if there is an increase in data, note potential 'bottom' of dip
            if(x(i) > x(i-1) && checkDecrease == true)
                dipBottom = x(i-1);
                potentialCrackCol = i-1;
                checkDecrease = false;
                checkIncrease = true;
            end


            %look for the next time data begins to decrease
            %then note current data and compare to the previously found bottom of dip.

            %also compare the 1st 'top' of the dip to the previously found
            %bottom of the dip.

            if(x(i-1)>x(i) && checkIncrease == true)

                checkIncrease = false;
                dipTop2 = x(i-1);
                if((dipTop1-dipBottom) > 0.9*10^4 && (dipTop2 - dipBottom) > 0.9*10^4)

                    potentialCrack(end+1) = potentialCrackCol;
                    disp("Crack Detected");
                end
            end
        end
    end
           
    %}

    % Plot the Smoothed Averaged Intensity Row
    figure;
    plot(smoothedIntensity, 'b', 'LineWidth', 1.5); hold on; % Plot smoothed intensity in blue
    %plot(find(darkPixels), smoothedIntensity(darkPixels), 'ro', 'MarkerSize', 3); % Highlight dark areas in red
    xlabel('Column Number');
    ylabel('Light Intensity (Smoothed & Averaged)');
    title(['Smoothed Light Intensity Across ' num2str(rowsToAverage) ' Rows']);
    legend('Smoothed Intensity', 'Dark Pixels');
    grid on;
end

testingCapSmooth("C:\Users\User\Documents\GitHub\LaserPipeplineNDTDevice\Images\RecentTest\small hole.tiff")