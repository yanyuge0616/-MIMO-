
clc; clear; close all;
%%
M = 2;
N = 1;

snr_dB = (-10: 1: 15);
snr = 10.^(snr_dB / 10);
N_snr = length(snr);

N_repeat = 1e+7;

do_Opt_01 = 1;
if do_Opt_01 == 1

%% Opt 01: 2Tx - 1Rx
ber = zeros(1, N_snr); % 1x snr -> 1x ber
for ite_snr = 1:N_snr
    snr_rate = snr(ite_snr);
    
    ber_array = zeros(1, N_repeat);
    for ite_repeat = 1:N_repeat  % 1x snr -> 1x ber_array
        % Generate Tx Symbol
        tdi = zeros(M, 1);
        for tx_ite=1:M
            tdi(tx_ite) = (round(rand) * 2) - 1;
        end
        
        % 2 Tx STBC
        tdi_stbc(1,1) = tdi(1);
        tdi_stbc(2,1) = tdi(2);
        tdi_stbc(1,2) = (-1) * conj(tdi(2));
        tdi_stbc(2,2) = conj(tdi(1));
        
        % STBC Matrix ???
        
        % Get Noise @ Desired SNR
        % P_sig = rms(tdi)^2;
        P_sig = getPower(tdi);
        P_noise_Desired = P_sig / snr_rate;
        
        noise_t1 = randn(1, 1) + 1j*randn(1, 1);
        noise_t2 = randn(1, 1) + 1j*randn(1, 1);
        noise = [noise_t1, noise_t2];
        
        P_noise = getPower(noise);
        % P_noise = rms(noise)^2;
        % err = P_noise - P_noise_1;
        % disp(err);
        
        p_amp = P_noise_Desired / P_noise;
        v_amp = p_amp ^ 0.5;
        
        noise = noise * v_amp;
        
        % Rayleigh Channel
        H = randn(N, M) + 1j*randn(N, M);
        
        % Receiver Side
        r = H * tdi_stbc + noise;
        foo = 1;
        
        % STBC Decode: Use Channel Estimation Result
        % Re-Shape to be Column Vector
        y = [r(1) ; conj(r(2))];
        
        H_det = [conj(H(1,1)), H(1,2); ...
                conj(H(1,2)), -H(1,1) ...
                ];
        r_proc = H_det * y;
        % foo = 1;
        
        r_proc = real(r_proc);
        
        a = zeros(1, M);
        % demap
        for ite = 1:M
            if r_proc(ite) >=0 
                a(ite) = 1;
            else
                a(ite) = -1;
            end
        end
        
        % BER Estimation
        N_err = 0;
        for ite = 1:M
            if a(ite) == tdi(ite)
                N_err = N_err + 0;
            else
                N_err = N_err + 1;
            end
        end
        ber_array(ite_repeat) = N_err / M;
    end
    % Average
    ber(ite_snr) = mean(ber_array);
end

figure(1);
semilogy(snr_dB, ber, 'k-o');
axis([snr_dB(1) ,snr_dB(end), 1e-6, 1e-0]);
grid on;
hold on;

end

%% Opt 02: 2Tx - 2Rx
M = 2;
N = 2;

%% Loop Operation
ber = zeros(1, N_snr); % 1x snr -> 1x ber
for ite_snr = 1:N_snr
    snr_rate = snr(ite_snr);
    
    ber_array = zeros(1, N_repeat);
    for ite_repeat = 1:N_repeat  % 1x snr -> 1x ber_array
        % Generate Tx Symbol
        tdi = getBPSK(M, 1);
        
        % 2x2 Tx Data STBC: Use this Matrix by its Each Column
        x_t1 = [tdi(1), tdi(2)];
        x_t1 = x_t1';
        x_t2 = [(-1)*conj(tdi(2)), conj(tdi(1))];
        x_t2 = x_t2';
        
        % Get Noise @ Desired SNR
        % P_sig = rms(tdi)^2;
        P_sig = getPower(tdi);
        P_noise_Desired = P_sig / snr_rate;
        
        % Noise #1
        noise_r1 = randn(1, 1) + 1j*randn(1, 1);
        noise_r2 = randn(1, 1) + 1j*randn(1, 1);
        noise_t1 = [noise_r1, noise_r2];
        noise_t1 = noise_t1';
        
        P_noise = getPower(noise_t1);
        % P_noise = rms(noise)^2;
        % err = P_noise - P_noise_1;
        % disp(err);
        
        p_amp = P_noise_Desired / P_noise;
        v_amp = p_amp ^ 0.5;
        
        noise_t1 = noise_t1 * v_amp;
        
        % Noise #2
        noise_r1 = randn(1, 1) + 1j*randn(1, 1);
        noise_r2 = randn(1, 1) + 1j*randn(1, 1);
        noise_t2 = [noise_r1, noise_r2];
        noise_t2 = noise_t2';
        
        P_noise = getPower(noise_t2);
        % P_noise = rms(noise)^2;
        % err = P_noise - P_noise_1;
        % disp(err);
        
        p_amp = P_noise_Desired / P_noise;
        v_amp = p_amp ^ 0.5;
        
        noise_t2 = noise_t2 * v_amp;
        
        % Rayleigh Channel
        H = randn(N, M) + 1j*randn(N, M);
        
        % Receive Side
        h11 = H(1, 1);
        h12 = H(1, 2);
        h21 = H(2, 1);
        h22 = H(2, 2);
        
        % Receiver Side
        r_t1 = H * x_t1 + noise_t1;
        r_t2 = H * x_t2 + noise_t2;        
        
        % Process
        r1 = conj(h11)*r_t1(1) + h12*conj(r_t2(1)) + conj(h21)*r_t1(2) + h22*conj(r_t2(2));
        r2 = conj(h12)*r_t1(1) - h11*conj(r_t2(1)) + conj(h22)*r_t1(2) - h21*conj(r_t2(2));
        
        r1 = (-1)*real(r1);
        r2 = (-1)*real(r2);
        
        if r1 > 0
            a(1) = 1;
        else
            a(1) = -1;
        end
        
        if r2 > 0 
            a(2) = 1;
        else
            a(2) = -1;
        end
        
        N_err = 0;
        if a(1) == tdi(1)
            N_err = N_err + 1;
        else
            N_err = N_err + 0;
        end
        
        if a(2) == tdi(2)
            N_err = N_err + 1;
        else
            N_err = N_err + 0;
        end
        
        ber_array(ite_repeat) = N_err / M;
% % %         % foo = 1;
% % %         
% % %         % STBC Decode
% % %         h11 = H(1,1);
% % %         h12 = H(1,2);
% % %         h21 = H(2,1);
% % %         h22 = H(2,2);
% % %         
% % %         Gain = abs(H).^2;
% % %         Gain = sum(Gain, 1);
% % %         Gain = sum(Gain, 2);
% % %         foo = 1;
% % %         
% % %         r_reform = [r_t1(1), conj(r_t2(1)), r_t1(2), conj(r_t2(2))];
% % %         r_reform = r_reform';
% % %         
% % %         H_det1 = [conj(h11), h12,       conj(h21), h22];
% % %         H_det2 = [conj(h12), (-1)*h11,  conj(h22), (-1)*h21];
% % %         
% % %         r1 = H_det1 * r_reform;
% % %         r2 = H_det2 * r_reform;
% % %         
% % %         r = [r1, r2];
% % %         
% % %         % Hard Judge Reshape
% % %         r = real(r); % Judge By Real Part
% % %         a = zeros(1, M);
% % %         for ite = 1:M
% % %             if r(ite) >= 0
% % %                 a(ite) = 1;
% % %             else
% % %                 a(ite) = -1;
% % %             end
% % %         end
% % %         
% % %         % Error Detection
% % %         N_err = 0;
% % %         for ite = 1:M
% % %             if a(ite) == tdi(ite)
% % %                 N_err = N_err + 0;
% % %             else
% % %                 N_err = N_err + 1;
% % %             end
% % %         end
% % %         ber_array(ite_repeat) = N_err / M;
    end
    % Average
    ber(ite_snr) = mean(ber_array);
end

figure(1);
semilogy(snr_dB, ber, 'r-x');
hold on;

%% plot Noatation
title('BER vs SNR');
xlabel('SNR(dB)');
ylabel('BER');
legend('2Tx 1Rx', '2Tx 2Rx');

%% Opt 03: 4Tx -> 4Rx
M = 4;
N = 4;

%% Loop Operation
ber = zeros(1, N_snr); % 1x snr -> 1x ber
for ite_snr = 1:N_snr
    snr_rate = snr(ite_snr);
    
    ber_array = zeros(1, N_repeat);
    for ite_repeat = 1:N_repeat  % 1x snr -> 1x ber_array
        % Generate Tx Symbol
        tdi = getBPSK(M, 1);
        
        % 4x4 Tx Data STBC: Use this Matrix by its Each Column
        x_t1 = [tdi(1), tdi(2), tdi(3), tdi(4)];
        x_t1 = x_t1.'; % Form a Column Vector @ t1
        x_t2 = [(-1)*tdi(2), tdi(1), (-1)*tdi(4), tdi(3)];
        x_t2 = x_t2.'; % Form a Column Vector @ t2
        x_t3 = [(-1)*tdi(3), tdi(4), tdi(1), (-1)*tdi(2)];
        x_t3 = x_t3.'; % Form a Column Vector @ t3
        x_t4 = [(-1)*tdi(4), (-1)*tdi(3), tdi(2), tdi(1)];
        x_t4 = x_t4.'; % Form a Column Vector @ t4
        
        % Get Noise @ Desired SNR
        n_t1 = getNoise(tdi(x_t1), snr_rate, 'DontFollow', N, 1);
        n_t2 = getNoise(tdi(x_t2), snr_rate, 'DontFollow', N, 1);
        n_t3 = getNoise(tdi(x_t3), snr_rate, 'DontFollow', N, 1);
        n_t4 = getNoise(tdi(x_t4), snr_rate, 'DontFollow', N, 1);
        
        % Rayleigh Channel
        H = randn(N, M) + 1j*randn(N, M);
        
        % Receive Side
        h11 = H(1, 1);
        h12 = H(1, 2);
        h13 = H(1, 3);
        h14 = H(1, 4);
        
        h21 = H(2, 1);
        h22 = H(2, 2);
        h23 = H(2, 3);
        h24 = H(2, 4);
        
        h31 = H(3, 1);
        h32 = H(3, 2);
        h33 = H(3, 3);
        h34 = H(3, 4);
        
        h41 = H(4, 1);
        h42 = H(4, 2);
        h43 = H(4, 3);
        h44 = H(4, 4);
        
        % Receiver Side
        r_t1 = H * x_t1 + noise_t1;
        r_t2 = H * x_t2 + noise_t2;        
        
        % Process
        r1 = conj(h11)*r_t1(1) + h12*conj(r_t2(1)) + conj(h21)*r_t1(2) + h22*conj(r_t2(2));
        r2 = conj(h12)*r_t1(1) - h11*conj(r_t2(1)) + conj(h22)*r_t1(2) - h21*conj(r_t2(2));
        
        r1 = (-1)*real(r1);
        r2 = (-1)*real(r2);
        
        if r1 > 0
            a(1) = 1;
        else
            a(1) = -1;
        end
        
        if r2 > 0 
            a(2) = 1;
        else
            a(2) = -1;
        end
        
        N_err = 0;
        if a(1) == tdi(1)
            N_err = N_err + 1;
        else
            N_err = N_err + 0;
        end
        
        if a(2) == tdi(2)
            N_err = N_err + 1;
        else
            N_err = N_err + 0;
        end
        
        ber_array(ite_repeat) = N_err / M;
    end
    % Average
    ber(ite_snr) = mean(ber_array);
end

