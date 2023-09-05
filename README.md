## What is the system for?
##### This is a system that records the amount of refueling, the unit price and the mileage of the current car every time you refuel.

## what was used.
##### This system uses mui framework, html5+, and hBuilder IDE development environment. It is responsible for packaging a hybrid app. The advantage of HBuilder is that it is compatible with IOS system and Android system.

##### The background was initially developed using classic asp+mdb, and then changed to a php+mysql system because the project was migrated to a non-iis environment (Linux system), (the asp system may not be available because of the front-end update), if necessary Modify the pass parameters.

##### The front-end and back-end interactions use ajax to access the background and use json to return data.

## interface parameters
To pass parameters, use the get method to pass parameters.

### add data
| parameter | value | detail | 
|:----- | :----: | ---- |
| action | add | "add" command  |
| data | format: year,month,day,mile,price,gallon | use","to connect those value and send to server need action="add" | 
| return json | | {state:'success'} OR {state:'fail',error: err_info} | 

<img src="https://github.com/conanluo/fuilingDataLog/blob/main/1.jpg" style="width:500px">

### view data by year
| parameter | value | detail | 
|:----- | :----: | ---- |
| action | json |  "view" command |
| year | eg: 2022 | check the year your need | 
| return json | | {list:[<BR>{&nbsp;&nbsp;&nbsp;id:156,<br>&nbsp;&nbsp;&nbsp;date{year:2022,month:11,day:20},<br>&nbsp;&nbsp;&nbsp;mile:19546,<br>&nbsp;&nbsp;&nbsp;gallon:9.361,<BR>&nbsp;&nbsp;&nbsp;price:4.799,<br>&nbsp;&nbsp;&nbsp;total:44.92<br>&nbsp;&nbsp;&nbsp;},...]<br>}| 

### update data
| parameter | value | detail | 
|:----- | :----: | ---- |
| action | update | "edit" command  |
| condition | format: id:2 | Provide the modified id | 
| value | nDate:2023-12-31,mile:19546,price:4.799,gallon:9.361 | Provide the modified all data | 
| return json | | {state:'success'} OR {state:'fail',error: err_info} | 

### update data
| parameter | value | detail | 
|:----- | :----: | ---- |
| action | dle | "delete" command  |
| id | 2 | Provide the delete id | 
| return json | | {state:'success'} OR {state:'fail',error: err_info} | 

### update data
| parameter | value | detail | 
|:----- | :----: | ---- |
| action | showSummary | "summary" command  |
| showType | 0, 1 , 2 or "" | "" or 2: show by year,  1: show by year-month ,0 show all | 
| sumYear | 2022 | Provide the summary year | 
| return json | | {state:'success',<br>,oilChangeMile:14219,<br>oilChangeDate:"2022-09-02",<br>action:{type:"showSummary",isSuccess:true,showType:""}data:[{year:2022,(month:12,)mile:20321,gallon:9.321,mpg:34.21,total:3256,mpd:7.94,avgPrice:4.428},...]} OR {state:'fail',error: err_info} <br>(total->the days total money;mpd->mile per dollor)| 

<img src="https://github.com/conanluo/fuilingDataLog/blob/main/2.jpg" style="width:500px">

### update oil-Change data
| parameter | value | detail | 
|:----- | :----: | ---- |
| action | updateOilChange | "updateOilChange" command  |
| showType | 0, 1 , 2 or "" | "" or 2: show by year,  1: show by year-month ,0 show all | 
| sumYear | 2022 | Provide the summary year | 
| return json | | {state:'success',<br>,oilChangeMile:14219,<br>oilChangeDate:"2022-09-02",<br>action:{type:"updateOilChange",isSuccess:true,showType:2}data:[{year:2022,(month:12,)mile:20321,gallon:9.321,mpg:34.21,total:3256,mpd:7.94,avgPrice:4.428},...]} OR {state:'fail',error: err_info} <br>(total->the days total money;mpd->mile per dollor)| 


<img src="https://github.com/conanluo/fuilingDataLog/blob/main/3.jpg" style="width:500px">

<img src="https://github.com/conanluo/fuilingDataLog/blob/main/4.jpg" style="width:500px">

