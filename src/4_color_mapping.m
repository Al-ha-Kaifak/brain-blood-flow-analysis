%% Color Mapping and Time-to-Peak Visualization
% This script creates colored visualizations of brain blood flow based on
% Time-to-Peak (TTP) analysis. It processes registered CTA and CTP images to
% create color-coded maps showing blood flow patterns.
%
% The process includes:
% 1. Edge detection and dilation on merged CTA images
% 2. TTP calculation from CTP time series
% 3. Color mapping using an inverted jet colormap
% 4. Visualization and saving of results
%
% Author: Yotam Gunders
% Last Modified: 26.11.2024

%% Initialize Environment
clc;

%% Check Initial Data
disp('=== Initial Data Check ===');
initial_groups = numel(female_1990.registered.groups);
initial_images = numel(female_1990.registered.groups{1}.registeredImages_CTP);
disp(['Number of groups: ', num2str(initial_groups)]);
disp(['Number of CTP images in group 1: ', num2str(initial_images)]);
disp('========================');

%% Load Data and Setup Paths
% Load processed data
load("C:\Users\ygund\Desktop\Matlab_Projects\Final_Project_Yotam\final final project\Female_1990\female_1990_processed.mat");

% Setup output directory
output_base_path = "C:\Users\ygund\Desktop\Matlab_Projects\Final_Project_Yotam\final final project\Female_1990\colored_images";
if ~exist(output_base_path, 'dir')
    mkdir(output_base_path);
end

%% Set Parameters
EDGE_DILATION_RADIUS = 2;
COLOR_LEVELS = 256;
colormapUsed = jet(COLOR_LEVELS);
invertedColormapUsed = flipud(colormapUsed);

%% Process Each Group
num_groups = numel(female_1990.registered.groups);

for group = 1:num_groups
    fprintf('\nProcessing group %d of %d\n', group, num_groups);
    
    % Create vessel mask from merged CTA
    [dilatedMask, merged_CTA] = createVesselMask(...
        female_1990.registered.groups{group}.merged_CTA, ...
        EDGE_DILATION_RADIUS);
    
    % Process CTP images and calculate TTP
    [TTP, imageStack] = calculateTTP(...
        female_1990.registered.groups{group}.registeredImages_CTP);
    
    % Create colored visualization
    coloredCTA = createColoredVisualization(...
        TTP, dilatedMask, invertedColormapUsed, size(imageStack, 3));
    
    % Visualize results
    visualizeResults(merged_CTA, dilatedMask, TTP, coloredCTA, ...
        invertedColormapUsed, group);
    
    % Save results
    saveResults(coloredCTA, group, output_base_path, female_1990);
    
    % Report progress
    reportProgress(TTP, group);
end

%% Save Final Results
save("C:\Users\ygund\Desktop\Matlab_Projects\Final_Project_Yotam\final final project\Female_1990\female_1990_processed_with_colors.mat", ...
    'female_1990', '-v7.3');
disp('Processing and saving completed.');

%% Helper Functions

function [dilatedMask, merged_CTA] = createVesselMask(merged_CTA, radius)
    % Create dilated vessel mask from merged CTA image
    edges = edge(merged_CTA, 'canny');
    dilatedMask = imdilate(edges, strel('disk', radius));
end

function [TTP, imageStack] = calculateTTP(ctpImages)
    % Calculate Time-to-Peak from CTP image series
    [rows, cols] = size(ctpImages{1});
    imageStack = zeros(rows, cols, numel(ctpImages));
    
    % Normalize each CTP image
    for k = 1:numel(ctpImages)
        temp = ctpImages{k};
        imageStack(:,:,k) = normalizeImage(temp);
    end
    
    % Calculate TTP
    [~, TTP] = max(imageStack, [], 3);
end

function normalizedImg = normalizeImage(img)
    % Normalize image to [0,1] range
    normalizedImg = (img - min(img(:))) / (max(img(:)) - min(img(:)));
end

function coloredCTA = createColoredVisualization(TTP, mask, colormap, numTimePoints)
    % Create colored visualization based on TTP values
    [rows, cols] = size(TTP);
    coloredCTA = zeros(rows, cols, 3);
    
    for i = 1:rows
        for j = 1:cols
            if mask(i,j) == 1
                idx = round(TTP(i,j) * 255 / numTimePoints);
                idx = max(1, min(256, idx));
                coloredCTA(i,j,:) = colormap(idx,:);
            end
        end
    end
end

function visualizeResults(merged_CTA, mask, TTP, coloredCTA, colormap, group)
    % Create visualization figure with subplots
    figure('Position', [100 100 1200 400]);
    
    % Merged CTA
    subplot(1,4,1);
    imshow(merged_CTA, []);
    title('Merged CTA');
    colorbar;
    
    % Mask
    subplot(1,4,2);
    imshow(mask);
    title(sprintf('Mask (%d pixels)', sum(mask(:))));
    
    % TTP Map
    subplot(1,4,3);
    imshow(TTP, []);
    title('TTP Map');
    colorbar;
    
    % Colored Result
    subplot(1,4,4);
    imshow(coloredCTA);
    title('Colored Result');
    colormap(colormap);
    colorbar;
    
    sgtitle(sprintf('Group %d Analysis', group));
end

function saveResults(coloredCTA, group, output_path, data_struct)
    % Save colored image and update data structure
    output_file = fullfile(output_path, sprintf('group_%d_colored_CTA.png', group));
    imwrite(coloredCTA, output_file);
    data_struct.registered.groups{group}.colored_CTA = coloredCTA;
end

function reportProgress(TTP, group)
    % Report processing progress and statistics
    fprintf('Group %d processing completed\n', group);
    fprintf('TTP range: %.1f to %.1f\n', min(TTP(:)), max(TTP(:)));
end