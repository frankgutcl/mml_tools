function gen_oecf_report(file, rgbw_array, lumi_table)
    T1 = [3 2 6 22];
    T2 = [2 2 2 22];
    
    xlswrite(file, {'Color' 'cd/m2' 'Red' 'Green' 'Blue' 'Gray'}, getRange(T1(1)-2, T1(2), T1(3), T1(2)));
    xlswrite(file, rgbw_array, getRange(T1(1), T1(2)+1, T1(3), T1(4)));
    xlswrite(file, lumi_table, getRange(T2(1), T2(2)+1, T2(3), T2(4)));
    
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
    
    for i=1:20
        sheet.Range(getRange(1,T1(2)+i,1,T1(2)+i)).Interior.Color = RGB(rgbw_array(i,1), rgbw_array(i,2), rgbw_array(i,3));
    end
    
    %Adding chart
    chart = excel.ActiveSheet.Shapes.AddChart(); 
    chart.Name = 'Tone Curve';
    
    ExpChart = excel.ActiveSheet.ChartObjects('Tone Curve');
    ExpChart.Activate;
    try
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
        Series = invoke(excel.ActiveChart,'SeriesCollection',1);
        invoke(Series,'Delete');
    catch e
    end 
    
    NewSeries = invoke(excel.ActiveChart.SeriesCollection,'NewSeries');
    NewSeries.XValues = ['=Sheet1' '!B' int2str(3) ':B' int2str(22)];
    NewSeries.Values  = ['=Sheet1' '!F' int2str(3) ':F' int2str(22)];
    NewSeries.Name    = 'test1';
    
    excel.ActiveChart.ChartType = 'xlXYScatterLinesNoMarkers'; 
    
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