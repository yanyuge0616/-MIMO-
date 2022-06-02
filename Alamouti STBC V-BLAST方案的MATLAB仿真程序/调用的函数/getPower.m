function p = getPower(x)
%This Power Estimation Actually is Square of rms Value
    N = length(x);
    
    temp = 0;
    for k=1:N
        temp = temp + abs(x(k))^2;
    end
    p = temp / N;
    % p = rms(x)^2;
    
end