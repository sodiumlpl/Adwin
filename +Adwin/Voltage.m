classdef Voltage < handle
    %Voltage Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties
        
        parent_block
        
    end
    
    properties (SetObservable = true) % listened properties
        
        value_formula        % value formula for the analog output
        
    end
    
    properties
        
        value        % calibrated value corresponding to the formula
       
        voltage      % voltage corresponding to the calibrated value (-10 V -> 10 V)
        
        binary       % binary number corresponding to the voltage (16 bits)
        
        out_nbr      % corresponding analog output for this voltage
        
        voltage_nbr     % Number of the Timing within the Block
        
        behaviour    % behaviour of the voltage 'C' -> Constant, 'R' -> Ramp, 'S' -> Splines
        
        fonction
        
    end
    
    properties % listeners list
        
        lst_value_formula
        
    end
    
    methods
        
        function obj = Voltage ()
            
            obj = obj@handle;
            
            obj.lst_value_formula = addlistener(obj,'value_formula','PostSet',@obj.postset_value_formula);
            
        end
        
        function postset_value_formula(obj,~,~)
            
            obj.value=evalin('base',obj.value_formula);
            
            eval(['obj.voltage = Adwin.Calibrations.ana_out_',num2str(obj.out_nbr),'(obj.value);']);
            
            obj.binary = max(min(round(obj.voltage/(10/2^15))+2^15,2^16-1),0);
            
            if ~isempty(obj.parent_block.asg)&&ishandle(obj.parent_block.asg.h)
                
                i = mod(obj.out_nbr,2*Adwin.Default_parameters.ana_crd_out_nbr);
                if isequal(i,0)
                    
                    i = 2*Adwin.Default_parameters.ana_crd_out_nbr;

                end
                
                l = (obj.out_nbr-i)/(2*Adwin.Default_parameters.ana_crd_out_nbr)+1;
                
                eval(['set(obj.parent_block.asg.text4',num2str(l),'_',num2str(i),'_',num2str(obj.voltage_nbr), ...
                            ',''String''              ,num2str(obj.value)', ...
                            ');']);
                
            end
            
        end
        
    end
    
end

