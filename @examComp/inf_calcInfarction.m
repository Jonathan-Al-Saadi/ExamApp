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
mask = calcStandardInfarction(DWI, ADC, 1);

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


end

function mask = calcStandardInfarction(DWI, ADC, userInput)
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

maskedADC = ADC < (620);

maskDWI = DWI.*maskedADC > (MeanDWI + 3*StdDWI);

%Suggesting infarction area
mask = (maskDWI & maskedADC) == 1;

if userInput
    %Taking user input.
    standard = imtool3D(DWI);
    standard.setMask(mask);
    pause
    mask = standard.getMask;
end


end
