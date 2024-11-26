function image = readDicomImage(filepath)
%READDICOMIMAGE Reads and preprocesses a DICOM image file
%   This function reads a DICOM image file, converts it to double precision,
%   and normalizes its values to the range [0,1].
%
% Inputs:
%   filepath - String, path to the DICOM file
%
% Outputs:
%   image    - Normalized double precision image matrix
%
% Example:
%   img = readDicomImage('path/to/dicom/file.dcm');
%
% Notes:
%   - Uses 'UseDictionaryVR' for robust DICOM header reading
%   - Performs min-max normalization to range [0,1]
%   - Output is always in double precision
%
% See also DICOMINFO, DICOMREAD

    % Read DICOM header
    dicomInfo = dicominfo(filepath, 'UseDictionaryVR', true);
    
    % Read and convert image to double
    image = double(dicomread(dicomInfo));
    
    % Normalize to [0,1] range
    image = (image - min(image(:))) / (max(image(:)) - min(image(:)));
end