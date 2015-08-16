% function [desc_s] = FCalcDescr(c)
%
% Description:
% ============
% Wrapper to encapsulate descriptor functions
%
% Input(s):
% =======
% - c:			2-d distribution  function (inherit from c2xDistr)
%
% Output(s):
% ========
% - desc_s:		...
%
% See c2xDistr, cFFTRep, cERBRep
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [desc_s] = FCalcDescr(c)

do_affiche = 0;

% === Local statistical measures
% === c.f_DistrPts_m (N = c.i_SizeY, nb_frame = c.i_SizeX)
f_ProbDistrY_m	= c.f_DistrPts_m ./ repmat( sum(c.f_DistrPts_m, 1)+eps, c.i_SizeY, 1 ); % === normalize distribution in Y dim
%if any( ...
%    abs(sum(f_ProbDistrY_m) - ones(1,size(f_ProbDistrY_m,2))) > 300*eps),
%    sum(f_ProbDistrY_m)
%    error('Calculation of distributions failed.');
%end;

% === Calculate spectral moments

% Compute the variable of integration
Y_ = repmat(c.f_SupY_v,1,c.i_SizeX);
% Spectral centroid (mean)
f_Centroid_v = sum( Y_ .* f_ProbDistrY_m );
% Centre variable of integration around the mean
f_MeanCntr_m = Y_ - repmat(f_Centroid_v, c.i_SizeY, 1);
% Spectral spread (variance)
f_Spread_v = sum(f_MeanCntr_m.^2 .* f_ProbDistrY_m) .^ (1/2);
% Spectral skewness (skewness)
f_Skew_v = sum(f_MeanCntr_m.^3 .* f_ProbDistrY_m) ./ (f_Spread_v .^ 3);
% Spectral kurtosis (kurtosis)
f_Kurtosis_v = sum(f_MeanCntr_m.^4 .* f_ProbDistrY_m) ./ (f_Spread_v .^ 4);

% === Spectral slope (linear regression)
f_Num_v		= c.i_SizeY .* (c.f_SupY_v' * f_ProbDistrY_m) ...
                - sum(c.f_SupY_v) .* sum(f_ProbDistrY_m);
f_Den		= c.i_SizeY .* sum(c.f_SupY_v.^2) - sum(c.f_SupY_v).^2;
f_Slope_v	= f_Num_v ./ f_Den;

% === Spectral decrease (according to peeters report)
f_Num_m		= c.f_DistrPts_m(2:c.i_SizeY, :) ...
                - repmat(c.f_DistrPts_m(1,:), c.i_SizeY-1, 1);
f_Den_v		= 1 ./ [1:c.i_SizeY-1];
% The sum is carried out by inner product.
f_SpecDecr_v= (f_Den_v * f_Num_m) ./ sum(c.f_DistrPts_m(2:c.i_SizeY,:)+eps);

% === Spectral roll-off
% This will only be correct according to the definition if the power
% spectrum is used as it assumes that the amplitude values have already
% been squared.
f_Thresh		= 0.95;
f_CumSum_m		= cumsum(c.f_DistrPts_m);
f_Sum_v			= f_Thresh * sum(c.f_DistrPts_m, 1);
i_Bin_m			= f_CumSum_m > repmat( f_Sum_v, c.i_SizeY, 1 );
[i_Ind_v, trash]= find( cumsum(i_Bin_m) == 1 );
f_SpecRollOff_v	= c.f_SupY_v(i_Ind_v)';

% === Spectral variation (Spect. Flux)
f_CrossProd_v	= sum( c.f_DistrPts_m .* [zeros(c.i_SizeY,1), c.f_DistrPts_m(:,1:c.i_SizeX-1)] , 1);
f_AutoProd_v	= sum( c.f_DistrPts_m.^2 , 1) .* sum( [zeros(c.i_SizeY,1), c.f_DistrPts_m(:,1:c.i_SizeX-1)].^2, 1);
f_SpecVar_v		= 1 - f_CrossProd_v ./ (sqrt(f_AutoProd_v) + eps);
f_SpecVar_v(1)	= f_SpecVar_v(2);		% === the first value is always incorrect because of "c.f_DistrPts_m .* [zeros(c.i_SizeY,1)"

% === Energy
f_Energy_v		= sum(c.f_DistrPts_m);  

% === Spectral Flatness
% We only consider the spectrum below Nyquist
f_GeoMean_v		= exp( (1/c.i_SizeY) * sum(log(c.f_DistrPts_m+eps)) ); 
f_ArthMean_v	= sum(c.f_DistrPts_m) ./ c.i_SizeY;
f_SpecFlat_v	= f_GeoMean_v ./ (f_ArthMean_v+eps);

% === Spectral Crest Measure
f_SpecCrest_v = max(c.f_DistrPts_m) ./ (f_ArthMean_v+eps);



% ==============================
% ||| Build output structure |||
% ==============================
% debugging
desc_s.f_MeanCntr_m = f_MeanCntr_m;
desc_s.f_ProbDistrY_m = f_ProbDistrY_m;
%
desc_s.SpecCent		= f_Centroid_v;			% spectral centroid
desc_s.SpecSpread	= f_Spread_v;			% spectral standard deviation
desc_s.SpecSkew		= f_Skew_v;				% spectral skew
desc_s.SpecKurt		= f_Kurtosis_v;			% spectral kurtosis

desc_s.SpecSlope	= f_Slope_v;			% spectral slope
desc_s.SpecDecr		= f_SpecDecr_v;			% spectral decrease
desc_s.SpecRollOff	= f_SpecRollOff_v;		% spectral roll-off
desc_s.SpecVar		= f_SpecVar_v;			% spectral variation

desc_s.FrameErg		= f_Energy_v;			% frame energy

desc_s.SpecFlat		= f_SpecFlat_v;			% spectral flatness
desc_s.SpecCrest	= f_SpecCrest_v;		% spectral crest
desc_s.f_SupX_v     = c.f_SupX_v;           % time points

% ++++++++++++++++++++++++++++++++++
if do_affiche
	clf,
	subplot(221), imagesc(c.f_SupX_v, c.f_SupY_v, c.f_DistrPts_m),
	a=colormap('gray'); colormap(1-a); axis xy;
	subplot(223), plot(c.f_SupY_v, c.f_DistrPts_m);
	ALLDESC_s.desc_s = desc_s;	
	Gget_temporalmodeling_onefile(ALLDESC_s, 1);
	Fpause
end
% ++++++++++++++++++++++++++++++++++
