function varargout = MCodeBlockGUI(varargin)
% MCode Block Editor and Callbacks.
%
% Developed by: Sysenso Systems, https://sysenso.com/
% Contact: contactus@sysenso.com
%
% Version:
% 1.0 - Initial Version.
%

% Input Validation
content = '';
blockHandle = [];
codeExecution = 'PreLoadFcn';
doNotExecute = 0;
if nargin == 4
    content = varargin{1};
    codeExecution = varargin{2};
    doNotExecute = varargin{3};
    blockHandle = varargin{4};
end

% Check MCode Block Editor already opened
blockHandle = get_param(blockHandle,'handle');
isOpened = findobj('Tag',num2str(blockHandle));

if isempty(isOpened)
    % Creates MCode Block Editor,if it is doesn't exists.
    screenSize = get(0,'ScreenSize');
    screenSizeFactor = 0.4;
    screensize_factor_1 = 0.8;
    figureSize = [(screenSize(3)*(1-screenSizeFactor))/2 (screenSize(4)*(1-screensize_factor_1))/2 ...
        screenSize(3)*screenSizeFactor screenSize(4)*screensize_factor_1];
    
    blockName = get_param(blockHandle,'Name');
    handles.mCodeBlockFigure = figure('Toolbar','none','MenuBar','none','Position',figureSize,'Tag',num2str(blockHandle));
    set(handles.mCodeBlockFigure,'Name',['MCode Block Editor: ' blockName],'Numbertitle','off','Visible','on');
    mainLayout = uiflowcontainer('v0','parent',handles.mCodeBlockFigure);
    set(mainLayout,'FlowDirection','TopDown');
    topPanel = uipanel('Parent',mainLayout);
    topLayout = uiflowcontainer('v0','parent',topPanel);
    set(topLayout,'FlowDirection','LeftToRight');
    editorLayout = uiflowcontainer('v0','parent',mainLayout);
    set(editorLayout,'FlowDirection','LeftToRight');
    bottomPanel = uipanel('Parent',mainLayout);
    bottomLayout = uiflowcontainer('v0','parent',bottomPanel);
    set(bottomLayout,'FlowDirection','LeftToRight');
    
    optionsPanel = uipanel('Parent',topLayout,'BorderWidth',0);
    checkBoxLayout = uiflowcontainer('v0','parent',topLayout);
    set(checkBoxLayout,'FlowDirection','LeftToRight');
    handles.codeExecutionLabel = uicontrol('style','text','string','Code Execution','HorizontalAlignment','Center','Parent',optionsPanel,'Position',[5 0.5 100 23]);
    callbacks = {'PreLoadFcn','PostLoadFcn','InitFcn','StartFcn','PauseFcn','ContinueFcn','StopFcn','PreSaveFcn','PostSaveFcn','CloseFcn'};
    idx = find(ismember(callbacks,codeExecution),1);
    handles.callbackMenu = uicontrol('style','popupmenu','string',callbacks,'Value',idx,'Parent',optionsPanel,'Position',[110 3 250 25]);
    set(handles.callbackMenu,'BackgroundColor','White','HorizontalAlignment','Center');
    uicontainer('parent',checkBoxLayout);
    handles.doNotExecuteCheckBox = uicontrol('style','checkbox','string','Do Not Execute','Value',doNotExecute,'Parent',checkBoxLayout);
    
    handles.jCodePane = com.mathworks.widgets.SyntaxTextPane;
    codeType = handles.jCodePane.M_MIME_TYPE;
    handles.jCodePane.setContentType(codeType);
    handles.jCodePane.setText(content);
    jScrollPane = com.mathworks.mwswing.MJScrollPane(handles.jCodePane);
    oldWarningState = warning('off', 'MATLAB:ui:javacomponent:FunctionToBeRemoved');
    [handles.jhPanel,handles.hContainer] = javacomponent(jScrollPane,'',editorLayout);
    warning(oldWarningState);
    
    uicontainer('parent',bottomLayout);
    handles.saveButton = uicontrol('style','pushButton','string','Save','parent',bottomLayout);
    handles.helpButton = uicontrol('style','pushButton','string','Help','parent',bottomLayout);
    handles.closeButton = uicontrol('style','pushButton','string','Close','parent',bottomLayout);
    uicontainer('parent',bottomLayout);
    
    % Set HeightLimits and WidthLimits for uicontrols
    set(topPanel,'HeightLimits',[35,35]);
    set(bottomPanel,'HeightLimits',[30,30]);
    set(handles.doNotExecuteCheckBox,'WidthLimits',[100 100]);
    set(handles.saveButton,'WidthLimits',[100 100]);
    set(handles.closeButton,'WidthLimits',[100 100]);
    set(handles.helpButton,'WidthLimits',[100 100]);
    
    % Set Callbacks for uicontrols
    set(handles.mCodeBlockFigure,'DeleteFcn',@(src,event)mCodeFigureDeleteCallback(src,event,handles))
    set(handles.doNotExecuteCheckBox,'CallBack',@(src,event)checkBoxCallback(src,event,handles))
    set(handles.closeButton,'CallBack',@(src,event)closeButtonCallback(src,event,handles))
    set(handles.helpButton,'CallBack',@(src,event)helpButtonCallback(src,event))
    set(handles.saveButton,'CallBack',@(src,event)saveButtonCallback(src,event,handles))
    
    % Store block handle and editor handle in MCode Block Editor userdata
    set(handles.mCodeBlockFigure,'userData',{blockHandle,handles});
else
    figure(isOpened);
    userData = get(isOpened,'userData');
    handles = userData{2};
end

% Returns MCode Block Editor handles
if nargout == 1
    varargout(1) = handles;
end

end
%--------------------------------------------------------------------------
function checkBoxCallback(src,event,handles)
% Do  Not Execute checkbox callback

% Based on the checkbox value the code execution popup menu will be enabled
% or disabled.
checkBoxValue = src.Value;
if checkBoxValue
    set(handles.callbackMenu,'Enable','off');
else
    set(handles.callbackMenu,'Enable','on');
end

end
%--------------------------------------------------------------------------
function mCodeFigureDeleteCallback(src,event,handles)
% MCode Block Editor Deletion Callback

% Save the existing data from the MCode Block Editor to block userdata
options = {'Yes','No'};
closeButtonCallback(src,event,handles,options);

end
%--------------------------------------------------------------------------
function closeButtonCallback(src,event,handles,varargin)
% Close button callback

options = {'Yes','No','Cancel'};
if ~isempty(varargin)
    options = varargin{:};
end

% Get the block handle from MCode Block Editor userdata
figureUserData = get(handles.mCodeBlockFigure,'userData');
blockHandle = figureUserData{1};
userData = get_param(blockHandle,'userData');
% Get the required field from MCode Block Editor
content = char(handles.jCodePane.getText);
idx = handles.callbackMenu.Value;
callbacks = handles.callbackMenu.String;
codeExecution = callbacks{idx};
doNotExecute = handles.doNotExecuteCheckBox.Value;
existingContent = userData.content;
existingCodeExecution = userData.codeExecution;
existingDoNotExecute = userData.doNotExecute;

% Check if any changes made in MCode Block Editor
if ~(isequal(content,existingContent) && isequal(codeExecution,existingCodeExecution) && isequal(doNotExecute,existingDoNotExecute))
    % Popup a dialog box with options to save the changes.
    action = questdlg('Save the changes','M-Code Block Editor',options{:},'Yes');
    if strcmpi(action,'Cancel') || isempty(action)
        try
            figure(handles.mCodeBlockFigure);
        catch
        end
    else
        % Save the changes in block userdata
        if strcmpi(action,'Yes')
            saveButtonCallback([],[],handles)
        end
        handles.mCodeBlockFigure.DeleteFcn = [];
        delete(handles.mCodeBlockFigure);
    end
    % If MCode Block Editor remains unchanged then close the Editor
else
    handles.mCodeBlockFigure.DeleteFcn = [];
    delete(handles.mCodeBlockFigure);
end

end
%--------------------------------------------------------------------------
function helpButtonCallback(src,event)

open('MCodeBlock_Doc.pdf');

end
%--------------------------------------------------------------------------
function saveButtonCallback(src,event,handles)
% Save button Callback

% Get the required field from MCode Block Editor
figureUserData = get(handles.mCodeBlockFigure,'userData');
blockHandle = figureUserData{1};
userData = get_param(blockHandle,'userData');
content = char(handles.jCodePane.getText);
idx = handles.callbackMenu.Value;
callbacks = handles.callbackMenu.String;
codeExecution = callbacks{idx};
doNotExecute = handles.doNotExecuteCheckBox.Value;
existingContent = userData.content;
existingCodeExecution = userData.codeExecution;
existingDoNotExecute = userData.doNotExecute;

% Check if any changes made in MCode Block Editor
if ~(isequal(content,existingContent) && isequal(codeExecution,existingCodeExecution) && isequal(doNotExecute,existingDoNotExecute))
    % Save the changes in block userdata
    try
        userData.content = content;
        userData.codeExecution = codeExecution;
        userData.doNotExecute = doNotExecute;
        set_param(blockHandle,'UserDataPersistent','on','userData',userData);
        msgbox('Saved Successfully','Success');
    catch
        error('Unable to save the content');
    end
end

execution = sprintf('%s\n','mFileData = get_param(gcb,''UserData'');',...
    'try',...
    'eval(mFileData.content)',...
    'catch',...
    'disp(''The MCode block content is not valid. Please check for error and rectify'');',...
    'end');
% If Do Not Execute checkbox is checked then remove the callback from the
% model
if doNotExecute
    system = bdroot(blockHandle);
    set_param(system,existingCodeExecution,[]);
else
    try
        system = bdroot(blockHandle);
        set_param(system,codeExecution,execution);
        set_param(system,existingCodeExecution,[]);
    catch
    end
end

end