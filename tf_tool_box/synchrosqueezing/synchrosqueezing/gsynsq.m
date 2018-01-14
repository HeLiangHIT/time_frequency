function varargout = gsynsq(varargin)
% function hgui = gsynsq()
%
% Runs the Synchrosqueezing toolbox GUI.
% Does not require input parameters.  Returns a handle to the GUI.
%
% This GUI tool can be used for speedy/rough Synchrosqueezing
% analysis, filtering, component extraction of signals.
% 
%
%---------------------------------------------------------------------------------
%    Synchrosqueezing Toolbox
%    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)
%---------------------------------------------------------------------------------

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gsynsq_OpeningFcn, ...
                   'gui_OutputFcn',  @gsynsq_OutputFcn, ...
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

% --- Executes just before gsynsq is made visible.
function gsynsq_OpeningFcn(hObj, eventdata, hs, varargin)
% This function has no output args, see OutputFcn.
% hObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
% varargin   command line arguments to gsynsq (see VARARGIN)

% Choose default command line output for gsynsq
hs.output = hObj;

% This sets up the initial plot - only do when we are invisible
% so window can get raised using gsynsq.
if strcmp(get(hObj,'Visible'),'off')
    set(hs.axesx, 'Visible', 'off');
    set(hs.axesTx, 'Visible', 'off');
    set(hs.axesrx, 'Visible', 'off');
    
    % Set up zoom
    zh = zoom;

    setAllowAxesZoom(zh, hs.axesx, true);
    setAllowAxesZoom(zh, hs.axesTx, true);
    setAllowAxesZoom(zh, hs.axesrx, true);

    % Link the axes w.r.t. zoom (just the t-axis component)
    linkaxes([hs.axesx hs.axesTx hs.axesrx], 'x');
    
    % Menu bar with "reset axes" does not work with linked axes
    set(zh, 'RightClickAction', 'InverseZoom');

    % Append any past ActionPostCallBack to run first
    %set(zh, 'ActionPostCallback', @postZoomUpdate);

    % Allow zoom
    set(zh, 'Enable', 'on');
    
    hs.zh = zh;
    
    % Initialize internal data structure placeholders
    hs = clear_data(hs);
end

% Update hs structure
guidata(hObj, hs);

% UIWAIT makes gsynsq wait for user response (see UIRESUME)
% uiwait(hs.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gsynsq_OutputFcn(hObj, eventdata, hs)
% varargout  cell array for returning output args (see VARARGOUT);
% hObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)

% Get default command line output from hs structure
varargout{1} = hs.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObj, eventdata, hs)
% hObj    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObj, eventdata, hs)
% hObj    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
file = uigetfile('*.mat');
if ~isequal(file, 0)
    try
        tx = load(file);
        assert(isfield(tx, 't'));
        assert(isfield(tx, 'x'));
        assert(length(tx.t) == length(tx.x));
    catch ME
        errordlg(sprintf('File load error: %s', ME.message), ...
                 'File Load Error');
        return;
    end
    
    load_data(hObj, eventdata, hs, file, tx);
end

function load_data(hObj, eventdata, hs, file, tx)
% Do something here about old data, if any?
if (hs.active && ~hs.saved)
end
    
% Load up the data.  First clear old data
hs = clear_data(hs);
hs.data.t = tx.t;
hs.data.x = tx.x - mean(tx.x);

[fpath, fname] = fileparts(file);
hs.prefix = fullfile(fpath, fname);

% Plot axes
plot(hs.axesx, hs.data.t, hs.data.x);
set(hs.axesx, 'Visible', 'on');
grid(hs.axesx, 'on');
axis(hs.axesx,'tight');
setAxesZoomMotion(hs.zh, hs.axesx, 'horizontal');
set(hs.axesx,'FontSize',10);

% Hide other axes and delete colorbars, if any
axes(hs.axesTx);
colorbar('delete');

cla(hs.axesTx);
set(hs.axesTx, 'Visible', 'off');
cla(hs.axesrx);
set(hs.axesrx, 'Visible', 'off');

% Save app data
guidata(hObj, hs);


% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObj, eventdata, hs)
% hObj    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
printdlg(hs.figure1)

% --------------------------------------------------------------------
function ExitMenuItem_Callback(hObj, eventdata, hs)
% hObj    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
figure1_CloseRequestFcn(hObj, eventdata, hs);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObj, eventdata, hs)
% hObj    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)

% If the analysis has been modified but not been saved
if (hs.active && ~hs.saved)
    selection = questdlg(['Unsaved Analysis.  Close ' get(hs.figure1,'Name') '?'],...
        ['Close ' get(hs.figure1,'Name') '...'],...
        'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end
end

% Closes the figure
delete(hs.output);

% Initializes / clears data from last job from hs
function hs = clear_data(hs)
% Is there an analysis active?
hs.active = 0;
% Has it been saved since the last change?
hs.saved = 0;

% What is the file prefix of the current analysis?
hs.prefix = '';

% Default parameters for the transforms
hs.padtype = 'symmetric';
% Number of voices
hs.nv = 32;
% Wavelet type and other options
hs.opt = struct('disp', 1, 'bd', 1, 'gamma', sqrt(eps), 'type', 'morlet');

% Placeholders for the input data
hs.data = [];

% Placeholders for the results of the analysis part
hs.data.as = [];
hs.data.fs = [];
hs.data.Wx = [];
hs.data.Tx = [];

% Placeholders for the results of the synthesis part
hs.data.rx = [];

% Placeholder for the results of synthesis after removing padding
%hs.data.rx0 = [];

% Placeholder for the extracted curves
hs.data.Cs = [];
hs.data.xrs = [];

% Attenuation filters
if isfield(hs, 'filters')
    for hi = 1:length(hs.filters)
        delete(hs.filters(hi).f);
    end
end
hs.filters = [];

% --------------------------------------------------------------------
function openpush_ClickedCallback(hObj, eventdata, hs)
% hObj    handle to openpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
OpenMenuItem_Callback(hObj, eventdata, hs);


% --------------------------------------------------------------------
function savepush_ClickedCallback(hObj, eventdata, hs)
% hObj    handle to savepush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
SaveMenuItem_Callback(hObj, eventdata, hs);


% --------------------------------------------------------------------
function zoomtoggle_ClickedCallback(hObj, eventdata, hs)
% hObj    handle to zoomtoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)

% ZOOM


% --------------------------------------------------------------------
function zoomtoggle_OffCallback(hObj, eventdata, hs)
% hObj    handle to zoomtoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)

% Disable zoom
zoom_disable(hs);

function zoom_disable(hs)
set(hs.zoomtoggle, 'State', 'off');
set(hs.ZoomMenuItem, 'Checked', 'off');
set(hs.zh, 'Enable', 'off');

% --------------------------------------------------------------------
function zoomtoggle_OnCallback(hObj, eventdata, hs)
% hObj    handle to zoomtoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)

% Allow zoom
%if strcmp(get(hObj,'Visible'),'off')
zoom_enable(hs);
%end

function zoom_enable(hs)
set(hs.zoomtoggle, 'State', 'on');
set(hs.zh, 'Enable', 'on');
set(hs.ZoomMenuItem, 'Checked', 'on');


%%% NOT USED %%%
function postZoomUpdate(hObj, eventdata)
% Get the new horizontal values of the updated axes
XLim = get(eventdata.Axes, 'XLim');

% Update the values for each of the axes
hs = guidata(hObj);

XLim(1) = max(XLim(1), min(hs.data.t));
XLim(2) = min(XLim(2), max(hs.data.t));
set(eventdata.Axes, 'XLim', XLim);

if (eventdata.Axes ~= hs.axesTx), set(hs.axesTx, 'XLim', XLim); end
if (eventdata.Axes ~= hs.axesx), set(hs.axesx, 'XLim', XLim); end
if (eventdata.Axes ~= hs.axesrx), set(hs.axesrx, 'XLim', XLim); end

% --------------------------------------------------------------------
function SaveMenuItem_Callback(hObj, eventdata, hs)
% hObj    handle to SaveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
if (~hs.active || hs.saved)
    return;
end

file = uiputfile(sprintf('%s_r.mat', hs.prefix));
if ~isequal(file, 0)
    try
        data = hs.data;
        save(file, '-struct', 'data');
    catch ME
        errordlg(sprintf('File save error: %s', ME.message), ...
            'File Save Error');
        return;
    end
    
    hs.saved = 1;
    guidata(hObj, hs);
end


% --------------------------------------------------------------------
function ExportMenuItem_Callback(hObj, eventdata, hs)
% hObj    handle to ExportMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
if (~hs.active), return; end
labels = {'Export t?', 'Export x(t)?', 'Export as?', 'Export Wx(a,t)?', ...
          'Export fs?', 'Export Tx(f,t)?', 'Export rx(t) (reconstructed)?', ...
          'Export filters?', 'Export identified contours?', ...
          'Export extracted components?'};
varnames = {'t', 'x', 'as', 'Wx', 'fs', 'Tx', 'rx', ...
            'filters', 'Cs', 'xrs'};
filters = hs.filters;
for fi=1:length(filters)
    filters(fi).bbox = filters(fi).f.getPosition();
    filters(fi).mask = filters(fi).f.createMask();
    % bbox = [tmin tmax fmin fmax]
    % filters(fi).bbox = [filters(fi).bbox([1 3])];
    tmin = filters(fi).bbox(1);
    tmax = tmin + filters(fi).bbox(3);
    flogmin = filters(fi).bbox(2);
    flogmax = flogmin + filters(fi).bbox(4);
    filters(fi).bbox = [tmin tmax 2^flogmin 2^flogmax];
end
if length(filters)>0, filters = rmfield(filters, 'f'); end
vars = {hs.data.t, hs.data.x, hs.data.as, ...
        hs.data.Wx, hs.data.fs, hs.data.Tx, hs.data.rx, ...
        filters, hs.data.Cs, hs.data.xrs};
selected = logical([0 0 0 0 0 0 0 0 0 0]);
export2wsdlg(labels, varnames, vars, 'Export to Workspace', selected);

% TODO - export to a variable with proper prefix and name of choice

% --------------------------------------------------------------------
function AnalysisMenu_Callback(hObj, eventdata, hs)
% hObj    handle to AnalysisMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)


% --------------------------------------------------------------------
function AnalysisMenuItem_Callback(hObj, eventdata, hs)
% hObj    handle to AnalysisMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
run_analysis(hObj, eventdata, hs);

function run_analysis(hObj, eventdata, hs)
if (isempty(hs.data))
    errordlg('Load a data file first', 'Error');
    return;
end

prompt = {'Wavelet [morlet,bump,hhhat,...]', ...
          'Number of Voices (nv)', ...
          'Pad type [symmetric, circular, replicate]', ...
          'Gamma (\gamma)'};
name = 'Synchrosqueezing Analysis Parameters';
answers = {hs.opt.type, num2str(hs.nv), hs.padtype, num2str(hs.opt.gamma)};
idata = inputdlg(prompt, name, 1, answers, struct('WindowStyle', 'normal'));
if isempty(idata)
    return
end

hs.opt.type = idata{1};
hs.nv = str2num(idata{2});
hs.padtype = idata{3};
hs.opt.gamma = str2num(idata{4});

[hs.data.Tx, hs.data.fs, hs.data.Wx, hs.data.as] = ...
    synsq_cwt_fw(hs.data.t, hs.data.x, hs.nv, hs.opt);

axes(hs.axesTx);
cla(hs.axesTx);
tplot(hs.data.Tx, hs.data.t, hs.data.fs, hs.opt);
set(hs.axesTx, 'Visible', 'on');
grid(hs.axesTx, 'on');
setAxesZoomMotion(hs.zh, hs.axesTx, 'vertical');
set(hs.axesTx,'FontSize',10);
hs.filters = [];

hs.active = 1;

% Store application parameters
guidata(hObj, hs);


% --------------------------------------------------------------------
function ReconMenuItem_Callback(hObj, eventdata, hs)
% hObj    handle to ReconMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
run_recon(hObj, eventdata, hs);

function run_recon(hObj, eventdata, hs);

if (~hs.active)
    errordlg('Run Analysis First', 'Error');
    return;
end

Tx = filter_Tx(hs);

hs.data.rx = synsq_cwt_iw(Tx, hs.data.fs, hs.opt);

plot(hs.axesrx, hs.data.t, hs.data.rx);
grid(hs.axesrx,'on');
set(hs.axesrx, 'Visible', 'on');
set(hs.axesrx,'FontSize',10);
axis(hs.axesrx, [min(hs.data.t) max(hs.data.t) min(hs.data.x) max(hs.data.x)]);

XLim = get(hs.axesx, 'XLim'); set(hs.axesrx, 'XLim', XLim);
setAxesZoomMotion(hs.zh, hs.axesrx, 'horizontal');
%zoom_enable(hs);

guidata(hObj, hs);

function Tx = filter_Tx(hs)
% Logic to see if any attenuation and/or passband filters are active
Tx = hs.data.Tx;
if ~isempty(hs.filters)
    % Step 1: combine all pass-band filters
    maskp = zeros(size(hs.data.Tx));
    maska = ones(size(hs.data.Tx));
    nmp = 0;
    for fi=1:length(hs.filters)
        mask = hs.filters(fi).f.createMask();
        if strcmpi(hs.filters(fi).type, 'atten')
            maska = maska & ~mask;
        else
            maskp = maskp | mask;
            nmp = nmp + 1;
        end
    end
    
    % Mask via the filters
    if (nmp > 0)
        Tx = Tx .* maskp .* maska;
    else
        Tx = Tx .* maska;
    end
end


% --------------------------------------------------------------------
function FiltersMenu_Callback(hObj, eventdata, hs)
% hObj    handle to FiltersMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)


% --------------------------------------------------------------------
function RectAtten_Callback(hObj, eventdata, hs)
% hObj    handle to RectAtten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
filter_enable(hObj, hs, 'recta')

% --------------------------------------------------------------------
function filter_enable(hObj, hs, type)

% Check to make sure analysis is active
if (~hs.active)
    return;
end

% Disable zoom icon
set(hs.zoomtoggle, 'State', 'off');

% Start filter selection - this disabled zoom
fhs = filter_construct(hs, type);

% Make sure that it's within the proper constraints at first
for fhi=1:length(fhs)
    fh = fhs(fhi);
    fh.setConstrainedPosition(fh.getPosition());
    
    if strcmpi(type(end), 'a')
        hs.filters = [hs.filters struct('type', 'atten', 'f', fh)];
    else
        hs.filters = [hs.filters struct('type', 'pass', 'f', fh)];
    end
end

% Save
guidata(hObj, hs);


function h = filter_construct(hs, type)
switch type
  case 'recta',
    h = imrect(hs.axesTx);
  case 'ellipsea',
    h = imellipse(hs.axesTx);
  case 'polya',
    h = impoly(hs.axesTx);
  case 'rectp',
    h = imrect(hs.axesTx);
  case 'bda',
    t = hs.data.t(:);
    fs = [hs.data.fs(1), hs.data.fs(2:hs.nv:end-1), hs.data.fs(end)]; % Subsample
    [Lbdi, Rbdi] = synsq_bd_loc(t, fs);
    fsbd = [fs(1); fs(:); fs(end)];
    Lbdi = [1; Lbdi(:); 1];
    Rbdi = [length(t); Rbdi(:); length(t)];

    hL = impoly(hs.axesTx, [t(Lbdi) log2(fsbd)]);
    hR = impoly(hs.axesTx, [t(Rbdi) log2(fsbd)]);
    h = [hL hR];
  otherwise,
    error('Unknown filter type');
end

for j=1:length(h)
    hj = h(j);

    cstrstr = class(hj);

    % Set constraints
    constrfcn = makeConstrainToRectFcn(cstrstr, ...
      [min(hs.data.t)-sqrt(eps) max(hs.data.t)], ...
      [min(log2(hs.data.fs))-sqrt(eps) max(log2(hs.data.fs))]);
    hj.setPositionConstraintFcn(constrfcn);

    % Set color
    if strcmpi(type(end), 'a')
        hj.setColor('r');
    else
        hj.setColor('g');
    end
end


% --- Executes on mouse press over axes background.
function axesTx_ButtonDownFcn(hObj, eventdata, hs)
% hObj    handle to axesTx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)

% Is not called due to axis ownership by zoom object


% --------------------------------------------------------------------
function EllipseAtten_Callback(hObj, eventdata, hs)
% hObj    handle to EllipseAtten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
filter_enable(hObj, hs, 'ellipsea')


% --------------------------------------------------------------------
function PolyAtten_Callback(hObj, eventdata, hs)
% hObj    handle to PolyAtten (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
filter_enable(hObj, hs, 'polya')

% --------------------------------------------------------------------
function filterselector_ClickedCallback(hObj, eventdata, hs)
% hObj    handle to filterselector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)

% FILTER SELECTOR

% --------------------------------------------------------------------
function filterselector_OffCallback(hObj, eventdata, hs)
% hObj    handle to filterselector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)


% FILTER SELECTOR

% --------------------------------------------------------------------
function filterselector_OnCallback(hObj, eventdata, hs)
% hObj    handle to filterselector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)


% FILTER SELECTOR

% --------------------------------------------------------------------
function rectattenpush_ClickedCallback(hObj, eventdata, hs)
% hObj    handle to rectattenpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
filter_enable(hObj, hs, 'recta')


% --------------------------------------------------------------------
function polyattenpush_ClickedCallback(hObj, eventdata, hs)
% hObj    handle to polyattenpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
filter_enable(hObj, hs, 'polya')


% --------------------------------------------------------------------
function ellipseattenpush_ClickedCallback(hObj, eventdata, hs)
% hObj    handle to ellipseattenpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
filter_enable(hObj, hs, 'ellipsea')


% --------------------------------------------------------------------
function analysispush_ClickedCallback(hObj, eventdata, hs)
% hObj    handle to analysispush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
run_analysis(hObj, eventdata, hs);

% --------------------------------------------------------------------
function reconpush_ClickedCallback(hObj, eventdata, hs)
% hObj    handle to reconpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% hs    structure with hs and user data (see GUIDATA)
run_recon(hObj, eventdata, hs);


% --------------------------------------------------------------------
function ZoomMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ZoomMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(handles.zh, 'Enable'), 'on'),
    zoomtoggle_OffCallback(hObject, eventdata, handles);
else
    zoomtoggle_OnCallback(hObject, eventdata, handles);
end


% --------------------------------------------------------------------
function ToolsMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ToolsMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ImportMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ImportMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prompts = {'Import t variable: ', 'Import x(t) variable: ', 'Prefix: '};
name = 'Import signal from workspace';
danswers = {'t', 'x', 'ws'};
idata = inputdlg(prompts, name, 1, danswers, struct('WindowStyle', 'normal'));

% Cancelled
if isempty(idata),
    return;
end

try
    tx = struct('t', evalin('base', idata{1}), ...
        'x', evalin('base', idata{2}));
    assert(length(tx.t) == length(tx.x));
catch ME
    errordlg(sprintf('Import error: %s', ME.message), ...
        'Import Error');
        return;
end

% Set some file prefix in the current directory
file = fullfile(pwd, idata{3});

load_data(hObject, eventdata, handles, file, tx);


% --------------------------------------------------------------------
function rectpasspush_ClickedCallback(hObj, eventdata, hs)
% hObject    handle to rectpasspush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter_enable(hObj, hs, 'rectp');


% --------------------------------------------------------------------
function RectPass_Callback(hObj, eventdata, hs)
% hObject    handle to RectPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter_enable(hObj, hs, 'rectp');


% --------------------------------------------------------------------
function ExtractMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to ExtractMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
extract_contour(hObject, handles);

% Extract a contour
function extract_contour(hObj, hs)

if (~hs.active)
    errordlg('Run Analysis First', 'Error');
    return;
end

prompt = {'Number of Curves to Extract', ...
          'Lambda (smoothness penalty)', ...
         'Extraction window (n_w)'};
name = 'Contour Extraction Parameters';
numlines = 1;
answers = {'2', '1e4', num2str(hs.nv/2)};

idata = inputdlg(prompt, name, numlines, answers, struct('WindowStyle', 'normal'));

% User cancelled
if isempty(idata),
    return;
end

nc = str2num(idata{1});
lambda = str2num(idata{2});
nw = str2num(idata{3});

Tx = filter_Tx(hs);
[na, N] = size(Tx);

% Extract curves for plotting
[hs.data.Cs,Es] = curve_ext_multi(Tx, log2(hs.data.fs), nc, lambda, nw);

% Extract functions for export
hs.data.xrs = curve_ext_recon(Tx, hs.data.fs, hs.data.Cs, hs.opt, nw);

% Save
guidata(hObj, hs);

figure;
hc = plot_ext_curves(hs.data.t, hs.data.x, ...
                     Tx, hs.data.fs, hs.data.Cs, Es, hs.opt);

% --------------------------------------------------------------------
function extractpush_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to extractpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
extract_contour(hObject, handles);


% --------------------------------------------------------------------
function AttenBd_Callback(hObj, eventdata, hs)
% hObject    handle to AttenBd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter_enable(hObj, hs, 'bda');


% --------------------------------------------------------------------
function attenbdpush_ClickedCallback(hObj, eventdata, hs)
% hObject    handle to attenbdpush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filter_enable(hObj, hs, 'bda');
