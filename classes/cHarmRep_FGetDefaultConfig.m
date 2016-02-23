function [config_s] = cHarmRep_FGetDefaultConfig()
% FGETDEFAULTCONFIG
%
% Returns a structure containing a default configuration for object
% instantiation.
config_s=struct();
config_s.f_sr_hz         = GGetDefaultSampRate();
config_s.threshold_harmo = 0.3;
config_s.nb_harmo        = 20;
config_s.f_WinSize_sec   = 0.1; % === analysis window length
config_s.f_HopSize_sec   = config_s.f_WinSize_sec/4;
config_s.i_WinSize       = round(config_s.f_WinSize_sec*config_s.f_sr_hz);
config_s.i_HopSize       = round(config_s.f_HopSize_sec*config_s.f_sr_hz);
config_s.i_FFTSize       = 4*2^nextpow2(config_s.i_WinSize);
config_s.w_WinType       = 'blackman';
config_s.f_Win_v         = eval(sprintf('%s(%d)',config_s.w_WinType,config_s.i_WinSize));
