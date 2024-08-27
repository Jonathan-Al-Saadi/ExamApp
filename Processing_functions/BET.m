function [fileOUT, fileOUT_mask]  = BET(varargin)

switch nargin
    case 1
        %file2BET
        fileIN = varargin{1};

        %Options
        options.betMethod = 'mri_synthstrip';
        options.freeSurferFlags = '';
        options.checkIMG = 1;

        fileOUT = [fileIN(1:end-4) '_brain.nii.gz'];
        fileOUT_mask = [fileIN(1:end-4) '_brain_mask.nii.gz'];

    case 2
        fileIN = varargin{1};
        options = varargin{2};
        fileOUT = [fileIN(1:end-4) '_brain.nii.gz'];
        fileOUT_mask = [fileIN(1:end-4) '_brain_mask.nii.gz'];

    case 3
        fileIN = varargin{1};
        options = varargin{2};
        fileOUT = varargin{3};
        fileOUT_mask = [fileOUT '_brain_mask.nii.gz'];     
    
end

%Check if the folder exists. If it does not, create it.
if ~exist(fileparts(fileOUT), 'dir')
    mkdir(fileparts(fileOUT));
end

if strcmp(options.betMethod, 'mri_synthstrip')
    %Brain extraction
    cmd = ['$FREESURFER_HOME/bin/mri_synthstrip -i "', fileIN, '" -o "', fileOUT, '" -m "', fileOUT_mask '" ' options.freeSurferFlags];
    iserror = system(cmd);
end

if options.checkIMG == 1 && ~iserror
    checkImg(fileIN, fileOUT, fileOUT_mask, fileIN)
end

end

 function checkImg(fileIN, fileOUT, fileOUT_mask, name)
        fig = figure("Name", name);

        %Show BET to user and make sure it is accepted!
        tmpImgMask = niftiread(fileOUT_mask);
        tmpImg= niftiread(fileIN);

        tl = imtool3D(tmpImg, [0 0 1 1], fig);
        tl.setMask(tmpImgMask);

        user_answer = askUser();
        %Default -val
        b_val = 1; b_flag = '';
        csf_flag = '';

        while user_answer ~= 1
            %Change f-val or let user edit accordingly
            switch user_answer
                case 2
                    b_val = b_val + 1;
                case 3
                    b_val = b_val -1;
                case 4
                    tmpImgMask = tl.getMask;
                    tmpImg_brain = tmpImg .* int16(tmpImgMask);
                    %Write new to disk
                    %name
                    niftiwrite(double(tmpImg_brain), fileOUT(1:end-7), niftiinfo(fileOUT), Compressed=true);
                    niftiwrite(uint8(tmpImgMask), fileOUT_mask(1:end-7), niftiinfo(fileOUT_mask), Compressed=true);


                    user_answer = 1;
                case 5
                    csf_flag =  ' --no-csf';
            end

            if user_answer ~= 4 && user_answer ~= 1

                %Write out the new command
                cmd = ['$FREESURFER_HOME/bin/mri_synthstrip -i "', fileIN, '" -o "', fileOUT, '" -m "', fileOUT_mask '" -b ' num2str(b_val) csf_flag];
                system(cmd);

                %Show image
                tmpImgMask = niftiread(fileOUT_mask);
                tl.setMask(tmpImgMask);

                user_answer = askUser();
            end
        end

        close all
 end

 function user_answer = askUser()
        prompt = "Do the following: \n" + ...
            "(1) Accept [Default]\n" + ...
            "(2) Include more brain [Increases B]\n" + ...
            "(3) Include less brain [Decreases B]\n" + ...
            "(4) Manual correction\n" + ...
            "(5) Remove CSF\n";

        user_answer = input(prompt);
        if isempty(user_answer)
            user_answer = 1;
        end
    end