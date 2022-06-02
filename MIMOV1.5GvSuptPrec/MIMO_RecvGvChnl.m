function [errors]=MIMO_RecvGvChnl(Phi,SendCell, RecvCell, ChnlCell, DecodeStruct, SysSturct, N_it, MeasureMSE)
% Author: Mihai Badiu,YUAN
%function:OFDM联合信道估计加检测GAMP_MF_GivenPrior_EstLemmdaV2.4
%author: yuan
%time: 2016.4.15PM
% Reading System parameters
dataSubcIndx=DecodeStruct.dataSubcIndx;
pilotSubcIndx_total=DecodeStruct.pilotSubcIndx;
%由于导频“避让”，使得导频subset并上数据subset，会出现空余位置。则用此subsetIndex代表此刻的n域内所有导频和数据的并集
%重新定义为“子集”
subsetIndx=union(dataSubcIndx,pilotSubcIndx_total(1,:));
Ni=DecodeStruct.Ni;
Nc=DecodeStruct.Nc;
M_d=DecodeStruct.M_d;
SNRdB=DecodeStruct.SNRdB;
K=length(RecvCell{1}.y);
%n域内导频和数据并集的维度
Ksubset=length(subsetIndx);
N=SysSturct.N;
M=SysSturct.M;
code_param=DecodeStruct.code_param;     %编码相关参数
% init setting
[meaning coordinateset] = Modulation(M_d);
xPower = mean(abs(coordinateset).^2); % constellation power
Niter=5;%迭代前信道估计次数
Nd = length(dataSubcIndx); % number of data symbols
Ncp = M_d*Nd; % number of coded bits + padding bits
MSE=zeros(N,N_it);
%init vectors
errors = zeros(N,N_it);
MSE = zeros(1,N_it);
% initialize extrinsic info for the uncoded bits
apriori_uncoded_llrs = zeros(1,Ni);
% initialize EXT values for soft coded bits;
soft_cod_bits_dec = [log(0.5.*ones(Nc,2)); log(repmat([1 0],Ncp-Nc,1))];
% the noise precision
Lmd = 10^(0.1*SNRdB)/xPower; % the average noise precision value
ChnlEstCell=cell(M,N);
% init the x-fy 之间网络 struct and cell
msg_x2fy_m=zeros(Nd,1);  %x到fy消息
msg_x2fy_v=ones(Nd,1);
msg_fy2x_m=zeros(Nd,1); %fy-x消息
msg_fy2x_v=inf(Nd,1);
func_fy_m=zeros(Nd,1);   %fy函数
func_fy_v=inf(Nd,1);
XnFymStruct=struct('msg_x2fy_m',msg_x2fy_m,'msg_x2fy_v',msg_x2fy_v,'msg_fy2x_m',msg_fy2x_m,'msg_fy2x_v',msg_fy2x_v,'func_fy_m',func_fy_m,'func_fy_v',func_fy_v);
XnFymCell=cell(M,N);
for m=1:M
    for n=1:N
        XnFymCell{m,n}=XnFymStruct;
    end
end
% init the data decoding struct and cell
msg_x2M_m=zeros(Nd,1);
msg_x2M_v=zeros(Nd,1);
blf_x_m=zeros(Nd,1);
blf_x_v=inf(Nd,1);
XnCell=cell(1,N);
XnStruct=struct('msg_x2M_m',msg_x2M_m,'msg_x2M_v',msg_x2M_v,'blf_x_m',blf_x_m,'blf_x_v',blf_x_v);
for n=1:N
    XnCell{n}=XnStruct;
end
it = 1;
% %% %%%%%%%%%%%%%%%%%%%%%%Pilot Iterations%%%%%%%%%%%%%%%%%%%%%
% for m=1:M
%     for n=1:N
%         pilotSubcIndx=pilotSubcIndx_total(n,:);
%         subsetIndx=union(dataSubcIndx,pilotSubcIndx);   %子集
%         alpha=ChnlCell{m,n}.alpha;
%         GamaInv=ChnlCell{m,n}.GamaInv;
%         x=SendCell{n}.x;
%         y=RecvCell{m}.y;
%         [BayesianGAMP_pilot]=ChannelEst_GAMP(Phi(pilotSubcIndx,:),y(pilotSubcIndx),x(pilotSubcIndx),Lmd, Niter,alpha,GamaInv);  %pilot channel estimation
%         [BayesianGAMP_joint]=ModifySizeGAMP(Phi,BayesianGAMP_pilot,y,x,Lmd,pilotSubcIndx,dataSubcIndx);  %trans the pilot part to data part
%         ChnlEstCell{m,n}=BayesianGAMP_joint;
%         msg_p_m=ChnlEstCell{m,n}.msg_p_m;
%         msg_p_v=ChnlEstCell{m,n}.msg_p_v;
%         blf_h_m=ChnlEstCell{m,n}.blf_h_m(dataSubcIndx);
%         H=ChnlCell{m,n}.H;
%         MSE(n,1) = mean(abs(blf_h_m-H(dataSubcIndx)).^2); %观察信道估计MSE
%     end
% end

%% %%%%%%%%%%%%%%%%%%%%%%% 计算fy-x消息 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sum_blf_h_m=zeros(length((dataSubcIndx)),M);
for m=1:M
    for n=1:N
        blf_x_m=XnCell{n}.blf_x_m;
        blf_h_m=ChnlCell{m,n}.H(dataSubcIndx);  %代换为已知信道
        sum_blf_h_m(:,m)=sum_blf_h_m(:,m)+blf_h_m.*blf_x_m;
    end
end
for m=1:M
    y=RecvCell{m}.y(dataSubcIndx);
    for n=1:N
        blf_h_m=ChnlCell{m,n}.H(dataSubcIndx);
        blf_h_v=zeros(length(dataSubcIndx),1);
        blf_x_m=XnCell{n}.blf_x_m;
        
        msg_fy2x_m= conj(blf_h_m).*(y-sum_blf_h_m(:,m)+blf_h_m.*blf_x_m)./(abs(blf_h_m).^2+blf_h_v);
        msg_fy2x_v=1./(Lmd*(abs(blf_h_m).^2+blf_h_v));
        
        XnFymCell{m,n}.msg_fy2x_v=msg_fy2x_v;
        XnFymCell{m,n}.msg_fy2x_m=msg_fy2x_m;
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%由高斯的fy-x消息，计算x-M消息%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n=1:N
    msg_x2M_m=zeros(Nd,1);      %初始化参数为零
    msg_x2M_v=zeros(Nd,1);
    for m=1:M
        msg_x2M_v=msg_x2M_v+1./XnFymCell{m,n}.msg_fy2x_v; %累加其倒数
        msg_x2M_m=msg_x2M_m+XnFymCell{m,n}.msg_fy2x_m./XnFymCell{m,n}.msg_fy2x_v; %累加均值除方差
    end
    msg_x2M_v=1./msg_x2M_v;                           %(56.v)，累加完成后，倒数
    msg_x2M_m=msg_x2M_v.*msg_x2M_m;                   %(56.m)，累加完成后乘方差
    XnCell{n}.msg_x2M_v=msg_x2M_v;
    XnCell{n}.msg_x2M_m=msg_x2M_m;
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%(解码)%%%%%%%%%%%%%%%%%%%%%%%%
for n=1:N
    bicm_interleaver=SendCell{n}.bicm_interleaver;  %读取针对此n的interleaver
    % BP demapping
    soft_cod_bits_dem = BP_demapper(XnCell{n}.msg_x2M_m, XnCell{n}.msg_x2M_v, soft_cod_bits_dec,M_d);
    % convert soft bits to LLRs
    extrinsic_DEM_llrs = logP_to_LLR( soft_cod_bits_dem );
    % deinterleave (BICM)
    apriori_coded_llrs = Deinterleave( extrinsic_DEM_llrs(1:Nc)', bicm_interleaver);
    % Decode
    [aposteriori_uncoded_llrs, aposteriori_coded_llrs] = SisoDecode( apriori_uncoded_llrs, apriori_coded_llrs, code_param.gen, code_param.nsc_flag, code_param.decoder_type );
    decoded_data = (sign(aposteriori_uncoded_llrs)+1)/2;
    % Calculate extrinsic information
    extrinsic_coded_llrs = aposteriori_coded_llrs - apriori_coded_llrs;
    % count bit errors
    data=SendCell{n}.data;
    errorPos = abs(decoded_data - data);
    errors(n,it) = floor(sum(errorPos));
    % 写进对应cell
    XnCell{n}.extrinsic_coded_llrs=extrinsic_coded_llrs;
    XnCell{n}.soft_cod_bits_dec=soft_cod_bits_dec;
    XnCell{n}.errors=errors;
end
%% %%%% SUBSEQUENT ITERATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
it = it + 1;
while it <= N_it && ( errors(it-1) || MeasureMSE )
    %while it <= N_it && ( errors(it-1) )
    for n=1:N
        % interleave (BICM)
        extrinsic_coded_llrs=XnCell{n}.extrinsic_coded_llrs;
        bicm_interleaver=SendCell{n}.bicm_interleaver;  %读取针对此n的interleaver
        apriori_DEM_llrs(1:Nc) = Interleave( extrinsic_coded_llrs, bicm_interleaver );
        % convert from LLR to logP
        soft_cod_bits_dec(1:Nc,:) = LLR_to_logP(apriori_DEM_llrs(1:Nc));
        %%%%%%%%%%%%%%%%%%% (60,61)%%%%%%%%%%%%%%%%%%%%%%%%%
        msg_x2M_v=XnCell{n}.msg_x2M_v;
        msg_x2M_m=XnCell{n}.msg_x2M_m;
        [blf_x_m blf_x_v] = MFBP_Mapper(soft_cod_bits_dec,msg_x2M_m,msg_x2M_v,meaning, coordinateset);
        XnCell{n}.blf_x_m=blf_x_m;
        XnCell{n}.blf_x_v=blf_x_v;
        XnCell{n}.soft_cod_bits_dec=soft_cod_bits_dec;
    end
   
    %% %%%%%%%%%%%%%%%%%%%%%%% 计算fy-x消息 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sum_blf_h_m=zeros(length((dataSubcIndx)),M);
    for m=1:M
        for n=1:N
            blf_x_m=XnCell{n}.blf_x_m;
            blf_h_m=ChnlCell{m,n}.H(dataSubcIndx);
            sum_blf_h_m(:,m)=sum_blf_h_m(:,m)+blf_h_m.*blf_x_m;
        end
    end
    for m=1:M
        y=RecvCell{m}.y(dataSubcIndx);
        for n=1:N
            blf_h_m=ChnlCell{m,n}.H(dataSubcIndx);
            blf_h_v=zeros(length(dataSubcIndx),1);
            blf_x_m=XnCell{n}.blf_x_m;
            
            msg_fy2x_m= conj(blf_h_m).*(y-sum_blf_h_m(:,m)+blf_h_m.*blf_x_m)./(abs(blf_h_m).^2+blf_h_v);
            msg_fy2x_v=1./(Lmd*(abs(blf_h_m).^2+blf_h_v));
            
            XnFymCell{m,n}.msg_fy2x_v=msg_fy2x_v;
            XnFymCell{m,n}.msg_fy2x_m=msg_fy2x_m;
        end
    end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%由高斯的fy-x消息，计算x-M消息%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for n=1:N
        msg_x2M_m=zeros(Nd,1);      %初始化参数为零
        msg_x2M_v=zeros(Nd,1);
        for m=1:M
            msg_x2M_v=msg_x2M_v+1./XnFymCell{m,n}.msg_fy2x_v; %累加其倒数
            msg_x2M_m=msg_x2M_m+XnFymCell{m,n}.msg_fy2x_m./XnFymCell{m,n}.msg_fy2x_v; %累加均值除方差
        end
        msg_x2M_v=1./msg_x2M_v;                           %(56.v)，累加完成后，倒数
        msg_x2M_m=msg_x2M_v.*msg_x2M_m;                   %(56.m)，累加完成后乘方差
        XnCell{n}.msg_x2M_v=msg_x2M_v;
        XnCell{n}.msg_x2M_m=msg_x2M_m;
    end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%解码%%%%%%%%%%%%%%%%%%%%%%%%
    for n=1:N
        bicm_interleaver=SendCell{n}.bicm_interleaver;  %读取针对此n的interleaver
        soft_cod_bits_dec=XnCell{n}.soft_cod_bits_dec;
        % BP demapping
        soft_cod_bits_dem = BP_demapper(XnCell{n}.msg_x2M_m, XnCell{n}.msg_x2M_v, soft_cod_bits_dec,M_d);
        % convert soft bits to LLRs
        extrinsic_DEM_llrs = logP_to_LLR( soft_cod_bits_dem );
        % deinterleave (BICM)
        apriori_coded_llrs = Deinterleave( extrinsic_DEM_llrs(1:Nc)', bicm_interleaver);
        % Decode
        [aposteriori_uncoded_llrs, aposteriori_coded_llrs] = SisoDecode( apriori_uncoded_llrs, apriori_coded_llrs, code_param.gen, code_param.nsc_flag, code_param.decoder_type );
        decoded_data = (sign(aposteriori_uncoded_llrs)+1)/2;
        % Calculate extrinsic information
        extrinsic_coded_llrs = aposteriori_coded_llrs - apriori_coded_llrs;
        % count bit errors
        data=SendCell{n}.data;
        errorPos = abs(decoded_data - data);
        errors(n,it) = floor(sum(errorPos));
        % 写进对应cell
        XnCell{n}.extrinsic_coded_llrs=extrinsic_coded_llrs;
        XnCell{n}.errors=errors;
    end
    it = it + 1;
end
end
