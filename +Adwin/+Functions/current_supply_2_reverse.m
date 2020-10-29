function val = current_supply_2_reverse(t)

load C:\Users\BEC\Documents\MATLAB\13_Adwin\sequence_manager\+Adwin\+Functions\current_supply_2.mat

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define position vs time for tanh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L = evalin('base','trspt_length'); % Length of the transport
% 
% d = evalin('base','trspt_shape'); % Optimised value : minimize the maximum acceleration
% 
% Mag_Trap_current = evalin('base','Mag_Trap_current'); % Initial value of the current in the magnetic coils
% 
% Mag_Trap_ref_current = evalin('base','Mag_Trap_ref_current'); % Reference value of the current in the magnetic coils
% 
% c = 2^(-3/2-d)*sqrt((1+d)*(2+d))/d; % Optimised value : flat velocity at the center of the transport
% 
% y_pos = @(t) (1+tanh(-c./t.^d+c./(1-t).^d))*L/2; % position
% 
% % Calculates positions
% 
% val = Mag_Trap_current/Mag_Trap_ref_current*ppval(pp2,y_pos(1-t));
% 
% clear pp2 ypos

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define position vs time for erf
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

L = evalin('base','trspt_length'); % Length of the transport

d = evalin('base','trspt_shape'); % Optimised value : minimize the maximum acceleration

Mag_Trap_current = evalin('base','Mag_Trap_current'); % Initial value of the current in the magnetic coils

Mag_Trap_ref_current = evalin('base','Mag_Trap_ref_current'); % Reference value of the current in the magnetic coils

c = 2^(-3/2-d)*sqrt((1+d)*(2+d))/d; % Optimised value : flat velocity at the center of the transport

y_pos = @(t) (1+erf(-c./t.^d+c./(1-t).^d))*L/2; % position

% Calculates positions

val = Mag_Trap_current/Mag_Trap_ref_current*ppval(pp2,y_pos(1-t));

clear pp2 ypos

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define position vs time for constant velocity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L = evalin('base','trspt_length'); % Length of the transport
% 
% % L = evalin('base','trspt_stop'); % Length of the transport
% 
% Mag_Trap_current = evalin('base','Mag_Trap_current'); % Initial value of the current in the magnetic coils
% 
% Mag_Trap_ref_current = evalin('base','Mag_Trap_ref_current'); % Reference value of the current in the magnetic coils
% 
% y_pos = @(t) L*t; % position
% 
% % Calculates positions
% 
% val = Mag_Trap_current/Mag_Trap_ref_current*ppval(pp2,y_pos(1-t));
% 
% clear pp2 ypos

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define position vs time for constant acceleration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L = evalin('base','trspt_length'); % Length of the transport
% 
% Mag_Trap_current = evalin('base','Mag_Trap_current'); % Initial value of the current in the magnetic coils
% 
% Mag_Trap_ref_current = evalin('base','Mag_Trap_ref_current'); % Reference value of the current in the magnetic coils
% 
% y_pos = @(t) 2*L*t.^2.*(t<=0.5)+(L/2+2*L*(t-0.5)-2*L*(t-0.5).^2).*(t>0.5); % position
% 
% % Calculates positions
% 
% val = Mag_Trap_current/Mag_Trap_ref_current*ppval(pp2,y_pos(1-t));
% 
% clear pp2 ypos

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define position vs time for sinusoidal acceleration
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L = evalin('base','trspt_length'); % Length of the transport
% 
% Mag_Trap_current = evalin('base','Mag_Trap_current'); % Initial value of the current in the magnetic coils
% 
% Mag_Trap_ref_current = evalin('base','Mag_Trap_ref_current'); % Reference value of the current in the magnetic coils
% 
% y_pos = @(t) L*t-L/(2*pi)*sin(2*pi*t); % position
% 
% % Calculates positions
% 
% val = Mag_Trap_current/Mag_Trap_ref_current*ppval(pp2,y_pos(1-t));
% 
% clear pp2 ypos

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Define position vs time for constant acceleration with pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L = evalin('base','trspt_length'); % Length of the transport
% 
% dL = evalin('base','trspt_dL'); % Length of the first step of the transport
% 
% T0 = evalin('base','trspt_t1'); % total duration of the transport
% 
% TdL = evalin('base','trspt_TdL'); % duration of the first step of the transport
% 
% Tpause = evalin('base','trspt_pause'); % duration of the pause at the middle of the transport
% 
% T1=TdL/T0;
% 
% T3 = Tpause/T0;
% 
% T2 = (1-(2*T1+T3))/2;
% 
% a0 = (L/2-dL)/(T2^2/2+T1*T2);
% 
% a1 = 2*dL/T1^2;
% 
% Mag_Trap_current = evalin('base','Mag_Trap_current'); % Initial value of the current in the magnetic coils
% 
% Mag_Trap_ref_current = evalin('base','Mag_Trap_ref_current'); % Reference value of the current in the magnetic coils
% 
% y_pos = @(t) a1*t.^2/2.*(t<=T1)+(dL+a0*(t-T1).^2/2+a0*T1*(t-T1)).*((t>T1)&(t<=T1+T2))+(L/2)*((t>T1+T2)&(t<=T1+T2+T3)) ...
%     + (L/2+a0*(T1+T2)*(t-(T1+T2+T3))-a0*(t-(T1+T2+T3)).^2/2).*((t>T1+T2+T3)&(t<=T1+T2+T3+T2)) ...
%     + (L-dL+a1*T1*(t-(T1+T2+T3+T2))-a1*(t-(T1+T2+T3+T2)).^2/2).*((t>T1+T2+T3+T2)&(t<=1)); % position
% 
% % Calculates positions
% 
% val = Mag_Trap_current/Mag_Trap_ref_current*ppval(pp2,y_pos(1-t));
% 
% clear pp2 ypos

end