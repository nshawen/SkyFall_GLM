%% InterpData

load labels_full_rot.mat

t=0:.02:4.98;
tbar=0:1/6:29/6;

for i=1:length(labels.acce)
    if size(labels.acce{i},1)>99
        data=labels.acce{i};
        
        % remove duplicates
        data=sortrows(data);
        data(diff(data(:,1))==0,:)=[];
        
        labels.acce{i}=[t' spline(data(:,1)'-data(1,1),data(:,2:end)',t')'];
    end
    if size(labels.gyro{i},1)>99
        data=labels.gyro{i};
        
        % remove duplicates
        data=sortrows(data);
        data(diff(data(:,1))==0,:)=[];
        
        labels.gyro{i}=[t' spline(data(:,1)'-data(1,1),data(:,2:end)',t')'];
    end
    if size(labels.baro{i},1)>9
        data=labels.baro{i};
        
        % remove duplicates
        data=sortrows(data);
        data(diff(data(:,1))==0,:)=[];
        
        labels.baro{i}=[tbar' spline(data(:,1)'-data(1,1),data(:,2:end)',tbar')'];
    end
end

save labels_full_interp.mat labels