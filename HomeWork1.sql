-- 1. Добавить новый учебный курс в таблице Course.

SELECT *
FROM Course
WHERE CourseId IN (500)
GO

INSERT INTO Course (CourseId, Code, Title, [Description], Amount, [Status], CreateDate)
Values (500, 'KT500', 'QA Automation', 'Вы узнаете основы ООП, Вы научитесь пользоваться основной библиотекой языка Java и получите навыки автоматизации тестирования Selenium.', 6000, 'A', CURRENT_TIMESTAMP)
GO

/* 2. Добавить описание новосозданного курса (п.1.) в таблице CourseContent (минимум 3 записи). 
Предварительно проанализируйте таблицы, посмотрите как на текущих данных выполнено наполнение таблиц. 
*/

SELECT *
FROM CourseContent
WHERE CourseId = 500
GO

INSERT INTO CourseContent (CourseId, Chapter, ContentType, Title, [Description])
Values (500, 1, 'UN', 'Введение в автоматизацию', 'Тестирование и автоматизация. В чем разница?')
GO

INSERT INTO CourseContent (CourseId, Chapter, ContentType, Title, [Description])
Values (500, 1, 'CH', 'Знакомство с Java', 'Как работает Java')
GO

INSERT INTO CourseContent (CourseId, Chapter, ContentType, Title, [Description])
Values (500, 1, 'CH', 'Учимся программировать', 'Основы ООП')
GO

/* 
3. Добавить новую учебную группу в таблице UserGroup (проанализировать связи таблиц Course и UserGroup.
Используйте скрипт 2-Create_Tables.sql и диаграмму БД для изучения связей).
*/

SELECT *
FROM UserGroup
WHERE CourseId = 500
GO

INSERT INTO UserGroup (CourseId, [Name], CreateDate, UpdateDate, [Status]) 
SELECT c.CourseId, 'Группа №5. Группа выходного дня. Старт 28.12.2021', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, c.[Status]
FROM Course c
WHERE c.CourseId = 500
GO

-- 4. Добавить 2 новых пользователя в таблицу UserData со статусом 'D' и параметром 0 и 1.

SELECT *
FROM UserData
WHERE [Login] IN ('pupkin123', 'ivan123')
GO

INSERT INTO UserData ([Login], [Password], FirstName, MiddleName, LastName, CreateDate, UpdateDate, [Status], Parameter)
VALUES ('pupkin123', 'abcd', 'Александр', 'Александрович', 'Пупкин', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'D', 0)
GO

INSERT INTO UserData ([Login], [Password], FirstName, MiddleName, LastName, CreateDate, UpdateDate, [Status], Parameter)
VALUES ('ivan123', '123abcd', 'Иван', 'Иванович', 'Иванов', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'D', 1)
GO


-- 5. Добавить еще 2 пользователя в таблицу UserData с другим допустимым статусом и параметром 0 и 1.

SELECT *
FROM UserData
WHERE [Login] IN ('pete123', 'kate123')
GO

INSERT INTO UserData ([Login], [Password], FirstName, MiddleName, LastName, CreateDate, UpdateDate, [Status], Parameter)
VALUES ('pete123', '456abcd', 'Петр', 'Викторович', 'Великий', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'A', 0)
GO

INSERT INTO UserData ([Login], [Password], FirstName, MiddleName, LastName, CreateDate, UpdateDate, [Status], Parameter)
VALUES ('kate123', '789abcd', 'Екатерина', 'Евгениевна', 'Вторая', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'A', 1)
GO


/*
6. Изменить статус  на 'активный' для своих новосозданных пользователей у которых статус 'D'. 
Изменить параметр на 1 для своих новосозданных пользователей у которых параметр 0.
Также изменить дату с поле  UpdateDate через функцию CURRENT_TIMESTAMP только для своих пользователей
у которых производились изменения статуса и параметра.
Постараться этот пункт сделать одним запросом.
*/

SELECT *
FROM UserData
WHERE [Login] IN ('pupkin123', 'ivan123', 'pete123')
GO

UPDATE UserData set Status = 'A', Parameter = 1, UpdateDate = CURRENT_TIMESTAMP
WHERE Login IN ('pupkin123', 'ivan123', 'pete123')
GO

/*
7. Связать своих 4-х новых пользователей с группой (связь данных с таблиц UserGroup и UserData через таблицу UserGroupLink).
Для определения идентификатора пользователя, постарайтесь научиться использовать функцию getUserId.
Пример ее использования есть в скрипте 3 - Insert_Tables.sql при вставке в таблицу "[UserRoleLink] inserts".
Функция, это универсальный механизм, вам не придется вручную прописывать идентификатор пользователя, 
который у вас и у меня может отличаться.
*/

SELECT * 
FROM UserGroupLink
GO

INSERT INTO UserGroupLink (UserGroupId, UserDataId)
SELECT (SELECT g.UserGroupId
         FROM UserGroup g
		 WHERE g.CourseId = 500), (SELECT * FROM getUserId ('pupkin123'))       
UNION
SELECT (SELECT g.UserGroupId
         FROM UserGroup g
		 WHERE g.CourseId = 500), (SELECT * FROM getUserId ('ivan123'))  
UNION
SELECT (SELECT g.UserGroupId
         FROM UserGroup g
		 WHERE g.CourseId = 500), (SELECT * FROM getUserId ('pete123')) 
UNION
SELECT (SELECT g.UserGroupId
         FROM UserGroup g
		 WHERE g.CourseId = 500), (SELECT * FROM getUserId ('kate123'))
GO



/*
8. Выбрать всех пользователей из СВОЕЙ ГРУППЫ и своего КУРСА, отсортировав по имени пользователя (FirstName). 
Вывести только эти колонки: Login, FirstName, MiddleName, LastName, [Name] as GroupName (колонка с таблицы UserGroup), 
Title (таблица Course).
Ожидаю получить SELECT в секции FROM которого будет написано 4 таблицы (UserData, UserGroupLink, UserGroup, Course), 
далее в условии WHERE и AND необходимо связать эти таблицы по корректным идентификаторам таблиц.
Так же написать дополнительное условие фильтрации (AND) по названию новой группы, 
что бы вывести только своих 4-х студентов со своей группы.
Сортировка, это дополнительное условие в самом конце выборки: ORDER BY FirstName.
*/


SELECT ud.[Login], ud.FirstName, ud.MiddleName, ud.LastName, ug.[Name] as GroupName, c.Title
FROM Course c
				INNER JOIN UserGroup ug ON ug.CourseId = c.CourseId
				INNER JOIN UserGroupLink ugl ON ug.UserGroupId = ugl.UserGroupId
                INNER JOIN UserData ud ON ud.UserDataId = ugl.UserDataId
WHERE c.Code = 'KT500' ORDER BY FirstName
GO



/*
9. Удалить своих пользователей с БД, созданную группу и описатели курса и курс. 
Нужно будет проделать работу в  обратном порядке. Просто так пользователя удалить не получится, 
потому что он будет связан с новосозданной группой.
Выполняйте удаление по Login с таблицы UserData. Это поле уникально и удалится только тот пользователь, 
которого вы напишете в условии WHERE Login  = 'логин пользователя' или через IN ('','','') указав перечень логинов пользователей.
Так же можно использовать функцию, на ваше усмотрение.
*/


SELECT *  --1
FROM UserData
GO

DELETE 
FROM UserGroupLink
WHERE UserDataId in (select UserDataId
                     from UserData
					 where Login IN ('pupkin123', 'ivan123', 'pete123', 'kate123'))
GO

SELECT * --2
FROM UserData
GO

DELETE 
FROM UserData
WHERE Login IN ('pupkin123', 'ivan123', 'pete123', 'kate123')
GO

SELECT * --3
FROM UserGroup
GO

DELETE 
FROM UserGroup 
WHERE CourseId = '500'
GO

SELECT * --4 
FROM Course
GO

DELETE 
FROM Course 
WHERE CourseId IN ('500', '501', '502', '503' )
GO



--Практика написания запросов.

/*1. Найти документы в таблице Payment, где сумма (Amount)  больше равна 26024.92.
*/

Select*
FROM Payment AS p
WHERE p.Amount >= 26024.92
GO

/*2. Найти документы в таблице Payment, где назначение платежа (TXT) имеет слово 'рахунок' в любом сегменте строки,
И валюта (Currency) документов может быть '978', '980'.
*/

Select*
FROM Payment AS p
WHERE p.TXT LIKE '%рахунок%'
AND p.Currency IN ('978', '980')
GO

/*3. Найти документы в таблице Payment, где дата документа между 2010-02-11 и 2011-05-22, 
и валюта документов НЕ равна 980.
*/

Select*
FROM Payment AS p
WHERE p.Data_doc BETWEEN '2010-02-11' AND '2011-05-22'
AND p.Currency <> '980'
GO

/*4. Найти документы в таблице Payment, где Дебет счета (DebAcc) может иметь  такие счета 
'260070001','260088791','260006443', Статус '+' и валюта НЕ 980.
*/


Select*
FROM Payment AS p
WHERE p.DebAcc IN (260070001, 260088791, 260006443)
AND p.[Status] = '+'
AND p.Currency <> '980'
GO

/*5. Найти документы в таблице Payment, где Дебет счета (DebAcc) может иметь  такие счета 
'260070001','260088791','260006443'. 
При этом вывести сумму каждого документа Amount умноженную на 3 и от этой суммы отнять 1000.
*/

SELECT*, (p.Amount * 3) - 1000 AS 'Sum'
FROM Payment AS p
WHERE p.DebAcc IN (260070001, 260088791, 260006443)
GO


/*6. Вывести счета с таблицы Account, где "(" Status равен 'O' И дата открытия OpenDate равна 2016-01-21 ")" 
ИЛИ дата закрытия CloseDate явяется НЕ NULL. Здесь обратите внимание на скобки в условии.*/

SELECT *
FROM Account AS a
WHERE (a.Status = 'O' AND a.OpenDate = '2016-01-21')
OR a.CloseDate IS NOT NULL
GO

/*7. Вывести счета с таблицы Account, где Status равен 'O' И "(" дата открытия OpenDate равна 2016-01-21
ИЛИ дата закрытия CloseDate явяется НЕ NULL ")". Здесь обратите внимание на скобки в условии.*/

SELECT *
FROM Account AS a
WHERE a.OpenDate = '2016-01-21' OR a.CloseDate IS NOT NULL
AND a.Status = 'O'
GO


/* 8. Вывести пользователей с таблицы Customer и Salary, у которых ДР '1977-09-26', 
получал Бонус и дата ЗП между '2019-03-31' и '2019-09-30'..*/

SELECT *
FROM Customer AS c INNER JOIN Salary AS s ON c.Cust_Id = s.Cust_Id
WHERE c.Birthday = '1977-09-26'
      AND s.Bonus IS NOT NULL
	  AND s.[Date] BETWEEN '2019-03-31' AND '2019-09-30'
GO

/* 9. Вывести информацию о пользователях и его счетах с таблиц Customer и Account, где:
	- Клиенты нерезиденты
	- Счет начинается на 2650
	вторая часть выборки
	- Клиенты нерезиденты
	- Код валюты 980.
Подсказка: между запросами использовать UNION или UNION ALL, но что бы выводимые строки не дублировались 
(попрактикуйте с этим оператором соединения). 
Поля для вывода такие: CustomerLogin, NameUser, Resident, Country, Gender, Account, Currency, [Status], OpenDate
Отсортировать по дате открытия счета в обратном порядке */


SELECT  c.CustomerLogin, c.NameUser, c.Resident, c.Country, c.Gender, a.Account,
        a.Currency, a.[Status], a.OpenDate
FROM Customer AS c INNER JOIN Account AS a 
ON c.Cust_Id = a.Cust_Id
WHERE c.Resident = 'N' AND a.Account LIKE '2650%'
UNION 
SELECT  c.CustomerLogin, c.NameUser, c.Resident, c.Country, 
        c.Gender, a.Account, a.Currency, a.[Status], a.OpenDate
FROM Customer AS c INNER JOIN Account AS a 
ON c.Cust_Id = a.Cust_Id
WHERE c.Resident = 'N' AND a.Currency = 980
ORDER BY a.OpenDate DESC
GO

/* 10. Выбрать тех клиентов, у которых была сумма ЗП но без бонусов и при этом они ниразу 
не были оштрафованы, и статус клиента Открыт.*/


Select *
FROM Salary AS s 
		LEFT JOIN Penalty AS p ON s.Cust_Id = p.CustomerId
		LEFT JOIN Customer AS c ON s.Cust_Id = c.Cust_Id
WHERE c.[Status] = 'O' AND p.CustomerId IS NULL AND s.Bonus IS NULL 
GO

/*11. Задача про "Алкоголика".
Найти платежи, назначение платежа которых имеет фрагмент слова "алког" 
(в любом сегменте назначения платежа).
Дебет DebAcc счета этих платежей использовать для поиска/связи счета в таблице счетов Account.
А с таблицы Account сделать связь на клиента-владельца с таблицы Customer.	
Вывести только поле NameUser.*/


SELECT NameUser
FROM Account AS a
INNER JOIN Payment AS p ON p.DebAcc = a.Account
INNER JOIN Customer AS c ON a.Cust_Id = c.Cust_Id
WHERE TXT LIKE '%алког%' AND c.[Status] = 'O'
GO