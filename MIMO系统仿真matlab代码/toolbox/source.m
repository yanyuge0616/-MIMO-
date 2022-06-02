function data = source(fr_length,frames,md,zf,varargin)

%SOURCE Generate source data.
%   D = SOURCE(K,F,MD,ZF) creates a data source consists of desired
%   number of F frames each having K symbols. MD determines the range of
%   integers (data) the source will be filled with. For instance of MD=4,
%   D will contain numbers within a set { 0,1,2,3}. ZF corresponds to
%   the number of zeros that will be appended at the end of each frame.
%   This ensures the encoder will be forced into the zero state at the
%   beginning and end of each frame. 
%
%   D = SOURCE(...,'PropertyName',PropertyValue,...)
%
%   Source Property List
%
%   Pattern        {'rand'} | 'ramp' | 'const'
%   Const          value
%   Echo           'on' | {'off'}
%
%   See also SPACE.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

global ECHO

name = 'SOURCE';
[idt,tag] = iecho(name);

nopts = length(varargin) / 2;
opts = reshape(varargin,[2 nopts])';

ord1 = strmatch('Echo',opts(:,1));
ord2 = strmatch('Pattern',opts(:,1));
ord3 = strmatch('Const',opts(:,1));

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

% Pattern
if isempty(ord2) % there's no such option
	mode = 'rand'; % default value
else % there's relevant option
	mode = opts{ord2,2};
end

% Const
if isempty(ord3) % there's no such option
	const = 1; % default value
else % there's relevant option
	const = opts{ord3,2};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch mode
case 'rand'
	data = round((md - 1) * rand(fr_length,1,frames));
case 'ramp'
	ramp = mod([1:fr_length] - 1,md)';
	data = repmat(ramp,[1 1 frames]);
case 'const'
	data = varargin{1} * ones(fr_length,1,frames);
end

% zero forcing appendix
[m,n,o] = size(data);
n = m + 1:m + zf;
data(n,:,1:o) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ech
	str1 = num2str(frames);
	str2 = num2str(fr_length);
	str3 = num2str(zf);
	
	disp(' ');
	disp([tag,'Pattern ',mode,' -> ',str1,' frame(s) by ',str2,...
    ' symbols; ',str3,' zeros appended.']);
	disp(' ');
end