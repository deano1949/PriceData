function FutureData=Get_Crypto_data(startpt,endpt,infolist,type,FutureData,Carry_adj_factor)
% infolistname=fieldnames(infolist);

for i=startpt:endpt %size(contctlist,2)
   
    secname=infolist.Name2{i}; secname=strrep(secname,' ','_');
    G1name=infolist.Generic_1{i};
    G2name=infolist.Generic_2{i};  
    Gname={G1name G2name};
    
    fromdate=datestr(today()-30,'mm/dd/yyyy');
    todate=datestr(today(),'mm/dd/yyyy HH:MM:SS');
    field={'Bid','Ask','Trade'};
    interval=5;
    
    % get intraday data
for k=1:length(field)
    olddata=FutureData.(secname).(strcat('Generic12',field{k}));
    for j=1:size(Gname,2)
        dat=bbggetintradata(Gname(j),field{k},fromdate,todate,interval);
            G1=table; G1.Time=datenum(dat.Time,'dd/mm/yyyy HH:MM:SS');G1.(strrep(strrep(Gname{j},' ','_'),':','_'))=dat.Close;
            if j==1
                GP=G1;
            end
            GP=innerjoin(GP,G1);
    end
    GP = sortrows(GP,'Time','ascend');
    GP.Time=datestr(GP.Time,'dd/mm/yyyy HH:MM:SS');

    %Stack new data with old data
    [~,id]=ismember(datenum(GP.Time(1,:),'dd/mm/yyyy HH:MM:SS'),datenum(olddata.Time,'dd/mm/yyyy HH:MM:SS'));
    if id==1
        newdata=GP;
    else
        olddata=olddata(1:id-1,:);
        newdata=vertcat(olddata,GP);
    end
    Gdat.(strcat('Generic12',field{k}))=newdata;
end
    
%% Mid Price time series
Gmid=table;
Generic12Ask=Gdat.Generic12Ask;
Generic12Bid=Gdat.Generic12Bid;
A2B=ismember(datenum(Generic12Ask.Time,'dd/mm/yyyy HH:MM:SS'),datenum(Generic12Bid.Time,'dd/mm/yyyy HH:MM:SS'));
Generic12Ask=Generic12Ask(A2B,:);
tempdata=join(Generic12Ask,Generic12Bid,'Keys','Time');
Gmid.Time=tempdata.Time;
Gmid.(Generic12Bid.Properties.VariableNames{2})=(table2array(tempdata(:,2))+table2array(tempdata(:,4)))/2;
Gmid.(Generic12Bid.Properties.VariableNames{3})=(table2array(tempdata(:,3))+table2array(tempdata(:,5)))/2;

Gdat.Generic12Mid=Gmid;
    %% Return time series 
    Gret=table;
    Gret.Time=Gmid.Time(2:end,:);
    Gret.(Gmid.Properties.VariableNames{2})=tick2ret(table2array(Gmid(:,2)));
    Gret.(Gmid.Properties.VariableNames{3})=tick2ret(table2array(Gmid(:,3)));
    %Apply rolling adj factor
    if strcmp(GP.Properties.VariableNames{3},'BTC1_Curncy')
        for k=1:size(Carry_adj_factor,1)-1
            [id,ix]=ismember(Carry_adj_factor.RollTime(k,:),Gret.Time);
            if id==1
            Gret.BTC1_Curncy(ix+1)= (Gret.BTC1_Curncy(ix+1)+1)*newdata.BTC1_Curncy(ix+1)/Carry_adj_factor.AdjFactor(k)-1;
            end
        end
    end
% %%Special Treatment for Spectrion Data
% % set roll dates' return to zero
% 
%     rollDT={'28/07/2021 22:00:00','25/08/2021 22:00:00','22/09/2021 22:00:00',...
%         '27/10/2021 22:00:00','24/11/2021 23:00:00'};
%     [~,id]=ismember(rollDT,Gret.Time);
%     Gret.BTC1_Curncy(id)=0;
%     Gret.XBTUSD_Curncy(id)=0;

    Gdat.Generic12Return=Gret; %Return Time Series
    %% Calculate Carry
    carry=table2array(Gmid(:,3))./table2array(Gmid(:,2))-1;
    Carry=table;
    Carry.Time=Gmid.Time;Carry.carry=carry;
    Gdat.Carry=Carry;
    Gdat.name=secname;

FutureData.(secname)=Gdat;
eval([type,'_',num2str(interval),'min', 'Data=FutureData;']);
matfilename=strcat(type,'_',num2str(interval),'min','Data.mat');
instruname=strcat(type,'_',num2str(interval),'min','Data');
save(matfilename,instruname);

end