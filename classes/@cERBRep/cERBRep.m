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
% The configuration structure contains the following fields. If any of the
% fields are not specified, they are calculated or given default values.
% w_Method      -- The method that is used for doing the transformation. It can
%                  be one of 'fft' or 'gammatone'.
% f_HopSize_sec -- The distance between the centres of two analysis windows in
%                  seconds. The default is the number of seconds that would give
%                  a distance of 256 samples at 44100 Hz sample rate.
% i_HopSize     -- The distance between the centres of two analysis windows in
%                  samples. 
% f_Exp         -- Exponent to obtain loudness from power. See
%                  private/ERBspect.m to see more details. Default is 1/4.
%
% OUTPUTS:
% ========
% (1) ERBRep object
% i_IncToNext   - If the descriptors are being calculated in chunks, how many
%                 samples the read head should be advanced to have the chunk
%                 start where this analysis left off. For example if the chunk
%                 size is 16 samples, the hop size is 2 samples and the window
%                 size is 5 samples, the highest index attained where the window
%                 still fits within the chunk is 11. So the next hop we want to
%                 compute is at index 13 but before we can do that, we must
%                 read in more samples. Before reading in more samples,
%                 increment the read head by 12 to place the beginning of the
%                 chunk where the next hop should land.
%
% See also cFFTRep
% 
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [c] = cERBRep(varargin)

% === Handle input args
if nargin == 1
		oSnd = varargin{1};
		% use default settings
        config_s=cERBRep_FGetDefaultConfig();
		config_s.f_HopSize_sec	= FGetSampRate(oSnd);
		config_s.i_HopSize		= round(config_s.f_HopSize_sec * FGetSampRate(oSnd));
end
if nargin > 1
		% use input config structure
		oSnd				= varargin{1};
		config_s 			= varargin{2};
		% check completness of config.
		if ~isfield( config_s, 'w_Method'),
            config_s.w_Method = 'fft';
        end
        % If both f_HopSize_sec and i_HopSize are specified, i_HopSize takes
        % precident, that is, it will be the hop size that is actually used.
        % Default 5.8 ms
        if ~isfield( config_s, 'f_HopSize_sec'),
            config_s.f_HopSize_sec = 0.0058;
        end
		if ~isfield( config_s, 'i_HopSize'),
            config_s.i_HopSize = round(config_s.f_HopSize_sec * FGetSampRate(oSnd));
        end
		if ~isfield( config_s, 'f_Exp'),		config_s.f_Exp = 1/4;				end
end
if nargin > 2
    f_Pad_v=varargin{3};
end;

f_Sig_v = FGetSignal(oSnd);

% Calc. ERB power spec.
[d.f_DistrPts_m, d.f_SupY_v, d.f_SupX_v, i_ForwardWinSize] = ERBspect(f_Sig_v', ...                             % input sig.
	    FGetSampRate(oSnd), ...						% samp. rate
	    config_s.w_Method, ...						% method ('fft' or 'gammatone')
	    config_s.f_Exp, ...							% exponent (1/4 default)
	    config_s.i_HopSize/FGetSampRate(oSnd),...	% hopsize in seconds
        f_Pad_v);

d.i_SizeY	= length(d.f_SupY_v);
d.i_SizeX	= length(d.f_SupX_v);
d.f_SupY_v	= (d.f_SupY_v ./ FGetSampRate(oSnd))'; % normalized support

% 2x distribution elements
d.f_SampRateX = FGetSampRate(oSnd) ./ config_s.i_HopSize;
d.f_SampRateY = d.i_SizeY ./ FGetSampRate(oSnd);

% TODO: The Equivalent Noise Bandwidth (ENBW) has not been calculated for ERB
% representation.
d.f_ENBW=0;

% ERB specific
c.i_HopSize	= config_s.i_HopSize;
c.w_Method	= config_s.w_Method;
if ~isfield(config_s,'f_Exp');
    config_s.f_Exp = 1/4'; % partial loudness exponent (0.25 from Hartmann97)
end 
c.f_Exp     = config_s.f_Exp;

c.i_Len=FGetLen(oSnd);
if i_ForwardWinSize == 0
    % Some ERB techniques don't use windowing so it is safe to just increment by
    % the whole length.
    c.i_IncToNext=c.i_Len;
else
    c.i_IncToNext=(floor((c.i_Len - i_ForwardWinSize)/c.i_HopSize + 1)*c.i_HopSize);
end

% Build class
c = class(c, 'cERBRep', c2xDistr(d)); % inherit generic distribution properties
