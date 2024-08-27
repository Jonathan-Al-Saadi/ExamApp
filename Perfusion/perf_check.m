function volCell = perf_check(volCell, options, saveDir)
%PERF_CHECK Summary of this function goes here
%   Detailed explanation goes here
%Perf_check will check the volumes in examObjs volCell. If Volumes are not
%skullstripped it will run BET. It will merge the perfusion images to a 4D
%volume. Create a pre_processed volume and R2 star. VolCell is the volCell
%property form examObj. Options is used for pre_processing, BET and so on.
%SaveDir is where it should save the images
%BE
%

%%Check the volumes
if ~any(contains(volCell(:,3)', 'Forsk_Ax_Perf'))
    return;
end
%% Check if there are several vols and merge
if any(contains(volCell(:,3)', 'Forsk_Ax_Perf'))
    [isfound, index] = ismember('merged_perfusion', volCell(:,3));

    if ~isfound
        fprintf('Merging perfusion vol...\n');
        i = find(contains(volCell(:,3)', 'Forsk_Ax_Perf'));

        % Specify the directory
        directory = fileparts(volCell{i, 4});

        % Get list of all volCell and folders in the specified directory
        dirInfo = dir(directory);

        % Remove folders from the list (keep only volCell)
        isFile = ~[dirInfo.isdir];
        fileList = dirInfo(isFile);

        % Extract file names
        fileNames = {fileList.name};


        % Construct full file paths using cellfun
        filePaths = cellfun(@(x) fullfile(directory, x), fileNames, 'UniformOutput', false);

        %Set mergeLocation
        mergeLocation = [saveDir, filesep, options.pre_process_settings.processed_saveName,...
            filesep, 'mergedPerfusion.nii'];

      

        % Merge
        spm_file_merge(filePaths,  mergeLocation);

        %Correct name
        volCell{height(volCell)+1, 4} = mergeLocation;
        %Correct name
        volCell{height(volCell), 3} = 'merged_perfusion';

        %% Use mask for BET
         skullStripName = [saveDir filesep options.pre_process_settings.processed_saveName filesep ...
                        'Skull_Stripped' filesep 'merged_perfusion_brain.nii.gz'];

         %Read the mask
         perf_mask = niftiread(volCell{i, 6});

         %Read the perfusion vol
         perf_vol = niftiread(volCell{i, 4});

         %Multiply mask with timedimension
         perf_mask_4D = repmat(perf_mask, [1, 1, 1, size(perf_vol, 4)]);

         %extract the brain
         merged_perfusion_brain = int16(perf_mask_4D) .* niftiread(mergeLocation);

         %write the vol to disk
         niftiwrite(merged_perfusion_brain, skullStripName, niftiinfo(mergeLocation));

         %save the brainextraction in volcell
         volCell{height(volCell), 5} = skullStripName;
         volCell{height(volCell), 6} = volCell{i, 6};

    end
end

%Find if proccessed volume exists
[isfound, index] = ismember('pre_processed_perf', volCell(:,3));

if ~isfound

    fprintf('Did not find pre_processed_perf, writing...\n'); 
    %finding location of Forsk_Ax_Perf
    index = find(cell2mat(cellfun(@(x) contains(x, 'merged_perfusion'), volCell(:, 3), 'UniformOutput', false)));
    
    %Create the saveDir
    saveDirectory = [saveDir, filesep, options.pre_process_settings.processed_saveName,...
        filesep 'pre_processed_perf.nii'];
    
    %Process the volume
    outVolPath = perf_preProcess(options.pre_process_settings, volCell{index,4}, saveDirectory);

    volCell{height(volCell)+1,3} = 'pre_processed_perf';
    volCell{height(volCell),4} = outVolPath;
    
    %% Use mask for BET
         skullStripName = [saveDir filesep options.pre_process_settings.processed_saveName filesep ...
                        'Skull_Stripped' filesep 'pre_processed_perf_brain.nii.gz'];

     %Read the mask
     i = find(contains(volCell(:,3)', 'Forsk_Ax_Perf'));
         perf_mask = niftiread(volCell{i, 6});

         %Read the perfusion vol
         perf_vol = niftiread(volCell{i, 4});

         %Multiply mask with timedimension
         perf_mask_4D = repmat(perf_mask, [1, 1, 1, size(perf_vol, 4)]);

         %extract the brain
         pre_procecced_perfusion_brain = int16(perf_mask_4D) .* niftiread(outVolPath);

         %write the vol to disk
         niftiwrite(pre_procecced_perfusion_brain, skullStripName, niftiinfo(outVolPath));

         %save the brainextraction in volcell
         volCell{height(volCell), 5} = skullStripName;
         volCell{height(volCell), 6} = volCell{i, 6};
end

%Find if R2 Star volume exists
[isfound, index] = ismember('R2Star', volCell(:,3));

if ~isfound
    
    fprintf('Did not find R2_star, writing...\n'); 
    %finding location of Forsk_Ax_Perf
    index = find(cell2mat(cellfun(@(x) contains(x, 'pre_processed_perf'), volCell(:, 3), 'UniformOutput', false)));
    
    saveDirectory = [saveDir, filesep, options.pre_process_settings.processed_saveName,...
        filesep 'R2Star.nii'];

    %Process the volume
    outVolPath = perf_convertToR2star(options, volCell{index,4}, saveDirectory);

    volCell{height(volCell)+1,3} = 'R2Star';
    volCell{height(volCell),4} = outVolPath;

    %% Use mask for BET
         skullStripName = [saveDir filesep options.pre_process_settings.processed_saveName filesep ...
                        'Skull_Stripped' filesep 'R2Star_brain.nii.gz'];

         %Read the mask
         i = find(contains(volCell(:,3)', 'Forsk_Ax_Perf'));
         perf_mask = niftiread(volCell{i, 6});

         %Read the perfusion vol
         perf_vol = niftiread(volCell{i, 4});

         %Multiply mask with timedimension
         perf_mask_4D = repmat(perf_mask, [1, 1, 1, size(perf_vol, 4)]);

         %extract the brain
         r2star_brain = int16(perf_mask_4D) .* niftiread(outVolPath);

         %write the vol to disk
         niftiwrite(r2star_brain, skullStripName, niftiinfo(outVolPath));

         %save the brainextraction in volcell
         volCell{height(volCell), 5} = skullStripName;
         volCell{height(volCell), 6} = volCell{i, 6};
end

%Find if BET volume exists. Removed this to main function
% if width(volCell) < 5
% 
%     fprintf('Did not find extracted brainvols, writing using default settings...\n');
%     mkdir tmp;
%     addpath tmp;
%     for volIter = 1:height(volCell)
%         saveLocationName = [saveDir filesep options.pre_process_settings.processed_saveName filesep ...
%             'Skull_Stripped' filesep volCell{volIter, 3} '_brain.nii.gz'];
%         [volCell{volIter, 5}, volCell{volIter, 6}] = BET(volCell{volIter, 4}, options.BET_settings, saveLocationName);
%     end
% end

end


