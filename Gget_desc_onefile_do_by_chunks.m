function [ALLDESC_s,ALLREP_s] = ...
    Gget_desc_onefile_do_by_chunks(AUDIOFILENAME, do_s, config_s, i_ChunkSize)
% GGET_DESC_ONEFILE_DO_BY_CHUNKS:
% ===============================
% Performs descriptor computation. This function is best used for long files as
% it reads subsections of the file from disc to make the computation of the
% descriptors possible with limited memory. The downside of this is that 
% descriptors that compute global metrics for an entire sound are no longer
% valid as they are only being shown a subsection of the sound.
%
% INPUTS:
% =======
% AUDIOFILENAME - A path to the soundfile. If MATLAB cannot find it, add its
%                 folder to the search path or specify an absolute path.
% do_s          - A structure containing the fields b_TEE, b_STFTmag, b_STFTpow,
%                 b_Harmonic, b_ERBfft, b_ERBgam. If you would like their
%                 descriptors to be computed, give these fields the value 1,
%                 otherwise give them the value 0.
% config_s      - A structure containing the fields SOUND, TEE, STFTmag,
%                 STFTpow, Harmonic, ERBfft, and ERBgam. These fields contain
%                 structures configuring how to analyse the the sound to compute
%                 the descriptors. See the FCalcDescr function files for each
%                 descriptor to see what parameters are available. These fields
%                 are allowed to conatain empty structures. In that case their
%                 fields are given default values. The only exception is the
%                 SOUND structure when a raw file is being read. See cSound.m
%                 for what fields must be specified.
% i_ChunkSize   - The number of samples to be read each time the disk is
%                 accessed.
%                 
%
% OUTPUTS:
% ========
% - ALLDESC_s(:).family_name(:).descriptor_name(:)
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

% Get file type from filename suffix.
pos_v__	   = findstr(AUDIOFILENAME, '.');
filetype = AUDIOFILENAME(pos_v__(end)+1:end);
if strcmp(filetype,'raw')
    if ~isfield(config_s.SOUND,'i_Samples') ...
        || ~isfield(config_s.SOUND,'i_Channels')
        error(['For files of type raw, the number of samples and number of ' ...
            'channels must be specified in the configuration structure.']);
    else
        nSamples=config_s.SOUND.i_Samples;
        nChannels=config_s.SOUND.i_Channels;
    end
else
    % Get number of samples in audio file 
    sfSizeInfo=FGetSFInfo(AUDIOFILENAME,'size');
    nSamples=sfSizeInfo(1);
    nChannels=sfSizeInfo(2);
end

currentSample = 1;
if(nargin() < 4),
    i_ChunkSize=32768;
end;
chunkPoints=(1:i_ChunkSize:nSamples);
chunkPoints=chunkPoints(1:end);
chunkPoint=struct('TEE',1,'STFTmag',1,'STFTpow',1,...
            'Harmonic',1,'ERBfft',1,'ERBgam',1);

ALLDESC_s=struct();
ALLREP_s=struct();

if( do_s.b_TEE )
    while (1)
	    % === Time-domain Representation (log attack time, envelope, etc)
	    fprintf(1, 'Descriptors based on Temporal Energy Envelope / Audio Signal\n');
        rangeMin=chunkPoint.TEE;
        rangeMax=rangeMin+i_ChunkSize-1;
        if(rangeMax>nSamples)
            rangeMax=nSamples;
        end;
        config_s.SOUND.i_SampleRange_v=[rangeMin,rangeMax];
        Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
        [TEE,AS]=FCalcDescr(Snd_o,config_s.TEE);
        if isfield(ALLDESC_s,'TEE') && isfield(ALLDESC_s,'AS'),
            ALLDESC_s.TEE=[ALLDESC_s.TEE,cTEEDescr(TEE)];
            ALLDESC_s.AS=[ALLDESC_s.AS,cASDescr(AS)];
        else,
            ALLDESC_s.TEE=cTEEDescr(TEE);
            ALLDESC_s.AS=cASDescr(AS);
        end;
        if rangeMax==nSamples
            break
        end
        chunkPoint.TEE=chunkPoint.TEE+FGetIncToNext(Snd_o);
    end
end

if( do_s.b_STFTmag )
    while(1)
	    % === STFT Representation mag-scale
	    fprintf(1, 'Descriptors based on STFTmag\n');
        rangeMin=chunkPoint.STFTmag;
        rangeMax=rangeMin+i_ChunkSize-1;
        if(rangeMax>nSamples)
            rangeMax=nSamples;
        end;
        config_s.SOUND.i_SampleRange_v=[rangeMin,rangeMax];
        Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
	    config_s.STFTmag.w_DistType	= 'mag'; % other config. args. will take defaults
	    FFT1_o=cFFTRep(Snd_o,config_s.STFTmag);
        if isfield(ALLREP_s,'STFTmag')
            ALLREP_s.STFTmag=[ALLREP_s.STFTmag,FFT1_o];
        else
            ALLREP_s.STFTmag=FFT1_o;
        end
	    STFTmag		= FCalcDescr(FFT1_o);
        if isfield(ALLDESC_s,'STFTmag'),
            ALLDESC_s.STFTmag=[ALLDESC_s.STFTmag,cFFTDescr(STFTmag)];
        else,
            ALLDESC_s.STFTmag=cFFTDescr(STFTmag);
        end;
        if rangeMax==nSamples
            break
        end
        chunkPoint.STFTmag=chunkPoint.STFTmag+FGetIncToNext(FFT1_o);
    end
end

if( do_s.b_STFTpow )
    while(1)
	    % === STFT Representation power-scale
	    fprintf(1, 'Descriptors based on STFTpow\n');
        rangeMin=chunkPoint.STFTpow;
        rangeMax=rangeMin+i_ChunkSize-1;
        if(rangeMax>nSamples)
            rangeMax=nSamples;
        end;
        config_s.SOUND.i_SampleRange_v=[rangeMin,rangeMax];
        Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
	    config_s.STFTpow.w_DistType	= 'pow'; % other config. args. will take defaults
	    FFT2_o=cFFTRep(Snd_o, config_s.STFTpow);
        if isfield(ALLREP_s,'STFTpow')
            ALLREP_s.STFTpow=[ALLREP_s.STFTpow,FFT2_o];
        else
            ALLREP_s.STFTpow=FFT2_o;
        end
	    STFTpow		= FCalcDescr(FFT2_o);
        if isfield(ALLDESC_s,'STFTpow'),
            ALLDESC_s.STFTpow=[ALLDESC_s.STFTpow,cFFTDescr(STFTpow)];
        else,
            ALLDESC_s.STFTpow=cFFTDescr(STFTpow);
        end;
        if rangeMax==nSamples
            break
        end
        chunkPoint.STFTpow=chunkPoint.STFTpow+FGetIncToNext(FFT2_o);
    end
end;

if( do_s.b_Harmonic )
    while(1)
	    % === Sinusoidal Harmonic Model Representation
	    fprintf(1, 'Descriptors based on Harmonic\n');
        rangeMin=chunkPoint.Harmonic;
        rangeMax=rangeMin+i_ChunkSize-1;
        if(rangeMax>nSamples)
            rangeMax=nSamples;
        end;
        config_s.SOUND.i_SampleRange_v=[rangeMin,rangeMax];
        Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
        Harm_o                  = cHarmRep(Snd_o, config_s.Harmonic);
        if isfield(ALLREP_s,'Harmonic')
            ALLREP_s.Harmonic=[ALLREP_s.Harmonic,Harm_o];
        else
            ALLREP_s.Harmonic=Harm_o;
        end
	    Harmonic		= FCalcDescr(Harm_o);
        if isfield(ALLDESC_s,'Harmonic'),
            ALLDESC_s.Harmonic=[ALLDESC_s.Harmonic,cHarmDescr(Harmonic)];
        else,
            ALLDESC_s.Harmonic=cHarmDescr(Harmonic);
        end;
        if rangeMax==nSamples
            break
        end
        chunkPoint.Harmonic=chunkPoint.Harmonic+FGetIncToNext(Harm_o);
    end
end

% === Equivalent Rectangular Bandwidth (ERB) Representation
if( do_s.b_ERBfft )
    while(1)
	    % === ERB power spectrum using fft method
	    fprintf(1, 'Descriptors based on ERBfft\n');
        rangeMin=chunkPoint.ERBfft;
        rangeMax=rangeMin+i_ChunkSize-1;
        if(rangeMax>nSamples)
            rangeMax=nSamples;
        end;
        config_s.SOUND.i_SampleRange_v=[rangeMin,rangeMax];
        Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
	    config_s.ERBfft.w_Method	= 'fft';
	    config_s.ERBfft.f_Exp		= 1/4'; % partial loudness exponent (0.25 from Hartmann97)
	    ERB1_o                      = cERBRep(Snd_o, config_s.ERBfft);
        if isfield(ALLREP_s,'ERBfft')
            ALLREP_s.ERBfft=[ALLREP_s.ERBfft,ERB1_o];
        else
            ALLREP_s.ERBfft=ERB1_o;
        end
	    ERBfft 		= FCalcDescr(ERB1_o);
        if isfield(ALLDESC_s,'ERBfft'),
            ALLDESC_s.ERBfft=[ALLDESC_s.ERBfft,cERBDescr(ERBfft)];
        else,
            ALLDESC_s.ERBfft=cERBDescr(ERBfft);
        end;
        if rangeMax==nSamples
            break
        end
        chunkPoint.ERBfft=chunkPoint.ERBfft+FGetIncToNext(ERB1_o);
    end
end

if( do_s.b_ERBgam )
    while(1)
	    % === ERB power spectrum using gammatone filterbank method
	    fprintf(1, 'Descriptors based on ERBgam\n');
        rangeMin=chunkPoint.ERBgam;
        rangeMax=rangeMin+i_ChunkSize-1;
        if(rangeMax>nSamples)
            rangeMax=nSamples;
        end;
        config_s.SOUND.i_SampleRange_v=[rangeMin,rangeMax];
        Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
	    config_s.ERBgam.w_Method	= 'gammatone';
	    config_s.ERBgam.f_Exp		= 1/4'; % partial loudness exponent (0.25 from Hartmann97)
	    ERB2_o					= cERBRep(Snd_o, config_s.ERBgam);
        if isfield(ALLREP_s,'ERBgam')
            ALLREP_s.ERBgam=[ALLREP_s.ERBgam,ERB2_o];
        else
            ALLREP_s.ERBgam=ERB2_o;
        end
	    ERBgam 		= FCalcDescr(ERB2_o);
        if isfield(ALLDESC_s,'ERBgam'),
            ALLDESC_s.ERBgam=[ALLDESC_s.ERBgam,cERBDescr(ERBgam)];
        else,
            ALLDESC_s.ERBgam=cERBDescr(ERBgam);
        end;
        if rangeMax==nSamples
            break
        end
        chunkPoint.ERBgam=chunkPoint.ERBgam+FGetIncToNext(ERB2_o);
    end
end

flds=fields(ALLDESC_s);
for k=1:length(flds),
    ALLDESC_s.(flds{k})=struct(ALLDESC_s.(flds{k}));
end;
