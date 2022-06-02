function [ h ] = generateSubcarrierGains( Gains, Delays, Df, K )
% Author: Mihai Badiu
%GENERATESUBCARRIERGAINS Summary of this function goes here
%   Detailed explanation goes here

Paths = length(Delays);
a = zeros(Paths,1);
avgPower = 10.^(Gains/10);
avgPower = avgPower/sum(avgPower); % normalize average power

for p = 1:Paths
    a(p) = sqrt(0.5*avgPower(p)) * (randn(1,1) + 1i*randn(1,1));
end

h = zeros(K,1);
fk = 0;
for k = 1:K
    h(k) = 0;
    for p = 1:Paths
        h(k) = h(k) + a(p)*exp(-1i*2*pi*fk*Delays(p));
    end
    fk = fk + Df;
end

end

