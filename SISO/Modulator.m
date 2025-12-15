function y = Modulator(u, Mode)
% Modulator compatible with new MATLAB versions (no comm.* objects)
% Mode = 1: QPSK
% Mode = 2: 16QAM
% Mode = 3: 64QAM

u = u(:);  % ensure column vector

switch Mode
    case 1  % ------------------- QPSK ---------------------
        % Mapping: [0 2 3 1] (same as original)
        map = [0 2 3 1];

        % Standard QPSK constellation with pi/4 offset
        const = exp(1j * (pi/4 + (0:3) * pi/2));

        % Extract bits
        b = reshape(u, 2, []).';      % Each row = 1 symbol
        ints = bi2de(b, 'left-msb');  % Convert to integer 0–3

        % Apply custom mapping
        symIdx = map(ints + 1);

        y = const(symIdx + 1).';

    case 2  % ------------------- 16QAM ---------------------
        map = [11 10 14 15 9 8 12 13 1 0 4 5 3 2 6 7];

        b = reshape(u, 4, []).';
        ints = bi2de(b, 'left-msb');
        mapped = map(ints + 1);

        const = qammod(0:15, 16, 'UnitAveragePower', true, ...
                       'PlotConstellation', false);

        y = const(mapped + 1).';

    case 3  % ------------------- 64QAM ---------------------
        map = [47 46 42 43 59 58 62 63 45 44 40 41 ...
               57 56 60 61 37 36 32 33 49 48 52 53 ...
               39 38 34 35 51 50 54 55 7 6 2 3 19 18 ...
               22 23 5 4 0 1 17 16 20 21 13 12 8 9 ...
               25 24 28 29 15 14 10 11 27 26 30 31];

        b = reshape(u, 6, []).';
        ints = bi2de(b, 'left-msb');
        mapped = map(ints + 1);

        const = qammod(0:63, 64, 'UnitAveragePower', true, ...
                       'PlotConstellation', false);

        y = const(mapped + 1).';

    otherwise
        error('Invalid Modulation Mode. Use 1=QPSK, 2=16QAM, 3=64QAM');
end
end
