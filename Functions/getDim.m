

% Get embedding dimension given delay parameter
% getDim(sig, tau)
function embedDim = getDim(sig, tau)

    % Pre-set parameters
    maxDim = 7; 
    threshFNN = 0.1; % 10% false neighbors

    percFNN = fnn(sig,maxDim,tau,'silent');
    % Get the change in % false neighbors to identify whether the number
    % start going up
    changeFNN = diff(percFNN);
    
    % Initialize a logical array for the combined condition
    combined_condition = false(size(percFNN));
    
    % First condition: differences > 0
    % Note: Adjust index to match length of percFNN
    combined_condition(2:end) = (changeFNN > 0);

    % Second condition: percFNN < threshFNN
    combined_condition = combined_condition+(percFNN < threshFNN);

    idx = find(combined_condition); % find non-zero elements

    if ~isempty(idx)
        embedDim = idx(1);
    else
        % Handle the case where no index meets the conditions
        embedDim = NaN; % or set it to a default value or handle as needed
    end
    
    % idx = find(percFNN < threshFNN);
    % embedDim = idx(1);

end