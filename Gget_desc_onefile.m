function [ALLDESC_s,ALLREP_s] = Gget_desc_onefile(AUDIOFILENAME, ...
                                        do_s, config_s, b_normalized)
% GGET_DESC_ONEFILE
% =================
% performs descriptor computation
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
% b_normalized  - If 1, values that have units of frequency are given in
%                 the range [0,1]. 1 corresponding to the sampling rate.
%                 Otherwise they are given in units of Hz. If not supplied,
%                 the default is that these values are not normalized.
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

if (nargin() < 4)
    b_normalized=0;
end

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

if (b_normalized ~= 1)
    ALLDESC_s=Gdesc_make_freq_hz(ALLDESC_s,Snd_o);
end
