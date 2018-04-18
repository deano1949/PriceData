%% Description
% Check data quality and futures data stitching

%%
try
    dir='C:\Spectrion\Data\PriceData\Future_Generic\';
    load(strcat(dir,'EquityData_RollT-1.mat'));

catch
    dir='O:\langyu\Reading\Systematic_Trading_RobCarver\Futures Generic\';
end

load(strcat(dir,'EquityData_RollT-1.mat'));
load(strcat(dir,'Bond10YData_RollT-1.mat'));
load(strcat(dir,'ComdtyData_RollT-1.mat'));
load(strcat(dir,'CurrencyData_RollT-1.mat'));

%% Equity
    %SPX
        dat=EquityData.SPX;
        x=EquityData.SPX.Generic123Price.SP1_Index;
        xret=[0;tick2ret(x)];
        xret_stitched=EquityData.SPX.Generic12Return.G1ret;

        ix=round(xret,8)~=round(xret_stitched,8);
        ftsmtx=fints(datenum(dat.timestamp,'dd/mm/yyyy'),[xret_stitched xret]);
        ftsmtx=ftsmtx(ix);