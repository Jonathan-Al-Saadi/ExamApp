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

%% Ask the user for input
for i = 1:numel(list)
    [indx,tf] = listdlg('ListString',collection.SeriesDescription, 'PromptString',['Select ' list{i}]);
    fileNumberInList(i) = indx;
end
end

%Create a list function (front end)
function list = listCreator()
    numberOfFiles = input('How many files/images should be read? \n');
    list = cell(1, numberOfFiles);
    for i = 1:numberOfFiles
        list{1, i} = input('Filedescription: \n', 's');
    end
end
