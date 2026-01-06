<template>
  <div class="seat-legend">
    <div class="legend-container">
      <!-- Zone Specific Available Seats -->
      <div v-for="zone in zoneConfig" :key="zone.zone" class="legend-item">
        <img :src="zone.icons.available" class="legend-icon" alt="available" />
        <span class="legend-label">
          {{ zone.name || zone.zone }} - {{ formatDesc(zone.desc, zone.zone) }}
        </span>
      </div>

      <!-- Common Statuses -->
      <div class="legend-item">
        <img :src="commonIcons.selected" class="legend-icon" alt="selected" />
        <span class="legend-label">{{ $t('seatArea.legend.selected') }}</span>
      </div>

      <div class="legend-item">
        <img :src="commonIcons.sold" class="legend-icon" alt="sold" />
        <span class="legend-label">{{ $t('seatArea.legend.sold') }}</span>
      </div>

      <div class="legend-item">
        <img :src="commonIcons.locked" class="legend-icon" alt="locked" />
        <span class="legend-label">{{ $t('seatArea.legend.locked') }}</span>
      </div>

      <div v-if="hasUnavailable" class="legend-item">
        <img :src="commonIcons.unavailable" class="legend-icon" alt="unavailable" />
        <span class="legend-label">{{ $t('seatArea.legend.unavailable') }}</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SeatLegend',
  props: {
    zoneConfig: {
      type: Array,
      default: () => []
    },
    zonePrices: {
      type: Object,
      default: () => ({})
    },
    hasUnavailable: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    commonIcons() {
      // Use the first zone's icons as a representative for common statuses
      if (this.zoneConfig.length > 0) {
        return this.zoneConfig[0].icons
      }
      return {}
    }
  },
  methods: {
    formatDesc(desc, zone) {
      if (!desc) {
        // Fallback to zonePrices if desc is missing
        const price = this.zonePrices[zone]
        return price ? `$${price}` : ''
      }
      
      // If it looks like a number, prepend $
      if (!isNaN(desc) && desc.trim() !== '') {
        return `$${desc}`
      }
      
      return desc
    }
  }
}
</script>

<style scoped>
.seat-legend {
  @apply w-full bg-white/80 backdrop-blur-sm border-b border-gray-200 py-2 px-4 sticky top-[64px] z-20;
}

.legend-container {
  @apply flex flex-wrap justify-center gap-x-6 gap-y-2 max-w-4xl mx-auto;
}

.legend-item {
  @apply flex items-center gap-2 whitespace-nowrap;
}

.legend-icon {
  @apply w-5 h-5 object-contain;
}

.legend-label {
  @apply text-xs md:text-sm text-gray-600 font-medium;
}

/* Adjust for different screen sizes */
@media (max-width: 640px) {
  .seat-legend {
    @apply top-[56px];
  }
  .legend-container {
    @apply gap-x-4 gap-y-1.5;
  }
}
</style>
