source =   {'Calvin';  'PanJab';  'Nokia'};
target = {'????'  '?????',  '???'};
T = table(target, 'RowNames', source);
writetable(T,'dictionary.csv', 'Encoding', 'UTF-8');