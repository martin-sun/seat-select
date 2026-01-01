import json

# Configuration
output_file = 'public/mock/seats.json'

event_id = "evt-spring-gala-2026"
zone_prices = {
    "red": 100,
    "pink": 80,
    "purple": 60,
    "handicaped": 60
}

zone_config = [
    {
        "zone": "red",
        "name": "Red Zone",
        "price": 100,
        "color": "#DC2626",
        "icons": {
            "available": "/icons/seats/seat-red-available.svg",
            "selected": "/icons/seats/seat-red-selected.svg",
            "locked": "/icons/seats/seat-red-locked.svg",
            "sold": "/icons/seats/seat-red-sold.svg"
        }
    },
    {
        "zone": "pink",
        "name": "Pink Zone",
        "price": 80,
        "color": "#EC4899",
        "icons": {
            "available": "/icons/seats/seat-pink-available.svg",
            "selected": "/icons/seats/seat-pink-selected.svg",
            "locked": "/icons/seats/seat-pink-locked.svg",
            "sold": "/icons/seats/seat-pink-sold.svg"
        }
    },
    {
        "zone": "purple",
        "name": "Purple Zone",
        "price": 60,
        "color": "#7C3AED",
        "icons": {
            "available": "/icons/seats/seat-purple-available.svg",
            "selected": "/icons/seats/seat-purple-selected.svg",
            "locked": "/icons/seats/seat-purple-locked.svg",
            "sold": "/icons/seats/seat-purple-sold.svg"
        }
    },
    {
        "zone": "handicaped",
        "name": "Handicapped",
        "price": 60,
        "color": "#F59E0B",
        "icons": {
            "locked": "/icons/seats/seat-handicaped-locked.svg"
        },
        "width": 2
    }
]

# Grid Logic
# gRow 1 is top (Row A - Closest to Stage). gRow 17 is bottom (Row Q).
row_names = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q']
g_row_map = {
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8, 'I': 9, 'J': 10,
    # Gap K, L would be 11, 12
    'M': 13, 'N': 14, 'O': 15, 'P': 16, 'Q': 17
}

seats_data = []

def generate_row_seats(row_name, blocks):
    g_row = g_row_map[row_name]
    for block in blocks:
        start_seat = block['start']
        end_seat = block['end']
        zone = block['zone']
        start_gcol = block['start_gcol']
        
        count = end_seat - start_seat + 1
        for i in range(count):
            seat_num = start_seat + i
            g_col = start_gcol + i
            seat_obj = {
                "id": str(16880000 + (g_row * 1000) + seat_num),
                "row": row_name,
                "col": str(seat_num),
                "gRow": g_row,
                "gCol": g_col,
                "zone": zone,
                "status": "available",
                "locked_until": None
            }
            seats_data.append(seat_obj)

# Row Configurations based on the provided image
# M-Q Section
for r in ['Q', 'P', 'O', 'N']:
    blocks = [
        {'start': 7, 'end': 21, 'zone': 'purple', 'start_gcol': 10},
        {'start': 22, 'end': 25, 'zone': 'purple', 'start_gcol': 26},
        {'start': 26, 'end': 29, 'zone': 'purple', 'start_gcol': 32},
        {'start': 30, 'end': 44, 'zone': 'purple', 'start_gcol': 37}
    ]
    generate_row_seats(r, blocks)

generate_row_seats('M', [
    {'start': 8, 'end': 22, 'zone': 'purple', 'start_gcol': 10},
    {'start': 23, 'end': 26, 'zone': 'purple', 'start_gcol': 26},
    {'start': 27, 'end': 30, 'zone': 'purple', 'start_gcol': 32},
    {'start': 31, 'end': 45, 'zone': 'purple', 'start_gcol': 37}
])

# A-J Section
generate_row_seats('A', [
    {'start': 5, 'end': 11, 'zone': 'pink', 'start_gcol': 18},
    {'start': 12, 'end': 21, 'zone': 'red', 'start_gcol': 26},
    {'start': 22, 'end': 28, 'zone': 'pink', 'start_gcol': 37}
])

generate_row_seats('B', [
    {'start': 8, 'end': 15, 'zone': 'pink', 'start_gcol': 17},
    {'start': 16, 'end': 25, 'zone': 'red', 'start_gcol': 26},
    {'start': 26, 'end': 33, 'zone': 'pink', 'start_gcol': 37}
])

generate_row_seats('C', [
    {'start': 8, 'end': 16, 'zone': 'pink', 'start_gcol': 16},
    {'start': 17, 'end': 26, 'zone': 'red', 'start_gcol': 26},
    {'start': 27, 'end': 35, 'zone': 'pink', 'start_gcol': 37}
])

generate_row_seats('D', [
    {'start': 8, 'end': 18, 'zone': 'pink', 'start_gcol': 14},
    {'start': 19, 'end': 28, 'zone': 'red', 'start_gcol': 26},
    {'start': 29, 'end': 39, 'zone': 'pink', 'start_gcol': 37}
])

generate_row_seats('E', [
    {'start': 8, 'end': 19, 'zone': 'pink', 'start_gcol': 13},
    {'start': 20, 'end': 29, 'zone': 'red', 'start_gcol': 26},
    {'start': 30, 'end': 41, 'zone': 'pink', 'start_gcol': 37}
])

generate_row_seats('F', [
    {'start': 8, 'end': 20, 'zone': 'pink', 'start_gcol': 12},
    {'start': 21, 'end': 30, 'zone': 'red', 'start_gcol': 26},
    {'start': 31, 'end': 43, 'zone': 'pink', 'start_gcol': 37}
])

generate_row_seats('G', [
    {'start': 8, 'end': 22, 'zone': 'pink', 'start_gcol': 10},
    {'start': 23, 'end': 32, 'zone': 'red', 'start_gcol': 26},
    {'start': 33, 'end': 48, 'zone': 'pink', 'start_gcol': 37}
])

generate_row_seats('H', [
    {'start': 8, 'end': 22, 'zone': 'pink', 'start_gcol': 10},
    {'start': 23, 'end': 32, 'zone': 'red', 'start_gcol': 26},
    {'start': 33, 'end': 48, 'zone': 'pink', 'start_gcol': 37}
])

generate_row_seats('I', [
    {'start': 7, 'end': 21, 'zone': 'pink', 'start_gcol': 14},
    {'start': 22, 'end': 24, 'zone': 'red', 'start_gcol': 30},
    {'start': 25, 'end': 40, 'zone': 'pink', 'start_gcol': 34}
])

generate_row_seats('J', [
    {'start': 1, 'end': 3, 'zone': 'pink', 'start_gcol': 1},
    {'start': 7, 'end': 15, 'zone': 'pink', 'start_gcol': 20},
    {'start': 16, 'end': 18, 'zone': 'red', 'start_gcol': 30},
    {'start': 19, 'end': 28, 'zone': 'pink', 'start_gcol': 34},
    {'start': 29, 'end': 30, 'zone': 'pink', 'start_gcol': 50}
])

final_data = {
    "event_id": event_id,
    "zone_prices": zone_prices,
    "seats": seats_data,
    "zone_config": zone_config
}

with open(output_file, 'w') as f:
    json.dump(final_data, f, indent=2, ensure_ascii=False)

print(f"Generated {len(seats_data)} seats to {output_file}")
