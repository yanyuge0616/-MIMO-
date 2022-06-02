function sig_down = mfilter(sig,varargin)

%MFILTER Matched filter
%   Y = MFILTER(X) passes the incoming signal X along the matched filter
%   and resamples filtered signal once per a symbol period.
%
%   Y = MFILTER(X,'PropertyName',PropertyValue,...)
% 
%   Detect Property List
% 
%   SymbolSamples  value
%   SamplePeriod   value
%   Gain           value
%   Pulse          value
%   Echo           'on' | {'off'}
%
%   See also DETECT.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

global ECHO PULSE GAIN SYMB_SAMPLES SMPLPER

name = 'MFILTER';
[idt,tag] = iecho(name);

nopts = length(varargin) / 2;
opts = reshape(varargin,[2 nopts])';

ord1 = strmatch('Echo',opts(:,1));
ord2 = strmatch('SymbolSamples',opts(:,1));
ord3 = strmatch('SamplePeriod',opts(:,1));
ord4 = strmatch('Gain',opts(:,1));
ord5 = strmatch('Pulse',opts(:,1));

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

% SymbolSamples
if ~isempty(ord2) % first check whether local option exists
	samples = opts{ord2,2};
else
	if ~isempty(SYMB_SAMPLES) % than check whether global option exists
		samples = SYMB_SAMPLES;
	else % if there are no settings use the defaults
		samples = 4; % default value
	end
end

% SamplePeriod
if ~isempty(ord3) % first check whether local option exists
	smplper = opts{ord3,2};
else
	if ~isempty(SMPLPER) % than check whether global option exists
		smplper = SMPLPER;
	else % if there are no settings use the defaults
		smplper = 1; % default value
	end
end

% Gain
if ~isempty(ord4) % first check whether local option exists
	gain = opts{ord4,2};
else
	if ~isempty(GAIN) % than check whether global option exists
		gain = GAIN;
	else % if there are no settings use the defaults
		gain = 1; % default value
	end
end

% Pulse
if ~isempty(ord5) % first check whether local option exists
	pulse = opts{ord5,2};
else
	if ~isempty(PULSE) % than check whether global option exists
		pulse = PULSE;
	else % if there are no settings use the defaults
		pulse = 1; % default value
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[sig_length,space_dim,frames] = size(sig);

for k = 1:frames
	% passing the signal through matched filter
  clear sig_mf;
	for j = 1:space_dim
    sig_mf(:,j) = smplper * conv(pulse,sig(:,j,k)) / gain;
	end

  % omiting the sig begining to prevent of insecure decisions
	delay = length(pulse);
	sig_mf = sig_mf(delay:end-delay,:,:);

	% sampling at symbol period (Ns in Dt)
	sig_down(:,:,k) = downsample(sig_mf,samples);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ech
 [down_length,frames] = size(sig_down);
	str1 = num2str(down_length);
	str2 = num2str(frames);
	
	disp(' ');
	disp([tag,'Total length -> ',str1,' samples; ',str2,' frame(s).']);
	disp(' ');
end
