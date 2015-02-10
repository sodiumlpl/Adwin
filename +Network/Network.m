classdef Network < handle
    % Network class
    
    properties
       
        parent
        
    end
    
    properties % network structure
        
        net_struct % network_structure

    end
    
    methods
        
        function obj = Network(parent)
            
            obj = obj@handle;
            
            obj.parent = parent;
            
            obj.net_struct = Network.Default_parameters.remote_struct;
            
            for i=1:length(obj.net_struct)
                
                obj.net_struct(i).udp = udp(...
                    obj.net_struct(i).ip,obj.net_struct(i).port ...
                    ,'LocalPort'             ,Network.Default_parameters.server_struct.local_ports{i} ...
                    ,'Name'                  ,obj.net_struct(i).name ...
                    ,'DatagramReceivedFcn'   ,@obj.DgmRcdFcn);
                
                % Open connection
                
                fopen(obj.net_struct(i).udp);
                
            end
            
        end
        
        function DgmRcdFcn(obj,udp,~)
            
            message = fscanf(udp);

            obj.parent.execute(udp.Name,message);
            
            disp(['received message : ',message]);
            
        end
        
        function send_message(obj,name,message)
            
            disp(['sent message : ',message]);
            
            i=find(strcmp({obj.net_struct.name},name));
            
            fprintf(obj.net_struct(i).udp,message);

        end
        
        function delete(obj)
            
            for i=1:length(obj.net_struct)
                
                fclose(obj.net_struct(i).udp);
                
                delete(obj.net_struct(i).udp);
                
            end
            
        end

    end
    
    
    
end