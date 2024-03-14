/*
@sc23mas

This is an sql file to put your queries for SQL coursework. 
You can write your comment in sqlite with -- or /* * /

To read the sql and execute it in the sqlite, simply
type .read sqlcwk.sql on the terminal after sqlite3 musicstore.db.
*/

/* =====================================================
   WARNNIG: DO NOT REMOVE THE DROP VIEW
   Dropping existing views if exists
   =====================================================
*/
DROP VIEW IF EXISTS vNoCustomerEmployee; 
DROP VIEW IF EXISTS v10MostSoldMusicGenres; 
DROP VIEW IF EXISTS vTopAlbumEachGenre; 
DROP VIEW IF EXISTS v20TopSellingArtists; 
DROP VIEW IF EXISTS vTopCustomerEachGenre; 

/*
============================================================================
Task 1: Complete the query for vNoCustomerEmployee.
DO NOT REMOVE THE STATEMENT "CREATE VIEW vNoCustomerEmployee AS"
============================================================================
*/
CREATE VIEW vNoCustomerEmployee AS
SELECT
    employees.EmployeeId,
    employees.FirstName,
    employees.LastName,
    employees.Title
FROM employees
LEFT JOIN customers ON employees.EmployeeId = customers.SupportRepId
WHERE customers.SupportRepId IS NULL;


/*
============================================================================
Task 2: Complete the query for v10MostSoldMusicGenres
DO NOT REMOVE THE STATEMENT "CREATE VIEW v10MostSoldMusicGenres AS"
============================================================================
*/
CREATE VIEW v10MostSoldMusicGenres AS
SELECT
    genres.Name AS Genre,
    SUM(invoice_items.Quantity) AS Sales
FROM genres
INNER JOIN tracks ON genres.GenreId = tracks.GenreId
INNER JOIN invoice_items ON tracks.TrackId = invoice_items.TrackId
GROUP BY genres.Name
ORDER BY Sales DESC
LIMIT 10;


/*
============================================================================
Task 3: Complete the query for vTopAlbumEachGenre
DO NOT REMOVE THE STATEMENT "CREATE VIEW vTopAlbumEachGenre AS"
============================================================================
*/
CREATE VIEW vTopAlbumEachGenre AS
SELECT
    Genre,
    Album,
    Artist,
    Sales
FROM (
    SELECT
        genres.Name AS Genre,
        albums.Title AS Album,
        artists.Name AS Artist,
        SUM(invoice_items.Quantity) AS Sales,
        ROW_NUMBER() OVER (PARTITION BY genres.GenreId ORDER BY SUM(invoice_items.Quantity) DESC) AS Rank
    FROM invoice_items
    INNER JOIN tracks ON invoice_items.TrackId = tracks.TrackId
    INNER JOIN albums ON tracks.AlbumId = albums.AlbumId
    INNER JOIN artists ON albums.ArtistId = artists.ArtistId
    INNER JOIN genres ON tracks.GenreId = genres.GenreId
    GROUP BY genres.GenreId, albums.AlbumId
) AS RankedAlbums
WHERE Rank = 1;


/*
============================================================================
Task 4: Complete the query for v20TopSellingArtists
DO NOT REMOVE THE STATEMENT "CREATE VIEW v20TopSellingArtists AS"
============================================================================
*/

CREATE VIEW v20TopSellingArtists AS
SELECT
    artists.Name AS Artist,
    COUNT(DISTINCT albums.AlbumId) AS TotalAlbum,
    SUM(invoice_items.Quantity) AS TrackSold
FROM artists
INNER JOIN albums ON artists.ArtistId = albums.ArtistId
INNER JOIN tracks ON albums.AlbumId = tracks.AlbumId
INNER JOIN invoice_items ON tracks.TrackId = invoice_items.TrackId
GROUP BY artists.Name
ORDER BY TrackSold DESC
LIMIT 20;


/*
============================================================================
Task 5: Complete the query for vTopCustomerEachGenre
DO NOT REMOVE THE STATEMENT "CREATE VIEW vTopCustomerEachGenre AS" 
============================================================================
*/
CREATE VIEW vTopCustomerEachGenre AS
SELECT
    Genre,
    CustomerName,
    TotalSpending
FROM (
    SELECT
        genres.Name AS Genre,
        customers.FirstName || ' ' || customers.LastName AS CustomerName,
        ROUND(SUM(invoice_items.Quantity * invoice_items.UnitPrice), 2) AS TotalSpending,
        ROW_NUMBER() OVER (PARTITION BY genres.GenreId ORDER BY SUM(invoice_items.Quantity * invoice_items.UnitPrice) DESC) AS Rank
    FROM invoice_items
    INNER JOIN tracks ON invoice_items.TrackId = tracks.TrackId
    INNER JOIN genres ON tracks.GenreId = genres.GenreId
    INNER JOIN invoices ON invoice_items.InvoiceId = invoices.InvoiceId
    INNER JOIN customers ON invoices.CustomerId = customers.CustomerId
    GROUP BY genres.GenreId, customers.CustomerId
) AS SpendingRank
WHERE Rank = 1
ORDER BY Genre ASC;

