function varargout = hms(time,varargin);

%HMS Convert time to hour-min-sec format.
%   [STR] = HMS(TIME) takes the time variable in seconds and returns the
%   string of the form `xx hours, xx min, xx sec'. Note that Format
%   property must be set to 'string'.
%
%   [H,M,S] = HMS(TIME) simlply returns hour-min-sec time format.
%
%   [...] = HMS(TIME,'PropertyName',PropertyValue,...)
%
%   Hms Property List
%
%   Format         {'numeric'} | 'string'
%
%   See also TIC, TOC, CLOCK.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 1.0 $  $Date: 2003/5/23 20:55:18 $
%   --
%   <additional stuff goes here>

nopts = length(varargin) / 2;
opts = reshape(varargin,[2 nopts])';

ord1 = strmatch('Format',opts(:,1));

% Format
if isempty(ord1) % there's no such option
	form = 'numeric'; % default value
else % there's relevant option
	form = opts{ord1,2};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hour = round(time / 3600); 
mins = round(time / 60); 
secs = mod(time,60);

str1 = sprintf('%1d',hour); 
str2 = sprintf('%1d',mins); 
str3 = sprintf('%1.1f',secs);

switch form
  case 'numeric'
    varargout = {hour,mins,secs};
  case 'string'
    varargout = {str1,str2,str3};
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
