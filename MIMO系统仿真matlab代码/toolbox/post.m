function post(varargin)

%POST Data post-processing.
%   POST simply plots the system performance so that it can be directly
%   exported into the file.
%
%   See also MIMO, LOGREPORT.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 1.0 $  $Date: 2003/5/29 22:36:22 $
%   --
%   <additional stuff goes here>

global VERSION

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

j = 1;

for i = 1:length(varargin) / 2;
  x = varargin{1};
  y = varargin{2};
  curve = semilogy(x,y); hold on;
  j = j + 2;
end

set(curve,'LineWidth',2);
grid on;

figtitle = ['MIMOTOOLS ',VERSION,' - Code Performance'];
wintitle = ['MIMOTOOLS: Code Performance'];
ft = title(figtitle);
xlabel('E_b/N_0 [dB]');
ylabel('SER [-]');

set(ft,'FontWeight','bold','FontSize',12);
set(gcf,'Name',wintitle);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
