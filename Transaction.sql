--purchase transaction process
INSERT INTO PurchaseHeader VALUES ('PU016','SF005','SU001','PA005','2021-12-29')
INSERT INTO PurchaseDetail VALUES 
('MA009','PU016',13),
('MA007','PU016',15)

--sales transaction process
INSERT INTO MsCustomer VALUES ('CU011','Alvaro Maldini','087845670684','Bukit tinggi 13 Blok 3 no 2','Male','alvaromldn@gmail.com','2003-02-11')
INSERT INTO SalesHeader VALUES ('SA017','SF011','CU011','PA006','2021-12-30')
INSERT INTO SalesDetail VALUES 
('CL010','SA017',5),
('CL009','SA017',3)
