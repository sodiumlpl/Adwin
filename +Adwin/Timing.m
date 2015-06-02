classdef Timing < handle
    %Timing Summary of this class goes here
    %   Detailed explanation goes here
    
    
    properties
        
        parent_block
        
    end
    
    properties
        
        previous       % previous Timing
        
        next           % next Timing
        
        time_ref       % Time reference : empty means Time reference of the Block,
                       % otherwise it is the order of the Timing reference in the array.
        
        abs_out        % absolute Timing (from the beginning of the Block sequence)
        
        out            % Timing (from the previous Timing)
        
        ord
        
        out_nbr        % Number of the Adwin output
        
        timing_nbr     % Number of the Timing within the Block
        
        type           % either 'analog' or 'digital'
        
    end
    
    properties (SetObservable = true) % listened properties
        
        formula        % formula that defines the timing of the event
           
        state          % state of the output during the Timing
        
    end
    
    properties % listeners list
        
        lst_formula
        
        lst_state
        
    end
    
    methods
        
        function obj = Timing ()
            
            obj = obj@handle;
            
            obj.lst_formula = addlistener(obj,'formula','PostSet',@obj.postset_formula);
            
            obj.lst_state = addlistener(obj,'state','PostSet',@obj.postset_state);
            
        end
        
        function postset_formula(obj,~,~)
            
            obj.set_out;
            
            if ~isempty(obj.next)
                
                obj.next.set_out;
                
            end
            
        end
        
        function postset_state(obj,~,~)
            
            if ~isempty(obj.next)
                
                obj.next.state = ~obj.state;
                
            else
                
                if ~isempty(obj.parent_block.next)
                    
                    obj.parent_block.next.dig_out_struct(obj.out_nbr).timings_array(1).state = obj.state;
                    
                end
                
            end
            
        end
        
        function set_out(obj)
            
            if ~isempty(obj.time_ref)
                
                %t_res
                %obj.abs_out = obj.time_ref.abs_out + round(evalin('base',obj.formula)/Adwin.Default_parameters.t_res)*Adwin.Default_parameters.t_res;
                obj.abs_out = obj.time_ref.abs_out + round(evalin('base',obj.formula)/Adwin.Default_parameters.t_res);
                
                obj.out = obj.abs_out - obj.previous.abs_out;
                
            else
                
                %t_res
                %obj.abs_out = round(evalin('base',obj.formula)/Adwin.Default_parameters.t_res)*Adwin.Default_parameters.t_res;
                obj.abs_out = round(evalin('base',obj.formula)/Adwin.Default_parameters.t_res);
                
                if ~isempty(obj.previous)
                    
                    obj.out = obj.abs_out - obj.previous.abs_out;
                    
                else
                    
                    obj.out = obj.abs_out;
                    
                end
                
            end
            
            switch obj.type
                
                case 'digital'
                    
                    if ~isempty(obj.parent_block.bsg)&&ishandle(obj.parent_block.bsg.h)
                        
                        %t_res
%                         eval(['set(obj.parent_block.bsg.text',num2str(obj.out_nbr),'_',num2str(obj.timing_nbr), ...
%                            ',''String''              ,num2str(obj.out)', ...
%                            ');']);
                        eval(['set(obj.parent_block.bsg.text',num2str(obj.out_nbr),'_',num2str(obj.timing_nbr), ...
                            ',''String''              ,num2str(obj.out*Adwin.Default_parameters.t_res)', ...
                            ');']);
                    end
                    
                case 'analog'
                    
                    if ~isempty(obj.parent_block.asg)&&ishandle(obj.parent_block.asg.h)
                        
                        %%t_res
%                         eval(['set(obj.parent_block.asg.text3',num2str(obj.out_nbr),'_',num2str(obj.timing_nbr), ...
%                            ',''String''              ,num2str(obj.out)', ...
%                            ');']);
                        eval(['set(obj.parent_block.asg.text3',num2str(obj.out_nbr),'_',num2str(obj.timing_nbr), ...
                            ',''String''              ,num2str(obj.out*Adwin.Default_parameters.t_res)', ...
                            ');']);
                    end

            end
            
        end
        
    end
    
end

