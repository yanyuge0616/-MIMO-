%LOGREPORT Create simulation log-file.
%   LOGREPORT simply archives simulation environment variables and
%   running conditions into a log-file named `mimotools.log'. In fact 
%   LOGEPORT script is a part of the main MIMO script and therefore it 
%   must not work when running alone. 
%   
%   See also MIMO, MESG, POST.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 1.0 $  $Date: 2003/5/29 21:23:58 $
%   --
%   <additional stuff goes here>

totalsymb = length(ch_snr) * frames * fr_length;
[hr,min,sec] = hms(timing);
ts = fix(clock);
table(:,1) = ch_snr';
table(:,2) = err';
table(:,3) = 10 * log10(ser)';

filename=['mimotools.log'];
fid = fopen(filename,'w');
fprintf(fid,'MIMOTOOLS %s log file, \n',VERSION);
fprintf(fid,'(c) 2001 - 2003 Kamil Anis, anisk@feld.cvut.cz, \n');
fprintf(fid,'This file is created automatically during the simulation run. \n\n');

fprintf(fid,'[GLOBAL SETTINGS] \n');
fprintf(fid,'\t Log reported: \t\t\t\t %d.%d.%d at %d:%d:%d \n',ts);
fprintf(fid,'\t Echo: \t\t\t\t\t %s \n',ECHO);
fprintf(fid,'\t Symbol energy: \t\t\t %1.2f \n',SYMB_ENERGY);
fprintf(fid,'\t Samples per symbol: \t\t\t %d \n',SYMB_SAMPLES);
fprintf(fid,'\t Symbol time duration: \t\t\t %1.2f [s]\n',SYMB_TIME);
fprintf(fid,'\t MIMO system setup: \t\t\t %d x %d \n',CH_CONF(1),CH_CONF(2));
fprintf(fid,'\t Sampling period: \t\t\t %1.2e [s] \n',SMPLPER);
fprintf(fid,'\t Constellation expansion factor: \t %1.2f \n',GAIN);
fprintf(fid,'\t Transmitted signal power: \t\t %1.2f \n',SIG_PWR);
fprintf(fid,'\t Enable detection timing: \t\t %d \n\n',TIMING);

fprintf(fid,'[SOURCE SECTION] \n');
fprintf(fid,'\t Number of data frames: \t\t %d \n',frames);
fprintf(fid,'\t Number of symbols per frame: \t\t %d \n',fr_length);
fprintf(fid,'\t Number of splashing zeros: \t\t %d \n',zf);
fprintf(fid,'\t Message data pattern: \t\t\t %s \n',src_mode);
fprintf(fid,'\t Constant message value: \t\t %d \n\n',src_const);

fprintf(fid,'[ENCODER SECTION] \n');
fprintf(fid,'\t Encoding scheme: \t\t\t %s \n',enc_scheme);
fprintf(fid,'\t Code states: \t\t\t\t %d \n',s);
fprintf(fid,'\t Number of data symbols: \t\t %d \n\n',md);

fprintf(fid,'[MODULATOR SECTION] \n');
fprintf(fid,'\t Modulation pulse shape: \t\t %s \n',pulse_shape);
fprintf(fid,'\t Modulation pulse shortening: \t\t %d x Ts\n',pulse_cutoff);
fprintf(fid,'\t Modulation pulse roll-off: \t\t %1.2f \n\n',pulse_rolloff);

fprintf(fid,'[CHANNEL SECTION] \n');
fprintf(fid,'\t Channel fading type: \t\t\t %s \n\n',ch_fading);

fprintf(fid,'[ESTIMATOR SECTION] \n');
fprintf(fid,'\t Estimator has been temporarily removed in version %s. \n',VERSION);
fprintf(fid,'\t CSI knowledge: \t\t\t %s \n\n',est_csi);

fprintf(fid,'[COUNTER SECTION] \n');
fprintf(fid,'\t Total elapsed time: \t\t\t %d hrs %d mins %1.1f sec \n',hr,min,sec);
fprintf(fid,'\t Total symbols transmitted: \t\t %d \n\n',totalsymb);
fprintf(fid,'[PERFORMANCE MEASUREMENT STATISTICS] \n');
fprintf(fid,'\t SNR [dB] \t Errors \t SER \n');
fprintf(fid,'\t %2.2f \t\t %4d \t\t %-2.2E \n',table');

fclose(fid);
