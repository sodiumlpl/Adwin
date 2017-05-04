%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% ADWIN Digital Sequence %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Block test_mag_transport %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array = Adwin.Block;

for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(1).dig_out_struct(i).timings_array(1).state = Adwin.Default_parameters.dig_out_init{i};

end

test_adwin.block_seq_array(1).name = 'test_mag_transport';
test_adwin.block_seq_array(1).t_start = '0';

test_adwin.block_seq_array(1).parent_adwin = test_adwin;

%%%% Digital : 18 : Mag. trans. clock %%%%

test_adwin.chge_state_dig(18,'test_mag_transport',[],'init_time+step1_time');

test_adwin.chge_state_dig(18,'test_mag_transport',1,'pulse_time');

test_adwin.chge_state_dig(18,'test_mag_transport',2,'step2_time-pulse_time');

test_adwin.chge_state_dig(18,'test_mag_transport',3,'pulse_time');

test_adwin.chge_state_dig(18,'test_mag_transport',4,'step3_time-pulse_time');

test_adwin.chge_state_dig(18,'test_mag_transport',5,'pulse_time');

test_adwin.chge_state_dig(18,'test_mag_transport',6,'step4_time-pulse_time');

test_adwin.chge_state_dig(18,'test_mag_transport',7,'pulse_time');

test_adwin.chge_state_dig(18,'test_mag_transport',8,'step5_time-pulse_time');

test_adwin.chge_state_dig(18,'test_mag_transport',9,'pulse_time');

test_adwin.chge_state_dig(18,'test_mag_transport',10,'step6_time-pulse_time');

test_adwin.chge_state_dig(18,'test_mag_transport',11,'pulse_time');

%%%% Digital : 19 : Mag. trans. dir. %%%%

test_adwin.chge_state_dig(19,'test_mag_transport',[],'init_time+step1_time+step2_time+step3_time+step4_time+step5_time+step6_time+step7_time+step7_time');

%%%% Digital : Out 20 %%%%

test_adwin.chge_state_dig(20,'test_mag_transport',[],'init_time+step1_time');

test_adwin.chge_state_dig(20,'test_mag_transport',1,'pulse_time');

%%%% Analog : 11 : Current Supply II [A] %%%%

test_adwin.chge_state_ana(11,'test_mag_transport',[],'init_time','0','R','');

test_adwin.chge_state_ana(11,'test_mag_transport',1,'step1_time','max_curr','C','');

test_adwin.chge_state_ana(11,'test_mag_transport',2,'step2_time','max_curr','R','');

test_adwin.chge_state_ana(11,'test_mag_transport',3,'step3_time','0','R','');

test_adwin.chge_state_ana(11,'test_mag_transport',4,'step4_time','max_curr','C','');

test_adwin.chge_state_ana(11,'test_mag_transport',5,'step5_time','max_curr','R','');

test_adwin.chge_state_ana(11,'test_mag_transport',6,'step6_time','0','R','');

test_adwin.chge_state_ana(11,'test_mag_transport',7,'step7_time','max_curr','C','');

test_adwin.chge_state_ana(11,'test_mag_transport',8,'step7_time','max_curr','R','');

test_adwin.chge_state_ana(11,'test_mag_transport',9,'c_hold_time','0','C','');

%%%% Analog : 13 : Current Supply I [A] %%%%

test_adwin.chge_state_ana(13,'test_mag_transport',[],'init_time','0','R','');

test_adwin.chge_state_ana(13,'test_mag_transport',1,'step1_time','max_curr','R','');

test_adwin.chge_state_ana(13,'test_mag_transport',2,'step2_time','0','R','');

test_adwin.chge_state_ana(13,'test_mag_transport',3,'step3_time','max_curr','C','');

test_adwin.chge_state_ana(13,'test_mag_transport',4,'step4_time','max_curr','R','');

test_adwin.chge_state_ana(13,'test_mag_transport',5,'step5_time','0','R','');

test_adwin.chge_state_ana(13,'test_mag_transport',6,'step6_time','max_curr','C','');

test_adwin.chge_state_ana(13,'test_mag_transport',7,'step7_time','max_curr','R','');

test_adwin.chge_state_ana(13,'test_mag_transport',8,'step7_time','0','C','');

test_adwin.chge_state_ana(13,'test_mag_transport',9,'c_hold_time','0','C','');

%%%% Analog : 15 : Current Supply III [A] %%%%

test_adwin.chge_state_ana(15,'test_mag_transport',[],'init_time','0','C','');

test_adwin.chge_state_ana(15,'test_mag_transport',1,'step1_time','0','C','');

test_adwin.chge_state_ana(15,'test_mag_transport',2,'step2_time','0','S','test_function');

test_adwin.chge_state_ana(15,'test_mag_transport',3,'step3_time','0','C','');

test_adwin.chge_state_ana(15,'test_mag_transport',4,'step4_time','0','S','test_function');

test_adwin.chge_state_ana(15,'test_mag_transport',5,'step5_time','0','C','');

test_adwin.chge_state_ana(15,'test_mag_transport',6,'step6_time','0','C','');

test_adwin.chge_state_ana(15,'test_mag_transport',7,'step7_time','0','S','test_function');

test_adwin.chge_state_ana(15,'test_mag_transport',8,'step7_time','0','C','');

test_adwin.chge_state_ana(15,'test_mag_transport',9,'c_hold_time','0','C','');

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Block back_to_1 %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array(2) = Adwin.Block;
test_adwin.block_seq_array(1).next = test_adwin.block_seq_array(2);

for i = 1:Adwin.Default_parameters.dig_crd*Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(2).dig_out_struct(i).timings_array(1).state = test_adwin.block_seq_array(1).dig_out_struct(i).timings_array(end).state;

end

test_adwin.block_seq_array(2).name = 'back_to_1';
test_adwin.block_seq_array(2).t_start = 'init_time+step1_time+step2_time+step3_time+step4_time+step5_time+step6_time+step7_time+step7_time+c_hold_time';

test_adwin.block_seq_array(2).parent_adwin = test_adwin;

%%%% Digital : 18 : Mag. trans. clock %%%%

test_adwin.chge_state_dig(18,'back_to_1',[],'back_step_time');

test_adwin.chge_state_dig(18,'back_to_1',1,'pulse_time');

test_adwin.chge_state_dig(18,'back_to_1',2,'back_step_time');

test_adwin.chge_state_dig(18,'back_to_1',3,'pulse_time');

test_adwin.chge_state_dig(18,'back_to_1',4,'back_step_time');

test_adwin.chge_state_dig(18,'back_to_1',5,'pulse_time');

test_adwin.chge_state_dig(18,'back_to_1',6,'back_step_time');

test_adwin.chge_state_dig(18,'back_to_1',7,'pulse_time');

test_adwin.chge_state_dig(18,'back_to_1',8,'back_step_time');

test_adwin.chge_state_dig(18,'back_to_1',9,'pulse_time');

test_adwin.chge_state_dig(18,'back_to_1',10,'back_step_time');

test_adwin.chge_state_dig(18,'back_to_1',11,'pulse_time');

%%%% Digital : 19 : Mag. trans. dir. %%%%

test_adwin.chge_state_dig(19,'back_to_1',[],'7*(pulse_time+back_step_time)');

