function test_oecf(in_file, out_file)
    oecf = imread(in_file);
    grid = oecf_align(oecf);
    imshow(oecf);
    for i=1:20
        draw_rect(grid(i,1), grid(i,2), grid(i,3), grid(i,4));
    end
    
    rgbw = ones(20,4);
    
    for i=1:20
        rgbw(i,1:3) = uint8(mean(mean(oecf(floor(grid(i,2)):floor(grid(i,4)),floor(grid(i,1)):floor(grid(i,3)),:))));
        rgbw(i,4) = uint8(rgbw(i,1:3)*[0.2989;0.5870;0.1140]);
    end
    
    gen_oecf_report(out_file, rgbw);
    plot_oecf_curv(rgbw);
    
    disp('Done!');
end