function [errors MSE]=MIMO_RecvGvSuptPar(SendCell, RecvCell, ChnlCell, DecodeStruct, SysSturct, init, N_it, MeasureMSE,EstNoisePrec,EstPrec)
% Author: Mihai Badiu,YUAN
%function:MIMO-OFDM receiver��given support, transform the sparse channel
%estimation into un-sparse estimation.
%author: yuan
%time: 2016.5.6PM
% ע�ͣ���Ƶ�ŵ����Ʋ��ô���schedule��ȫ���ŵ����Ʋ��ô���schedule��
%
dataSubcIndx=DecodeStruct.dataSubcIndx;
pilotSubcIndxTotal=DecodeStruct.pilotSubcIndx;
%���ڵ�Ƶ�����á���ʹ�õ�Ƶsubset��������subset������ֿ���λ�á����ô�subsetIndex����˿̵�n�������е�Ƶ�����ݵĲ���
Ni=DecodeStruct.Ni;
Nc=DecodeStruct.Nc;
M_d=DecodeStruct.M_d;
SNRdB=DecodeStruct.SNRdB;
%n���ڵ�Ƶ�����ݲ�����ά��
N=SysSturct.N;
M=SysSturct.M;
code_param=DecodeStruct.code_param;     %������ز���
% init setting
[meaning coordinateset] = Modulation(M_d);
xPower = mean(abs(coordinateset).^2); % constellation power
Niter=init;%����ǰ�ŵ����ƴ���
Nd = length(dataSubcIndx); % number of data symbols
Ncp = M_d*Nd; % number of coded bits + padding bits
%init vectors
errors = zeros(N,N_it);
MSE = zeros(1,N_it);
% initialize extrinsic info for the uncoded bits
apriori_uncoded_llrs = zeros(1,Ni);
% initialize EXT values for soft coded bits;
soft_cod_bits_dec = [log(0.5.*ones(Nc,2)); log(repmat([1 0],Ncp-Nc,1))];
% the noise precision
Lmd = 10^(0.1*SNRdB)/xPower; % the average noise precision value
% init the x-fy ֮������ struct and cell
msg_x2fy_m=zeros(Nd,1);  %x��fy��Ϣ
msg_x2fy_v=ones(Nd,1);
msg_fy2x_m=zeros(Nd,1); %fy-x��Ϣ
msg_fy2x_v=inf(Nd,1);
XnFymStruct=struct('msg_x2fy_m',msg_x2fy_m,'msg_x2fy_v',msg_x2fy_v,'msg_fy2x_m',msg_fy2x_m,'msg_fy2x_v',msg_fy2x_v);
XnFymCell=cell(M,N); %xn��fy֮����Ϣ�ṹ�壬����MN��
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
%% %%%%%%%%%%%%%%%%%%%%%%Pilot Iterations%%%%%%%%%%%%%%%%%%%%%
%������Ƶ�ŵ�����(��֪support) ChnlEstPilot_GvSupt,serial schedule
[ChnlEstCell LmdEst]=ChnlEstPilot_GvSupt(SysSturct,SendCell,RecvCell,ChnlCell,DecodeStruct,Lmd,EstNoisePrec,EstPrec,Niter);
if EstNoisePrec
    Lmd=LmdEst;
end
for m=1:M
    for n=1:N
        pilotSubcIndx=pilotSubcIndxTotal(n,:);
        x=SendCell{n}.x;
        y=RecvCell{m}.y;
        %Phi=ChnlCell{m,n}.Phi;
        Support=ChnlCell{m,n}.Support;
        Phi=ChnlCell{m,n}.Phi(:,Support);      %ֻȡsupport���ֵ�phi      
        [ChnlEstCell{m,n}]=ModifySizeBP(Phi,ChnlEstCell{m,n},y,x,Lmd,pilotSubcIndx,dataSubcIndx);  %trans the pilot part to data part
    end
end
H=ChnlCell{1,1}.H;
MSE(1,it) = mean(abs(ChnlEstCell{1,1}.blf_h_m(dataSubcIndx)-H(dataSubcIndx)).^2); %�۲��ŵ�����MSE
%% %%%%%%%%%%%%%%%%%%%%%%% ����fy-x��Ϣ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sum_blf_h_m=zeros(length((dataSubcIndx)),M); %x��ֵ��h��ֵ�˻������
for m=1:M
    for n=1:N
        blf_x_m=XnCell{n}.blf_x_m;
        blf_h_m=ChnlEstCell{m,n}.blf_h_m(dataSubcIndx);
        sum_blf_h_m(:,m)=sum_blf_h_m(:,m)+blf_h_m.*blf_x_m;
    end
end
for m=1:M
    y=RecvCell{m}.y(dataSubcIndx);
    for n=1:N
        blf_h_m=ChnlEstCell{m,n}.blf_h_m(dataSubcIndx);
        blf_h_v=ChnlEstCell{m,n}.blf_h_v(dataSubcIndx);
        blf_x_m=XnCell{n}.blf_x_m;
            %�˴�Ϊsum(b(x)*b(h)),��ȥ��ʱn��b(x)*b(h)
        msg_fy2x_m= conj(blf_h_m).*(y-sum_blf_h_m(:,m)+blf_h_m.*blf_x_m)./(abs(blf_h_m).^2+blf_h_v);    
        msg_fy2x_v=1./(Lmd*(abs(blf_h_m).^2+blf_h_v));
        
        XnFymCell{m,n}.msg_fy2x_v=msg_fy2x_v;
        XnFymCell{m,n}.msg_fy2x_m=msg_fy2x_m;
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%�ɸ�˹��fy-x��Ϣ������x-M��Ϣ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n=1:N
    msg_x2M_m=zeros(Nd,1);      %��ʼ������Ϊ��
    msg_x2M_v=zeros(Nd,1);
    for m=1:M
        msg_x2M_v=msg_x2M_v+1./XnFymCell{m,n}.msg_fy2x_v; %�ۼ��䵹��
        msg_x2M_m=msg_x2M_m+XnFymCell{m,n}.msg_fy2x_m./XnFymCell{m,n}.msg_fy2x_v; %�ۼӾ�ֵ������
    end
    msg_x2M_v=1./msg_x2M_v;                           %(56.v)���ۼ���ɺ󣬵���
    msg_x2M_m=msg_x2M_v.*msg_x2M_m;                   %(56.m)���ۼ���ɺ�˷���
    XnCell{n}.msg_x2M_v=msg_x2M_v;
    XnCell{n}.msg_x2M_m=msg_x2M_m;
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%(����)%%%%%%%%%%%%%%%%%%%%%%%%
for n=1:N
    bicm_interleaver=SendCell{n}.bicm_interleaver;  %��ȡ��Դ�n��interleaver
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
    % д����Ӧcell
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
        bicm_interleaver=SendCell{n}.bicm_interleaver;  %��ȡ��Դ�n��interleaver
        apriori_DEM_llrs(1:Nc) = Interleave( extrinsic_coded_llrs, bicm_interleaver );
        % convert from LLR to logP��soft_cod_bits_dec��ʵ������M-x����ɢ��Ϣ����ͨ��
        soft_cod_bits_dec(1:Nc,:) = LLR_to_logP(apriori_DEM_llrs(1:Nc));
        %%%%%%%%%%%%%%%%%%% (60,61)%%%%%%%%%%%%%%%%%%%%%%%%%
        msg_x2M_v=XnCell{n}.msg_x2M_v;
        msg_x2M_m=XnCell{n}.msg_x2M_m;
        [blf_x_m blf_x_v] = MFBP_Mapper(soft_cod_bits_dec,msg_x2M_m,msg_x2M_v,meaning, coordinateset); %��M-x��ɢ��Ϣ���͸�˹��x-M��Ϣ���õ�b��x��
        XnCell{n}.blf_x_m=blf_x_m;
        XnCell{n}.blf_x_v=blf_x_v;
        XnCell{n}.soft_cod_bits_dec=soft_cod_bits_dec; %ʵ������M-x����ɢ��Ϣ����ͨ��
    end
    %% %%%��һ�Σ�������������õ�b��x���Ժ�%%%%
    if EstNoisePrec
        Lmd=LmdEstimation(SysSturct,DecodeStruct,RecvCell,SendCell,ChnlEstCell,XnCell); %����lembda,��δ��ɣ�
    end
    %% %%%%%%%%%%%%%%%%%%%%%%% ����fy-h��Ϣ��ֵ���� %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sum_blf_hx_m=zeros(length((dataSubcIndx)),M); %x��ֵ��h��ֵ�˻������
    for m=1:M
        for n=1:N
            blf_x_m=XnCell{n}.blf_x_m;
            blf_h_m=ChnlEstCell{m,n}.blf_h_m(dataSubcIndx);
            sum_blf_hx_m(:,m)=sum_blf_hx_m(:,m)+blf_h_m.*blf_x_m;
        end
    end
    for m=1:M
        y=RecvCell{m}.y(dataSubcIndx);
        for n=1:N
            blf_h_m=ChnlEstCell{m,n}.blf_h_m(dataSubcIndx);
            blf_x_m=XnCell{n}.blf_x_m;
            blf_x_v=XnCell{n}.blf_x_v;
            ChnlEstCell{m,n}.msg_fy2h_m(dataSubcIndx)= conj(blf_x_m).*(y-sum_blf_hx_m(:,m)+blf_h_m.*blf_x_m)./(abs(blf_x_m).^2+blf_x_v);
            ChnlEstCell{m,n}.msg_fy2h_v(dataSubcIndx)=1./(Lmd*(abs(blf_x_m).^2+blf_x_v));
        end
    end
    
    %% %%%%%%%%%%%%%%%%%%�����ŵ�����%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ChnlEstCell]=ChnlEstGlobal_GvSupt(SysSturct,ChnlEstCell,ChnlCell,DecodeStruct,EstPrec,1); %serial schedule
    H=ChnlCell{1,1}.H;
    MSE(1,it) = mean(abs(ChnlEstCell{1,1}.blf_h_m(dataSubcIndx)-H(dataSubcIndx)).^2); %�۲��ŵ�����MSE
    %% %%%�ڶ��Σ�������������õ�b��h���Ժ�%%%%
    if EstNoisePrec
        Lmd=LmdEstimation(SysSturct,DecodeStruct,RecvCell,SendCell,ChnlEstCell,XnCell); %����lembda,��δ��ɣ�
    end
    %% %%%%%%%%%%%%%%%%%%%%%%% ����fy-x��Ϣ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    sum_blf_h_m=zeros(length((dataSubcIndx)),M);
    for m=1:M
        for n=1:N
            blf_x_m=XnCell{n}.blf_x_m;
            blf_h_m=ChnlEstCell{m,n}.blf_h_m(dataSubcIndx);
            sum_blf_h_m(:,m)=sum_blf_h_m(:,m)+blf_h_m.*blf_x_m;
        end
    end
    for m=1:M
        y=RecvCell{m}.y(dataSubcIndx);
        for n=1:N
            blf_h_m=ChnlEstCell{m,n}.blf_h_m(dataSubcIndx);
            blf_h_v=ChnlEstCell{m,n}.blf_h_v(dataSubcIndx);
            blf_x_m=XnCell{n}.blf_x_m;
            
            msg_fy2x_m= conj(blf_h_m).*(y-sum_blf_h_m(:,m)+blf_h_m.*blf_x_m)./(abs(blf_h_m).^2+blf_h_v);
            msg_fy2x_v=1./(Lmd*(abs(blf_h_m).^2+blf_h_v));
            
            XnFymCell{m,n}.msg_fy2x_v=msg_fy2x_v;
            XnFymCell{m,n}.msg_fy2x_m=msg_fy2x_m;
        end
    end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%�ɸ�˹��fy-x��Ϣ������x-M��Ϣ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for n=1:N
        msg_x2M_m=zeros(Nd,1);      %��ʼ������Ϊ��
        msg_x2M_v=zeros(Nd,1);
        for m=1:M
            msg_x2M_v=msg_x2M_v+1./XnFymCell{m,n}.msg_fy2x_v; %�ۼ��䵹��
            msg_x2M_m=msg_x2M_m+XnFymCell{m,n}.msg_fy2x_m./XnFymCell{m,n}.msg_fy2x_v; %�ۼӾ�ֵ������
        end
        msg_x2M_v=1./msg_x2M_v;                           %(56.v)���ۼ���ɺ󣬵���
        msg_x2M_m=msg_x2M_v.*msg_x2M_m;                   %(56.m)���ۼ���ɺ�˷���
        XnCell{n}.msg_x2M_v=msg_x2M_v;
        XnCell{n}.msg_x2M_m=msg_x2M_m;
    end
    %% %%%%%%%%%%%%%%%%%%%%%%%%%%%(����)%%%%%%%%%%%%%%%%%%%%%%%%
    for n=1:N
        bicm_interleaver=SendCell{n}.bicm_interleaver;  %��ȡ��Դ�n��interleaver
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
        % д����Ӧcell
        XnCell{n}.extrinsic_coded_llrs=extrinsic_coded_llrs;
        XnCell{n}.soft_cod_bits_dec=soft_cod_bits_dec;
        XnCell{n}.errors=errors;
    end
    it = it + 1;
end
end
