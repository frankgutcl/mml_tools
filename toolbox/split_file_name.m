%Split the file name into base name and path
function [fp, fn]=split_file_name(in_file)
    parts = regexp(in_file,'\','split');
    fn = cell2mat(parts(end));
    
    fp = '';

    for i=1:(size(parts,2)-1)
        fp = strcat(fp, [cell2mat(parts(i)) '\']);
    end
end