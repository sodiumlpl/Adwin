%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% ADWIN Digital Sequence %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Block Zeeman_TOF %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array = Adwin.Block;

for i = 1:Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(1).dig_out_struct(i).timings_array(1).state = Adwin.Default_parameters.dig_out_init{i};

end

test_adwin.block_seq_array(1).name = 'Zeeman_TOF';
test_adwin.block_seq_array(1).t_start = '0';

test_adwin.block_seq_array(1).parent_adwin = test_adwin;

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'Zeeman_TOF',[],'t0+DelayImag-PulseLength-DelayShutter');

test_adwin.chge_state_dig(2,'Zeeman_TOF',1,'DelayShutter');

test_adwin.chge_state_dig(2,'Zeeman_TOF',2,'PulseLength');

test_adwin.chge_state_dig(2,'Zeeman_TOF',3,'DelayShutter');

test_adwin.chge_state_dig(2,'Zeeman_TOF',[],'t1+DelayImag-PulseLength-DelayShutter');

test_adwin.chge_state_dig(2,'Zeeman_TOF',5,'DelayShutter');

test_adwin.chge_state_dig(2,'Zeeman_TOF',6,'PulseLength');

test_adwin.chge_state_dig(2,'Zeeman_TOF',7,'DelayShutter');

%%%% Digital : 3 : AOM Imaging %%%%

test_adwin.chge_state_dig(3,'Zeeman_TOF',[],'t0');

test_adwin.chge_state_dig(3,'Zeeman_TOF',1,'PulseNonDep');

%%%% Digital : 5 : MOT Shutter %%%%

test_adwin.chge_state_dig(5,'Zeeman_TOF',[],'t0+DelayImag-PulseLength-DelayShutter');

test_adwin.chge_state_dig(5,'Zeeman_TOF',1,'PulseLength+DelayShutter');

test_adwin.chge_state_dig(5,'Zeeman_TOF',[],'t1+DelayImag-PulseLength-DelayShutter');

test_adwin.chge_state_dig(5,'Zeeman_TOF',3,'PulseLength+DelayShutter');

%%%% Digital : 7 : Repumper Shutter %%%%

test_adwin.chge_state_dig(7,'Zeeman_TOF',[],'t0-DelayShutterRepump');

test_adwin.chge_state_dig(7,'Zeeman_TOF',1,'PulseNonDep+DelayShutterRepump');

%%%% Digital : Out 8 %%%%

test_adwin.chge_state_dig(8,'Zeeman_TOF',[],'t0-DelayShutterRepump');

test_adwin.chge_state_dig(8,'Zeeman_TOF',1,'DelayShutterRepump');

test_adwin.chge_state_dig(8,'Zeeman_TOF',2,'PulseNonDep');

test_adwin.chge_state_dig(8,'Zeeman_TOF',3,'DelayShutterRepump');

%%%% Digital : 13 : Camera Trigger %%%%

test_adwin.chge_state_dig(13,'Zeeman_TOF',[],'t0+DelayImag-PulseLength');

test_adwin.chge_state_dig(13,'Zeeman_TOF',1,'2.1*PixelflyAcq');

test_adwin.chge_state_dig(13,'Zeeman_TOF',[],'t1+DelayImag-PulseLength');

test_adwin.chge_state_dig(13,'Zeeman_TOF',3,'2.1*PixelflyAcq');

%%%% Digital : 30 : Mechanical Shutter %%%%

test_adwin.chge_state_dig(30,'Zeeman_TOF',[],'t0-500');

test_adwin.chge_state_dig(30,'Zeeman_TOF',1,'t1+2.1*PixelflyAcq');

%%%% Analog : 2 : MOT AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(2,'Zeeman_TOF','AOM_MOT_freq');

%%%% Analog : 3 : Imaging AOM freq [MHz] %%%%

test_adwin.chge_end_state_ana(3,'Zeeman_TOF','AOM_imag_freq');

%%%% Analog : 4 : MOT AOM eff %%%%

test_adwin.chge_end_state_ana(4,'Zeeman_TOF','AOM_MOT_eff');

%%%% Analog : 7 : Repumper AOM freq [GHz] %%%%

test_adwin.chge_end_state_ana(7,'Zeeman_TOF','AOM_Repumper_freq');

