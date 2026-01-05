-- Clean up old organizers and insert the correct ones
DELETE FROM chunwan_organizers;

INSERT INTO chunwan_organizers (name, type, sort) VALUES
('萨省中国舞蹈学校', 'organizer', 1),
('春之声合唱团', 'organizer', 2),
('加拿大育才学校', 'organizer', 3),
('海外新生活', 'co-organizer', 4);
