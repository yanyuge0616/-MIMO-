function varargout = icdtool(varargin)
%ICDTOOL - Individual Channel Design utility for 2x2 MIMO systems
%
% Syntax:
%    icdtool(G) - Starts icdtool for G, where G is a transfer function matrix
%
% Example: 
%    g11=tf(2,[1 3 2]);
%    g12=tf(-2,[1 1]);
%    g21=tf(-1,[1 2 1]);
%    g22=tf(6,[1 5 6]);
%    G=[g11 g12; g21 g22];
%
% Other m-files required: nyqmimo
%
% Author: Oskar Vivero Osornio
% email: oskar.vivero@gmail.com
% Created: February 2006; 
% Last revision: 12-April-2006;

% May be distributed freely for non-commercial use, 
% but please leave the above info unchanged, for
% credit and feedback purposes

% Last Modified by GUIDE v2.5 20-Apr-2006 00:42:51

%------------- BEGIN CODE --------------
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @icdtool_OpeningFcn, ...
                   'gui_OutputFcn',  @icdtool_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before icdtool is made visible.
function icdtool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to icdtool (see VARARGIN)

% Determining Input
ni=nargin;

switch ni
    case 4
        %Input is a matrix transfer function 
        G=varargin{1};
end


g11=G(1,1);
g12=G(1,2);
g21=G(2,1);
g22=G(2,2);
gamma=minreal((g12*g21)/(g11*g22));

setappdata(0,'hMainGui',gcf);
setappdata(gcf,'G',G);
setappdata(gcf,'gamma',gamma);

% Choose default command line output for icdtool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes icdtool wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = icdtool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function gain_K1_Callback(hObject, eventdata, handles)
% hObject    handle to gain_K1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gain_K1 as text
%        str2double(get(hObject,'String')) returns contents of gain_K1 as a double


% --- Executes during object creation, after setting all properties.
function gain_K1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gain_K1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function poles_K1_Callback(hObject, eventdata, handles)
% hObject    handle to poles_K1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of poles_K1 as text
%        str2double(get(hObject,'String')) returns contents of poles_K1 as a double


% --- Executes during object creation, after setting all properties.
function poles_K1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to poles_K1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zeros_K1_Callback(hObject, eventdata, handles)
% hObject    handle to zeros_K1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zeros_K1 as text
%        str2double(get(hObject,'String')) returns contents of zeros_K1 as a double


% --- Executes during object creation, after setting all properties.
function zeros_K1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zeros_K1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gain_K2_Callback(hObject, eventdata, handles)
% hObject    handle to gain_K2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gain_K2 as text
%        str2double(get(hObject,'String')) returns contents of gain_K2 as a double


% --- Executes during object creation, after setting all properties.
function gain_K2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gain_K2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function poles_K2_Callback(hObject, eventdata, handles)
% hObject    handle to poles_K2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of poles_K2 as text
%        str2double(get(hObject,'String')) returns contents of poles_K2 as a double


% --- Executes during object creation, after setting all properties.
function poles_K2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to poles_K2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zeros_K2_Callback(hObject, eventdata, handles)
% hObject    handle to zeros_K2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zeros_K2 as text
%        str2double(get(hObject,'String')) returns contents of zeros_K2 as a double


% --- Executes during object creation, after setting all properties.
function zeros_K2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zeros_K2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_C1.
function popupmenu_C1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_C1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_C1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_C1

% Get user input from GUI
% System data
hMainGui = getappdata(0,'hMainGui');
G = getappdata(hMainGui,'G');
gamma = getappdata(hMainGui,'gamma');
g11 = G(1,1);
g12 = G(1,2);
g21 = G(2,1);
g22 = G(2,2);

val = get(hObject,'Value');
str = get(hObject, 'String');

figure(1)
switch str{val};
    case 'Nyquist of Gamma' % User selects peaks

        % Status window
        [num11,den11]=tfdata(g11,'v');
        [num22,den22]=tfdata(g22,'v');
        zeros11=roots(num11);
        zeros22=roots(num22);
        RHPP11=0;
        RHPP22=0;
        for i=1:length(zeros11)
            if sign(real(zeros(i)))==1
                RHPP11=RHPP11+1;
            end
        end

        for i=1:length(zeros22)
            if sign(real(zeros22(i)))==1
                RHPP22=RHPP22+1;
            end
        end
        s1=sprintf('%-d RHPP in g11',RHPP11);
        s2=sprintf('%-d RHPP in g22',RHPP22);
        vars{1}='RHPP of Gamma';
        vars{2}=s1;
        vars{3}=s2;
        set(handles.status_window,'String',vars)
        
        % Plot
        syms p
        g=tf2sym(gamma);
        nyqmimo(gamma);
        title('Nyquist Diagram of Gamma')

    case 'Bode k1*g11' % User selects membrane
        k1=getappdata(hMainGui,'k1');
        margin(k1*g11);

    case 'Bode h1'
        h1=getappdata(hMainGui,'h1');

        % Status Window
        [num,den]=tfdata(h1,'v');
        den=roots(den);
        RHPP=0;
        for i=1:length(den)
            if sign(real(den))==1
                RHPP=RHPP+1;
            end
        end
        vars{1}=sprintf('%-d RHPP in h1',RHPP);
        set(handles.status_window,'String',vars)
        
        % Plot
        bode(h1);
        title('Bode Diagram h1')
        
    case 'Nyquist Gamma*h1' % User selects sinc
        h1=getappdata(hMainGui,'h1');
        syms p
        g=tf2sym(gamma*h1);
        nyqmimo(gamma*h1);
        title('Nyquist Diagram of Gamma*h1')

    case 'Bode Gamma*h1'
        h1=getappdata(hMainGui,'h1');
        margin(minreal(gamma*h1))

    case 'Nyquist C1'
        C1=getappdata(hMainGui,'C1');
        
        % Status Window
        [num,den]=tfdata(C1,'v');
        den=roots(den);
        RHPP=0;
        for i=1:length(den)
            if sign(real(den))==1
                RHPP=RHPP+1;
            end
        end
        vars{1}=sprintf('%-d RHPP in C1',RHPP);
        set(handles.status_window,'String',vars)
        
        % Plot
        syms p
        g=tf2sym(C1);
        nyqmimo(C1);
        title('Nyquist Diagram of C1')
        
    case 'Bode C1'
        C1=getappdata(hMainGui,'C1');
        margin(C1);

    case 'Step of C1->R1'
        C1=getappdata(hMainGui,'C1');
        C1cl=C1/(1+C1);
        step(C1cl);
        grid on
        title('Step Response of C1->R1')

    case 'Step of C1->R2'
        h2=getappdata(hMainGui,'h2');
        S1=getappdata(hMainGui,'S1');
        Pref1=minreal(((g12/g22)*h2)*S1);
        step(Pref1);
        grid on
        title('Step Response of C1->R2')
end


% --- Executes during object creation, after setting all properties.
function popupmenu_C1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_C1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_C2.
function popupmenu_C2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_C2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_C2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_C2

hMainGui = getappdata(0,'hMainGui');
G = getappdata(hMainGui,'G');
gamma = getappdata(hMainGui,'gamma');
g11 = G(1,1);
g12 = G(1,2);
g21 = G(2,1);
g22 = G(2,2);

val = get(hObject,'Value');
str = get(hObject, 'String');

figure(2)
switch str{val};
    case 'Nyquist of Gamma' % User selects peaks
        % Status window
        [num11,den11]=tfdata(g11,'v');
        [num22,den22]=tfdata(g22,'v');
        zeros11=roots(num11);
        zeros22=roots(num22);
        RHPP11=0;
        RHPP22=0;
        for i=1:length(zeros11)
            if sign(real(zeros(i)))==1
                RHPP11=RHPP11+1;
            end
        end

        for i=1:length(zeros22)
            if sign(real(zeros22(i)))==1
                RHPP22=RHPP22+1;
            end
        end
        s1=sprintf('%-d RHPP in g11',RHPP11);
        s2=sprintf('%-d RHPP in g22',RHPP22);
        vars{1}='RHPP of Gamma';
        vars{2}=s1;
        vars{3}=s2;
        set(handles.status_window,'String',vars)
        
        %Plot
        syms p
        g=tf2sym(gamma);
        nyqmimo(gamma);
        title('Nyquist Diagram of Gamma')

    case 'Bode k2*g22' % User selects membrane
        k2=getappdata(hMainGui,'k2');
        margin(k2*g22);

    case 'Bode h2'
        h2=getappdata(hMainGui,'h2');
        % Status Window
        [num,den]=tfdata(h2,'v');
        den=roots(den);
        RHPP=0;
        for i=1:length(den)
            if sign(real(den))==1
                RHPP=RHPP+1;
            end
        end
        vars{1}=sprintf('%-d RHPP in h2',RHPP);
        set(handles.status_window,'String',vars)

        % Plot
        bode(h2);
        title('Bode Diagram h2')
    case 'Nyquist Gamma*h2' % User selects sinc
        h2=getappdata(hMainGui,'h2');
        syms p
        g=tf2sym(gamma*h2);
        nyqmimo(gamma*h2);
        title('Nyquist Diagram of Gamma*h2')

    case 'Bode Gamma*h2'
        h2=getappdata(hMainGui,'h2');
        margin(minreal(gamma*h2))

    case 'Nyquist C2'
        C2=getappdata(hMainGui,'C2');

        % Status Window
        [num,den]=tfdata(C2,'v');
        den=roots(den);
        RHPP=0;
        for i=1:length(den)
            if sign(real(den))==1
                RHPP=RHPP+1;
            end
        end
        vars{1}=sprintf('%-d RHPP in C2',RHPP);
        set(handles.status_window,'String',vars)

        % Plot
        syms p
        g=tf2sym(C2);
        nyqmimo(C2);
        title('Nyquist Diagram of C2')
        
    case 'Bode C2'
        C2=getappdata(hMainGui,'C2');
        margin(C2);

    case 'Step of C2->R2'
        C2=getappdata(hMainGui,'C2');
        C2cl=C2/(1+C2);
        step(C2cl);
        grid on
        title('Step response of C2->R2')

    case 'Step of C2->R1'
        h1=getappdata(hMainGui,'h1');
        S2=getappdata(hMainGui,'S2');
        Pref2=minreal(((g21/g11)*h1)*S2);
        step(Pref2);
        grid on
        title('Step response of C2->R1')
end


% --- Executes during object creation, after setting all properties.
function popupmenu_C2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_C2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updatebutton.
function updatebutton_Callback(hObject, eventdata, handles)
% hObject    handle to updatebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get user input from GUI
% System data
hMainGui = getappdata(0,'hMainGui');
G = getappdata(hMainGui,'G');
gamma = getappdata(hMainGui,'gamma');
g11 = G(1,1);
g12 = G(1,2);
g21 = G(2,1);
g22 = G(2,2);

% K1 CONTROLLER
gain_k1 = str2double(get(handles.gain_K1,'String'));
poles_k1 = strread(get(handles.poles_K1,'String'));
zeros_k1 = strread(get(handles.zeros_K1,'String'));

% K2 CONTROLLER
gain_k2 = str2double(get(handles.gain_K2,'String'));
poles_k2 = strread(get(handles.poles_K2,'String'));
zeros_k2 = strread(get(handles.zeros_K2,'String'));

% Calculating data
% C1
num_k1=poly(zeros_k1);
den_k1=poly(poles_k1);
k1=tf(gain_k1*num_k1,den_k1);

% C2
num_k2=poly(zeros_k2);
den_k2=poly(poles_k2);
k2=tf(gain_k2*num_k2,den_k2);

% Subsystems and channels
h1=minreal((k1*g11)/(1+k1*g11));
h2=minreal((k2*g22)/(1+k2*g22));
C1=minreal((k1*g11)*(1-(gamma*h2)));
C2=minreal((k2*g22)*(1-(gamma*h1)));
% C1cl=C1/(1+C1);
% C2cl=C2/(1+C2);

% Sensibility channels
S1=minreal(1/(1+C1));
T1=minreal(C1/(1+C1));
S2=minreal(1/(1+C2));
T2=minreal(C2/(1+C2));

% Exporting data
setappdata(hMainGui,'k1',k1);
setappdata(hMainGui,'k2',k2);
setappdata(hMainGui,'h1',h1);
setappdata(hMainGui,'h2',h2);
setappdata(hMainGui,'C1',C1);
setappdata(hMainGui,'C2',C2);
setappdata(hMainGui,'S1',S1);
setappdata(hMainGui,'S2',S2);
setappdata(hMainGui,'T1',T1);
setappdata(hMainGui,'T2',T2);

% --- Executes on selection change in status_window.
function status_window_Callback(hObject, eventdata, handles)
% hObject    handle to status_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns status_window contents as cell array
%        contents{get(hObject,'Value')} returns selected item from status_window


% --- Executes during object creation, after setting all properties.
function status_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


