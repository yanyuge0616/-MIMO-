function [ChnlEstCell LmdEst]=ChnlEstPilot_GvSupt(SysSturct,SendCell,RecvCell,ChnlCell,DecodeStruct,Lmd,EstimateLmd,EstPrec,Niter)
%function：单纯利用导频，贝叶斯估计，串行schedule
%time：5.6PM
%注释：已知support,串行schedule

M=SysSturct.M;
N=SysSturct.N;
pilotSubcIndxTotal=DecodeStruct.pilotSubcIndx;
[~,K]=size(pilotSubcIndxTotal); %总子载波个数
Support=ChnlCell{1,1}.Support;  % 时域的维度为support个数
L=length(Support);
Bayesian_BP_init;           %初始化分层贝叶斯模型
ChnlEstCell=cell(M,N);
if EstimateLmd==0
    LmdEst=Lmd; %如果不估计lembda，用真实值替代。
else
    LmdEst=10; %if estimate the precision, just use 10 to initiate Lmd;
end
MeanAlphaV=zeros(1,Niter);
for m=1:M
    for n=1:N
        ChnlEstCell{m,n}=BayesianBP; %将cell初始化为对应结构体
        ChnlEstCell{m,n}.MeanAlphaV=MeanAlphaV;%初始化平均方差
    end
end

%% 全局迭代
for iter=1:Niter
    for n=1:N
        for m=1:M
            %% 第一部分，初步更新alpha
            pilotSubcIndx=pilotSubcIndxTotal(n,:);  %取对应发送端n的导频
            x=SendCell{n}.x(pilotSubcIndx);
            y=RecvCell{m}.y(pilotSubcIndx);
            Support=ChnlCell{m,n}.Support;
            Phi=ChnlCell{m,n}.Phi;      
            phi=Phi(pilotSubcIndx,Support);   %phi只取导频部分列，support部分行
            msg_fy2h_m=y./x;
            msg_fy2h_v=1./(LmdEst*abs(x).^2);
            %稀疏贝叶斯估计，第一部分，初步更新alpha
            [ChnlEstCell{m,n}]=SparseChannelEstBayOne(phi,K,L,M,ChnlEstCell{m,n},msg_fy2h_m,msg_fy2h_v);
            
            %% 更新对应mn的alpha的二阶矩对所有M求和
            SumScndMmt=zeros(L,1);
            for mm=1:M
                blf_alpha_m=ChnlEstCell{mm,n}.blf_alpha_m;
                blf_alpha_v=ChnlEstCell{mm,n}.blf_alpha_v;
                SumScndMmt=SumScndMmt+abs(blf_alpha_m).^2+blf_alpha_v;  %对所有二阶矩求和
            end
            ChnlEstCell{m,n}.SumScndMmt=SumScndMmt; %写入cell
            
            %% 第二部分，更新gamma，alpha，alpha-h消息，b（h）等
            [ChnlEstCell{m,n}]=SparseChannelEstBayTwo(phi,K,L,M,ChnlEstCell{m,n},ChnlCell{m,n},msg_fy2h_m,msg_fy2h_v,EstPrec);
            alpha=ChnlCell{m,n}.alpha(Support); %只取support部分的alpha做MSE计算
            ChnlEstCell{m,n}.MSE_Alpha(iter) = mean(abs(ChnlEstCell{m,n}.blf_alpha_m-alpha).^2);
            blf_alpha_v=ChnlEstCell{m,n}.blf_alpha_v;
            Mean=mean(blf_alpha_v);
            ChnlEstCell{m,n}.MeanAlphaV(iter)=Mean;%统计mean（blf_alpha_v）大概，小于2e-3能达到最佳性能。
        end
    end
    %% 第三部分，估计噪声方差
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
%     blf_alpha_v=ChnlEstCell{1,1}.blf_alpha_v;
%     mean_alphav=mean(blf_alpha_v);
%     if mean_alphav<threshold
%         break;
%     end
end
end



