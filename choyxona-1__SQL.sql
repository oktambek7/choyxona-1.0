--. E-Commerce Sales Analytics
--Loyiha: Online do‘kon savdolarini tahlil qilish.
--Task:
--Mijozlar, mahsulotlar, buyurtmalar va to‘lovlar haqidagi jadval(lar) asosida:
--•	Oxirgi 6 oy ichida eng ko‘p foyda bergan 5 ta mahsulotni toping.
--•	Har bir foydalanuvchi bo‘yicha RFM (Recency, Frequency, Monetary) tahlilini bajaring.
--•	Har bir kategoriyadagi mahsulotlar bo‘yicha o‘rtacha buyurtma miqdorini aniqlang.
--•	Har bir to‘lov turi (karta, naqd, PayPal) bo‘yicha o‘rtacha kechikish vaqtini toping (buyurtma berilgan va to‘langan vaqt orasidagi farq).
--•	SQL orqali mahsulotlar omborda qolmasa, ularni avtomatik inactive holatiga o‘tkazuvchi view yoki trigger yozing.


-- Kategoriyalar jadvali
CREATE TABLE Kategoriyalar (
kategoriya_id INT IDENTITY(1,1) PRIMARY KEY,
kategoriya_nomi NVARCHAR(50) NOT NULL
);

-- Mijozlar jadvali
CREATE TABLE Mijozlar (
mijoz_id INT IDENTITY(1,1) PRIMARY KEY,
ism NVARCHAR(50) NOT NULL,
familiya NVARCHAR(50) NOT NULL,
telefon NVARCHAR(20),
manzil NVARCHAR(MAX),
email NVARCHAR(100) UNIQUE
);

-- Mahsulotlar jadvali
CREATE TABLE Mahsulotlar (
mahsulot_id INT IDENTITY(1,1) PRIMARY KEY,
nom NVARCHAR(100) NOT NULL,
kategoriya_id INT,
narx DECIMAL(10, 2) NOT NULL,
qoldiq INT NOT NULL,
status NVARCHAR(20) DEFAULT 'active', -- active/inactive
CONSTRAINT FK_Mahsulotlar_Kategoriyalar FOREIGN KEY (kategoriya_id) REFERENCES Kategoriyalar(kategoriya_id)
);

-- Buyurtmalar jadvali
CREATE TABLE Buyurtmalar (
buyurtma_id INT IDENTITY(1,1) PRIMARY KEY,
mijoz_id INT,
buyurtma_sanasi DATETIME2 DEFAULT GETDATE(),
umumiy_summa DECIMAL(10, 2) NOT NULL,
CONSTRAINT FK_Buyurtmalar_Mijozlar FOREIGN KEY (mijoz_id) REFERENCES Mijozlar(mijoz_id)
);

-- Buyurtma elementlari jadvali
CREATE TABLE Buyurtma_Elementlari (
element_id INT IDENTITY(1,1) PRIMARY KEY,
buyurtma_id INT,
mahsulot_id INT,
miqdor INT NOT NULL,
jami_narx DECIMAL(10, 2) NOT NULL,
CONSTRAINT FK_BuyurtmaElementlari_Buyurtmalar FOREIGN KEY (buyurtma_id) REFERENCES Buyurtmalar(buyurtma_id),
CONSTRAINT FK_BuyurtmaElementlari_Mahsulotlar FOREIGN KEY (mahsulot_id) REFERENCES Mahsulotlar(mahsulot_id)
);

-- To‘lovlar jadvali
CREATE TABLE Tolovlar (
tolov_id INT IDENTITY(1,1) PRIMARY KEY,
buyurtma_id INT,
tolov_summa DECIMAL(10, 2) NOT NULL,
tolov_sanasi DATETIME2 DEFAULT GETDATE(),
tolov_turi NVARCHAR(50), -- Karta, Naqd, PayPal
CONSTRAINT FK_Tolovlar_Buyurtmalar FOREIGN KEY (buyurtma_id) REFERENCES Buyurtmalar(buyurtma_id)
);


-- Kategoriyalar jadvaliga ma’lumot kiritish
INSERT INTO Kategoriyalar (kategoriya_nomi) VALUES
(N'Elektronika'),
(N'Uy jihozlari'),
(N'Kiyim');

-- Mijozlar jadvaliga ma’lumot kiritish
INSERT INTO Mijozlar (ism, familiya, telefon, manzil, email) VALUES
(N'Ali', N'Valiyev', N'+998901234567', N'Toshkent, Chilanzor', N'ali.valiyev@email.com'),
(N'Sardor', N'Usmonov', N'+998907654321', N'Samarqand, Registon', N'sardor.usmonov@email.com'),
(N'Nodira', N'Karimova', N'+998933214567', N'Farg‘ona, Al-Farg‘oniy', N'nodira.karimova@email.com'),
(N'Zilola', N'Azizova', N'+998912345678', N'Buxoro, Lyabi Hauz', N'zilola.azizova@email.com');

-- Mahsulotlar jadvaliga ma’lumot kiritish
INSERT INTO Mahsulotlar (nom, kategoriya_id, narx, qoldiq, status) VALUES
(N'Telefon', 1, 500.00, 10, N'active'),
(N'Noutbuk', 1, 1200.00, 5, N'active'),
(N'Televizor', 2, 800.00, 7, N'active'),
(N'Futbolka', 3, 20.00, 0, N'active'),
(N'Kostyum', 3, 100.00, 3, N'active');


truncate table buyurtmalar
-- Buyurtmalar jadvaliga ma’lumot kiritish
INSERT INTO Buyurtmalar (mijoz_id, buyurtma_sanasi, umumiy_summa) VALUES
(1, '2025-04-12 10:00:00', 1700.00),
(2, '2025-03-16 12:30:00', 500.00),
(3, '2025-02-03 15:45:00', 2400.00),
(1, '2024-12-19 09:00:00', 520.00),
(4, '2025-01-06 14:20:00', 100.00);


truncate table Buyurtma_Elementlari
-- Buyurtma elementlari jadvaliga ma’lumot kiritish
INSERT INTO Buyurtma_Elementlari (buyurtma_id, mahsulot_id, miqdor, jami_narx) VALUES
(1, 3, 2, 500.00),
(1, 2, 5, 1200.00),
(2, 1, 3, 500.00),
(3, 2, 6, 2400.00),
(4, 1, 2, 500.00),
(4, 3, 4, 20.00),
(5, 5, 5, 100.00);


-- To‘lovlar jadvaliga ma’lumot kiritish
INSERT INTO Tolovlar (buyurtma_id, tolov_summa, tolov_sanasi, tolov_turi) VALUES
(1, 1700.00, '2025-04-14 10:30:00', N'Karta'),
(2, 500.00, '2025-03-19 13:00:00', N'Naqd'),
(3, 2400.00, '2025-02-27 16:15:00', N'PayPal'),
(4, 520.00, '2024-12-17 09:30:00', N'Karta'),
(5, 100.00, '2025-01-10 14:50:00', N'PayPal');




--•	Oxirgi 6 oy ichida eng ko‘p foyda bergan 5 ta mahsulotni toping.

go
alter view Top5_mahsulotlar as
select distinct top 5  
be.mahsulot_id,
b.umumiy_summa,
m.nom
from Buyurtma_Elementlari be
JOIN Buyurtmalar b
ON be.buyurtma_id=b.buyurtma_id
JOIN Mahsulotlar m
on m.mahsulot_id=be.mahsulot_id
where b.buyurtma_sanasi >= DATEADD(MONTH, -6, GETDATE()) 
order by umumiy_summa desc

select distinct * from Top5_mahsulotlar;

--•	Har bir kategoriyadagi mahsulotlar bo‘yicha o‘rtacha buyurtma miqdorini aniqlang.

select distinct
	k.kategoriya_nomi,
	avg(avg_count.average_quantity) as average
from Mahsulotlar m
JOIN(
select mahsulot_id,
	avg(miqdor)over(partition by mahsulot_id) as average_quantity
from Buyurtma_Elementlari) avg_count
ON m.mahsulot_id=avg_count.mahsulot_id
JOIN kategoriyalar k
ON k.kategoriya_id=m.kategoriya_id
group by k.kategoriya_nomi;


--Har bir to‘lov turi (karta, naqd, PayPal) bo‘yicha o‘rtacha kechikish vaqtini toping (buyurtma berilgan va to‘langan vaqt orasidagi

select * from Tolovlar
select * from Buyurtmalar;
select * from Buyurtma_Elementlari
select * from mahsulotlar
select * from Kategoriyalar


; with cte as (
select
	t.tolov_turi,
	abs(day(b.buyurtma_sanasi) - day(t.tolov_sanasi)) as delays_in_days
from Buyurtmalar b
JOIN Tolovlar t
on b.buyurtma_id=t.buyurtma_id
),

avg_calc as (
	select 
	tolov_turi,
	avg(delays_in_days) as average
	from cte
	group by tolov_turi

)
select * from avg_calc;


--•	SQL orqali mahsulotlar omborda qolmasa, ularni avtomatik inactive holatiga o‘tkazuvchi view yoki trigger yozing.

GO
CREATE VIEW is_inactive AS
SELECT 
    mahsulot_id,
    nom,
    CASE 
        WHEN qoldiq = 0 THEN 'inactive'
        ELSE 'active'
    END AS status
FROM Mahsulotlar;
GO


select * from is_inactive

--2. Avtobus Chiptalar Tizimi (Transport CRM)
--Loyiha: Avtobus chiptalari tizimi (sening loyihang asosida).
--Task:
--•	Har bir shahar uchun eng ko‘p sotilgan yo‘nalishlar va umumiy tushumni hisoblang.
--•	Belgilangan sana oralig‘ida avtobuslarning to‘ldirilganlik darajasini aniqlang (100%ga nisbatan).
--•	Har bir kompaniya bo‘yicha o‘rtacha chiptaning narxini, foydani va safar sonini hisoblang.
--•	Mijozlar takroriy sotib olishlarini tahlil qiling (1, 2 va undan ko‘p martalik xaridlar).
--•	SQL orqali chiptalarni avtomatik holatda cancelled ga o‘tkazish uchun har kuni 1 kun oldingi va hali to‘lanmagan chiptalarni belgilovchi procedure yozing.


CREATE TABLE Cities (
    city_id INT IDENTITY(1,1),
    city_name NVARCHAR(50) NOT NULL
);

-- Companies table
CREATE TABLE Companies (
    company_id INT IDENTITY(1,1),
    company_name NVARCHAR(100) NOT NULL,
    contact_email NVARCHAR(100)
);

-- Buses table
CREATE TABLE Buses (
    bus_id INT IDENTITY(1,1),
    company_id INT,
    model NVARCHAR(50) NOT NULL,
    capacity INT NOT NULL
);

-- Routes table
CREATE TABLE Routes (
    route_id INT IDENTITY(1,1),
    start_city_id INT,
    end_city_id INT,
    distance_km INT NOT NULL
);

-- Trips table
CREATE TABLE Trips (
    trip_id INT IDENTITY(1,1),
    route_id INT,
    bus_id INT,
    departure_time DATETIME2 NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Customers table
CREATE TABLE Customers (
    customer_id INT IDENTITY(1,1),
    first_name NVARCHAR(50) NOT NULL,
    last_name NVARCHAR(50) NOT NULL,
    phone NVARCHAR(20),
    email NVARCHAR(100)
);

-- Tickets table
CREATE TABLE Tickets (
    ticket_id INT IDENTITY(1,1),
    customer_id INT,
    trip_id INT,
    purchase_date DATETIME2 DEFAULT GETDATE(),
    price DECIMAL(10, 2) NOT NULL,
    status NVARCHAR(20) DEFAULT 'pending', -- pending, confirmed, cancelled
    payment_date DATETIME2
);

-- Cities: 10 new cities
INSERT INTO Cities (city_name) VALUES
('Namangan'),
('Khiva'),
('Nukus'),
('Termez'),
('Qarshi'),
('Jizzakh'),
('Urgench'),
('Navoi'),
('Gulistan'),
('Kokand');

-- Companies: 10 new companies
INSERT INTO Companies (company_name, contact_email) VALUES
('CityLink', 'citylink@email.com'),
('TravelStar', 'travelstar@email.com'),
('RoadMaster', 'roadmaster@email.com'),
('SwiftBus', 'swiftbus@email.com'),
('EcoRide', 'ecoride@email.com'),
('MetroBus', 'metrobus@email.com'),
('Horizon', 'horizon@email.com'),
('UnityTravel', 'unitytravel@email.com'),
('BlueRoute', 'blueroute@email.com'),
('GoldenWheels', 'goldenwheels@email.com');

-- Buses: 10 new buses (using existing and new company_id)
INSERT INTO Buses (company_id, model, capacity) VALUES
(1, 'Hyundai Aero', 25),
(2, 'Scania Touring', 45),
(3, 'Yutong ZK', 30),
(4, 'Iveco Crossway', 35),
(5, 'King Long', 40),
(6, 'Higer KLQ', 28),
(7, 'Neoplan Cityliner', 50),
(8, 'Temsa Safari', 32),
(9, 'Van Hool', 38),
(10, 'Setra Comfort', 42);



-- Routes: 10 new routes (using existing and new city_id)
INSERT INTO Routes (start_city_id, end_city_id, distance_km) VALUES
(1, 6, 280), -- Tashkent -> Namangan
(3, 8, 450), -- Samarkand -> Khiva
(3, 8, 300), -- Bukhara -> Nukus
(4, 9, 400), -- Fergana -> Termez
(5, 10, 200), -- Andijan -> Qarshi
(1, 6, 150), -- Namangan -> Jizzakh
(5, 10, 250), -- Khiva -> Urgench
(1, 6, 350), -- Nukus -> Navoi
(3, 8, 500), -- Termez -> Tashkent
(5, 10, 320); -- Qarshi -> Samarkand


truncate table trips
-- Trips: 10 new trips (using existing and new route_id, bus_id)
INSERT INTO Trips (route_id, bus_id, departure_time, price) VALUES
(1, 5, '2025-05-01 08:00:00', 55.00), -- Tashkent -> Namangan, Hyundai
(2, 6, '2025-05-02 09:00:00', 80.00), -- Samarkand -> Khiva, Scania
(3, 7, '2025-05-03 10:00:00', 60.00), -- Bukhara -> Nukus, Yutong
(4, 8, '2025-05-04 11:00:00', 70.00), -- Fergana -> Termez, Iveco
(5, 9, '2025-05-05 12:00:00', 40.00), -- Andijan -> Qarshi, King Long
(6, 10, '2025-05-06 13:00:00', 35.00), -- Namangan -> Jizzakh, Higer
(7, 11, '2025-05-07 14:00:00', 50.00), -- Khiva -> Urgench, Neoplan
(8, 12, '2025-05-08 15:00:00', 65.00), -- Nukus -> Navoi, Temsa
(9, 13, '2025-05-09 16:00:00', 85.00), -- Termez -> Tashkent, Van Hool
(10, 14, '2025-05-10 17:00:00', 60.00); -- Qarshi -> Samarkand, Setra

-- Customers: 10 new customers
INSERT INTO Customers (first_name, last_name, phone, email) VALUES
('Kamila', 'Rahimova', '+998901111222', 'kamila.rahimova@email.com'),
('Farrukh', 'Mirzaev', '+998902222333', 'farrukh.mirzaev@email.com'),
('Laziza', 'Yusupova', '+998903333444', 'laziza.yusupova@email.com'),
('Rustam', 'Khalilov', '+998904444555', 'rustam.khalilov@email.com'),
('Dilshod', 'Toshpulatov', '+998905555666', 'dilshod.toshpulatov@email.com'),
('Mavjuda', 'Nematova', '+998906666777', 'mavjuda.nematova@email.com'),
('Shokhrukh', 'Abdullaev', '+998907777888', 'shokhrukh.abdullaev@email.com'),
('Gulnara', 'Ismailova', '+998908888999', 'gulnara.ismailova@email.com'),
('Bekzod', 'Karimov', '+998909999000', 'bekzod.karimov@email.com'),
('Aziza', 'Sattorova', '+998900000111', 'aziza.sattorova@email.com');


-- Tickets: 10 new tickets (using existing and new customer_id, trip_id)
INSERT INTO Tickets (customer_id, trip_id, purchase_date, price, status, payment_date) VALUES
(1, 16, '2025-04-29 10:00:00', 55.00, 'confirmed', '2025-04-29 10:30:00'), -- Kamila, Tashkent -> Namangan
(2, 17, '2025-04-30 11:00:00', 80.00, 'pending', NULL), -- Farrukh, Samarkand -> Khiva
(1, 18, '2025-05-01 12:00:00', 60.00, 'confirmed', '2025-05-01 12:30:00'), -- Laziza, Bukhara -> Nukus
(3, 19, '2025-05-02 13:00:00', 70.00, 'confirmed', '2025-05-02 13:30:00'), -- Rustam, Fergana -> Termez
(2, 20, '2025-05-03 14:00:00', 40.00, 'pending', NULL), -- Dilshod, Andijan -> Qarshi
(3, 21, '2025-05-04 15:00:00', 35.00, 'confirmed', '2025-05-04 15:30:00'), -- Mavjuda, Namangan -> Jizzakh
(1, 22, '2025-05-05 16:00:00', 50.00, 'confirmed', '2025-05-05 16:30:00'), -- Shokhrukh, Khiva -> Urgench
(4, 23, '2025-05-06 17:00:00', 65.00, 'pending', NULL), -- Gulnara, Nukus -> Navoi
(6, 24, '2025-05-07 18:00:00', 85.00, 'confirmed', '2025-05-07 18:30:00'), -- Bekzod, Termez -> Tashkent
(5, 25, '2025-05-08 19:00:00', 60.00, 'pending', NULL); -- Aziza, Qarshi -> Samarkand

select*from Cities
select*from Companies
select*from buses
select*from routes
select*from trips
select*from Customers
select*from tickets

--•	Har bir shahar uchun eng ko‘p sotilgan yo‘nalishlar va umumiy tushumni hisoblang.

SELECT distinct
    c.city_name AS start_city,
    r.route_id,
    COUNT(t.ticket_id) AS total_tickets,
    SUM(t.price) AS total_revenue
FROM Tickets t
JOIN Trips tr ON t.trip_id = tr.trip_id
JOIN Routes r ON tr.route_id = r.route_id
JOIN Cities c ON r.start_city_id = c.city_id
WHERE t.status = 'confirmed'
GROUP BY c.city_name, r.route_id
ORDER BY c.city_name, total_tickets DESC;


--•	Belgilangan sana oralig‘ida avtobuslarning to‘ldirilganlik darajasini aniqlang (100%ga nisbatan).

----capacity between 2025-05-01 and 2025-05-10.

SELECT 
    tr.trip_id,
    b.model,
    b.capacity,
    COUNT(t.ticket_id) AS sold_tickets,
    CAST(COUNT(t.ticket_id) * 100.0 / b.capacity AS DECIMAL(5,2)) AS fill_percentage
FROM Trips tr
JOIN Buses b ON tr.bus_id = b.bus_id
LEFT JOIN Tickets t ON t.trip_id = tr.trip_id AND t.status = 'confirmed'
WHERE tr.departure_time BETWEEN '2025-05-01' AND '2025-05-10'
GROUP BY tr.trip_id, b.model, b.capacity;

--•	Har bir kompaniya bo‘yicha o‘rtacha chiptaning narxini, foydani va safar sonini hisoblang.

SELECT 
    c.company_name,
    COUNT(DISTINCT tr.trip_id) AS trip_count,
    round(AVG(t.price), 2) AS avg_ticket_price,
    SUM(t.price) AS total_profit
FROM Tickets t
JOIN Trips tr ON t.trip_id = tr.trip_id
JOIN Buses b ON tr.bus_id = b.bus_id
JOIN Companies c ON b.company_id = c.company_id
WHERE t.status = 'confirmed'
GROUP BY c.company_name;

--•	Mijozlar takroriy sotib olishlarini tahlil qiling (1, 2 va undan ko‘p martalik xaridlar).

select*from trips
select*from Customers
select*from tickets

select
	case
		when count_purchase = 1 then 'bir martalik'
		when count_purchase = 2 then 'ikki martalim'
		when count_purchase = 3 then 'uch martalik'
		else 'uch martadan kop'
	end as type_of_purchase,
	count(*) customer_count

from
	(select customer_id, count(*) as count_purchase
	from tickets
	where status = 'Confirmed'
	group by customer_id) as T1

group by 
	case
		when count_purchase = 1 then 'bir martalik'
		when count_purchase = 2 then 'ikki martalim'
		when count_purchase = 3 then 'uch martalik'
		else 'uch martadan kop'
	end;

--•	SQL orqali chiptalarni avtomatik holatda cancelled ga o‘tkazish uchun har kuni 1 kun oldingi va hali to‘lanmagan chiptalarni belgilovchi procedure yozing.

go
alter PROCEDURE Cancel_Unpaid_Tickets
AS
BEGIN
    UPDATE Tickets
    SET status = 'cancelled'
    WHERE 
        status = 'pending'
		 AND CAST(purchase_date AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE)
         AND payment_date IS NULL;
END;

execute Cancel_Unpaid_Tickets




--3. Ijtimoiy Tarmoq Analitikasi
--Loyiha: Foydalanuvchilar, postlar, like va followerlar bilan ishlovchi tizim.
--Task:
--•	Har bir foydalanuvchining engagement rate'ini hisoblang (like + comment / followers).
--•	"Influencer" statusiga mos keluvchi foydalanuvchilarni aniqlang (followers > 10k, engagement > 5%).
--•	Foydalanuvchilar orasida eng ko‘p post qilganlar va eng ko‘p layk olganlar topilsin.
--•	Har bir hafta bo‘yicha yangi foydalanuvchilar soni, faol postlar va layklar trendini chiqaruvchi view yarating.
--•	SQL bilan: Followerlar ro‘yxatida "ghost followers"ni aniqlash (ya'ni faollik ko‘rsatmayotganlar: post ko‘rmagan, like bosmagan).

drop table users
-- Users table
CREATE TABLE Users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL,
    join_date DATE NOT NULL
);

drop table posts
-- Posts table
CREATE TABLE Posts (
    post_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT FOREIGN KEY REFERENCES Users(user_id),
    content NVARCHAR(500),
    post_date DATETIME2 NOT NULL
);
drop table likes
-- Likes table
CREATE TABLE Likes (
    like_id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT FOREIGN KEY REFERENCES Posts(post_id),
    user_id INT FOREIGN KEY REFERENCES Users(user_id),
    like_date DATETIME2 NOT NULL
);

drop table comments
-- Comments table
CREATE TABLE Comments (
    comment_id INT IDENTITY(1,1) PRIMARY KEY,
    post_id INT FOREIGN KEY REFERENCES Posts(post_id),
    user_id INT FOREIGN KEY REFERENCES Users(user_id),
    comment_text NVARCHAR(255),
    comment_date DATETIME2 NOT NULL
);


-- Followers table
CREATE TABLE Followers (
	user_id int,
    follower_id INT IDENTITY(1,1) PRIMARY KEY,
    followed_user_id INT FOREIGN KEY REFERENCES Users(user_id),
    follower_user_id INT FOREIGN KEY REFERENCES Users(user_id),
    follow_date DATE NOT NULL
);

INSERT INTO Users (username, join_date) VALUES
('john_doe', '2025-01-01'),
('jane_smith', '2025-01-03'),
('alex_kim', '2025-01-05'),
('maria_lee', '2025-01-10'),
('tim_ross', '2025-01-15'),
('sara_white', '2025-02-01'),
('daniel_ray', '2025-02-10'),
('lucy_brown', '2025-03-01'),
('mike_green', '2025-03-15'),
('nina_choi', '2025-04-01');


-- Posts
INSERT INTO Posts (user_id, content, post_date) VALUES
(1, 'Hello world!', '2025-01-01 09:00'),
(2, 'My first post', '2025-01-03 10:00'),
(2, 'Another day, another post', '2025-01-04 11:00'),
(3, 'Coffee time!', '2025-01-05 14:00'),
(4, 'Sunset vibes', '2025-01-10 18:00'),
(4, 'Throwback pic', '2025-01-11 19:00'),
(5, 'Monday mood', '2025-01-15 08:00'),
(6, 'Winter in the city', '2025-02-02 12:00'),
(7, 'Reading a new book', '2025-02-10 16:00'),
(1, 'Travel blog update!', '2025-03-01 09:00');

-- Likes
INSERT INTO Likes (post_id, user_id, like_date) VALUES
(1, 2, '2025-01-01 10:00'),
(1, 3, '2025-01-01 10:30'),
(2, 1, '2025-01-03 12:00'),
(3, 4, '2025-01-04 12:00'),
(4, 2, '2025-01-05 14:30'),
(5, 5, '2025-01-10 19:00'),
(5, 1, '2025-01-10 20:00'),
(6, 3, '2025-01-11 20:00'),
(7, 4, '2025-01-15 09:00'),
(10, 2, '2025-03-01 10:00');

-- Comments
INSERT INTO Comments (post_id, user_id, comment_text, comment_date) VALUES
(1, 2, 'Nice post!', '2025-01-01 11:00'),
(2, 1, 'Thanks!', '2025-01-03 12:30'),
(3, 4, 'Love this!', '2025-01-04 12:30'),
(5, 1, 'Beautiful!', '2025-01-10 20:30'),
(6, 2, 'Wow!', '2025-01-11 21:00');

truncate table followers
-- Followers
INSERT INTO Followers (user_id, followed_user_id, follower_user_id, follow_date) VALUES
(1, 1, 2, '2025-01-02'),
(2, 2, 3, '2025-01-03'),
(3, 3, 4, '2025-01-05'),
(4, 3, 1, '2025-01-03'),
(5, 4, 5, '2025-01-06'),
(6, 5, 6, '2025-01-07');

create table number_of_followers
(   
	user_id int,
	num_of_folllowers int
);
insert into number_of_followers
values
	(1, 2000),
	(2, 12000),
	(3, 5000),
	(4, 10200),
	(5, 15000),
	(6, 4000),
	(7, 18000),
	(8, 13000);


--•	Har bir foydalanuvchining engagement rate'ini hisoblang (like + comment / followers).

--(like+comment) / followers


SELECT 
    u.user_id,
    u.username,
    ISNULL(f.total_followers, 0) AS followers,
    CASE 
        WHEN ISNULL(f.total_followers, 0) = 0 THEN 0
        ELSE ROUND(1.0 * (ISNULL(l.total_likes, 0) + ISNULL(c.total_comments, 0)) / f.total_followers, 4)
    END AS engagement_rate
FROM Users u
LEFT JOIN (
    SELECT p.user_id, COUNT(*) AS total_likes
    FROM Posts p JOIN Likes l ON p.post_id = l.post_id
    GROUP BY p.user_id
) l ON u.user_id = l.user_id
LEFT JOIN (
    SELECT p.user_id, COUNT(*) AS total_comments
    FROM Posts p JOIN Comments c ON p.post_id = c.post_id
    GROUP BY p.user_id
) c ON u.user_id = c.user_id
LEFT JOIN (
    SELECT followed_user_id, COUNT(*) AS total_followers
    FROM Followers
    GROUP BY followed_user_id
) f ON u.user_id = f.followed_user_id;


--"Influencer" statusiga mos keluvchi foydalanuvchilarni aniqlang (followers > 10k, engagement > 5%).


SELECT 
    u.user_id,
    u.username,
    ISNULL(f.total_followers, 0) AS followers,
    CASE 
        WHEN ISNULL(f.total_followers, 0) = 0 THEN 0
        ELSE ROUND(1.0 * (ISNULL(l.total_likes, 0) + ISNULL(c.total_comments, 0)) / f.total_followers, 4)
    END AS engagement_rate,
	case 
		when nof.num_of_folllowers>10000 then 'Influencer' else 'NO'
	end as is_influencer
FROM Users u
LEFT JOIN (
    SELECT p.user_id, COUNT(*) AS total_likes
    FROM Posts p JOIN Likes l ON p.post_id = l.post_id
    GROUP BY p.user_id
) l ON u.user_id = l.user_id
LEFT JOIN (
    SELECT p.user_id, COUNT(*) AS total_comments
    FROM Posts p JOIN Comments c ON p.post_id = c.post_id
    GROUP BY p.user_id
) c ON u.user_id = c.user_id
LEFT JOIN (
    SELECT followed_user_id, COUNT(*) AS total_followers
    FROM Followers
    GROUP BY followed_user_id
) f ON u.user_id = f.followed_user_id
JOIN users u2
ON u2.user_id=l.user_id
JOIN number_of_followers nof
on nof.user_id=u2.user_id


--•	Foydalanuvchilar orasida eng ko‘p post qilganlar va eng ko‘p layk olganlar topilsin.


select
	post_id,
	count(post_id) as post_count,
	like_id,
	count(post_id) as like_count
from likes
group by post_id, like_id


SELECT TOP 1 u.username, COUNT(*) AS post_count
FROM Posts p
JOIN Users u ON p.user_id = u.user_id
GROUP BY u.username
ORDER BY post_count DESC;

-- Most Likes
SELECT TOP 1 u.username, COUNT(*) AS like_count
FROM Posts p
JOIN Likes l ON p.post_id = l.post_id
JOIN Users u ON p.user_id = u.user_id
GROUP BY u.username
ORDER BY like_count DESC;

--Most Posts
select top 1 u.username, count(*) as post_count
from posts p
JOIN likes l ON l.post_id=l.post_id
JOIN users u ON p.user_id=u.user_id
group by u.username
order by post_count desc;



--•	Har bir hafta bo‘yicha yangi foydalanuvchilar soni, faol postlar va layklar trendini chiqaruvchi view yarating.

go
CREATE VIEW WeeklyTrends AS
SELECT 
    DATEPART(ISO_WEEK, u.join_date) AS week,
    COUNT(DISTINCT u.user_id) AS new_users,
    COUNT(DISTINCT p.post_id) AS posts,
    COUNT(DISTINCT l.like_id) AS likes
FROM Users u
LEFT JOIN Posts p ON u.user_id = p.user_id
LEFT JOIN Likes l ON p.post_id = l.post_id
GROUP BY DATEPART(ISO_WEEK, u.join_date);
go
select * from WeeklyTrends

--•	SQL bilan: Followerlar ro‘yxatida "ghost followers"ni aniqlash (ya'ni faollik ko‘rsatmayotganlar: post ko‘rmagan, like bosmagan).

SELECT DISTINCT f.follower_id
FROM Followers f
LEFT JOIN Likes l ON f.follower_id = l.user_id
LEFT JOIN Comments c ON f.follower_id = c.user_id
WHERE l.like_id IS NULL AND c.comment_id IS NULL;



-------------------


------4. Bank Kredit Tahlili
------Loyiha: Kredit arizalar, to‘lovlar, mijozlar va risk tahlili.
------Task:
------•	Kreditni o‘z vaqtida to‘lamagan mijozlar ro‘yxatini, ularning umumiy qarzdorligi va kechikish kunlari bilan toping.
------•	Kredit olishdan oldingi va keyingi 3 oy ichidagi xarajatlarni solishtiring (salary vs expense).
------•	Har bir hudud uchun o‘rtacha kredit miqdorini va foiz stavkalarini tahlil qiling.
------•	Mijozlar risk darajasi (High, Medium, Low) asosida guruhlab, har bir guruhga ajratilgan kredit miqdorini toping.
------•	Trigger yozing: agar mijozning kechikish soni 3 martadan oshsa, kredit holatini avtomatik “frozen”ga o‘tkazilsin
;
CREATE TABLE Customers2 (
    customer_id INT PRIMARY KEY,
    full_name nVARCHAR(max),
    region VARCHAR(max)
);

INSERT INTO Customers2 VALUES
(1, 'Ali Karimov', 'Tashkent'),
(2, 'Dilnoza Yuldasheva', 'Samarkand'),
(3, 'Bekzod Sodiqov', 'Fergana'),
(4, 'Gulbahor Mamatova', 'Tashkent'),
(5, 'Islom Nurmatov', 'Bukhara');

CREATE TABLE Credits (
    credit_id INT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    start_date DATE,
    status VARCHAR(20), -- active, frozen, closed
    FOREIGN KEY (customer_id) REFERENCES Customers2(customer_id)
);

INSERT INTO Credits VALUES
(1, 1, 5000, 12.5, '2025-01-01', 'active'),
(2, 2, 10000, 14.0, '2025-02-15', 'active'),
(3, 3, 3000, 11.0, '2025-03-10', 'frozen'),
(4, 4, 8000, 13.5, '2025-01-20', 'active'),
(5, 5, 15000, 15.0, '2025-01-25', 'active');


CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    credit_id INT,
    payment_date DATE,
    due_date DATE,
    amount_paid DECIMAL(12,2),
    FOREIGN KEY (credit_id) REFERENCES Credits(credit_id)
);

INSERT INTO Payments VALUES
(1, 1, '2025-02-05', '2025-02-01', 1000),
(2, 1, '2025-03-01', '2025-03-01', 1000),
(3, 2, '2025-03-20', '2025-03-15', 2000),
(4, 3, '2025-04-25', '2025-04-01', 500),
(5, 4, '2025-02-15', '2025-02-01', 1000),
(6, 5, '2025-02-01', '2025-02-01', 3000);


CREATE TABLE Salaries (
    salary_id INT PRIMARY KEY,
    customer_id INT,
    salary_date DATE,
    amount DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES Customers2(customer_id)
);

INSERT INTO Salaries VALUES
(1, 1, '2024-12-01', 2500),
(2, 1, '2025-01-01', 2600),
(3, 1, '2025-02-01', 2550),
(4, 2, '2024-11-01', 3000),
(5, 2, '2025-02-01', 3100),
(6, 3, '2024-12-01', 2000);


CREATE TABLE Expenses (
    expense_id INT PRIMARY KEY,
    customer_id INT,
    expense_date DATE,
    amount DECIMAL(12,2),
    FOREIGN KEY (customer_id) REFERENCES Customers2(customer_id)
);

INSERT INTO Expenses VALUES
(1, 1, '2024-12-15', 1200),
(2, 1, '2025-01-15', 1500),
(3, 1, '2025-02-15', 1600),
(4, 2, '2024-11-20', 1800),
(5, 2, '2025-02-20', 2000),
(6, 3, '2024-12-10', 1000);


CREATE TABLE Delays (
    delay_id INT PRIMARY KEY,
    credit_id INT,
    delay_date DATE,
    FOREIGN KEY (credit_id) REFERENCES Credits(credit_id)
);

INSERT INTO Delays VALUES
(1, 1, '2025-02-05'),
(2, 2, '2025-03-20'),
(3, 3, '2025-04-25'),
(4, 3, '2025-03-25'),
(5, 3, '2025-02-25');


------•	Kreditni o‘z vaqtida to‘lamagan mijozlar ro‘yxatini, ularning umumiy qarzdorligi va kechikish kunlari bilan toping.

select * from Credits
select * from delays

select 
	customer_id,
	amount,
	min(delay_days) as delay_days
from
	(select 
		c.customer_id,
		c.amount,
		abs(day(d.delay_date) - day(c.start_date)) as delay_days
	from Credits c
	JOIN delays d
	ON d.credit_id=d.credit_id
) t

where delay_days > 0
group by customer_id, amount
order by t.customer_id


------•	Kredit olishdan oldingi va keyingi 3 oy ichidagi xarajatlarni solishtiring (salary vs expense).

SELECT 
    c.customer_id,

    -- Kreditdan oldingi 3 oy xarajatlar
    SUM(CASE 
            WHEN e.expense_date BETWEEN DATEADD(MONTH, -3, cr.start_date) AND cr.start_date 
            THEN ISNULL(e.amount, 0) 
            ELSE 0 
        END) AS kreditdan_oldingi_harajat,

    -- Kreditdan oldingi 3 oy ish haqi
    SUM(CASE 
            WHEN s.salary_date BETWEEN DATEADD(MONTH, -3, cr.start_date) AND cr.start_date 
            THEN ISNULL(s.amount, 0) 
            ELSE 0 
        END) AS kreaditdan_oldingi_maosh,

    -- Kreditdan keyingi 3 oy xarajatlar
    SUM(CASE 
            WHEN e.expense_date BETWEEN cr.start_date AND DATEADD(MONTH, 3, cr.start_date) 
            THEN ISNULL(e.amount, 0) 
            ELSE 0 
        END) AS kreditdan_keyingi_harajat,

    -- Kreditdan keyingi 3 oy ish haqi
    SUM(CASE 
            WHEN s.salary_date BETWEEN cr.start_date AND DATEADD(MONTH, 3, cr.start_date) 
            THEN ISNULL(s.amount, 0) 
            ELSE 0 
        END) AS kreditdan_keyingi_maosh

FROM Customers c
JOIN Credits cr ON cr.customer_id = c.customer_id
LEFT JOIN Expenses e ON e.customer_id = c.customer_id
LEFT JOIN Salaries s ON s.customer_id = c.customer_id
GROUP BY c.customer_id, cr.start_date;


------•	Har bir hudud uchun o‘rtacha kredit miqdorini va foiz stavkalarini tahlil qiling.

select 
	c.region,
	avg(cr.amount) as average_amount,
	min(cr.interest_rate) as interest_rate
from customers2 c
JOIN credits cr
ON cr.customer_id=c.customer_id
group by region
order by average_amount


------•	Mijozlar risk darajasi (High, Medium, Low) asosida guruhlab, har bir guruhga ajratilgan kredit miqdorini toping.

select
	amount,
	IIF(amount <= 3000, 'Low',
		IIF(amount>=3000 and amount<=5000, 'Medium', 'High')
		) as level_of_risk
from credits cr
group by amount;
			
------•	Trigger yozing: agar mijozning kechikish soni 3 martadan oshsa, kredit holatini avtomatik “frozen”ga o‘tkazilsin


go
CREATE TRIGGER trg_freeze_credit_status
ON Delays
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    --Kchikish soni
    UPDATE c
    SET c.status = 'frozen'
    FROM Credits c
    INNER JOIN (
        SELECT credit_id
        FROM Delays
        GROUP BY credit_id
        HAVING COUNT(*) > 3
    ) d ON d.credit_id = c.credit_id;
END;
go


--------5. Universitet Ma'lumotlar Bazasi
--------Loyiha: Talabalar, kurslar, fanlar, o‘qituvchilar va baholar bazasi.
--------Task:
--------•	Har bir talabaga GPA hisoblang va top 10 talabani chiqaruvchi view yarating.
--------•	Talabalarning kurslarni o‘z vaqtida tugatganligini tekshiring (deadline'ga ko‘ra).
--------•	Baholarga qarab kurslar bo‘yicha o‘rtacha baho va muvaffaqiyat darajasini aniqlang.
--------•	Har bir o‘qituvchining kurslari bo‘yicha pass rate va fail rate'ni hisoblang.
--------•	SQL procedure yozing: yangi semestr boshlanishida avtomatik ravishda barcha kurslar uchun ro‘yxat ochilsin va talabalar enroll qilinsin.



CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    enrollment_date DATE
);

INSERT INTO Students VALUES
(1, 'Ali Karimov', '2021-09-01'),
(2, 'Dilnoza Ismoilova', '2021-09-01'),
(3, 'Sardor Raximov', '2022-09-01'),
(4, 'Malika Toirova', '2022-09-01'),
(5, 'Shoxrux Olimov', '2023-09-01'),
(6, 'Islom Baxtiyorov', '2023-09-01'),
(7, 'Karim Obidov', '2023-09-01'),
(8, 'Toxir Sodiqov', '2023-09-01'),
(9, 'Ubaydullo Ilhomov', '2023-09-01'),
(10, 'Abbos Choriyev', '2023-09-01'),
(11, 'Oyatillo Toirov', '2023-09-01'),
(12, 'Beridyor Otaboyev', '2023-09-01'),
(13, 'Ibrohim Muzaffarov', '2023-09-01'),
(14, 'Bexruz Quvonov', '2023-09-01');


	


	CREATE TABLE Teachers (
    teacher_id INT PRIMARY KEY,
    full_name VARCHAR(100)
);

INSERT INTO Teachers VALUES
(1, 'Anvar Mamatov'),
(2, 'Zarina Qodirova'),
(3, 'Bekzod Karimov');


CREATE TABLE Courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    teacher_id INT,
    deadline DATE
);

INSERT INTO Courses VALUES
(1, 'Mathematics', 1, '2024-12-31'),
(2, 'Physics', 2, '2024-12-15'),
(3, 'Chemistry', 3, '2024-12-10');


CREATE TABLE Enrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    enrollment_date DATE
);

INSERT INTO Enrollments VALUES
(1, 1, 1, '2024-09-01'),
(2, 2, 1, '2024-09-01'),
(3, 3, 2, '2024-09-01'),
(4, 4, 3, '2024-09-01'),
(5, 5, 2, '2024-09-01');


CREATE TABLE Grades (
    grade_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    grade DECIMAL(3,1),         -- e.g. 3.5, 4.0
    grade_date DATE
);

INSERT INTO Grades VALUES
(1, 1, 1, 4.0, '2024-12-01'),
(2, 2, 1, 3.5, '2024-12-02'),
(3, 3, 2, 2.0, '2024-12-05'),
(4, 4, 3, 4.5, '2024-12-04'),
(5, 5, 2, 5.0, '2024-12-03'),
(6, 6, 2, 3.5, '2024-12-10'),
(7, 7, 2, 3.0, '2024-12-19'),
(8, 8, 2, 4.2, '2024-12-28'),
(9, 9, 2, 3.8, '2024-12-14'),
(10, 10, 2, 2.6, '2024-12-11'),
(11, 11, 2, 4.7, '2024-12-20'),
(12, 12, 2, 4.9, '2024-12-03'),
(13, 13, 2, 3.1, '2024-12-03'),
(14, 14, 2, 1.8, '2024-12-03');

--------•	Har bir talabaga GPA hisoblang va top 10 talabani chiqaruvchi view yarating.

go
alter view Students_TOP_GPA as
select top 10 s.full_name,
			g.grade
from students s
LEFT join grades g
ON s.student_id=g.student_id
group by s.full_name,g.grade
order by g.grade desc;
go
select*from Students_TOP_GPA


--------•	Talabalarning kurslarni o‘z vaqtida tugatganligini tekshiring (deadline'ga ko‘ra).




--------•	Baholarga qarab kurslar bo‘yicha o‘rtacha baho va muvaffaqiyat darajasini aniqlang.

SELECT
  c.course_name,
  AVG(g.grade) AS avg_grade,
  CASE
    WHEN AVG(g.grade) >= 4.0 THEN 'Great'
    WHEN AVG(g.grade) >= 3.0 THEN 'Good'
    WHEN AVG(g.grade) >= 2.0 THEN 'Bad'
    ELSE 'Poor'
  END AS success_rate
FROM Grades g
JOIN Courses c
  ON g.course_id = c.course_id
GROUP BY c.course_name;

--------•	Har bir o‘qituvchining kurslari bo‘yicha pass rate va fail rate'ni hisoblang.


SELECT
    t.full_name,
    c.course_name,
    -- Pass rate calculation
    ROUND(COUNT(CASE WHEN g.grade >= 3 THEN 1 END) * 100.0 / COUNT(g.grade), 2) AS pass_rate,
    -- Fail rate calculation
    ROUND(COUNT(CASE WHEN g.grade < 3 THEN 1 END) * 100.0 / COUNT(g.grade), 2) AS fail_rate
FROM
    grades g
JOIN
    courses c ON g.course_id = c.course_id
JOIN
    teachers t ON c.teacher_id = t.teacher_id
GROUP BY
    t.full_name,
    c.course_name
ORDER BY
    t.full_name, c.course_name;


--------•	SQL procedure yozing: yangi semestr boshlanishida avtomatik ravishda barcha kurslar uchun ro‘yxat ochilsin va talabalar enroll qilinsin.


select *from students
select *from grades
select *from Enrollments
select *from Courses
select *from teachers

go 
create proc ps_new_royxat as
(


)
go



----1. Online Streaming Platform (masalan: Netflix, YouTube)
----Jadvallar: users, videos, views, subscriptions, payments
----Tasklar:
----1.	Har bir foydalanuvchi uchun umumiy tomosha qilingan daqiqalarni hisoblang.
----2.	Har bir video uchun o‘rtacha tomosha muddati va engagement ko‘rsatkichi (views/comments/likes) chiqaring.
----3.	Eng ko‘p kuzatilgan 10ta content yaratgan foydalanuvchilar ro‘yxatini chiqaring.
----4.	Yangi foydalanuvchilar ichida 30 kun ichida obuna bo‘lganlar ulushini hisoblang.
----5.	Har bir oy bo‘yicha subscription daromadini va foydalanuvchilar sonini ko‘rsatuvchi CTE yozing.
----6.	SQL Trigger yozing: video joylanganida avtomatik holatda “pending approval” sifatida saqlansin.
----7.	O‘tgan 3 oyda subscription bekor qilganlar soni va sabablarini chiqaruvchi so‘rov yozing.
----8.	Har bir content category bo‘yicha o‘rtacha daromad va retention foizini hisoblang.


set identity_insert users off
drop table users
-- USERS table
CREATE TABLE Users (
    user_id INT PRIMARY KEY identity,
    username VARCHAR(100),
    join_date DATE
);

INSERT INTO Users (username, join_date) VALUES
('user1', '2025-01-10'),
('user2', '2025-02-15'),
('user3', '2025-03-01'),
('user4', '2025-03-20'),
('user5', '2025-04-05');

-- VIDEOS table
CREATE TABLE Videos (
    video_id INT PRIMARY KEY,
    uploader_id INT,
    title VARCHAR(100),
    duration_minutes INT,
    category VARCHAR(50),
    status VARCHAR(20),
    upload_date DATE,
    FOREIGN KEY (uploader_id) REFERENCES Users(user_id)
);

INSERT INTO Videos (video_id, uploader_id, title, duration_minutes, category, status, upload_date) VALUES
(1, 1, 'Video A', 10, 'Music', 'approved', '2025-01-15'),
(2, 2, 'Video B', 15, 'Education', 'approved', '2025-02-16'),
(3, 1, 'Video C', 20, 'Music', 'approved', '2025-02-25'),
(4, 3, 'Video D', 30, 'Gaming', 'approved', '2025-03-10'),
(5, 2, 'Video E', 12, 'Education', 'approved', '2025-04-01');

-- VIEWS table
CREATE TABLE Views (
    view_id INT PRIMARY KEY,
    user_id INT,
    video_id INT,
    watch_duration_minutes INT,
    view_date DATE,
    comments INT,
    likes INT,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (video_id) REFERENCES Videos(video_id)
);

INSERT INTO Views (view_id, user_id, video_id, watch_duration_minutes, view_date, comments, likes) VALUES
(1, 1, 1, 10, '2025-01-16', 2, 1),
(2, 2, 2, 12, '2025-02-17', 1, 0),
(3, 3, 3, 15, '2025-03-12', 0, 1),
(4, 4, 4, 30, '2025-03-21', 3, 2),
(5, 5, 5, 10, '2025-04-05', 1, 1);

-- SUBSCRIPTIONS table
CREATE TABLE Subscriptions (
    subscription_id INT PRIMARY KEY,
    user_id INT,
    start_date DATE,
    end_date DATE,
    cancel_reason VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Subscriptions (subscription_id, user_id, start_date, end_date, cancel_reason) VALUES
(1, 1, '2025-01-12', '2025-04-12', 'No longer interested'),
(2, 2, '2025-02-16', NULL, NULL),
(3, 3, '2025-03-03', NULL, NULL),
(4, 4, '2025-03-25', '2025-04-25', 'Too expensive'),
(5, 5, '2025-04-06', NULL, NULL);


-- PAYMENTS table
CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    user_id INT,
    amount DECIMAL(6,2),
    payment_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Payments (payment_id, user_id, amount, payment_date) VALUES
(1, 1, 10.99, '2025-01-12'),
(2, 2, 15.10, '2025-02-16'),
(3, 3, 9.99, '2025-03-03'),
(4, 4, 7.79, '2025-03-25'),
(5, 5, 8.59, '2025-04-06');



----1.	Har bir foydalanuvchi uchun umumiy tomosha qilingan daqiqalarni hisoblang.

select*from users
select*from Views

select 
	u.username,
	sum(v.watch_duration_minutes) watch_duration_minutes
from users u
JOIN Views v
ON u.user_id=v.user_id
group by username

----2.	Har bir video uchun o‘rtacha tomosha muddati va engagement ko‘rsatkichi (views/comments/likes) chiqaring.
select*from Views
select*from Videos

select 
	vd.category,
	avg(watch_duration_minutes) as avg_watching,
	v.view_id,
	v.comments,
	v.likes
from views v
LEFT JOIN videos vd
ON v.video_id=vd.video_id
group by view_id, comments, likes, category;

----3.	Eng ko‘p kuzatilgan 10ta content yaratgan foydalanuvchilar ro‘yxatini chiqaring.
select* from users
select*from Views
select*from Videos

SELECT top 10 
    v.uploader_id,
    COUNT(*) AS total_views
FROM 
    Videos v
JOIN 
    Views vw ON v.video_id = vw.video_id
GROUP BY 
    v.uploader_id
ORDER BY 
    total_views DESC

----4.	Yangi foydalanuvchilar ichida 30 kun ichida obuna bo‘lganlar ulushini hisoblang.
select * from Subscriptions
select * from Payments

select
	day(s.start_DATE) as between_30Days,
	sum(p.amount) as ulush
from
Subscriptions s
left join Payments p
ON s.user_id=p.user_id
where day(s.start_DATE) between 1 and 30
group by s.start_DATE;


----5.	Har bir oy bo‘yicha subscription daromadini va foydalanuvchilar sonini ko‘rsatuvchi CTE yozing.

select * from Payments
select * from Views


;with cte as(
	select month(p.payment_date) payment_date_month,
		   p.amount,
		   count(p.user_id) as user_count
	from Payments p
	JOIN views v
	ON v.user_id=p.user_id
	group by month(p.payment_date), p.amount
) 
select * from cte

----6.	SQL Trigger yozing: video joylanganida avtomatik holatda “pending approval” sifatida saqlansin.

go
CREATE TRIGGER trg_SetPendingApproval
ON Videos
INSTEAD OF INSERT
AS
BEGIN
    INSERT INTO Videos (video_id, uploader_id, title, duration_minutes, category, status, upload_date)
    SELECT video_id, uploader_id, title, duration_minutes, category, 'pending approval', upload_date
    FROM inserted;
END;

go

----7.	O‘tgan 3 oyda subscription bekor qilganlar soni va sabablarini chiqaruvchi so‘rov yozing.

select*from Subscriptions

select
      cancel_reason,
	  count(*) as cancelled_count
from Subscriptions
where end_date>=dateadd(month, -3, getdate())
and cancel_reason is not null
group by cancel_reason;


----8.	Har bir content category bo‘yicha o‘rtacha daromad va retention foizini hisoblang.

select*from Videos
select * from Payments

SELECT 
    v.category,
    AVG(p.amount) AS avg_revenue
FROM 
    Views vw
JOIN 
    Videos v ON vw.video_id = v.video_id
JOIN 
    Payments p ON vw.user_id = p.user_id
GROUP BY 
    v.category;


----2. Kasalxona va Tibbiyot Tahlili
----Jadvallar: patients, doctors, appointments, prescriptions, lab_results
----Tasklar:
----1.	Har bir shifokor bo‘yicha bemor soni va o‘rtacha tashrif sonini hisoblang.
----2.	Har bir bemor uchun eng so‘nggi lab test natijalarini ko‘rsatuvchi query yozing.
----3.	Dori-darmonlar narxi va ulardan tushgan umumiy daromadni hisoblang.
----4.	65+ yoshdagi bemorlarning lab test natijalariga ko‘ra eng ko‘p uchraydigan kasalliklarni toping.
----5.	Har bir mutaxassislik bo‘yicha o‘rtacha davolanish muddati va tashriflar sonini chiqaring.
----6.	Trigger yozing: agar lab natijasi normadan chiqsa, alert jadvaliga yozilsin.
----7.	Shifokorning bo‘sh vaqtlarini topish uchun available schedule yaratadigan view yozing.
----8.	SQL orqali “no-show” bemorlar foizini hisoblang (ro‘yxatdan o‘tgan, lekin kelmaganlar).


-- PATIENTS table
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    birth_date DATE,
    gender VARCHAR(10)
);

INSERT INTO patients (patient_id, full_name, birth_date, gender) VALUES
(1, 'Ali Valiyev', '1958-05-10', 'Male'),
(2, 'Dilnoza Karimova', '1990-02-20', 'Female'),
(3, 'Jasur Ergashev', '1980-11-30', 'Male'),
(4, 'Muqaddas Tursunova', '1955-08-15', 'Female');


-- DOCTORS table
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    specialty VARCHAR(50)
);

INSERT INTO doctors (doctor_id, full_name, specialty) VALUES
(1, 'Dr. Nodir Alimov', 'Cardiology'),
(2, 'Dr. Gulbahor Toshpulatova', 'Endocrinology'),
(3, 'Dr. Shavkat Mirzayev', 'Neurology');


-- APPOINTMENTS table
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    appointment_date DATE,
    status VARCHAR(20), -- 'attended', 'no-show', 'cancelled'
    treatment_days INT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

INSERT INTO appointments (appointment_id, patient_id, doctor_id, appointment_date, status, treatment_days) VALUES
(1, 1, 1, '2025-01-10', 'attended', 10),
(2, 2, 2, '2025-01-15', 'no-show', NULL),
(3, 3, 1, '2025-02-05', 'attended', 5),
(4, 4, 3, '2025-02-25', 'attended', 7),
(5, 1, 1, '2025-03-05', 'attended', 3);


-- PRESCRIPTIONS table
CREATE TABLE prescriptions (
    prescription_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    medication_name VARCHAR(100),
    price DECIMAL(6,2),
    quantity INT,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
);

INSERT INTO prescriptions (prescription_id, patient_id, doctor_id, medication_name, price, quantity) VALUES
(1, 1, 1, 'Aspirin', 5.00, 2),
(2, 2, 2, 'Metformin', 10.00, 1),
(3, 3, 1, 'Atorvastatin', 15.00, 1),
(4, 4, 3, 'Gabapentin', 12.50, 2);


-- LAB_RESULTS table
CREATE TABLE lab_results (
    result_id INT PRIMARY KEY,
    patient_id INT,
    test_name VARCHAR(100),
    result_value VARCHAR(50),
    normal_range VARCHAR(50),
    diagnosis VARCHAR(100),
    test_date DATE,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

INSERT INTO lab_results (result_id, patient_id, test_name, result_value, normal_range, diagnosis, test_date) VALUES
(1, 1, 'Blood Pressure', '150/90', '120/80', 'Hypertension', '2025-03-01'),
(2, 2, 'Blood Sugar', '110', '70-99', 'Pre-diabetes', '2025-03-05'),
(3, 3, 'Cholesterol', '180', '125-200', 'Normal', '2025-04-01'),
(4, 1, 'Blood Sugar', '140', '70-99', 'Diabetes', '2025-04-10'),
(5, 4, 'MRI', 'Lesion Found', 'None', 'Tumor', '2025-03-15');


-- ALERTS table (for trigger)
CREATE TABLE alerts (
    alert_id INT PRIMARY KEY IDENTITY,
    patient_id INT,
    test_name VARCHAR(100),
    result_value VARCHAR(50),
    test_date DATE,
    alert_message VARCHAR(255)
);


----Tasklar:
----1.	Har bir shifokor bo‘yicha bemor soni va o‘rtacha tashrif sonini hisoblang.
select* from appointments
select * from doctors


SELECT 
    d.full_name,
    COUNT(DISTINCT a.patient_id) AS patient_count,
    CAST(COUNT(*) AS FLOAT) / COUNT(DISTINCT a.patient_id) AS avg_appointments_per_patient
FROM 
    doctors d
JOIN 
    appointments a ON d.doctor_id = a.doctor_id
GROUP BY 
    d.full_name;

----2.	Har bir bemor uchun eng so‘nggi lab test natijalarini ko‘rsatuvchi query yozing.

select * from patients
select * from lab_results

SELECT lr.*
FROM lab_results lr
JOIN (
    SELECT patient_id, MAX(test_date) AS latest_test_date
    FROM lab_results
    GROUP BY patient_id
) latest ON lr.patient_id = latest.patient_id AND lr.test_date = latest.latest_test_date;

----3.	Dori-darmonlar narxi va ulardan tushgan umumiy daromadni hisoblang.
SELECT * FROM prescriptions

SELECT
	medication_name,
	PRICE,
	(PRICE*QUANTITY) AS DAROMAD
FROM prescriptions
GROUP BY PRICE,quantity, medication_name

----4.	65+ yoshdagi bemorlarning lab test natijalariga ko‘ra eng ko‘p uchraydigan kasalliklarni toping.

select*from patients
select * from lab_results

select top 1 
	p.birth_date,
	lr.diagnosis
from patients p
JOIN lab_results lr
ON p.patient_id=lr.patient_id
where year(p.birth_date) > 65
group by p.birth_date, lr.diagnosis;

----5.	Har bir mutaxassislik bo‘yicha o‘rtacha davolanish muddati va tashriflar sonini chiqaring.


select * from lab_results
select * from doctors
select*from appointments

select
	d.specialty,
	isnull(avg(a.treatment_days), 0) as avg_days
from appointments a
join doctors d
ON d.doctor_id=a.doctor_id
group by d.specialty

----6.	Trigger yozing: agar lab natijasi normadan chiqsa, alert jadvaliga yozilsin.
go
CREATE TRIGGER trg_lab_result_alert
ON lab_results
AFTER INSERT
AS
BEGIN
    INSERT INTO alerts (patient_id, test_name, result_value, test_date, alert_message)
    SELECT 
        i.patient_id,
        i.test_name,
        i.result_value,
        i.test_date,
        'Lab result out of normal range'
    FROM inserted i
    WHERE i.result_value NOT LIKE i.normal_range;
END;
go
----7.	Shifokorning bo‘sh vaqtlarini topish uchun available schedule yaratadigan view yozing.
go
CREATE VIEW available_schedule AS
SELECT 
    d.doctor_id,
    d.full_name,
    a.appointment_date,
    'Available' AS status
FROM doctors d
CROSS JOIN (
    SELECT DISTINCT appointment_date FROM appointments
) a
WHERE NOT EXISTS (
    SELECT 1
    FROM appointments ap
    WHERE ap.doctor_id = d.doctor_id
    AND ap.appointment_date = a.appointment_date
);

select* from available_schedule
----8.	SQL orqali “no-show” bemorlar foizini hisoblang (ro‘yxatdan o‘tgan, lekin kelmaganlar).

SELECT 
    CAST(SUM(CASE WHEN status = 'no-show' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS no_show_percentage
FROM appointments;

----3. Bank Fraud Detection (Firibgarlik aniqlash)
----Jadvallar: accounts, transactions, fraud_flags, users
----Tasklar:
----1.	24 soat ichida 5 dan ortiq transaction qilgan foydalanuvchilarni toping.
----2.	$5000 dan katta 3 ta ketma-ket pul yechish bo‘lsa, ehtimoliy firibgarlik deb flag qo‘ying.
----3.	Har bir account bo‘yicha eng katta va eng kichik tranzaksiyani chiqaring.
----4.	Foydalanuvchi bir vaqtning o‘zida ikki marta login qilgan bo‘lsa, ogohlantiruvchi signal yozing.
----5.	Har bir haftada nechta fraud flag qo‘yilganligini va ularning yechimini ko‘rsatuvchi query yozing.
----6.	Trigger yozing: agar pul o‘tkazmasi chet el kartasiga qilinsa, flag jadvalga yozilsin.
----7.	Mamlakatlar kesimida eng ko‘p firibgarliklar sonini vizualizatsiya qilishga tayyor view yarating.
----8.	Foydalanuvchilarning IP-manzillari o‘zgarishini kuzatib boradigan log jadvaliga yozuvchi procedure yozing.

drop table if exists users1
-- USERS table
CREATE TABLE users1 (
    user_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(50)
);

INSERT INTO users1 (user_id, full_name, email, country) VALUES
(1, 'Bobur Sodiqov', 'bobur@example.com', 'Uzbekistan'),
(2, 'Laylo Mirzayeva', 'laylo@example.com', 'USA'),
(3, 'Javlon Bekmurodov', 'javlon@example.com', 'Germany'),
(4, 'Gulbahor Tursunova', 'gulbahor@example.com', 'Uzbekistan');

drop table accounts
-- ACCOUNTS table
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    user_id INT,
    account_number VARCHAR(20),
    account_type VARCHAR(20),
    balance DECIMAL(10,2),
    FOREIGN KEY (user_id) REFERENCES users1(user_id)
);

INSERT INTO accounts (account_id, user_id, account_number, account_type, balance) VALUES
(101, 1, 'ACC1001', 'savings', 15000.00),
(102, 2, 'ACC1002', 'current', 9000.00),
(103, 3, 'ACC1003', 'savings', 7000.00),
(104, 4, 'ACC1004', 'current', 2000.00);


-- TRANSACTIONS table
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    amount DECIMAL(10,2),
    transaction_type VARCHAR(20), -- 'withdraw', 'deposit', 'transfer'
    transaction_time DATETIME,
    destination_country VARCHAR(50),
    ip_address VARCHAR(50),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
truncate table transactions
INSERT INTO transactions (transaction_id, account_id, amount, transaction_type, transaction_time, destination_country, ip_address) VALUES
(1, 101, 3000.00, 'withdraw', '2025-05-03 7:00:00', 'Korea', '192.168.1.1'),
(2, 102, 5200.00, 'withdraw', '2025-05-01 09:00:00', 'Uzbekistan', '192.168.1.1'),
(3, 101, 5500.00, 'deposit', '2025-05-04 09:05:00', 'Uzbekistan', '192.168.1.1'),
(4, 103, 5100.00, 'withdraw', '2025-05-01 09:10:00', 'Uzbekistan', '192.168.1.1'),
(5, 101, 1000.00, 'deposit', '2025-05-03 11:00:00', 'Africa', '192.168.1.1'),
(6, 104, 8000.00, 'transfer', '2025-05-02 11:00:00', 'Germany', '192.168.1.2'),
(7, 102, 2000.00, 'withdraw', '2025-05-03 13:00:00', 'Germany', '192.168.1.3'),
(8, 101, 3000.00, 'withdraw', '2025-05-04 10:00:00', 'Germany', '192.168.1.4'),
(9, 104, 4000.00, 'deposit', '2025-05-03 15:00:00', 'USA', '192.168.1.5'),
(10, 101, 5000.00, 'deposit', '2025-05-03 12:00:00', 'USA', '192.168.1.5'),
(11, 104, 10000.00, 'deposit', '2025-05-03 15:00:00', 'USA', '192.168.1.5'),
(12, 101, 9000.00, 'transfer', '2025-05-03 13:00:00', 'USA', '192.168.1.5');

drop table fraud_flags
-- FRAUD_FLAGS table
CREATE TABLE fraud_flags (
    flag_id INT PRIMARY KEY IDENTITY,
    account_id INT,
    transaction_id INT,
    flag_reason VARCHAR(255),
    flag_date date,
    resolved BIT DEFAULT 0,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

INSERT INTO fraud_flags (account_id, transaction_id, flag_reason, flag_date)
VALUES
(101, 2, 'High-value withdrawal over $5000', '2025-01-14'),
(101, 3, 'Second consecutive high-value withdrawal', '2025-02-18'),
(101, 4, 'Third high-value withdrawal in short time', '2025-03-04'),
(102, 6, 'International transfer to Germany', '2025-05-19'),
(101, NULL, 'Multiple logins from different IPs at the same time', '2025-04-20');


-- LOGIN_LOG table (foydalanuvchi loginlari uchun)
CREATE TABLE login_log (
    log_id INT PRIMARY KEY IDENTITY,
    user_id INT,
    login_time DATETIME,
    ip_address VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
truncate table login_log
INSERT INTO login_log (user_id, login_time, ip_address) VALUES
(1, '2025-05-01 08:00:00', '192.168.1.1'),
(1, '2025-05-01 08:00:00', '10.0.0.1'),
(2, '2025-05-02 10:00:00', '192.168.2.2'),
(3, '2025-05-03 09:00:00', '192.168.3.3');

----1.	24 soat ichida 5 dan ortiq transaction qilgan foydalanuvchilarni toping.

select * from transactions
select * from users1
select*from accounts

select 
	u.user_id,
	u.full_name,
	count(t.transaction_id) as transaction_count,
	min(t.transaction_time) as first_transaction,
	max(t.transaction_time) as last_transaction
from users1 u
JOIN accounts a
ON u.user_id=a.account_id
JOIN transactions t
ON t.account_id=a.account_id
where transaction_time between dateadd(hour, -24, getdate()) and getdate()
group by u.user_id, full_name
having count(t.transaction_id)>=5
order by transaction_count desc;



----2.	$5000 dan katta 3 ta ketma-ket pul yechish bo‘lsa, ehtimoliy firibgarlik deb flag qo‘ying.


select * from fraud_flags

;WITH filtered AS (
    SELECT 
        transaction_id,
        account_id,
        amount,
        transaction_time,
        ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY transaction_time) AS rn
    FROM transactions
    WHERE transaction_type = 'withdrawal' AND amount > 5000
)
INSERT INTO fraud_flags (account_id, transaction_id, flag_reason)
SELECT 
    f1.account_id,
    f1.transaction_id,
    '3 high-value withdrawals in a row'
FROM filtered f1
JOIN filtered f2 ON f2.account_id = f1.account_id AND f2.rn = f1.rn + 1
JOIN filtered f3 ON f3.account_id = f1.account_id AND f3.rn = f1.rn + 2


----3.	Har bir account bo‘yicha eng katta va eng kichik tranzaksiyani chiqaring.

select * from accounts
select * from transactions

select distinct t.account_id, a.account_number,
	min(t.amount) over(partition by t.account_id order by t.account_id) as MIN_amount
from transactions t
JOIN accounts a
ON a.account_id=t.account_id

----4.	Foydalanuvchi bir vaqtning o‘zida ikki marta login qilgan bo‘lsa, ogohlantiruvchi signal yozing.

select * from login_log
select * from fraud_flags
select * from accounts
---==========================================
SELECT 
    l1.user_id,
    l1.login_time AS suspicious_login_time,
    COUNT(*) AS login_count
FROM login_log l1
JOIN (
    SELECT user_id, login_time
    FROM login_log
    GROUP BY user_id, login_time
    HAVING COUNT(*) > 1
) dup ON l1.user_id = dup.user_id AND l1.login_time = dup.login_time
GROUP BY l1.user_id, l1.login_time


----5.	Har bir haftada nechta fraud flag qo‘yilganligini va ularning yechimini ko‘rsatuvchi query yozing.

SELECT 
    DATEPART(WEEK, flag_date) AS week,
    COUNT(*) AS total_flags,
    SUM(CASE WHEN resolved = 1 THEN 1 ELSE 0 END) AS resold_veflags,
    SUM(CASE WHEN resolved = 0 THEN 1 ELSE 0 END) AS unresolved_flags
FROM fraud_flags
GROUP BY DATEPART(YEAR, flag_date), DATEPART(WEEK, flag_date)
ORDER BY week;

----6.	Trigger yozing: agar pul o‘tkazmasi chet el kartasiga qilinsa, flag jadvalga yozilsin.

CREATE TRIGGER trg_foreign_transfer_flag
ON transactions
AFTER INSERT
AS
BEGIN
    INSERT INTO fraud_flags (account_id, transaction_id, flag_reason)
    SELECT 
        i.account_id,
        i.transaction_id,
        'Foreign card transfer detected'
    FROM inserted i
    WHERE i.destination_country IS NOT NULL AND i.destination_country != 'UZ'; -- 'UZ' = Uzbekistan
END;


----7.	Mamlakatlar kesimida eng ko‘p firibgarliklar sonini vizualizatsiya qilishga tayyor view yarating.

go
CREATE VIEW vw_fraud_by_country AS
SELECT 
    t.destination_country,
    COUNT(f.flag_id) AS fraud_count
FROM fraud_flags f
JOIN transactions t ON f.account_id = t.account_id
GROUP BY t.destination_country;

select * from vw_fraud_by_country

----8.	Foydalanuvchilarning IP-manzillari o‘zgarishini kuzatib boradigan log jadvaliga yozuvchi procedure yozing.

-- Log jadvali
CREATE TABLE ip_change_log (
    log_id INT PRIMARY KEY IDENTITY,
    user_id INT,
    old_ip VARCHAR(50),
    new_ip VARCHAR(50),
    change_time DATETIME DEFAULT GETDATE()
);
go
-- Procedure
CREATE PROCEDURE sp_track_ip_change
    @user_id INT,
    @new_ip VARCHAR(50)
AS
BEGIN
    DECLARE @old_ip VARCHAR(50);
    
    SELECT TOP 1 @old_ip = ip_address 
    FROM login_log 
    WHERE user_id = @user_id 
    ORDER BY login_time DESC;
    
    IF @old_ip IS NOT NULL AND @old_ip <> @new_ip
    BEGIN
        INSERT INTO ip_change_log (user_id, old_ip, new_ip)
        VALUES (@user_id, @old_ip, @new_ip);
    END;
END;


------4. Ishchilar va HR tizimi
------Jadvallar: employees, salaries, positions, attendance, leaves
------Tasklar:
------1.	Har bir ishchi uchun oxirgi 6 oydagi ish haqi o‘zgarishini ko‘rsatuvchi query yozing.
------2.	Har bir bo‘lim bo‘yicha ishchi soni, o‘rtacha ish haqi va yillik aylanmani chiqaring.
------3.	Har bir ishchi uchun eng ko‘p kechikgan kunlar ro‘yxatini tuzing.
------4.	SQL bilan: 3 martadan ko‘p kechikkan ishchilar “warning” holatiga o‘tkazilsin.
------5.	1 yil ichida eng kam ta'til olgan ishchilarni toping.
------6.	O‘rtacha mehnat davomiyligini (loyalty) hisoblang: hire_date dan bugungacha.
------7.	Shaxsiy ma’lumotlar o‘zgartirilsa, audit_log jadvaliga yozuvchi trigger yozing.
------8.	Har bir lavozim bo‘yicha ishga qabul tezligini aniqlang (interview → hire).

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    email VARCHAR(100),
    hire_date DATE,
    department VARCHAR(50)
);

CREATE TABLE positions (
    position_id INT PRIMARY KEY,
    employee_id INT,
    title VARCHAR(50),
    department VARCHAR(50),
    start_date DATE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE salaries1 (
    salary_id INT PRIMARY KEY,
    employee_id INT,
    amount DECIMAL(10,2),
    pay_date DATE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY,
    employee_id INT,
    attend_date DATE,
    check_in TIME,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE leaves (
    leave_id INT PRIMARY KEY,
    employee_id INT,
    leave_date DATE,
    duration_days INT,
    reason VARCHAR(100),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Employees
INSERT INTO employees VALUES
(1, 'Employee 1', 'employee1@company.com', '2023-12-21', 'Finance'),
(2, 'Employee 2', 'employee2@company.com', '2024-01-26', 'HR'),
(3, 'Employee 3', 'employee3@company.com', '2023-02-26', 'Marketing'),
(4, 'Employee 4', 'employee4@company.com', '2023-04-19', 'Marketing'),
(5, 'Employee 5', 'employee5@company.com', '2023-05-01', 'HR');

-- Positions
INSERT INTO positions VALUES
(1, 1, 'Position 1', 'Finance', '2023-01-01'),
(2, 2, 'Position 2', 'HR', '2023-01-01'),
(3, 3, 'Position 3', 'Finance', '2023-01-01'),
(4, 4, 'Position 4', 'HR', '2023-01-01'),
(5, 5, 'Position 5', 'HR', '2023-01-01');

-- Salaries
INSERT INTO salaries VALUES
(1, 1, 1100, '2024-12-01'), (2, 1, 1110, '2024-12-31'), (3, 1, 1120, '2025-01-30'),
(4, 1, 1130, '2025-03-01'), (5, 1, 1140, '2025-03-31'), (6, 1, 1150, '2025-04-30'),
(7, 2, 1200, '2024-12-01'), (8, 2, 1210, '2024-12-31'), (9, 2, 1220, '2025-01-30'),
(10, 2, 1230, '2025-03-01'), (11, 2, 1240, '2025-03-31'), (12, 2, 1250, '2025-04-30'),
(13, 3, 1300, '2024-12-01'), (14, 3, 1310, '2024-12-31'), (15, 3, 1320, '2025-01-30'),
(16, 3, 1330, '2025-03-01'), (17, 3, 1340, '2025-03-31'), (18, 3, 1350, '2025-04-30'),
(19, 4, 1400, '2024-12-01'), (20, 4, 1410, '2024-12-31'), (21, 4, 1420, '2025-01-30'),
(22, 4, 1430, '2025-03-01'), (23, 4, 1440, '2025-03-31'), (24, 4, 1450, '2025-04-30'),
(25, 5, 1500, '2024-12-01'), (26, 5, 1510, '2024-12-31'), (27, 5, 1520, '2025-01-30'),
(28, 5, 1530, '2025-03-01'), (29, 5, 1540, '2025-03-31'), (30, 5, 1550, '2025-04-30');

-- Attendance
INSERT INTO attendance VALUES
(1, 1, '2025-04-01', '09:00'), (2, 1, '2025-04-02', '09:30'), (3, 1, '2025-04-03', '09:30'),
(4, 1, '2025-04-04', '09:30'), (5, 1, '2025-04-05', '09:00'),
(6, 2, '2025-04-01', '09:30'), (7, 2, '2025-04-02', '09:00'), (8, 2, '2025-04-03', '09:00'),
(9, 2, '2025-04-04', '09:30'), (10, 2, '2025-04-05', '09:00'),
(11, 3, '2025-04-01', '09:30'), (12, 3, '2025-04-02', '09:00'), (13, 3, '2025-04-03', '09:00'),
(14, 3, '2025-04-04', '09:00'), (15, 3, '2025-04-05', '09:00'),
(16, 4, '2025-04-01', '09:30'), (17, 4, '2025-04-02', '09:30'), (18, 4, '2025-04-03', '09:30'),
(19, 4, '2025-04-04', '09:30'), (20, 4, '2025-04-05', '09:30'),
(21, 5, '2025-04-01', '09:30'), (22, 5, '2025-04-02', '09:00'), (23, 5, '2025-04-03', '09:30'),
(24, 5, '2025-04-04', '09:00'), (25, 5, '2025-04-05', '09:30');

-- Leaves
INSERT INTO leaves VALUES
(1, 1, '2024-07-01', 2, 'Vacation'),
(2, 2, '2024-07-02', 1, 'Vacation'),
(3, 3, '2024-07-03', 1, 'Vacation'),
(4, 4, '2024-07-04', 1, 'Vacation'),
(5, 5, '2024-07-05', 5, 'Vacation');


------1.Har bir ishchi uchun oxirgi 6 oydagi ish haqi o‘zgarishini ko‘rsatuvchi query yozing.

select * from employees
select * from salaries1

;with cte as(
select 
	e.full_name as full_name,
	s.pay_date as pay_date,
	s.amount as salary_raise
from employees e
JOIN salaries1 s
ON e.employee_id=s.employee_id
where s.pay_date between dateadd(month, -6, getdate()) and getdate()
group by e.full_name,
	s.pay_date,
	s.amount
)

select * from cte
order by salary_raise asc


------2. Har bir bo‘lim bo‘yicha ishchi soni, o‘rtacha ish haqi va yillik aylanmani chiqaring.

select count(distinct emp.department) as emp_count, s.employee_id, avg(s.amount) as average_emp_salary, sum(amount) as yearly_circulation
from employees emp
JOIN salaries1 s
ON s.employee_id=emp.employee_id
group by emp.department, s.employee_id, year(pay_date)



------3.Har bir ishchi uchun eng ko‘p kechikgan kunlar ro‘yxatini tuzing.

SELECT 
    e.employee_id,
    e.full_name,
    COUNT(*) AS late_days
FROM attendance a
JOIN employees e ON a.employee_id = e.employee_id
WHERE a.check_in > '09:00'
GROUP BY e.employee_id, e.full_name
ORDER BY employee_id asc;


------4.	SQL bilan: 3 martadan ko‘p kechikkan ishchilar “warning” holatiga o‘tkazilsin.

SELECT 
    e.employee_id,
    e.full_name,
    COUNT(*) AS late_days,
	case
		when COUNT(*) >3 then 'Warning' else 'Notning'
	end as Reminder
FROM attendance a
JOIN employees e ON a.employee_id = e.employee_id
WHERE a.check_in > '09:00'
GROUP BY e.employee_id, e.full_name
ORDER BY employee_id asc;

------5.	1 yil ichida eng kam ta'til olgan ishchilarni toping.

select top 5
	e.full_name,
	e.employee_id,
	count(l.leave_id) as vacation_count
from employees e
left join leaves l
ON l.employee_id=e.employee_id
where leave_date>=dateadd(year, -1, getdate())
group by e.full_name,
	e.employee_id
order by vacation_count

------6.	O‘rtacha mehnat davomiyligini (loyalty) hisoblang: hire_date dan bugungacha.

select 
	avg(datediff(day, hire_date, getdate())) as avg_hire_day,
	avg(datediff(month, hire_date, getdate())) as avg_hire_month,
	avg(datediff(year, hire_date, getdate())) as avg_hire_year
from employees

------7.	Shaxsiy ma’lumotlar o‘zgartirilsa, audit_log jadvaliga yozuvchi trigger yozing.


select * from salaries1
select * from attendance
select * from leaves
select * from employees
select * from positions

CREATE TABLE audit_log (
    log_id INT IDENTITY PRIMARY KEY,
    employee_id INT,
    column_changed VARCHAR(50),
    old_value NVARCHAR(255),
    new_value NVARCHAR(255),
    changed_at DATETIME DEFAULT GETDATE()
);
go
CREATE TRIGGER trg_audit_employee_update
ON employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- full_name o‘zgarishini yozish
    INSERT INTO audit_log (employee_id, column_changed, old_value, new_value)
    SELECT 
        i.employee_id,
        'full_name',
        d.full_name,
        i.full_name
    FROM inserted i
    JOIN deleted d ON i.employee_id = d.employee_id
    WHERE ISNULL(i.full_name, '') <> ISNULL(d.full_name, '');

    -- department o‘zgarishini yozish
    INSERT INTO audit_log (employee_id, column_changed, old_value, new_value)
    SELECT 
        i.employee_id,
        'department',
        d.department,
        i.department
    FROM inserted i
    JOIN deleted d ON i.employee_id = d.employee_id
    WHERE ISNULL(i.department, '') <> ISNULL(d.department, '');

    -- hire_date o‘zgarishini yozish
    INSERT INTO audit_log (employee_id, column_changed, old_value, new_value)
    SELECT 
        i.employee_id,
        'hire_date',
        CONVERT(VARCHAR, d.hire_date, 120),
        CONVERT(VARCHAR, i.hire_date, 120)
    FROM inserted i
    JOIN deleted d ON i.employee_id = d.employee_id
    WHERE i.hire_date <> d.hire_date;
END;



------8.	Har bir lavozim bo‘yicha ishga qabul tezligini aniqlang (interview → hire).

select
	p.department,
	avg(datediff(month, p.start_date, e.hire_date)) as hire_speed_month
from Positions p
JOIN employees e
ON e.employee_id=p.employee_id
group by p.department


----5. Xalqaro Savdo va Logistika (Import/Export)
----Jadvallar: shipments, customs, countries, goods, ports, invoices
----Tasklar:
----1.	Har bir mamlakatdan import va eksport qilinadigan tovarlar bo‘yicha statistika tuzing.
----2.	Eng uzoq vaqt bojxonada qolgan yuklarni aniqlang (arrival_date - release_date).
----3.	Har bir port bo‘yicha o‘rtacha o‘tkazilgan yuk miqdorini chiqaring.
----4.	Chegaradan o‘tgan, lekin hali bojxonadan chiqmagan yuklar ro‘yxatini toping.
----5.	Bir oy ichida eng ko‘p miqdordagi tranzitlar bo‘lgan yo‘nalishlarni toping.
----6.	Invoice'larda narx noto‘g‘ri (manfiy yoki 0) kiritilgan holatlarni topish uchun query yozing.
----7.	SQL Trigger: yangi yuk kelganda avtomatik quarantine statusini bersin.
----8.	Custom clearance muddati 10 kundan oshgan yuklar bo‘yicha ogohlantiruvchi report tuzing.

CREATE TABLE countries (
    country_id INT PRIMARY KEY,
    country_name VARCHAR(100)
);

INSERT INTO countries VALUES
(1, 'USA'),
(2, 'China'),
(3, 'Germany'),
(4, 'Uzbekistan');

-- =========================
-- 2. ports jadvali
-- =========================
CREATE TABLE ports (
    port_id INT PRIMARY KEY,
    port_name VARCHAR(100),
    country_id INT,
    FOREIGN KEY (country_id) REFERENCES countries(country_id)
);

INSERT INTO ports VALUES
(1, 'Los Angeles Port', 1),
(2, 'Shanghai Port', 2),
(3, 'Hamburg Port', 3),
(4, 'Tashkent Inland Port', 4);

-- =========================
-- 3. goods jadvali
-- =========================
CREATE TABLE goods (
    goods_id INT PRIMARY KEY,
    goods_name VARCHAR(100),
    unit VARCHAR(50)
);

INSERT INTO goods VALUES
(1, 'Electronics', 'tons'),
(2, 'Textiles', 'tons'),
(3, 'Vehicles', 'units'),
(4, 'Fruits', 'tons');

-- =========================
-- 4. shipments jadvali
-- =========================
CREATE TABLE shipments (
    shipment_id INT PRIMARY KEY,
    origin_country_id INT,
    destination_country_id INT,
    port_id INT,
    goods_id INT,
    quantity DECIMAL(10,2),
    arrival_date DATE,
    release_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (origin_country_id) REFERENCES countries(country_id),
    FOREIGN KEY (destination_country_id) REFERENCES countries(country_id),
    FOREIGN KEY (port_id) REFERENCES ports(port_id),
    FOREIGN KEY (goods_id) REFERENCES goods(goods_id)
);

INSERT INTO shipments VALUES
(1, 2, 1, 1, 1, 20.5, '2025-01-01', '2025-01-05', 'released'),
(2, 3, 4, 4, 2, 15.0, '2025-01-10', NULL, 'pending'),
(3, 1, 3, 3, 3, 10, '2025-01-15', '2025-02-01', 'released'),
(4, 2, 4, 4, 4, 25.5, '2025-02-01', NULL, 'pending');

-- =========================
-- 5. customs jadvali
-- =========================
CREATE TABLE customs (
    customs_id INT PRIMARY KEY,
    shipment_id INT,
    quarantine_status VARCHAR(50),
    clearance_date DATE,
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);

INSERT INTO customs VALUES
(1, 1, 'cleared', '2025-01-06'),
(2, 3, 'cleared', '2025-02-03');

-- =========================
-- 6. invoices jadvali
-- =========================
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY,
    shipment_id INT,
    invoice_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (shipment_id) REFERENCES shipments(shipment_id)
);

INSERT INTO invoices VALUES
(1, 1, '2025-01-02', 15000.00),
(2, 2, '2025-01-11', -500.00),  -- wrong invoice
(3, 3, '2025-01-16', 18000.00),
(4, 4, '2025-02-02', 0.00);      -- wrong invoice


----1.	Har bir mamlakatdan import va eksport qilinadigan tovarlar bo‘yicha statistika tuzing.

select 
	c.country_id,
	g.goods_name,
	c.country_name,
	s.goods_id,
	s.origin_country_id,
	s.destination_country_id
from 
countries c
LEFT JOIN shipments s
ON c.country_id=s.origin_country_id
JOIN goods g
ON g.goods_id=s.goods_id
order by country_id

----2.	Eng uzoq vaqt bojxonada qolgan yuklarni aniqlang (arrival_date - release_date).

select TOP 1
	g.goods_name,
	s.arrival_date, 
	s.release_date,
	datediff(day, arrival_date, release_date) as total_days
from shipments s
JOIN goods g
ON g.goods_id=s.goods_id
where s.arrival_date is not null and s.release_date is not null
order by total_days desc


----3.	Har bir port bo‘yicha o‘rtacha o‘tkazilgan yuk miqdorini chiqaring.

;with avg_port_goods as(
select 
	p.port_id,
	p.port_name,
	coalesce(avg(s.quantity), 0) as average_quantity
from ports p
left JOIN shipments s
ON s.port_id=p.port_id
group by p.port_id,
	p.port_name)
select * from avg_port_goods


----4.	Chegaradan o‘tgan, lekin hali bojxonadan chiqmagan yuklar ro‘yxatini toping.

select 
	g.goods_name
from shipments s
join goods g
on g.goods_id=s.goods_id
where s.status='pending';

----5.	Bir oy ichida eng ko‘p miqdordagi tranzitlar bo‘lgan yo‘nalishlarni toping.

select top 1
	c1.country_name as from_country,
	c1.country_name as to_country,
	count(s.shipment_id) as transit_count
from shipments s
JOIN countries c1
ON c1.country_id=s.origin_country_id
JOIN countries c2
ON c2.country_id=s.destination_country_id
where s.arrival_date between '2024-12-01' and '2025-01-02'
group by c1.country_name

----6.	Invoice'larda narx noto‘g‘ri (manfiy yoki 0) kiritilgan holatlarni topish uchun query yozing.

select 
	total_amount as wrong_input_amounts
from invoices
where total_amount <= 0

----7.	SQL Trigger: yangi yuk kelganda avtomatik quarantine statusini bersin.
go

CREATE TRIGGER trg_SetQuarantineStatus
ON shipments
AFTER INSERT
AS
BEGIN
    UPDATE s
    SET s.status = 'quarantine'
    FROM shipments s
    JOIN inserted i ON s.shipment_id = i.shipment_id;
END;
go


----8.	Custom clearance muddati 10 kundan oshgan yuklar bo‘yicha ogohlantiruvchi report tuzing.
select * from Customs

;with Report1 as(
select
	g.goods_name,
	s.shipment_id,
	clearance_date
from customs c
JOIN shipments s
ON c.shipment_id=s.shipment_id
JOIN goods g
ON g.goods_id=s.goods_id
),
 Report2 as(
 select shipment_id, goods_name,
	 case 
		when datediff(day, clearance_date, getdate())>10 then 'Warning !'
	 end as reminder
 from Report1
)

select * from Report2 







