function r2VolPath = perf_convertToR2star(options, volPath, savePath)

%Read vol
vol = niftiread(volPath);

r2vol = -1 .* vol; 

niftiwrite(int16(r2vol), savePath, niftiinfo(volPath));

r2VolPath = savePath;
end

