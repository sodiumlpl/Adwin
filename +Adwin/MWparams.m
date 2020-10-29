classdef MWparams < handle
    %Block Summary of this class goes here
    %   Detailed explanation goes here
    
    properties % parent Adwin class
        
        parent_adwin    
        
    end
    
    properties % GUI structures
        
        sfg
        pfg
        
        sdg
        spg
        
        lvg
        
    end
    
    properties (SetObservable = true) % listened properties
        
        start_freq_formula
        stop_freq_formula
        
        sweep_duration_formula
        sweep_points_formula
        
        level_formula
        
        start_freq
        stop_freq
        
        sweep_duration
        sweep_points
        
        level
        
    end
    
    properties % listeners list
        
        lst_start_freq_formula
        lst_stop_freq_formula
        
        lst_sweep_duration_formula
        lst_sweep_points_formula
        
        lst_level_formula
        
        lst_start_freq
        lst_stop_freq
        
        lst_sweep_duration
        lst_sweep_points
        
        lst_level
        
    end
    
    methods
        
        function obj = MWparams ()
            
            obj = obj@handle;
            
            % Create properties listeners
            
            obj.lst_start_freq_formula = addlistener(obj,'start_freq_formula','PostSet',@obj.postset_start_freq_formula);
            obj.lst_stop_freq_formula = addlistener(obj,'stop_freq_formula','PostSet',@obj.postset_stop_freq_formula);
            
            obj.lst_sweep_duration_formula = addlistener(obj,'sweep_duration_formula','PostSet',@obj.postset_sweep_duration_formula);
            obj.lst_sweep_points_formula = addlistener(obj,'sweep_points_formula','PostSet',@obj.postset_sweep_points_formula);
            
            obj.lst_level_formula = addlistener(obj,'level_formula','PostSet',@obj.postset_level_formula);
            
            obj.lst_start_freq = addlistener(obj,'start_freq','PreSet',@obj.preset_start_freq);
            obj.lst_stop_freq = addlistener(obj,'stop_freq','PreSet',@obj.preset_stop_freq);
            
            obj.lst_sweep_duration = addlistener(obj,'sweep_duration','PreSet',@obj.preset_sweep_duration);
            obj.lst_sweep_points = addlistener(obj,'sweep_points','PreSet',@obj.preset_sweep_points);
            
            obj.lst_level = addlistener(obj,'level','PreSet',@obj.preset_level);

        end
        
        function sweep_start_freq_btd_fcn(obj,~,~)
            
            if ~isempty(obj.sfg)&&ishandle(obj.sfg.h)
                
                set(obj.sfg,'Visible','off');
                set(obj.sfg,'Visible','on');
                
            else
                
                obj.sfg.h = figure(...
                    'Name'                ,'Sweep Start Frequency' ...
                    ,'NumberTitle'        ,'off' ...
                    ,'Position'           ,[200 200 200 200] ...
                    ,'MenuBar'            ,'none'...
                    ,'CloseRequestFcn'    ,@obj.sfg_closereq ...
                    );
                
                obj.sfg.hsp1 = uipanel(...
                    'Parent'              ,obj.sfg.h ...
                    ,'Title'              ,'Sweep Start Frequency' ...
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
                
                obj.sfg.txt1 = uicontrol(...
                    'Parent'                ,obj.sfg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,'Sweep Start Frequency formula' ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.05 0.8 0.40 0.15] ...
                    );
                
                obj.sfg.edt = uicontrol(...
                    'Parent'                ,obj.sfg.hsp1 ...
                    ,'Style'                ,'edit' ...
                    ,'String'               ,obj.start_freq_formula ...
                    ,'Units'                ,Adwin.Default_parameters.Edit_Units ...
                    ,'Position'             ,[0.55 0.8 0.40 0.15] ...
                    ,'Callback'             ,@obj.sfg_edt_clb ...
                    );
                
                obj.sfg.txt2 = uicontrol(...
                    'Parent'                ,obj.sfg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,'Sweep Start Frequency' ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.05 0.6 0.40 0.15] ...
                    );
                
                obj.sfg.txt3 = uicontrol(...
                    'Parent'                ,obj.sfg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,num2str(obj.start_freq) ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,'normal' ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.55 0.6 0.40 0.15] ...
                    );
                
            end
            
        end
        
        function sfg_closereq(obj,~,~)
           
            delete(obj.sfg.h)
            
            obj.sfg = [];
            
        end
        
        function sfg_edt_clb(obj,~,~)
            
            formula = get(obj.sfg.edt,'String');
            
            obj.start_freq_formula = formula;
            
        end
        
        function sweep_stop_freq_btd_fcn(obj,~,~)
            
            if ~isempty(obj.pfg)&&ishandle(obj.pfg.h)
                
                set(obj.pfg,'Visible','off');
                set(obj.pfg,'Visible','on');
                
            else
                
                obj.pfg.h = figure(...
                    'Name'                ,'Sweep Stop Frequency' ...
                    ,'NumberTitle'        ,'off' ...
                    ,'Position'           ,[200 200 200 200] ...
                    ,'MenuBar'            ,'none'...
                    ,'CloseRequestFcn'    ,@obj.pfg_closereq ...
                    );
                
                obj.pfg.hsp1 = uipanel(...
                    'Parent'              ,obj.pfg.h ...
                    ,'Title'              ,'Sweep Stop Frequency' ...
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
                
                obj.pfg.txt1 = uicontrol(...
                    'Parent'                ,obj.pfg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,'Sweep Stop Frequency formula' ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.05 0.8 0.40 0.15] ...
                    );
                
                obj.pfg.edt = uicontrol(...
                    'Parent'                ,obj.pfg.hsp1 ...
                    ,'Style'                ,'edit' ...
                    ,'String'               ,obj.stop_freq_formula ...
                    ,'Units'                ,Adwin.Default_parameters.Edit_Units ...
                    ,'Position'             ,[0.55 0.8 0.40 0.15] ...
                    ,'Callback'             ,@obj.pfg_edt_clb ...
                    );
                
                obj.pfg.txt2 = uicontrol(...
                    'Parent'                ,obj.pfg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,'Sweep Stop Frequency' ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.05 0.6 0.40 0.15] ...
                    );
                
                obj.pfg.txt3 = uicontrol(...
                    'Parent'                ,obj.pfg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,num2str(obj.stop_freq) ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,'normal' ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.55 0.6 0.40 0.15] ...
                    );
                
            end
            
        end
        
        function pfg_closereq(obj,~,~)
           
            delete(obj.pfg.h)
            
            obj.pfg = [];
            
        end
        
        function pfg_edt_clb(obj,~,~)
            
            formula = get(obj.pfg.edt,'String');
            
            obj.stop_freq_formula = formula;
            
        end
        
        function sweep_duration_btd_fcn(obj,~,~)
            
            if ~isempty(obj.sdg)&&ishandle(obj.sdg.h)
                
                set(obj.sdg,'Visible','off');
                set(obj.sdg,'Visible','on');
                
            else
                
                obj.sdg.h = figure(...
                    'Name'                ,'Sweep Duration' ...
                    ,'NumberTitle'        ,'off' ...
                    ,'Position'           ,[200 200 200 200] ...
                    ,'MenuBar'            ,'none'...
                    ,'CloseRequestFcn'    ,@obj.sdg_closereq ...
                    );
                
                obj.sdg.hsp1 = uipanel(...
                    'Parent'              ,obj.sdg.h ...
                    ,'Title'              ,'Sweep Duration' ...
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
                
                obj.sdg.txt1 = uicontrol(...
                    'Parent'                ,obj.sdg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,'Sweep Duration formula' ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.05 0.8 0.40 0.15] ...
                    );
                
                obj.sdg.edt = uicontrol(...
                    'Parent'                ,obj.sdg.hsp1 ...
                    ,'Style'                ,'edit' ...
                    ,'String'               ,obj.sweep_duration_formula ...
                    ,'Units'                ,Adwin.Default_parameters.Edit_Units ...
                    ,'Position'             ,[0.55 0.8 0.40 0.15] ...
                    ,'Callback'             ,@obj.sdg_edt_clb ...
                    );
                
                obj.sdg.txt2 = uicontrol(...
                    'Parent'                ,obj.sdg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,'Sweep Duration' ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.05 0.6 0.40 0.15] ...
                    );
                
                obj.sdg.txt3 = uicontrol(...
                    'Parent'                ,obj.sdg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,num2str(obj.sweep_duration) ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,'normal' ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.55 0.6 0.40 0.15] ...
                    );
                
            end
            
        end
        
        function sdg_closereq(obj,~,~)
           
            delete(obj.sdg.h)
            
            obj.sdg = [];
            
        end
        
        function sdg_edt_clb(obj,~,~)
            
            formula = get(obj.sdg.edt,'String');
            
            obj.sweep_duration_formula = formula;
            
        end
        
        function sweep_points_btd_fcn(obj,~,~)
            
            if ~isempty(obj.spg)&&ishandle(obj.spg.h)
                
                set(obj.spg,'Visible','off');
                set(obj.spg,'Visible','on');
                
            else
                
                obj.spg.h = figure(...
                    'Name'                ,'Sweep Points' ...
                    ,'NumberTitle'        ,'off' ...
                    ,'Position'           ,[200 200 200 200] ...
                    ,'MenuBar'            ,'none'...
                    ,'CloseRequestFcn'    ,@obj.spg_closereq ...
                    );
                
                obj.spg.hsp1 = uipanel(...
                    'Parent'              ,obj.spg.h ...
                    ,'Title'              ,'Sweep Points' ...
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
                
                obj.spg.txt1 = uicontrol(...
                    'Parent'                ,obj.spg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,'Sweep Points formula' ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.05 0.8 0.40 0.15] ...
                    );
                
                obj.spg.edt = uicontrol(...
                    'Parent'                ,obj.spg.hsp1 ...
                    ,'Style'                ,'edit' ...
                    ,'String'               ,obj.sweep_points_formula ...
                    ,'Units'                ,Adwin.Default_parameters.Edit_Units ...
                    ,'Position'             ,[0.55 0.8 0.40 0.15] ...
                    ,'Callback'             ,@obj.spg_edt_clb ...
                    );
                
                obj.spg.txt2 = uicontrol(...
                    'Parent'                ,obj.spg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,'Sweep Points' ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.05 0.6 0.40 0.15] ...
                    );
                
                obj.spg.txt3 = uicontrol(...
                    'Parent'                ,obj.spg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,num2str(obj.sweep_points) ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,'normal' ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.55 0.6 0.40 0.15] ...
                    );
                
            end
            
        end
        
        function spg_closereq(obj,~,~)
           
            delete(obj.spg.h)
            
            obj.spg = [];
            
        end
        
        function spg_edt_clb(obj,~,~)
            
            formula = get(obj.spg.edt,'String');
            
            obj.sweep_points_formula = formula;
            
        end
        
        function mw_level_btd_fcn(obj,~,~)
            
            if ~isempty(obj.lvg)&&ishandle(obj.lvg.h)
                
                set(obj.lvg,'Visible','off');
                set(obj.lvg,'Visible','on');
                
            else
                
                obj.lvg.h = figure(...
                    'Name'                ,'MW Level' ...
                    ,'NumberTitle'        ,'off' ...
                    ,'Position'           ,[200 200 200 200] ...
                    ,'MenuBar'            ,'none'...
                    ,'CloseRequestFcn'    ,@obj.lvg_closereq ...
                    );
                
                obj.lvg.hsp1 = uipanel(...
                    'Parent'              ,obj.lvg.h ...
                    ,'Title'              ,'MW Level' ...
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
                
                obj.lvg.txt1 = uicontrol(...
                    'Parent'                ,obj.lvg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,'MW Level formula' ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.05 0.8 0.40 0.15] ...
                    );
                
                obj.lvg.edt = uicontrol(...
                    'Parent'                ,obj.lvg.hsp1 ...
                    ,'Style'                ,'edit' ...
                    ,'String'               ,obj.level_formula ...
                    ,'Units'                ,Adwin.Default_parameters.Edit_Units ...
                    ,'Position'             ,[0.55 0.8 0.40 0.15] ...
                    ,'Callback'             ,@obj.lvg_edt_clb ...
                    );
                
                obj.lvg.txt2 = uicontrol(...
                    'Parent'                ,obj.lvg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,'MW Level' ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,Adwin.Default_parameters.Text_FontWeight ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.05 0.6 0.40 0.15] ...
                    );
                
                obj.lvg.txt3 = uicontrol(...
                    'Parent'                ,obj.lvg.hsp1 ...
                    ,'Style'                ,'text' ...
                    ,'String'               ,num2str(obj.level) ...
                    ,'FontName'             ,Adwin.Default_parameters.Text_FontName ...
                    ,'FontSize'             ,Adwin.Default_parameters.Text_FontSize ...
                    ,'FontUnits'            ,Adwin.Default_parameters.Text_FontUnits ...
                    ,'FontWeight'           ,'normal' ...
                    ,'HorizontalAlignment'  ,Adwin.Default_parameters.Text_HorizontalAlignment ...
                    ,'Units'                ,Adwin.Default_parameters.Text_Units ...
                    ,'Position'             ,[0.55 0.6 0.40 0.15] ...
                    );
                
            end
            
        end
        
        function lvg_closereq(obj,~,~)
           
            delete(obj.lvg.h)
            
            obj.lvg = [];
            
        end
        
        function lvg_edt_clb(obj,~,~)
            
            formula = get(obj.lvg.edt,'String');
            
            obj.level_formula = formula;
            
        end
        
        function postset_start_freq_formula(obj,~,~)
            
           obj.start_freq = evalin('base',obj.start_freq_formula);
           
           if ~isempty(obj.sfg)&&ishandle(obj.sfg.h)
               
               set(obj.sfg.txt3,'String',num2str(obj.start_freq))
               
           end
           
           if ~isempty(obj.parent_adwin.srf)&&ishandle(obj.parent_adwin.srf.h)&&isfield(obj.parent_adwin.srf,'txt2_1')
               
               set(obj.parent_adwin.srf.txt4,'String',obj.start_freq_formula)
               
           end

        end
        
        function postset_stop_freq_formula(obj,~,~)
            
           obj.stop_freq = evalin('base',obj.stop_freq_formula);
           
           if ~isempty(obj.pfg)&&ishandle(obj.pfg.h)
               
               set(obj.pfg.txt3,'String',num2str(obj.stop_freq))
               
           end
           
           if ~isempty(obj.parent_adwin.srf)&&ishandle(obj.parent_adwin.srf.h)&&isfield(obj.parent_adwin.srf,'txt2_2')
               
               set(obj.parent_adwin.srf.txt7,'String',obj.stop_freq_formula)
               
           end

        end
        
        function postset_sweep_duration_formula(obj,~,~)
            
           obj.sweep_duration = evalin('base',obj.sweep_duration_formula);
           
           if ~isempty(obj.sdg)&&ishandle(obj.sdg.h)
               
               set(obj.sdg.txt3,'String',num2str(obj.sweep_duration))
               
           end
           
           if ~isempty(obj.parent_adwin.srf)&&ishandle(obj.parent_adwin.srf.h)&&isfield(obj.parent_adwin.srf,'txt2_3')
               
               set(obj.parent_adwin.srf.txt10,'String',obj.sweep_duration_formula)
               
           end

        end
        
        function postset_sweep_points_formula(obj,~,~)
            
           obj.sweep_points = evalin('base',obj.sweep_points_formula);
           
           if ~isempty(obj.spg)&&ishandle(obj.spg.h)
               
               set(obj.spg.txt3,'String',num2str(obj.sweep_points))
               
           end
           
           if ~isempty(obj.parent_adwin.srf)&&ishandle(obj.parent_adwin.srf.h)&&isfield(obj.parent_adwin.srf,'txt2_4')
               
               set(obj.parent_adwin.srf.txt13,'String',obj.sweep_points_formula)
               
           end

        end
        
        function postset_level_formula(obj,~,~)
            
           obj.level = evalin('base',obj.level_formula);
           
           if ~isempty(obj.lvg)&&ishandle(obj.lvg.h)
               
               set(obj.lvg.txt3,'String',num2str(obj.level))
               
           end
           
           if ~isempty(obj.parent_adwin.srf)&&ishandle(obj.parent_adwin.srf.h)&&isfield(obj.parent_adwin.srf,'txt2_5')
               
               set(obj.parent_adwin.srf.txt15,'String',obj.level_formula)
               
           end

        end
        
        function preset_start_freq(obj,~,~)
            
            new_value = evalin('base',obj.start_freq_formula);
            
            if ~isequal(new_value,obj.start_freq)
               
                obj.parent_adwin.mw_seq_changed = 1;
                
            end
            
        end
        
        function preset_stop_freq(obj,~,~)
            
            new_value = evalin('base',obj.stop_freq_formula);
            
            if ~isequal(new_value,obj.stop_freq)
               
                obj.parent_adwin.mw_seq_changed = 1;
                
            end
            
        end
        
        function preset_sweep_duration(obj,~,~)
            
            new_value = evalin('base',obj.sweep_duration_formula);
            
            if ~isequal(new_value,obj.sweep_duration)
               
                obj.parent_adwin.mw_seq_changed = 1;
                
            end
            
        end
        
        function preset_sweep_points(obj,~,~)
            
            new_value = evalin('base',obj.sweep_points_formula);
            
            if ~isequal(new_value,obj.sweep_points)
               
                obj.parent_adwin.mw_seq_changed = 1;
                
            end
            
        end
        
        function preset_level(obj,~,~)
            
            new_value = evalin('base',obj.level_formula);
            
            if ~isequal(new_value,obj.level)
               
                obj.parent_adwin.mw_seq_changed = 1;
                
            end
            
        end
        
    end
    
end

