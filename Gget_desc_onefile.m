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

function [ALLDESC_s,ALLREP_s] = Gget_desc_onefile(AUDIOFILENAME, do_s, config_s)

% Get file type from filename suffix.
pos_v__	   = findstr(AUDIOFILENAME, '.');
filetype = AUDIOFILENAME(pos_v__(end)+1:end);
if strcmp(filetype,'raw')
    if ~isfield(config_s.SOUND,'i_Channels') ...
        error(['For files of type raw, the number of ' ...
            'channels must be specified in the configuration structure.']);
    end
end

% === Read input file
Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);

ALLDESC_s=struct();
ALLREP_s=struct();

% Specify respective analysis methods for ERB.
config_s.ERBfft.w_Method	= 'fft';
config_s.ERBgam.w_Method	= 'gammatone';

if( do_s.b_TEE )
	% === Time-domain Representation (log attack time, envelope, etc)
	fprintf(1, 'Descriptors based on Temporal Energy Envelope / Audio Signal\n');
    [TEE,AS]=FCalcDescr(Snd_o,config_s.TEE);
    ALLDESC_s.TEE=cTEEDescr(TEE);
    ALLDESC_s.AS=cASDescr(AS);
end

if( do_s.b_STFTmag )
	% === STFT Representation mag-scale
	fprintf(1, 'Descriptors based on STFTmag\n');
    config_s.STFTmag.w_DistType	= 'mag'; % other config. args. will take defaults
    FFT1_o=cFFTRep(Snd_o,config_s.STFTmag,[]);
    ALLREP_s.STFTmag=FFT1_o;
    STFTmag	= FCalcDescr(FFT1_o);
    ALLDESC_s.STFTmag=cFFTDescr(STFTmag);
end

if( do_s.b_STFTpow )
	% === STFT Representation power-scale
	fprintf(1, 'Descriptors based on STFTpow\n');
    config_s.STFTpow.w_DistType	= 'pow'; % other config. args. will take defaults
    FFT2_o=cFFTRep(Snd_o,config_s.STFTpow,[]);
    ALLREP_s.STFTpow=FFT2_o;
    STFTpow	= FCalcDescr(FFT2_o);
    ALLDESC_s.STFTpow=cFFTDescr(STFTpow);
end;

if( do_s.b_Harmonic )
	% === Sinusoidal Harmonic Model Representation
	fprintf(1, 'Descriptors based on Harmonic\n');
    Harm_o=cHarmRep(Snd_o,config_s.Harmonic,[]);
    ALLREP_s.Harmonic=Harm_o;
    Harmonic		= FCalcDescr(Harm_o);
    ALLDESC_s.Harmonic=cHarmDescr(Harmonic);
end


% === Equivalent Rectangular Bandwidth (ERB) Representation
if( do_s.b_ERBfft )
	% === ERB power spectrum using fft method
	fprintf(1, 'Descriptors based on ERBfft\n');
    ERB1_o=cERBRep(Snd_o,config_s.ERBfft,[]);
    ALLREP_s.ERBfft=ERB1_o;
    ERBfft		= FCalcDescr(ERB1_o);
    ALLDESC_s.ERBfft=cERBDescr(ERBfft);
end

if( do_s.b_ERBgam )
	% === ERB power spectrum using gammatone filterbank method
	fprintf(1, 'Descriptors based on ERBgam\n');
	config_s.ERBgam.w_Method	= 'gammatone';
    ERB2_o = cERBRep(Snd_o, config_s.ERBgam, []);
    ALLREP_s.ERBgam=ERB2_o;
    ERBgam 		= FCalcDescr(ERB2_o);
    ALLDESC_s.ERBgam=cERBDescr(ERBgam);
end

flds=fields(ALLDESC_s);
for k=1:length(flds),
    ALLDESC_s.(flds{k})=struct(ALLDESC_s.(flds{k}));
end;
