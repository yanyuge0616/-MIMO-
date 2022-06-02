function [ LLR ] = logP_to_LLR( soft_bits )
% Author: Mihai Badiu
%LOGP_TO_LLR converts the probabilities (in log domain) log(P(b=0)) and
%log(P(b=1)) to log-likelihood ratio: LLR = log(P(b=1)/P(b=0)) =
%log(P(b=1)) - log(P(b=0));

LLR = soft_bits(:,2) - soft_bits(:,1);

end

