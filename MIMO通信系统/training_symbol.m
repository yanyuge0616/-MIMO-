% ************************beginning of file*****************************
%training_symbol.m
function tx_training_symbols=training_symbol(Nt,carrier_count) 

%此函数用于产生训练符号

j=sqrt(-1); 
Wk=exp((-2*pi/carrier_count)*i); 
training_symbols= [ 1 j j 1 -1 -j -j -1 1 j j 1 -1 -j -j -1 1 j j 1 -1 -j -j -1 1 j j 1 -1 -j -j -1 1 j j 1 -1 ... 
                    -j -j -1 1 j j 1 -1 -j -j -1 1 j j 1 -1 -j -j -1 1 j j 1 -1 -j -j -1 1 j j 1 -1 -j -j -1 1 ... 
                    j j 1 -1 -j -j -1 1 j j 1 -1 -j -j -1 1 j j 1 -1 -j -j -1 1 j j 1 ]'; 
tx_training_symbols=[];       
for ii=1:carrier_count 
  training_symbols_buf=[];    
  for jj=1:Nt 
  training_symbols_buf=[training_symbols_buf,Wk^(-floor(carrier_count/Nt)*(jj-1)*ii)*training_symbols(ii,1)]; 
  end 
  tx_training_symbols=[tx_training_symbols;training_symbols_buf]; 
end
%************************end of file**********************************
