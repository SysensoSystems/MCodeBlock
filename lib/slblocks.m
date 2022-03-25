function blkStruct = slblocks
% SLBLOCKS Defines the block library for a specific Toolbox or Blockset.
%
% To create and add custom library to Simulink library browser refer the
% following link - https://www.mathworks.com/help/simulink/ug/creating-block-libraries.html

blkStruct.OpenFcn = 'mCodeBlockLibrary';
blkStruct.Name = 'MCode';

% Define the library list for the Simulink Library browser.
% Return the name of the library model and the name for it.
if exist('mCodeBlockLibrary','file') == 4
    Browser.Library = 'mCodeBlockLibrary';
    Browser.Name = 'MCode';
    Browser.IsFlat = 0;
    blkStruct.Browser = Browser;
end

end
