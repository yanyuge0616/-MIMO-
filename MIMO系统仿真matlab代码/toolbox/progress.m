function bar_string = progress(percent,varargin);

%PROGRESS Create a progress bar.
%   BS = PROGRESS(PERCENT) returns a string showing the ratio of
%   done/remaining jobs.
%
%   BS = PROGRESS(PERCENT,'PropertyName','PropertyValue,...)
%
%   Progress Property List
%
%   BarSize        {48}
%   BodyChar       {'|'}
%
%   See also MIMO.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 1.0 $  $Date: 2003/5/23 20:55:18 $
%   --
%   <additional stuff goes here>

nopts = length(varargin) / 2;
opts = reshape(varargin,[2 nopts])';

ord1 = strmatch('BarSize',opts(:,1));
ord2 = strmatch('BodyChar',opts(:,1));

% BarSize
if isempty(ord1) % there's no such option
	barsize = 48; % default value
else % there's relevant option
	barsize = opts{ord1,2};
end

% BodyChar
if isempty(ord2) % there's no such option
	char2 = '|'; % default value
else % there's relevant option
	char2 = opts{ord2,2};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

done = round( barsize * percent / 100);
remains = barsize - done;

str1 = repmat([char2],1,done);
str2 = repmat([' '],1,remains);
str5 = ['[',str1,str2,']'];
str3 = sprintf('%3.1f',percent);
str4 = [' ',str3,' % '];

m = length(str4); n = length(str5);
p = round(n / 2) - round(m / 2) + 1;
q = p + m - 1;

str5(p:q) = str4;
bar_string = str5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
