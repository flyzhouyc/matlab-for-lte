function y = AWGNChannel(u, noiseVar )
%% Initialization
%% Initialization2
%% Initialization3
%% Initialization4
persistent AWGN
if isempty(AWGN)
    AWGN             = comm.AWGNChannel('NoiseMethod', 'Variance', ...
    'VarianceSource', 'Input port');
end
y = step(AWGN, u, noiseVar);
end

