% function [MOD_fr, MOD_am] = FCalcModulation(f_Env_v, f_ADSR_v, fFs)
%
% DESCRIPTION:
% ============
% compute the modulation (frequency and amplitude) of f_Env_v
%
% INPUTS:
% =======
% - f_Env_v		: envelop vector (can be energy or fundamenal frequency) over time
% - f_ADSR_v	: define the attack/ sustain/ release point
% - fFs			: sampling rate
%
% OUTPUTS:
% ========
% - MOD_fr		: modulation frequency
% - MOD_am		: modulation amplitude
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%


function [MOD_fr, MOD_am] = FCalcModulation(f_Env_v, f_ADSR_v, fFs)

do.method		= 'fft'; % === 'fft' 'hilbert'

% ============================================
envelopfull_v	= f_Env_v;
envelopfull_v	= envelopfull_v(:);
tempsfull_sec_v = [0:length(f_Env_v)-1]'*1/fFs;

sr_hz			= 1/mean(diff(tempsfull_sec_v));
ss_sec			= f_ADSR_v(2); % === start sustain
es_sec			= f_ADSR_v(5); % === end   sustain

flag_is_sustained = 0;

if (es_sec - ss_sec) > 0.02,  % === if there is a sustained part
	pos_v		= find(ss_sec <= tempsfull_sec_v & tempsfull_sec_v <= es_sec);
	if ~isempty(pos_v), flag_is_sustained = 1; end
end

if flag_is_sustained

	envelop_v	= envelopfull_v(pos_v);
	temps_sec_v	= tempsfull_sec_v(pos_v);
	M			= mean(envelop_v);

	% === TAKING THE ENVELOP
	mon_poly	= polyfit(temps_sec_v, log(envelop_v), 1);
	hatenvelop_v= exp(polyval(mon_poly, temps_sec_v));
	signal_v	= envelop_v - hatenvelop_v;

	switch do.method

		case 'fft', % ==========================

			% === par FFT
			L_n    		= length(signal_v);
			N      		= max([sr_hz, 2^nextpow2(L_n)]);
			fenetre_v	= hamming(L_n);
			norma		= sum(fenetre_v) ;
			fft_v		= fft(signal_v.*fenetre_v*2/norma, round(N));
			ampl_v 		= abs(fft_v);
			phas_v		= angle(fft_v);
			freq_v 		= Fmatlabversf([1:N], sr_hz, N)';

			param_fmin = 1; param_fmax = 10;
			pos_v  		= find(freq_v < param_fmax & freq_v > param_fmin);

			[pos_max_v]	= Fcomparepics2(ampl_v(pos_v), 2);
			if ~isempty(pos_max_v)
				[max_value, max_pos]	= max(ampl_v(pos_v(pos_max_v)));
				max_pos					= pos_v(pos_max_v(max_pos));
			else
				[max_value, max_pos]	= max(ampl_v(pos_v));
				max_pos 				= pos_v(max_pos);
			end

			MOD_am		= max_value/M;
			MOD_fr		= freq_v(max_pos);
			MOD_ph		= phas_v(max_pos);

			if isempty(MOD_am) || isempty(MOD_fr),
				MOD_am = 0;
				MOD_fr = 0;
			end




		case 'hilbert', % ==========================

			sa_v		= hilbert(signal_v(:));
			sa_ampl_v	= abs(signal_v);
			sa_phase_v	= unwrap(angle(hilbert(signal_v)));
			sa_freqinst_v= 1/(2*pi)*sa_phase_v./(temps_n_v/sr_hz);

			MOD_am		= median(sa_ampl_v);
			MOD_fr		= median(sa_freqinst_v);

	end
	% ============================

else % === if there is NO  sustained part

	MOD_fr = 0;
	MOD_am = 0;

end
