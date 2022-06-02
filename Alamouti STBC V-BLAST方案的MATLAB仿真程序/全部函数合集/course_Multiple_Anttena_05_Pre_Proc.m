
clc; clear; close all;
%% General Parameters
snr_dB = (-10: 1: 35);
snr = 10.^(snr_dB / 10);
N_snr = length(snr);

N_repeat = 1e+4;

%% Opt 01: 4x4 System
M = 4;
N = 4;
M_tx = min(M, N); % Tx Symbols to Send in the M Antenna, and Will be Received in the Rx Antenna

ber = zeros(1, N_snr); % 1x snr -> 1x ber
parfor ite_snr=1:N_snr
    snr_rate = snr(ite_snr); % Current SNR Value
    
    ber_array = zeros(1, N_repeat); % BER in Each Transmission
    for ite_repeat = 1:N_repeat
        % Generate Tx Symbol
        tdi = zeros(M_tx, 1);
        for tx_ite=1:M_tx
            tdi(tx_ite) = (round(rand) * 2) - 1;
        end
        % Generate Noise @ Desired SNR
        P_sig = getPower(tdi); % Signal Symbol
        
        noise = randn(N, 1); % Original Noise
        P_noise = getPower(noise);
        
        P_noise_Desired = P_sig / snr_rate;
        p_amp = P_noise_Desired / P_noise;
        v_amp = p_amp ^ 0.5;
        noise = noise * v_amp; % Proper Noise Generated
        
        % Tx Know the Channel
        H = randn(N, M) + 1j*randn(N, M);
        
        % Gain Factor
        Etr = 4;
        Rs = tdi * tdi';
        g_temp = H*(H')\Rs; % inv() * Rs; Hermitian
        g = (trace(g_temp) / Etr)^0.5;
        
        % Pre-Processing
        V = pinv(H);
        V = g \ V;
        x = V * tdi;
        
        % Receive
        y = H * x + noise;
        foo = 1;
        
        % Simple Process
        r = y;
        % Simple Decode
        a = zeros(M_tx, 1);
        for k=1:M_tx
            if r(k) >= 0
                a(k) = 1;
            else
                a(k) = -1;
            end
        end
        
        % Error Detect
        N_err = 0;
        for k=1:M_tx
            if a(k) == tdi(k)
                N_err = N_err + 0;
            else
                N_err = N_err + 1;
            end
        end
        ber_array(ite_repeat) = N_err / M_tx;
    end
    % Average
    ber(ite_snr) = mean(ber_array);
end

figure(1);
semilogy(snr_dB, ber, 'k-o');
axis([-10 ,35, 1e-5, 1e-0]);
grid on;
hold on;

pp_ber = ber;
pp_snr_dB = snr_dB;
save('mimoofdm_pre_proc.mat', 'pp_ber', 'pp_snr_dB');

%% Opt 02: 5x4 System
M = 5;
N = 4;
M_tx = min(M, N); % Tx Symbols to Send in the M Antenna, and Will be Received in the Rx Antenna

ber = zeros(1, N_snr); % 1x snr -> 1x ber
parfor ite_snr=1:N_snr
    snr_rate = snr(ite_snr); % Current SNR Value
    
    ber_array = zeros(1, N_repeat); % BER in Each Transmission
    for ite_repeat = 1:N_repeat
        % Generate Tx Symbol
        tdi = zeros(M_tx, 1);
        for tx_ite=1:M_tx
            tdi(tx_ite) = (round(rand) * 2) - 1;
        end
        % Generate Noise @ Desired SNR
        P_sig = getPower(tdi); % Signal Symbol
        
        noise = randn(N, 1); % Original Noise
        P_noise = getPower(noise);
        
        P_noise_Desired = P_sig / snr_rate;
        p_amp = P_noise_Desired / P_noise;
        v_amp = p_amp ^ 0.5;
        noise = noise * v_amp; % Proper Noise Generated
        
        % Tx Know the Channel
        H = randn(N, M) + 1j*randn(N, M);
        
        % Gain Factor
        Etr = 4;
        Rs = tdi * tdi';
        g_temp = H*(H')\Rs; % inv() * Rs
        g = (trace(g_temp) / Etr)^0.5;
        
        % Pre-Processing
        V = pinv(H);
        V = g \ V;
        x = V * tdi;
        
        % Receive
        y = H * x + noise;
        foo = 1;
        
        % Simple Process
        r = y;
        % Simple Decode
        a = zeros(M_tx, 1);
        for k=1:M_tx
            if r(k) >= 0
                a(k) = 1;
            else
                a(k) = -1;
            end
        end
        
        % Error Detect
        N_err = 0;
        for k=1:M_tx
            if a(k) == tdi(k)
                N_err = N_err + 0;
            else
                N_err = N_err + 1;
            end
        end
        ber_array(ite_repeat) = N_err / M_tx;
    end
    % Average
    ber(ite_snr) = mean(ber_array);
end

figure(1);
semilogy(snr_dB, ber, 'b-^');
axis([-10 ,35, 1e-5, 1e-0]);
grid on;
hold on;

pp_ber_02 = ber;
pp_snr_dB_02 = snr_dB;
save('mimoofdm_pre_proc.mat', 'pp_ber_02', 'pp_snr_dB_02');

%% Opt 03: 6x4 System
M = 6;
N = 4;
M_tx = min(M, N); % Tx Symbols to Send in the M Antenna, and Will be Received in the Rx Antenna

ber = zeros(1, N_snr); % 1x snr -> 1x ber
parfor ite_snr=1:N_snr
    snr_rate = snr(ite_snr); % Current SNR Value
    
    ber_array = zeros(1, N_repeat); % BER in Each Transmission
    for ite_repeat = 1:N_repeat
        % Generate Tx Symbol
        tdi = zeros(M_tx, 1);
        for tx_ite=1:M_tx
            tdi(tx_ite) = (round(rand) * 2) - 1;
        end
        % Generate Noise @ Desired SNR
        P_sig = getPower(tdi); % Signal Symbol
        
        noise = randn(N, 1); % Original Noise
        P_noise = getPower(noise);
        
        P_noise_Desired = P_sig / snr_rate;
        p_amp = P_noise_Desired / P_noise;
        v_amp = p_amp ^ 0.5;
        noise = noise * v_amp; % Proper Noise Generated
        
        % Tx Know the Channel
        H = randn(N, M) + 1j*randn(N, M);
        
        % Gain Factor
        Etr = 4;
        Rs = tdi * tdi';
        g_temp = H*(H')\Rs; % inv() * Rs
        g = (trace(g_temp) / Etr)^0.5;
        
        % Pre-Processing
        V = pinv(H);
        V = g \ V;
        x = V * tdi;
        
        % Receive
        y = H * x + noise;
        foo = 1;
        
        % Simple Process
        r = y;
        % Simple Decode
        a = zeros(M_tx, 1);
        for k=1:M_tx
            if r(k) >= 0
                a(k) = 1;
            else
                a(k) = -1;
            end
        end
        
        % Error Detect
        N_err = 0;
        for k=1:M_tx
            if a(k) == tdi(k)
                N_err = N_err + 0;
            else
                N_err = N_err + 1;
            end
        end
        ber_array(ite_repeat) = N_err / M_tx;
    end
    % Average
    ber(ite_snr) = mean(ber_array);
end

figure(1);
semilogy(snr_dB, ber, 'r-x');
axis([-10 ,35, 1e-5, 1e-0]);
% axis([-10 ,95, 1e-8, 1e-0]);
grid on;
hold on;

pp_ber_03 = ber;
pp_snr_dB_03 = snr_dB;
save('mimoofdm_pre_proc.mat', ...
    'pp_ber', 'pp_snr_dB', ...
    'pp_ber_02', 'pp_snr_dB_02', ...
    'pp_ber_03', 'pp_snr_dB_03');

%% Plot and Display
legend('4Tx, 4Rx', '5Tx, 4Rx', '6Tx, 4Rx');
title('Tx Pre-Proc: Known CSI');
xlabel('SNR(dB)');
ylabel('BER');





