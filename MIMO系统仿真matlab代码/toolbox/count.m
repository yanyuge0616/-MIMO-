function varargout = count(data_src,data_est,varargin)

%COUNT Error counter.
%   ERR = COUNT(D,D_E) simply counts an error occurrence of data
%   estimations D_E.
%
%   [ERR,SER] = COUNT(D,D_E) same as above, but also gives a symbol
%   error rate in decibels.
%
%   [...] = CHANNEL(...,'PropertyName',PropertyValue,...)
%
%   Count Property List
%
%   Echo           'on' | {'off'}
%   SERLowerBound  value (1e-6}
%
%   See also DETECT, SOURCE.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.2 $  $Date: 2003/5/29 22:16:53 $
%   --
%   <additional stuff goes here>

global ECHO

name = 'COUNT';
[idt,tag] = iecho(name);

nopts = length(varargin) / 2;
opts = reshape(varargin,[2 nopts])';

ord1 = strmatch('Echo',opts(:,1));
ord2 = strmatch('SERLowerBound',opts(:,1));

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

% SERLowerBound
if isempty(ord2) % there's no such option
	ser_lb = 1e-6; % default value
else % there's relevant option
	ser_lb = opts{ord2,2};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fr_length,space_dim,frames] = size(data_est);
err = sum(sum(data_src ~= data_est));
all = fr_length * frames;

if err ~= 0
    ser = err / all;
    ser_db = 10 * log10(ser);
    rel = 100 * (err / all);
else
    ser_db = -Inf;
    ser = ser_lb;
    rel = 100;
end

varargout = {err,ser};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ech
	str1 = sprintf('%1d',err);
	str2 = sprintf('%1.1e',ser_db);
	str3 = sprintf('%1.0f',rel);
	str4 = sprintf('%1.0f',all);
    str5 = sprintf('%1.1e',ser_lb);
	
	disp(' ');
	disp([tag,'Total symbols received -> ',str4,'.']);
	disp([idt,'Total errors counted -> ',str1,'.']);
	disp([idt,'Symbol error rate -> ',str2,' [dB], (',str5,...
      ' is a lower bound).']);
	disp([idt,'System reliability -> ',str3,' %.']);
	disp(' ');
end
