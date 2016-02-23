function [config_s] = cSound_FGetDefaultConfig()
% FGETDEFAULTCONFIG
%
% Returns a structure containing a default configuration for object
% instantiation.
config_s=struct();
config_s.f_Fs            = GGetDefaultSampRate();
config_s.f_HopSize_sec   = 0.0029;
config_s.f_WinSize_sec   = 0.0232;   
config_s.w_Format        = 'double';
config_s.i_Channels      = 2;
config_s.i_Samples       = config_s.f_Fs;
%config_s.i_SampleRange_v = [0,config_s.f_Fs]; % Default 1 second of audio
