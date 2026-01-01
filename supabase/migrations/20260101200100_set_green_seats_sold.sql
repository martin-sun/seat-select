-- Migration to set all Green Zone seats to sold status

UPDATE seats
SET status = 'sold'
WHERE zone = 'green'
  AND event_id = 'bff090f7-fb8a-408f-b3df-fc2522151004';
