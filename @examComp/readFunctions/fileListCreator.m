function [fileNumberInList, list, collection] = fileListCreator(options, collection)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Check options input
if ~nargin
    warning("No options in, creating collection.")
    collection = CollectionCreator;
    options.fileNumberInList = [];
    options.list = listCreator;
end


%Check if collection exists
if ~exist('collection', 'var') == 1
    collection = CollectionCreator;
end

%Check if list exists
if ~isfield(options,'list') == 1
    options.list = listCreator;
end

%% Figure out what files are diffusion, T1, perfusion and ADC etc.
list = options.list;
%list = {'Diffusion', 'ADC', 'T1', 'T2-starperfusion'};
fileNumberInList = [];

%% If there are several dates in the collection
if length(unique(collection.StudyDateTime)) > 1
    dialogList = strcat(string(datetime(collection.StudyDateTime, 'Format', 'yyyy-MM-dd')), {' '},collection.SeriesDescription);
else
    dialogList = collection.SeriesDescription;
end

%% Ask the user for input
    for i = 1:numel(list)
        indx = selectWithPreview(['Select ' list{i}], dialogList, collection);
        fileNumberInList(i) = indx;
    end

    %Remove the ones that did not exist
    list = list(fileNumberInList ~= -1);
    fileNumberInList = fileNumberInList(fileNumberInList ~= -1);
end

%Create a list function (front end)
function list = listCreator()
    numberOfFiles = input('How many files/images should be read? \n');
    list = cell(1, numberOfFiles);
    for i = 1:numberOfFiles
        list{1, i} = input('Filedescription: \n', 's');
    end
end

function indx = selectWithPreview(promptString, dialogList, collection)
    % Initialize the filtered list (initially all items)
    filteredList = dialogList;
    originalList = dialogList;

    % GUI layout parameters
    figWidth = 800;
    figHeight = 600;
    leftPanelWidth = 300;
    searchBoxHeight = 25;
    buttonHeight = 30;
    buttonWidth = 100;
    spacing = 10;

    % Create the figure window
    hFig = figure('Name', promptString, 'MenuBar', 'none', 'Toolbar', 'none', ...
                  'NumberTitle', 'off', 'Position', [100, 100, figWidth, figHeight], 'Resize','off');

    % Calculate positions
    searchBoxY = figHeight - searchBoxHeight - spacing; % Position of search box from bottom
    listboxY = buttonHeight + 2 * spacing;              % Position of listbox from bottom
    listboxHeight = searchBoxY - listboxY - spacing;    % Height of the listbox

    % Create the search box
    hSearchBox = uicontrol('Style', 'edit', 'Position', [spacing, searchBoxY, leftPanelWidth, searchBoxHeight], ...
                           'KeyReleaseFcn', @searchCallback, 'HorizontalAlignment', 'left');

    % Create the listbox
    hListbox = uicontrol('Style', 'listbox', 'Position', [spacing, listboxY, leftPanelWidth, listboxHeight], ...
                         'String', filteredList, 'Callback', @listboxCallback);

    % Create the axes for image display
    axesX = leftPanelWidth + 2 * spacing;
    axesWidth = figWidth - axesX - spacing;
    axesHeight = figHeight - buttonHeight - 3 * spacing;
    hAxes = axes('Parent', hFig, 'Units', 'pixels', 'Position', [axesX, buttonHeight + spacing, axesWidth, axesHeight]);

    % Create OK and Cancel buttons
    hOK = uicontrol('Style', 'pushbutton', 'String', 'OK', 'Position', [spacing, spacing, buttonWidth, buttonHeight], 'Callback', @okCallback);
    hCancel = uicontrol('Style', 'pushbutton', 'String', 'Cancel', 'Position', [2 * spacing + buttonWidth, spacing, buttonWidth, buttonHeight], 'Callback', @cancelCallback);
    hNone = uicontrol('Style', 'pushbutton', 'String', 'Does not exist', 'Position', [3 * spacing + 2* buttonWidth, spacing, buttonWidth, buttonHeight], 'Callback', @doesNotExistCallback);

    % Variable to store the selected index
    selectedIndex = [];
    filteredIndices = 1:length(originalList);

    % Wait for the user to make a selection
    uiwait(hFig);

    % Output the selected index
    indx = selectedIndex;

    % Callback function for search box
    function searchCallback(src, ~)
        searchTerm = lower(get(src, 'String')); % Get the search term in lower case
        if isempty(searchTerm)
            % If search term is empty, show all items
            filteredList = originalList;
            filteredIndices = 1:length(originalList);
        else
            % Filter the list based on the search term
            matches = contains(lower(originalList), searchTerm);
            filteredList = originalList(matches);
            filteredIndices = find(matches);
        end
        % Update the listbox
        set(hListbox, 'String', filteredList, 'Value', 1);
        % Clear the image preview
        cla(hAxes);
    end

    % Callback function for listbox selection
    function listboxCallback(src, ~)
        idxInFiltered = src.Value; % Index in the filtered list
        if isempty(idxInFiltered)
            return;
        end
        % Map the index back to the original collection
        idx = filteredIndices(idxInFiltered);
        % Get the DICOM files corresponding to the selected item
        dicomFiles = collection(idx, :).Filenames;
        % Take the first set of files (if nested)
        dicomFile = dicomFiles{1};
        try
            % Read the middle image from the DICOM series
            midIdx = round(length(dicomFile)/2);
            img = dicomread(dicomFile{midIdx});
            % Display the image
            imshow(img, [], 'Parent', hAxes, 'InitialMagnification', 'fit');
        catch ME
            warning('Could not read DICOM file: %s\nError: %s', dicomFile{midIdx}, ME.message);
            cla(hAxes);
        end
    end

    % Callback function for OK button
    function okCallback(~, ~)
        idxInFiltered = hListbox.Value; % Index in the filtered list
        if isempty(idxInFiltered)
            selectedIndex = [];
        else
            % Map the index back to the original collection
            selectedIndex = filteredIndices(idxInFiltered);
        end
        uiresume(hFig);
        close(hFig);
    end

    % Callback function for Cancel button
    function cancelCallback(~, ~)
        selectedIndex = -1;
        uiresume(hFig);
        close(hFig);
    end

    function doesNotExistCallback(~, ~)
        selectedIndex = -1;
        uiresume(hFig);
        close(hFig);
    end
end





