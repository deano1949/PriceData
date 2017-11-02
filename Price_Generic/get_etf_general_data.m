function PriceData=get_etf_general_data(startpt,endpt,infolist,type,PriceData)
infolistname=fieldnames(infolist);

for i=startpt:endpt %size(contctlist,2)
    secname=infolist.Name2{i}; secname=strrep(secname,' ','_');
    Gname=infolist.BBG_code{i};
    %% Generic Time series
    fromdate='01/01/1987';
    todate=datestr(today()-1,'mm/dd/yyyy');
    field={'PX_LAST'};
    period='daily';
    currency=[];
    G1=bbggethistdata({Gname},field,fromdate,todate,period,currency);
    StartDT=infolist.Start_date(i);
    [~,id]=ismember(StartDT,G1.timestamp);
    if id~=0 %Extract data from start date
        Gdat.GPrice=G1.PX_LAST(id:end,:);
        Gdat.timestamp=G1.timestamp(id:end,:);
    else
        Gdat.GPrice=G1.PX_LAST;
        Gdat.timestamp=G1.timestamp;
    end
%     %% Futures Contract list
%     FutRollinfo='LAST_TRADEABLE_DT';
%     FutConList=contractlist.(secname);%Contract name
%     [ix,id]=ismember('',FutConList); %remove empty cells
%     if ix==1
%         FutConList=FutConList(1:id-1);
%     end
%     
%     LastTradeDT=bbggetstaticdata(FutConList,FutRollinfo);
%     LastTradeDT=LastTradeDT.(FutRollinfo);
%     FutRollDT=LastTradeDT-1; %Roll @ T-1
%     wkdt=weekday(FutRollDT);
%     for k=1:size(FutRollDT) % if T-1 is Sat/Sun, Futures roll @ Fri
%         if weekday(FutRollDT(k))==7
%             FutRollDT(k)=FutRollDT(k)-1;
%         elseif weekday(FutRollDT(k))==1
%             FutRollDT(k)=FutRollDT(k)-2;
%         end
%     end
%     
%     FutRolldate=datestr(FutRollDT,'dd/mm/yyyy');    
%     Gdat.FutCon=FutConList;
%     Gdat.FutRollDT=FutRollDT;
    
    %% Calculate Generic TS returns
%     timestamp=datenum(Gdat.timestamp,'dd/mm/yyyy');
    G1ts= Gdat.GPrice.(1); %Price
    
    G1ret=[0 ;tick2ret(G1ts)];
    
    Gdat.GReturn=G1ret;
    Gdat.GPrice=G1ts;
    
   i
PriceData.(secname)=Gdat;
eval([type, 'Data=PriceData;']);
matfilename=strcat(lower(type),'data.mat');
instruname=strcat(type,'Data');
save(matfilename,instruname);
end

end
