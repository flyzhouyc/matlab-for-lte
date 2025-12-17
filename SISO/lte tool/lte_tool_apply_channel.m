function [rxWaveform, chanInfo, fadingChannel] = lte_tool_apply_channel(txWaveform, snrdB, chanMdl, samplingRate)
%LTE_TOOL_APPLY_CHANNEL Applies fading and AWGN to a waveform.
%   [RXWAVEFORM, CHANINFO, FADINGCHANNEL] = LTE_TOOL_APPLY_CHANNEL(TXWAVEFORM,
%   SNRDB, CHANMDL, SAMPLINGRATE) simulates channel impairments by applying
%   a fading channel model and adding Additive White Gaussian Noise (AWGN).
%
%   TXWAVEFORM is the input time-domain waveform.
%   SNRDB is the desired signal-to-noise ratio in dB.
%   CHANMDL is a string defining the channel model (e.g., 'EPA 5Hz').
%   SAMPLINGRATE is the waveform sampling rate.
%
%   RXWAVEFORM is the output waveform after channel impairments.
%   CHANINFO is a structure containing information from the fading channel.
%   FADINGCHANNEL is a handle to the channel configuration structure.

% Parse channel model string (e.g., 'EPA 5Hz')
% Handle various formats: 'EPA 5Hz', 'EPA5Hz', 'EPA', etc.
parts = strsplit(strtrim(chanMdl));
if numel(parts) >= 2
    delayProfile = parts{1};
    dopplerFreq = str2double(regexprep(parts{2}, '[Hh][Zz]', ''));
elseif numel(parts) == 1
    % Try to parse combined format like 'EPA5Hz' or just 'EPA'
    tokens = regexp(parts{1}, '([A-Za-z]+)\s*(\d*)', 'tokens');
    if ~isempty(tokens) && ~isempty(tokens{1})
        delayProfile = tokens{1}{1};
        if numel(tokens{1}) >= 2 && ~isempty(tokens{1}{2})
            dopplerFreq = str2double(tokens{1}{2});
        else
            dopplerFreq = 5; % Default Doppler frequency
        end
    else
        delayProfile = 'EPA';
        dopplerFreq = 5;
    end
else
    % Fallback defaults
    delayProfile = 'EPA';
    dopplerFreq = 5;
end

% Validate Doppler frequency
if isnan(dopplerFreq) || dopplerFreq < 0
    dopplerFreq = 5; % Default to 5 Hz
end

% Configure fading channel structure for lteFadingChannel
chanCfg.DelayProfile = delayProfile;
chanCfg.DopplerFreq = dopplerFreq;
chanCfg.MIMOCorrelation = 'Low';
chanCfg.Seed = 73; % for reproducibility
chanCfg.NRxAnts = 1;
chanCfg.SamplingRate = samplingRate;

% Use persistent state to track elapsed time for continuous fading
% and AWGN seed for reproducibility
persistent elapsedTime lastDelayProfile lastDopplerFreq lastSamplingRate awgnSeedCounter;
if isempty(elapsedTime)
    elapsedTime = 0;
    awgnSeedCounter = 0;
    lastDelayProfile = delayProfile;
    lastDopplerFreq = dopplerFreq;
    lastSamplingRate = samplingRate;
elseif ~strcmp(lastDelayProfile, delayProfile) || ...
       lastDopplerFreq ~= dopplerFreq || ...
       lastSamplingRate ~= samplingRate
    % Configuration changed, reset state
    elapsedTime = 0;
    awgnSeedCounter = 0;
    lastDelayProfile = delayProfile;
    lastDopplerFreq = dopplerFreq;
    lastSamplingRate = samplingRate;
end

% Set InitTime to elapsed time for continuous fading across subframes
chanCfg.InitTime = elapsedTime;

% Apply fading channel using LTE Toolbox function
[rxFaded, chanInfo] = lteFadingChannel(chanCfg, txWaveform);
fadingChannel = chanCfg; % Return channel configuration

% Advance elapsed time for next call (waveform duration)
% Use size(,1) instead of numel() in case waveform is multi-column
elapsedTime = elapsedTime + size(txWaveform, 1) / samplingRate;

% Apply AWGN with controlled RNG for reproducibility
% Save current RNG state, seed with counter-based value, then restore
rngState = rng;
rng(74 + awgnSeedCounter); % Base seed 74, offset by call count
rxWaveform = awgn(rxFaded, snrdB, 'measured');
rng(rngState); % Restore RNG state to avoid side effects
awgnSeedCounter = awgnSeedCounter + 1;

end
