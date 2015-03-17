% function[f] = Fmatlabversf(k, sr_hz, sizeFFT)
%
% DESCRIPTION:
% ============
% convert index in Matlab vector k (1<=k<=sizeFFT) to frequency f (0<=f<=sr_hz) in Hz 
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

function[f] = Fmatlabversf(k, sr_hz, sizeFFT)

f = (k-1)/sizeFFT*sr_hz;