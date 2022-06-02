function [tdi] = getBPSK(N_row, N_col)
% Generate Random BPSK Symbol, Value = +1, -1

% (Gaussian) N(0,1) Random Number
temp = randn(N_row, N_col);

for kr = 1:N_row
    for kc = 1:N_col
        if temp(kr, kc) >= 0 
            temp(kr, kc) = 1;
        else
            temp(kr, kc) = -1;
        end
    end
end

tdi = temp;  % Done

end

