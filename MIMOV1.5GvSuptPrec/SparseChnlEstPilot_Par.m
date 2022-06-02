function [ChnlEstCell LmdEst]=SparseChnlEstPilot_Par(SysSturct,SendCell,RecvCell,ChnlCell,DecodeStruct,Lmd,EstimateLmd,Niter)
%function：单纯利用导频，稀疏贝叶斯估计，并行schedule
%author：yuan
%time：5.5PM
%注释： Common support, parallel schedule 
M=SysSturct.M;
N=SysSturct.N;
pilotSubcIndxTotal=DecodeStruct.pilotSubcIndx;
%dataSubcIndx=DecodeStruct.dataSubcIndx;
[~,K]=size(pilotSubcIndxTotal); %总子载波个数
Phi=ChnlCell{1,1}.Phi;      %
[~, L]=size(Phi);           %抽头数
Bayesian_BP_init;           %初始化分层贝叶斯模型
ChnlEstCell=cell(M,N);
if EstimateLmd==0
    LmdEst=Lmd; %如果不估计lembda，用真实值替代。
else
    LmdEst=10; %if estimate the precision, just use 10 to initiate Lmd;
end
for m=1:M
    for n=1:N
        ChnlEstCell{m,n}=BayesianBP; %将cell初始化为对应结构体
    end
end

for iter=1:Niter
    for m=1:M
        for n=1:N
            pilotSubcIndx=pilotSubcIndxTotal(n,:);  %取对应发送端n的导频
            x=SendCell{n}.x(pilotSubcIndx);
            y=RecvCell{m}.y(pilotSubcIndx);
            Phi=ChnlCell{m,n}.Phi;      
            phi=Phi(pilotSubcIndx,:);   %只取导频部分phi
            msg_fy2h_m=y./x;
            msg_fy2h_v=1./(LmdEst*abs(x).^2);
                %稀疏贝叶斯估计，第一部分
            [ChnlEstCell{m,n}]=SparseChannelEstBayOne(phi,K,L,M,ChnlEstCell{m,n},msg_fy2h_m,msg_fy2h_v);
        end
    end
    %更新对应mnCell的二阶矩对所有M求和
    for n=1:N
        SumScndMmt=zeros(L,1);
        for m=1:M
            blf_alpha_m=ChnlEstCell{m,n}.blf_alpha_m;
            blf_alpha_v=ChnlEstCell{m,n}.blf_alpha_v;
            SumScndMmt=SumScndMmt+abs(blf_alpha_m).^2+blf_alpha_v;  %对所有二阶矩求和
            ChnlEstCell{m,n}.SumScndMmt=SumScndMmt; %写入cell
        end
    end
    for m=1:M
        for n=1:N
            pilotSubcIndx=pilotSubcIndxTotal(n,:);  %取对应发送端n的导频
            x=SendCell{n}.x(pilotSubcIndx);
            y=RecvCell{m}.y(pilotSubcIndx);
            Phi=ChnlCell{m,n}.Phi;
            phi=Phi(pilotSubcIndx,:);   %
            msg_fy2h_m=y./x;
            msg_fy2h_v=1./(LmdEst*abs(x).^2);
            [ChnlEstCell{m,n}]=SparseChannelEstBayTwo(phi,K,L,M,ChnlEstCell{m,n},msg_fy2h_m,msg_fy2h_v);
            alpha=ChnlCell{m,n}.alpha;  %真实的抽头
            alpha_est=ChnlEstCell{m,n}.blf_alpha_m;
            ChnlEstCell{m,n}.MSE_Alpha(iter) = mean(abs(ChnlEstCell{m,n}.blf_alpha_m-alpha).^2);
        end
    end
   
    if EstimateLmd % 计算lemmda
        Sum_OvAll_m=zeros(K,1); %
        for m=1:M
            sum_xn_hn=zeros(K,1);    %xn,hn 期望乘积，对n求和
            sum_xn_vhmn=zeros(K,1);     %xn,vhn,vxn,hn交叉，对n求和
            y=RecvCell{m}.y(pilotSubcIndx);
            for n=1:N
                blf_x_m=SendCell{n}.x(pilotSubcIndx);
                blf_x_v=zeros(length(blf_x_m),1);
                blf_h_m=ChnlEstCell{m,n}.blf_h_m;
                blf_h_v=ChnlEstCell{m,n}.blf_h_v;
                
                sum_xn_vhmn=sum_xn_vhmn+abs(blf_x_m).^2.*blf_h_v+abs(blf_h_m).^2.*blf_x_v+blf_x_v.*blf_h_v;  %xn,vhn,vxn,hn交叉，对n求和
                sum_xn_hn=sum_xn_hn+blf_x_m.*blf_h_m; %xn,hn 期望乘积，对n求和
            end
            Sum_OvAll_m=Sum_OvAll_m+abs(y-sum_xn_hn).^2+sum_xn_vhmn; %对m求和
        end
        LmdEst=M*K/sum(Sum_OvAll_m);    %对k求和
    end
end
end




