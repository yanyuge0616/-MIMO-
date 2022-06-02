function sig_modul = modul(data,md,varargin)

%MODUL Multidimensional digital modulator
%   S = MODUL(Q,MD,'PropertyName',PropertyValue,...) performs linear
%   memoryless digital modulation of channel symbols q. The output
%   signal sampled Ns-times per symbol period is assumed to be a 
%   complex envelope of the real bandpass signal. MD corresponds to the
%   number of constellation signals. Possible values for MD are 4|8|16 
%   which corresponds to 4PSK, 8PASK and 16QAM constellations
%   respectively.
%
%   Modul Property List
%
%   SymbolSamples  value
%   SamplePeriod   value [s]
%   Gain           value
%   Pulse          vector
%   Echo           'on' | {'off'}
%
%   NOTE: The order of the 16QAM constellation signals is defined via
%         external file qam16.txt and may be arbitrarily modified.
%
%   See also MAKEPULSE, SCALE.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

global ECHO SYMB_SAMPLES SMPLPER GAIN PULSE

name = 'MODUL';
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

% 16QAM definition
load qam16.txt;
[frame_length,space_dim,frames]=size(data);

for k = 1:frames
	switch md
	case 16         % 16QAM
		for l = 1:space_dim
		k1(:,l) = qam16(data(:,l,k) + 1,1);
		k2(:,l) = qam16(data(:,l,k) + 1,2);
		end
		
		q(:,:,k) = (2 * k1 - md - 1) - i * (2 * k2 - md - 1);
		
	otherwise
		expr = 2 * pi * i / md;
		q(:,:,k) = exp(expr * data(:,:,k));
	end
	
	sig_up(:,:,k) = upsample(q(:,:,k),samples);
	
	% to compute convolution signals must be vectors -> for loop
	for j = 1:space_dim
		sig_modul(:,j,k) = gain * conv(pulse,sig_up(:,j,k));
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ech
	[m,foo1,foo2] = size(sig_modul);
	str2 = num2str(frame_length);
	str3 = num2str(frames);
	str4 = num2str(m);
	str5 = num2str(md);
	
	switch md
	case 4
		str1 = '4PSK';
	case 8
		str1 = '8PSK';
	case 16
		str1 = '16QAM';
	end
	
	disp(' ');
	disp([tag,'Modulation ',str1,' performed; ',str2,' symbols,',...
    str3,' frame(s).']);
	disp([idt,'Total signal length: ',str4,' samples.']);
	disp(' ');
end
