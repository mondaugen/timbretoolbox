function get_descriptors_gui(fig_num,load_default_config)
    if (nargin < 2)
        load_default_config=1;
    end
    if (nargin < 1)
        fig_num=1;
    end
    config_s=struct();
    names_s=struct('SOUND','cSound',...
                   'TEE','cTEERep',...
                   'STFTmag','cFFTRep',...
                   'STFTpow','cFFTRep',...
                   'Harmonic','cHarmRep',...
                   'ERBfft','cERBRep',...
                   'ERBgam','cERBRep');
    sounds_path='/';
    desc_path='/';
    default_config_path='./get_descriptors_gui_default_config.mat';
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
    sounds_path_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Path to soundfiles...',...
                        'Position',...
                         [edge_marg+button_width,max_bottom-height,button_width,height],...
                        'Callback',@set_sounds_path_cb);
    desc_path_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Path to descriptors...',...
                        'Position',...
                         [edge_marg+button_width,max_bottom-2*height,button_width,height],...
                        'Callback',@set_desc_path_cb);
    compute_descriptors_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Start analysis...',...
                        'Position',...
                         [edge_marg+button_width,max_bottom-3*height,button_width,height],...
                        'BackgroundColor','g',...
                        'Callback',@compute_descriptors);
    sounds_path_display = uicontrol('Style','text',...
                        'Parent',fig,...
                        'String',sounds_path,...
                        'Position',...
                         [edge_marg+2*button_width,max_bottom-height,2*button_width,height],...
                         'HorizontalAlignment','left');
    desc_path_display = uicontrol('Style','text',...
                        'Parent',fig,...
                        'String',desc_path,...
                        'Position',...
                         [edge_marg+2*button_width,max_bottom-2*height,2*button_width,height],...
                         'HorizontalAlignment','left');
    
    if (load_default_config)
        % Load default parameters
        s=load(default_config_path);
        config_s=s.config_s;
        for n_=1:length(guielems)
            refresh_gui_new_params(n_);
        end
    end

    function set_sounds_path_cb(source,cbd)
        pa=uigetdir(sounds_path);
        if (pa ~= 0)
            sounds_path=pa;
            sounds_path_display.String=sounds_path;
        end
    end

    function set_desc_path_cb(source,cbd)
        pa=uigetdir(desc_path);
        if (pa ~= 0)
            desc_path=pa;
            desc_path_display.String=desc_path;
        end
    end

    function load_config_cb(source,cbd)
        pa=uigetfile('*.mat');
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

    function compute_descriptors(source,cbd)
        do_s = struct();
        % Specifiy field as 1 if computation should be carried out, 0 if not.
        % Here we compute all descriptors
        do_s.b_TEE = 1;
        do_s.b_STFTmag = 1;
        do_s.b_STFTpow = 1;
        do_s.b_Harmonic = 1;
        do_s.b_ERBfft = 1;
        do_s.b_ERBgam = 1;
        % get names of files in directory
        filenames=dir(sounds_path);
        for n_=(1:length(filenames))
            if (filenames(n_).isdir == 0)
                filename=filenames(n_).name;
                % Compute descriptors and representations
                [ALLDESC_s, ALLREP_s] = Gget_desc_onefile_do_by_chunks(filename,do_s,config_s,131072,0);
                ALLDESCSTATS_s=Gget_statistics(ALLDESC_s);
                filebasename=filename(1:find(filename == '.',1,'last')-1);
                % Save descriptors and representations to files
                save([desc_path '/' filebasename '_desc.mat'],'ALLDESC_s');
                save([desc_path '/' filebasename '_rep.mat'],'ALLREP_s');
                save([desc_path '/' filebasename '_stat.mat'],'ALLDESCSTATS_s');
                clear ALLDESC_s ALLREP_s ALLDESCSTATS_s;
            end
        end
        display('Done.');
    end

end
