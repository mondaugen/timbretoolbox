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
        c=c2xDistr_FGetDefaultConfig();
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
        if (isfield(d,'f_ENBW')),
            c.f_ENBW = d.f_ENBW;
        else,
            c.f_ENBW        = 0;
        end;
    otherwise
        error('Incorrect arg. to C2xDistr class constructor');
end;

c = class(c, 'c2xDistr');%, cErrReport); % inherit error reporting capabilities
