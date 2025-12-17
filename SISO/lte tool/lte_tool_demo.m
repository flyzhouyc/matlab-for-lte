% LTE Toolbox Demo Script
% Demonstrates LTE downlink SISO transmission using LTE Toolbox
%
% This script simulates LTE Mode 1: Single Tx and Rx antenna
% It generates and processes downlink waveforms with visualization
%
% Usage: Run from MATLAB command window:
% >> lte_tool_demo

%% Clear workspace and command window (skip if running in test context)
if ~(exist('LTE_TOOL_TEST_MODE', 'var') && LTE_TOOL_TEST_MODE)
    close all;
    clear;
    clc;
end

%% Load configuration
lte_tool_params;

%% Disable visuals in test mode for faster/stable CI runs
if exist('LTE_TOOL_TEST_MODE', 'var') && LTE_TOOL_TEST_MODE
    visualsOn = 0;
end

%% Setup RMC and PDSCH configurations
[rmc, trBlkSize] = lte_tool_configure(enb, pdsch, cRate);

%% Configure channel estimation parameters
cec.PilotAverage = 'TestEVM';
cec.FreqWindow = 9;
cec.TimeWindow = 9;

%% Display simulation info
fprintf('LTE SISO Simulation\n');
fprintf('===================\n');
fprintf('Channel Bandwidth: %.2f MHz\n', rmc.NDLRB * 0.18);
fprintf('Modulation: %s\n', rmc.PDSCH.Modulation);
fprintf('Target Code Rate: %.2f\n', cRate);
fprintf('Transport Block Size: %d bits\n', trBlkSize);
fprintf('Channel Model: %s\n', chanMdl);
fprintf('SNR: %d dB\n', snrdB);
fprintf('\n');

%% Initialize error rate calculator
hPBer = comm.ErrorRate;
Measures = zeros(3,1); % [BER, Errors, TotalBits]

%% Main simulation loop
subframe = 0;

fprintf('Starting simulation (up to 10 subframes for visualization)...\n');

while ((Measures(2) < maxNumErrs) && (Measures(3) < maxNumBits) && subframe < 10)
    % Generate random transport block data
    dataIn = randi([0 1], trBlkSize, 1);

    % Process subframe through the transceiver, requesting full output
    [dataOut, ~, txWaveform, rxWaveform, rxData, channelSpec] = ...
        lte_tool_step(subframe, dataIn, rmc, snrdB, chanMdl, cec);

    % Calculate bit errors for this subframe
    Measures = step(hPBer, dataIn, dataOut);

    % Visualize constellations and spectrum
    if visualsOn
        % Calculate per-subframe errors for better feedback
        subframeErrors = sum(dataIn(:) ~= dataOut(:));
        fprintf('  Subframe %d: Errors = %d, Cumulative BER = %.4e\n', ...
            subframe, subframeErrors, Measures(1));
        lte_tool_visualize(rmc, txWaveform, rxWaveform, rxData, channelSpec, subframe);
    end

    % Update subframe number
    subframe = subframe + 1;
end

%% Display final results
fprintf('\nSimulation Complete\n');
fprintf('===================\n');
fprintf('Bit Error Rate: %.4e\n', Measures(1));
fprintf('Number of Errors: %d\n', Measures(2));
fprintf('Total Bits: %d\n', Measures(3));
fprintf('SNR: %d dB\n', snrdB);
