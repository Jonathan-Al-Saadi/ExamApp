function files = niftiConvert(options, collection, fileNumberInList)

if ~nargin
    warning("No options in.")
    [fileNumberInList, list, collection] = fileListCreator();
    options.saveLocation = uigetdir();
end

%Create a cell to store file paths
files = cell(numel(fileNumberInList), 1);

% Where are the files located?
for i = 1:numel(fileNumberInList)
    %Folder name in first column
    files{i, 1} = fileparts(collection(fileNumberInList(i), :).Filenames{1}(1));
    %File names in second column
    files{i, 2} = collection(fileNumberInList(i), :).Filenames{1};
    %SeriesDescription in third column
    files{i,3} = char([collection(fileNumberInList(i), :).SeriesDescription]);
end


%% Converting files to nifti and storing them in saveLocationName
%Conversion
saveLocationName = [options.saveLocation, '/', collection.StudyInstanceUID{1}, '/', 'original']; % Define the save location
mkdir(saveLocationName);
addpath(saveLocationName);

% Conversion
for i = 1:height(files)
    % Get all the dicom headers
    headers = spm_dicom_headers(files{i, 2});
    % Use SPM dicom2nifti
    spm_dicom_convert(headers, 'all', 'series', 'nii', saveLocationName);
    % Find where it was saved
    pathName = [saveLocationName, '/' getlatestfile(saveLocationName)];
    dirNames = dir(pathName);
    fileName = {dirNames(~[dirNames.isdir]).name};
    files{i, 4} = [pathName '/' fileName{1}]; % Store the path in files
end

end