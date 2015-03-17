% function [dFFTHarm_s] = FCalcDescr(c)
%
% Description:
% ============
% Calculate harmonic descriptors 
%
% INPUTS:
% =======
% - c
%
% OUTPUTS:
% ========
% - dFFTHarm_s
% 
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [dFFTHarm_s] = FCalcDescr(c)

do_affiche = 0;

i_Offset = 0;
i_EndFrm = length(c.PartTrax_s);

for (i = 2:i_EndFrm)

	% === Energy
	f_Energy	= sum( c.f_DistrPts_m(:,i+i_Offset) );	 
	f_HarmErg	= sum( c.PartTrax_s(i).f_Ampl_v .^2 );		 
	f_NoiseErg	= f_Energy - f_HarmErg;					 

	% === Noisiness
	f_Noisiness	= f_NoiseErg ./ (f_Energy+eps);			 

	% === Inharmonicity
	i_NumHarm	= length( c.PartTrax_s(i).f_Ampl_v );
	if( i_NumHarm < 5 ), f_InHarm = []; continue; end;
	f_Harms_v	= c.f_F0_v(i) .* [1:i_NumHarm]';
	f_InHarm	= sum( abs(c.PartTrax_s(i).f_Freq_v - f_Harms_v) .* (c.PartTrax_s(i).f_Ampl_v .^ 2) ) ./ (sum( c.PartTrax_s(i).f_Ampl_v .^ 2 )+eps) .* 2 / c.f_F0_v(i);

	% === Harmonic spectral deviation
	f_SpecEnv_v					= []; % === clear prev result
	f_SpecEnv_v(1)				= c.PartTrax_s(i).f_Ampl_v(1);
	f_SpecEnv_v(2:i_NumHarm-1)	= ( c.PartTrax_s(i).f_Ampl_v(1:end-2) + c.PartTrax_s(i).f_Ampl_v(2:end-1) + c.PartTrax_s(i).f_Ampl_v(3:end) ) / 3;
	f_SpecEnv_v(i_NumHarm)		= ( c.PartTrax_s(i).f_Ampl_v(end-1) + c.PartTrax_s(i).f_Ampl_v(end) ) / 2;
	f_HarmDev					= sum( abs( c.PartTrax_s(i).f_Ampl_v - f_SpecEnv_v' ) ) ./ i_NumHarm;

	% === Odd to even harmonic ratio
	f_OddEvenRatio	= sum( c.PartTrax_s(i).f_Ampl_v(1:2:end).^2 ) ./ (sum( c.PartTrax_s(i).f_Ampl_v(2:2:end).^2 )+eps);

	% === Harmonic tristimulus
	f_TriStim_v(1,1)	= c.PartTrax_s(i).f_Ampl_v(1)				/ (sum(c.PartTrax_s(i).f_Ampl_v)+eps);	 
	f_TriStim_v(2,1)	= sum(c.PartTrax_s(i).f_Ampl_v([2 3 4]))	/ (sum(c.PartTrax_s(i).f_Ampl_v)+eps);	 
	f_TriStim_v(3,1)	= sum(c.PartTrax_s(i).f_Ampl_v([5:end]))	/ (sum(c.PartTrax_s(i).f_Ampl_v)+eps);	 

	% === Build output structure
	dFFTHarm_s.FrameErg(i-1)	= f_Energy;		 
	dFFTHarm_s.HarmErg(i-1)		= f_HarmErg;
	dFFTHarm_s.NoiseErg(i-1)	= f_NoiseErg;
	dFFTHarm_s.Noisiness(i-1)	= f_Noisiness;
	dFFTHarm_s.F0(i-1)			= c.f_F0_v(i);
	dFFTHarm_s.InHarm(i-1)		= f_InHarm;
	dFFTHarm_s.TriStim1(i-1)	= f_TriStim_v(1,1);
	dFFTHarm_s.TriStim2(i-1)	= f_TriStim_v(2,1);
	dFFTHarm_s.TriStim3(i-1)	= f_TriStim_v(3,1);
	dFFTHarm_s.HarmDev(i-1)		= f_HarmDev;
	dFFTHarm_s.OddEvenRatio(i-1)= f_OddEvenRatio;

	dFFTHarm_s						= FCalcDescr_common(c, i, dFFTHarm_s);
	dFFTHarm_s.w_ErrMsg				= ' ';

	% +++++++++++++++++++++++++++++++++
	if do_affiche
		clf,
		subplot(221), imagesc(c.f_SupX_v, c.f_SupY_v, c.f_DistrPts_m), 
		a=colormap('gray'); colormap(1-a); axis xy;  
		subplot(223), plot(c.f_SupY_v, c.f_DistrPts_m);   
		ALLDESC_s.dFFTHarm_s=dFFTHarm_s; 
		Gget_temporalmodeling_onefile(ALLDESC_s, 1);
		Fpause
	end
	% +++++++++++++++++++++++++++++++++

end



if i_EndFrm==0
	dFFTHarm_s = [];
end

if isempty(c.PartTrax_s)
	name_c = {'FrameErg', 'HarmErg', 'NoiseErg', 'Noisiness', 'F0', 'InHarm', 'TriStim1', 'TriStim2', 'TriStim3', 'HarmDev', 'OddEvenRatio', ...
		'SpecCent', 'SpecSpread', 'SpecSkew', 'SpecKurt', 'SpecSlope', 'SpecDecr', 'SpecRollOff', 'SpecVar'};
	for n=1:length(name_c)
		dFFTHarm_s.(name_c{n})(1,5) = 0;
	end
	dFFTHarm_s.w_ErrMsg				= ' ';
end


