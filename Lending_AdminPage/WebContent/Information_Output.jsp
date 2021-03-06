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
		text-decoration: none !important;
		display:block;
	    width:80px;
	    line-height:30px;
	    text-align:center;
	    background-color:#222;
	    color:white;
	}
	.b_btn:hover{
		color:white;
	}
</style>

</head>

<body>
	<div class="container">
		<div id="lending_info">
			<!-- 대관 정보 출력  -->
		</div>
		
		<div id="lending_update">
			<h1>Lending Update</h1>
			<a class="b_btn" href="${pageContext.request.contextPath}/Information_Output.jsp" style="width:70px;">목록</a>
			<br>
			카테고리값 : <input type="text" class="category"/>
			<br><br>
			대관명 : <input type="text" class="lending_name"/>
			<br><br>
			주최자 : <input type="text"  class="organizer_name"/>
			<br><br>
			short_URL : <input type="text" size="34" class="short_url"/>
			<br><br>
			이미지 : * 파일선택을 하지 않을경우 이전 이미지가 그대로 유지됩니다. <div id="preview"><img id="img1" /></div>
			<br>
			<input type="file" id="FILE_TAG" accept="image/*" />
			<br>
			<a class="btn btn-danger upload">전송</a>
		</div>
	</div>
	
<script type="text/javascript">

var doc_id;

$().ready(function(){

	lending_info();
	
});

function lending_info(){
	$('#lending_update').hide();
	
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
			html+= "<h1>Lending Info</h1>";
			html+= "<a class=\"b_btn\" href=\"${pageContext.request.contextPath}/Information_Registration.jsp\">대관 추가</a>";
			html+= "<br>";
			html+= "<table class=\"table\">";
			html+= "<thead><tr>";
			html+= "<th>카테고리</th><th>대관이름</th><th>대관신청자</th><th>URL</th><th>이미지</th><th></th><th></th>";
			html+= "</tr></thead>";
			html+= "<tbody>";
			
		    for(var i=0; i<(lending.length); i++){

		    	var category = lending[i].category;
		    	var lending_name = lending[i].lending_name;	
		    	var organizer_name = lending[i].organizer_name;
		    	var short_url = lending[i].short_url;
		    	var image = lending[i].image;
		    	
		    	var link = "/image/";
				
		    	html+= "<tr class=\"c_"+i+"\">";
		    	html+= "<td class=\"info_category\">"+category+"</td>";
		    	html+= "<td class=\"info_lending_name\">"+lending_name+"</td>";
		    	html+= "<td class=\"info_organizer_name\">"+organizer_name+"</td>";
		    	html+= "<td class=\"info_short_url\"><a  href=\""+short_url+"\" target=\"_blank\" >"+short_url+"</a></td>";
		    	html+= "<td><img src=\""+link+image+"\" style=\"width:100px;\"></td>"; 
		    	/* html+= "<td>"+image+"</td>"; */ 
		    	html+= "<td><button class=\"btn btn-danger\" onclick=\"lending_delete("+i+")\">삭제</button></td>";
		    	html+= "<td><button class=\"btn btn-info\" onclick=\"lending_update("+i+")\">수정</button></td>";
		    	html+= "</tr>";
		    }
		    
	    	html+= "</tbody>";
			html+= "</table>";
			
			
			$('#lending_info').html(html);			
			
		},
		error : function(e){
			console.log("현재 대관 anyone 부분에서 '등록된 대관 정보'가 없습니다.")
		}
	});
}

function lending_delete(index) {
	//console.log(index);
	var image = $(".c_"+index).find("img").attr('src');
	image = image.split("/image/");
	image = image[1];
	
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

function lending_update(index) {
	
	$('#lending_info').hide();
	$('#lending_update').show();
	
	$(".category").val($(".c_"+index).children(".info_category").text());
	$(".lending_name").val($(".c_"+index).children(".info_lending_name").text());
	$(".organizer_name").val($(".c_"+index).children(".info_organizer_name").text());
	$(".short_url").val($(".c_"+index).children(".info_short_url").text());
	
	var image = $(".c_"+index).find("img").attr('src');
	image = image.split("/image/");
	image = image[1];
	
	// ---------------------------------------------------------------------------------------------------------
	
	$(document).ready(function() {
        $("#FILE_TAG").on("change", fileimage);
       
    });
	
	function fileimage(e){
		
		var files = e.target.files;
        var filesArr = Array.prototype.slice.call(files);
        
        
        filesArr.forEach(function(f) {
            if(!f.type.match("image.*")) {
                alert("확장자는 이미지 확장자만 가능합니다.");
                return;
            }

            var reader = new FileReader();
            reader.onload = function(e) {        
            	$("#preview > img").attr('style', "height:100px;");
            	$("#preview > img").attr("src", e.target.result);
            }
            reader.readAsDataURL(f);
        });
    
	};
	
	$(".upload").click(function(){
		
		var formData = new FormData();
		
		if($("#FILE_TAG").val()!=""){
			
			var inputFile = $("#FILE_TAG");
      		var files = inputFile[0].files[0];
			
      		//파일 내용 변경
      		formData.append('uploadFile',files);
      		
		}else{
			//파일 내용 유지
			formData.append('uploadFile',"");           
		}
		
		formData.append("doc_id",doc_id);
		formData.append("index",index);
		formData.append("category",$('.category').val());
        formData.append("lending_name",$('.lending_name').val());
        formData.append("organizer_name",$('.organizer_name').val());
        formData.append("short_url",$('.short_url').val());
        formData.append("image",image);

        var url = "/Lending_AdminPage/update.len";
        
		$.ajax({
		 	url: url,
            processData: false,
            contentType: false,
            data: formData,
            type: 'POST',
            success: function(result){
            	alert("수정 성공!!");
            	location.href = "/Lending_AdminPage/";
            	/* $("#lending_update").hide();
            	$("#lending_info").show(); */
            }	
		});
		
	});
	
	//이미지부분이 change될 경우 , ajax에 파일 업로드한다.
	
}

</script>
</body>
</html>