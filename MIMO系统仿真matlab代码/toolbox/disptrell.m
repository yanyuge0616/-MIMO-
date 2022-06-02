function disptrell(dlt,slt,data_est,state_est,varargin)

%DISPTRELL Display decoding process in graphical form.
%   DISPTRELL(DLT,SLT,D_E,S_E) displays most probable path and data
%   estimations in decoding process. DLT and SLT look-up tables are
%   required to display code trellis with all possible transitions. The
%   DISPTRELL function doesn't affect the detection process. It's just a
%   tool intended for lectures and presentations. As it belongs to the
%   Visual Layer it's not included in the DETECT function to speed up
%   decoding process.
%
%   DISPTRELL(...,'PropertyName',PropertyValue,...)
%
%   Disptrell Property List
% 
%   Shrink         0 < SHRINK < {0.5}
%
%   See also DETECT.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

name = 'DISPTRELL';
[idt,tag] = iecho(name);

[s,md,space_dim] = size(dlt);
[symbols,foo,frames] = size(data_est);
framecut = 15;

% only one frame perfigure can be displayed
if frames > 1
  str5 = num2str(frames);

  disp(' ');
  disp([tag,'Data consists from ',str5,' frame(s).']);
  disp([idt,'Only one frame per figure can be displayed!'])
  disp(' ');

  data_est = data_est(:,1,1);
end

% max 20 symbols can be displayed
if symbols > 20
  str6 = num2str(framecut);

  disp(' ');
  disp([tag,'Frame is too long!']);
  disp([idt,'Only first ',str6,' symbols will be displayed.'])
  disp(' ');

	endstate = framecut;
	data_est = data_est(1:framecut,1,1);
else
	endstate = symbols;
end

% default shrink factor
if length(varargin) == 1
	shrink = varargin{1};
else
	shrink = 1 / 2;
	shrink_axis = (s + 1) * shrink;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

offset = 0.1;
clf;

for k = 1:endstate
	x1 = k; x2 = k + 1;
	for i = 1:s
		for j = 1:md
			y1 = i;
			y2 = slt(i,j,:);
			
			trellis = line([x1 x2],[y1,y2]);
			set(trellis,'LineStyle',':');
		end
		str = num2str(i);
		text(0.5,i,str,'HorizontalAlignment','Center');
	end
	backpath = line([k k + 1],[state_est(k) state_est(k + 1)]);
	set(backpath,'Color','red','LineWidth',2);
	str1 = num2str(k);
	text(k,s + 1,str1,'HorizontalAlignment','Center');
	
	str2 = num2str(data_est(k));
	str3 = text(k + offset,state_est(k) - offset,str2);
	set(str3,'HorizontalAlignment','Center','FontWeight','bold');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

text((endstate + 1) / 2,s + 2,'Steps [\itk\rm]')
text(0.5,-0.5,'States','HorizontalAlignment','Center')
legend([backpath;trellis],['Back path  ';'Transitions']);

figtitle = ['Best path found with Viterbi iterative decoder'];
wintitle = [name,': ',figtitle];
ft = title(figtitle);

set(ft,'FontWeight','bold','FontSize',12);
set(gcf,'Name',wintitle);

axis([1,endstate + 1,1 - (s / shrink_axis),s + (s / shrink_axis)]);
axis off;
view(0,-90);

