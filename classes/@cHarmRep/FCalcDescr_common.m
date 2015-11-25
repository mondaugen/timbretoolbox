% function [desc_s] = FCalcDescr_common(c, i, desc_s)
%
% DESCRIPTION:
% ============
%
% INPUTS:
% =======
% - c
%    PartTrax_s	.f_Ampl_v
%				.fa_NormAmpl
%				.f_Freq_v
% - i
% - desc_s
%
% OUTPUTS
% =======
% - desc_s
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [desc_s] = FCalcDescr_common(c, i, desc_s)

i_NumHarm		= length( c.PartTrax_s(i).f_Ampl_v );

% === Harmonic centroid
f_NormAmpl_v	= c.PartTrax_s(i).f_Ampl_v ./ (sum( c.PartTrax_s(i).f_Ampl_v ) + eps);	% === divide by zero
f_Centroid		= sum( c.PartTrax_s(i).f_Freq_v .* f_NormAmpl_v );
f_MeanCentrFreq	= c.PartTrax_s(i).f_Freq_v - f_Centroid;

% === Harmonic spread
f_StdDev		= sqrt( sum( f_MeanCentrFreq.^2 .* f_NormAmpl_v ) );

% === Harmonic skew
f_Skew			= sum( f_MeanCentrFreq.^3 .* f_NormAmpl_v ) ./ (f_StdDev+eps).^3;			% === divide by zero

% === Harmonic kurtosis
f_Kurtosis		= sum( f_MeanCentrFreq.^4 .* f_NormAmpl_v ) ./ (f_StdDev+eps).^4;			% === divide by zero

% === Harmonic spectral slope (linear regression)
f_Num			= i_NumHarm * sum(c.PartTrax_s(i).f_Freq_v .* f_NormAmpl_v) - sum(c.PartTrax_s(i).f_Freq_v);
f_Den			= i_NumHarm .* sum(c.PartTrax_s(i).f_Freq_v.^2) - sum(c.PartTrax_s(i).f_Freq_v).^2;
f_Slope			= f_Num ./ f_Den;

% === Spectral decrease (according to peeters report)
if (i_NumHarm < 5)
    f_Num=0;
    f_Den=0;
else
    f_Num			= sum( (c.PartTrax_s(i).f_Ampl_v(2:i_NumHarm)' - c.PartTrax_s(i).f_Ampl_v(1)) ./ [1:i_NumHarm-1] );
    f_Den			= sum( c.PartTrax_s(i).f_Ampl_v(2:i_NumHarm) );
end
f_SpecDecr		= (f_Num ./ (f_Den+eps));	% === divide by zero

% === Spectral roll-off
f_Thresh		= 0.95;
f_CumSum_v		= cumsum(c.PartTrax_s(i).f_Ampl_v);
f_CumSumNorm_v	= f_CumSum_v / (sum(c.PartTrax_s(i).f_Ampl_v)+eps);
i_Pos			= find( f_CumSumNorm_v > f_Thresh );
%if ~isempty(i_Pos), f_SpecRollOff	= i_Pos(1); % === OLD
%else				 f_SpecRollOff	= 1;		% === OLD
%end
if ~isempty(i_Pos), f_SpecRollOff	= c.PartTrax_s(i).f_Freq_v(i_Pos(1));
else				f_SpecRollOff	= c.PartTrax_s(i).f_Freq_v(1);
end

% === Spectral variation (Spect. Flux)
% === Insure that prev. frame has same size as current frame by zero-padding
f_PrevFrm_v					= c.PartTrax_s(i).f_Ampl_v;
f_CurFrm_v					= c.PartTrax_s(i).f_Ampl_v;
i_Sz						= max( length(f_CurFrm_v), length(f_PrevFrm_v) );
f_PrevFrm_v(end+1:i_Sz)		= 0;
f_CurFrm_v(end+1:i_Sz)		= 0;
f_CrossProd					= sum( f_PrevFrm_v(:) .* f_CurFrm_v(:) );
f_AutoProd					= sqrt( sum( f_PrevFrm_v.^2 ) * sum( f_CurFrm_v.^2 ) );
f_SpecVar					= 1 - f_CrossProd / (f_AutoProd+eps);

desc_s.SpecCent(i)		= f_Centroid;
desc_s.SpecSpread(i)		= f_StdDev;
desc_s.SpecSkew(i)		= f_Skew;
desc_s.SpecKurt(i)		= f_Kurtosis;
desc_s.SpecSlope(i)		= f_Slope;
desc_s.SpecDecr(i)		= f_SpecDecr;
desc_s.SpecRollOff(i)		= f_SpecRollOff;
desc_s.SpecVar(i)			= f_SpecVar;
