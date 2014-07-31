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

% Last Modified by GUIDE v2.5 15-Jul-2014 13:38:45

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

%set up graphics for CIE Color spaces
handles.xyY_bg=imread('RequiredData/xyYaxes.png');
handles.xyY_bg=flipdim(handles.xyY_bg,1);

handles.LUV_bg=imread('RequiredData/LUVaxes.png');
handles.LUV_bg=flipdim(handles.LUV_bg,1);

handles.slider_holding=0;

%Set up LED/Ideal control variables
%alpha refers to the multipliers
handles.ideal_multiplier=[];
handles.output = hObject;
handles.LED_active=[];
handles.alpha=[];
handles.generated=[];
handles.match_active=[];
handles.LED_lux=[];
handles.Ideal_lux=[];
handles.match_data=[];
handles.LED_data=[];
handles.Wavelength=380:1:780;
handles.max_alpha=1;
handles.normalize=0;

%Set up page system
handles.LED_pages=0;
handles.LED_pagenum=0;
set(handles.prev_page,'Enable','off') 
set(handles.next_page,'Enable','off')

%set up popup menus and other lists
options={'xyY';
         'LUV';
         'Lab';
         'UVW';
         'RGB'};
set(handles.CIE_popup,'string',options);
handles.CIE_space='xyY';
     
temp=[''];
handles.matching_spectrum_names=cellstr(temp);
handles.clean=1;

options={
    'Least-Squares Spectrum Match';
    'Least-Squares RGB Match' 
    'Minimized LUV dE';
    'Minimized Lab dE76'};
set(handles.optimize_options,'string',options);
handles.optimize_type='Least-Squares Spectrum Match';

options={
    'Spectral Power (W/m)   ';
    'Unknown (Lux available)'};
set(handles.units_popup,'string',options);
handles.unit_type='Spectral Power (W/m)';
handles.current_unit_type='Spectral Power (W/m)';
set(handles.current_unit_text,'string',handles.current_unit_type) 

%Import and set up required data for calculations
temp=importdata('RequiredData/illuminants_xy_2deg.txt');
handles.illuminant_data_xy_2deg=temp.data;
handles.illuminant_names=temp.rowheaders;

handles.standard_illuminant=[0.44757 0.40745];
set(handles.reference_illuminant_popup,'string',handles.illuminant_names);

temp=importdata('RequiredData/illuminants_xy_10deg.txt');
handles.illuminant_data_xy_10deg=temp.data;

load RequiredData/DSPD.mat
handles.DSPD=DSPD;
load RequiredData/CIETCS1nm.mat
handles.CIETCS1nm=CIETCS1nm;

temp=handles.Wavelength';
for i=2:size(handles.DSPD,2)
    data=spline(handles.DSPD(:,1),handles.DSPD(:,i),handles.Wavelength);
    data(handles.Wavelength < min(handles.DSPD(:,1)))=0;
    data(handles.Wavelength > max(handles.DSPD(:,1)))=0;
    temp=[temp data'];
end
handles.DSPD=temp;

temp=handles.Wavelength';
for i=2:size(handles.CIETCS1nm,2)
    data=spline(handles.CIETCS1nm(:,1),handles.CIETCS1nm(:,i),handles.Wavelength);
    data(handles.Wavelength < min(handles.CIETCS1nm(:,1)))=0;
    data(handles.Wavelength > max(handles.CIETCS1nm(:,1)))=0;
    temp=[temp data'];
end
handles.CIETCS1nm=temp;

%3 columns: kelvin, u, v with 1 kelvin resolution. Credit pspectro 
load RequiredData/uvbbCCT.mat
handles.uvbbCCT=uvbbCCT;
%handles.uvbbCCT=importdata('RequiredData/uvbbCCT.txt');

%http://www.cvrl.org/cmfs.htm
%cmf=importdata('RequiredData/xyz_cmf_2deg.txt');
load RequiredData/cie1931xyz1nm.mat
cmf=cie1931xyz1nm;

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

%Set up color space data variables
%[ideal generated]
handles.cct=[0 0];

handles.X=[0 0];
handles.Y=[0 0];
handles.Z=[0 0]; 

handles.R=[0 0];
handles.G=[0 0];
handles.B=[0 0];

handles.RGB_brightness_mod=[0 0];

handles.RGB_mat=[ 2.0413690 -0.5649464 -0.3446944;
                 -0.9692660  1.8760108  0.0415560;
                  0.0134474 -0.1183897  1.0154096];

handles.x=[0 0];
handles.y=[0 0];
handles.z=[0 0];

handles.LUV_u_prime=[0 0];
handles.LUV_v_prime=[0 0];
handles.LUV_u=[0 0];
handles.LUV_v=[0 0];
handles.LUV_L=[0 0];

handles.UVW_u=[0 0];
handles.UVW_v=[0 0];

handles.W=[0 0];

handles.Lab_L=[0 0];
handles.a=[0 0];
handles.b=[0 0];

handles.LUV_dE=-1;
handles.dE76=-1;
handles.dE94=-1;
handles.dE00=-1;

handles.CRI=[0 0];

%initialize button states
set(handles.optimize_coefficients,'Enable','off') 
set(handles.matching_spectrum_popup,'Enable','off')
set(handles.LED1_toggle,'Value',1);
set(handles.LED2_toggle,'Value',1);
set(handles.LED3_toggle,'Value',1);
set(handles.LED4_toggle,'Value',1);
set(handles.LED5_toggle,'Value',1);
set(handles.range1,'Value',1);

%set(handles.range1,'Visible','off')
%set(handles.range2,'Visible','off')

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
set(handles.tab4text,'Visible','off') 
set(handles.tab5text,'Visible','off') 
set(handles.tab6text,'Visible','off') 

% Set units to normalize for easier handling
set(handles.tab1text,'Units','normalized')
set(handles.tab2text,'Units','normalized')
set(handles.tab3text,'Units','normalized')
set(handles.tab4text,'Units','normalized')
set(handles.tab5text,'Units','normalized')
set(handles.tab6text,'Units','normalized')

set(handles.tab1Panel,'Units','normalized')
set(handles.tab2Panel,'Units','normalized')
set(handles.tab3Panel,'Units','normalized')
set(handles.tab4Panel,'Units','normalized')
set(handles.tab5Panel,'Units','normalized')
set(handles.tab6Panel,'Units','normalized')

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
handles.t2=text('String','Color Spaces',...
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
handles.t3=text('String','LED Design',...
                'Units','normalized',...
                'Position',[pos3(3)/2,pos3(2)/2+pos3(4)],...
                'HorizontalAlignment','left',...
                'VerticalAlignment','middle',...
                'Margin',0.001,...
                'FontSize',8,...
                'Backgroundcolor',handles.unselectedTabColor,...
                'ButtonDownFcn','color_matcher_gui(''t3bd'',gcbo,[],guidata(gcbo))');

% Tab 4 
pos4=get(handles.tab4text,'Position');
pos4(1)=pos3(1)+pos3(3);
handles.a4=axes('Units','normalized',...
                'Box','on',...
                'XTick',[],...
                'YTick',[],...
                'Color',handles.unselectedTabColor,...
                'Position',[pos4(1) pos4(2) pos4(3) pos4(4)+0.01],...
                'ButtonDownFcn','color_matcher_gui(''a4bd'',gcbo,[],guidata(gcbo))');
handles.t4=text('String','Help',...
                'Units','normalized',...
                'Position',[pos4(3)/2,pos4(2)/2+pos4(4)],...
                'HorizontalAlignment','left',...
                'VerticalAlignment','middle',...
                'Margin',0.001,...
                'FontSize',8,...
                'Backgroundcolor',handles.unselectedTabColor,...
                'ButtonDownFcn','color_matcher_gui(''t4bd'',gcbo,[],guidata(gcbo))');            

% Tab 5 
pos5=get(handles.tab5text,'Position');
pos5(1)=pos4(1)+pos4(3);
handles.a5=axes('Units','normalized',...
                'Box','on',...
                'XTick',[],...
                'YTick',[],...
                'Color',handles.unselectedTabColor,...
                'Position',[pos5(1) pos5(2) pos5(3) pos5(4)+0.01],...
                'ButtonDownFcn','color_matcher_gui(''a5bd'',gcbo,[],guidata(gcbo))');
handles.t5=text('String','tab5',...
                'Units','normalized',...
                'Position',[pos5(3)/2,pos5(2)/2+pos5(4)],...
                'HorizontalAlignment','left',...
                'VerticalAlignment','middle',...
                'Margin',0.001,...
                'FontSize',8,...
                'Backgroundcolor',handles.unselectedTabColor,...
                'ButtonDownFcn','color_matcher_gui(''t5bd'',gcbo,[],guidata(gcbo))');            

% Tab 6 
pos6=get(handles.tab6text,'Position');
pos6(1)=pos5(1)+pos5(3);
handles.a6=axes('Units','normalized',...
                'Box','on',...
                'XTick',[],...
                'YTick',[],...
                'Color',handles.unselectedTabColor,...
                'Position',[pos6(1) pos6(2) pos6(3) pos6(4)+0.01],...
                'ButtonDownFcn','color_matcher_gui(''a6bd'',gcbo,[],guidata(gcbo))');
handles.t6=text('String','tab6',...
                'Units','normalized',...
                'Position',[pos6(3)/2,pos6(2)/2+pos6(4)],...
                'HorizontalAlignment','left',...
                'VerticalAlignment','middle',...
                'Margin',0.001,...
                'FontSize',8,...
                'Backgroundcolor',handles.unselectedTabColor,...
                'ButtonDownFcn','color_matcher_gui(''t6bd'',gcbo,[],guidata(gcbo))');            
            
% Manage panels (place them in the correct position and manage visibilities)
pan1pos=get(handles.tab1Panel,'Position');
set(handles.tab2Panel,'Position',pan1pos)
set(handles.tab3Panel,'Position',pan1pos)
set(handles.tab4Panel,'Position',pan1pos)
set(handles.tab5Panel,'Position',pan1pos)
set(handles.tab6Panel,'Position',pan1pos)
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

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
set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
set(handles.t6,'BackgroundColor',handles.unselectedTabColor)

set(handles.a1,'Color',handles.selectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.a4,'Color',handles.unselectedTabColor)
set(handles.a5,'Color',handles.unselectedTabColor)
set(handles.a6,'Color',handles.unselectedTabColor)

set(handles.tab1Panel,'Visible','on')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

% Text object 2 callback (tab 2)
function t2bd(hObject,eventdata,handles)

set(hObject,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
set(handles.t6,'BackgroundColor',handles.unselectedTabColor)

set(handles.a2,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.a4,'Color',handles.unselectedTabColor)
set(handles.a5,'Color',handles.unselectedTabColor)
set(handles.a6,'Color',handles.unselectedTabColor)

set(handles.tab2Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

handles=replot_color_space(hObject,eventdata,handles);
guidata(hObject, handles);

% Text object 3 callback (tab 3)
function t3bd(hObject,eventdata,handles)

set(hObject,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
set(handles.t6,'BackgroundColor',handles.unselectedTabColor)

set(handles.a3,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a4,'Color',handles.unselectedTabColor)
set(handles.a5,'Color',handles.unselectedTabColor)
set(handles.a6,'Color',handles.unselectedTabColor)

set(handles.tab3Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab2Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

% Text object 4 callback (tab 4)
function t4bd(hObject,eventdata,handles)

set(hObject,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
set(handles.t6,'BackgroundColor',handles.unselectedTabColor)

set(handles.a4,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.a5,'Color',handles.unselectedTabColor)
set(handles.a6,'Color',handles.unselectedTabColor)

set(handles.tab4Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

% Text object 5 callback (tab 5)
function t5bd(hObject,eventdata,handles)

set(hObject,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
set(handles.t6,'BackgroundColor',handles.unselectedTabColor)

set(handles.a5,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.a4,'Color',handles.unselectedTabColor)
set(handles.a6,'Color',handles.unselectedTabColor)

set(handles.tab5Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

% Text object 6 callback (tab 6)
function t6bd(hObject,eventdata,handles)

set(hObject,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
set(handles.t5,'BackgroundColor',handles.unselectedTabColor)

set(handles.a6,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.a4,'Color',handles.unselectedTabColor)
set(handles.a5,'Color',handles.unselectedTabColor)

set(handles.tab6Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')

% Axes object 1 callback (tab 1)
function a1bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.a4,'Color',handles.unselectedTabColor)
set(handles.a5,'Color',handles.unselectedTabColor)
set(handles.a6,'Color',handles.unselectedTabColor)

set(handles.t1,'BackgroundColor',handles.selectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
set(handles.t6,'BackgroundColor',handles.unselectedTabColor)

set(handles.tab1Panel,'Visible','on')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

% Axes object 2 callback (tab 2)
function a2bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.a4,'Color',handles.unselectedTabColor)
set(handles.a5,'Color',handles.unselectedTabColor)
set(handles.a6,'Color',handles.unselectedTabColor)

set(handles.t2,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
set(handles.t6,'BackgroundColor',handles.unselectedTabColor)

set(handles.tab2Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

handles=replot_color_space(hObject,eventdata,handles);

% Axes object 3 callback (tab 3)
function a3bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a4,'Color',handles.unselectedTabColor)
set(handles.a5,'Color',handles.unselectedTabColor)
set(handles.a6,'Color',handles.unselectedTabColor)

set(handles.t3,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
set(handles.t6,'BackgroundColor',handles.unselectedTabColor)

set(handles.tab3Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab2Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

% Axes object 4 callback (tab 4)
function a4bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.a5,'Color',handles.unselectedTabColor)
set(handles.a6,'Color',handles.unselectedTabColor)

set(handles.t4,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.t5,'BackgroundColor',handles.unselectedTabColor)
set(handles.t6,'BackgroundColor',handles.unselectedTabColor)

set(handles.tab4Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

% Axes object 5 callback (tab 5)
function a5bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.a4,'Color',handles.unselectedTabColor)
set(handles.a6,'Color',handles.unselectedTabColor)

set(handles.t5,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
set(handles.t6,'BackgroundColor',handles.unselectedTabColor)

set(handles.tab5Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab6Panel,'Visible','off')

% Axes object 6 callback (tab 6)
function a6bd(hObject,eventdata,handles)

set(hObject,'Color',handles.selectedTabColor)
set(handles.a1,'Color',handles.unselectedTabColor)
set(handles.a2,'Color',handles.unselectedTabColor)
set(handles.a3,'Color',handles.unselectedTabColor)
set(handles.a4,'Color',handles.unselectedTabColor)
set(handles.a5,'Color',handles.unselectedTabColor)

set(handles.t6,'BackgroundColor',handles.selectedTabColor)
set(handles.t1,'BackgroundColor',handles.unselectedTabColor)
set(handles.t2,'BackgroundColor',handles.unselectedTabColor)
set(handles.t3,'BackgroundColor',handles.unselectedTabColor)
set(handles.t4,'BackgroundColor',handles.unselectedTabColor)
set(handles.t5,'BackgroundColor',handles.unselectedTabColor)

set(handles.tab6Panel,'Visible','on')
set(handles.tab1Panel,'Visible','off')
set(handles.tab2Panel,'Visible','off')
set(handles.tab3Panel,'Visible','off')
set(handles.tab4Panel,'Visible','off')
set(handles.tab5Panel,'Visible','off')

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

%Turn off slider while plotting and refreshing is going on to prevent lag
%when you hold down the slider
handles.slider_holding=1;
set(handles.LED1_slider,'enable','off')
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
set(handles.LED1_slider,'enable','on')
handles.slider_holding=0;
%set(handles.LED1_slider,'enable','off');

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

%open file browser window
[filename, pathname]=uigetfile({'*.*';'*.txt';'*.m';'*.csv'});

%filename is a double (0) if cancel is slected or window closed
if ischar(filename) 
    FileNameString=fullfile(pathname, filename); %Same as FullFileName
    InputData=importdata(FileNameString);
    tempWave=InputData(:,1);
    
    %Separate lux data (if it is supposed to be there) from the rest of the
    %data. If it is meant to be there but isn't, output a formatting error
    %to the user and cancel the data import. 
    
    %hacky solution because I couldn't make exceptions work with callbacks
    continue_callback=1;
    if  strcmp(handles.unit_type,'Unknown (Lux available)')==1
        if InputData(1,1)==0
            tempLux=InputData(1,2:end);
            handles.LED_lux=[handles.LED_lux tempLux];
        else
            error = [
                '                                                                   ';...
                'Error with import file format                                      ';...
                '                                                                   ';...
                'With the currently selected unit type, "Unknown (Lux available)",  ';...
                'the first row of the input file is expected to contain Lux data.   ';...
                'The first element of the wavelength column (element (1,1)) should  ';...
                'be a 0 such that the first row is in the form "0 Lux1 Lux2 Lux3..."'];
            disp(error)
            continue_callback=0;
        end
    end
    
    if continue_callback==1
        %loop through each column of data (each column is a spectrum for a
        %single LED)
        for n=2:size(InputData,2)
            %update control variables for appropriate number of LEDs
            handles.LED_active(end+1)=1;
            handles.alpha(end+1)=1;
            
            %spline the data to match the standardized wavelength range and
            %sampling frequency
            data=spline(tempWave,InputData(:,n),handles.Wavelength);
            data(handles.Wavelength < min(tempWave))=0;
            data(handles.Wavelength > max(tempWave))=0;

            %if lux available, correct for normalization of the data
            if strcmp(handles.unit_type,'Unknown (Lux available)')==1
                data=(data-min(data)) ./ (max(data)-min(data));
                k=683;

                coeff=handles.LED_lux(size(handles.LED_lux,2)-(size(InputData,2)-1)+n-1)/(k*sum(data(1,:).*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
                data=coeff*data;
                handles.current_unit_type='Spectral Irradiance (W*m^-2*nm^-1)';
            end       

            %add the processed data to the handle
            handles.LED_data=[handles.LED_data data'];
        end

        %only allow optimization when both LEDs and ideal spectra have been
        %imported
        if size(handles.LED_active(handles.LED_active==1),2) >= 1 && size(handles.match_active(handles.match_active==1),2)>=1
            set(handles.optimize_coefficients,'Enable','on') 
        end
        %imported data only makes sense if it's all the same units. Remove
        %the option to change after the first import
        set(handles.units_popup,'Enable','off') 
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
[filename, pathname]=uigetfile({'*.*';'*.txt';'*.m';'*.csv'});

%filename is a double (0) if cancel is slected or the window is closed
if ischar(filename) 
    FileNameString=fullfile(pathname, filename);
    InputData=importdata(FileNameString);
    tempWave=InputData(:,1);

    %handles lux data and give formatting error if necessary
    continue_callback=1;
    if  strcmp(handles.unit_type,'Unknown (Lux available)')==1
        if InputData(1,1)==0
            handles.Ideal_lux=[handles.Ideal_lux InputData(1,2:end)];
        else
            error = [
                '                                                                   ';...
                'Error with import file format                                      ';...
                '                                                                   ';...
                'With the currently selected unit type, "Unknown (Lux available)",  ';...
                'the first row of the input file is expected to contain Lux data.   ';...
                'The first element of the wavelength column (element (1,1)) should  ';...
                'be a 0 such that the first row is in the form "0 Lux1 Lux2 Lux3..."'];
            disp(error)
            continue_callback=0;
        end
    end    
    
    if continue_callback==1
        
        %enables the popup list if this is the first ideal import
        if size(handles.match_active,2)==0
            set(handles.matching_spectrum_popup,'Enable','on')
        end

        %removes the first "empty" element from the popup list during the
        %first import. There is probably a neater way to do this.
        if handles.clean==1
            handles.matching_spectrum_names(:,1)=[];
            handles.clean=0;
        end

        %loop through each column of the imported data        
        for n=2:size(InputData,2)
            
            %handles the case where this file has been imported before. Gives
            %it a different name and associated constants even though the
            %data is the same
            if size(handles.matching_spectrum_names(strcmp(handles.matching_spectrum_names,filename)==1),2) >= 1
                temp_names=regexprep(handles.matching_spectrum_names,'---(\w*)','');
                repeat=size(temp_names(strcmp(temp_names,filename)==1),2)+1;
                handles.matching_spectrum_names{1,size(handles.matching_spectrum_names,2)+1}=strcat(filename,'---',num2str(repeat)); 
                
            %one spectrum in this file
            elseif size(InputData,2) <= 2
                handles.matching_spectrum_names{1,size(handles.matching_spectrum_names,2)+1}=filename;
                
            %handles the case where there are multiple spectra in the same 
            %file. Gives each a unique id      
            else
                handles.matching_spectrum_names{1,size(handles.matching_spectrum_names,2)+1}=strcat(filename,'---',num2str(n-1));
            end
            
            %set up associated constants
            handles.ideal_multiplier(end+1)=1;
            
            %if this is the first ideal spectrum to be imported, set it as
            %the active spectrum. Otherwise leave it as inactive
            if size(handles.match_active,2)==0 && n==2
                handles.match_active(end+1)=1;
            else
                handles.match_active(end+1)=0;            
            end
            
            %spline the data with the standardized wavelength
            data=spline(tempWave,InputData(:,n),handles.Wavelength);
            data(handles.Wavelength < min(tempWave))=0;
            data(handles.Wavelength > max(tempWave))=0;
            
            %apply lux if available to undo normalization of the data
            if strcmp(handles.unit_type,'Unknown (Lux available)')==1
                data=(data-min(data)) ./ (max(data)-min(data));
                k=683;

                coeff=handles.Ideal_lux(size(handles.Ideal_lux,2)-(size(InputData,2)-1)+n-1)/(k*sum(data(1,:).*handles.ycmf.*(handles.Wavelength(1,2)-handles.Wavelength(1,1))));
                data=coeff*data;
                handles.current_unit_type='Spectral Irradiance (W*m^-2*nm^-1)';
            end   

            %add processed data to the handle
            handles.match_data=[handles.match_data data'];
        end

        %only allow optimization if both LED and ideal spectra have been
        %imported
        if size(handles.LED_active(handles.LED_active==1),2) >= 1 && size(handles.match_active(handles.match_active==1),2)>=1
            set(handles.optimize_coefficients,'Enable','on') 
        end
        if size(handles.match_active(handles.match_active==1),2)>=1
            set(handles.ideal_multiplier_text,'Enable','on')
        end
        set(handles.units_popup,'Enable','off') 
    end
end
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% function [f] = CCT_fun(x,R,xcmf,ycmf,zcmf,uvbbCCT)
% 
%         f=handles.uvbbCCT(min(sqrt((handles.LUV_u(1)-handles.uvbbCCT(:,2)).^2+(handles.LUV_v(1)-handles.uvbbCCT(:,3)).^2)),1)

function [f] = Lab_dE76_fun(x,ratio,R,standard_X,standard_Y,standard_Z,xcmf,ycmf,zcmf,ideal_data,Wave)
    stepsize=Wave(2)-Wave(1);
    k=683;
    if ratio(2) > (6/29)^3
       if ratio(1) > (6/29)^3 && ratio(2) > (6/29)^3
           f=sqrt((ideal_data(1)-(116*(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-16))^2 ...
             +(ideal_data(2)-500*((k*stepsize*sum(xcmf*R.*x)/standard_X)^(1/3)-(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)))^2 ...
             +(ideal_data(3)-200*((k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-(k*stepsize*sum(zcmf*R.*x)/standard_Z)^(1/3)))^2);
       elseif ratio(1) <= (6/29)^3 && ratio(3) > (6/29)^3
           f=sqrt((ideal_data(1)-(116*(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-16))^2 ...
             +(ideal_data(2)-500*(7.7870*k*stepsize*sum(xcmf*R.*x)/standard_X+.13793-(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)))^2 ...
             +(ideal_data(3)-200*((k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-(k*stepsize*sum(zcmf*R.*x)/standard_Z)^(1/3)))^2);           
       elseif ratio(1) <= (6/29)^3 && ratio(3) <= (6/29)^3
           f=sqrt((ideal_data(1)-(116*(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-16))^2 ...
             +(ideal_data(2)-500*(7.7870*k*stepsize*sum(xcmf*R.*x)/standard_X+.13793-(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)))^2 ...
             +(ideal_data(3)-200*((k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-(7.7870*k*stepsize*sum(zcmf*R.*x)/standard_Z+.13793)))^2);           
       elseif ratio(1) > (6/29)^3 && ratio(3) <= (6/29)^3
           f=sqrt((ideal_data(1)-(116*(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-16))^2 ...
             +(ideal_data(2)-500*((k*stepsize*sum(xcmf*R.*x)/standard_X)^(1/3)-(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)))^2 ...
             +(ideal_data(3)-200*((k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-(7.7870*k*stepsize*sum(zcmf*R.*x)/standard_Z+.13793)))^2);           
       end      
    end
    if ratio(2) <= (6/29)^3
       if ratio(1) > (6/29)^3 && ratio(2) > (6/29)^3
           f=sqrt((ideal_data(1)-(116*(7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)-16))^2 ...
             +(ideal_data(2)-500*((k*stepsize*sum(xcmf*R.*x)/standard_X)^(1/3)-(7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)))^2 ...
             +(ideal_data(3)-200*((7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)-(k*stepsize*sum(zcmf*R.*x)/standard_Z)^(1/3)))^2);
       elseif ratio(1) <= (6/29)^3 && ratio(3) > (6/29)^3
           f=sqrt((ideal_data(1)-(116*(7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)-16))^2 ...
             +(ideal_data(2)-500*(7.7870*k*stepsize*sum(xcmf*R.*x)/standard_X+.13793-(7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)))^2 ...
             +(ideal_data(3)-200*((7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)-(k*stepsize*sum(zcmf*R.*x)/standard_Z)^(1/3)))^2);           
       elseif ratio(1) <= (6/29)^3 && ratio(3) <= (6/29)^3
           f=sqrt((ideal_data(1)-(116*(7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)-16))^2 ...
             +(ideal_data(2)-500*(7.7870*k*stepsize*sum(xcmf*R.*x)/standard_X+.13793-(7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)))^2 ...
             +(ideal_data(3)-200*((7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)-(7.7870*k*stepsize*sum(zcmf*R.*x)/standard_Z+.13793)))^2);           
       elseif ratio(1) > (6/29)^3 && ratio(3) <= (6/29)^3
           f=sqrt((ideal_data(1)-(116*(7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)-16))^2 ...
             +(ideal_data(2)-500*((k*stepsize*sum(xcmf*R.*x)/standard_X)^(1/3)-(7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)))^2 ...
             +(ideal_data(3)-200*((7.7870*k*stepsize*sum(ycmf*R.*x)/standard_Y+.13793)-(7.7870*k*stepsize*sum(zcmf*R.*x)/standard_Z+.13793)))^2);           
       end         
    end    
%     if ratio(2) > (6/29)^3
%        if ratio(1) > (6/29)^3 && ratio(2) > (6/29)^3
%            f=sqrt((ideal_data(1)-(116*(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-16))^2 ...
%              +(ideal_data(2)-500*((sum(xcmf*R.*x)/(standard_X*801))^(1/3)-(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)))^2 ...
%              +(ideal_data(3)-200*((sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-(sum(zcmf*R.*x)/(standard_Z*801))^(1/3)))^2);
%        elseif ratio(1) <= (6/29)^3 && ratio(3) > (6/29)^3
%            f=sqrt((ideal_data(1)-(116*(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-16))^2 ...
%              +(ideal_data(2)-500*(7.7870*sum(xcmf*R.*x)/(standard_X*801)+.13793-(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)))^2 ...
%              +(ideal_data(3)-200*((sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-(sum(zcmf*R.*x)/(standard_Z*801))^(1/3)))^2);           
%        elseif ratio(1) <= (6/29)^3 && ratio(3) <= (6/29)^3
%            f=sqrt((ideal_data(1)-(116*(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-16))^2 ...
%              +(ideal_data(2)-500*(7.7870*sum(xcmf*R.*x)/(standard_X*801)+.13793-(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)))^2 ...
%              +(ideal_data(3)-200*((sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-(7.7870*sum(zcmf*R.*x)/(standard_Z*801)+.13793)))^2);           
%        elseif ratio(1) > (6/29)^3 && ratio(3) <= (6/29)^3
%            f=sqrt((ideal_data(1)-(116*(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-16))^2 ...
%              +(ideal_data(2)-500*((sum(xcmf*R.*x)/(standard_X*801))^(1/3)-(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)))^2 ...
%              +(ideal_data(3)-200*((sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-(7.7870*sum(zcmf*R.*x)/(standard_Z*801)+.13793)))^2);           
%        end      
%     end
%     if ratio(2) <= (6/29)^3
%        if ratio(1) > (6/29)^3 && ratio(2) > (6/29)^3
%            f=sqrt((ideal_data(1)-(116*(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)-16))^2 ...
%              +(ideal_data(2)-500*((sum(xcmf*R.*x)/(standard_X*801))^(1/3)-(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)))^2 ...
%              +(ideal_data(3)-200*((7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)-(sum(zcmf*R.*x)/(standard_Z*801))^(1/3)))^2);
%        elseif ratio(1) <= (6/29)^3 && ratio(3) > (6/29)^3
%            f=sqrt((ideal_data(1)-(116*(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)-16))^2 ...
%              +(ideal_data(2)-500*(7.7870*sum(xcmf*R.*x)/(standard_X*801)+.13793-(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)))^2 ...
%              +(ideal_data(3)-200*((7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)-(sum(zcmf*R.*x)/(standard_Z*801))^(1/3)))^2);           
%        elseif ratio(1) <= (6/29)^3 && ratio(3) <= (6/29)^3
%            f=sqrt((ideal_data(1)-(116*(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)-16))^2 ...
%              +(ideal_data(2)-500*(7.7870*sum(xcmf*R.*x)/(standard_X*801)+.13793-(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)))^2 ...
%              +(ideal_data(3)-200*((7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)-(7.7870*sum(zcmf*R.*x)/(standard_Z*801)+.13793)))^2);           
%        elseif ratio(1) > (6/29)^3 && ratio(3) <= (6/29)^3
%            f=sqrt((ideal_data(1)-(116*(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)-16))^2 ...
%              +(ideal_data(2)-500*((sum(xcmf*R.*x)/(standard_X*801))^(1/3)-(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)))^2 ...
%              +(ideal_data(3)-200*((7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)-(7.7870*sum(zcmf*R.*x)/(standard_Z*801)+.13793)))^2);           
%        end         
%     end


function [f] = LUV_dE_fun(x,ratio,R,standard_Y,standard_u,standard_v,xcmf,ycmf,zcmf,ideal_data,Wave)
 
    %order matters sum(handles.ycmf*R.*x)!=sum(x.*handles.ycmf*R)
    N=size(Wave,2);
    k=683;
    stepsize=Wave(2)-Wave(1);
    if  ratio(2)<=(6/29)^3
       f=sqrt((ideal_data(1)-(29/3)^3/standard_Y*k*stepsize*sum(ycmf*R.*x)).^2 ...
       +(ideal_data(2)-13*(29/3)^3/standard_Y*k*stepsize*sum(ycmf*R.*x)*(4*sum(xcmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_u)).^2 ...
       +(ideal_data(3)-13*(29/3)^3/standard_Y*k*stepsize*sum(ycmf*R.*x)*(9*sum(ycmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_v)).^2);
    else
       f=sqrt((ideal_data(1)-(116*(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-16)).^2 ...
       +(ideal_data(2)-13*(116*(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-16)*(4*sum(xcmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_u)).^2 ...
       +(ideal_data(3)-13*(116*(k*stepsize*sum(ycmf*R.*x)/standard_Y)^(1/3)-16)*(9*sum(ycmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_v)).^2); 
    end    
    
%     if  ratio(2)<=(6/29)^3
%        f=sqrt((ideal_data(1)-.01128*sum(ycmf*R.*x)).^2 ...
%        +(ideal_data(2)-.1466*sum(ycmf*R.*x)*(4*sum(xcmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_u)).^2 ...
%        +(ideal_data(3)-.1466*sum(ycmf*R.*x)*(9*sum(ycmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_v)).^2);
%     else
%        f=sqrt((ideal_data(1)-2.69*(sum(ycmf*R.*x))^(1/3)-16).^2 ...
%        +(ideal_data(2)-13*(2.69*(sum(ycmf*R.*x))^(1/3)-16)*(4*sum(xcmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_u)).^2 ...
%        +(ideal_data(3)-13*(2.69*(sum(ycmf*R.*x))^(1/3)-16)*(9*sum(ycmf*R.*x)/(sum(xcmf*R.*x)+15*sum(ycmf*R.*x)+3*sum(zcmf*R.*x))-standard_v)).^2); 
%     end

% --- Executes on button press in optimize_coefficients.
function optimize_coefficients_Callback(hObject, eventdata, handles)
% hObject    handle to optimize_coefficients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp_handles=findall(handles.tab1Panel, 'enable', 'on');
set(temp_handles, 'enable', 'off')

R=[];
for n=1:size(handles.LED_data,2)
    if handles.LED_active(n)==1
        R=[R handles.LED_data(:,n)];
    end
end

standard_u=4*handles.standard_illuminant(1)/(-2*handles.standard_illuminant(1)+12*handles.standard_illuminant(2)+3);
standard_v=6*handles.standard_illuminant(1)/(-2*handles.standard_illuminant(1)+12*handles.standard_illuminant(2)+3);
standard_Y=100;
standard_X=handles.standard_illuminant(1)*standard_Y/handles.standard_illuminant(2);
standard_Z=handles.standard_illuminant(2)*standard_Y/(1-handles.standard_illuminant(1)-handles.standard_illuminant(2));

xcmf=handles.xcmf;
ycmf=handles.ycmf;
zcmf=handles.zcmf;

Wave=handles.Wavelength;

ratio=[handles.X(1)/standard_X handles.Y(2)/standard_Y handles.Z(1)/standard_Z];

options = optimoptions('fmincon','Algorithm','sqp','Display','off');%,'DerivativeCheck','on');
%[2.1476 1.3684 72.2731 3.4866 21.0973];%
x0=rand(1,size(handles.LED_active(handles.LED_active==1),2));
lb=zeros(1,size(handles.LED_active(handles.LED_active==1),2));
ub=ones(1,size(handles.LED_active(handles.LED_active==1),2));
ub=ub.*handles.max_alpha;
%%%%%%%%%%%%%%%%%%%%%%%%%%Troubleshooting
% sol=handles.alpha(handles.LED_active==1);
% Lcorrect=handles.LUV_L(2);
% Ucorrect=handles.LUV_u(2);
% Vcorrect=handles.LUV_v(2);
% uprime_correct=handles.LUV_u_prime(2);
% vprime_correct=handles.LUV_v_prime(2);
% 
% stepsize=Wave(2)-Wave(1)
% k=683;
% 
% uprime_test=4*sum(xcmf*R.*sol)/(sum(xcmf*R.*sol)+15*sum(ycmf*R.*sol)+3*sum(zcmf*R.*sol));
% vprime_test=9*sum(ycmf*R.*sol)/(sum(xcmf*R.*sol)+15*sum(ycmf*R.*sol)+3*sum(zcmf*R.*sol));
% if handles.Y(2)/100 <=(6/29)^3
%     q='one'
%     Ltest=(29/3)^3*k*stepsize*sum(ycmf*R.*sol)/standard_Y;
%     Utest=13*(29/3)^3/standard_Y*k*stepsize*sum(ycmf*R.*sol)*(4*sum(xcmf*R.*sol)/(sum(xcmf*R.*sol)+15*sum(ycmf*R.*sol)+3*sum(zcmf*R.*sol))-standard_u);
%     Vtest=13*(29/3)^3/standard_Y*k*stepsize*sum(ycmf*R.*sol)*(9*sum(ycmf*R.*sol)/(sum(xcmf*R.*sol)+15*sum(ycmf*R.*sol)+3*sum(zcmf*R.*sol))-standard_v);
% else
%     q='two'
%     Ltest=(k*stepsize/standard_Y)^(1/3)*116*sum(ycmf*R.*sol)^(1/3)-16;
%     Utest=13*(116*(k*stepsize*sum(ycmf*R.*sol)/standard_Y)^(1/3)-16)*(4*sum(xcmf*R.*sol)/(sum(xcmf*R.*sol)+15*sum(ycmf*R.*sol)+3*sum(zcmf*R.*sol))-standard_u);
%     Vtest=13*(116*(k*stepsize*sum(ycmf*R.*sol)/standard_Y)^(1/3)-16)*(9*sum(ycmf*R.*sol)/(sum(xcmf*R.*sol)+15*sum(ycmf*R.*sol)+3*sum(zcmf*R.*sol))-standard_v);
% end
% t1=[Lcorrect Ltest 174.6847095*sum(ycmf*R.*sol)^(1/3)-16]
% t2=[Ucorrect Utest]
% t3=[Vcorrect Vtest]
% t4=[uprime_correct uprime_test]
% t5=[vprime_correct vprime_test]
%%%%%%%%%%%%%%%%%%%%%%%%%Troubleshooting
%%%%%%%%%%%%%%%%%%%%%%%%%%Troubleshooting
% x=handles.alpha(handles.LED_active==1);
% Lcorrect=handles.Lab_L(2);
% acorrect=handles.a(2);
% bcorrect=handles.b(2);
% 
%     if ratio(2) > (6/29)^3
%        if ratio(1) > (6/29)^3 && ratio(2) > (6/29)^3
%            note='1'
%            Ltest=116*(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-16;
%            atest=500*((sum(xcmf*R.*x)/(standard_X*801))^(1/3)-(sum(ycmf*R.*x)/(standard_Y*801))^(1/3));
%            btest=200*((sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-(sum(zcmf*R.*x)/(standard_Z*801))^(1/3));
%        elseif ratio(1) <= (6/29)^3 && ratio(3) > (6/29)^3
%            note='2'
%            Ltest=116*(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-16;
%            atest=500*(7.7870*sum(xcmf*R.*x)/(standard_X*801)+.1379-(sum(ycmf*R.*x)/(standard_Y*801))^(1/3));
%            btest=200*((sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-(sum(zcmf*R.*x)/(standard_Z*801))^(1/3));           
%        elseif ratio(1) <= (6/29)^3 && ratio(3) <= (6/29)^3
%            note='3'
%            Ltest=116*(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-16;
%            atest=500*(7.7870*sum(xcmf*R.*x)/(standard_X*801)+.1379-(sum(ycmf*R.*x)/(standard_Y*801))^(1/3));
%            btest=200*((sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-7.7870*sum(zcmf*R.*x)/(standard_Z*801)+.1379);           
%        elseif ratio(1) > (6/29)^3 && ratio(3) <= (6/29)^3
%            note='4'
%            Ltest=116*(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-16;
%            atest=500*((sum(xcmf*R.*x)/(standard_X*801))^(1/3)-(sum(ycmf*R.*x)/(standard_Y*801))^(1/3));
%            btest=200*((sum(ycmf*R.*x)/(standard_Y*801))^(1/3)-7.7870*sum(zcmf*R.*x)/(standard_Z*801)+.1379);           
%        end      
%     end
% 
%     %7.787*ratio3+.13793
%     
%     %(sum(ycmf*R.*x)/(standard_Y*801))^(1/3)
%     %(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.1379)
%     if ratio(2) <= (6/29)^3
%        if ratio(1) > (6/29)^3 && ratio(2) > (6/29)^3
%            note='5'
%            Ltest=116*(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.1379)-16;
%            atest=500*((sum(xcmf*R.*x)/(standard_X*801))^(1/3)-(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.1379));
%            btest=200*((7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.1379)-(sum(zcmf*R.*x)/(standard_Z*801))^(1/3));
%        elseif ratio(1) <= (6/29)^3 && ratio(3) > (6/29)^3
%            note='6'
%            Ltest=116*(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.1379)-16;
%            atest=500*(7.7870*sum(xcmf*R.*x)/(standard_X*801)+.1379-(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.1379));
%            btest=200*((7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.1379)-(sum(zcmf*R.*x)/(standard_Z*801))^(1/3));           
%        elseif ratio(1) <= (6/29)^3 && ratio(3) <= (6/29)^3
%            note='7'
%            Ltest=116*(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)-16;
%            atest=500*(7.7870*sum(xcmf*R.*x)/(standard_X*801)+.13793-(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793));
%            btest=200*((7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.13793)-(7.7870*sum(zcmf*R.*x)/(standard_Z*801)+.13793));           
%        elseif ratio(1) > (6/29)^3 && ratio(3) <= (6/29)^3
%            note='8'
%            Ltest=116*(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.1379)-16;
%            atest=500*((sum(xcmf*R.*x)/(standard_X*801))^(1/3)-(7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.1379));
%            btest=200*((7.7870*sum(ycmf*R.*x)/(standard_Y*801)+.1379)-7.7870*sum(zcmf*R.*x)/(standard_Z*801)+.1379);           
%        end         
%     end
% 
% t1=[Lcorrect Ltest]
% t2=[acorrect atest]
% t3=[bcorrect btest]
%%%%%%%%%%%%%%%%%%%%%%%%%Troubleshooting
if strcmp(handles.optimize_type,'Least-Squares Spectrum Match')==1
    s=handles.match_data(:,handles.match_active==1);

    lb=zeros(1,size(handles.LED_active(handles.LED_active==1),2));
    ub=ones(1,size(handles.LED_active(handles.LED_active==1),2));
    ub=ub.*handles.max_alpha;

    options = optimoptions('lsqlin','Display','off');
    alpha_temp=lsqlin(R,s,[],[],[],[],lb,ub,[],options);
    
    i=1;
    for n=1:size(handles.LED_active,2)
        if handles.LED_active(n)==1
            handles.alpha(n)=alpha_temp(i);
            i=i+1;
        end
    end
end

if strcmp(handles.optimize_type,'Minimized LUV dE')==1

    %[x,fval]=fmincon('LUV_dE_fun',x0,[],[],[],[],lb,ub,[],options);
    ideal_data=[handles.LUV_L(1) handles.LUV_u(1) handles.LUV_v(1)];
    f=@(x)LUV_dE_fun(x,ratio,R,standard_Y,standard_u,standard_v,xcmf,ycmf,zcmf,ideal_data,Wave);
    [x,fval]=fmincon(f,x0,[],[],[],[],lb,ub,[],options);
    
    i=1;
    for n=1:size(handles.LED_active,2)
        if handles.LED_active(n)==1
            handles.alpha(n)=x(i);
            i=i+1;
        end
    end
end

if strcmp(handles.optimize_type,'Minimized Lab dE76')==1

    ideal_data=[handles.Lab_L(1) handles.a(1) handles.b(1)];    
    f=@(x)Lab_dE76_fun(x,ratio,R,standard_X,standard_Y,standard_Z,xcmf,ycmf,zcmf,ideal_data,Wave);
    [x,fval]=fmincon(f,x0,[],[],[],[],lb,ub,[],options);
    
    i=1;
    for n=1:size(handles.LED_active,2)
        if handles.LED_active(n)==1
            handles.alpha(n)=x(i);
            i=i+1;
        end
    end
end

set(temp_handles, 'enable', 'on')

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
    ylabel(handles.current_unit_type)
    xlim([min(handles.Wavelength) max(handles.Wavelength)])
    hold off
    
    axes(handles.Matching_plot)
    cla reset
    
    hold on
%    if size(handles.match_data,2) >= 1
        for n=1:size(handles.match_data,2)  
            if handles.match_active(n)==1
                plot(handles.Wavelength,handles.match_data(:,n),'k','LineWidth',2)
            end
        end
%    end
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
    ylabel(handles.current_unit_type)
    xlim([min(handles.Wavelength) max(handles.Wavelength)])
    hold off
    
function [handles]=replot_color_space(hObject,eventdata,handles)    
if strcmp(handles.CIE_space,'xyY')==1
    set(handles.xyY_plot,'Visible','On')
    set(handles.LUV_plot,'Visible','Off')
    set(handles.Lab_plot,'Visible','Off')
    set(handles.UVW_plot,'Visible','Off')
    set(handles.RGB_plot,'Visible','Off')
    
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
    set(handles.RGB_plot,'Visible','Off')
    
    axes(handles.LUV_plot)
    cla reset
    
    hold on
    imagesc([0 .63],[0 .6],handles.LUV_bg)
    xlim([0 .63])
    ylim([0 .6])
    scatter(handles.LUV_u_prime(1),handles.LUV_v_prime(1),70,'k','fill')
    scatter(handles.LUV_u_prime(2),handles.LUV_v_prime(2),70,'k','v','fill')
    
    legend('Ideal','Generated')
    xlabel('u`')
    ylabel('v`')
    hold off
end

if strcmp(handles.CIE_space,'Lab')==1
    set(handles.xyY_plot,'Visible','Off')
    set(handles.LUV_plot,'Visible','Off')
    set(handles.Lab_plot,'Visible','On')
    set(handles.UVW_plot,'Visible','Off')
    set(handles.RGB_plot,'Visible','Off')
    
    axes(handles.Lab_plot)
    cla reset
end

if strcmp(handles.CIE_space,'UVW')==1
    
    set(handles.xyY_plot,'Visible','Off')
    set(handles.LUV_plot,'Visible','Off')
    set(handles.Lab_plot,'Visible','Off')
    set(handles.UVW_plot,'Visible','On')
    set(handles.RGB_plot,'Visible','Off')    
    
    axes(handles.UVW_plot)
    cla reset

end

if strcmp(handles.CIE_space,'RGB')==1
    set(handles.xyY_plot,'Visible','Off')
    set(handles.LUV_plot,'Visible','Off')
    set(handles.Lab_plot,'Visible','Off')
    set(handles.UVW_plot,'Visible','Off')
    set(handles.RGB_plot,'Visible','On')    
    
    axes(handles.RGB_plot)
    cla reset
    
    color_square=ones(1,2,3);
    if handles.R(1) <= 255 && handles.R(1) >= 0 ...
    && handles.G(1) <= 255 && handles.G(1) >= 0 ...
    && handles.B(1) <= 255 && handles.B(1) >= 0 
    color_square(:,1,1)=handles.R(1)/255;
    color_square(:,1,2)=handles.G(1)/255;
    color_square(:,1,3)=handles.B(1)/255;
    
    end
    if handles.R(2) <= 255 && handles.R(2) >= 0 ...
    && handles.G(2) <= 255 && handles.G(2) >= 0 ...
    && handles.B(2) <= 255 && handles.B(2) >= 0     
    color_square(:,2,1)=handles.R(2)/255;
    color_square(:,2,2)=handles.G(2)/255;
    color_square(:,2,3)=handles.B(2)/255;
    end
    imagesc([0 1],[0 1],color_square)

    
    
%     X=k*sum(xcmf.*s')*(red(2,1)-red(1,1))
%     Y=k*sum(ycmf.*s')*(red(2,1)-red(1,1))
%     Z=k*sum(zcmf.*s')*(red(2,1)-red(1,1))
end

function [Ra,R] = get_cri1995(testsourcespd,referencesourcespd,cmf,CIETCS1nm,Wavelength)
    %calculate normalization constant k for perfect diffuse reflector of source
    
    ktest = 100./sum(cmf(:,2).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    kref = 100./sum(cmf(:,2).*referencesourcespd*(Wavelength(2)-Wavelength(1)));

    %Need have to apply von Kries chromatic adaptation 
    %first calculate c and d for both sources
    %this requires calculating the chromaticity in uv for the test source and
    %reference source
    
    %tristimulus values of the 15 samples when they are illuminated by the
    %test source
    XYZtest_samples= zeros(3,15);
    %tristimulus values of the 15 samples when they are illuminated by the
    %reference source    
    XYZreference_samples = zeros(3,15);    
    
    %XYZ, u', and v' coordinates of the test source itself
    Xtest_source=ktest*sum(cmf(:,1).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    Ytest_source=ktest*sum(cmf(:,2).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    Ztest_source=ktest*sum(cmf(:,3).*testsourcespd*(Wavelength(2)-Wavelength(1)));
    Utest_source=4*Xtest_source./(Xtest_source+15*Ytest_source+3*Ztest_source);
    Vtest_source=6*Ytest_source./(Xtest_source+15*Ytest_source+3*Ztest_source);
    
    %XYZ, u', and v' coordinates of the reference source itself    
    Xreference_source=kref*sum(cmf(:,1).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
    Yreference_source=kref*sum(cmf(:,2).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
    Zreference_source=kref*sum(cmf(:,3).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
    Ureference_source=4*Xreference_source./(Xreference_source+15*Yreference_source+3*Zreference_source);
    Vreference_source=6*Yreference_source./(Xreference_source+15*Yreference_source+3*Zreference_source);    
    
    for j=1:size(cmf,2)
        for i=2:size(CIETCS1nm,2) %all 15 samples in CIETCS1nm
            XYZtest_samples(j,i-1) = ktest.*sum(CIETCS1nm(:,i).*cmf(:,j).*testsourcespd*(Wavelength(2)-Wavelength(1)));
        end
    end

    for j=1:size(cmf,2)
        for i=2:size(CIETCS1nm,2) %all 15 samples in CIETCS1nm
            XYZreference_samples(j,i-1) = kref.*sum(CIETCS1nm(:,i).*cmf(:,j).*referencesourcespd*(Wavelength(2)-Wavelength(1)));
        end
    end

    %UV coordinates of the 15 samples when they are illuminated by test and
    %reference sources respectively
    Ureference_samples=4*XYZreference_samples(1,:)./(XYZreference_samples(1,:)+15*XYZreference_samples(2,:)+3*XYZreference_samples(3,:));
    Vreference_samples=6*XYZreference_samples(2,:)./(XYZreference_samples(1,:)+15*XYZreference_samples(2,:)+3*XYZreference_samples(3,:));
    
    Utest_samples=4*XYZtest_samples(1,:)./(XYZtest_samples(1,:)+15*XYZtest_samples(2,:)+3*XYZtest_samples(3,:));
    Vtest_samples=6*XYZtest_samples(2,:)./(XYZtest_samples(1,:)+15*XYZtest_samples(2,:)+3*XYZtest_samples(3,:)); 
    
    %next we need to calculate c and d coefficients for both sources, as well
    %as for the samples illuminated by the test source
    Ctest_source=(4-Utest_source-10*Vtest_source)./Vtest_source;
    Dtest_source=(1.708*Vtest_source+.404-1.481*Utest_source)./Vtest_source;

    Creference_source=(4-Ureference_source-10*Vreference_source)/Vreference_source;
    Dreference_source=(1.708*Vreference_source+.404-1.481*Ureference_source)./Vreference_source;

    Ctest_samples=(4-Utest_samples-10*Vtest_samples)./Vtest_samples;
    Dtest_samples=(1.708*Vtest_samples+.404-1.481*Utest_samples)./Vtest_samples;
    
    %Recalculate the u and v coordinates of the samples illuminated by the
    %test source, applying von kries chromatic adaptation       
    Utest_samples=(10.872+.404*Ctest_samples.*(Creference_source./Ctest_source)-4*Dtest_samples.*(Dreference_source./Dtest_source))./ ...
                  (16.518+1.481*Ctest_samples.*(Creference_source./Ctest_source)-Dtest_samples.*(Dreference_source./Dtest_source));
    
    Vtest_samples=5.520./(16.518+1.481*Ctest_samples.*(Creference_source./Ctest_source)-Dtest_samples.*(Dreference_source./Dtest_source));
     
    %calculate UVW for chromatically adapted object colors
    Wtest = 25.*(XYZtest_samples(2,:).^(1/3))-17;
    Utest = 13.*Wtest.*(Utest_samples-Ureference_source);
    Vtest = 13.*Wtest.*(Vtest_samples-Vreference_source);
    %UVWtest = horzcat(Utest',Vtest',Wtest');

    %calculate UVW for reference illumance object colors
    Wref = 25.*(XYZtest_samples(2,:).^(1/3))-17;
    Uref = 13.*Wref.*(Ureference_samples-Ureference_source);
    Vref = 13.*Wref.*(Vreference_samples-Vreference_source); 
    %UVWref = horzcat(Uref',Vref',Wref');
    
    deltaE = sqrt((Wtest-Wref).^2+(Utest-Uref).^2+(Vtest-Vref).^2);
    R = 100-(4.6.*deltaE);
    Ra = (sum(R(:,1:8))/8);

%credit pspectro
function nrefspd = get_nrefspd(CCT,DSPD,Wavelength,normWavelength)

    %blackbody spd
    if CCT <= 5000
        Wavelength_nm=Wavelength*10^-9;
        c1 = 3.7418e-16;
        c2 = 1.438775225e-2;
        refspd = horzcat(Wavelength',c1./(Wavelength_nm.^5.*(exp(c2./(Wavelength_nm.*CCT))-1))');
        
    %daylight spd    
    elseif CCT > 5000
        %linearly interpolate DSPD
        %DSPD = horzcat(range',interp1(DSPD(:,1),DSPD(:,[2 3 4]),range,'linear'));

        %calculate x_d,y_d based on input color temperature
        if CCT <= 7000
            xd = .244063 + .09911*(1e3/CCT) + 2.9678*(1e6/(CCT^2)) - 4.6070*(1e9/(CCT^3));
        else 
            xd = .237040 + .24748*(1e3/CCT) + 1.9018*(1e6/CCT^2) - 2.0064*(1e9/CCT^3);
        end

        yd = -3.000*xd^2 + 2.870*xd - 0.275;

        %calculate relatative SPD
        M = 0.0241 + 0.2562*xd - 0.7341*yd;
        M1 = (-1.3515 - 1.7703*xd + 5.9114*yd)/M;
        M2 = (0.03000 - 31.4424*xd + 30.0717*yd)/M;

        refspd = horzcat(DSPD(:,1),DSPD(:,2) + M1.*DSPD(:,3) + M2.*DSPD(:,4));    
    end 
     
%     startval = find(refspd(:,1) == min(range));
%     endval = find(refspd(:,1) == max(range));

    %normalize spd around given wavelength
    nrefspd = horzcat(Wavelength',1.*(refspd(:,2)./refspd(refspd(:,1) == normWavelength,2)));  
    
function [handles]=refresh(hObject,eventdata,handles)
    set(handles.current_unit_text,'string',handles.current_unit_type) 
    set(handles.ideal_multiplier_text,'string',num2str(handles.ideal_multiplier(handles.match_active==1)))
    
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
        k=683;
        %k = 100./sum(handles.ycmf.*s*(handles.Wavelength(2)-handles.Wavelength(1)));

        handles.X(1)=k*sum(handles.xcmf.*s*(handles.Wavelength(2)-handles.Wavelength(1)));
        handles.Y(1)=k*sum(handles.ycmf.*s*(handles.Wavelength(2)-handles.Wavelength(1)));
        handles.Z(1)=k*sum(handles.zcmf.*s*(handles.Wavelength(2)-handles.Wavelength(1)));        
        
%         handles.X(1)=sum(handles.xcmf.*s)/size(s,2);
%         handles.Y(1)=sum(handles.ycmf.*s)/size(s,2);
%         handles.Z(1)=sum(handles.zcmf.*s)/size(s,2);        

        RGB=handles.RGB_mat*[handles.X(1); handles.Y(1); handles.Z(1)];
        max_RGB=max([RGB(1) RGB(2) RGB(3)]);
        handles.RGB_brightness_mod(1)=1;
        if max_RGB > 255
            handles.RGB_brightness_mod(1)=255/max_RGB;
        end
        RGB=RGB*handles.RGB_brightness_mod(1);
        handles.R(1)=RGB(1);
        handles.G(1)=RGB(2);
        handles.B(1)=RGB(3);
        
        handles.x(1)=handles.X(1)/(handles.X(1)+handles.Y(1)+handles.Z(1));
        handles.y(1)=handles.Y(1)/(handles.X(1)+handles.Y(1)+handles.Z(1));
        handles.z(1)=handles.Z(1)/(handles.X(1)+handles.Y(1)+handles.Z(1));
        
        standard_u=4*handles.standard_illuminant(1)/(-2*handles.standard_illuminant(1)+12*handles.standard_illuminant(2)+3);
        standard_v=6*handles.standard_illuminant(2)/(-2*handles.standard_illuminant(1)+12*handles.standard_illuminant(2)+3);
        
        handles.LUV_u_prime(1)=4*handles.x(1)/(-2*handles.x(1)+12*handles.y(1)+3);
        
        %wikipedia says "9*x", pspectro says "6*x"
        handles.LUV_v_prime(1)=6*handles.y(1)/(-2*handles.x(1)+12*handles.y(1)+3);   
        
        handles.W(1)=25*(handles.Y(1)).^(1/3)-17;
        handles.UVW_u(1)=13*handles.W(1).*(handles.LUV_u_prime(1)-standard_u);
        handles.UVW_v(1)=13*handles.W(1).*(handles.LUV_v_prime(1)-standard_v);

        ref_Y=100;
        ref_X=handles.standard_illuminant(1)*ref_Y/handles.standard_illuminant(2);
        ref_Z=handles.standard_illuminant(2)*ref_Y/(1-handles.standard_illuminant(1)-handles.standard_illuminant(2));
        
        ratio1=handles.X(1)/ref_X;
        ratio2=handles.Y(1)/ref_Y;
        ratio3=handles.Z(1)/ref_Z;
        
        if ratio2 <= .008856
            handles.LUV_L(1)=(29/3)^3*ratio2;
        else
            handles.LUV_L(1)=116*ratio2^(1/3)-16;
        end
        handles.LUV_u(1)=13*handles.LUV_L(1)*(handles.LUV_u_prime(1)-standard_u);
        handles.LUV_v(1)=13*handles.LUV_L(1)*(handles.LUV_v_prime(1)-standard_v);        
        
        %credit pspectro getuvbbCCT.m
        finddistance = sqrt((handles.LUV_u_prime(1)-handles.uvbbCCT(:,2)).^2+(handles.LUV_v_prime(1)-handles.uvbbCCT(:,3)).^2);
        [mindistance,row] = min(finddistance);

        handles.cct(1) = handles.uvbbCCT(row,1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nrefspd = get_nrefspd(handles.cct(1),handles.DSPD,handles.Wavelength,560);
        cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
        [Ra,R] = get_cri1995(s',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength);
        
        handles.CRI(1)=Ra;
        
        if ratio1 > .008856
            f1=ratio1^(1/3);
        else
            f1=7.787*ratio1+.13793;
        end
        
        if ratio2 > .008856
            f2=ratio2^(1/3);
        else
            f2=7.787*ratio2+.13793;
        end
        
        if ratio3 > .008856
            f3=ratio3^(1/3);
        else
            f3=7.787*ratio3+.13793;
        end

        handles.Lab_L(1)=116*f2-16;
        handles.a(1)=500*(f1-f2);
        handles.b(1)=200*(f2-f3);
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
        k=683;
        %k=100./sum(handles.ycmf.*handles.generated*(handles.Wavelength(2)-handles.Wavelength(1)));
                
        handles.X(2)=k*sum(handles.xcmf.*handles.generated*(handles.Wavelength(2)-handles.Wavelength(1)));
        handles.Y(2)=k*sum(handles.ycmf.*handles.generated*(handles.Wavelength(2)-handles.Wavelength(1)));
        handles.Z(2)=k*sum(handles.zcmf.*handles.generated*(handles.Wavelength(2)-handles.Wavelength(1)));    
        
%         handles.X(2)=sum(handles.xcmf.*handles.generated)/size(handles.generated,2);
%         handles.Y(2)=sum(handles.ycmf.*handles.generated)/size(handles.generated,2);
%         handles.Z(2)=sum(handles.zcmf.*handles.generated)/size(handles.generated,2);             
        
        RGB=handles.RGB_mat*[handles.X(2); handles.Y(2); handles.Z(2)];
        max_RGB=max([RGB(1) RGB(2) RGB(3)]);
        handles.RGB_brightness_mod(2)=1;
        if max_RGB > 255
            handles.RGB_brightness_mod(2)=255/max_RGB;
        end
        RGB=RGB*handles.RGB_brightness_mod(2);
        handles.R(2)=RGB(1);
        handles.G(2)=RGB(2);
        handles.B(2)=RGB(3);        
        
        handles.x(2)=handles.X(2)/(handles.X(2)+handles.Y(2)+handles.Z(2));
        handles.y(2)=handles.Y(2)/(handles.X(2)+handles.Y(2)+handles.Z(2));
        handles.z(2)=handles.Z(2)/(handles.X(2)+handles.Y(2)+handles.Z(2));
        
        handles.LUV_u_prime(2)=4*handles.x(2)/(-2*handles.x(2)+12*handles.y(2)+3);
        handles.LUV_v_prime(2)=6*handles.y(2)/(-2*handles.x(2)+12*handles.y(2)+3);      
                
        standard_u=4*handles.standard_illuminant(1)/(-2*handles.standard_illuminant(1)+12*handles.standard_illuminant(2)+3);
        standard_v=6*handles.standard_illuminant(2)/(-2*handles.standard_illuminant(1)+12*handles.standard_illuminant(2)+3);

        handles.W(2)=25*(handles.Y(2)).^(1/3)-17;
        handles.UVW_u(2)=13*handles.W(2).*(handles.LUV_u_prime(2)-standard_u);
        handles.UVW_v(2)=13*handles.W(2).*(handles.LUV_v_prime(2)-standard_v);
        
        ref_Y=100;
        ref_X=handles.standard_illuminant(1)*ref_Y/handles.standard_illuminant(2);
        ref_Z=handles.standard_illuminant(2)*ref_Y/(1-handles.standard_illuminant(1)-handles.standard_illuminant(2));
        
        ratio1=handles.X(2)/ref_X;
        ratio2=handles.Y(2)/ref_Y;
        ratio3=handles.Z(2)/ref_Z;
        
        if ratio2 <= .008856
            handles.LUV_L(2)=(29/3)^3*ratio2;
        else
            handles.LUV_L(2)=116*ratio2^(1/3)-16;
        end
        handles.LUV_u(2)=13*handles.LUV_L(2)*(handles.LUV_u_prime(2)-standard_u);
        handles.LUV_v(2)=13*handles.LUV_L(2)*(handles.LUV_v_prime(2)-standard_v);        
        
        %credit pspectro getuvbbCCT.m
        finddistance = sqrt((handles.LUV_u_prime(2)-handles.uvbbCCT(:,2)).^2+(handles.LUV_v_prime(2)-handles.uvbbCCT(:,3)).^2);
        [mindistance,row] = min(finddistance);

        handles.cct(2) = handles.uvbbCCT(row,1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %handles.cct(2)=3623;
        nrefspd = get_nrefspd(handles.cct(2),handles.DSPD,handles.Wavelength,560);
        %load nrefspd.mat
        cmf=[handles.xcmf' handles.ycmf' handles.zcmf'];
        %save('nrefspd_actual','nrefspd')
        [Ra,R] = get_cri1995(handles.generated',nrefspd(:,2),cmf,handles.CIETCS1nm,handles.Wavelength);

        handles.CRI(2)=Ra;        
        
        if ratio1 > .008856
            f1=ratio1^(1/3);
        else
            f1=7.787*ratio1+.13793;
        end
        
        if ratio2 > .008856
            f2=ratio2^(1/3);
        else
            f2=7.787*ratio2+.13793;
        end
        
        if ratio3 > .008856
            f3=ratio3^(1/3);
        else
            f3=7.787*ratio3+.13793;
        end

        handles.Lab_L(2)=116*f2-16;
        handles.a(2)=500*(f1-f2);
        handles.b(2)=200*(f2-f3);
    end
    
    if size(handles.match_data,2) >= 1 && size(handles.LED_data,2) >= 1
        handles.LUV_dE=sqrt((handles.LUV_L(1)-handles.LUV_L(2))^2+(handles.LUV_u(1)-handles.LUV_u(2))^2+(handles.LUV_v(1)-handles.LUV_v(2))^2);
        handles.dE76=sqrt((handles.Lab_L(1)-handles.Lab_L(2))^2+(handles.a(1)-handles.a(2))^2+(handles.b(1)-handles.b(2))^2);
        
        kL=1;
        k1=.045;
        k2=.015;
        dL=handles.Lab_L(1)-handles.Lab_L(2);
        C1=sqrt(handles.a(1)^2+handles.b(1)^2);
        C2=sqrt(handles.a(2)^2+handles.b(2)^2);
        dC=C1-C2;
        da=handles.a(1)-handles.a(2);
        db=handles.b(1)-handles.b(2);
        dH=sqrt(da^2+db^2-dC^2); 
        SC=1+k1*C1;
        SH=1+k2*C1;
        SL=1; kC=1; kH=1;
        
        handles.dE94=sqrt((dL/(kL*SL))^2+(dC/(kC*SC))^2+(dH/(kH*SH))^2);
        
        dL=handles.Lab_L(2)-handles.Lab_L(1);
        Lbar=mean(handles.Lab_L); Cbar=mean([C1 C2]);
        
        a1=handles.a(1)+.5*handles.a(1)*(1-sqrt(Cbar^7/(Cbar^7+25^7)));
        a2=handles.a(2)+.5*handles.a(2)*(1-sqrt(Cbar^7/(Cbar^7+25^7)));
        
        C1_prime=sqrt(a1^2+handles.b(1)^2);
        C2_prime=sqrt(a2^2+handles.b(2)^2);
        dC_prime=C2_prime-C1_prime;
        Cbar_prime=mean([C1_prime C2_prime]);
        
        h1=mod((180/pi)*atan2(handles.b(1),a1),360);
        h2=mod((180/pi)*atan2(handles.b(2),a2),360);
        
        if abs(h1-h2)<=180
            dh=h2-h1; 
        end
        if abs(h1-h2) > 180 && h2 <= h1
            dh=h2-h1+360; 
        end
        if abs(h1-h2) > 180 && h2 > h1
            dh=h2-h1-360;
        end
        
        dH=2*sqrt(C1_prime*C2_prime)*sind(dh/2);
        if abs(h1-h2) > 180
            Hbar=(h1+h2+360)/2;
        end
        if abs(h1-h2) <= 180
            Hbar=(h1+h2)/2;
        end
        if C1_prime==0 || C2_prime==0
            Hbar=h1+h2; 
        end
        
        T=1-.17*cosd(Hbar-30)+.24*cosd(2*Hbar)+.32*cosd(3*Hbar+6)-.2*cosd(4*Hbar-63);
        SL=1+.015*(Lbar-50)^2/sqrt(20+(Lbar-50)^2);
        SC=1+.045*Cbar_prime;
        SH=1+.015*Cbar_prime*T;
        RT=-2*sqrt(Cbar_prime^7/(Cbar_prime^7+25^7))*sind(60*exp(-1*((Hbar-275)/25)^2));
        
        handles.dE00=sqrt((dL/(kL*SL))^2+(dC_prime/(kC*SC))^2+(dH/(kH*SH))^2+RT*dC_prime*dH/(kC*SC*kH*SH));
    end
    
    if strcmp(handles.CIE_space,'xyY')==1
        rowNames={'X','Y','Z','CCT','CRI','CQS','CFI','CSI','CDI','','x','y','z'};
        CIE_table_data={
          handles.X(1) handles.X(2); handles.Y(1) handles.Y(2);...
          handles.Z(1) handles.Z(2);handles.cct(1) handles.cct(2);...
          handles.CRI(1) handles.CRI(2); [] []; [] [];[] []; [] [] ;[] []; handles.x(1) handles.x(2);...
          handles.y(1) handles.y(2);handles.z(1) handles.z(2)};

        set(handles.CIE_table,'Data',CIE_table_data)  
        set(handles.CIE_table,'RowName',rowNames)
    end
    if strcmp(handles.CIE_space,'LUV')==1
        rowNames={'X','Y','Z','CCT','CRI','CQS','CFI','CSI','CDI','','u`','v`','u*','v*','L*','dE'};
        CIE_table_data={
        handles.X(1) handles.X(2); handles.Y(1) handles.Y(2);...
        handles.Z(1) handles.Z(2);handles.cct(1) handles.cct(2);...
        handles.CRI(1) handles.CRI(2); [] []; [] [];[] []; [] [] ;[] []; handles.LUV_u_prime(1) handles.LUV_u_prime(2);...
        handles.LUV_v_prime(1) handles.LUV_v_prime(2);handles.LUV_u(1) handles.LUV_u(2);...
        handles.LUV_v(1) handles.LUV_v(2);handles.LUV_L(1) handles.LUV_L(2);...
        handles.LUV_dE [];};
  
        set(handles.CIE_table,'RowName',rowNames)
        set(handles.CIE_table,'Data',CIE_table_data)
    end
    if strcmp(handles.CIE_space,'Lab')==1
        rowNames={'X','Y','Z','CCT','CRI','CQS','CFI','CSI','CDI','','L','a','b','dE76','dE94','dE00'};
        CIE_table_data={
        handles.X(1) handles.X(2); handles.Y(1) handles.Y(2);...
        handles.Z(1) handles.Z(2);handles.cct(1) handles.cct(2);...
        handles.CRI(1) handles.CRI(2); [] []; [] [];[] []; [] [] ;[] []; handles.Lab_L(1) handles.Lab_L(2);...
        handles.a(1) handles.a(2);handles.b(1) handles.b(2);handles.dE76 [];...
        handles.dE94 []; handles.dE00 [];};
  
        set(handles.CIE_table,'RowName',rowNames)
        set(handles.CIE_table,'Data',CIE_table_data)        
    end
    if strcmp(handles.CIE_space,'UVW')==1
        rowNames={'X','Y','Z','CCT','CRI','CQS','CFI','CSI','CDI','','u','v','W'};
        CIE_table_data={
        handles.X(1) handles.X(2); handles.Y(1) handles.Y(2);...
        handles.Z(1) handles.Z(2);handles.cct(1) handles.cct(2);...
        handles.CRI(1) handles.CRI(2); [] []; [] [];[] []; [] [] ;[] []; handles.UVW_u(1) handles.UVW_u(2);...
        handles.UVW_v(1) handles.UVW_v(2); handles.W(1) handles.W(2)};
  
        set(handles.CIE_table,'RowName',rowNames)
        set(handles.CIE_table,'Data',CIE_table_data)        
    end    
    if strcmp(handles.CIE_space,'RGB')==1
        rowNames={'X','Y','Z','CCT','CRI','CQS','CFI','CSI','CDI','','R','G','B','Mod'};
        CIE_table_data={
        handles.X(1) handles.X(2); handles.Y(1) handles.Y(2);...
        handles.Z(1) handles.Z(2);handles.cct(1) handles.cct(2);...
        handles.CRI(1) handles.CRI(2); [] []; [] [];[] []; [] [] ;[] []; handles.R(1) handles.R(2);...
        handles.G(1) handles.G(2); handles.B(1) handles.B(2); handles.RGB_brightness_mod(1) handles.RGB_brightness_mod(2)};
  
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
        
    if size(handles.matching_spectrum_names,2) >= 1
        set(handles.ideal_multiplier_text,'string',num2str(handles.ideal_multiplier(handles.match_active==1)));
    end
    
    if size(handles.alpha,2) >= 1+handles.LED_pagenum*5
        set(handles.LED1_toggle,'Visible','on')
        set(handles.LED1_text,'Visible','on')
        set(handles.LED1_slider,'Visible','on')        
        set(handles.LED1_text,'string',num2str(handles.alpha(1+handles.LED_pagenum*5)));
        set(handles.LED1_slider,'value',handles.alpha(1+handles.LED_pagenum*5));
                
        set(handles.LED1_toggle,'string',num2str(1+handles.LED_pagenum*5));
        set(handles.LED1_toggle,'value',handles.LED_active(1+handles.LED_pagenum*5));  
        
        if handles.slider_holding==0
            if handles.LED_active(1+handles.LED_pagenum*5)==1
               set(handles.LED1_slider,'Enable','on')
               set(handles.LED1_text,'Enable','on')
            else
               set(handles.LED1_slider,'Enable','off')  
               set(handles.LED1_text,'Enable','off')    
            end
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
        
        if handles.slider_holding==0
            if handles.LED_active(2+handles.LED_pagenum*5)==1
               set(handles.LED2_slider,'Enable','on')
               set(handles.LED2_text,'Enable','on')
            else
               set(handles.LED2_slider,'Enable','off')  
               set(handles.LED2_text,'Enable','off')    
            end
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
        if handles.slider_holding==0
            if handles.LED_active(3+handles.LED_pagenum*5)==1
               set(handles.LED3_slider,'Enable','on')
               set(handles.LED3_text,'Enable','on')
            else
               set(handles.LED3_slider,'Enable','off')  
               set(handles.LED3_text,'Enable','off')    
            end        
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
        if handles.slider_holding==0
            if handles.LED_active(4+handles.LED_pagenum*5)==1
               set(handles.LED4_slider,'Enable','on')
               set(handles.LED4_text,'Enable','on')
            else
               set(handles.LED4_slider,'Enable','off')  
               set(handles.LED4_text,'Enable','off')    
            end  
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
        if handles.slider_holding==0
            if handles.LED_active(5+handles.LED_pagenum*5)==1
               set(handles.LED5_slider,'Enable','on')
               set(handles.LED5_text,'Enable','on')
            else
               set(handles.LED5_slider,'Enable','off')  
               set(handles.LED5_text,'Enable','off')    
            end       
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
% 
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

handles.slider_holding=1;
set(handles.LED2_slider,'enable','off');
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
set(handles.LED2_slider,'enable','on');
handles.slider_holding=0;

guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function LED2_slider_CreateFcn(hObject, ~, handles)
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

handles.slider_holding=1;
set(handles.LED3_slider,'enable','off');
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
set(handles.LED3_slider,'enable','on');
handles.slider_holding=0;

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

handles.slider_holding=1;
set(handles.LED4_slider,'enable','off');
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
set(handles.LED4_slider,'enable','on');
handles.slider_holding=0;

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

handles.slider_holding=1;
set(handles.LED5_slider,'enable','off');
handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
set(handles.LED5_slider,'enable','on');
handles.slider_holding=0;

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
handles=replot_color_space(hObject,eventdata,handles);
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


% --- Executes on selection change in reference_illuminant_popup.
function reference_illuminant_popup_Callback(hObject, eventdata, handles)
% hObject    handle to reference_illuminant_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns reference_illuminant_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from reference_illuminant_popup
contents = cellstr(get(hObject,'String'));
handles.standard_illuminant=handles.illuminant_data_xy_2deg(strcmp(handles.illuminant_names,contents{get(hObject,'Value')})==1,:);

handles=refresh(hObject,eventdata,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function reference_illuminant_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reference_illuminant_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in units_popup.
function units_popup_Callback(hObject, eventdata, handles)
% hObject    handle to units_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns units_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from units_popup
contents = cellstr(get(hObject,'String'));
handles.unit_type=contents{get(hObject,'Value')};

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function units_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to units_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on import_LED_pushbutton and none of its controls.
function import_LED_pushbutton_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to import_LED_pushbutton (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in unit_conversion_popup.
function unit_conversion_popup_Callback(hObject, eventdata, handles)
% hObject    handle to unit_conversion_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns unit_conversion_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from unit_conversion_popup


% --- Executes during object creation, after setting all properties.
function unit_conversion_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unit_conversion_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ideal_multiplier_text_Callback(hObject, eventdata, handles)
% hObject    handle to ideal_multiplier_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ideal_multiplier_text as text
%        str2double(get(hObject,'String')) returns contents of ideal_multiplier_text as a double
handles.match_data(:,handles.match_active==1)=handles.match_data(:,handles.match_active==1)/handles.ideal_multiplier(handles.match_active==1);
handles.ideal_multiplier(handles.match_active==1)=str2double(get(hObject,'String'));
handles.match_data(:,handles.match_active==1)=handles.match_data(:,handles.match_active==1)*handles.ideal_multiplier(handles.match_active==1);

handles=refresh(hObject,eventdata,handles);
handles=replot(hObject,eventdata,handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ideal_multiplier_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ideal_multiplier_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
