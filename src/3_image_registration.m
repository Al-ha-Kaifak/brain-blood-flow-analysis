%% Two-Stage Image Registration for Brain Blood Flow Analysis
% This script performs registration of CTA and CTP images using a two-stage approach:
% 1. Initial registration using active contour segmentation
% 2. Refinement using Canny edge detection
%
% The script processes multiple groups of images, where each group contains:
% - Multiple CTP time series images
% - Four CTA images that need to be registered and merged
%
% Author: Yotam Gunders
% Last Modified: 26.11.2024

%% Initialize Environment
clc;

% Add functions folder to path
functions_folderPath = "C:\Users\ygund\Desktop\Matlab_Projects\Final_Project_Yotam\functions";
addpath(functions_folderPath);

%% Load Data
fprintf('Loading data...\n');
load("C:\Users\ygund\Desktop\Matlab_Projects\Final_Project_Yotam\final final project\ANONJA72BI1FH Male 1956\Male_1956.mat");

%% Setup Processing Parameters
% Calculate number of groups to process
num_groups = min(numel(Male_1956.CTP), numel(Male_1956.CTA_of_fours));
start_group = 1;

% Registration parameters
REG_ITERATIONS = 1000;
CANNY_THRESHOLD = 0.1;
FIXED_IMAGE_INDEX = 15;  % Reference image in CTP series

fprintf('Found %d groups to process\n', num_groups);

%% Main Processing Loop
for group = start_group:num_groups
    fprintf('\nProcessing group %d of %d\n', group);
    
    %% Stage 1: Active Contour Segmentation
    % Process CTP images
    fprintf('Segmenting CTP images...\n');
    [maskedCell_CTP, segmentedCell_CTP] = processCTPImages(Male_1956.CTP{group});
    
    % Process CTA images
    fprintf('Segmenting CTA images...\n');
    [maskedCell_CTA, segmentedCell_CTA] = processCTAImages(Male_1956.CTA_of_fours{group});
    
    %% Stage 2: Two-Stage Registration
    % Setup reference images
    fixedSegmented = segmentedCell_CTP{FIXED_IMAGE_INDEX};
    fixedImage = maskedCell_CTP{FIXED_IMAGE_INDEX};
    fixedCanny = detectEdgesCanny(fixedImage, CANNY_THRESHOLD);
    
    % Register CTP images
    fprintf('Registering CTP images...\n');
    [registeredImages_CTP, registeredSegmented_CTP] = registerTimeSeriesImages(...
        maskedCell_CTP, segmentedCell_CTP, fixedImage, fixedSegmented, ...
        fixedCanny, FIXED_IMAGE_INDEX, REG_ITERATIONS);
    
    % Register CTA images
    fprintf('Registering CTA images...\n');
    [registeredImages_CTA, registeredSegmented_CTA] = registerCTAImages(...
        maskedCell_CTA, segmentedCell_CTA, fixedImage, fixedSegmented, ...
        fixedCanny, REG_ITERATIONS);
    
    %% Store Results
    saveGroupResults(Male_1956, group, registeredImages_CTP, registeredImages_CTA, ...
        registeredSegmented_CTP, registeredSegmented_CTA);
    
    %% Merge CTA Images
    mergeCTAImages(Male_1956, group);
    
    % Add reference image
    Male_1956.registered.groups{group}.registeredImages_CTP{FIXED_IMAGE_INDEX} = ...
        readDicomImage(Male_1956.CTP{group}{FIXED_IMAGE_INDEX});
    
    % Verify storage
    verifyGroupStorage(Male_1956, group);
end

%% Save Final Results
saveResults(Male_1956, start_group, num_groups);

fprintf('\nProcessing completed successfully.\n');

%% Helper Functions

function [maskedCell, segmentedCell] = processCTPImages(images)
    maskedCell = {};
    segmentedCell = {};
    for idx = 1:numel(images)
        img = readDicomImage(images{idx});
        [segmentedImage, maskedImage] = improvedActiveContour(img);
        segmentedCell{idx} = double(segmentedImage);
        maskedCell{idx} = double(maskedImage);
    end
end

%% Helper Functions (המשך)

function [maskedCell, segmentedCell] = processCTAImages(images)
    % Process CTA images with Active Contour segmentation
    maskedCell = {};
    segmentedCell = {};
    for idx = 1:numel(images)
        img = readDicomImage(images{idx});
        [segmentedImage, maskedImage] = improvedActiveContour(img);
        segmentedCell{idx} = double(segmentedImage);
        maskedCell{idx} = double(maskedImage);
    end
end

function [registeredImages, registeredSegmented] = registerTimeSeriesImages(...
    maskedCell, segmentedCell, fixedImage, fixedSegmented, fixedCanny, ...
    fixedIndex, iterations)
    % Register time series images using two-stage registration
    registeredImages = cell(size(maskedCell));
    registeredSegmented = cell(size(segmentedCell));
    
    for idx = 1:numel(maskedCell)
        if idx ~= fixedIndex  % Skip reference image
            % Stage 1: Segmentation-based registration
            [tempRegImg, tempRegSeg, ~] = registerImages(...
                maskedCell{idx}, fixedImage, ...
                segmentedCell{idx}, fixedSegmented, ...
                iterations, 'similarity');
            
            % Stage 2: Edge-based refinement
            movingCanny = detectEdgesCanny(tempRegImg, 0.1);
            [registeredImages{idx}, registeredSegmented{idx}, ~] = ...
                registerImages(tempRegImg, fixedImage, ...
                movingCanny, fixedCanny, ...
                iterations, 'similarity');
        end
    end
end

function [registeredImages, registeredSegmented] = registerCTAImages(...
    maskedCell, segmentedCell, fixedImage, fixedSegmented, fixedCanny, iterations)
    % Register CTA images using two-stage registration
    registeredImages = cell(size(maskedCell));
    registeredSegmented = cell(size(segmentedCell));
    
    for idx = 1:numel(maskedCell)
        % Stage 1: Segmentation-based registration
        [tempRegImg, tempRegSeg, ~] = registerImages(...
            maskedCell{idx}, fixedImage, ...
            segmentedCell{idx}, fixedSegmented, ...
            iterations, 'similarity');
        
        % Stage 2: Edge-based refinement
        movingCanny = detectEdgesCanny(tempRegImg, 0.1);
        [registeredImages{idx}, registeredSegmented{idx}, ~] = ...
            registerImages(tempRegImg, fixedImage, ...
            movingCanny, fixedCanny, ...
            iterations, 'similarity');
    end
end

function saveGroupResults(data_struct, group, regImages_CTP, regImages_CTA, ...
    regSegmented_CTP, regSegmented_CTA)
    % Save registration results for a single group
    data_struct.registered.groups{group} = struct();
    data_struct.registered.groups{group}.registeredImages_CTA = regImages_CTA;
    data_struct.registered.groups{group}.registeredImages_CTP = regImages_CTP;
    
    data_struct.segmented_registered.groups{group} = struct();
    data_struct.segmented_registered.groups{group}.registeredSegmented_CTA = regSegmented_CTA;
    data_struct.segmented_registered.groups{group}.registeredSegmented_CTP = regSegmented_CTP;
end

function mergeCTAImages(data_struct, group)
    % Merge registered CTA images into a single image
    registered_CTA_images = data_struct.registered.groups{group}.registeredImages_CTA;
    
    if ~isempty(registered_CTA_images)
        [rows, cols] = size(registered_CTA_images{1});
        merged_CTA = zeros(rows, cols);
        
        for idx = 1:numel(registered_CTA_images)
            merged_CTA = merged_CTA + registered_CTA_images{idx};
        end
        
        merged_CTA = mat2gray(merged_CTA);
        data_struct.registered.groups{group}.merged_CTA = merged_CTA;
    else
        warning('No images found for merging in group %d', group);
    end
end

function verifyGroupStorage(data_struct, group)
    % Verify that all data was stored correctly
    fprintf('Group %d data verification:\n', group);
    fprintf('  CTA images: %d\n', ...
        numel(data_struct.registered.groups{group}.registeredImages_CTA));
    fprintf('  CTP images: %d\n', ...
        numel(data_struct.registered.groups{group}.registeredImages_CTP));
    
    if isfield(data_struct.registered.groups{group}, 'merged_CTA')
        merged_size = size(data_struct.registered.groups{group}.merged_CTA);
        fprintf('  Merged CTA size: [%d, %d]\n', merged_size(1), merged_size(2));
    else
        warning('  Merged CTA not found');
    end
end

function saveResults(data_struct, start_group, num_groups)
    % Save all results to files
    base_path = "C:\Users\ygund\Desktop\Matlab_Projects\Final_Project_Yotam\final final project\ANONJA72BI1FH Male 1956\ANONJA72BI1FH Male 1956";
    
    if ~exist(base_path, 'dir')
        mkdir(base_path);
        fprintf('Created directory: %s\n', base_path);
    end
    
    % Try to save full structure
    try
        full_filename = fullfile(base_path, 'Male_1956_full_registered_data.mat');
        save(full_filename, 'data_struct', '-v7.3', '-nocompression');
        fprintf('Full structure saved successfully\n');
    catch ME
        warning('Failed to save full structure: %s', ME.message);
        saveFieldsSeparately(data_struct, base_path);
    end
    
    % Save individual groups
    saveIndividualGroups(data_struct, base_path, start_group, num_groups);
    
    % Report total size
    reportTotalSize(base_path);
end

function saveFieldsSeparately(data_struct, base_path)
    % Save each field separately if full save fails
    fields = fieldnames(data_struct);
    for i = 1:length(fields)
        try
            field_filename = fullfile(base_path, ['Male_1956_', fields{i}, '.mat']);
            field_data = data_struct.(fields{i});
            save(field_filename, 'field_data', '-v7.3', '-nocompression');
            fprintf('Saved field %s successfully\n', fields{i});
        catch ME
            warning('Failed to save field %s: %s', fields{i}, ME.message);
        end
    end
end

function saveIndividualGroups(data_struct, base_path, start_group, num_groups)
    % Save each group separately
    for group = start_group:num_groups
        try
            group_data = data_struct.registered.groups{group};
            group_filename = fullfile(base_path, ...
                sprintf('Male_1956_registered_group_%d.mat', group));
            save(group_filename, 'group_data', '-v7.3');
            fprintf('Saved group %d successfully\n', group);
        catch ME
            warning('Failed to save group %d: %s', group, ME.message);
        end
    end
end

function reportTotalSize(base_path)
    % Report total size of saved data
    folder_info = dir(fullfile(base_path, '*.mat'));
    total_size = sum([folder_info.bytes]);
    fprintf('Total size of saved data: %.2f GB\n', total_size / 1e9);
end