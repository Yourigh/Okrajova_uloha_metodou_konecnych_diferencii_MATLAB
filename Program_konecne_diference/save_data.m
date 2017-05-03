function save_data(xres,yres,file_name)
    fileID = fopen(file_name,'w');
    fprintf(fileID,'x;y\n');
    fprintf(fileID,'%.7e;%.7e\r\n',[xres yres]');
    fclose(fileID);
    %type(file_name)
end