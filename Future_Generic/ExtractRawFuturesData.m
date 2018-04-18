% function Gen_data_generic()
% Amyaddpath('Home');
% addmypath
% javaaddpath('F:\MATLAB\blpapi3.jar');

%% Get contract list
% clc;clear
infolist=readtable('Future_Generic_data.xlsx','sheet','IndexInfo');
contractlist=readtable('Future_Generic_data.xlsx','sheet','Sigmaa005 Instruments');

contractlist=contractlist(50:124,:);
futlist=fieldnames(contractlist); 
LastTradeDT=table;
load FUTRAWTS.mat
for i=[3 4 10:14] %length(futlist)-1
    futnm=futlist{i};
    futinst=contractlist.(futnm);
    Gname=futinst; %futures name
    staticdat=bbggetstaticdata(Gname,{'LAST_TRADEABLE_DT'}); %get last trading date
    staticTable=table(datestr(staticdat.LAST_TRADEABLE_DT,'yyyymmdd'),'VariableNames',cellstr(futnm));
    fromdate=staticdat.LAST_TRADEABLE_DT -180;
    todate=staticdat.LAST_TRADEABLE_DT;
    
    for j=1:size(todate,1)
        field={'PX_HIGH','PX_LOW','PX_OPEN','PX_LAST'};
        period='daily';
        currency=[];
        tsdat=bbggethistdata(Gname{j},field,fromdate(j),todate(j),period,currency);
        tsmat=table(tsdat.timestamp,'VariableNames',{'Date'}); %timestamptable
        tsmat=horzcat(tsmat,table(table2array(tsdat.PX_HIGH), table2array(tsdat.PX_LOW), ...
            table2array(tsdat.PX_OPEN), table2array(tsdat.PX_LAST),'VariableNames',{'High','Low','Open','Close'}));
        futbbgname=fieldnames(tsdat.PX_HIGH); 
        futbbgname=futbbgname{1};
        FUTRAWTS.(futbbgname)=tsmat;
    end
save FUTRAWTS.mat FUTRAWTS

% Save LastTradeDT (annual task)
%     LastTradeDT=horzcat(LastTradeDT,staticTable);
% save LastTradeDT.mat LastTradeDT

end
