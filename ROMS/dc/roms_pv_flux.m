% Calculate PV fluxes through a section along index 'ind' (for PV) of axis 'axis'
%        [pvflux] = roms_pv_flux(hisname,pvname,axis,ind,plot)

function [pvflux] = roms_pv_flux(hisname,pvname,tindices,axis,ind,plot)
    
    % if pv file doesn't exist, create it.
    if strcmp(pvname,hisname), roms_pv(hisname,tindices), end
    
    if ~exist('plot','var'), plot = 0; end
    
    %% figure out fluxing velocity and averaging 
    ax = 'xyz';
    vx = 'uvw';
    avgind = {[2 3], [3 1], [1 2]};
    per = {[1 2 3 4]; [2 1 3 4]; [2 3 1 4]};
    
    if ischar(axis), axis = find(ax == axis); end
    heading = ['Total PV fluxed through ' ax(axis) ' = '];
    ax = axis; % index
    vx = vx(ax);
    avgind = avgind{ax};
    
    [gridv{1},gridv{2},gridv{3},tv,~,~] = roms_var_grid(hisname,vx);
    [gridpv{1},gridpv{2},gridpv{3},tpv,~,~] = roms_var_grid(pvname,'pv');
    
    sliceax = gridpv{ax};
    if strcmp(ind,'mid'), ind = num2str((sliceax(1)+sliceax(end))/2); end
    if ischar(ind), ind = find_approx(sliceax,str2double(ind),1); end  
    
    heading = [heading num2str(sliceax(ind))];
    
    %% parse input
    vinfo = ncinfo(hisname,'u');
    s     = vinfo.Size;
    dim   = length(s); 
    slab  = 30;
    if ~exist('tindices','var'), tindices = []; end
    [iend,tindices,dt,nt,stride] = roms_tindices(tindices,slab,vinfo.Size(end));
    
    %% calculate fluxes
    %pvflux = nan([tindices(2)-tindices(1)+1]); DO THIS
    
    for i=0:iend-1
        [read_start,read_count] = roms_ncread_params(dim,i,iend,slab,tindices,dt);
        tstart = read_start(end);
        tend   = read_start(end) + read_count(end) -1;

        % Read pv
        read_start(ax) = ind;
        read_count(ax) = 1;
        pv  = ncread(pvname,'pv',read_start,read_count);   
        % read velocity at points on either side of interior RHO point and then average
        read_start(ax) = ind-1; 
        read_count(ax) = 2;
        vel = avg1(ncread(hisname,vx,read_start,read_count),ax);
       
        L1 = max(gridpv{avgind(1)}) - min(gridpv{avgind(1)});
        L2 = max(gridpv{avgind(2)}) - min(gridpv{avgind(2)});

        % obtain vel on pv grid
        switch vx
            case 'u'
                vel = avg1(vel(:,2:end-1,:,:),3);
        end
    
        % calculate flux
        pvflux(tstart:tend) = squeeze( -1 * trapz(gridpv{avgind(2)}, ... % integrate along second axis
                                    trapz(gridpv{avgind(1)},pv.*vel,avgind(1))/L1 ... % integrate along first axis
                                    ,avgind(2))/L2);
                                
        % write to file if needed
    end
    
    if plot    
        figure;
        plot(tpv./86400,cumtrapz(tpv,pvflux));
        xlabel('Time (days)');
        ylabel('Integrated PV flux');
        title(heading);
    end