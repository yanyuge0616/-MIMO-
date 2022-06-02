clc;
clear;
close all;

nR = 2;
nT = 2;

% nR-by-nT complex Gaussian channel matrix with i.i.d. entries
% H = zeros(nR, nT);
% create a 3D matrix to store 300 different H
num_of_H = 300;
H = sqrt(1/2) * (randn(nR, nT, num_of_H)+1i*randn(nR, nT, num_of_H));

% transmitted signal x satisfies the unit power constraint
num_of_bits = 1000000;
% transmit 2 bits as one symbol at a time and transmit 500,000 times
x = round(rand(2, num_of_bits/2));
% use QPSK to modulate the input bits
x_mod = pskmod((bi2de(x'))', 4, pi/4, 'gray');
x_mod = reshape(x_mod, 2, num_of_bits/4);

%  nR-dimensional i.i.d. complex Gaussian noise vector
% n = zeros(nR, 1);
n = sqrt(1/2) * (randn(nR, num_of_bits/4)+1i*randn(nR, num_of_bits/4));

% SNR (unit: dB)
rho_db = 0:5:35;
ber_ml = zeros(size(rho_db));
ber_zf = zeros(size(rho_db));
ber_mmse = zeros(size(rho_db));

for k = 1:size(H, 3)
    disp("iter: "+k);
    for i = 1: size(rho_db,2)
        rho = 10 ^ (rho_db(i) / 10);
        
        % The nR-dimensional received signal
        y = sqrt(rho/nT) * (H(:,:,k) * x_mod) + n;
        
        % x detected by standard maximum-likelihood (ML) detector
        x_ml = argmin(y, sqrt(rho/nT) * H(:,:,k));
        
        % bit error rate
        ber_ml(i) = ber_ml(i) + sum(sum(x_ml~=x)) / num_of_bits;
        % disp("iter " + i + " bit error rate: " + ber_ml(i));
        
        % x detected by zero-forcing (ZF)
        x_zf = (sqrt(rho/nT) * H(:,:,k)) \ y;              % 2 by num_of_bits/4 matrix
        x_zf = pskdemod(x_zf, 4, pi/4, 'gray');     % demodulate the bits
        x_zf = reshape(x_zf, 1, num_of_bits/2);     % 1 by num_of_bits/2 matrix
        x_zf = (de2bi(x_zf))';                      % convert decimal to binary
        ber_zf(i) = ber_zf(i) + sum(sum(x_zf~=x)) / num_of_bits;
        % disp("bit error rate: " + ber_zf(i));
        
        I = eye(nR, nT);
        x_mmse = inv((rho/nT)*(H(:,:,k)'*H(:,:,k))+I) * sqrt(rho/nT) * H(:,:,k)' * y;
        x_mmse = (de2bi(reshape(pskdemod(x_mmse, 4, pi/4, 'gray'), 1, num_of_bits/2)))';
        ber_mmse(i) = ber_mmse(i) + sum(sum(x_mmse~=x)) / num_of_bits;

        % disp("bit error rate: " + ber_zf(i));
        
    end
end
ber_ml = ber_ml / size(H, 3);
ber_zf = ber_zf / size(H, 3);
ber_mmse = ber_mmse / size(H, 3);

%%
figure(1);
semilogy(rho_db, ber_ml, rho_db, ber_zf, rho_db, ber_mmse);
title('Bit error rate of a 2-by-2 MIMO system with QPSK modulation with Gray mapping');
xlabel('SNR (dB)');
ylabel('Capacity (bps/Hz)');
legend("ML", "ZF", "MMSE");

function x_ml = argmin(y, H_)
[R, C] = size(y);
x_ml = zeros(R, C);

x_dec = [0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3;
    0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3];
x_constellation = pskmod(x_dec, 4, pi/4, 'gray');

error = zeros(1, 16);
for i = 1: size(y, 2)
    for j = 1: 16
        error(j) = norm(y(:,i)-H_*x_constellation(:,j)).^2;
    end
    [M, I] = min(error);
    x_ml(:,i) = (x_dec(:,I))';
end
x_ml = reshape(x_ml, 1, C*2);
x_ml = (de2bi(x_ml))';
end

