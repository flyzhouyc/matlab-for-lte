%% Visualizing channel models under different mobility and multipath delay profiles
maxNumErrs=1e6;
maxNumBits=1e6;
EbNo=9;
CodingRate=1/3;          % Choose any coding rate between 1/3 to 0.99
Mode=3;                       % Choose either of 1 for QPSK or 2 for QAM16 or 3 for QAM64
prmLTE.Mode=Mode;
prmLTE.Rate=CodingRate;
prmLTE.maxIter=6;
prmLTE.chanSRate=3.654e6;
chanSRate=prmLTE.chanSRate;
%% Low-mobility flat fading channel  
prmLTE.PathDelays=0*(1/chanSRate);
prmLTE.PathGains= 0;
prmLTE.DopplerShift= 0;
clear functions
chap5_ex01(EbNo, maxNumErrs, maxNumBits, prmLTE);
%% High-mobility flat fading channel
prmLTE.PathDelays=0*(1/chanSRate);
prmLTE.PathGains= 0;
prmLTE.DopplerShift= 70;
clear functions
chap5_ex01(EbNo, maxNumErrs, maxNumBits, prmLTE);
%% Low-mobility frequency-selective fading channel
prmLTE.PathDelays= [0 10 20 30 100]*(1/chanSRate);
prmLTE.PathGains= [0 -3 -6 -8 -172];
prmLTE.DopplerShift= 0;
clear functions
chap5_ex01(EbNo, maxNumErrs, maxNumBits, prmLTE);
%% High-mobility frequency-selective fading channel
prmLTE.PathDelays= [0 10 20 30 100]*(1/chanSRate);
prmLTE.PathGains= [0 -3 -6 -8 -172];
prmLTE.DopplerShift= 70;
clear functions
chap5_ex01(EbNo, maxNumErrs, maxNumBits, prmLTE);