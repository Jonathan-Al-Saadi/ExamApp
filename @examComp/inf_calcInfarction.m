function [infarctionMasks] = inf_calcInfarction(examObj)
%A function that tries to calculate/find an infarction using DWI and ADC
%images. 

%% Extract the data
%Get the masked standard DWI
[~,info_dwi,~,DWI] = examObj.getVol('isotropic');
%Get the masked standard ADC
[~,info,~,ADC] = examObj.getVol('avdc');

%Apply correct stupid scaling
%ADC = info.AdditiveOffset + ADC.*info.MultiplicativeScaling;

%% Suggesting areas for the infarction.
%Get standard infarction mask
[mask, stdMultiplier] = calcStandardInfarction(DWI, ADC, 1);

%% Write the masks to disk as niftifiles
maskPath = examObj.writeVol('infarction_mask', int16(mask), info_dwi);

%Get it out
infarctionMasks.mask = mask;
infarctionMasks.maskPath = maskPath;

%% Get the mask volume in mL
%Reading the nifti info
info = niftiinfo(maskPath);

%Get pixelDimensions
pixelDimensions = info.PixelDimensions;

%Calculate the number of voxels
numberOfVoxels = sum(mask, 'all');

%Calculate the actual volume
actualVolume = numberOfVoxels * pixelDimensions(1) * pixelDimensions(2) * pixelDimensions(3);

%Convert to mL
if strcmp(info.SpaceUnits, 'Millimeter')
    actualVolumeInML = actualVolume/1000;
else
    print("It is not in Millimeter!!!!!")
end

infarctionMasks.volume = actualVolumeInML;

infarctionMasks.stdMultiplier = stdMultiplier;


end

function [mask, stdMultiplier] = calcStandardInfarction(DWI, ADC, userInput)
%% Calculating mean and STD standard DWI
%set all outside mask = NaN;
DWI(DWI == 0) = NaN;

%calculating mean and STD
MeanDWI = mean(DWI, 'all', 'omitnan');
StdDWI = std(double(DWI), 0, 'all', 'omitnan');

%% Calculating mean and STD for standard ADC
%set all outside mask = NaN;
ADC(isnan(DWI)) = NaN;

%calculating mean and STD
MeanADC = mean(ADC, 'all', 'omitnan');
StdADC = std(double(ADC), 0, 'all', 'omitnan');

%% Checking areas that are white (3STDs on DWI)
%Staring with neuromix

%Checking if those voxels are dark on ADC (3STD)
%maskedADC = ADC < (MeanADC - 1*StdADC);
stdMultiplier = 5;
maskedADC = ADC < (620);

maskDWI = DWI.*maskedADC > (MeanDWI + stdMultiplier*StdDWI);



%Suggesting infarction area
mask = (maskDWI & maskedADC) == 1;



if userInput
    
   [mask, stdMultiplier] = checkImg(DWI, mask, MeanDWI, StdDWI, maskedADC);

end


end

function [mask, stdMultiplier] = checkImg(DWI, mask, MeanDWI, StdDWI, maskedADC)

%Creating imtool3D window
tool = imtool3D(DWI);
tool.setMask(mask);
user_answer = askUser();
%Default stdMultiplier

stdMultiplier = 5;


while user_answer ~= 1
    %Change std-val or let user edit accordingly
    switch user_answer
        case 2
            stdMultiplier = stdMultiplier -1;
        case 3
            stdMultiplier = stdMultiplier + 1;
        case 4
            mask = tool.getMask;
            user_answer = 1;
    end

    if user_answer ~= 4 && user_answer ~= 1
    
        maskDWI = DWI.*maskedADC > (MeanDWI + stdMultiplier*StdDWI);

        %Suggesting infarction area
        mask = (maskDWI & maskedADC) == 1;

        %Show image
        tool.setMask(mask);

        user_answer = askUser();
    end
end

close all
end

function user_answer = askUser()
prompt = "Do the following: \n" + ...
    "(1) Accept [Default]\n" + ...
    "(2) Include more infarction\n" + ...
    "(3) Include less infarction\n" + ...
    "(4) Manual correction\n" ;
user_answer = input(prompt);
if isempty(user_answer)
    user_answer = 1;
end
end
