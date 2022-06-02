% Generate Random Data
data = round( rand( 1, Ni ) );
% Encode
codeword = ConvEncode( data, code_param.gen, code_param.nsc_flag );
% BICM interleave
bicm_interleaver = randperm( Nc )-1;
codeword_intl = Interleave( codeword, bicm_interleaver );

% Multiplex with pilots
x = zeros(K,1);
% Generate subcarrier gains
%H = generateSubcarrierGains(Gains, Delays, Df, K);
index=randperm(L);
index=sort(index(1:Sparse));
[H Phi alpha GamaInv]=ChannelGenerator4(K,L,Sparse,index,Df,Dt);
% Signal at channel output
ChannelOutput = H .* x;
% Add Gaussian noise to obtain the received signal
y = ChannelOutput ;
y=zeros(length(y),1);

SendStruct=struct('data',data,'codeword',codeword,'bicm_interleaver',bicm_interleaver,'x',x);
RecvStruct=struct('y',y);
ChnlStruct=struct('H',H,'Phi',Phi,'alpha',alpha,'Threshod',Threshod);

DecodeStruct=struct('M_d',M_d,'M_p',M_p,'dataSubcIndx',dataSubcIndx, 'pilotSubcIndx', pilotSubcIndx);
DecodeStruct.Ni=Ni;
DecodeStruct.Nc=Nc;
DecodeStruct.SNRdB=snrp;
DecodeStruct.code_param=code_param;

SysSturct.N=N;
SysSturct.M=M;

clear data codeword bicm_interleaver codedbits modSymbols x H Phi alpha GamaInv ChannelOutput awgn y 