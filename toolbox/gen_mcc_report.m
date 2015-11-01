function gen_mcc_report(file, rgb, srgb, lab, slab, ref_label)

    T1 = [3, 2, 17, 26];
    T2 = [3,30, 7, 54];
    
    xlswrite(file, {ref_label 'Sample' 'Mean-R' 'Mean-G' 'Mean-B' '' [ref_label,'-R'] [ref_label,'-G'] [ref_label,'-B'] '' 'Mean-L*' 'Mean-A*' 'Mean-B*' '' [ref_label,'-L*'] [ref_label,'-A*'] [ref_label,'-B*']}, getRange(T1(1)-2, T1(2), T1(3), T1(2)));
    xlswrite(file, rgb, getRange(T1(1), T1(2)+1, T1(1)+2, T1(4)));
    xlswrite(file, srgb, getRange(T1(1)+4, T1(2)+1, T1(1)+6, T1(4)));
    xlswrite(file, lab, getRange(T1(1)+8, T1(2)+1, T1(1)+10, T1(4)));
    xlswrite(file, slab, getRange(T1(1)+12, T1(2)+1, T1(1)+14, T1(4)));
        
    deltaE = sqrt(sum((lab-slab).^2, 2));
    deltaL = abs(lab(:,1)-slab(:,1));
    deltaC = sqrt(deltaE.^2-deltaL.^2);
    deltaH = (abs(atan(lab(:,3)./lab(:,2)) - atan(slab(:,3)./slab(:,2)))*180)./pi;
    deltaS = abs(sqrt(sum(lab(:,[2 3]).^2, 2)) - sqrt(sum(slab(:,[2 3]).^2, 2)));
    
    xlswrite(file, {'Delta-E' 'Delta-L' 'Delta-C' 'Delta-H' 'Delta-S'}, getRange(T2(1), T2(2), T2(3), T2(4)));
    xlswrite(file, [deltaE,deltaL,deltaC,deltaH,deltaS], getRange(T2(1), T2(2)+1, T2(3), T2(4)));
    
    excel = actxserver('Excel.Application');
    excel.visible = 1;
    workbooks = excel.Workbooks;
    workbook = workbooks.Open(file);
    sheets = workbook.Sheets;
    sheet = sheets.Item('Sheet1'); 
    
    sheet.Activate; 
    
    font = sheet.Range(getRange(T1(1), T1(2), T1(3), T1(2))).font;
    font.size=12;
    font.bold=1;

    for i=T1(2):2:T1(4)
        sheet.Range(getRange(T1(1), i, T1(3),i)).Interior.ColorIndex = 15;
    end
    
    border=sheet.Range(getRange(T1(1), T1(2), T1(3), T1(4))).Borders;
    border.ColorIndex=1;
    border.Weight=3;
    
    font = sheet.Range(getRange(T2(1), T2(2), T2(3), T2(2))).font;
    font.size=12;
    font.bold=1;
    
    for i=T2(2):2:T2(4)
        sheet.Range(getRange(T2(1), i, T2(3),i)).Interior.ColorIndex = 15;
    end
    
    border=sheet.Range(getRange(T2(1), T2(2), T2(3), T2(4))).Borders;
    border.ColorIndex=1;
    border.Weight=3;
    
    for i=1:24
        sheet.Range(getRange(1,T1(2)+i,1,T1(2)+i)).Interior.Color = RGB(srgb(i,1), srgb(i,2), srgb(i,3));
        sheet.Range(getRange(2,T1(2)+i,2,T1(2)+i)).Interior.Color = RGB(rgb(i,1), rgb(i,2), rgb(i,3));

        sheet.Range(getRange(1,T2(2)+i,1,T2(2)+i)).Interior.Color = RGB(srgb(i,1), srgb(i,2), srgb(i,3));
        sheet.Range(getRange(2,T2(2)+i,2,T2(2)+i)).Interior.Color = RGB(rgb(i,1), rgb(i,2), rgb(i,3));
    end

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