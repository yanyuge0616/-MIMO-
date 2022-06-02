function z = max_special(x,y)
%Author Mihai Badiu

z = -Inf;
if isfinite(x) || isfinite(y)
    m = max(x,y);
    z = m + log( 1 + exp( -(m-x) - (m-y) ) );
end

end