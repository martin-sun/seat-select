<template>
  <div class="markdown-renderer" v-html="renderedHtml"></div>
</template>

<script>
import { computed } from 'vue'
import { marked } from 'marked'
import DOMPurify from 'dompurify'

export default {
  name: 'MarkdownRenderer',
  props: {
    content: {
      type: String,
      default: ''
    }
  },
  setup(props) {
    const renderedHtml = computed(() => {
      if (!props.content) return ''
      const rawHtml = marked(props.content)
      return DOMPurify.sanitize(rawHtml)
    })

    return {
      renderedHtml
    }
  }
}
</script>

<style>
/* Non-scoped styles to apply globally to markdown content */
.markdown-renderer {
  line-height: 1.7;
}

.markdown-renderer h1,
.markdown-renderer h2,
.markdown-renderer h3,
.markdown-renderer h4,
.markdown-renderer h5,
.markdown-renderer h6 {
  font-weight: 600;
  margin: 1rem 0 0.5rem;
}

.markdown-renderer h1 { font-size: 1.5rem; }
.markdown-renderer h2 { font-size: 1.25rem; }
.markdown-renderer h3 { font-size: 1.125rem; }

.markdown-renderer p {
  margin: 0.5rem 0;
}

.markdown-renderer a {
  text-decoration: underline;
}

.markdown-renderer strong,
.markdown-renderer b {
  font-weight: 600;
}

.markdown-renderer em,
.markdown-renderer i {
  font-style: italic;
}

.markdown-renderer code {
  background: rgba(255, 255, 255, 0.1);
  padding: 0.125rem 0.375rem;
  border-radius: 0.25rem;
  font-family: 'Courier New', monospace;
  font-size: 0.875em;
}

.markdown-renderer pre {
  background: rgba(0, 0, 0, 0.2);
  padding: 1rem;
  border-radius: 0.5rem;
  overflow-x: auto;
  margin: 1rem 0;
}

.markdown-renderer pre code {
  background: transparent;
  padding: 0;
}

.markdown-renderer ul {
  list-style-type: disc;
  padding-left: 1.5rem;
  margin: 0.5rem 0;
}

.markdown-renderer ol {
  list-style-type: decimal;
  padding-left: 1.5rem;
  margin: 0.5rem 0;
}

.markdown-renderer li {
  list-style-type: inherit;
  margin: 0.25rem 0;
}

.markdown-renderer blockquote {
  border-left: 3px solid currentColor;
  padding-left: 1rem;
  margin: 1rem 0;
  opacity: 0.8;
  font-style: italic;
}

.markdown-renderer table {
  width: 100%;
  border-collapse: collapse;
  margin: 1rem 0;
}

.markdown-renderer th,
.markdown-renderer td {
  border: 1px solid rgba(255, 255, 255, 0.1);
  padding: 0.5rem 0.75rem;
  text-align: left;
}

.markdown-renderer th {
  background: rgba(255, 255, 255, 0.05);
  font-weight: 600;
}

.markdown-renderer hr {
  border: none;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  margin: 1.5rem 0;
}

.markdown-renderer img {
  max-width: 100%;
  height: auto;
  border-radius: 0.5rem;
  margin: 1rem 0;
}
</style>
