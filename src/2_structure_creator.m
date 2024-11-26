%% DICOM Structure Creation for Brain Blood Flow Analysis
% This script is the second step in the brain blood flow analysis pipeline.
% It creates an organized data structure from the previously sorted CTA and CTP
% DICOM files.
%
% Input:
%   - Sorted CTA and CTP files from step 1 (DICOM File Sorter)
%
% Output:
%   - Male_1956.mat containing:
%     * CTA: Cell array of CTA image paths
%     * CTP: 23 cells, each containing time series for one slice location
%     * CTA_of_fours: Groups of 4 CTA images matched to CTP slice locations
%
% Processing Steps:
%   1. Load and organize CTP images by slice location
%   2. Determine valid range for CTA images based on CTP locations
%   3. Filter and sort CTA images within the valid range
%   4. Group CTA images in sets of four
%
% Author: Yotam Gunders
% Last Modified: 26.11.2024

%% Initialize Environment
clear; clc;

%% Define Folder Paths
% Input paths - these should match the output directories from step 1
ctaFolderPath = "C:\Users\ygund\Desktop\Matlab_Projects\Final_Project_Yotam\final final project\ANONJA72BI1FH Male 1956\ANONJA72BI1FH Male 1956 'AXIAL MIP F_0.7'";
ctpFolderPath = "C:\Users\ygund\Desktop\Matlab_Projects\Final_Project_Yotam\final final project\ANONJA72BI1FH Male 1956\ANONJA72BI1FH Male 1956 'HEAD PERFUSION'";

%% Create Destination Folders
% Create destination folders if they don't exist
fprintf('Setting up destination directories...\n');

if ~exist(destinationCTAPath, 'dir')
    mkdir(destinationCTAPath);
    fprintf('Created CTA directory: %s\n', destinationCTAPath);
end

if ~exist(destinationCTPPath, 'dir')
    mkdir(destinationCTPPath);
    fprintf('Created CTP directory: %s\n', destinationCTPPath);
end

%% Initialize Counters
ctaFileCount = 0;
ctpFileCount = 0;
errorCount = 0;

%% Process Files
% List all files in the source folder and its subfolders
fprintf('\nScanning source directory for DICOM files...\n');
files = dir(fullfile(sourceFolderPath, '**', '*.*'));

% Progress bar initialization
totalFiles = length(files);
fprintf('Found %d total files to process\n', totalFiles);

% Loop through each file
for i = 1:length(files)
    % Construct full file path
    dicomFilePath = fullfile(files(i).folder, files(i).name);
    
    % Display progress
    if mod(i, 100) == 0
        fprintf('Processing file %d of %d (%.1f%%)\n', i, totalFiles, (i/totalFiles)*100);
    end
    
    try
        % Read DICOM metadata
        fileInfo = dicominfo(dicomFilePath, 'UseDictionaryVR', true);
        
        % Process only if SeriesDescription exists
        if isfield(fileInfo, 'SeriesDescription')
            seriesDescription = strtrim(fileInfo.SeriesDescription);
            
            % Sort and copy files based on series description
            if contains(seriesDescription, 'AXIAL MIP  F_0.7', 'IgnoreCase', true)
                copyfile(dicomFilePath, destinationCTAPath);
                ctaFileCount = ctaFileCount + 1;
                
            elseif contains(seriesDescription, 'HEAD PERFUSION', 'IgnoreCase', true)
                copyfile(dicomFilePath, destinationCTPPath);
                ctpFileCount = ctpFileCount + 1;
            end
        end
        
    catch ME
        errorCount = errorCount + 1;
        fprintf('\nError processing file: %s\nError message: %s\n', ...
            files(i).name, ME.message);
    end
end

%% Final Report
fprintf('\nFile Processing Complete!\n');
fprintf('Summary:\n');
fprintf('- CTA files copied: %d\n', ctaFileCount);
fprintf('- CTP files copied: %d\n', ctpFileCount);
fprintf('- Errors encountered: %d\n', errorCount);
fprintf('- Total files processed: %d\n', totalFiles);

% Check if any files were copied
if ctaFileCount == 0 && ctpFileCount == 0
    warning('No relevant DICOM files were found and copied.');
end