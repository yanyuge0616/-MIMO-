function [ soft_bits ] = LLR_to_logP( LLR )
% Author: Mihai Badiu
%LLR_TO_LOGP converts the log-likelihood ratio: LLR = log(P(b=1)/P(b=0)) to
%probabilities (in log domain): log(P(b=0)) and log(P(b=1))
N = length(LLR);
soft_bits = zeros(N,2);
for n = 1:N
    soft_bits(n,1) = -max_special(0,LLR(n));
    soft_bits(n,2) = -max_special(0,-LLR(n));
end

end

