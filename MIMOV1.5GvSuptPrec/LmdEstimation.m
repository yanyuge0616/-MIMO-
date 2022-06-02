function LmdEst=LmdEstimation(SysSturct,DecodeStruct,RecvCell,SendCell,ChnlEstCell,XnCell)
%function:更新lembda,尚未完成！
%time: 16.5.4PM
%note: 此处估计lemmda只采用数据部分，而并非导频和数据共同估计
M=SysSturct.M;
N=SysSturct.N;
pilotSubcIndxTotal=DecodeStruct.pilotSubcIndx;
dataSubcIndx=DecodeStruct.dataSubcIndx;
pilotSubcIndx=pilotSubcIndxTotal(1,:);
%GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %改变index位置1
%Kglobal=length(GlobalSubcIndx);% 只包含data+pilot部分的size
K=length(RecvCell{1}.y);   %整体子载波个数
Sum_OvAll_m=zeros(K,1); 
blf_x_m=zeros(K,1);
blf_x_v=zeros(K,1);
for m=1:M
    sum_xn_hn=zeros(K,1);    %xn,hn 期望乘积，对n求和
    sum_xn_vhmn=zeros(K,1);     %xn,vhn,vxn,hn交叉，对n求和
    y=RecvCell{m}.y;
    for n=1:N
        pilotSubcIndx=pilotSubcIndxTotal(n,:);  %取得此发射天线n的pilot index
        %GlobalSubcIndx=union(pilotSubcIndx,dataSubcIndx);   %取得此发射天线n的global index
        blf_x_m(pilotSubcIndx)=SendCell{n}.x(pilotSubcIndx);    %针对此pilot index 填充进真实的x，方差为0
        blf_x_v(pilotSubcIndx)=0;
        blf_x_m(dataSubcIndx)=XnCell{n}.blf_x_m;    %剩余的data index 填充进估计得到的b(x)
        blf_x_v(dataSubcIndx)=XnCell{n}.blf_x_v;
        
        blf_h_m=ChnlEstCell{m,n}.blf_h_m;
        blf_h_v=ChnlEstCell{m,n}.blf_h_v;
        
        sum_xn_vhmn=sum_xn_vhmn+abs(blf_x_m).^2.*blf_h_v+abs(blf_h_m).^2.*blf_x_v+blf_x_v.*blf_h_v;  %xn,vhn,vxn,hn交叉，对n求和
        sum_xn_hn=sum_xn_hn+blf_x_m.*blf_h_m; %xn,hn 期望乘积，对n求和
    end
    Sum_OvAll_m=Sum_OvAll_m+abs(y-sum_xn_hn).^2+sum_xn_vhmn;
end
LmdEst=M*K/sum(Sum_OvAll_m);
end