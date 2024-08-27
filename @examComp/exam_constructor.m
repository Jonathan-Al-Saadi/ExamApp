function examObj = exam_constructor(examObj, varargin)
%EXAM_CONSTRUCTOR Summary of this function goes here
%   Detailed explanation goes here
switch nargin
    case 1
        %Asks the user how to read the volume
        options = readOptions;

        userChoice = input('(1) Load saved file \n(2) Load new volume \n');
        switch userChoice
            case 1
                [file, path] = uigetfile();
                load([path file]);
            case 2
                [collection, fileNumberInList, volCell] = getCollectionAndVols(options);
        end
    case 2
        options = varargin{1};
        [collection, fileNumberInList, volCell] = getCollectionAndVols(options);

    case 3
        options = varargin{1};

        
        collection = varargin{2};

        %Find the files
        fileNumberInList = fileListCreator(options, collection);

        %Convert the volumes to nifti and save the locations in a cell
        volCell = getVolume(options, collection, fileNumberInList);

    case 4
        options = varargin{1};
        collection = varargin{2};
        fileNumberInList = varargin{3};
        %Convert the volumes to nifti and save the locations in a cell
        volCell = getVolume(options, collection, fileNumberInList);

    case 5
        options = varargin{1};
        collection = varargin{2};
        fileNumberInList = varargin{3};
        volCell = varargin{4};

    case 7
        options = varargin{1};
        collection = varargin{2};
        volCell = varargin{3};
        props = varargin{4};
        infarctionMasks = varargin{5};
        stats = varargin{6};
end

%Get the props
if ~exist('props', 'Var')
 props = createPropsFunc(collection, options);
end

if ~exist('stats', 'Var')
    stats = struct();
end

if ~exist('infarctionMasks', 'Var')
    infarctionMasks = struct();
end

examObj.volCell = volCell;
examObj.props = props;
examObj.stats = stats;
examObj.infarctionMasks = infarctionMasks;
examObj.options = options;
examObj.collection = collection;

end

function [collection, fileNumberInList, volCell] = getCollectionAndVols(options)

        %Creates dicom collection
        collection = CollectionCreator();

        %Find the files
        fileNumberInList = fileListCreator(options, collection);

        %Convert the volumes to nifti and save the locations in a cell
        volCell = getVolume(options, collection, fileNumberInList);

end

function props = createPropsFunc(collection, options)
    props = struct();

    % Get patient ID
    props.metadata = dicominfo(collection.Filenames{1}(1));
    props.studyDate = collection.StudyDateTime(1);
    props.patientId = [props.metadata.PatientBirthDate '_' datestr(props.studyDate, 'yyyy_mm_dd_HH_MM')];
    props.sex = collection.PatientSex(1);
    props.patientDir = [options.saveLocation filesep collection.StudyInstanceUID{1}];
end

function options = readOptions()
fileId = fopen('settings.json', 'r');
raw = fread(fileId, inf);
str = char(raw');
fclose(fileId);
options = jsondecode(str);
end