function [ALLDESC_s,ALLREP_s] = Gget_desc_onefile_do_by_chunks(AUDIOFILENAME,...
                                    do_s, config_s, i_ChunkSize, b_normalized)
% GGET_DESC_ONEFILE_DO_BY_CHUNKS
% ==============================
% Performs descriptor computation. This function is best used for long files as
% it reads subsections of the file from disc to make the computation of the
% descriptors possible with limited memory. The downside of this is that 
% descriptors that compute global metrics for an entire sound are no longer
% valid as they are only being shown a subsection of the sound.
%
% INPUTS:
% =======
% AUDIOFILENAME - A path to the soundfile. If MATLAB cannot find it, add its
%                 folder to the search path or specify an absolute path.  The
%                 number of samples, sample datatype, sample rate and number of
%                 channels in the file must be specified in the config_s.SOUND
%                 structure with the field names "i_Samples", "w_Format",
%                 "f_Fs", and "i_Channels" respectively.
% do_s          - A structure containing the fields b_TEE, b_STFTmag, b_STFTpow,
%                 b_Harmonic, b_ERBfft, b_ERBgam. If you would like their
%                 descriptors to be computed, give these fields the value 1,
%                 otherwise give them the value 0.
% config_s      - A structure containing the fields SOUND, TEE, STFTmag,
%                 STFTpow, Harmonic, ERBfft, and ERBgam. These fields contain
%                 structures configuring how to analyse the the sound to compute
%                 the descriptors. See the FCalcDescr function files for each
%                 descriptor to see what parameters are available. These fields
%                 are allowed to contain empty structures.  In that case their
%                 fields are given default values. The only exception is the
%                 SOUND structure when a raw file is being read. See cSound.m
%                 for what fields must be specified.
% i_ChunkSize   - The number of samples to be read each time the disk is
%                 accessed.
% b_normalized  - If 1, values that have units of frequency are given in
%                 the range [0,1]. 1 corresponding to the sampling rate.
%                 Otherwise they are given in units of Hz. If not supplied,
%                 the default is that these values are not normalized.
%                 
%
% OUTPUTS:
% ========
% ALLDESC_s     - A structure containing the fields
%                   - TEE
%                   - AS
%                   - STFTmag
%                   - STFTpow
%                   - Harmonic
%                   - ERBfft
%                   - ERBgam
%               - Each field's value is a structure containing fields relevant
%               to the description implied by the name. There are generally two
%               kinds of descriptor generating algorithms: one computes a value
%               based on the analysis of a whole soundfile. We will call these
%               "global descriptors". Others compute a
%               series of values where each value is computed from a (usually
%               windowed) frame consisting of a subsection of the soundfile, we
%               will call these "time-varying descriptors".
%               In the case of a soundfile analysed in chunks, there are
%               actually two levels of frames. The larger frames consist of the
%               samples that are read in from disk, usually in the 10s to 100s
%               of thousounds of samples. The smaller frames are chosen by each
%               descriptor's analysis algorithm based on the parameters such as
%               "window size" or "overlap" and are usually in the 100s to 1000s
%               of samples. So a number of smaller frames usually fit into a
%               large frame. The results of the analysis on a large frame are
%               concatenated with those of the last large frame. For all
%               descriptors (TODO: except for ERB), some values from the last
%               large frames are "doctored" so that small frames falling at the
%               beginning or end of the large frame always have samples to use
%               for computation (except at the beginning or end of the
%               soundfile, of course). In this way, time-varying descriptors
%               computed "in chunks" do not differ from those computed from an
%               entire soundfile read into memory from disk. However, global
%               descriptors computed from chunks of soundfile do differ from
%               those computed from an entire soundfile. Probably the global
%               descriptors whose computation is managed with this function are
%               not admissable metrics.  Nevertheless, they are computed and
%               concatenated with the descriptor computed from the last large
%               frame. One will see in some fields of the strucutres containing
%               global descriptors (e.g., TEE) arrays of values for global
%               descriptors. Above is an explanation why.
%
% ALLREP_s      - A structure containing the fields:
%                   - STFTmag
%                        whose value is cFFTRep
%                   - STFTpow
%                       whose value is cFFTRep
%                   - Harmonic
%                       whose value is cHarmRep
%                   - ERBfft
%                       whose value is cERBRep
%                   - ERBgam
%                       whose value is cERBRep
%
%               These values are objects containing analysis data which was used
%               to compute the descriptors above. See the .m file of each class
%               for information on the fields it contains, or call struct() on
%               the class.
%
% Copyright (c) 2011 IRCAM/McGill, All Rights Reserved.
% Permission is only granted to use for research purposes
%

% Get file type from filename suffix.
pos_v__	   = findstr(AUDIOFILENAME, '.');
filetype = AUDIOFILENAME(pos_v__(end)+1:end);
BADFILE=0;
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
    try
        sfSizeInfo=FGetSFInfo(AUDIOFILENAME,'size');
        nSamples=sfSizeInfo(1);
        nChannels=sfSizeInfo(2);
    catch ME
        switch ME.identifier
        case 'MATLAB:audiovideo:audioinfo:NoAudio'
            BADFILE=1;
        end
    end
end

ALLDESC_s=struct();
ALLREP_s=struct();

if ~BADFILE
    
    currentSample = 1;
    if(nargin() < 4),
        i_ChunkSize=32768;
    end;
    
    if(nargin() < 5)
        b_normalized=0;
    end
    
    chunkPoint=struct('TEE',1,'STFTmag',1,'STFTpow',1,...
                'Harmonic',1,'ERBfft',1,'ERBgam',1);
    
    
    % Specify respective analysis methods for ERB.
    
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
            Snd_o = cSound(AUDIOFILENAME,config_s.SOUND);
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
        i_IncToNext=0;
        f_Pad_v=[];
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
            if isfield(ALLREP_s,'STFTmag')
                % If field already exists, pad analysis with the last chunk read in
                FFT1_o=cFFTRep(Snd_o,config_s.STFTmag,f_Pad_v);
                ALLREP_s.STFTmag=[ALLREP_s.STFTmag,FFT1_o];
            else
                FFT1_o=cFFTRep(Snd_o,config_s.STFTmag,[]);
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
            i_IncToNext=FGetIncToNext(FFT1_o);
            % Get signal so we can pad it next iteration
            f_Pad_v=FGetSignal(Snd_o);
            % The signal may be too long, trim it down to one index before the index
            % to which the chunkPoint is incremented.
            f_Pad_v=f_Pad_v(1:i_IncToNext);
            chunkPoint.STFTmag=chunkPoint.STFTmag+i_IncToNext;
        end
    end
    
    if( do_s.b_STFTpow )
        i_IncToNext=0;
        f_Pad_v=[];
        while(1)
    	    % === STFT Representation pow-scale
    	    fprintf(1, 'Descriptors based on STFTpow\n');
            rangeMin=chunkPoint.STFTpow;
            rangeMax=rangeMin+i_ChunkSize-1;
            if(rangeMax>nSamples)
                rangeMax=nSamples;
            end;
            config_s.SOUND.i_SampleRange_v=[rangeMin,rangeMax];
            Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
    	    config_s.STFTpow.w_DistType	= 'pow'; % other config. args. will take defaults
            if isfield(ALLREP_s,'STFTpow')
                % If field already exists, pad analysis with the last chunk read in
                FFT2_o=cFFTRep(Snd_o,config_s.STFTpow,f_Pad_v);
                ALLREP_s.STFTpow=[ALLREP_s.STFTpow,FFT2_o];
            else
                FFT2_o=cFFTRep(Snd_o,config_s.STFTpow,[]);
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
            i_IncToNext=FGetIncToNext(FFT2_o);
            % Get signal so we can pad it next iteration
            f_Pad_v=FGetSignal(Snd_o);
            % The signal may be too long, trim it down to one index before the index
            % to which the chunkPoint is incremented.
            f_Pad_v=f_Pad_v(1:i_IncToNext);
            chunkPoint.STFTpow=chunkPoint.STFTpow+i_IncToNext;
        end
    end
    
    if( do_s.b_Harmonic )
        i_IncToNext=0;
        f_Pad_v=[];
        while(1)
    	    % === STFT Representation pow-scale
    	    fprintf(1, 'Descriptors based on Harmonic\n');
            rangeMin=chunkPoint.Harmonic;
            rangeMax=rangeMin+i_ChunkSize-1;
            if(rangeMax>nSamples)
                rangeMax=nSamples;
            end;
            config_s.SOUND.i_SampleRange_v=[rangeMin,rangeMax];
            Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
            if isfield(ALLREP_s,'Harmonic')
                % If field already exists, pad analysis with the last chunk read in
                Harm_o=cHarmRep(Snd_o,config_s.Harmonic,f_Pad_v);
                ALLREP_s.Harmonic=[ALLREP_s.Harmonic,Harm_o];
            else
                Harm_o=cHarmRep(Snd_o,config_s.Harmonic,[]);
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
            i_IncToNext=FGetIncToNext(Harm_o);
            % Get signal so we can pad it next iteration
            f_Pad_v=FGetSignal(Snd_o);
            % The signal may be too long, trim it down to one index before the index
            % to which the chunkPoint is incremented.
            f_Pad_v=f_Pad_v(1:i_IncToNext);
            chunkPoint.Harmonic=chunkPoint.Harmonic+i_IncToNext;
        end
    end
    
    if( do_s.b_ERBfft )
        i_IncToNext=0;
        f_Pad_v=[];
        while(1)
    	    % === STFT Representation pow-scale
    	    fprintf(1, 'Descriptors based on ERBfft\n');
            rangeMin=chunkPoint.ERBfft;
            rangeMax=rangeMin+i_ChunkSize-1;
            if(rangeMax>nSamples)
                rangeMax=nSamples;
            end;
            config_s.SOUND.i_SampleRange_v=[rangeMin,rangeMax];
            Snd_o	= cSound(AUDIOFILENAME,config_s.SOUND);
            config_s.ERBfft.w_Method	= 'fft';
            if isfield(ALLREP_s,'ERBfft')
                % If field already exists, pad analysis with the last chunk read in
                ERB1_o=cERBRep(Snd_o,config_s.ERBfft,f_Pad_v);
                ALLREP_s.ERBfft=[ALLREP_s.ERBfft,ERB1_o];
            else
                ERB1_o=cERBRep(Snd_o,config_s.ERBfft,[]);
                ALLREP_s.ERBfft=ERB1_o;
            end
    	    ERBfft		= FCalcDescr(ERB1_o);
            if isfield(ALLDESC_s,'ERBfft'),
                ALLDESC_s.ERBfft=[ALLDESC_s.ERBfft,cERBDescr(ERBfft)];
            else,
                ALLDESC_s.ERBfft=cERBDescr(ERBfft);
            end;
            if rangeMax==nSamples
                break
            end
            i_IncToNext=FGetIncToNext(ERB1_o);
            % Get signal so we can pad it next iteration
            f_Pad_v=FGetSignal(Snd_o);
            % The signal may be too long, trim it down to one index before the index
            % to which the chunkPoint is incremented.
            f_Pad_v=f_Pad_v(1:i_IncToNext);
            chunkPoint.ERBfft=chunkPoint.ERBfft+i_IncToNext;
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
            if isfield(ALLREP_s,'ERBgam')
                ERB2_o = cERBRep(Snd_o, config_s.ERBgam, f_Pad_v);
                ALLREP_s.ERBgam=[ALLREP_s.ERBgam,ERB2_o];
            else
                ERB2_o = cERBRep(Snd_o, config_s.ERBgam, []);
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
            i_IncToNext=FGetIncToNext(ERB2_o);
            % Get signal so we can pad it next iteration
            f_Pad_v=FGetSignal(Snd_o);
            % The signal may be too long, trim it down to one index before the index
            % to which the chunkPoint is incremented.
            f_Pad_v=f_Pad_v(1:i_IncToNext);
            chunkPoint.ERBgam=chunkPoint.ERBgam+FGetIncToNext(ERB2_o);
        end
    end
    
    flds=fields(ALLDESC_s);
    for k=1:length(flds),
        ALLDESC_s.(flds{k})=struct(ALLDESC_s.(flds{k}));
    end;
    
    if (b_normalized ~= 1)
        ALLDESC_s=Gdesc_make_freq_hz(ALLDESC_s,Snd_o);
    end
end
