<template>
  <div class="milkdown-crepe-editor">
    <div ref="editorRoot"></div>
  </div>
</template>

<script>
import { ref, onMounted, onBeforeUnmount } from 'vue'
import { Crepe } from '@milkdown/crepe'

export default {
  name: 'MilkdownCrepeEditor',
  props: {
    modelValue: {
      type: String,
      default: ''
    },
    placeholder: {
      type: String,
      default: '输入内容...'
    }
  },
  emits: ['update:modelValue'],
  setup(props, { emit }) {
    const editorRoot = ref(null)
    let crepe = null

    onMounted(async () => {
      crepe = new Crepe({
        root: editorRoot.value,
        defaultValue: props.modelValue || ''
      })

      const editor = await crepe.create()

      // 监听内容变化
      editor.action((ctx) => {
        ctx.get('listener').markdownUpdated((ctx, markdown) => {
          emit('update:modelValue', markdown)
        })
      })
    })

    onBeforeUnmount(async () => {
      if (crepe) {
        await crepe.destroy()
      }
    })

    return {
      editorRoot
    }
  }
}
</script>

<style>
/* Import Milkdown Crepe styles using absolute paths */
@import '../../node_modules/@milkdown/crepe/lib/theme/common/style.css';
@import '../../node_modules/@milkdown/crepe/lib/theme/common/toolbar.css';
@import '../../node_modules/@milkdown/crepe/lib/theme/common/list-item.css';
@import '../../node_modules/@milkdown/crepe/lib/theme/common/block-edit.css';
@import '../../node_modules/@milkdown/crepe/lib/theme/crepe-dark/style.css';
</style>

<style scoped>
.milkdown-crepe-editor {
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.05);
  overflow: hidden;
  min-height: 200px;
}

/* Override Milkdown colors for dark theme */
.milkdown-crepe-editor :deep(.milkdown) {
  background: transparent !important;
}

.milkdown-crepe-editor :deep(.milkdown .editor) {
  outline: none;
  padding: 16px;
  min-height: 200px;
  color: #fff;
}

.milkdown-crepe-editor :deep(.milkdown .prosemirror) {
  outline: none;
}

/* Fix toolbar display */
.milkdown-crepe-editor :deep(.milkdown .crepe-toolbar) {
  display: flex !important;
  background: rgba(0, 0, 0, 0.3) !important;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1) !important;
  padding: 8px;
  gap: 4px;
  flex-wrap: wrap;
}

.milkdown-crepe-editor :deep(.milkdown .crepe-toolbar button) {
  display: flex !important;
  align-items: center;
  justify-content: center;
  min-width: 32px;
  height: 32px;
  padding: 4px 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.05);
  color: rgba(255, 255, 255, 0.8);
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.milkdown-crepe-editor :deep(.milkdown .crepe-toolbar button:hover) {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
}

.milkdown-crepe-editor :deep(.milkdown .crepe-toolbar button.active) {
  background: rgba(233, 69, 96, 0.3);
  border-color: rgba(233, 69, 96, 0.5);
  color: #e94560;
}

.milkdown-crepe-editor :deep(.milkdown .crepe-toolbar button svg) {
  width: 18px;
  height: 18px;
}

.milkdown-crepe-editor :deep(.milkdown .crepe-toolbar .crepe-toolbar-group) {
  display: flex;
  gap: 4px;
  margin-right: 8px;
}

.milkdown-crepe-editor :deep(.milkdown .crepe-toolbar .crepe-toolbar-group:last-child) {
  margin-right: 0;
}
</style>
