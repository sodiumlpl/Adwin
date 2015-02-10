%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% ADWIN Digital Sequence %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%
%%%% Block test %%%%
%%%%%%%%%%%%%%%%%%%%

test_adwin.block_seq_array = Adwin.Block;

for i = 1:Adwin.Default_parameters.dig_out_nbr

test_adwin.block_seq_array(1).dig_out_struct(i).timings_array(1).state = Adwin.Default_parameters.dig_out_init{i};

end

test_adwin.block_seq_array(1).name = 'test';
test_adwin.block_seq_array(1).t_start = '0';

test_adwin.block_seq_array(1).parent_adwin = test_adwin;

%%%% Digital : 1 : AOM Zeeman %%%%

test_adwin.chge_state_dig(1,'test',[],'t0+0.4*PixelflyAcq-DelayShutter+DelayZeemanPulse');

test_adwin.chge_state_dig(1,'test',1,'DelayShutter');

test_adwin.chge_state_dig(1,'test',2,'PulseZeeman');

test_adwin.chge_state_dig(1,'test',3,'DelayShutter');

test_adwin.chge_state_dig(1,'test',4,'t1-(DelayZeemanPulse+DelayShutter+PulseZeeman+0.4*PixelflyAcq)+0.4*PixelflyAcq-DelayShutter+DelayZeemanPulse');

test_adwin.chge_state_dig(1,'test',5,'DelayShutter');

test_adwin.chge_state_dig(1,'test',6,'PulseZeeman');

test_adwin.chge_state_dig(1,'test',7,'DelayShutter');

%%%% Digital : 2 : AOM MOT %%%%

test_adwin.chge_state_dig(2,'test',[],'t0+0.4*PixelflyAcq+Delay-DelayShutter');

test_adwin.chge_state_dig(2,'test',1,'DelayShutter');

test_adwin.chge_state_dig(2,'test',2,'PulseLength');

test_adwin.chge_state_dig(2,'test',3,'DelayShutter');

test_adwin.chge_state_dig(2,'test',4,'t1-(Delay+PulseLength+DelayShutter+0.4*PixelflyAcq)+0.4*PixelflyAcq+Delay-DelayShutter');

test_adwin.chge_state_dig(2,'test',5,'DelayShutter');

test_adwin.chge_state_dig(2,'test',6,'PulseLength');

test_adwin.chge_state_dig(2,'test',7,'DelayShutter');

%%%% Digital : 4 : Zeeman Shutter %%%%

test_adwin.chge_state_dig(4,'test',[],'t0+0.4*PixelflyAcq-DelayShutter+DelayZeemanPulse');

test_adwin.chge_state_dig(4,'test',1,'DelayShutter+PulseZeeman');

test_adwin.chge_state_dig(4,'test',2,'t1-(PulseZeeman+DelayZeemanPulse+0.4*PixelflyAcq)+0.4*PixelflyAcq-DelayShutter+DelayZeemanPulse');

test_adwin.chge_state_dig(4,'test',3,'DelayShutter+PulseZeeman');

%%%% Digital : 5 : MOT Shutter %%%%

test_adwin.chge_state_dig(5,'test',[],'t0+0.4*PixelflyAcq+Delay-DelayShutter');

test_adwin.chge_state_dig(5,'test',1,'DelayShutter+PulseLength');

test_adwin.chge_state_dig(5,'test',2,'t1-(Delay+PulseLength+0.4*PixelflyAcq)+0.4*PixelflyAcq+Delay-DelayShutter');

test_adwin.chge_state_dig(5,'test',3,'DelayShutter+PulseLength');

%%%% Digital : 7 : Repumper Shutter %%%%

test_adwin.chge_state_dig(7,'test',[],'t0+0.4*PixelflyAcq-DelayShutterRepump');

test_adwin.chge_state_dig(7,'test',1,'PulseRepump+DelayShutterRepump');

%%%% Digital : 13 : Camera Trigger %%%%

test_adwin.chge_state_dig(13,'test',[],'t0');

test_adwin.chge_state_dig(13,'test',1,'2.1*PixelflyAcq');

test_adwin.chge_state_dig(13,'test',2,'t1-2.1*PixelflyAcq');

test_adwin.chge_state_dig(13,'test',3,'2.1*PixelflyAcq');

%%%% Digital : Out 16 %%%%

test_adwin.chge_state_dig(16,'test',[],'t0+0.4*PixelflyAcq');

test_adwin.chge_state_dig(16,'test',1,'1');

