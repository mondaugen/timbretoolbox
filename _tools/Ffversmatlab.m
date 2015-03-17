% function [k] = Ffversmatlab(f, sr_hz, sizeFFT)
%
% DESCRIPTION:
% ===========
% convert frequency vector f (0<=f<=sr_hz) to matlab index k (1<=k<=sizeFFT) 
%
% INPUTS:
% =======
%
% OUTPUTS:
% ========
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [k] = Ffversmatlab(f, sr_hz, sizeFFT)

k = round(f/sr_hz*sizeFFT)+1;
