%To exam the oecf(Optical-Electronic-Conversion-Function) of the camaera
%
% Input 
% *in_file: A string of file name(path) or an array of files
%
% Output
% *out_file: The report to be generated

function test_oecf(in_file, out_file)

    if ~iscell(in_file)
        %Only one file, make it a cell
        in_file = {in_file};
    end
    
    rgbw_array = ones(size(in_file,1), 20, 4);
    label_array = {};
    
    for i=1:size(in_file,1)
        fn = cell2mat(in_file(i));
        
        oecf = imread(fn);
        grid = oecf_align(oecf);
        figure;
        imshow(oecf);
        
        for j=1:20
            draw_rect(grid(j,1), grid(j,2), grid(j,3), grid(j,4));
        end

        rgbw = ones(20,4);

        for j=1:20
            rgbw(j,1:3) = uint8(mean(mean(oecf(floor(grid(j,2)):floor(grid(j,4)),floor(grid(j,1)):floor(grid(j,3)),:))));
            rgbw(j,4) = uint8(rgbw(j,1:3)*[0.2989;0.5870;0.1140]);
        end
        
        rgbw_array(i,:,:) = rgbw(:,:);
        
        
        fn = cell2mat(regexp(fn, '\w*.jpg', 'match', 'ignorecase'));
        label_array(i) = regexp(fn, '\w*\.', 'match');        
    end
        
    ltable = load('oecf_lum.dat');
    
    gen_oecf_report(out_file, rgbw_array, label_array, ltable);
    %plot_oecf_curv(rgbw, ltable);
    
    disp('Done!');
end