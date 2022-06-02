function varargout = channel(sig,varargin)

%CHANNEL MIMO channel model.
%   Y = CHANNEL(X) corrupts input signal X by desired type of channel
%   fading. 
%
%   [Y,ALPHA] = CHANNEL(X) same as above but returns a matrix of complex
%   path fading. This may be useful when performing data detection. 
%
%   [Y,...] = CHANNEL(X,'PropertyName',PropertyValue,...)
%
%   Channel Property List
%
%   Arrangement    [m n]
%   Fading         {'none'} | 'awgn' | 'rayleigh'
%   SignalPower    value
%   SNR            value [db]
%   SymbolTime     value [s]
%   SamplePeriod   value [s]
%   Echo           'on' | {'off'}
%
%   NOTE: When the 'none' option is chosen than there are no noise in
%         the channel, however the direct signals will be
%         combined at the receiver input.
%
%   See also DETECT, EST.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

global ECHO CH_CONF SIG_PWR SYMB_TIME SMPLPER

name = 'CHANNEL';
[idt,tag] = iecho(name);

nopts = length(varargin) / 2;
opts = reshape(varargin,[2 nopts])';

ord1 = strmatch('Echo',opts(:,1));
ord2 = strmatch('Arrangement',opts(:,1));
ord3 = strmatch('Fading',opts(:,1));
ord4 = strmatch('SignalPower',opts(:,1));
ord5 = strmatch('SNR',opts(:,1));
ord6 = strmatch('SymbolTime',opts(:,1));
ord7 = strmatch('SamplePeriod',opts(:,1));

% Echo
if ~isempty(ord1) % first check whether local option exists
	value1 = opts{ord1,2};
	switch value1
	case 'on'
		ech = 1;
	case 'off'
		ech = 0;
	otherwise
		disp(' ');
		disp([tag,'Invalid option for Echo property.']);
		disp([idt,'Possible values are ''on''|{''off''}.']);
		disp(' ');
		ech = 0;
	end
else
	if ~isempty(ECHO) % than check whether global option exists
		switch ECHO
		case 'on'
			ech = 1;
		case 'off'
			ech = 0;
		otherwise
			disp(' ');
			disp([tag,'Invalid option for Echo property.']);
			disp([idt,'Possible values are ''on''|{''off''}.']);
			disp(' ');
			ech = 0;
		end
	else % if there are no settings use the defaults
		ech = 0; % default value
	end
end
	
% Arrangement
if ~isempty(ord2) % first check whether local option exists
	ch_conf = opts{ord2,2};
else
	if ~isempty(CH_CONF) % than check whether global option exists
		ch_conf = CH_CONF;
	else % if there are no settings use the defaults
		ch_conf = 0; % default value
	end
end

% Fading
if isempty(ord3) % there's no such option
	fading = 'none'; % default value
else % there's relevant option
	fading = opts{ord3,2};
end

% SignalPower
if ~isempty(ord4) % first check whether local option exists
	sig_pwr = opts{ord4,2};
else
	if ~isempty(SIG_PWR) % than check whether global option exists
		sig_pwr = SIG_PWR;
	else % if there are no settings use the defaults
		sig_pwr = 1; % default value
	end
end

% SNR
if isempty(ord5) % there's no such option
	snr = 5; % default value
else % there's relevant option
	snr = opts{ord5,2};
end

% SymbolTime
if ~isempty(ord6) % first check whether local option exists
	symb_time = opts{ord6,2};
else
	if ~isempty(SYMB_TIME) % than check whether global option exists
		symb_time = SYMB_TIME;
	else % if there are no settings use the defaults
		symb_time = 0.0001; % default value
	end
end

% SamplePeriod
if ~isempty(ord7) % first check whether local option exists
	smplper = opts{ord7,2};
else
	if ~isempty(SMPLPER) % than check whether global option exists
		smplper = SMPLPER;
	else % if there are no settings use the defaults
		smplper = 1; % default value
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[sig_length,space_dim,frames] = size(sig);

sigma_ch = 1;
esr = symb_time * sigma_ch ^ 2 * ch_conf(1) * sig_pwr;
n0 = esr / (10 ^ (0.1 * snr));
sigma = sqrt(2 * n0 / smplper);
const = sqrt(2);

switch fading
case 'rayleigh'
  ch_coefs = (randn(ch_conf(1),ch_conf(2),frames) +...
    i * randn(ch_conf(1),ch_conf(2),frames)) / const;

  ch_noise = (randn(sig_length,space_dim,frames) +...
    i * randn(sig_length,space_dim,frames)) * sigma / const;

case 'awgn'
  ch_coefs = ones(ch_conf(1),ch_conf(2),frames);

  ch_noise = (randn(sig_length,space_dim,frames) +...
    i * randn(sig_length,space_dim,frames)) * sigma / const;

case 'none'
  ch_coefs = ones(ch_conf(1),ch_conf(2),frames);

  ch_noise = zeros(sig_length,space_dim,frames);
end

% signal mixture
for k = 1:frames % no 3D arrays multiplication is available
    sig_add(:,:,k) = sig(:,:,k) * ch_coefs(:,:,k);
end

sig_corr = sig_add + ch_noise;
varargout = {sig_corr,ch_coefs};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ech
	switch fading
	case 'none'
      str2 = [''];
	otherwise
      str1 = num2str(snr);
      str2 = [' ,SNR -> ',str1,' [dB]'];
	end
	
	disp(' ');
	disp([tag,'Channel fading -> ',fading,str2,'.']);
	disp(' ');
end
