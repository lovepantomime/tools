% writes setup parameters to _ini.nc file for ROMS runs

function [] = write_params_to_ini(ininame, param, varname)

    if ~exist('varname','var'), varname = inputname(2); end
    
    if isstruct(param)
        names = fieldnames(param);
        for i=1:length(names)
            field = param.(names{i});
            if numel(field) < 2 || ischar(field)
                write_params_to_ini(ininame,field,[inputname(2) '.' names{i}]);
            end
        end
        return
    end
       
    % create & write variable in netcdf file
    try
        if ~ischar(param)
            nccreate(ininame,varname,'Datatype',class(param));%,'Dimensions',{size(param)},'Datatype',class(param));
        else
            nccreate(ininame,varname,'Datatype',class(param),'Dimensions', ...
                     {[varname '_1'] 1 [varname '_2'] length(param)});
        end
    catch ME
    end
    
    ncwrite(ininame,varname,param)