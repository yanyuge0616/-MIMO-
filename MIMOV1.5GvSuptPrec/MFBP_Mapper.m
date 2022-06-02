function [meanOut covOut] = MFBP_Mapper(soft_bits_all,mean_all,cov_all,meaning, coordinateset)
%Author Carles Navarro & Mihai Badiu
%
% This Mapper performs message combining from the BP part (decoder+mod) and
% the MF part of the receiver (MIMO detection). The BP message is the pmf
% of the different constellation points, obtained from the decoder. The MF
% message is a Gaussian distribution originated in the MIMO detector. The
% output MF message corresponds to the mean and variance of the combined
% messages.
% INPUTS:   Mod: modulation order
%           soft_bits: EXT soft values of the decoder, in the form of log
%                       probabilities of bits being 0 or 1
%           mean: mean of the input MF message
%           cov: covariance of the input MF message
% OUTPUTS:  meanOut: mean of the output MF message
%           covOut: covariance of the output MF message

% [meaning coordinateset]=Modulation(Mod);
S = length(coordinateset);
M = size(meaning,1);
Nsymb = length(mean_all);
meanOut = zeros(Nsymb,1);
covOut = zeros(Nsymb,1);

for ns = 1:Nsymb
    symbLogProb=zeros(1,S);
    normConst = -Inf;      
    soft_bits = soft_bits_all(((ns-1)*M+1):ns*M,:);
    mean = mean_all(ns);
    cov = cov_all(ns);
    for constPointInd = 1:S
        for bitInd = 1:M
            symbLogProb(constPointInd) = symbLogProb(constPointInd) + soft_bits( bitInd, meaning(bitInd,constPointInd)+1 );
        end
        symbLogProb(constPointInd) = symbLogProb(constPointInd) - abs(coordinateset(constPointInd)-mean)^2/cov;
        % apply max*(x,y)
        y = symbLogProb(constPointInd);
        z = -Inf;
        if isfinite(normConst) || isfinite(y)
            m = max(normConst,y);
            z = m + log( 1 + exp( -(m-normConst) - (m-y) ) );
        end
        normConst = z;
    end
    
    % Normalization of logprob values
    symbLogProb = symbLogProb-normConst;
    % Translation to linear probability values
    symbProb = exp(symbLogProb);
    meanOut(ns) = sum((symbProb).*coordinateset);
    covOut(ns) = sum((symbProb).*(abs(coordinateset-meanOut(ns)).^2));
end

