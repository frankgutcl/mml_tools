%Use gui to select the folder, all jpg under this folder will join the
%comparison


function test_oecf_gui()
    folder = uigetdir();
    jpgfiles = dir(fullfile(folder, '*.jpg'));
    
    in_files = {};
    for index=1:size(jpgfiles)  
        in_files(index,1) = mat2cell(fullfile(folder, jpgfiles(index).name));
    end
    
    test_oecf(in_files, fullfile(folder, 'reports.xlsx'));
end