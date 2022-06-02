%function: MIMO-OFDM 联合接收机
%author: yuan
%time: 2016.5.6PM
%版本说明：1.改为稀疏信道，抽头数L=50，稀疏度k=5。
%注释：稀疏贝叶斯信道估计，导频部分为串行，全局部分为并行。
%已知support将稀疏转为非稀疏，导频部分为串行，全局部分为串行。
%考察初始化迭代，设置条件阈值，提前终止迭代。
clear all;
clc;
%dbstop at 11;
fprintf('MIMO-OFDM receiver V1.5，Common Support Vs Given Support');
% get different random values each time the code is run (or Matlab is started)
mystream = RandStream('mt19937ar','Seed',sum(100*clock));
ver=version;
if strcmp({ver(length(ver)-7:length(ver))},'(R2010b)')
    RandStream.setDefaultStream(mystream);
else
    RandStream.setGlobalStream(mystream);
end
SystemParameters1; % load system parameters

for SparsePoint=1:length(SPARSE)
    Sparse=SPARSE(SparsePoint);
    for InitPoint=1:length(INIT)
        init=INIT(InitPoint);
        for point = 1:length(SNR)
            fprintf('\nCurrent SNR point: %.1f dB',SNR(point));
            snrp = SNR(point);
            NoisePower = 10^(-snrp/10);
            CreatStruct; %生成一个结构体模板，并且回收中间变量
            savefile = strcat('MIMO_K',int2str(K),'_S',int2str(N),'_R',int2str(M),'_SNR',int2str(snrp*10),...
                '_Pilots',int2str(Npilots),'_Taps',int2str(L),'_Sparse',int2str(Sparse),'_init',int2str(init),'_GvSuptPrec_V1.5.mat');
            if exist(savefile,'file')
                load(savefile);
            else
                TotalBitErrors_GvChnl = zeros(1,N_it); %已知信道，bound
                TotalBlckErrors_GvChnl=0;
                
                TotalBitErrors_MF = zeros(1,N_it); %导频估计：并行。全局估计：并行
                TotalMSE_MF = zeros(1,N_it);
                TotalBlckErrors_MF=0;
                
                TotalBitErrors_GvSupt = zeros(1,N_it); %自定义存储位置
                TotalMSE_GvSupt = zeros(1,N_it);
                TotalBlckErrors_GvSupt=0;
                countBlck = 0;
            end
            Frame=200;
            while ( countBlck < numberFrames(point) )
                LocalErrors_GvChnl=zeros(Frame,N_it);
                LocalBlckErrors_GvChnl=zeros(Frame,1);
                
                LocalErrors_MF=zeros(Frame,N_it);
                LocalMSE_MF=zeros(Frame,N_it);
                LocalBlckErrors_MF=zeros(Frame,1);
                
                LocalErrors_GvSupt=zeros(Frame,N_it);%自定义存储位置
                LocalMSE_GvSupt=zeros(Frame,N_it);
                LocalBlckErrors_GvSupt=zeros(Frame,1);
                parfor local=1:Frame
                    SendCell=cell(1,N);
                    RecvCell=cell(M,1);
                    ChnlCell=cell(M,N);
                    for n=1:N
                        for m=1:M
                            SendCell{n}=SendStruct;%初始化所有的cell
                            RecvCell{m}=RecvStruct;
                            ChnlCell{m,n}=ChnlStruct;
                        end
                    end
                    %% 生成数据
                    for n=1:N
                        % Generate Random Data
                        data= round( rand( 1, Ni ) );   %生成随机data
                        SendCell{n}.data =data; %随机data写入cell
                        % Encode
                        codeword = ConvEncode( data, code_param.gen, code_param.nsc_flag ); %卷积编码
                        % BICM interleave
                        bicm_interleaver = randperm( Nc )-1;
                        SendCell{n}.bicm_interleaver =bicm_interleaver;     %保存此cell的interleaver
                        codeword_intl = Interleave( codeword, bicm_interleaver);
                        codedbits = [codeword_intl zeros(1,Nbits-Nc)]; %coder
                        % Map to complex symbols
                        modSymbols = Mapper(M_d,codedbits,1); %mapper
                        % Multiplex with pilots
                        SendCell{n}.x(dataSubcIndx) = modSymbols;
                        SendCell{n}.x(pilotSubcIndx(n,:)) = constellPilots(randi(2^M_p,Npilots,1));
                    end
                    %% channel
                    for n=1:N
                        index=randperm(L);
                        index=sort(index(1:Sparse));    %common support,对于任意m，其support相同
                        for m=1:M
                            [H Phi alpha Support Prec]=ChannelGenerator4(K,L,Sparse,index,Df,Dt);
                            ChnlCell{m,n}.alpha=alpha;
                            ChnlCell{m,n}.H=H;
                            ChnlCell{m,n}.Phi=Phi;
                            ChnlCell{m,n}.Support=Support;
                            ChnlCell{m,n}.Prec=Prec;
                        end
                    end
                    %% output
                    awgn=sqrt(0.5*NoisePower)*(randn(K,1) + 1i*randn(K,1)); %每块数据单独产生awgn
                    for m=1:m
                        for n=1:n
                            % Signal at channel output
                            ChannelOutput = ChnlCell{m,n}.H .* SendCell{n}.x;
                            % Add Gaussian noise to obtain the received signal
                            y = ChannelOutput ;
                            RecvCell{m}.y=RecvCell{m}.y+y;
                        end
                        RecvCell{m}.y=RecvCell{m}.y+ awgn;
                    end
                    %% Receiver processing
                    %giver Perfect CSI
                    %[errors_GvChnl]=MIMO_RecvGvChnl(Phi,SendCell, RecvCell, ChnlCell, DecodeStruct, SysSturct, N_it, measureMSE);
                    %Common Support, Ser+Par,将所有m的平均抽头方差再做平均，只有整体小于阈值，才提前结束
                    %[errors_MF MSE_MF times]=MIMO_RecvComSupt(SendCell, RecvCell, ChnlCell, DecodeStruct, SysSturct,init, N_it, measureMSE,EstNoisePrec);%
                    %单个m和阈值比较，只要小于，则提前结束本m
                    [errors_GvSupt MSE_GvSupt]=MIMO_RecvGvSuptPar(SendCell, RecvCell, ChnlCell, DecodeStruct, SysSturct,init, N_it, measureMSE,EstNoisePrec,EstPrec);%
                    %Given Support, Ser+Ser
                    %% display and save
                    fprintf('\n MIMO-OFDM Receiver; Recv=%d, Send=%d, SNR=%5.2f, countBlck=%d, Sparse=%d, Given Support, Given Prec, V1.5 ',...
                        M,N,snrp,countBlck+local,Sparse);
                    if Testing==1
                        errors_MF=zeros(N,N_it);
                        MSE_MF=zeros(N,N_it);
                        errors_GvChnl=zeros(N,N_it);
                    else
                        %[LocalErrors_MF(local,:) LocalMSE_MF(local,:) LocalBlckErrors_MF(local)]=PrintResultSave('MF(whole)',N,errors_MF,MSE_MF,measureMSE);
                        [LocalErrors_GvSupt(local,:) LocalMSE_GvSupt(local,:) LocalBlckErrors_GvSupt(local)]=PrintResultSave('MF(GiverSupport)',N,errors_GvSupt,MSE_GvSupt,measureMSE);
                        %[LocalErrors_GvChnl(local,:),~, LocalBlckErrors_GvChnl(local)]=PrintResultSave('GvChnl',N,errors_GvChnl,zeros(N,N_it),measureMSE);
                    end
                end
                countBlck = countBlck + Frame;
                
                TotalBitErrors_GvChnl = TotalBitErrors_GvChnl+sum(LocalErrors_GvChnl);
                BER_GvChnl=TotalBitErrors_GvChnl/(countBlck*N*Ni);
                TotalBlckErrors_GvChnl=TotalBlckErrors_GvChnl+sum(LocalBlckErrors_GvChnl);
                
                TotalBitErrors_MF = TotalBitErrors_MF+sum(LocalErrors_MF);
                BER_MF=TotalBitErrors_MF/(countBlck*N*Ni);
                TotalMSE_MF = TotalMSE_MF+ sum(LocalMSE_MF);
                TotalBlckErrors_MF=TotalBlckErrors_MF+sum(LocalBlckErrors_MF);
                
                TotalBitErrors_GvSupt = TotalBitErrors_GvSupt+sum(LocalErrors_GvSupt);
                BER_GvSupt=TotalBitErrors_GvSupt/(countBlck*N*Ni);
                TotalMSE_GvSupt = TotalMSE_GvSupt+ sum(LocalMSE_GvSupt);
                TotalBlckErrors_GvSupt=TotalBlckErrors_GvSupt+sum(LocalBlckErrors_GvSupt);
                
                save(savefile, 'M','N','snrp','countBlck','Ni','K','L','Npilots','N_it',...
                    'TotalBitErrors_MF','TotalMSE_MF','TotalBlckErrors_MF','BER_MF',...
                    'TotalBitErrors_GvSupt','TotalMSE_GvSupt','TotalBlckErrors_GvSupt','BER_GvSupt',...
                    'TotalBitErrors_GvChnl','TotalBlckErrors_GvChnl','BER_GvChnl');
            end
        end
    end
end