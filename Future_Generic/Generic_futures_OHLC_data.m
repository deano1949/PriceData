workbook='Generic_Futures_OHLC.xlsx';
[status,sheets,xlFormat] = xlsfinfo(workbook);

for i=1:size(sheets,2)
    sheetname=sheets{i};
    dat=readtable(workbook,'Sheet',sheetname,'Range','A5:E10000','ReadVariableNames',true);
    dat=dat(~isnan(dat.PX_OPEN),:);
    dat=dat(~dat.PX_OPEN==0,:);
    dat=dat(2:end,:);
    sheetname=strrep(sheetname,' ','_');
    FUTROHLC.(sheetname)=dat;
end

save FUTROHLC.mat FUTROHLC