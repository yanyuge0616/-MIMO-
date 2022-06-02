function data_enc = space(data,dlt,slt,varargin)

%SPACE Space-time channel encoder
%   Q = SPACE(D,DLT,SLT) performs the data (D) encoding based on the DLT
%   and SLT look-up tables. The tables for AT&T space-time codes these
%   tables may be easily obtained from the LTABLE function. In fact the
%   structure of look-up tables is as general as possible. By the way
%   the encoder doesn't care about the content of the look-up tables. 
%   This feature allows you to force the encoder's operation mode into 
%   the arbitrary scheme. Even an encoding based on block codes may be
%   performed using the space function. This is when the slt table is
%   filled with equal entries. There is also a zero-force check performed
%   during each frame encoding process. 
%
%   Q = SPACE(D,DLT,SLT,'PropertyName',PropertyValue,...)
%
%   Space Property List
%
%   Display       {'off'} | 'report'
%   Echo           'on' | {'off'}
%
%   See also LTABLE, DISPDES.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

global ECHO

name = 'SPACE';
[idt,tag] = iecho(name);

nopts = length(varargin) / 2;
opts = reshape(varargin,[2 nopts])';

ord1 = strmatch('Echo',opts(:,1));
ord2 = strmatch('Display',opts(:,1));

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

% Display
if isempty(ord2) % there's no such option
	report = 'off'; % default value
else % there's relevant option
	report = opts{ord2,2};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fr_length,l,frames] = size(data);
[foo1,md,foo2] = size(dlt);

s = 1; % setting up initial state

for k = 1:frames
	for i = 1:fr_length                           % stc encoder 
		d = data(i,1,k) + 1; % data_dim=1           % stc encoder                      
    data_enc(i,:,k) = dlt(s,d,:);               % stc encoder
    s = slt(s,d,:);                             % stc encoder
  end                                           % stc encoder

  % zero force flag
  if (i == fr_length) & (s ~= 1) 
    zf_check(k,1) = 0;
  else
    zf_check(k,1) = 1;
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ech 
	disp(' ');
	if zf_check == 1
        disp([tag,'All frames were encoded successfuly.']);
	else
        disp([tag,'Some frames were encoded uncorrectly!']);
        disp([idt,'Use |FullReport| option to get more details.']);
	end
	
	switch report
	case 'off'
		disp(' ');
		return
	case 'report'
		[m,n] = size(zf_check);
		table(:,1) = [1:m]';
		table(:,2) = zf_check;
		str1 = sprintf([idt,' #%3d  | %3d\n'],table');
		
		disp(' ');
		disp([idt,' Frame | Status']);
		disp([idt,'-------+-------']);
		disp(str1);
		disp([idt,'Legend: "1" = OK; "0" = wrong encoded.']);
	end
	disp(' ');
end
