# 💪 SmartGym - Hệ Thống Quản Lý Sức Khỏe & Tập Luyện Thông Minh

---

## 📌 Giới Thiệu Dự Án

**SmartGym** là một hệ thống quản lý sức khỏe cá nhân toàn diện, giúp người dùng theo dõi, phân tích và cải thiện thể chất thông qua dữ liệu và công nghệ hiện đại.

Hệ thống kết hợp:
- 📊 Data tracking (BMI, dinh dưỡng, giấc ngủ)
- 🤖 AI (tư vấn thông minh)
- ⛓️ Blockchain (minh bạch giao dịch)

→ Tạo ra trải nghiệm **cá nhân hóa – thông minh – đáng tin cậy**

---

## 🎯 Mục Tiêu Hệ Thống

- Xây dựng hệ thống quản lý sức khỏe toàn diện  
- Ứng dụng AI để đưa ra gợi ý thông minh  
- Tích hợp Blockchain để đảm bảo minh bạch  
- Thiết kế hệ thống có khả năng mở rộng cao  
- Mô phỏng hệ thống thực tế (real-world system)  

---

## 🏗️ Kiến Trúc Hệ Thống

Hệ thống được thiết kế theo mô hình **3-tier architecture**:

- 🎨 Presentation Layer (Frontend - Flutter)
- ⚙️ Application Layer (Backend - ASP.NET Core API)
- 🗄️ Data Layer (SQL Server + Blockchain)

---

## 👥 Vai Trò Người Dùng

| Vai trò | Mô tả |
|--------|------|
| 👤 User | Theo dõi sức khỏe, tập luyện |
| 👑 Admin | Quản lý hệ thống |
| 🤖 AI System | Gợi ý & tư vấn |

---

## 🧠 Phân Tích Nghiệp Vụ (Business Analyst)

### 🔹 1. Phân tích hệ thống
- Xác định actor & use case  
- Xây dựng Use Case Diagram, Activity Diagram, ERD  
- Phân tích yêu cầu chức năng & phi chức năng  

---

### 🔹 2. Thiết kế luồng nghiệp vụ

#### 📌 Luồng xác thực
- Đăng ký → xác thực → đăng nhập  
- Quên mật khẩu  

#### 📌 Luồng theo dõi sức khỏe
- Nhập dữ liệu → xử lý → hiển thị dashboard  

#### 📌 Luồng AI Chat
- User input → gửi API → AI xử lý → trả kết quả  

#### 📌 Luồng thanh toán
- Chọn sản phẩm → tạo đơn → QR Payment → xác nhận  

---

### 🔹 3. Thiết kế dữ liệu
- User, HealthData, Exercise, Nutrition  
- Order, Transaction, Wallet (GymCoin)  

---

## 🎨 Phát Triển Giao Diện (Frontend)

### 🔹 UI/UX Design
- Responsive đa nền tảng  
- Thiết kế trực quan, dễ sử dụng  
- Dashboard biểu đồ realtime  

---

### 🔹 Các module chính

- 🏠 Dashboard  
- 🏋️ Exercise Tracking  
- 🍎 Nutrition Tracking  
- 💧 Water Tracking  
- 😴 Sleep Tracking  
- 🛒 E-commerce  
- 🤖 AI Chat  

---

### 🔹 Tối ưu trải nghiệm
- Lazy loading  
- Animation mượt  
- Async API  

---

## ⚙️ Chức Năng Hệ Thống

### 👤 User Features
- Quản lý hồ sơ  
- Theo dõi sức khỏe  
- Gợi ý tập luyện  
- Chat AI  

---

### 🛒 E-commerce
- Xem sản phẩm  
- Giỏ hàng  
- Thanh toán QR  

---

### 💰 Ví GymCoin
- Nạp tiền  
- Theo dõi giao dịch  
- Thanh toán nội bộ  

---

### 👑 Admin
- Quản lý user  
- Quản lý dữ liệu  
- Dashboard  

---

## ⛓️ Blockchain Integration

### 🔹 Mục đích
- Đảm bảo tính **minh bạch & không thể chỉnh sửa dữ liệu**

---

### 🔹 Ứng dụng
- Lưu lịch sử giao dịch GymCoin  
- Xác minh thanh toán  
- Chống gian lận  

---

### 🔹 Smart Contract
- Xử lý giao dịch  
- Tự động hóa thanh toán  
- Bảo toàn dữ liệu  

---

## 🤖 AI Integration

- Sử dụng **Google Gemini API**
- Hỗ trợ:
  - Gợi ý bài tập  
  - Tư vấn dinh dưỡng  
  - Hỏi đáp sức khỏe  

---

## 🛠️ Tech Stack

### 🔹 Frontend
- Flutter (Dart)  
- Provider / Bloc  
- fl_chart  

---

### 🔹 Backend
- ASP.NET Core Web API  
- Entity Framework Core  
- JWT Authentication  

---

### 🔹 Database
- SQL Server  

---

### 🔹 Other Technologies
- ⛓️ Blockchain (Smart Contract)  
- 🤖 Gemini AI  
- 💳 VietQR  
- 📊 Chart  

---

## 📊 Điểm Nổi Bật

- 🚀 Full-stack hoàn chỉnh  
- 🤖 AI + ⛓️ Blockchain  
- 📈 Dashboard trực quan  
- 💳 Thanh toán thực tế  
- 🧠 Thiết kế theo system design  

---

## 📈 Hướng Phát Triển

- Wearable integration  
- AI recommendation nâng cao  
- Mobile app production  
- Social fitness  

---

## 🧪 Testing & Quality

- Unit testing (Backend)  
- API testing (Postman)  
- UI testing  
