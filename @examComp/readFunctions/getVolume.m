 function files = getVolume(options, collection, fileNumberInList)
%Function that finds volumes and converts to NIFTI. Output is a cell of
%locations

if ~nargin
    warning("No options in.")
    [fileNumberInList, list, collection] = fileListCreator();
    options.fileNumberInList = fileNumberInList;
    options.list = list;

    %Get the save location
    options.saveLocation = uigetdir();
end

%Converts to nifti and outputs the files
files = niftiConvert(options, collection, fileNumberInList);
end