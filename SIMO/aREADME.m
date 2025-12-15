% zREADME.m 
% Instructions regarding how to run MATLAB experiments in this directory
% (UnderstandingLTEwithMATLAB_Chapter5\SIMO)
%
% This folder contains two main MATLAB scripts (testbenches) that showcase how
% to execute the SIMO transceiver model and look at various signals and how to assess 
% the qualitative and quantitative performance of the Downlink SIMO Mode 1 system 
% as presented in chapter 5 of the "Understanding LTE withMATLAB"
% The main testbenches are called commlteSIMO.m & commlteSIMO_test_timing_ber.m
% 
% How to run the 1st demo:
% type commlteSIMO at the MATLAB command prompt
% You will see that the script first sets relevant experiment parameters found in MATLAB script
% commlteSIMO_params.m. It then initializes three LTE transceiver parameter structures 
% by calling the function commlteSIMO_initialize.m. Then it sets up a while loop to call 
% the main transceiver function commlteSIMO_step.m.
% Each iteration of the while loop processes one subframe of data.
% You will see that after processing each subframe, the script calls the zVisualize.m function to 
% examine the magnitude spectra of the tranmitted and received signals (before and after equalization)
% as well as the modulation constellation of the transmitted and the received signals.
% Exploration:
% By changing the parametrers found in commlteSIMO_params.m you can experiment with various conditions.
% For example by chaging parameters such as maxNumErrs and maxNumBits,  
% you get longer or shorter experiment time. By changing the parameter modType 
% you can see the effect of using  different modulation schemes and by
% chaging link SNR, the parameter snrdB, you can se the efect of AWGN noise
% on the overall performance. 
% 
% How to run the 2nd demo:
% type commlteSIMO_test_timing_ber at the MATLAB command prompt
% You will see that the script first sets relevant experiment parameters found in MATLAB script
% commlteSIMO_params.m. It then initializes three LTE transceiver parameter structures 
% by calling the function commlteSIMO_initialize.m. Then it iterates
% through a set of link SNR values and computes a quantitative performance
% measure of BER as a function of SNR. For better results, the experiments
% have to be long enough, which usually means parametrers in file
% commlteSIMO_params.m, known as maxNumErrs and maxNumBits, need to be larger than
% 1e4 and 1e7 respectively. 
% Exploration:
% By changing the parameter modType you can see the effect of using  different modulation schemes.
% By changing the parameters Eqmode and chEstOn , you can experiment with different types of equalizer used 
% and chanel estimation methods applied, respectively, etc.