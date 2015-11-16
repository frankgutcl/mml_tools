%Use gui to select the files to compare
%
% Input
% * num: The picture to select, be 1 or 2, or leave empty
%        If input is 2, the 2nd choosen one act as the reference.
%        If leave it empty, it will prompt to select the folder
function test_mcc_gui(num)

    if nargin == 0
        in_files = {};

        folder = uigetdir();
        allFiles = dir(fullfile(folder, '*.jpg'));
        
        if size(allFiles,1)>1
            in_files = {fullfile(folder, allFiles(1).name);fullfile(folder, allFiles(2).name)};
        elseif size(allFiles,1)>0
            in_files = fullfile(folder, allFiles(1).name);
        end
        
        test_mcc(in_files, fullfile(folder, 'report.xlsx'));
    elseif num == 2
        [file1, folder1] = uigetfile('*.*', 'Select a picture');
        [file2, folder2] = uigetfile('*.*', 'Select the reference picture');
        
        test_mcc({fullfile(folder1, file1);fullfile(folder2, file2)}, fullfile(folder1, 'report.xlsx'));
    elseif num == 1
        [file, folder] = uigetfile('*.*', 'Select a picture');
        
        test_mcc(fullfile(folder,file), fullfile(folder, 'report.xlsx'));
    end
end