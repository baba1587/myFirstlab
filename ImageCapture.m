function varargout = ImageCapture(varargin)
% ImageCapture MATLAB code for ImageCapture.fig
% When u use this code,you need to change the output paths :)
%      ImageCapture, by itself, creates a new ImageCapture or raises the existing
%      singleton*.
%
%      H = ImageCapture returns the handle to a new ImageCapture or the handle to
%      the existing singleton*.
%
%      ImageCapture('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ImageCapture.M with the given input arguments.
%
%      ImageCapture('Property','Value',...) creates a new ImageCapture or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageCapture_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageCapture_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageCapture

% Last Modified by GUIDE v2.5 29-Aug-2020 00:04:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageCapture_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageCapture_OutputFcn, ...
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

% --- Executes just before ImageCapture is made visible. 
function ImageCapture_OpeningFcn(hObject, eventdata, handles, varargin) %Initialized things you need.
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageCapture (see VARARGIN)
    
    %Global Vars
    handles.ImageNo = 0;
    handles.CamVideo = [];
    handles.MacVideoInfo = [];
    handles.previewed = 0;
    handles.seqstop = 1;
    handles.img_num = 0;
    global save_camera_paras_filename
    global ncounts
    global seqcounts
    global filename1
    global img_num
    global hhh
    global images_for_calib_path
    hhh =1 ;
    filename1 = '';
    seqcounts = 0;
    ncounts = 0;
    img_num = 0;
    images_for_calib_path = '';
    save_camera_paras_filename = '';
% Choose default command line output for ImageCapture
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImageCapture wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = ImageCapture_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles) %Camera Initializer
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  % handles.peaks = peaks(35);
  % handles.membrane = membrane;
  % [x,y] = meshgrid(-8:.5:8);r = sqrt(x.^2+y.^2) + eps;
  % sinc = sin(r)./r; handles.sinc = sinc;
  % handles.current_data = handles.peaks;
  % axes(handles.axes1);surf(handles.current_data);
CameraInfo = imaqhwinfo('winvideo'); %computer Afeng
handles.MacvideoInfo = CameraInfo;  
handles.CamVideo = videoinput('winvideo',1,'MJPG_640x480'); % ('winvideo',1,'RGB24_640x480'); 

guidata(hObject, handles);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles) %open Camera
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(handles.CamVideo)    
%     set(gcf,'CurrentAxes',handles.Axes1);
%     vidRes = get(handles.CamVideo, 'VideoResolution');
%     nBands = get(handles.CamVideo, 'NumberOfBands');
%     hImage = imshow(zeros(vidRes(2), vidRes(1), nBands));
%     preview(handles.CamVideo, hImage);
%     handles.previewed = 1;
    set(handles.CamVideo,'FramesPerTrigger',1);
    set(handles.CamVideo,'TriggerRepeat',Inf);
    vidRes = get(handles.CamVideo, 'VideoResolution');
    nBands = get(handles.CamVideo, 'NumberOfBands');
    axes(handles.axes1)
    hImage = imshow(zeros(vidRes(2), vidRes(1), nBands));
    preview(handles.CamVideo,hImage);
    handles.previewed = 1;
else 
    disp('no camera!')
end
guidata(hObject, handles);  

% --- Executes on button press in pushbutton3. 
function pushbutton3_Callback(hObject, eventdata, handles)  %Snapshot
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ileftframe
if handles.previewed>0
    ileftframe = getsnapshot(handles.CamVideo);
    axes(handles.axes2)   
    imshow(ileftframe);
else 
    disp('The cameras have not been opened!');
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles) %save currentImg
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ileftframe
if isempty(handles.axes2) %|| isempty(handles.rightframe)
    disp('There is no image for saving!!');
    return
end

[FileName,PathName] = uiputfile({'*.jpg','JPEG(*.jpg)';...
                                 '*.bmp','Bitmap(*.bmp)';...
                                 '*.gif','GIF(*.gif)';...
                                 '*.*',  'All Files (*.*)'},...
                                 'Save Picture','ImageCapture');
if FileName==0
    return;
else
    %h=getframe(handles.axes2);
    imwrite(ileftframe,[PathName,FileName]);
end

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles) % seq savePath
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in pushbutton7.
global foldername

foldername = uigetdir('D://');
mkdir(foldername);
disp(foldername);

guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)  %seq start
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global foldername
global flag
global filename1 
global ncounts
flag = 0;
if handles.previewed > 0
    while (flag == 0)
        pause(0.00001)
        iframe = getsnapshot(handles.CamVideo);
        iframe = im2double(iframe);
        filename1 = [foldername,'/SeqImg',num2str(ncounts),'.jpg'];
        imwrite(iframe,filename1);
        ncounts=ncounts+1;
        disp(sprintf('ncounts = %d',ncounts));
        %global flag
        %global ncounts
        %if isletter(get(gcf,'CurrentCharacter'))
        %   break;
        %end
    end
else
    disp('no camera!')
end
guidata(hObject, handles);

function pushbutton7_Callback(hObject, eventdata, handles) %close
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA) 
close all

% --------------------------------------------------------------------
function ImageCapture_1_Callback(hObject, eventdata, handles)
% hObject    handle to ImageCapture_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function ImageCapture_2_Callback(hObject, eventdata, handles)
% hObject    handle to ImageCapture_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%togbutton code
% % --- Executes on button press in togglebutton1.
% function togglebutton1_Callback(hObject, eventdata, handles) %Seq Stop
% % hObject    handle to togglebutton1 (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% % Hint: get(hObject,'Value') returns toggle state of togglebutton1
% global flag
% 
% if get(handles.togglebutton1,'Value') == 1 
%     flag = 1;
% end
% if get(handles.togglebutton1,'Value') == 0 
%     flag = 0;
% end
% guidata(hObject, handles);

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles) %seq stop
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global flag
global ncounts
global seqcounts
if handles.previewed > 0
    flag = 1;
    disp('stop seq');
    if ncounts > 0
        seqcounts = ncounts;
        ncounts = 0;
    end
else
    disp('not open camera!');
end
disp(sprintf('seqcounts = %d',seqcounts));
disp(sprintf('ncounts = %d',ncounts));
guidata(hObject,handles);


% --- Executes on button press in pushbutton11. 
function pushbutton11_Callback(hObject, eventdata, handles) %seq continue 
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global foldername
global flag
global seqcounts
flag = 0;
if handles.previewed > 0
    while (flag == 0)
        %global flag
        ss = seqcounts;
        pause(0.0001)
        ileftframe = getsnapshot(handles.CamVideo);
        ileftframe = im2double(ileftframe);
        filename1 = [foldername,'/SeqImg',num2str(ss),'.jpg'];
        imwrite(ileftframe,filename1);
        ss= ss+1;
        seqcounts=ss;
        disp(sprintf('seqcounts = %d',seqcounts));
        %if isletter(get(gcf,'CurrentCharacter'))
         %   break;
        %end
    end
else
    disp('no camera!');
end
guidata(hObject, handles);

% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles) %seq loop 
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global foldername
global jjj
global hhh
file_path = sprintf('%s/',foldername);
img_path_list = dir(strcat(file_path,'*.jpg'));
handles.img_num = length(img_path_list);
handles.img_num = handles.img_num - 1;
set(handles.slider1,'Min',0,'Max',handles.img_num,'value',0);
disp('The scanned sequence image has been loaded.lease slide the sliderbar to view what u wanna see.')
jjj=1;

while 1
    while hhh ~= 1
        jjj = hhh;
        disp(jjj);
        hhh = 1;
        break;
    end
    if (jjj ~= (handles.img_num))
        set(handles.slider1,'value',jjj);
        set(handles.text3,'String',num2str(round(jjj-1)));
        %j = str2num(get(j),'string');
        disp(sprintf('the current number of the image is %d',jjj-1));
        image_name = img_path_list(jjj).name;
        image = imread(strcat(file_path,image_name));
        axes(handles.axes2);
        imshow(image);
        %set(handles,slider1,'value',jjj);
        pause(1);
        jjj = jjj+1;
    else
        disp('loop restart.');
        jjj = 1;
    end
end

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)    
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
%global image
global foldername
global hhh
global a
global fname

a = get(handles.slider1,'value');

if rem(a,1)~=0
    set(handles.text3,'String',num2str(round(a)));
    fname = [foldername,'/SeqImg',num2str(round(a)),'.jpg'];
end    
axes(handles.axes2);
imshow(fname);
hhh = round(a);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.axes2,'visible','on');
set(handles.slider1,'visible','on');
set(handles.pushbutton1,'visible','on');
set(handles.pushbutton2,'visible','on');
set(handles.pushbutton3,'visible','on');
set(handles.pushbutton4,'visible','on');
set(handles.pushbutton6,'visible','on');
set(handles.text2,'visible','on');
set(handles.pushbutton7,'visible','on');
set(handles.pushbutton8,'visible','on');
set(handles.pushbutton10,'visible','on');
set(handles.pushbutton11,'visible','on');
set(handles.pushbutton12,'visible','on');
set(handles.text3,'visible','on');
set(handles.axes1,'visible','on');
set(handles.pushbutton15,'visible','off');
set(handles.pushbutton16,'visible','off');
set(handles.pushbutton17,'visible','off');
%set(handles.pushbutton18,'visible','off');
%set(handles.,'visible','');
set(handles.pushbutton19,'visible','off');
set(handles.pushbutton20,'visible','off');
set(handles.axes4,'visible','off');
set(handles.pushbutton21,'visible','off');

% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.axes1,'visible','off');
set(handles.axes2,'visible','off');
set(handles.slider1,'visible','off');
set(handles.pushbutton1,'visible','off');
set(handles.pushbutton2,'visible','off');
set(handles.pushbutton3,'visible','off');
set(handles.pushbutton4,'visible','off');
set(handles.pushbutton6,'visible','off');
set(handles.text2,'visible','off');
set(handles.pushbutton7,'visible','off');
set(handles.pushbutton8,'visible','off');
set(handles.pushbutton10,'visible','off');
set(handles.pushbutton11,'visible','off');
set(handles.pushbutton12,'visible','off');
set(handles.text3,'visible','off');
set(handles.pushbutton15,'visible','on');
set(handles.pushbutton16,'visible','on');
set(handles.pushbutton17,'visible','on');
%set(handles.pushbutton18,'visible','on');
set(handles.pushbutton19,'visible','off');
set(handles.pushbutton20,'visible','off');
set(handles.axes4,'visible','off');
set(handles.pushbutton21,'visible','off');

% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.axes1,'visible','off');
set(handles.axes2,'visible','off');
set(handles.slider1,'visible','off');
set(handles.pushbutton1,'visible','off');
set(handles.pushbutton2,'visible','off');
set(handles.pushbutton3,'visible','off');
set(handles.pushbutton4,'visible','off');
set(handles.pushbutton6,'visible','off');
set(handles.text2,'visible','off');
set(handles.pushbutton7,'visible','off');
set(handles.pushbutton8,'visible','off');
set(handles.pushbutton10,'visible','off');
set(handles.pushbutton11,'visible','off');
set(handles.pushbutton12,'visible','off');
set(handles.text3,'visible','off');
set(handles.pushbutton15,'visible','off');
set(handles.pushbutton16,'visible','off');
set(handles.pushbutton17,'visible','off');
set(handles.pushbutton19,'visible','on');
set(handles.pushbutton20,'visible','on');
set(handles.axes4,'visible','on');
set(handles.pushbutton21,'visible','on');

% function camera_paras = monocular_camera_calibration(images_for_calib_path)
% 
% images = imageDatastore(images_for_calib_path,'FileExtensions',{'.jpg'});
% [imagePoints,boardSize] = detectCheckerboardPoints(images.Files);
% squareSize = 30;
% worldPoints = generateCheckerboardPoints(boardSize,squareSize);
% I = readimage(images,1); 
% imageSize = [size(I,1),size(I,2)];
% camera_paras = estimateCameraParameters(imagePoints,worldPoints, 'ImageSize',imageSize,...
%     'EstimateSkew',true ,'NumRadialDistortionCoefficients',2,'EstimateTangentialDistortion',true);

% --- Executes on button press in pushbutton15.
function pushbutton15_Callback(hObject, eventdata, handles) %images_for_calib_path
% hObject    handle to pushbutton15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global images_for_calib_path

images_for_calib_path = uigetdir('D://');
mkdir(images_for_calib_path);
disp(images_for_calib_path);

guidata(hObject, handles);


% --- Executes on button press in pushbutton16.
function pushbutton16_Callback(hObject, eventdata, handles) %
% hObject    handle to pushbutton16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global images_for_calib_path
global camera_paras
tic
images = imageDatastore(images_for_calib_path,'FileExtensions',{'.jpg'});
[imagePoints,boardSize] = detectCheckerboardPoints(images.Files);
squareSize = 30;
worldPoints = generateCheckerboardPoints(boardSize,squareSize);
I = readimage(images,1); 
imageSize = [size(I,1),size(I,2)];
camera_paras = estimateCameraParameters(imagePoints,worldPoints,...
    'ImageSize',imageSize,...
    'EstimateSkew',true ,'NumRadialDistortionCoefficients',2,...
    'EstimateTangentialDistortion',true);
toc
disp('Calibration works has done');


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global camera_paras
global save_camera_paras_filename

save_camera_paras_filename = uigetdir('D://');
mkdir(save_camera_paras_filename);
save
disp(save_camera_paras_filename);
save_camera_paras_filename = [save_camera_paras_filename,...
                              '/camera_parameters.mat'];
save(save_camera_paras_filename,'camera_paras');
disp(sprintf('The camera paras has been saved at %s'...
        ,save_camera_paras_filename));

% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles) %load the camera calibrated parameters
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global import_camera_paras_path
tic
[import_camera_paras_file,import_camera_paras_path,indx] = uigetfile;
if isequal(import_camera_paras_file,0)
   disp('User selected Cancel')
else
   disp(['You selected ', fullfile(import_camera_paras_path, import_camera_paras_file),... 
         ' and filter index: ', num2str(indx)])
end
import_camera_paras_path = [import_camera_paras_path,import_camera_paras_file];
%camera_paras1 = load(import_camera_paras_path,'camera_paras');
disp('file import success!');

guidata(hObject, handles);

% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles) %load the captured marker image
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global loadimage
[im_orig,path] = uigetfile('*.jpg',...
               'Select an icon file','icon.jpg')
im_orig = [path,im_orig];

loadimage = imread(im_orig);
disp('file import success!');

guidata(hObject, handles);


% --- Executes on button press in pushbutton21.
function pushbutton21_Callback(hObject, eventdata, handles) %start position calibration
% hObject    handle to pushbutton21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global import_camera_paras_path
%global camera_paras1
global loadimage

load(import_camera_paras_path,'camera_paras');
im_gray = rgb2gray(loadimage);
[im_undised, newOrigin] = undistortImage(im_gray,camera_paras, 'OutputView','full');

C0 = corner(im_undised);
[ncorners,ndim] = size(C0);
Cleft = [];
Cright = [];
if ncorners<3   
    return
end

Iedge = edge(im_undised,'Sobel');
se = ones(3,3);
Iedgemask= imdilate(Iedge,se);
[Ilabels,nlabels] =  bwlabel(Iedgemask);   %return the number of labels.
if nlabels <1
    return
end

[nrow,ncol] = size(im_undised                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              );siz=[nrow,ncol];
indx_C0 = sub2ind(siz,C0(:,2),C0(:,1));   % Convert subscripts to linear indices.
C0_labels = Ilabels(indx_C0);       

Tratio_left = 0.75;
Tratio_right = 0.75;
for i=1:nlabels
    ilabel = i;
    idx_tempcorners =  find(C0_labels==ilabel);
    if length(idx_tempcorners)<3
        continue;
    else
        tempC = C0(idx_tempcorners,:);
        [xleft,idx_mostleft]=min(tempC(:,1));
        yleft = tempC(idx_mostleft,2);
        [xright,idx_mostright]=max(tempC(:,1));
        yright = tempC(idx_mostright,2);
        [ytop,idx_mosttop]=min(tempC(:,2)); % wrong?
        xtop = tempC(idx_mosttop,1);
        [ylow,idx_mostlow]=max(tempC(:,2));
        xlow = tempC(idx_mostlow,1);        
       
        lr_length = sqrt((xright-xleft)^2+(yright-yleft)^2); 
        
        lt_length = sqrt((xleft-xtop)^2+(yleft-ytop)^2);
        rt_length = sqrt((xright-xtop)^2+(yright-ytop)^2);        
        lmin=min([lt_length,lr_length,rt_length]);
        lmax=max([lt_length,lr_length,rt_length]);
        lratio_left= lmin/lmax;
        
        lb_length = sqrt((xleft-xlow)^2+(yleft-ylow)^2);
        rb_length = sqrt((xright-xlow)^2+(yright-ylow)^2);        
        lmin=min([lb_length,lr_length,rb_length]);
        lmax=max([lb_length,lr_length,rb_length]);
        lratio_right = lmin/lmax;
        
        if lratio_left > Tratio_left
            Cleft =[[xleft,xtop,xright];[yleft,ytop,yright]]';
            Tratio_left = lratio_left;            
        end
        
        if lratio_right > Tratio_right
            Cright =[[xleft,xlow,xright];[yleft,ylow,yright]]';
            Tratio_right = lratio_right;            
        end
        
    end
    
end

%Store the target point in imagePoints
if isempty(Cleft) || isempty(Cright)
    cameraPoints = [];
    imagePoints = [];
    disp('I can not find out the target corners!!!');
    return;
else 
    imagePoints=zeros([6,2]);
    imagePoints(1:3,:)=Cleft;
    imagePoints(4:6,:)=Cright;    
end
imagePoints_orig = imagePoints; % points in the intrinsic coordinates of output image
imagePoints = imagePoints + newOrigin; % points in the intrinsic coordinates of input image

%the world coordinate
worldPoints = [[43.0,6.7];[8.0,28.8];[44.0,49.0];[8.3,42.2];[44.0,62.0];[9.0,83.0]];

%calculate the extrinsics 
%Compute location of calibrated camera
%[rotationMatrix,translationVector] = extrinsics(imagePoints,worldPoints,cameraParams)
% R[3x3] matrix t[1x3]matrix 
[R, t] = extrinsics(imagePoints, worldPoints, camera_paras);

%the world coordinates are transformed to the camera coordinates
cameraPoints = zeros([6,3]);
for i = 1:6
    tempPoint = R*[worldPoints(i,:),0]'+t';
    cameraPoints(i,:) = tempPoint;
end

axes(handles.axes4);
imshow(im_undised,[]);
hold on;
plot(imagePoints_orig(:,1),imagePoints_orig(:,2),'ro');
disp('please see the result!');
toc
