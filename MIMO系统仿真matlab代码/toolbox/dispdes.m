function dispdes(dlt,slt)

%DISPDES Display designed code in a graphical form.
%   DISPDES(DLT,SLT) picks-up the entries from DLT and SLT look-up
%   tables and displays designed code in graphical form. The figure may
%   be than exported into various graphical formats including JPEG, GIF, 
%   PostScript and inserted into the report.
%
%   See also LTABLE.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.2 $  $Date: 2003/4/15 15:13:28 $
%   --
%   <additional stuff goes here>

name = 'DISPDES';
[idt,tag] = iecho(name);

[s,md,space_dim] = size(dlt);
[l,foo,partran] = size(slt);

% parallel trasitions check -> won't be displayed
if partran > 1
  str5 = num2str(partran);

  disp(' ');
  disp([tag,str5,' parallel transitions detected.']);
  disp([idt,'Paralel transitions will not be diplayed.'])
  disp(' ');

  slt = slt(:,:,1);
end

% figure size and offset adjustment
switch md
case 16
	set(gcf,'Position',[200 514 850 420]);
  offset = 20;
case 8
  offset = 0;
case 4
  offset = -3;
otherwise
  offset = -3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY BEGIN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clf;
x1 = 5.5 + offset; x2 = 10 + offset;

for i = 1:s
  str = '';
  for j = 1:md
    y1 = i;
    y2 = slt(i,j,:);
    line([x1 x2],[y1,y2]);

  	d = dlt(i,j,:);
    d = reshape(d,[1 space_dim]);

    str1 = sprintf('%d ',d);
    str = [str str1,', '];
  end

  text(5 + offset,i,str,'HorizontalAlignment','Right');
end

axis([0 10 + offset 0 s]);
axis off;
view(0,-90);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BODY END %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (md == 4) | (md == 8)
      str2 = 'PSK';
else
      str2 = 'QAM';
end

str1 = num2str(md);
str3 = num2str(s);
str4 = num2str(log2(md));

figtitle = ['Space-time code, ',str1,str2,', ',str3,' states, ',...
      str4,' bit/sec/Hz'];
wintitle = ['DISPDES: ',figtitle];
ft = title(figtitle);

set(ft,'FontWeight','bold','FontSize',12);
set(gcf,'Name',wintitle);
