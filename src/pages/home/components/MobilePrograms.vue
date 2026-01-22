<template>
  <div class="mobile-programs-container">
    <!-- Language Switcher -->
    <MobileLanguageSwitcher />

    <!-- Page Indicator (only show when unlocked) -->
    <PageIndicator
      v-if="!isLocked"
      :total="pages.length"
      :current="currentSection"
      @navigate="scrollToSection"
    />

    <!-- Scroll Snap Container -->
    <div
      ref="container"
      :class="['scroll-container', { 'scroll-locked': isLocked }]"
    >
      <!-- Countdown Section (only shown when locked) -->
      <section
        v-if="isLocked && countdown !== null"
        class="snap-section countdown-section"
      >
        <div class="countdown-content">
          <div class="countdown-icon">🏮</div>

          <h2 class="countdown-title">{{ $t("chunwan.countdown.title") }}</h2>

          <p class="unlock-date">{{ formattedUnlockDate }}</p>

          <!-- 倒计时数字 -->
          <div class="countdown-display">
            <div class="countdown-unit">
              <span class="countdown-number">{{
                formattedCountdown.days
              }}</span>
              <span class="countdown-label">{{
                $t("chunwan.countdown.days")
              }}</span>
            </div>
            <span class="countdown-separator">:</span>
            <div class="countdown-unit">
              <span class="countdown-number">{{
                formattedCountdown.hours
              }}</span>
              <span class="countdown-label">{{
                $t("chunwan.countdown.hours")
              }}</span>
            </div>
            <span class="countdown-separator">:</span>
            <div class="countdown-unit">
              <span class="countdown-number">{{
                formattedCountdown.minutes
              }}</span>
              <span class="countdown-label">{{
                $t("chunwan.countdown.minutes")
              }}</span>
            </div>
            <span class="countdown-separator">:</span>
            <div class="countdown-unit">
              <span class="countdown-number">{{
                formattedCountdown.seconds
              }}</span>
              <span class="countdown-label">{{
                $t("chunwan.countdown.seconds")
              }}</span>
            </div>
          </div>

          <div class="countdown-footer">
            <span>🧧</span>
            <span>🐎</span>
            <span>🏮</span>
          </div>
        </div>
      </section>

      <!-- Cover Section -->
      <section class="snap-section cover-section">
        <div class="cover-background">
          <div class="cover-gradient"></div>
        </div>

        <div class="cover-content">
          <span class="year-badge">{{ settings.eventYear }}</span>
          <h1 class="cover-title brush-font">{{ settings.eventTheme }}</h1>
          <p class="cover-subtitle">{{ settings.siteTitle }}</p>
        </div>

        <div class="scroll-hint">
          <span class="scroll-hint-text">{{
            $t("chunwan.mobile.swipeUp")
          }}</span>
          <div class="scroll-arrow">
            <svg
              width="32"
              height="32"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
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
          <h2 class="staff-title brush-font">
            {{ $t("chunwan.mobile.staff.title") }}
          </h2>

          <div class="staff-list">
            <div
              v-for="(member, index) in $tm('chunwan.mobile.staff.members')"
              :key="index"
              class="staff-item"
            >
              <span class="staff-role">{{ member.role }}</span>
              <span class="staff-name-pill">
                <template v-for="(name, nIndex) in splitNames(member.names)" :key="nIndex">
                  <span>{{ nIndex > 0 ? ' / ' : '' }}{{ name }}</span>
                </template>
              </span>
            </div>
          </div>

          <div class="art-directors">
            <h3 class="art-directors-title">
              {{ $t("chunwan.mobile.staff.artDirection") }}
            </h3>
            <div class="art-directors-list">
              <div
                v-for="(director, index) in $tm(
                  'chunwan.mobile.staff.artDirectors'
                )"
                :key="index"
                class="director-item"
              >
                <span class="director-name">{{ director.name }}</span>
                <span class="director-org">{{ director.org }}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <!-- Programs and Prizes -->
      <template v-for="(page, index) in programPages" :key="`program-${index}`">
        <!-- Program Section -->
        <section
          v-if="page.type === 'program'"
          class="snap-section program-section"
        >
          <div class="program-content">
            <div class="program-number-center">
              {{ getProgramNumber(page.program) }}
            </div>
            <div class="program-header">
              <h2 class="program-title">
                {{ formatTitle(page.program.title).main }}
                <span
                  v-if="formatTitle(page.program.title).sub"
                  class="title-sub-text"
                >
                  {{ formatTitle(page.program.title).sub }}
                </span>
              </h2>
              <p v-if="page.program.subtitle" class="program-subtitle">
                {{ page.program.subtitle }}
              </p>
            </div>

            <p v-if="page.program.description" class="program-description">
              {{ page.program.description }}
            </p>

            <div v-if="page.program.performers" class="performers-list">
              <div
                v-for="(segment, index) in splitPerformers(
                  page.program.performers
                )"
                :key="index"
                class="performer-item"
              >
                <span class="performer-names">{{ segment }}</span>
              </div>
            </div>
          </div>
        </section>

        <!-- Prize Section -->
        <section
          v-else-if="page.type === 'prize'"
          class="snap-section prize-section"
        >
          <div class="prize-content">
            <div class="prize-card">
              <div class="prize-emoji">🎁</div>
              <h2 class="prize-title brush-font">{{ page.program.title }}</h2>
              <p class="prize-text">{{ page.program.performers }}</p>
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
              <div class="finale-number">{{ getFinaleNumber() }}</div>
              <div>
                <h2 class="finale-title">
                  {{ formatTitle(finaleProgram.title).main }}
                  <span
                    v-if="formatTitle(finaleProgram.title).sub"
                    class="title-sub-text finale-sub-text"
                  >
                    {{ formatTitle(finaleProgram.title).sub }}
                  </span>
                </h2>
                <p v-if="finaleProgram.subtitle" class="finale-subtitle">
                  {{ finaleProgram.subtitle }}
                </p>
              </div>
            </div>
            <div v-if="finaleProgram.performers" class="finale-performers">
              <div
                v-for="(segment, index) in splitPerformers(
                  finaleProgram.performers
                )"
                :key="index"
                class="finale-performer"
              >
                <span class="finale-performer-names">{{ segment }}</span>
              </div>
            </div>
          </div>

          <div class="blessings">
            <p class="blessing-1 brush-font">
              {{ $t("chunwan.mobile.footer.blessing1") }}
            </p>
            <p class="blessing-2">
              {{ $t("chunwan.mobile.footer.blessing2") }}
            </p>
            <p class="blessing-3">
              {{ $t("chunwan.mobile.footer.blessing3") }}
            </p>

            <div class="blessing-emojis">
              <span>🏮</span>
              <span>🐎</span>
              <span>🧧</span>
            </div>

            <p class="copyright">{{ $t("chunwan.mobile.footer.copyright") }}</p>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted, onUnmounted, nextTick } from "vue";
import { useI18n } from "vue-i18n";
import MobileLanguageSwitcher from "./MobileLanguageSwitcher.vue";
import PageIndicator from "./PageIndicator.vue";

export default {
  name: "MobilePrograms",
  components: {
    MobileLanguageSwitcher,
    PageIndicator,
  },
  props: {
    lang: {
      type: String,
      default: "zh",
    },
    programs: {
      type: Array,
      default: () => [],
    },
    settings: {
      type: Object,
      default: () => ({}),
    },
    isLocked: {
      type: Boolean,
      default: false,
    },
    countdown: {
      type: Number,
      default: null,
    },
    unlockDate: {
      type: String,
      default: null,
    },
  },
  setup(props) {
    const { locale } = useI18n();
    const container = ref(null);
    const currentSection = ref(0);

    // Format countdown for display
    const formattedCountdown = computed(() => {
      if (props.countdown === null || props.countdown <= 0) {
        return { days: "00", hours: "00", minutes: "00", seconds: "00" };
      }

      const totalSeconds = props.countdown;
      const days = Math.floor(totalSeconds / 86400);
      const hours = Math.floor((totalSeconds % 86400) / 3600);
      const minutes = Math.floor((totalSeconds % 3600) / 60);
      const seconds = totalSeconds % 60;

      return {
        days: days.toString().padStart(2, "0"),
        hours: hours.toString().padStart(2, "0"),
        minutes: minutes.toString().padStart(2, "0"),
        seconds: seconds.toString().padStart(2, "0"),
      };
    });

    // Format unlock date for display
    const formattedUnlockDate = computed(() => {
      if (!props.unlockDate) {
        return locale.value.startsWith("zh")
          ? "解锁时间：2026年2月14日 18:30"
          : "Unlock Time: February 14, 2026 at 6:30 PM";
      }

      const date = new Date(props.unlockDate);
      const localeStr = locale.value.startsWith("zh") ? "zh-CN" : "en-US";

      return locale.value.startsWith("zh")
        ? `解锁时间：${date.toLocaleString(localeStr, {
            year: "numeric",
            month: "long",
            day: "numeric",
            hour: "2-digit",
            minute: "2-digit",
          })}`
        : `Unlock Time: ${date.toLocaleString(localeStr, {
            year: "numeric",
            month: "long",
            day: "numeric",
            hour: "numeric",
            minute: "2-digit",
          })}`;
    });

    // Check if program is the finale (last non-prize program)
    const isFinaleProgram = (program) => {
      if (program.type === "prize") return false;
      const regularPrograms = props.programs.filter((p) => p.type !== "prize");
      return (
        regularPrograms.length > 0 &&
        program === regularPrograms[regularPrograms.length - 1]
      );
    };

    // Get program display number (skip prizes)
    const getProgramNumber = (program) => {
      let count = 0;
      for (const p of props.programs) {
        if (p.type === "prize") continue;
        count++;
        if (p.id === program.id) break;
      }
      return count;
    };

    // Get finale program number
    const getFinaleNumber = () => {
      const regularPrograms = props.programs.filter((p) => p.type !== "prize");
      return regularPrograms.length;
    };

    // Split performers by | for better mobile display
    const splitPerformers = (performersText) => {
      if (!performersText) return [];
      return performersText
        .split("|")
        .map((s) => s.trim())
        .filter((s) => s.length > 0);
    };

    // Split staff names by / for better mobile display
    const splitNames = (namesText) => {
      if (!namesText) return [];
      return namesText
        .split("/")
        .map((s) => s.trim())
        .filter((s) => s.length > 0);
    };

    // Format title to split main and sub (parentheses)
    const formatTitle = (title) => {
      if (!title) return { main: "", sub: null };

      // Match content in () or （） at the end of string
      // Explanation:
      // ^(.+?) -> Capture group 1 (Main): standard chars
      // \s* -> optional whitespace
      // [（(] -> Open parenthesis (Chinese or English)
      // (.*) -> Capture group 2 (Sub): Content inside parens
      // [）)]$ -> Close parenthesis (Chinese or English) at end of string
      const regex = /^(.+?)\s*[（(](.*)[）)]$/;
      const match = title.match(regex);

      if (match) {
        return {
          main: match[1],
          sub: match[2],
        };
      }

      return { main: title, sub: null };
    };

    // Build program pages (exclude finale and prizes)
    const programPages = computed(() => {
      const pages = [];

      for (const program of props.programs) {
        if (program.type === "prize") {
          pages.push({ type: "prize", program });
        } else if (!isFinaleProgram(program)) {
          pages.push({ type: "program", program });
        }
      }
      return pages;
    });

    // Get finale program
    const finaleProgram = computed(() => {
      const regularPrograms = props.programs.filter((p) => p.type !== "prize");
      return regularPrograms.length > 0
        ? regularPrograms[regularPrograms.length - 1]
        : null;
    });

    // Total pages: countdown (if locked) + cover + staff + programs/prizes + finale
    const pages = computed(() => {
      const basePages = [
        { type: "cover" },
        { type: "staff" },
        ...programPages.value,
        { type: "finale" },
      ];
      // Only add countdown page if locked and countdown is available
      if (props.isLocked && props.countdown !== null) {
        return [{ type: "countdown" }, ...basePages];
      }
      return basePages;
    });

    // Scroll to section
    const scrollToSection = (index) => {
      if (!container.value) return;
      const sections = container.value.querySelectorAll(".snap-section");
      sections[index]?.scrollIntoView({
        behavior: "smooth",
        block: "start",
      });
    };

    // Setup intersection observer for animations
    let observer = null;

    const setupObserver = () => {
      if (!container.value) return;

      const sections = container.value.querySelectorAll(".snap-section");

      // Make first section visible immediately
      if (sections[0]) {
        sections[0].classList.add("visible");
      }

      observer = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              entry.target.classList.add("visible");

              // Update current section
              const index = Array.from(sections).indexOf(entry.target);
              if (index !== -1) {
                currentSection.value = index;
              }
            }
          });
        },
        {
          root: container.value,
          threshold: 0.3,
        }
      );

      sections.forEach((section) => observer.observe(section));
    };

    onMounted(async () => {
      await nextTick();
      setupObserver();
    });

    onUnmounted(() => {
      if (observer) {
        observer.disconnect();
      }
    });

    return {
      container,
      currentSection,
      pages,
      programPages,
      finaleProgram,
      formattedCountdown,
      formattedUnlockDate,
      scrollToSection,
      getProgramNumber,
      getFinaleNumber,
      splitPerformers,
      splitNames,
      formatTitle,
    };
  },
};
</script>

<style scoped>
/* Brush font */
.brush-font {
  font-family: "Ma Shan Zheng", cursive;
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

/* Locked state - disable scrolling */
.scroll-locked {
  overflow: hidden;
  scroll-snap-type: none;
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
  padding-right: calc(1.5rem + 1rem);
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
  background: linear-gradient(
    to bottom,
    rgba(127, 29, 29, 0.6),
    transparent,
    rgba(127, 29, 29, 0.8)
  );
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
  0%,
  100% {
    opacity: 0.5;
  }
  50% {
    opacity: 1;
  }
}

@keyframes bounceUp {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

/* Staff section */
.staff-section {
  background: linear-gradient(
    135deg,
    rgba(127, 29, 29, 0.9),
    rgba(153, 27, 27, 0.9)
  );
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
  flex-direction: column;
  gap: 0.25rem;
  font-size: 1rem;
  padding: 0.5rem;
  background: rgba(0, 0, 0, 0.2);
  border-radius: 0.5rem;
}

.staff-role {
  font-size: 0.9rem;
  color: #f59e0b;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  opacity: 0.9;
}

.staff-names-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.staff-name-pill {
  color: #fef3c7;
  font-weight: 500;
}

.art-directors {
  margin-top: 2rem;
  padding-top: 1.5rem;
  border-top: 1px solid rgba(245, 158, 11, 0.3);
}

.art-directors-title {
  margin-bottom: 1rem;
  font-size: 1.125rem;
  font-weight: 600;
  color: #fbbf24;
  text-align: center;
}

.art-directors-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.director-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  background: rgba(0, 0, 0, 0.2);
  padding: 0.5rem;
  border-radius: 0.5rem;
}

.director-name {
  color: #fef3c7;
  font-weight: 600;
  font-size: 1.1rem;
}

.director-org {
  color: rgba(254, 243, 199, 0.7);
  font-size: 0.9rem;
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
  margin-bottom: 1rem;
}

.program-number-center {
  display: flex;
  width: 3.5rem;
  height: 3.5rem;
  margin: 0 auto 1rem;
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
  font-size: 1.25rem;
  line-height: 1.3;
  font-weight: 700;
  color: #fef3c7;
  margin-bottom: 0.25rem;
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
  background: radial-gradient(
    ellipse at center,
    rgba(127, 29, 29, 1),
    rgba(69, 10, 10, 1)
  );
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
  box-shadow: 0 0 30px rgba(245, 158, 11, 0.3), 0 0 60px rgba(245, 158, 11, 0.1);
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
  margin-bottom: 0.5rem;
  font-size: 1.25rem;
  font-weight: 700;
  color: #fef3c7;
}

/* Finale section */
.finale-section {
  background: linear-gradient(
    180deg,
    rgba(127, 29, 29, 0.95),
    rgba(69, 10, 10, 1)
  );
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

/* Countdown section */
.countdown-section {
  background: linear-gradient(to bottom, #7f1d1d, #991b1b, #7f1d1d);
}

.countdown-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  text-align: center;
}

.countdown-icon {
  font-size: 4rem;
  margin-bottom: 1.5rem;
  animation: swing 3s ease-in-out infinite;
}

@keyframes swing {
  0%,
  100% {
    transform: rotate(-5deg);
  }
  50% {
    transform: rotate(5deg);
  }
}

.countdown-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #fbbf24;
  margin-bottom: 1rem;
}

.unlock-date {
  font-size: 1rem;
  color: rgba(253, 230, 138, 0.9);
  margin-bottom: 2rem;
}

.countdown-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 2rem;
}

.countdown-unit {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 60px;
}

.countdown-number {
  font-family: "Courier New", monospace;
  font-size: 2.5rem;
  font-weight: 700;
  color: #fbbf24;
  text-shadow: 0 0 20px rgba(245, 158, 11, 0.5);
  line-height: 1;
}

.countdown-label {
  font-size: 0.75rem;
  color: #fcd34d;
  margin-top: 0.25rem;
}

.countdown-separator {
  font-size: 1.5rem;
  font-weight: 700;
  color: #f59e0b;
  margin: 0 0.25rem;
}

.countdown-footer {
  display: flex;
  justify-content: center;
  gap: 1rem;
  font-size: 1.5rem;
}

.title-sub-text {
  display: block;
  font-size: 0.75em;
  font-weight: 500;
  opacity: 0.9;
  margin-top: 0.1rem;
}

.finale-sub-text {
  color: #fbbf24;
}
</style>
