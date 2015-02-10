classdef Default_parameters
    % Default_parameters class contains the value of every Network
    % parameters
    
    properties (Constant) % Defaults Panel properties

        remote_struct = struct(...
             'name'        ,{'BEC009','main'} ...
            ,'ip'          ,{'192.168.137.156','192.168.137.1'} ...
            ,'port'        ,{9094,9093}...
            );
        % {'192.168.137.165','192.168.137.1'}
        server_struct = struct(...
             'name'               ,{'BEC008'} ...
            ,'ip'                 ,{'192.168.137.76'} ...
            ,'local_ports'        ,{{9090,9091}}...
            );
        % {'192.168.137.152'}
    end

    
    methods
    end
    
end