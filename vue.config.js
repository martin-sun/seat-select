const { defineConfig } = require('@vue/cli-service')

module.exports = defineConfig({
  // 基本路径
  publicPath: '/',
  // 如果您不需要生产时的源映射，那么将此设置为false可以加速生产构建
  productionSourceMap: false,
  transpileDependencies: true,
  devServer: {
    proxy: {
      '/mock': {
        target: 'http://localhost:80',
        pathRewrite: {
          '^/mock': '/mock'
        }
      }
    }
  }
})
