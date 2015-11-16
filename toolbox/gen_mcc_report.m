%Generate the xlsx report between the two inputs.
%
% Input
% *out_file: The out put file of xlsx
% *rgb_array: The RGB input. Includes two cells {rgb, ref_rgb}, each is
%             24*3 array
% *lab_array: The LAB input. Includes two cells {lab, ref_lab}, each is
%             24*3 array
% *label_array: Include two cells {string, ref_string}
% *crop_files: Include one or two cells {crop_file_name; ref_crop_file_name}


function gen_mcc_report(out_file, rgb_array, lab_array, label_array, crop_files)

    T1 = [3, 2, 7, 26];  %The table of statistic/compare data
    T2 = [3, 2, 17, 26]; %The table of seperated image (original data)
    
    label = cell2mat(label_array(1));
    ref_label = cell2mat(label_array(2));
    
    rgb = cell2mat(rgb_array(1));
    ref_rgb = cell2mat(rgb_array(2));
    
    lab = cell2mat(lab_array(1));
    ref_lab = cell2mat(lab_array(2));
    
        
    %Write comparison data
    deltaE = sqrt(sum((lab-ref_lab).^2, 2));
    deltaL = abs(lab(:,1)-ref_lab(:,1));
    deltaC = sqrt(deltaE.^2-deltaL.^2);
    deltaH = (abs(atan(lab(:,3)./lab(:,2)) - atan(ref_lab(:,3)./ref_lab(:,2)))*180)./pi;
    deltaS = abs(sqrt(sum(lab(:,[2 3]).^2, 2)) - sqrt(sum(ref_lab(:,[2 3]).^2, 2)));
    
    xlswrite(out_file, {label ref_label 'Delta-E' 'Delta-L' 'Delta-C' 'Delta-H' 'Delta-S'}, 1, getRange(T1(1)-2, T1(2), T1(3), T1(2)));
    xlswrite(out_file, [deltaE,deltaL,deltaC,deltaH,deltaS], 1, getRange(T1(1), T1(2)+1, T1(3), T1(4)));
    
    %Write original data
    xlswrite(out_file, {label ref_label [label,'-R'] [label,'-G'] [label,'-B'] '' [ref_label,'-R'] [ref_label,'-G'] [ref_label,'-B'] '' [label,'-L*'] [label,'-A*'] [label,'-B*'] '' [ref_label,'-L*'] [ref_label,'-A*'] [ref_label,'-B*']}, 2, getRange(T2(1)-2, T2(2), T2(3), T2(2)));
    xlswrite(out_file, rgb, 2, getRange(T2(1), T2(2)+1, T2(1)+2, T2(4)));
    xlswrite(out_file, ref_rgb, 2, getRange(T2(1)+4, T2(2)+1, T2(1)+6, T2(4)));
    xlswrite(out_file, lab, 2, getRange(T2(1)+8, T2(2)+1, T2(1)+10, T2(4)));
    xlswrite(out_file, ref_lab, 2, getRange(T2(1)+12, T2(2)+1, T2(1)+14, T2(4)));
    
    %Excel decoration and etc.
    excel = actxserver('Excel.Application');
    excel.visible = 1;
    workbooks = excel.Workbooks;
    workbook = workbooks.Open(out_file);
    sheets = workbook.Sheets;
    sheet = sheets.Item(1); 
    sheet.Activate; 
    
    %Font
    font = sheet.Range(getRange(T1(1)-2, T1(2), T1(3), T1(2))).font;
    font.size=12;
    font.bold=1;

    %Line by line color sep
    for i=T1(2):2:T1(4)
        sheet.Range(getRange(T1(1), i, T1(3),i)).Interior.ColorIndex = 15;
    end
    
    %Border
    border=sheet.Range(getRange(T1(1), T1(2), T1(3), T1(4))).Borders;
    border.ColorIndex=1;
    border.Weight=3;
    
    %Display color
    for i=1:24
        sheet.Range(getRange(1,T1(2)+i,1,T1(2)+i)).Interior.Color = RGB(rgb(i,1), rgb(i,2), rgb(i,3));
        sheet.Range(getRange(2,T1(2)+i,2,T1(2)+i)).Interior.Color = RGB(ref_rgb(i,1), ref_rgb(i,2), ref_rgb(i,3));
    end
    
    %Show plotted image
    plot_mcc_error(lab, ref_lab, rgb, ref_rgb);
    [path, ~, ~] = fileparts(out_file);
    tmpfile = [path, '\plotmcc~.jpg'];
    saveas(gcf, tmpfile);
    close(gcf);
    
    left = excel.ActiveSheet.Range('I1').Left;
    top = excel.ActiveSheet.Range('I1').Top;
    sheet.Shapes.AddPicture(tmpfile,0,1,left, top, 350, 350);
    
    delete(tmpfile);
   
    plot3d_mcc_error(lab, ref_lab, rgb, ref_rgb);
    tmpfile = [path, '\plotmcc~.fig'];
    saveas(gcf, tmpfile);
    close(gcf);
    
    %TODO: Cannot insert the OLE object, have to do it manually

    %left = excel.ActiveSheet.Range('A28').Left;
    %top = excel.ActiveSheet.Range('A28').Top;
    %invoke(sheet.Shapes,'AddOLEObject','',tmpfile,0,0,'',0,'', left, top, 50, 50); 
    %delete(tmpfile);
    
    sheet.Name = 'Comparison';
    
    %For the second sheet
    sheet = sheets.Item(2);
    sheet.Activate;
    
    %Font
    font = sheet.Range(getRange(T2(1), T2(2), T2(3), T2(2))).font;
    font.size=12;
    font.bold=1;
    
    %Line by line color sep
    for i=T2(2):2:T2(4)
        sheet.Range(getRange(T2(1), i, T2(3),i)).Interior.ColorIndex = 15;
    end
    
    %Border
    border=sheet.Range(getRange(T2(1), T2(2), T2(3), T2(4))).Borders;
    border.ColorIndex=1;
    border.Weight=3;
    
    %Display color
    for i=1:24
        sheet.Range(getRange(1,T2(2)+i,1,T2(2)+i)).Interior.Color = RGB(rgb(i,1), rgb(i,2), rgb(i,3));
        sheet.Range(getRange(2,T2(2)+i,2,T2(2)+i)).Interior.Color = RGB(ref_rgb(i,1), ref_rgb(i,2), ref_rgb(i,3));
    end
    
    %Show original plotted image
    left = excel.ActiveSheet.Range('A30').Left;
    top = excel.ActiveSheet.Range('A30').Top;
    sheet.Shapes.AddPicture(cell2mat(crop_files(1)),0,1,left, top, 400, 300);
    
    if size(crop_files,1)>1
        left = excel.ActiveSheet.Range('J30').Left;
        top = excel.ActiveSheet.Range('J30').Top;
        sheet.Shapes.AddPicture(cell2mat(crop_files(2)),0,1,left, top, 400, 300);
    end
    
    sheet.Name = 'Data';

    workbook.Save();
    workbook.Close();
    excel.Quit();
end

function range=getRange(left, top, right, bottom)
    range=[char(64+left), num2str(top), ':', char(64+right), num2str(bottom)];
end

function color=RGB(r, g, b)
    color = 256*(256*b +g)+r;
end