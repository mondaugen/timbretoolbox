function get_descriptors_gui(fig_num,size_scalar)
% GET_DESCRIPTORS_GUI(FIG_NUM,SIZE_SCALAR)
%
% How to use:
%
%    Running:
%        The function can simply be called from the command window. The argument
%        'FIG_NUM' allows you to specify the figure number into which the GUI
%        will be drawn. The argument 'SIZE_SCALAR' allows you to scale the size
%        of the GUI elements.
%        For example:
%
%           >> get_descriptors_gui(3,1.2)
%
%        Will load the GUI and draw it in figure number 3 at 1.2 times the
%        default size. By default it is drawn in figure 1 and drawn to (almost)
%        fill the screen's width when these arguments to the function are omitted.
%        If the requested size scalar renders a GUI too big to fit within the
%        screen's horizontal dimension, it is scaled down to fit.
%
%    Configuration:
%        When the GUI loads, a default configuration file is used to populate
%        all the editable boxes. If it cannot find this file, it will report an
%        error. You can change these editable boxes as you please. Note that the
%        GUI is simply a convenient way to specify values that are passed to
%        functions that do the computation. That means that if values are
%        contradictory (e.g., a hop size in samples that does not equal the hop
%        size in seconds) or erroneous (e.g., the window type requested is not
%        supported or spelled incorrectly), these problems will not be handled
%        until the computation functions are called.  In the case of
%        contradictory values, most functions have a predefined hierarchy of
%        values (e.g., if both hop size in seconds and in samples are specified
%        the hop size in samples usually takes precident). For erroneous values,
%        the functions will report an error. You can choose to not specify a
%        value and have it be filled in with its default by simply omitting the
%        value (deleting the contents of the field). The GUI is generated from
%        the values that each function accepts, however sometimes the
%        specification of a certain value is what makes a compution unique
%        (e.g., if you specify some other 'w_Method' than 'fft' for the 'ERBfft'
%        computations, the value will be forced to be 'fft').
%
%    Choosing sound files:
%        Click the button 'Path to soundfiles...' and choose the folder in which
%        your files are contained.
%
%    Choosing the output directory:
%        Click the button 'Path to descriptors...' and choose the path where the
%        descriptors will be saved.
%
%    Saving configurations:
%        You can save the configuration you have specified to a file to be
%        recalled later. The file is simply a MATLAB data file (so it can be
%        loaded into MATLAB and edited from the command line if you wish).
%        Simply click on 'Save Configuration' and choose where you would like it
%        to be saved to.
%
%    When you have set up everything, click 'Start Analysis...' to do the analysis.

    load_default_config=1;
    sz_scalar_spec=1;
    if (nargin < 2)
        size_scalar=1;
        sz_scalar_spec=0;
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
    default_config_path='get_descriptors_gui_default_config.mat';
    guielems=[];
    left=10*size_scalar;
    bottom=10*size_scalar;
    width=75*size_scalar;
    height=15*size_scalar;
    edge_marg=2*size_scalar;
    marg=10*size_scalar;
    fontsize=8*size_scalar;
    max_n=0;
    fig=figure(fig_num);
    clf(fig);
    max_bottom=0;
    button_width=100*size_scalar;
    for fld=fields(names_s)'
        fld=char(fld);
        config_s.(fld)=eval(...
            sprintf('%s_FGetDefaultConfig',names_s.(fld)));
        uicontrol('Style','text',...
                  'Parent',fig,...
                  'String',fld,...
                  'Units','points',...
                  'Position',[left,bottom,width,height],...
                  'FontWeight','bold',...
                  'FontSize',fontsize);
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
                                'Units','points',...
                                'Position',[left_,bottom_,width,height],...
                                'FontSize',fontsize)];
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
                          'Units','points',...
                          'Position',[left_,bottom_,width,height],...
                          'String',str_,...
                          'Callback',@set_config_s_cb,...
                          'FontSize',fontsize,...
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
    disp_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Display Configuration',...
                        'Units','points',...
                        'Position',...
                            [edge_marg,max_bottom+height,button_width,height],...
                        'FontSize',fontsize,...
                        'Callback',@print_config_cb);
    load_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Load Configuration',...
                        'Units','points',...
                        'Position',...
                         [edge_marg,max_bottom+2*height,button_width,height],...
                        'FontSize',fontsize,...
                        'Callback',@load_config_cb);
    save_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Save Configuration',...
                        'Units','points',...
                        'Position',...
                         [edge_marg,max_bottom+3*height,button_width,height],...
                        'FontSize',fontsize,...
                        'Callback',@save_config_cb);
    help_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Help',...
                        'Units','points',...
                        'Position',...
                         [edge_marg,max_bottom+4*height,button_width,height],...
                        'FontSize',fontsize,...
                        'Callback',@disp_help_cb);
    sounds_path_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Path to soundfiles...',...
                        'Units','points',...
                        'Position',...
                         [edge_marg+button_width,max_bottom+height,button_width,height],...
                        'FontSize',fontsize,...
                        'Callback',@set_sounds_path_cb);
    desc_path_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Path to descriptors...',...
                        'Units','points',...
                        'Position',...
                         [edge_marg+button_width,max_bottom+2*height,button_width,height],...
                        'FontSize',fontsize,...
                        'Callback',@set_desc_path_cb);
    compute_descriptors_button = uicontrol('Style','pushbutton',...
                        'Parent',fig,...
                        'String','Start analysis...',...
                        'Units','points',...
                        'Position',...
                         [edge_marg+button_width,max_bottom+3*height,button_width,height],...
                        'FontSize',fontsize,...
                        'BackgroundColor','g',...
                        'Callback',@compute_descriptors);
    % Height adjusted here because little bits of text would show from the
    % following lines if the text didn't fit in the text box.
    sounds_path_display = uicontrol('Style','text',...
                        'Parent',fig,...
                        'String',sounds_path,...
                        'Units','points',...
                        'Position',...
                         [edge_marg+2*button_width,max_bottom+height,button_width,height-2],...
                        'FontSize',fontsize,...
                         'HorizontalAlignment','left');
    desc_path_display = uicontrol('Style','text',...
                        'Parent',fig,...
                        'String',desc_path,...
                        'Units','points',...
                        'Position',...
                         [edge_marg+2*button_width,max_bottom+2*height,button_width,height-2],...
                        'FontSize',fontsize,...
                         'HorizontalAlignment','left');

    buttons_height=5*height;
    set(fig,'Units','points');
    set(fig,'Position',[0,0,left,max_bottom+buttons_height]);

    % Check to see all elements fit on to screen
    chld=get(fig,'children');
    pos=horzcat(chld(:).Position);
    pos=reshape(pos,[length(pos)/4,4]);
    pos_ll=pos(:,1);
    pos_wi=pos(:,3);
    [ma_ll,mai_ll]=max(pos_ll);
    screen_sz=get(0,'screensize');
    % Resize if elements overflow or screen size wasn't specified
    if ((pos_ll(mai_ll)+pos_wi(mai_ll)) > screen_sz(3)) || (sz_scalar_spec==0)
        sz_scalar=screen_sz(3)/(pos_ll(mai_ll)+pos_wi(mai_ll));
        for n_=1:length(chld)
            chld(n_).Position=chld(n_).Position*sz_scalar;
            chld(n_).FontSize=chld(n_).FontSize*sz_scalar;
        end
        fig_pos=get(fig,'Position');
        set(fig,'Position',fig_pos*sz_scalar);
    end

    
    if (load_default_config)
        % Load default parameters
        s=load(default_config_path);
        config_s=s.config_s;
        for n_=1:length(guielems)
            refresh_gui_new_params(n_);
        end
    end

    function disp_help_cb(source,cbd)
        help('get_descriptors_gui');
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
        [fn,pa]=uigetfile('*.mat');
        if ([pa,fn] ~= 0)
            s=load([fn,pa]);
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
            if (isfield(config_s.(fld),fld_)==1)
                % Only load into GUI field if field present in struct
                val=config_s.(fld).(fld_);
                switch cls
                    case 'double'
                        str_=num2str(val(n));
                    otherwise
                        str_=val;
                end
            end
            % If field was present, str_ will contain its value, otherwise it
            % will be a string of length 0
            guielems(n_).String=str_;
        end
    end
    
    function save_config_cb(source,cbd)
        [fn,pa]=uiputfile('.mat');
        if (fn ~= 0)
            save([pa,fn],'config_s');
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
        if (length(source.String) == 0)
            % Remove field if value from GUI element is string of length 0
            config_s.(fld)=rmfield(config_s.(fld),fld_);
        else
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
                if ((length(fields(ALLDESC_s))>0) & (length(fields(ALLREP_s))>0))
                    ALLDESCSTATS_s=Gget_statistics(ALLDESC_s);
                    filebasename=filename(1:find(filename == '.',1,'last')-1);
                    % Save descriptors and representations to files
                    save([desc_path '/' filebasename '_desc.mat'],'ALLDESC_s');
                    save([desc_path '/' filebasename '_rep.mat'],'ALLREP_s');
                    save([desc_path '/' filebasename '_stat.mat'],'ALLDESCSTATS_s');
                    clear ALLDESCSTATS_s;
                end
                clear ALLDESC_s ALLREP_s;
            end
        end
        display('Done.');
    end

end
