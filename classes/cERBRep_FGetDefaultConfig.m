function [config_s] = cERBRep_FGetDefaultConfig()
% FGETDEFAULTCONFIG
%
% Returns a structure containing a default configuration for object
% instantiation.
config_s=struct();
config_s.f_sr_hz        = GGetDefaultSampRate();
config_s.w_Method		= 'fft';% other option: w_Method = 'gammatone';
config_s.f_HopSize_sec	= 256/config_s.f_sr_hz;
config_s.i_HopSize		= round(config_s.f_HopSize_sec * config_s.f_sr_hz);
config_s.f_Exp			= 1/4;
