% zREADME.m 
% Instructions regarding how to run MATLAB experiments in this directory
% (UnderstandingLTEwithMATLAB_Chapter5\ChannelModeling)
%
% This folder contains a main MATLAB script (testbench) that showcases how
% to visualize channel models under different mobility and multipath
% delay profiles as presented in chapter 5 of the "Understanding LTE with
% MATLAB"
% The main testbench is called  chap5_ex01_testbench.m
% 
% How to run the demo:
% type chap5_ex01_testbench at the MATLAB command prompt
% You wil see that the script first initializes various common parameters needed
% to call the function  chap5_ex01.m. 
% Then in 4 sections we set 3 distinct parameters for each cases of 
% 1. Low-mobility flat fading channel
% 2. High-mobility flat fading channel
% 3. Low-mobility frequency-selective fading channel
% 4. High-mobility frequency-selective fading channel
% and then in each case we call the the function  chap5_ex01.m.
% You will see in each case the magnitude spectra of the tranmitted and
% received signals (before and after channel modeling)
% as well as the modulation constellation of the received signal (after channel modeling).
%
% Exploration:
% By changing the first set of common parametrers, such as maxNumErrs and maxNumBits,  
% you can experiment with longer or shorter experiment time. By changing the parameter Mode 
% you can see the effect of using  different modulation schemes and by
% chaging link SNR, the parameter EbNo, you can se the efect of AWGN noise
% on the overall received constellation. 