function MCodeBlock(varargin)
% MCodeBlock is custom Simulink block, which helps to add/write MATLAB
% script inside a Simulink Model.
%
% Developed by: Sysenso Systems, https://sysenso.com/
% Contact: contactus@sysenso.com
%
% Version:
% 1.0 - Initial Version.
%

try
    feval(varargin{:});
catch
    msgbox('Please check the function name and arguments in the block callbacks');
end

end
%--------------------------------------------------------------------------
function editMCodeBlock(inputBlockName)
% Opens the block content in MCode Block Editor

% MCode Block Editor can not be opened from library browser.
if strcmpi(bdroot(inputBlockName), 'simulink')
    msgbox('MCode block editor cannot be opened from library browser.');
    return;
end
try
    % Get the data from block userdata
    blockHandle = get_param(inputBlockName,'Handle');
    [blockContent,~,codeExecution,doNotExecute] = getBlockData(blockHandle);
catch
    return;
end
try
    % Open the MCode Block Editor
    MCodeBlockGUI(blockContent,codeExecution,doNotExecute,inputBlockName);
catch
    msgbox('Unable to open MCode block content.');
end

end
%--------------------------------------------------------------------------
function saveMCodeBlock(inputBlockName)
% Helps to save from MCode Block Editor to block userdata

blockHandle = get_param(inputBlockName,'Handle');
% Check M-Code Block Editor already opened
isOpened = findobj('Tag',num2str(blockHandle));
if ~isempty(isOpened)
    figureUserData = get(isOpened,'userData');
    handle = figureUserData{2};
    callback = handle.saveButton.Callback;
    callback([],[],handle);
end

end
%--------------------------------------------------------------------------
function closeMCodeBlock(inputBlockName)
% Close MCode Block Editor if already opened

blockHandle = get_param(inputBlockName,'Handle');
isOpened = findobj('Tag',num2str(blockHandle));
if ~isempty(isOpened)
    delete(isOpened);
end

end
%--------------------------------------------------------------------------
function [content,format,codeExecution,doNotExecute] = getBlockData(blockName)
% Helps to get content from the block userdata
try
    userData = get_param(blockName,'userData');
    content = userData.content;
    format = userData.format;
    % Force content to be always 1xN character array.
    content = reshape(content,1,[]);
    codeExecution = userData.codeExecution;
    doNotExecute = userData.doNotExecute;
catch
    msgbox('Unable to get MCode block content.');
end

end
