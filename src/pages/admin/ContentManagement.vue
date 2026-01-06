<template>
  <div class="content-management">
    <div class="page-header">
      <h1>内容管理</h1>
      <p class="subtitle">管理首页展示内容</p>
    </div>

    <!-- Tabs -->
    <div class="tabs">
      <button 
        v-for="tab in tabs" 
        :key="tab.key"
        :class="['tab-btn', { active: activeTab === tab.key }]"
        @click="activeTab = tab.key"
      >
        <component :is="tab.icon" class="tab-icon" />
        {{ tab.label }}
      </button>
    </div>

    <!-- Settings Section -->
    <div v-if="activeTab === 'settings'" class="content-section">
      <div class="section-header">
        <h2>全局设置</h2>
        <button 
          class="save-btn" 
          @click="saveSettings"
          :disabled="saving"
        >
          {{ saving ? '保存中...' : '保存更改' }}
        </button>
      </div>

      <div v-if="loadingSettings" class="loading-state">
        <div class="spinner"></div>
        <span>加载中...</span>
      </div>

      <form v-else class="settings-form">
        <div class="form-section">
          <h3>网站基本信息</h3>
          <div class="form-grid">
            <div class="form-group">
              <label>站点标题（中文）</label>
              <input v-model="settings.site_title" type="text" placeholder="如：2026年RBC新春之夜萨斯卡通春晚" />
            </div>
            <div class="form-group">
              <label>站点标题（英文）</label>
              <input v-model="settings.site_title_en" type="text" placeholder="如：2026 RBC New Year Night" />
            </div>
            <div class="form-group">
              <label>活动年份</label>
              <input v-model="settings.event_year" type="text" placeholder="2026" />
            </div>
          </div>
        </div>

        <div class="form-section">
          <h3>横幅信息</h3>
          <div class="form-grid">
            <div class="form-group">
              <label>横幅标题（中文）</label>
              <input v-model="settings.banner_title" type="text" />
            </div>
            <div class="form-group">
              <label>横幅标题（英文）</label>
              <input v-model="settings.banner_title_en" type="text" />
            </div>
            <div class="form-group full-width">
              <label>横幅副标题（中文）</label>
              <input v-model="settings.banner_subtitle" type="text" />
            </div>
            <div class="form-group full-width">
              <label>横幅副标题（英文）</label>
              <input v-model="settings.banner_subtitle_en" type="text" />
            </div>
          </div>
        </div>

        <div class="form-section">
          <h3>活动信息</h3>
          <div class="form-grid">
            <div class="form-group">
              <label>活动主题（中文）</label>
              <input v-model="settings.event_theme" type="text" />
            </div>
            <div class="form-group">
              <label>活动主题（英文）</label>
              <input v-model="settings.event_theme_en" type="text" />
            </div>
            <div class="form-group">
              <label>活动日期（中文）</label>
              <input v-model="settings.event_date" type="text" placeholder="如：2026年2月14日" />
            </div>
            <div class="form-group">
              <label>活动日期（英文）</label>
              <input v-model="settings.event_date_en" type="text" placeholder="如：February 14, 2026" />
            </div>
            <div class="form-group">
              <label>活动地点（中文）</label>
              <input v-model="settings.event_location" type="text" />
            </div>
            <div class="form-group">
              <label>活动地点（英文）</label>
              <input v-model="settings.event_location_en" type="text" />
            </div>
            <div class="form-group full-width">
              <label>详细地址（中文）</label>
              <input v-model="settings.event_address" type="text" />
            </div>
            <div class="form-group full-width">
              <label>详细地址（英文）</label>
              <input v-model="settings.event_address_en" type="text" />
            </div>
          </div>
        </div>

        <div class="form-section">
          <h3>活动介绍</h3>
          <div class="form-grid">
            <div class="form-group full-width">
              <label>活动介绍（中文）</label>
              <textarea v-model="settings.about_content" rows="4"></textarea>
            </div>
            <div class="form-group full-width">
              <label>活动介绍（英文）</label>
              <textarea v-model="settings.about_content_en" rows="4"></textarea>
            </div>
          </div>
        </div>

        <div class="form-section">
          <h3>联系方式与社交媒体</h3>
          <div class="form-grid">
            <div class="form-group">
              <label>联系邮箱</label>
              <input v-model="settings.contact_email" type="email" />
            </div>
            <div class="form-group">
              <label>Facebook 链接</label>
              <input v-model="settings.facebook_url" type="url" />
            </div>
            <div class="form-group">
              <label>YouTube 链接</label>
              <input v-model="settings.youtube_url" type="url" />
            </div>
            <div class="form-group">
              <label>Instagram 链接</label>
              <input v-model="settings.instagram_url" type="url" />
            </div>
          </div>
        </div>

        <div class="form-section">
          <h3>其他设置</h3>
          <div class="form-grid">
            <div class="form-group checkbox-group">
              <label class="checkbox-label">
                <input type="checkbox" v-model="settings.show_programs_link" />
                <span>显示节目单链接</span>
              </label>
            </div>
          </div>
        </div>
      </form>
    </div>

    <!-- Sponsors Section -->
    <div v-if="activeTab === 'sponsors'" class="content-section">
      <div class="section-header">
        <h2>赞助商管理</h2>
        <button class="add-btn" @click="openSponsorModal()">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          添加赞助商
        </button>
      </div>

      <div v-if="loadingSponsors" class="loading-state">
        <div class="spinner"></div>
        <span>加载中...</span>
      </div>

      <div v-else class="items-grid">
        <div v-for="sponsor in sponsors" :key="sponsor.id" class="item-card">
          <div class="item-image">
            <img v-if="sponsor.logo" :src="sponsor.logo" :alt="sponsor.name" />
            <div v-else class="placeholder-image">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                  d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
            </div>
          </div>
          <div class="item-info">
            <h3>{{ sponsor.name }}</h3>
            <span class="level-badge" :class="sponsor.level">{{ getLevelText(sponsor.level) }}</span>
          </div>
          <div class="item-actions">
            <button class="edit-btn" @click="openSponsorModal(sponsor)">编辑</button>
            <button class="delete-btn" @click="deleteSponsorItem(sponsor)">删除</button>
          </div>
        </div>

        <div v-if="sponsors.length === 0" class="empty-state">
          <p>暂无赞助商</p>
        </div>
      </div>
    </div>

    <!-- Organizers Section -->
    <div v-if="activeTab === 'organizers'" class="content-section">
      <div class="section-header">
        <h2>承办单位管理</h2>
        <button class="add-btn" @click="openOrganizerModal()">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          添加单位
        </button>
      </div>

      <div v-if="loadingOrganizers" class="loading-state">
        <div class="spinner"></div>
        <span>加载中...</span>
      </div>

      <div v-else class="items-grid">
        <div v-for="org in organizers" :key="org.id" class="item-card">
          <div class="item-image">
            <img v-if="org.logo" :src="org.logo" :alt="org.name" />
            <div v-else class="placeholder-image">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                  d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
              </svg>
            </div>
          </div>
          <div class="item-info">
            <h3>{{ org.name }}</h3>
            <span class="type-badge" :class="org.type">{{ getTypeText(org.type) }}</span>
          </div>
          <div class="item-actions">
            <button class="edit-btn" @click="openOrganizerModal(org)">编辑</button>
            <button class="delete-btn" @click="deleteOrganizerItem(org)">删除</button>
          </div>
        </div>

        <div v-if="organizers.length === 0" class="empty-state">
          <p>暂无承办单位</p>
        </div>
      </div>
    </div>

    <!-- Sponsor Modal -->
    <div v-if="sponsorModal.show" class="modal-overlay" @click.self="closeSponsorModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>{{ sponsorModal.isEdit ? '编辑赞助商' : '添加赞助商' }}</h2>
          <button class="close-btn" @click="closeSponsorModal">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>赞助商名称（中文）</label>
            <input v-model="sponsorModal.data.name" type="text" placeholder="输入名称" />
          </div>
          <div class="form-group">
            <label>赞助商名称（英文）</label>
            <input v-model="sponsorModal.data.name_en" type="text" placeholder="输入英文名称" />
          </div>
          <div class="form-group">
            <label>赞助级别</label>
            <select v-model="sponsorModal.data.level">
              <option value="title">冠名赞助</option>
              <option value="gold">金牌赞助</option>
              <option value="silver">银牌赞助</option>
              <option value="bronze">友好赞助</option>
            </select>
          </div>
          <div class="form-group">
            <label>Logo 图片链接</label>
            <input v-model="sponsorModal.data.logo" type="url" placeholder="https://..." />
          </div>
          <div class="form-group">
            <label>官网链接</label>
            <input v-model="sponsorModal.data.url" type="url" placeholder="https://..." />
          </div>
          <div class="form-group">
            <label>排序（数字越小越靠前）</label>
            <input v-model.number="sponsorModal.data.sort" type="number" />
          </div>
        </div>
        <div class="modal-footer">
          <button class="cancel-btn" @click="closeSponsorModal">取消</button>
          <button class="submit-btn" @click="saveSponsor" :disabled="sponsorModal.saving">
            {{ sponsorModal.saving ? '保存中...' : '保存' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Organizer Modal -->
    <div v-if="organizerModal.show" class="modal-overlay" @click.self="closeOrganizerModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>{{ organizerModal.isEdit ? '编辑单位' : '添加单位' }}</h2>
          <button class="close-btn" @click="closeOrganizerModal">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label>单位名称（中文）</label>
            <input v-model="organizerModal.data.name" type="text" placeholder="输入名称" />
          </div>
          <div class="form-group">
            <label>单位名称（英文）</label>
            <input v-model="organizerModal.data.name_en" type="text" placeholder="输入英文名称" />
          </div>
          <div class="form-group">
            <label>单位类型</label>
            <select v-model="organizerModal.data.type">
              <option value="organizer">主办单位</option>
              <option value="co-organizer">协办单位</option>
            </select>
          </div>
          <div class="form-group">
            <label>Logo 图片链接</label>
            <input v-model="organizerModal.data.logo" type="url" placeholder="https://..." />
          </div>
          <div class="form-group">
            <label>排序（数字越小越靠前）</label>
            <input v-model.number="organizerModal.data.sort" type="number" />
          </div>
        </div>
        <div class="modal-footer">
          <button class="cancel-btn" @click="closeOrganizerModal">取消</button>
          <button class="submit-btn" @click="saveOrganizer" :disabled="organizerModal.saving">
            {{ organizerModal.saving ? '保存中...' : '保存' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getSettings } from '@/cms'
import { 
  updateChunwanSettings, 
  getAdminSponsors, 
  createSponsor, 
  updateSponsor, 
  deleteSponsor,
  getAdminOrganizers,
  createOrganizer,
  updateOrganizer,
  deleteOrganizer
} from '@/supabase'

export default {
  name: 'ContentManagement',
  data() {
    return {
      activeTab: 'settings',
      tabs: [
        { key: 'settings', label: '全局设置', icon: 'svg' },
        { key: 'sponsors', label: '赞助商', icon: 'svg' },
        { key: 'organizers', label: '承办单位', icon: 'svg' }
      ],
      // Settings
      settings: {},
      loadingSettings: true,
      saving: false,
      // Sponsors
      sponsors: [],
      loadingSponsors: false,
      sponsorModal: {
        show: false,
        isEdit: false,
        saving: false,
        data: this.getEmptySponsor()
      },
      // Organizers
      organizers: [],
      loadingOrganizers: false,
      organizerModal: {
        show: false,
        isEdit: false,
        saving: false,
        data: this.getEmptyOrganizer()
      }
    }
  },
  mounted() {
    this.loadSettings()
    this.loadSponsors()
    this.loadOrganizers()
  },
  methods: {
    getEmptySponsor() {
      return { name: '', name_en: '', level: 'gold', logo: '', url: '', sort: 0 }
    },
    getEmptyOrganizer() {
      return { name: '', name_en: '', type: 'organizer', logo: '', sort: 0 }
    },
    async loadSettings() {
      this.loadingSettings = true
      try {
        const data = await getSettings()
        this.settings = data || {}
      } catch (err) {
        console.error('Failed to load settings:', err)
      } finally {
        this.loadingSettings = false
      }
    },
    async saveSettings() {
      this.saving = true
      try {
        await updateChunwanSettings(this.settings)
        alert('设置已保存')
      } catch (err) {
        console.error('Failed to save settings:', err)
        alert('保存失败，请重试')
      } finally {
        this.saving = false
      }
    },
    async loadSponsors() {
      this.loadingSponsors = true
      try {
        this.sponsors = await getAdminSponsors()
      } catch (err) {
        console.error('Failed to load sponsors:', err)
      } finally {
        this.loadingSponsors = false
      }
    },
    openSponsorModal(sponsor = null) {
      if (sponsor) {
        this.sponsorModal.isEdit = true
        this.sponsorModal.data = { ...sponsor }
      } else {
        this.sponsorModal.isEdit = false
        this.sponsorModal.data = this.getEmptySponsor()
      }
      this.sponsorModal.show = true
    },
    closeSponsorModal() {
      this.sponsorModal.show = false
    },
    async saveSponsor() {
      if (!this.sponsorModal.data.name) {
        alert('请输入赞助商名称')
        return
      }
      this.sponsorModal.saving = true
      try {
        if (this.sponsorModal.isEdit) {
          await updateSponsor(this.sponsorModal.data.id, this.sponsorModal.data)
        } else {
          await createSponsor(this.sponsorModal.data)
        }
        await this.loadSponsors()
        this.closeSponsorModal()
      } catch (err) {
        console.error('Failed to save sponsor:', err)
        alert('保存失败，请重试')
      } finally {
        this.sponsorModal.saving = false
      }
    },
    async deleteSponsorItem(sponsor) {
      if (!confirm(`确定要删除赞助商 "${sponsor.name}" 吗？`)) return
      try {
        await deleteSponsor(sponsor.id)
        await this.loadSponsors()
      } catch (err) {
        console.error('Failed to delete sponsor:', err)
        alert('删除失败，请重试')
      }
    },
    getLevelText(level) {
      const map = { title: '冠名赞助', gold: '金牌赞助', silver: '银牌赞助', bronze: '友好赞助' }
      return map[level] || level
    },
    async loadOrganizers() {
      this.loadingOrganizers = true
      try {
        this.organizers = await getAdminOrganizers()
      } catch (err) {
        console.error('Failed to load organizers:', err)
      } finally {
        this.loadingOrganizers = false
      }
    },
    openOrganizerModal(org = null) {
      if (org) {
        this.organizerModal.isEdit = true
        this.organizerModal.data = { ...org }
      } else {
        this.organizerModal.isEdit = false
        this.organizerModal.data = this.getEmptyOrganizer()
      }
      this.organizerModal.show = true
    },
    closeOrganizerModal() {
      this.organizerModal.show = false
    },
    async saveOrganizer() {
      if (!this.organizerModal.data.name) {
        alert('请输入单位名称')
        return
      }
      this.organizerModal.saving = true
      try {
        if (this.organizerModal.isEdit) {
          await updateOrganizer(this.organizerModal.data.id, this.organizerModal.data)
        } else {
          await createOrganizer(this.organizerModal.data)
        }
        await this.loadOrganizers()
        this.closeOrganizerModal()
      } catch (err) {
        console.error('Failed to save organizer:', err)
        alert('保存失败，请重试')
      } finally {
        this.organizerModal.saving = false
      }
    },
    async deleteOrganizerItem(org) {
      if (!confirm(`确定要删除单位 "${org.name}" 吗？`)) return
      try {
        await deleteOrganizer(org.id)
        await this.loadOrganizers()
      } catch (err) {
        console.error('Failed to delete organizer:', err)
        alert('删除失败，请重试')
      }
    },
    getTypeText(type) {
      const map = { organizer: '主办单位', 'co-organizer': '协办单位' }
      return map[type] || type
    }
  }
}
</script>

<style scoped>
.content-management {
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

/* Tabs */
.tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 24px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  padding-bottom: 16px;
}

.tab-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.03);
  color: rgba(255, 255, 255, 0.6);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.tab-btn:hover {
  background: rgba(255, 255, 255, 0.08);
  color: #fff;
}

.tab-btn.active {
  background: rgba(233, 69, 96, 0.15);
  border-color: rgba(233, 69, 96, 0.4);
  color: #e94560;
}

/* Content Section */
.content-section {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  padding: 24px;
}

.section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}

.section-header h2 {
  font-size: 18px;
  font-weight: 600;
  margin: 0;
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
  border-top-color: #e94560;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Settings Form */
.settings-form {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.form-section h3 {
  font-size: 14px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.5);
  margin: 0 0 16px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.form-group.full-width {
  grid-column: 1 / -1;
}

.form-group label {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.7);
}

.form-group input,
.form-group textarea,
.form-group select {
  padding: 12px 14px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
  font-size: 14px;
  transition: all 0.3s ease;
}

.form-group input::placeholder,
.form-group textarea::placeholder {
  color: rgba(255, 255, 255, 0.3);
}

.form-group input:focus,
.form-group textarea:focus,
.form-group select:focus {
  outline: none;
  border-color: #e94560;
  background: rgba(255, 255, 255, 0.08);
}

.form-group textarea {
  resize: vertical;
  min-height: 100px;
}

.form-group select {
  cursor: pointer;
}

.checkbox-group {
  flex-direction: row;
  align-items: center;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
}

.checkbox-label input[type="checkbox"] {
  width: 18px;
  height: 18px;
  cursor: pointer;
}

/* Buttons */
.save-btn {
  padding: 10px 20px;
  border-radius: 8px;
  border: none;
  background: linear-gradient(135deg, #e94560 0%, #ff6b6b 100%);
  color: white;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.save-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 15px rgba(233, 69, 96, 0.3);
}

.save-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.add-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 16px;
  border-radius: 8px;
  border: 1px solid rgba(76, 175, 80, 0.4);
  background: rgba(76, 175, 80, 0.15);
  color: #4caf50;
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.add-btn:hover {
  background: rgba(76, 175, 80, 0.25);
}

.add-btn svg {
  width: 16px;
  height: 16px;
}

/* Items Grid */
.items-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 16px;
}

.item-card {
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  overflow: hidden;
  transition: all 0.3s ease;
}

.item-card:hover {
  border-color: rgba(255, 255, 255, 0.15);
  transform: translateY(-2px);
}

.item-image {
  height: 120px;
  background: rgba(0, 0, 0, 0.2);
  display: flex;
  align-items: center;
  justify-content: center;
}

.item-image img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
  padding: 16px;
}

.placeholder-image {
  color: rgba(255, 255, 255, 0.2);
}

.placeholder-image svg {
  width: 48px;
  height: 48px;
}

.item-info {
  padding: 16px;
}

.item-info h3 {
  font-size: 15px;
  font-weight: 500;
  margin: 0 0 8px;
}

.level-badge, .type-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.level-badge.title {
  background: rgba(255, 193, 7, 0.15);
  color: #ffc107;
}

.level-badge.gold {
  background: rgba(255, 152, 0, 0.15);
  color: #ff9800;
}

.level-badge.silver {
  background: rgba(158, 158, 158, 0.15);
  color: #9e9e9e;
}

.level-badge.bronze {
  background: rgba(121, 85, 72, 0.15);
  color: #8d6e63;
}

.type-badge.organizer {
  background: rgba(33, 150, 243, 0.15);
  color: #2196f3;
}

.type-badge.co-organizer {
  background: rgba(156, 39, 176, 0.15);
  color: #9c27b0;
}

.item-actions {
  display: flex;
  gap: 8px;
  padding: 12px 16px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.edit-btn, .delete-btn {
  flex: 1;
  padding: 8px;
  border-radius: 6px;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
}

.edit-btn {
  background: rgba(33, 150, 243, 0.15);
  color: #2196f3;
}

.edit-btn:hover {
  background: rgba(33, 150, 243, 0.25);
}

.delete-btn {
  background: rgba(244, 67, 54, 0.15);
  color: #f44336;
}

.delete-btn:hover {
  background: rgba(244, 67, 54, 0.25);
}

.empty-state {
  grid-column: 1 / -1;
  text-align: center;
  padding: 40px;
  color: rgba(255, 255, 255, 0.4);
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
  max-width: 500px;
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
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.modal-footer {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  padding: 16px 24px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.cancel-btn {
  padding: 10px 20px;
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: transparent;
  color: rgba(255, 255, 255, 0.7);
  font-size: 14px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.cancel-btn:hover {
  background: rgba(255, 255, 255, 0.05);
  color: #fff;
}

.submit-btn {
  padding: 10px 20px;
  border-radius: 8px;
  border: none;
  background: linear-gradient(135deg, #e94560 0%, #ff6b6b 100%);
  color: white;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 15px rgba(233, 69, 96, 0.3);
}

.submit-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
</style>
