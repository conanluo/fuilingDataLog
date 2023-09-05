<?php
//数据库连接 mysql---begin----

//------------ 连接数据库---正式服-----------------
// $servername = "Your_Host"; 
// $username = "your_username";
// $password = "your_PW";
// $dbname = "your_DB_Name";
//------------ 连接数据库---正式服-----------------


//------------ 连接数据库---测试服-----------------
// $servername = "Your_Test_Host"; 
// $username = "your_username";
// $password = "your_PW";
// $dbname = "your_DB_Name";
//------------ 连接数据库---测试服-----------------


// 创建连接
$conn = mysqli_connect($servername, $username, $password,$dbname);

// 检测连接
if (!$conn) {
   die("连接失败: " . mysqli_connect_error());
}



//数据库连接 mysql---end----


$data=$_GET["data"];
$action=$_GET["action"];
$datas=explode(",",$data);

    if(count($datas)==6 and $action=="add"){//action为添加,datas需要6个参数

        if(is_numeric($datas[0]) and is_numeric($datas[1]) and is_numeric($datas[2]) and is_numeric($datas[3]) and is_numeric($datas[4]) and is_numeric($datas[5]){
            $mDate=$datas[0]."/".$datas[1]."/".$datas[2];
            $mile=(int) $datas[3];
            $price=(float) $datas[4];
            $gallon=(float) $datas[5];
            //计算总数
            $total=$price*$gallon;

            $sql="INSERT INTO tData(nDate, mile, price, gallon) VALUES ('$mDate', $mile,$price,$gallon)";

            if (mysqli_query($conn, $sql)) {//以json形式输出状态
                echo "{state:'success'}";
            } else {
                echo "{state:'fail',error:'".mysqli_error($conn)."'}";
            }
        }else{
            echo "{state:'fail',error:'data参数格式错误'}";

        }
    }elseif($action=="json"){//action为json, 查看模式
        $checkYear=$_GET["year"];//获取查询年份
        if($checkYear=="") $checkYear=date("Y");//如果没提供,默认查询今年
        $sql="select * from vData where DYear=$checkYear order by nDate DESC";
        $result = mysqli_query($conn, $sql);
        $resultJson="{\"list\":[";
        
        $r=mysqli_fetch_assoc($result);
        while($r){
            $resultJson.='{';
                $resultJson.='"id":'.$r["ID"].",";
                $resultJson.='"date":{';
                    $resultJson.='"year":'.$r["DYear"];
                    $resultJson.=',"month":'.$r["DMonth"];
                    $resultJson.=',"day":'.$r["DDay"];
                $resultJson.='},';
                $resultJson.='"mile":'.$r["mile"].",";
                $resultJson.='"price":'.$r["price"].",";
                $resultJson.='"gallon":'.$r["gallon"].",";
                $resultJson.='"total":'.$r["total"];
            $resultJson.='}';


            $r=mysqli_fetch_assoc($result);//查找下一个
            //如果$r还有值,添加逗号
            if($r) $resultJson.=",";
        }
        $resultJson.="]}";
        echo $resultJson;

        //echo "$sql";

    }elseif($action=="update"){// 当action为update,是更新数据
        $outputString="{state:'fail',error:'缺少参数'}";
        if($_GET["condition"]!="" and $_GET["value"]!=""){
            
            $condition=str_replace(":", "=",$_GET["condition"]);//格式例如    id:2,然后str_resplace 为  id=2
            $valueList=str_replace(":", "=",$_GET["value"]);//格式例如 nDate:2022-09-25,mile:56311,price:4.999,gallon:9.04 然后通过 str_replace 讲:替换=
            $tableName="tData";//修改tData表数据
            //组合sql更新语句
            $sql="update $tableName set ";

            $values=explode(",",$valueList);//拆分每个字段跟数值
            $sql.=(explode("=",$values[0])[0].'="'.explode("=",$values[0])[1].'",');//除了第一个数值需要修改其他直接套用
            $sql.=$values[1].",";
            $sql.=$values[2].",";
            $sql.=$values[3];
            
            $sql.=" where $condition";
            if (mysqli_query($conn, $sql)) {
                $outputString = "{state:'success'}";
            } else {
                $outputString = "{state:'fail',error:'".mysqli_error($conn)."'}";
            }
        }

        echo $outputString;
    }elseif ($action=="del") {// 当action为del,是删除数据,需要提交id信息
        $outputString="{state:'fail',error:'缺少参数'}";
        $id=$_GET["id"];
        if($id!=""){//id是必须有的参数
            $sql="delete from tData where id=".$id;
            if (mysqli_query($conn, $sql)) {
                $outputString = "{state:'success'}";
            } else {
                $outputString = "{state:'fail',error:'".mysqli_error($conn)."'}";
            }
        }
        echo $outputString;
    }elseif($action=="showSummary" or $action=="updateOilChange"){//action是showSummary,updateOilchange需要查找整个base表
        //初始化变量
        $outputString='{"state":"success",';
        $error="'缺少参数'";
        $baseTable="Base";
        $sql="";
        $showType=$_GET["showType"];

        $sumYear=$_GET["sumYear"];
        $oilDate=$_GET["oilDate"];
        $oilMile=$_GET["oilMile"];
        
        //初始化各个日期如果没有传值,取今天
        if($sumYear=="") $sumYear=date('Y');
        if($oilDate=="") $oilDate=date('Y-m-d');
        //初始化oilMile值,为空则为0
        if($oilMile=="") $oilMile=0;
        //showType 为空,默认2 (显示年份)
        if($showType=="") $showType=2;
        elseif(is_numeric($showType)) $showType=(int) $showType;
        else $showType=2;
        //isSuccess,布尔值检测状态是不是更新
        $isSuccess="true"; 

        
        if($action=="updateOilChange"){//当action为updateOilChange,是更新oilchange数据(表为Base)
            $sql='update base set oilChangeMile='.$oilMile.' ,oilChangeDate="'.$oilDate.'"';
            if (mysqli_query($conn, $sql)) {
                $isSuccess="true";
                $outputString.='"info":"更新换油信息",';
            } else {
                $isSuccess="false";
                $outputString='{"state":"fail","error":"更新换油信息时出错",';
            }
            // echo $sql;
        }
        //sql的拼接元素
        $sql="select * from Base, ";
        $table=" summaryByYear ";//默认查找年份
        $opt="";//条件,按月份时需要
        $orderby=" order by DYear desc";
        //拼接sql语句( 例子 select * from base, summaryByYear )
         if($showType<2){//月份或全部
            $table=" summaryByMonth ";
            if($showType==1){//按照指定年份的月份查询
                $opt=" where DYear=$sumYear ";
            }
            $orderby.=" , dMonth desc ";
        }
        $sql=($sql.$table.$opt.$orderby);
//echo $sql."<br>";
        $result = mysqli_query($conn,$sql);
        $r=mysqli_fetch_assoc($result);

        //拼接输出json语句
        //先拼接data数组之前的数据
        $outputString.='"oilChangeMile":'.$r["oilChangeMile"].',"oilChangeDate":"'.$r["oilChangeDate"].'",';
        $outputString.='"action":{"type":"'.$action.'","isSuccess":'.$isSuccess.',"showType":'.$showType.'},';
        $outputString.='"data":[';
        //拼接data内容.
        while($r){
            $outputString.="{";
                $outputString.='"year":'.$r["DYear"].',';
                if($showType<2){
                    $outputString.='"month":'.$r["DMonth"].',';
                }
                $outputString.='"mile":'.$r["mile"].',';
                $outputString.='"gallon":'.$r["gallon"].',';
                $outputString.='"mpg":'.$r["mpg"].',';
                $outputString.='"total":'.$r["total"].',';
                $outputString.='"mpd":'.$r["mpd"].',';
                $outputString.='"avgPrice":'.$r["avgPrice"];
            $outputString.="}";
            
            $r=mysqli_fetch_assoc($result);//查找下一个
            //如果$r还有值,添加逗号
            if($r) $outputString.=",";
        }
        
        
        $outputString.="]}";
        echo $outputString;
    }else{
        echo '{"state":"fail","error":"错误入口,请联系管理员(接口数据丢失)"}';
    }


// 关闭连接
mysqli_close($conn);
?>