function perf_calcTNTTP(varargin)
%PERF_CALCTNTTP Summary of this function goes here
%   Detailed explanation goes here

switch nargin
    case 1
        examObj = varargin{1};
        mask = [];
    case 2
        examObj = varargin{1};
        mask = varargin{2};
end

          extendBeyondHighCut = 10;
          extendBeyondLowCut = 0;

          ttpLow = [];
          ttpHigh = [];
          ttpCurve = cell(1);


            ttp = double(examObj.getVol('TTP'));
            
            if ~isempty(mask)
                ttp = ttp .* double(mask);
            end

            ttpLow = examObj.props.bolusCutOff.ttpLow;
            ttpHigh = examObj.props.bolusCutOff.ttpHigh;
            
            %Exclude values outside cutoff +/- extensions for plotting (useful to
            %plot unmasked whole 4D vol).
            ttp(ttp <= (ttpLow - extendBeyondLowCut)) = NaN;
            ttp(ttp > (ttpHigh + extendBeyondHighCut)) = NaN;

            %Get the vector describing the distribution
            [v, edges] = histcounts(ttp, max(ttp, [], 'all') - min(ttp, [], 'all'));

            %Normlize x-axis values
             xVals = edges(1:end-1);
             %Move to origo
             xVals = xVals - ttpLow;
             %Normalise
             xVals = xVals / (ttpHigh - ttpLow);

            %Save the data
            ttpCurve{1, 1} = v;
            ttpCurve{1, 2} = xVals;


          xVal = 0:0.01:3;
          xVal = xVal';

         
          %Smoothing
          v = [0 v];
          xVals = [0 xVals];
          %Get an interpolated vector for plotting
          vqTTP = interp1(xVals, v, xVal, 'makima');
          %Normalize the vector
          vqTTP = vqTTP ./ max(vqTTP(1:200));

   

          f = figure;
          hold on

          for i = 1:size(vqTTP, 2)
            hMLNind = plot(xVal, vqTTP(:, i));
          end


end

