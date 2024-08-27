function options = readOptions()
fileId = fopen('settings.json', 'r');
raw = fread(fileId, inf);
str = char(raw');
fclose(fileId);
options = jsondecode(str);
end