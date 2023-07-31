% function Gen_data_generic()
% Amyaddpath('Home');
% addmypath
% javaaddpath('F:\MATLAB\blpapi3.jar');

%% Get contract list
infolist=readtable('price_generic_data.xlsx','sheet','IndexInfo');

load indexdata.mat
[~,ix]=ismember(infolist.AssetType,'Index'); ix=find(ix==1,100);
IndexData=get_etf_general_data(256:300,infolist,'Index',IndexData); %177:462
save indexdata.mat IndexData

load equityetfdata.mat
[~,ix]=ismember(infolist.AssetType,'Equity'); %find the index numbers matching Equity
ix=find(ix==1,50);
EquityETFData=get_etf_general_data(transpose(ix),infolist,'EquityETF',EquityETFData);
save equityetfdata.mat EquityETFData

load fietfdata.mat
[~,ix]=ismember(infolist.AssetType,'FI'); ix=find(ix==1,50);
FIETFData=get_etf_general_data(transpose(ix),infolist,'FIETF',FIETFData);
save fietfdata.mat FIETFData

load comdtyetfdata.mat
[~,ix]=ismember(infolist.AssetType,'Comdty'); ix=find(ix==1,50);
ComdtyETFData=get_etf_general_data(transpose(ix),infolist,'ComdtyETF',ComdtyETFData);
save comdtyetfdata.mat ComdtyETFData
