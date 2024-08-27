classdef examComp < handle
    %examComp is a class that holds exams for a given patient. It can be
    %used to create different images, register, find infarctions and
    %perform statistics

    properties (SetAccess = {?exam_constructor}, GetAccess = private)
        volCell
    end

    properties (SetAccess = public, GetAccess = public)
        props
        handle
        options
        stats
        infarctionMasks
        collection
    end

    methods (Access = public)
        %Construct the examobject with all properties
        function examObj = examComp(varargin)
            %Construct the object
            examObj.exam_constructor(varargin{:});

            %Check if BET exisits and create them
            examObj.BET_check;
            
            %Check if perfusion volumes exists and create them
            examObj.volCell = perf_check(examObj.volCell, examObj.options, examObj.props.patientDir);
            
            %save the object
            examObj.saveData;
        end
        
        %% Processing functions

        %If you want to extract using own settings
        function extractBrains(examObj)
            volCell = examObj.volCell;
            
            %Perform BET and stor BET and mask i column 5 and 6 in volcell
            for volIter = 1:height(volCell)
                [volCell(volIter, 5), volCell(volIter, 5)] = BET(volCell{volIter, 4}, examObj.options);
            end
            
        end

        function BET_check(examObj)
            
            %Initialize 5th row if it is empty
            if width(examObj.volCell) < 5
                examObj.volCell{1, 5} = [];
            end

            %Check if BET exists
            isEmptyFifthColumn = cellfun(@(x) isempty(x), examObj.volCell(:, 5));

            %List the empty rows
            emptyIndices = find(isEmptyFifthColumn);

            if ~isempty(emptyIndices)
                fprintf('Did not find extracted brainvols for all rows, writing using default settings...\n');
                %SaveDir
                saveDir = examObj.props.patientDir;

                %Get options
                options = examObj.options;
                
                %Get volCell
                volCell = examObj.volCell;

                %Run the BET function
                for volIter = emptyIndices'
                    saveLocationName = [saveDir filesep options.pre_process_settings.processed_saveName filesep ...
                        'Skull_Stripped' filesep volCell{volIter, 3} '_brain.nii.gz'];
                    [volCell{volIter, 5}, volCell{volIter, 6}] = BET(volCell{volIter, 4}, options.BET_settings, saveLocationName);
                end

                %Save new VolCell
                examObj.volCell = volCell;
            end
        end

        function viewVol
            
        end
        
        %% Get Functions
        function volCell = getVolCells(examObj)
            volCell = examObj.volCell;
        end

        function props = getProps(examObj)
            props = examObj.props;
        end

        function options = getOptions(examObj)
            options = examObj.options;
        end

        function infarctionMasks = getInfarctionMasks(examObj)
            infarctionMasks = examObj.infarctionMasks;
        end

        function stats = getStats(examObj)
            stats = examObj.stats;
        end

        function collection = getCollection(examObj)
            collection = examObj.collection;
        end
        
        function [ttpLow, ttpHigh] = getTimeCutoffs(examObj)
            ttpLow = examObj.props.bolusCutOff.ttpLow;
            ttpHigh = examObj.props.bolusCutOff.ttpHigh;
        end

        function [outVol, outVolInfo, outVolMask, outVolMasked] = getVol(varargin)
            [outVol, outVolInfo, outVolMask, outVolMasked] = perf_getVol(varargin{:});
        end
        
        %% Save and load
        function saveData(varargin)
            exam_saveData(varargin{:});
        end
        
        function varargout = writeVol(examObj, volName, vol, info)
            saveLocationName = writeVolTodisk(examObj, volName, vol, info);

            if nargout > 0
                varargout{1} = saveLocationName;
            end
        end
        
        %% Perfusion functions
        function setTTPCutoff(varargin)
            perf_setTTPCutoff(varargin{:});
        end

        function calcTNTTP(varargin)
            perf_calcTNTTP(varargin{:});
        end
            
        
        %% Set functions
        function setVolCell(examObj, volCell)
            examObj.volCell = volCell;
        end

        %% Calc function
        function calcInfarction(examObj)
            examObj.infarctionMasks = inf_calcInfarction(examObj);
        end

        function [savePathImg, matFileName]  = linear_registration(varargin)
            %%TODO add this to volcell or save it somewhere?
            [savePathImg, matFileName]  = ex_linear_registration(varargin{:});

        end


       

    
    end

    methods (Access = private)
        examObj = perf_constructor(varargin);
        perf_setTTPCutoff(varargin);
        perf_calcTNTTP(varargin);
    end

end

