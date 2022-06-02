% Program 5-3
% mseq.m
%
% The generation function of M-sequence
%
% An example
%    stg     = 3
%    taps    = [ 1 , 3 ]
%    inidata = [ 1 , 1 , 1 ]
%    n       = 2
%
% Programmed by M.Okita and H.Harada
%

function [mout] = mseq(stg, taps, inidata, n)

% ****************************************************************
% stg     : Number of stages
% taps    : Position of register feedback
% inidata : Initial sequence
% n       : Number of output sequence(It can be omitted)
% mout    : output M sequence
% ****************************************************************

if nargin < 4
    n = 1;
end

mout = zeros(n,2^stg-1);
fpos = zeros(stg,1);

fpos(taps) = 1;

for ii=1:2^stg-1
    
    mout(1,ii) = inidata(stg);                      % storage of the output data
    num        = mod(inidata*fpos,2);               % calculation of the feedback data
    
    inidata(2:stg) = inidata(1:stg-1);              % one shifts the register
    inidata(1)     = num;                           % return feedback data
    
end

if n > 1
    for ii=2:n
        mout(ii,:) = shift(mout(ii-1,:),1,0);
    end
end

%******************************** end of file ********************************