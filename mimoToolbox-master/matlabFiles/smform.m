function [M,poles,zeros] = smform(a,b,c,d)
%SMFORM - Finds the Smith-McMillan form of a LTI MIMO SYS model along with
%its poles and zeros.
%
% Syntax:  [M,poles,zeros] = smform(SYS)
%
% Inputs:
%    SYS - LTI MIMO system, either in State Space or Transfer Function
%    representation.
%
% Outputs:
%    M - Smith-McMillan Matrix
%    poles - Poles of the Smith-McMillan Matrix
%    zeros - Zeros of the Smith-McMillan Matrix
%
% Example: 
%   g11=tf([1 0],conv(conv([1 1],[1 1]),conv([1 2],[1 2])));
%   g12=tf(conv([1 0],conv([1 1],[1 1])),conv(conv([1 1],[1 1]),conv([1 2],[1 2])));
%   g21=tf(-conv([1 0],conv([1 1],[1 1])),conv(conv([1 1],[1 1]),conv([1 2],[1 2])));
%   g22=tf(-conv([1 0],conv([1 1],[1 1])),conv(conv([1 1],[1 1]),conv([1 2],[1 2])));
%   G=[g11 g12; g21 g22];
%   [M,poles,zeros]=smform(G)
%
% Other m-files required: tf2sym, ss2sym
% Subfunctions: multiplica
%
% Author: Oskar Vivero Osornio
% email: oskar.vivero@gmail.com
% Created: February 2006; 
% Last revision: 13-Dec-2017;

% May be distributed freely for non-commercial use, 
% but please leave the above info unchanged, for
% credit and feedback purposes

%------------- BEGIN CODE --------------
% Determines Syntax
ni=nargin;
p=sym('p');

switch ni
    case 1
        %Transfer Function Syntax
        switch class(a)
            case 'tf'
                %Numeric Transfer Function Syntax
                g=tf2sym(a);
            case 'sym'
                %Symbolic Transfer Function Syntax
                g=a;
        end
        
    case 4
        %State Space Syntax
        g=ss2sym(a,b,c,d);
end

%****************************************************************
% Common Denominator
[n,m]=size(g);
[num,den]=numden(g);
d=den;
d=reshape(d,1,n*m);
while (length(d))>1
    k=1;
    d1=sym([]);
     for i=2:length(d)
%     d1(k)=lcm(factor(d(i)),factor(d(i-1)));
     d1(k)=lcm(d(i),d(i-1));
     k=k+1;
     end
d=d1;
clear d1
end

%****************************************************************
% Determines P, S, and finally M
P=simplify(d*g);
S=smithForm(P);
M=simplify(S/d);

%****************************************************************
% Determines the poles and zeros
clear num den
n=size(M,1);
for i=1:n
    [num(i),den(i)]=numden(M(i,i));
end
d=prod(den);
n=prod(num);
n=sym2poly(n);
poles=solve(d);
zeros=roots(n);
%------------- END OF CODE --------------