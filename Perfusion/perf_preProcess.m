function savePath = perf_preProcess(opts, volPath, savePath)


%Read vol
vol = double(niftiread(volPath));

%Preallocate
outVol = zeros(size(vol));

f = waitbar(0, 'Preprocessing data in Timedimension ...');

for sliceIter = 1:size(vol, 3)
    for xIter = 1:size(vol, 1)
        for yIter = 1:size(vol, 2)

            %Take a sample vector
            v = squeeze(vol(xIter, yIter, sliceIter, :));

            %Run the detrendning
            if opts.detrendSpikes
                v = medfilt1(v, 3);
            end
            if opts.sgolayFilt
                v = sgolayfilt(v, 3, 5, []);
            end

            %Store the vector
            outVol(xIter, yIter, sliceIter, :) = v;

        end
    end

    waitbar(sliceIter/size(vol, 3), f);

end

close(f);

if opts.spatialSmoothing

    f = waitbar(0, 'Preprocessing data in Spatial dimension ...');

    for sliceIter = 1:size(outVol, 3)
        upSampleImg = imresize(outVol(:, :, sliceIter,:), opts.SpatialFilterUpSamplFactor);
        spcSmoothedImg = imgaussfilt(upSampleImg, opts.SpatialFilterSigma, 'FilterSize', opts.SpatialFilterSize);
        outVol(:, :, sliceIter, :) = imresize(spcSmoothedImg, (1 / opts.SpatialFilterUpSamplFactor));

        waitbar(sliceIter/size(outVol, 3));

    end

    close(f);
end

niftiwrite(int16(outVol), savePath, niftiinfo(volPath));


end
