function exam_saveData(varargin)

switch nargin
    case 1
        examObj = varargin{1};
        dirToWrite = examObj.options.saveLocation;

    case 2
        examObj = varargin{1};
        dirToWrite = varargin{2};
end

volCell = examObj.getVolCells;
props = examObj.getProps;
options = examObj.getOptions;
infarctionMasks = examObj.getInfarctionMasks;
stats = examObj.getStats;
collection = examObj.getCollection;

try
    save([dirToWrite filesep props.patientId '.mat'], 'volCell', 'options',...
        'infarctionMasks', 'props', 'stats', 'collection' );
catch
    warning('No directory was choosen! Data NOT saved!\n');
end
end