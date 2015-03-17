% function [c] = c2xDistr(varargin)
%
% DESCRIPTION:
% ============ 
%
% INPUTS:
% =======
%
% OUTPUTS:
% ========
% 
% see cFFTRep, cERBRep
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [c] = c2xDistr(varargin)

switch nargin
    case 0
        % elements common to any 2-d distribution
        c.i_SizeX		= 0;								% size of x-dim (cols)
        c.i_SizeY		= 0;								% size of y-dim (rows)
        c.f_SupX_v		= [1:c.i_SizeX];					% row vector for x-dim
        c.f_SupY_v		= [1:c.i_SizeY]';					% column vector for y-dim
        c.f_SampRateX	= 0;								% sampling rate on x-dim (hop rate)
        c.f_SampRateY	= 0;								% sampling rate on y-dim (fft rate)
        c.f_DistrPts_m	= zeros( c.i_SizeY, c.i_SizeX );	% distr points
    case 1
        d = varargin{1};
        % add checks for compatibility of args here
        c.i_SizeX		= d.i_SizeX; 
        c.i_SizeY		= d.i_SizeY; 
        c.f_SupX_v		= d.f_SupX_v;
        c.f_SupY_v		= d.f_SupY_v;
        c.f_SampRateX	= d.f_SampRateX;
        c.f_SampRateY	= d.f_SampRateY;
        c.f_DistrPts_m	= d.f_DistrPts_m;
    otherwise
        error('Incorrect arg. to C2xDistr class constructor');
end;

c = class(c, 'c2xDistr');%, cErrReport); % inherit error reporting capabilities
