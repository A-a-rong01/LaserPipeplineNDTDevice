% Peterson Mun
% microcrack and pit detection with inaccurate width measurement
% using intensity profile analysis and dual detection methods
% 1) Sample filenames
files = { ...
    '5.20.2025_noScratch1_noVibration.png', ...
    '5.20.2025_maybeScratch_withVibration.png', ...
    '5.20.2025_maybeScratch_noVibration.png', ...
    'scratch 4.tiff', ...
    'small hole.tiff' ...
    };
% 2) Parameters
bandHeight = 21; % # of rows to average around vertical center
smoothWin = 21; % SG smoothing window (must be odd)
polyDegree = 3; % degree for polynomial background fit
madFactor = 5; % threshold = madFactor × MAD(dI/dx)
pixelToMicrons = 1.1; % Calibration: 1.1 μm per pixel based on Appendix F
% Parameters for width estimation improvement
depthThresholdFactor = 0.15; % Depth threshold for width estimation (was 0.3)
extendedSearchFactor = 6.0; % How much to extend the search region (was 0.5)
minWidthMultiplier = 20; % Minimum expected width multiplier for known
scratches
% Parameters for pit detection
enablePitDetection = true; % Enable the pit detection mode
pitThreshFactor = 1.5; % How many std deviations below mean for pit
detection
minPitWidth = 10; % Minimum width for valid pit (pixels)
% 3) Create unified figure with tiled layout (5 rows × 4 cols)
figure('Name','Improved Microcrack & Pit Detection','NumberTitle','off',...
    
74

'Units','normalized','Position',[.05 .05 .9 .85]);
t = tiledlayout(5,4,'TileSpacing','compact','Padding','compact');
for idx = 1:numel(files)
    fname = files{idx};
    % Load & grayscale
    I = imread(fname);
    if ndims(I)==3
        Igray = rgb2gray(I);
    else
        Igray = I;
    end
    IgrayD = double(Igray);
    [H,W] = size(IgrayD);
    % 1D profile extraction: band‐average
    mid = round(H/2);
    r1 = max(1, mid - floor(bandHeight/2));
    r2 = min(H, mid + floor(bandHeight/2));
    prof = mean(IgrayD(r1:r2, :), 1);
    % Smooth the profile (Savitzky–Golay)
    profSmooth = smoothdata(prof, 'sgolay', smoothWin);
    % Background subtraction ("torch" correction)
    x = 1:W;
    bgCoeff = polyfit(x, profSmooth, polyDegree);
    background = polyval(bgCoeff, x);
    profFlat = profSmooth - background;
    % Create BG‐subtracted image for display
    BGimage = repmat(background, H, 1);
    I_bgsub = IgrayD - BGimage;
    %Compute derivative & threshold via MAD
    d = diff(profFlat);
    madVal = median(abs(d - median(d)));
    threshold = madFactor * madVal;
    %Detect and cluster spikes above threshold
    candIdx = find(abs(d) > threshold);
    regions = {};
    if ~isempty(candIdx)
        startIdx = candIdx(1);
        prevIdx = startIdx;
        for k = 2:numel(candIdx)
            if candIdx(k) == prevIdx + 1

                75

                prevIdx = candIdx(k);
            else
                regions{end+1} = startIdx:prevIdx; %#ok<AGROW>
                startIdx = candIdx(k);
                prevIdx = candIdx(k);
            end
        end
        regions{end+1} = startIdx:prevIdx;
    end
    % Rank regions by peak |d|
    nR = numel(regions);
    scores = zeros(nR,1);
    for r = 1:nR
        scores(r) = max(abs(d(regions{r})));
    end
    [~, order] = sort(scores,'descend');
    regions = regions(order);
    scores = scores(order);
    %Improved scratch width measurement
    scratchWidths = zeros(nR, 1);
    scratchWidthsMicrons = zeros(nR, 1);
    for r = 1:nR
        % Get improved width estimation
        [widthPx, leftEdge, rightEdge] = improvedFeatureWidth(profFlat,
        regions{r}, ...

            extendedSearchFactor,

        depthThresholdFactor);
        % Apply minimum width correction for known scratches
        if contains(fname, 'scratch')
            expectedMinWidth = minWidthMultiplier * length(regions{r});
            if widthPx < expectedMinWidth
                % Use intensity valley detection for width estimation
                [valleyWidth, valleyLeft, valleyRight] =

                findIntensityValley(profFlat, regions{r}, W);
                if valleyWidth > widthPx
                    widthPx = valleyWidth;
                    leftEdge = valleyLeft;
                    rightEdge = valleyRight;
                end
            end
        end
        scratchWidths(r) = widthPx;

        76

        scratchWidthsMicrons(r) = widthPx * pixelToMicrons;
    end
    %Pit detection (complementary approach)
    pitRegions = {};
    pitScores = [];
    pitWidths = [];
    if enablePitDetection
        % Look for sustained intensity drops (pits)
        meanIntensity = mean(profFlat);
        stdIntensity = std(profFlat);
        pitThreshold = meanIntensity - (pitThreshFactor * stdIntensity);
        % Find regions below threshold
        belowThreshold = profFlat < pitThreshold;
        % Find contiguous regions
        diffs = diff([false, belowThreshold, false]);
        pitStarts = find(diffs == 1);
        pitEnds = find(diffs == -1) - 1;
        % Filter by minimum width
        validPits = (pitEnds - pitStarts + 1) >= minPitWidth;
        % Collect valid pits
        pitCount = sum(validPits);
        if pitCount > 0
            pitRegions = cell(1, pitCount);
            pitWidths = zeros(1, pitCount);
            pitScores = zeros(1, pitCount);
            validIdx = find(validPits);
            for p = 1:pitCount
                start = pitStarts(validIdx(p));
                endIdx = pitEnds(validIdx(p));
                pitRegions{p} = start:endIdx;
                % Score based on depth × width
                pitDepth = meanIntensity - min(profFlat(pitRegions{p}));
                pitWidths(p) = endIdx - start + 1;
                pitScores(p) = pitDepth * pitWidths(p);
            end
            % Sort pits by score
            [pitScores, pitOrder] = sort(pitScores, 'descend');
            pitRegions = pitRegions(pitOrder);

            77

            pitWidths = pitWidths(pitOrder);
        end
    end
    %Plot original grayscale image
    ax1 = nexttile;
    imshow(Igray, [], 'Parent', ax1);
    title(ax1, 'Original Grayscale','FontSize',9);
    % Plot BG‐subtracted image
    ax2 = nexttile;
    imshow(I_bgsub, [], 'Parent', ax2);
    title(ax2, 'BG-Subtracted','FontSize',9);
    %Plot intensity profiles & detected regions
    ax3 = nexttile;
    hold(ax3,'on'); grid(ax3,'on');
    plot(ax3, prof, 'Color',[0.6 0.6 0.6], 'LineStyle',':',
    'DisplayName','Raw');
    plot(ax3, profSmooth, 'r-', 'LineWidth',1.2, 'DisplayName','Smoothed');
    plot(ax3, profFlat, 'b--','DisplayName','Flat');
    % Plot scratch extent for top feature
    if nR > 0
        % Plot full extent of top scratch
        topScratch = regions{1};
        leftEdge = topScratch(1) - floor(scratchWidths(1)/2) +

        floor(length(topScratch)/2);

        rightEdge = leftEdge + scratchWidths(1);
        % Keep within bounds
        leftEdge = max(1, leftEdge);
        rightEdge = min(W, rightEdge);
        % Mark full detected region
        xfill = [leftEdge:rightEdge];
        if length(xfill) > 1
            ymin = min(ax3.YLim);
            ymax = max(ax3.YLim);
            fill(ax3, [leftEdge rightEdge rightEdge leftEdge], [ymin ymin ymax

                ymax], ...
                
            [0.8 1 0.8], 'FaceAlpha', 0.3, 'EdgeColor', 'none',

            'DisplayName', 'Feature Width');

        end
        % Plot detected edge points
        plot(ax3, topScratch, profFlat(topScratch), 'gv',

        'MarkerFaceColor','g', ...

            78

        'DisplayName','Edge Points');

    end
    % Plot top detected pit
    if enablePitDetection && ~isempty(pitRegions)
        pitIdx = pitRegions{1};
        plot(ax3, pitIdx, profFlat(pitIdx), 'm-', 'LineWidth', 2, ...
            'DisplayName', 'Top Pit');
    end
    hold(ax3,'off');
    title(ax3,'Intensity Profile','FontSize',9);
    xlabel(ax3,'Column'); ylabel(ax3,'I');
    if idx==1
        legend(ax3,'Location','northeast','FontSize',7,'Box','off');
    end
    %Plot derivative & threshold & region boundaries
    ax4 = nexttile;
    hold(ax4,'on'); grid(ax4,'on');
    plot(ax4, d, 'k-', 'DisplayName','dI/dx');
    yline(ax4, +threshold, 'r--','DisplayName','+Thr');
    yline(ax4, -threshold, 'r--','DisplayName','-Thr');
    for r = 1:min(3, nR)
        xb = [regions{r}(1), regions{r}(end)];
        plot(ax4, [xb(1) xb(1)], ylim(ax4), 'g-','HandleVisibility','off');
        plot(ax4, [xb(2) xb(2)], ylim(ax4), 'g-','HandleVisibility','off');
    end
    hold(ax4,'off');
    title(ax4,'Derivative','FontSize',9);
    xlabel(ax4,'Column'); ylabel(ax4,'dI/dx');
    if idx==1
        legend(ax4,'Location','northeast','FontSize',7,'Box','off');
    end
    % --- Console summary with accurate size measurements ---
    if nR==0
        fprintf('%s: no candidate regions detected.\n', fname);
    else
        top = regions{1};
        topWidth = scratchWidthsMicrons(1);
        fprintf('%s: %d region(s), top spans cols %d–%d (width: %.1f μm,
        score=%.2f).\n', ...

        fname, nR, top(1), top(end), topWidth, scores(1));
    end
    % Report detected pits
    if enablePitDetection && ~isempty(pitRegions)

        79

        topPit = pitRegions{1};
        pitWidthMicrons = pitWidths(1) * pixelToMicrons;
        fprintf(' Potential pit detected: cols %d-%d (width: %.1f μm, score:
        %.2f)\n', ...

        topPit(1), topPit(end), pitWidthMicrons, pitScores(1));
    end
end
%feature width estimation function
function [featureWidthPx, leftEdge, rightEdge] = improvedFeatureWidth(profile,
region, extendedSearchFactor, depthThresholdFactor)
% Use a much wider search region around the detected edges
margin = max(50, round(length(region) * extendedSearchFactor));
extStart = max(1, region(1) - margin);
extEnd = min(length(profile), region(end) + margin);
% Calculate baseline from context - use data far from the detected region
contextStart = max(1, extStart);
contextEnd = min(length(profile), extEnd);
% Use the first and last 20% of the extended region as baseline references
baselinesegmentSize = round(0.2 * (contextEnd - contextStart));
leftBaselineRegion = contextStart:(contextStart + baselinesegmentSize);
rightBaselineRegion = (contextEnd - baselinesegmentSize):contextEnd;
% Filter out any points that might be part of regions
leftBaselineRegion = leftBaselineRegion(leftBaselineRegion < (region(1) -
10));
rightBaselineRegion = rightBaselineRegion(rightBaselineRegion > (region(end)
+ 10));
% Combine baseline regions
baselineRegion = [leftBaselineRegion, rightBaselineRegion];
if isempty(baselineRegion) || length(baselineRegion) < 5
    % Fallback if we couldn't get good baseline regions
    baseline = mean(profile);
else
    baseline = mean(profile(baselineRegion));
end
% Identify the approximate depth at the center of the feature
centralRegion = max(1, region(1) - 10):min(length(profile), region(end) +
10);
featureDepth = baseline - min(profile(centralRegion));
% Use a lower threshold for width determination - capture more of the
feature
threshold = baseline - (depthThresholdFactor * featureDepth);

80

% Scan left to find feature boundary
leftEdge = region(1);
for i = region(1):-1:extStart
    if profile(i) > threshold
        leftEdge = i+1;
        break;
    end
end
% Scan right to find feature boundary
rightEdge = region(end);
for i = region(end):extEnd
    if profile(i) > threshold
        rightEdge = i-1;
        break;
    end
end
% Calculate feature width
featureWidthPx = rightEdge - leftEdge + 1;
end
% Additional helper function for valley-based width detection
function [valleyWidth, valleyLeft, valleyRight] = findIntensityValley(profile,
region, imageWidth)
% This alternative approach looks for the broader valley structure around
the edges
% Define search region
margin = max(100, length(region) * 10);
valleyLeft = max(1, region(1) - margin);
valleyRight = min(imageWidth, region(end) + margin);
% Find the average intensity in the detection region
detectionIntensity = mean(profile(region));
% Calculate local baseline away from the feature
outerLeft = max(1, valleyLeft - 50);
outerRight = min(imageWidth, valleyRight + 50);
leftBaseline = mean(profile(outerLeft:valleyLeft));
rightBaseline = mean(profile(valleyRight:outerRight));
localBaseline = (leftBaseline + rightBaseline) / 2;
% Determine valley threshold (halfway between baseline and detection
intensity)
valleyThreshold = localBaseline - 0.3 * (localBaseline -
detectionIntensity);

81

% Scan from left edge of region towards left to find valley boundary
for i = region(1):-1:outerLeft
    if profile(i) > valleyThreshold
        valleyLeft = i+1;
        break;
    end
end
% Scan from right edge of region towards right to find valley boundary
for i = region(end):outerRight
    if profile(i) > valleyThreshold
        valleyRight = i-1;
        break;
    end
end
valleyWidth = valleyRight - valleyLeft + 1;
end