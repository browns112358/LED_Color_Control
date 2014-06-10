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

% Last Modified by GUIDE v2.5 09-Jun-2014 15:47:50

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

handles.xyY_bg=imread('xyYaxes3.png');
handles.xyY_bg=flipdim(handles.xyY_bg,1);

handles.LUV_bg=imread('LUVaxes2.png');
handles.LUV_bg=flipdim(handles.LUV_bg,1);

handles.Lab_bg=imread('LUVaxes2.png');
handles.Lab_bg=flipdim(handles.Lab_bg,1);

handles.UVW_bg=imread('xyYaxes3.png');
handles.UVW_bg=flipdim(handles.LUV_bg,1);

handles.CIE_space='xyY';

handles.output = hObject;
handles.LED_active=[];
handles.alpha=[];
handles.generated=[];
handles.match_active=[];

handles.LED_pages=0;
handles.LED_pagenum=0;
set(handles.prev_page,'Enable','off') 
set(handles.next_page,'Enable','off')
set(handles.optimize_coefficients,'Enable','off') 

temp=[''];
handles.matching_spectrum_names=cellstr(temp);

options=cellstr([
    'Least-Squares Spectrum Match';
    'CCT Match                   ';
    'Maximized CRI               ']);
set(handles.optimize_options,'string',options);
handles.optimize_type='Least-Squares Spectrum Match';

handles.clean=1;
handles.match_data=[];
handles.LED_data=[];

handles.Wavelength=350:.5:850;

cmf=importdata('xyz_cmf.txt');
xcmf=spline(cmf(:,1),cmf(:,2),handles.Wavelength);
xcmf(handles.Wavelength < min(cmf(:,1)))=0;
xcmf(handles.Wavelength > max(cmf(:,1)))=0;

ycmf=spline(cmf(:,1),cmf(:,3),handles.Wavelength);
ycmf(handles.Wavelength < min(cmf(:,1)))=0;
ycmf(handles.Wavelength > max(cmf(:,1)))=0;

zcmf=spline(cmf(:,1),cmf(:,4),handles.Wavelength);
zcmf(handles.Wavelength < min(cmf(:,1)))=0;
zcmf(handles.Wavelength > max(cmf(:,1)))=0;

handles.xcmf=xcmf;
handles.ycmf=ycmf;
handles.zcmf=zcmf;

%[ideal generated]
handles.X=[0 0];
handles.Y=[0 0];
handles.Z=[0 0]; 

handles.x=[0 0];
handles.y=[0 0];

handles.u=[0 0];
handles.v=[0 0];

set(handles.matching_spectrum_popup,'Enable','off')
set(handles.LED1_toggle,'Value',1);
set(handles.LED2_toggle,'Value',1);
set(handles.LED3_toggle,'Value',1);
set(handles.LED4_toggle,'Value',1);
set(handles.LED5_toggle,'Value',1);

set(handles.range1,'Value',1);
handles.max_alpha=1;

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

% Set the colors indicating a selected/unselected tab
handles.unselectedTabColor=get(handles.tab1text,'BackgroundColor');
handles.selectedTabColor=handles.unselectedTabColor-0.1;

set(handles.tab1text,'Visible','off') 
set(handles.tab2text,'Visible','off') 
set(handles.tab3text,'Visible','off') 

% Set units to normalize for easier handling
set(handles.tab1text,'Units','normalized')
set(handles.tab2text,'Units','normalized')
set(handles.tab3text,'Units','normalized')
set(handles.tab1Panel,'Units','normalized')
set(handles.tab2Panel,'Units','normalized')
set(handles.tab3Panel,'Units','normalized')

% Tab 1
pos1=get(handles.tab1text,'Position');
handles.a1=axes('Units','normalized',...
                'Box','on',...
                'XTick',[],...
                'YTick',[],...
                'Color',handles.selectedTabColor,...
                'Position',[pos1(1) pos1(2) pos1(3) pos1(4)+0.01],...
                'ButtonDownFcn','color_matcher_gui(''a1bd'',gcbo,[],guidata(gcbo))');
handles.t1=text('String','Spectrum Setup',...
                'Units','normalized',...
                'Position',[(pos1(3)-pos1(1))/2,pos1(2)/2+pos1(4)],...
                'HorizontalAlignment','left',...
                'VerticalAlignment','middle',...
                'Margin',0.001,...
                'FontSize',8,...
                'Backgroundcolor',handles.selectedTabColor,...
                'ButtonDownFcn','color_matcher_gui(''t1bd'',gcbo,[],guidata(gcbo))');

% Tab 2
pos2=get(handles.tab2text,'Position');
pos2(1)=pos1(1)+pos1(3);
handles.a2=axes('Units','normalized',...
                'Box','on',...
                'XTick',[],...
                'YTick',[],...
                'Color',handles.unselectedTabColor,...
                'Position',[pos2(1) pos2(2) pos2(3) pos2(4)+0.01],...
                'ButtonDownFcn','color_matcher_gui(''a2bd'',gcbo,[],guidata(gcbo))');
handles.t2=text('String','CIE Color Spaces',...
                'Units','normalized',...
                'Position',[pos2(3)/2,pos2(2)/2+pos2(4)],...
                'HorizontalAlignment','left',...
                'VerticalAlignment','middle',...
                'Margin',0.001,...
                'FontSize',8,...
                'Backgroundcolor',handles.unselectedTabColor,...
                'ButtonDownFcn','color_matcher_gui(''t2bd'',gcbo,[],guidata(gcbo))');
           
% Tab 3 
pos3=get(handles.tab3text,'Position');
pos3(1)=pos2(1)+pos2(3);
handles.a3=axes('Units','normalized',...
                'Box','on',...
                'XTick',[],...
                'YTick',[],...
                'Color',handles.unselectedTabColor,...
                'Position',[pos3(1) pos3(2) pos3(3) pos3(4)+0.01],...
                'ButtonDownFcn','color_matcher_gui(''a3bd'',gcbo,[],guidata(gcbo))');
handles.t3=text('String','Background',...
                'Units','normalized',...
                'Position',[pos3(3)/2,pos3(2)/2+pos3(4)],...
                'HorizontalAlignment','left',...
                'VerticalAlignment','middle',...
                'Margin',0.001,...
                'FontSize',8,...
                'Backgroundcolor',handles.unselectedTabColor,...
                'ButtonDownFcn','color_matcher_gui(''t3bd'',gcbo,[],guidata(gcbo))');
            
% Manage panels (place them in the correct position and manage visibilities)
pan1pos=get(handles.tab1Panel,'Position');
set(handles.tab2Panel,'Position',pan1pos)
set(handles.tab3Panel,'Position',pan1pos)
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')

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

% Text object 1 callback (tab 1)
function t1bd(hObject,eventdata,handles)

set(hObject,'BackgroundColor',handles.selectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.a1,'Color',handles.selectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.tab1Panel,'Visible','on')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')

% Text object 2 callback (tab 2)
function t2bd(hObject,eventdata,handles)

set(hObject,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.a2,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.tab2Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')

% Text object 3 callback (tab 3)
function t3bd(hObject,eventdata,handles)

set(hObject,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.a3,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.tab3Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab2Panel,'Visible','off')

% Axes object 1 callback (tab 1)
function a1bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.t1,'BackgroundColor',handles.selectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.tab1Panel,'Visible','on')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')

% Axes object 2 callback (tab 2)
function a2bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.tab2Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')

% Axes object 3 callback (tab 3)
function a3bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.tab3Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab2Panel,'Visible','off')

% --- Executes on button press in LED1_toggle.
function LED1_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED1_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LED1_toggle
handles.LED_active(1+handles.LED_pagenum*5)=get(hObject,'Value');

% if get(hObject,'Value')==1
%     set(handles.LED1_slider,'Enable','on')
%     set(handles.LED1_text,'Enable','on')
% else
%     set(handles.LED1_slider,'Enable','off')  
%     set(handles.LED1_text,'Enable','off')    
% end
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);


function LED1_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED1_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LED1_text as text
%        str2double(get(hObject,'String')) returns contents of LED1_text as a double
handles.alpha(1+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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
        set(handles.optimize_coefficients,'Enable','on') 
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
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function [f] = objfun(x)
    R=[];
    for n=1:size(handles.LED_data,2)
        if handles.LED_active(n)==1
            R=[R handles.LED_data(:,n)];
        end
    end
    s=handles.match_data(:,handles.match_active==1);
    f=sum((s-x(1)*R(:,1)-x(2)*R(:,2)-x(3)*R(:,3)-x(4)*R(:,4)-x(5)*R(:,5)).^2);



% --- Executes on button press in optimize_coefficients.
function optimize_coefficients_Callback(hObject, eventdata, handles)
% hObject    handle to optimize_coefficients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.optimize_type,'Least-Squares Spectrum Match')==1 && handles.max_alpha==1
    
end
if strcmp(handles.optimize_type,'Least-Squares Spectrum Match')==1 && handles.max_alpha==100
%     R=[];
%     for n=1:size(handles.LED_data,2)
%         if handles.LED_active(n)==1
%             R=[R handles.LED_data(:,n)];
%         end
%     end
%     %index=find(handles.match_active)
%     s=handles.match_data(:,handles.match_active==1);
%     alpha_temp=lsqnonneg(R,s);

%     options = optimoptions('fmincon','GradObj','off');
%     [x,fval]=fmincon('objfun',x0,[],[],[],[],[0 0 0 0 0],[100 100 100 100 100]);
    i=1;
    for n=1:size(handles.LED_active,2)
        if handles.LED_active(n)==1
            handles.alpha(n)=alpha_temp(i);
            i=i+1;
        end
    end
end
if strcmp(handles.optimize_type,'CCT Match')==1
    
end
if strcmp(handles.optimize_type,'Maximized CRI')==1
    
end
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

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

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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

function [handles]=replot(hObject,eventdata,handles)
    colors=['k','r','y','g','c','m','b'];
    
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
    %xlabel('Wavelength (nm)')
    ylabel('Spectral Power Distribution')
    xlim([min(handles.Wavelength) max(handles.Wavelength)])
    hold off
    
    axes(handles.Matching_plot)
    cla reset
    
    hold on     
    for n=1:size(handles.match_data,2)  
        if handles.match_active(n)==1
            plot(handles.Wavelength,handles.match_data(:,n),'k','LineWidth',2)
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
    plot(handles.Wavelength,generated,'b','LineWidth',2)

    title('Ideal and Generated Spectra')
    xlabel('Wavelength (nm)')
    ylabel('Spectral Power Distribution')
    xlim([min(handles.Wavelength) max(handles.Wavelength)])
    hold off
    
if strcmp(handles.CIE_space,'xyY')==1
    set(handles.xyY_plot,'Visible','On')
    set(handles.LUV_plot,'Visible','Off')
    set(handles.Lab_plot,'Visible','Off')
    set(handles.UVW_plot,'Visible','Off')
    
    axes(handles.xyY_plot)
    cla reset
    
    hold on
    imagesc([0 .8],[0 .9],handles.xyY_bg)
    xlim([0 .8])
    ylim([0 .9])
    scatter(handles.x(1),handles.y(1),70,'k','fill')
    scatter(handles.x(2),handles.y(2),70,'k','v','fill')
    
    legend('Ideal','Generated')
    xlabel('x')
    ylabel('y')
    hold off
    
end
if strcmp(handles.CIE_space,'LUV')==1
    set(handles.xyY_plot,'Visible','Off')
    set(handles.LUV_plot,'Visible','On')
    set(handles.Lab_plot,'Visible','Off')
    set(handles.UVW_plot,'Visible','Off')
    
    axes(handles.LUV_plot)
    cla reset
    
    hold on
    imagesc([0 .63],[0 .6],handles.LUV_bg)
    xlim([0 .63])
    ylim([0 .6])
    scatter(handles.u(1),handles.v(1),70,'k','fill')
    scatter(handles.u(2),handles.v(2),70,'k','v','fill')
    
    legend('Ideal','Generated')
    xlabel('u')
    ylabel('v')
    hold off
end

if strcmp(handles.CIE_space,'Lab')==1
    set(handles.xyY_plot,'Visible','Off')
    set(handles.LUV_plot,'Visible','Off')
    set(handles.Lab_plot,'Visible','On')
    set(handles.UVW_plot,'Visible','Off')
    
    axes(handles.Lab_plot)
    cla reset
end

if strcmp(handles.CIE_space,'UVW')==1
    
    set(handles.xyY_plot,'Visible','Off')
    set(handles.LUV_plot,'Visible','Off')
    set(handles.Lab_plot,'Visible','Off')
    set(handles.UVW_plot,'Visible','On')
    
    axes(handles.UVW_plot)
    cla reset

end
    
    

function [handles]=refresh(hObject,eventdata,handles)

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
       
    if size(handles.match_data) >= 1
        s=handles.match_data(:,handles.match_active==1);
        s=s';
        handles.X(1)=sum(handles.xcmf.*s)/size(s,2);
        handles.Y(1)=sum(handles.ycmf.*s)/size(s,2);
        handles.Z(1)=sum(handles.zcmf.*s)/size(s,2);

        handles.x(1)=handles.X(1)/(handles.X(1)+handles.Y(1)+handles.Z(1));
        handles.y(1)=handles.Y(1)/(handles.X(1)+handles.Y(1)+handles.Z(1));

        handles.u(1)=4*handles.X(1)/(handles.X(1)+15*handles.Y(1)+3*handles.Z(1));
        handles.v(1)=9*handles.Y(1)/(handles.X(1)+15*handles.Y(1)+3*handles.Z(1));        
    end
    
    if size(handles.LED_data) >= 1
        alpha_applied=ones(size(handles.Wavelength,2),size(handles.alpha,2));
        for n=1:size(handles.alpha,2)
            if handles.LED_active(n)==1
                alpha_applied(:,n)=handles.LED_data(:,n).*handles.alpha(n);
            else
                alpha_applied(:,n)=0;
            end
        end
        handles.generated=sum(alpha_applied,2);        
        handles.generated=handles.generated';

        handles.X(2)=sum(handles.xcmf.*handles.generated)/size(handles.generated,2);
        handles.Y(2)=sum(handles.ycmf.*handles.generated)/size(handles.generated,2);
        handles.Z(2)=sum(handles.zcmf.*handles.generated)/size(handles.generated,2);
        
        handles.x(2)=handles.X(2)/(handles.X(2)+handles.Y(2)+handles.Z(2));
        handles.y(2)=handles.Y(2)/(handles.X(2)+handles.Y(2)+handles.Z(2));

        handles.u(2)=4*handles.X(2)/(handles.X(2)+15*handles.Y(2)+3*handles.Z(2));
        handles.v(2)=9*handles.Y(2)/(handles.X(2)+15*handles.Y(2)+3*handles.Z(2));       
    end
    
    if strcmp(handles.CIE_space,'xyY')==1
        rowNames={'X','Y','Z','x','y'};
        CIE_table_data={
          handles.X(1) handles.X(2); handles.Y(1) handles.Y(2);...
          handles.Z(1) handles.Z(2); handles.x(1) handles.x(2);...
          handles.y(1) handles.y(2)};

        set(handles.CIE_table,'Data',CIE_table_data)  
        set(handles.CIE_table,'RowName',rowNames)
    end
    if strcmp(handles.CIE_space,'LUV')==1
        rowNames={'X','Y','Z','u','v','L'};
        CIE_table_data={
        handles.X(1) handles.X(2); handles.Y(1) handles.Y(2);...
        handles.Z(1) handles.Z(2); handles.u(1) handles.u(2);...
        handles.v(1) handles.v(2)};
  
        set(handles.CIE_table,'RowName',rowNames)
        set(handles.CIE_table,'Data',CIE_table_data)
    end
    if strcmp(handles.CIE_space,'Lab')==1
        rowNames={'X','Y','Z','a','b','L'};
        CIE_table_data={
        handles.X(1) handles.X(2); handles.Y(1) handles.Y(2);...
        handles.Z(1) handles.Z(2)};
  
        set(handles.CIE_table,'RowName',rowNames)
        set(handles.CIE_table,'Data',CIE_table_data)        
    end
    if strcmp(handles.CIE_space,'UVW')==1
        rowNames={'X','Y','Z','u','v','W'};
        CIE_table_data={
        handles.X(1) handles.X(2); handles.Y(1) handles.Y(2);...
        handles.Z(1) handles.Z(2)};
  
        set(handles.CIE_table,'RowName',rowNames)
        set(handles.CIE_table,'Data',CIE_table_data)        
    end    
    
    for n=1:size(handles.alpha,2)
        if handles.alpha(n) < 0
           handles.alpha(n)=0; 
        end
        if handles.alpha(n) > 1 && handles.max_alpha==1
           handles.alpha(n)=1; 
        end
    end

    %'k','r','y','g','b'    
    
    set(handles.matching_spectrum_popup,'string',handles.matching_spectrum_names)
        
    if size(handles.alpha,2) >= 1+handles.LED_pagenum*5
        set(handles.LED1_toggle,'Visible','on')
        set(handles.LED1_text,'Visible','on')
        set(handles.LED1_slider,'Visible','on')        
        set(handles.LED1_text,'string',num2str(handles.alpha(1+handles.LED_pagenum*5)));
        set(handles.LED1_slider,'value',handles.alpha(1+handles.LED_pagenum*5));
                
        set(handles.LED1_toggle,'string',num2str(1+handles.LED_pagenum*5));
        set(handles.LED1_toggle,'value',handles.LED_active(1+handles.LED_pagenum*5));

        if handles.LED_active(1+handles.LED_pagenum*5)==1
            set(handles.LED1_slider,'Enable','on')
            set(handles.LED1_text,'Enable','on')
        else
            set(handles.LED1_slider,'Enable','off')  
            set(handles.LED1_text,'Enable','off')    
        end
        
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
        
        set(handles.LED2_toggle,'string',num2str(2+handles.LED_pagenum*5))
        set(handles.LED2_toggle,'value',handles.LED_active(2+handles.LED_pagenum*5)) 
        
        if handles.LED_active(2+handles.LED_pagenum*5)==1
            set(handles.LED2_slider,'Enable','on')
            set(handles.LED2_text,'Enable','on')
        else
            set(handles.LED2_slider,'Enable','off')  
            set(handles.LED2_text,'Enable','off')    
        end
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
        
        set(handles.LED3_toggle,'string',num2str(3+handles.LED_pagenum*5))
        set(handles.LED3_toggle,'value',handles.LED_active(3+handles.LED_pagenum*5))
        
        if handles.LED_active(3+handles.LED_pagenum*5)==1
            set(handles.LED3_slider,'Enable','on')
            set(handles.LED3_text,'Enable','on')
        else
            set(handles.LED3_slider,'Enable','off')  
            set(handles.LED3_text,'Enable','off')    
        end
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
        
        set(handles.LED4_toggle,'string',num2str(4+handles.LED_pagenum*5))
        set(handles.LED4_toggle,'value',handles.LED_active(4+handles.LED_pagenum*5))
        
        if handles.LED_active(4+handles.LED_pagenum*5)==1
            set(handles.LED4_slider,'Enable','on')
            set(handles.LED4_text,'Enable','on')
        else
            set(handles.LED4_slider,'Enable','off')  
            set(handles.LED4_text,'Enable','off')    
        end
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
        
        set(handles.LED5_toggle,'string',num2str(5+handles.LED_pagenum*5))
        set(handles.LED5_toggle,'value',handles.LED_active(5+handles.LED_pagenum*5)) 
        
        if handles.LED_active(5+handles.LED_pagenum*5)==1
            set(handles.LED5_slider,'Enable','on')
            set(handles.LED5_text,'Enable','on')
        else
            set(handles.LED5_slider,'Enable','off')  
            set(handles.LED5_text,'Enable','off')    
        end
    else
        set(handles.LED5_toggle,'Visible','off')
        set(handles.LED5_text,'Visible','off')
        set(handles.LED5_slider,'Visible','off')
    end

    




% --- Executes on button press in LED2_toggle.
function LED2_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to LED2_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LED_active(2+handles.LED_pagenum*5)=get(hObject,'Value');

% if get(hObject,'Value')==1
%     set(handles.LED2_slider,'Enable','on')
%     set(handles.LED2_text,'Enable','on')
% else
%     set(handles.LED2_slider,'Enable','off')  
%     set(handles.LED2_text,'Enable','off')    
% end

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED2_toggle



function LED2_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED2_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(2+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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
% if get(hObject,'Value')==1
%     set(handles.LED3_slider,'Enable','on')
%     set(handles.LED3_text,'Enable','on')
% else
%     set(handles.LED3_slider,'Enable','off')  
%     set(handles.LED3_text,'Enable','off')    
% end
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED3_toggle



function LED3_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED3_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(3+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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
% if get(hObject,'Value')==1
%     set(handles.LED4_slider,'Enable','on')
%     set(handles.LED4_text,'Enable','on')
% else
%     set(handles.LED4_slider,'Enable','off')  
%     set(handles.LED4_text,'Enable','off')    
% end
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED4_toggle



function LED4_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED4_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(4+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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
% if get(hObject,'Value')==1
%     set(handles.LED5_slider,'Enable','on')
%     set(handles.LED5_text,'Enable','on')
% else
%     set(handles.LED5_slider,'Enable','off')  
%     set(handles.LED5_text,'Enable','off')    
% end
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LED5_toggle



function LED5_text_Callback(hObject, eventdata, handles)
% hObject    handle to LED5_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.alpha(5+handles.LED_pagenum*5)=str2double(get(hObject,'String'));

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
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

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);

guidata(hObject, handles);
% --- Executes on button press in next_page.
function next_page_Callback(hObject, eventdata, handles)
% hObject    handle to next_page (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.LED_pagenum=handles.LED_pagenum+1;

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);

guidata(hObject, handles);


% --- Executes on button press in range1.
function range1_Callback(hObject, eventdata, handles)
% hObject    handle to range1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of range1
if get(hObject,'Value')==1
    set(handles.range2,'Value',0);
    
    set(handles.LED1_slider,'max',1);
    set(handles.LED2_slider,'max',1);
    set(handles.LED3_slider,'max',1);
    set(handles.LED4_slider,'max',1);
    set(handles.LED5_slider,'max',1);

else
    set(handles.range2,'Value',1);
    set(handles.LED1_slider,'max',100);
    set(handles.LED2_slider,'max',100);
    set(handles.LED3_slider,'max',100);
    set(handles.LED4_slider,'max',100);
    set(handles.LED5_slider,'max',100);    
end

handles.max_alpha=1;
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);

guidata(hObject, handles);

% --- Executes on button press in range2.
function range2_Callback(hObject, eventdata, handles)
% hObject    handle to range2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')==1
    set(handles.range1,'Value',0);
    set(handles.LED1_slider,'max',100);
    set(handles.LED2_slider,'max',100);
    set(handles.LED3_slider,'max',100);
    set(handles.LED4_slider,'max',100);
    set(handles.LED5_slider,'max',100);
else
    set(handles.range1,'Value',1);
    set(handles.LED1_slider,'max',1);
    set(handles.LED2_slider,'max',1);
    set(handles.LED3_slider,'max',1);
    set(handles.LED4_slider,'max',1);
    set(handles.LED5_slider,'max',1);    
end

handles.max_alpha=100; %actually no limit

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);

guidata(hObject, handles);

% Hint: get(hObject,'Value') returns toggle state of range2


% --- Executes on selection change in optimize_options.
function optimize_options_Callback(hObject, eventdata, handles)
% hObject    handle to optimize_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns optimize_options contents as cell array
%        contents{get(hObject,'Value')} returns selected item from optimize_options
contents = cellstr(get(hObject,'String'));
handles.optimize_type=contents{get(hObject,'Value')};
    
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function optimize_options_CreateFcn(hObject, eventdata, handles)
% hObject    handle to optimize_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CIE_popup.
function CIE_popup_Callback(hObject, eventdata, handles)
% hObject    handle to CIE_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CIE_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CIE_popup

contents = cellstr(get(hObject,'String'));
handles.CIE_space=contents{get(hObject,'Value')};

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function CIE_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CIE_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
