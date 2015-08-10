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

function [ALLDESC_s] = Gget_desc_onefile_do_by_chunks(AUDIOFILENAME, do_s, config_s)

% Get number of samples in audio file (just assume wave for now)
sfSizeInfo=wavread(AUDIOFILENAME,'size')
nSamples=sfSizeInfo(1);
nChannels=sfSizeInfo(2);
if(nChannels~=1)
    error('Single channel audio files only, please.');
end;

currentSample = 1;
if(~isfield(config_s.SOUND,'i_ChunkSize')),
    config_s.SOUND.i_ChunkSize=32768;
end;
chunkPoints=(1:config_s.SOUND.i_ChunkSize:nSamples);
chunkPoints=chunkPoints(1:end-1);

ALLDESC_s=struct();

for rangeMin=chunkPoints,
    rangeMax=rangeMin+config_s.SOUND.i_ChunkSize-1;
    if(rangeMax>nSamples)
        rangeMax=nSamples;
    end;
    config_s.SOUND.i_SampleRange_v=[rangeMin,rangeMax];
    % === Read input file
    Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
    %Snd_o	= FNormalize(Snd_o); 
    
    ALLDESC_s.DATA = struct(Snd_o);
    
    if( do_s.b_TEE )
    	% === Time-domain Representation (log attack time, envelope, etc)
    	fprintf(1, 'Descriptors based on Temporal Energy Envelope / Audio Signal\n');
        [TEE,AS]=FCalcDescr(Snd_o,config_s.TEE);
        if isfield(ALLDESC_s,'TEE') & isfield(ALLDESC_s,'AS'),
            ALLDESC_s.TEE=[ALLDESC_s.TEE,cDescr(TEE)];
            ALLDESC_s.AS=[ALLDESC_s.AS,cDescr(AS)];
        else,
            ALLDESC_s.TEE=cDescr(TEE);
            ALLDESC_s.AS=cDescr(AS);
        end;
    end
    
    if( do_s.b_STFTmag )
    	% === STFT Representation mag-scale
    	fprintf(1, 'Descriptors based on STFTmag\n');
    	config_s.STFTmag.w_DistType	= 'mag'; % other config. args. will take defaults
    	FFT1_o					= cFFTRep(Snd_o, config_s.STFTmag);
%    	ALLDESC_s.STFTmag_raw	= FFT1_o;
    	STFTmag		= FCalcDescr(FFT1_o);
        if isfield(ALLDESC_s,'STFTmag'),
            ALLDESC_s.STFTmag=[ALLDESC_s.STFTmag,cDescr(STFTmag)];
        else,
            ALLDESC_s.STFTmag=cDescr(STFTmag);
        end;
    end
    
    if( do_s.b_STFTpow )
    	% === STFT Representation power-scale
    	fprintf(1, 'Descriptors based on STFTpow\n');
    	config_s.STFTpow.w_DistType	= 'pow'; % other config. args. will take defaults
    	FFT2_o					= cFFTRep(Snd_o, config_s.STFTpow);
%    	ALLDESC_s.STFTpow_raw	= FFT2_o;
    	STFTpow		= FCalcDescr(FFT2_o);
        if isfield(ALLDESC_s,'STFTpow'),
            ALLDESC_s.STFTpow=[ALLDESC_s.STFTpow,cDescr(STFTpow)];
        else,
            ALLDESC_s.STFTpow=cDescr(STFTpow);
        end;
    end;
    
    if( do_s.b_Harmonic )
    	% === Sinusoidal Harmonic Model Representation
    	fprintf(1, 'Descriptors based on Harmonic\n');
        Harm_o                  = cHarmRep(Snd_o, config_s.Harmonic);
%    	ALLDESC_s.Harmonic_raw	= Harm_o;
    	Harmonic		= FCalcDescr(Harm_o);
        if isfield(ALLDESC_s,'Harmonic'),
            ALLDESC_s.Harmonic=[ALLDESC_s.Harmonic,cDescr(Harmonic)];
        else,
            ALLDESC_s.Harmonic=cDescr(Harmonic);
        end;
    end
    
    % === Equivalent Rectangular Bandwidth (ERB) Representation
    if( do_s.b_ERBfft )
    	% === ERB power spectrum using fft method
    	fprintf(1, 'Descriptors based on ERBfft\n');
    	config_s.ERBfft.w_Method	= 'fft';
    	config_s.ERBfft.f_Exp		= 1/4'; % partial loudness exponent (0.25 from Hartmann97)
    	ERB1_o					= cERBRep(Snd_o, config_s.ERBfft);
%    	ALLDESC_s.ERBfft_raw 	= ERB1_o;
    	ERBfft 		= FCalcDescr(ERB1_o);
        if isfield(ALLDESC_s,'ERBfft'),
            ALLDESC_s.ERBfft=[ALLDESC_s.ERBfft,cDescr(ERBfft)];
        else,
            ALLDESC_s.ERBfft=cDescr(ERBfft);
        end;
    end
    
    if( do_s.b_ERBgam )
    	% === ERB power spectrum using gammatone filterbank method
    	fprintf(1, 'Descriptors based on ERBgam\n');
    	config_s.ERBgam.w_Method	= 'gammatone';
    	config_s.ERBgam.f_Exp		= 1/4'; % partial loudness exponent (0.25 from Hartmann97)
    	ERB2_o					= cERBRep(Snd_o, config_s.ERBgam);
%    	ALLDESC_s.ERBgam_raw 	= ERB2_o;
    	ERBgam 		= FCalcDescr(ERB2_o);
        if isfield(ALLDESC_s,'ERBgam'),
            ALLDESC_s.ERBgam=[ALLDESC_s.ERBgam,cDescr(ERBgam)];
        else,
            ALLDESC_s.ERBgam=cDescr(ERBgam);
        end;
    end
flds=fields(ALLDESC_s);
for k=1:length(flds),
    ALLDESC_s.(flds{k})=struct(ALLDESC_s.(flds{k}));
end;

end
