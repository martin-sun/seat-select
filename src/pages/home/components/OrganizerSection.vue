<template>
  <section class="organizer-section py-16 px-4 border-t border-red-800/30">
    <div class="max-w-6xl mx-auto">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-12">
        <!-- 主办单位 (Organizers) -->
        <div v-if="organizers.length">
          <h3 class="text-2xl font-bold text-yellow-400 mb-6 flex items-center space-x-2">
            <span class="w-8 h-px bg-yellow-400/50"></span>
            <span>{{ $t('chunwan.organizerSection.organizer') }}</span>
          </h3>
          <ul class="space-y-4">
            <li 
              v-for="item in organizers" 
              :key="item.id"
              class="text-lg text-yellow-50/90 flex items-center space-x-3 bg-red-900/20 p-4 rounded-xl border border-red-800/30"
            >
              <span class="text-yellow-500">◈</span>
              <span>{{ item.name }}</span>
            </li>
          </ul>
        </div>

        <!-- 协办单位 (Co-organizers) -->
        <div v-if="coOrganizers.length">
          <h3 class="text-2xl font-bold text-yellow-400 mb-6 flex items-center space-x-2">
            <span class="w-8 h-px bg-yellow-400/50"></span>
            <span>{{ $t('chunwan.organizerSection.coOrganizer') }}</span>
          </h3>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div 
              v-for="item in coOrganizers" 
              :key="item.id"
              class="bg-red-900/10 p-4 rounded-lg border border-red-800/20 text-yellow-100/80 hover:bg-red-800/10 transition-colors"
            >
              {{ item.name }}
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import { computed } from 'vue'

export default {
  name: 'OrganizerSection',
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  setup(props) {
    const organizers = computed(() => props.items.filter(i => i.type === 'organizer'))
    const coOrganizers = computed(() => props.items.filter(i => i.type === 'co-organizer'))

    return {
      organizers,
      coOrganizers
    }
  }
}
</script>
