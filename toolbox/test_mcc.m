%Test the mcc chart
%
% Input
% *in_file: A string of file name(path) or an array of files 
%          embrace with {'test_file';'ref_file'} and seperate with ;, maximum in 2. The second
%          picture is taken as the reference, if there's only 1 picture,
%          take mcc-standard(D65) as reference
% *out_file: The report in xlsx. format in string

function test_mcc(in_file, out_file)

    isRefPic = 0;
    temp_files = {};

    if iscell(in_file) && size(in_file,1) == 2
        mcc = cell2mat(in_file(1));
        ref = cell2mat(in_file(2));
        isRefPic = 1;
    elseif iscell(in_file)
        mcc = cell2mat(in_file(1));
    else
        mcc = in_file;  
    end

    if isRefPic
        [path, ~] = split_file_name(ref);
        refData = imread(ref);
        mccData = imread(mcc);
        temp_files(2) = mat2cell([path 'tempref~.jpg']);
        mcc_align(refData, makeCallback(isRefPic), [path 'tempref~.jpg']);
    else
        [path, ~] = split_file_name(mcc);
        mccData = imread(mcc);
        temp_fies(1) = mat2cell([path 'temp~.jpg']);
        mcc_align(mccData, makeCallback(isRefPic), [path 'temp~.jpg']);
    end
    
    function f=makeCallback(refPic)
        rgb2lab = makecform('srgb2lab', 'AdaptedWhitePoint', whitepoint('d65'));
        ref_rgb = zeros(24,3);
        ref_lab = zeros(24,3);

        if ~refPic
            ref_rgb = round(load('mcc_rgb.dat').*255);
            ref_lab =  applycform(load('mcc_rgb.dat'), rgb2lab);
            ref_name = 'Ideal';
        else
            refAligned = 0; 
            [~, fn] = split_file_name(ref);
            result = regexp(fn, '\.', 'split');
            ref_name = cell2mat(result(1));
        end

        function align_cb(grid)  
            if isRefPic && ~refAligned
                %aligned the reference picture
                refAligned = 1;
                
                for i=1:size(grid,1)
                    a=(mean(mean(refData(grid(i,2):grid(i,4),grid(i,1):grid(i,3),1:3),1),2));
                    ref_rgb(i,1:3) = a(:,:,1:3);
                end
                ref_lab = applycform(ref_rgb/255, rgb2lab);
                
                [path, ~] = split_file_name(mcc);
                mcc_align(mccData, @align_cb, [path 'temp~.jpg']);
                return;
            else
                %align the current picture
                for i=1:size(grid,1)
                    a=(mean(mean(mccData(grid(i,2):grid(i,4),grid(i,1):grid(i,3),1:3),1),2));
                    rgb(i,1:3) = a(:,:,1:3);
                end
                lab = applycform(rgb/255, rgb2lab);
            end

            gen_mcc_report(out_file, round(rgb), round(ref_rgb), lab, ref_lab, ref_name);
            plot3d_mcc_error(lab, ref_lab, round(rgb), ref_rgb);
            disp('Done!');
        end
        
        f = @align_cb;
    end
end