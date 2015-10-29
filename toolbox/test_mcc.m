function test_mcc(in_file, out_file)

mcc = imread(in_file);
mcc_align(mcc, @align_cb);

    function align_cb(grid)
        rgb2lab = makecform('srgb2lab', 'AdaptedWhitePoint', whitepoint('d65'));
        for i=1:size(grid,1)
            a=(mean(mean(mcc(grid(i,2):grid(i,4),grid(i,1):grid(i,3),1:3),1),2));
            rgb(i,1:3) = a(:,:,1:3);
        end
        lab = applycform(rgb/255, rgb2lab);

        gen_mcc_report(out_file, round(rgb), round(load('mcc_rgb.dat').*255), lab, load('mcc_lab_d65.dat'));
        plot3d_mcc_error(lab,load('mcc_lab_d65.dat'), round(rgb), round(load('mcc_rgb.dat').*255));
        disp('Done!');
    end
end