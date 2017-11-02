function code=extractMonthCode(ContractName)
    if ~isempty(strfind(ContractName,'Comdty'))
        id=length(ContractName)-length('xx Comdty');
        code=ContractName(id);
    elseif ~isempty(strfind(ContractName,'Index'))
        id=length(ContractName)-length('xx Index');
        code=ContractName(id);
    end
end
