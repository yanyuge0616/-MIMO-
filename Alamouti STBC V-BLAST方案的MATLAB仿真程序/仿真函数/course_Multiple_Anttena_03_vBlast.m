clc; clear; close all;
tic;

%% Key Parapmeters
M = 4;
N = 6;
snr_dB = (-10: 1: 15);
N_repeat = 1e+7;

snr = 10.^(snr_dB / 10);
N_snr = length(snr);

%% Loop and Operation

%% Opt 01: Zero-Forcing
% Different S/N Ratio
ber = zeros(1, N_snr);
for ite_snr = 1:N_snr
    snr_rate = snr(ite_snr);
    
    ber_array = zeros(1, N_repeat);
    parfor ite_repeat = 1:N_repeat
        % Generate Tx Symbol
        tdi = zeros(M, 1);
        for tx_ite=1:M
            tdi(tx_ite) = (round(rand) * 2) - 1;
        end
        % P_sig = rms(tdi)^2;
        P_sig = getPower(tdi);
        P_noise_Desired = P_sig / snr_rate;
        
        noise = randn(N, 1);
        P_noise = getPower(noise);
        % P_noise = rms(noise)^2;
        % err = P_noise - P_noise_1;
        % disp(err);
        
        p_amp = P_noise_Desired / P_noise;
        v_amp = p_amp ^ 0.5;
        
        noise = noise * v_amp;
        
        %     p02 = getPower(noise);
        %     disp(p02 - P_noise_Desired);
        %     foo = 1;
        
        % Rayleigh Channel
        H = randn(N, M) + 1j*randn(N, M);
        % H_esti = H;
        
        r = H * tdi + noise;
        % foo = 1;
        
        % Opt 01: ZF
        G = pinv(H);
        y = G * r;  % y now is M-to-1 Column Vector
        
        % Hard Judge
        a_esti = zeros(M, 1);
        for ite_demap = 1:M
            temp = real(y(ite_demap));
            if temp >= 0
                a_esti(ite_demap) = 1;
            else
                a_esti(ite_demap) = -1;
            end
        end
        
        % Error Detect
        N_err = 0;
        for ite_err = 1:M
            if a_esti(ite_err) ~= tdi(ite_err)
                N_err = N_err + 1;
            else
                N_err = N_err + 0;
            end
        end
        ber_array(ite_repeat) = N_err / M;
    end
    % Average
    ber(ite_snr) = mean(ber_array); 
end

figure(1);
semilogy(snr_dB, ber, 'k-o');
axis([-10 ,10, 1e-6, 1e-0]);
grid on;
hold on;

%% Opt 02: Random SUC
% Different S/N Ratio
ber = zeros(1, N_snr);
for ite_snr = 1:N_snr
    snr_rate = snr(ite_snr);
    
    ber_array = zeros(1, N_repeat);
    parfor ite_repeat = 1:N_repeat
        % Generate Tx Symbol
        tdi = zeros(M, 1);
        for tx_ite=1:M
            tdi(tx_ite) = (round(rand) * 2) - 1;
        end
        % P_sig = rms(tdi)^2;
        P_sig = getPower(tdi);
        P_noise_Desired = P_sig / snr_rate;
        
        noise = randn(N, 1);
        P_noise = getPower(noise);
        % P_noise = rms(noise)^2;
        % err = P_noise - P_noise_1;
        % disp(err);
        
        p_amp = P_noise_Desired / P_noise;
        v_amp = p_amp ^ 0.5;
        
        noise = noise * v_amp;
        
        % p02 = getPower(noise);
        % disp(p02 - P_noise_Desired);
        % foo = 1;
        
        % Rayleigh Channel
        H = randn(N, M) + 1j*randn(N, M);
        H_esti = H;
        % figure(23);
        % h11 = H(1,1);
        % h12 = H(1,2);
        % scatter(real(h11), imag(h11), 'bx');
        % hold on;
        % scatter(real(h12), imag(h12), 'ro');
        % hold on;
        % axis([-4, 4, -4, 4]);
        % grid on;
        
        r = H * tdi + noise;
        % foo = 1;
        
        % Opt 02 Random SUC : Use the Demod Scheme from the MIMO-OFDM Demo Code
        ki_vec = zeros(1, M);
        a_esti = zeros(M, 1);
        % Algorithm Begin: Init
        G = pinv(H);
        row_norm = sum(abs(G).^2,2);
        % [~, ki] = min(row_norm);
        ki = 1;
        % Algorithm Process: Iterate
        for ite_demod = 1:M
            ki_vec(ite_demod) = ki; % Record ki in Sequence
            w = G(ki,:);
            y = w * r;
            a_esti(ki) = slice(y);
            r = r - a_esti(ki) * H_esti(:, ki); % Cancel
            H(:,ki) = zeros(N,1);
            G = pinv(H);
            for ite = 1:ite_demod
                G(ki_vec(ite),:) = inf; % Exclude this Row When Finding min Value
            end
            row_norm = sum(abs(G).^2,2);
            % [~, ki] = min(row_norm);
            ki = ki + 1;
        end
        
        % Error Detect
        N_err = 0;
        % Hard Judge
        for ite = 1:M
            if a_esti(ite) >= 0
                a_esti(ite) = 1;
            else
                a_esti(ite) = -1;
            end
        end
        % Get Error Count
        for ite_err = 1:M
            if a_esti(ite_err) ~= tdi(ite_err)
                N_err = N_err + 1;
            else
                N_err = N_err + 0;
            end
        end
        ber_array(ite_repeat) = N_err / M;
    end
    ber(ite_snr) = mean(ber_array);
    
end

figure(1);
semilogy(snr_dB, ber, 'b-o');
hold on;

%% Opt 03: O-SUC
% Different S/N Ratio
ber = zeros(1, N_snr);
for ite_snr = 1:N_snr
    snr_rate = snr(ite_snr);
    
    ber_array = zeros(1, N_repeat);
    parfor ite_repeat = 1:N_repeat
        % Generate Tx Symbol
        tdi = zeros(M, 1);
        for tx_ite=1:M
            tdi(tx_ite) = (round(rand) * 2) - 1;
        end
        % P_sig = rms(tdi)^2;
        P_sig = getPower(tdi);
        P_noise_Desired = P_sig / snr_rate;
        
        noise = randn(N, 1);
        P_noise = getPower(noise);
        % P_noise = rms(noise)^2;
        % err = P_noise - P_noise_1;
        % disp(err);
        
        p_amp = P_noise_Desired / P_noise;
        v_amp = p_amp ^ 0.5;
        
        noise = noise * v_amp;
        
        % p02 = getPower(noise);
        % disp(p02 - P_noise_Desired);
        % foo = 1;
        
        % Rayleigh Channel
        H = randn(N, M) + 1j*randn(N, M);
        H_esti = H;
        % figure(23);
        % h11 = H(1,1);
        % h12 = H(1,2);
        % scatter(real(h11), imag(h11), 'bx');
        % hold on;
        % scatter(real(h12), imag(h12), 'ro');
        % hold on;
        % axis([-4, 4, -4, 4]);
        % grid on;
        
        r = H * tdi + noise;
        % foo = 1;
        
%         % Opt 02: O-SUC  (Obsolete)
%         a_esti = zeros(M, 1);
%         for ite_k = 0:M-1
%             G = pinv(H); % G is (M-itek)-to-N Matrix
%             % y_ki = G * r;  % y now is M-to-1 Column Vector
%             
%             % Estimate SNR
%             snr_esti = zeros(M-ite_k, 1);
%             for ite_snr_esti = 1:M-ite_k
%                 % 1. Use the getSNR() Function
%                 % snr_esti(ite_snr_esti) = getSNR(tdi(ite_snr_esti), y(ite_snr_esti)-tdi(ite_snr_esti));
%                 % 2. Get the norm of row in G Matrix
%                 temp = G(ite_snr_esti, :);
%                 temp = norm(temp)^2;  % 2-Norm
%                 snr_esti(ite_snr_esti) = temp;
%             end
%             snr_esti = 1 ./ snr_esti;  % to Estimate SNR, norm is at Denominator
%             % disp(snr_esti);
%             % disp(10*log10(snr_esti));
%             % foo = 1;
%             
%             % Get the Current Optimal Index
%             % 1. Use the getSNR() Function
%             %[~, ki] = max(snr_esti);
%             % 2. Get the norm of row in G Matrix
%             [~, ki] = max(snr_esti);  % Get Optimal ki
%             y_ki = G(ki,:) * r;  % y now is M-to-1 Column Vector
%             temp = real(y_ki);
%             % Hard Judge
%             if temp >= 0
%                 a_esti(ki) = 1;
%             else
%                 a_esti(ki) = -1;
%             end
%             h_emulate = H_esti(:,ki);
%             r = r - a_esti(ki) * h_emulate;
%             H = cut_col(H, ki);
%             % foo = 1;
%         end
        
        % Opt 02x: Use the Demod Scheme from the MIMO-OFDM Demo Code
        ki_vec = zeros(1, M);
        a_esti = zeros(M, 1);
        % Algorithm Begin: Init
        G = pinv(H);
        row_norm = sum(abs(G).^2,2);
        [~, ki] = min(row_norm);
        % Algorithm Process: Iterate
        for ite_demod = 1:M
            ki_vec(ite_demod) = ki; % Record ki in Sequence
            w = G(ki,:);
            y = w * r;
            a_esti(ki) = slice(y);
            r = r - a_esti(ki) * H_esti(:, ki); % Cancel
            H(:,ki) = zeros(N,1);
            G = pinv(H);
            for ite = 1:ite_demod
                G(ki_vec(ite),:) = inf; % Exclude this Row When Finding min Value
            end
            row_norm = sum(abs(G).^2,2);
            [~, ki] = min(row_norm);
        end
        
        % Error Detect
        N_err = 0;
        % Hard Judge
        for ite = 1:M
            if a_esti(ite) >= 0
                a_esti(ite) = 1;
            else
                a_esti(ite) = -1;
            end
        end
        % Get Error Count
        for ite_err = 1:M
            if a_esti(ite_err) ~= tdi(ite_err)
                N_err = N_err + 1;
            else
                N_err = N_err + 0;
            end
        end
        ber_array(ite_repeat) = N_err / M;
    end
    ber(ite_snr) = mean(ber_array);
    
end

figure(1);
semilogy(snr_dB, ber, 'r-x');
hold on;
vb_ber = ber;
vb_snr_dB = snr_dB;
save('mimoofdm_vblast.mat', 'vb_ber', 'vb_snr_dB');

%% plot Noatation
title('BER vs SNR');
xlabel('SNR(dB)');
ylabel('BER');
legend('ZF Only', 'ZF:Random SIC', 'ZF:O-SIC');

toc;


