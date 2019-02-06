function varargout = cross_eval(varargin)
% CROSS_EVAL MATLAB code for cross_eval.fig
%      CROSS_EVAL, by itself, creates a new CROSS_EVAL or raises the existing
%      singleton*.
%
%      H = CROSS_EVAL returns the handle to a new CROSS_EVAL or the handle to
%      the existing singleton*.
%
%      CROSS_EVAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CROSS_EVAL.M with the given input arguments.
%
%      CROSS_EVAL('Property','Value',...) creates a new CROSS_EVAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cross_eval_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cross_eval_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cross_eval

% Last Modified by GUIDE v2.5 15-Jan-2019 15:23:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cross_eval_OpeningFcn, ...
                   'gui_OutputFcn',  @cross_eval_OutputFcn, ...
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


% --- Executes just before cross_eval is made visible.
function cross_eval_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cross_eval (see VARARGIN)

% Choose default command line output for cross_eval
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cross_eval wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cross_eval_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnCross.
function btnCross_Callback(hObject, eventdata, handles)
% hObject    handle to btnCross (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
features = [];
checkHog = findobj(0, 'tag', 'checkHog');
checkEcc = findobj(0, 'tag', 'checkEcc');
checkSurf = findobj(0, 'tag', 'checkSurf');
checkLbp = findobj(0, 'tag', 'checkLBP');
checkHaar = findobj(0, 'tag', 'checkHaar');

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

if get(checkHaar, 'Value')
   features = [features, "Haar"]; 
end

count = 0;
f = waitbar(0, "");
file = fopen('cross_eval_Eyes.txt', 'wt');
best_accuracy = 0;
best_result = [];
for i = 1 : size(features,2)
    combos = nchoosek(features, i);
    for j = 1 : size(combos, 1)
        waitbar(count / (2^size(features, 2) - 1), f, combos(j, :));
        mean_accuracy = 0;
        mean_vectors    = 0;
        for k = 1 : 5
            eyeDet = EyeDetector(combos(j, :), randi(100000));
            [error, confusion] = eyeDet.testClassifier();
            accuracy = 1.0 - error;
            mean_accuracy = mean_accuracy + accuracy;
            mean_vectors = mean_vectors + size(eyeDet.EyeSVM.SupportVectors, 1);
        end
        mean_accuracy = mean_accuracy / 5;
        mean_vectors = mean_vectors / 5;
        fprintf(file, '\n#####');
        for k = 1 : size(combos, 2)
            fprintf(file, strcat({' '}, combos(j, k)));
        end
        fprintf(file, '#####');
        fprintf(file, strcat('\nAccuracy: ', num2str(mean_accuracy)));
        fprintf(file, strcat('\nSupport Vectors: ', num2str(mean_vectors)));
        fprintf(file, '\n################################');
        
        if mean_accuracy >= best_accuracy
            best_accuracy = mean_accuracy;
            best_result = combos(j, :);
        end
        count = count + 1;
    end
end

fprintf(file, '\nBEST RESULT: ');
for k = 1 : size(best_result, 2)
    fprintf(file, strcat({' '}, best_result(1, k)));
end
fclose(file);
delete(f);


% --- Executes on button press in btnCrossG.
function btnCrossG_Callback(hObject, eventdata, handles)
% hObject    handle to btnCrossG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
features = [];
checkHog = findobj(0, 'tag', 'checkHogG');
checkEcc = findobj(0, 'tag', 'checkEccG');
checkSurf = findobj(0, 'tag', 'checkSurfG');
checkLbp = findobj(0, 'tag', 'checkLBPG');
checkHaar = findobj(0, 'tag', 'checkHaarG');

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

if get(checkHaar, 'Value')
   features = [features, "Haar"]; 
end

count = 0;
f = waitbar(0, "");
file = fopen('cross_eval_Gaze.txt', 'wt');
best_accuracy = 0;
best_result = [];
for i = 1 : size(features,2)
    combos = nchoosek(features, i);
    for j = 1 : size(combos, 1)
        waitbar(count / (2^size(features, 2) - 1), f, combos(j, :));
        mean_accuracy = 0;
        mean_vectors = 0;
        for k = 1 : 5
            eyeDet = GazeDetector(combos(j, :), randi(100000));
            [error, confusion] = eyeDet.testClassifier();
            accuracy = 1.0 - error;
            mean_accuracy = mean_accuracy + accuracy;
            mean_vectors = mean_vectors + size(eyeDet.GazeSVM.SupportVectors, 1);
        end
        mean_accuracy = mean_accuracy / 5;
        mean_vectors = mean_vectors / 5;
        fprintf(file, '\n#####');
        for k = 1 : size(combos, 2)
            fprintf(file, strcat({' '}, combos(j, k)));
        end
        fprintf(file, '#####');
        fprintf(file, strcat('\nAccuracy: ', num2str(mean_accuracy)));
        fprintf(file, strcat('\nSupport Vectors: ', num2str(mean_vectors)));
        fprintf(file, '\n################################');
        
        if mean_accuracy >= best_accuracy
            best_accuracy = mean_accuracy;
            best_result = combos(j, :);
        end
        count = count + 1;
    end
end

fprintf(file, '\nBEST RESULT: ');
for k = 1 : size(best_result, 2)
    fprintf(file, strcat({' '}, best_result(1, k)));
end
fclose(file);
delete(f);

% --- Executes on button press in checkEccG.
function checkEccG_Callback(hObject, eventdata, handles)
% hObject    handle to checkEccG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkEccG


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


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
function checkHaar_Callback(hObject, eventdata, handles)
% hObject    handle to checkHaar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkHaar


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


% --- Executes on button press in checkbox8.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox8


% --- Executes on button press in checkHog.
function checkHog_Callback(hObject, eventdata, handles)
% hObject    handle to checkHog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkHog
