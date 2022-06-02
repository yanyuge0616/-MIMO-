function g = ss2sym(a,b,c,d)
%SS2SYM - State Space to Symbolic Transfer Function conversion.
%
% Syntax:  g = ss2sym(SYS)
%
% Inputs:
%    SYS - State Space system representation
%
% Outputs:
%    g - Transfer Function system representation
%
% Example: 
%    A = [0 1 0 0 0; 0 0 1 0 0; -2 -5 -4 0 0; 0 0 0 0 1; 0 0 0 -3 -4];
%    B = [0 0; 0 0; 1 0; 0 0; 0 1];
%    C = [1 2 1 9 3; 14 9 1 1 1];
%    D = [0 1; 0 0];
%    g=ss2sym(A,B,C,D);
%    pretty(g)
%
% See also: tf2sym, sym2tf
%
% Author: Oskar Vivero Osornio
% email: oskar.vivero@gmail.com
% Created: February 2006; 
% Last revision: 25-March-2006;

% May be distributed freely for non-commercial use, 
% but please leave the above info unchanged, for
% credit and feedback purposes

%------------- BEGIN CODE --------------
p=sym('p');
[n,m]=size(a);
if n~=m
    error('El sistema debe ser cuadrado')
end
g=simplify(c*inv(p*eye(n) - a)*b +d);
%------------- END OF CODE --------------