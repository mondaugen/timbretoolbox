function [config_s] = cTEERep_FGetDefaultConfig()
% FGETDEFAULTCONFIG
%
% Returns a structure containing a default configuration for object
% instantiation.
config_s=struct();
config_s.xcorr_nb_coeff = 12;
