function varargout = Konecne_diference(varargin)
% KONECNE_DIFERENCE MATLAB code for Konecne_diference.fig
%      KONECNE_DIFERENCE, by itself, creates a new KONECNE_DIFERENCE or raises the existing
%      singleton*.
%
%      H = KONECNE_DIFERENCE returns the handle to a new KONECNE_DIFERENCE or the handle to
%      the existing singleton*.
%
%      KONECNE_DIFERENCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KONECNE_DIFERENCE.M with the given input arguments.
%
%      KONECNE_DIFERENCE('Property','Value',...) creates a new KONECNE_DIFERENCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Konecne_diference_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Konecne_diference_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Konecne_diference

% Last Modified by GUIDE v2.5 01-May-2017 00:01:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Konecne_diference_OpeningFcn, ...
                   'gui_OutputFcn',  @Konecne_diference_OutputFcn, ...
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


% --- Executes just before Konecne_diference is made visible.
function Konecne_diference_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Konecne_diference (see VARARGIN)

% Choose default command line output for Konecne_diference
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Konecne_diference wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Konecne_diference_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in solve.
function solve_Callback(hObject, eventdata, handles)
set(handles.busy,'String','»akajte prosÌm   V˝poËet prebieha');
guidata(hObject,handles);
drawnow();
%extrahovat data z GIU
inputy = strcat('(',get(handles.inputy,'String'),')');
inputyd = strcat('(',get(handles.inputyd,'String'),')');
inputydd = strcat('(',get(handles.inputydd,'String'),')');
inputRHS = strcat('(',get(handles.inputRHS,'String'),')');
a = str2double(get(handles.a,'String'));
b = str2double(get(handles.b,'String'));
a_RHS = str2double(get(handles.ya,'String'));
b_RHS = str2double(get(handles.yb,'String'));
a_alfa1 = str2double(get(handles.a_alfa1,'String'));
a_alfa2 = str2double(get(handles.a_alfa2,'String'));
b_beta1 = str2double(get(handles.b_beta1,'String'));
b_beta2 = str2double(get(handles.b_beta2,'String'));
presnost = str2double(get(handles.presnost,'String'));
over_jednoznacost = (get(handles.jednoznacnost,'Value'));
%% overit ci su vstupy platne
if a>=b
   msg = 'a je v‰Ëöie alebo rovnÈ b, obr·ù podmienky'; 
   set(handles.busy,'String',msg);
   guidata(hObject,handles);
   return;
end
if (strcmp(inputydd,'(0)'))
   msg = 'Druh· deriv·cia musÌ buù nenulov·!';
   set(handles.busy,'String',msg);
   guidata(hObject,handles);
   return;
end
if presnost==0
   msg = 'Presnosù musÌ byù >0!';
   set(handles.busy,'String',msg);
   guidata(hObject,handles);
   return;
end
[ok_subs_center, ok_subs_pos] = over_podmienky(...
    inputydd,inputyd,inputy,a,b,100);
%% definovat substituce, rovnice
syms x y_ip y_i y_in h
%subsitucie * h^2
subs_y = '(y_i*h^2)';
if (ok_subs_center)
    subs_yd = '(((y_ip-y_in)/2)*h)';
else
    if (ok_subs_pos)
        subs_yd = '((y_ip-y_i)*h)';
    else
       msg = 'Rovnica sa ned· rieöiù touto metÛdou!';
       set(handles.busy,'String',msg);
       guidata(hObject,handles);
       return;
    end
end
subs_ydd = '(y_ip-2*y_i+y_in)';

%vytvorit lavu stranu rovnice
LHS = strcat('(',inputy,')*',subs_y,'+(',inputyd,')*'...
    ,subs_yd,'+(',inputydd,')*',subs_ydd);
difeq = eval(LHS);
difeq = expand(difeq);

%vytvorit pravu stranu rovnice
RHS = eval(strcat(inputRHS,'*h^2'));

%% vypocet metody, predat data funkcii
max_iter = 30; %obmedzenie itracii konecnych diferencii

%stara verzia, dokaze iba derichletove podmienky
%[xres, yres, presnost_out, krok_out, msg] = kondiff_calc...
%    (difeq,RHS,a,b,a_RHS,b_RHS,presnost,max_iter);

%nova verzia, dokaze vseobecne sturmove podmienky
podm_a = [a a_alfa1 a_alfa2 a_RHS];
podm_b = [b b_beta1 b_beta2 b_RHS];
[xres, yres, presnost_out, krok_out, msg] = kondiff_calc_v2...
    (difeq,RHS,podm_a,podm_b,presnost,max_iter,over_jednoznacost);
%vypis s akym krokom bolo vyriesene, a s akou presnostou
set(handles.krok_out,'String',sprintf('%e',krok_out));
set(handles.presnost_out,'String',sprintf('%e',presnost_out));

%porovnanie s presnym riesenim, vykresli sa 30 bodov
axes(handles.plot);
if (get(handles.exact,'Value'))
    xpres = linspace(a,b,30);
    %presne riesenie napisane v GUI
    syms x;
    fexact = eval(get(handles.Fexact,'String'));
    for t=1:30
        y_presne(t) = eval(subs(fexact,x,xpres(t)));
    end
    plot(xres,yres,xpres,y_presne,'kx');
    %debug, na vypis chyb.
    save('aktualny_vypocet','xres','yres','presnost_out','fexact');
else %ak nebolo zvolene porovnanie s presnym riesenim, 
    %vykresli sa iba graf funkcie y
    plot(xres,yres);   
end
%nastav status spravu
set(handles.busy,'String',msg);
%nastav data do tabulky
set(handles.table,'Data',[xres yres]);

%uloz ak bolo zvolene ulozenie tak uloz do suboru
if (get(handles.save,'Value'))
    filename = strcat(get(handles.filename,'String'),'.csv');
    save_data(xres,yres,filename);
end
guidata(hObject,handles);

function inputRHS_Callback(hObject, eventdata, handles)
% hObject    handle to inputRHS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputRHS as text
%        str2double(get(hObject,'String')) returns contents of inputRHS as a double


% --- Executes during object creation, after setting all properties.
function inputRHS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputRHS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function inputa_Callback(hObject, eventdata, handles)
% hObject    handle to inputa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputa as text
%        str2double(get(hObject,'String')) returns contents of inputa as a double


% --- Executes during object creation, after setting all properties.
function inputa_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputa (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function inputy_Callback(hObject, eventdata, handles)
% hObject    handle to inputy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputy as text
%        str2double(get(hObject,'String')) returns contents of inputy as a double


% --- Executes during object creation, after setting all properties.
function inputy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function inputyd_Callback(hObject, eventdata, handles)
% hObject    handle to inputyd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputyd as text
%        str2double(get(hObject,'String')) returns contents of inputyd as a double


% --- Executes during object creation, after setting all properties.
function inputyd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputyd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function inputydd_Callback(hObject, eventdata, handles)
% hObject    handle to inputydd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputydd as text
%        str2double(get(hObject,'String')) returns contents of inputydd as a double


% --- Executes during object creation, after setting all properties.
function inputydd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputydd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function inputyddd_Callback(hObject, eventdata, handles)
% hObject    handle to inputyddd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputyddd as text
%        str2double(get(hObject,'String')) returns contents of inputyddd as a double


% --- Executes during object creation, after setting all properties.
function inputyddd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputyddd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1



function a_Callback(hObject, eventdata, handles)
% hObject    handle to a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a as text
%        str2double(get(hObject,'String')) returns contents of a as a double


% --- Executes during object creation, after setting all properties.
function a_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function b_Callback(hObject, eventdata, handles)
% hObject    handle to b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b as text
%        str2double(get(hObject,'String')) returns contents of b as a double


% --- Executes during object creation, after setting all properties.
function b_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function presnost_Callback(hObject, eventdata, handles)
% hObject    handle to presnost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of presnost as text
%        str2double(get(hObject,'String')) returns contents of presnost as a double


% --- Executes during object creation, after setting all properties.
function presnost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to presnost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save.
function save_Callback(hObject, eventdata, handles)
% hObject    handle to save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function ya_Callback(hObject, eventdata, handles)
% hObject    handle to ya (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ya as text
%        str2double(get(hObject,'String')) returns contents of ya as a double


% --- Executes during object creation, after setting all properties.
function ya_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ya (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yb_Callback(hObject, eventdata, handles)
% hObject    handle to yb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yb as text
%        str2double(get(hObject,'String')) returns contents of yb as a double


% --- Executes during object creation, after setting all properties.
function yb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filename_Callback(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filename as text
%        str2double(get(hObject,'String')) returns contents of filename as a double


% --- Executes during object creation, after setting all properties.
function filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in exact.
function exact_Callback(hObject, eventdata, handles)
% hObject    handle to exact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of exact



function Fexact_Callback(hObject, eventdata, handles)
% hObject    handle to Fexact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Fexact as text
%        str2double(get(hObject,'String')) returns contents of Fexact as a double


% --- Executes during object creation, after setting all properties.
function Fexact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Fexact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function a_alfa2_Callback(hObject, eventdata, handles)
% hObject    handle to a_alfa2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a_alfa2 as text
%        str2double(get(hObject,'String')) returns contents of a_alfa2 as a double


% --- Executes during object creation, after setting all properties.
function a_alfa2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a_alfa2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function a_alfa1_Callback(hObject, eventdata, handles)
% hObject    handle to a_alfa1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of a_alfa1 as text
%        str2double(get(hObject,'String')) returns contents of a_alfa1 as a double


% --- Executes during object creation, after setting all properties.
function a_alfa1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to a_alfa1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function b_beta1_Callback(hObject, eventdata, handles)
% hObject    handle to b_beta1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b_beta1 as text
%        str2double(get(hObject,'String')) returns contents of b_beta1 as a double


% --- Executes during object creation, after setting all properties.
function b_beta1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b_beta1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function b_beta2_Callback(hObject, eventdata, handles)
% hObject    handle to b_beta2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of b_beta2 as text
%        str2double(get(hObject,'String')) returns contents of b_beta2 as a double


% --- Executes during object creation, after setting all properties.
function b_beta2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to b_beta2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in jednoznacnost.
function jednoznacnost_Callback(hObject, eventdata, handles)
% hObject    handle to jednoznacnost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of jednoznacnost
