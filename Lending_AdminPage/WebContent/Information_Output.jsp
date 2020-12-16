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
		
		<div id="lending_upload">
			<span class="register_sentence"><h1>Lending Registration</h1></span>
			<span class="update_sentence"><h1>Lending Update</h1></span>
			<a class="b_btn" href="javascript:lending_info();" style="width:70px;">목록</a>
			<br>
			카테고리값 : <input type="text" class="category"/>
			<br><br>
			대관명 : <input type="text" class="lending_name"/>
			<br><br>
			주최자 : <input type="text"  class="organizer_name"/>
			<br><br>
			short_URL : <input type="text" size="34" class="short_url"/>
			<br><br>
			이미지 : <span class="update_sentence">* 파일선택을 하지 않을경우 이전 이미지가 그대로 유지됩니다.</span> <div id="preview"><img id="img1" /></div>
			<br>
			<input type="file" id="FILE_TAG" accept="image/*" />
			<br>
			<span class="register_sentence"><a class="btn btn-danger register_button">전송</a></span>
			<span class="update_sentence"><a class="btn btn-danger update_button">전송</a></span>
		</div>
	</div>
	
<script type="text/javascript">

var doc_id;

$().ready(function(){

	lending_info();
	
	 $("#FILE_TAG").on("change", fileimage);
	
});

function lending_info(){
	$('#lending_upload').hide();
	$('#lending_info').show();
	
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
			html+= "<a class=\"b_btn\" href=\"javascript:lending_register();\">대관 추가</a>";
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

function lending_register(){
	
	$('#lending_info').hide();
	$('#lending_upload').show();
	$('.register_sentence').show();
	$('.update_sentence').hide();
}

$(".register_button").click(function(){
	var inputFile = $("#FILE_TAG");
		var files = inputFile[0].files[0];
		
    if(!validImageType(files)) { 
        alert("이미지파일 형식이 아닙니다.(.jpg .jpeg .png)");
        return;
    } 
    
    var formData = new FormData();
    
    formData.append('uploadFile',files);
    formData.append("category",$('.category').val());
    formData.append("lending_name",$('.lending_name').val());
    formData.append("organizer_name",$('.organizer_name').val());
    formData.append("short_url",$('.short_url').val());

    
    /* 아래 코드로 formData 값 확인가능 */
    /* for (var pair of formData.entries()) { console.log(pair[0]+ ', ' + pair[1]); } */

    
    
    /* processData는 일반적으로 서버에 전달되는 데이터가 String형태로 전달된다.이를 피하기 위해 false로 설정 해주어야함 */
    /* contentType에서 파일을 보내줄 때는 multipart/form-data로 전송해야하기 때문에 false로 설정해준다.*/
    $.ajax({
        url: 'Lending_AdminPage/regist.len',
        processData: false,
        contentType: false,
        data: formData,
        type: 'POST',
        success: function(result){
        	alert("업로드 성공!!");
        	location.href = "/Lending_AdminPage/";
        	//main값 다시 꾸려주기
        }
    });  
});

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
	$('#lending_upload').show();
	$('.register_sentence').hide();
	$('.update_sentence').show();
	
	$(".category").val($(".c_"+index).children(".info_category").text());
	$(".lending_name").val($(".c_"+index).children(".info_lending_name").text());
	$(".organizer_name").val($(".c_"+index).children(".info_organizer_name").text());
	$(".short_url").val($(".c_"+index).children(".info_short_url").text());
	
	var image = $(".c_"+index).find("img").attr('src');
	image = image.split("/image/");
	image = image[1];
	
	// ---------------------------------------------------------------------------------------------------------
	

}

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

$(".update_button").click(function(){
	
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
        	/* $("#lending_upload").hide();
        	$("#lending_info").show(); */
        }	
	});
	
});

function Avoid_Overlap(file){ //중복이름 방지
	var dt = new Date();
	var time = dt.getTime();
	return time+file.name;
}

//이미지 여부 체크
//찾는곳.indexOf(찾고자 하는것) = -1 (-1은 없음을 의미=false)
function validImageType(files) {
	  var result = ([ 'image/jpeg',
	                    'image/png',
	                    'image/jpg' ].indexOf(files.type) > -1);
	  return result;
};
</script>
</body>
</html>