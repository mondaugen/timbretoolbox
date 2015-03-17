% function [f_Env_v] = FCalcEnv(f_Sig_v, f_Fs, f_Fc)
%
% Description:
% ============
% Calculates signal envelope from filtered amplitude modulation of the analytic signal
%
% x_a(t) = x(t) + jH{x}(t) = A(t)e^jphi
% abs(x_a(t)) = A(t) <--- signal envelope (LPF to remove noise)
%
% INPUTS:
% =======
% - f_Sig_v     : signal
% - f_Fs		: sampling rate
% - f_Fc		: cutting frequency (low-pass filter)
%
% OUTPUTS:
% ========
% - f_Env_v		: energy signal (same length as input signal)
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [f_Env_v] = FCalcEnv(f_Sig_v, f_Fs, f_Fc)

f_AnaSig_v   = hilbert(f_Sig_v); % analytic signal
f_AmpMod_v   = abs(f_AnaSig_v);  % amplitude modulation of analytic signal

% === Filter amplitude modulation with 3rd order butterworth filter
w			= f_Fc/(f_Fs/2);
[B_v,A_v]	= butter(3, w);
f_Env_v		= filter(B_v, A_v, f_AmpMod_v);
f_Env_v		= f_Env_v(:);

