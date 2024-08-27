function [outVol, outVolInfo, outVolMask, outVolMasked] = perf_getVol(varargin)

switch nargin
    case 1
        examObj = varargin{1};
        volFlag = getVolFlag(examObj);
    case 2
        examObj = varargin{1};
        volFlag = varargin{2};
 
end

%Get volcell
volcell = examObj.getVolCells;
%Find the volFlagg
i = find(contains(volcell(:,3)', volFlag, 'IgnoreCase', true));

%if volflag exists
if ~isempty(i)
    outVol = niftiread(volcell{i,4});
    outVolMask = niftiread(volcell{i,6});
    outVolInfo = niftiinfo(volcell{i,4});
    outVolMasked = niftiread(volcell{i,5});

end
end

function volFlag = getVolFlag(examObj)

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

    volFlagNumber = input(['Which vol\n' charArray '\n']);

    volFlag = volcell{volFlagNumber, 3};


end