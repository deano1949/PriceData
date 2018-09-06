%% Establish Connection to server-ny

conn=databaseconnection2serverny;

%% insert instrument
% instrument=readtable('future_generic_data.xlsx','sheet','Sigmaa005 Instrument',...
%     'Range','A:B');
% 
% colnames=fieldnames(instrument);colnames=colnames(1:end-1);
% 
% datainsert(conn,'instrument',colnames,instrument);
% 
%% insert data into "future_contract"
% future_contract=readtable('future_generic_data.xlsx','sheet','Sigmaa005 Expirydate',...
%     'Range','D:L');
% 
% colnames=fieldnames(future_contract);colnames=colnames(1:end-1);
% 
% datainsert(conn,'future_contract',colnames,future_contract);


%% quick data format

load FUTRAWTS.mat
tbl=readtable('Quandl\ContractID mysqlid.xlsx');
id=tbl.instrument_id;
sym=tbl.Symbol;
BigTxt=[];
for i=113:size(id,1) %Contract mysql command
    futdat=FUTRAWTS.(sym{i});
    txt1='insert into input.eod_data values(';
    txt_id=num2str(id(i));
    txt2=',''';
    txt3=datestr(datenum(futdat.Date,'dd/mm/yyyy'),'yyyy-mm-dd');
    txt4=''',';
    txt5=num2str(futdat.High);
    txt6=',';
    txt7=num2str(futdat.Low);
    txt8=',';
    txt9=num2str(futdat.Open);
    txt10=',';
    txt11=num2str(futdat.Close);
    txt12=',''';
    txt13='bloomberg''';
    txt14=',''';
    txt15='2018-03-23'');';
    
    
    finaltext=strcat(txt1,txt_id,txt2,txt3,txt4,txt5,...
        txt6,txt7,txt8,txt9,txt10,...
        txt11,txt12,txt13,txt14,txt15);
    
%     curs=exec(conn,'SELECT * FROM input.future_contract where symbol=''CAC40'' and delivery_year=2015 and delivery_month=6;');
%     curs=fetch(curs);
%     
%     expirydate=futdat.Date(end,:);
%     Expirydatelist{i,1}=nm{i};
%     Expirydatelist{i,2}=expirydate;
    BigTxt=[BigTxt;finaltext];
end

%% insert eod_data

%load instrument id
