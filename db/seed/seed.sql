-- Seed data: 100 bookings, 5 orgs, 6 cities, 4 statuses, events for every booking.
-- 'delhi' appears twice in the city list so it gets more rows than the others.

INSERT INTO hotel_bookings
    (id, org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
SELECT
    gen_random_uuid(),
    s.org_id,
    s.hotel_id,
    s.city,
    s.checkin,
    s.checkin + s.nights,
    s.amount,
    s.status,
    s.created_at
FROM (
    SELECT
        (ARRAY[
            'aaaaaaaa-0000-0000-0000-000000000001',
            'aaaaaaaa-0000-0000-0000-000000000002',
            'aaaaaaaa-0000-0000-0000-000000000003',
            'aaaaaaaa-0000-0000-0000-000000000004',
            'aaaaaaaa-0000-0000-0000-000000000005'
        ]::uuid[])[1 + floor(random() * 5)::int] AS org_id,
        'hotel_' || (1 + floor(random() * 15)::int) AS hotel_id,
        (ARRAY['delhi','delhi','mumbai','bangalore','jaipur','goa','chennai'])[1 + floor(random() * 7)::int] AS city,
        (CURRENT_DATE + (floor(random() * 60)::int - 20)) AS checkin,
        (1 + floor(random() * 6)::int) AS nights,
        round((1500 + random() * 28500)::numeric, 2) AS amount,
        (ARRAY['confirmed','confirmed','confirmed','pending','cancelled','completed'])[1 + floor(random() * 6)::int] AS status,
        (NOW() - random() * INTERVAL '60 days')::timestamp AS created_at
    FROM generate_series(1, 100)
) s;

-- every booking gets a "created" event
INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT id,
       'booking_created',
       jsonb_build_object('amount', amount, 'city', city, 'hotel_id', hotel_id),
       created_at
FROM hotel_bookings;

-- bookings that moved out of "pending" get a status change event
INSERT INTO booking_events (booking_id, event_type, payload, created_at)
SELECT id,
       'status_changed',
       jsonb_build_object('from', 'pending', 'to', status),
       created_at + INTERVAL '5 minutes'
FROM hotel_bookings
WHERE status <> 'pending';

-- refresh planner stats and the visibility map
VACUUM ANALYZE hotel_bookings;
VACUUM ANALYZE booking_events;