
function [user_bit,user_bit_cnt]  = user_bit_gen( N_user, N_data ,N_sym , Modulation )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 功能:       产生不同用户一帧内的发送比特
%           用cell结构体封装不同用户的数据,因为cell结构体的矩阵元素可以维数不同
% 输入:     N_user,用户数
%           N_data,数据子载波数 
%           N_sym,每帧OFDM符号数
%           Modulation, 调制方式
% 输出:     user_bit, 每个用户的比特序列,为cell结构
%           user_bit_cnt, 每个用户的序列长度
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 每个用户在一个OFDM符号期间发送的比特数
user_bit_tmp = cell( 1,N_user );
bit_per_sym = Modulation * N_data;%所有用户在一个OFDM符号内传送的总bit数

% 可以选择用户比特分布为：
% 1) 所有用户比特相同。 
bit_cnt_sym = repmat(bit_per_sym/N_user,1,N_user);

% 2) 用户按照比例 (1:N_user)/((1 + N_user)*N_user/2) 发送比特数据
% 目的是为了仿真不同用户的信息比特长度不同的情况,也可以修改得到其他的用户数据比例
% bit_cnt_sym = round( [1:N_user]/((1 + N_user)*N_user/2) * bit_per_sym );

user_bit_cnt = bit_cnt_sym * N_sym ;%每用户一帧内比特数

for u = 1:N_user 
    user_bit_tmp{u} = rand (  user_bit_cnt(u) ,1 ) > 0.5 ;%产生二进制随机序列
end


user_bit = user_bit_tmp;