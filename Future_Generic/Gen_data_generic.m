% function Gen_data_generic()
% Amyaddpath('Home');
% addmypath
% javaaddpath('F:\MATLAB\blpapi3.jar');

%% Bloomberg setting (Check)
%% CDEF 2 <GO> set "Generic Futures Roll Defaults to 
%Days=1
%Adjust= Ratio

%% Get contract list
infolist=readtable('Future_Generic_data.xlsx','sheet','IndexInfo');
Global_Carry_setting=table2array(readtable('Future_Generic_data.xlsx','sheet','Adjusted Tickers','Range','B27:B28','Basic',1)); Global_Carry_setting=Global_Carry_setting{:};
contractlist=readtable('Future_Generic_data.xlsx','sheet','Mapping(Q)','ReadVariableNames',true,'UseExcel',true);

%% Equity (1:14)
load EquityData_RollT-1.mat
EquityData=Get_generic_data(1,14,infolist,contractlist,'Equity',EquityData,Global_Carry_setting);
save EquityData_RollT-1.mat EquityData
%% Commodity (15:37)
load ComdtyData_RollT-1.mat
ComdtyData=Get_generic_data(29,37,infolist,contractlist,'Comdty',ComdtyData,Global_Carry_setting); %Full: 21:30 are Agriculture
save ComdtyData_RollT-1.mat ComdtyData
%% Fixed Income (38:43)
load Bond10YData_RollT-1.mat
Bond10YData=Get_generic_data(38,43,infolist,contractlist,'Bond10Y',Bond10YData,Global_Carry_setting);
save Bond10YData_RollT-1.mat Bond10YData
%% Currency (44:52)
load CurrencyData_RollT-1.mat
CurrencyData=Get_generic_data(44,52,infolist,contractlist,'Currency',CurrencyData,Global_Carry_setting);
save CurrencyData_RollT-1.mat CurrencyData

% %% Crypto
% load Crypto_5minData.mat
% Carry_table=readtable('Future_Generic_data.xlsx','sheet','CryptoRollDate');
% Carry_adj_table=table(Carry_table.RollDT,Carry_table.Adj_Factor,'VariableNames',{'RollTime','AdjFactor'});
% Crypto_5minData=Get_Crypto_data(60,61,infolist,'Crypto',Crypto_5minData,Carry_adj_table);
% save Crypto_5minData.mat Crypto_5minData

try
    load('O:\langyu\Reading\Systematic_Trading_RobCarver\VIX subsystem\Setting.mat')
    setting.timestamp=EquityData.SPX.timestamp;
    save('O:\langyu\Reading\Systematic_Trading_RobCarver\VIX subsystem\Setting.mat','setting');
catch
    load('C:\Users\gly19\Dropbox\GU\1.Investment\4. Alphas (new)\17.Extract_Rollyield\0.Research\VIX\dat\Setting.mat');
    setting.timestamp=EquityData.ES.timestamp;
    save('C:\Users\gly19\Dropbox\GU\1.Investment\4. Alphas (new)\17.Extract_Rollyield\0.Research\VIX\dat\Setting.mat','setting');
    
    load('C:\Users\gly19\Dropbox\GU\1.Investment\4. Alphas (new)\17.Extract_Rollyield\0.Research\VIX\dat\Sigmaa005\Sigmaa005_Setting.mat');
    setting.timestamp=EquityData.ES.timestamp;
    save('C:\Users\gly19\Dropbox\GU\1.Investment\4. Alphas (new)\17.Extract_Rollyield\0.Research\VIX\dat\Sigmaa005\Sigmaa005_Setting.mat','setting');
end    
%% Get Market Index
Gen_market_index