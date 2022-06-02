%% MIMO parameters
M=4;
N=2;
%% OFDM parameters
Df = 15*1e3; % subcarrier spacing [Hz]
Dt=130*1e-9;
K = 512; % number of subcarriers
L=80;  %时域抽头个数
%Sparse=4;
Npilots=40; %pilot number

% 均匀产生pilot位置
gap=floor(K/Npilots);
pilotSubcIndx=zeros(N,Npilots);
for n=1:N
    indx=floor(gap/2)+n:gap:K;
    pilotSubcIndx(n,:)=indx(1:Npilots);
end 
temp=reshape(pilotSubcIndx,N*Npilots,1);
mask = ones(1,K);
mask(temp) = 0;
dataSubcIndx = find(mask);

%% 随机产生pilot位置
% remain=1:K;
% pilotSubcIndx=zeros(N,Npilots);
% select=randperm(length(remain));
% pilotSubcIndx_total=select(1:N*Npilots);
% for n=1:N
%     pilotSubcIndx(n,:)=sort(pilotSubcIndx_total((n-1)*Npilots+1 : n*Npilots));
% end
% dataSubcIndx=sort(select(N*Npilots+1:K));

%% 
M_d = 4; % number of bits/symbol for data subcarriers
[meaning coordinateset] = Modulation(M_d); % mapping and constellation points for data subcarriers
M_p = 4;% QPSK constellation for pilot subcarriers
[meaningPilots constellPilots] = Modulation(M_p);
Nsymbols = K - N*Npilots; % number of data symbols
Nbits = M_d*Nsymbols; % number of coded bits + padding bits
%% Channel Code
% Convolutional Code Parameters - it is not a tail-biting code, but has
% the LTE parameters generator polynomial
code_param.gen = [1 0 1 1 0 1 1; 1 1 1 1 0 0 1; 1 1 1 0 1 0 1]; %(133,171,165)
code_param.nsc_flag = 1;  % NSC
code_param.tail_pattern = [];
code_param.decoder_type = 4;
%     	  the decoder type:
% 			= 0 For linear approximation to log-MAP (DEFAULT)
% 			= 1 For max-log-MAP algorithm (i.e. max*(x,y) = max(x,y) )
% 			= 2 For Constant-log-MAP algorithm
% 			= 3 For log-MAP, correction factor from small nonuniform table and interpolation
% 			= 4 For log-MAP, correction factor uses C function calls (slow)
Ni = floor(Nbits/3) - 6;
Nc = (Ni+6)*3;

%% channel
Delays=0:L-1;             %一共L条径
Delays=Delays*Dt;   %每条径时延，每条径都有值
Gains =ones(L,1)/L; %每条径方差为1/2
%% Receiver
EstPrec=0;
measureMSE = 0;
EstNoisePrec = 1; % flag indicating whether the noise precision is estimated (1) or assumed to be known (0)
N_it =15; % # of receiver iterations
Testing=0;
Threshod=18e-4;
%% Simulation Settings
SNR =3:-0.5:0.5;% [dB]
INIT=[18];
numberFrames =[5e4,3e4,2e4,1e4,5e3,2e3];
SPARSE=[6];
