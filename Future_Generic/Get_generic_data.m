function FutureData=Get_generic_data(startpt,endpt,infolist, contractlist,type,FutureData)
infolistname=fieldnames(infolist);

for i=startpt:endpt %size(contctlist,2)
    secname=infolist.Name2{i}; secname=strrep(secname,' ','_');
    G1name=infolist.Generic_1{i};
    G2name=infolist.Generic_2{i};
    G3name=infolist.Generic_3{i};
    Gname={G1name G2name G3name};
    %% Generic Time series
    fromdate='01/01/1987';
    todate=datestr(today()-1,'mm/dd/yyyy');
    field={'PX_LAST'};
    period='daily';
    currency=[];
    G1=bbggethistdata(Gname,field,fromdate,todate,period,currency);
    StartDT=infolist.Start_date(i);
    [~,id]=ismember(StartDT,G1.timestamp);
    if id~=0 %Extract data from start date
        Gdat.Generic123Price=G1.PX_LAST(id:end,:);
        Gdat.timestamp=G1.timestamp(id:end,:);
    else
        Gdat.Generic123Price=G1.PX_LAST;
        Gdat.timestamp=G1.timestamp;
    end
    %% Futures Contract list
    FutRollinfo='LAST_TRADEABLE_DT';
    FutConList=contractlist.(secname);%Contract name
    [ix,id]=ismember('',FutConList); %remove empty cells
    if ix==1
        FutConList=FutConList(1:id-1);
    end
    
    LastTradeDT=bbggetstaticdata(FutConList,FutRollinfo);
    LastTradeDT=LastTradeDT.(FutRollinfo);
    FutRollDT=LastTradeDT-1; %Roll @ T-1
    wkdt=weekday(FutRollDT);
    for k=1:size(FutRollDT) % if T-1 is Sat/Sun, Futures roll @ Fri
        if weekday(FutRollDT(k))==7
            FutRollDT(k)=FutRollDT(k)-1;
        elseif weekday(FutRollDT(k))==1
            FutRollDT(k)=FutRollDT(k)-2;
        end
    end
    
    if isnan(sum(FutRollDT))
        display(FutRollDT)
        error(strcat('Please check Future Contract ',secname,' name in infolist'));      
    end
    
    FutRolldate=datestr(FutRollDT,'dd/mm/yyyy');    
    Gdat.FutCon=FutConList;
    Gdat.FutRollDT=FutRollDT;
    
    %% Calculate Generic TS returns
    timestamp=datenum(Gdat.timestamp,'dd/mm/yyyy');
    G1ts=Gdat.Generic123Price.(1); %Generic 1st
    G2ts=Gdat.Generic123Price.(2); %Generic 2nd
    G3ts=Gdat.Generic123Price.(3); %Generic 3rd
    
    G1ret=zeros(size(G1ts)); G2ret=zeros(size(G2ts));
    for j=2:size(G1ts,1)
        if ~strcmp(type,'Currency')
            if ismember(timestamp(j-1),FutRollDT)
                G1ret(j)=G1ts(j)/G2ts(j-1)-1;
                G2ret(j)=G2ts(j)/G3ts(j-1)-1;
            else
                G1ret(j)=G1ts(j)/G1ts(j-1)-1;
                G2ret(j)=G2ts(j)/G2ts(j-1)-1;
            end
        else
            G1ret(j)=G1ts(j)/G1ts(j-1)-1;
            if ismember(timestamp(j-1),FutRollDT)
                G2ret(j)=G2ts(j)/G3ts(j-1)-1;
            else
                G2ret(j)=G2ts(j)/G2ts(j-1)-1;
            end
        end  
    end
    
    Gdat.Generic12Return=table(G1ret,G2ret);
    
    %% Calculate Carry(annualised)
    %G1ts/G2ts/FutRollDT
    FutRollDT=Gdat.FutRollDT;
    Carry=NaN(size(G1ts));
    for j=1:size(G1ts,1)
        [~,id]=ismember(1,timestamp(j)<FutRollDT);%Find Generic 1st RollDate
        G1rollDT=FutRollDT(id);
        G2rollDT=FutRollDT(id+1);
        G12timegap=G2rollDT-G1rollDT;
        Carry(j)=(G1ts(j)-G2ts(j))/G2ts(j)*(252/G12timegap);%annualised carry
    end
    Gdat.Carry=Carry;
    Gdat.name=secname;
   i
FutureData.(secname)=Gdat;
eval([type, 'Data=FutureData;']);
matfilename=strcat(type,'Data_RollT-1.mat');
instruname=strcat(type,'Data');
save(matfilename,instruname);
end

end
