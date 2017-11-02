function Gen_market_index()
addpath('O:\langyu\Reading\Systematic_Trading_RobCarver\VIX subsystem');
load('O:\langyu\Reading\Systematic_Trading_RobCarver\VIX subsystem\Setting.mat')
timestamp=setting.timestamp;
timenum=datenum(timestamp,'dd/mm/yyyy');

%% Equity
load EquityData_RollT-1.mat

instrumentlist=fieldnames(EquityData);
mat1=NaN(size(timenum,1),length(instrumentlist)-1); %average of generic 1st returns
mat2=NaN(size(timenum,1),length(instrumentlist)-1); %average of generic 2nd returns

for i=2:length(instrumentlist)-1
    datasys=EquityData.(instrumentlist{i});
    tsdat1=datasys.Generic12Return.G1ret;
    tsdat2=datasys.Generic12Return.G2ret;
    t1=datenum(datasys.timestamp,'dd/mm/yyyy');

    lookupts1=tsvlookup(timenum,t1,tsdat1);
    lookupts2=tsvlookup(timenum,t1,tsdat2);
    
    mat1(:,i-1)=lookupts1(:,2);
    mat2(:,i-1)=lookupts2(:,2);
end

mkt.name='Equity_Market_Equal_Weighted_Index';
mkt.timestamp=setting.timestamp;
mkt.Generic12Return=table;
mkt.Generic12Return.G1ret=smartmean(mat1,2);
mkt.Generic12Return.G2ret=smartmean(mat2,2);
mkt.Generic12Price=table;
mkt.Generic12Price.EQmkt1=ret2tick(mkt.Generic12Return.G1ret);
mkt.Generic12Price.EQmkt2=ret2tick(mkt.Generic12Return.G2ret);
mkt.Generic12Price=mkt.Generic12Price(2:end,:);

EquityData.EWIndex=mkt;
save EquityData_RollT-1.mat EquityData

%% Bonds

load Bond10YData_RollT-1.mat

instrumentlist=fieldnames(Bond10YData);
mat1=NaN(size(timenum,1),length(instrumentlist)); %average of generic 1st returns
mat2=NaN(size(timenum,1),length(instrumentlist)); %average of generic 2nd returns

for i=[1 3:length(instrumentlist)-1]
    datasys=Bond10YData.(instrumentlist{i});
    tsdat1=datasys.Generic12Return.G1ret;
    tsdat2=datasys.Generic12Return.G2ret;
    t1=datenum(datasys.timestamp,'dd/mm/yyyy');

    lookupts1=tsvlookup(timenum,t1,tsdat1); 
    lookupts2=tsvlookup(timenum,t1,tsdat2);
    
    mat1(:,i)=lookupts1(:,2);
    mat2(:,i)=lookupts2(:,2);
end
mkt=struct;
mkt.name='Bond_Market_Equal_Weighted_Index';
mkt.timestamp=setting.timestamp;
mkt.Generic12Return=table;
mkt.Generic12Return.G1ret=smartmean(mat1,2);
mkt.Generic12Return.G2ret=smartmean(mat2,2);
mkt.Generic12Price=table;
mkt.Generic12Price.FImkt1=ret2tick(mkt.Generic12Return.G1ret);
mkt.Generic12Price.FImkt2=ret2tick(mkt.Generic12Return.G2ret);
mkt.Generic12Price=mkt.Generic12Price(2:end,:);

Bond10YData.EWIndex=mkt;
save Bond10YData_RollT-1.mat Bond10YData

