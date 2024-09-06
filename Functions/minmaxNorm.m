

% Min max normalization of a vector/matrix
function out = minmaxNorm(dat)

    if isvector(dat)
        % if data is a vector
        out = (dat-min(dat))./(max(dat)-min(dat));
    else
        % if data is a matrix
        [minDat, maxDat] = bounds(dat, 'all');
        out = (dat - minDat) ./ (maxDat - minDat);
    end

end