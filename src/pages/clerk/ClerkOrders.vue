<template>
  <div class="clerk-orders">
    <div class="page-header">
      <h1>订单管理</h1>
      <p class="subtitle">查看和管理取票订单</p>
    </div>

    <!-- Filters -->
    <div class="filters-bar">
      <div class="search-box">
        <svg class="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
        </svg>
        <input
          v-model="searchQuery"
          type="text"
          placeholder="搜索订单（姓名、邮箱、电话）..."
          @input="debouncedSearch"
        />
      </div>

      <div class="filter-tabs">
        <button
          v-for="tab in statusTabs"
          :key="tab.value"
          :class="['filter-tab', { active: currentStatus === tab.value }]"
          @click="filterByStatus(tab.value)"
        >
          {{ tab.label }}
          <span v-if="tab.count !== undefined" class="tab-count">{{ tab.count }}</span>
        </button>
        <button class="export-btn" @click="exportToCSV" :disabled="loading || orders.length === 0">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4" />
          </svg>
          导出 CSV
        </button>
      </div>
    </div>

    <!-- Stats Cards -->
    <div class="stats-grid">
      <div class="stat-card paid">
        <div class="stat-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.paid }}</span>
          <span class="stat-label">待取票</span>
        </div>
      </div>
      <div class="stat-card picked-up">
        <div class="stat-icon">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M5 13l4 4L19 7" />
          </svg>
        </div>
        <div class="stat-info">
          <span class="stat-value">{{ stats.pickedUp }}</span>
          <span class="stat-label">已取票</span>
        </div>
      </div>
    </div>

    <!-- Orders Table -->
    <div class="orders-table-container">
      <div v-if="loading" class="loading-state">
        <div class="spinner"></div>
        <span>加载中...</span>
      </div>

      <table v-else class="orders-table">
        <thead>
          <tr>
            <th>订单编号</th>
            <th>客户信息</th>
            <th>座位</th>
            <th>金额</th>
            <th>状态</th>
            <th>时间</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="order in orders" :key="order.id">
            <td class="order-id">
              <span class="id-text">#{{ order.id.substring(0, 8).toUpperCase() }}</span>
            </td>
            <td class="customer-info">
              <div class="customer-name">{{ order.customer_name }}</div>
              <div class="customer-contact">{{ order.customer_email }}</div>
              <div class="customer-contact">{{ order.customer_phone }}</div>
            </td>
            <td class="seats-info">
              <div class="seats-list">
                <span
                  v-for="rs in (order.reservation_seats || []).slice(0, 3)"
                  :key="rs.seat_id"
                  class="seat-tag"
                >
                  {{ formatSeat(rs.seats) }}
                </span>
                <span v-if="(order.reservation_seats || []).length > 3" class="seat-more">
                  +{{ (order.reservation_seats || []).length - 3 }}
                </span>
              </div>
            </td>
            <td class="amount">${{ order.total_amount }}</td>
            <td>
              <span :class="['status-badge', order.status]">
                {{ getStatusText(order.status) }}
              </span>
            </td>
            <td class="time-info">
              <div class="created-time">{{ formatDate(order.created_at) }}</div>
            </td>
            <td class="actions">
              <div class="action-buttons">
                <button
                  v-if="order.status === 'paid'"
                  class="action-btn pickup"
                  @click="pickUpTicket(order)"
                  :disabled="actionLoading === order.id"
                >
                  取票
                </button>
                <button
                  class="action-btn view"
                  @click="viewOrder(order)"
                >
                  详情
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>

      <div v-if="!loading && orders.length === 0" class="empty-state">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
            d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
        </svg>
        <p>暂无订单记录</p>
      </div>
    </div>

    <!-- Pagination -->
    <div v-if="totalPages > 1" class="pagination">
      <button
        class="page-btn"
        :disabled="currentPage === 1"
        @click="goToPage(currentPage - 1)"
      >
        上一页
      </button>
      <span class="page-info">第 {{ currentPage }} / {{ totalPages }} 页</span>
      <button
        class="page-btn"
        :disabled="currentPage === totalPages"
        @click="goToPage(currentPage + 1)"
      >
        下一页
      </button>
    </div>

    <!-- Order Detail Modal -->
    <div v-if="selectedOrder" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>订单详情</h2>
          <button class="close-btn" @click="closeModal">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div class="modal-body">
          <div class="detail-section">
            <h3>客户信息</h3>
            <div class="detail-grid">
              <div class="detail-item">
                <span class="label">姓名</span>
                <span class="value">{{ selectedOrder.customer_name }}</span>
              </div>
              <div class="detail-item">
                <span class="label">邮箱</span>
                <span class="value">{{ selectedOrder.customer_email }}</span>
              </div>
              <div class="detail-item">
                <span class="label">电话</span>
                <span class="value">{{ selectedOrder.customer_phone }}</span>
              </div>
            </div>
          </div>
          <div class="detail-section">
            <h3>座位信息</h3>
            <div class="seats-detail">
              <span
                v-for="rs in (selectedOrder.reservation_seats || [])"
                :key="rs.seat_id"
                class="seat-tag-lg"
              >
                {{ formatSeat(rs.seats) }}
              </span>
            </div>
          </div>
          <div class="detail-section">
            <h3>订单信息</h3>
            <div class="detail-grid">
              <div class="detail-item">
                <span class="label">订单编号</span>
                <span class="value">{{ selectedOrder.id }}</span>
              </div>
              <div class="detail-item">
                <span class="label">总金额</span>
                <span class="value amount">${{ selectedOrder.total_amount }}</span>
              </div>
              <div class="detail-item">
                <span class="label">状态</span>
                <span :class="['status-badge', selectedOrder.status]">{{ getStatusText(selectedOrder.status) }}</span>
              </div>
              <div class="detail-item">
                <span class="label">创建时间</span>
                <span class="value">{{ formatDateTime(selectedOrder.created_at) }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Password Verification Modal -->
    <div v-if="showPasswordModal" class="modal-overlay" @click.self="closePasswordModal">
      <div class="password-modal-content">
        <div class="modal-header">
          <h2>确认取票</h2>
          <button class="close-btn" @click="closePasswordModal">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div class="modal-body">
          <div class="password-info">
            <p class="order-info-text">
              确认将订单 <strong>#{{ pendingOrder?.id?.substring(0, 8).toUpperCase() }}</strong> 标记为已取票？
            </p>
            <p class="password-hint">请输入取票密码</p>
          </div>
          <div class="password-input-group">
            <input
              ref="passwordInput"
              v-model="passwordInput"
              type="password"
              class="password-input-field"
              placeholder="输入密码"
              :disabled="isVerifying"
              @keydown="handlePasswordKeydown"
              maxlength="20"
            />
            <button
              class="confirm-password-btn"
              @click="confirmPickUpWithPassword"
              :disabled="isVerifying || !passwordInput"
            >
              <span v-if="isVerifying" class="btn-spinner"></span>
              <span v-else>确认取票</span>
            </button>
          </div>
          <p v-if="passwordError" class="password-error">{{ passwordError }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getClerkReservations, pickUpTicket as pickUpTicketApi } from '@/supabase'
import { formatSeat } from '@/composables/useSeatFormat'

export default {
  name: 'ClerkOrders',
  data() {
    return {
      orders: [],
      loading: true,
      currentPage: 1,
      pageSize: 20,
      totalCount: 0,
      currentStatus: null,
      searchQuery: '',
      searchTimeout: null,
      actionLoading: null,
      selectedOrder: null,
      // Password verification modal
      showPasswordModal: false,
      pendingOrder: null,
      passwordInput: '',
      passwordError: '',
      isVerifying: false,
      stats: {
        paid: 0,
        pickedUp: 0
      }
    }
  },
  computed: {
    totalPages() {
      return Math.ceil(this.totalCount / this.pageSize)
    },
    statusTabs() {
      return [
        { label: '全部', value: null },
        { label: '待取票', value: 'paid', count: this.stats.paid },
        { label: '已取票', value: 'picked_up', count: this.stats.pickedUp }
      ]
    }
  },
  mounted() {
    this.loadOrders()
    this.loadStats()
  },
  methods: {
    formatSeat,
    async loadOrders() {
      this.loading = true
      try {
        const result = await getClerkReservations({
          page: this.currentPage,
          pageSize: this.pageSize,
          status: this.currentStatus,
          search: this.searchQuery
        })
        this.orders = result.data || []
        this.totalCount = result.count || 0
      } catch (err) {
        console.error('Failed to load orders:', err)
      } finally {
        this.loading = false
      }
    },
    async loadStats() {
      try {
        const [paid, pickedUp] = await Promise.all([
          getClerkReservations({ status: 'paid', pageSize: 1 }),
          getClerkReservations({ status: 'picked_up', pageSize: 1 })
        ])

        this.stats.paid = paid.count || 0
        this.stats.pickedUp = pickedUp.count || 0
      } catch (err) {
        console.error('Failed to load stats:', err)
      }
    },
    debouncedSearch() {
      if (this.searchTimeout) clearTimeout(this.searchTimeout)
      this.searchTimeout = setTimeout(() => {
        this.currentPage = 1
        this.loadOrders()
      }, 300)
    },
    filterByStatus(status) {
      this.currentStatus = status
      this.currentPage = 1
      this.loadOrders()
    },
    goToPage(page) {
      this.currentPage = page
      this.loadOrders()
    },
    async pickUpTicket(order) {
      // Show password modal instead of direct confirm
      this.pendingOrder = order
      this.passwordInput = ''
      this.passwordError = ''
      this.showPasswordModal = true
      // Focus on password input after modal is shown
      this.$nextTick(() => {
        const input = document.querySelector('.password-input-field')
        if (input) input.focus()
      })
    },
    async confirmPickUpWithPassword() {
      const pickupPassword = process.env.VUE_APP_CLERK_PICKUP_PASSWORD

      if (!pickupPassword) {
        this.passwordError = '系统错误：未配置取票密码，请联系管理员'
        console.error('VUE_APP_CLERK_PICKUP_PASSWORD environment variable is not set')
        return
      }

      if (this.passwordInput !== pickupPassword) {
        this.passwordError = '密码错误'
        return
      }

      this.isVerifying = true
      try {
        await pickUpTicketApi(this.pendingOrder.id)
        await this.loadOrders()
        await this.loadStats()
        this.closePasswordModal()
      } catch (err) {
        console.error('Failed to mark as picked up:', err)
        this.passwordError = '取票失败，请重试'
      } finally {
        this.isVerifying = false
      }
    },
    closePasswordModal() {
      this.showPasswordModal = false
      this.pendingOrder = null
      this.passwordInput = ''
      this.passwordError = ''
    },
    handlePasswordKeydown(event) {
      if (event.key === 'Enter') {
        this.confirmPickUpWithPassword()
      } else if (event.key === 'Escape') {
        this.closePasswordModal()
      }
    },
    viewOrder(order) {
      this.selectedOrder = order
    },
    closeModal() {
      this.selectedOrder = null
    },
    getStatusText(status) {
      const map = {
        paid: '待取票',
        picked_up: '已取票'
      }
      return map[status] || status
    },
    formatDate(dateStr) {
      if (!dateStr) return ''
      const date = new Date(dateStr)
      return date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit' })
    },
    formatDateTime(dateStr) {
      if (!dateStr) return ''
      const date = new Date(dateStr)
      return date.toLocaleString('zh-CN')
    },
    exportToCSV() {
      if (this.orders.length === 0) return

      const headers = ['订单编号', '客户姓名', '客户邮箱', '客户电话', '座位', '金额', '状态', '创建时间']

      const rows = this.orders.map(order => [
        order.id.substring(0, 8).toUpperCase(),
        order.customer_name,
        order.customer_email,
        order.customer_phone,
        (order.reservation_seats || []).map(rs => formatSeat(rs.seats)).join('; '),
        order.total_amount,
        this.getStatusText(order.status),
        this.formatDateTime(order.created_at)
      ])

      const csvContent = [
        headers.join(','),
        ...rows.map(row => row.map(cell => {
          // 如果包含逗号、引号或换行符，用引号包裹并转义引号
          const cellStr = String(cell || '')
          if (cellStr.includes(',') || cellStr.includes('"') || cellStr.includes('\n')) {
            return `"${cellStr.replace(/"/g, '""')}"`
          }
          return cellStr
        }).join(','))
      ].join('\n')

      // 添加 BOM 以支持 Excel 正确识别中文
      const BOM = '\uFEFF'
      const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' })

      const url = URL.createObjectURL(blob)
      const link = document.createElement('a')
      link.href = url

      const now = new Date()
      const dateStr = now.toISOString().slice(0, 10)
      const timeStr = now.toTimeString().slice(0, 5).replace(':', '-')
      link.download = `订单数据_${dateStr}_${timeStr}.csv`

      document.body.appendChild(link)
      link.click()
      document.body.removeChild(link)
      URL.revokeObjectURL(url)
    }
  }
}
</script>

<style scoped>
.clerk-orders {
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

/* Filters */
.filters-bar {
  display: flex;
  gap: 16px;
  margin-bottom: 24px;
  flex-wrap: wrap;
}

.search-box {
  position: relative;
  flex: 1;
  min-width: 280px;
}

.search-icon {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  width: 18px;
  height: 18px;
  color: rgba(255, 255, 255, 0.4);
}

.search-box input {
  width: 100%;
  padding: 12px 16px 12px 44px;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 14px;
}

.search-box input::placeholder {
  color: rgba(255, 255, 255, 0.3);
}

.search-box input:focus {
  outline: none;
  border-color: #4CAF50;
}

.filter-tabs {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.filter-tab {
  padding: 10px 16px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.03);
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 6px;
}

.filter-tab:hover {
  background: rgba(255, 255, 255, 0.08);
  color: #fff;
}

.filter-tab.active {
  background: rgba(76, 175, 80, 0.15);
  border-color: rgba(76, 175, 80, 0.4);
  color: #4CAF50;
}

.tab-count {
  font-size: 12px;
  padding: 2px 6px;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
}

.filter-tab.active .tab-count {
  background: rgba(76, 175, 80, 0.3);
}

.export-btn {
  padding: 10px 16px;
  border-radius: 8px;
  border: 1px solid rgba(76, 175, 80, 0.4);
  background: rgba(76, 175, 80, 0.15);
  color: #4CAF50;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 6px;
  margin-left: auto;
}

.export-btn:hover:not(:disabled) {
  background: rgba(76, 175, 80, 0.25);
  transform: translateY(-1px);
}

.export-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.export-btn svg {
  width: 16px;
  height: 16px;
}

/* Stats Grid */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.stat-icon svg {
  width: 24px;
  height: 24px;
}

.stat-card.paid .stat-icon {
  background: rgba(76, 175, 80, 0.15);
  color: #4caf50;
}

.stat-card.picked-up .stat-icon {
  background: rgba(156, 39, 176, 0.15);
  color: #9c27b0;
}

.stat-info {
  display: flex;
  flex-direction: column;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
}

.stat-label {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.5);
}

/* Orders Table */
.orders-table-container {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  overflow: hidden;
}

.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 60px;
  color: rgba(255, 255, 255, 0.5);
}

.spinner {
  width: 24px;
  height: 24px;
  border: 2px solid rgba(255, 255, 255, 0.1);
  border-top-color: #4CAF50;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.orders-table {
  width: 100%;
  border-collapse: collapse;
}

.orders-table th {
  text-align: left;
  padding: 14px 16px;
  font-size: 13px;
  font-weight: 500;
  color: rgba(255, 255, 255, 0.5);
  background: rgba(255, 255, 255, 0.02);
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.orders-table td {
  padding: 14px 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.03);
  vertical-align: top;
}

.orders-table tr:hover {
  background: rgba(255, 255, 255, 0.02);
}

.order-id .id-text {
  font-family: monospace;
  font-size: 13px;
  color: #4CAF50;
}

.customer-info .customer-name {
  font-weight: 500;
  margin-bottom: 4px;
}

.customer-info .customer-contact {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
}

.seats-list {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}

.seat-tag {
  font-size: 11px;
  padding: 3px 6px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 4px;
  color: rgba(255, 255, 255, 0.8);
}

.seat-more {
  font-size: 11px;
  color: rgba(255, 255, 255, 0.5);
}

.amount {
  font-weight: 600;
  color: #4caf50;
}

.status-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.status-badge.paid {
  background: rgba(76, 175, 80, 0.15);
  color: #4caf50;
}

.status-badge.picked_up {
  background: rgba(156, 39, 176, 0.15);
  color: #9c27b0;
}

.time-info {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.7);
}

.action-buttons {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.action-btn {
  padding: 6px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  border: none;
  transition: all 0.3s ease;
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.action-btn.pickup {
  background: rgba(76, 175, 80, 0.15);
  color: #4caf50;
}

.action-btn.pickup:hover:not(:disabled) {
  background: rgba(76, 175, 80, 0.25);
}

.action-btn.view {
  background: rgba(33, 150, 243, 0.15);
  color: #2196f3;
}

.action-btn.view:hover {
  background: rgba(33, 150, 243, 0.25);
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px;
  color: rgba(255, 255, 255, 0.4);
}

.empty-state svg {
  width: 48px;
  height: 48px;
  margin-bottom: 16px;
}

/* Pagination */
.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  margin-top: 24px;
}

.page-btn {
  padding: 8px 16px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.page-btn:hover:not(:disabled) {
  background: rgba(255, 255, 255, 0.1);
}

.page-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.page-info {
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: #1a1a2e;
  border-radius: 16px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.modal-header h2 {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
}

.close-btn {
  width: 32px;
  height: 32px;
  border-radius: 8px;
  border: none;
  background: rgba(255, 255, 255, 0.05);
  color: rgba(255, 255, 255, 0.6);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.close-btn svg {
  width: 18px;
  height: 18px;
}

.modal-body {
  padding: 24px;
}

.detail-section {
  margin-bottom: 24px;
}

.detail-section:last-child {
  margin-bottom: 0;
}

.detail-section h3 {
  font-size: 14px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.5);
  margin: 0 0 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: 12px;
}

.detail-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.detail-item .label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.4);
}

.detail-item .value {
  font-size: 14px;
  color: #fff;
  word-break: break-all;
}

.detail-item .value.amount {
  font-size: 18px;
  font-weight: 600;
  color: #4caf50;
}

.seats-detail {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.seat-tag-lg {
  padding: 8px 12px;
  background: rgba(255, 255, 255, 0.08);
  border-radius: 8px;
  font-size: 13px;
}

/* Password Verification Modal */
.password-modal-content {
  background: #1a1a2e;
  border-radius: 16px;
  width: 100%;
  max-width: 420px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.password-info {
  margin-bottom: 24px;
}

.order-info-text {
  color: #fff;
  font-size: 15px;
  margin: 0 0 12px;
}

.order-info-text strong {
  color: #4CAF50;
  font-family: monospace;
}

.password-hint {
  color: rgba(255, 255, 255, 0.6);
  font-size: 13px;
  margin: 0;
}

.password-input-group {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.password-input-field {
  flex: 1;
  padding: 12px 16px;
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 15px;
  transition: all 0.3s ease;
}

.password-input-field::placeholder {
  color: rgba(255, 255, 255, 0.3);
}

.password-input-field:focus {
  outline: none;
  border-color: #4CAF50;
  background: rgba(255, 255, 255, 0.08);
}

.password-input-field:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.confirm-password-btn {
  padding: 12px 24px;
  border-radius: 10px;
  border: none;
  background: linear-gradient(135deg, #4CAF50 0%, #8BC34A 100%);
  color: white;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-width: 100px;
}

.confirm-password-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 16px rgba(76, 175, 80, 0.3);
}

.confirm-password-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  transform: none;
}

.btn-spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: white;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

.password-error {
  color: #ff6b6b;
  font-size: 13px;
  margin: 0;
  padding: 10px 12px;
  background: rgba(255, 107, 107, 0.1);
  border-radius: 8px;
}
</style>
