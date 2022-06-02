function [ChnlEstCell]=SparseChnlEstGlobal_Ser(SysSturct,ChnlEstCell,ChnlCell,DecodeStruct,Niter)
%function：全局（导频和数据合集）稀疏贝叶斯估计
%time：16.5.5PM
%注释：（1）将全部ChnlEstCell赋值到本地ChnlEstCell。（2）生成针对本cell的合集，频域的合集赋值到本地ChnlEstCell。
%（3）本地ChnlEstCell进行稀疏估计。（4）重新写回全局ChnlEstCell。
M=SysSturct.M;
N=SysSturct.N;
pilotSubcIndxTotal=DecodeStruct.pilotSubcIndx;
dataSubcIndx=DecodeStruct.dataSubcIndx;
pilotSubcIndx=pilotSubcIndxTotal(1,:);
GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %改变index位置1
%GlobalSubcIndx=dataSubcIndx;
[~,K]=size(GlobalSubcIndx);
Phi=ChnlCell{1,1}.Phi;
[~, L]=size(Phi);
%% （1）
SubChnlEstCell=ChnlEstCell;
%% （2）
for n=1:N
    dataSubcIndx=DecodeStruct.dataSubcIndx;
    pilotSubcIndx=pilotSubcIndxTotal(n,:);
    GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %改变index位置1
    for m=1:M
        SubChnlEstCell{m,n}.msg_alpha2h_v=ChnlEstCell{m,n}.msg_alpha2h_v(GlobalSubcIndx,:);
        SubChnlEstCell{m,n}.msg_alpha2h_m=ChnlEstCell{m,n}.msg_alpha2h_m(GlobalSubcIndx,:);
        
        SubChnlEstCell{m,n}.msg_h2alpha_v=ChnlEstCell{m,n}.msg_h2alpha_v(GlobalSubcIndx,:);
        SubChnlEstCell{m,n}.msg_h2alpha_m=ChnlEstCell{m,n}.msg_h2alpha_m(GlobalSubcIndx,:);
        
        SubChnlEstCell{m,n}.blf_h_v=ChnlEstCell{m,n}.blf_h_v(GlobalSubcIndx);
        SubChnlEstCell{m,n}.blf_h_m=ChnlEstCell{m,n}.blf_h_m(GlobalSubcIndx);
        
        SubChnlEstCell{m,n}.msg_p_v=ChnlEstCell{m,n}.msg_p_v(GlobalSubcIndx);
        SubChnlEstCell{m,n}.msg_p_m=ChnlEstCell{m,n}.msg_p_m(GlobalSubcIndx);
        
        SubChnlEstCell{m,n}.msg_fy2h_m=ChnlEstCell{m,n}.msg_fy2h_m(GlobalSubcIndx);
        SubChnlEstCell{m,n}.msg_fy2h_v=ChnlEstCell{m,n}.msg_fy2h_v(GlobalSubcIndx);
    end
end
%% （3）
for iter=1:Niter
    for n=1:N
        for m=1:M
            %% 第一部分，初步更新alpha
            pilotSubcIndx=pilotSubcIndxTotal(n,:);
            GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %改变index位置2
            %GlobalSubcIndx=dataSubcIndx;    %测试，只采用数据部分，放弃导频和数据公用的情况
            Phi=ChnlCell{m,n}.Phi;
            phi=Phi(GlobalSubcIndx,:);
            msg_fy2h_m=SubChnlEstCell{m,n}.msg_fy2h_m;
            msg_fy2h_v=SubChnlEstCell{m,n}.msg_fy2h_v;
            %一次稀疏贝叶斯估计。
            [SubChnlEstCell{m,n}]=SparseChannelEstBayOne(phi,K,L,M,SubChnlEstCell{m,n},msg_fy2h_m,msg_fy2h_v);
            
            %% 第二部分，更新对应mn的alpha的二阶矩对所有M求和
            SumScndMmt=zeros(L,1);
            for mm=1:M
                blf_alpha_m=SubChnlEstCell{mm,n}.blf_alpha_m;
                blf_alpha_v=SubChnlEstCell{mm,n}.blf_alpha_v;
                SumScndMmt=SumScndMmt+abs(blf_alpha_m).^2+blf_alpha_v;  %对所有二阶矩求和
            end
            SubChnlEstCell{m,n}.SumScndMmt=SumScndMmt; %写入cell

            %% 第三部分，更新gamma，alpha，alpha-h消息，b（h）等
            [SubChnlEstCell{m,n}]=SparseChannelEstBayTwo(phi,K,L,M,SubChnlEstCell{m,n},msg_fy2h_m,msg_fy2h_v);
            %             alpha=ChnlCell{m,n}.alpha;  %真实的抽头
            %             alpha_est=SubChnlEstCell{m,n}.blf_alpha_m;
            %             SubChnlEstCell{m,n}.MSE_Alpha(iter) = mean(abs(SubChnlEstCell{m,n}.blf_alpha_m-alpha).^2);
        end
    end
end
%% （4）
for n=1:N
    dataSubcIndx=DecodeStruct.dataSubcIndx;
    pilotSubcIndx=pilotSubcIndxTotal(n,:);
    GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %改变index位置1
    for m=1:M
        %再将去处空缺以后的信道估计结果，写入老结构体（只写“非空缺”位置）。
        ChnlEstCell{m,n}.msg_alpha2h_v(GlobalSubcIndx,:)=SubChnlEstCell{m,n}.msg_alpha2h_v;
        ChnlEstCell{m,n}.msg_alpha2h_m(GlobalSubcIndx,:)=SubChnlEstCell{m,n}.msg_alpha2h_m;
        
        ChnlEstCell{m,n}.msg_h2alpha_v(GlobalSubcIndx,:)=SubChnlEstCell{m,n}.msg_h2alpha_v;
        ChnlEstCell{m,n}.msg_h2alpha_m(GlobalSubcIndx,:)=SubChnlEstCell{m,n}.msg_h2alpha_m;
        
        ChnlEstCell{m,n}.blf_h_v(GlobalSubcIndx)=SubChnlEstCell{m,n}.blf_h_v;
        ChnlEstCell{m,n}.blf_h_m(GlobalSubcIndx)=SubChnlEstCell{m,n}.blf_h_m;
        
        ChnlEstCell{m,n}.msg_p_v(GlobalSubcIndx)=SubChnlEstCell{m,n}.msg_p_v;
        ChnlEstCell{m,n}.msg_p_m(GlobalSubcIndx)=SubChnlEstCell{m,n}.msg_p_m;
        
        ChnlEstCell{m,n}.msg_fy2h_m(GlobalSubcIndx)=SubChnlEstCell{m,n}.msg_fy2h_m;
        ChnlEstCell{m,n}.msg_fy2h_v(GlobalSubcIndx)=SubChnlEstCell{m,n}.msg_fy2h_v;
    end
end
end