function m_circles
%M_CIRCLES - Superimposes the M circles of magnitude -2dB to 20 dB.
% This function is useful to measure the gain margins on a Nyquist's
% Diagram
%
% Syntax: m_circles
%
%
% Example: 
%    G=tf(1,[1 2 1]);
%    nyqmimo(G);
%    m_circles
%
% Other m-files required: none
% See also: nyqmimo, nyquist
%
% Author: Oskar Vivero Osornio
% email: oskar.vivero@gmail.com
% Created: February 2006; 
% Last revision: 11-May-2006;

% May be distributed freely for non-commercial use, 
% but please leave the above info unchanged, for
% credit and feedback purposes

%------------- BEGIN CODE --------------
if ishold,
	WasHold = 1;
else
	WasHold = 0;
	hold on;
end

vM=[-2 -4 -6 -10 -20 2 4 6 10 20];
r=zeros(1,length(vM));
x=zeros(1,length(vM));

for i=1:length(vM)
    M=10^(vM(i)/20);
    theta=0:0.1:(2*pi)+0.1;
    x(i)=-(M^2)/(M^2-1);
    r(i)=abs(M/(M^2-1));
    R=repmat(r(i),1,length(theta));
    X=R.*cos(theta);
    Y=R.*sin(theta);
    plot(X+x(i),Y,':k')
    text(x(i),r(i)+0.08,int2str(vM(i)),'Fontsize',8)
end

if ~WasHold
    hold off
end
%------------- END OF CODE --------------