<template>
  <div class="programs-management">
    <div class="page-header">
      <h1>节目单管理</h1>
      <p class="subtitle">管理春晚节目列表</p>
    </div>

    <div class="toolbar">
      <button class="add-btn" @click="openModal()">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
        添加节目
      </button>
    </div>

    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <span>加载中...</span>
    </div>

    <div v-else class="programs-list">
      <div v-if="programs.length === 0" class="empty-state">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
            d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
        </svg>
        <p>暂无节目</p>
      </div>

      <draggable 
        v-else
        v-model="programs" 
        item-key="id"
        handle=".drag-handle"
        @end="onDragEnd"
        class="programs-grid"
      >
        <template #item="{ element: program, index }">
          <div class="program-card">
            <div class="drag-handle">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8h16M4 16h16" />
              </svg>
            </div>
            <div class="program-order">{{ index + 1 }}</div>
            <div class="program-thumbnail">
              <img v-if="program.thumbnail" :src="program.thumbnail" :alt="program.title" />
              <div v-else class="placeholder-thumbnail">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                    d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
                </svg>
              </div>
            </div>
            <div class="program-info">
              <h3>{{ program.title }}</h3>
              <p v-if="program.title_en" class="subtitle-en">{{ program.title_en }}</p>
              <div class="program-meta">
                <span class="type-badge" :class="program.type">{{ getTypeText(program.type) }}</span>
                <span class="performers">{{ program.performers }}</span>
              </div>
              <p v-if="program.description" class="description">{{ program.description }}</p>
            </div>
            <div class="program-status">
              <span :class="['status-badge', program.status]">
                {{ program.status === 'published' ? '已发布' : '草稿' }}
              </span>
            </div>
            <div class="program-actions">
              <button class="edit-btn" @click="openModal(program)">编辑</button>
              <button class="delete-btn" @click="deleteItem(program)">删除</button>
            </div>
          </div>
        </template>
      </draggable>
    </div>

    <!-- Edit Modal -->
    <div v-if="modal.show" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content">
        <div class="modal-header">
          <h2>{{ modal.isEdit ? '编辑节目' : '添加节目' }}</h2>
          <button class="close-btn" @click="closeModal">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-row">
            <div class="form-group">
              <label>节目名称（中文）<span class="required">*</span></label>
              <input v-model="modal.data.title" type="text" placeholder="如：开场舞：盛世欢腾" />
            </div>
            <div class="form-group">
              <label>节目名称（英文）</label>
              <input v-model="modal.data.title_en" type="text" placeholder="如：Opening Dance" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>节目类型</label>
              <select v-model="modal.data.type">
                <option value="song">歌曲</option>
                <option value="dance">舞蹈</option>
                <option value="skit">小品</option>
                <option value="opera">戏曲</option>
                <option value="acrobatics">杂技/武术</option>
                <option value="other">其他</option>
              </select>
            </div>
            <div class="form-group">
              <label>状态</label>
              <select v-model="modal.data.status">
                <option value="published">已发布</option>
                <option value="draft">草稿</option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label>表演者（中文）</label>
              <input v-model="modal.data.performers" type="text" placeholder="如：萨斯卡通舞蹈团" />
            </div>
            <div class="form-group">
              <label>表演者（英文）</label>
              <input v-model="modal.data.performers_en" type="text" placeholder="如：Saskatoon Dance Group" />
            </div>
          </div>
          <div class="form-group">
            <label>缩略图链接</label>
            <input v-model="modal.data.thumbnail" type="url" placeholder="https://..." />
          </div>
          <div class="form-row">
            <div class="form-group full-width">
              <label>节目简介（中文）</label>
              <textarea v-model="modal.data.description" rows="2" placeholder="简短描述节目内容"></textarea>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group full-width">
              <label>节目简介（英文）</label>
              <textarea v-model="modal.data.description_en" rows="2" placeholder="Brief description in English"></textarea>
            </div>
          </div>
          <div class="form-group">
            <label>排序（数字越小越靠前）</label>
            <input v-model.number="modal.data.sort" type="number" />
          </div>
        </div>
        <div class="modal-footer">
          <button class="cancel-btn" @click="closeModal">取消</button>
          <button class="submit-btn" @click="saveProgram" :disabled="modal.saving">
            {{ modal.saving ? '保存中...' : '保存' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getAdminPrograms, createProgram, updateProgram, deleteProgram } from '@/supabase'
import draggable from 'vuedraggable'

export default {
  name: 'ProgramsManagement',
  components: { draggable },
  data() {
    return {
      programs: [],
      loading: true,
      modal: {
        show: false,
        isEdit: false,
        saving: false,
        data: this.getEmptyProgram()
      }
    }
  },
  mounted() {
    this.loadPrograms()
  },
  methods: {
    getEmptyProgram() {
      return {
        title: '',
        title_en: '',
        type: 'song',
        performers: '',
        performers_en: '',
        description: '',
        description_en: '',
        thumbnail: '',
        sort: 0,
        status: 'published'
      }
    },
    async loadPrograms() {
      this.loading = true
      try {
        this.programs = await getAdminPrograms()
      } catch (err) {
        console.error('Failed to load programs:', err)
      } finally {
        this.loading = false
      }
    },
    openModal(program = null) {
      if (program) {
        this.modal.isEdit = true
        this.modal.data = { ...program }
      } else {
        this.modal.isEdit = false
        this.modal.data = this.getEmptyProgram()
        // Set sort to be after the last program
        if (this.programs.length > 0) {
          this.modal.data.sort = Math.max(...this.programs.map(p => p.sort || 0)) + 1
        }
      }
      this.modal.show = true
    },
    closeModal() {
      this.modal.show = false
    },
    async saveProgram() {
      if (!this.modal.data.title) {
        alert('请输入节目名称')
        return
      }
      this.modal.saving = true
      try {
        if (this.modal.isEdit) {
          await updateProgram(this.modal.data.id, this.modal.data)
        } else {
          await createProgram(this.modal.data)
        }
        await this.loadPrograms()
        this.closeModal()
      } catch (err) {
        console.error('Failed to save program:', err)
        alert('保存失败，请重试')
      } finally {
        this.modal.saving = false
      }
    },
    async deleteItem(program) {
      if (!confirm(`确定要删除节目 "${program.title}" 吗？`)) return
      try {
        await deleteProgram(program.id)
        await this.loadPrograms()
      } catch (err) {
        console.error('Failed to delete program:', err)
        alert('删除失败，请重试')
      }
    },
    async onDragEnd() {
      // Update sort order for all programs
      try {
        for (let i = 0; i < this.programs.length; i++) {
          if (this.programs[i].sort !== i + 1) {
            await updateProgram(this.programs[i].id, { sort: i + 1 })
          }
        }
      } catch (err) {
        console.error('Failed to update sort order:', err)
      }
    },
    getTypeText(type) {
      const map = {
        song: '歌曲',
        dance: '舞蹈',
        skit: '小品',
        opera: '戏曲',
        acrobatics: '杂技',
        other: '其他'
      }
      return map[type] || type
    }
  }
}
</script>

<style scoped>
.programs-management {
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

.toolbar {
  margin-bottom: 24px;
}

.add-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 20px;
  border-radius: 10px;
  border: none;
  background: linear-gradient(135deg, #e94560 0%, #ff6b6b 100%);
  color: white;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.add-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 15px rgba(233, 69, 96, 0.3);
}

.add-btn svg {
  width: 18px;
  height: 18px;
}

.loading-state {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 12px;
  padding: 80px;
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

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 80px;
  color: rgba(255, 255, 255, 0.4);
  background: rgba(255, 255, 255, 0.02);
  border-radius: 12px;
}

.empty-state svg {
  width: 48px;
  height: 48px;
  margin-bottom: 16px;
}

.programs-grid {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.program-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(255, 255, 255, 0.05);
  border-radius: 12px;
  transition: all 0.3s ease;
}

.program-card:hover {
  background: rgba(255, 255, 255, 0.05);
  border-color: rgba(255, 255, 255, 0.1);
}

.drag-handle {
  cursor: grab;
  padding: 8px;
  color: rgba(255, 255, 255, 0.3);
  transition: color 0.3s ease;
}

.drag-handle:hover {
  color: rgba(255, 255, 255, 0.6);
}

.drag-handle svg {
  width: 18px;
  height: 18px;
}

.program-order {
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(233, 69, 96, 0.15);
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  color: #e94560;
}

.program-thumbnail {
  width: 80px;
  height: 60px;
  border-radius: 8px;
  overflow: hidden;
  background: rgba(0, 0, 0, 0.3);
  flex-shrink: 0;
}

.program-thumbnail img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.placeholder-thumbnail {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(255, 255, 255, 0.2);
}

.placeholder-thumbnail svg {
  width: 24px;
  height: 24px;
}

.program-info {
  flex: 1;
  min-width: 0;
}

.program-info h3 {
  font-size: 15px;
  font-weight: 500;
  margin: 0 0 4px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.subtitle-en {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
  margin: 0 0 8px;
}

.program-meta {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 6px;
}

.type-badge {
  padding: 3px 8px;
  border-radius: 4px;
  font-size: 11px;
  font-weight: 500;
}

.type-badge.song {
  background: rgba(156, 39, 176, 0.15);
  color: #ce93d8;
}

.type-badge.dance {
  background: rgba(233, 30, 99, 0.15);
  color: #f48fb1;
}

.type-badge.skit {
  background: rgba(255, 152, 0, 0.15);
  color: #ffb74d;
}

.type-badge.opera {
  background: rgba(76, 175, 80, 0.15);
  color: #81c784;
}

.type-badge.acrobatics {
  background: rgba(33, 150, 243, 0.15);
  color: #64b5f6;
}

.type-badge.other {
  background: rgba(158, 158, 158, 0.15);
  color: #9e9e9e;
}

.performers {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
}

.description {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.4);
  margin: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.program-status {
  flex-shrink: 0;
}

.status-badge {
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.status-badge.published {
  background: rgba(76, 175, 80, 0.15);
  color: #4caf50;
}

.status-badge.draft {
  background: rgba(158, 158, 158, 0.15);
  color: #9e9e9e;
}

.program-actions {
  display: flex;
  gap: 8px;
  flex-shrink: 0;
}

.edit-btn, .delete-btn {
  padding: 8px 14px;
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
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
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

.required {
  color: #e94560;
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
  min-height: 60px;
}

.form-group select {
  cursor: pointer;
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
