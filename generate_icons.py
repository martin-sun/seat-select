
import os

OUTPUT_DIR = "public/icons/seats"

COLORS = {
    "green": {
        "grad_top": "#4ADE80", "grad_bot": "#22C55E",
        "cushion": "#16A34A", "armrest": "#15803D", "highlight": "#86EFAC",
        "light_bg": "#DCFCE7", "light_cushion": "#BBF7D0", "light_arm": "#86EFAC"
    },
    "pink": { # Extra Light / Elegant Pink
        "grad_top": "#FCE7F3", "grad_bot": "#FBCFE8",
        "cushion": "#F9A8D4", "armrest": "#F472B6", "highlight": "#FFF1F2",
        "light_bg": "#FDF2F8", "light_cushion": "#FCE7F3", "light_arm": "#FBCFE8"
    },
    "red": {
        "grad_top": "#F87171", "grad_bot": "#EF4444",
        "cushion": "#DC2626", "armrest": "#B91C1C", "highlight": "#FCA5A5",
        "light_bg": "#FEE2E2", "light_cushion": "#FECACA", "light_arm": "#FCA5A5"
    },
    "purple": {
        "grad_top": "#C084FC", "grad_bot": "#A855F7",
        "cushion": "#9333EA", "armrest": "#7E22CE", "highlight": "#D8B4FE",
        "light_bg": "#F3E8FF", "light_cushion": "#E9D5FF", "light_arm": "#D8B4FE"
    }
}

TEMPLATE_Available = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs>
    <filter id="soft-shadow-{color}" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="1" result="blur"/>
      <feOffset in="blur" dx="0" dy="1" result="offsetBlur"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
      <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <linearGradient id="seat-gradient-{color}" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:{grad_top};stop-opacity:1" />
      <stop offset="100%" style="stop-color:{grad_bot};stop-opacity:1" />
    </linearGradient>
  </defs>
  <g filter="url(#soft-shadow-{color})">
    <path d="M7 6C7 3.5 9 2 16 2C23 2 25 3.5 25 6V16H7V6Z" fill="url(#seat-gradient-{color})"/>
    <rect x="5" y="15" width="22" height="10" rx="3" fill="{cushion}"/>
    <rect x="4" y="10" width="3" height="12" rx="1.5" fill="{armrest}"/>
    <rect x="25" y="10" width="3" height="12" rx="1.5" fill="{armrest}"/>
    <path d="M10 4C10 4 12 3 16 3C20 3 22 4 22 4" stroke="{highlight}" stroke-width="1.5" stroke-linecap="round" fill="none" opacity="0.6"/>
  </g>
</svg>"""

TEMPLATE_Selected = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs>
    <filter id="soft-shadow-sel-{color}" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="1" result="blur"/>
      <feOffset in="blur" dx="0" dy="1" result="offsetBlur"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
      <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <linearGradient id="seat-gradient-sel-{color}" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:{grad_top};stop-opacity:1" />
      <stop offset="100%" style="stop-color:{grad_bot};stop-opacity:1" />
    </linearGradient>
  </defs>
  <g filter="url(#soft-shadow-sel-{color})">
    <path d="M7 6C7 3.5 9 2 16 2C23 2 25 3.5 25 6V16H7V6Z" fill="url(#seat-gradient-sel-{color})" stroke="white" stroke-width="1.5"/>
    <rect x="5" y="15" width="22" height="10" rx="3" fill="{cushion}" stroke="white" stroke-width="1.5"/>
    <rect x="4" y="10" width="3" height="12" rx="1.5" fill="{armrest}"/>
    <rect x="25" y="10" width="3" height="12" rx="1.5" fill="{armrest}"/>
    <path d="M11 12 L15 16 L21 8" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" fill="none" transform="translate(0, 3)"/>
  </g>
</svg>"""

TEMPLATE_Unavailable = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs>
    <filter id="soft-shadow-un-{color}" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="1" result="blur"/>
      <feOffset in="blur" dx="0" dy="1" result="offsetBlur"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
      <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <g filter="url(#soft-shadow-un-{color})" opacity="0.8">
    <path d="M7 6C7 3.5 9 2 16 2C23 2 25 3.5 25 6V16H7V6Z" fill="{light_bg}"/>
    <rect x="5" y="15" width="22" height="10" rx="3" fill="{light_cushion}"/>
    <rect x="4" y="10" width="3" height="12" rx="1.5" fill="{light_arm}"/>
    <rect x="25" y="10" width="3" height="12" rx="1.5" fill="{light_arm}"/>
    <!-- Slash -->
    <line x1="8" y1="8" x2="24" y2="24" stroke="{light_arm}" stroke-width="2" stroke-linecap="round"/>
  </g>
</svg>"""

# Locked and Sold are typically Gray, but we generate them for each color filename as requested.
# We will use the Gray design for all 'locked' and 'sold' filenames.

TEMPLATE_Locked = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs>
    <filter id="soft-shadow-lock" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="1" result="blur"/>
      <feOffset in="blur" dx="0" dy="1" result="offsetBlur"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
      <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <linearGradient id="seat-gradient-lock" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#6B7280;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#4B5563;stop-opacity:1" />
    </linearGradient>
  </defs>
  <g filter="url(#soft-shadow-lock)">
    <path d="M7 6C7 3.5 9 2 16 2C23 2 25 3.5 25 6V16H7V6Z" fill="url(#seat-gradient-lock)"/>
    <rect x="5" y="15" width="22" height="10" rx="3" fill="#374151"/>
    <rect x="4" y="10" width="3" height="12" rx="1.5" fill="#1F2937"/>
    <rect x="25" y="10" width="3" height="12" rx="1.5" fill="#1F2937"/>
    <path d="M16 8 C14.5 8 13.5 9 13.5 10.5 V12 H18.5 V10.5 C18.5 9 17.5 8 16 8 Z" fill="#D1D5DB" transform="translate(0, 1)"/>
    <rect x="12.5" y="13" width="7" height="6" rx="1" fill="#D1D5DB"/>
  </g>
</svg>"""

TEMPLATE_Sold = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <defs>
    <filter id="soft-shadow-sold" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="1" result="blur"/>
      <feOffset in="blur" dx="0" dy="1" result="offsetBlur"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
      <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <linearGradient id="seat-gradient-sold" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#9CA3AF;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#6B7280;stop-opacity:1" />
    </linearGradient>
  </defs>
  <g filter="url(#soft-shadow-sold)">
    <path d="M7 6C7 3.5 9 2 16 2C23 2 25 3.5 25 6V16H7V6Z" fill="url(#seat-gradient-sold)"/>
    <rect x="5" y="15" width="22" height="10" rx="3" fill="#4B5563"/>
    <rect x="4" y="10" width="3" height="12" rx="1.5" fill="#374151"/>
    <rect x="25" y="10" width="3" height="12" rx="1.5" fill="#374151"/>
    <path d="M12 10 L20 18 M20 10 L12 18" stroke="#374151" stroke-width="2" stroke-linecap="round" opacity="0.5" transform="translate(0, -1)"/>
  </g>
</svg>"""

TEMPLATE_Handicapped = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 32">
  <defs>
    <filter id="soft-shadow-handicap" x="-50%" y="-50%" width="200%" height="200%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="1" result="blur"/>
      <feOffset in="blur" dx="0" dy="1" result="offsetBlur"/>
      <feComponentTransfer><feFuncA type="linear" slope="0.2"/></feComponentTransfer>
      <feMerge><feMergeNode/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <linearGradient id="seat-gradient-handicap" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" style="stop-color:#F59E0B;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#D97706;stop-opacity:1" />
    </linearGradient>
  </defs>
  <g filter="url(#soft-shadow-handicap)">
    <!-- Backrest (Double width) -->
    <path d="M7 6C7 3.5 9 2 16 2 H48 C55 2 57 3.5 57 6 V16 H7 V6 Z" fill="url(#seat-gradient-handicap)"/>
    <!-- Seat Cushion -->
    <rect x="5" y="15" width="54" height="10" rx="3" fill="#B45309"/>
    <!-- Armrests -->
    <rect x="4" y="10" width="3" height="12" rx="1.5" fill="#92400E"/>
    <rect x="57" y="10" width="3" height="12" rx="1.5" fill="#92400E"/>
    
    <!-- Wheelchair Icon -->
    <g transform="translate(26, 8)" stroke="#FEF3C7" stroke-width="2" fill="none">
        <circle cx="6" cy="6" r="5" />
        <path d="M6 6 V1 L10 -1" stroke-linecap="round"/>
        <circle cx="10" cy="-2" r="1.5" fill="#FEF3C7" stroke="none"/>
    </g>
    <!-- Lock Icon on right -->
    <g transform="translate(48, 6)">
         <path d="M4 2 C2.5 2 1.5 3 1.5 4.5 V6 H6.5 V4.5 C6.5 3 5.5 2 4 2 Z" fill="#78350F"/>
         <rect x="0.5" y="7" width="7" height="6" rx="1" fill="#78350F"/>
    </g>
  </g>
</svg>"""

def generate():
    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)

    # 1. Generate Color Variants
    for color, palette in COLORS.items():
        # Available
        with open(f"{OUTPUT_DIR}/seat-{color}-available.svg", "w") as f:
            f.write(TEMPLATE_Available.format(color=color, **palette))
        
        # Selected
        with open(f"{OUTPUT_DIR}/seat-{color}-selected.svg", "w") as f:
            f.write(TEMPLATE_Selected.format(color=color, **palette))
        
        # Unavailable (Custom Light Palette)
        with open(f"{OUTPUT_DIR}/seat-{color}-unavailable.svg", "w") as f:
            f.write(TEMPLATE_Unavailable.format(color=color, **palette))
            
        # Locked (Standard Gray)
        with open(f"{OUTPUT_DIR}/seat-{color}-locked.svg", "w") as f:
            f.write(TEMPLATE_Locked)
            
        # Sold (Standard Gray)
        with open(f"{OUTPUT_DIR}/seat-{color}-sold.svg", "w") as f:
            f.write(TEMPLATE_Sold)

    # 2. Handicap Special
    with open(f"{OUTPUT_DIR}/seat-handicaped-locked.svg", "w") as f:
        f.write(TEMPLATE_Handicapped)

    print("All icons generated successfully.")

if __name__ == "__main__":
    generate()
