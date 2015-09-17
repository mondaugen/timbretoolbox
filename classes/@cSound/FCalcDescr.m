function [dTEE_s, dAS_s] = FCalcDescr(c, config_s)
% FCALCDESCR
%
% Description:
% ============
% Description:  Descriptor functions for time-domain sound
%
% INPUTS:
% =======
% c:          Sound object
% config_s:   Structure containing field
%             - xcorr_nb_coeff
%               The number of auto correlation coefficients computed.
%   
%
% OUTPUTS:
% ========
% - dTEE_s	descriptors of Temporal Energy Envelope
% - dAS_s	descriptors of Audio Signal
%
% See cSound
%
% Copyright (c) 2011 IRCAM/ McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%


if ~isfield(config_s,'xcorr_nb_coeff'),
    config_s.xcorr_nb_coeff = 12;
end;

do_affiche = 0;

% === Duration: This is actually the time of the beginning of the last sample.
f_Dur			= (c.i_Len-1)/c.f_Fs; % (s)

% === Calculate signal envelope (const taken from IRCAM toolbox)
[f_Energy_v]	= FCalcEnv(c.f_Sig_v, c.f_Fs, 5);

% === Log attack time, Temporal increase, Temporal decrease
[f_LAT, f_Incr, f_Decr, f_ADSR_v]	= FCalcLogAttack(f_Energy_v, c.f_Fs, 0.15);	% === GFP 2010/11/16

% === Temporal centroid
f_TempCent	= FCalcTempCentroid(f_Energy_v, 0.15) ./ c.f_Fs;	% temporal centroid (in seconds)

% === Effective duration
f_EffDur	= FCalcEffectiveDur(f_Energy_v, 0.4) ./ c.f_Fs;	% effective duration (in seconds)

% === Energy modulation (tremolo)
[f_FreqMod, f_AmpMod] = FCalcModulation(f_Energy_v, f_ADSR_v, c.f_Fs); % === GFP 2010/11/16

% === Instantaneous temporal features
count = 0;
dAS_f_SupX_v_count = 0;
dAS_f_SupX_v = zeros(1,floor((c.i_Len - c.i_WinSize)/c.i_HopSize)+1);
for n = (1 + c.i_HopSize*(0 : floor((c.i_Len - c.i_WinSize)/c.i_HopSize))),
%for n = 1 : c.i_HopSize : (c.i_Len - c.i_WinSize)
	f_Frm_v					= c.f_Sig_v( n + [0:c.i_WinSize-1]) .* c.f_Win_v;

	count = count+1;
	% === Autocorrelation
	f_Coeffs_v				= fftshift( xcorr(f_Frm_v + eps, 'coeff') );	% GFP divide by zero issue
	f_AutoCoeffs_v(:,count)	= f_Coeffs_v(1 : config_s.xcorr_nb_coeff);	% only save 12 coefficients

	% === Zero crossing rate
	i_Sign_v			= sign( f_Frm_v - mean(f_Frm_v) );
	i_Zcr_v				= find( diff(i_Sign_v) );
	i_NumZcr			= length(i_Zcr_v);
	f_ZcrRate_v(count)	= i_NumZcr ./ (length(f_Frm_v) / c.f_Fs); % zero crossing rate
    dAS_f_SupX_v(count) = dAS_f_SupX_v_count;
    dAS_f_SupX_v_count  = dAS_f_SupX_v_count + c.i_HopSize/c.f_Fs;
end




% ==============================
% ||| Build output structure |||
% ==============================

dTEE_s.Att			= f_ADSR_v(1);
dTEE_s.Dec			= f_ADSR_v(2);
dTEE_s.Rel			= f_ADSR_v(5);
dTEE_s.LAT			= f_LAT;				% === log attack time
dTEE_s.AttSlope		= f_Incr;				% === temporal increase
dTEE_s.DecSlope		= f_Decr;				% === temporal decrease
dTEE_s.TempCent		= f_TempCent;			% === temporal centroid
dTEE_s.EffDur		= f_EffDur;				% === effective duration
dTEE_s.FreqMod		= f_FreqMod;			% === energy modulation frequency
dTEE_s.AmpMod		= f_AmpMod;				% === energy modulation amplitude
dTEE_s.RMSEnv		= f_Energy_v(:).';		% === GFP 2010/11/16
% The support vector for the RMSEnv goes from 0 to the time of the last sample
% in seconds, incremented by the sample period.
dTEE_s.f_SupX_v     = (0:(c.i_Len-1))/c.f_Fs;
% The chunk size is stored to indicate the amount of time over which the
% values, except for RMSEnv and f_SupX_v, are valid.
dTEE_s.f_ChunkSize_sec = c.i_Len/c.f_Fs;
%dTEE_s.ADSR_v		= f_ADSR_v([1 2 5]);	% === attack-decay-sustain-release envelope
for num_dim=1:size(f_AutoCoeffs_v,1)
dAS_s.(sprintf('AutoCorr%d',num_dim)) = f_AutoCoeffs_v(num_dim,:);	% === autocorrelation
end
dAS_s.ZcrRate		= f_ZcrRate_v;		% === zero crossing rate
% The support vector for the autocorrelation values and zero crossing rate goes
% from 0 to the time floor((c.i_Len - c.i_WinSize)/c.i_HopSize)*c.i_HopSize/c.f_Fs
% incremented by c.i_HopSize/c.f_Fs
% 
dAS_s.f_SupX_v      = dAS_f_SupX_v;


% +++++++++++++++++++++++++++++++++++++
if do_affiche
	clf,
	subplot(121), plot(f_Energy_v);
	ALLDESC_s.dTEE_s = dTEE_s; 
	Gget_temporalmodeling_onefile(ALLDESC_s, 1);
	Fpause
end
% +++++++++++++++++++++++++++++++++++++
