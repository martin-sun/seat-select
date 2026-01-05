<template>
  <div class="seats-management">
    <div class="page-header">
      <h1>座位管理</h1>
      <p class="subtitle">管理活动座位状态</p>
    </div>

    <!-- Event Selector -->
    <div class="event-selector">
      <label>选择活动：</label>
      <select v-model="selectedEventId" @change="loadSeats">
        <option value="">请选择活动</option>
        <option v-for="event in events" :key="event.id" :value="event.id">
          {{ event.name }} - {{ formatDate(event.show_time) }}
        </option>
      </select>
    </div>

    <div v-if="!selectedEventId" class="empty-state">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
          d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
      </svg>
      <p>请先选择一个活动</p>
    </div>

    <div v-else-if="loading" class="loading-state">
      <div class="spinner"></div>
      <span>加载座位数据...</span>
    </div>

    <template v-else>
      <!-- Stats Overview -->
      <div class="stats-grid">
        <div v-for="(zoneStat, zoneName) in stats" :key="zoneName" class="zone-stat-card">
          <div class="zone-header">
            <span class="zone-name" :style="{ color: getZoneColor(zoneName) }">{{ zoneName }}</span>
            <span class="zone-total">共 {{ zoneStat.total }} 座</span>
          </div>
          <div class="zone-bars">
            <div class="bar-item">
              <span class="bar-label">可用</span>
              <div class="bar-container">
                <div class="bar available" :style="{ width: getPercent(zoneStat.available, zoneStat.total) }"></div>
              </div>
              <span class="bar-value">{{ zoneStat.available }}</span>
            </div>
            <div class="bar-item">
              <span class="bar-label">预订</span>
              <div class="bar-container">
                <div class="bar reserved" :style="{ width: getPercent(zoneStat.reserved, zoneStat.total) }"></div>
              </div>
              <span class="bar-value">{{ zoneStat.reserved }}</span>
            </div>
            <div class="bar-item">
              <span class="bar-label">已售</span>
              <div class="bar-container">
                <div class="bar sold" :style="{ width: getPercent(zoneStat.sold, zoneStat.total) }"></div>
              </div>
              <span class="bar-value">{{ zoneStat.sold }}</span>
            </div>
            <div class="bar-item">
              <span class="bar-label">禁用</span>
              <div class="bar-container">
                <div class="bar unavailable" :style="{ width: getPercent(zoneStat.unavailable, zoneStat.total) }"></div>
              </div>
              <span class="bar-value">{{ zoneStat.unavailable || 0 }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Batch Actions -->
      <div class="batch-actions">
        <div class="selection-info">
          <span v-if="selectedSeats.length > 0">已选择 {{ selectedSeats.length }} 个座位</span>
          <span v-else>点击座位进行选择，或使用下方筛选器</span>
        </div>
        <div class="action-buttons">
          <button 
            class="action-btn"
            :disabled="selectedSeats.length === 0"
            @click="batchSetStatus('available')"
          >
            设为可用
          </button>
          <button 
            class="action-btn"
            :disabled="selectedSeats.length === 0"
            @click="batchSetStatus('unavailable')"
          >
            设为禁用
          </button>
          <button 
            class="clear-btn"
            :disabled="selectedSeats.length === 0"
            @click="clearSelection"
          >
            清除选择
          </button>
        </div>

        <div class="divider"></div>

        <div class="zone-action">
          <label>更改区域：</label>
          <select v-model="selectedZoneId" :disabled="selectedSeats.length === 0">
            <option value="">请选择区域</option>
            <option v-for="zone in availableZones" :key="zone.id" :value="zone.id">
              {{ zone.name }}
            </option>
          </select>
          <button 
            class="zone-btn"
            :disabled="selectedSeats.length === 0 || !selectedZoneId"
            @click="batchSetZone"
          >
            确认更改
          </button>
        </div>
      </div>

      <!-- Filters -->
      <div class="filters">
        <div class="filter-group">
          <label>按区域筛选：</label>
          <div class="filter-options">
            <button 
              v-for="zone in zones" 
              :key="zone"
              :class="['filter-btn', { active: filterZone === zone }]"
              :style="filterZone === zone ? { borderColor: getZoneColor(zone), color: getZoneColor(zone) } : {}"
              @click="toggleZoneFilter(zone)"
            >
              {{ zone }}
            </button>
          </div>
        </div>
        <div class="filter-group">
          <label>按状态筛选：</label>
          <div class="filter-options">
            <button 
              v-for="status in statuses" 
              :key="status.value"
              :class="['filter-btn', { active: filterStatus === status.value }]"
              @click="toggleStatusFilter(status.value)"
            >
              {{ status.label }}
            </button>
          </div>
        </div>
        <button class="select-filtered-btn" @click="selectFiltered">
          选择筛选结果 ({{ filteredSeats.length }})
        </button>
      </div>

      <!-- Seats Grid -->
      <div class="seats-container">
        <div class="seats-grid">
          <div 
            v-for="seat in filteredSeats" 
            :key="seat.id"
            :class="['seat-item', seat.status, { selected: isSeatSelected(seat.id) }]"
            :style="{ borderColor: getZoneColor(seat.zone) }"
            @click="toggleSeatSelection(seat)"
          >
            <span class="seat-label">{{ seat.row }}{{ seat.col }}</span>
            <span class="seat-status">{{ getStatusText(seat.status) }}</span>
          </div>
        </div>

        <div v-if="filteredSeats.length === 0" class="empty-seats">
          <p>没有符合筛选条件的座位</p>
        </div>
      </div>

      <!-- Legend -->
      <div class="legend">
        <div class="legend-item">
          <span class="legend-dot available"></span>
          <span>可用</span>
        </div>
        <div class="legend-item">
          <span class="legend-dot reserved"></span>
          <span>已预订</span>
        </div>
        <div class="legend-item">
          <span class="legend-dot sold"></span>
          <span>已售出</span>
        </div>
        <div class="legend-item">
          <span class="legend-dot unavailable"></span>
          <span>禁用</span>
        </div>
      </div>

      <!-- Custom Confirmation Modal -->
      <ConfirmModal
        :show="confirmModal.show"
        :title="confirmModal.title"
        :message="confirmModal.message"
        :type="confirmModal.type"
        @confirm="handleModalConfirm"
        @cancel="closeModal"
      />
    </template>
  </div>
</template>

<script>
import { getAdminEvents, getAdminSeats, batchUpdateSeatStatus, batchUpdateSeatZone } from '@/supabase'
import { toast } from '@/utils/toast'
import ConfirmModal from '@/components/ConfirmModal.vue'

export default {
  name: 'SeatsManagement',
  components: {
    ConfirmModal
  },
  data() {
    return {
      events: [],
      selectedEventId: '',
      seats: [],
      stats: {},
      loading: false,
      selectedSeats: [],
      filterZone: null,
      filterStatus: null,
      statuses: [
        { value: 'available', label: '可用' },
        { value: 'reserved', label: '已预订' },
        { value: 'sold', label: '已售出' },
        { value: 'unavailable', label: '禁用' }
      ],
      selectedZoneId: '',
      confirmModal: {
        show: false,
        title: '',
        message: '',
        type: 'primary',
        action: null
      }
    }
  },
  computed: {
    zones() {
      return [...new Set(this.seats.map(s => s.zone))]
    },
    filteredSeats() {
      return this.seats.filter(seat => {
        if (this.filterZone && seat.zone !== this.filterZone) return false
        if (this.filterStatus && seat.status !== this.filterStatus) return false
        return true
      })
    },
    availableZones() {
      const event = this.events.find(e => e.id === this.selectedEventId)
      if (!event || !event.zone_config) {
        // Fallback to zones from seats if no config
        return [...new Set(this.seats.map(s => s.zone))].map(id => ({ id, name: id }))
      }
      return event.zone_config.map(c => ({
        id: c.zone,
        name: c.name || c.zone
      }))
    }
  },
  mounted() {
    this.loadEvents()
  },
  methods: {
    async loadEvents() {
      try {
        this.events = await getAdminEvents()
        if (this.events.length === 1) {
          this.selectedEventId = this.events[0].id
          this.loadSeats()
        }
      } catch (err) {
        console.error('Failed to load events:', err)
      }
    },
    async loadSeats(silent = false) {
      if (!this.selectedEventId) {
        this.seats = []
        this.stats = {}
        return
      }

      if (!silent) this.loading = true
      
      try {
        const result = await getAdminSeats(this.selectedEventId)
        this.seats = result.seats
        this.stats = result.stats
        
        // If it was silent, we should probably clear selection? 
        // Actually keep it if possible, but for simplicity let's clear it
        // this.selectedSeats = [] 
      } catch (err) {
        console.error('Failed to load seats:', err)
      } finally {
        if (!silent) this.loading = false
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return ''
      return new Date(dateStr).toLocaleDateString('zh-CN', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    },
    getZoneColor(zone) {
      const colors = {
        'green': '#4caf50',
        'pink': '#e91e63',
        'purple': '#9c27b0',
        'red': '#f44336',
        'Green Zone': '#4caf50',
        'Pink Zone': '#e91e63',
        'Purple Zone': '#9c27b0',
        'Red Zone': '#f44336'
      }
      return colors[zone] || '#808080'
    },
    getPercent(value, total) {
      if (!total) return '0%'
      return `${Math.round((value / total) * 100)}%`
    },
    getStatusText(status) {
      const map = {
        available: '可用',
        reserved: '预订',
        sold: '已售',
        unavailable: '禁用'
      }
      return map[status] || status
    },
    isSeatSelected(seatId) {
      return this.selectedSeats.includes(seatId)
    },
    toggleSeatSelection(seat) {
      const idx = this.selectedSeats.indexOf(seat.id)
      if (idx === -1) {
        this.selectedSeats.push(seat.id)
      } else {
        this.selectedSeats.splice(idx, 1)
      }
    },
    clearSelection() {
      this.selectedSeats = []
    },
    toggleZoneFilter(zone) {
      this.filterZone = this.filterZone === zone ? null : zone
    },
    toggleStatusFilter(status) {
      this.filterStatus = this.filterStatus === status ? null : status
    },
    selectFiltered() {
      this.selectedSeats = this.filteredSeats.map(s => s.id)
    },
    async batchSetStatus(status) {
      if (this.selectedSeats.length === 0) return
      
      const statusText = this.getStatusText(status)
      this.openModal({
        title: '操作确认',
        message: `确定要将选中的 ${this.selectedSeats.length} 个座位设为"${statusText}"吗？`,
        action: async () => {
          try {
            const count = this.selectedSeats.length
            await batchUpdateSeatStatus(this.selectedSeats, status)
            await this.loadSeats(true) // Silent refresh
            this.selectedSeats = [] // Clear after success
            toast.success(`已成功更新 ${count} 个座位状态`)
          } catch (err) {
            console.error('Failed to update seats:', err)
            toast.error('操作失败，请重试')
          }
        }
      })
    },
    async batchSetZone() {
      if (this.selectedSeats.length === 0 || !this.selectedZoneId) return
      
      const zoneName = this.availableZones.find(z => z.id === this.selectedZoneId)?.name || this.selectedZoneId
      this.openModal({
        title: '更改区域确认',
        message: `确定要将选中的 ${this.selectedSeats.length} 个座位更改为区域 "${zoneName}" 吗？`,
        action: async () => {
          try {
            const count = this.selectedSeats.length
            await batchUpdateSeatZone(this.selectedSeats, this.selectedZoneId)
            await this.loadSeats(true) // Silent refresh
            this.selectedSeats = [] // Clear after success
            this.selectedZoneId = ''
            toast.success(`已成功更改 ${count} 个座位的区域`)
          } catch (err) {
            console.error('Failed to update seat zones:', err)
            toast.error('操作失败，请重试: ' + err.message)
          }
        }
      })
    },
    openModal({ title, message, action, type = 'primary' }) {
      this.confirmModal = {
        show: true,
        title,
        message,
        action,
        type
      }
    },
    closeModal() {
      this.confirmModal.show = false
    },
    async handleModalConfirm() {
      const action = this.confirmModal.action
      this.closeModal()
      if (action) {
        await action()
      }
    }
  }
}
</script>

<style scoped>
.seats-management {
  color: #fff;
}

.page-header {
  margin-bottom: 24px;
}

.page-header h1 {
  font-size: 28px;
  font-weight: 600;
  margin: 0 0 8px;
}

.subtitle {
  color: rgba(255, 255, 255, 0.5);
  font-size: 14px;
  margin: 0;
}

/* Event Selector */
.event-selector {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 24px;
  padding: 16px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
}

.event-selector label {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.7);
}

.event-selector select {
  flex: 1;
  max-width: 400px;
  padding: 10px 14px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 14px;
  cursor: pointer;
}

.event-selector select:focus {
  outline: none;
  border-color: #e94560;
}

/* Loading & Empty States */
.loading-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px 40px;
  color: rgba(255, 255, 255, 0.4);
  background: rgba(255, 255, 255, 0.02);
  border-radius: 12px;
}

.loading-state {
  flex-direction: row;
  gap: 12px;
}

.spinner {
  width: 24px;
  height: 24px;
  border: 2px solid rgba(255, 255, 255, 0.1);
  border-top-color: #e94560;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.empty-state svg {
  width: 48px;
  height: 48px;
  margin-bottom: 16px;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.zone-stat-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 20px;
}

.zone-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 16px;
}

.zone-name {
  font-size: 16px;
  font-weight: 600;
}

.zone-total {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.5);
}

.zone-bars {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.bar-item {
  display: flex;
  align-items: center;
  gap: 10px;
}

.bar-label {
  width: 36px;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
}

.bar-container {
  flex: 1;
  height: 8px;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 4px;
  overflow: hidden;
}

.bar {
  height: 100%;
  border-radius: 4px;
  transition: width 0.3s ease;
}

.bar.available { background: #4caf50; }
.bar.reserved { background: #ff9800; }
.bar.sold { background: #2196f3; }
.bar.unavailable { background: #9e9e9e; }

.bar-value {
  width: 32px;
  text-align: right;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.7);
}

/* Batch Actions */
.batch-actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  margin-bottom: 16px;
  flex-wrap: wrap;
  gap: 12px;
}

.selection-info {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.6);
}

.action-buttons {
  display: flex;
  gap: 8px;
}

.action-btn {
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid rgba(76, 175, 80, 0.4);
  background: rgba(76, 175, 80, 0.15);
  color: #4caf50;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.action-btn:hover:not(:disabled) {
  background: rgba(76, 175, 80, 0.25);
}

.action-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.clear-btn {
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: transparent;
  color: rgba(255, 255, 255, 0.6);
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.clear-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.05);
}

.clear-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.divider {
  width: 1px;
  height: 24px;
  background: rgba(255, 255, 255, 0.1);
  margin: 0 8px;
}

.zone-action {
  display: flex;
  align-items: center;
  gap: 8px;
}

.zone-action label {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
}

.zone-action select {
  padding: 6px 12px;
  border-radius: 6px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(0, 0, 0, 0.2);
  color: #fff;
  font-size: 13px;
  cursor: pointer;
}

.zone-btn {
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid rgba(33, 150, 243, 0.4);
  background: rgba(33, 150, 243, 0.15);
  color: #2196f3;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.zone-btn:hover:not(:disabled) {
  background: rgba(33, 150, 243, 0.25);
}

.zone-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

/* Filters */
.filters {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  margin-bottom: 24px;
}

.filter-group {
  display: flex;
  align-items: center;
  gap: 10px;
}

.filter-group label {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
}

.filter-options {
  display: flex;
  gap: 6px;
}

.filter-btn {
  padding: 6px 12px;
  border-radius: 6px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: transparent;
  color: rgba(255, 255, 255, 0.6);
  font-size: 12px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.filter-btn:hover {
  background: rgba(255, 255, 255, 0.05);
}

.filter-btn.active {
  background: rgba(233, 69, 96, 0.15);
  border-color: rgba(233, 69, 96, 0.4);
  color: #e94560;
}

.select-filtered-btn {
  margin-left: auto;
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid rgba(33, 150, 243, 0.4);
  background: rgba(33, 150, 243, 0.15);
  color: #2196f3;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.select-filtered-btn:hover {
  background: rgba(33, 150, 243, 0.25);
}

/* Seats Grid */
.seats-container {
  background: rgba(255, 255, 255, 0.02);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 24px;
  margin-bottom: 16px;
}

.seats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(64px, 1fr));
  gap: 8px;
}

.seat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 8px;
  border-radius: 8px;
  border: 2px solid transparent;
  background: rgba(255, 255, 255, 0.03);
  cursor: pointer;
  transition: all 0.2s ease;
}

.seat-item:hover {
  background: rgba(255, 255, 255, 0.08);
  transform: scale(1.05);
}

.seat-item.selected {
  background: rgba(233, 69, 96, 0.2) !important;
  box-shadow: 0 0 0 2px #e94560;
}

.seat-item.available {
  background: rgba(76, 175, 80, 0.1);
}

.seat-item.reserved {
  background: rgba(255, 152, 0, 0.1);
}

.seat-item.sold {
  background: rgba(33, 150, 243, 0.1);
}

.seat-item.unavailable {
  background: rgba(158, 158, 158, 0.1);
  opacity: 0.6;
}

.seat-label {
  font-size: 12px;
  font-weight: 500;
}

.seat-status {
  font-size: 10px;
  color: rgba(255, 255, 255, 0.5);
  margin-top: 2px;
}

.empty-seats {
  text-align: center;
  padding: 40px;
  color: rgba(255, 255, 255, 0.4);
}

/* Legend */
.legend {
  display: flex;
  gap: 24px;
  justify-content: center;
  padding: 16px;
  background: rgba(255, 255, 255, 0.02);
  border-radius: 8px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.6);
}

.legend-dot {
  width: 12px;
  height: 12px;
  border-radius: 3px;
}

.legend-dot.available { background: #4caf50; }
.legend-dot.reserved { background: #ff9800; }
.legend-dot.sold { background: #2196f3; }
.legend-dot.unavailable { background: #9e9e9e; }
</style>
