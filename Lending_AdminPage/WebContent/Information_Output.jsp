<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script src="${pageContext.request.contextPath}/resource/js/jquery.js"></script>

<title>Insert title here</title>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.4.1/css/bootstrap.min.css">

<style type="text/css">
	.b_btn{
		border-radius: 10px;
		text-decoration: none;
		display:block;
	    width:80px;
	    line-height:30px;
	    text-align:center;
	    background-color:#222;
	    color:#fff;
</style>

</head>

<body>

	<div id="lending_info">
		<!-- 대관 정보 출력  -->
	</div>

<script type="text/javascript">

var doc_id;

$().ready(function(){

	var url = "/Lending_AdminPage/loadAll.len";
	
	$.ajax({
		url : url,
		dataType : "json",
		contentType : "application/json; charset=utf-8",
		success : function(res){
			
			var lending = res.lending;
			doc_id = res._id.$oid.toString();
			
			//console.log(lending.length);
			var html = "";
			html+= "<div class=\"container\">";
			html+= "<h1>Lending Info</h1>";
			html+= "<a class=\"b_btn\" href=\"\">대관 추가</a>";
			html+= "<br>";
			html+= "<table class=\"table\">";
			html+= "<thead><tr>";
			html+= "<th>카테고리</th><th>대관이름</th><th>대관신청자</th><th>URL</th><th>이미지</th> <th></th><th></th>";
			html+= "</tr></thead>";
			html+= "<tbody>";
			
		    for(var i=0; i<(lending.length); i++){

		    	var category = lending[i].category;
		    	var lending_name = lending[i].lending_name;	
		    	var organizer_name = lending[i].organizer_name;
		    	var short_url = lending[i].short_url;
		    	var image = lending[i].image;
		    	
		    	var link = "/image/"; 
				console.log(link+image);
				
		    	html+= "<tr class=\"c_"+i+"\">";
		    	html+= "<td>"+category+"</td>";
		    	html+= "<td>"+lending_name+"</td>";
		    	html+= "<td>"+organizer_name+"</td>";
		    	html+= "<td><a  href=\""+short_url+"\" target=\"_blank\" >"+short_url+"</a></td>";
		    	html+= "<td><img src=\""+link+image+"\" style=\"width:100px;\"></td>"; 
		    	/* html+= "<td>"+image+"</td>"; */ 
		    	html+= "<td><button class=\"btn btn-danger\" onclick=\"lending_delete("+i+",'"+image+"')\">삭제</button></td>";
		    	html+= "<td><button class=\"btn btn-info\" onclick=\"lending_update("+i+",'"+image+"')\">수정</button></td>";
		    	html+= "</tr>";
		    }
		    
	    	html+= "</tbody>";
			html+= "</table>";
			html+= "</div>";
			
			
			
			$('#lending_info').html(html);			
			
		},
		error : function(e){
			console.log("현재 대관 anyone 부분에서 '등록된 대관 정보'가 없습니다.")
		}
	})
	
});

function lending_delete(index,image) {
	//console.log(index);
	
	var result = confirm("정말로 해당 대관내용을 삭제하시겠습니까?");
	
	
	if(result){
		var url = "Lending_AdminPage/delete.len";
		var data = JSON.stringify({ 
			"index" : index,
			"doc_id" : doc_id,
			"image" : image
		});

 		$.ajax({
			
			type : "POST",
			dataType : "json",
			contentType : "application/json; charset=utf-8",
			data : data,
			url : url,
			success : function(res){
				$(".c_"+index).remove();
				//$("tbody>tr:eq("+index+")").remove();
				
			},
			error : function(e){
				alert("ERROR!(lending_delete) : " + e);
			}
		
		}); 

	} 
	
}

function lending_update(index,image) {
	
	
	
}
</script>
</body>
</html>