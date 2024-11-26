function edgesDouble = detectEdgesCanny(image, threshold)
%DETECTEDGESCANNY Performs Canny edge detection and converts to double
%   This function applies the Canny edge detection algorithm to an input image
%   and returns the result as a double precision matrix. The Canny method is
%   particularly effective for finding true edges while minimizing noise.
%
% Inputs:
%   image     - Input image (grayscale)
%   threshold - Sensitivity threshold for edge detection:
%              * Scalar: Single threshold value
%              * [low high]: Double threshold values
%
% Output:
%   edgesDouble - Edge map as double precision matrix (0s and 1s)
%
% Example:
%   img = readDicomImage('brain_scan.dcm');
%   edges = detectEdgesCanny(img, 0.1);
%   % Or with double threshold
%   edges = detectEdgesCanny(img, [0.1 0.2]);
%
% Notes:
%   - Uses MATLAB's built-in Canny edge detector
%   - Output is converted to double for compatibility with registration functions
%   - Recommended threshold range: 0.1-0.5 for medical images
%
% See also EDGE, IM2DOUBLE

    % Input validation
    validateattributes(image, {'numeric'}, {'2d', 'nonsparse'}, ...
        'detectEdgesCanny', 'image');
    validateattributes(threshold, {'numeric'}, {'vector', 'nonnan', '>=', 0, '<=', 1}, ...
        'detectEdgesCanny', 'threshold');
    
    try
        % Apply Canny edge detection
        edges = edge(image, 'canny', threshold);
        
        % Convert to double precision
        edgesDouble = double(edges);
    catch ME
        error('Edge detection failed: %s', ME.message);
    end
end