function [ttpVol, cbfVol, cbvVol, maxRelEnhanceVol, noiseVol, ce] = perf_calcTNTTP(examObj)

  %Set variables and get everything for the function
  [ttpLow, ttpHigh] = examObj.getTimeCutoffs;
  
  truncLow = ttpLow -10;
  truncHigh = ttpHigh +10;
  
  [vol, info] = examObj.getVol('R2Star');

  %Truncate the volume for calculation
  vol = vol(:, :, :, truncLow:truncHigh-1);

  [M, I] = max(vol, [], 4);

  ttpVol = I;
  cbfVol = M;


  %Save location
  patientDir = examObj.props.patientDir;

  %Get options
  options = examObj.getOptions;

  %The savelocation name
  saveLocationName = [patientDir filesep options.pre_process_settings.processed_saveName filesep ...
      'TTP.nii'];

  %Get the volCell
  volCell = examObj.getVolCells;

  ind = find(contains(volCell(:,3)', 'Forsk_Ax_Perf'));
  
  info = niftiinfo(volCell{ind,4});

  %WriteVol
  niftiwrite(int16(I), saveLocationName, info)

  %% Update VolCell
  i = find(contains(volCell(:,3)', 'TTP'));
    
  %Make sure there is not a TTP already, if there is, overwrite. 
  if isempty(i)
      volCell{end+1, 3} = 'TTP';
      volCell{end, 4} = saveLocationName;
      volCell{end, 5} = volCell{ind,5};
      volCell{end, 6} = volCell{ind,6};
  else
      volCell{i, 3} = 'TTP';
      volCell{i, 4} = saveLocationName;
      volCell{i, 5} = volCell{ind,5};
      volCell{i, 6} = volCell{ind,6};
  end

  examObj.setVolCell(volCell);

end