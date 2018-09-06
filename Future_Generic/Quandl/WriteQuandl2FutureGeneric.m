%% Establish connection to Quandl

Quandl.api_key('xDy2BnggovVhXnES5Nf9');

%% Download data
Gen0=Quandl.get('CME/SIM2018'); %generic0
Gen1=Quandl.get('CME/SIU2018'); %generic1
Gen2=Quandl.get('CME/SIZ2018');%generic2
Gen3=Quandl.get('CME/SIH2019');%generic3

glydata=Silver; %load my own database

futurename=fieldnames(glydata.Generic123Price); %name of futures price table
lastdate=datenum(glydata.timestamp,'dd/mm/yyyy');lastdate=lastdate(end); %last date in my own database

Gen0date=datenum(Gen0.getabstime,'dd-mm-yyyy'); 
Gen0expirydate=Gen0date(end); %generic0's end date (load the previous expired contract just in case database is not up-to-date
Gen1date=datenum(Gen1.getabstime,'dd-mm-yyyy');
Gen1expirydate=Gen1date(end); %generic1's end date
Gen2date=datenum(Gen2.getabstime,'dd-mm-yyyy');
Gen2expirydate=Gen2date(end); %generic2's end date
Gen3date=datenum(Gen3.getabstime,'dd-mm-yyyy');
Gen3expirydate=Gen3date(end); %generic2's end date

G0SP=Gen0.Settle.Data; %Generic0 settle price
G1SP=Gen1.Settle.Data; %Generic1 settle price
G2SP=Gen2.Settle.Data; %Generic2 settle price
G3SP=Gen3.Settle.Data; %Generic3 settle price

while lastdate==Gen1expirydate
    if lastdate<Gen0expirydate
        [~,id0]=ismember(lastdate,Gen0date); 
        [~,id1]=ismember(lastdate,Gen1date); [~,ie1]=ismember(Gen0date(end-1),Gen1date); %enddate of generic0
        [~,id2]=ismember(lastdate,Gen2date); [~,ie2]=ismember(Gen0date(end-1),Gen2date);

        copydat(:,1)=G0SP(id0+1:end-1);
        copydat(:,2)=G1SP(id1+1:ie1);
        copydat(:,3)=G2SP(id2+1:ie2);

        glydata.Generic123Price=vertcat(glydata.Generic123Price,table(copydat(:,1),copydat(:,2),copydat(:,3),'VariableNames',futurename(1:end-1))); %merge price data
        glydata.timestamp=vertcat(glydata.timestamp,datestr(Gen0date(id0+1:end-1),'dd/mm/yyyy'));
        
        lastdate=datenum(glydata.timestamp,'dd/mm/yyyy');lastdate=lastdate(end); %last date in my own database

    elseif lastdate<Gen1expirydate
        [~,id1]=ismember(lastdate,Gen1date); 
        [~,id2]=ismember(lastdate,Gen2date); [~,ie2]=ismember(Gen1date(end),Gen2date);
        [~,id3]=ismember(lastdate,Gen3date); [~,ie3]=ismember(Gen2date(end),Gen3date);
        copydat=[];
        copydat(:,1)=G1SP(id1+1:end);
        copydat(:,2)=G2SP(id2+1:ie2);
        copydat(:,3)=G3SP(id3+1:ie3);

        glydata.Generic123Price=vertcat(glydata.Generic123Price,table(copydat(:,1),copydat(:,2),copydat(:,3),'VariableNames',futurename(1:end-1))); %merge price data
        glydata.timestamp=vertcat(glydata.timestamp,datestr(Gen1date(id1+1:end),'dd/mm/yyyy'));
        
        lastdate=datenum(glydata.timestamp,'dd/mm/yyyy');lastdate=lastdate(end); %last date in my own database
    end
end

%To do
%Produce generic return & carry
%automation on looping through insturments
%schedule time to download data