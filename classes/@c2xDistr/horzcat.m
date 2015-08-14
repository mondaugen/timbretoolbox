function [a] = horzcat(a,b)
% Combines two c2xDistr objects by only concatenating their x supports and
% distributions. Other fields are checked for equality and if this succeeds, the
% fields of "a" are kept. Otherwise the function fails.
%
% convert to structures
a=struct(a);
b=struct(b);
% check for equality of certain fields
if ~(a.i_SizeY == b.i_SizeY)
    error(['Fields i_SizeY not equal.' ...
        'First is ' a.i_SizeY ', second is ' b.i_SizeY]);
end;
if any(~(a.f_SupY_v == b.f_SupY_v))
    error(['Fields f_SupY_v not equal.' ...
        'First is ' a.f_SupY_v ', second is ' b.f_SupY_v]);
end;
if ~(a.f_SampRateX == b.f_SampRateX)
    error(['Fields f_SampRateX not equal.' ...
        'First is ' a.f_SampRateX ', second is ' b.f_SampRateX]);
end;
if ~(a.f_SampRateY == b.f_SampRateY)
    error(['Fields f_SampRateY not equal.' ...
        'First is ' a.f_SampRateY ', second is ' b.f_SampRateY]);
end;
if ~(a.f_ENBW == b.f_ENBW)
    error(['Fields f_ENBW not equal.' ...
        'First is ' a.f_ENBW ', second is ' b.f_ENBW]);
end;
f_SupX_v=b.f_SupX_v+a.f_SupX_v(end)+ ...
    (a.f_SupX_v(end)-a.f_SupX_v(end-1));
a.f_SupX_v=[a.f_SupX_v,f_SupX_v];
a.i_SizeX=a.i_SizeX+b.i_SizeX;
a.f_DistrPts_m=[a.f_DistrPts_m,b.f_DistrPts_m];
a=class(a,'c2xDistr');
