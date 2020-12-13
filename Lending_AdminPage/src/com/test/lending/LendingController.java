package com.test.lending;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.NoSuchElementException;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import org.bson.types.ObjectId;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.mongodb.BasicDBObject;
import com.mongodb.DB;
import com.mongodb.DBCollection;
import com.mongodb.DBCursor;
import com.mongodb.DBObject;
import com.mongodb.MongoClient;
import com.mongodb.WriteConcern;
import com.mongodb.util.JSON;

/**
 * fileSizeThreshold 서버로 파일을 저장할 때 파일의 임시 저장 사이즈 maxFileSize 1개 파일에 대한 최대 사이즈
 * maxRequestSize 서버로 전송되는 request의 최대 사이즈
 */

@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 10, // 10 MB
		maxFileSize = 1024 * 1024 * 50, // 50 MB
		maxRequestSize = 1024 * 1024 * 100) // 100 MB

public class LendingController extends HttpServlet {

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(req, resp);
	}

	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");
		response.setCharacterEncoding("UTF-8");
		response.setContentType("text/html; charset=UTF-8");

		MongoClient mongoClient = null;
		DBCollection coll = null;

		final long serialVersionUID = -4793303100936264213L;

		final String UPLOAD_DIR = "filefolder";

		// DB 연결
		try {
			String MongoDB_IP = "localhost";
			int MongoDB_Port = 27017;
			mongoClient = new MongoClient(MongoDB_IP, MongoDB_Port);

			System.out.println("server 접속 성공");

			// 쓰기권한 부여
			WriteConcern w = new WriteConcern(1, 2000);// 쓰게 락 갯수, 연결 시간 2000
														// //쓰레드 쓰게되면 2개 동시에 쓸
														// 경우도 생기니까
			mongoClient.setWriteConcern(w);
			// 데이터베이스 연결
			DB db = mongoClient.getDB("lending");
			// 컬렉션 가져오기
			coll = db.getCollection("lending");
			System.out.println("db,collection 접속 성공");
			System.out.println();

		} catch (Exception e) {
			System.out.println(e.getMessage());
		}

		PrintWriter out = response.getWriter();

		// 조회
		if (request.getRequestURI().endsWith("loadAll.len")) {

			try {

				BasicDBObject query = new BasicDBObject();
				DBCursor cursor = coll.find(query);
				DBObject doc = cursor.next();

				System.out.println("데이터 o");
				// System.out.println(doc.get("lending"));

				out.println(doc);

			} catch (NoSuchElementException e) {
				// lending값에 아무것도 없을때 (java.util.NoSuchElementException)

				System.out.println("데이터 x");

			}

			// 등록(테스트버전)
		} else if (request.getRequestURI().endsWith("before_regist.len")) {

			// post타입으로 넘겨 받은 정보
			String data = getBody(request);
			JsonParser parser = new JsonParser();
			JsonElement xjson = parser.parse(data);
			JsonObject reg = xjson.getAsJsonObject();

			// String 타입으로 바꾸기
			String category = reg.get("category").getAsString();
			String lending_name = reg.get("lending_name").getAsString();
			String organizer_name = reg.get("organizer_name").getAsString();
			String short_url = reg.get("short_url").getAsString();
			String image = reg.get("image").getAsString();

			/*----------------------------------------------*/

			// db조회 : 에러확인 - lending collection에 document 있는지 확인
			BasicDBObject query = new BasicDBObject();
			DBCursor cursor = coll.find(query);

			try {

				// 있다면 해당 _id 값 확인 // 없다면 catch부분으로 넘어감
				DBObject doc = cursor.next();

				// System.out.println((doc.get("_id").toString()).getClass().getName());
				// //변수 타입 확인
				String docID = doc.get("_id").toString(); // _id 조회
				System.out.println(docID);

				System.out.println("데이터 추가(update+$push)");

				query.put("_id", new ObjectId(docID));

				DBObject lending2 = new BasicDBObject();
				lending2.put("category", category);
				lending2.put("lending_name", lending_name);
				lending2.put("organizer_name", organizer_name);
				lending2.put("short_url", short_url);
				lending2.put("image", image);

				DBObject rdata = new BasicDBObject("lending", lending2);
				DBObject se = new BasicDBObject("$push", rdata);
				coll.update(query, se);

			} catch (NoSuchElementException e) {

				// lending값에 아무것도 없을때 (java.util.NoSuchElementException)
				// 새로운 document 생성
				System.out.println("document 새로 생성");

				DBObject lending1 = new BasicDBObject();
				lending1.put("category", category);
				lending1.put("lending_name", lending_name);
				lending1.put("organizer_name", organizer_name);
				lending1.put("short_url", short_url);
				lending1.put("image", image);

				DBObject doc = new BasicDBObject();
				doc.put("lending", Arrays.asList(lending1));
				coll.insert(doc);
			}

			/*----------------------------------------------*/

			// 파일 업로드 (업로드하고 정보올라가야하나..?)

			JsonObject res = new JsonObject();
			res.addProperty("result", "OK");
			out.println(res.getAsJsonObject());

			// 등록
		} else if (request.getRequestURI().endsWith("regist.len")) {

			String category = request.getParameter("category");
			String lending_name = request.getParameter("lending_name");
			String organizer_name = request.getParameter("organizer_name");
			String short_url = request.getParameter("short_url");

			Part filePart = request.getPart("uploadFile");
			String image = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

			// -----------------파일업로드 시작

			// 서버의 실제 경로
			String applicationPath = request.getServletContext().getRealPath("");
			String uploadFilePath = applicationPath + UPLOAD_DIR;

			// System.out.println(" LOG :: [서버 루트 경로] :: " + applicationPath);
			// System.out.println(" LOG :: [파일 저장 경로] :: " + uploadFilePath);

			// creates the save directory if it does not exists
			File fileSaveDir = new File(uploadFilePath);

			// 파일 경로 없으면 생성
			if (!fileSaveDir.exists()) {
				fileSaveDir.mkdirs();
			}

			// System.out.println(image);
			// System.out.println("파일이름: "+filePart.getSubmittedFileName());
			// System.out.println("파일사이즈: "+filePart.getSize());

			// 이미지 중복이름 방지
			String time = getTime();
			image = time + "_" + image;

			System.out.println("중복이름 방지 : " + image);

			//File.separator 사용하는 이유 : 리눅스와 윈도우의 파일 경로가 틀리기 때문에 이걸쓰면 자동으로 잡아준다.
			System.out.println(" LOG :: [ 업로드 파일 경로 ] :: " + uploadFilePath + File.separator + image);
			filePart.write(uploadFilePath + File.separator + image);

			// ------------------파일업로드 끝
			
			// ======DB시작

			// db조회 : 에러확인 - lending collection에 document 있는지 확인
			BasicDBObject query = new BasicDBObject();
			DBCursor cursor = coll.find(query);

			try {

				// 있다면 해당 _id 값 확인 // 없다면 catch부분으로 넘어감
				DBObject doc = cursor.next();

				// System.out.println((doc.get("_id").toString()).getClass().getName());
				// //변수 타입 확인
				String docID = doc.get("_id").toString(); // _id 조회
				System.out.println("_id 조회 : " + docID);

				System.out.println("데이터 추가(update+$push)");

				query.put("_id", new ObjectId(docID));

				DBObject lending2 = new BasicDBObject();
				lending2.put("category", category);
				lending2.put("lending_name", lending_name);
				lending2.put("organizer_name", organizer_name);
				lending2.put("short_url", short_url);
				lending2.put("image", image);

				DBObject rdata = new BasicDBObject("lending", lending2);
				DBObject se = new BasicDBObject("$push", rdata);
				coll.update(query, se);

			} catch (NoSuchElementException e) {

				// lending값에 아무것도 없을때 (java.util.NoSuchElementException)
				// 새로운 document 생성
				System.out.println("document 새로 생성");

				DBObject lending1 = new BasicDBObject();
				lending1.put("category", category);
				lending1.put("lending_name", lending_name);
				lending1.put("organizer_name", organizer_name);
				lending1.put("short_url", short_url);
				lending1.put("image", image);

				DBObject doc = new BasicDBObject();
				doc.put("lending", Arrays.asList(lending1));
				coll.insert(doc);
			}

			// ======DB끝
			/*----------------------------------------------*/

			JsonObject res = new JsonObject();
			res.addProperty("result", "OK");
			out.println(res.getAsJsonObject());


			// 삭제
		} else if (request.getRequestURI().endsWith("delete.len")) {
			// post타입으로 넘겨 받은 정보
			String data = getBody(request);
			JsonParser parser = new JsonParser();
			JsonElement xjson = parser.parse(data);
			JsonObject reg = xjson.getAsJsonObject();

			// String 타입으로 바꾸기
			String index = reg.get("index").getAsString();
			String doc_id = reg.get("doc_id").getAsString();
			String image = reg.get("image").getAsString();

			// ------------------폴더안에 있는 파일 삭제

			String applicationPath = request.getServletContext().getRealPath("");
			String uploadFilePath = applicationPath + UPLOAD_DIR;
			
			File file = new File(uploadFilePath + File.separator + image);

			//System.out.println("파일삭제 경로맞나????? "+file);
			file.delete();
			
			// ------------------폴더안에 있는 파일 삭제 완료
			
			// ======DB시작

			BasicDBObject query = new BasicDBObject();
			query.put("_id", new ObjectId(doc_id));
	
			// 1 해당 index를 null값으로 만들기
			BasicDBObject rdata1 = new BasicDBObject();
			rdata1.put("lending." + index, 1);
			DBObject se1 = new BasicDBObject("$unset", rdata1);
			coll.update(query, se1);
	
			// 2 null인 부분을 삭제하기
			BasicDBObject rdata2 = new BasicDBObject();
			rdata2.put("lending", null);
			DBObject se2 = new BasicDBObject("$pull", rdata2);
			coll.update(query, se2);
	
			// ======DB끝
			/*----------------------------------------------*/
	
			System.out.println("삭제완료");
	
			JsonObject res = new JsonObject();
			res.addProperty("result", "OK");
			out.println(res.getAsJsonObject());

	} else if (request.getRequestURI().endsWith("update.len")) {
		
		System.out.println("Update");
		
	}// test.len끝

	}// doGet끝

	// 중복이름 방지
	private static String getTime() {
		long time = System.currentTimeMillis();
		SimpleDateFormat dayTime = new SimpleDateFormat("yyMMddHHmmssSSS");
		String strTime = dayTime.format(new Date(time));
		return strTime;
	}

	// 이미지 파일 이름
	private static String getFilename(Part part) {

		for (String cd : part.getHeader("content-disposition").split(";")) {

			if (cd.trim().startsWith("filename")) {

				String filename = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");

				return filename.substring(filename.lastIndexOf('/') + 1).substring(filename.lastIndexOf('\\') + 1); // MSIE
																													// fix.

			}

		}

		return null;

	}
	// -----------------------------------------------------------------------------------

	private DBObject JsonConvertDBObject(JsonObject doc) {
		Object o = JSON.parse(doc.toString());
		DBObject oo = (DBObject) o;
		return oo;
	}

	private JsonObject DBObjectConvertJsonObject(DBObject doc) {
		JsonParser jp = new JsonParser();
		JsonElement je = jp.parse(doc.toString());

		return je.getAsJsonObject();
	}

	public static String getBody(HttpServletRequest request) throws IOException {

		String body = null;
		StringBuilder stringBuilder = new StringBuilder();
		BufferedReader bufferedReader = null;

		try {
			InputStream inputStream = request.getInputStream();
			if (inputStream != null) {
				bufferedReader = new BufferedReader(new InputStreamReader(inputStream, "UTF-8"));
				char[] charBuffer = new char[128];
				int bytesRead = -1;
				while ((bytesRead = bufferedReader.read(charBuffer)) > 0) {

					stringBuilder.append(charBuffer, 0, bytesRead);

				}
			}
		} catch (IOException ex) {
			throw ex;
		} finally {
			if (bufferedReader != null) {
				try {
					bufferedReader.close();
				} catch (IOException ex) {
					throw ex;
				}
			}
		}

		body = stringBuilder.toString();
		body = cleanXSS(body);
		return body;
	}

	private static String cleanXSS(String value) {

		// You'll need to remove the spaces from the html entities below

		value = value.replaceAll("<", "&lt;").replaceAll(">", "&gt;");

		value = value.replaceAll("\\(", "&#40;").replaceAll("\\)", "&#41;");

		value = value.replaceAll("'", "&#39;");

		value = value.replaceAll("eval\\((.*)\\)", "");

		value = value.replaceAll("[\\\"\\\'][\\s]*javascript:(.*)[\\\"\\\']", "\"\"");

		value = value.replaceAll("script", "");

		return value;

	}

}
