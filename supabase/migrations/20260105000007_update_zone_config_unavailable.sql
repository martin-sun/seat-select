-- Migration to update zone_config to include 'unavailable' icons for all zones

UPDATE events
SET zone_config = '[
  {
    "zone": "red",
    "name": "Red Zone",
    "color": "#DC2626",
    "icons": {
      "available": "/icons/seats/seat-red-available.svg",
      "selected": "/icons/seats/seat-red-selected.svg",
      "locked": "/icons/seats/seat-red-locked.svg",
      "sold": "/icons/seats/seat-red-sold.svg",
      "unavailable": "/icons/seats/seat-red-unavailable.svg"
    }
  },
  {
    "zone": "pink",
    "name": "Pink Zone",
    "color": "#EC4899",
    "icons": {
      "available": "/icons/seats/seat-pink-available.svg",
      "selected": "/icons/seats/seat-pink-selected.svg",
      "locked": "/icons/seats/seat-pink-locked.svg",
      "sold": "/icons/seats/seat-pink-sold.svg",
      "unavailable": "/icons/seats/seat-pink-unavailable.svg"
    }
  },
  {
    "zone": "purple",
    "name": "Purple Zone",
    "color": "#7C3AED",
    "icons": {
      "available": "/icons/seats/seat-purple-available.svg",
      "selected": "/icons/seats/seat-purple-selected.svg",
      "locked": "/icons/seats/seat-purple-locked.svg",
      "sold": "/icons/seats/seat-purple-sold.svg",
      "unavailable": "/icons/seats/seat-purple-unavailable.svg"
    }
  },
  {
    "zone": "handicaped",
    "name": "Handicapped",
    "color": "#F59E0B",
    "icons": {
      "locked": "/icons/seats/seat-handicaped-locked.svg",
      "unavailable": "/icons/seats/seat-handicaped-locked.svg"
    },
    "width": 2
  },
  {
    "zone": "green",
    "name": "Green Zone",
    "color": "#22C55E",
    "icons": {
      "available": "/icons/seats/seat-green-available.svg",
      "selected": "/icons/seats/seat-green-selected.svg",
      "locked": "/icons/seats/seat-green-locked.svg",
      "sold": "/icons/seats/seat-green-sold.svg",
      "unavailable": "/icons/seats/seat-green-unavailable.svg"
    }
  }
]'::jsonb
WHERE id = 'bff090f7-fb8a-408f-b3df-fc2522151004';
