

% Function to simulate (noisy) cosine wave
% Emma Ning, Apr.14, 2024
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% amp: amplitude
% f: frequency of generated cosine wave
% fs: sampling frequency
% duration: duration of the simulated signal, in seconds
% phi: phase offset, input in degrees
% noiseAmp: noise level amplitude

function [t y] = cosineWave(amp, f, fs, duration, phi, noiseAmp)

    % % Set seed to ensure reproducibility
    % rng(2);

    % Set seed based on the current time
    rng('shuffle');

    t = 0:1/fs:duration;
    phi = deg2rad(phi);
    % % Adjust noiseAmp according to sampling frequency, OPTIONAL
    % noiseAmp = noiseAmp.*sqrt(fs);
    noise = noiseAmp.* randn(size(t));
    y = amp.*cos(2*pi*f.*t+phi)+noise;

end
