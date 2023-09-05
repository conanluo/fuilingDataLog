Create View
`tempGroupByYear` AS
(select `vdata`.`DYear` AS `DYear`,max(`vdata`.`mile`) AS `currentMile`,round(sum(`vdata`.`gallon`),3) AS `totalGallon`,round(sum(`vdata`.`total`),2) AS `totalMoney` from `sqlwpblog`.`vdata` group by `vdata`.`DYear` order by `vdata`.`DYear` desc)