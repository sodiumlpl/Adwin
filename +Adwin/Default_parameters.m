classdef Default_parameters
    % Default_parameters class contains the value of every Adwin GUI
    % parameters
    
    properties (Constant)
        
        root_path = 'C:\Users\BEC\Documents\MATLAB\13_Adwin\';
        data_root_path = 'C:\Users\BEC\Documents\data\';
        
        params_path = '\\TIBO-HP\Data\Tmp\';
        
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
        
        dig_out_nbr = 32;
        
        dig_out_name = {...
             '1 : AOM Zeeman'...           % Out 1
            ,'2 : AOM MOT'...              % Out 2
            ,'3 : AOM Imaging'...          % Out 3
            ,'4 : Zeeman Shutter'...       % Out 4
            ,'5 : MOT Shutter'...          % Out 5
            ,'6 : Imaging Shutter'...      % Out 6
            ,'7 : Repumper Shutter'...     % Out 7
            ,'Out 8'...                    % Out 8
            ,'9 : Transport inhib 2'...    % Out 9
            ,'Out 10'...                   % Out 10
            ,'Out 11'...                   % Out 11
            ,'Out 12'...                   % Out 12
            ,'13 : Camera Trigger'...      % Out 13
            ,'Out 14'...                   % Out 14
            ,'Out 15'...                   % Out 15
            ,'16 : AOM 200 MHz'...         % Out 16
            ,'Out 17'...                   % Out 17
            ,'Out 18'...                   % Out 18
            ,'Out 19'...                   % Out 19
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
            ,'31 : AOM 200 MHz'...         % Out 31
            ,'32 : AOMs On'...             % Out 32
            };
        
        dig_out_init = {...
             1 ...                % Out 1
            ,1 ...                % Out 2
            ,1 ...                % Out 3
            ,0 ...                % Out 4
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
            ,1 ...               % Out 16
            ,0 ...               % Out 17
            ,0 ...               % Out 18
            ,0 ...               % Out 19
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
            ,1 ...               % Out 31
            ,1 ...               % Out 32
            };
        
    end
    
    properties (Constant) % Default analog outputs properties 
        
        ana_crd = 2;         % Number of analog outputs cards
        
        ana_crd_out_nbr = 8; % Number of outputs per analog outputs card
        
        ana_data_time_array = [3,5];
        
        ana_data_out_array = [4,6];
        
        ana_out_name = {...
             '1 : Zeeman AOM freq [MHz]' ...       % Ana 1
            ,'2 : MOT AOM freq [MHz]' ...          % Ana 2
            ,'3 : Imaging AOM freq [MHz]' ...      % Ana 3
            ,'4 : MOT AOM eff' ...                 % Ana 4
            ,'5 : Imaging AOM eff' ...             % Ana 5
            ,'6 : MOT EOM freq [GHz]' ...          % Ana 6
            ,'7 : Repumper AOM freq [GHz]' ...     % Ana 7
            ,'8 : Zeeman EOM freq [GHz]' ...       % Ana 8
            ,'9 : Repumper AOM amp'...             % Ana 9
            ,'10 : Zeeman EOM amp'...              % Ana 10
            ,'11 : Power Supply Int [A]'...        % Ana 11
            ,'12: MOT EOM amp'...                  % Ana 12
            ,'Ana 13'...                           % Ana 13
            ,'Ana 14'...                           % Ana 14
            ,'15 : Lock AOM eff'...                % Ana 15
            ,'16 : Zeeman AOM eff'...              % Ana 16
            };
        
        ana_out_init = {...
             295.3 ...            % Ana 1
            ,307 ...              % Ana 2
            ,287.3 ...            % Ana 3
            ,1 ...                % Ana 4
            ,1 ...                % Ana 5
            ,1.71 ...             % Ana 6
            ,1.71 ...             % Ana 7
            ,1.71 ...             % Ana 8
            ,1 ...                % Ana 9
            ,1 ...                % Ana 10
            ,0 ...                % Ana 11
            ,0 ...                % Ana 12
            ,0 ...                % Ana 13
            ,0 ...                % Ana 14
            ,0.26 ...             % Ana 15
            ,1 ...                % Ana 16
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
        
        max_step_ana = 10100; % maximum number of steps of a analog sequence
        
        t_res = 0.01; % time resolution in [ms]
        
        seq_duration = 12;   % sequence total duration
        
        pgb_duration = 1; % duration of each step of the progress bar
        
    end
    
    methods
    end
    
end