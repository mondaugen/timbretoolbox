function get_descriptors_gui(fig_num)
    config_s=struct();
    names_s=struct('SOUND','cSound',...
                   'TEE','cTEERep',...
                   'STFTmag','cFFTRep',...
                   'STFTpow','cFFTRep',...
                   'Harmonic','cHarmRep',...
                   'ERBfft','cERBRep',...
                   'ERBgam','cERBRep');
    guielems=[];
    left=10;
    bottom=10;
    width=75;
    height=15;
    edge_marg=2;
    marg=10;
    max_n=0;
    fig=figure(fig_num);
    max_bottom=0;
    button_width=100;
    for fld=fields(names_s)'
        fld=char(fld);
        config_s.(fld)=eval(...
            sprintf('%s_FGetDefaultConfig',names_s.(fld)));
        uicontrol('Style','text',...
                  'Parent',fig,...
                  'String',fld,...
                  'Position',[left,bottom,width,height],...
                  'FontWeight','bold');
        bottom_=bottom+height+marg;
        flds_=filter_allowed_fields(fields(config_s.(fld)),names_s.(fld));
        for fld_=flds_'
            fld_=char(fld_);
            val=config_s.(fld).(fld_);
            left_=left;
            guielems=[guielems;
                      uicontrol('Style','text',...
                                'Parent',fig,...
                                'String',fld_,...
                                'Position',[left_,bottom_,width,height])];
            left_=left_+width;
            len=0;
            if isa(val,'char')
                % prevent making a field for every character in a string
                len=1;
            else
                len=length(val);
            end
            for n=1:len
                str_='';
                switch class(val)
                    case 'double'
                        str_=num2str(val(n));
                    otherwise
                        str_=val;
                end
                guielems=[guielems;
                          uicontrol('Style','edit',...
                          'Parent',fig,...
                          'Position',[left_,bottom_,width,height],...
                          'String',str_,...
                          'Callback',@set_config_s_cb,...
                          'UserData',{fld,fld_,n,class(val)})];
                left_=left_+width;
                if (n > max_n)
                    max_n = n;
                end
            end
            bottom_=bottom_+height;
        end
        if(bottom_ > max_bottom)
            max_bottom=bottom_;
        end
        left=left+width*(max_n+1);
        max_n=0;
    end
    set(fig,'Position',[0,0,left,max_bottom]);
    disp_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Display Configuration',...
                        'Position',...
                            [edge_marg,max_bottom-height,button_width,height],...
                        'Callback',@print_config_cb);
    load_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Load Configuration',...
                        'Position',...
                         [edge_marg,max_bottom-2*height,button_width,height],...
                        'Callback',@load_config_cb);
    save_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Save Configuration',...
                        'Position',...
                         [edge_marg,max_bottom-3*height,button_width,height],...
                        'Callback',@save_config_cb);

    function load_config_cb(source,cbd)
        pa=uigetfile();
        if (pa ~= 0)
            s=load(pa);
            config_s=s.config_s;
            for n_=1:length(guielems)
                refresh_gui_new_params(n_);
            end
        end
    end 

    function refresh_gui_new_params(n_)
        % n_ index of guielems array
        extra=guielems(n_).UserData;
        if (length(extra) > 0)
            fld=extra{1};
            fld_=extra{2};
            n=extra{3};
            cls=extra{4};
            str_='';
            val=config_s.(fld).(fld_);
            switch cls
                case 'double'
                    str_=num2str(val(n));
                otherwise
                    str_=val;
            end
            guielems(n_).String=str_;
        end
    end
    
    function save_config_cb(source,cbd)
        pa=uiputfile('.mat');
        if (pa ~= 0)
            save(pa,'config_s');
        end
    end 

    function print_config_cb(source,cbd)
        for fld=fields(config_s)'
            fld=char(fld);
            display(config_s.(fld));
        end
    end

    function set_config_s_cb(source,cbd)
        extra=source.UserData;
        fld=extra{1};
        fld_=extra{2};
        n=extra{3};
        cls=extra{4};
        val=[];
        a_=config_s.(fld).(fld_);
        switch cls
            case 'double'
                val=str2num(source.String);
                a_(n)=val;
            otherwise
                val=source.String;
                a_=val;
        end
        config_s.(fld).(fld_)=a_;
    end

    function [result] = filter_allowed_fields(flds,rep_type)
        if strcmp(rep_type,'cFFTRep') | strcmp(rep_type,'cHarmRep')
            result={};
            n=1;
            for f=flds'
                if ~strcmp(f,'f_Win_v')
                    result{n}=char(f);
                    n=n+1;
                end
            end
            result=result';
        else
            result=flds;
        end
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
