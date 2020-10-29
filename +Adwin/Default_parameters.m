classdef Default_parameters
    % Default_parameters class contains the value of every Adwin GUI
    % parameters
    
    properties (Constant)
        
        root_path = 'C:\Users\BEC\Documents\MATLAB\13_Adwin\';
        data_root_path = 'C:\Users\BEC\Documents\data\';
        
        tabor_data_path = '\\BEC009-T3600\Users\BEC\Documents\MATLAB\20\09_tabor\';
        
        params_path = '\\E010-BEC-PC03\Data\Tmp\';
        
    end
    
    properties (Constant) % Defaults Panel properties
        
        Panel_BackgroundColor = [0.929 0.929 0.929];
        Panel_ForegroundColor = [0. 0. 0.];
        Panel_HighlightColor = [0.5 0.5 0.5];
        Panel_ShadowColor = [0.7 0.7 0.7];
        
        Panel_Units = 'normalized';
        
        Panel_FontName = 'Helvetica';
        Panel_FontSize = 12;
        Panel_FontUnits = 'points';
        Panel_FontWeight = 'bold';
        
        Panel_SelectionHighlight = 'off';
        
        
    end
    
    properties (Constant) % Defaults Panel properties
        
        Tab_BackgroundColor = [0.929 0.929 0.929];
        Tab_ForegroundColor = [0. 0. 0.];
        
        Tab_Units = 'normalized';

    end
    
    properties (Constant) % Defaults Text properties
        
        Text_Units = 'normalized';
        
        Text_FontName = 'Helvetica';
        Text_FontSize =8;
        Text_FontUnits = 'points';
        Text_FontWeight = 'bold';

        Text_HorizontalAlignment = 'center';

    end
    
    properties (Constant) % Defaults Edit properties
                
        Edit_Units = 'normalized';
        
        Edit_FontName = 'Helvetica';
        Edit_FontSize = 8;
        Edit_FontUnits = 'points';
        Edit_FontWeight = 'bold';
        
        Edit_HorizontalAlignment = 'center';
        
    end
    
    properties (Constant) % Defaults Pushbutton properties
        
        Pushbutton_FontName = 'Helvetica';
        Pushbutton_FontSize = 9;
        Pushbutton_FontUnits = 'points';
        Pushbutton_FontWeight = 'bold';
        
        Pushbutton_Units = 'normalized';

    end
    
    properties (Constant) % Defaults Radiobutton properties
        
        Radiobutton_FontName = 'Helvetica';
        Radiobutton_FontSize = 9;
        Radiobutton_FontUnits = 'points';
        Radiobutton_FontWeight = 'bold';
        
        Radiobutton_Units = 'normalized';

    end
    
    properties (Constant) % Defaults Listbox properties
        
        Listbox_Units = 'normalized';

    end
    
    properties (Constant) % Defaults Checkbox properties
        
        Checkbox_Units = 'normalized';

    end
    
    properties (Constant) % Defaults Axes properties
        
        Axes_Units = 'normalized';
        
        Axes_FontName = 'Helvetica';
        Axes_FontSize = 9;
        Axes_FontUnits = 'points';
        Axes_FontWeight = 'normal';
        
    end
    
    properties (Constant) % Default digital outputs properties
        
        dig_crd = 2;         % Number of digital outputs cards
        
        dig_out_nbr = 32;
        
        dig_data_time_array = [1,7];
        
        dig_data_out_array = [2,8];
        
        dig_out_name = {...
             '1 : AOM Zeeman'...           % Out 1
            ,'2 : AOM MOT'...              % Out 2
            ,'3 : AOM Rep+Pol'...          % Out 3
            ,'4 : EOM MOT'...              % Out 4
            ,'Out 5'...                    % Out 5
            ,'Out 6'...                    % Out 6
            ,'Out 7'...                    % Out 7
            ,'8 : AOM 1.7 GHz'...          % Out 8
            ,'9 : Current Supply 2'...     % Out 9
            ,'Out 10'...                   % Out 10
            ,'Out 11'...                   % Out 11
            ,'12 : Pixelfly Trigger'...    % Out 12
            ,'13 : ImagSource Trigger'...  % Out 13
            ,'Out 14'...                   % Out 14
            ,'15 : Current Supply 1'...    % Out 15
            ,'Out 16'...                   % Out 16
            ,'17 : Current Supply 3'...    % Out 17
            ,'18 : Transport clock'...     % Out 18
            ,'19 : Transport direction'... % Out 19
            ,'Out 20'...                   % Out 20
            ,'Out 21'...                   % Out 21
            ,'Out 22'...                   % Out 22
            ,'Out 23'...                   % Out 23
            ,'Out 24'...                   % Out 24
            ,'Out 25'...                   % Out 25
            ,'Out 26'...                   % Out 26
            ,'Out 27'...                   % Out 27
            ,'Out 28'...                   % Out 28
            ,'Out 29'...                   % Out 29
            ,'30 : Mechanical Shutter'...  % Out 30
            ,'Out 31'...                   % Out 31
            ,'Out 32'...                   % Out 32
            ,'33 : Rep+Pol Shutter'...     % Out 33
            ,'34 : MOT Shutter'...         % Out 34
            ,'35 : Imaging Shutter'...     % Out 35
            ,'36 : Zeeman Shutter'...      % Out 36
            ,'37 : Trigger SMC100A'...     % Out 37
            ,'38 : Trigger Tabor evap'...  % Out 38
            ,'Out 39'...                   % Out 39
            ,'Out 40'...                   % Out 40
            ,'Out 41'...                   % Out 41
            ,'Out 42'...                   % Out 42
            ,'Out 43'...                   % Out 43
            ,'Out 44'...                   % Out 44
            ,'Out 45'...                   % Out 45
            ,'Out 46'...                   % Out 46
            ,'Out 47'...                   % Out 47
            ,'Out 48'...                   % Out 48
            ,'Out 49'...                   % Out 49
            ,'Out 50'...                   % Out 50
            ,'Out 51'...                   % Out 51
            ,'Out 52'...                   % Out 52
            ,'Out 53'...                   % Out 53
            ,'Out 54'...                   % Out 54
            ,'Out 55'...                   % Out 55
            ,'Out 56'...                   % Out 56
            ,'Out 57'...                   % Out 57
            ,'Out 58'...                   % Out 58
            ,'Out 59'...                   % Out 59
            ,'Out 60'...                   % Out 60
            ,'Out 61'...                   % Out 61
            ,'Out 62'...                   % Out 62
            ,'Out 63'...                   % Out 63
            ,'Out 64'...                   % Out 64
            };
        
        dig_out_init = {...
             1 ...                % Out 1
            ,1 ...                % Out 2
            ,1 ...                % Out 3
            ,1 ...                % Out 4
            ,0 ...                % Out 5
            ,0 ...                % Out 6
            ,0 ...                % Out 7
            ,0 ...                % Out 8
            ,0 ...                % Out 9
            ,0 ...               % Out 10
            ,0 ...               % Out 11
            ,0 ...               % Out 12
            ,0 ...               % Out 13
            ,0 ...               % Out 14
            ,0 ...               % Out 15
            ,0 ...               % Out 16
            ,0 ...               % Out 17
            ,0 ...               % Out 18
            ,1 ...               % Out 19
            ,0 ...               % Out 20
            ,0 ...               % Out 21
            ,0 ...               % Out 22
            ,0 ...               % Out 23
            ,0 ...               % Out 24
            ,0 ...               % Out 25
            ,0 ...               % Out 26
            ,0 ...               % Out 27
            ,0 ...               % Out 28
            ,0 ...               % Out 29
            ,0 ...               % Out 30
            ,0 ...               % Out 31
            ,0 ...               % Out 32
            ,0 ...               % Out 33
            ,0 ...               % Out 34
            ,0 ...               % Out 35
            ,0 ...               % Out 36
            ,0 ...               % Out 37
            ,0 ...               % Out 38
            ,0 ...               % Out 39
            ,0 ...               % Out 40
            ,0 ...               % Out 41
            ,0 ...               % Out 42
            ,0 ...               % Out 43
            ,0 ...               % Out 44
            ,0 ...               % Out 45
            ,0 ...               % Out 46
            ,0 ...               % Out 47
            ,0 ...               % Out 48
            ,0 ...               % Out 49
            ,0 ...               % Out 50
            ,0 ...               % Out 51
            ,0 ...               % Out 52
            ,0 ...               % Out 53
            ,0 ...               % Out 54
            ,0 ...               % Out 55
            ,0 ...               % Out 56
            ,0 ...               % Out 57
            ,0 ...               % Out 58
            ,0 ...               % Out 59
            ,0 ...               % Out 60
            ,0 ...               % Out 61
            ,0 ...               % Out 62
            ,0 ...               % Out 63
            ,0 ...               % Out 64
            };
        
    end
    
    properties (Constant) % Default analog outputs properties 
        
        ana_crd = 4;         % Number of analog outputs cards
        
        ana_crd_out_nbr = 8; % Number of outputs per analog outputs card
        
        ana_data_time_array = [3,5,9,11];
        
        ana_data_out_array = [4,6,10,12];
        
        ana_out_name = {...
             '1 : Zeeman AOM freq [MHz]' ...       % Ana 1
            ,'2 : MOT AOM freq [MHz]' ...          % Ana 2
            ,'3 : Rep+Pol AOM freq [MHz]' ...      % Ana 3
            ,'4 : MOT AOM eff' ...                 % Ana 4
            ,'5 : Rep+Pol AOM eff' ...             % Ana 5
            ,'6 : MOT EOM freq [GHz]' ...          % Ana 6
            ,'7 : AOM 1.7GHz freq [GHz]' ...       % Ana 7
            ,'8 : Rep+Pol EOM freq [GHz]' ...      % Ana 8
            ,'9 : AOM 1.7GHz eff'...               % Ana 9
            ,'10 : Rep+Pol EOM eff'...             % Ana 10
            ,'11 : Current Supply 2 [A]'...        % Ana 11
            ,'12 : MOT EOM eff'...                 % Ana 12
            ,'13 : Current Supply 1 [A]'...        % Ana 13
            ,'14 : Current Supply 2 [V]'...        % Ana 14
            ,'15 : Current Supply 3 [A]'...        % Ana 15
            ,'16 : Zeeman AOM eff'...              % Ana 16
            ,'17 : Current Supply 1 [V]' ...       % Ana 17
            ,'18 : Current Supply 3 [V]' ...       % Ana 18
            ,'19 : SM 52-30 [A]' ...               % Ana 19
            ,'20 : SM 52-30 [V]' ...               % Ana 20
            ,'21 : SM 70-22 [A]' ...               % Ana 21
            ,'22 : SM 70-22 [V]' ...               % Ana 22
            ,'23 : SM 70-AR-24 [A]' ...            % Ana 23
            ,'24 : SM 70-AR-24 [V]' ...            % Ana 24
            ,'25 : SM 15-100 [A]'...               % Ana 25
            ,'26 : SM 15-100 [V]'...               % Ana 26
            ,'27 : Ana 27'...                      % Ana 27
            ,'28 : Ana 28'...                      % Ana 28
            ,'29 : Ana 29'...                      % Ana 29
            ,'30 : Ana 30'...                      % Ana 30
            ,'31 : Ana 31'...                      % Ana 31
            ,'32 : Ana 32'...                      % Ana 32
            };
        
        ana_out_init = {...
             193 ...              % Ana 1
            ,116.5 ...            % Ana 2
            ,90 ...               % Ana 3
            ,1 ...                % Ana 4
            ,1 ...                % Ana 5
            ,1.711 ...            % Ana 6
            ,1.71 ...             % Ana 7
            ,1.771 ...            % Ana 8
            ,1 ...                % Ana 9
            ,0.5 ...              % Ana 10
            ,3.75 ...             % Ana 11
            ,0 ...                % Ana 12
            ,0 ...                % Ana 13
            ,0 ...                % Ana 14
            ,0 ...                % Ana 15
            ,1 ...                % Ana 16
            ,0 ...                % Ana 17
            ,0 ...                % Ana 18
            ,0 ...                % Ana 19
            ,0 ...                % Ana 20
            ,0 ...                % Ana 21
            ,0 ...                % Ana 22
            ,0 ...                % Ana 23
            ,0 ...                % Ana 24
            ,0 ...                % Ana 25
            ,0 ...                % Ana 26
            ,0 ...                % Ana 27
            ,0 ...                % Ana 28
            ,0 ...                % Ana 29
            ,0 ...                % Ana 30
            ,0 ...                % Ana 31
            ,0 ...                % Ana 32
            };
        
    end
    
    properties (Constant) % Default parameters properties
        
        nb_r_stat_params = 15;
        nb_c_stat_params = 10;
        
        nb_r_dep_params = 15;
        nb_c_dep_params = 10;
        
        nb_r_scans_params = 30;
        nb_c_scans_params = 5;
        
    end
    
    properties (Constant) % Default Adwin properties
        
        max_step_dig = 101; % maximum number of steps of a digital sequence
        
        max_step_ana = 1010000; % maximum number of steps of a analog sequence
        
        seq_duration = 12;   % sequence total duration
        
        pgb_duration = 1; % duration of each step of the progress bar
        
    end
    
    properties (Constant) % MW parameters
        
        mw_start_freq = 1610; % [MHz]
        mw_stop_freq = 1600; % [MHz]
        
        mw_sweep_duration = 100; % [ms]
        mw_sweep_points = 100;
        
        mw_level = 0; % [dBm]
        
    end
    
    methods
    end
    
end