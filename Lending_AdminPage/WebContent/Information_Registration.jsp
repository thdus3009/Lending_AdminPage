<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<script src="${pageContext.request.contextPath}/resource/js/jquery.js"></script>

<script src="${pageContext.request.contextPath}/resource/dropzone/dropzone.js"></script>
<link rel="stylesheet" href="${pageContext.request.contextPath}/resource/dropzone/dropzone.min.css" />

<style type="text/css">
	.btn{
		border-radius: 20px;
		text-decoration: none;
		display:block;
	    width:80px;
	    line-height:30px;
	    text-align:center;
	    background-color:#222;
	    color:#fff;
	}

</style>

<title>Insert title here</title>
</head>
<body>

	카테고리값 : <input type="text" class="category"/>
	<br><br>
	대관명 : <input type="text" class="lending_name"/>
	<br><br>
	주최자 : <input type="text"  class="organizer_name"/>
	<br><br>
	short_URL : <input type="text" size="34" class="short_url"/>
	<br><br>
	
	<div id="preview">
		<img id="img1" /> 
	</div>
	이미지 : <!-- <input type="text"  class="image" value="ddd.jpg">  -->
	<!--  required : 'form이 submit 될 때' 파일이 반드시 선택되어야 하는지 여부를 결정하는 것 -->
	<!--  multiple : 다중선택 가능 -->  
       <input type="file" id="FILE_TAG" accept="image/*" />
       
	<br><br>
       <a class="btn" href="javascript:uploadFile();">전송</a>
	<!-- <button id="save">등록</button> -->

		
	
	
	<script type="text/javascript">
		/* $('#save').click(function(){ */ 
		
		//이미지 미리보기
		$(document).ready(function() {
            $("#FILE_TAG").on("change", fileimage);
        });
        
        //onchange > input태그의 내용변경을 감지 시켜준다.	
		function fileimage(e){
			
			var files = e.target.files;
            var filesArr = Array.prototype.slice.call(files);
 
            filesArr.forEach(function(f) {
                if(!f.type.match("image.*")) {
                    alert("확장자는 이미지 확장자만 가능합니다.");
                    return;
                }
 
                sel_file = f;
 
                var reader = new FileReader();
                reader.onload = function(e) {        
                	$("#preview > img").attr('style', "height:100px;");
                	$("#preview > img").attr("src", e.target.result);
                }
                reader.readAsDataURL(f);
            });
        
		};
		
		//파일 및 다른 내용들 업로드
		function uploadFile(){	
			//let 변수 / const 상수
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
	            }
            });  

			
            // 이건 보내는 정보가 전부 string 타입
/* 			var category = $('.category').val();
			var lending_name = $('.lending_name').val();
			var organizer_name = $('.organizer_name').val();
			var short_url = $('.short_url').val();
			var image = $('.image').val();
			
			var url = "/Lending_Page/regist.len";
			
			var data = JSON.stringify({ 
				"category" : category,
				"lending_name" : lending_name,
				"organizer_name" : organizer_name,
				"short_url" : short_url,
				"image" : image
			});
			
 			$.ajax({
				type:"POST",
				dataType:"json",
				data:data,
				contentType:"application/json; charset=utf-8",
				url:url,
				success:function(res){
					alert("등록이 완료되었습니다.");
				},
				error:function(e){
					alert("ERROR(lending_register) : " + e);
				}
			
			}); */
			 
		};
		
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