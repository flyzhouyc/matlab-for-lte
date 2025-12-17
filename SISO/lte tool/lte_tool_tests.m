classdef lte_tool_tests < matlab.unittest.TestCase
%LTE_TOOL_TESTS Unit tests for the LTE Toolbox simulation tool.
%   This test class verifies the functionality of the key components of the
%   LTE SISO simulation tool, including configuration, parameter
%   validation, and single-subframe processing.
%
%   To run these tests, execute 'runtests('lte_tool_tests.m')' in the
%   MATLAB command window.

    properties
        % Store common valid parameters loaded from the config file
        enb_valid
        pdsch_valid
        cRate_valid
        cec_valid
    end
    
    methods (TestMethodSetup)
        % Set up common fixtures for each test method to use
        function setup(testCase)
            % Load default parameters from the file into the test case
            lte_tool_params; 
            testCase.enb_valid = enb;
            testCase.pdsch_valid = pdsch;
            testCase.cRate_valid = cRate;
            testCase.cec_valid = cec;
        end
    end
    
    methods (Test)
        % Test case for valid configuration processing
        function testValidConfiguration(testCase)
            [rmc, trBlkSize] = lte_tool_configure(testCase.enb_valid, testCase.pdsch_valid, testCase.cRate_valid);
            
            % Verify that the outputs are not empty and have correct types
            testCase.verifyClass(rmc, 'struct', 'The RMC output should be a struct.');
            testCase.verifyClass(trBlkSize, 'double', 'The transport block size should be a double.');
            testCase.verifyNotEmpty(rmc.PDSCH.TrBlkSizes, 'Transport block size should be set in the RMC.');
            testCase.verifyEqual(rmc.PDSCH.TrBlkSizes, trBlkSize, 'TrBlkSizes in RMC should match the calculated size.');
        end
        
        % Test the parameter validation for an invalid NDLRB
        function testInvalidNDLRB(testCase)
            invalid_enb = testCase.enb_valid;
            invalid_enb.NDLRB = 99; % An invalid NDLRB value
            
            % Verify that the configure function throws the correct error ID
            testCase.verifyError(@() lte_tool_configure(invalid_enb, testCase.pdsch_valid, testCase.cRate_valid), ...
                'lte_tool:invalidNDLRB', 'The function should throw an error for an invalid NDLRB.');
        end
        
        % Test the main step function for a single subframe execution
        function testStepFunction(testCase)
            % Reset channel state for independent/repeatable test results
            clear lte_tool_apply_channel;
            [rmc, trBlkSize] = lte_tool_configure(testCase.enb_valid, testCase.pdsch_valid, testCase.cRate_valid);
            dataIn = randi([0 1], trBlkSize, 1);
            snr = 20; % High SNR

            [dataOut, crcError] = lte_tool_step(0, dataIn, rmc, snr, 'EPA 5Hz', testCase.cec_valid);
            
            % Verify output size and type
            testCase.verifySize(dataOut, [trBlkSize, 1], 'The output data should have the same size as the input.');
            testCase.verifyMember(crcError, [0, 1], 'The CRC error must be either 0 or 1.');
        end
        
        % Smoke test to ensure the main demo runs without producing an error
        function testDemoSmoke(testCase)
            % This test simply confirms that the lte_tool_demo script runs to
            % completion without throwing an error. The 'evalc' suppresses
            % command window output.
            % Reset channel state for independent/repeatable test results
            clear lte_tool_apply_channel;
            % Set test mode flag to prevent clear/clc from interfering
            LTE_TOOL_TEST_MODE = true; %#ok<NASGU>
            testCase.verifyWarningFree(@() evalc('lte_tool_demo'), ...
                'The main demo script should run without errors or warnings.');
        end
    end
    
end
