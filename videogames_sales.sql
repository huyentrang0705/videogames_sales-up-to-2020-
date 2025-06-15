SELECT TOP (1000) [Rank]
      ,[Name]
      ,[Platform]
      ,[Year]
      ,[Genre]
      ,[Publisher]
      ,[NA_Sale]
      ,[EU_Sales]
      ,[JP_Sales]
      ,[Other_Sales]
      ,[Global_Sales]
  FROM [portforlio].[dbo].[videogames_sales]
  
--Đổi kiểu dữ liệu
ALTER TABLE videogames_sales
	ALTER COLUMN Rank INT;
ALTER TABLE videogames_sales
	ALTER COLUMN NA_Sale float;
ALTER TABLE videogames_sales
	ALTER COLUMN EU_Sales float;
ALTER TABLE videogames_sales
	ALTER COLUMN JP_Sales float;
ALTER TABLE videogames_sales
	ALTER COLUMN Other_Sales float;
ALTER TABLE videogames_sales
	ALTER COLUMN Global_Sales float;
--Loại bỏ các dòng có giá trị null, missing
delete from videogames_sales
where platform is null;

delete from videogames_sales
where year is null;

delete from videogames_sales
where genre is null;

delete from videogames_sales
where global_sales is null;
--Xem toàn bộ dữ liệu
select *
from videogames_sales;

/*Phân tích*/
--Nhóm các tựa game theo các nền tảng 
	select platform, count(*) as Quantity
	from videogames_sales
	group by platform
	order by count(*) desc;
--> 31 nền tảng, trong đó nền tảng DS có nhiều video game nhất 

--Nhóm các game trong genre 
	select genre, count(*) as Quantity_genre
	from videogames_sales
	group by genre
	order by count(*) desc;
--> 12 thể loại game, trong đó thể loại sport có nhiều video game nhất

/*Phân tích */
-- 1. Nhà phát hành có doanh số toàn cầu cao nhất
	select publisher,  sum(global_sales) as global_total
	from videogames_sales
	group by publisher
	order by sum(global_sales) desc;
--> Nintendo có doanh thu toàn cầu cao nhất. Đứng thứ hai là Electronic Arts
-- 1.1. Phân tích thêm về Nintendo
  --Các thể loại game, tựa game, doanh thu từng nơi cụ thể
	select *
	from videogames_sales
	where publisher like 'Nintendo'
	order by global_sales desc;
	--> doanh thu toàn cầu cao nhất vào năm 2006 với thể loại game sports
  --Xu hướng gần đây? 
	select *
	from videogames_sales
	where publisher like 'Nintendo'
	order by year desc;
	--> doanh thu toàn cầu ko cao, với thể loại game strategy
--> Hướng giải quyết?

/*Phân tích về Electronic Arts để thấy sự khác biệt */
	select *
	from videogames_sales
	where publisher like 'Electronic Arts'
	order by global_sales desc;
--> xu hướng gần đây sản xuất sports (năm 2015)
--> Nintendo có thể cân nhắc về việc đầu tư phát hành thêm về Sports. Ngoài ra, Sports cũng đứng vị trí đầu--> thu hút mạnh mẽ

--2. Thể loại game nào bán chạy nhất toàn cầu
	select genre, sum(Global_Sales) as global_total
	from videogames_sales
	where year between 2015 and 2020
	group by genre 
	order by sum(global_sales) desc;
--> Action là thể loại game bán chạy nhất, ngay sau là sports

--Cụ thể xu hướng gần đây của 2 thể loại
	select *
	from videogames_sales
	where genre like 'Action'
	order by year desc;
--> doanh thu ko cao
	select *
	from videogames_sales
	where genre like 'Sports'
	order by year desc;
--> doanh thu cao hơn nhiều so với action --> đang phát triển

--3. Nền tảng có doanh thu cao  nhất
	select year, platform, sum(global_sales) as global_total
	from videogames_sales
	group by year, platform 
	order by sum(global_sales) desc;
--> Không có nhiều tựa game nhất nhưng PS2 có doanh thu toàn cầu cao nhất
	select year, platform, count(*) as quantity
	from videogames_sales
	group by year, platform 
	order by year  desc;
--> Tuy nhiên xu hướng gần đây, các tựa game được phát hành trên các nền tảng khác

--4. Doanh thu của trên các thị trường theo các nền tảng và theo năm
	select platform, year, sum(na_sale) as na_total,
		sum(eu_sales) as eu_total,
		sum(jp_sales) as jp_total,
		sum(other_sales) as other_total,
		sum(global_sales) as global_total,
		dense_rank() over(partition by platform order by sum(global_sales) desc) as rank
	from videogames_sales
	group by year, platform 
	order by year desc;	
--> doanh thu bán game những năm gần đây không cao, với doanh thu các thị trường biến động

--5. Thị trường tiềm năng
	select year, sum(na_sale) as na_total,
		sum(eu_sales) as eu_total,
		sum(jp_sales) as jp_total,
		sum(other_sales) as other_total
	from videogames_sales
	where year between 2015 and 2020
	group by year 
	order by year desc;
-->gần đây, doanh thu bán game giảm sút nghiêm trọng, na là thị trường có tiềm năng hơn.

--Số lượng tựa game theo thể loại và trong trên mỗi nền tảng theo năm
	select year, platform, genre, count(*) as quantity
	from videogames_sales
	group by year, platform, genre
	order by year desc;
--> so với những năm trước các tựa game ra mắt ít hơn rất nhiều --> có thể là nguyên nhân giảm doanh thu

--Phân tích về na
--Theo thể loại game
	select genre, sum(na_sale) as na_sale_total
	from videogames_sales
	group by genre 
	order by sum(na_sale) desc;
--> thể loại game action bán chạy nhất ở na trong suốt giai đoạn

--Theo năm và thể loại
	select year, genre, sum(na_sale) as na_sale_total
	from videogames_sales
	group by year, genre 
	order by year desc;
--> tuy nhiên gần đây năm 2020, tình hình bán game ở na lại không quá khả quan

--Xu hướng hiện tại tại na
	select rank, name, year, platform, genre, na_sale
	from videogames_sales
	where year >= 2017;
--> thể loại game action chỉ có 1 tựa game được phát hành --> doanh thu không có
--simulation có doanh thu nhưng không cao.

/*Kết luận
-Các nhà phát hành nên cân nhắc đa dạng các tựa game trong cùng 1 thể loại.
-Thể loại game có doanh thu cao là Action và Sports
-Doanh thu tại các thị trường đang giảm mạnh, cần tập trung tìm hiểu nguyên nhân khác ngoài số lượng game ít: giao diện, 
trải nghiệm,..
-Nền tảng PS2 có doanh thu toàn cầu cao nhất, tuy nhiên gần đây các tựa game phát hành trên các nền tảng khác
--> cần xem xét lại nền tảng ra mắt game
-Thị trường NA tuy vẫn có doanh thu nhưng không khả quan, cần đưa ra các giải pháp cụ thể
*/

