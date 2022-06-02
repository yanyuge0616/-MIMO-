function output=stbc_code_TX(input)
%----------------------------------------------------------------------

%对输入的OFDM符号进行空时编码，采用两个或四个发送天线。
%input为输入的信号，input的列数为发送天线数；
%input的每一列是一个OFDM符号；
%output为输出的OFDM符号（经过了空时分组编码）

% 编写: 刘江华 , 2004.3
%----------------------------------------------------------------------
index=size(input,2);
if index==2   %发送天线数为2
    Xe=input(:,1);%取第一列，即第一个OFDM符号
    Xo=input(:,2);%取第二列，即第二个OFDM符号
    output=[Xe Xo;-conj(Xo) conj(Xe)];%alamouti编码
elseif index==4
    X1=input(:,1);
    X2=input(:,2);
    X3=input(:,3);
    X4=input(:,4);
    output=[X1 X2 X3  X4;...
        -X2 X1 -X4 X3;...
        -X3 X4 X1 -X2;...
        -X4 -X3 X2 X1;...
        conj(X1) conj(X2) conj(X3) conj(X4);...
        -conj(X2) conj(X1) -conj(X4) conj(X3);...
        -conj(X3) conj(X4) conj(X1) -conj(X2);...
        -conj(X4) -conj(X3) conj(X2) conj(X1)];
else fprintf('输入不正确，请重新输入')
end

