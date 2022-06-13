%%%%%%%%%%% junção dos dados do IBGE com os dados do ISNIS %%%%%%%%%%%%%%%%


T_isns = readtable('municipios_pb_prestadores.csv');
T_isns = T_isns(ismember(T_isns.Prestador,'Sem informações'),:);
T_ibge = readtable('ibge.xlsx');
T_isns.Properties.VariableNames{3} = 'Codigo_cidade';
T_join =join(T_isns,T_ibge);
T_join = removevars(T_join, {'Regi_o','Mesorregi_','Nome_Meso'});
T_join = removevars(T_join, {'Var1','OBJECTID','UF','Shape_Leng','Shape_Area','geometry','Prestador','x_reaTerritorial_Km__2021_'});
T_join.Properties.VariableNames{7} = 'Populacao';
T_join.Properties.VariableNames{8} = 'Densidade';
T_join.Properties.VariableNames{9} = 'IDHM';
T_join.Properties.VariableNames{11} = 'PIB_per_capita';

%%%%%%%%%%%%%%%%%%%% T_norm = tabela normalizada %%%%%%%%%%%%%%%%%%%%
T_norm = T_join;

%normaliza as densidades
dens_med = mean(T_norm.Densidade)
for i = 1:1:size(T_join)
T_norm.Densidade(i) = T_norm.Densidade(i)/dens_med;
end

%normaliza os IDHM
dens_med = mean(T_norm.IDHM)
for i = 1:1:size(T_join)
T_norm.IDHM(i) = T_norm.IDHM(i)/dens_med;
end

%normaliza o PIB
dens_med = mean(T_norm.PIB_per_capita)
for i = 1:1:size(T_join)
T_norm.PIB_per_capita(i) = T_norm.PIB_per_capita(i)/dens_med;
end

%normaliza a População
dens_med = mean(T_norm.Populacao);
for i = 1:1:size(T_join)
T_norm.Populacao(i) = T_norm.Populacao(i)/dens_med;
end

%%%%%%%%%%%%%%%%%%%% T_cust = tabela dos custos %%%%%%%%%%%%%%%%%%%%
T_cust = T_norm
%custo da do PIB e do IDHM fica igual. A função objetivo de minimização
%priorizará PIBs e IDHMs pequenos

%custo de Densidade, minimiza o custo pras cidades mais densas
for i = 1:1:size(T_cust)
T_cust.Densidade(i) = 1/T_cust.Densidade(i);
end

%custo da População, minimiza o custo pras cidades mais populosas
for i = 1:1:size(T_cust)
T_cust.Populacao(i) = 1/T_cust.Populacao(i);
end


%%%%%%%%%%%%%%%%%%%% A priorização será dada às cidades de menor custo por pessoa %%%%%%%%%%%%%%%%%%%%
T_cust.Properties.VariableNames{4} = 'Custo_Total';
T_cust.Properties.VariableNames{10} = 'Custo_Total_capita';
for i = 1:1:size(T_cust)
T_cust.Custo_Total(i) = T_cust.Populacao(i) + T_cust.Densidade(i) + T_cust.PIB_per_capita(i) + T_cust.IDHM(i);
T_cust.Custo_Total_capita(i) =  T_cust.Custo_Total(i)/T_join.Populacao(i);
end
T_cust.Var12(1,1) = 1;
T_cust.Properties.VariableNames{12} = 'Populacao_t';

T_cust.Populacao_t = T_join.Populacao
T_cust = sortrows(T_cust,'Custo_Total_capita','ascend');

head(T_cust.Custo_Total_capita)