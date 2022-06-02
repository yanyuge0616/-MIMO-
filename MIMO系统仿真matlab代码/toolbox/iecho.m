function [ispace,strout] = iecho(str);

%IECHO Indent echo
%   [IDT,TAG] = IECHO(NAME) is a useful utility which allows function
%   echoes to be indented. The script returns an empty string IDT such
%   that is inserted in front of displayed text. Than you don't need to
%   take care about prompt indenting any more. To change indent
%   spacing set the INDENT variable to the desired value. Default value
%   for INDENT is 11 (characters). This means that 11 blank spaces will
%   inserted in front of the NAME. INDENT may also be set globally.
%
%   Example:
%     [indent,tag] = iecho('FUNCTION');
%     disp(' ');
%     disp([tag,'Some echo on the 1st line.']);
%     disp([idt,'Some echo on the 2nd line.'])
%     disp([idt,'Some echo on the 3rd line.'])
%     disp([idt,'Some echo on the 4th line.'])
%     disp(' ');

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Pragu
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

global INDENT

if ~isempty(INDENT) % than check whether global option exists
	indent = INDENT;
else % if there are no settings use the defaults
	indent = 12; % default value
end

if indent <= length(str)
	tspace = ' ';
else
	tlength = indent - length(str) - 2;
	tspace(1:tlength) = ' ';
end

ispace(1:indent - 1) = ' ';
strout = [str,':',tspace];
