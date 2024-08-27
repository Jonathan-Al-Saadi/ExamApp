function [savePathImg, matFileName] = ex_linear_registration(varargin)
%This function takes in two paths, input_path_1 and input_path_2.
%input_path_2 is treated as the moving image. Default saves to same folder
%as input_path_1. The function uses FSL FLIRT.
%------------------------------------------------%
% Inputs:
%   stillImage - A path to a nifti file. This image is the still image
%   movingImage - A path to a nifti file, this image is treated as the moving image.
%   movingMask - A path to a mask to be registered. (optional)
%   savePath - Save location (optional)
%   saveName - Name for file (optional)
% Outputs:
%   Success flag - 1 if succes 0 if error

%% Parse inputs
switch nargin
    case 1
        examObj = varargin{1};
        [stillImage, movingImage, movingMask] = imagePicker(examObj);
       [savePath, saveName] = createSavePath(examObj, stillImage, movingImage);
    case 3
        examObj = varargin{1};
        stillImage = varargin{2};
        movingImage = varargin{3};
        movingMask = [];
       [savePath, saveName] = createSavePath(examObj, stillImage, movingImage);
   
    case 4
        examObj = varargin{1};
        stillImage = varargin{2};
        movingImage = varargin{3};
        movingMask = varargin{4};
        [savePath, saveName] = createSavePath(examObj, stillImage, movingImage);
    case 5
        examObj = varargin{1};
        stillImage = varargin{2};
        movingImage = varargin{3};
        movingMask = varargin{4};
        savePath = varargin{5};
        [~, saveName] = createSavePath(examObj, stillImage, movingImage);
    case 6
        examObj = varargin{1};
        stillImage = varargin{2};
        movingImage = varargin{3};
        movingMask = varargin{4};
        savePath = varargin{5};
        saveName = varargin{6};
end

savePathFolder = [savePath, filesep, saveName];

mkdir(savePathFolder);

addpath(savePathFolder);

savePathImg = [savePathFolder, filesep, saveName];

matFileName = [savePathFolder, '/invol2refvol.mat'];

%Add escape characters to paths
movingImage = strrep(movingImage, ' ', '\ ');
stillImage = strrep(stillImage, ' ', '\ ');
savePathImg = strrep(savePathImg, ' ', '\ ');
matFileName = strrep(matFileName, ' ', '\ ');
movingMask = strrep(movingMask, ' ', '\ ');

%The command for the image
cmd = ['$FSLDIR/bin/flirt -in ', movingImage, ' -ref ', stillImage, ' -out ', savePathImg, ' -omat ' matFileName, ' -bins 256 -cost corratio -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12 -interp trilinear'];

system(cmd);

%The command for the mask

if ~isempty(movingMask)
    cmd = ['$FSLDIR/bin/flirt -in ' movingMask ' -ref ' stillImage, ' -out ' savePathImg, '_mask -applyxfm -init ', matFileName, ' -interp trilinear'];
    system(cmd);
end

    function [savePath, saveName] = createSavePath(examObj, stillImage, movingImage)
        props = examObj.getProps;
        savePath = [props.patientDir filesep 'registered_images'];

        %Create the savename from originalNames
        [~, stillImageName] = fileparts(stillImage);
        [~, movingImageName] = fileparts(movingImage);

        saveName = [movingImageName, '_to_' stillImageName];
        saveName = strrep(saveName, ' ', '_');
    end
    function [stillImage, movingImage, movingMask] = imagePicker(examObj)
        volcell = examObj.getVolCells;
        cellArray = volcell(:, 3);
        % Initialize a new cell array to store the numbered strings
        numberedList = cell(size(cellArray));

        % Loop through each element and add the numbering
        for i = 1:length(cellArray)
            numberedList{i} = sprintf('%d. %s', i, cellArray{i});
        end

        % Convert the numbered list to a single character array with newline separation
        charArray = strjoin(numberedList, '\n');

        volFlagNumberStill = input(['Which vol as still image? \n' charArray '\n']);

        volFlagNumberMoving = input(['Which vol as moving \n' charArray '\n']);

        maskIncludeflag = input('Include mask? y/n \n', 's');

        %Using the extracted image
        stillImage = volcell{volFlagNumberStill, 5};

        %Not extracted for better performance
        movingImage= volcell{volFlagNumberMoving, 5};

        if strcmp(maskIncludeflag, 'y')
            movingMask = volcell{volFlagNumberMoving, 5};
        else
            movingMask = [];
        end


    end
end