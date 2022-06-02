function [meaning coordinateset]=Modulation(Mod)
%Author Gunvor Kirkelund
%
%[meaning coordinateset]=Modulation(Mod) dictates a modulation alpabet
%Mod is a variable indicating which modulation schemes is wanted, 1=BPSK,
%2=QPSK, 4=16QAM.
%the return is the coordinates for the alphabet "coordinateset"
%"meaning" is the corresponding binary sequence

meaning=[];
coordinateset=[];


if Mod==1
%BPSK
coordinateset=  [1,-1];
meaning=        [1, 0];
else if Mod==2
%QPSK
coordinateset=  [1/(sqrt(2))*j+1/(sqrt(2)),-1/(sqrt(2))*j-1/(sqrt(2)), 1/(sqrt(2))*j-1/(sqrt(2)),-1/(sqrt(2))*j+1/(sqrt(2))];
meaning=        [1, 0, 0, 1;...
                 1, 0, 1, 0];
    else if Mod==4
%16-QAM
a = 3/sqrt(10);
b = 1/sqrt(10);
coordinateset=  [-a+a*j,-b+a*j,b+a*j,a+a*j,-a+b*j,-b+b*j,b+b*j,a+b*j,-a-b*j,-b-b*j,b-b*j,a-b*j,-a-a*j,-b-a*j,b-a*j,a-a*j];
meaning=        [0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1;...
                 0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0;...
                 0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1;...
                 0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0];
        end
    end
end
