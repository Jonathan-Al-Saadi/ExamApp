function [X, Y, T, AUC] = calcROC_perf(dwi_mask, ttp_values, brainMask)
% Load TTP and DWI mask data


% Ensure TTP values and DWI mask are numeric
ttp_values = double(ttp_values);  % Convert TTP values to floating-point if necessary
dwi_mask = double(dwi_mask);% Convert DWI mask to binary (0, 1)
brainMask = double(brainMask); %Brainmask to double

%Outside should be NaN;
brainMask(brainMask ==0) = NaN;
dwi_mask = dwi_mask.*brainMask;
ttp_values = ttp_values.*brainMask;


% Reshape to vectors (if necessary)
ttp_values = ttp_values(:);  % Flatten the TTP values to a column vector
dwi_mask = dwi_mask(:);      % Flatten the DWI infarction mask to a column vector

% Remove NaN values or any mismatched dimensions
valid_idx = ~isnan(ttp_values) & ~isnan(dwi_mask);  % Identify valid indices

ttp_values = ttp_values(valid_idx);  % Filter out NaNs in TTP values
dwi_mask = dwi_mask(valid_idx);      % Filter out corresponding entries in DWI mask

% Check if both arrays have the same length
assert(length(ttp_values) == length(dwi_mask), 'TTP values and DWI mask must have the same length');

% Compute ROC curve
[X, Y, T, AUC] = perfcurve(dwi_mask, ttp_values, 1);

% Plot ROC curve
figure;
plot(X, Y, 'LineWidth', 2);
xlabel('False Positive Rate');
ylabel('True Positive Rate');
title(['ROC Curve, AUC = ' num2str(AUC)]);
grid on;

end


% extendBeyondLowCut = 0;
% extendBeyondHighCut = 10;
% ttp = TN_TTP;
% volcell = ex.getVolCells
% imtool3D(niftiread(volcell{5,4}))
% ttpLow = 31
% ttpHigh = 43
% ttp(ttp <= (ttpLow - extendBeyondLowCut)) = NaN;
% ttp(ttp > (ttpHigh + extendBeyondHighCut)) = NaN;
% ttp = ttp(:);
% [R TF] = rmmissing(ttp);
% sum(R)
% ind = ttp == 0;
% ttp(ind) = [];
% dwi_mask(ind) = [];
% ttp = double(ttp);
% [X, Y, T, AUC] = perfcurve(dwi_mask, ttp, 1);
