Create View
`tempGroupByMonth` AS
(select `vdata`.`DYear` AS `DYear`,`vdata`.`DMonth` AS `DMonth`,max(`vdata`.`mile`) AS `currentMile`,round(sum(`vdata`.`gallon`),3) AS `totalGallon`,round(sum(`vdata`.`total`),2) AS `totalMoney` from `sqlwpblog`.`vdata` group by `vdata`.`DYear`,`vdata`.`DMonth` order by `vdata`.`DYear` desc,`vdata`.`DMonth` desc)