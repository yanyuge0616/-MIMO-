function [A,cond] = rga(a,b,c,d,w)
%RGA - Finds the RGA (relative gain array) matrix A of an LTI MIMO SYS
% model at a certain frequency value (w). The use of RGA its helpful for
% finding the coupling grade of a MIMO system.
%
% Syntax:  [A,cond] = rga(SYS,w)
%
% Inputs:
%    SYS - LTI MIMO system, either in State Space or Transfer Function
%    representation.
%    w - Frequency value (default w=0).
%
% Outputs:
%    A - RGA Matrix
%    cond - Conditional Number
%
% Example: 
%    g11=tf(2,[1 3 2]);
%    g12=tf(0.1,[1 1]);
%    g21=tf(0.1,[1 2 1]);
%    g22=tf(6,[1 5 6]);
%    G=[g11 g12; g21 g22];
%    A=rga(G)
%
% Other m-files required: tf2sym, ss2sym
%
% See also: gershband
%
% Author: Oskar Vivero Osornio
% email: oskar.vivero@gmail.com
% Created: February 2006; 
% Last revision: 25-March-2006;

% May be distributed freely for non-commercial use, 
% but please leave the above info unchanged, for
% credit and feedback purposes

%------------- BEGIN CODE --------------
% Determines Syntax
ni=nargin;
no=nargout;

switch ni
    case 1
        %Transfer Function Syntax without frequency
        w=0;
        switch class(a)
            case 'tf'
                %Numeric Transfer Function Syntax
                g=tf2sym(a);
        
            case 'sym'
                %Symbolic Transfer Function Syntax
                g=a;
        end

    case 2
        %Transfer Function Syntax
        w=b;
        switch class(a)
            case 'tf'
                %Numeric Transfer Function Syntax
                G=a;
                g=tf2sym(G);
        
            case 'sym'
                %Symbolic Transfer Function Syntax
                g=a;
        end

    case 4
        %State Space Syntax without frequency
        g=ss2sym(a,b,c,d);
        w=0;

    case 5
        %State Space Syntax with frequency
        g=ss2sym(a,b,c,d);
end

%****************************************************************

[n,m]=size(g);
if n==m
    A=g.*(inv(g)).';
else
    A=g.*(pinv(g)).';
end

A=subs(A,complex(0,w));

if isa(A,'sym')==true
    A=simplify(subs(A,complex(0,w)));
end

if no==2
    cond=simplify(sum(sum(abs(A))));
end
%------------- END OF CODE --------------