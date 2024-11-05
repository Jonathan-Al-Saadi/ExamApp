function [vol_path] = volPicker(examObj)
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

        volFlagNumberStill = input(['Which vol? \n' charArray '\n']);

        vol_path = volcell{volFlagNumberStill, 5};
    end