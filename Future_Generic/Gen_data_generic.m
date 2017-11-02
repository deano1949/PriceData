% function Gen_data_generic()
% Amyaddpath('Home');
% addmypath
% javaaddpath('F:\MATLAB\blpapi3.jar');

%% Get contract list
infolist=readtable('Future_Generic_data.xlsx','sheet','IndexInfo');
contractlist=readtable('Future_Generic_data.xlsx','sheet','Mapping(M)');
%Equity
load EquityData_RollT-1.mat
EquityData=Get_generic_data(1,14,infolist,contractlist,'Equity',EquityData);
save EquityData_RollT-1.mat EquityData
%Commodity
load ComdtyData_RollT-1.mat
ComdtyData=Get_generic_data(15,37,infolist,contractlist,'Comdty',ComdtyData); %Full: 15:37
save ComdtyData_RollT-1.mat ComdtyData
%Fixed Income
load Bond10YData_RollT-1.mat
Bond10YData=Get_generic_data(38,43,infolist,contractlist,'Bond10Y',Bond10YData);
save Bond10YData_RollT-1.mat Bond10YData
%Currency
load CurrencyData_RollT-1.mat
CurrencyData=Get_generic_data(44,46,infolist,contractlist,'Currency',CurrencyData);
save CurrencyData_RollT-1.mat CurrencyData
% end

load('O:\langyu\Reading\Systematic_Trading_RobCarver\VIX subsystem\Setting.mat')
setting.timestamp=EquityData.SPX.timestamp;
save('O:\langyu\Reading\Systematic_Trading_RobCarver\VIX subsystem\Setting.mat','setting');

%% Get Market Index
Gen_market_index