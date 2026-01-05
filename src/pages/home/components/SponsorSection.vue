<template>
  <section class="sponsor-section py-16 px-4 bg-red-950/30">
    <div class="max-w-6xl mx-auto">
      <h2 class="text-3xl md:text-4xl font-bold text-center text-yellow-400 mb-12">
        特别鸣谢我们的赞助商
      </h2>

      <!-- 冠名赞助 (Title Sponsor) -->
      <div v-if="titleSponsors.length" class="mb-12">
        <div class="text-center mb-6">
          <span class="px-4 py-1 bg-yellow-500 text-red-900 rounded-full text-sm font-bold tracking-widest uppercase">
            冠名赞助
          </span>
        </div>
        <div class="flex justify-center">
          <div 
            v-for="sponsor in titleSponsors" 
            :key="sponsor.id"
            class="sponsor-card title bg-white/10 backdrop-blur-md border border-yellow-500/50 p-8 rounded-2xl transform transition-all hover:scale-105"
          >
            <div class="text-2xl md:text-3xl font-bold text-yellow-400 text-center">
              {{ sponsor.name }}
            </div>
          </div>
        </div>
      </div>

      <!-- 金牌赞助 (Gold Sponsors) -->
      <div v-if="goldSponsors.length" class="mb-12">
        <div class="text-center mb-6">
          <span class="px-4 py-1 bg-yellow-600/80 text-yellow-50 rounded-full text-sm font-bold tracking-widest">
            金牌赞助
          </span>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-6 max-w-4xl mx-auto">
          <div 
            v-for="sponsor in goldSponsors" 
            :key="sponsor.id"
            class="sponsor-card gold bg-white/5 backdrop-blur-sm border border-yellow-600/30 p-6 rounded-xl text-center hover:bg-white/10 transition-colors"
          >
            <div class="text-xl font-semibold text-yellow-100">
              {{ sponsor.name }}
            </div>
          </div>
        </div>
      </div>

      <!-- 银牌赞助 (Silver Sponsors) -->
      <div v-if="silverSponsors.length" class="mb-12">
        <div class="text-center mb-6">
          <span class="px-4 py-1 bg-gray-400/50 text-gray-100 rounded-full text-sm font-bold tracking-widest">
            银牌赞助
          </span>
        </div>
        <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          <div 
            v-for="sponsor in silverSponsors" 
            :key="sponsor.id"
            class="sponsor-card silver bg-red-900/40 p-4 rounded-lg text-center border border-red-800/50 hover:border-yellow-500/30 transition-all"
          >
            <div class="text-base font-medium text-yellow-50/90">
              {{ sponsor.name }}
            </div>
          </div>
        </div>
      </div>

      <!-- 铜牌赞助 (Bronze Sponsors) -->
      <div v-if="bronzeSponsors.length">
        <div class="text-center mb-6">
          <span class="px-4 py-1 bg-orange-800/30 text-orange-200 rounded-full text-sm font-bold tracking-widest">
            友好赞助
          </span>
        </div>
        <div class="flex flex-wrap justify-center gap-3">
          <div 
            v-for="sponsor in bronzeSponsors" 
            :key="sponsor.id"
            class="sponsor-tag bronze bg-red-900/20 px-4 py-2 rounded-full border border-red-800/30 text-sm text-yellow-100/70"
          >
            {{ sponsor.name }}
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
import { computed } from 'vue'

export default {
  name: 'SponsorSection',
  props: {
    sponsors: {
      type: Array,
      default: () => []
    }
  },
  setup(props) {
    const titleSponsors = computed(() => props.sponsors.filter(s => s.level === 'title'))
    const goldSponsors = computed(() => props.sponsors.filter(s => s.level === 'gold'))
    const silverSponsors = computed(() => props.sponsors.filter(s => s.level === 'silver'))
    const bronzeSponsors = computed(() => props.sponsors.filter(s => s.level === 'bronze'))

    return {
      titleSponsors,
      goldSponsors,
      silverSponsors,
      bronzeSponsors
    }
  }
}
</script>

<style scoped>
.sponsor-card {
  box-shadow: 0 10px 30px -10px rgba(0, 0, 0, 0.5);
}

.title {
  min-width: 300px;
}
</style>
