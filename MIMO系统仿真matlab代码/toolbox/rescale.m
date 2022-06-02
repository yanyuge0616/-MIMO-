function gain = scale(md,symb_energy,varargin)

%SCALE Constellation expansion factor.
%   G = RESCALE(MD,Es) simply computes an expansion constellation factor
%   sets the modulated signal power. Symbol energy Es is assumed to be
%   equal Ts.Ps i.e. the symbol time duration and transmitted signal
%   power respectively. MD corresponds to the number of constellation
%   signals. Possible values for MD are 4|8|16 which corresponds to 4PSK,
%   8PASK and 16QAM constellations respectively.
%
%   Rescale Property List
%
%   Constellation  {'4PSK'} | '8PSK' | '16QAM'
%
%   See also MODUL.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

name = 'RESCALE';
[idt,tag] = iecho(name);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch md
case 16 % 16QAM
  md_qam = log2(md);
  gain = sqrt(6 * symb_energy / (md_qam ^ 2 + md_qam ^ 2 - 2));
otherwise % 4PSK, 8PSK
  gain = sqrt(2 * symb_energy);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
