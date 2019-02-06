function varargout = manual_interface(varargin)
% MANUAL_INTERFACE MATLAB code for manual_interface.fig
%      MANUAL_INTERFACE, by itself, creates a new MANUAL_INTERFACE or raises the existing
%      singleton*.
%
%      H = MANUAL_INTERFACE returns the handle to a new MANUAL_INTERFACE or the handle to
%      the existing singleton*.
%
%      MANUAL_INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUAL_INTERFACE.M with the given input arguments.
%
%      MANUAL_INTERFACE('Property','Value',...) creates a new MANUAL_INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before manual_interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to manual_interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help manual_interface

% Last Modified by GUIDE v2.5 15-Jan-2019 15:25:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @manual_interface_OpeningFcn, ...
                   'gui_OutputFcn',  @manual_interface_OutputFcn, ...
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


% --- Executes just before manual_interface is made visible.
function manual_interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to manual_interface (see VARARGIN)

% Choose default command line output for manual_interface
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes manual_interface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = manual_interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editSeed_Callback(hObject, eventdata, handles)
% hObject    handle to editSeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSeed as text
%        str2double(get(hObject,'String')) returns contents of editSeed as a double


% --- Executes during object creation, after setting all properties.
function editSeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnTrain.
function btnTrain_Callback(hObject, eventdata, handles)
% hObject    handle to btnTrain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
features = [];
checkHog = findobj(0, 'tag', 'checkHog');
checkEcc = findobj(0, 'tag', 'checkEcc');
checkSurf = findobj(0, 'tag', 'checkSurf');
checkLbp = findobj(0, 'tag', 'checkLBP');
editSeed = findobj(0, 'tag', 'editSeed');
textAccuracy = findobj(0, 'tag', 'textAccuracy');
textVectors = findobj(0, 'tag', 'textVectors');
textFeatures = findobj(0, 'tag', 'textFeatures');
btnConfusion = findobj(0, 'tag', 'btnConfusion');
btnPredict = findobj(0, 'tag', 'btnPredict');
set(textAccuracy, 'String', '-');
set(textFeatures, 'String', '-');
set(textVectors, 'String', '-');
set(btnConfusion, 'Enable', 'off');
if get(checkHog, 'Value')
   features = [features, "Hog"]; 
end

if get(checkEcc, 'Value')
   features = [features, "Eccentricity"]; 
end

if get(checkSurf, 'Value')
   features = [features, "Surf"]; 
end

if get(checkLbp, 'Value')
   features = [features, "Lbp"]; 
end

set(handles.figure1, 'pointer', 'watch')
drawnow;
eyePredictor = EyeDetector(features, uint8(get(editSeed, 'Value')));
[error, confusion] = eyePredictor.testClassifier();
accuracy = 1.0 - error;
set(handles.figure1, 'pointer', 'arrow')

set(textAccuracy, 'String', strcat(num2str(accuracy*100), '%'));
set(textVectors, 'String', strcat(num2str(size(eyePredictor.EyeSVM.SupportVectors,1)), ' vectors'));
set(textFeatures, 'String', features);
if ~isprop(btnConfusion, 'ConfusionMatrix')
    addprop(btnConfusion, 'ConfusionMatrix');
end
if ~isprop(btnPredict, 'EyePredictor')
    addprop(btnPredict, 'EyePredictor')
end
set(btnConfusion, 'ConfusionMatrix', confusion);
set(btnConfusion, 'Enable', 'on');
set(btnPredict, 'EyePredictor', eyePredictor);

% --- Executes on key press with focus on btnTrain and none of its controls.
function btnTrain_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to btnTrain (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkHog.
function checkHog_Callback(hObject, eventdata, handles)
% hObject    handle to checkHog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkHog


% --- Executes on button press in checkEcc.
function checkEcc_Callback(hObject, eventdata, handles)
% hObject    handle to checkEcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkEcc


% --- Executes on button press in checkSurf.
function checkSurf_Callback(hObject, eventdata, handles)
% hObject    handle to checkSurf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSurf


% --- Executes on button press in checkLBP.
function checkLBP_Callback(hObject, eventdata, handles)
% hObject    handle to checkLBP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkLBP


% --- Executes on button press in checkHaar.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkHaar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkHaar


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in btnConfusion.
function btnConfusion_Callback(hObject, eventdata, handles)
% hObject    handle to btnConfusion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
conf = hObject.ConfusionMatrix;
figure;
confusionchart(conf,'RowSummary','row-normalized','ColumnSummary','column-normalized');


function editSeedG_Callback(hObject, eventdata, handles)
% hObject    handle to editSeedG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSeedG as text
%        str2double(get(hObject,'String')) returns contents of editSeedG as a double


% --- Executes during object creation, after setting all properties.
function editSeedG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSeedG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnTrainG.
function btnTrainG_Callback(hObject, eventdata, handles)
% hObject    handle to btnTrainG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
features = [];
checkHog = findobj(0, 'tag', 'checkHogG');
checkEcc = findobj(0, 'tag', 'checkEccG');
checkSurf = findobj(0, 'tag', 'checkSurfG');
checkLbp = findobj(0, 'tag', 'checkLBPG');
editSeed = findobj(0, 'tag', 'editSeedG');
textAccuracy = findobj(0, 'tag', 'textAccuracyG');
textVectors = findobj(0, 'tag', 'textVectorsG');
textFeatures = findobj(0, 'tag', 'textFeaturesG');
btnConfusion = findobj(0, 'tag', 'btnConfusionG');
btnPredict = findobj(0, 'tag', 'btnPredict');
set(textAccuracy, 'String', '-');
set(textFeatures, 'String', '-');
set(textVectors, 'String', '-');
set(btnConfusion, 'Enable', 'off');
if get(checkHog, 'Value')
   features = [features, "Hog"]; 
end

if get(checkEcc, 'Value')
   features = [features, "Eccentricity"]; 
end

if get(checkSurf, 'Value')
   features = [features, "Surf"]; 
end

if get(checkLbp, 'Value')
   features = [features, "Lbp"]; 
end

set(handles.figure1, 'pointer', 'watch')
drawnow;
gazePredictor = GazeDetector(features, uint8(get(editSeed, 'Value')));
[error, confusion] = gazePredictor.testClassifier();
accuracy = 1.0 - error;
set(handles.figure1, 'pointer', 'arrow')

set(textAccuracy, 'String', strcat(num2str(accuracy*100), '%'));
set(textVectors, 'String', strcat(num2str(size(gazePredictor.GazeSVM.SupportVectors,1)), ' vectors'));
set(textFeatures, 'String', features);
if ~isprop(btnConfusion, 'ConfusionMatrix')
    addprop(btnConfusion, 'ConfusionMatrix');
end
if ~isprop(btnPredict, 'GazePredictor')
    addprop(btnPredict, 'GazePredictor')
end
set(btnConfusion, 'ConfusionMatrix', confusion);
set(btnConfusion, 'Enable', 'on');
set(btnPredict, 'GazePredictor', gazePredictor);


% --- Executes on button press in btnConfusionG.
function btnConfusionG_Callback(hObject, eventdata, handles)
% hObject    handle to btnConfusionG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
conf = hObject.ConfusionMatrix;
figure;
confusionchart(conf,'RowSummary','row-normalized','ColumnSummary','column-normalized');

% --- Executes on button press in btnPredict.
function btnPredict_Callback(hObject, eventdata, handles)
% hObject    handle to btnPredict (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
EyePredictor = hObject.EyePredictor;
GazePredictor = hObject.GazePredictor;
editImageChoose = findobj(0, 'tag', 'editImageChoose');
textGaze = findobj(0, 'tag', 'textGaze');
textX1 = findobj(0, 'tag', 'textX1');
textX2 = findobj(0, 'tag', 'textX2');
textY1 = findobj(0, 'tag', 'textY1');
textY2 = findobj(0, 'tag', 'textY2');
set(textGaze, 'String', '?');
set(textX1, 'String', '?');
set(textY1, 'String', '?');
set(textX2, 'String', '?');
set(textY2, 'String', '?');

set(handles.figure1, 'pointer', 'watch')
drawnow;

image = imread(get(editImageChoose, 'String'));
figure;
imshow(image);
coords = EyePredictor.findEyesCoords(image);
if ~isempty(coords)
    hold on;
    rectangle('Position', coords, 'EdgeColor', 'g', 'LineWidth', 2);
    
    % Update panel
    set(textX1, 'String', num2str(coords(2)));
    set(textY1, 'String', num2str(coords(1)));
    set(textX2, 'String', num2str(coords(2) + coords(3)));
    set(textY2, 'String', num2str(coords(1) + coords(4)));
    
    % Predict gaze
    eyes = imcrop(image, coords);
    eyes = imresize(eyes, [25, 80]);
    eyes = rgb2gray(eyes);
    gaze = GazePredictor.predictData(eyes);
    if gaze == 1
        gaze = 'Yes';
    else
        gaze = 'No';
    end
    set(textGaze, 'String', gaze);
end

set(handles.figure1, 'pointer', 'arrow')


function editImageChoose_Callback(hObject, eventdata, handles)
% hObject    handle to editImageChoose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editImageChoose as text
%        str2double(get(hObject,'String')) returns contents of editImageChoose as a double


% --- Executes during object creation, after setting all properties.
function editImageChoose_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editImageChoose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnImageChoose.
function btnImageChoose_Callback(hObject, eventdata, handles)
% hObject    handle to btnImageChoose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file,path] = uigetfile();
editFileChoose = findobj(0, 'tag', 'editImageChoose');
btnPredict = findobj(0, 'tag', 'btnPredict');
set(editFileChoose, 'String', fullfile(path, file));
if ~isequal(file,0) && isprop(btnPredict, 'EyePredictor') && isprop(btnPredict, 'GazePredictor')
    set(btnPredict, 'Enable', 'on');    
else
    set(btnPredict, 'Enable', 'off');
end

% --- Executes on button press in checkEccG.
function checkEccG_Callback(hObject, eventdata, handles)
% hObject    handle to checkEccG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkEccG


% --- Executes on button press in checkbox18.
function checkbox18_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox18


% --- Executes on button press in checkbox17.
function checkbox17_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox17


% --- Executes on button press in checkbox16.
function checkbox16_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox16


% --- Executes on button press in checkHaarG.
function checkHaarG_Callback(hObject, eventdata, handles)
% hObject    handle to checkHaarG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkHaarG


% --- Executes on button press in checkLBPG.
function checkLBPG_Callback(hObject, eventdata, handles)
% hObject    handle to checkLBPG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkLBPG


% --- Executes on button press in checkSurfG.
function checkSurfG_Callback(hObject, eventdata, handles)
% hObject    handle to checkSurfG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSurfG


% --- Executes on button press in checkHogG.
function checkHogG_Callback(hObject, eventdata, handles)
% hObject    handle to checkHogG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkHogG


% --- Executes on key press with focus on btnImageChoose and none of its controls.
function btnImageChoose_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to btnImageChoose (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox19.
function checkbox19_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox19


% --- Executes on button press in checkbox20.
function checkbox20_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox20


% --- Executes on button press in checkbox21.
function checkbox21_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox21


% --- Executes on button press in checkbox22.
function checkbox22_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox22


% --- Executes on button press in checkHaar.
function checkHaar_Callback(hObject, eventdata, handles)
% hObject    handle to checkHaar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkHaar


% --- Executes on button press in checkbox24.
function checkbox24_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox24


% --- Executes on button press in checkbox25.
function checkbox25_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox25


% --- Executes on button press in checkbox26.
function checkbox26_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox26
