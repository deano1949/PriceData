% addmypath

%% Get contract list
contctlist=readtable('Future Generic data.xlsx','sheet','Mapping(Q)');
contractname=fieldnames(contctlist);
for i=1:1 %size(contctlist,2)
    secname=contctlist.(i);
    %Time series
    fromdate='01/01/2005';
    todate='03/30/2017';
    field={'PX_LAST'};
    period='daily';
    currency=[];
    dat=bbggethistdata(secname,field,fromdate,todate,period,currency);
    FutureMasterData.(contractname{i})=dat.PX_LAST;
    
    %Contract Info
    FutRollinfo='FUT_ROLL_DT';
    info=bbggetstaticdata(secname,FutRollinfo);
    FutRolldate=info.(FutRollinfo);
    FutRolldate=datestr(FutRolldate,'dd/mm/yyyy');
end

save FutureMasterData.mat FutureMasterData