% function Gen_data_generic()
% Amyaddpath('Home');
% addmypath
% javaaddpath('F:\MATLAB\blpapi3.jar');

%% Get contract list
infolist=readtable('price_generic_data.xlsx','sheet','IndexInfo');

load indexdata.mat
IndexData=get_etf_general_data(1,1,infolist,'Index',IndexData);
save indexdata.mat IndexData

load equityetfdata.mat
EquityETFData=Get_ETF_general_data(2,5,infolist,'EquityETF',EquityETFData);
save equityetfdata.mat EquityETFData

load fietfdata.mat
FIETFData=Get_ETF_general_data(6,8,infolist,'FIETF',FIETFData);
save fietfdata.mat FIETFData

load comdtyetfdata.mat
ComdtyETFData=Get_ETF_general_data(9,12,infolist,'ComdtyETF',ComdtyETFData);
save comdtyetfdata.mat ComdtyETFData
