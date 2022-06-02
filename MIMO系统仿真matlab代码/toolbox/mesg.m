%MESG Display progress information.
%   MESG subroutine displays progress status when performing MIMO system
%   performance measurement. Therefore it makes no sense to run this
%   routine alone. 
%   
%   See also MIMO, PROGRESS.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/5/23 20:51:24 $
%   --
%   <additional stuff goes here>

clc;
steps = length(ch_snr);
str1 = num2str(ch_snr(i));
str2 = num2str(100 * i / steps);
done = 100 * i / steps;
str3 = num2str(i);

timing = timing + toc;
timeest = (length(ch_snr) - i) * toc;

[str2,str3,str4] = hms(timing,'Format','string');
[str6,str7,str8] = hms(timeest,'Format','string');

msg = sprintf('Processing measurement #%d of %d at SNR %1.1f [dB].',...
  i,steps,ch_snr(i));
str5 = progress(done);

disp(' ');
disp([tag,msg]);
disp(' ');
disp([idt,str5]);
disp(' ');
disp([idt,'Elapsed time -> ',str2,' hrs, ',str3,' min, ',str4,...
	' sec.']);
disp([idt,'Estimated time -> ',str6,' hrs, ',str7,' min, ',str8,...
	' sec.']);
disp(' ');
