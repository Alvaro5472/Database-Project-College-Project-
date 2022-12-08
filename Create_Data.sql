CREATE DATABASE UniDlox
GO
USE UniDlox
GO
CREATE TABLE MsCustomer(
	CustomerID			CHAR(5) PRIMARY KEY CHECK(CustomerID LIKE ('CU[0-9][0-9][0-9]')),
	CustomerName		VARCHAR(255),
	CustomerPhoneNumber	VARCHAR(15),
	CustomerAddress		VARCHAR(255),
	CustomerGender		VARCHAR(6) CHECK(CustomerGender IN ('Male', 'Female')),
	CustomerEmail		VARCHAR(255) CHECK(CustomerEmail LIKE ('%@gmail.com') OR CustomerEmail LIKE ('%@yahoo.com')),
	CustomerDOB			DATE
)
GO
CREATE TABLE MsCloth(
	ClothID				CHAR(5) PRIMARY KEY CHECK(ClothID LIKE ('CL[0-9][0-9][0-9]')),
	ClothName			VARCHAR(255) NOT NULL,
	ClothStock			INT NOT NULL CHECK(ClothStock BETWEEN 0 AND 250),
	ClothPrice			FLOAT NOT NULL
)
GO
CREATE TABLE MsStaff(
	StaffID				CHAR(5) PRIMARY KEY CHECK(StaffID LIKE ('SF[0-9][0-9][0-9]')),
	StaffName			VARCHAR(255),
	StaffPhoneNumber	VARCHAR(15),
	StaffAddress		VARCHAR(15) CHECK(LEN(StaffAddress) BETWEEN 10 AND 15),
	StaffAge			INT,
	StaffGender			VARCHAR(6) CHECK(StaffGender IN ('Male', 'Female')),
	StaffSalary			FLOAT
)
GO
CREATE TABLE MsSupplier(
	SupplierID			CHAR(5) PRIMARY KEY CHECK(SupplierID LIKE ('SU[0-9][0-9][0-9]')),
	SupplierName		VARCHAR(255) CHECK(LEN(SupplierName) > 6),
	SupplierPhoneNumber	VARCHAR(15),
	SupplierAddress		VARCHAR(255)
)
GO
CREATE TABLE MsMaterial(
	MaterialID			CHAR(5) PRIMARY KEY CHECK(MaterialID LIKE ('MA[0-9][0-9][0-9]')),
	MaterialName		VARCHAR(255) NOT NULL,
	MaterialPrice		FLOAT NOT NULL CHECK (MaterialPrice > 0)
)
GO
CREATE TABLE MsPaymentType(
	PaymentTypeID		CHAR(5) PRIMARY KEY CHECK(PaymentTypeID LIKE ('PA[0-9][0-9][0-9]')),
	PaymentType			VARCHAR(20) NOT NULL
)
GO
CREATE TABLE SalesHeader(
	SalesID				CHAR(5) PRIMARY KEY CHECK(SalesID LIKE ('SA[0-9][0-9][0-9]')),
	StaffID				CHAR(5) FOREIGN KEY REFERENCES MsStaff(StaffID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	CustomerID			CHAR(5) FOREIGN KEY REFERENCES MsCustomer(CustomerID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	PaymentTypeID		CHAR(5) FOREIGN KEY REFERENCES MsPaymentType(PaymentTypeID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	SalesDate			DATE NOT NULL
)
GO
CREATE TABLE SalesDetail(
	ClothID				CHAR(5) FOREIGN KEY REFERENCES MsCloth(ClothID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	SalesID				CHAR(5) FOREIGN KEY REFERENCES SalesHeader(SalesID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	SalesQuantity		INT NOT NULL,
	PRIMARY KEY(ClothID,SalesID)
)
GO
CREATE TABLE PurchaseHeader(
	PurchaseID			CHAR(5) PRIMARY KEY CHECK(PurchaseID LIKE ('PU[0-9][0-9][0-9]')),
	StaffID				CHAR(5) FOREIGN KEY REFERENCES MsStaff(StaffID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	SupplierID			CHAR(5) FOREIGN KEY REFERENCES MsSupplier(SupplierID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	PaymentTypeID		CHAR(5) FOREIGN KEY REFERENCES MsPaymentType(PaymentTypeID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	PurchaseDate		DATE NOT NULL
)
GO
CREATE TABLE PurchaseDetail(
	MaterialID			CHAR(5) FOREIGN KEY REFERENCES MsMaterial(MaterialID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	PurchaseID			CHAR(5) FOREIGN KEY REFERENCES PurchaseHeader(PurchaseID) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	PurchaseQuantity	INT NOT NULL,
	PRIMARY KEY(MaterialID, PurchaseID)
)
GO