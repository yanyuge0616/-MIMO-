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
num_of_bits = 10000;
% transmit 2 bits as one symbol at a time and transmit 500,000 times
x = round(rand(2, num_of_bits/2));
% use QPSK to modulate the input bits
temp1 = pskmod((bi2de(x'))', 4, pi/4, 'gray');
temp1 = reshape(temp1, 2, num_of_bits/4);
temp2 = conj(flip(temp1));
temp2(1,:) = -temp2(1,:);
% use Alamouti code
X = zeros(2, num_of_bits/2);
X(:, 1:2:end) = temp1;
X(:, 2:2:end) = temp2;

%  nR-dimensional i.i.d. complex Gaussian noise vector
% n = zeros(nR, 1);
N = sqrt(1/2) * (randn(nR, num_of_bits/2)+1i*randn(nR, num_of_bits/2));
n = sqrt(1/2) * (randn(nR, num_of_bits/4)+1i*randn(nR, num_of_bits/4));

% SNR (unit: dB)
rho_db = 0:3:36;
ber_ml_alam = zeros(size(rho_db));
ber_ml_uncoded = zeros(size(rho_db));

for k = 1:num_of_H
%     tic;
    disp("Iter: "+k);
    for i = 1:size(rho_db, 2)
        rho = 10 ^ (rho_db(i) / 10);
        % Alamouti code bit error rate computation
        % The nR-dimensional received signal
        Y = sqrt(rho/nT) * (H(:,:,k) * X) + N; % Y = num_of_bits/4 (2-by-2 matrixs)
        
        % x detected by standard maximum-likelihood (ML) detector
        x_ml_alam = argmin_alam(Y, sqrt(rho/nT) * H(:,:,k));
        
        % bit error rate
        ber_ml_alam(i) = ber_ml_alam(i) + sum(sum(x_ml_alam~=x)) / num_of_bits;
        
        
        % uncoded bit error rate computation
        % The nR-dimensional received signal
        y = sqrt(rho/nT) * (H(:,:,k) * temp1) + n;
        % x detected by standard maximum-likelihood (ML) detector
        x_ml_uncoded = argmin_uncoded(y, sqrt(rho/nT) * H(:,:,k));
        % bit error rate
        ber_ml_uncoded(i) = ber_ml_uncoded(i) + sum(sum(x_ml_uncoded~=x)) / num_of_bits;
        
        % disp("iter " + i);
    end
%     toc;
end
ber_ml_alam = ber_ml_alam / num_of_H;
ber_ml_uncoded = ber_ml_uncoded / num_of_H;

%%
figure(1);
semilogy(rho_db, ber_ml_alam);
title('Bit error rate of a 2-by-2 MIMO system with Alamouti code, QPSK modulation and Gray mapping');
xlabel('SNR (dB)');
ylabel('Capacity (bps/Hz)');
legend("Alamouti Code - ML");

figure(2);
semilogy(rho_db, ber_ml_alam, rho_db, ber_ml_uncoded);
title('Bit error rate of a 2-by-2 MIMO system with QPSK modulation and Gray mapping');
xlabel('SNR (dB)');
ylabel('Capacity (bps/Hz)');
legend("Alamouti Code - ML", "Uncoded - ML");

function x_ml = argmin_alam(Y, H_)
[R, C] = size(Y);
x_ml = zeros(R, C);

x_dec = [0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3;
    0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3];
x_constellation = pskmod(x_dec, 4, pi/4, 'gray');
x_constellation2 = conj(flip(x_constellation));
x_constellation2(1,:) = -x_constellation2(1,:);

error = zeros(1, 16);
for i = 1:2:(size(Y, 2))   % num_of_bits/4
    for j = 1: 16           % 16 combination of x
        % Frobenius Norm
        error(j) = norm(Y(:,i:i+1)-H_*[x_constellation(:,j) x_constellation2(:,j)], 'fro').^2;
    end
    [~, I] = min(error);
    x_ml(:,i) = (x_dec(:,I))';
end
x_ml(:, 2:2:end) = [];
x_ml = (de2bi(reshape(x_ml, 1, C)))';
end

function x_ml = argmin_uncoded(y, H_)
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

x_ml = (de2bi(reshape(x_ml, 1, C*2)))';
end

