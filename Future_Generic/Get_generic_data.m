function FutureData=Get_generic_data(startpt,endpt,infolist, contractlist,type,FutureData,Carry_setting)

for i=startpt:endpt %size(contctlist,2)
    secname=infolist.Name2{i}; secname=strrep(secname,' ','_');
    G1name=infolist.Generic_1{i};
    G2name=infolist.Generic_2{i};
    G3name=infolist.Generic_3{i};

    if ~strcmp(type,'Currency')
        strpos=strfind(G1name,'1');
        G1name_stitched=[G1name(1:strpos) ' ' Carry_setting ' ' G1name(strpos+1:end)]; % Non-stitched Generic 1 Time series
        G2name_stitched=[G2name(1:strpos) ' ' Carry_setting ' ' G2name(strpos+1:end)]; % Non-stitched Generic 2 Time series
        Gname={G1name G2name G3name G1name_stitched G2name_stitched};
    else
        strpos=strfind(G2name,'1');
        G2name_stitched=[G2name(1:strpos) ' ' Carry_setting ' ' G2name(strpos+1:end)]; % Non-stitched Generic 1 Time series
        G3name_stitched=[G3name(1:strpos) ' ' Carry_setting ' ' G3name(strpos+1:end)]; % Non-stitched Generic 2 Time series
        Gname={G1name G2name G3name G2name_stitched G3name_stitched};
    end
    %% Generic Time series (insert new data into the existing data mat)
    fromdate='04-Jan-2022';
    GdatOld=FutureData.(secname);
    [~,ipos]=ismember(fromdate,datetime(GdatOld.timestamp)); %allocate the position of new data in the existing data mat

    if ipos==0
        error('Please check the fromdate');
    end

    todate=datestr(today()-1,'mm/dd/yyyy');
    field={'PX_LAST'};
    period='daily';
    currency=[];
    G1=bbggethistdata(Gname,field,fromdate,todate,period,currency);
    StartDT=infolist.Start_date(i);
    [~,id]=ismember(StartDT,datetime(G1.timestamp));

    %% Vertcat new data to Old data

    if id~=0 %Extract data from start date
        Gdat.Generic123Price=vertcat(GdatOld.Generic123Price(1:ipos-1,:),G1.PX_LAST(id:end,:)); %New
        Gdat.timestamp=vercat(GdatOld.timestamp(1:ipos-1,:),datetime(G1.timestamp(id:end,:))); %New

    else
        Gdat.Generic123Price=vertcat(GdatOld.Generic123Price(1:ipos-1,:),G1.PX_LAST); %New
        Gdat.timestamp=vertcat(GdatOld.timestamp(1:ipos-1,:),G1.timestamp); %New
    end

%****For inseting new series ************************
%     if id~=0 %Extract data from start date
%             Gdat.Generic123Price=G1.PX_LAST(id:end,:);
%            Gdat.timestamp=G1.timestamp(id:end,:);
%     else
%     Gdat.Generic123Price=G1.PX_LAST; %Old
%     Gdat.timestamp=G1.timestamp; %Old
%     end
%***************************************************
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

    G1ret=zeros(size(G1ts)); G2ret=zeros(size(G2ts));
    for j=2:size(G1ts,1)
        G1ret(j)=G1ts(j)/G1ts(j-1)-1;
        G2ret(j)=G2ts(j)/G2ts(j-1)-1;
    end

    Gdat.Generic12Return=table(G1ret,G2ret);

    %% Calculate Carry(annualised)
    %G1ts/G2ts/FutRollDT
    FutRollDT=Gdat.FutRollDT;
    Carry=NaN(size(G1ts));

    if ~strcmp(type,'Currency')
        G1ts_nonstitched=Gdat.Generic123Price.(4); %Generic 1st non-stitched
        G2ts_nonstitched=Gdat.Generic123Price.(5); %Generic 2nd non-stitched
    else
        G1ts_nonstitched=Gdat.Generic123Price.(1); %Spot
        G2ts_nonstitched=Gdat.Generic123Price.(4); %Generic 1st non-stitched
    end

    for j=1:size(G1ts_nonstitched,1)
        [~,id]=ismember(1,timestamp(j)<FutRollDT);%Find Generic 1st RollDate
        G1rollDT=FutRollDT(id);
        G2rollDT=FutRollDT(id+1);
        G12timegap=G2rollDT-G1rollDT;
        Carry(j)=(G1ts_nonstitched(j)-G2ts_nonstitched(j))/G2ts_nonstitched(j)*(252/G12timegap);%annualised carry
    end
    Gdat.Carry=Carry;
    Gdat.name=secname;

    %% Collected TimeTable
    Gdat.TimeTable=table2timetable(horzcat(Gdat.Generic123Price,Gdat.Generic12Return,...
        array2table(Gdat.Carry,'VariableNames',{'Carry'})),'RowTimes',datetime(Gdat.timestamp));

    i
    FutureData.(secname)=Gdat;
    eval([type, 'Data=FutureData;']);
    matfilename=strcat(type,'Data_RollT-1.mat');
    instruname=strcat(type,'Data');
    save(matfilename,instruname);
end

end
