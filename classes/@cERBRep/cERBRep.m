% function [c] = cERBRep(varargin)
%
% DESCRIPTION:
% ============ 
% ERB cochleagram representation
%
% INPUTS:
% =======
% (1) cSound object (mandatory)
% (2) configuration structure (optional)
%
% OUTPUTS:
% ========
% (1) ERBRep object
%
% See also cFFTRep
% 
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [c] = cERBRep(varargin)

% === Handle input args
switch nargin
	case 1
		oSnd = varargin{1};
		% use default settings
		config_s.w_Method		= 'fft';% other option: w_Method = 'gammatone';
		config_s.f_HopSize_sec	= 256/44100;
		config_s.i_HopSize		= round(config_s.f_HopSize_sec * FGetSampRate(oSnd));
		config_s.f_Exp			= 1/4;
	case 2
		% use input config structure
		oSnd				= varargin{1};
		config_s 			= varargin{2};
		% check completness of config.
		if ~isfield( config_s, 'w_Method'),		config_s.w_Method = 'fft';			end
		if ~isfield( config_s, 'i_HopSize'),	config_s.f_HopSize_sec = 256/44100;	end
		config_s.i_HopSize	= round(config_s.f_HopSize_sec * FGetSampRate(oSnd));
		if ~isfield( config_s, 'f_Exp'),		config_s.f_Exp = 1/4;				end
	otherwise
		disp('Error');
		exit(1);
end;

f_Sig_v = FGetSignal(oSnd);

% Calc. ERB power spec.
[d.f_DistrPts_m, d.f_SupY_v, d.f_SupX_v] = ERBspect(f_Sig_v', ...                             % input sig.
	FGetSampRate(oSnd), ...						% samp. rate
	config_s.w_Method, ...						% method ('fft' or 'gammatone')
	config_s.f_Exp, ...							% exponent (1/4 default)
	config_s.i_HopSize/FGetSampRate(oSnd));		% hopsize in seconds


d.i_SizeY	= length(d.f_SupY_v);
d.i_SizeX	= length(d.f_SupX_v);
d.f_SupY_v	= (d.f_SupY_v ./ FGetSampRate(oSnd))'; % normalized support

% 2x distribution elements
d.f_SampRateX = FGetSampRate(oSnd) ./ config_s.i_HopSize;
d.f_SampRateY = d.i_SizeY ./ FGetSampRate(oSnd);

% ERB specific
c.i_HopSize	= config_s.i_HopSize;
c.w_Method	= config_s.w_Method;



% Build class
c = class(c, 'cERBRep', c2xDistr(d)); % inherit generic distribution properties
