function updateMCodeBlock(userData,blockHandle)
% Helps to update the MCode block userdata which in turn update the block
% contents.
%
% The user data will be a struct, having the following  fields.
% content - MCode block code contents.
% format - 'M_CODE'. Not used as of now. It can be used in future version.
% codeExecution - Any one callback function {'PreLoadFcn','PostLoadFcn','InitFcn','StartFcn','PauseFcn','ContinueFcn','StopFcn','PreSaveFcn','PostSaveFcn','CloseFcn'}
% doNotExecute - 0 or 1. 0 - Execute as per codeExecution callback. 1 - Do not execute the codeExecution callback.
% imageData - Icon data for the MCode block.
%
% Developed by: Sysenso Systems, https://sysenso.com/
% Contact: contactus@sysenso.com
%
% Version:
% 1.0 - Initial Version.
%

fields = {'content','format','codeExecution','doNotExecute','imageData'};
% Input Structure Validation
if isempty(find(isfield(userData,fields) == 0,1))
    if ~isempty(find(isfield(userData.imageData,{'data'}) == 0,1))
        error('imageData field must be a structure with the following field:/ndata');
    end
else
    error('UserData structure must contains the following fields:/n content,format,imageData');
end

callbacks = {'PreLoadFcn','PostLoadFcn','InitFcn','StartFcn','PauseFcn','ContinueFcn','StopFcn','PreSaveFcn','PostSaveFcn','CloseFcn'};
% Input Data Validation
imageField = fieldnames(userData.imageData);
for ii = 1:numel(fields)
    field = fields{ii};
    switch field
        case 'content'
            value = userData.(field);
            if ischar(value) || isempty(value)
                setBlockContent(value,field,blockHandle)
            else
                error('Type Error: content field must be of type char');
            end
        case 'format'
            value = userData.(field);
            if ischar(value) || isempty(value)
                if ~strcmp(value,'M_CODE')
                    warning('format field value cannot be changed.\n Note:The support will be provided in upcoming version');
                    userData.(field) = 'M_Code';
                end
            else
                error('Type Error: format field must be of type char');
            end
        case 'codeExecution'
            value = userData.(field);
            if ischar(value) || isempty(value)
                idx = find(ismember(callbacks,value),1);
                if ~isempty(idx)
                    setBlockContent(idx,field,blockHandle);
                else
                    warning('Invalid Callback:Code Execution Value remains unchanged');
                    userData.(field) = callbacks{1};
                end
            else
                error('Type Error: codeExecution field must be of type char');
            end
        case 'doNotExecute'
            value = userData.(field);
            if isnumeric(value) && isscalar(value)
                if isequal(value,0) || isequal(value,1)
                    setBlockContent(value,field,blockHandle);
                else
                    warning('Invalid Value:Do Not Execute Value remains unchanged');
                    userData.(field) = 0;
                end
            else
                error('Type Error: doNotExecute field must be of type numeric');
            end
        case 'imageData'
            value = userData.(field).(imageField{:});
            if ~(isnumeric(value) && (isequal(ndims(value),2) || isequal(ndims(value),3)))
                error('Type Error: imageData field must be of type numeric');
            end
    end
end
set_param(blockHandle,'UserDataPersistent','on','userData',userData);
setMaskDisplay(blockHandle);
doNotExecute = userData.doNotExecute;
setExecutionCallback(blockHandle,doNotExecute);

end
%--------------------------------------------------------------------------
function setBlockContent(value,field,blockHandle)
% Helps to set the content in MCode Block Editor

% Check MCode Block Editor already opened
blockHandle = get_param(blockHandle,'Handle');
isOpened = findobj('Tag',num2str(blockHandle));

try
    figureUserData = get(isOpened,'userData');
    handle = figureUserData{2};
catch
    handle = [];
end

switch field
    case 'content'
        if ~isempty(handle)
            handle.jCodePane.setText(value);
        end
    case 'codeExecution'
        if ~isempty(handle)
            handle.callbackMenu.Value = value;
        end
    case 'doNotExecute'
        if ~isempty(handle)
            handle.doNotExecuteCheckBox.Value = value;
        end
end

end
%--------------------------------------------------------------------------
function setMaskDisplay(blockHandle)
% Helps to set the Maskdisplay of the block

try
    maskDisplay = get_param(blockHandle,'MaskDisplay');
    set_param(blockHandle,'MaskDisplay',maskDisplay);
catch
end

end
%--------------------------------------------------------------------------
function setExecutionCallback(blockHandle,doNotExecute)
% Helps to set the model callback

execution = sprintf('%s\n','mFileData = get_param(gcb,''UserData'');',...
    'try',...
    'eval(mFileData.content)',...
    'catch',...
    'disp(''The MCode block content is not valid.Please check for error and rectify'');',...
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