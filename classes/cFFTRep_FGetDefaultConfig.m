function [config_s] = cFFTRep_FGetDefaultConfig()
% FGETDEFAULTCONFIG
%
% Returns a structure containing a default configuration for object
% instantiation.
config_s=struct();
config_s.f_sr_hz = GGetDefaultSampRate();
config_s.f_WinSize_sec	= 0.0232;
config_s.f_HopSize_sec	= 0.0058;
config_s.i_WinSize	= round(config_s.f_WinSize_sec*config_s.f_sr_hz);
config_s.i_HopSize  = config_s.f_HopSize_sec*config_s.f_sr_hz;
config_s.i_FFTSize = 2^nextpow2(config_s.i_WinSize);
config_s.w_WinType = 'hamming';
config_s.f_Win_v = eval(sprintf('%s(%d)', config_s.w_WinType, config_s.i_WinSize));
config_s.f_SampRateX= config_s.f_sr_hz ./ config_s.i_HopSize;
config_s.f_BinSize	= config_s.f_sr_hz ./ config_s.i_FFTSize;
config_s.f_SampRateY= config_s.i_FFTSize ./ config_s.f_sr_hz;
config_s.w_DistType	= 'pow';
