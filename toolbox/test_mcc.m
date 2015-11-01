function test_mcc(in_file, out_file, ref)

mcc = imread(in_file);
mcc_align(mcc, @align_cb);

    function align_cb(grid)
        rgb2lab = makecform('srgb2lab', 'AdaptedWhitePoint', whitepoint('d65'));
        for i=1:size(grid,1)
            a=(mean(mean(mcc(grid(i,2):grid(i,4),grid(i,1):grid(i,3),1:3),1),2));
            rgb(i,1:3) = a(:,:,1:3);
        end
        lab = applycform(rgb/255, rgb2lab);
        
        ref_rgb = ones(24,3);
        ref_lab = ones(24,3);
        ref_name = 'Ideal';
        
        if strcmpi(ref, 'ip6')
            ref_rgb = round(load('ip6_rgb.dat').*255);
            ref_lab =  applycform(load('ip6_rgb.dat'), rgb2lab);
            ref_name = 'Iphone6';
        elseif strcmpi(ref, 's6')
            ref_rgb = round(load('s6_rgb.dat').*255);
            ref_lab =  applycform(load('s6_rgb.dat'), rgb2lab);
            ref_name = 'SS/S6';
        else
            ref_rgb = round(load('mcc_rgb.dat').*255);
            ref_lab =  applycform(load('mcc_rgb.dat'), rgb2lab);
            ref_name = 'Ideal';
        end

        gen_mcc_report(out_file, round(rgb), ref_rgb, lab, ref_lab, ref_name);
        plot3d_mcc_error(lab, ref_lab, round(rgb), ref_rgb);
        disp('Done!');
    end
end