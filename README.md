#  SmartGym - Hệ Thống Quản Lý Sức Khỏe & Tập Luyện

---

## 📌 1. Tổng Quan Dự Án

SmartGym là một hệ thống full-stack hỗ trợ người dùng quản lý sức khỏe và hoạt động tập luyện một cách hiệu quả.  
Ứng dụng cho phép theo dõi các chỉ số cơ thể, phân tích dữ liệu và đưa ra các gợi ý cá nhân hóa.

Hệ thống tích hợp các công nghệ hiện đại như Trí tuệ nhân tạo (AI) và Blockchain nhằm nâng cao tính thông minh, minh bạch và độ tin cậy.

---

## 🎯 2. Mục Tiêu Dự Án

- Xây dựng hệ thống quản lý sức khỏe toàn diện  
- Theo dõi các chỉ số như BMI, dinh dưỡng, giấc ngủ, nước uống  
- Đề xuất bài tập và chế độ ăn phù hợp  
- Tích hợp AI để tư vấn thông minh  
- Đảm bảo hệ thống có khả năng mở rộng và dễ bảo trì  

---

## 👥 3. Đối Tượng Sử Dụng

- Người mới bắt đầu tập luyện  
- Người muốn cải thiện sức khỏe tại nhà  
- Người cần theo dõi chỉ số cơ thể hằng ngày  

---

## 💼 4. Phân Tích Nghiệp Vụ

### 4.1 Phân tích hệ thống
- Xác định actor và use case  
- Thiết kế Use Case Diagram, Activity Diagram, ERD  
- Phân tích yêu cầu chức năng và phi chức năng  

---

### 4.2 Luồng nghiệp vụ

#### Luồng xác thực
- Đăng ký → xác thực → đăng nhập  
- Quên mật khẩu  

#### Luồng theo dõi sức khỏe
- Nhập dữ liệu → xử lý → hiển thị dashboard  

#### Luồng AI Chat
- Người dùng nhập → gọi API → AI xử lý → trả kết quả  

#### Luồng thanh toán
- Chọn sản phẩm → tạo đơn → thanh toán QR → xác nhận  

---

### 4.3 Thiết kế dữ liệu
- User  
- HealthData  
- Exercise  
- Nutrition  
- Order  
- Transaction  
- Wallet (GymCoin)  

---

## 🎨 5. Phát Triển Giao Diện

### 5.1 Thiết kế UI/UX
- Responsive trên Mobile và Web  
- Giao diện trực quan, dễ sử dụng  
- Dashboard hiển thị dữ liệu bằng biểu đồ  

---

### 5.2 Các module chính
- Dashboard  
- Theo dõi tập luyện  
- Theo dõi dinh dưỡng  
- Theo dõi nước uống  
- Theo dõi giấc ngủ  
- E-commerce  
- AI Chat  

---

### 5.3 Tối ưu hiệu năng
- Lazy loading  
- Gọi API bất đồng bộ  
- Tối ưu trải nghiệm người dùng  

---

## ⚙️ 6. Chức Năng Hệ Thống

### 6.1 Người dùng
- Quản lý tài khoản  
- Theo dõi sức khỏe  
- Nhận gợi ý tập luyện  
- Chat với AI  

---

### 6.2 E-commerce
- Xem sản phẩm  
- Giỏ hàng  
- Thanh toán QR  

---

### 6.3 Ví GymCoin
- Nạp tiền  
- Theo dõi giao dịch  
- Thanh toán nội bộ  

---

### 6.4 Quản trị viên
- Quản lý người dùng  
- Quản lý dữ liệu  
- Dashboard thống kê  

---

## ⛓️ 7. Tích Hợp Blockchain

### 7.1 Mục đích
- Đảm bảo dữ liệu minh bạch và không thể chỉnh sửa  

---

### 7.2 Ứng dụng
- Lưu lịch sử giao dịch GymCoin  
- Xác minh thanh toán  
- Ngăn chặn gian lận  

---

### 7.3 Smart Contract
- Xử lý giao dịch  
- Tự động hóa thanh toán  
- Đảm bảo toàn vẹn dữ liệu  

---

## 🤖 8. Tích Hợp Trí Tuệ Nhân Tạo (AI)

- Sử dụng Google Gemini API  
- Hỗ trợ:
  - Gợi ý bài tập  
  - Tư vấn dinh dưỡng  
  - Hỏi đáp sức khỏe  

---

## 🛠️ 9. Công Nghệ Sử Dụng

### Frontend
- Flutter (Dart)  
- Provider / Bloc  
- fl_chart  

---

### Backend
- ASP.NET Core Web API  
- Entity Framework Core  
- JWT Authentication  

---

### Database
- SQL Server  

---

### Công nghệ khác
- Blockchain (Smart Contract)  
- Google Gemini AI  
- VietQR Payment  
- Chart Visualization  

---

## 📊 10. Điểm Nổi Bật

- Hệ thống full-stack hoàn chỉnh  
- Tích hợp AI và Blockchain  
- Dashboard trực quan  
- Thanh toán QR thực tế  
- Thiết kế theo tư duy hệ thống  

---

## 📈 11. Hướng Phát Triển

- Tích hợp thiết bị đeo (smartwatch)  
- Nâng cấp AI recommendation  
- Hoàn thiện mobile app  
- Xây dựng social fitness  

---

## 🧪 12. Kiểm Thử

- Unit testing (Backend)  
- API testing (Postman)  
- UI testing  

---

## 📫 13. Liên Hệ

- GitHub: https://github.com/ThanhTin2209
