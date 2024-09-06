

clear all; close all hidden; clc

run('config.m');


%% Generate clusters of cosine waves

% Define cluster properties
nClusters = 4;
nSignals = 12;
duration = 5; % seconds
fs = 100;

% Specify custom ranges
customRanges = {
    struct('amp', [1, 1], 'freq', [0.2, 0.5], 'phase', [0, 360], 'noise', [0.3, 0.3]), 
    struct('amp', [1, 1], 'freq', [2, 5], 'phase', [0, 360], 'noise', [0.3, 0.3]), 
    struct('amp', [1, 1], 'freq', [10, 13], 'phase', [0, 360], 'noise', [0.3, 0.3]), 
    struct('amp', [1, 1], 'freq', [20, 23], 'phase', [0, 360], 'noise', [0.3, 0.3])
};


% Generate the signals and their corresponding properties
signals = generateCosineClusters(nClusters, nSignals, duration, fs, customRanges);

% signals{15,1} = rand(size(signals{1,1}));
% signals{16,1} = rand(size(signals{1,1}));
% signals{17,1} = rand(size(signals{1,1}));

% Add an ID column at the beginning and shift existing columns back
signals = [[num2cell((1:nSignals)')] signals]; % Create a column with IDs and prepend it to signals
% signals = [[num2cell((1:nSignals+3)')] signals];

% Min-max normalization
normSignals = cellfun(@(x) minmaxNorm(x), signals(:,2), 'UniformOutput', false);
signals(:,8) = normSignals; % 2,3,4,5,6,7: signal, label, amplitude, frequency, phase, noise

% Initialize columns 9 and 10 in the signals cell array for storing delay and dimension
numSignals = size(signals, 1);  % Number of signals

% Loop through each normalized signal in column 8 and compute delay and dimension
for i = 1:numSignals
    % Get the normalized signal from column 8
    normalizedSignal = signals{i, 8};
    
    % Estimate RQA parameters
    delay = getDelay(normalizedSignal);  % Get delay
    dimension = getDim(normalizedSignal, delay);  % Get embedding dimension
    
    % Store the results in columns 9 and 10
    signals{i, 9} = delay;
    signals{i, 10} = dimension;
end

% Compute the overall average delay and dimension
tau1 = round(mean(cell2mat(signals(:, 9))));
m1 = round(mean(cell2mat(signals(:, 10))));

% Get RQA matrices
for k = 1:numSignals
    % Get current signal
    currSig = signals{k,8};
    
    % Compute the unthresholded distance matrix
    currMat = crp(currSig, m1, tau1, 'distance', 'nonormalize', 'nogui');
    
    % Store the matrix in column 11
    signals{k,11} = currMat;
end

% Compute pairwise similarity scores
signalPairs = nchoosek(1:size(signals,1),2);

% Initialize the confusion matrix
confusionMatrix = nan(numSignals, numSignals);

% Loop through each pair of signals in the upper triangle using signalPairs
K = [0.01 0.03]; % ssim params
window = ones(8); % TWEAK window size
% L = max(cellfun(@(x) max(x,[],'all'), signals(:,11)),[],'all'); % find max of distance across all signals
for p = 1:size(signalPairs, 1)
    i = signalPairs(p, 1);
    j = signalPairs(p, 2);

    % Retrieve the matrices for the current pair
    matrix1 = signals{i, 11};
    matrix2 = signals{j, 11};

    % Compute the SSIM similarity score
    [similarityScore,~] = ssim_index(matrix1, matrix2, K, window, 100); 

    % Store the similarity score in the upper triangle
    confusionMatrix(i, j) = similarityScore;
end

% Reflect the upper triangle to the lower triangle for plotting
confusionMatrixP = confusionMatrix;
for i = 1:numSignals-1
    for j = i+1:numSignals
        confusionMatrixP(j, i) = confusionMatrixP(i, j);
    end
end

% % Set the diagonal elements of confusionMatrixP to 1
% confusionMatrixP(1:numSignals+1:end) = 1; % skip every numSignals+1



%% Do the same, but save each RQA not as unthresholded, but with radius

signalsBi = signals;
for k = 1:numSignals
    currSig = signals{k,8};
    currMat = crp(currSig, m1, tau1, 0.1,'maxnorm', 'nonormalize', 'nogui');
    signalsBi{k,11} = currMat;
end

% Compute pairwise similarity scores
signalPairs = nchoosek(1:size(signals,1),2);
confusionMatrixBi = nan(numSignals, numSignals);

K = [0.01 0.03];
window = ones(8);

for p = 1:size(signalPairs, 1)
    i = signalPairs(p, 1);
    j = signalPairs(p, 2);
    matrix1 = signalsBi{i, 11};
    matrix2 = signalsBi{j, 11};
    [similarityScore,~] = ssim_index(matrix1, matrix2, K, window, 100);
    confusionMatrixBi(i, j) = similarityScore;
end

% Reflect the upper triangle to the lower triangle for plotting
confusionMatrixBi2 = confusionMatrixBi;
for i = 1:numSignals-1
    for j = i+1:numSignals
        confusionMatrixBi2(j, i) = confusionMatrixBi2(i, j);
    end
end

% confusionMatrixBi2(1:numSignals+1:end) = 1;


%%
% Do that using RR
% Compute pairwise similarity scores
confusionMatrixJRP = nan(numSignals, numSignals);

for p = 1:size(signalPairs, 1)
    i = signalPairs(p, 1);
    j = signalPairs(p, 2);
    sig1 = signals{i, 8};
    sig2 = signals{j, 8};
    y = jrqa(sig1,sig2,m1,tau1,0.2,'maxnorm','nonormalize','nogui');
    confusionMatrixJRP(i, j) = y(1);
end

% Reflect the upper triangle to the lower triangle for plotting
confusionMatrixJRP2 = confusionMatrixJRP;
for i = 1:numSignals-1
    for j = i+1:numSignals
        confusionMatrixJRP2(j, i) = confusionMatrixJRP2(i, j);
    end
end

% confusionMatrixJRP2(1:numSignals+1:end) = 1;


% Create a figure with white background
figure('Color', 'white');

% First subplot
subplot(1, 3, 1);
imagesc(minmaxNorm(confusionMatrixP));
colorbar;
title('SSIM Un-thresholded');
xlabel('Signal Index');
ylabel('Signal Index');
axis square;
set(gca, 'XTick', 1:numSignals, 'YTick', 1:numSignals);

% Second subplot
subplot(1, 3, 2);
imagesc(minmaxNorm(confusionMatrixBi2));
colorbar;
title('SSIM Thresholded r=0.1');
xlabel('Signal Index');
ylabel('Signal Index');
axis square;
set(gca, 'XTick', 1:numSignals, 'YTick', 1:numSignals);

% Third subplot
subplot(1, 3, 3);
imagesc(minmaxNorm(confusionMatrixJRP2));
colorbar;
title('JRP RR r=0.2');
xlabel('Signal Index');
ylabel('Signal Index');
axis square;
set(gca, 'XTick', 1:numSignals, 'YTick', 1:numSignals);

% Adjust layout to remove excessive white space
set(gcf, 'Position', [100, 100, 1200, 400]);  % Set the figure size
% Set a global title
sgtitle('Comparison of Confusion Matrices');






