clc;
clear;
close all;

figure(1);
box;
title('MIMO capacity vs. SNR (dB) for different n_R and n_T');
xlabel('SNR (dB)');
ylabel('Capacity (bps/Hz)');
hold on;
for n = 5: 10
    plotCapacityCurve(n);
end
legend show;
hold off;

function plotCapacityCurve(num)
nT = num;
nR = num;

% nR-dimensional i.i.d. complex Gaussian noise vector
% n = zeros(nR, 1);
n = sqrt(1/2) * (randn(nR, 1)+1i*randn(nR, 1));

% SNR (unit: dB)
rho_db = 0: 1: 30;

CH_avg_curve = zeros(size(rho_db));
for i=1:size(rho_db, 2)
    CH_avg_curve(i) = capacityCal(nR, nT, rho_db(i));
end

plot(rho_db, CH_avg_curve, 'DisplayName', "n="+ nT); % legend("n=" + nT);
end


function CH_avg = capacityCal(nR, nT, rho_db)
rho = 10 ^ (rho_db / 10);

CH = 0;
num_of_iter = 10000;

for i = 1: num_of_iter
    % nR-by-nT complex Gaussian channel matrix with i.i.d. entries
    % H = zeros(nR, nT);
    H = sqrt(1/2) * (randn(nR, nT)+1i*randn(nR, nT));
    
    % instantaneous MIMO capacity
    I = eye(nR, nT);
    CH = CH + real(log2(det(I + (rho/nT) .* (H * H'))));
end

CH_avg = CH / num_of_iter;
end

