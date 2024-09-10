

function signalsData = generateCosineClusters(nClusters, nSignals, duration, fs, varargin)

    % Default ranges for properties
    globalRanges = struct(...
        'amp', [0.5, 5], ...
        'freq', [1, 30], ...
        'phase', [0, 360], ...
        'noise', [0.05, 0.6] ...
    );

    % Parse optional input arguments (custom ranges)
    if nargin > 4
        customRanges = varargin{1};
    else
        customRanges = [];
    end

    % Initialize the cell array to store signals and their parameters
    signalsData = cell(nSignals, 6);  % Columns: Signal, Label, Amp, Freq, Phase, Noise

    % Calculate signals per cluster
    nSignalsPerCluster = floor(nSignals / nClusters);
    remainingSignals = mod(nSignals, nClusters);

    % Generate signals and corresponding properties
    signalCounter = 1; % Counter to track the overall signal index
    for clusterIdx = 1:nClusters
        if ~isempty(customRanges) && clusterIdx <= length(customRanges)
            clusterRanges = customRanges{clusterIdx};  % Use custom ranges if provided
        else
            clusterRanges = generateClusterRanges(globalRanges, clusterIdx, nClusters);  % Generate ranges automatically
        end

        % Generate signals for this cluster
        nSignalsForThisCluster = nSignalsPerCluster + (remainingSignals > 0);
        remainingSignals = remainingSignals - 1;

        for signalIdx = 1:nSignalsForThisCluster
            amp = randRange(clusterRanges.amp);
            freq = randRange(clusterRanges.freq);
            phase = randRange(clusterRanges.phase);
            noise = randRange(clusterRanges.noise);

            % Generate the signal
            [~, y] = cosineWave(amp, freq, fs, duration, phase, noise);

            % Store the signal, label, and parameters in the cell array
            signalsData{signalCounter, 1} = y;           % Signal
            signalsData{signalCounter, 2} = clusterIdx;  % Label
            signalsData{signalCounter, 3} = amp;         % Amplitude
            signalsData{signalCounter, 4} = freq;        % Frequency
            signalsData{signalCounter, 5} = phase;       % Phase
            signalsData{signalCounter, 6} = noise;       % Noise

            % Increment the signal counter
            signalCounter = signalCounter + 1;
        end
    end
end


function val = randRange(range)
    rng('shuffle');
    val = range(1) + (range(2) - range(1)) * rand;
end

function clusterRanges = generateClusterRanges(globalRanges, clusterIdx, nClusters)
    % Split global ranges into clusters
    step = 1 / nClusters;
    clusterRanges.amp = globalRanges.amp(1) + step * (clusterIdx-1) * (globalRanges.amp(2) - globalRanges.amp(1)) + step * rand(1,2) * (globalRanges.amp(2) - globalRanges.amp(1));
    clusterRanges.freq = globalRanges.freq(1) + step * (clusterIdx-1) * (globalRanges.freq(2) - globalRanges.freq(1)) + step * rand(1,2) * (globalRanges.freq(2) - globalRanges.freq(1));
    clusterRanges.phase = globalRanges.phase(1) + step * (clusterIdx-1) * (globalRanges.phase(2) - globalRanges.phase(1)) + step * rand(1,2) * (globalRanges.phase(2) - globalRanges.phase(1));
    clusterRanges.noise = globalRanges.noise(1) + step * (clusterIdx-1) * (globalRanges.noise(2) - globalRanges.noise(1)) + step * rand(1,2) * (globalRanges.noise(2) - globalRanges.noise(1));
end
