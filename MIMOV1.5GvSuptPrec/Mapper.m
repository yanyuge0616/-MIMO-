function [modulated cov]=Mapper(Mod,unmodulated,SoftHard)
%Author Gunvor Kirkelund
%
%modulated=Mapper(Mod,unmodulated,SoftHard) maps a binary sequence to a modulation alphabet.
%Mod is a variable indicating which modulation schemes is wanted, 1=BPSK,
%2=QPSK, 4=16QAM, unmodulated is the unmodulated sequence, the return
%sequence is the modulated sequence.
%The input SoftHard indicates wether the mapning is a hard value mapning or
%a soft value mapning, for harddecision the input unmodulated should be one
%dimensional and for soft mapning two dimensional.
cov=[];
[meaning coordinateset]=Modulation(Mod);
modulated=[];
if SoftHard==1
    while  length(unmodulated)/Mod-ceil(length(unmodulated)/Mod) ~= 0
        unmodulated=[unmodulated 0];
    end

    n=1;
    mm=1;
    while n<=length(unmodulated)

        symbol=unmodulated(n:Mod+n-1);

        m=1;
        modulated(mm)=coordinateset(m);
        while sum(abs(squeeze(meaning(:,m)).'-symbol)) ~= 0

            m=m+1;
            modulated(mm)=coordinateset(m);

        end
        mm=mm+1;
        n=n+Mod;
    end
else
    keyboard
    n=1;
    mm=1;
    mm1=1;
    bb=length(unmodulated);
    while n<=length(unmodulated)
        P1=[];
        covE=[];
        P1=0;
        P1_stor=0;
        for n2=1:length(coordinateset)

            P0=0;
            mm2=0;
            for m=1:log(length(coordinateset))/log(2)
                if mm1>bb

                else
                    if meaning(m,n2)==1
                        P0=P0+unmodulated(mm1,2);
                    else
                        P0=P0+unmodulated(mm1,1);
                    end
                end
                mm2=mm2+1;
                mm1=mm1+1;
            end
            mm1=mm1-mm2;
            P1(n2)=real(P0);
            P1_stor=max_special(P1_stor,P1(n2)); %% Why compare with only one P1_stor??? Shouldn't there be one for 1's and one for 0's??? Check!!
        end
        P1=exp(P1-P1_stor);
       % P1=P1./sum(P1);
        for n2=1:length(coordinateset)
            if P1(n2)<0 || P1(n2)>1
                P1(n2)
            end
            covE(n2)=coordinateset(n2)*coordinateset(n2)'*P1(n2);
            P1(n2)=coordinateset(n2)*P1(n2);

        end
        cov(mm)=abs(sum(covE)-sum(P1)*sum(P1)');
        modulated(mm)=sum(P1);
        mm=mm+1;
        mm1=mm1+Mod;
        n=n+Mod;
    end
end