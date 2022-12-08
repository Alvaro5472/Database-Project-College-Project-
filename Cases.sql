USE UniDlox
GO
-- 1.
SELECT mst.StaffId, mst.StaffName, mst.StaffAddress, msu.SupplierName, COUNT(PurchaseId) AS [Total Purchases]
FROM MsStaff mst
JOIN PurchaseHeader ph ON mst.StaffId = ph.StaffId
JOIN MsSupplier msu ON ph.SupplierId = msu.SupplierId
WHERE MONTH(ph.PurchaseDate) = 11
AND RIGHT(mst.StaffId, 1) % 2 = 0
GROUP BY mst.StaffId, mst.StaffName, mst.StaffAddress, msu.SupplierName 

-- 2.
SELECT sh.SalesId, mcu.CustomerName, SUM(mcl.ClothPrice*sd.SalesQuantity) AS [Total Sales Price]
FROM SalesHeader sh
JOIN MsCustomer mcu ON sh.CustomerID = mcu.CustomerID
JOIN SalesDetail sd ON sh.SalesID = sd.SalesID
JOIN MsCloth mcl ON sd.ClothID = mcl.ClothID
WHERE CustomerName LIKE ('%m%')
GROUP BY sh.SalesId, CustomerName
HAVING SUM(ClothPrice*SalesQuantity) > 2000000

-- 3.
SELECT DATENAME(m,ph.PurchaseDate) AS [Month], COUNT(pd.PurchaseID) AS [Transaction Count], SUM(pd.PurchaseQuantity) AS [Material Sold Count]
FROM PurchaseHeader ph
JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID
JOIN MsStaff ms ON ph.StaffID = ms.StaffID
JOIN MsMaterial mm ON pd.MaterialID = mm.MaterialID
WHERE ms.StaffAge BETWEEN 25 AND 30
AND mm.MaterialPrice > 150000
GROUP BY DATENAME(m,ph.PurchaseDate)

-- 4.
SELECT LOWER(CustomerName) AS [CustomerName], CustomerEmail, CustomerAddress, 
	COUNT(SalesQuantity) AS [Cloth Bought Count], CONCAT('IDR ',SUM(SalesQuantity*CONVERT(int,ClothPrice))) AS [Total Price]
FROM MsCustomer mcu
JOIN SalesHeader sh ON mcu.CustomerID=sh.CustomerID
JOIN SalesDetail sd ON sd.SalesID=sh.SalesID
JOIN MsCloth mcl ON sd.ClothID=mcl.ClothID
JOIN MsPaymentType mpt ON sh.PaymentTypeID=mpt.PaymentTypeID
WHERE mpt.PaymentType IN ('Cryptocurrency','Cash','Shopee-Pay')
GROUP BY mcu.CustomerName, mcu.CustomerEmail, mcu.CustomerAddress



--	5.
SELECT RIGHT(PurchaseID,3) AS [PurchaseID], PurchaseDate, StaffName, PaymentType AS [PaymentTypeName]
FROM PurchaseHeader ph
JOIN MsStaff ms ON ph.StaffID=ms.StaffID
JOIN MsPaymentType mpt ON ph.PaymentTypeID=mpt.PaymentTypeID
WHERE ms.StaffID IN(
	SELECT ms.StaffID
	FROM MsStaff ms
	WHERE ms.StaffGender LIKE 'Female' AND
	ms.StaffSalary > (
	SELECT AVG(ms.StaffSalary)
	FROM MsStaff ms
	WHERE ms.StaffAge > YEAR(GETDATE())-1996
	)
) 

--	6.
SELECT SalesID, CONVERT(NVARCHAR, SalesDate, 107) AS SalesDate, CustomerName, CustomerGender
FROM 
(
	SELECT sd.SalesID, sh.SalesDate, SUM(SalesQuantity) AS 'SalesQuantity', mcu.CustomerName, mcu.CustomerGender
	FROM SalesDetail sd
	JOIN SalesHeader sh
	ON sd.SalesID = sh.SalesID
	JOIN MsCustomer mcu
	ON sh.CustomerID = mcu.CustomerID
	GROUP BY sd.SalesID, sh.SalesDate, mcu.CustomerName, mcu.CustomerGender
	HAVING SUM(sd.SalesQuantity) < 
	(
		SELECT MIN(sd.SalesQuantity)
		FROM SalesDetail sd
		JOIN SalesHeader sh ON sd.SalesID=sh.SalesID
		WHERE DAY(sh.SalesDate)= 15
	)
) AS tabQuery

-- 7.
SELECT pd.PurchaseID, SupplierName, CONCAT('+62', RIGHT(SupplierPhoneNumber, LEN(SupplierPhoneNumber)-1)) AS 'SupplierPhoneNumber', DATENAME(WEEKDAY, PurchaseDate) AS 'PurchaseDate', PurchaseQuantity
FROM PurchaseDetail pd
JOIN PurchaseHeader ph
ON pd.PurchaseID = ph.PurchaseID--SupplierPhoneNumber
JOIN MsSupplier ms
ON ph.SupplierID = ms.SupplierID
WHERE pd.PurchaseQuantity > 
(
	SELECT AVG(PurchaseQuantity)
	FROM PurchaseDetail
)
AND ((DATEPART(WEEKDAY, PurchaseDate) >= 6 AND DATEPART(WEEKDAY, PurchaseDate) <= 7) OR DATEPART(WEEKDAY, PurchaseDate) = 1)
ORDER BY PurchaseQuantity

-- 8.
SELECT CASE WHEN CustomerGender = 'Male' THEN CONCAT('Mr. ', CustomerName) ELSE CONCAT('Mrs. ', CustomerName) END AS 'CustomerName', mc.CustomerPhoneNumber, mc.CustomerAddress, CONVERT(VARCHAR, mc.CustomerDOB, 103) AS 'CustomerDOB', SUM(SalesQuantity) AS 'Cloth Count'
FROM SalesDetail sd
JOIN SalesHeader sh
ON sd.SalesID = sh.SalesID
JOIN MsCustomer mc
ON sh.CustomerID = mc.CustomerID
WHERE CustomerName LIKE '%o%' 
GROUP BY mc.CustomerID, mc.CustomerName, mc.CustomerPhoneNumber, mc.CustomerAddress, mc.CustomerDOB, mc.CustomerGender
HAVING SUM(SalesQuantity) = 
(
	SELECT TOP 1 SUM(SalesQuantity)
	FROM SalesDetail sd
	JOIN SalesHeader sh
	ON sd.SalesID = sh.SalesID
	JOIN MsCustomer mc
	ON sh.CustomerID = mc.CustomerID
	GROUP BY mc.CustomerID, mc.CustomerName, mc.CustomerPhoneNumber, mc.CustomerAddress, mc.CustomerDOB
	ORDER BY SUM(SalesQuantity) DESC
)

-- 9.
GO
CREATE VIEW ViewCustomerTransaction AS
SELECT CustomerID, CustomerName, CustomerEmail, CustomerDOB, MAX(SalesQuantity) AS 'Maximum Quantity', MIN(SalesQuantity) AS 'Minimum Quantity'
FROM
(
	SELECT mc.CustomerID, CustomerName, mc.CustomerEmail, mc.CustomerDOB, mc.CustomerGender, SUM(SalesQuantity) AS 'SalesQuantity'
	FROM SalesDetail sd
	JOIN SalesHeader sh
	ON sd.SalesID = sh.SalesID
	JOIN MsCustomer mc
	ON mc.CustomerID = sh.CustomerID
	WHERE YEAR(mc.CustomerDOB) >= 2000 AND mc.CustomerEmail LIKE '%@yahoo.com'
	GROUP BY sd.SalesID, mc.CustomerID, mc.CustomerName, mc.CustomerEmail, mc.CustomerDOB, mc.CustomerGender
) tab
GROUP BY tab.CustomerID, CustomerName, CustomerEmail, CustomerDOB, CustomerGender
GO

-- 10.
GO
CREATE VIEW FemaleStaffTransaction AS
SELECT mst.StaffId, UPPER(mst.StaffName) AS [StaffName], CONCAT('Rp.',CONVERT(INT,mst.StaffSalary), ',00') AS [StaffSalary], CONCAT(SUM(PurchaseQuantity), ' Pc(s)') AS [Material Bought Count]
FROM MsStaff mst
JOIN PurchaseHeader ph ON mst.StaffID = ph.StaffID
JOIN PurchaseDetail pd ON ph.PurchaseID = pd.PurchaseID
WHERE StaffGender LIKE 'Female'
AND StaffSalary>(SELECT AVG(StaffSalary) FROM MsStaff)
GROUP BY mst.StaffId, mst.StaffName, mst.StaffSalary
GO

