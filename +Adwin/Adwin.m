classdef Adwin < handle
    % Vision class
    
    properties % GUI structures
        
        amg     % adwin main gui
        
        nbg     % new block gui
        
        iog     % init out gui
        
        iag     % init ana gui
        
        ssg     % set scans gui
        
    end
    
    properties % block sequence properties
        
        block_seq_array
        
    end
    
    properties % Sequences
        
        dig_out_init  % array containing the initial values of the digital outputs
        dig_out_cell % cell containing the digital outputs timing sequence
        
        ana_out_cell  % cell containing the analog outputs timing sequence
        ana_volt_cell % cell containing the analog outputs voltage sequence
        ana_init_cell % cell containing the initial analog outputs values
        
        dep_params_cell  % cell containing the dependent parameters names
        st_params_cell  % cell containing the static parameters names
        
        scans_params_struct % structure containing the scan parameters
        
        scan_struct
        
        scan_repeats % boolean telling if a scan includes repeats
        
        scan_repeats_nbr % number of repeats
        
    end
    
    properties % Timers
        
        adw_timer        % adwin timer
        
        pgb_timer        % progress bar timer
        
    end
    
    properties % general
        
        day
        
        month
        
        year
        
    end
    
    properties (SetObservable = true)
        
        running = 0; % boolean telling if a sequence is running
        
        seq_changed = 0; % boolean checking if there has been any modification on the sequence
        
        scanning = 0; % boolean telling if a scan is running
        
        scan_loop = 0;
        
        scan_end = 0;
        
        scan_count % number of scans during the day
        
        global_saved_count % number of saved sequence of a day
        
        seq_duration = Adwin.Default_parameters.seq_duration;
        
    end
    
    properties %Network
        
        net
        
        msg  % message containing some informations about the sequence
        
    end
    
    methods
        
        function obj = Adwin ()
            
            obj = obj@handle;
            
            obj.dig_out_init = Adwin.Default_parameters.dig_out_init;
            
            obj.dig_out_cell = cell(1,Adwin.Default_parameters.dig_crd);
            
            for l=1:Adwin.Default_parameters.dig_crd
                
                obj.dig_out_cell{l} = num2cell(Inf(1,Adwin.Default_parameters.dig_out_nbr));
                
            end
            
            obj.ana_out_cell = cell(1,Adwin.Default_parameters.ana_crd);
            
            obj.ana_volt_cell = cell(1,Adwin.Default_parameters.ana_crd);
            
            for l=1:Adwin.Default_parameters.ana_crd
                
                obj.ana_out_cell{l} = num2cell(Inf(1,Adwin.Default_parameters.ana_crd_out_nbr));
                
                obj.ana_volt_cell{l} = num2cell(zeros(1,Adwin.Default_parameters.ana_crd_out_nbr));
                
            end
            
            obj.dep_params_cell = cell(1,Adwin.Default_parameters.nb_r_dep_params*Adwin.Default_parameters.nb_c_dep_params);
            
            obj.st_params_cell = cell(1,Adwin.Default_parameters.nb_r_stat_params*Adwin.Default_parameters.nb_c_stat_params);
            
            obj.scans_params_struct = struct(...
                'scanned',num2cell(zeros(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params)), ...
                'name',cell(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params), ...
                'begin',cell(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params), ...
                'stop',cell(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params), ...
                'steps',cell(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params), ...
                'order',cell(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params), ...
                'index',num2cell(1:Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params) ...
                );
            
            obj.adw_timer = timer(...
                'Period'        ,obj.seq_duration,...
                'StopFcn'       ,@obj.adw_stop_fcn,...
                'TimerFcn'      ,@obj.adw_timer_fcn,...
                'ExecutionMode' ,'fixedSpacing'...
                );
            
            obj.pgb_timer = timer(...
                'Period'        ,Adwin.Default_parameters.pgb_duration,...
                'StartFcn'      ,@obj.pgb_timer_str,...
                'StopFcn'       ,@obj.pgb_timer_stp,...
                'TimerFcn'      ,@obj.pgb_timer_fcn,...
                'ExecutionMode' ,'fixedSpacing',...
                'TasksToExecute',floor(obj.seq_duration/Adwin.Default_parameters.pgb_duration) ...
                );
            
            % Initialize Matlab for communication with ADwin
            ADwin_Init()
            
            disp('Initialize Matlab for communication with ADwin !');
            
            % Load operating system for the T11 processor
            ret_val = Boot('C:\ADwin\ADwin11.btl',0);
            
            if isequal(ret_val,8000)
                
                disp('Adwin boot process OK !');
                
            else
                
                errnum = Get_Last_Error();
                pErrText = Get_Last_Error_Text(errnum);
                disp(['Error booting Adwin - ',pErrText]);
                
            end
            
            % Load Processes
            
            ret_val = Load_Process([Adwin.Default_parameters.root_path,'adwin_processes\Init_Outputs.TB1']);
            
            if isequal(ret_val,1)
                
                disp('Process 1 loaded into ADwin !');
                
            else
                
                errnum = Get_Last_Error();
                pErrText = Get_Last_Error_Text(errnum);
                disp(['Error loading Process 1 into ADwin - ',pErrText]);
                
            end
            
            ret_val = Load_Process([Adwin.Default_parameters.root_path,'adwin_processes\Manage_Sequences.TB2']);
            
            if isequal(ret_val,1)
                
                disp('Process 2 loaded into ADwin !')
                
            else
                
                errnum = Get_Last_Error();
                pErrText = Get_Last_Error_Text(errnum);
                disp(['Error loading Process 2 into ADwin - ',pErrText]);
                
            end
            
            % Initialize Outputs
            
            ret_val = Start_Process(1);
            
            if ~isequal(ret_val,255)
                
                disp('Start Process 1 Success !')
                disp('!! Digital outputs initialized !!');
                
            else
                
                errnum = Get_Last_Error();
                pErrText = Get_Last_Error_Text(errnum);
                disp(['Error Start Process 1 - ',pErrText]);
                
            end
            
            % Get the time resolution of the process
            
            evalin('base','Adwin_time_resol = Get_Processdelay(2)*10/3*1e-6;');
            
            % initialize listeners
            
            addlistener(obj,'seq_changed','PostSet',@obj.postset_seq_changed);
            
            addlistener(obj,'scanning','PostSet',@obj.postset_scanning);
            
            addlistener(obj,'scan_loop','PostSet',@obj.postset_scan_loop);
            
            addlistener(obj,'scan_end','PostSet',@obj.postset_scan_end);
            
            addlistener(obj,'scan_count','PostSet',@obj.postset_scan_count);
            
            addlistener(obj,'global_saved_count','PostSet',@obj.postset_global_saved_count);
            
            addlistener(obj,'seq_duration','PostSet',@obj.postset_seq_duration);
            
            addlistener(obj,'running','PostSet',@obj.postset_running);
            
            % set date and create date folder
            
            cur_date = clock;
            
            obj.year = num2str(cur_date(1));
            
            if (cur_date(2)<10)
                
                obj.month = ['0',num2str(cur_date(2))];
                
            else
                
                obj.month = num2str(cur_date(2));
                
            end
            
            if (cur_date(3)<10)
                
                obj.day = ['0',num2str(cur_date(3))];
                
            else
                
                obj.day = num2str(cur_date(3));
                
            end
            
            year_dir = [Adwin.Default_parameters.data_root_path,...
                obj.year];
            
            if ~isdir(year_dir)
                
                mkdir(year_dir);
                
            end
            
            month_dir = [Adwin.Default_parameters.data_root_path,...
                obj.year,'\',obj.month];
            
            if ~isdir(month_dir)
                
                mkdir(month_dir);
                
            end
            
            day_dir = [Adwin.Default_parameters.data_root_path,...
                obj.year,'\',obj.month,'\',obj.day];
            
            if ~isdir(day_dir)
                
                mkdir(day_dir);
                
            end
            
            %%% set scan count and saved sequence count
            
            % scan directory
            
            scan_dir = [Adwin.Default_parameters.data_root_path,...
                obj.year,'\',obj.month,'\',obj.day,'\','scans'];
            
            if isdir(scan_dir)
                
                listing = dir(scan_dir);
                
                obj.scan_count = length(listing)-2;
                
            else
                
                obj.scan_count = 0;
                
            end
            
            % saved sequence directory
            
            seq_dir = [Adwin.Default_parameters.data_root_path,...
                obj.year,'\',obj.month,'\',obj.day,'\','sequences'];
            
            if isdir(seq_dir)
                
                listing = dir(seq_dir);
                
                obj.global_saved_count = length(listing)-2;
                
            else
                
                obj.global_saved_count = 0;
                
            end
            
            % create Network class
            
            obj.net = Network.Network(obj);
            
        end
        
        function adwin_main_gui(obj)
            
            % initialize Vision GUI
            
            obj.amg.h = figure(...
                'Name'                ,'Adwin Main' ...
                ,'NumberTitle'        ,'off' ...
                ,'Position'           ,[8 48 1904 950] ... %,'MenuBar'     ,'none'...
                );
            
            %%% Block sequence panel %%%
            
            obj.amg.hsp1 = uipanel(...
                'Parent'              ,obj.amg.h ...
                ,'Title'              ,'Blocks sequence' ...
                ,'TitlePosition'      ,'lefttop' ...
                ,'BackgroundColor'    ,Adwin.Default_parameters.Panel_BackgroundColor ...
                ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                ,'FontSize'           ,Adwin.Default_parameters.Panel_FontSize ...
                ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                ,'Position'           ,[0.0025 0.86 0.995 0.13] ...
                );
            
            for i=1:length(obj.block_seq_array)
                
                temp = obj.block_seq_array(i);
                
                eval(['obj.amg.but',num2str(i),' = uicontrol(', ...
                    '''Parent''               ,obj.amg.hsp1', ...
                    ',''Style''               ,''pushbutton''', ...
                    ',''String''              ,obj.block_seq_array(i).name', ...
                    ',''FontName''            ,Adwin.Default_parameters.Pushbutton_FontName', ...
                    ',''FontSize''            ,Adwin.Default_parameters.Pushbutton_FontSize', ...
                    ',''FontUnits''           ,Adwin.Default_parameters.Pushbutton_FontUnits', ...
                    ',''FontWeight''          ,Adwin.Default_parameters.Pushbutton_FontWeight', ...
                    ',''Units''               ,Adwin.Default_parameters.Pushbutton_Units', ...
                    ',''Position''            ,[0.01+',num2str(i-1),'*(0.05+0.01) 0.075 0.05 0.85]',  ...
                    ',''Callback''            ,@temp.blk_seq_gui', ...
                    ',''ButtonDownFcn''       ,@temp.blk_seq_edit_btd_fcn', ...
                    ');']);
                
            end
            
            obj.amg.but1_1 = uicontrol(...
                'Parent'                ,obj.amg.hsp1 ...
                ,'Style'                ,'pushbutton' ...
                ,'String'               ,'add Block' ...
                ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                ,'Position'             ,[0.01+length(obj.block_seq_array)*(0.05+0.01) 0.075 0.05 0.85] ...
                ,'Callback'             ,@obj.amg_but1_1_clb ...
                );
            
            %%% Sequence management panel %%%
            
            % panel hsp2 geometry
            
            c_ofs = 0.0025;
            r_ofs = 0.72;
            c_wth = 0.495;
            r_wth = 0.13;
            
            obj.amg.hsp2 = uipanel(...
                'Parent'              ,obj.amg.h ...
                ,'Title'              ,'Sequence management' ...
                ,'TitlePosition'      ,'lefttop' ...
                ,'BackgroundColor'    ,Adwin.Default_parameters.Panel_BackgroundColor ...
                ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                ,'FontSize'           ,Adwin.Default_parameters.Panel_FontSize ...
                ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                ,'Position'           ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % pushbutton 2_1 geometry
            
            c_ofs = 2*0.01;
            r_ofs = 0.075;
            c_wth = 2*0.05;
            r_wth = 0.85;
            
            obj.amg.but2_1 = uicontrol(...
                'Parent'                ,obj.amg.hsp2 ...
                ,'Style'                ,'pushbutton' ...
                ,'String'               ,'init. Outputs' ...
                ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                ,'Callback'             ,@obj.init_out_gui ...
                );
            
            % pushbutton 2_2 geometry
            
            c_ofs = 2*0.01+2*(0.05+0.01);
            r_ofs = 0.075;
            c_wth = 2*0.05;
            r_wth = 0.85;
            
            obj.amg.but2_2 = uicontrol(...
                'Parent'                ,obj.amg.hsp2 ...
                ,'Style'                ,'pushbutton' ...
                ,'String'               ,'start Sequence' ...
                ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                ,'BackgroundColor'      ,[0.0 1.0 0.0] ...
                ,'Callback'             ,@obj.amg_but2_2_clb ...
                );
            
            % pushbutton 2_3 geometry
            
            c_ofs = 2*0.01+2*2*(0.05+0.01);
            r_ofs = 0.075;
            c_wth = 2*0.05;
            r_wth = 0.85;
            
            obj.amg.but2_3 = uicontrol(...
                'Parent'                ,obj.amg.hsp2 ...
                ,'Style'                ,'pushbutton' ...
                ,'String'               ,'reload Scripts' ...
                ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                ,'Callback'             ,@obj.amg_but2_3_clb ...
                );
            
            % pushbutton 2_4 geometry
            
            c_ofs = 2*0.01+2*3*(0.05+0.01);
            r_ofs = 0.075;
            c_wth = 2*0.05;
            r_wth = 0.85;
            
            obj.amg.but2_4 = uicontrol(...
                'Parent'                ,obj.amg.hsp2 ...
                ,'Style'                ,'pushbutton' ...
                ,'String'               ,'gener. Scripts' ...
                ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                ,'Callback'             ,@obj.amg_but2_4_clb ...
                );
            
            % pushbutton 2_5 geometry
            
            c_ofs = 2*0.01+2*4*(0.05+0.01);
            r_ofs = 0.075;
            c_wth = 2*0.05;
            r_wth = 0.85;
            
            obj.amg.but2_5 = uicontrol(...
                'Parent'                ,obj.amg.hsp2 ...
                ,'Style'                ,'pushbutton' ...
                ,'String'               ,'set Scan' ...
                ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                ,'Callback'             ,@obj.amg_but2_5_clb ...
                );
            
            % pushbutton 2_6 geometry
            
            c_ofs = 2*0.01+2*5*(0.05+0.01);
            r_ofs = 0.075;
            c_wth = 2*0.05;
            r_wth = 0.85;
            
            obj.amg.but2_6 = uicontrol(...
                'Parent'                ,obj.amg.hsp2 ...
                ,'Style'                ,'pushbutton' ...
                ,'String'               ,'start Scan' ...
                ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                ,'BackgroundColor'      ,[0.0 1.0 0.0] ...
                ,'Callback'             ,@obj.amg_but2_6_clb ...
                );
            
            % pushbutton 2_7 geometry
            
            c_ofs = 2*0.01+2*6*(0.05+0.01);
            r_ofs = 0.075;
            c_wth = 2*0.05;
            r_wth = 0.85;
            
            obj.amg.but2_7 = uicontrol(...
                'Parent'                ,obj.amg.hsp2 ...
                ,'Style'                ,'pushbutton' ...
                ,'String'               ,'sort Param.' ...
                ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                ,'Callback'             ,@obj.amg_but2_7_clb ...
                );
            
            %%% Dependent Parameters panel %%%
            
            obj.amg.hsp3 = uipanel(...
                'Parent'              ,obj.amg.h ...
                ,'Title'              ,'Dependent parameters' ...
                ,'TitlePosition'      ,'lefttop' ...
                ,'BackgroundColor'    ,Adwin.Default_parameters.Panel_BackgroundColor ...
                ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                ,'FontSize'           ,Adwin.Default_parameters.Panel_FontSize ...
                ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                ,'Position'           ,[0.0025 0.36 0.995 0.35] ...
                );
            
            for i=1:Adwin.Default_parameters.nb_c_dep_params
                
                % Panel geometry
                
                c_wth = 0.0975;
                c_ofs = (1-Adwin.Default_parameters.nb_c_dep_params*c_wth)/(Adwin.Default_parameters.nb_c_dep_params+1);
                r_wth = 0.9875;
                r_ofs = 0.0125;
                
                eval(['obj.amg.hsp3_',num2str(i),' = uipanel(', ...
                    '''Parent''                ,obj.amg.hsp3' ...
                    ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                    ',''ForegroundColor''      ,Adwin.Default_parameters.Panel_ForegroundColor', ...
                    ',''HighlightColor''       ,Adwin.Default_parameters.Panel_HighlightColor', ...
                    ',''ShadowColor''          ,Adwin.Default_parameters.Panel_ShadowColor', ...
                    ',''FontName''             ,Adwin.Default_parameters.Panel_FontName', ...
                    ',''FontSize''             ,Adwin.Default_parameters.Panel_FontSize', ...
                    ',''FontUnits''            ,Adwin.Default_parameters.Panel_FontUnits', ...
                    ',''FontWeight''           ,Adwin.Default_parameters.Panel_FontWeight', ...
                    ',''SelectionHighlight''   ,Adwin.Default_parameters.Panel_SelectionHighlight', ...
                    ',''Units''                ,Adwin.Default_parameters.Panel_Units', ...
                    ',''Position''             ,[c_ofs+(i-1)*(c_wth+c_ofs) r_ofs c_wth r_wth]', ...
                    ');']);
                
                % Text geometry
                
                c_wth = 0.16;
                c_ofs = 0.008;
                r_wth = 0.04;
                r_ofs = 0.95;
                
                eval(['obj.amg.txt_3_',num2str(i),'_1 = uicontrol(', ...
                    '''Parent''                ,obj.amg.hsp3_',num2str(i), ...
                    ',''Style''                ,''text''', ...
                    ',''String''               ,''Used''', ...
                    ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                    ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                    ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                    ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                    ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                    ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                    ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                    ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                    ');']);
                
                % Text geometry
                
                c_wth = 0.2;
                c_ofs = 0.265;
                r_wth = 0.04;
                r_ofs = 0.95;
                
                eval(['obj.amg.txt_3_',num2str(i),'_2 = uicontrol(', ...
                    '''Parent''                ,obj.amg.hsp3_',num2str(i), ...
                    ',''Style''                ,''text''', ...
                    ',''String''               ,''Name''', ...
                    ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                    ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                    ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                    ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                    ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                    ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                    ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                    ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                    ');']);
                
                % Text geometry
                
                c_wth = 0.2;
                c_ofs = 0.7;
                r_wth = 0.04;
                r_ofs = 0.95;
                
                eval(['obj.amg.txt_3_',num2str(i),'_3 = uicontrol(', ...
                    '''Parent''                ,obj.amg.hsp3_',num2str(i), ...
                    ',''Style''                ,''text''', ...
                    ',''String''               ,''Value''', ...
                    ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                    ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                    ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                    ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                    ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                    ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                    ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                    ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                    ');']);
                
                for j=1:Adwin.Default_parameters.nb_r_dep_params
                    
                    % Checkbox geometry
                    
                    c_wth = 0.1;
                    c_ofs = 0.02;
                    r_wth = 0.04;
                    r_ofs = (1-(Adwin.Default_parameters.nb_r_dep_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_dep_params+2);
                    
                    eval(['obj.amg.ckb_3_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                        '''Parent''                ,obj.amg.hsp3_',num2str(i), ...
                        ',''Style''                ,''checkbox''', ...
                        ',''Units''                ,Adwin.Default_parameters.Checkbox_Units', ...
                        ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                        ',''Tag''                 ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                        ',''Callback''             ,@obj.amg_ckb_3_clb', ...
                        ');']);
                    
                    if ~isempty(obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})
                        
                        eval(['set(obj.amg.ckb_3_',num2str(i),'_',num2str(j), ...
                            ',''Value''               ,1', ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.ckb_3_',num2str(i),'_',num2str(j), ...
                            ',''Value''               ,0', ...
                            ');']);
                        
                    end
                    
                    % edit parameter name
                    
                    c_wth = 0.425;
                    c_ofs = 0.15;
                    r_wth = 0.055;
                    r_ofs = (1-(Adwin.Default_parameters.nb_r_dep_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_dep_params+2);
                    
                    eval(['obj.amg.edt_3_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                        '''Parent''                ,obj.amg.hsp3_',num2str(i), ...
                        ',''Style''                ,''edit''', ...
                        ',''FontName''             ,Adwin.Default_parameters.Edit_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Edit_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Edit_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Edit_FontWeight', ...
                        ',''HorizontalAlignment''  ,Adwin.Default_parameters.Edit_HorizontalAlignment', ...
                        ',''Units''                ,Adwin.Default_parameters.Edit_Units', ...
                        ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                        ',''Tag''                 ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                        ',''Callback''             ,@obj.amg_edt_3_clb', ...
                        ');']);
                    
                    if ~isempty(obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})
                        
                        eval(['set(obj.amg.edt_3_',num2str(i),'_',num2str(j), ...
                            ',''String''               ,''',obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j},'''', ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.edt_3_',num2str(i),'_',num2str(j), ...
                            ',''String''               ,[''unused'']', ...
                            ',''Enable''               ,''off''', ...
                            ');']);
                        
                    end
                    
                    % text parameter value
                    
                    % Panel geometry
                    
                    c_wth = 0.425;
                    c_ofs = 0.575;
                    r_wth = 0.055;
                    r_ofs = (1-(Adwin.Default_parameters.nb_r_dep_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_dep_params+2);
                    
                    eval(['obj.amg.hsp3_',num2str(i),'_',num2str(j),' = uipanel(', ...
                        '''Parent''                ,obj.amg.hsp3_',num2str(i), ...
                        ',''BackgroundColor''      ,Adwin.Default_parameters.Panel_BackgroundColor', ...
                        ',''ForegroundColor''      ,Adwin.Default_parameters.Panel_ForegroundColor', ...
                        ',''HighlightColor''       ,Adwin.Default_parameters.Panel_HighlightColor', ...
                        ',''ShadowColor''          ,Adwin.Default_parameters.Panel_ShadowColor', ...
                        ',''FontName''             ,Adwin.Default_parameters.Panel_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Panel_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Panel_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Panel_FontWeight', ...
                        ',''SelectionHighlight''   ,Adwin.Default_parameters.Panel_SelectionHighlight', ...
                        ',''Units''                ,Adwin.Default_parameters.Panel_Units', ...
                        ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                        ');']);
                    
                    c_wth = 1;
                    c_ofs = 0;
                    r_wth = 1;
                    r_ofs = 0;
                    
                    eval(['obj.amg.txt_3_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                        '''Parent''                ,obj.amg.hsp3_',num2str(i),'_',num2str(j), ...
                        ',''Style''                ,''text''', ...
                        ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                        ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                        ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                        ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                        ',''Tag''                  ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                        ');']);
                    
                    if ~isequal(sum(strcmp(evalin('base','who'),obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})),0)
                        
                        eval(['set(obj.amg.txt_3_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,',num2str(evalin('base',obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})) ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.txt_3_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,0' ...
                            ',''Enable''               ,''off''', ...
                            ');']);
                        
                    end
                    
                end
            end
            
            %%% Static Parameters panel %%%
            
            obj.amg.hsp4 = uipanel(...
                'Parent'              ,obj.amg.h ...
                ,'Title'              ,'Static parameters' ...
                ,'TitlePosition'      ,'lefttop' ...
                ,'BackgroundColor'    ,Adwin.Default_parameters.Panel_BackgroundColor ...
                ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                ,'FontSize'           ,Adwin.Default_parameters.Panel_FontSize ...
                ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                ,'Position'           ,[0.0025 0.0025 0.995 0.35] ...
                );
            
            for i=1:Adwin.Default_parameters.nb_c_stat_params
                
                % Panel geometry
                
                c_wth = 0.0975;
                c_ofs = (1-Adwin.Default_parameters.nb_c_stat_params*c_wth)/(Adwin.Default_parameters.nb_c_stat_params+1);
                r_wth = 0.9875;
                r_ofs = 0.0125;
                
                eval(['obj.amg.hsp4_',num2str(i),' = uipanel(', ...
                    '''Parent''                ,obj.amg.hsp4' ...
                    ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                    ',''ForegroundColor''      ,Adwin.Default_parameters.Panel_ForegroundColor', ...
                    ',''HighlightColor''       ,Adwin.Default_parameters.Panel_HighlightColor', ...
                    ',''ShadowColor''          ,Adwin.Default_parameters.Panel_ShadowColor', ...
                    ',''FontName''             ,Adwin.Default_parameters.Panel_FontName', ...
                    ',''FontSize''             ,Adwin.Default_parameters.Panel_FontSize', ...
                    ',''FontUnits''            ,Adwin.Default_parameters.Panel_FontUnits', ...
                    ',''FontWeight''           ,Adwin.Default_parameters.Panel_FontWeight', ...
                    ',''SelectionHighlight''   ,Adwin.Default_parameters.Panel_SelectionHighlight', ...
                    ',''Units''                ,Adwin.Default_parameters.Panel_Units', ...
                    ',''Position''             ,[c_ofs+(i-1)*(c_wth+c_ofs) r_ofs c_wth r_wth]', ...
                    ');']);
                
                % Text geometry
                
                c_wth = 0.16;
                c_ofs = 0.008;
                r_wth = 0.04;
                r_ofs = 0.95;
                
                eval(['obj.amg.txt_4_',num2str(i),'_1 = uicontrol(', ...
                    '''Parent''                ,obj.amg.hsp4_',num2str(i), ...
                    ',''Style''                ,''text''', ...
                    ',''String''               ,''Used''', ...
                    ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                    ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                    ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                    ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                    ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                    ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                    ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                    ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                    ');']);
                
                % Text geometry
                
                c_wth = 0.2;
                c_ofs = 0.265;
                r_wth = 0.04;
                r_ofs = 0.95;
                
                eval(['obj.amg.txt_4_',num2str(i),'_2 = uicontrol(', ...
                    '''Parent''                ,obj.amg.hsp4_',num2str(i), ...
                    ',''Style''                ,''text''', ...
                    ',''String''               ,''Name''', ...
                    ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                    ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                    ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                    ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                    ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                    ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                    ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                    ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                    ');']);
                
                % Text geometry
                
                c_wth = 0.2;
                c_ofs = 0.7;
                r_wth = 0.04;
                r_ofs = 0.95;
                
                eval(['obj.amg.txt_4_',num2str(i),'_3 = uicontrol(', ...
                    '''Parent''                ,obj.amg.hsp4_',num2str(i), ...
                    ',''Style''                ,''text''', ...
                    ',''String''               ,''Value''', ...
                    ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                    ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                    ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                    ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                    ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                    ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                    ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                    ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                    ');']);
                
                
                for j=1:Adwin.Default_parameters.nb_r_stat_params
                    
                    % Checkbox geometry
                    
                    c_wth = 0.1;
                    c_ofs = 0.02;
                    r_wth = 0.04;
                    r_ofs = (1-(Adwin.Default_parameters.nb_r_stat_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_stat_params+2);
                    
                    eval(['obj.amg.ckb_4_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                        '''Parent''                ,obj.amg.hsp4_',num2str(i), ...
                        ',''Style''                ,''checkbox''', ...
                        ',''Units''                ,Adwin.Default_parameters.Checkbox_Units', ...
                        ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                        ',''Tag''                 ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                        ',''Callback''             ,@obj.amg_ckb_4_clb', ...
                        ');']);
                    
                    if ~isempty(obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j})
                        
                        eval(['set(obj.amg.ckb_4_',num2str(i),'_',num2str(j), ...
                            ',''Value''               ,1', ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.ckb_4_',num2str(i),'_',num2str(j), ...
                            ',''Value''               ,0', ...
                            ');']);
                        
                    end
                    
                    % edit parameter name
                    
                    c_wth = 0.425;
                    c_ofs = 0.15;
                    r_wth = 0.055;
                    r_ofs = (1-(Adwin.Default_parameters.nb_r_stat_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_stat_params+2);
                    
                    eval(['obj.amg.edt_4_1_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                        '''Parent''                ,obj.amg.hsp4_',num2str(i), ...
                        ',''Style''                ,''edit''', ...
                        ',''FontName''             ,Adwin.Default_parameters.Edit_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Edit_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Edit_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Edit_FontWeight', ...
                        ',''HorizontalAlignment''  ,Adwin.Default_parameters.Edit_HorizontalAlignment', ...
                        ',''Units''                ,Adwin.Default_parameters.Edit_Units', ...
                        ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                        ',''Tag''                 ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                        ',''Callback''             ,@obj.amg_edt_4_1_clb', ...
                        ');']);
                    
                    if ~isempty(obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j})
                        
                        eval(['set(obj.amg.edt_4_1_',num2str(i),'_',num2str(j), ...
                            ',''String''               ,''',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j},'''', ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.edt_4_1_',num2str(i),'_',num2str(j), ...
                            ',''String''               ,[''unused'']', ...
                            ',''Enable''               ,''off''', ...
                            ');']);
                        
                    end
                    
                    % edit parameter value
                    
                    c_wth = 0.425;
                    c_ofs = 0.575;
                    r_wth = 0.055;
                    r_ofs = (1-(Adwin.Default_parameters.nb_r_stat_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_stat_params+2);
                    
                    eval(['obj.amg.edt_4_2_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                        '''Parent''                ,obj.amg.hsp4_',num2str(i), ...
                        ',''Style''                ,''edit''', ...
                        ',''FontName''             ,Adwin.Default_parameters.Edit_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Edit_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Edit_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Edit_FontWeight', ...
                        ',''HorizontalAlignment''  ,Adwin.Default_parameters.Edit_HorizontalAlignment', ...
                        ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                        ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                        ',''Tag''                  ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                        ',''Callback''             ,@obj.amg_edt_4_2_clb', ...
                        ');']);
                    
                    if ~isequal(sum(strcmp(evalin('base','who'),obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j})),0)
                        
                        eval(['set(obj.amg.edt_4_2_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,',num2str(evalin('base',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j})) ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.edt_4_2_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,0' ...
                            ',''Enable''               ,''off''', ...
                            ');']);
                        
                    end
                    
                    
                    
                end
            end
            
            %%% Sequence info panel %%%
            
            % panel hsp5 geometry
            
            c_ofs = 0.5+0.0025;
            r_ofs = 0.72;
            c_wth = 0.495;
            r_wth = 0.13;
            
            obj.amg.hsp5 = uipanel(...
                'Parent'              ,obj.amg.h ...
                ,'Title'              ,'Sequence info' ...
                ,'TitlePosition'      ,'lefttop' ...
                ,'BackgroundColor'    ,[0.7 0.7 0.7] ...
                ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                ,'FontSize'           ,Adwin.Default_parameters.Panel_FontSize ...
                ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                ,'Position'           ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % panel hsp5_1 geometry
            
            c_ofs = 0.0025;
            r_ofs = 0.0125;
            c_wth = 0.495;
            r_wth = 0.975;
            
            obj.amg.hsp5_1 = uipanel(...
                'Parent'              ,obj.amg.hsp5 ...
                ,'Title'              ,'General' ...
                ,'TitlePosition'      ,'lefttop' ...
                ,'BackgroundColor'    ,Adwin.Default_parameters.Panel_BackgroundColor ...
                ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                ,'FontSize'           ,10 ...
                ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                ,'Position'           ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_1 geometry
            
            c_ofs = 0.01;
            r_ofs = 0.75;
            c_wth = 0.2;
            r_wth = 0.2;
            
            obj.amg.txt5_1_1 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Saved Count' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_2 geometry
            
            c_ofs = 0.01+0.2+0.01;
            r_ofs = 0.75;
            c_wth = 0.05;
            r_wth = 0.2;
            
            obj.amg.txt5_1_2 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,num2str(obj.global_saved_count) ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_3 geometry
            
            c_ofs = 0.5;
            r_ofs = 0.75;
            c_wth = 0.1;
            r_wth = 0.2;
            
            obj.amg.txt5_1_3 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Date' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_4 geometry
            
            c_ofs = 0.5+0.1+0.01;
            r_ofs = 0.75;
            c_wth = 0.15;
            r_wth = 0.2;
            
            obj.amg.txt5_1_4 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,[obj.day,'-',obj.month,'-',obj.year] ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_5 geometry
            
            c_ofs = 0.01;
            r_ofs = 0.5;
            c_wth = 0.2;
            r_wth = 0.2;
            
            obj.amg.txt5_1_5 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Time resolution' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_6 geometry
            
            c_ofs = 0.01+0.2+0.01;
            r_ofs = 0.5;
            c_wth = 0.1;
            r_wth = 0.2;
            
            obj.amg.txt5_1_6 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,[num2str(evalin('base','Adwin_time_resol')*1000),' \mus']  ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_7 geometry
            
            c_ofs = 0.01;
            r_ofs = 0.25;
            c_wth = 0.2;
            r_wth = 0.2;
            
            obj.amg.txt5_1_7 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Cycle duration' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text edt5_1_1 geometry
            
            c_ofs = 0.01+0.2+0.01;
            r_ofs = 0.285;
            c_wth = 0.05;
            r_wth = 0.2;
            
            obj.amg.edt5_1_1 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'edit' ...
                ,'String'               ,num2str(obj.seq_duration) ...
                ,'Units'                ,Adwin.Default_parameters.Edit_Units ...
                ,'FontName'             ,Adwin.Default_parameters.Edit_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Edit_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Edit_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,Adwin.Default_parameters.Edit_HorizontalAlignment ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                ,'Callback'             ,@obj.amg_edt5_1_1_clb ...
                );
            
            % text txt5_1_8 geometry
            
            c_ofs = 0.01+0.2+0.01+0.06;
            r_ofs = 0.25;
            c_wth = 0.02;
            r_wth = 0.2;
            
            obj.amg.txt5_1_8 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'s'  ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_9 geometry
            
            c_ofs = 0.01;
            r_ofs = 0.;
            c_wth = 0.2;
            r_wth = 0.2;
            
            obj.amg.txt5_1_9 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Seq. duration' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_10 geometry
            
            c_ofs = 0.01+0.2+0.01;
            r_ofs = 0.;
            c_wth = 0.11;
            r_wth = 0.2;
            
            obj.amg.txt5_1_10 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'0 s'  ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_11 geometry
            
            c_ofs = 0.5;
            r_ofs = 0.5;
            c_wth = 0.2;
            r_wth = 0.2;
            
            obj.amg.txt5_1_11 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Save sequence' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % checkbox ckb5_1 geometry
            
            c_ofs = 0.5+0.2+0.01;
            r_ofs = 0.53;
            c_wth = 0.03;
            r_wth = 0.18;
            
            obj.amg.ckb5_1 = uicontrol(...
                'Parent'               ,obj.amg.hsp5_1 ...
                ,'Style'                ,'checkbox' ...
                ,'Units'                ,Adwin.Default_parameters.Checkbox_Units ...
                ,'Value'                , 0 ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_1_12 geometry
            
            c_ofs = 0.5;
            r_ofs = 0.25;
            c_wth = 0.2;
            r_wth = 0.2;
            
            obj.amg.txt5_1_12 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Progress status' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % panel hsp5_1_0 geometry
            
            c_ofs = 0.5;
            r_ofs = 0.025;
            c_wth = 0.495;
            r_wth = 0.2;
            
            obj.amg.hsp5_1_0 = uipanel(...
                'Parent'              ,obj.amg.hsp5_1 ...
                ,'BackgroundColor'    ,[1. 1. 1.] ...
                ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                ,'FontSize'           ,10 ...
                ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                ,'Position'           ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % panel hsp5_1_0_0 geometry
            
            c_ofs = 0.;
            r_ofs = 0.;
            c_wth = 0.01;
            r_wth = 1.;
            
            obj.amg.hsp5_1_0_0 = uipanel(...
                'Parent'              ,obj.amg.hsp5_1_0 ...
                ,'BackgroundColor'    ,[0. 0. 1.] ...
                ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                ,'FontSize'           ,10 ...
                ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                ,'Position'           ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            %%% panel hsp5_2 geometry
            
            c_ofs = 0.5+0.0025;
            r_ofs = 0.0125;
            c_wth = 0.495;
            r_wth = 0.975;
            
            obj.amg.hsp5_2 = uipanel(...
                'Parent'              ,obj.amg.hsp5 ...
                ,'Title'              ,'Scans' ...
                ,'TitlePosition'      ,'lefttop' ...
                ,'BackgroundColor'    ,Adwin.Default_parameters.Panel_BackgroundColor ...
                ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                ,'FontSize'           ,10 ...
                ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                ,'Position'           ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_1 geometry
            
            c_ofs = 0.01;
            r_ofs = 0.5;
            c_wth = 0.1;
            r_wth = 0.2;
            
            obj.amg.txt5_2_1 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Loop...' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_2 geometry
            
            c_ofs = 0.01+0.1+0.01;
            r_ofs = 0.5;
            c_wth = 0.05;
            r_wth = 0.2;
            
            obj.amg.txt5_2_2 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,num2str(obj.scan_loop) ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_3 geometry
            
            c_ofs = 0.01+(0.1+0.01)+(0.05+0.01);
            r_ofs = 0.5;
            c_wth = 0.15;
            r_wth = 0.2;
            
            obj.amg.txt5_2_3 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'... out of ...' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_4 geometry
            
            c_ofs = 0.01+(0.1+0.01)+(0.05+0.01)+(0.15+0.01);
            r_ofs = 0.5;
            c_wth = 0.05;
            r_wth = 0.2;
            
            obj.amg.txt5_2_4 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,num2str(obj.scan_end) ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_5 geometry
            
            c_ofs = 0.01;
            r_ofs = 0.25;
            c_wth = 0.3;
            r_wth = 0.2;
            
            obj.amg.txt5_2_5 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Remaining duration' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_6 geometry
            
            c_ofs = 0.01+0.3+0.01;
            r_ofs = 0.25;
            c_wth = 0.15;
            r_wth = 0.2;
            
            obj.amg.txt5_2_6 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'0h:0min:0s' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_7 geometry
            
            c_ofs = 0.01;
            r_ofs = 0.0;
            c_wth = 0.3;
            r_wth = 0.2;
            
            obj.amg.txt5_2_7 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Total duration' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_8 geometry
            
            c_ofs = 0.01+0.3+0.01;
            r_ofs = 0.0;
            c_wth = 0.15;
            r_wth = 0.2;
            
            obj.amg.txt5_2_8 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'0h:0min:0s' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_9 geometry
            
            c_ofs = 0.01;
            r_ofs = 0.75;
            c_wth = 0.1;
            r_wth = 0.2;
            
            obj.amg.txt5_2_9 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Count' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_10 geometry
            
            c_ofs = 0.01+0.1+0.01;
            r_ofs = 0.75;
            c_wth = 0.05;
            r_wth = 0.2;
            
            obj.amg.txt5_2_10 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,num2str(obj.scan_count) ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,'normal' ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text txt5_2_11 geometry
            
            c_ofs = 0.5;
            r_ofs = 0.75;
            c_wth = 0.2;
            r_wth = 0.2;
            
            obj.amg.txt5_2_11 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Set repeats' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % checkbox ckb5_2 geometry
            
            c_ofs = 0.686;
            r_ofs = 0.78;
            c_wth = 0.03;
            r_wth = 0.18;
            
            obj.amg.ckb5_2 = uicontrol(...
                'Parent'               ,obj.amg.hsp5_2 ...
                ,'Style'                ,'checkbox' ...
                ,'Units'                ,Adwin.Default_parameters.Checkbox_Units ...
                ,'Value'                , 0 ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                ,'Callback'             ,@obj.amg_ckb5_2_clb ...
                );
            
            if ~isempty(obj.scan_repeats)
                
                set(obj.amg.ckb5_2,'Value',obj.scan_repeats)
                
            else
                
                set(obj.amg.ckb5_2,'Value',0)
                
                obj.scan_repeats = 0;
                
            end
            
            % text txt5_2_12 geometry
            
            c_ofs = 0.5;
            r_ofs = 0.5;
            c_wth = 0.2;
            r_wth = 0.2;
            
            obj.amg.txt5_2_12 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Repeats #' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,'left' ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                );
            
            % text edt5_2_1 geometry
            
            c_ofs = 0.675;
            r_ofs = 0.525;
            c_wth = 0.06;
            r_wth = 0.2;
            
            obj.amg.edt5_2_1 = uicontrol(...
                'Parent'                ,obj.amg.hsp5_2 ...
                ,'Style'                ,'edit' ...
                ,'Units'                ,Adwin.Default_parameters.Edit_Units ...
                ,'Position'             ,[c_ofs r_ofs c_wth r_wth] ...
                ,'Callback'             ,@obj.amg_edt5_2_1_clb ...
                ,'Enable'               ,'off' ...
                );
            
            if ~isempty(obj.scan_repeats_nbr)
                
                set(obj.amg.edt5_2_1,'String',obj.scan_repeats_nbr)
                
            else
                
                set(obj.amg.edt5_2_1,'String','1')
                
                obj.scan_repeats_nbr = 1;
                
            end
            
        end
        
        function amg_ckb_3_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            i=str2double(split_tag{2});
            j=str2double(split_tag{3});
            
            val = eval(['get(obj.amg.ckb_3_',num2str(i),'_',num2str(j),',''Value'')']);
            
            switch val
                
                case 1
                    
                    eval(['set(obj.amg.edt_3_',num2str(i),'_',num2str(j), ...
                        ',''Enable''               ,''on''', ...
                        ');']);
                    
                    eval(['set(obj.amg.txt_3_',num2str(i),'_',num2str(j), ...
                        ',''Enable''               ,''on''', ...
                        ');']);
                    
                case 0
                    
                    eval(['set(obj.amg.edt_3_',num2str(i),'_',num2str(j), ...
                        ',''Enable''               ,''off''', ...
                        ',''String''               ,''unused''', ...
                        ');']);
                    
                    eval(['set(obj.amg.txt_3_',num2str(i),'_',num2str(j), ...
                        ',''Enable''               ,''off''', ...
                        ',''String''               ,''0''', ...
                        ');']);
                    
                    evalin('base',['clear ',obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j},';']);
                    
                    obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j} = [];
                    
            end
            
        end
        
        function amg_edt_3_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            i=str2double(split_tag{2});
            j=str2double(split_tag{3});
            
            if ~isequal(sum(strcmp(evalin('base','who'),obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})),0)
                
                evalin('base',['clear ',obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j},';']);
                
            end
            
            obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j}=eval(['get(obj.amg.edt_3_',num2str(i),'_',num2str(j),',''String'')']);
            
            evalin('base','dependent_parameters_script;');
            
            if ~isequal(sum(strcmp(evalin('base','who'),obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})),0)
                
                eval(['set(obj.amg.txt_3_',num2str(i),'_',num2str(j),',', ...
                    '''String''                ,',num2str(evalin('base',obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})) ...
                    ');']);
                
            end
            
        end
        
        function amg_ckb_4_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            i=str2double(split_tag{2});
            j=str2double(split_tag{3});
            
            val = eval(['get(obj.amg.ckb_4_',num2str(i),'_',num2str(j),',''Value'')']);
            
            switch val
                
                case 1
                    
                    eval(['set(obj.amg.edt_4_1_',num2str(i),'_',num2str(j), ...
                        ',''Enable''               ,''on''', ...
                        ');']);
                    
                    eval(['set(obj.amg.edt_4_2_',num2str(i),'_',num2str(j), ...
                        ',''Enable''               ,''on''', ...
                        ');']);
                    
                case 0
                    
                    eval(['set(obj.amg.edt_4_1_',num2str(i),'_',num2str(j), ...
                        ',''Enable''               ,''off''', ...
                        ',''String''               ,''unused''', ...
                        ');']);
                    
                    eval(['set(obj.amg.edt_4_2_',num2str(i),'_',num2str(j), ...
                        ',''Enable''               ,''off''', ...
                        ',''String''               ,''0''', ...
                        ');']);
                    
                    evalin('base',['clear ',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j},';']);
                    
                    obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j} = [];
                    
            end
            
        end
        
        function amg_edt_4_1_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            i=str2double(split_tag{2});
            j=str2double(split_tag{3});
            
            if ~isequal(sum(strcmp(evalin('base','who'),obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j})),0)
                
                evalin('base',['clear ',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j},';']);
                
            end
            
            obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j}=eval(['get(obj.amg.edt_4_1_',num2str(i),'_',num2str(j),',''String'')']);
            
            str=eval(['get(obj.amg.edt_4_2_',num2str(i),'_',num2str(j),',''String'')']);
            
            evalin('base',[obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j},'=',str,';']);
            
            obj.seq_changed = 1;
            
            obj.reset_all_formulas;
            
        end
        
        function amg_edt_4_2_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            i=str2double(split_tag{2});
            j=str2double(split_tag{3});
            
            str=eval(['get(obj.amg.edt_4_2_',num2str(i),'_',num2str(j),',''String'')']);
            
            evalin('base',[obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j},'=',str,';']);
            
            obj.seq_changed = 1;
            
            obj.reset_all_formulas;
            
        end
        
        function amg_but1_1_clb(obj,~,~)
            
            if ~isempty(obj.block_seq_array)
                
                obj.block_seq_array(end+1) = Adwin.Block;
                
                obj.block_seq_array(end-1).next = obj.block_seq_array(end);
                
                obj.block_seq_array(end).parent_adwin = obj;
                
                for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr
                    
                    obj.block_seq_array(end).dig_out_struct(i).timings_array(1).state = obj.block_seq_array(end-1).dig_out_struct(i).timings_array(end).state;
                    
                end
                
            else
                
                obj.block_seq_array = Adwin.Block;
                
                obj.block_seq_array(end).parent_adwin = obj;
                
                for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr
                    
                    obj.block_seq_array(end).dig_out_struct(i).timings_array(1).state =  Adwin.Default_parameters.dig_out_init{i};
                    
                end
                
            end
            
            obj.nbg.h = figure(...
                'Name'                ,'New Block' ...
                ,'NumberTitle'        ,'off' ...
                ,'Position'           ,[200 200 200 200] ...
                ,'MenuBar'            ,'none'...
                );
            
            obj.nbg.hsp1 = uipanel(...
                'Parent'              ,obj.nbg.h ...
                ,'Title'              ,'Block Properties' ...
                ,'TitlePosition'      ,'lefttop' ...
                ,'BackgroundColor'    ,Adwin.Default_parameters.Panel_BackgroundColor ...
                ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                ,'FontSize'           ,Adwin.Default_parameters.Panel_FontSize ...
                ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                ,'Position'           ,[0.015 0.015 0.97 0.97] ...
                );
            
            obj.nbg.txt1 = uicontrol(...
                'Parent'                ,obj.nbg.hsp1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Name' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[0.05 0.8 0.40 0.15] ...
                );
            
            obj.nbg.edt1 = uicontrol(...
                'Parent'                ,obj.nbg.hsp1 ...
                ,'Style'                ,'edit' ...
                ,'String'               ,'' ...
                ,'Units'                ,Adwin.Default_parameters.Edit_Units ...
                ,'Position'             ,[0.55 0.8 0.40 0.15] ...
                ,'Callback'             ,@obj.nbg_edt1_clb ...
                );
            
            obj.nbg.txt2 = uicontrol(...
                'Parent'                ,obj.nbg.hsp1 ...
                ,'Style'                ,'text' ...
                ,'String'               ,'Start Formula' ...
                ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                ,'Position'             ,[0.05 0.6 0.40 0.15] ...
                );
            
            obj.nbg.edt2 = uicontrol(...
                'Parent'                ,obj.nbg.hsp1 ...
                ,'Style'                ,'edit' ...
                ,'String'               ,'' ...
                ,'Units'                ,Adwin.Default_parameters.Edit_Units ...
                ,'Position'             ,[0.55 0.6 0.40 0.15] ...
                ,'Callback'             ,@obj.nbg_edt2_clb ...
                );
            
        end
        
        function init_out_gui(obj,~,~)
            
            %-----Initialize the digital output GUI-----%
            
            if ~isempty(obj.iog)&&ishandle(obj.iog.h)
                
                set(obj.iog.h,'Visible','on');
                
            else
                
                obj.iog.h = figure(...
                    'Name'                ,'Initialize Initial Digital Outputs Values' ...
                    ,'NumberTitle'        ,'off' ...
                    ,'Position'           ,[8 48 400 950] ... %,'MenuBar'     ,'none'...
                    );
                
                obj.iog.tab = uitabgroup(...
                    'Parent'              ,obj.iog.h ...
                    ,'TabLocation'        ,'top' ...
                    ,'Units'              ,Adwin.Default_parameters.Tab_Units ...
                    ,'Position'           ,[0.015 0.015 0.67 0.97] ...
                    );
                
                for l=1:Adwin.Default_parameters.dig_crd % go through adwin digital cards
                    
                    eval(['obj.iog.tab_',num2str(l),' = uitab(', ...
                        '''Parent''              ,obj.iog.tab', ...
                        ',''BackgroundColor''    ,Adwin.Default_parameters.Tab_BackgroundColor', ...
                        ',''ForegroundColor''    ,Adwin.Default_parameters.Tab_ForegroundColor', ...
                        ',''Title''              ,''Digital Card ',num2str(l),'''', ...
                        ',''Units''              ,Adwin.Default_parameters.Tab_Units', ...
                        ');']);
                    
                    for i=1:Adwin.Default_parameters.dig_out_nbr
                        
                        eval(['obj.iog.hsp_',num2str(l),'_',num2str(i),' = uipanel(', ...
                            '''Parent''              ,obj.iog.tab_',num2str(l), ...
                            ',''BackgroundColor''    ,Adwin.Default_parameters.Panel_BackgroundColor', ...
                            ',''ForegroundColor''    ,Adwin.Default_parameters.Panel_ForegroundColor', ...
                            ',''HighlightColor''     ,Adwin.Default_parameters.Panel_HighlightColor', ...
                            ',''ShadowColor''        ,Adwin.Default_parameters.Panel_ShadowColor', ...
                            ',''FontName''           ,Adwin.Default_parameters.Panel_FontName', ...
                            ',''FontSize''           ,Adwin.Default_parameters.Panel_FontSize', ...
                            ',''FontUnits''          ,Adwin.Default_parameters.Panel_FontUnits', ...
                            ',''FontWeight''         ,Adwin.Default_parameters.Panel_FontWeight', ...
                            ',''SelectionHighlight'' ,Adwin.Default_parameters.Panel_SelectionHighlight', ...
                            ',''Units''              ,Adwin.Default_parameters.Panel_Units', ...
                            ',''Position''           ,[0.0025 0.0025+(i-1)*((1-33*0.0025)/32+0.0025) 0.95 (1-33*0.0025)/32]', ...
                            ');']);
                        
                        eval(['obj.iog.txt_',num2str(l),'_',num2str(i),' = uicontrol(', ...
                            '''Parent''                ,obj.iog.hsp_',num2str(l),'_',num2str(i), ...
                            ',''Style''                ,''text''', ...
                            ',''String''               ,Adwin.Default_parameters.dig_out_name(i+(l-1)*Adwin.Default_parameters.dig_out_nbr)', ...
                            ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                            ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                            ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                            ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                            ',''HorizontalAlignment''  ,''left''', ...
                            ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                            ',''Position''             ,[0.0025 0.2 0.7 0.6]', ...
                            ');']);
                        
                        eval(['obj.iog.hsp2_',num2str(l),'_',num2str(i),' = uipanel(', ...
                            '''Parent''              ,obj.iog.hsp_',num2str(l),'_',num2str(i), ...
                            ',''BackgroundColor''    ,Adwin.Default_parameters.Panel_BackgroundColor', ...
                            ',''ForegroundColor''    ,Adwin.Default_parameters.Panel_ForegroundColor', ...
                            ',''HighlightColor''     ,Adwin.Default_parameters.Panel_HighlightColor', ...
                            ',''ShadowColor''        ,Adwin.Default_parameters.Panel_ShadowColor', ...
                            ',''FontName''           ,Adwin.Default_parameters.Panel_FontName', ...
                            ',''FontSize''           ,Adwin.Default_parameters.Panel_FontSize', ...
                            ',''FontUnits''          ,Adwin.Default_parameters.Panel_FontUnits', ...
                            ',''FontWeight''         ,Adwin.Default_parameters.Panel_FontWeight', ...
                            ',''SelectionHighlight'' ,Adwin.Default_parameters.Panel_SelectionHighlight', ...
                            ',''Units''              ,Adwin.Default_parameters.Panel_Units', ...
                            ',''Position''           ,[0.7 0.0025 0.25 0.995]', ...
                            ');']);
                        
                        
                        eval(['obj.iog.edit',num2str(l),'_',num2str(i),' = uicontrol(', ...
                            '''Parent''               ,obj.iog.hsp2_',num2str(l),'_',num2str(i), ...
                            ',''Style''               ,''edit''', ...
                            ',''String''              ,num2str(obj.dig_out_init{i+(l-1)*Adwin.Default_parameters.dig_out_nbr})', ...
                            ',''ForegroundColor''     ,[0,0,0]', ...
                            ',''Units''               ,Adwin.Default_parameters.Edit_Units', ...
                            ',''Position''            ,[0. 0.0 1.0 1.0]',  ...
                            ',''Callback''            ,@obj.iog_edit_clb', ...
                            ',''Tag''                 ,','''tag_',num2str(l),'_',num2str(i),'''', ...
                            ');']);
                        
                        switch obj.dig_out_init{i+(l-1)*Adwin.Default_parameters.dig_out_nbr}
                            
                            case 1
                                
                                eval(['set(obj.iog.hsp2_',num2str(l),'_',num2str(i), ...
                                    ',''HighlightColor''               ,[0.0 1.0 0.0]', ...
                                    ');']);
                                
                            case 0
                                
                                eval(['set(obj.iog.hsp2_',num2str(l),'_',num2str(i), ...
                                    ',''HighlightColor''               ,[1.0 0.0 0.0]', ...
                                    ');']);
                                
                        end
                        
                    end
                    
                end
                
                obj.iog.hsp3 = uipanel(...
                    'Parent'              ,obj.iog.h ...
                    ,'BackgroundColor'    ,Adwin.Default_parameters.Panel_BackgroundColor ...
                    ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                    ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                    ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                    ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                    ,'FontSize'           ,Adwin.Default_parameters.Panel_FontSize ...
                    ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                    ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                    ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                    ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                    ,'Position'           ,[0.67+0.015 0.015 0.3 0.97] ...
                    );
                
                
                obj.iog.but = uicontrol(...
                    'Parent'                ,obj.iog.hsp3 ...
                    ,'Style'                ,'pushbutton' ...
                    ,'String'               ,'set Outputs' ...
                    ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                    ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                    ,'Position'             ,[0.15 0.9 0.7 0.09] ...
                    ,'Callback'             ,@obj.iog_but_clb ...
                    );
                
                obj.iog.but2 = uicontrol(...
                    'Parent'                ,obj.iog.hsp3 ...
                    ,'Style'                ,'pushbutton' ...
                    ,'String'               ,'reset Outputs' ...
                    ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                    ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                    ,'Position'             ,[0.15 0.78 0.7 0.09] ...
                    ,'Callback'             ,@obj.iog_but2_clb ...
                    );
                
            end
            
            %-----Initialize the analog output GUI-----%
            
            if ~isempty(obj.iag)&&ishandle(obj.iag.h)
                
                set(obj.iag.h,'Visible','on');
                
            else
                
                obj.iag.h = figure(...
                    'Name'                ,'Initialize Initial Analog Outputs Values' ...
                    ,'NumberTitle'        ,'off' ...
                    ,'Position'           ,[420 48 400 950] ... %,'MenuBar'     ,'none'...
                    );
                
                obj.iag.tab = uitabgroup(...
                    'Parent'              ,obj.iag.h ...
                    ,'TabLocation'        ,'top' ...
                    ,'Units'              ,Adwin.Default_parameters.Tab_Units ...
                    ,'Position'           ,[0.015 0.015 0.67 0.97] ...
                    );
                
                obj.ana_init_cell = cell(1,Adwin.Default_parameters.ana_crd);
                
                for l=1:Adwin.Default_parameters.ana_crd % go through adwin analog cards
                    
                    obj.ana_init_cell{l} = num2cell(zeros(1,Adwin.Default_parameters.ana_crd_out_nbr));
                    
                    eval(['obj.iag.tab_',num2str(l),' = uitab(', ...
                        '''Parent''              ,obj.iag.tab', ...
                        ',''BackgroundColor''    ,Adwin.Default_parameters.Tab_BackgroundColor', ...
                        ',''ForegroundColor''    ,Adwin.Default_parameters.Tab_ForegroundColor', ...
                        ',''Title''              ,''Analog Card ',num2str(l),'''', ...
                        ',''Units''              ,Adwin.Default_parameters.Tab_Units', ...
                        ');']);
                    
                    
                    for j=1:length(obj.ana_volt_cell{l}) % go through each outputs of each card
                        
                        if ~isempty(obj.block_seq_array)
                            
                            obj.ana_init_cell{l}{j} = obj.block_seq_array(1).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(1).value;
                            
                        else
                            
                            obj.ana_init_cell{l}{j} = Adwin.Default_parameters.ana_out_init{j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr};
                            
                        end
                        
                        eval(['obj.ana_volt_cell{l}{j} =  max(min(round(Adwin.Calibrations.ana_out_',num2str(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr),'(obj.ana_init_cell{l}{j})/(10/2^15))+2^15,2^16-1),0);']);
                        
                        eval(['obj.iag.hsp_',num2str(l),'_',num2str(j),' = uipanel(', ...
                            '''Parent''              ,obj.iag.tab_',num2str(l), ...
                            ',''BackgroundColor''    ,Adwin.Default_parameters.Panel_BackgroundColor', ...
                            ',''ForegroundColor''    ,Adwin.Default_parameters.Panel_ForegroundColor', ...
                            ',''HighlightColor''     ,Adwin.Default_parameters.Panel_HighlightColor', ...
                            ',''ShadowColor''        ,Adwin.Default_parameters.Panel_ShadowColor', ...
                            ',''FontName''           ,Adwin.Default_parameters.Panel_FontName', ...
                            ',''FontSize''           ,Adwin.Default_parameters.Panel_FontSize', ...
                            ',''FontUnits''          ,Adwin.Default_parameters.Panel_FontUnits', ...
                            ',''FontWeight''         ,Adwin.Default_parameters.Panel_FontWeight', ...
                            ',''SelectionHighlight'' ,Adwin.Default_parameters.Panel_SelectionHighlight', ...
                            ',''Units''              ,Adwin.Default_parameters.Panel_Units', ...
                            ',''Position''           ,[0.025 0.025+(j-1)*((1-9*0.025)/8+0.025) 0.95 (1-9*0.025)/8]', ...
                            ');']);
                        
                        eval(['obj.iag.txt_',num2str(l),'_',num2str(j),' = uicontrol(', ...
                            '''Parent''                ,obj.iag.hsp_',num2str(l),'_',num2str(j), ...
                            ',''Style''                ,''text''', ...
                            ',''String''               ,Adwin.Default_parameters.ana_out_name(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr)', ...
                            ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                            ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                            ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                            ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                            ',''HorizontalAlignment''  ,''left''', ...
                            ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                            ',''Position''             ,[0.025 0.15 0.7 0.425]', ...
                            ');']);
                        
                        eval(['obj.iag.hsp2_',num2str(l),'_',num2str(j),' = uipanel(', ...
                            '''Parent''              ,obj.iag.hsp_',num2str(l),'_',num2str(j), ...
                            ',''BackgroundColor''    ,Adwin.Default_parameters.Panel_BackgroundColor', ...
                            ',''ForegroundColor''    ,Adwin.Default_parameters.Panel_ForegroundColor', ...
                            ',''HighlightColor''     ,Adwin.Default_parameters.Panel_HighlightColor', ...
                            ',''ShadowColor''        ,Adwin.Default_parameters.Panel_ShadowColor', ...
                            ',''FontName''           ,Adwin.Default_parameters.Panel_FontName', ...
                            ',''FontSize''           ,Adwin.Default_parameters.Panel_FontSize', ...
                            ',''FontUnits''          ,Adwin.Default_parameters.Panel_FontUnits', ...
                            ',''FontWeight''         ,Adwin.Default_parameters.Panel_FontWeight', ...
                            ',''SelectionHighlight'' ,Adwin.Default_parameters.Panel_SelectionHighlight', ...
                            ',''Units''              ,Adwin.Default_parameters.Panel_Units', ...
                            ',''Position''           ,[0.75 0.3 0.2 0.4]', ...
                            ');']);
                        
                        
                        eval(['obj.iag.edit',num2str(l),'_',num2str(j),' = uicontrol(', ...
                            '''Parent''               ,obj.iag.hsp2_',num2str(l),'_',num2str(j), ...
                            ',''Style''               ,''edit''', ...
                            ',''String''              ,num2str(obj.ana_init_cell{l}{j})', ...
                            ',''ForegroundColor''     ,[0,0,0]', ...
                            ',''Units''               ,Adwin.Default_parameters.Edit_Units', ...
                            ',''Position''            ,[0. 0.0 1.0 1.0]',  ...
                            ',''Callback''            ,@obj.iag_edit_clb', ...
                            ',''Tag''                 ,','''tag_',num2str(l),'_',num2str(j),'''', ...
                            ');']);
                        
                    end
                    
                end
                
                obj.iag.hsp3 = uipanel(...
                    'Parent'              ,obj.iag.h ...
                    ,'BackgroundColor'    ,Adwin.Default_parameters.Panel_BackgroundColor ...
                    ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                    ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                    ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                    ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                    ,'FontSize'           ,Adwin.Default_parameters.Panel_FontSize ...
                    ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                    ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                    ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                    ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                    ,'Position'           ,[0.67+0.015 0.015 0.3 0.97] ...
                    );
                
                
                obj.iag.but = uicontrol(...
                    'Parent'                ,obj.iag.hsp3 ...
                    ,'Style'                ,'pushbutton' ...
                    ,'String'               ,'set Outputs' ...
                    ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                    ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                    ,'Position'             ,[0.15 0.9 0.7 0.09] ...
                    ,'Callback'             ,@obj.iag_but_clb ...
                    );
                
                obj.iag.but2 = uicontrol(...
                    'Parent'                ,obj.iag.hsp3 ...
                    ,'Style'                ,'pushbutton' ...
                    ,'String'               ,'reset Outputs' ...
                    ,'FontName'             ,Adwin.Default_parameters.Pushbutton_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Pushbutton_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Pushbutton_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Pushbutton_FontWeight ...
                    ,'Units'                ,Adwin.Default_parameters.Pushbutton_Units ...
                    ,'Position'             ,[0.15 0.78 0.7 0.09] ...
                    ,'Callback'             ,@obj.iag_but2_clb ...
                    );
                
            end
            
            obj.seq_changed = 1;
            
        end
        
        function iog_edit_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            l=str2double(split_tag{2});
            
            i=str2double(split_tag{3});
            
            obj.dig_out_init{i+(l-1)*Adwin.Default_parameters.dig_out_nbr}=str2double(get(gcbo,'String'));
            
            switch obj.dig_out_init{i+(l-1)*Adwin.Default_parameters.dig_out_nbr}
                
                case 1
                    
                    eval(['set(obj.iog.hsp2_',num2str(l),'_',num2str(i), ...
                        ',''HighlightColor''               ,[0.0 1.0 0.0]', ...
                        ');']);
                    
                case 0
                    
                    eval(['set(obj.iog.hsp2_',num2str(l),'_',num2str(i), ...
                        ',''HighlightColor''               ,[1.0 0.0 0.0]', ...
                        ');']);
                    
            end
            
            if ~isempty(obj.block_seq_array)
                
                obj.block_seq_array(1).dig_out_struct(i+(l-1)*Adwin.Default_parameters.dig_out_nbr).timings_array(1).state = obj.dig_out_init{i+(l-1)*Adwin.Default_parameters.dig_out_nbr};
                
            end
            
        end
        
        function iog_but_clb(obj,~,~)
            
            if ~obj.running
                
                for l=1:Adwin.Default_parameters.dig_crd % go through adwin digital cards
                    
                    adw_out = 0; % initial digital outputs state
                    
                    for i=1:(Adwin.Default_parameters.dig_out_nbr-1)
                        
                        adw_out=adw_out+obj.dig_out_init{i+(l-1)*Adwin.Default_parameters.dig_out_nbr}*2^(i-1);
                        
                    end
                    
                    if isequal(obj.dig_out_init{Adwin.Default_parameters.dig_out_nbr+(l-1)*Adwin.Default_parameters.dig_out_nbr},1)
                        
                        adw_out=adw_out-2^(Adwin.Default_parameters.dig_out_nbr-1);
                        
                    end
                    
                    SetData_Double(Adwin.Default_parameters.dig_data_out_array(l),int32(adw_out),1);
                    
                end
                
                Start_Process(1);
                
                obj.seq_changed = 1;
                
                disp('!! Re-initialize the digital outputs !!');
                
            end
            
        end
        
        function iog_but2_clb(obj,~,~)
            
            if ~obj.running
                
                obj.dig_out_init = Adwin.Default_parameters.dig_out_init;
                
                for l=1:Adwin.Default_parameters.dig_crd % go through adwin digital cards
                    
                    adw_out = 0; % initial digital outputs state
                    
                    for i=1:(Adwin.Default_parameters.dig_out_nbr-1)
                        
                        adw_out=adw_out+obj.dig_out_init{i+(l-1)*Adwin.Default_parameters.dig_out_nbr}*2^(i-1);
                        
                        eval(['set(obj.iog.edit',num2str(l),'_',num2str(i), ...
                            ',''String''               ,num2str(obj.dig_out_init{i+(l-1)*Adwin.Default_parameters.dig_out_nbr})', ...
                            ');']);
                        
                        switch obj.dig_out_init{i+(l-1)*Adwin.Default_parameters.dig_out_nbr}
                            
                            case 1
                                
                                eval(['set(obj.iog.hsp2_',num2str(l),'_',num2str(i), ...
                                    ',''HighlightColor''               ,[0.0 1.0 0.0]', ...
                                    ');']);
                                
                            case 0
                                
                                eval(['set(obj.iog.hsp2_',num2str(l),'_',num2str(i), ...
                                    ',''HighlightColor''               ,[1.0 0.0 0.0]', ...
                                    ');']);
                                
                        end
                        
                        if ~isempty(obj.block_seq_array)
                            
                            obj.block_seq_array(1).dig_out_struct(i+(l-1)*Adwin.Default_parameters.dig_out_nbr).timings_array(1).state = obj.dig_out_init{i+(l-1)*Adwin.Default_parameters.dig_out_nbr};
                            
                        end
                        
                    end
                    
                    if ~isempty(obj.block_seq_array)
                        
                        obj.block_seq_array(1).dig_out_struct(Adwin.Default_parameters.dig_out_nbr+(l-1)*Adwin.Default_parameters.dig_out_nbr).timings_array(1).state = obj.dig_out_init{Adwin.Default_parameters.dig_out_nbr+(l-1)*Adwin.Default_parameters.dig_out_nbr};
                        
                    end
                    
                    eval(['set(obj.iog.edit',num2str(l),'_',num2str(Adwin.Default_parameters.dig_out_nbr), ...
                        ',''String''               ,num2str(obj.dig_out_init{Adwin.Default_parameters.dig_out_nbr+(l-1)*Adwin.Default_parameters.dig_out_nbr})', ...
                        ');']);
                    
                    switch obj.dig_out_init{Adwin.Default_parameters.dig_out_nbr+(l-1)*Adwin.Default_parameters.dig_out_nbr}
                        
                        case 1
                            
                            eval(['set(obj.iog.hsp2_',num2str(l),'_',num2str(Adwin.Default_parameters.dig_out_nbr), ...
                                ',''HighlightColor''               ,[0.0 1.0 0.0]', ...
                                ');']);
                            
                        case 0
                            
                            eval(['set(obj.iog.hsp2_',num2str(l),'_',num2str(Adwin.Default_parameters.dig_out_nbr), ...
                                ',''HighlightColor''               ,[1.0 0.0 0.0]', ...
                                ');']);
                            
                    end
                    
                    if isequal(obj.dig_out_init{Adwin.Default_parameters.dig_out_nbr+(l-1)*Adwin.Default_parameters.dig_out_nbr},1)
                        
                        adw_out=adw_out-2^(Adwin.Default_parameters.dig_out_nbr-1);
                        
                    end
                    
                    SetData_Double(Adwin.Default_parameters.dig_data_out_array(l),int32(adw_out),1);
                    
                end
                
                Start_Process(1);
                
                obj.seq_changed = 1;
                
                disp('!! Re-initialize the digital outputs !!');
                
            end
            
        end
        
        function iag_edit_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            l=str2double(split_tag{2});
            
            j=str2double(split_tag{3});
            
            obj.ana_init_cell{l}{j}=str2double(get(gcbo,'String'));
            
            eval(['obj.ana_volt_cell{l}{j} =  max(min(round(Adwin.Calibrations.ana_out_',num2str(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr),'(obj.ana_init_cell{l}{j})/(10/2^15))+2^15,2^16-1),0);']);
            
        end
        
        function iag_but_clb(obj,~,~)
            
            if ~obj.running
                
                adw_ana_out_seq = cell(1,Adwin.Default_parameters.ana_crd); % analog outputs state sequence
                
                for l=1:Adwin.Default_parameters.ana_crd
                    
                    adw_ana_out_seq{l} = 32768*ones(1,4*Adwin.Default_parameters.max_step_ana)-2^31;
                    
                    for i=1:(Adwin.Default_parameters.ana_crd_out_nbr/2)
                        
                        if (obj.ana_volt_cell{l}{2*i}(1)>=2^15)
                            
                            adw_ana_out_seq{l}(i) = obj.ana_volt_cell{l}{2*i-1}+mod(obj.ana_volt_cell{l}{2*i},2^15)*2^16-2^31;
                            
                        else
                            
                            adw_ana_out_seq{l}(i) = obj.ana_volt_cell{l}{2*i-1}+obj.ana_volt_cell{l}{2*i}*2^16;
                            
                        end
                        
                    end
                    
                    % Set Adwin memory
                    
                    disp(['Analog output table sent to Adwin (8 first terms) - card ',num2str(l)])
                    fprintf('%d %d %d %d %d %d %d %d \n',adw_ana_out_seq{l}(1:8));
                    disp(['Analog output table sent to Adwin (9 to 16) - card ',num2str(l)])
                    fprintf('%d %d %d %d %d %d %d %d \n \n',adw_ana_out_seq{l}(9:16));
                    
                    SetData_Double(Adwin.Default_parameters.ana_data_out_array(l),int32(adw_ana_out_seq{l}),1);
                    
                end
                
                Start_Process(1);
                
                obj.seq_changed = 1;
                
                disp('!! Re-initialize analog outputs !!');
                
            end
            
        end
        
        function iag_but2_clb(obj,~,~)
            
            %-----Re-initialize analog output voltages-----%
            
            for l=1:Adwin.Default_parameters.ana_crd % go through adwin analog cards
                
                for j=1:length(obj.ana_volt_cell{l}) % go through each outputs of each card
                    
                    if ~isempty(obj.block_seq_array)
                        
                        obj.ana_init_cell{l}{j} = obj.block_seq_array(1).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(1).value;
                        
                    else
                        
                        obj.ana_init_cell{l}{j} = Adwin.Default_parameters.ana_out_init{j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr};
                        
                    end
                    
                    eval(['obj.ana_volt_cell{l}{j} =  max(min(round(Adwin.Calibrations.ana_out_',num2str(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr),'(obj.ana_init_cell{l}{j})/(10/2^15))+2^15,2^16-1),0);']);
                    
                    eval(['set(obj.iag.edit',num2str(l),'_',num2str(j), ...
                        ',''String''               ,num2str(obj.ana_init_cell{l}{j})', ...
                        ');']);
                    
                end
                
            end
            
            %-----Update Adwin memory and set voltages-----%
            
            if ~obj.running
                
                adw_ana_out_seq = cell(1,Adwin.Default_parameters.ana_crd); % analog outputs state sequence
                
                for l=1:Adwin.Default_parameters.ana_crd
                    
                    adw_ana_out_seq{l} = 32768*ones(1,4*Adwin.Default_parameters.max_step_ana)-2^31;
                    
                    for i=1:(Adwin.Default_parameters.ana_crd_out_nbr/2)
                        
                        if (obj.ana_volt_cell{l}{2*i}(1)>=2^15)
                            
                            adw_ana_out_seq{l}(i) = obj.ana_volt_cell{l}{2*i-1}+mod(obj.ana_volt_cell{l}{2*i},2^15)*2^16-2^31;
                            
                        else
                            
                            adw_ana_out_seq{l}(i) = obj.ana_volt_cell{l}{2*i-1}+obj.ana_volt_cell{l}{2*i}*2^16;
                            
                        end
                        
                    end
                    
                    % Set Adwin memory
                    
                    disp(['Analog output table sent to Adwin (8 first terms) - card ',num2str(l)])
                    fprintf('%d %d %d %d %d %d %d %d \n',adw_ana_out_seq{l}(1:8));
                    disp(['Analog output table sent to Adwin (9 to 16) - card ',num2str(l)])
                    fprintf('%d %d %d %d %d %d %d %d \n \n',adw_ana_out_seq{l}(9:16));
                    
                    SetData_Double(Adwin.Default_parameters.ana_data_out_array(l),int32(adw_ana_out_seq{l}),1);
                    
                end
                
                Start_Process(1);
                
                obj.seq_changed = 1;
                
                disp('!! Re-initialize analog outputs !!');
                
            end
            
        end
        
        function amg_but2_2_clb(obj,~,~)
            
            switch obj.running
                
                case 0
                    
                    % initialize and start sequence
                    
                    start(obj.adw_timer);
                    
                    set(obj.amg.but2_2,'BackgroundColor',[1.0,0.0,0.0]);
                    
                    obj.running = 1;
                    
                case 1
                    
                    % stop sequence
                    
                    stop(obj.adw_timer);
                    
                    set(obj.amg.but2_2,'BackgroundColor',[0.0,1.0,0.0]);
                    
                    obj.running = 0;
                    
            end
            
        end
        
        function adw_timer_fcn(obj,~,~)
            
            if obj.running
                
                % Stop Adwin process
                
                ret_val = Stop_Process(2);
                
                if ~isequal(ret_val,255)
                    
                    disp('Stop Process 2 Success !')
                    
                else
                    
                    errnum = Get_Last_Error();
                    pErrText = Get_Last_Error_Text(errnum);
                    disp(['Error Stop Process 2 - ',pErrText])
                    
                end
                
                % Reset Scan params if Scan ended
                
                if ~isempty(obj.scan_struct)
                    
                    if obj.scan_loop == obj.scan_end
                        
                        obj.scanning = 0;
                        
                        % reset scan parameters
                        
                        obj.scan_loop = 0;
                        
                        obj.scan_end = 0;
                        
                        obj.scan_struct = [];
                        
                    end
                    
                end
                
            end
            
            if obj.scanning
                
                if (sum([obj.scans_params_struct.scanned])==0)
                    
                    disp('!!! warning : no parameter to scan !!!')
                    
                    obj.scanning = 0;
                    
                    disp('End Scan')
                    
                else
                    
                    obj.scan_loop = obj.scan_loop + 1;
                    
                    if isequal(obj.scan_loop,1)
                        
                        % increment scan count
                        
                        obj.scan_count = obj.scan_count + 1;
                        
                        disp('Initialize Scan')
                        
                        tmp_struct = obj.scans_params_struct(logical([obj.scans_params_struct.scanned]));
                        
                        obj.scan_struct = tmp_struct([tmp_struct.order]);
                        
                        if (obj.scan_repeats_nbr > 1)
                            
                            str_in = ['1:',num2str(obj.scan_repeats_nbr)];
                            
                            str_out = 'x_0';
                            
                            for i = 1:length(obj.scan_struct)
                                
                                str_in = [str_in,',linspace(',num2str(obj.scan_struct(i).begin),',',num2str(obj.scan_struct(i).stop),...
                                    ',',num2str(obj.scan_struct(i).steps),')'];
                                
                                str_out = [str_out,',x_',num2str(i)];
                                
                            end
                            
                        else
                            
                            str_in = ['linspace(',num2str(obj.scan_struct(1).begin),',',num2str(obj.scan_struct(1).stop),...
                                ',',num2str(obj.scan_struct(1).steps),')'];
                            
                            str_out = 'x_1';
                            
                            for i = 2:length(obj.scan_struct)
                                
                                str_in = [str_in,',linspace(',num2str(obj.scan_struct(i).begin),',',num2str(obj.scan_struct(i).stop),...
                                    ',',num2str(obj.scan_struct(i).steps),')'];
                                
                                str_out = [str_out,',x_',num2str(i)];
                                
                            end
                            
                        end
                        
                        eval(['[',str_out,'] = ndgrid(',str_in,');']);
                        
                        for i=1:length(obj.scan_struct)
                            
                            eval(['obj.scan_struct(i).out_vec = x_',num2str(i),'(:);']);
                            
                        end
                        
                        obj.scan_end = length(obj.scan_struct(1).out_vec);
                        
                        %%% create scan scripts directory
                        
                        scan_dir = [Adwin.Default_parameters.data_root_path,...
                            obj.year,'\',obj.month,'\',obj.day,'\','scans'];
                        
                        if ~isdir(scan_dir)
                            
                            mkdir(scan_dir);
                            
                        end
                        
                        mkdir([scan_dir,'\scan_',num2str(obj.scan_count)])
                        
                    end
                    
                    for i = 1:length(obj.scan_struct)
                        
                        evalin('base',[obj.scan_struct(i).name,' = ',num2str(obj.scan_struct(i).out_vec(obj.scan_loop)),';']);
                        
                        j = floor(obj.scan_struct(i).index/Adwin.Default_parameters.nb_r_stat_params);
                        
                        k = mod(obj.scan_struct(i).index,Adwin.Default_parameters.nb_r_stat_params);
                        
                        if (k==0)
                            
                            k=Adwin.Default_parameters.nb_r_stat_params;
                            
                            j=j-1;
                            
                        end
                        
                        eval(['set(obj.amg.edt_4_2_',num2str(j),'_',num2str(k),',''String'',',num2str(obj.scan_struct(i).out_vec(obj.scan_loop)),')']);
                        
                    end
                    
                    obj.reset_all_formulas;
                    
                    obj.seq_changed = 1;
                    
                    disp(['Scan : Loop ',num2str(obj.scan_loop),' out of ',num2str(obj.scan_end)])
                    
                    % save scan scripts
                    
                    scan_dir = [Adwin.Default_parameters.data_root_path,...
                        obj.year,'\',obj.month,'\',obj.day,'\','scans\scan_',num2str(obj.scan_count),'\',num2str(obj.scan_loop)];
                    
                    mkdir(scan_dir);
                    
                    obj.generate_script_file('auto_script');
                    
                    obj.generate_parameters_script_file('auto_parameters_script');
                    
                    copyfile('auto_script.m',scan_dir);
                    copyfile('auto_parameters_script.m',scan_dir);
                    copyfile('dependent_parameters_script.m',scan_dir);
                    
                    copyfile('+Adwin\Default_parameters.m',scan_dir);
                    
                    obj.msg = ['scan-',num2str(obj.scan_count),'-pic-',num2str(obj.scan_loop)];
                    
                end
                
            else
                
                % reset scan parameters if manually stopped
                
                if ~isempty(obj.scan_struct)
                    
                    obj.scan_loop = 0;
                    
                    obj.scan_end = 0;
                    
                    obj.scan_struct = [];
                end
                
                % check date and create date folder if needed
                
                cur_date = clock;
                
                if ~isequal(str2double(obj.day),cur_date(3))
                    
                    obj.year = num2str(cur_date(1));
                    
                    if (cur_date(2)<10)
                        
                        obj.month = ['0',num2str(cur_date(2))];
                        
                    else
                        
                        obj.month = num2str(cur_date(2));
                        
                    end
                    
                    if (cur_date(3)<10)
                        
                        obj.day = ['0',num2str(cur_date(3))];
                        
                    else
                        
                        obj.day = num2str(cur_date(3));
                        
                    end
                    
                    year_dir = [Adwin.Default_parameters.data_root_path,...
                        obj.year];
                    
                    if ~isdir(year_dir)
                        
                        mkdir(year_dir);
                        
                    end
                    
                    month_dir = [Adwin.Default_parameters.data_root_path,...
                        obj.year,'\',obj.month];
                    
                    if ~isdir(month_dir)
                        
                        mkdir(month_dir);
                        
                    end
                    
                    day_dir = [Adwin.Default_parameters.data_root_path,...
                        obj.year,'\',obj.month,'\',obj.day];
                    
                    if ~isdir(day_dir)
                        
                        mkdir(day_dir);
                        
                    end
                    
                    %%% reset scan counts and global save counts
                    
                    obj.scan_count = 0;
                    
                    obj.global_saved_count = 0;
                    
                end
                
                if get(obj.amg.ckb5_1,'Value')
                    
                    % create sequences folder if doesn't exist
                    
                    seq_dir = [Adwin.Default_parameters.data_root_path,...
                        obj.year,'\',obj.month,'\',obj.day,'\','sequences'];
                    
                    if (obj.global_saved_count == 0)
                        
                        mkdir(seq_dir);
                        
                    end
                    
                    obj.global_saved_count = obj.global_saved_count + 1;
                    
                    % copy scripts
                    
                    sc_dir = [Adwin.Default_parameters.data_root_path,...
                        obj.year,'\',obj.month,'\',obj.day,'\','sequences\',num2str(obj.global_saved_count)];
                    
                    mkdir(sc_dir);
                    
                    if obj.seq_changed
                        
                        obj.generate_script_file('auto_script');
                        
                        obj.generate_parameters_script_file('auto_parameters_script');
                        
                    end
                    
                    copyfile('auto_script.m',sc_dir);
                    copyfile('auto_parameters_script.m',sc_dir);
                    copyfile('dependent_parameters_script.m',sc_dir);
                    
                    copyfile('+Adwin\Default_parameters.m',sc_dir);
                    
                    obj.msg = ['seq-',num2str(obj.global_saved_count)];
                    
                else
                    
                    obj.msg = 'seq-0';
                    
                end
                
            end
            
            if obj.seq_changed % update Adwin memory if the sequence has changed
                
                %%% Set digital outputs
                
                % Create a cell containing all digital outputs timings
                
                for l=1:Adwin.Default_parameters.dig_crd % go through adwin digital cards
                    
                    for j=1:length(obj.dig_out_cell{l})
                        
                        obj.dig_out_cell{l}{j}=[];
                        
                        for i=1:length(obj.block_seq_array)
                            
                            len_temp = length(obj.dig_out_cell{l}{j});
                            
                            obj.dig_out_cell{l}{j}=[obj.dig_out_cell{l}{j},zeros(1,length(obj.block_seq_array(i).dig_out_struct((l-1)*Adwin.Default_parameters.dig_out_nbr+j).timings_array)-1)];
                            
                            for k=1:(length(obj.block_seq_array(i).dig_out_struct((l-1)*Adwin.Default_parameters.dig_out_nbr+j).timings_array)-1)
                                
                                obj.dig_out_cell{l}{j}(len_temp+k)= evalin('base',obj.block_seq_array(i).t_start)/evalin('base','Adwin_time_resol') + obj.block_seq_array(i).dig_out_struct((l-1)*Adwin.Default_parameters.dig_out_nbr+j).timings_array(k).abs_out;
                                
                            end
                            
                        end
                        
                        obj.dig_out_cell{l}{j}=[obj.dig_out_cell{l}{j},Inf];
                        
                        if (length(obj.dig_out_cell{l}{j})>1)
                            
                            for k=length(obj.dig_out_cell{l}{j}):-1:2
                                
                                obj.dig_out_cell{l}{j}(k)=obj.dig_out_cell{l}{j}(k)-obj.dig_out_cell{l}{j}(k-1);
                                
                            end
                        end
                        
                    end
                    
                end
                
                %%% Set Digital Outputs Sequence
                
                adw_dig_time_seq = cell(1,Adwin.Default_parameters.dig_crd); % adwin digital timing sequence
                adw_dig_out_seq = cell(1,Adwin.Default_parameters.dig_crd); % digital outputs state sequence
                
                dig_out_temp = obj.dig_out_init;
                
                temp_cell = obj.dig_out_cell;
                
                for l=1:Adwin.Default_parameters.dig_crd
                    
                    adw_dig_time_seq{l} = zeros(1,Adwin.Default_parameters.max_step_dig);
                    adw_dig_out_seq{l} =  zeros(1,Adwin.Default_parameters.max_step_dig);
                    
                    index = 1;
                    
                    while ~isequal(cellfun(@(x) isequal(x,Inf),temp_cell{l}),ones(1,Adwin.Default_parameters.dig_out_nbr))
                        
                        [t,j] = min(cellfun(@(x) x(1),temp_cell{l}));
                        
                        for i=1:Adwin.Default_parameters.dig_out_nbr
                            
                            temp_cell{l}{i}(1) = temp_cell{l}{i}(1) - t;
                            
                        end
                        
                        adw_dig_time_seq{l}(index)=t;
                        
                        for i=1:(Adwin.Default_parameters.dig_out_nbr-1)
                            
                            adw_dig_out_seq{l}(index)=adw_dig_out_seq{l}(index)+dig_out_temp{(l-1)*Adwin.Default_parameters.dig_out_nbr+i}*2^(i-1);
                            
                            if isequal(temp_cell{l}{i}(1),0)
                                
                                temp_cell{l}{i}=temp_cell{l}{i}(2:end);
                                
                                dig_out_temp{(l-1)*Adwin.Default_parameters.dig_out_nbr+i}=~dig_out_temp{(l-1)*Adwin.Default_parameters.dig_out_nbr+i};
                                
                            end
                            
                        end
                        
                        if isequal(dig_out_temp{(l-1)*Adwin.Default_parameters.dig_out_nbr+Adwin.Default_parameters.dig_out_nbr},1)
                            
                            adw_dig_out_seq{l}(index)=adw_dig_out_seq{l}(index)-2^(Adwin.Default_parameters.dig_out_nbr-1);
                            
                        end
                        
                        if isequal(temp_cell{l}{Adwin.Default_parameters.dig_out_nbr}(1),0)
                            
                            temp_cell{l}{Adwin.Default_parameters.dig_out_nbr}=temp_cell{l}{Adwin.Default_parameters.dig_out_nbr}(2:end);
                            
                            dig_out_temp{(l-1)*Adwin.Default_parameters.dig_out_nbr+Adwin.Default_parameters.dig_out_nbr}=~dig_out_temp{(l-1)*Adwin.Default_parameters.dig_out_nbr+Adwin.Default_parameters.dig_out_nbr};
                            
                        end
                        
                        index=index+1;
                        
                    end
                    
                    for i=1:(Adwin.Default_parameters.dig_out_nbr-1)
                        
                        adw_dig_out_seq{l}(index)=adw_dig_out_seq{l}(index)+dig_out_temp{(l-1)*Adwin.Default_parameters.dig_out_nbr+i}*2^(i-1);
                        
                    end
                    
                    if isequal(dig_out_temp{(l-1)*Adwin.Default_parameters.dig_out_nbr+Adwin.Default_parameters.dig_out_nbr},1)
                        
                        adw_dig_out_seq{l}(index)=adw_dig_out_seq{l}(index)-2^(Adwin.Default_parameters.dig_out_nbr-1);
                        
                    end
                    
                    ret_val = SetData_Double(Adwin.Default_parameters.dig_data_time_array(l),int32(adw_dig_time_seq{l}),1);
                    
                    if ~isequal(ret_val,255)
                        
                        disp(['Set Data Digital Time ',num2str(l),' Success !'])
                        
                    else
                        
                        errnum = Get_Last_Error();
                        pErrText = Get_Last_Error_Text(errnum);
                        disp(['Error Set Data Digital Time ',num2str(l),' - ',pErrText])
                        
                    end
                    
                    SetData_Double(Adwin.Default_parameters.dig_data_out_array(l),int32(adw_dig_out_seq{l}),1);
                    
                    if ~isequal(ret_val,255)
                        
                        disp(['Set Data Digital Out ',num2str(l),' Success !'])
                        
                    else
                        
                        errnum = Get_Last_Error();
                        pErrText = Get_Last_Error_Text(errnum);
                        disp(['Error Set Data Digital Out ',num2str(l),' - ',pErrText])
                        
                    end
                    
                end
                
                %%% Set Analog outputs sequence
                
                % Create analog outputs timings and voltage cell for each
                % analog outputs card
                
                for l=1:Adwin.Default_parameters.ana_crd % go through adwin analog cards
                    
                    for j=1:length(obj.ana_out_cell{l}) % go through each outputs of each card
                        
                        obj.ana_out_cell{l}{j}=[]; % output structures containing timings of analog outputs
                        
                        obj.ana_volt_cell{l}{j}=[]; % output structure containing analog output voltage values
                        
                        for i=1:length(obj.block_seq_array)
                            
                            for k=1:(length(obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).timings_array)-1)
                                
                                switch obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(k).behaviour
                                    
                                    case 'C'
                                        
                                        obj.ana_out_cell{l}{j}  = [obj.ana_out_cell{l}{j}, ...
                                            round(evalin('base',obj.block_seq_array(i).t_start)/evalin('base','Adwin_time_resol')) + ...
                                            obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).timings_array(k).abs_out];
                                        
                                        obj.ana_volt_cell{l}{j} = [obj.ana_volt_cell{l}{j}, ...
                                            obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(k).binary];
                                        
                                    case 'R'
                                        
                                        binary_steps = abs(obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(k+1).binary-...
                                            obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(k).binary);
                                        
                                        sign_steps = sign(obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(k+1).binary-...
                                            obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(k).binary);
                                        
                                        ramp_steps_number = obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).timings_array(k).out;
                                        
                                        bin_per_step = binary_steps/ramp_steps_number;
                                        
                                        if (binary_steps<ramp_steps_number)
                                            
                                            temp_out_cell = zeros(1,binary_steps);
                                            
                                            temp_bin_cell = zeros(1,binary_steps);
                                            
                                            temp_bin_cell(1) = obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(k).binary;
                                            
                                            for m=1:(binary_steps-1)
                                                
                                                temp_bin_cell(m+1) = temp_bin_cell(m) + sign_steps;
                                                
                                                temp_out_cell(m) = round((temp_bin_cell(m+1)-temp_bin_cell(1))/bin_per_step);
                                                
                                            end
                                            
                                            temp_out_cell(end) = ramp_steps_number;
                                            
                                            if ~isempty(obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).timings_array(k).previous)
                                                
                                                temp_out_cell = temp_out_cell+obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).timings_array(k).previous.abs_out;
                                                
                                            end
                                            
                                        else
                                            
                                            temp_out_cell  = zeros(1,ramp_steps_number);
                                            
                                            temp_bin_cell = zeros(1,ramp_steps_number);
                                            
                                            temp_out_cell(1) = 1;
                                            
                                            temp_bin_cell(1) = obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(k).binary;
                                            
                                            for m=2:ramp_steps_number
                                                
                                                temp_out_cell(m) = temp_out_cell(m-1) + sign_steps;
                                                
                                                temp_bin_cell(m) = round((m-1)*bin_per_step+temp_bin_cell(1));
                                                
                                            end
                                            
                                            if ~isempty(obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).timings_array(k).previous)
                                                
                                                temp_out_cell = temp_out_cell+obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).timings_array(k).previous.abs_out;
                                                
                                            end
                                            
                                        end
                                        
                                        obj.ana_out_cell{l}{j}  = [obj.ana_out_cell{l}{j}, ...
                                            round(evalin('base',obj.block_seq_array(i).t_start)/evalin('base','Adwin_time_resol')) + ...
                                            temp_out_cell];
                                        
                                        obj.ana_volt_cell{l}{j} = [obj.ana_volt_cell{l}{j}, ...
                                            temp_bin_cell];
                                        
                                    case 'S'
                                        
                                        ramp_steps_number = obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).timings_array(k).out;
                                        
                                        if ~isempty(obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).timings_array(k).previous)
                                            
                                            temp_out_cell = obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).timings_array(k).previous.abs_out+1;
                                            
                                        else
                                            
                                            temp_out_cell = 1;
                                            
                                        end
                                        
                                        temp_bin_cell = obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(k).binary;
                                        
                                        for m=2:ramp_steps_number
                                            
                                            val = eval(['Adwin.Functions.',obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(k).fonction,...
                                                '(',num2str((m-1)/(ramp_steps_number-1)),')']);
                                            
                                            volt = eval(['Adwin.Calibrations.ana_out_',num2str(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr),'(',num2str(val),');']);
                                            
                                            binary = max(min(round(volt/(10/2^15))+2^15,2^16-1),0);
                                            
                                            if isequal(binary,temp_bin_cell(end))
                                                
                                                temp_out_cell(end) = temp_out_cell(end)+1;
                                                
                                            else
                                                
                                                temp_out_cell(end+1) = temp_out_cell(end)+1;
                                                
                                                temp_bin_cell(end+1) = binary;
                                                
                                            end
                                            
                                        end
                                        
                                        obj.ana_out_cell{l}{j}  = [obj.ana_out_cell{l}{j}, ...
                                            round(evalin('base',obj.block_seq_array(i).t_start)/evalin('base','Adwin_time_resol')) + ...
                                            temp_out_cell];
                                        
                                        obj.ana_volt_cell{l}{j} = [obj.ana_volt_cell{l}{j}, ...
                                            temp_bin_cell];
                                        
                                end
                                
                            end
                            
                            %%% New Block
                            
                            if isequal(i,length(obj.block_seq_array))
                                
                                obj.ana_out_cell{l}{j}=[obj.ana_out_cell{l}{j},Inf];
                                
                                obj.ana_volt_cell{l}{j}=[obj.ana_volt_cell{l}{j},obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(end).binary];
                                
                            else
                                
                                obj.ana_out_cell{l}{j}=[obj.ana_out_cell{l}{j},round(evalin('base',obj.block_seq_array(i+1).t_start)/evalin('base','Adwin_time_resol'))];
                                
                                obj.ana_volt_cell{l}{j}=[obj.ana_volt_cell{l}{j},obj.block_seq_array(i).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(end).binary];
                                
                            end
                            
                            %%%
                            
                        end
                        
                        %%% Old Block
                        
                        %obj.ana_out_cell{l}{j}=[obj.ana_out_cell{l}{j},Inf];
                        
                        %obj.ana_volt_cell{l}{j}=[obj.ana_volt_cell{l}{j},obj.block_seq_array(end).ana_out_struct(j+(l-1)*Adwin.Default_parameters.ana_crd_out_nbr).voltages_array(end).binary];
                        
                        %%%
                        
                        if (length(obj.ana_out_cell{l}{j})>1)
                            
                            obj.ana_out_cell{l}{j}(2:end) = obj.ana_out_cell{l}{j}(2:end) - obj.ana_out_cell{l}{j}(1:(end-1));
                            
                        end
                        
                        %%% New Block clean structures
                        
                        tmp_out = obj.ana_out_cell{l}{j}(1);
                        tmp_volt = obj.ana_volt_cell{l}{j}(1);
                        
                        for i=2:length(obj.ana_out_cell{l}{j})
                            
                            if isequal(tmp_volt(end),obj.ana_volt_cell{l}{j}(i))
                                
                                tmp_out(end) = tmp_out(end) + obj.ana_out_cell{l}{j}(i);
                                
                            else
                                
                                if ~isequal(obj.ana_out_cell{l}{j}(i),0)
                                    
                                    tmp_out(end+1) = obj.ana_out_cell{l}{j}(i);
                                    tmp_volt(end+1) = obj.ana_volt_cell{l}{j}(i);
                                    
                                end
                                
                            end
                            
                        end
                        
                        obj.ana_out_cell{l}{j} = tmp_out;
                        obj.ana_volt_cell{l}{j} = tmp_volt;
                        
                        %%%
                        
                    end
                    
                end
                
                % Send analog outputs timings and voltages to Adwin
                
                adw_ana_time_seq = cell(1,Adwin.Default_parameters.ana_crd); % adwin analog outputs timing sequence
                adw_ana_out_seq = cell(1,Adwin.Default_parameters.ana_crd); % analog outputs state sequence
                
                temp_cell = obj.ana_out_cell;
                
                temp_volt_cell = obj.ana_volt_cell;
                
                for l=1:Adwin.Default_parameters.ana_crd
                    
                    adw_ana_time_seq{l} = zeros(1,Adwin.Default_parameters.max_step_ana);
                    
                    adw_ana_out_seq{l} = 32768*ones(1,4*Adwin.Default_parameters.max_step_ana)-2^31;
                    
                    index = 1;
                    
                    while ~isequal(cellfun(@(x) isequal(x,Inf),temp_cell{l}),ones(1,Adwin.Default_parameters.ana_crd_out_nbr))
                        
                        % new code
                        
                        [T,J] = sort(cellfun(@(x) x(1),temp_cell{l}),'ascend');
                        
                        tmp_cum = cumsum(temp_cell{l}{J(1)});
                        
                        if isequal(T(2),Inf)
                            
                            tmp_len = length(temp_cell{l}{J(1)})-1;
                            
                        else
                            
                            tmp_len = 2;
                            
                            while tmp_cum(tmp_len)<=temp_cell{l}{J(2)}(1)
                                
                                tmp_len = tmp_len+1;
                                
                            end
                            
                            tmp_len = tmp_len-1;
                            
                        end
                        
                        adw_ana_time_seq{l}(index:index+(tmp_len-1))=temp_cell{l}{J(1)}(1:tmp_len);
                        
                        tmp_bin_cell = cell(1,Adwin.Default_parameters.ana_crd_out_nbr);
                        
                        for i=1:(Adwin.Default_parameters.ana_crd_out_nbr)
                            
                            if isequal(i,J(1))
                                
                                tmp_bin_cell{i} = temp_volt_cell{l}{i}(1:tmp_len);
                                
                                temp_cell{l}{i}=temp_cell{l}{i}((tmp_len+1):end);
                                
                                temp_volt_cell{l}{i}=temp_volt_cell{l}{i}((tmp_len+1):end);
                                
                            else
                                
                                tmp_bin_cell{i}=temp_volt_cell{l}{i}(1)*ones(1,tmp_len);
                                
                                temp_cell{l}{i}(1) = temp_cell{l}{i}(1) - tmp_cum(tmp_len);
                                
                                if isequal(temp_cell{l}{i}(1),0)
                                    
                                    temp_cell{l}{i}=temp_cell{l}{i}(2:end);
                                    
                                    temp_volt_cell{l}{i}=temp_volt_cell{l}{i}(2:end);
                                    
                                end
                                
                            end
                            
                        end
                        
                        for i=1:(Adwin.Default_parameters.ana_crd_out_nbr/2)
                            
                            mask = tmp_bin_cell{2*i}>=2^15;
                            
                            adw_ana_out_seq{l}(4*(index-1)+i:4:4*(index-1+tmp_len-1)+i) = tmp_bin_cell{2*i-1} + ...
                                (tmp_bin_cell{2*i}*2^16).*~mask + (mod(tmp_bin_cell{2*i},2^15)*2^16-2^31).*mask;
                            
                        end
                        
                        index=index+tmp_len;
                        
                    end
                    
                    for i=1:(Adwin.Default_parameters.ana_crd_out_nbr/2)
                        
                        if (temp_volt_cell{l}{2*i}(1)>=2^15)
                            
                            adw_ana_out_seq{l}(4*(index-1)+i) = temp_volt_cell{l}{2*i-1}(1)+mod(temp_volt_cell{l}{2*i}(1),2^15)*2^16-2^31;
                            
                        else
                            
                            adw_ana_out_seq{l}(4*(index-1)+i) = temp_volt_cell{l}{2*i-1}(1)+temp_volt_cell{l}{2*i}(1)*2^16;
                            
                        end
                        
                    end
                    
                    % display the 10 first terms of the tables sent to the adwin
                    
                    disp(['Time table sent to Adwin (4 first terms) - card ',num2str(l)])
                    fprintf('%d %d %d %d \n',adw_ana_time_seq{l}(1:4));
                    disp(['Analog output table sent to Adwin (8 first terms) - card ',num2str(l)])
                    fprintf('%d %d %d %d %d %d %d %d \n',adw_ana_out_seq{l}(1:8));
                    disp(['Analog output table sent to Adwin (9 to 16) - card ',num2str(l)])
                    fprintf('%d %d %d %d %d %d %d %d \n \n',adw_ana_out_seq{l}(9:16));
                    
                    ret_val = SetData_Double(Adwin.Default_parameters.ana_data_time_array(l),int32(adw_ana_time_seq{l}),1);
                    
                    if ~isequal(ret_val,255)
                        
                        disp(['Set Data Analog Time ',num2str(l),' Success !'])
                        
                    else
                        
                        errnum = Get_Last_Error();
                        pErrText = Get_Last_Error_Text(errnum);
                        disp(['Error Set Data Analog Time ',num2str(l),' - ',pErrText])
                        
                    end
                    
                    ret_val = SetData_Double(Adwin.Default_parameters.ana_data_out_array(l),int32(adw_ana_out_seq{l}),1);
                    
                    if ~isequal(ret_val,255)
                        
                        disp(['Set Data Analog Out ',num2str(l),' Success !'])
                        
                    else
                        
                        errnum = Get_Last_Error();
                        pErrText = Get_Last_Error_Text(errnum);
                        disp(['Error Set Data Analog Out ',num2str(l),' - ',pErrText])
                        
                    end
                    
                end
                
                % Reset the seq_changed tag
                
                obj.seq_changed = 0;
                
            end
            
            %%% Start Sequence
            
            ret_val = Start_Process(2);
            
            if ~isequal(ret_val,255)
                
                disp('Start Process 2 Success !')
                
            else
                
                errnum = Get_Last_Error();
                pErrText = Get_Last_Error_Text(errnum);
                disp(['Error Start Process 2 - ',pErrText])
                
            end
            
            if strcmp(obj.pgb_timer.running,'off')
                
                start(obj.pgb_timer);
                
            else
                
                stop(obj.pgb_timer);
                
                start(obj.pgb_timer);
                
            end
            
            %-----send sequence duration to camera-----%
            
            disp(['Start Adwin sequence : duration = ',num2str(obj.seq_duration),' s'])
            
            obj.net.send_message('BEC009',['seq_duration-',num2str(obj.seq_duration)]);
            
            %-----send message pictures incoming-----%
            
            % save parameters file
            
            [static_params,dep_params] = obj.get_params;
            
            save([Adwin.Default_parameters.params_path,'params.mat'],'static_params','dep_params');
            
            % send message to Data-Treatment computer
            
            obj.net.send_message('BEC009',obj.msg);
            
        end
        
        function adw_stop_fcn(obj,~,~)
            
            %%% stop sequence
            
            ret_val = Stop_Process(2);
            
            if ~isequal(ret_val,255)
                
                disp('Stop Process 2 Success !');
                disp('!! Adwin sequence stopped !!');
                
            else
                
                errnum = Get_Last_Error();
                pErrText = Get_Last_Error_Text(errnum);
                disp(['Error Stop Process 2 - ',pErrText]);
                
            end
            
            % stop progress bar
            
            stop(obj.pgb_timer);
            
            % send message to empty camera buffer
            
            obj.net.send_message('BEC009','stop-seq');
            
            %%% re-initialize adwin outputs
            
            ret_val = Start_Process(1);
            
            if ~isequal(ret_val,255)
                
                disp('Start Process 1 Success !');
                disp('!! Digital outputs re-initialized !!');
                
            else
                
                errnum = Get_Last_Error();
                pErrText = Get_Last_Error_Text(errnum);
                disp(['Error Start Process 1 - ',pErrText]);
                
            end
            
        end
        
        function pgb_timer_str(obj,~,~)
            
            c_ofs = 0.;
            r_ofs = 0.;
            c_wth = 0.01;
            r_wth = 1.;
            
            set(obj.amg.hsp5_1_0_0,'Position',[c_ofs r_ofs c_wth r_wth]);
            
        end
        
        function pgb_timer_fcn(obj,~,~)
            
            pos = get(obj.amg.hsp5_1_0_0,'Position');
            
            c_ofs = 0.;
            r_ofs = 0.;
            c_wth = pos(3) + 1/floor(obj.seq_duration/Adwin.Default_parameters.pgb_duration);
            r_wth = 1.;
            
            set(obj.amg.hsp5_1_0_0,'Position',[c_ofs r_ofs c_wth r_wth]);
            
        end
        
        function pgb_timer_stp(obj,~,~)
            
            c_ofs = 0.;
            r_ofs = 0.;
            c_wth = 1.;
            r_wth = 1.;
            
            set(obj.amg.hsp5_1_0_0,'Position',[c_ofs r_ofs c_wth r_wth]);
            
        end
        
        function amg_but2_3_clb(obj,~,~)
            
            % ask from which folder to load the sequence
            
            path = uigetdir([Adwin.Default_parameters.root_path,'sequence_manager']);
            
            if ~strcmp(path,[Adwin.Default_parameters.root_path,'sequence_manager'])
                
                copyfile([path,'\auto_parameters_script.m'],[Adwin.Default_parameters.root_path,'sequence_manager\auto_parameters_script.m']);
                copyfile([path,'\dependent_parameters_script.m'],[Adwin.Default_parameters.root_path,'sequence_manager\dependent_parameters_script.m']);
                copyfile([path,'\auto_script.m'],[Adwin.Default_parameters.root_path,'sequence_manager\auto_script.m']);
                
                if exist([path,'\Default_parameters.m'],'file')
                    
                    copyfile([path,'\Default_parameters.m'],[Adwin.Default_parameters.root_path,'sequence_manager\+Adwin\Default_parameters.m']);
                    
                end
                
            end
            
            % reinitialize the parameters cell arrays
            
            obj.dig_out_cell = cell(1,Adwin.Default_parameters.dig_crd);
            
            for l=1:Adwin.Default_parameters.dig_crd
                
                obj.dig_out_cell{l} = num2cell(Inf(1,Adwin.Default_parameters.dig_out_nbr));
                
            end
            
            obj.ana_out_cell = cell(1,Adwin.Default_parameters.ana_crd);
            
            obj.ana_volt_cell = cell(1,Adwin.Default_parameters.ana_crd);
            
            for l=1:Adwin.Default_parameters.ana_crd
                
                obj.ana_out_cell{l} = num2cell(Inf(1,Adwin.Default_parameters.ana_crd_out_nbr));
                
                obj.ana_volt_cell{l} = num2cell(zeros(1,Adwin.Default_parameters.ana_crd_out_nbr));
                
            end
            
            obj.dep_params_cell = cell(1,Adwin.Default_parameters.nb_r_dep_params*Adwin.Default_parameters.nb_c_dep_params);
            
            obj.st_params_cell = cell(1,Adwin.Default_parameters.nb_r_stat_params*Adwin.Default_parameters.nb_c_stat_params);
            
            for i=1:length(obj.block_seq_array)
                
                if ~isempty(obj.block_seq_array(i).bsg)&&ishandle(obj.block_seq_array(i).bsg.h)
                    
                    close(obj.block_seq_array(i).bsg.h)
                    
                end
                
                if ~isempty(obj.block_seq_array(i).asg)&&ishandle(obj.block_seq_array(i).asg.h)
                    
                    close(obj.block_seq_array(i).asg.h)
                    
                end
                
                delete(obj.block_seq_array(i));
                
            end
            
            obj.block_seq_array = [];
            
            % reload scripts
            
            rehash;
            
            evalin('base','auto_parameters_script;');
            
            evalin('base','dependent_parameters_script;');
            
            evalin('base','auto_script;');
            
            % restart GUI
            
            close(obj.amg.h)
            
            obj.adwin_main_gui;
            
            % modify tag changed sequence
            
            obj.seq_changed = 1;
            
        end
        
        function amg_but2_4_clb(obj,~,~)
            
            obj.generate_script_file('auto_script');
            
            obj.generate_parameters_script_file('auto_parameters_script');
            
        end
        
        function amg_but2_5_clb(obj,~,~)
            
            if ~isempty(obj.ssg)&&ishandle(obj.ssg.h)
                
                set(obj.ssg.h,'Visible','on');
                
            else
                
                % initialize Scans GUI
                
                obj.ssg.h = figure(...
                    'Name'                ,'Scans' ...
                    ,'NumberTitle'        ,'off' ...
                    ,'Position'           ,[8 48 1904 650] ... %,'MenuBar'     ,'none'...
                    ,'CloseRequestFcn'    ,@obj.ssg_closereq ...
                    );
                
                c_wth = 0.995;
                c_ofs = 0.0025;
                r_wth = 0.995;
                r_ofs = 0.0025;
                
                obj.ssg.hsp = uipanel(...
                    'Parent'              ,obj.ssg.h ...
                    ,'BackgroundColor'    ,Adwin.Default_parameters.Panel_BackgroundColor ...
                    ,'ForegroundColor'    ,Adwin.Default_parameters.Panel_ForegroundColor ...
                    ,'HighlightColor'     ,Adwin.Default_parameters.Panel_HighlightColor ...
                    ,'ShadowColor'        ,Adwin.Default_parameters.Panel_ShadowColor ...
                    ,'FontName'           ,Adwin.Default_parameters.Panel_FontName ...
                    ,'FontSize'           ,Adwin.Default_parameters.Panel_FontSize ...
                    ,'FontUnits'          ,Adwin.Default_parameters.Panel_FontUnits ...
                    ,'FontWeight'         ,Adwin.Default_parameters.Panel_FontWeight ...
                    ,'SelectionHighlight' ,Adwin.Default_parameters.Panel_SelectionHighlight ...
                    ,'Units'              ,Adwin.Default_parameters.Panel_Units ...
                    ,'Position'           ,[c_ofs r_ofs c_wth r_wth] ...
                    );
                
                for i=1:Adwin.Default_parameters.nb_c_scans_params
                    
                    % Panel geometry
                    
                    c_wth = 0.195;
                    c_ofs = (1-Adwin.Default_parameters.nb_c_scans_params*c_wth)/(Adwin.Default_parameters.nb_c_scans_params+1);
                    r_wth = 0.99;
                    r_ofs = 0.005;
                    
                    eval(['obj.ssg.hsp_',num2str(i),' = uipanel(', ...
                        '''Parent''                ,obj.ssg.hsp' ...
                        ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                        ',''ForegroundColor''      ,Adwin.Default_parameters.Panel_ForegroundColor', ...
                        ',''HighlightColor''       ,Adwin.Default_parameters.Panel_HighlightColor', ...
                        ',''ShadowColor''          ,Adwin.Default_parameters.Panel_ShadowColor', ...
                        ',''FontName''             ,Adwin.Default_parameters.Panel_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Panel_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Panel_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Panel_FontWeight', ...
                        ',''SelectionHighlight''   ,Adwin.Default_parameters.Panel_SelectionHighlight', ...
                        ',''Units''                ,Adwin.Default_parameters.Panel_Units', ...
                        ',''Position''             ,[c_ofs+(i-1)*(c_wth+c_ofs) r_ofs c_wth r_wth]', ...
                        ');']);
                    
                    % Text geometry
                    
                    c_wth = 0.14;
                    c_ofs = 0.0;
                    r_wth = 0.02;
                    r_ofs = 0.975;
                    
                    eval(['obj.ssg.txt_',num2str(i),'_1 = uicontrol(', ...
                        '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                        ',''Style''                ,''text''', ...
                        ',''String''               ,''Scanned''', ...
                        ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                        ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                        ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                        ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                        ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                        ');']);
                    
                    % Text geometry
                    
                    c_wth = 0.1;
                    c_ofs = 0.145;
                    r_wth = 0.02;
                    r_ofs = 0.975;
                    
                    eval(['obj.ssg.txt_',num2str(i),'_2 = uicontrol(', ...
                        '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                        ',''Style''                ,''text''', ...
                        ',''String''               ,''Name''', ...
                        ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                        ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                        ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                        ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                        ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                        ');']);
                    
                    % Text geometry
                    
                    c_wth = 0.1;
                    c_ofs = 0.360;
                    r_wth = 0.02;
                    r_ofs = 0.975;
                    
                    eval(['obj.ssg.txt_',num2str(i),'_3 = uicontrol(', ...
                        '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                        ',''Style''                ,''text''', ...
                        ',''String''               ,''Begin''', ...
                        ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                        ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                        ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                        ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                        ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                        ');']);
                    
                    % Text geometry
                    
                    c_wth = 0.1;
                    c_ofs = 0.55;
                    r_wth = 0.02;
                    r_ofs = 0.975;
                    
                    eval(['obj.ssg.txt_',num2str(i),'_4 = uicontrol(', ...
                        '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                        ',''Style''                ,''text''', ...
                        ',''String''               ,''Stop''', ...
                        ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                        ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                        ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                        ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                        ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                        ');']);
                    
                    % Text geometry
                    
                    c_wth = 0.1;
                    c_ofs = 0.72;
                    r_wth = 0.02;
                    r_ofs = 0.975;
                    
                    eval(['obj.ssg.txt_',num2str(i),'_5 = uicontrol(', ...
                        '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                        ',''Style''                ,''text''', ...
                        ',''String''               ,''Steps''', ...
                        ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                        ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                        ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                        ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                        ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                        ');']);
                    
                    % Text geometry
                    
                    c_wth = 0.1;
                    c_ofs = 0.87;
                    r_wth = 0.02;
                    r_ofs = 0.975;
                    
                    eval(['obj.ssg.txt_',num2str(i),'_6 = uicontrol(', ...
                        '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                        ',''Style''                ,''text''', ...
                        ',''String''               ,''Order''', ...
                        ',''BackgroundColor''      ,[0.8 0.8 0.8]', ...
                        ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                        ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                        ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                        ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                        ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                        ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                        ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                        ');']);
                    
                    for j=1:Adwin.Default_parameters.nb_r_scans_params
                        
                        % Initialize sca parameters structure
                        
                        obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).name = obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j};
                        
                        obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).index = (i-1)*Adwin.Default_parameters.nb_r_scans_params+j;
                        
                        % Checkbox geometry
                        
                        c_wth = 0.04;
                        c_ofs = 0.02;
                        r_wth = 0.025;
                        r_ofs = (1-(Adwin.Default_parameters.nb_r_scans_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_scans_params+2);
                        
                        eval(['obj.ssg.ckb_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                            '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                            ',''Style''                ,''checkbox''', ...
                            ',''Units''                ,Adwin.Default_parameters.Checkbox_Units', ...
                            ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                            ',''Tag''                 ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                            ',''Callback''             ,@obj.ssg_ckb_clb', ...
                            ');']);
                        
                        if (obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).scanned)
                            
                            eval(['set(obj.ssg.ckb_',num2str(i),'_',num2str(j), ...
                                ',''Value''               ,1', ...
                                ');']);
                            
                        else
                            
                            if ~isempty(obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j})
                                
                                eval(['set(obj.ssg.ckb_',num2str(i),'_',num2str(j), ...
                                    ',''Value''               ,0', ...
                                    ');']);
                                
                            else
                                
                                eval(['set(obj.ssg.ckb_',num2str(i),'_',num2str(j), ...
                                    ',''Value''               ,0', ...
                                    ',''Enable''               ,''off''', ...
                                    ');']);
                                
                            end
                            
                        end
                        
                        % text parameter name
                        
                        % Panel geometry
                        
                        c_wth = 0.225;
                        c_ofs = 0.08;
                        r_wth = 0.0325;
                        r_ofs = (1-(Adwin.Default_parameters.nb_r_scans_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_scans_params+2);
                        
                        eval(['obj.ssg.hsp_',num2str(i),'_',num2str(j),' = uipanel(', ...
                            '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                            ',''BackgroundColor''      ,Adwin.Default_parameters.Panel_BackgroundColor', ...
                            ',''ForegroundColor''      ,Adwin.Default_parameters.Panel_ForegroundColor', ...
                            ',''HighlightColor''       ,Adwin.Default_parameters.Panel_HighlightColor', ...
                            ',''ShadowColor''          ,Adwin.Default_parameters.Panel_ShadowColor', ...
                            ',''FontName''             ,Adwin.Default_parameters.Panel_FontName', ...
                            ',''FontSize''             ,Adwin.Default_parameters.Panel_FontSize', ...
                            ',''FontUnits''            ,Adwin.Default_parameters.Panel_FontUnits', ...
                            ',''FontWeight''           ,Adwin.Default_parameters.Panel_FontWeight', ...
                            ',''SelectionHighlight''   ,Adwin.Default_parameters.Panel_SelectionHighlight', ...
                            ',''Units''                ,Adwin.Default_parameters.Panel_Units', ...
                            ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                            ');']);
                        
                        c_wth = 1;
                        c_ofs = 0;
                        r_wth = 1;
                        r_ofs = 0;
                        
                        eval(['obj.ssg.txt_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                            '''Parent''                ,obj.ssg.hsp_',num2str(i),'_',num2str(j), ...
                            ',''Style''                ,''text''', ...
                            ',''FontName''             ,Adwin.Default_parameters.Text_FontName', ...
                            ',''FontSize''             ,Adwin.Default_parameters.Text_FontSize', ...
                            ',''FontUnits''            ,Adwin.Default_parameters.Text_FontUnits', ...
                            ',''FontWeight''           ,Adwin.Default_parameters.Text_FontWeight', ...
                            ',''HorizontalAlignment''  ,Adwin.Default_parameters.Text_HorizontalAlignment', ...
                            ',''Units''                ,Adwin.Default_parameters.Text_Units', ...
                            ',''Position''             ,[c_ofs r_ofs c_wth r_wth]', ...
                            ');']);
                        
                        if ~isempty(obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j})
                            
                            eval(['set(obj.ssg.txt_',num2str(i),'_',num2str(j), ...
                                ',''String''               ,''',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j},'''', ...
                                ');']);
                            
                        else
                            
                            eval(['set(obj.ssg.txt_',num2str(i),'_',num2str(j), ...
                                ',''String''               ,[''unused'']', ...
                                ',''Enable''               ,''off''', ...
                                ');']);
                            
                        end
                        
                        % edit parameter value (Begin)
                        
                        c_wth = 0.1875;
                        c_ofs = 0.315;
                        r_wth = 0.0325;
                        r_ofs = (1-(Adwin.Default_parameters.nb_r_scans_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_scans_params+2);
                        
                        eval(['obj.ssg.edt_1_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                            '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                            ',''Style''                ,''edit''', ...
                            ',''FontName''             ,Adwin.Default_parameters.Edit_FontName', ...
                            ',''FontSize''             ,Adwin.Default_parameters.Edit_FontSize', ...
                            ',''FontUnits''            ,Adwin.Default_parameters.Edit_FontUnits', ...
                            ',''FontWeight''           ,Adwin.Default_parameters.Edit_FontWeight', ...
                            ',''HorizontalAlignment''  ,Adwin.Default_parameters.Edit_HorizontalAlignment', ...
                            ',''Units''                ,Adwin.Default_parameters.Edit_Units', ...
                            ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                            ',''Tag''                  ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                            ',''Callback''             ,@obj.ssg_edt_1_clb', ...
                            ');']);
                        
                        if ~isempty(obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j})
                            
                            if ~isempty(obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).begin)
                                
                                eval(['set(obj.ssg.edt_1_',num2str(i),'_',num2str(j),',', ...
                                    '''String''                ,',num2str(obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).begin) ...
                                    ');']);
                                
                            else
                                
                                obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).begin = ...
                                    evalin('base',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j});
                                
                                eval(['set(obj.ssg.edt_1_',num2str(i),'_',num2str(j),',', ...
                                    '''String''                ,',num2str(evalin('base',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j})) ...
                                    ');']);
                                
                            end
                            
                        else
                            
                            eval(['set(obj.ssg.edt_1_',num2str(i),'_',num2str(j),',', ...
                                '''String''                ,0' ...
                                ',''Enable''               ,''off''', ...
                                ');']);
                            
                        end
                        
                        % edit parameter value (Stop)
                        
                        c_wth = 0.1875;
                        c_ofs = 0.505;
                        r_wth = 0.0325;
                        r_ofs = (1-(Adwin.Default_parameters.nb_r_scans_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_scans_params+2);
                        
                        eval(['obj.ssg.edt_2_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                            '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                            ',''Style''                ,''edit''', ...
                            ',''FontName''             ,Adwin.Default_parameters.Edit_FontName', ...
                            ',''FontSize''             ,Adwin.Default_parameters.Edit_FontSize', ...
                            ',''FontUnits''            ,Adwin.Default_parameters.Edit_FontUnits', ...
                            ',''FontWeight''           ,Adwin.Default_parameters.Edit_FontWeight', ...
                            ',''HorizontalAlignment''  ,Adwin.Default_parameters.Edit_HorizontalAlignment', ...
                            ',''Units''                ,Adwin.Default_parameters.Edit_Units', ...
                            ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                            ',''Tag''                  ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                            ',''Callback''             ,@obj.ssg_edt_2_clb', ...
                            ');']);
                        
                        if ~isempty(obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j})
                            
                            if ~isempty(obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).stop)
                                
                                eval(['set(obj.ssg.edt_2_',num2str(i),'_',num2str(j),',', ...
                                    '''String''                ,',num2str(obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).stop) ...
                                    ');']);
                                
                            else
                                
                                obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).stop = ...
                                    evalin('base',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j});
                                
                                eval(['set(obj.ssg.edt_2_',num2str(i),'_',num2str(j),',', ...
                                    '''String''                ,',num2str(evalin('base',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j})) ...
                                    ');']);
                                
                            end
                            
                        else
                            
                            eval(['set(obj.ssg.edt_2_',num2str(i),'_',num2str(j),',', ...
                                '''String''                ,0' ...
                                ',''Enable''               ,''off''', ...
                                ');']);
                            
                        end
                        
                        % edit parameter value (Steps)
                        
                        c_wth = 0.150;
                        c_ofs = 0.695;
                        r_wth = 0.0325;
                        r_ofs = (1-(Adwin.Default_parameters.nb_r_scans_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_scans_params+2);
                        
                        eval(['obj.ssg.edt_3_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                            '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                            ',''Style''                ,''edit''', ...
                            ',''FontName''             ,Adwin.Default_parameters.Edit_FontName', ...
                            ',''FontSize''             ,Adwin.Default_parameters.Edit_FontSize', ...
                            ',''FontUnits''            ,Adwin.Default_parameters.Edit_FontUnits', ...
                            ',''FontWeight''           ,Adwin.Default_parameters.Edit_FontWeight', ...
                            ',''HorizontalAlignment''  ,Adwin.Default_parameters.Edit_HorizontalAlignment', ...
                            ',''Units''                ,Adwin.Default_parameters.Edit_Units', ...
                            ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                            ',''Tag''                  ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                            ',''Callback''             ,@obj.ssg_edt_3_clb', ...
                            ');']);
                        
                        if ~isempty(obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_scans_params+j})
                            
                            if ~isempty(obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).steps)
                                
                                eval(['set(obj.ssg.edt_3_',num2str(i),'_',num2str(j),',', ...
                                    '''String''                ,',num2str(obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).steps) ...
                                    ');']);
                                
                            else
                                
                                obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).steps = 1;
                                
                                eval(['set(obj.ssg.edt_3_',num2str(i),'_',num2str(j),',', ...
                                    '''String''                ,1' ...
                                    ');']);
                                
                            end
                            
                        else
                            
                            eval(['set(obj.ssg.edt_3_',num2str(i),'_',num2str(j),',', ...
                                '''String''                ,0' ...
                                ',''Enable''               ,''off''', ...
                                ');']);
                            
                        end
                        
                        % edit parameter value (order)
                        
                        c_wth = 0.150;
                        c_ofs = 0.8475;
                        r_wth = 0.0325;
                        r_ofs = (1-(Adwin.Default_parameters.nb_r_scans_params+1)*r_wth)/(Adwin.Default_parameters.nb_r_scans_params+2);
                        
                        eval(['obj.ssg.edt_4_',num2str(i),'_',num2str(j),' = uicontrol(', ...
                            '''Parent''                ,obj.ssg.hsp_',num2str(i), ...
                            ',''Style''                ,''edit''', ...
                            ',''FontName''             ,Adwin.Default_parameters.Edit_FontName', ...
                            ',''FontSize''             ,Adwin.Default_parameters.Edit_FontSize', ...
                            ',''FontUnits''            ,Adwin.Default_parameters.Edit_FontUnits', ...
                            ',''FontWeight''           ,Adwin.Default_parameters.Edit_FontWeight', ...
                            ',''HorizontalAlignment''  ,Adwin.Default_parameters.Edit_HorizontalAlignment', ...
                            ',''Units''                ,Adwin.Default_parameters.Edit_Units', ...
                            ',''Position''             ,[c_ofs 1-(j+1)*(r_wth+r_ofs) c_wth r_wth]', ...
                            ',''Tag''                  ,','''tag_',num2str(i),'_',num2str(j),'''', ...
                            ',''Callback''             ,@obj.ssg_edt_4_clb', ...
                            ');']);
                        
                        if (obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).scanned)
                            
                            if ~isempty(obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).order)
                                
                                eval(['set(obj.ssg.edt_4_',num2str(i),'_',num2str(j),',', ...
                                    '''String''                ,',num2str(obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).order) ...
                                    ');']);
                                
                            else
                                
                                tmp_order_array = [obj.scans_params_struct.order];
                                
                                if ~isempty(tmp_order_array)
                                    
                                    tmp_max_order=max(tmp_order_array);
                                    
                                    obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).order=tmp_max_order+1;
                                    
                                    eval(['set(obj.ssg.edt_4_',num2str(i),'_',num2str(j),',', ...
                                        '''String''                ,',num2str(tmp_max_order+1) ...
                                        ');']);
                                    
                                else
                                    
                                    eval(['set(obj.ssg.edt_4_',num2str(i),'_',num2str(j),',', ...
                                        '''String''                ,''1''', ...
                                        ');']);
                                    
                                end
                                
                            end
                            
                        else
                            
                            obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).order=0;
                            
                            eval(['set(obj.ssg.edt_4_',num2str(i),'_',num2str(j),',', ...
                                '''String''                ,''0''' ...
                                ',''Enable''               ,''off''', ...
                                ');']);
                            
                        end
                        
                    end
                end
                
            end
            
        end
        
        function amg_but2_6_clb(obj,~,~)
            
            switch obj.scanning
                
                case 0
                    
                    obj.scanning = 1;
                    
                case 1
                    
                    obj.scanning = 0;
                    
            end
            
        end
        
        function amg_but2_7_clb(obj,~,~)
            
            %%% reset scan_params_struct and close scan GUI if it is opened
            
            if ~isempty(obj.ssg)&&ishandle(obj.ssg.h)
                
                close(obj.ssg.h);
                
            end
            
            obj.scans_params_struct = struct(...
                'scanned',num2cell(zeros(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params)), ...
                'name',cell(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params), ...
                'begin',cell(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params), ...
                'stop',cell(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params), ...
                'steps',cell(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params), ...
                'order',cell(1,Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params), ...
                'index',num2cell(1:Adwin.Default_parameters.nb_r_scans_params*Adwin.Default_parameters.nb_c_scans_params) ...
                );
            
            %%% sort static parameters names
            
            % sort cell
            
            mask_st = cellfun(@(x) ~isempty(x),obj.st_params_cell);
            
            sorted_st = sort(obj.st_params_cell(mask_st));
            
            len_st = length(sorted_st);
            
            if len_st>1
                
                obj.st_params_cell(1:len_st) = sorted_st;
                
                obj.st_params_cell((len_st+1):end) = cell(1,Adwin.Default_parameters.nb_r_stat_params*Adwin.Default_parameters.nb_c_stat_params-len_st);
                
            end
            
            % update GUI
            
            for i=1:Adwin.Default_parameters.nb_c_stat_params
                
                for j=1:Adwin.Default_parameters.nb_r_stat_params
                    
                    % update checkbox status
                    
                    if ~isempty(obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j})
                        
                        eval(['set(obj.amg.ckb_4_',num2str(i),'_',num2str(j), ...
                            ',''Value''               ,1', ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.ckb_4_',num2str(i),'_',num2str(j), ...
                            ',''Value''               ,0', ...
                            ');']);
                        
                    end
                    
                    % update name
                    
                    if ~isempty(obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j})
                        
                        eval(['set(obj.amg.edt_4_1_',num2str(i),'_',num2str(j), ...
                            ',''String''               ,''',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j},'''', ...
                            ',''Enable''               ,''on''', ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.edt_4_1_',num2str(i),'_',num2str(j), ...
                            ',''String''               ,[''unused'']', ...
                            ',''Enable''               ,''off''', ...
                            ');']);
                        
                    end
                    
                    % update value
                    
                    if ~isequal(sum(strcmp(evalin('base','who'),obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j})),0)
                        
                        eval(['set(obj.amg.edt_4_2_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,',num2str(evalin('base',obj.st_params_cell{(i-1)*Adwin.Default_parameters.nb_r_stat_params+j})) ...
                            ',''Enable''               ,''on''', ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.edt_4_2_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,0' ...
                            ',''Enable''               ,''off''', ...
                            ');']);
                        
                    end
                    
                end
                
            end
            
            %%% sort dependent parameters
            
            % sort cell
            
            mask_dep = cellfun(@(x) ~isempty(x),obj.dep_params_cell);
            
            sorted_dep = sort(obj.dep_params_cell(mask_dep));
            
            len_dep = length(sorted_dep);
            
            if len_dep>1
                
                obj.dep_params_cell(1:len_dep) = sorted_dep;
                
                obj.dep_params_cell((len_dep+1):end) = cell(1,Adwin.Default_parameters.nb_r_dep_params*Adwin.Default_parameters.nb_c_dep_params-len_dep);
                
            end
            
            % update GUI
            
            for i=1:Adwin.Default_parameters.nb_c_dep_params
                
                for j=1:Adwin.Default_parameters.nb_r_dep_params
                    
                    % update checkbox status
                    
                    if ~isempty(obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})
                        
                        eval(['set(obj.amg.ckb_3_',num2str(i),'_',num2str(j), ...
                            ',''Value''               ,1', ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.ckb_3_',num2str(i),'_',num2str(j), ...
                            ',''Value''               ,0', ...
                            ');']);
                        
                    end
                    
                    % update name
                    
                    if ~isempty(obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})
                        
                        eval(['set(obj.amg.edt_3_',num2str(i),'_',num2str(j), ...
                            ',''String''               ,''',obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j},'''', ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.edt_3_',num2str(i),'_',num2str(j), ...
                            ',''String''               ,[''unused'']', ...
                            ',''Enable''               ,''off''', ...
                            ');']);
                        
                    end
                    
                    % update value
                    
                    if ~isequal(sum(strcmp(evalin('base','who'),obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})),0)
                        
                        eval(['set(obj.amg.txt_3_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,',num2str(evalin('base',obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})) ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.amg.txt_3_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,0' ...
                            ',''Enable''               ,''off''', ...
                            ');']);
                        
                    end
                    
                end
                
            end
            
        end
        
        function amg_edt5_1_1_clb(obj,~,~)
            
            obj.seq_duration = str2double(get(obj.amg.edt5_1_1,'String'));
            
        end
        
        function amg_ckb5_2_clb(obj,~,~)
            
            switch get(obj.amg.ckb5_2,'Value')
                
                case 1
                    
                    set(obj.amg.edt5_2_1,'Enable','on');
                    
                    obj.scan_repeats = 1;
                    
                case 0
                    
                    set(obj.amg.edt5_2_1,'Enable','off','String','1');
                    
                    obj.scan_repeats = 0;
                    
                    obj.scan_repeats_nbr = 1;
                    
            end
            
        end
        
        function amg_edt5_2_1_clb(obj,~,~)
            
            obj.scan_repeats_nbr = str2double(get(obj.amg.edt5_2_1,'String'));
            
        end
        
        function ssg_ckb_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            i=str2double(split_tag{2});
            j=str2double(split_tag{3});
            
            val = eval(['get(obj.ssg.ckb_',num2str(i),'_',num2str(j),',''Value'')']);
            
            switch val
                
                case 1
                    
                    obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).scanned = 1;
                    
                    tmp_order_array = [obj.scans_params_struct.order];
                    
                    if ~isempty(tmp_order_array)
                        
                        tmp_max_order=max(tmp_order_array);
                        
                        obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).order=tmp_max_order+1;
                        
                        eval(['set(obj.ssg.edt_4_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,',num2str(tmp_max_order+1) ...
                            ',''Enable''               ,''on''', ...
                            ');']);
                        
                    else
                        
                        eval(['set(obj.ssg.edt_4_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,''1''', ...
                            ',''Enable''               ,''on''', ...
                            ');']);
                        
                    end
                    
                case 0
                    
                    obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).scanned = 0;
                    
                    eval(['set(obj.ssg.edt_4_',num2str(i),'_',num2str(j),',', ...
                        '''String''                ,''0''' ...
                        ',''Enable''               ,''off''', ...
                        ');']);
                    
                    tmp_order_array = [obj.scans_params_struct.order];
                    
                    [~,ind_max_order]=max(tmp_order_array);
                    
                    k = floor(ind_max_order/Adwin.Default_parameters.nb_r_stat_params)+1;
                    
                    l = mod(ind_max_order,Adwin.Default_parameters.nb_r_stat_params);
                    
                    if (l==0)
                        
                        l=Adwin.Default_parameters.nb_r_stat_params;
                        
                    end
                    
                    obj.scans_params_struct(ind_max_order).order=obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).order;
                    
                    obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).order=0;
                    
                    eval(['set(obj.ssg.edt_4_',num2str(k),'_',num2str(l),',', ...
                        '''String''                ,',num2str(obj.scans_params_struct(ind_max_order).order), ...
                        ');']);
                    
            end
            
        end
        
        function ssg_edt_1_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            i=str2double(split_tag{2});
            j=str2double(split_tag{3});
            
            obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).begin = ...
                str2double(eval(['get(obj.ssg.edt_1_',num2str(i),'_',num2str(j),',''String'')']));
            
        end
        
        function ssg_edt_2_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            i=str2double(split_tag{2});
            j=str2double(split_tag{3});
            
            obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).stop = ...
                str2double(eval(['get(obj.ssg.edt_2_',num2str(i),'_',num2str(j),',''String'')']));
            
        end
        
        function ssg_edt_3_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            i=str2double(split_tag{2});
            j=str2double(split_tag{3});
            
            obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).steps = ...
                str2double(eval(['get(obj.ssg.edt_3_',num2str(i),'_',num2str(j),',''String'')']));
            
        end
        
        function ssg_edt_4_clb(obj,~,~)
            
            tag_edt=get(gcbo,'Tag');
            
            split_tag=regexp(tag_edt,'_','split');
            
            i=str2double(split_tag{2});
            j=str2double(split_tag{3});
            
            tmp_order_array = [obj.scans_params_struct.order];
            
            new_ord =  str2double(eval(['get(obj.ssg.edt_4_',num2str(i),'_',num2str(j),',''String'')']));
            
            tmp_ind=find(tmp_order_array==new_ord);
            
            k = floor(tmp_ind/Adwin.Default_parameters.nb_r_stat_params)+1;
            
            l = mod(tmp_ind,Adwin.Default_parameters.nb_r_stat_params);
            
            if (l==0)
                
                l=Adwin.Default_parameters.nb_r_stat_params;
                
            end
            
            obj.scans_params_struct((k-1)*Adwin.Default_parameters.nb_r_scans_params+l).order = ...
                obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).order;
            
            eval(['set(obj.ssg.edt_4_',num2str(k),'_',num2str(l),',', ...
                '''String''                ,',num2str(obj.scans_params_struct((k-1)*Adwin.Default_parameters.nb_r_scans_params+l).order) ...
                ');']);
            
            obj.scans_params_struct((i-1)*Adwin.Default_parameters.nb_r_scans_params+j).order = new_ord;
            
        end
        
        function ssg_closereq(obj,~,~)
            
            delete(obj.ssg.h)
            
            obj.ssg = [];
            
        end
        
        function nbg_edt1_clb(obj,~,~)
            
            obj.block_seq_array(end).name = get(obj.nbg.edt1,'String');
            
            if ~isempty(obj.block_seq_array(end).t_start)
                
                set(obj.amg.but1_1,'Position',[0.01+length(obj.block_seq_array)*(0.05+0.01) 0.075 0.05 0.85])
                
                temp = obj.block_seq_array(end);
                
                eval(['obj.amg.but',num2str(length(obj.block_seq_array)),' = uicontrol(', ...
                    '''Parent''               ,obj.amg.hsp1', ...
                    ',''Style''               ,''pushbutton''', ...
                    ',''String''              ,obj.block_seq_array(end).name', ...
                    ',''FontName''            ,Adwin.Default_parameters.Pushbutton_FontName', ...
                    ',''FontSize''            ,Adwin.Default_parameters.Pushbutton_FontSize', ...
                    ',''FontUnits''           ,Adwin.Default_parameters.Pushbutton_FontUnits', ...
                    ',''FontWeight''          ,Adwin.Default_parameters.Pushbutton_FontWeight', ...
                    ',''Units''               ,Adwin.Default_parameters.Pushbutton_Units', ...
                    ',''Position''            ,[0.01+',num2str(length(obj.block_seq_array)-1),'*(0.05+0.01) 0.075 0.05 0.85]',  ...
                    ',''Callback''            ,@temp.blk_seq_gui', ...
                    ',''ButtonDownFcn''       ,@temp.blk_seq_edit_btd_fcn', ...
                    ');']);
                
                close(obj.nbg.h);
                
            end
            
        end
        
        function nbg_edt2_clb(obj,~,~)
            
            obj.block_seq_array(end).t_start = get(obj.nbg.edt2,'String');
            
            if ~isempty(obj.block_seq_array(end).t_start)
                
                set(obj.amg.but1_1,'Position',[0.01+length(obj.block_seq_array)*(0.05+0.01) 0.075 0.05 0.85])
                
                temp = obj.block_seq_array(end);
                
                eval(['obj.amg.but',num2str(length(obj.block_seq_array)),' = uicontrol(', ...
                    '''Parent''               ,obj.amg.hsp1', ...
                    ',''Style''               ,''pushbutton''', ...
                    ',''String''              ,obj.block_seq_array(end).name', ...
                    ',''FontName''            ,Adwin.Default_parameters.Pushbutton_FontName', ...
                    ',''FontSize''            ,Adwin.Default_parameters.Pushbutton_FontSize', ...
                    ',''FontUnits''           ,Adwin.Default_parameters.Pushbutton_FontUnits', ...
                    ',''FontWeight''          ,Adwin.Default_parameters.Pushbutton_FontWeight', ...
                    ',''Units''               ,Adwin.Default_parameters.Pushbutton_Units', ...
                    ',''Position''            ,[0.01+',num2str(length(obj.block_seq_array)-1),'*(0.05+0.01) 0.075 0.05 0.85]',  ...
                    ',''Callback''            ,@temp.blk_seq_gui', ...
                    ',''ButtonDownFcn''       ,@temp.blk_seq_edit_btd_fcn', ...
                    ');']);
                
                close(obj.nbg.h);
                
            end
            
        end
        
        function [static_params,dep_params] = get_params(obj)
            
            st_params_names = obj.st_params_cell(cellfun(@(x) ~isempty(x),obj.st_params_cell));
            
            dep_params_names = obj.st_params_cell(cellfun(@(x) ~isempty(x),obj.dep_params_cell));
            
            static_params = struct('name',st_params_names,'value',zeros(size(st_params_names)));
            
            for i=1:length(static_params)
                
                static_params(i).value = evalin('base',[static_params(i).name,';']);
                
            end
            
            dep_params = struct('name',dep_params_names,'value',zeros(size(dep_params_names)));
            
            for i=1:length(dep_params)
                
                dep_params(i).value = evalin('base',[dep_params(i).name,';']);
                
            end
            
        end
        
        function reset_all_formulas(obj)
            
            evalin('base','dependent_parameters_script;');
            
            for i=1:Adwin.Default_parameters.nb_c_dep_params
                
                for j=1:Adwin.Default_parameters.nb_r_dep_params
                    
                    if ~isequal(sum(strcmp(evalin('base','who'),obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})),0)
                        
                        eval(['set(obj.amg.txt_3_',num2str(i),'_',num2str(j),',', ...
                            '''String''                ,',num2str(evalin('base',obj.dep_params_cell{(i-1)*Adwin.Default_parameters.nb_r_dep_params+j})) ...
                            ');']);
                        
                    end
                    
                end
                
            end
            
            for i=1:length(obj.block_seq_array)
                
                % reset digital outputs timings
                
                for j=1:length(obj.block_seq_array(i).dig_out_struct)
                    
                    for k=1:(length(obj.block_seq_array(i).dig_out_struct(j).timings_array)-1)
                        
                        obj.block_seq_array(i).dig_out_struct(j).timings_array(k).set_out;
                        
                    end
                    
                end
                
                % reset analog outputs timings
                
                for j=1:length(obj.block_seq_array(i).ana_out_struct)
                    
                    for k=1:(length(obj.block_seq_array(i).ana_out_struct(j).timings_array)-1)
                        
                        obj.block_seq_array(i).ana_out_struct(j).timings_array(k).set_out;
                        
                        obj.block_seq_array(i).ana_out_struct(j).voltages_array(k).postset_value_formula;
                        
                    end
                    
                    obj.block_seq_array(i).ana_out_struct(j).voltages_array(end).postset_value_formula;
                    
                end
                
            end
            
        end
        
        function chge_state_dig(obj,out,blk_seq_name,time_ref_nbr,formula)
            
            tmp_block = obj.block_seq_array(strcmp({obj.block_seq_array.name},blk_seq_name));
            
            if isempty(time_ref_nbr)
                
                if length(tmp_block.dig_out_struct(out).timings_array)<2
                    
                    tmp_block.dig_out_struct(out).timings_array(end+1) = tmp_block.dig_out_struct(out).timings_array(end);
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1)= Adwin.Timing;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).type = 'digital';
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).parent_block = tmp_block;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).next = tmp_block.dig_out_struct(out).timings_array(end);
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).formula = formula;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).ord = length(tmp_block.dig_out_struct(out).timings_array)-1;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).out_nbr = out;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).timing_nbr = tmp_block.dig_out_struct(out).timings_array(end).timing_nbr;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).state = tmp_block.dig_out_struct(out).timings_array(end).state;
                    
                    tmp_block.dig_out_struct(out).timings_array(end).previous = tmp_block.dig_out_struct(out).timings_array(end-1);
                    
                    tmp_block.dig_out_struct(out).timings_array(end).ord = length(tmp_block.dig_out_struct(out).timings_array);
                    
                    tmp_block.dig_out_struct(out).timings_array(end).timing_nbr = tmp_block.dig_out_struct(out).timings_array(end).timing_nbr+1;
                    
                else
                    
                    tmp_block.dig_out_struct(out).timings_array(end+1) = tmp_block.dig_out_struct(out).timings_array(end);
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1)= Adwin.Timing;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).type = 'digital';
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).parent_block = tmp_block;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).previous = tmp_block.dig_out_struct(out).timings_array(end-2);
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).previous.next = tmp_block.dig_out_struct(out).timings_array(end-1);
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).next = tmp_block.dig_out_struct(out).timings_array(end);
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).formula = formula;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).ord = length(tmp_block.dig_out_struct(out).timings_array)-1;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).out_nbr = out;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).timing_nbr = tmp_block.dig_out_struct(out).timings_array(end).timing_nbr;
                    
                    tmp_block.dig_out_struct(out).timings_array(end-1).state = tmp_block.dig_out_struct(out).timings_array(end).state;
                    
                    tmp_block.dig_out_struct(out).timings_array(end).previous = tmp_block.dig_out_struct(out).timings_array(end-1);
                    
                    tmp_block.dig_out_struct(out).timings_array(end).ord = length(tmp_block.dig_out_struct(out).timings_array);
                    
                    tmp_block.dig_out_struct(out).timings_array(end).timing_nbr = tmp_block.dig_out_struct(out).timings_array(end).timing_nbr+1;
                    
                end
                
            else
                
                tmp_block.dig_out_struct(out).timings_array(end+1) = tmp_block.dig_out_struct(out).timings_array(end);
                
                tmp_block.dig_out_struct(out).timings_array(end-1)= Adwin.Timing;
                
                tmp_block.dig_out_struct(out).timings_array(end-1).type = 'digital';
                
                tmp_block.dig_out_struct(out).timings_array(end-1).parent_block = tmp_block;
                
                tmp_block.dig_out_struct(out).timings_array(end-1).time_ref = tmp_block.dig_out_struct(out).timings_array(time_ref_nbr);
                
                tmp_block.dig_out_struct(out).timings_array(end-1).previous = tmp_block.dig_out_struct(out).timings_array(end-2);
                
                tmp_block.dig_out_struct(out).timings_array(end-1).previous.next = tmp_block.dig_out_struct(out).timings_array(end-1);
                
                tmp_block.dig_out_struct(out).timings_array(end-1).next = tmp_block.dig_out_struct(out).timings_array(end);
                
                tmp_block.dig_out_struct(out).timings_array(end-1).formula = formula;
                
                tmp_block.dig_out_struct(out).timings_array(end-1).ord = length(tmp_block.dig_out_struct(out).timings_array)-1;
                
                tmp_block.dig_out_struct(out).timings_array(end-1).out_nbr = out;
                
                tmp_block.dig_out_struct(out).timings_array(end-1).timing_nbr = tmp_block.dig_out_struct(out).timings_array(end).timing_nbr;
                
                tmp_block.dig_out_struct(out).timings_array(end-1).state = tmp_block.dig_out_struct(out).timings_array(end).state;
                
                tmp_block.dig_out_struct(out).timings_array(end).previous = tmp_block.dig_out_struct(out).timings_array(end-1);
                
                tmp_block.dig_out_struct(out).timings_array(end).ord = length(tmp_block.dig_out_struct(out).timings_array);
                
                tmp_block.dig_out_struct(out).timings_array(end).timing_nbr = tmp_block.dig_out_struct(out).timings_array(end).timing_nbr+1;
                
            end
            
        end
        
        function chge_state_ana(obj,out,blk_seq_name,time_ref_nbr,formula,value_formula,behaviour,fonction)
            
            % Get the right sequence Block
            
            tmp_block = obj.block_seq_array(strcmp({obj.block_seq_array.name},blk_seq_name));
            
            % Set the timing right
            
            if isempty(time_ref_nbr)
                
                if length(tmp_block.ana_out_struct(out).timings_array)<2
                    
                    tmp_block.ana_out_struct(out).timings_array(end+1) = tmp_block.ana_out_struct(out).timings_array(end);
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1)= Adwin.Timing;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).type = 'analog';
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).parent_block = tmp_block;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).next = tmp_block.ana_out_struct(out).timings_array(end);
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).formula = formula;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).ord = length(tmp_block.ana_out_struct(out).timings_array)-1;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).out_nbr = out;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).timing_nbr = tmp_block.ana_out_struct(out).timings_array(end).timing_nbr;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).state = tmp_block.ana_out_struct(out).timings_array(end).state;
                    
                    tmp_block.ana_out_struct(out).timings_array(end).previous = tmp_block.ana_out_struct(out).timings_array(end-1);
                    
                    tmp_block.ana_out_struct(out).timings_array(end).ord = length(tmp_block.ana_out_struct(out).timings_array);
                    
                    tmp_block.ana_out_struct(out).timings_array(end).timing_nbr = tmp_block.ana_out_struct(out).timings_array(end).timing_nbr+1;
                    
                else
                    
                    tmp_block.ana_out_struct(out).timings_array(end+1) = tmp_block.ana_out_struct(out).timings_array(end);
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1)= Adwin.Timing;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).type = 'analog';
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).parent_block = tmp_block;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).previous = tmp_block.ana_out_struct(out).timings_array(end-2);
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).previous.next = tmp_block.ana_out_struct(out).timings_array(end-1);
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).formula = formula;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).ord = length(tmp_block.ana_out_struct(out).timings_array)-1;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).out_nbr = out;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).timing_nbr = tmp_block.ana_out_struct(out).timings_array(end).timing_nbr;
                    
                    tmp_block.ana_out_struct(out).timings_array(end-1).state = tmp_block.ana_out_struct(out).timings_array(end).state;
                    
                    tmp_block.ana_out_struct(out).timings_array(end).previous = tmp_block.ana_out_struct(out).timings_array(end-1);
                    
                    tmp_block.ana_out_struct(out).timings_array(end).ord = length(tmp_block.ana_out_struct(out).timings_array);
                    
                    tmp_block.ana_out_struct(out).timings_array(end).timing_nbr = tmp_block.ana_out_struct(out).timings_array(end).timing_nbr+1;
                    
                end
                
            else
                
                tmp_block.ana_out_struct(out).timings_array(end+1) = tmp_block.ana_out_struct(out).timings_array(end);
                
                tmp_block.ana_out_struct(out).timings_array(end-1)= Adwin.Timing;
                
                tmp_block.ana_out_struct(out).timings_array(end-1).type = 'analog';
                
                tmp_block.ana_out_struct(out).timings_array(end-1).parent_block = tmp_block;
                
                tmp_block.ana_out_struct(out).timings_array(end-1).time_ref = tmp_block.ana_out_struct(out).timings_array(time_ref_nbr);
                
                tmp_block.ana_out_struct(out).timings_array(end-1).previous = tmp_block.ana_out_struct(out).timings_array(end-2);
                
                tmp_block.ana_out_struct(out).timings_array(end-1).previous.next = tmp_block.ana_out_struct(out).timings_array(end-1);
                
                tmp_block.ana_out_struct(out).timings_array(end-1).next = tmp_block.ana_out_struct(out).timings_array(end);
                
                tmp_block.ana_out_struct(out).timings_array(end-1).formula = formula;
                
                tmp_block.ana_out_struct(out).timings_array(end-1).ord = length(tmp_block.ana_out_struct(out).timings_array)-1;
                
                tmp_block.ana_out_struct(out).timings_array(end-1).out_nbr = out;
                
                tmp_block.ana_out_struct(out).timings_array(end-1).timing_nbr = tmp_block.ana_out_struct(out).timings_array(end).timing_nbr;
                
                tmp_block.ana_out_struct(out).timings_array(end-1).state = tmp_block.ana_out_struct(out).timings_array(end).state;
                
                tmp_block.ana_out_struct(out).timings_array(end).previous = tmp_block.ana_out_struct(out).timings_array(end-1);
                
                tmp_block.ana_out_struct(out).timings_array(end).ord = length(tmp_block.ana_out_struct(out).timings_array);
                
                tmp_block.ana_out_struct(out).timings_array(end).timing_nbr = tmp_block.ana_out_struct(out).timings_array(end).timing_nbr+1;
                
            end
            
            % Set the voltage right
            
            tmp_block.ana_out_struct(out).voltages_array(end+1) = tmp_block.ana_out_struct(out).voltages_array(end);
            
            tmp_block.ana_out_struct(out).voltages_array(end-1) = Adwin.Voltage;
            
            tmp_block.ana_out_struct(out).voltages_array(end-1).parent_block = tmp_block;
            
            tmp_block.ana_out_struct(out).voltages_array(end-1).out_nbr = out;
            
            tmp_block.ana_out_struct(out).voltages_array(end-1).value_formula = value_formula;
            
            tmp_block.ana_out_struct(out).voltages_array(end-1).behaviour = behaviour;
            
            tmp_block.ana_out_struct(out).voltages_array(end-1).fonction = fonction;
            
            tmp_block.ana_out_struct(out).voltages_array(end-1).voltage_nbr = tmp_block.ana_out_struct(out).voltages_array(end).voltage_nbr;
            
            tmp_block.ana_out_struct(out).voltages_array(end).voltage_nbr = tmp_block.ana_out_struct(out).voltages_array(end).voltage_nbr+1;
            
        end
        
        function chge_end_state_ana(obj,out,blk_seq_name,value_formula)
            
            % Get the right sequence Block
            
            tmp_block = obj.block_seq_array(strcmp({obj.block_seq_array.name},blk_seq_name));
            
            % Set the Voltage value
            
            tmp_block.ana_out_struct(out).voltages_array(end).value_formula = value_formula;
            
        end
        
        function generate_parameters_script_file(obj,sc_name)
            
            fid=fopen([sc_name,'.m'],'w');
            
            str = '%%%%%%%% ADWIN Static Parameters %%%%%%%%\n';
            
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n']);
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n']);
            fprintf(fid,str);
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n']);
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n\n']);
            
            for i=1:(Adwin.Default_parameters.nb_c_stat_params*Adwin.Default_parameters.nb_r_stat_params)
                
                if ~isempty(obj.st_params_cell{i})
                    
                    fprintf(fid,['test_adwin.st_params_cell{',num2str(i),'}=''',obj.st_params_cell{i},''';\n\n']);
                    
                    fprintf(fid,[obj.st_params_cell{i},'=',num2str(evalin('base',obj.st_params_cell{i})),';\n\n']);
                    
                end
                
            end
            
            str = '%%%%%%%% ADWIN Dependent Parameters %%%%%%%%\n';
            
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n']);
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n']);
            fprintf(fid,str);
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n']);
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n\n']);
            
            for i=1:(Adwin.Default_parameters.nb_c_dep_params*Adwin.Default_parameters.nb_r_dep_params)
                
                if ~isempty(obj.dep_params_cell{i})
                    
                    fprintf(fid,['test_adwin.dep_params_cell{',num2str(i),'}=''',obj.dep_params_cell{i},''';\n\n']);
                    
                end
                
            end
            
            fclose(fid);
            
        end
        
        function generate_script_file(obj,sc_name)
            
            fid=fopen([sc_name,'.m'],'w');
            
            str = '%%%%%%%% ADWIN Digital Sequence %%%%%%%%\n';
            
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n']);
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n']);
            fprintf(fid,str);
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n']);
            fprintf(fid,[repmat('%%',1,length(str)-10),'\n\n']);
            
            for l=1:length(obj.block_seq_array)
                
                str = ['%%%%%%%% Block ',obj.block_seq_array(l).name,' %%%%%%%%\n'];
                
                fprintf(fid,[repmat('%%',1,length(str)-10),'\n']);
                fprintf(fid,str);
                fprintf(fid,[repmat('%%',1,length(str)-10),'\n\n']);
                
                if (l==1)
                    
                    fprintf(fid,['test_adwin.block_seq_array = Adwin.Block;\n\n']);
                    
                    fprintf(fid,['for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr\n\n']);
                    fprintf(fid,['test_adwin.block_seq_array(1).dig_out_struct(i).timings_array(1).state = Adwin.Default_parameters.dig_out_init{i};\n\n']);
                    fprintf(fid,['end\n\n']);
                    
                else
                    
                    fprintf(fid,['test_adwin.block_seq_array(',num2str(l),') = Adwin.Block;\n']);
                    fprintf(fid,['test_adwin.block_seq_array(',num2str(l-1),').next = test_adwin.block_seq_array(',num2str(l),');\n\n']);
                    
                    fprintf(fid,['for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr\n\n']);
                    fprintf(fid,['test_adwin.block_seq_array(',num2str(l),').dig_out_struct(i).timings_array(1).state = test_adwin.block_seq_array(',num2str(l-1),').dig_out_struct(i).timings_array(end).state;\n\n']);
                    fprintf(fid,['end\n\n']);
                    
                end
                
                fprintf(fid,['test_adwin.block_seq_array(',num2str(l),').name = ''',obj.block_seq_array(l).name,''';\n']);
                fprintf(fid,['test_adwin.block_seq_array(',num2str(l),').t_start = ''',obj.block_seq_array(l).t_start,''';\n\n']);
                fprintf(fid,['test_adwin.block_seq_array(',num2str(l),').parent_adwin = test_adwin;\n\n']);
                
                obj.block_seq_array(l).generate_script_file(fid);
                
            end
            
            fclose(fid);
            
        end
        
        function postset_seq_changed(obj,~,~)
            
            if ~isempty(obj.block_seq_array)
                
                %%% Calculate sequence duration and set it
                
                dur_seq = 0;
                
                for i=1:length(obj.block_seq_array(end).dig_out_struct)
                    
                    if length(obj.block_seq_array(end).dig_out_struct(i).timings_array)>1
                        
                        tmp_dur_seq = obj.block_seq_array(end).dig_out_struct(i).timings_array(end-1).abs_out*evalin('base','Adwin_time_resol') + evalin('base',obj.block_seq_array(end).t_start);
                        
                        if tmp_dur_seq>dur_seq
                            
                            dur_seq = tmp_dur_seq;
                            
                        end
                        
                    end
                    
                end
                
                for i=1:length(obj.block_seq_array(end).ana_out_struct)
                    
                    if length(obj.block_seq_array(end).ana_out_struct(i).timings_array)>1
                        
                        tmp_dur_seq = obj.block_seq_array(end).ana_out_struct(i).timings_array(end-1).abs_out*evalin('base','Adwin_time_resol') + evalin('base',obj.block_seq_array(end).t_start);
                        
                        if tmp_dur_seq>dur_seq
                            
                            dur_seq = tmp_dur_seq;
                            
                        end
                        
                    end
                    
                end
                
                set(obj.amg.txt5_1_10,'String',[num2str(dur_seq/1000),' s'])
                
            end
            
        end
        
        function postset_scanning(obj,~,~)
            
            switch obj.scanning
                
                case 1
                    
                    set(obj.amg.but2_6,'BackgroundColor',[1.0,0.0,0.0]);
                    
                    set(obj.amg.but2_2,'Enable','off');
                    
                case 0
                    
                    set(obj.amg.but2_6,'BackgroundColor',[0.0,1.0,0.0]);
                    
                    set(obj.amg.but2_2,'Enable','on');
                    
            end
            
        end
        
        function postset_scan_loop(obj,~,~)
            
            set(obj.amg.txt5_2_2,'String',num2str(obj.scan_loop));
            
            if ~isequal(obj.scan_loop,0)
                
                dur = (obj.scan_end-obj.scan_loop+1)*obj.seq_duration;
                
                set(obj.amg.txt5_2_6,'String',obj.convert_time_to_string(dur));
                
            else
                
                set(obj.amg.txt5_2_6,'String','0h:0min:0s');
                
            end
            
        end
        
        function postset_scan_end(obj,~,~)
            
            set(obj.amg.txt5_2_4,'String',num2str(obj.scan_end));
            
            if ~isequal(obj.scan_end,0)
                
                dur = obj.scan_end*obj.seq_duration;
                
                set(obj.amg.txt5_2_8,'String',obj.convert_time_to_string(dur));
                
            else
                
                set(obj.amg.txt5_2_8,'String','0h:0min:0s');
                
            end
            
        end
        
        function postset_scan_count(obj,~,~)
            
            if ~isempty(obj.amg)&&ishandle(obj.amg.h)
                
                set(obj.amg.txt5_2_10,'String',num2str(obj.scan_count));
                
            end
            
        end
        
        function postset_global_saved_count(obj,~,~)
            
            if ~isempty(obj.amg)&&ishandle(obj.amg.h)
                
                set(obj.amg.txt5_1_2,'String',num2str(obj.global_saved_count));
                
            end
            
        end
        
        function postset_seq_duration(obj,~,~)
            
            % Update GUI
            
            if ~isempty(obj.amg)&&ishandle(obj.amg.h)
                
                set(obj.amg.edt5_1_1,'String',obj.seq_duration)
                
            end
            
            % Update timers
            
            obj.adw_timer.Period = obj.seq_duration;
            
            obj.pgb_timer.TasksToExecute = floor(obj.seq_duration/Adwin.Default_parameters.pgb_duration);
            
        end
        
        function postset_running(obj,~,~)
            
            if obj.running
                
                set(obj.amg.edt5_1_1,'Enable','off')
                
            else
                
                set(obj.amg.edt5_1_1,'Enable','on')
                
            end
            
        end
        
        function delete(obj)
            
            for i=1:length(obj.block_seq_array)
                
                for j=1:Adwin.Default_parameters.dig_out_nbr
                    
                    for k=1:length(obj.block_seq_array(i).dig_out_struct(j).timings_array)
                        
                        delete(obj.block_seq_array(i).dig_out_struct(j).timings_array(k));
                        
                    end
                    
                end
                
                delete(obj.block_seq_array(i));
                
            end
            
            delete(obj.adw_timer);
            
            delete(obj.pgb_timer);
            
            delete(obj.net);
            
        end
        
    end
    
    methods (Static)
        
        function str = convert_time_to_string(dur)
            
            hours = floor(dur/3600);
            
            dur = dur - 3600*hours;
            
            mins = floor(dur/60);
            
            seconds = dur - 60*mins;
            
            str = [num2str(hours),'h:',num2str(mins),'min:',num2str(seconds),'s'];
            
        end
        
    end
    
end
