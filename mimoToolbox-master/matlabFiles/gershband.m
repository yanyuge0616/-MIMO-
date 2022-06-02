function gershband(a,b,c,d,e)
%GERSHBAND - Finds the Gershorin Bands of a nxn LTI MIMO SYS model
% The use of the Gershorin Bands along the Nyquist plot is helpful for
% finding the coupling grade of a MIMO system.
%
% Syntax: gershband(SYS) - computes the Gershgorin bands of SYS
%         gershband(SYS,'v') - computes the Gershgorin bands and the
%                              Nyquist array of SYS
% Inputs:
%    SYS - LTI MIMO system, either in State Space or Transfer Function
%    representation.
%
% Example: 
%    g11=tf(2,[1 3 2]);
%    g12=tf(0.1,[1 1]);
%    g21=tf(0.1,[1 2 1]);
%    g22=tf(6,[1 5 6]);
%    G=[g11 g12; g21 g22];
%    gershband(G);
%
% Other m-files required: sym2tf, ss2sym
% Subfunctions: center, radio
% See also: rga
%
% Author: Oskar Vivero Osornio
% email: oskar.vivero@gmail.com
% Created: February 2006; 
% Last revision: 11-May-2006;

% May be distributed freely for non-commercial use, 
% but please leave the above info unchanged, for
% credit and feedback purposes

%------------- BEGIN CODE --------------
%--------- Determines Syntax -----------
ni=nargin;

switch ni
    case 1
        %Transfer Function Syntax
        switch class(a)
            case 'tf'
                %Numeric Transfer Function Syntax
                g=a;

            case 'sym'
                %Symbolic Transfer Function Syntax
                g=sym2tf(a);
        end
        e=0;
    case 2
        %Transfer Function Syntax with Nyquist Array
        switch class(a)
            case 'tf'
                %Numeric Transfer Function Syntax
                g=a;

            case 'sym'
                %Symbolic Transfer Function Syntax
                g=sym2tf(a);
        end
        e=1;

    case 4
        %State Space Syntax
        g=ss2sym(a,b,c,d);
        g=sym2tf(g);
        e=0;
    case 5
        %State Space Syntax
        g=ss2sym(a,b,c,d);
        g=sym2tf(g);
        e=1;
end
%---------------------------------------
[n,m]=size(g);
w=logspace(-1,6,200);
q=0:(pi/50):(2*pi);

for i=1:n
    for j=1:m
        if i==j
            figure(i)
            nyquist(g(i,i));
            grid on
            title(['Nyquist Diagram of G(',num2str(i),',',num2str(j),')'])
            for iest=1:n
                for jest=1:m
                    if iest~=jest
                        hold on
                        C=center(g(i,j),w);
                        R=radio(g(iest,jest),w);
                        for k=1:length(C)
                            plot((R(k)*cos(q))+real(C(k)),(R(k)*sin(q))+imag(C(k)),'g-')
                        end
                        hold off
                    end
                end
            end
        end
    end
end

if e==1
    figure(n+1)
    nyquist(g);
    grid on
end
%------------ Subfunction --------------
function C = center(g,w)
g=tf2sym(g);
C=subs(g,complex(0,w));

function R = radio(g,w)
g=tf2sym(g);
R=abs(subs(g,complex(0,w)));
%------------- END OF CODE --------------