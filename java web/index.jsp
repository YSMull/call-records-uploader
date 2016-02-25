<%@page import="java.util.HashMap"%>
<%@page import="java.util.LinkedList"%>
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<%@ page import="java.sql.*" %> 

<%@ page import="java.text.SimpleDateFormat" %> 
<%@ page import="java.util.Calendar" %>
<%@ page import="java.util.TimeZone" %>
<%@ page import="java.math.BigDecimal" %>  
	
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Insert title here</title>
<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="js/highcharts.js"></script>
	<script type="text/javascript">
	window.onload = function(){
		var sel = document.getElementsByTagName("select");
		sel[0].onchange = function(){
			
			var request = new XMLHttpRequest();
			
			var method = "POST";
			//var url = "../../../../www/html/show.php";
			var url = "http://115.159.42.107:8080/html/show.php";
			request.open(method, url);
			request.send(null);
			//request.setRequestHeader("ContentType", "application/json");
			request.onreadystatechange = function(){
				if(request.readyState == 4) {
					if(request.status == 200 || request.status == 304) {
						//alert(request.resopnseText);
						var json = eval("(" + request.resopnseText + ")");
						//var json = JSON.parse(request.resopnseText);
            			alert(json.toJSONString());//读取json数据
					}
				}
			}
			return false;
		}
	}
</script>
</head>




<script type="text/javascript" src="js/modules/exporting.js"  type="text/javascript"></script>
<body onload="chart()">
<form>
<select name="call_type" onchange="chart()">
<option value="ALL">拨出</option>
<option value="saab">接入</option>
<option value="fiat">未接通</option>
</select>
</form>
<p>选择功能未完成，目测要用ajax技术</p>
<div id="container" style="height: 75%; min-width: 70%"></div>

</body>

<%!
public int between(long t1, long t2) {
	TimeZone.setDefault(TimeZone.getTimeZone("GMT+8"));
	Date start = new Date(t1);
	Date stop = new Date(t2);
	Calendar start_c = Calendar.getInstance(); 
	start_c.setTime(start);
	Calendar stop_c = Calendar.getInstance();  
	stop_c.setTime(stop);
	int bet = 0;
	/*
	System.out.println(start_c.get(Calendar.DAY_OF_YEAR));
	System.out.println(stop_c.get(Calendar.DAY_OF_YEAR));
	SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");  
	String st1 = sdf.format(new Date(t1*1000));
	String st2 = sdf.format(new Date(t2*1000));
	System.out.println(st1);
	System.out.println(st2);
	*/
	while(true) {
		if(start_c.get(Calendar.YEAR) > stop_c.get(Calendar.YEAR)) break;
		if(start_c.get(Calendar.YEAR) == stop_c.get(Calendar.YEAR) && 
		   start_c.get(Calendar.DAY_OF_YEAR) >= stop_c.get(Calendar.DAY_OF_YEAR))
			break;
		if(start_c.get(Calendar.YEAR) < stop_c.get(Calendar.YEAR)) {
			start_c.add(Calendar.DATE, 1);
			bet++;
			continue;
		}
		if(start_c.get(Calendar.DAY_OF_YEAR) < stop_c.get(Calendar.DAY_OF_YEAR)) {
			start_c.add(Calendar.DATE,1);
			bet++;
			continue;
		}
		
	}
	return bet;
}
%>

<%!
public class Data_S_L {
	public String v_S;
	public String v_L;
	public Data_S_L(String s, String l) {
		this.v_L = l;
		this.v_S = s;
	}
}
%>
<%
Class.forName("com.mysql.jdbc.Driver").newInstance();  
Connection conn = DriverManager.getConnection("jdbc:mysql://localhost/huanhuan","root","*****");  
Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);  

String sql = "select * from phone_data where number = '15527704622' or number = '18772381046' or number = '15549689673' order by date";  

ResultSet rs = stmt.executeQuery(sql); 
ResultSetMetaData rmeta = rs.getMetaData(); 
int numColumns=rmeta.getColumnCount(); 
if(numColumns > 0) {
	//System.out.println(numColumns);
}

LinkedList<Data_S_L> lt = new LinkedList<Data_S_L>();
while(rs.next()) {
	Data_S_L sl = new Data_S_L(rs.getString(1),rs.getString(3));
	lt.add(sl);
	//SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");  
	//String sd = sdf.format(new Date(Long.parseLong(rs.getString(1))));  
	//out.println(sd);
	//out.print("<br>");

    //var data = [<%=values.toString()%\>],
}
Long start = Long.parseLong(lt.getFirst().v_S);
Long stop	= Long.parseLong(lt.getLast().v_S);
//long start = 1454255969000;2016-01-31 23:59:29
//long stop  = 1454260229000;2016-02-01 01:10:29
//long day=(stop - start)/(24*60*60*1000); wrong!
long interval = between(start, stop);
//out.print(between(start, stop));
//out.print("<br>");

LinkedList<Double> plotData = new LinkedList<Double>();

for(int i = 0; i <= interval; i++) {
	double a = 0;
	plotData.add(a);
}

for(int i = 0; i < lt.size(); i++) {
	int curr = between(Long.parseLong(lt.getFirst().v_S),
					Long.parseLong(lt.get(i).v_S));
	double aaa = plotData.get(curr);
	aaa += Long.parseLong(lt.get(i).v_L);
	plotData.set(curr, aaa);
}

for(int i = 0; i <= interval; i++) {
	BigDecimal bg = new BigDecimal(plotData.get(i)/60.0);  
    double f1 = bg.setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
	plotData.set(i, f1);
}

//out.print(plotData.toString());
SimpleDateFormat year=new SimpleDateFormat("yyyy");
SimpleDateFormat month=new SimpleDateFormat("MM");  
SimpleDateFormat day=new SimpleDateFormat("dd");  
String y_start = year.format(new Date(Long.parseLong(lt.getFirst().v_S)));
String m_start = month.format(new Date(Long.parseLong(lt.getFirst().v_S)));
String d_start = day.format(new Date(Long.parseLong(lt.getFirst().v_S)));
String y_stop = year.format(new Date(Long.parseLong(lt.getLast().v_S)));
String m_stop = month.format(new Date(Long.parseLong(lt.getLast().v_S)));
String d_stop = day.format(new Date(Long.parseLong(lt.getLast().v_S)));
%>


<script>
function chart() {
    $('#container').highcharts({
        chart: {
            zoomType: 'x',
            spacingRight: 20
        },
        title: {
            text: '<%out.print("给猪猪打电话时长");%>'
        },
        subtitle: {
            text: document.ontouchstart === undefined ?
                '<%out.print("从"+y_start+"年"+m_start+"月到"+y_stop+"年"+m_stop+"月");%>' :
                '<%out.print("从"+y_start+"年"+m_start+"月到"+y_stop+"年"+m_stop+"月");%>'
        },
        credits:{
     		enabled:false // 禁用版权信息
		},
        xAxis: {
            type: 'datetime',
            maxZoom: 14 * 24 * 3600000, // fourteen days
            title: {
                text: null
            }
        },
        yAxis: {
            title: {
                text: '通话时长(分钟)'
            }
        },
        tooltip: {
            shared: true
        },
        legend: {
            enabled: false
        },
        plotOptions: {
            area: {
                fillColor: {
                    linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1},
                    stops: [
                        [0, Highcharts.getOptions().colors[0]],
                        [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                    ]
                },
                lineWidth: 1,
                marker: {
                    enabled: false
                },
                shadow: false,
                states: {
                    hover: {
                        lineWidth: 1
                    }
                },
                threshold: null
            }
        },

        series: [{
            type: 'area',
            name: '通话时长',
            pointInterval: 24 * 3600 * 1000,
            pointStart: Date.UTC(
            <%//2015, 6, 26
        		out.print(y_start+","+String.valueOf((Integer.parseInt(m_start)-1))+","+d_start);
            %>),
            data: <%out.print(plotData.toString());%>
        }]
    });
}				
</script>
   
</html>