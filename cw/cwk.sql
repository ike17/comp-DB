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
