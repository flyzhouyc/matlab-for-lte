function y = DemodulatorSoft(u, Mode, NoiseVar)
% DemodulatorSoft - Soft LLR demodulator for QPSK/16QAM/64QAM
% Compatible with latest MATLAB (no comm.* objects)
% Mode: 1=QPSK, 2=16QAM, 3=64QAM

u = u(:);   % column vector
sigma2 = NoiseVar;

switch Mode
    case 1  % ====================== QPSK ======================
        map = [0 2 3 1];
        const = exp(1j * (pi/4 + (0:3) * pi/2));
        M = 4;
        bitsPerSym = 2;

    case 2  % ====================== 16QAM ======================
        map = [11 10 14 15 9 8 12 13 1 0 4 5 3 2 6 7];
        const = qammod(0:15, 16, 'UnitAveragePower', true);
        M = 16;
        bitsPerSym = 4;

    case 3  % ====================== 64QAM ======================
        map = [47 46 42 43 59 58 62 63 45 44 40 41 ...
               57 56 60 61 37 36 32 33 49 48 52 53 ...
               39 38 34 35 51 50 54 55 7 6 2 3 19 18 ...
               22 23 5 4 0 1 17 16 20 21 13 12 8 9 ...
               25 24 28 29 15 14 10 11 27 26 30 31];
        const = qammod(0:63, 64, 'UnitAveragePower', true);
        M = 64;
        bitsPerSym = 6;

    otherwise
        error('Invalid Mode. Use {1,2,3}');
end

% ===== 使用与调制器相同的 mapping =====
[~, invMap] = sort(map);       % invert mapping
const = const(invMap);         % permute constellation to match mapping

% ===== 预计算每个符号对应的比特 =====
bitLabels = de2bi(0:M-1, bitsPerSym, 'left-msb');

% ===== LLR 初始化 =====
N = length(u);
y = zeros(N, bitsPerSym);

% ===== Soft LLR 计算 =====
for k = 1:bitsPerSym
    % 符号集合 S0, S1
    idx0 = bitLabels(:,k) == 0;
    idx1 = bitLabels(:,k) == 1;

    s0 = const(idx0).';    % column vectors
    s1 = const(idx1).';

    for n = 1:N
        r = u(n);

        % dist0 = exp(-|r-s|^2 / sigma^2)
        d0 = exp( -abs(r - s0).^2 / sigma2 );
        d1 = exp( -abs(r - s1).^2 / sigma2 );

        y(n,k) = log(sum(d0) + eps) - log(sum(d1) + eps);
    end
end

% return column vector of bits
y = reshape(y.', [], 1);
end
