scales = [1.5:-0.1:0.5];
for id = 1 : size(scales,2)
    myFolder = strcat('C:\Users\schaffqg\Documents\GitHub\Image-Translation\Code\cutImages\',num2str(scales(id)),'\1');
    % Check to make sure that folder actually exists.  Warn user if it doesn't.
    if ~isdir(myFolder)
        errorMessage = sprintf('Error: The following folder does not exist:\n%s', myFolder);
        uiwait(warndlg(errorMessage));
        return;
    end
    fprintf(1, 'Now deleting files in %s\n', myFolder);
    % Get a list of all files in the folder with the desired file name pattern.
    filePattern = fullfile(myFolder, '*.png'); % Change to whatever pattern you need.
    theFiles = dir(filePattern);
    for k = 1 : length(theFiles)
        baseFileName = theFiles(k).name;
        fullFileName = fullfile(myFolder, baseFileName);
        %fprintf(1, 'Now deleting %s\n', fullFileName);
        delete(fullFileName);
    end
end    