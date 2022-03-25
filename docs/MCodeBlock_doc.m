%% *|MCode Block|*
%
% MCodeBlock is a custom Simulink block, which helps to add/write MATLAB
% script inside a Simulink Model.
%
% This block can be used in the following ways as:
%
% 1. *Parameter File* - The parameters required for the Simulink model can
% be saved, initialised and retrieved using this block.
%
% 2. *Comments/Document File* - The comments for the Simulink model can
% also be added using this block. This block can be used in any levels of
% the model and comments for the level can be added.
%
% 3. *Callbacks* - Provides extended callback for the Simulink model.
%
% Developed by: Sysenso Systems, <https://sysenso.com/>
%
% Contact: contactus@sysenso.com
%
% Version:
% 1.0 - Initial Version.
%
%
%%
% *|MCode Block Library|*
%
% * Add the MCodeBlock folder to the MATLAB path, then the MCode block library will be available to use from Simulink Library Browser.
%
% <<\images\path.png>>
%
% * If this library is not visible in Simulink Library Browser, then close the Simulink and type following command in MATLAB command window.
% >> sl_refresh_customizations
%
% * Now, it will become available within the Simulink Library Browser.
%
% <<\images\mCodeBlock.png>>
%
% * Alternatively, MCode block can be copied from the lib\mCodeBlockLibrary.slx file.
%
%%
% *|MCode Block Editor|*
%
% * On double clicking the MCode block, a MCode Block Editor GUI opens with
% default text in the text area.
%
% <<\images\editorOptions.png>>
%
% * MCode Block Editor GUI consists of the following features:
%
% 1. *Code Execution* - Provides the callback options of the Simulink
% model. The MATLAB code will be executed during the selected callback.
%
% 2. *DoNotExecute* - On Selecting the "Do Not Execute" checkbox, prevents
% the MATLAB code from executing.
%
% 3. *Editor* - Provides a MATLAB editor window to write the MATLAB
% scripts.
%
% 4. *Save* - On clicking the Save button, the MATLAB scripts will be
% saved.
%
% 5. *Help* - On clicking the Help button, the user manual document of MCode
% Block will be  opened.
%
% 6. *Close* - On clicking the Close button, a dialog box opens with options
% for saving the MATLAB scripts and Closes the MCode Block Editor.
%
%
%%
% *|MCode Block Usage|*
%
% * MCode block can be used at any levels of the Simulink model.
%
% <<\images\model.png>>
%
% * Sample usage:
%
% <<\images\usage.png>>
%
%%
% *|API Support|*
%
% * API Support for MCode Block and MCode Block Editor is also provided.
%
% * Get the userdata of the MCode Block using the following commands:
% * >>userData = get_param(<MCode Block Name/handle>,'userData');
%
% * The returned userData is a structure variable with the following fields.
% The user data will be a struct, having the following fields.
%
% 1. *content* - MCode block code contents.
%
% 2. *format* - 'M_CODE'. Not used as of now. It can be used in future version.
%
% 3. *codeExecution* - Any one model callback function.
%
% 4. *doNotExecute* - 0 or 1. 0 - Execute as per codeExecution callback. 1 - Do not execute the codeExecution callback.
%
% 5. *imageData* - Icon data for the MCode block.
%
% * Now the values of each field can be viewed and edited.
%
% * To refelect the edited values of userData to MCode Block and
% MCode Block Editor, use the following command to update the editor.
% * >>updateMCodeBlock(userData,<MCode Block Name/handle>);
%
% <<\images\userData.png>>
%