function perf_setTTPCutoff(varargin)

  examObj = varargin{1};

  switch nargin
  %Option to input manual TTP values
  case 1
    %Get new values
    low = input('Input low cutoff for TTP \n');
    high = input('Input high cutoff for TTP \n');

    %Save the values in props
    examObj.props.bolusCutOff.ttpLow = low;
    examObj.props.bolusCutOff.ttpHigh = high;

  %Here TTP values are given as arguments
  case 3
    %perfObj = varargin{1};
    %Get new values
    low = varargin{2};
    high = varargin{3};

    examObj.props.bolusCutOff.ttpLow = low;
    examObj.props.bolusCutOff.ttpHigh = high;
    
  end
end 