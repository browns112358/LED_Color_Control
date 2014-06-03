%%%NOTES%%%
%Replot function, called at the end of every callback, which redoes the
%plots in case a change was made to any of the variables. Get rid of the
%plotting from the import buttons.  

function varargout = color_matcher_gui(varargin)
% COLOR_MATCHER_GUI MATLAB code for color_matcher_gui.fig
%      COLOR_MATCHER_GUI, by itself, creates a new COLOR_MATCHER_GUI or raises the existing
%      singleton*.
%
%      H = COLOR_MATCHER_GUI returns the handle to a new COLOR_MATCHER_GUI or the handle to
%      the existing singleton*.
%
%      COLOR_MATCHER_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COLOR_MATCHER_GUI.M with the given input arguments.
%
%      COLOR_MATCHER_GUI('Property','Value',...) creates a new COLOR_MATCHER_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before color_matcher_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to color_matcher_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help color_matcher_gui

% Last Modified by GUIDE v2.5 02-Jun-2014 15:04:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @color_matcher_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @color_matcher_gui_OutputFcn, ...
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


% --- Executes just before color_matcher_gui is made visible.
function color_matcher_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to color_matcher_gui (see VARARGIN)
% Choose default command line output for color_matcher_gui
handles.output = hObject;
handles.LED_active=[];
handles.alpha=[];
handles.match_active=[];

handles.LED_pages=0;
handles.LED_pagenum=0;
set(handles.prev_page,'Enable','off') 
set(handles.next_page,'Enable','off') 

temp=[''];
handles.matching_spectrum_names=cellstr(temp);
handles.clean=1;
handles.match_data=[];
handles.LED_data=[];
handles.Wavelength=350:.5:850;

set(handles.matching_spectrum_popup,'Enable','off')
set(handles.LED1_toggle,'Value',1);
set(handles.LED2_toggle,'Value',1);
set(handles.LED3_toggle,'Value',1);
set(handles.LED4_toggle,'Value',1);
set(handles.LED5_toggle,'Value',1);

set(handles.LED1_toggle,'Visible','off')
set(handles.LED1_text,'Visible','off')
set(handles.LED1_slider,'Visible','off')

set(handles.LED2_toggle,'Visible','off')
set(handles.LED2_text,'Visible','off')
set(handles.LED2_slider,'Visible','off')

set(handles.LED3_toggle,'Visible','off')
set(handles.LED3_text,'Visible','off')
set(handles.LED3_slider,'Visible','off')

set(handles.LED4_toggle,'Visible','off')
set(handles.LED4_text,'Visible','off')
set(handles.LED4_slider,'Visible','off')

set(handles.LED5_toggle,'Visible','off')
set(handles.LED5_text,'Visible','off')
set(handles.LED5_slider,'Visible','off')

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes color_matcher_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = color_matcher_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LED1_toggle.
function LED1_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED1_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LED1_toggle
handles.LED_active(1+handles.LED_pagenum*5)=get(hObject,'Value');

if get(hObject,'Value')==1
    set(handles.LED1_slider,'Enable','on')
    set(handles.LED1_text,'Enable','on')
else
    set(handles.LED1_slider,'Enable','off')  
    set(handles.LED1_text,'Enable','off')    
end
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);


function LED1_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED1_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LED1_text as text
%        str2double(get(hObject,'String')) returns contents of LED1_text as a double
handles.alpha(1+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function LED1_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED1_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function LED1_slider_Callback(hObject, eventdata, handles)
% hObject    handle to LED1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.alpha(1+handles.LED_pagenum*5)=get(hObject,'Value');

set(handles.LED1_slider,'enable','off');
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
set(handles.LED1_slider,'enable','on');

guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function LED1_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in import_LED_pushbutton.
function import_LED_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to import_LED_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Assumes the first column is wavelength and eqach subsequent column is an
%LED spectrum. Limited to 5 LEDs
[filename, pathname]=uigetfile({'*.txt';'*.m';'*.csv';'*.*'});

if ischar(filename) %is a double (0) if cancel is slected or window closed
    FileNameString=fullfile(pathname, filename); %Same as FullFileName
    InputData=importdata(FileNameString);
    tempWave=InputData(:,1);

    for n=2:size(InputData,2)
        handles.LED_active(end+1)=1;
        handles.alpha(end+1)=1;
        data=spline(tempWave,InputData(:,n),handles.Wavelength);

        data(handles.Wavelength < min(tempWave))=0;
        data(handles.Wavelength > max(tempWave))=0;

        handles.LED_data=[handles.LED_data data'];

    end
end
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);


% --- Executes on button press in import_match_pushbutton.
function import_match_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to import_match_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uigetfile({'*.txt';'*.m';'*.csv';'*.*'});

if ischar(filename) %is a double (0) if cancel is slected or window closed
    FileNameString=fullfile(pathname, filename); %Same as FullFileName
    InputData=importdata(FileNameString);
    tempWave=InputData(:,1);

    set(handles.matching_spectrum_popup,'Enable','on')
    
    if handles.clean == 1
        handles.matching_spectrum_names(:,1)=[];
    end

    for n=2:size(InputData,2)
        if size(InputData,2) <= 2
            handles.matching_spectrum_names{1,size(handles.matching_spectrum_names,2)+1}=filename;
        else
            handles.matching_spectrum_names{1,size(handles.matching_spectrum_names,2)+1}=strcat(filename,'---',num2str(n-1));
        end
        if handles.clean==1 && n==2
            handles.match_active(end+1)=1;
        else
            handles.match_active(end+1)=0;            
        end
        data=spline(tempWave,InputData(:,n),handles.Wavelength);

        data(handles.Wavelength < min(tempWave))=0;
        data(handles.Wavelength > max(tempWave))=0;

        handles.match_data=[handles.match_data data'];
    end
    hold off    
    handles.clean=0;

end
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in optimize_coefficients.
function optimize_coefficients_Callback(hObject, eventdata, handles)
% hObject    handle to optimize_coefficients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on LED1_toggle and none of its controls.
function LED1_toggle_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to LED1_toggle (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in matching_spectrum_popup.
function matching_spectrum_popup_Callback(hObject, eventdata, handles)
% hObject    handle to matching_spectrum_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns matching_spectrum_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from matching_spectrum_popup
contents=cellstr(get(hObject,'String'));
handles.match_active(:)=0;
index=find(strcmp(contents{get(hObject,'Value')}, handles.matching_spectrum_names));
handles.match_active(index)=1;

refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function matching_spectrum_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matching_spectrum_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function replot(hObject,eventdata,handles)    
    colors=['k','r','y','g','b','m','c'];
    
    axes(handles.LED_plot)
    cla reset
    
    hold on     
    c=0;
    for n=(1+handles.LED_pagenum*5):min([size(handles.LED_data,2) 5+handles.LED_pagenum*5])
        c=c+1;
        if handles.LED_active(n)==1
            plot(handles.Wavelength,handles.LED_data(:,n),colors(c),'LineWidth',2)
        end
    end
    title('LED Spectra')
    xlabel('Wavelength (nm)')
    ylabel('Response')
    xlim([min(handles.Wavelength) max(handles.Wavelength)])
    hold off
    
    axes(handles.Matching_plot)
    cla reset
    
    hold on     
    for n=1:size(handles.match_data,2)  
        if handles.match_active(n)==1
            plot(handles.Wavelength,handles.match_data(:,n),colors(n),'LineWidth',2)
        end
    end
    alpha_applied=ones(size(handles.Wavelength,2),size(handles.alpha,2));
    for n=1:size(handles.alpha,2)
        if handles.LED_active(n)==1
            alpha_applied(:,n)=handles.LED_data(:,n).*handles.alpha(n);
        else
            alpha_applied(:,n)=0;
        end
    end
    generated=sum(alpha_applied,2);
    plot(handles.Wavelength,generated,'LineWidth',2)

    title('Input Spectrum and Match generated by summing LEDs with multipliers')
    xlabel('Wavelength (nm)')
    ylabel('Response')
    xlim([min(handles.Wavelength) max(handles.Wavelength)])
    hold off

function refresh(hObject,eventdata,handles)
    if size(handles.LED_data,2) > 5
        handles.LED_pages=handles.LED_pages+1;
    end
    
    if handles.LED_pagenum <= 0
        set(handles.prev_page,'Enable','off') 
    else
        set(handles.prev_page,'Enable','on')         
    end

    if size(handles.LED_data,2) < 1+(handles.LED_pagenum+1)*5
       set(handles.next_page,'Enable','off') 
    else
       set(handles.next_page,'Enable','on')         
    end    
    
    set(handles.LED1_toggle,'string',strcat('LED',num2str(1+handles.LED_pagenum*5)))  
    set(handles.LED2_toggle,'string',strcat('LED',num2str(2+handles.LED_pagenum*5)))
    set(handles.LED3_toggle,'string',strcat('LED',num2str(3+handles.LED_pagenum*5)))
    set(handles.LED4_toggle,'string',strcat('LED',num2str(4+handles.LED_pagenum*5)))        
    set(handles.LED5_toggle,'string',strcat('LED',num2str(5+handles.LED_pagenum*5)))
    
    set(handles.matching_spectrum_popup,'string',handles.matching_spectrum_names)
    
    a=size(handles.alpha,2)-mod(size(handles.alpha,2),5);
    b=mod(size(handles.alpha,2),5);
    
    if size(handles.alpha,2) >= 1+handles.LED_pagenum*5
        set(handles.LED1_toggle,'Visible','on')
        set(handles.LED1_text,'Visible','on')
        set(handles.LED1_slider,'Visible','on')        
        set(handles.LED1_text,'string',num2str(handles.alpha(1+handles.LED_pagenum*5)));
        set(handles.LED1_slider,'value',handles.alpha(1+handles.LED_pagenum*5));
    else
        set(handles.LED1_toggle,'Visible','off')
        set(handles.LED1_text,'Visible','off')
        set(handles.LED1_slider,'Visible','off')
    end

    if size(handles.alpha,2) >= 2+handles.LED_pagenum*5
        set(handles.LED2_toggle,'Visible','on')
        set(handles.LED2_text,'Visible','on')
        set(handles.LED2_slider,'Visible','on')        
        set(handles.LED2_text,'string',num2str(handles.alpha(2+handles.LED_pagenum*5)));
        set(handles.LED2_slider,'value',handles.alpha(2+handles.LED_pagenum*5));
    else
        set(handles.LED2_toggle,'Visible','off')
        set(handles.LED2_text,'Visible','off')
        set(handles.LED2_slider,'Visible','off')
    end 
    
    if size(handles.alpha,2) >= 3+handles.LED_pagenum*5
        set(handles.LED3_toggle,'Visible','on')
        set(handles.LED3_text,'Visible','on')
        set(handles.LED3_slider,'Visible','on')        
        set(handles.LED3_text,'string',num2str(handles.alpha(3+handles.LED_pagenum*5)));
        set(handles.LED3_slider,'value',handles.alpha(3+handles.LED_pagenum*5));
    else
        set(handles.LED3_toggle,'Visible','off')
        set(handles.LED3_text,'Visible','off')
        set(handles.LED3_slider,'Visible','off')
    end    
    
    if size(handles.alpha,2) >= 4+handles.LED_pagenum*5
        set(handles.LED4_toggle,'Visible','on')
        set(handles.LED4_text,'Visible','on')
        set(handles.LED4_slider,'Visible','on')        
        set(handles.LED4_text,'string',num2str(handles.alpha(4+handles.LED_pagenum*5)));
        set(handles.LED4_slider,'value',handles.alpha(4+handles.LED_pagenum*5));
    else
        set(handles.LED4_toggle,'Visible','off')
        set(handles.LED4_text,'Visible','off')
        set(handles.LED4_slider,'Visible','off')
    end  
    
    if size(handles.alpha,2) >= 5+handles.LED_pagenum*5
        set(handles.LED5_toggle,'Visible','on')
        set(handles.LED5_text,'Visible','on')
        set(handles.LED5_slider,'Visible','on')        
        set(handles.LED5_text,'string',num2str(handles.alpha(5+handles.LED_pagenum*5)));
        set(handles.LED5_slider,'value',handles.alpha(5+handles.LED_pagenum*5));
    else
        set(handles.LED5_toggle,'Visible','off')
        set(handles.LED5_text,'Visible','off')
        set(handles.LED5_slider,'Visible','off')
    end    
%     for n=1:size(handles.LED_active,2)
%         if n==1 && handles.LED_active(n)==1
%             set(handles.LED1_toggle,'Visible','on')
%             set(handles.LED1_text,'Visible','on')
%             set(handles.LED1_slider,'Visible','on')
%         end
%         if n==2 && handles.LED_active(n)==1
%             set(handles.LED2_toggle,'Visible','on')
%             set(handles.LED2_text,'Visible','on')
%             set(handles.LED2_slider,'Visible','on')
%         end
%         if n==3 && handles.LED_active(n)==1
%             set(handles.LED3_toggle,'Visible','on')
%             set(handles.LED3_text,'Visible','on')
%             set(handles.LED3_slider,'Visible','on')
%         end
%         if n==4 && handles.LED_active(n)==1
%             set(handles.LED4_toggle,'Visible','on')
%             set(handles.LED4_text,'Visible','on')
%             set(handles.LED4_slider,'Visible','on')
%         end
%         if n==5 && handles.LED_active(n)==1
%             set(handles.LED5_toggle,'Visible','on')
%             set(handles.LED5_text,'Visible','on')
%             set(handles.LED5_slider,'Visible','on')
%         end
%    end


% --- Executes on button press in LED2_toggle.
function LED2_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED2_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LED_active(2+handles.LED_pagenum*5)=get(hObject,'Value');

if get(hObject,'Value')==1
    set(handles.LED2_slider,'Enable','on')
    set(handles.LED2_text,'Enable','on')
else
    set(handles.LED2_slider,'Enable','off')  
    set(handles.LED2_text,'Enable','off')    
end

refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED2_toggle



function LED2_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(2+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of LED2_text as text
%        str2double(get(hObject,'String')) returns contents of LED2_text as a double


% --- Executes during object creation, after setting all properties.
function LED2_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function LED2_slider_Callback(hObject, eventdata, handles)
% hObject    handle to LED2_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(2+handles.LED_pagenum*5)=get(hObject,'Value');

set(handles.LED2_slider,'enable','off');
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
set(handles.LED2_slider,'enable','on');

guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function LED2_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED2_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in LED3_toggle.
function LED3_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED3_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LED_active(3+handles.LED_pagenum*5)=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.LED3_slider,'Enable','on')
    set(handles.LED3_text,'Enable','on')
else
    set(handles.LED3_slider,'Enable','off')  
    set(handles.LED3_text,'Enable','off')    
end
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED3_toggle



function LED3_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED3_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(3+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of LED3_text as text
%        str2double(get(hObject,'String')) returns contents of LED3_text as a double


% --- Executes during object creation, after setting all properties.
function LED3_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED3_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function LED3_slider_Callback(hObject, eventdata, handles)
% hObject    handle to LED3_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(3+handles.LED_pagenum*5)=get(hObject,'Value');

set(handles.LED3_slider,'enable','off');
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
set(handles.LED3_slider,'enable','on');

guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function LED3_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED3_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in LED4_toggle.
function LED4_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED4_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LED_active(4+handles.LED_pagenum*5)=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.LED4_slider,'Enable','on')
    set(handles.LED4_text,'Enable','on')
else
    set(handles.LED4_slider,'Enable','off')  
    set(handles.LED4_text,'Enable','off')    
end
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED4_toggle



function LED4_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED4_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(4+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of LED4_text as text
%        str2double(get(hObject,'String')) returns contents of LED4_text as a double


% --- Executes during object creation, after setting all properties.
function LED4_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED4_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function LED4_slider_Callback(hObject, eventdata, handles)
% hObject    handle to LED4_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(4+handles.LED_pagenum*5)=get(hObject,'Value');

set(handles.LED4_slider,'enable','off');
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
set(handles.LED4_slider,'enable','on');

guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function LED4_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED4_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in LED5_toggle.
function LED5_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED5_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LED_active(5+handles.LED_pagenum*5)=get(hObject,'Value');
if get(hObject,'Value')==1
    set(handles.LED5_slider,'Enable','on')
    set(handles.LED5_text,'Enable','on')
else
    set(handles.LED5_slider,'Enable','off')  
    set(handles.LED5_text,'Enable','off')    
end
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED5_toggle



function LED5_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED5_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(5+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hints: get(hObject,'String') returns contents of LED5_text as text
%        str2double(get(hObject,'String')) returns contents of LED5_text as a double


% --- Executes during object creation, after setting all properties.
function LED5_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED5_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function LED5_slider_Callback(hObject, eventdata, handles)
% hObject    handle to LED5_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(5+handles.LED_pagenum*5)=get(hObject,'Value');

set(handles.LED5_slider,'enable','off');
refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);
set(handles.LED5_slider,'enable','on');

guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function LED5_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LED5_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in prev_page.
function prev_page_Callback(hObject, eventdata, handles)
% hObject    handle to prev_page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LED_pagenum=handles.LED_pagenum-1;

refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);

guidata(hObject, handles);
% --- Executes on button press in next_page.
function next_page_Callback(hObject, eventdata, handles)
% hObject    handle to next_page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LED_pagenum=handles.LED_pagenum+1;

refresh(hObject,eventdata,handles);
replot(hObject,eventdata,handles);

guidata(hObject, handles);