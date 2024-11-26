function [registeredImage, registeredMoving, tform] = registerImages(movingImage, fixedImage, movingReference, fixedReference, maxIterations, transformationType)
%REGISTERIMAGES_POC2 Performs image registration using reference images
%   This function performs image registration using a reference-based approach,
%   where the transformation is computed using reference images (e.g., segmented
%   or edge images) and then applied to the original images.
%
% Inputs:
%   movingImage      - Original image to be registered
%   fixedImage       - Target image for registration
%   movingReference  - Reference version of moving image (e.g., segmented/edge)
%   fixedReference   - Reference version of fixed image (e.g., segmented/edge)
%   maxIterations    - Maximum number of iterations for optimization
%   transformationType - Type of transformation ('rigid', 'similarity', etc.)
%
% Outputs:
%   registeredImage  - Transformed version of movingImage
%   registeredMoving - Transformed version of movingReference
%   tform           - Transformation object that can be reused
%
% Example:
%   [regImg, regRef, tform] = registerImages_POC2(moving, fixed, ...
%                             movingRef, fixedRef, 1000, 'similarity');
%
% Notes:
%   - Uses multimodal registration configuration
%   - Applies same transformation to both original and reference images
%   - Output images are automatically sized to match fixed image dimensions
%
% See also IMREGCONFIG, IMREGTFORM, IMWARP

    % Input validation
    validateattributes(maxIterations, {'numeric'}, {'positive', 'integer'}, ...
        'registerImages_POC2', 'maxIterations');
    validateattributes(transformationType, {'char', 'string'}, {}, ...
        'registerImages_POC2', 'transformationType');
    
    % Configure registration settings for multimodal images
    [optimizer, metric] = imregconfig('multimodal');
    optimizer.MaximumIterations = maxIterations;
    
    try
        % Compute transformation from moving to fixed using reference images
        tform = imregtform(movingReference, fixedReference, ...
            transformationType, optimizer, metric);
        
        % Create spatial reference object for output image dimensions
        fixedRef = imref2d(size(fixedImage));
        
        % Apply computed transformation to original moving image
        registeredImage = imwarp(movingImage, tform, ...
            'OutputView', fixedRef);
        
        % Apply same transformation to reference image
        registeredMoving = imwarp(movingReference, tform, ...
            'OutputView', imref2d(size(fixedReference)));
        
    catch ME
        error('Registration failed: %s', ME.message);
    end
    
    % Uncomment for debugging visualization
    % figure;
    % imshowpair(fixedImage, registeredImage, 'Scaling', 'joint');
    % title('Overlay of Fixed and Registered Images');
    %
    % figure;
    % imshowpair(fixedReference, registeredMoving, 'ColorChannels', 'red-cyan');
    % title('Overlay of Fixed and Registered Reference Images');
end