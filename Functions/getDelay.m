

% getDelay - Compute the optimal delay for time-series embedding
%
% Syntax:
%   tau = getDelay(sig)
%
% Description:
%   Determines the delay parameter `tau` by finding the first local
%   minimum in the auto mutual information (AMI) of the time-series `sig`.
%   AMI is calculated using Marwan's CRP toolbox (`mi()`), with the
%   number of bins set by Sturges' rule. The maximum lag for AMI is set to
%   N/4, where N is the length of `sig`.
%
% Input:
%   sig - 1D time-series signal.
%
% Output:
%   tau - Optimal delay parameter.
%
% Example:
%   tau = getDelay(randn(1, 1000));

function tau = getDelay(sig)
    
    % Signal dependent params
    N = length(sig);
    maxlag = floor(N/4);
    % Nbin = round((max(sig)-min(sig))/(2*iqr(sig)*N^(-1/3))); %Freedman-Diaconis' rule 
    Nbin = ceil(1+log2(N)); % number of bins for AMI, Sturges' rule
    % Nbin = Nbin*2;
    ami1 = mi(sig,'nogui',Nbin,maxlag,'silent');
    % only take one element of each square matrix output from mi
    ami1 = squeeze(ami1(1,1,:))';

    % figure; plot(-ami1); shg % Plot the ami to make sure it's smooth
    FILT = 3;
    [lmval,indd]=lmin(ami1,FILT); % find local minima
    tau = indd(1);

end