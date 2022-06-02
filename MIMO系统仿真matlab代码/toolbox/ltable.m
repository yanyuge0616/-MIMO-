function [dlt,slt] = ltable(md,s,varargin)

%LTABLE Space-time code look-up table generator.
%   [DLT,SLT] = LTABLE(MD,S) creates MD, S-states space-time code data
%   and state look-up tables. MD corresponds to the number of 
%   constellation signals e.g. MD-PSK and MD-QAM. The summary of
%   available designs is listed below. 
%
%   Table of available designs
%
%     #  |  MD | MODULATION | STATES |   METHOD
%   -----+-----+------------+--------+-------------
%     1. |  4  |    PSK     |    4   |   'att'
%     2. |  4  |    PSK     |    8   |   'att'
%     3. |  4  |    PSK     |   16   |   'att'
%     4. |  4  |    PSK     |   32   |   'att'
%     5. |  8  |    PSK     |    8   |   'att'
%     6. |  8  |    PSK     |    8   |  'delay'
%     7. |  8  |    PSK     |   16   |   'att'
%     8. |  8  |    PSK     |   32   |   'att'
%     9. | 16  |    QAM     |   16   |   'att'
%    10. | 16  |    QAM     |   16   |  'delay'
%    11. | 16  |    QAM     |   16   |   'ext'
%
%   [DLT,SLT] = LTABLE(MD,S,'PropertyName',PropertyValue,...)
%
%   Ltable Property List
%
%   Method         {'att'} | 'delay' | 'ext'
%   Echo           'on' | {'off'}
%
%   See also DISPDES, SPACE.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

global ECHO

name = 'LTABLE';
[idt,tag] = iecho(name);

nopts = length(varargin) / 2;
opts = reshape(varargin,[2 nopts])';

ord1 = strmatch('Echo',opts(:,1));
ord2 = strmatch('Method',opts(:,1));

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


% Method
if isempty(ord2) % there's no such option
	method = 'att'; % default value
else % there's relevant option
	method = opts{ord2,2};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% State matrix generator
base = reshape(1:s,md,s/md)';
slt = repmat(base,md,1);

% Data matrix generator
% block code of 16QAM
load stc_bc16.txt;

for j = 1:md
	l = j - 1;
	
	ak = bitget(l,1);
	bk = bitget(l,2);
	dk = bitget(l,3);
	ek = bitget(l,4);
	
	switch md
	% 4 PSK
	case 4
		for i = 1:s
			k = i - 1;
			
			ak_1 = bitget(k,1);
			bk_1 = bitget(k,2);
			ak_2 = bitget(k,3);
			bk_2 = bitget(k,4);
			ak_3 = bitget(k,5);
			bk_3 = bitget(k,6);
			
			switch s
			case 4
				dlt(i,j,1) = mod(2 * bk_1 + ak_1,md);
				dlt(i,j,2) = mod(2 * bk + ak,md);
			case 8
				dlt(i,j,1) = mod(2 * ak_2 + 2 * bk_1 + ak_1,md);
				dlt(i,j,2) = mod(2 * ak_2 + 2 * bk + ak,md);
			case 16
				dlt(i,j,1) = mod(2 * ak_2 + 2 * bk_1 + ak_1,md);
				dlt(i,j,2) = mod(2 * bk_2 + 2 * ak_1 + 2 * bk + ak,md);            
			case 32
				dlt(i,j,1) = mod(2 * ak_3 + 3 * bk_2 + 2 * ak_2 + 2 * bk_1 +...
					ak_1,md);
				dlt(i,j,2) = mod(2 * ak_3 + 3 * bk_2 + 2 * bk_1 + ak_1 + 2 *...
          bk + ak,md);
			end
		end
	
	% 8 PSK
	case 8
		for i = 1:s
			k = i - 1;
			
			ak_1 = bitget(k,1);
			bk_1 = bitget(k,2);
			dk_1 = bitget(k,3);
			ak_2 = bitget(k,4);
			bk_2 = bitget(k,5);
			
			switch s
			case 8
        
				switch method
				case 'att'
					dlt(i,j,1) = mod(4 * dk_1 + 2 * bk_1 + 5 * ak_1,md);
					dlt(i,j,2) = mod(4 * dk + 2 * bk + ak,md);
          
        case 'delay'
					dlt(i,j,1)=mod(4 * dk_1 + 2 * bk_1 + ak_1,md);
					dlt(i,j,2)=mod(4 * dk + 2 * bk + ak,md);
				end
				
			case 16
				dlt(i,j,1) = mod(ak_2 + 4 * dk_1 + 2 * bk_1 + 5 * ak_1,md);
				dlt(i,j,2) = mod(5 * ak_2 + 4 * dk_1 + 2 * bk_1 + ak_1 + 4 *...
          dk + 2 * bk + ak,md);
			case 32
				dlt(i,j,1) = mod(2 * bk_2 + 3 * ak_2 + 4 * dk_1 + 2 * bk_1 +...
          5 *	ak_1,md);
				dlt(i,j,2) = mod(2 * bk_2 + 7 * ak_2 + 4 * dk_1 + 2 * bk_1 +...
					ak_1 + 4 * dk + 2 * bk + ak,md);
			end
		end
	
	% 16 QAM
	case 16
		for i = 1:s
			k = i - 1;
			
			ak_1 = bitget(k,1);
			bk_1 = bitget(k,2);
			dk_1 = bitget(k,3);
			ek_1 = bitget(k,4);
			
			switch s
			case 16
			
        switch method
				case 'att'
					dlt(i,j,1) = mod(8 * ek_1 + 4 * dk_1 + 2 * bk_1 + 11 *...
            ak_1,md);
					dlt(i,j,2) = mod(16 * ek_1 + 16 * dk_1 + 16 * bk_1 + 16 *...
						ak_1 + 8 * ek + 4 * dk + 2 * bk + ak,md);
        
        case 'delay'
					dlt(i,j,1) = mod(8 * ek_1 + 4 * dk_1 + 2 * bk_1 + ak_1,md);
					dlt(i,j,2) = mod(8 * ek + 4 * dk + 2 * bk + ak,md);
          
        case 'ext'
					dlt(i,j,1) = stc_bc16(k + 1,1);
					dlt(i,j,2) = stc_bc16(k + 1,2) - i + j;
				end
			end
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ech
		str1 = num2str(md);
		str2 = num2str(s);
		
		if (md == 4) | (md == 8)
      str3 = 'PSK';
		else
      str3 = 'QAM';
		end
		
		disp(' ');
		disp([tag,'Look-up tables for ',method,' code ',str1,str3,', ',...
        str2,'-states created.']);
		disp(' ');
end
