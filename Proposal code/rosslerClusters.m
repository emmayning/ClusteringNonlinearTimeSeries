




clear all; close all hidden; clc

run('config.m');

%% Generate multiple rossler signalsData with no noise

a2 = 0.2; 
b2 = 0.3; 
c2 = 10; 
noise_strength2 = 0;
noise_strength2 = repmat(noise_strength2,[1 3]); 

% Define different initial conditions for the new set
initial_conditions2 = [ 
    2, 2, 2; 
    2, 2.5, 2;
    1.9, 2, 2.1;
    1.5, 2.7, 1.8;

    2, 2, 2; 
    2, 2.5, 2;
    1.9, 2, 2.1;
    1.5, 2.7, 1.8];  % Different initial conditions

tspan = linspace(0, 1000, 1000);  % Time span, linspace to ensure ode45 uses same time steps

% Initialize a cell array to store results
num_conditions2 = size(initial_conditions2, 1);
signalsData = cell(num_conditions2, 6);  % 6 columns: x(t), a, b, c, initial conditions, coupling strength

for i = 1:num_conditions2
    init_cond = initial_conditions2(i, :);

    % Solve the system using ode45
    [t, y] = ode45(@(t, y) rossler_system(t, y, a2, b2, c2, noise_strength2), tspan, init_cond);

    % Append the results to the existing cell array
    signalsData{i, 1} = y(:, 1);         % x(t) trajectory
    signalsData{i, 2} = a2;              % Parameter a
    signalsData{i, 3} = b2;              % Parameter b
    signalsData{i, 4} = c2;              % Parameter c
    signalsData{i, 5} = init_cond;       % Initial conditions
    signalsData{i, 6} = noise_strength2; % Noise strength
end


% Add an ID column at the beginning and shift existing columns back
signalsData = [[num2cell((1:size(signalsData,1))')] signalsData];

% Min-max normalization
normSignals = cellfun(@(x) minmaxNorm(x), signalsData(:,2), 'UniformOutput', false);
signalsData(:,8) = normSignals; % 2,3,4,5,6,7,8: signal, a, b, c, initial conditions, coupling strength

% Initialize columns 9 and 10 in the signalsData cell array for storing delay
numSignals = size(signalsData, 1);

% Loop through each normalized signal in column 9 and compute delay and dimension
for i = 1:numSignals
    normalizedSignal = signalsData{i, 8};
    delay = getDelay(normalizedSignal);
    dimension = getDim(normalizedSignal, delay);
    
    % Store the results in columns 9 and 10
    signalsData{i, 9} = delay;
    signalsData{i, 10} = dimension;
end

% Compute the overall average delay and dimension
tau1 = round(mean(cell2mat(signalsData(:, 9))));
m1 = round(mean(cell2mat(signalsData(:, 10))));

% Get RQA matrices
for k = 1:numSignals
    currSig = signalsData{k,8};
    currMat = crp(currSig, m1, tau1, 'distance', 'nonormalize', 'nogui');
    signalsData{k,11} = currMat;
end

% Compute pairwise similarity scores
signalPairs = nchoosek(1:size(signalsData,1),2);
confusionMatrix = nan(numSignals, numSignals);

K = [0.01 0.03];
window = ones(8);

for p = 1:size(signalPairs, 1)
    i = signalPairs(p, 1);
    j = signalPairs(p, 2);
    matrix1 = signalsData{i, 11};
    matrix2 = signalsData{j, 11};
    [similarityScore,~] = ssim_index(matrix1, matrix2, K, window, 100);
    confusionMatrix(i, j) = similarityScore;
end

% Reflect the upper triangle to the lower triangle for plotting
confusionMatrixP = confusionMatrix;
for i = 1:numSignals-1
    for j = i+1:numSignals
        confusionMatrixP(j, i) = confusionMatrixP(i, j);
    end
end

% confusionMatrixP(1:numSignals+1:end) = 1;


%%

signalsBi = signalsData;
% Do the same, but save each RQA not as unthresholded, but with radius
for k = 1:numSignals
    currSig = signalsData{k,8};
    currMat = crp(currSig, m1, tau1, 0.1,'maxnorm', 'nonormalize', 'nogui');
    signalsBi{k,11} = currMat;
end

% Compute pairwise similarity scores
signalPairs = nchoosek(1:size(signalsData,1),2);
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
    sig1 = signalsData{i, 8};
    sig2 = signalsData{j, 8};
    y = jrqa(sig1,sig2,m1,tau1,0.1,'maxnorm','nonormalize','nogui');
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
title('JRP RR r=0.1');
xlabel('Signal Index');
ylabel('Signal Index');
axis square;
set(gca, 'XTick', 1:numSignals, 'YTick', 1:numSignals);

% Adjust layout to remove excessive white space
set(gcf, 'Position', [100, 100, 1200, 400]);  % Set the figure size
% Set a global title
sgtitle('Comparison of Confusion Matrices');



