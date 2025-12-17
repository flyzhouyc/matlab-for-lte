function lte_tool_visualize(rmc, txWaveform, rxWaveform, rxData, channelSpec, subframe)
%LTE_TOOL_VISUALIZE Create visualizations for LTE signals
%   Generates spectrum plots, channel response plots, and constellation
%   diagrams for the LTE SISO simulation.

%% Figure Setup
if ~ispc
    figPosition = [100 100 1200 800];
else
    figPosition = get(0, 'Screensize'); % Maximize figure on Windows
end

figure('Name', ['LTE SISO Visualization - Subframe ' num2str(subframe)], ...
       'NumberTitle', 'off', 'Position', figPosition);

%% Transmitted Signal Spectrum
subplot(2,3,1);
[Pxx_tx, F_tx] = pwelch(txWaveform, [], [], [], channelSpec.samplingRate, 'centered');
plot(F_tx/1e6, 10*log10(Pxx_tx));
title('Transmitted Signal Spectrum');
xlabel('Frequency (MHz)');
ylabel('Power (dB/Hz)');
grid on;

%% Received Signal Spectrum
subplot(2,3,4);
[Pxx_rx, F_rx] = pwelch(rxWaveform, [], [], [], channelSpec.samplingRate, 'centered');
plot(F_rx/1e6, 10*log10(Pxx_rx));
title('Received Signal Spectrum');
xlabel('Frequency (MHz)');
ylabel('Power (dB/Hz)');
grid on;

%% Channel Frequency Response
subplot(2,3,2);
if isfield(rxData, 'estChannelGrid')
    % Average the channel estimate over the OFDM symbols in the subframe
    H_est = mean(rxData.estChannelGrid, 2);
    plot(abs(H_est));
    title('Estimated Channel Frequency Response');
    xlabel('Subcarrier Index');
    ylabel('Magnitude');
    grid on;
    axis tight;
else
    title('Channel Frequency Response');
    text(0.5, 0.5, 'Not Available', 'HorizontalAlignment', 'center');
    axis off;
end

%% Channel Impulse Response
subplot(2,3,5);
if isfield(channelSpec, 'pathGains') && ~isempty(channelSpec.pathGains)
    % The impulse response is represented by the path gains in the fading channel model
    % PathGains is typically [NumSamples x NumPaths] for SISO
    % Handle various dimensionalities for robustness
    pg = channelSpec.pathGains;
    if ismatrix(pg) && size(pg, 1) > 1
        % 2-D: take first time instant (first row)
        pathMag = abs(pg(1, :));
    else
        % 1-D or single row: use as-is
        pathMag = abs(pg(:)).';
    end
    stem(pathMag);
    title('Estimated Channel Impulse Response');
    xlabel('Path Index');
    ylabel('Magnitude');
    grid on;
    axis tight;
else
    title('Channel Impulse Response');
    text(0.5, 0.5, 'Not Available', 'HorizontalAlignment', 'center');
    axis off;
end

%% Transmitted Constellation
subplot(2,3,3);
if isfield(rxData, 'txSymbols') && ~isempty(rxData.txSymbols)
    plot(rxData.txSymbols, 'o');
    title(['Transmitted Constellation (' rmc.PDSCH.Modulation ')']);
    xlabel('In-Phase');
    ylabel('Quadrature');
    grid on;
    axis square;
    % Set axis limits based on modulation (calculate M - constellation order)
    switch rmc.PDSCH.Modulation
        case 'QPSK'
            M = 4;
        case '16QAM'
            M = 16;
        case '64QAM'
            M = 64;
        case '256QAM'
            M = 256;
        otherwise
            error('Unsupported modulation: %s', rmc.PDSCH.Modulation);
    end
    lim = sqrt(2/3 * (M-1));
    axis([-lim lim -lim lim]);
else
    title('Transmitted Constellation');
    text(0.5, 0.5, 'Not Available', 'HorizontalAlignment', 'center');
    axis off;
end

%% Received Constellation (After Equalization)
subplot(2,3,6);
if isfield(rxData, 'eqSymbols') && ~isempty(rxData.eqSymbols)
    plot(rxData.eqSymbols, '.');
    title('Received Constellation (Post-Equalization)');
    xlabel('In-Phase');
    ylabel('Quadrature');
    grid on;
    axis square;
else
    title('Received Constellation');
    text(0.5, 0.5, 'Not Available', 'HorizontalAlignment', 'center');
    axis off;
end

%drawnow; % Force the plots to update

end
