function varargout = writeVolTodisk(examObj, volName, vol, info)

%Save location
patientDir = examObj.props.patientDir;

%Get options
options = examObj.getOptions;

%The savelocation name
saveLocationName = [patientDir filesep options.pre_process_settings.processed_saveName filesep ...
            volName];

%WriteVol
niftiwrite(vol, saveLocationName, info)


%If user request output
if nargout > 0
    varargout{1} = saveLocationName;
end
end

