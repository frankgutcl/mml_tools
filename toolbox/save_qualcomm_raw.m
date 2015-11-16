function save_qualcomm_raw(file, raw_image, w, h, format)
   if strcmpi(format, 'm10')

        Data = uint16(raw_image);
        Data = Data';
        Data = reshape(Data, [4, w*h/4]);
        LastLine = bitor(bitor(bitand(Data(1,:), 3), bitshift(bitand(Data(2,:), 3), 2)), bitor(bitshift(bitand(Data(3,:), 3), 4),bitshift(bitand(Data(4,:), 3), 6)));
        Data = [bitshift(Data(1:4,:), -2);LastLine];
        Data = reshape(Data, [w*5/4, h]);
        Data(w*5/4+1:w*5/4+4,:) = 0;
        Data = reshape(Data, 1, (w*5/4+4)*h);
        Data = uint8(Data);
        fp = fopen(file,'wb','b');
        fwrite(fp, Data, '*uint8', 0,'l');
        fclose(fp);
   elseif strcmpi(format,'q10')
       %Not applicable yet
   end
end