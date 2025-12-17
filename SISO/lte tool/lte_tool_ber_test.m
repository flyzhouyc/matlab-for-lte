% LTE Toolbox BER Test Script
% Measures BER performance of LTE SISO downlink vs SNR
%
% This script runs BER tests across a range of SNR values to generate
% performance curves for the LTE downlink SISO mode
%
% Usage: Run from MATLAB command window:
% >> lte_tool_ber_test

%% Clear workspace
close all;
clear;
clc;

%% Load configuration
lte_tool_params;

%% Setup RMC and PDSCH configurations
[rmc, trBlkSize] = lte_tool_configure(enb, pdsch, cRate);

%% Configure channel estimation parameters
cec.PilotAverage = 'TestEVM';
cec.FreqWindow = 9;
cec.TimeWindow = 9;

%% Display test configuration
fprintf('LTE SISO BER Performance Test\n');
fprintf('=============================\n');
fprintf('Channel Bandwidth: %.2f MHz\n', rmc.NDLRB * 0.18);
fprintf('Modulation: %s\n', rmc.PDSCH.Modulation);
fprintf('Target Code Rate: %.2f\n', cRate);
fprintf('Transport Block Size: %d bits\n', trBlkSize);
fprintf('Channel Model: %s\n', chanMdl);
fprintf('SNR Range: %d to %d dB\n', snrValues(1), snrValues(end));
fprintf('\n');

%% Preallocate result arrays
ber = zeros(size(snrValues));
crc_failures = zeros(size(snrValues));
subframes_processed = zeros(size(snrValues));

%% Main loop through SNR values
for idx = 1:length(snrValues)
    snr = snrValues(idx);
    fprintf('Testing SNR = %d dB...\n', snr);

    % Initialize error rate calculator for this SNR point
    hPBer = comm.ErrorRate;
    Measures = zeros(3,1); % [BER, Errors, TotalBits]

    % Reset counters for each SNR iteration
    nCrcFailures = 0;
    subframe = 0;

    % Simulation loop continues until max errors or bits are reached
    while ((Measures(2) < maxNumErrs) && (Measures(3) < maxNumBits))
        % Generate random transport block data
        dataIn = randi([0 1], trBlkSize, 1);

        % Process one subframe using the unified step function
        [dataOut, crcError] = lte_tool_step(subframe, dataIn, rmc, snr, chanMdl, cec);

        % Update BER statistics
        Measures = step(hPBer, dataIn, dataOut);

        % Count CRC failures
        nCrcFailures = nCrcFailures + crcError;

        % Increment subframe counter
        subframe = subframe + 1;
    end

    % Get final BER for this SNR (use the accumulated Measures)
    ber(idx) = Measures(1);
    crc_failures(idx) = nCrcFailures;
    subframes_processed(idx) = subframe;

    fprintf('  BER = %.4e (%d errors / %d bits)\n', ber(idx), Measures(2), Measures(3));
    fprintf('  CRC failures = %d\n', nCrcFailures);
    fprintf('  Subframes processed = %d\n\n', subframe);
end

%% Plot BER curve
figure('Name', 'LTE SISO BER Performance', 'Position', [100 100 800 600]);
semilogy(snrValues, ber, '-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
grid on;
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title(sprintf('LTE SISO Performance: %s, %s', ...
    rmc.PDSCH.Modulation, chanMdl), 'FontSize', 14);

% Add theoretical AWGN curve for QPSK for reference
if strcmp(rmc.PDSCH.Modulation, 'QPSK')
    ber_theory = berawgn(snrValues, 'psk', 2, 'nondiff');
    semilogy(snrValues, ber_theory, '--r', 'LineWidth', 1.5);
    legend('Simulated BER', 'Theoretical QPSK (AWGN)');
else
    legend('Simulated BER');
end

%% Plot CRC failure rate
if any(crc_failures)
    figure('Name', 'CRC Failure Rate', 'Position', [200 200 800 500]);
    semilogy(snrValues, crc_failures ./ subframes_processed, '-s', ...
        'LineWidth', 2, 'MarkerSize', 8);
    grid on;
    xlabel('SNR (dB)', 'FontSize', 12);
    ylabel('CRC Failure Rate', 'FontSize', 12);
    title('Transport Block CRC Failure Rate', 'FontSize', 14);
end

%% Display summary results in a table
fprintf('\nBER Test Summary\n');
fprintf('================\n');
results = table(snrValues', ber', crc_failures', subframes_processed', ...
    'VariableNames', {'SNR_dB', 'BER', 'CRC_Failures', 'Subframes'});
disp(results);
