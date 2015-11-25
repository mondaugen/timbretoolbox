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
f_DistrPts_m=FGetDistr(c);
f_ENBW=FGetENBW(c);

for (i = 1:i_EndFrm)

	% === Energy
	f_Energy	= sum( f_DistrPts_m(:,i+i_Offset) );	 
    % Calculate power from distribution points assuming it is magnitude spectrum
    f_Pow     = sum( f_DistrPts_m(:,i+i_Offset).^2 ) ./ f_ENBW;
	f_HarmErg	= sum( c.PartTrax_s(i).f_Ampl_v .^2 );		 
    % The "harmonic energy" is the same as the harmonic power
    f_HarmPow   = sum( c.PartTrax_s(i).f_Ampl_v .^2 );
	f_NoiseErg	= f_Energy - f_HarmErg;					 
    % Because the analytic signal is used when calculating the spectrogram, the
    % power of the noise in the signal has been doubled. We divide by two to get
    % the true estimate.
    f_NoisePow  = (f_Pow - f_HarmPow)/2;

	% === Noisiness
	f_Noisiness	= f_NoiseErg ./ (f_Energy+eps);			 

	% === Inharmonicity
	i_NumHarm	= length( c.PartTrax_s(i).f_Ampl_v );
	if (i_NumHarm < 5)
        f_Energy = 0;		 
        f_HarmErg = 0;
        f_NoiseErg = 0;
        f_Noisiness = 0;
        f_InHarm = 0;
        f_TriStim_v(1,1) = 0;
        f_TriStim_v(2,1) = 0;
        f_TriStim_v(3,1) = 0;
        f_HarmDev = 0;
        f_OddEvenRatio = 0;
        f_Pow = 0;
        f_HarmPow = 0;
        f_NoisePow = 0;
    else
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
    end
    
	% === Build output structure
	dFFTHarm_s.FrameErg(i)	= f_Energy;		 
	dFFTHarm_s.HarmErg(i)		= f_HarmErg;
	dFFTHarm_s.NoiseErg(i)	= f_NoiseErg;
	dFFTHarm_s.Noisiness(i)	= f_Noisiness;
	dFFTHarm_s.F0(i)			= c.f_F0_v(i);
	dFFTHarm_s.InHarm(i)		= f_InHarm;
	dFFTHarm_s.TriStim1(i)	= f_TriStim_v(1,1);
	dFFTHarm_s.TriStim2(i)	= f_TriStim_v(2,1);
	dFFTHarm_s.TriStim3(i)	= f_TriStim_v(3,1);
	dFFTHarm_s.HarmDev(i)		= f_HarmDev;
	dFFTHarm_s.OddEvenRatio(i)= f_OddEvenRatio;
    dFFTHarm_s.f_Pow(i) = f_Pow;
    dFFTHarm_s.f_HarmPow(i) = f_HarmPow;
    dFFTHarm_s.f_NoisePow(i) = f_NoisePow;

	dFFTHarm_s						= FCalcDescr_common(c, i, dFFTHarm_s);
	dFFTHarm_s.w_ErrMsg				= ' ';

	% +++++++++++++++++++++++++++++++++
	%if do_affiche
	%	clf,
	%	subplot(221), imagesc(c.f_SupX_v, c.f_SupY_v, f_DistrPts_m), 
	%	a=colormap('gray'); colormap(1-a); axis xy;  
	%	subplot(223), plot(c.f_SupY_v, f_DistrPts_m);   
	%	ALLDESC_s.dFFTHarm_s=dFFTHarm_s; 
	%	Gget_temporalmodeling_onefile(ALLDESC_s, 1);
	%	Fpause
	%end
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

% Descriptor's classes require f_SupX_v
[f_SupY_v,dFFTHarm_s.f_SupX_v]=FGetSup(c);
