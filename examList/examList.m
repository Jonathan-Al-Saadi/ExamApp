classdef examList < handle

    properties (SetAccess = public, GetAccess = public)

        exams
        handles
        states

    end

    properties (SetAccess = private, GetAccess = public)

        loadedExam
    end

    events
        newMousePosition
    end

    methods (Access = public)

        function examListObj = examList(varargin)
            %% Initialize the object
            exams.names = 'No exams loaded';
            examListObj.loadedExam = "No exams loaded";
            examListObj.exams = exams;
            examListObj.handles.currentImage = 'none';
            examListObj.states.patientsIsLoaded = 0;
            examListObj.handles.lists.examList.String = "No exams loaded";
            updateProps(examListObj);



            %% Create Menu figure
            menu_f = uifigure;
            set(menu_f,'Units','normalized');
            menu_f.Position = [0 1 0.3 0.3];
            menu_f.DeleteFcn = @(src, event)giveAlert(examListObj, src, event);
            examListObj.handles.menu_figure = menu_f;

            gridMenuFigure = uigridlayout(examListObj.handles.menu_figure, [4, 3]);

            %% Examlist panel
            examListObj.handles.menu.examlistPanel = uipanel(gridMenuFigure, "Title", "Examlist");
            examListObj.handles.menu.examlistPanel.Layout.Row = [1 3];
            examListObj.handles.menu.examlistPanel.Layout.Column = [1 3];

            gridExamList = uigridlayout(examListObj.handles.menu.examlistPanel, [2, 3]);
            examListObj.handles.menu.listOpen = uilistbox(gridExamList);
            examListObj.handles.menu.listOpen.Items = examListObj.handles.lists.examList.String;
            examListObj.handles.menu.listOpen.Layout.Row = [1 2];
            examListObj.handles.menu.listOpen.Layout.Column = 1;
            examListObj.handles.menu.listOpen.ValueChangedFcn = @(src,event) loadExam(examListObj, src);

            %% Info panel
            examListObj.handles.menu.hPanelDemographics = uipanel(gridExamList, 'Title', 'Demographics', ...
                'FontSize', 10);
            examListObj.handles.menu.hPanelDemographics.Layout.Row = [1 2];
            examListObj.handles.menu.hPanelDemographics.Layout.Column = [3];

            examListObj.handles.menu.hPanelDemographicsGrid = uigridlayout(examListObj.handles.menu.hPanelDemographics, [4 2]);

            %% Create the components for Demographics
            nameTag = uilabel(examListObj.handles.menu.hPanelDemographicsGrid, ...
                'Text', 'Patient ID: ', ...
                'HorizontalAlignment', 'right');
            nameTag.Layout.Row = 1;
            nameTag.Layout.Column = 1;

            dateTag = uilabel('Parent', examListObj.handles.menu.hPanelDemographicsGrid, ...
                'Text', 'Study Date: ', ...
                'HorizontalAlignment', 'right');
            dateTag.Layout.Row = 2;
            dateTag.Layout.Column = 1;

            sexTag = uilabel('Parent', examListObj.handles.menu.hPanelDemographicsGrid, ...
                'Text', 'Sex: ', ...
                'HorizontalAlignment', 'right');
            sexTag.Layout.Row = 3;
            sexTag.Layout.Column = 1;

            dirTag = uilabel('Parent', examListObj.handles.menu.hPanelDemographicsGrid, ...
                'Text', 'Patient Directory: ', ...
                'HorizontalAlignment', 'right');
            dirTag.Layout.Row = 4;
            dirTag.Layout.Column = 1;

            examListObj.handles.patientIdLabel = uitextarea('Parent', examListObj.handles.menu.hPanelDemographicsGrid, ...
                'HorizontalAlignment', 'left', ...
                'Editable','off');
                 examListObj.handles.patientIdLabel.Value = examListObj.handles.lists.examList.props.patientId;
            examListObj.handles.patientIdLabel.Layout.Row = 1;
            examListObj.handles.patientIdLabel.Layout.Column = 2;


            examListObj.handles.studyLabel = uitextarea('Parent', examListObj.handles.menu.hPanelDemographicsGrid, ...
                'HorizontalAlignment', 'left', ...
                'Editable','off');
            examListObj.handles.studyLabel.Value = examListObj.handles.lists.examList.props.studyDate;
            examListObj.handles.studyLabel.Layout.Row = 2;
            examListObj.handles.studyLabel.Layout.Column = 2;

            examListObj.handles.sexLabel = uitextarea('Parent', examListObj.handles.menu.hPanelDemographicsGrid, ...
                'HorizontalAlignment', 'left', ...
                'Editable','off');
            examListObj.handles.sexLabel.Value = examListObj.handles.lists.examList.props.sex;
            examListObj.handles.sexLabel.Layout.Row = 3;
            examListObj.handles.sexLabel.Layout.Column = 2;

            examListObj.handles.patientDirLabel = uitextarea('Parent', examListObj.handles.menu.hPanelDemographicsGrid, ...
                'HorizontalAlignment', 'left', ...
                'Editable','off');
            examListObj.handles.patientDirLabel.Value = examListObj.handles.lists.examList.props.patientDir;
            examListObj.handles.patientDirLabel.Layout.Row = 4;
            examListObj.handles.patientDirLabel.Layout.Column = 2;


            %% Tabgroups
            examListObj.handles.menu.tg = uitabgroup(gridMenuFigure, 'Units','normalized', ...
                'SelectionChangedFcn', @(src,event) tabGroupChanged(examListObj, event));
             examListObj.handles.menu.tg.Layout.Row = 4;
             examListObj.handles.menu.tg.Layout.Column = [1 3];

            % Create tabs
            examListObj.handles.menu.tab1 = uitab(examListObj.handles.menu.tg, 'Title', 'Menu', 'Units','normalized');
            examListObj.handles.menu.tab2 = uitab(examListObj.handles.menu.tg, 'Title', 'View','Units','normalized');
            examListObj.handles.menu.tab3 = uitab(examListObj.handles.menu.tg, 'Title', 'Functions','Units','normalized');

             

            %% Custom UI in Menu tab
            createCustomUIMenu(examListObj, examListObj.handles.menu.tab1);

            createCustomUIView(examListObj, examListObj.handles.menu.tab2);

            createCustomUIFunctions(examListObj, examListObj.handles.menu.tab3);
            
            %% Create viewport (hidden in the begining)
            viewport_f = figure;
            set(viewport_f,'Units','normalized', 'MenuBar', 'none');
            viewport_f.Position = [0 1 0.5 0.5];
            viewport_f.DeleteFcn = @(src, event)giveAlert(examListObj, src, event);
            viewport_f.Visible = 'off';
            examListObj.handles.imtools = cell(2,3);
            examListObj.handles.viewPanels = cell(2,3);
            examListObj.handles.viewport_f = viewport_f;
            examListObj.handles.viewport_f.CloseRequestFcn = @(src, event) hideFig(examListObj, src, event);
            examListObj.handles.imageSpinners = cell(2, 3);
            
            

        end
    end
        methods (Access = private)
            function createCustomUIMenu(examListObj, parent)
                % Create a grid layout manager within the specified parent (tab)
                grid = uigridlayout(parent, [2, 3]);
                grid.Padding = 10;
                grid.RowSpacing = 10;
                grid.ColumnSpacing = 10;

                % Font settings
                fontName = 'Arial';
                fontSizeLarge = 14;
                fontSizeSmall = 12;
                fontWeight = 'bold';

                % Button background color
                buttonColor = [1 1 0.8];

                % Create the 'Open' button
                btnOpen = uibutton(grid, 'push', 'Text', 'Open',  ...
                    "ButtonPushedFcn", @(src,event) openFilesPress(examListObj, event));
                btnOpen.Layout.Row = [1 2];
                btnOpen.Layout.Column = 1;
                btnOpen.BackgroundColor = buttonColor;
                btnOpen.FontName = fontName;
                btnOpen.FontSize = fontSizeLarge;
                btnOpen.FontWeight = fontWeight;
                btnOpen.Tooltip = "Open dicom files and convert to nifti";
                
                % Create the 'Load' button
                btnLoad = uibutton(grid, 'push', 'Text', 'Load', ...
                    "ButtonPushedFcn", @(src,event) loadFilesPress(examListObj, event));
                btnLoad.Layout.Row = 1;
                btnLoad.Layout.Column = 2;
                btnLoad.BackgroundColor = buttonColor;
                btnLoad.FontName = fontName;
                btnLoad.FontSize = fontSizeSmall;
                btnLoad.FontWeight = fontWeight;

                % Create the 'Save' button
                btnSave = uibutton(grid, 'push', 'Text', 'Save');
                btnSave.Layout.Row = 2;
                btnSave.Layout.Column = 2;
                btnSave.BackgroundColor = buttonColor;
                btnSave.FontName = fontName;
                btnSave.FontSize = fontSizeSmall;
                btnSave.FontWeight = fontWeight;

                % Create the 'About' button
                btnAbout = uibutton(grid, 'push', 'Text', 'About');
                btnAbout.Layout.Row = 1;
                btnAbout.Layout.Column = 3;
                btnAbout.BackgroundColor = buttonColor;
                btnAbout.FontName = fontName;
                btnAbout.FontSize = fontSizeSmall;
                btnAbout.FontWeight = fontWeight;

                % Create the 'Ops' button
                btnOps = uibutton(grid, 'push', 'Text', 'Ops');
                btnOps.Layout.Row = 2;
                btnOps.Layout.Column = 3;
                btnOps.BackgroundColor = buttonColor;
                btnOps.FontName = fontName;
                btnOps.FontSize = fontSizeSmall;
                btnOps.FontWeight = fontWeight;
            end

            function createCustomUIView(examListObj, parent)
                % Create a grid layout manager within the specified parent (tab)
                grid = uigridlayout(parent, [2, 3]);
                grid.Padding = 10;
                grid.RowSpacing = 10;
                grid.ColumnSpacing = 10;

                % Font settings
                fontName = 'Arial';
                fontSizeLarge = 14;
                fontSizeSmall = 12;
                fontWeight = 'bold';

                % Button background color
                buttonColor = [1 1 0.8];           

                % Create the 'Images' button
                btnImages = uibutton(grid, 'push', ...
                    'Text', 'Images', ...
                    'BackgroundColor', buttonColor, ...
                    'FontName', fontName, ...
                    'FontSize', fontSizeSmall, ...
                    'FontWeight', fontWeight);
                btnImages.Layout.Row = 1;
                btnImages.Layout.Column = 1;
                btnImages.ButtonPushedFcn = @(src,event) openViewPort(examListObj, event);

                % The Row button
                listRow = uispinner(grid, ...
                    'Limits', [1 2], ...
                    'ValueChangedFcn', @(src,event) imageGridCreator(examListObj));
                listRow.Layout.Row = 1;
                listRow.Layout.Column = 3;

                % The Row button
                listColumn = uispinner(grid, ...
                    'Limits', [1 3], ...
                    'ValueChangedFcn', @(src,event) imageGridCreator(examListObj));
                listColumn.Layout.Row = 2;
                listColumn.Layout.Column = 3;
                
                label1 = uilabel(grid, ...
                    "Text", "Rows");
                label1.Layout.Row = 1;
                label1.Layout.Column = [2];
                label1.HorizontalAlignment = 'right';

                label2 = uilabel(grid, ...
                    "Text", "Column");
                label2.Layout.Row = 2;
                label2.Layout.Column = [2];
                label2.HorizontalAlignment = 'right';

                %Save the ui
                examListObj.handles.spinners.listRow = listRow;
                examListObj.handles.spinners.listColumn = listColumn;
          
            end
            function createCustomUIFunctions(examListObj, parent)
                % Create a grid layout manager within the specified parent (tab)
                grid = uigridlayout(parent, [2, 3]);
                grid.Padding = 10;
                grid.RowSpacing = 10;
                grid.ColumnSpacing = 10;

                % Font settings
                fontName = 'Arial';
                fontSizeLarge = 14;
                fontSizeSmall = 12;
                fontWeight = 'bold';

                % Button background color
                buttonColor = [1 1 0.8];

                % Create the 'patient selector' dropdown
                listOpen = uidropdown(grid); 
                listOpen.Items = examListObj.handles.lists.examList.String;
                listOpen.Layout.Row = 1;
                listOpen.Layout.Column = 1;
                listOpen.BackgroundColor = buttonColor;
                listOpen.FontName = fontName;
                listOpen.FontSize = fontSizeLarge;
                listOpen.FontWeight = fontWeight;
                listOpen.ValueChangedFcn = @(src,event) loadExam(examListObj, event);
                
                %propListener = addlistener(examListObj.handles.lists.examList.String, @(src,evnt) disp('Color changed'));



            end
            function hideFig(examListObj, src, event)
                src.Visible = 'off';
            end

            function giveAlert(examListObj, src, event)
                disp(['Closing']);
                close(examListObj.handles.viewport_f);
            end

            function openFilesPress(examListObj, event)
                dataDir = uigetdir();
                examListObj.handles.dataDir = dataDir;

                %Create path to only list .mat files
                path = [dataDir '/*.mat'];
                if dataDir
                
                    %Read options
                    options = readOptions;

                    %Creates dicom collection
                    collection = CollectionCreator(path);

                    %Find the files
                    fileNumberInList = fileListCreator(options, collection);

                    %Convert the volumes to nifti and save the locations in a cell
                    volCell = getVolume(options, collection, fileNumberInList);

                    %Create examObj
                    examObj = examComp(options, collection, fileNumberInList, volCell);

                    %Save examObj

                    %Save the examObj path somewhere in examlistobj

                    %Update view
                    createCustomUIView(examListObj, examListObj.handles.menu.tab2);

                end
            end
            function loadFilesPress(examListObj, event)
                dataDir = uigetdir();
                examListObj.handles.dataDir = dataDir;

                %Create path to only list .mat files
                path = [dataDir '/*.mat'];
                if dataDir
                    %Get the filelist
                    fileList = dir(path);

                    examListObj.exams = fileList;

                    examListObj.states.patientsIsLoaded = 1;
                    %% Update Filelist
                    fileList = examListObj.exams(:,1);
                    fileList = struct2cell(fileList(:));
                    fileList = fileList';
                    fileList = fileList(:,1);

                    examListObj.handles.lists.examList.String = fileList;

                    %Set the first exam to the current loaded exam
                    objIn = load([dataDir filesep fileList{1}]);
                    examListObj.loadedExam = examComp(objIn.options, objIn.collection, objIn.volCell, objIn.props, ...
                        objIn.infarctionMasks, objIn.stats);
                    examListObj.handles.volCell = examListObj.loadedExam.getVolCells;
                    examListObj.handles.masks = examListObj.loadedExam.getInfarctionMasks;

                    %Update viewPort
                    imageGridCreator(examListObj);

                    %Update UIView
                    createCustomUIView(examListObj, examListObj.handles.menu.tab2);

                    %Update list
                    examListObj.handles.menu.listOpen.Items = examListObj.handles.lists.examList.String;
                    updateProps(examListObj)
                end
            end
            function tabGroupChanged(examListObj, event)
                switch event.NewValue.Title
                    case 'Menu'
                    case 'View'
                        if examListObj.states.patientsIsLoaded
                        else
                            examListObj.handles.menu.tg.SelectedTab = event.OldValue;
                        end
                    case 'Functions'
                end
            end
            function openViewPort(examListObj, event)
                examListObj.handles.viewport_f.Visible = 'on';
                
            end
            function imageGridCreator(examListObj)
                % Get the number of columns and rows. 
                nRows = examListObj.handles.spinners.listRow.Value;
                nCols = examListObj.handles.spinners.listColumn.Value;
       
                % Calculate panel size
                panelWidth = 1/nCols;
                panelHeight = 1/nRows;

                %Loop through panels and populate them with GUI containing
                %imtool3D and image selector
                for rowIter = 1:nRows
                    for columnIter = 1:nCols
                        % Create the main panel
                        examListObj.handles.viewPanels{rowIter, columnIter} = uipanel(examListObj.handles.viewport_f, ...
                            "Position", [(columnIter-1)/nCols, (nRows-rowIter)/nRows, ...
                            panelWidth, panelHeight])

                        %Create the viewport panel
                        % Create an instance of imtool3D within the panel
                        examListObj.handles.imtools{rowIter, columnIter} = imtool3D(0, [0 0 1 .98], ...
                            examListObj.handles.viewPanels{rowIter, columnIter}, [], ...
                            examListObj.handles.imtools{rowIter, columnIter});

                        % Create a spinner for image selection within the same panel
                        examListObj.handles.imageSpinners{rowIter, columnIter} = uicontrol(examListObj.handles.viewPanels{rowIter, columnIter}, ...
                            'Style', 'popupmenu', ...
                            'String', examListObj.handles.volCell(:,3), ... % Example image list
                            'Units','normalized', ...
                            'Position', [0.35, 0.9, 0.3, 0.1], ...
                            'Callback', @(src, event) imageSelectorCallback(examListObj, event, src, rowIter, columnIter));  
                    end
                end



            end
            function imageSelectorCallback(examListObj, event, src, rowIter, columnIter)
                %Get the tool
                tool = examListObj.handles.imtools{rowIter, columnIter};

                %Get the selected image
                selectedImage = src.String{src.Value};
                
                %Get the index
                i = find(contains(examListObj.handles.volCell(:,3)', selectedImage));

                %Read the image and mask
                image = niftiread(examListObj.handles.volCell{i,4});
                mask = niftiread(examListObj.handles.volCell{i,6});

                %Set the image and mask for the tool
                tool.setImage(image, [], [], [], tool, mask)

                %save the tool
                examListObj.handles.imtools{rowIter, columnIter} = tool;
            end
            function loadExam(examListObj, src)
                f = waitbar(0, 'Reading patient ...');

                fileList = examListObj.exams;

                matchingEntries = fileList(strcmp({fileList.name}, src.Value));

                objIn = load([matchingEntries.folder, filesep, matchingEntries.name]);
                examListObj.loadedExam = examComp(objIn.options, objIn.collection, objIn.volCell, objIn.props, ...
                        objIn.infarctionMasks, objIn.stats);

                waitbar(1/3, f, 'Reading volumes');

                examListObj.handles.volCell = examListObj.loadedExam.getVolCells;
                examListObj.handles.masks = examListObj.loadedExam.getInfarctionMasks;
                waitbar(1/2, f, 'Loaded volumes');
                close(f);

                %Update props
                updateProps(examListObj)

            end
            function updateProps(examListObj)
                if strcmp(examListObj.loadedExam, "No exams loaded")
                    props.patientId = "No exams loaded";
                    props.studyDate = "No exams loaded";
                    props.sex = "No exams loaded";
                    props.patientDir = "No exams loaded";
                    
                else
                    props = examListObj.loadedExam.getProps;
                    
                    %Update the demogrpahics
                    examListObj.handles.patientDirLabel.Value = props.patientDir;
                    examListObj.handles.sexLabel.Value = props.sex;
                    examListObj.handles.studyLabel.Value = string(props.studyDate);
                    examListObj.handles.patientIdLabel.Value = props.patientId;
                end
                examListObj.handles.lists.examList.props = props;
               
            end
        end
      
end