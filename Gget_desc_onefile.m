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
Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
Snd_o	= FNormalize(Snd_o); 

ALLDESC_s.DATA = struct(Snd_o);

if( do_s.b_TEE )
	% === Time-domain Representation (log attack time, envelope, etc)
	fprintf(1, 'Descriptors based on Temporal Energy Envelope / Audio Signal\n');
	[ALLDESC_s.TEE, ALLDESC_s.AS] = FCalcDescr(Snd_o, config_s.TEE);
end

if( do_s.b_STFTmag )
	% === STFT Representation mag-scale
	fprintf(1, 'Descriptors based on STFTmag\n');
	config_s.STFTmag.w_DistType	= 'mag'; % other config. args. will take defaults
	FFT1_o					= cFFTRep(Snd_o, config_s.STFTmag);
	ALLDESC_s.STFTmag_raw	= FFT1_o;
	ALLDESC_s.STFTmag		= FCalcDescr(FFT1_o);
end

if( do_s.b_STFTpow )
	% === STFT Representation power-scale
	fprintf(1, 'Descriptors based on STFTpow\n');
	config_s.STFTpow.w_DistType	= 'pow'; % other config. args. will take defaults
	FFT2_o					= cFFTRep(Snd_o, config_s.STFTpow);
	ALLDESC_s.STFTpow_raw	= FFT2_o;
	ALLDESC_s.STFTpow		= FCalcDescr(FFT2_o);
end;

if( do_s.b_Harmonic )
	% === Sinusoidal Harmonic Model Representation
	fprintf(1, 'Descriptors based on Harmonic\n');
    Harm_o                  = cHarmRep(Snd_o, config_s.Harmonic);
	ALLDESC_s.Harmonic_raw	= Harm_o;
	ALLDESC_s.Harmonic		= FCalcDescr(Harm_o);
end


% === Equivalent Rectangular Bandwidth (ERB) Representation
if( do_s.b_ERBfft )
	% === ERB power spectrum using fft method
	fprintf(1, 'Descriptors based on ERBfft\n');
	config_s.ERBfft.w_Method	= 'fft';
	config_s.ERBfft.f_Exp		= 1/4'; % partial loudness exponent (0.25 from Hartmann97)
	ERB1_o					= cERBRep(Snd_o, config_s.ERBfft);
	ALLDESC_s.ERBfft_raw 	= ERB1_o;
	ALLDESC_s.ERBfft 		= FCalcDescr(ERB1_o);
end

if( do_s.b_ERBgam )
	% === ERB power spectrum using gammatone filterbank method
	fprintf(1, 'Descriptors based on ERBgam\n');
	config_s.ERBgam.w_Method	= 'gammatone';
	config_s.ERBgam.f_Exp		= 1/4'; % partial loudness exponent (0.25 from Hartmann97)
	ERB2_o					= cERBRep(Snd_o, config_s.ERBgam);
	ALLDESC_s.ERBgam_raw 	= ERB2_o;
	ALLDESC_s.ERBgam 		= FCalcDescr(ERB2_o);
end

