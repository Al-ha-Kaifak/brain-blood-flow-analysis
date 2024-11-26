function [segmentedImage, maskedImage, initialContour] = improvedActiveContour(image)
%IMPROVEDACTIVECONTOUR Segments brain images using active contour method
%   This function performs brain image segmentation using the Chan-Vese active
%   contour method with an automatically generated elliptical initial contour.
%   The initial contour is created based on image properties using Otsu's
%   thresholding and ellipse fitting.
%
% Inputs:
%   image - Input image (can be any numeric format, will be converted to double)
%
% Outputs:
%   segmentedImage - Binary mask of the segmented region
%   maskedImage    - Original image with background set to zero
%   initialContour - The initial elliptical contour used (for debugging)
%
% Algorithm steps:
%   1. Image normalization and initial thresholding
%   2. Basic morphological operations
%   3. Ellipse fitting to create initial contour
%   4. Active contour evolution
%
% Example:
%   img = readDicomImage('brain_scan.dcm');
%   [segmented, masked] = improvedActiveContour(img);
%
% Notes:
%   - Uses Otsu's method for initial thresholding
%   - Initial contour is 45% of detected head size to ensure it's inside
%   - Performs 300 iterations of Chan-Vese active contour
%
% See also ACTIVECONTOUR, GRAYTHRESH, IMBINARIZE, REGIONPROPS

    %% Input Validation and Normalization
    validateattributes(image, {'numeric'}, {'2d', 'nonsparse'}, ...
        'improvedActiveContour', 'image');
    
    % Convert to double and normalize to [0,1]
    normalized_image = mat2gray(double(image));
    
    %% Initial Segmentation
    % Apply Otsu's thresholding
    threshold = graythresh(normalized_image);
    binary_mask = imbinarize(normalized_image, threshold);
    
    % Clean up binary mask
    binary_mask = bwareaopen(binary_mask, 1000);  % Remove small objects
    binary_mask = imfill(binary_mask, 'holes');   % Fill holes
    
    %% Region Analysis and Ellipse Fitting
    % Get properties of the binary mask
    stats = regionprops(binary_mask, 'Centroid', 'MajorAxisLength', ...
        'MinorAxisLength', 'Orientation');
    
    % Handle multiple regions by selecting largest
    if length(stats) > 1
        areas = regionprops(binary_mask, 'Area');
        [~, idx] = max([areas.Area]);
        stats = stats(idx);
    end
    
    %% Create Initial Contour
    % Extract ellipse parameters
    centerX = stats.Centroid(1);
    centerY = stats.Centroid(2);
    a = stats.MajorAxisLength * 0.45;  % Semi-major axis (45% of detected size)
    b = stats.MinorAxisLength * 0.45;  % Semi-minor axis (45% of detected size)
    orientation = stats.Orientation;
    
    % Create coordinate grid
    [rows, cols] = size(image);
    [X, Y] = meshgrid(1:cols, 1:rows);
    
    % Create rotated ellipse
    angle = orientation * pi / 180;
    X_r = (X - centerX) * cos(angle) + (Y - centerY) * sin(angle);
    Y_r = -(X - centerX) * sin(angle) + (Y - centerY) * cos(angle);
    initialContour = ((X_r.^2) / (a^2) + (Y_r.^2) / (b^2)) <= 1;
    
    %% Active Contour Evolution
    iterations = 300;
    try
        segmentedImage = activecontour(normalized_image, initialContour, ...
            iterations, 'Chan-Vese', 'SmoothFactor', 1);
    catch ME
        error('Active contour evolution failed: %s', ME.message);
    end
    
    %% Create Masked Output
    maskedImage = image;
    maskedImage(~segmentedImage) = 0;
end