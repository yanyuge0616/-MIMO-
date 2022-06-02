function metric = brmet(sig,q_test,ch_coefs);

%BRMET User defined branch metric.
%   RHO = BRMET(R,Q,ALPHA) evaluates branch metric and returns the
%   result as a column vector for all testing channel symbols Q. The
%   entries of RHO variable correspond to the squared Euclidean distance
%   of received signal R and testing channel symbols Q. ALPHA simply
%   contains the complex path fadings of the MIMO channel.
%
%   See also DETECT, CHANNEL.

%   Copyright 2001-2003 Kamil Anis, anisk@feld.cvut.cz
%   Dept. of Radioelectronics, 
%   Faculty of Electrical Engineering
%   Czech Technical University in Prague
%   $Revision: 2.1 $  $Date: 2003/1/16 17:33:28 $
%   --
%   <additional stuff goes here>

[m,n] = size(ch_coefs);
[q_dim,foo] = size(q_test);
sig = repmat(sig,q_dim,1);
outsum = 0;

for j=1:m % outer sum
  insum = 0;
  
	for i=1:n % inner sum
      insum1 = ch_coefs(i,j) .* q_test(:,i);
      insum = insum + insum1;
	end
  
  outsum1 = abs(sig(:,j) - insum) .^ 2;
  outsum = outsum + outsum1;
end
  
metric = outsum;
