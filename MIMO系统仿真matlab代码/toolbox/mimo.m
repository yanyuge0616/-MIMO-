%MIMO Run MIMO system simulation.
%   MIMO is the main simulation script where all the blocks are glued
%   together. Refer to the PDF documentation. This is the body of the
%   program which allows you to set various simulation conditions and
%   change wide range of parameters. Modular architecture let's you
%   easy focus your effort on the particular block development while
%   the rest of the system is not affected by this module. Other modules
%   can be integrated into the body very easily. You just modify the
%   simulation parameters in the script header. 
%
%   MIMO script is also suited for a code performance measurement. In 
%   such a case you should disable function ECHOes and enable PROG_INFO
%   instead. This keeps you informed about the simulation run, which
%   usually takes a long time. You may also do some post-processing by
%   calling a POST function or archive the simulation report into a
%   log-file.
%
%   See also POST, LOGREPORT, MESG and the script body to learn more.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.2 $  $Date: 2003/5/23 22:01:58 $
%   --
%   <additional stuff goes here>

clear all; close all;
tic;

% system-wide variables
global ECHO SYMB_ENERGY SYMB_SAMPLES SYMB_TIME CH_CONF SMPLPER GAIN...
	SIG_PWR	PULSE INDENT TIMING VERSION

VERSION = '2.2.0';                          % toolkit version
ECHO = 'on';															% enable function echoes
% ECHO = 'off';                               % disable functions echoes
% prog_info = 1;                              % enable progress info
prog_info = 0;                            % disable progress info
% INDENT = 12;                              % set function indenting
fashion;																		% graphics settings

md = 4;                                  		% # of constellation signals
s = 8;                                   		% # of code trellis states

fr_length = 10;                           	% frame length [symbols]
frames = 20;                             	  % # of frames
zf = 3;                                 		% length of zero appendix
src_mode = 'rand';                     		  % source operation mode
% src_mode = 'ramp';
% src_mode = 'const';
src_const = 1;

enc_scheme = 'att';                         % encoding scheme

pulse_shape = 'rrc';                        % modulation impulse shape
% pulse_shape = 'rect';
pulse_cutoff = 8;                       		% mod. impulse shortening
pulse_rolloff = 0.4;                     		% roll-off factor
SYMB_TIME = 0.0001;                      		% symbol duration
SYMB_SAMPLES = 4;                        		% samples per symbol
SYMB_ENERGY = 1;                            % symbol average energy

CH_CONF = [2 2];                         		% MIMO configuration
ch_snr_pts = 10;                               % # of points to be measured
ch_snr_lo = 1;
ch_snr_hi = 10;
ch_snr = 4;                              	% channel SNR [dB]
% ch_snr = linspace(ch_snr_lo,...
%   ch_snr_hi,ch_snr_pts);
% ch_fading = 'none';                      	% MIMO channel fading
% ch_fading = 'awgn';
ch_fading = 'rayleigh';

est_csi = 'perfect';                     	  % CSI mode

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INIT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% pre-requisities
SMPLPER = SYMB_TIME / SYMB_SAMPLES; 		% symbol sample period
SIG_PWR = SYMB_ENERGY / SYMB_TIME;      % modulation (constell) power
GAIN = rescale(md,SYMB_ENERGY);         % scale factor
TIMING = 0; % disable DETECT timing when running performance measurement
timing = 0;

name = 'MIMO';
[idt,tag] = iecho(name);

[dlt,slt] = ltable(md,s,'Method',enc_scheme);

PULSE = makepulse('Shape',pulse_shape,'Shortening',pulse_cutoff,...
	'RollOff',pulse_rolloff);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RUN %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if prog_info
  clc;
  disp(' ');
  disp([tag,'Running MIMO system performance measurement. Please wait...']);
  disp(' ');
end

for i = 1:length(ch_snr)
	% running modules
	data_src = source(fr_length,frames,md,zf,'Pattern',src_mode);
	
	data_enc = space(data_src,dlt,slt);
	
	sig_mod = modul(data_enc,md);
	
	[sig_corr,ch_coefs] = channel(sig_mod,'Fading',ch_fading,'SNR',ch_snr(i));
	
	% [est_coefs,mse]=est(sig_corr,est_csi,ch_coefs);
	% this block has been temporarily removed. 
	
	sig_mf = mfilter(sig_corr);
	
	[data_est,state_est] = detect(sig_mf,dlt,slt,ch_coefs);
	
	% counting the errors
	[err_i,ser_i] = count(data_src,data_est);
	
	ser(i) = ser_i; err(i) = err_i;
  
  if prog_info
    mesg;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% VISUAL LAYER & POST-PROCESSING %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check pulse shape
% stem(PULSE);

% display design
figure(1); dispdes(dlt,slt);
 
% display decoding process in a graphical form
figure (2); disptrell(dlt,slt,data_est,state_est);

% display code performance
if length(ch_snr) > 1 figure(3); post(ch_snr,ser); end

% save simulation report into a file
logreport;