function get_descriptors_gui
    config_s=struct();
    names_s=struct('SOUND','cSound',...
                   'TEE','cTEERep',...
                   'STFTmag','cFFTRep',...
                   'STFTpow','cFFTRep',...
                   'Harmonic','cHarmRep',...
                   'ERBfft','cERBRep',...
                   'ERBgam','cERBRep');
    guielems=[];
    left=0;
    bottom=0;
    width=25;
    height=10;
    max_n=0;
    for fld=fields(names_s)'
        fld=char(fld);
        config_s.(fld)=eval(...
            sprintf('%s_FGetDefaultConfig',names_s.(fld)));
        bottom_=bottom;
        for fld_=fields(config_s.(fld))'
            fld_=char(fld_)
            val=config_s.(fld).(fld_);
            left_=left;
            guielems=[guielems;
                      uicontrol('Style','text',...
                                'String',fld_,...
                                'Position',[left_,bottom_,width,height])];
            left_=left_+width;
            for n=1:length(val)
                guielems=[guielems;
                          uicontrol('Style','edit',...
                          'Position',[left_,bottom_,width,height],...
                          'Callback',...
                            {@set_config_s_cb,{fld,fld_,n,class(val)}})];
                left_=left_+width;
                if (n > max_n)
                    max_n = n;
                end
            end
            bottom_=bottom_+height;
        end
        left=left+width*max_n;
        max_n=0;
    end
    function set_config_s_cb(source,cbd,extra)
        fld=extra{1};
        fld_=extra{2};
        n=extra{3};
        cls=extra{4};
        val=[];
        switch cls
            case 'double'
                val=str2num(source.String);
            otherwise
                val=source.String;
        end
        a_=config_s.(fld).(fld_);
        a_(n)=val;
        config_s.(fld).(fld_)=a_;
    end
end

%% This is an example of how to compute decscriptors by carrying out analyses on
%% subsections of the soundfile read off the disk. See
%% Gget_desc_onefile_do_by_chunks.m to see the pros and cons of this method.
%% To run this example, make sure the path to this file is included in the MATLAB
%% path and do
%%
%% >> run 'get_descriptors_example.m'
%%
%% In a MATLAB prompt.
%
%% Change this to the directory where your sounds are
%in_dir_name='./sounds';
%% Change this to the directory where you would like the output to go (the
%% structures saved as .mat files)
%out_dir_name='./results';
%
%disp(sprintf('Directory name: %s\n',in_dir_name));
%
%config_s = struct();
%
%% Parameters passed to function that loads sound file
%config_s.SOUND = struct();
%% The following parameters are mandatory if a raw file is read in 
%config_s.SOUND.w_Format = 'double';
%config_s.SOUND.i_Channels = 2;
%config_s.SOUND.f_Fs = 48000;
%config_s.SOUND.i_Samples = 480001;
%% To see what other parameters can be specified, see cSound.m
%
%% Parameters passed to function that computes time-domain descriptors
%config_s.TEE = struct();
%% example of how to specify parameter
%config_s.TEE.xcorr_nb_coeff = 12;
%% See @cSound/FCalcDescr.m to see parameters that can be specified.
%
%% Parameters passed to function that computes spectrogram-based descriptors
%config_s.STFTmag = struct();	
%% example of how to specify parameter
%config_s.STFTmag.i_FFTSize = 4096;
%% The parameter w_DistType will be overridden, so specifying it is futile.
%% See @cFFTRep/cFFTRep.m to see parameters that can be specified.
%
%% Parameters passed to function that computes spectrogram-based descriptors
%config_s.STFTpow = struct();	
%% example of how to specify parameter
%config_s.STFTpow.i_FFTSize = 4096;
%% The parameter w_DistType will be overridden, so specifying it is futile.
%% See @cFFTRep/cFFTRep.m to see parameters that can be specified.
%
%% Parameters passed to function that computes harmonic-analysis-based descriptors
%config_s.Harmonic = struct();
%% examples of how to specify parameter
%config_s.Harmonic.threshold_harmo = 0.2;
%config_s.Harmonic.w_WinType = 'hamming';
%% See @cHarmRep/cHarmRep.m to see parameters that can be specified.
%
%% Parameters passed to function
%config_s.ERBfft = struct();	
%% example of how to specify parameter
%config_s.ERBfft.f_Exp = 1/8;
%% The parameter w_Method will be overridden, so specifying it here is futile.
%% See @cERBRep/cERBRep.m to see parameters that can be specified.
%
%config_s.ERBgam = struct();
%% example of how to specify parameter
%config_s.ERBgam.f_Exp = 1/8;
%% The parameter w_Method will be overridden, so specifying it here is futile.
%% See @cERBRep/cERBRep.m to see parameters that can be specified.
%
%do_s = struct();
%
%% Specifiy field as 1 if computation should be carried out, 0 if not.
%% Here we compute all descriptors
%do_s.b_TEE = 1;
%do_s.b_STFTmag = 1;
%do_s.b_STFTpow = 1;
%do_s.b_Harmonic = 1;
%do_s.b_ERBfft = 1;
%do_s.b_ERBgam = 1;
%
%% get names of files in directory
%filenames=dir(in_dir_name);
%for n_=(1:length(filenames))
%    if (filenames(n_).isdir == 0)
%        filename=filenames(n_).name;
%        % Compute descriptors and representations
%        [ALLDESC_s, ALLREP_s] = Gget_desc_onefile_do_by_chunks(filename,do_s,config_s,131072,0);
%        ALLDESCSTATS_s=Gget_statistics(ALLDESC_s);
%        filebasename=filename(1:find(filename == '.',1,'last')-1);
%        % Save descriptors and representations to files
%        save([out_dir_name '/' filebasename '_desc.mat'],'ALLDESC_s');
%        save([out_dir_name '/' filebasename '_rep.mat'],'ALLREP_s');
%        save([out_dir_name '/' filebasename '_stat.mat'],'ALLDESCSTATS_s');
%        clear ALLDESC_s ALLREP_s ALLDESCSTATS_s;
%    end
%end
