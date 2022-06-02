function [n] = getNoise(s, snr_ratio, isFollowTdi, size_r, size_c)
% get the Noise at the Desired SNR
% s is input Symbol, snr_ratio is NOT in dB Format
if 'follow' == isFollowTdi
    [N_row, N_col] = size(s);
else
    N_row = size_r;
    N_col = size_c;
end

% n = randn(N_row, N_col);  % Real Noise
n = randn(N_row, N_col) + 1j * randn(N_row, N_col);  % Complex Noise

P_sig = getPower(s);
P_noise = getPower(n);

P_desired_noise = P_sig / snr_ratio;
P_amp = P_desired_noise / P_noise;

v_amp = sqrt(P_amp);

n = n * v_amp;

end