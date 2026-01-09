<template>
  <div class="mobile-programs-container">
    <!-- Language Switcher -->
    <MobileLanguageSwitcher />

    <!-- Page Indicator -->
    <PageIndicator
      :total="pages.length"
      :current="currentSection"
      @navigate="scrollToSection"
    />

    <!-- Scroll Snap Container -->
    <div ref="container" class="scroll-container">
      <!-- Cover Section -->
      <section class="snap-section cover-section">
        <div class="cover-background">
          <div class="cover-gradient"></div>
        </div>

        <div class="cover-content">
          <span class="year-badge">{{ $t('chunwan.mobile.header.year') }}</span>
          <h1 class="cover-title brush-font">{{ $t('chunwan.mobile.header.title') }}</h1>
          <p class="cover-subtitle">{{ $t('chunwan.mobile.header.subtitle') }}</p>
        </div>

        <div class="scroll-hint">
          <span class="scroll-hint-text">{{ $t('chunwan.mobile.swipeUp') }}</span>
          <div class="scroll-arrow">
            <svg width="32" height="32" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M5 10l7-7m0 0l7 7m-7-7v18"
              ></path>
            </svg>
          </div>
        </div>
      </section>

      <!-- Staff Section -->
      <section class="snap-section staff-section">
        <div class="staff-content">
          <h2 class="staff-title brush-font">{{ $t('chunwan.mobile.staff.title') }}</h2>

          <div class="staff-list">
            <div v-for="(member, index) in $tm('chunwan.mobile.staff.members')" :key="index" class="staff-item">
              <span class="staff-role">{{ member.role }}</span>
              <span class="staff-name">{{ member.names }}</span>
            </div>
          </div>

          <div class="art-directors">
            <h3 class="art-directors-title">{{ $t('chunwan.mobile.staff.artDirection') }}</h3>
            <div class="art-directors-list">
              <div v-for="(director, index) in $tm('chunwan.mobile.staff.artDirectors')" :key="index" class="director-item">
                <span class="director-name">{{ director.name }}</span>
                <span class="director-org"> · {{ director.org }}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Programs and Prizes -->
      <template v-for="(page, index) in programPages" :key="`program-${index}`">
        <!-- Program Section -->
        <section v-if="page.type === 'program'" class="snap-section program-section">
          <div class="program-content">
            <div class="program-header">
              <div class="program-number">{{ page.program.sort }}</div>
              <div>
                <h2 class="program-title">{{ page.program.title }}</h2>
                <p v-if="page.program.subtitle" class="program-subtitle">{{ page.program.subtitle }}</p>
              </div>
            </div>

            <p v-if="page.program.description" class="program-description">
              {{ page.program.description }}
            </p>

            <div v-if="page.program.performers" class="performers-list">
              <div class="performer-item">
                <span class="performer-label">{{ $t('chunwan.programs.performers') }}</span>
                <span class="performer-names">{{ page.program.performers }}</span>
              </div>
            </div>
          </div>
        </section>

        <!-- Prize Section -->
        <section v-else-if="page.type === 'prize'" class="snap-section prize-section">
          <div class="prize-content">
            <div class="prize-card">
              <div class="prize-emoji">🎁</div>
              <h2 class="prize-title brush-font">{{ page.program.title }}</h2>
              <p class="prize-text">{{ page.program.description }}</p>
            </div>
          </div>
        </section>
      </template>

      <!-- Finale Section -->
      <section class="snap-section finale-section">
        <div class="finale-content">
          <div v-if="finaleProgram" class="finale-program-card">
            <div class="finale-header">
              <div class="finale-number">{{ finaleProgram.sort }}</div>
              <div>
                <h2 class="finale-title">{{ finaleProgram.title }}</h2>
                <p v-if="finaleProgram.subtitle" class="finale-subtitle">{{ finaleProgram.subtitle }}</p>
              </div>
            </div>
            <div v-if="finaleProgram.performers" class="finale-performers">
              <div class="finale-performer">
                <span class="finale-performer-role">{{ $t('chunwan.programs.performers') }}</span>
                <span class="finale-performer-names">{{ finaleProgram.performers }}</span>
              </div>
            </div>
          </div>

          <div class="blessings">
            <p class="blessing-1 brush-font">{{ $t('chunwan.mobile.footer.blessing1') }}</p>
            <p class="blessing-2">{{ $t('chunwan.mobile.footer.blessing2') }}</p>
            <p class="blessing-3">{{ $t('chunwan.mobile.footer.blessing3') }}</p>

            <div class="blessing-emojis">
              <span>🏮</span>
              <span>🐍</span>
              <span>🧧</span>
            </div>

            <p class="copyright">{{ $t('chunwan.mobile.footer.copyright') }}</p>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import MobileLanguageSwitcher from './MobileLanguageSwitcher.vue'
import PageIndicator from './PageIndicator.vue'

export default {
  name: 'MobilePrograms',
  components: {
    MobileLanguageSwitcher,
    PageIndicator
  },
  props: {
    lang: {
      type: String,
      default: 'zh'
    },
    programs: {
      type: Array,
      default: () => []
    },
    settings: {
      type: Object,
      default: () => ({})
    }
  },
  setup(props) {
    const container = ref(null)
    const currentSection = ref(0)

    // Check if program is the finale (last non-prize program)
    const isFinaleProgram = (program) => {
      if (program.type === 'prize') return false
      const regularPrograms = props.programs.filter(p => p.type !== 'prize')
      return regularPrograms.length > 0 && program === regularPrograms[regularPrograms.length - 1]
    }

    // Build program pages (exclude finale and prizes)
    const programPages = computed(() => {
      const pages = []

      for (const program of props.programs) {
        if (program.type === 'prize') {
          pages.push({ type: 'prize', program })
        } else if (!isFinaleProgram(program)) {
          pages.push({ type: 'program', program })
        }
      }
      return pages
    })

    // Get finale program
    const finaleProgram = computed(() => {
      const regularPrograms = props.programs.filter(p => p.type !== 'prize')
      return regularPrograms.length > 0 ? regularPrograms[regularPrograms.length - 1] : null
    })

    // Total pages: cover + staff + programs/prizes + finale
    const pages = computed(() => {
      return [
        { type: 'cover' },
        { type: 'staff' },
        ...programPages.value,
        { type: 'finale' }
      ]
    })

    // Scroll to section
    const scrollToSection = (index) => {
      if (!container.value) return
      const sections = container.value.querySelectorAll('.snap-section')
      sections[index]?.scrollIntoView({
        behavior: 'smooth',
        block: 'start'
      })
    }

    // Setup intersection observer for animations
    let observer = null

    const setupObserver = () => {
      if (!container.value) return

      const sections = container.value.querySelectorAll('.snap-section')

      // Make first section visible immediately
      if (sections[0]) {
        sections[0].classList.add('visible')
      }

      observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              entry.target.classList.add('visible')

              // Update current section
              const index = Array.from(sections).indexOf(entry.target)
              if (index !== -1) {
                currentSection.value = index
              }
            }
          })
        },
        {
          root: container.value,
          threshold: 0.3
        }
      )

      sections.forEach((section) => observer.observe(section))
    }

    onMounted(async () => {
      await nextTick()
      setupObserver()
    })

    onUnmounted(() => {
      if (observer) {
        observer.disconnect()
      }
    })

    return {
      container,
      currentSection,
      pages,
      programPages,
      finaleProgram,
      scrollToSection
    }
  }
}
</script>

<style scoped>
/* Brush font */
.brush-font {
  font-family: 'Ma Shan Zheng', cursive;
}

/* Mobile container */
.mobile-programs-container {
  width: 100%;
  height: 100vh;
  height: 100dvh;
  overflow: hidden;
}

/* Scroll Snap Container */
.scroll-container {
  height: 100vh;
  height: 100dvh;
  overflow-y: scroll;
  scroll-snap-type: y mandatory;
  scroll-behavior: smooth;
  -webkit-overflow-scrolling: touch;
  background: linear-gradient(to bottom, #7f1d1d, #991b1b, #7f1d1d);
}

/* Each section snaps to viewport */
.snap-section {
  min-height: 100vh;
  min-height: 100dvh;
  scroll-snap-align: start;
  scroll-snap-stop: always;
  display: flex;
  flex-direction: column;
  padding: 1.5rem;
  padding-top: max(1.5rem, env(safe-area-inset-top));
  padding-bottom: max(1.5rem, env(safe-area-inset-bottom));
  position: relative;
  overflow: hidden;
}

/* Animation: Entry */
.snap-section {
  opacity: 0;
  transform: translateY(30px);
  transition: opacity 0.6s cubic-bezier(0.4, 0, 0.2, 1),
              transform 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}

.snap-section.visible {
  opacity: 1;
  transform: translateY(0);
}

/* Cover section */
.cover-section {
  padding: 0;
}

.cover-background {
  position: absolute;
  inset: 0;
  overflow: hidden;
}

.cover-gradient {
  position: absolute;
  inset: 0;
  background: linear-gradient(to bottom, rgba(127, 29, 29, 0.6), transparent, rgba(127, 29, 29, 0.8));
}

.cover-content {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 10;
  text-align: center;
  width: 100%;
  padding: 0 1.5rem;
}

.year-badge {
  display: inline-block;
  margin-bottom: 1rem;
  padding: 0.5rem 1.5rem;
  border: 2px solid #f59e0b;
  border-radius: 9999px;
  background-color: rgba(127, 29, 29, 0.8);
  font-size: 1.25rem;
  font-weight: 700;
  color: #fbbf24;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.cover-title {
  margin-bottom: 1rem;
  font-size: 3rem;
  color: #fbbf24;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  line-height: 1.2;
}

.cover-subtitle {
  font-size: 1.125rem;
  color: rgba(253, 230, 138, 0.9);
}

/* Scroll hint */
.scroll-hint {
  position: absolute;
  bottom: 2rem;
  left: 0;
  right: 0;
  z-index: 20;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  color: #fbbf24;
  animation: fadeInOut 2s ease-in-out infinite;
}

.scroll-hint-text {
  font-size: 1rem;
  font-weight: 500;
}

.scroll-arrow {
  animation: bounceUp 1.5s ease-in-out infinite;
}

@keyframes fadeInOut {
  0%, 100% { opacity: 0.5; }
  50% { opacity: 1; }
}

@keyframes bounceUp {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}

/* Staff section */
.staff-section {
  background: linear-gradient(135deg, rgba(127, 29, 29, 0.9), rgba(153, 27, 27, 0.9));
  padding-top: 4rem;
}

.staff-content {
  display: flex;
  flex-direction: column;
  justify-content: center;
  height: 100%;
}

.staff-title {
  margin-bottom: 1.5rem;
  text-align: center;
  font-size: 1.875rem;
  color: #fbbf24;
}

.staff-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.staff-item {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
  font-size: 1rem;
}

.staff-role {
  flex-shrink: 0;
  color: #f59e0b;
}

.staff-name {
  color: rgba(255, 251, 235, 0.9);
}

.art-directors {
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid rgba(245, 158, 11, 0.3);
}

.art-directors-title {
  margin-bottom: 0.75rem;
  font-size: 1.125rem;
  font-weight: 600;
  color: #fbbf24;
}

.art-directors-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.director-item {
  font-size: 1rem;
}

.director-name {
  color: #fef3c7;
}

.director-org {
  color: rgba(245, 158, 11, 0.7);
}

/* Program section */
.program-section {
  border-bottom: 1px solid rgba(245, 158, 11, 0.2);
  padding-top: 4rem;
}

.program-content {
  display: flex;
  flex-direction: column;
  justify-content: center;
  height: 100%;
}

.program-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}

.program-number {
  display: flex;
  width: 3.5rem;
  height: 3.5rem;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  border-radius: 9999px;
  border: 2px solid #f59e0b;
  background-color: #b91c1c;
  font-size: 1.5rem;
  font-weight: 700;
  color: #fbbf24;
}

.program-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #fef3c7;
}

.program-subtitle {
  font-size: 1.125rem;
  color: rgba(251, 191, 36, 0.8);
}

.program-description {
  margin-bottom: 1rem;
  font-size: 1rem;
  color: rgba(252, 211, 77, 0.8);
}

.performers-list {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.performer-item {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
  font-size: 1rem;
}

.performer-label {
  flex-shrink: 0;
  color: #f59e0b;
}

.performer-names {
  color: rgba(254, 243, 199, 0.9);
}

/* Prize section */
.prize-section {
  background: radial-gradient(ellipse at center, rgba(127, 29, 29, 1), rgba(69, 10, 10, 1));
}

.prize-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  text-align: center;
}

.prize-card {
  padding: 2rem;
  border-radius: 1rem;
  border: 2px solid #f59e0b;
  background: linear-gradient(to bottom right, #991b1b, #7f1d1d);
  box-shadow: 0 0 30px rgba(245, 158, 11, 0.3),
              0 0 60px rgba(245, 158, 11, 0.1);
}

.prize-emoji {
  margin-bottom: 1rem;
  font-size: 3rem;
}

.prize-title {
  margin-bottom: 0.5rem;
  font-size: 1.875rem;
  color: #fbbf24;
}

.prize-text {
  font-size: 1.25rem;
  font-weight: 700;
  color: #fef3c7;
}

/* Finale section */
.finale-section {
  background: linear-gradient(180deg, rgba(127, 29, 29, 0.95), rgba(69, 10, 10, 1));
  padding-top: 4rem;
}

.finale-content {
  display: flex;
  flex-direction: column;
  justify-content: center;
  height: 100%;
}

.finale-program-card {
  margin-bottom: 2rem;
  padding: 1.5rem;
  border-radius: 1rem;
  border: 2px solid #f59e0b;
  background: linear-gradient(to bottom right, #b91c1c, #7f1d1d);
}

.finale-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.75rem;
}

.finale-number {
  display: flex;
  width: 3rem;
  height: 3rem;
  align-items: center;
  justify-content: center;
  border-radius: 9999px;
  background-color: #f59e0b;
  font-size: 1.25rem;
  font-weight: 700;
  color: #7f1d1d;
}

.finale-title {
  font-size: 1.25rem;
  font-weight: 700;
  color: #ffffff;
}

.finale-subtitle {
  color: #fcd34d;
}

.finale-performers {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.finale-performer {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
  font-size: 1rem;
}

.finale-performer-role {
  color: #fbbf24;
}

.finale-performer-names {
  color: rgba(255, 255, 255, 0.9);
}

.blessings {
  text-align: center;
}

.blessing-1 {
  margin-bottom: 0.5rem;
  font-size: 2.5rem;
  color: #fbbf24;
}

.blessing-2 {
  margin-bottom: 0.5rem;
  font-size: 1.25rem;
  color: #fde68a;
}

.blessing-3 {
  margin-bottom: 1.5rem;
  font-size: 1.125rem;
  color: rgba(252, 211, 77, 0.8);
}

.blessing-emojis {
  display: flex;
  justify-content: center;
  gap: 0.75rem;
  font-size: 1.5rem;
  margin-bottom: 1rem;
}

.copyright {
  font-size: 0.875rem;
  color: rgba(245, 158, 11, 0.6);
}
</style>
