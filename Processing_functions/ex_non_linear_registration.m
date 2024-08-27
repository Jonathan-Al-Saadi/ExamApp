function registeredImages = ex_non_linear_registration(varargin)
%% Get the paths to the wanted volumes
%Masks

%If no arguments are supplied the function will assume you want to do a
%registration from a functional image to a structural image and an
%infarctionMask
switch nargin
    case 1
        examObj = varargin{1};
        [stillImage, stillImage_brain, movingImage, ~] = imagePicker(examObj);
        [savePath, saveName] = createSavePath(examObj, stillImage, movingImage);
        infarctionMask = examObj.getInfarctionMasks;
        movingMask = infarctionMask.maskPath;
        
    case 4
        examObj = varargin{1};
    
end

if ~exist(savePath, 'dir')
    mkdir(savePath)
end
addpath(savePath);


%Neuromix diffusion to MNI via T2Flair
mniPaths = registerToMNI(movingImage,stillImage_brain,stillImage, savePath, saveName, movingMask);

%% Work with the mask
%Inverse the neuromix mask
%mniPathsNeuroMix.contralateralNeuromixMask = inverseMask(mniPathsNeuroMix.outMask, savePath, 'neuromixInvertedMask');
%Inverse the standardMask
%mniPathsStandard.contralateralStandardMask = inverseMask(mniPathsStandard.outMask, savePath, 'standardInvertedMask');


%% Save the paths
registeredImages.NeuromixDiff2Flair = savePathImgNeuroMix;
registeredImages.StandardDiff2Flair = savePathImgStandard;
registeredImages.NeuromixDiff2FlairMask = [savePathImgNeuroMix, '_mask.nii.gz'];
registeredImages.StandardDiff2FlairMask = [savePathImgStandard, '_mask.nii.gz'];
%registeredImages.Neuromix2MNI = mniPathsNeuroMix;
%registeredImages.Standard2MNI = mniPathsStandard;


    function [mniPaths] = registerToMNI(movingImage,stillImage_brain,stillImage, savePath, saveName, maskLocation)
        %% Inverse the mask
        savePath = [savePath, filesep, saveName];
        if ~exist(savePath, 'dir')
            mkdir(savePath)
        end
        addpath(savePath)

        %Add escape characters to paths
        movingImage = strrep(movingImage, ' ', '\ ');
        stillImage = strrep(stillImage, ' ', '\ ');
        stillImage_brain = strrep(stillImage_brain, ' ', '\ ');
        savePath = strrep(savePath, ' ', '\ ');
        maskLocation = strrep(maskLocation, ' ', '\ ');

        newMaskName = [savePath, '/inverseMask.nii.gz'];
        cmd = ['$FSLDIR/bin/fslmaths ', maskLocation, ' -sub 1 -mul -1 ', newMaskName];
        system(cmd);


        %% Register that shit using FSL
        %Rigid body registration
        rigidBodyMat = [savePath, '/func2struct.mat'];
        cmd = ['$FSLDIR/bin/flirt -ref ' stillImage_brain, ' -in ', movingImage, ' -dof 6 -omat ', rigidBodyMat, ' -bins 256 -cost corratio -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 6  -interp trilinear -v'];
        system(cmd);

        %Using affine transformation to register structural scan to MNI152 and get
        %the predicted matrix
        affineMat = [savePath '/my_affine_transf.mat'];
        %cmd = ['$FSLDIR/bin/flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in ' stillImage_brain ' -omat ' affineMat, ' -v'];
        cmd = ['$FSLDIR/bin/flirt -ref ${FSLDIR}/data/standard/MNI152_T1_2mm_brain -in ' stillImage_brain ' -omat ' affineMat, ' -bins 256 -cost corratio -searchrx -180 180 -searchry -180 180 -searchrz -180 180 -dof 12  -interp trilinear -v'];
        system(cmd);

        % The non-linear registration
        %configpath = ['$FSLDIR/src/fnirt/fnirtcnf/T1_2_MNI152_2mm.cnf'];
        configpath = 'T1_2_MNI152_2mm.cnf';
        coutp = [savePath '/my_nonlinear_transf'];

        cmd = ['$FSLDIR/bin/fnirt --in=', stillImage, ' --aff=', affineMat, ' --cout=' coutp ' --config=' configpath,  ' --refout=' savePath '/refImg' ' -v'];
        %cmd = ['$FSLDIR/bin/fnirt --in=', stillImage, ' --aff=', affineMat, ' --cout=' coutp, ' -v' ];
        system(cmd);

        % Apply the warp to the functional image
        outFunc = [savePath,'/warped_functional'];
        cmd = ['$FSLDIR/bin/applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=', movingImage, ' --warp=',coutp, ' --premat=', rigidBodyMat, ' --out=', outFunc, ' -v' ];
        system(cmd)

        %Apply the warp to the structural image
        outStruct = [savePath,'/warped_structural'];
        cmd = ['$FSLDIR/bin/applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=',stillImage_brain, ' --warp=',coutp, ' --out=', outStruct, ' -v' ];
        system(cmd)

        %Apply the warp to the mask image
        outMask = [savePath,'/warped_mask'];
        cmd = ['$FSLDIR/bin/applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --in=',maskLocation, ' --warp=',coutp, ' --premat=', rigidBodyMat, ' --out=', outMask, ' -v' ];
        system(cmd)

        %Save the paths
        mniPaths.newMask = newMaskName;
        mniPaths.rigidBodyMat = rigidBodyMat;
        mniPaths.affineMat = affineMat;
        mniPaths.coutp = coutp;
        mniPaths.diffusion = outFunc;
        mniPaths.flair = outStruct;
        mniPaths.outMask = outMask;
    end

    function savePathFileMask = inverseMask(maskPath, savePathFile, name)

        %% Read the mask
        maskInMNI = niftiread(maskPath);
        info = niftiinfo(maskPath);
        [nrows, ncols, nslices] = size(maskInMNI);


        %Different thresholds can be used. 0.9 is conservative, 0.1 is
        %liberal. 0.5 will ensure a similar size of the mask.
        voxelThreshold = 0.5;

        %% Find the indexes of the mask;
        index = find(maskInMNI(:) >= voxelThreshold);
        [I,J,K] = ind2sub([nrows, ncols, nslices],index);

        %Because matlab start at 1 we have to subtract -1 from I, J and
        %K...
        I = I-1;
        J = J-1;
        K = K-1;

        %Find them in mniSPace
        mniCordinates = voxel2MNI([I J K], info.Transform.T');

        xVal = mniCordinates(:,1); yVal = mniCordinates(:,2); zVal = mniCordinates(:,3);

        %% Reverse the mask to contralateral side
        contraLateralMni = [-xVal, yVal, zVal];

        %Get the mask back into normal cordinates
        reversedCordinatesMask = mni2cor(contraLateralMni, info.Transform.T');

        %GO from coordinates back to mask +1 because 0 vs 1 indexing
        indxReversedCordinatesMask = sub2ind([nrows, ncols, nslices], reversedCordinatesMask(:,1)+1, reversedCordinatesMask(:,2)+1, reversedCordinatesMask(:,3)+1);

        %Create contralateral mask
        contraLateralMask = zeros([nrows, ncols, nslices]);

        contraLateralMask(indxReversedCordinatesMask) = 1;

        %% Save the mask
        %Filename
        savePathFileMask = [savePathFile, filesep, name];
        %Write it to disk
        niftiwrite(single(contraLateralMask), savePathFileMask, info);

    end

    function savePathFile = warpBackToStandard(struct_path, warp_path, savePath, inverseMaskPath)

        %Saving the files
        savePathFile = [savePath filesep 'ContralateralMaskInFlairSpace'];
        savePathMat = [savePath filesep 'warps_into_my_struct_space'];

        %Creating the inverse warp file
        cmd = ['$FSLDIR/bin/invwarp --ref=' struct_path, ' --warp=', warp_path, ' --out=' savePathMat];
        system(cmd);

        %Applying warp
        cmd = ['$FSLDIR/bin/applywarp --ref=', struct_path, ' --in=', inverseMaskPath  ' --warp=', savePathMat, ' --out=', savePathFile, ' --interp=nn'];
        system(cmd);

    end

    function coordinate = mni2cor(mni, T)
        % function coordinate = mni2cor(mni, T)
        % convert mni coordinate to matrix coordinate
        %
        % mni: a Nx3 matrix of mni coordinate
        % T: (optional) transform matrix
        % coordinate is the returned coordinate in matrix
        %
        % caution: if T is not specified, we use:
        % T = ...
        %     [-4     0     0    84;...
        %      0     4     0  -116;...
        %      0     0     4   -56;...
        %      0     0     0     1];
        %
        % xu cui
        % 2004-8-18
        %


        coordinate = [mni(:,1) mni(:,2) mni(:,3) ones(size(mni,1),1)]*(inv(T))';
        coordinate(:,4) = [];
        coordinate = round(coordinate);
        return;
    end

    function mni = voxel2MNI(cor, T)
        cor = round(cor);
        mni = T*[cor(:,1) cor(:,2) cor(:,3) ones(size(cor,1),1)]';
        mni = mni';
        mni(:,4) = [];
    end
    
    %% Support functions
    function [savePath, saveName] = createSavePath(examObj, stillImage, movingImage)
        props = examObj.getProps;
        savePath = [props.patientDir filesep 'registered_images'];

        %Create the savename from originalNames
        [~, stillImageName] = fileparts(stillImage);
        [~, movingImageName] = fileparts(movingImage);

        saveName = [movingImageName, '_to_' stillImageName];
        saveName = strrep(saveName, ' ', '_');
    end

    function [stillImage, stillImage_brain, movingImage, movingMask] = imagePicker(examObj)
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
        stillImage_brain = volcell{volFlagNumberStill, 5};

        %Non extracted image
        stillImage = volcell{volFlagNumberStill, 4};

        %extracted for better performance
        movingImage= volcell{volFlagNumberMoving, 5};

        if strcmp(maskIncludeflag, 'y')
            movingMask = volcell{volFlagNumberMoving, 5};
        else
            movingMask = [];
        end


    end
end