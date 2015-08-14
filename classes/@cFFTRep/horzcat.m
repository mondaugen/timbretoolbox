function [a] = horzcat(a,b)
% Combines two FFT representations by concatenating their distributions. The
% concatenation fails if any fields other than the distributions are not equal.
%
% Convert to structures
a=struct(a);
b=struct(b);
% Check for equality
if ~(a.i_FFTSize == b.i_FFTSize)
    error(['Fields i_FFTSize not equal.' ...
        'First is ' a.i_FFTSize ', second is ' b.i_FFTSize]);
end;
if ~(a.f_BinSize == b.f_BinSize)
    error(['Fields f_BinSize not equal.' ...
        'First is ' a.f_BinSize ', second is ' b.f_BinSize]);
end;
if ~(a.i_WinSize == b.i_WinSize)
    error(['Fields i_WinSize not equal.' ...
        'First is ' a.i_WinSize ', second is ' b.i_WinSize]);
end;
if ~(a.i_HopSize == b.i_HopSize)
    error(['Fields i_HopSize not equal.' ...
        'First is ' a.i_HopSize ', second is ' b.i_HopSize]);
end;
if ~(a.w_WinType == b.w_WinType)
    error(['Fields w_WinType not equal.' ...
        'First is ' a.w_WinType ', second is ' b.w_WinType]);
end;
if any(~(a.f_Win_v == b.f_Win_v))
    error(['Fields f_Win_v not equal.' ...
        'First is ' a.f_Win_v ', second is ' b.f_Win_v]);
end;
% "a" cannot contain a field called c2xDistr before it becomes a class, so we
% store the concatenated distribution somewhere else and delete the field
distr=[a.c2xDistr,b.c2xDistr];
a=rmfield(a,'c2xDistr');
% Now it will inherit from the concatenated c2xDistr
a=class(a,'cFFTRep',distr);
