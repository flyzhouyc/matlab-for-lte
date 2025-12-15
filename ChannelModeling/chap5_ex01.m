function [ber, bits] = chap5_ex01(EbNo, maxNumErrs, maxNumBits, prmLTE)
%#codegen
%% Constants
FRM=2432-24;                                          
Kplus=FRM+24;
Indices = lteIntrlvrIndices(Kplus);
ModulationMode=prmLTE.Mode;
k=2*ModulationMode;
maxIter=prmLTE.maxIter;
CodingRate=prmLTE.Rate;
snr = EbNo + 10*log10(k) + 10*log10(CodingRate);
noiseVar = 10.^(-snr/10);
%% Processsing loop modeling transmitter, channel model and receiver
numErrs = 0; numBits = 0; nS=0; 
while ((numErrs < maxNumErrs) && (numBits < maxNumBits))
    % Transmitter
    u  =  randi([0 1], FRM,1);                                                           % Randomly generated input bits
    data= CbCRCGenerator(u);                                                        % Transport block CRC code
    [t1, Kplus, ~] = TbChannelCoding(data, prmLTE);
    t2 = Scrambler(t1, nS);                                                                % Scrambler
    t3 = Modulator(t2, ModulationMode);                                       % Modulator
    % Channel & Add AWG noise
    rxFade =  ChanModelFading(t3, prmLTE);                               % Fading channel - assume unit sigPower
    c0  = AWGNChannel2(rxFade, noiseVar );                                   % AWGN channel
    zVisualize_ex01(prmLTE, t3, c0);                                              % Visualize channel response and constellation
    % Receiver
    r0 = DemodulatorSoft(c0, ModulationMode, noiseVar);            % Demodulator
    r1 = DescramblerSoft(r0, nS);                                                     % Descrambler
    r2 = RateDematcher(r1, Kplus);                                                  % Rate Matcher
    r3  = TurboDecoder(-r2, Indices,  maxIter);                                % Turbo Deocder
    y   =  CbCRCDetector(r3);                                                           % Code block CRC dtector
    % Measurements
    numErrs     = numErrs + sum(y~=u);                                           % Update number of bit errors
    numBits     = numBits + FRM;                                                     % Update number of bits processed
    % Manage slot number with each subframe processed
    nS = nS + 2; nS = mod(nS, 20);
end
%% Clean up & collect results
ber = numErrs/numBits;                                          % Compute Bit Error Rate (BER)
bits = numBits;