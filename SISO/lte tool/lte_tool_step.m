function [varargout] = lte_tool_step(subframe, dataIn, rmc, snrdB, chanMdl, cec)
%LTE_TOOL_STEP Process one subframe through LTE transceiver chain
%   This function simulates one subframe, including transmitter, channel,
%   and receiver processing.
%
%   Syntax for BER testing:
%   [dataOut, crcError] = lte_tool_step(...)
%
%   Syntax for visualization:
%   [dataOut, crcError, txWaveform, rxWaveform, rxData, channelSpec] = lte_tool_step(...)

%% Set subframe number in RMC structure for LTE Toolbox functions
rmc.NSubframe = subframe;

%% Transmitter
% Get PDSCH indices and info to determine codeword length
[pdschIndices, pdschInfo] = ltePDSCHIndices(rmc, rmc.PDSCH, rmc.PDSCH.PRBSet);
outlen = pdschInfo.G;  % Codeword length

% DL-SCH encoding
codedBits = lteDLSCH(rmc, rmc.PDSCH, outlen, dataIn);

% PDSCH symbol generation
pdschSymbols = ltePDSCH(rmc, rmc.PDSCH, codedBits);

% Resource grid mapping and OFDM modulation
grid = lte_tool_resource_grid(rmc, subframe, pdschSymbols);
txWaveform = lteOFDMModulate(rmc, grid);

%% Channel
info = lteOFDMInfo(rmc);
[rxWaveform, chanInfo, fadingChannel] = lte_tool_apply_channel(txWaveform, snrdB, chanMdl, info.SamplingRate);

%% Receiver
% OFDM demodulation
rxGrid = lteOFDMDemodulate(rmc, rxWaveform);

% Channel estimation using provided cec parameters
[estChannelGrid, noiseEst] = lteDLChannelEstimate(rmc, cec, rxGrid);

% PDSCH decoding (reuse pdschIndices from transmitter)
rxPdschSymbols = lteExtractResources(pdschIndices, rxGrid);
pdschChEst = lteExtractResources(pdschIndices, estChannelGrid);

rxEncodedBits = ltePDSCHDecode(rmc, rmc.PDSCH, rxPdschSymbols, pdschChEst, noiseEst);

% DL-SCH decoding
[dataOut, crcError] = lteDLSCHDecode(rmc, rmc.PDSCH, numel(dataIn), rxEncodedBits);

% Extract from cell array and convert to double to match dataIn type
% (lteDLSCHDecode returns cell array of int8 when input is cell array)
if iscell(dataOut)
    dataOut = double(dataOut{1});
else
    dataOut = double(dataOut);
end

%% Output Arguments
% The output depends on the number of arguments requested by the caller (nargout)
varargout{1} = dataOut;
varargout{2} = crcError;

if nargout > 2
    % Extended output for visualization purposes
    rxData.txSymbols = pdschSymbols;
    rxData.rxSymbols = rxPdschSymbols; % Pre-equalization (after channel)

    % Compute equalized symbols using MMSE equalization for visualization
    % H is the channel estimate, y is received symbol, equalized = y ./ H
    eqSymbols = rxPdschSymbols .* conj(pdschChEst) ./ (abs(pdschChEst).^2 + noiseEst);
    rxData.eqSymbols = eqSymbols; % Post-equalization

    rxData.rxGrid = rxGrid;
    rxData.estChannelGrid = estChannelGrid;
    
    channelSpec.samplingRate = info.SamplingRate;

    % Extract path gains from lteFadingChannel output
    if isfield(chanInfo, 'PathGains')
        channelSpec.pathGains = chanInfo.PathGains;
    else
        channelSpec.pathGains = [];
    end

    % Store channel configuration for reference
    channelSpec.channelConfig = fadingChannel;

    varargout{3} = txWaveform;
    varargout{4} = rxWaveform;
    varargout{5} = rxData;
    varargout{6} = channelSpec;
end

end