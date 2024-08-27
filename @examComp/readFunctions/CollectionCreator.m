function [collection] = CollectionCreator(vol_path_folder)
% CollectionCreator created a collection out of dicom images

%% Check options input, if no input given try to act a front end
if ~nargin
    warning("No Vol Path folder")
    vol_path_folder = uigetdir();
end
%% Locate files
dicomdir = vol_path_folder;

%% Create a collection

%Check if there are a dicomdir in vol_path_folder and try to read that
%else it will read it all. (Saves time)
try
    collection = dicomCollection([dicomdir,'/DICOMDIR'], 'IncludeSubfolders', 1);
catch
    collection = dicomCollection(dicomdir, 'IncludeSubfolders', 1);
end

end

