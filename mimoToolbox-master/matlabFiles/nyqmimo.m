function nyqmimo(a,b,c,d,wi,wf,step)
%NYQMIMO - Find the general nyquist plot of a LTI nxn MIMO and SISO models
% Nyqmimo is capable of finding the roundings due to integral effects and
% improper transfer functions.
%
% Syntax: nyqmimo(SYS,wi,wf,step)
%
% Inputs:
%    a,b,c,d - System (SYS)
%    wi - Initial Frequency value (default wi=1e-3)
%    wf - Final Frequency value (default wf=1e6)
%    step - Amount of points between the initial and final frequency values
%    (default step resolution = 1000 points)
%
% Example 1 (SISO SYS): 
%    G=tf([1 25],[1 5 3 -9 0]);
%    nyqmimo(G)
% 
% Example 2 (Improper SISO SYS):
%    G=tf((1/6)*[1  7 14 12],[1 2 1]);
%    nyqmimo(G)
% 
% Example 2 (MIMO SYS):
%    den=1.25*conv([1 1],[1 2]);
%    g11=tf([1 -1],den);
%    g12=tf([1 0],den);
%    g21=tf([-6],den);
%    g22=tf([1 -2],den);
%    G=[g11 g12;g21 g22];
%    nyqmimo(G)
%
% Other m-files required: tf2sym, ss2sym
% Subfunctions: Arrows
%
% See also: gershband
%
% Author: Oskar Vivero Osornio
% email: oskar.vivero@gmail.com
% Created: February 2006; 
% Last revision: 11-May-2006;

% May be distributed freely for non-commercial use, 
% but please leave the above info unchanged, for
% credit and feedback purposes

%------------- BEGIN CODE --------------
%--------- Determines Syntax -----------
ni=nargin;
p=sym('p');

switch ni
    case 1
        %Transfer Function Syntax without wi, step and wf
        step=1000;
        wi=-3;
        wf=6;
        switch class(a)
            case 'tf'
                %Numeric Transfer Function Syntax
                G=a;
                g=tf2sym(G);

            case 'sym'
                %Symbolic Transfer Function Syntax
                g=a;
        end
        
    case 2
        %Transfer Function [num,den] Syntax without step and wf
        G=tf(a,b);
        step=1000;
        wi=-3;
        wf=6;
        g=tf2sym(G);
                
    case 4
        switch class(a)
            case 'tf'
                %Numeric Transfer Function Syntax with wi, step and wf
                G=a;
                g=tf2sym(G);
                wi=b;
                wf=c;
                step=d;
                
            case 'sym'
                %Symbolic Transfer Function Syntax with wi,step and wf
                g=a;
                wi=b;
                wf=c;
                step=d;
                
            case 'double'
                %State Space Syntax without wi, wf and step
                g=ss2sym(a,b,c,d);
                step=1000;
                wi=-3;
                wf=6;
        end
        
    case 7
        %State Space Syntax with step and wf
        g=ss2sym(a,b,c,d);
end
%----------------------------------------
e=eig(g);
m=length(e);
sing_o=zeros(m,1);
sing_oo=sing_o;
%------ Singularities on the origin -----
lim_o=limit(e,p,0);
for k=1:m
    if isfinite(eval(lim_o(k)))==false
        sing_o(k)=sing_o(k)+1;
    end
end
%-------- Checking for G improper -------
lim_oo=limit(e,p,Inf);
for k=1:m
    if isfinite(eval(lim_oo(k)))==false
        sing_oo(k)=sing_oo(k)+1;
    end
end
%-------- Setting Nyquist Contour -------
w=complex(0,logspace(wi,wf,step));
n=length(w);
if (sum(sing_o)>0)&&(sum(sing_oo)==0) %proper-integrators
    q=0:pi/50:pi/2;
    lemma_o=abs(w(1))*exp(i*q);
    freq=zeros(1,n+length(lemma_o));
    freq(1,1:length(lemma_o))=lemma_o;
    freq(1,(length(lemma_o)+1):(length(lemma_o)+n))=w;
elseif (sum(sing_o)==0)&&(sum(sing_oo>0)) %improper-continous
    f=pi/2:-pi/200:0;
    lemma_oo=abs(w(n))*exp(i*f);
    freq=zeros(1,n+length(lemma_oo));
    freq(1,1:n)=w;
    freq(1,(n+1):(n+length(lemma_oo)))=lemma_oo;
elseif (sum(sing_o)==0)&&(sum(sing_oo)==0) %proper-continous
    freq=w;
else %improper-integratos
    q=0:pi/50:pi/2;
    lemma_o=abs(w(1))*exp(i*q);
    f=pi/2:-pi/200:0;
    lemma_oo=abs(w(n))*exp(i*f);
    freq=zeros(1,(n+length(lemma_o)+length(lemma_oo)));
    freq(1,1:length(lemma_o))=lemma_o;
    freq(1,(length(lemma_o)+1):(length(lemma_o)+n))=w;
    freq(1,(length(lemma_o)+n+1):(length(lemma_o)+n+length(lemma_oo)))=lemma_oo;
end
%--------------- MAPPING ----------------
nyq=zeros(length(freq),m);
for k=1:m
    nyq(:,k)=subs(e(k),freq);
end
%--------------- PLOTTING ---------------
plot(nyq)
hold on
plot(real(nyq),-imag(nyq),'--')
plot(-1,0,'r+')

if sum(sing_oo)==0
    for j=1:m
        v1=nyq(26,j);
        v2=nyq(46,j);
        v3=nyq(200,j);
        v4=nyq(220,j);
        x1(1)=real(v1);
        x1(2)=real(v2);
        y1(1)=imag(v1);
        y1(2)=imag(v2);
        x2(1)=real(v3);
        x2(2)=real(v4);
        y2(1)=imag(v3);
        y2(2)=imag(v4);
        arrowh(x1,y1)
        arrowh(x2,y2)
    end

else
    for j=1:m
        v1=nyq(860,j);
        v2=nyq(880,j);
        v3=nyq(960,j);
        v4=nyq(980,j);
        x1(1)=real(v1);
        x1(2)=real(v2);
        y1(1)=imag(v1);
        y1(2)=imag(v2);
        x2(1)=real(v3);
        x2(2)=real(v4);
        y2(1)=imag(v3);
        y2(2)=imag(v4);
        arrowh(x1,y1)
        arrowh(x2,y2)
    end
end
hold off
%------------- END OF CODE --------------