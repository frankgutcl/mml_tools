%Crop the region of 24 colors in mcc chart
%
%  Input
%  * img: The mcc chart picture, can be the file path or loaded image(in RAM)
%
%  Output 
%  * grid: The 24 * 4 map of all coord of the cropped regions 
%  * output: To output the image file (with crop info) to the output path

function mcc_align(img, img_title, func_cb, output_file)

    %Can be adjusted according the real picture
    PATCH_DIFF = 6; %The color diff tolerance for first 23 patches
    BLACK_DIFF = 2; %The olor diff tolerance for the last black patch
    MARGIN = 50; %The safe margin to left for rotate/tile

    PICTURE_BLUR_LVL = 10; %Blur the image before starting search(to cover the input defect)


    if 2==size(size(img),2)
        %Looks like a file name
        img = imread(img);
    end

    if nargin<3
        output_file = '';
    end
    %Interactive...

    figure();
    clf;
    hold on
    imshow(img);
    set(gcf, 'WindowButtonDownFcn', @mouseDown);

    left=0;
    top=0;
    right=0;
    bottom=0;

        function mouseDown(src, evt)
            if left==0
                pt = get(gca,'CurrentPoint');     
                left = round(pt(1,1));
                top = round(pt(1,2));
                if left<0 || top<0 || left>size(img,2) || top>size(img,1)
                    left = 0;
                    top = 0;
                    disp('Invalid start position');
                else
                    hold on
                    plot(left,top,'*'); 
                end
            else
                pt=get(gca,'CurrentPoint');     
                right = round(pt(1,1));
                bottom = round(pt(1,2));

                if right<=left || bottom<=top || right>size(img,2) || bottom>size(img,1)
                    right = 0;
                    bottom = 0;
                    disp('Invalid stop position');
                else
                    close(gcf); 
                    grid = align_cropped_picture(img(top:bottom,left:right,:), true);
                    if size(output_file)
                        saveas(gcf, output_file);
                    end
                    close(gcf);
                    grid(:,1) = grid(:,1) + left;
                    grid(:,2) = grid(:,2) + top;
                    grid(:,3) = grid(:,3) + left;
                    grid(:,4) = grid(:,4) + top;
                   
                    func_cb(grid);
                end
            end
        end

        function output=align_cropped_picture(img, display)
            if display
                figure
                imshow(img)
            end

            %Blur the input image
            bfilter = fspecial('disk', PICTURE_BLUR_LVL);
            img = imfilter(img, bfilter);

            [imgH, imgW, ~] = size(img);

            hBlock = round(imgW/7);
            vBlock = round(imgH/5);

            patchCenter = zeros(24,2);


            for row=1:4
                for col=1:6
                    patchCenter((row-1)*6+col, :) = round([hBlock*col, vBlock*row]);
                end
            end         

            for i=1:24
                if i<24
                     [l, t, r, b] = color_region(img, patchCenter(i,1), patchCenter(i,2), 1, floor(imgW/6), floor(imgH/4), PATCH_DIFF, MARGIN);
                 else
                     %Last patch
                     [l1, t1, r1, b1] = color_region(img, patchCenter(i,1), patchCenter(i,2), 1, floor(imgW/6), floor(imgH/4), BLACK_DIFF, MARGIN);
                     %Shrink 33% since is is very easy to go out of border
                     l = round((l1+r1)/2-(r1-l1)/3);
                     r = round((l1+r1)/2+(r1-l1)/3);
                     t = round((t1+b1)/2-(b1-t1)/3);
                     b = round((t1+b1)/2+(b1-t1)/3);
                 end

                 output(i,1:4) = [l, t, r, b]; %#ok<AGROW>

            end

            if display
                for i=1:size(output, 1)
                    draw_rect(output(i,1), output(i,2), output(i,3), output(i,4));
                end
            end
            title(img_title);
        end

end


 
