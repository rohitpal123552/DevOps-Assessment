-- Index for the "last 30 days by city" report query.
--   city        -> equality filter, so it goes first
--   created_at  -> range filter, so it goes second
--   INCLUDE     -> org_id, status and amount are stored in the index leaf pages
--                  so Postgres can answer the query from the index alone
--                  (index-only scan) without visiting the table.
CREATE INDEX idx_hotel_bookings_city_created_at
    ON hotel_bookings (city, created_at)
    INCLUDE (org_id, status, amount);
