CREATE DATABASE QL_THUVIEN;

USE QL_THUVIEN;

CREATE TABLE SACH (
    MASH VARCHAR(10) PRIMARY KEY,           
    TENSACH NVARCHAR(100),                  
    TACGIA NVARCHAR(100),                   
    NHAXB NVARCHAR(100),                    
    NAMXB INT);

CREATE TABLE DOCGIA (
    MADG VARCHAR(10) PRIMARY KEY,           
    HOTEN NVARCHAR(100),                   
    NGAYSINH DATE,                         
    DIACHI NVARCHAR(200),                
    NGHENGHIEP NVARCHAR(100));

CREATE TABLE PHIEUMUON (
    SOPM VARCHAR(10) PRIMARY KEY,        
    NGAYMUON DATE,                       
    NGAYTRA DATE,                     
    MADG VARCHAR(10),                     
	FOREIGN KEY (MADG) REFERENCES DOCGIA(MADG));

CREATE TABLE CHITIETMUON (
    SOPM VARCHAR(10),                       
    MASH VARCHAR(10),              
    NGAYTRA DATE,                    
	PRIMARY KEY (SOPM, MASH),             
    FOREIGN KEY (SOPM) REFERENCES PHIEUMUON(SOPM),
    FOREIGN KEY (MASH) REFERENCES SACH(MASH));

INSERT INTO SACH (MASH, TENSACH, TACGIA, NHAXB, NAMXB) VALUES
('S001', N'Lập trình C cơ bản', N'Nguyễn Văn A', N'NXB Giáo Dục', 2020),
('S002', N'Cấu trúc dữ liệu & Giải thuật', N'Trần Thị B', N'NXB Khoa Học', 2019),
('S003', N'Thiết kế Web với HTML/CSS', N'Lê Văn C', N'NXB Trẻ', 2021),
('S004', N'Cơ sở dữ liệu', N'Phạm Minh D', N'NXB Đại Học Quốc Gia', 2018),
('S005', N'Python cho người mới bắt đầu', N'Hồ Thị E', N'NXB Lao Động', 2022);

INSERT INTO DOCGIA (MADG, HOTEN, NGAYSINH, DIACHI, NGHENGHIEP) VALUES
('DG01', N'Nguyễn Thị Hoa', '2002-05-10', N'123 Lê Lợi, Q.1', N'Sinh viên'),
('DG02', N'Lê Văn Nam', '1998-09-15', N'45 Nguyễn Trãi, Q.5', N'Giáo viên'),
('DG03', N'Trần Quốc Bảo', '2000-12-01', N'67 Hai Bà Trưng, Q.3', N'Kỹ sư'),
('DG04', N'Phạm Minh Anh', '2001-07-20', N'12 Trần Hưng Đạo, Q.1', N'Sinh viên'),
('DG05', N'Hoàng Thị Hạnh', '1995-03-08', N'56 Pasteur, Q.1', N'Nhân viên văn phòng');

INSERT INTO PHIEUMUON (SOPM, NGAYMUON, NGAYTRA, MADG) VALUES
('PM01', '2024-05-01', '2024-05-10', 'DG01'),
('PM02', '2024-05-02', '2024-05-12', 'DG02'),
('PM03', '2024-05-03', '2024-05-15', 'DG03'),
('PM04', '2024-05-04', '2024-05-14', 'DG04'),
('PM05', '2024-05-05', '2024-05-20', 'DG05');

INSERT INTO CHITIETMUON (SOPM, MASH, NGAYTRA) VALUES
('PM01', 'S001', '2024-05-09'),
('PM01', 'S002', '2024-05-10'),
('PM02', 'S003', '2024-05-11'),
('PM03', 'S004', '2024-05-14'),
('PM03', 'S005', '2024-05-13');

--- Truy vấn kết nối nhiều bảng (JOIN):
--•	Câu 1: Liệt kê tên sách, tên độc giả và ngày mượn của tất cả các lượt mượn:
SELECT S.TENSACH, D.HOTEN, P.NGAYMUON
FROM CHITIETMUON C
JOIN PHIEUMUON P ON C.SOPM = P.SOPM
JOIN SACH S ON C.MASH = S.MASH
JOIN DOCGIA D ON P.MADG = D.MADG;
--•	Câu 2: Cho biết danh sách độc giả đã mượn sách thuộc Nhà xuất bản "Giáo Dục": 
SELECT DISTINCT D.MADG, D.HOTEN
FROM PHIEUMUON P
JOIN CHITIETMUON C ON P.SOPM = C.SOPM
JOIN SACH S ON C.MASH = S.MASH
JOIN DOCGIA D ON P.MADG = D.MADG
WHERE S.NHAXB = N'Giáo Dục';

--- Truy vấn UPDATE:
--•	Câu 1: Cập nhật địa chỉ độc giả thành “Bình Dương” nếu họ đã từng mượn bất kỳ cuốn sách nào:
UPDATE DOCGIA
SET DIACHI = N'Bình Dương'
WHERE MADG IN (
    SELECT PM.MADG
    FROM PHIEUMUON PM
    JOIN CHITIETMUON CT ON PM.SOPM = CT.SOPM ) 
--•	Câu 2: Cập nhật nghề nghiệp độc giả thành “Cựu sinh viên” nếu mượn sách vào hoặc trước năm 2024:
UPDATE DOCGIA
SET NGHENGHIEP = N'Cựu sinh viên'
WHERE MADG IN (
    SELECT MADG
    FROM PHIEUMUON
    WHERE YEAR(NGAYMUON) <= 2024) 

--- Truy vấn DELETE:
--•	Câu 1: Xóa tất cả chi tiết mượn của những cuốn sách có năm xuất bản trước năm 2021:
DELETE FROM CHITIETMUON 
WHERE MASH IN ( 
SELECT MASH FROM SACH WHERE NAMXB < 2021);
--•	Câu 2: Xoá những độc giả chưa từng mượn sách nào và có nghề nghiệp là 'Nhân viên văn phòng':
DELETE FROM DOCGIA 
WHERE NGHENGHIEP = N'Nhân viên văn phòng' AND MADG NOT IN 
( SELECT MADG FROM PHIEUMUON );

--- Truy vấn GROUP BY:
--•	Câu 1: Đếm số lượng sách theo từng nhà xuất bản, chỉ lấy sách xuất bản từ năm 2020 trở đi:
SELECT NHAXB, COUNT(*) AS SoLuongSach 
FROM SACH 
WHERE NamXB >= 2020 
GROUP BY NHAXB;
--•	Câu 2: Đếm số lượt mượn của từng độc giả, chỉ thống kê trong năm 2024, sắp xếp theo tên độc giả:
SELECT D.MADG, D.HOTEN, COUNT(*) AS SoLuotMuon 
FROM PHIEUMUON P 
JOIN DOCGIA D ON P.MADG = D.MADG 
WHERE YEAR(P.NGAYMUON) = 2024 
GROUP BY D.MADG, D.HOTEN

--- Truy vấn con (SUBQUERY):
--•	Câu 1: Tìm tên độc giả đã mượn sách có năm xuất bản mới nhất:
SELECT DISTINCT HOTEN
FROM DOCGIA
WHERE MADG IN (
    SELECT MADG
    FROM PHIEUMUON P
    JOIN CHITIETMUON C ON P.SOPM = C.SOPM
    JOIN SACH S ON C.MASH = S.MASH
    WHERE S.NAMXB = (SELECT MAX(NAMXB) FROM SACH)
);
--•	Câu 2: Tìm tên sách đã được mượn nhiều hơn 1 lần:
SELECT TENSACH
FROM SACH
WHERE MASH IN (
    SELECT MASH
    FROM CHITIETMUON
    GROUP BY MASH
    HAVING COUNT(*) > 1
);

--- 2 câu truy vấn khác:
--•	Câu 1: Tìm họ tên độc giả đã từng mượn tất cả sách do NXB "Giáo Dục" xuất bản:
SELECT D.HOTEN
FROM DOCGIA D
WHERE NOT EXISTS (
SELECT MASH
FROM SACH
WHERE NHAXB = 'Giáo Dục'
EXCEPT
SELECT CT.MASH
FROM PHIEUMUON PM
JOIN CHITIETMUON CT ON PM.SOPM = CT.SOPM
WHERE PM.MADG = D.MADG)
--•	Câu 2: Liệt kê các độc giả đã mượn hơn 2 quyển sách khác nhau trong cùng một ngày, kèm theo thông tin: họ tên, ngày mượn và số lượng sách mượn:
SELECT 
    DG.HOTEN,
    PM.NGAYMUON,
    COUNT(DISTINCT CT.MASH) AS SoLuongSachMuon
FROM 
    DOCGIA DG
JOIN PHIEUMUON PM ON DG.MADG = PM.MADG
JOIN CHITIETMUON CT ON PM.SOPM = CT.SOPM
GROUP BY 
    DG.HOTEN, PM.NGAYMUON
HAVING 
    COUNT(DISTINCT CT.MASH) > 2;
