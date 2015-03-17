% function c = FNormalize(c)
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
% Copyright (c) 2011 IRCAM/ McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function c = FNormalize(c)

c.f_Sig_v = c.f_Sig_v ./ max(c.f_Sig_v);

return;