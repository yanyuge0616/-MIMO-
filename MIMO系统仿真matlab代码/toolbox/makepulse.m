function pulse = makepulse(varargin)

%MAKEPULSE Modulation impulse design.
%   H = MAKEPULSE('PropertyName',PropertyValue,...) returns the impulse
%   response of desired modulation impulse. All the impulses are
%   designed to have a unit energy.
%
%   Makepulse Property List
%
%   Shortening     value
%   SymbolTime     value
%   SymbolSamples	 value
%   Shape          {'rrc'} | 'rect'
%   RollOff        0 < value < 1
%   Echo           'on' | {'off'}
%
%   NOTE: If Shortening = 8 than MAKEPULSE makes the impulse of total
%         length equal to 8 * Samples + 1. One sample is added to
%         ensure symbol symetry and correct sampling. 
%
%   See also MODUL.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.2 $  $Date: 2003/3/20 11:55:28 $
%   --
%   <additional stuff goes here>

global ECHO SYMB_SAMPLES SYMB_TIME

name = 'MAKEPULSE';
[idt,tag] = iecho(name);

nopts = length(varargin) / 2;
opts = reshape(varargin,[2 nopts])';

ord1 = strmatch('Echo',opts(:,1));
ord2 = strmatch('Shortening',opts(:,1));
ord3 = strmatch('SymbolTime',opts(:,1));
ord4 = strmatch('SymbolSamples',opts(:,1));
ord5 = strmatch('Shape',opts(:,1));
ord6 = strmatch('RollOff',opts(:,1));

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

% Shortening
if isempty(ord2) % there's no such option
	cutoff = 8; % default value
else % there's relevant option
	cutoff = opts{ord2,2};
end

% SymbolTime
if ~isempty(ord3) % first check whether local option exists
	time = opts{ord3,2};
else
	if ~isempty(SYMB_TIME) % than check whether global option exists
		time = SYMB_TIME;
	else % if there are no settings use the defaults
		time = 0.0001; % default value
	end
end

% SymbolSamples
if ~isempty(ord4) % first check whether local option exists
	samples = opts{ord4,2};
else
	if ~isempty(SYMB_SAMPLES) % than check whether global option exists
		samples = SYMB_SAMPLES;
	else % if there are no settings use the defaults
		samples = 4; % default value
	end
end

% Shape
if isempty(ord5) % there's no such option
	shape = 'rrc'; % default value
else % there's relevant option
	shape = opts{ord5,2};
end

% RollOff
if isempty(ord6) % there's no such option
	rolloff = 0.4; % default value
else % there's relevant option
	rolloff = opts{ord6,2};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch shape
case 'rect'
  pulse = linspace(1 / sqrt(cutoff * time),...
      1 / sqrt(cutoff * time),samples * cutoff);
    
case 'rrc'
	singul = time / (4 * rolloff);
	tt = linspace(-cutoff * time / 2,...
          cutoff * time / 2,samples * cutoff + 1);
	
	z = find(tt == 0);
	k = find(abs(tt) == singul);
	
	% Checking for singularities...
  if (isempty(z) == 0) & (isempty(k) == 0) % zero & non-zero singularity
      n = [find(tt < -singul),find((tt > -singul) & (tt < 0)),...
        find((tt > 0) & (tt < singul)),find(tt > singul)];
      t = tt(n);
          
      pulse(n) = (1 ./ (sqrt(time) .* (1 - (4. * rolloff ./...
        time) .^ 2 .* t .^2))) .* ((sin((1 - rolloff) .* pi .* t ./...
        time) ./ (pi .* t ./ time)) + (4 .* rolloff .*...
        cos((1 + rolloff) .* pi .* t ./ time) ./ pi));

			pulse(z) = (1 / sqrt(time)) * (1 - rolloff + 4 * rolloff / pi);	
			
			pulse(k) = rolloff * ((-2 + pi) * cos(pi / (4 * rolloff)) +...
        (2 + pi) * sin(pi / (4 * rolloff))) / (pi * sqrt(2) *...
        sqrt(time));
  
  elseif (isempty(k) == 0) % non-zero singularity
		n = [find(tt < -singul),find(abs(tt) < singul),find(tt > singul)];
		t = tt(n);
            
		pulse(n) = (1 ./ (sqrt(time) .* (1 - (4 .* rolloff ./...
      time) .^ 2 .* t .^ 2))) .* ((sin((1 - rolloff) .* pi .* t ./...
      time) ./ (pi .* t ./ time)) + (4 .* rolloff .*...
      cos((1 + rolloff) .* pi .* t ./ time) ./ pi));
		
		pulse(k) = rolloff * ((-2 + pi) * cos(pi / (4 * rolloff)) + (2 + pi) *...
      sin(pi / (4 * rolloff))) / (pi * sqrt(2) * sqrt(time));
      
	elseif isempty(z) == 0 % zero singularity
		n = [find(tt < 0),find(tt > 0)];
    t = tt(n);
          
		pulse(n) = (1 ./ (sqrt(time) .* (1 - (4 .* rolloff ./...
      time) .^ 2 .* t .^ 2))) .* ((sin((1 - rolloff) .* pi .* t ./...
      time) ./ (pi .* t ./ time)) + (4 .* rolloff .*...
      cos((1 + rolloff) .* pi .* t ./ time) ./ pi));
		
		pulse(z)=(1 / sqrt(time)) * (1 - rolloff + 4 * rolloff / pi);
          
  else % no singularity found
    t = tt;
   
    pulse = (1 ./ (sqrt(time) .* (1 - (4 .* rolloff ./...
      time) .^ 2 .* t .^ 2))) .* ((sin((1 - rolloff) .* pi .* t ./...
      time) ./ (pi .* t ./ time)) + (4 .* rolloff .*...
      cos((1 + rolloff) .* pi .* t ./ time) ./ pi));
	end 
end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ech	
	str1 = num2str(length(pulse));
	str2 = num2str(rolloff);
	
	disp(' ');
	disp([tag,str1,' samples of ',shape,...
		' impulse generated; roll-off -> ',str2,'.']);
	disp(' ');
end
