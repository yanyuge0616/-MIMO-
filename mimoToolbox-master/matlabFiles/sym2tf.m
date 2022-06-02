function G = sym2tf(g)
%SYM2TF - Symbolic Transfer Function to Numerical Transfer Function
%conversion
%
% Syntax:  G = sym2tf(g)
%
% Inputs:
%    g - Symbolic Transfer Function representation
%
% Outputs:
%    G - Numeric Transfer Function representation
%
% Example: 
%    syms p
%    g11=(p + 2)/(p^2 + 2*p + 1);
%    g12=(p - 1)/(p^2 + 5*p + 6);
%    g21=(p - 1)/(p^2 + 3*p + 2);
%    g22=(p + 2)/(p + 1);
%    g=[g11 g12; g21 g22];
%    G=sym2tf(g)
%
% See also: tf2sym, ss2sym
%
% Author: Oskar Vivero Osornio
% email: oskar.vivero@gmail.com
% Created: February 2006; 
% Last revision: 25-March-2006;

% May be distributed freely for non-commercial use, 
% but please leave the above info unchanged, for
% credit and feedback purposes

%------------- BEGIN CODE -------------
[n,m]=size(g);
for i=1:n
    for j=1:m
        [num,den]=numden(g(i,j));
        num_n=sym2poly(num);
        den_n=sym2poly(den);
        G(i,j)=tf(num_n,den_n);
    end
end
%------------- END OF CODE --------------