% function [ALLDESC_s] = Gget_desc_onefile(AUDIOFILENAME, do_s, config_s)
%
% DESCRIPTION:
% ============
% performs descriptor computation
%
% INPUTS:
% =======
% - AUDIOFILENAME		.fullpath
% - do_s				.b_TDR	.b_FFT	.b_Harm	.b_ERB	.b_NLO
% - config_s			.nb_harmo, ...
%
% OUTPUTS:
% ========
% - ALLDESC_s(:).family_name(:).descriptor_name(:)
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

function [ALLDESC_s] = Gget_desc_onefile(AUDIOFILENAME, do_s, config_s)

% === Read input file
Snd_o	= cSound(AUDIOFILENAME);
Snd_o	= FNormalize(Snd_o); 

if( do_s.b_TEE )
	% === Time-domain Representation (log attack time, envelope, etc)
	fprintf(1, 'Descriptors based on Temporal Energy Envelope / Audio Signal\n');
	[ALLDESC_s.TEE, ALLDESC_s.AS] = FCalcDescr(Snd_o, config_s);
end

if( do_s.b_STFTmag )
	% === STFT Representation mag-scale
	fprintf(1, 'Descriptors based on STFTmag\n');
	FFTConfig1_s.w_DistType	= 'mag'; % other config. args. will take defaults
	FFT1_o					= cFFTRep(Snd_o, FFTConfig1_s);
	ALLDESC_s.STFTmag		= FCalcDescr(FFT1_o);
end

if( do_s.b_STFTpow )
	% === STFT Representation power-scale
	fprintf(1, 'Descriptors based on STFTpow\n');
	FFTConfig2_s.w_DistType	= 'pow'; % other config. args. will take defaults
	FFT2_o					= cFFTRep(Snd_o, FFTConfig2_s);
	ALLDESC_s.STFTpow		= FCalcDescr(FFT2_o);
end;

if( do_s.b_Harmonic )
	% === Sinusoidal Harmonic Model Representation
	fprintf(1, 'Descriptors based on Harmonic\n');
    Harm_o                  = cHarmRep(Snd_o, config_s);
	ALLDESC_s.Harmonic		= FCalcDescr(Harm_o);
end


% === Equivalent Rectangular Bandwidth (ERB) Representation
if( do_s.b_ERBfft )
	% === ERB power spectrum using fft method
	fprintf(1, 'Descriptors based on ERBfft\n');
	ERBConfig1_s.w_Method	= 'fft';
	ERBConfig1_s.f_Exp		= 1/4'; % partial loudness exponent (0.25 from Hartmann97)
	ERB1_o					= cERBRep(Snd_o, ERBConfig1_s);
	ALLDESC_s.ERBfft 		= FCalcDescr(ERB1_o);
end

if( do_s.b_ERBgam )
	% === ERB power spectrum using gammatone filterbank method
	fprintf(1, 'Descriptors based on ERBgam\n');
	ERBConfig2_s.w_Method	= 'gammatone';
	ERBConfig2_s.f_Exp		= 1/4'; % partial loudness exponent (0.25 from Hartmann97)
	ERB2_o					= cERBRep(Snd_o, ERBConfig2_s);
	ALLDESC_s.ERBgam 		= FCalcDescr(ERB2_o);
end

