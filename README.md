# 🐝 BeeLingual – Ứng dụng học tiếng Anh

<div align="center">
  <img width="200" height="200" alt="logoBee" src="https://github.com/user-attachments/assets/42f8892e-4de9-4f69-b583-1dfd7acea47f"/>
</div>

---

## 🌟 Giới thiệu chung

**BeeLingual** là ứng dụng học tiếng Anh giúp người dùng nâng cao **vốn từ vựng** và **kỹ năng nghe** thông qua các bài học theo **chủ đề** và **cấp độ**, từ cơ bản đến nâng cao.  

Ứng dụng tích hợp phát âm chuẩn từ các từ điển uy tín như **Laban** và **Cambridge**, đi kèm **ví dụ minh họa** và **bài tập thực hành** giúp ghi nhớ hiệu quả.  

Người dùng có thể theo dõi **tiến độ học**, ôn tập kiến thức đã học và rèn luyện thường xuyên qua các bài kiểm tra ngắn. Giao diện được thiết kế **đơn giản, thân thiện**, tối ưu cho cả người mới bắt đầu.

---

## 🎯 Mục tiêu

- Xây dựng **Mobile App** thân thiện với người dùng.  
- Cung cấp **Website Admin** để quản lý dữ liệu: [Website Admin](https://beelingual-admin.onrender.com/)  
- Tạo **Landing Page** giới thiệu về ứng dụng: [Landing Page](https://beelingual.onrender.com/)

---

## 📚 Tính năng chính

### 1️⃣ Vocabulary
- Học từ vựng theo **chủ đề (Topic)** và **cấp độ (A1–C2)**  
- Từ vựng đã học được lưu trong **Dictionary** để theo dõi tiến độ và ôn tập  

### 2️⃣ Grammar
- Bài học ngữ pháp **cấu trúc rõ ràng**  
- Kèm **bài tập thực hành** để củng cố kiến thức và vận dụng  

### 3️⃣ Exercises
- Bài tập luyện tập theo chủ đề với nhiều dạng:  
  - Reading  
  - Fill in the blank  
  - Multiple Choice  
  - Listening  

### 4️⃣ Listening
- Bài luyện nghe đa cấp độ  
- **Điều chỉnh tốc độ** và **độ khó** phù hợp với trình độ người học  

### 5️⃣ PVP
- Thi đấu trực tiếp với người dùng khác theo **cấp độ** và **số lượng câu hỏi**  
- Môi trường học vừa **học vừa chơi**, phù hợp giới trẻ  

### 6️⃣ Translate
- Hỗ trợ **dịch hai chiều tiếng Anh – tiếng Việt**  
- Mở rộng sang nhiều ngôn ngữ khác như Nhật, Trung  

---

## 💻 Công nghệ sử dụng

| Hạng mục          | Công nghệ / Công cụ                       |
|------------------|------------------------------------------|
| **Ngôn ngữ**     | Mobile App: Dart<br>Website: HTML, CSS, JavaScript |
| **Framework**    | Server BE: NodeJS<br>Website: ReactJS<br>Mobile App: Flutter |
| **IDE**          | Mobile App: Android Studio SDK<br>Website/Database: Visual Studio Code |
| **Công cụ khác** | CSDL: MongoDB Atlas<br>Deploy: Render<br>Test API: Postman<br>Quản lý mã nguồn: GitHub |

---

## 🗄 Cơ sở dữ liệu

<img width="945" height="711" alt="Database Schema" src="https://github.com/user-attachments/assets/ddc80f19-def4-4b7a-922b-9735d47cb7b3" />

---

## 🗂 Cấu trúc source code
```
lib
├─ component
│  ├─ messDialog.dart
│  ├─ navigation.dart
│  ├─ profileProvider.dart
│  └─ progressProvider.dart
├─ connect_api
│  ├─ api_connect.dart
│  ├─ tts_service.dart
│  └─ url.dart
├─ controller
│  ├─ authController.dart
│  ├─ dictionaryController.dart
│  ├─ exeGrmController.dart
│  ├─ exerciseController.dart
│  ├─ grammarController.dart
│  ├─ progressController.dart
│  ├─ socketController.dart
│  ├─ streakController.dart
│  ├─ topicController.dart
│  ├─ translateController.dart
│  ├─ userController.dart
│  ├─ vocabController.dart
│  └─ vocabTtsController.dart
├─ main.dart
├─ model
│  ├─ dictionary.dart
│  ├─ exercise.dart
│  ├─ exe_grammar.dart
│  ├─ exe_topic.dart
│  ├─ grammar.dart
│  ├─ level.dart
│  ├─ topic.dart
│  ├─ user.dart
│  └─ vocabulary.dart
└─ view
   ├─ account
   │  ├─ account_page.dart
   │  ├─ change_pass_page.dart
   │  ├─ log_in_page.dart
   │  ├─ profile_page.dart
   │  ├─ sign_up_page.dart
   │  └─ term_page.dart
   ├─ exercises
   │  ├─ exercises_list_page.dart
   │  ├─ exercises_summary_page.dart
   │  └─ exercises_topic_page.dart
   ├─ grammar
   │  ├─ grammar_detail_page.dart
   │  ├─ grammar_list_page.dart
   │  ├─ grammar_page.dart
   │  ├─ grammar_summary_page.dart
   │  └─ grammer_exe_page.dart
   ├─ home
   │  ├─ appTheme.dart
   │  └─ home_page.dart
   ├─ Listening
   │  ├─ listening_exe_page.dart
   │  └─ listening_level_page.dart
   ├─ matches
   │  ├─ history_pvp_page.dart
   │  ├─ match_page.dart
   │  ├─ match_result_page.dart
   │  └─ pvp_page.dart
   ├─ translate
   │  ├─ camera_scan_page.dart
   │  └─ translate_page.dart
   ├─ translation
   │  └─ translate_page.dart
   └─ vocabulary
      ├─ dictionary_page.dart
      ├─ vocab_level_page.dart
      ├─ vocab_page.dart
      └─ vocab_topic_page.dart

```

---
## 💻Demo giao diện
### 📱Mobile App

<img width="2000" height="1105" alt="image" src="https://github.com/user-attachments/assets/4858a8fe-f540-4821-badf-e3d9337a6828" />

### 📃Website Admin

<img width="100%" alt="image" src="https://github.com/user-attachments/assets/493bae06-ca42-4a03-971b-6a1b0ab084a2" />

### 📄Landing Page

<img width="1464" height="1009" alt="image" src="https://github.com/user-attachments/assets/014856f0-cec0-441d-a6c0-56559e3a5a06" />
